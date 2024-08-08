local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local CATEGORY_ID = BtWQuests.Constant.Category.Dragonflight.Thaldraszus
local Chain = BtWQuests.Constant.Chain.Dragonflight.Thaldraszus
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.DragonflightToF
local NOT_THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.NOTDragonflightToF
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 2025
local CONTINENT_ID = 1978
local ACHIEVEMENT_ID_1 = 16363
local ACHIEVEMENT_ID_2 = 16398
local LEVEL_RANGE = {60, 70}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        variations = {
            { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
            { level = 66, },
        },
    },
}

Database:AddChain(Chain.ValdrakkenCityOfDragons, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 1310,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 66, },
            },
        },
        {
            type = "achievement",
            id = 16336,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
    },
    active = {
        type = "quest",
        ids = { 66244, 66159 },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66252,
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 190000,
                    restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
                },
                {
                    type = "npc",
                    id = 190000,
                    restrictions = {
                        type = "quest",
                        id = 66244,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 198386,
                    restrictions = {
                        type = "quest",
                        id = 72269,
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
                    id = 66244,
                    restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 66244,
                    restrictions = {
                        type = "quest",
                        id = 66244,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 72269,
                    restrictions = {
                        type = "quest",
                        id = 72269,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 187678,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66159,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66163,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66166,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66167,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66169,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 66246,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66245,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66247,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66248,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66249,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66250,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66251,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66252,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TimeManagement, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 1324,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 66, },
            },
        },
        {
            type = "achievement",
            id = 16336,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.ValdrakkenCityOfDragons,
        },
    },
    active = {
        type = "quest",
        id = 66320,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65962,
    },
    items = {
        {
            type = "npc",
            id = 187669,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66320,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66080,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70136,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66081,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66082,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66083,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66084,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66085,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66087,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65935,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 65947,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65948,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66646,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65938,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65962,
            x = 0,
        },
    },
})
Database:AddChain(Chain.BigTimeAdventurer, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 1323,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 66, },
            },
        },
        {
            type = "achievement",
            id = 16336,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.ValdrakkenCityOfDragons,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TimeManagement,
        },
    },
    active = {
        type = "quest",
        id = 70040,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66221,
    },
    items = {
        {
            type = "npc",
            id = 186931,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70040,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66028,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66029,
            completed = {
                type = "quest",
                id = 66029,
                status = { "active", "completed", },
            },
            connections = {
                9, 
            },
        },
        {
            type = "quest",
            id = 66030,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66031,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66032,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66033,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66035,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 66036,
                    restrictions = ALLIANCE_RESTRICTIONS,
                },
                {
                    type = "quest",
                    id = 66704,
                },
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
                    id = 70373,
                    restrictions = ALLIANCE_RESTRICTIONS,
                },
                {
                    type = "quest",
                    id = 70371,
                },
            },
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66037,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66029,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66660,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66038,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66039,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66040,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66221,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72192,
            aside = true,
            x = 0,
        },
        {
            type = "quest",
            id = 66034,
            visible = false,
            x = 0,
            comment = "Removed?",
        },
    },
})
Database:AddChain(Chain.TempChain01, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 66468,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66472,
    },
    items = {
        { -- Apparently no requirements
            variations = {
                {
                    type = "quest",
                    id = 71179,
                    restrictions = false,
                    comment = "Is this actually a breadcrumb?",
                },
                {
                    type = "npc",
                    id = 189174,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66468,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66470,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66471,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66473,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66472,
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
        ids = {71219, 66100,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66467,
    },
    items = {
        { -- Apparently no requirements
            variations = {
                { -- only goes to 66100
                    type = "quest",
                    id = 71219,
                    restrictions = {
                        type = "quest",
                        id = 71219,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 191753,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66100,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66230,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66456,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66457,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66465,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 66467,
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
        ids = {66071, 65267,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66299,
    },
    items = {
        { -- no apparent requirements
            type = "npc",
            id = 183912,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 184591,
            connections = {
                3, 
            },
        },
        {
            type = "kill",
            id = 184592,
            aside = true,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66071,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 65267,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 65475,
            aside = true,
            x = -3,
            comment = "Check if available without doing other quests",
        },
        {
            type = "quest",
            id = 65313,
            connections = {
                3, 5, 6, 
            },
        },
        {
            type = "quest",
            id = 65490,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 65373,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 65287,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65371,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65374,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65778,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66299,
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
        ids = { 72189, 66134, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66412,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 72189,
                    restrictions = {
                        type = "quest",
                        id = 72189,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 187300,
                },
            },
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66134,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "object",
            id = 376451,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66135,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66278,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66136,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 66137,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66279,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66138,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66139,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66412,
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
        ids = { 72190, 65913, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65920,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 72190,
                    restrictions = {
                        type = "quest",
                        id = 72190,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 190527,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65913,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 70139,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 65918,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65916,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65921,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65920,
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
        id = 69932,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 69934,
    },
    items = {
        { -- No requirements apparently
            type = "npc",
            id = 193538,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 69932,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 69933,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69934,
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
        ids = {72067, 72246,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 70745,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 72067,
                    restrictions = {
                        type = "quest",
                        id = 72067,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 197670,
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "object",
            id = 381297,
            aside = true,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 72246,
            x = 0,
            connections = {
                3, 4, 
            },
        },
        {
            type = "kill",
            id = 197346,
            aside = true,
            x = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 70741,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 70740,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 70738,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 70377,
            aside = true,
        },
        {
            type = "quest",
            id = 70743,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 70744,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70745,
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
        id = 71024,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 70879,
    },
    items = {
        {
            type = "npc",
            id = 189842,
            x = 0,
            connections = {
                1, 
            },
            comment = "unknown requirement, Misty Veil!?",
        },
        {
            type = "quest",
            id = 71024,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70837,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 70838,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 70842,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 70843,
            connections = {
                1, 
            },
            comment = "check if available earlier in quest chain",
        },
        {
            type = "quest",
            id = 70850,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70874,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 70878,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 70875,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 70876,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70879,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 66468,
    },
    items = {
        {
            type = "npc",
            id = 193015,
            x = 0,
            connections = {
                1, 
            },
            comment = "Unknown requirement",
        },
        {
            type = "quest",
            id = 72406,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.TempChain10, {
    name = { -- Archivist Areniel
        type = "npc",
        id = 192543,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 66, },
            },
        },
        {
            type = "achievement",
            id = 16336,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.ValdrakkenCityOfDragons,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TimeManagement,
        },
    },
    active = {
        type = "quest",
        id = 70040,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66468,
    },
    items = {
        {
            type = "npc",
            id = 192543,
            x = 0,
            connections = {
                1, 2, 
            },
            comment = "Requires part of the campaign around to helping chromie, 2 quests arent entirely related",
        },
        {
            type = "quest",
            id = 67093,
            x = -1,
        },
        {
            type = "quest",
            id = 67154,
        },
    },
})
Database:AddChain(Chain.TempChain11, {
    name = { -- A Dryadic Remedy
        type = "quest",
        id = 67606,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    active = {
        type = "quest",
        id = 67094,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 67606,
    },
    items = {
        {
            type = "npc",
            id = 192522,
            x = 0,
            connections = {
                1, 
            },
            comment = "Requirements unknown",
        },
        {
            type = "quest",
            id = 67094,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67606,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain12, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 66468,
    },
    items = {
        {
            type = "object",
            id = 381687,
            x = 0,
            connections = {
                1, 
            },
            comments = "Unknown requirements, seems max level, sends you to the 2 weekly(?) dungeon quests",
        },
        {
            type = "quest",
            id = 67007,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain13, {
    name = { -- The Ruby Feast
        type = "quest",
        id = 71238,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            name = L["UNKNOWN"]
        }
    },
    active = {
        type = "quest",
        ids = { 71238, 70930 },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 67071,
    },
    items = {
        {
            visible = false,
            x = -2,
        },
        -- {
        --     type = "quest",
        --     id = 67055,
        --     x = -1,
        -- },
        -- {
        --     type = "quest",
        --     id = 72009,
        -- },
        {
            variations = {
                {
                    type = "quest",
                    id = 71238,
                    restrictions = {
                        type = "quest",
                        id = 71238,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 189479,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70930,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67047,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 67047,
                },
                {
                    type = "quest",
                    id = 70932,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72009,
                status = { "pending", },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70932,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67063,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 67063,
                },
                {
                    type = "quest",
                    id = 70957,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72009,
                status = { "pending", },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70957,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67064,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 67064,
                },
                {
                    type = "quest",
                    id = 70958,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72009,
                status = { "pending", },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70958,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67065,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 67065,
                },
                {
                    type = "quest",
                    id = 70981,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72009,
                status = { "pending", },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70981,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67066,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 67066,
                },
                {
                    type = "quest",
                    id = 70987,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72009,
                status = { "pending", },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70987,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67067,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 67067,
                },
                {
                    type = "quest",
                    id = 70988,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72009,
                status = { "pending", },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70988,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67068,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 67068,
                },
                {
                    type = "quest",
                    id = 67071,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72009,
                status = { "pending", },
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67071,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain14, {
    name = L["SPARK_OF_INGENUITY"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "achievement",
            id = 16336,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.ValdrakkenCityOfDragons,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TimeManagement,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BigTimeAdventurer,
        },
    },
    active = {
        type = "quest",
        ids = {70846, 72773, 70180,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 70633,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 70846,
                    restrictions = {
                        type = "quest",
                        id = 70846,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 72773,
                    restrictions = {
                        type = "quest",
                        id = 72773,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 196066,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70180,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70845,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70181,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70182,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70633,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 66468,
    },
    items = {
        {
            type = "npc",
            id = 187676,
            x = 0,
            connections = {
                1, 
            },
            comment = "unknown requirement",
        },
        {
            type = "quest",
            id = 72193,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.TempChain16, {
    name = L["BORN_TO_BE_WILDER"],
    questline = 1366,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 66, },
            },
        },
        {
            type = "achievement",
            id = 16336,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.ValdrakkenCityOfDragons,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TimeManagement,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BigTimeAdventurer,
        },
    },
    active = {
        type = "quest",
        id = 70647,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70854,
    },
    items = {
        {
            type = "npc",
            id = 185563,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70647,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70697,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70722,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70732,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70849,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70851,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70853,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70854,
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
        { -- Enraged Steamburst Elemental
            type = "quest",
            id = 69849,
        },
        { -- Sandana the Tempest
            type = "quest",
            id = 69859,
        },
        { -- Lord Epochbrgl
            type = "quest",
            id = 69882,
        },
        { -- Fifth Challenge of Tyr: Ingenuity
            type = "quest",
            id = 70899,
        },
        {
            type = "quest",
            id = 70900,
        },
        { -- Salamanther's Embrace
            type = "quest",
            id = 70934,
        },
        { -- Private Shikzar
            type = "quest",
            id = 70986,
        },
        { -- Stolen Bandages
            type = "quest",
            id = 71164,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 4742929,
    items = {
        {
            type = "chain",
            id = Chain.ValdrakkenCityOfDragons,
        },
        {
            type = "chain",
            id = Chain.TimeManagement,
        },
        {
            type = "chain",
            id = Chain.BigTimeAdventurer,
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
            id = Chain.TempChain13,
        },
        {
            type = "chain",
            id = Chain.TempChain11,
        },
        {
            type = "chain",
            id = Chain.TempChain16,
        },
        {
            type = "chain",
            id = Chain.TempChain10,
        },
--[==[@debug@
        {
            type = "chain",
            id = Chain.TempChain09,
        },
        {
            type = "chain",
            id = Chain.TempChain12,
        },
        {
            type = "chain",
            id = Chain.TempChain15,
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
        id = Chain.TempChain10,
    },
--[==[@debug@
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
--@end-debug@]==]
})
