-- AUTO GENERATED - NEEDS UPDATING

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local CATEGORY_ID = BtWQuests.Constant.Category.Dragonflight.TheWakingShores
local Chain = BtWQuests.Constant.Chain.Dragonflight.TheWakingShores
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.DragonflightToF
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 2022
local CONTINENT_ID = 1978
local ACHIEVEMENT_ID_1 = 16334
local ACHIEVEMENT_ID_2 = 16401
local LEVEL_RANGE = {58, 70}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 58,
    },
}

Chain.TheDragonscaleExpedition = 100101
Chain.DragonsInDistress = 100102
Chain.InDefenseOfLife = 100103
Chain.WrathionsGambit = 100104
Chain.APurposeRestored = 100105
Chain.TempChain01 = 100111
Chain.TempChain02 = 100112
Chain.TempChain03 = 100113
Chain.TempChain04 = 100114
Chain.TempChain05 = 100115
Chain.TempChain06 = 100116
Chain.TempChain07 = 100117
Chain.TempChain08 = 100118
Chain.TempChain09 = 100119
Chain.TempChain13 = 100123
Chain.TempChain14 = 100124
Chain.TempChain15 = 100125
Chain.TempChain16 = 100126
Chain.TempChain17 = 100127
Chain.TempChain19 = 100129
Chain.TempChain21 = 100131
Chain.TempChain23 = 100133
Chain.TempChain26 = 100136
Chain.TempChain27 = 100137
Chain.TempChain28 = 100138
Chain.TempChain29 = 100139
Chain.TempChain30 = 100140
Chain.TempChain31 = 100141
Chain.TempChain33 = 100143
Chain.TempChain34 = 100144
Chain.TempChain35 = 100145
Chain.TempChain36 = 100146
Chain.TempChain37 = 100147
Chain.TempChain38 = 100148
Chain.TempChain39 = 100149
Chain.TempChain40 = 100150
Chain.TempChain41 = 100151
Chain.TempChain42 = 100152
Chain.TempChain43 = 100153
Chain.TempChain44 = 100154
Chain.TempChain45 = 100155
Chain.TempChain46 = 100156
Chain.TempChain47 = 100157

Chain.OtherAlliance = 100197
Chain.OtherHorde = 100198
Chain.OtherBoth = 100199

Database:AddChain(Chain.TheDragonscaleExpedition, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 1289,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.DracthyrAwaken,
            restrictions = {
                type = "class",
                id = 13,
            },
        }
    },
    active = {
        type = "quest",
        ids = {65435, 65436, 66577, 65437, 72240, 72256, 66589, 65443},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 69914,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 65436,
                    restrictions = {
                        {
                            type = "faction",
                            id = "Alliance"
                        },
                        {
                            type = "class",
                            ids = {
                                1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
                            },
                        },
                    },
                },
                {
                    type = "quest",
                    id = 65435,
                },
            },
            restrictions = {
                type = "class",
                ids = {
                    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
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
                    id = 66577,
                    restrictions = {
                        {
                            type = "faction",
                            id = "Alliance"
                        },
                        {
                            type = "class",
                            ids = {
                                1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
                            },
                        },
                    },
                },
                {
                    type = "quest",
                    id = 65437,
                },
            },
            restrictions = {
                type = "class",
                ids = {
                    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 
                },
            },
            x = 0,
            connections = {
                3, 4, 
            },
        },
        {
            variations = {
                {
                    type = "npc",
                    id = 189603,
                    restrictions = {
                        {
                            type = "faction",
                            id = "Alliance"
                        },
                        {
                            type = "class",
                            id = 13,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 184786,
                },
            },
            restrictions = {
                type = "class",
                id = 13,
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "npc",
                    id = 189602,
                    restrictions = {
                        {
                            type = "faction",
                            id = "Alliance"
                        },
                        {
                            type = "class",
                            id = 13,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 184793,
                },
            },
            restrictions = {
                type = "class",
                id = 13,
            },
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 72240,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 72256,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 66589,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65443,
                },
            },
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 66596,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65439,
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
                    id = 67700,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65444,
                },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 70123,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65453,
                },
            },
            x = -2,
            connections = {
                5, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 70122,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65452,
                },
            },
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 70124,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65451,
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
                    id = 70125,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 69910,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69911,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69912,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69914,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DragonsInDistress, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 1299,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
        },
    },
    active = {
        type = "quest",
        id = 65760,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66001,
    },
    items = {
        {
            type = "npc",
            id = 193363,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65760,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65989,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65990,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65991,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "kill",
            id = 186777,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65993,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 65992,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65995,
            connections = {
                2, 
            },
            comment = "Can get the item but cant start quest before doing some part of the campaign",
        },
        {
            type = "chain",
            id = Chain.TempChain19,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 65996,
            x = 0,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65997,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 65998,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 65999,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66000,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66001,
            x = -1,
        },
        {
            type = "quest",
            id = 70179,
            aside = true,
        },
    },
})
Database:AddChain(Chain.InDefenseOfLife, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 1300,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
        },
    },
    active = {
        type = "quest",
        id = 66114,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66124,
    },
    items = {
        {
            type = "npc",
            id = 186795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66114,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66115,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 68795,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 70061,
            x = -1,
            connections = {
                8, 
            },
        },
        {
            type = "quest",
            id = 65118,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65120,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65133,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 68796,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 68797,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 68798,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 68799,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66931,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66116,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66118,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66121,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66122,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66119,
            aside = true,
        },
        {
            type = "quest",
            id = 66123,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66124,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WrathionsGambit, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 4),
    questline = 1301,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
        },
    },
    active = {
        type = "quest",
        id = 66079,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66057,
    },
    items = {
        {
            type = "npc",
            id = 187115,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66079,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 72241,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66078,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 66048,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65956,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 65957,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65939,
            x = -1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 66044,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66049,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66055,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66056,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66354,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66057,
            x = 0,
        },
    },
})
Database:AddChain(Chain.APurposeRestored, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 5),
    questline = 1302,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WrathionsGambit,
        },
    },
    active = {
        type = "quest",
        ids = {66779, 66780},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65794,
    },
    items = {
        {
            type = "npc",
            id = 185894,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 187495,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66779,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66780,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65793,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66785,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66788,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65791,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65794,
            x = 0,
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
        ids = {66435, 66436,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66447,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain17,
            aside = true,
            embed = true,
            x = -3,
            y = 0,
        },
        {
            type = "chain",
            id = Chain.TempChain23,
            aside = true,
            embed = true,
            x = 3,
            y = 0,
        },
        { -- Isolated questline, no apparent requirements. 69896 is a possible breadcrumb, currently (2022-09-11) leads to npc but not either quest, might change
            type = "npc",
            id = 188735,
            x = 0,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66435,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 66436,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66441,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 66438,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66439,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66447,
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
        ids = {69897, 69898,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 69902,
    },
    items = {
        { -- no apparent requirements
            type = "npc",
            id = 193500,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 69897,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 69898,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69899,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 69900,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 69901,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69902,
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
        ids = {66524, 66963},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66529,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 66963,
                    restrictions = {
                        type = "quest",
                        id = 66963,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 187705,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66524,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66525,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66526,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66527,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66528,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66529,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain04, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
            upto = 66114,
        },
    },
    active = {
        type = "quest",
        id = 66825,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {
            66737,66831,66893,66892
        },
        count = 4,
    },
    items = {
        {
            type = "npc",
            id = 191025,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66825,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = Chain.TempChain07,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.TempChain08,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.TempChain09,
            embed = true,
            x = 2,
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
        ids = {66105, 66107,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66108,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 72122,
                    restrictions = {
                        type = "quest",
                        id = 72122,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 186410,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 186428,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66105,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66107,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66104,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66106,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 66108,
        },
        {
            type = "quest",
            id = 66196,
            aside = true,
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
        ids = {65687, 65690,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65691,
    },
    items = {
        { -- No apparently requirements
            type = "npc",
            id = 185627,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65687,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65690,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65782,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65691,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 66737,
    },
    items = {
        {
            type = "quest",
            id = 66997,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66734,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66735,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66737,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain08, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 66831,
    },
    items = {
        {
            type = "quest",
            id = 70351,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66827,
            x = 0,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66828,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66830,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66831,
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
        id = 66893,
    },
    items = {
        {
            type = "quest",
            id = 66879,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66892,
            x = -1,
        },
        {
            type = "quest",
            id = 66893,
        },
    },
})
Database:AddChain(Chain.TempChain13, {
    name = { -- A Gift for Miguel
        type = "quest",
        id = 67100,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
            restrictions = THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
            lowPriority = true,
            restrictions = THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
            upto = 66114,
            restrictions = THREADS_OF_FATE_RESTRICTION,
        }
    },
    active = {
        type = "quest",
        id = 67564,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 67137,
    },
    items = {
        {
            type = "npc",
            id = 192498,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67564,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67100,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67137,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
            upto = 66114,
        }
    },
    active = {
        type = "quest",
        id = 70058,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70058,
    },
    items = {
        {
            type = "npc",
            id = 193955,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70058,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
            upto = 66114,
        }
    },
    active = {
        type = "quest",
        id = 70239,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70708,
    },
    items = {
        {
            type = "npc",
            id = 194801,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70239,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70240,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70241,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70242,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70708,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
            upto = 66114,
        }
    },
    active = {
        type = "quest",
        id = 70132,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70134,
    },
    items = {
        {
            type = "npc",
            id = 194076,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70132,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70134,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "item",
            id = 198661,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
            comment = "There is an object to loot but there is also an extra requirement (probably campaign) thats preventing it from showing for my alt",
            onClick = {
                type = "coords",
                mapID = 2022,
                x = 23,
                y = 60,
            },
        },
        {
            type = "quest",
            id = 70268,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
    },
    active = {
        type = "quest",
        id = 70994,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70994,
    },
    items = {
        {
            type = "npc",
            id = 196820,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70994,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
    },
    active = {
        type = "quest",
        id = 66998,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66998,
    },
    items = {
        {
            type = "npc",
            id = 188297,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66998,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = {
        type = "class",
        id = BtWQuests.Constant.Class.Rogue,
    },
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            variations = {
                {
                    upto = 70122,
                    restrictions = 924,
                },
                {
                    upto = 65452,
                }
            }
        }
    },
    active = {
        type = "quest",
        id = 70042,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70042,
    },
    items = {
        {
            type = "npc",
            id = 193838,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70042,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 66437,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66437,
    },
    items = {
        {
            type = "kill",
            id = 187745,
            x = 0,
            connections = {
                1, 
            },
            comment = "No requirements, got from a different mob in the area",
        },
        {
            type = "quest",
            id = 66437,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain26, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 381650,
            x = 0,
            connections = {
                1, 
            },
            comment = "No apparently requirements, No longer available?",
        },
        {
            type = "quest",
            id = 70992,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 193304,
            x = 0,
            connections = {
                1, 
            },
            comment = "No apparently requirements",
        },
        {
            type = "quest",
            id = 66612,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain28, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 196827,
            x = 0,
            connections = {
                1, 
            },
            comment = "No apparently requirements",
        },
        {
            type = "quest",
            id = 71141,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain29, {
    name = BtWQuests_GetAreaName(13729),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
    },
    active = {
        type = "quest",
        ids = {66612, 71141},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {66612, 71141},
        count = 2,
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
    },
})
Database:AddChain(Chain.TempChain30, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 187700,
            comment = "Bunch of single time hand ins, not sure what the deal is. 70822 was available first time here but 70812 wasnt iirc",
        },
        {
            type = "quest",
            id = 70822,
        },
        {
            type = "quest",
            id = 70812,
        },
        {
            type = "npc",
            id = 188265,
        },
        {
            type = "quest",
            id = 70335,
        },
        {
            type = "npc",
            id = 189226,
        },
        {
            type = "quest",
            id = 72023,
            comment = "Not sure when this became available, some time while handing in the previous quests. Was it rep releated?",
        },
    },
})
Database:AddChain(Chain.TempChain31, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 381672,
            x = 0,
            connections = {
                1, 
            },
            comment = "Apparently no requirements, no longer available?",
        },
        {
            type = "quest",
            id = 71011,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain33, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            variations = {
                {
                    upto = 70122,
                    restrictions = 924,
                },
                {
                    upto = 65452,
                }
            }
        }
    },
    active = {
        type = "quest",
        ids = {67053, 66110},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66112,
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 184449,
                    restrictions = 924,
                },
                {
                    type = "npc",
                    id = 184452,
                },
            },
            x = 0,
            connections = {
                1, 
            },
            comment = "unknown requirement",
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 67053,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 66110,
                },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 70135,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 66111,
                },
            },
            x = -1,
            comment = "Triggers achievement criteria Captian Garrick & Sjunka Grimaxe for achievement All Sides of the Story",
        },
        -- {
        --     type = "quest",
        --     id = 69965,
        --     comment = "Requires something else too. Alliance? Engineering? NPC seems to be missing, maybe goes away at 70, or not there for horde? NPC seems to leave when completeing this zone, a new quest becomes available from the same named npc at Ruby Life Pools and this npc vanishes",
        -- },
        {
            type = "quest",
            id = 66112,
        },
    },
})
Database:AddChain(Chain.TempChain34, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            variations = {
                {
                    upto = 70122,
                    restrictions = 924,
                },
                {
                    upto = 65452,
                }
            }
        }
    },
    active = {
        type = "quest",
        id = 66101,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66101,
    },
    items = {
        {
            type = "npc",
            id = 187257,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66101,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain35, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 192498,
            comment = "Seems to become available last quest of zone, need to check this though, only visible if missing a profession. The last few quests may have just phased the area",
        },
        {
            type = "quest",
            id = 70370,
        },
    },
})
Database:AddChain(Chain.TempChain36, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 186869,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72397,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain37, {
    name = BtWQuests_GetAreaName(13732),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
    },
    active = {
        type = "quest",
        ids = {72397, 70995, 70965},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {72397, 70995, 70965},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain39,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain36,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain38,
            embed = true,
        },
    },
})
Database:AddChain(Chain.TempChain38, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 381664,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70995,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain39, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 381579,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70965,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain40, {
    name = BtWQuests_GetAreaName(13728),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
            upto = 66114,
        }
    },
    active = {
        type = "quest",
        ids = {70058, 70239, 70132},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {70058, 70242, 70132},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain14,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain15,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain16,
            embed = true,
        },
    },
})
Database:AddChain(Chain.TempChain41, {
    name = BtWQuests_GetAreaName(13939),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
            variations = {
                {
                    upto = 70122,
                    restrictions = 924,
                },
                {
                    upto = 65452,
                }
            }
        }
    },
    active = {
        type = "quest",
        ids = {66110, 66101},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {66101, 66111, 70135, 66112},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = Chain.TempChain21,
            embed = true,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.TempChain33,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.TempChain34,
            embed = true,
        },
    },
})
Database:AddChain(Chain.TempChain42, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "quest",
            id = 65998,
        },
        {
            type = "quest",
            id = 65999,
        },
        {
            type = "quest",
            id = 66000,
        },
    },
    active = {
        type = "quest",
        id = 70179,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70179,
    },
    items = {
        {
            type = "npc",
            id = 194525,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 70179,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain43, {
    name = L["ANCIENT_WAYGATES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "currency",
            id = 2021,
            amount = 7,
        },
    },
    active = {
        type = "quest",
        ids = {66595, 66597,},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70156,
    },
    items = {
        {
            type = "quest",
            id = 66595,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66597,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66598,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70215,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66582,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70154,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70156,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain44, {
    name = L["CATALOGING_THE_EXPEIDITION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "currency",
            id = 2021,
            amount = 8,
        },
    },
    active = {
        type = "quest",
        ids = {69869, 72525,},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 65486,
    },
    items = {
        {
            type = "quest",
            id = 69869,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72525,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69870,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65486,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain45, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 66003,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 66369,
    },
    items = {
        {
            type = "npc",
            id = 187609,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66003,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66369,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66368,
            aside = true,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain46, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 70414,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 70414,
    },
    items = {
        {
            type = "npc",
            id = 195234,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70414,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain47, {
    name = L["THE_EARTHEN_RING"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        ids = {66003, 70414,},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {66369, 70414,},
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.TheWakingShores.TempChain45,
            embed = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.TheWakingShores.TempChain46,
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
        { -- Djaradin Djustice -- Bonus Objective at Scalecracker Keep
            type = "quest",
            id = 65994,
        },
        { -- Clear the Battlefield -- Bonus Objective at Flashfrost Enclave
            type = "quest",
            id = 66117,
        },
        { -- Dragonhunter Igordan -- Bonus Objective Rare at Scalecracker Keep
            type = "quest",
            id = 66956,
        },
        { -- Klozicc the Ascended -- Bonus Objective Rare at Flashfrost Enclave
            type = "quest",
            id = 66960,
        },
        {
            type = "quest",
            id = 67295,
        },
        {
            type = "quest",
            id = 69946,
        },
        { -- Lookout Mordren
            type = "quest",
            id = 69967,
        },
        {
            type = "quest",
            id = 69979,
        },
        { -- Artisan's Supply: Salamanther Scale
            type = "quest",
            id = 70034,
        },
        { -- Without Purpose
            type = "quest",
            id = 70148,
        },
        { -- A Tinker's Chance
            type = "quest",
            id = 70164,
        },
        { -- Pruning the Preserve -- Bonus Objective
            type = "quest",
            id = 70196,
        },
        { -- Firava the Rekindler -- Bonus Objective Rare?
            type = "quest",
            id = 70648,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 4742927,
    items = {
        {
            type = "chain",
            id = Chain.TheDragonscaleExpedition,
        },
        {
            type = "chain",
            id = Chain.DragonsInDistress,
        },
        {
            type = "chain",
            id = Chain.InDefenseOfLife,
        },
        {
            type = "chain",
            id = Chain.WrathionsGambit,
        },
        {
            type = "chain",
            id = Chain.APurposeRestored,
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
            id = Chain.TempChain29,
        },
        {
            type = "chain",
            id = Chain.TempChain41,
        },
        {
            type = "chain",
            id = Chain.TempChain40,
        },
        {
            type = "chain",
            id = Chain.TempChain13,
        },
        {
            type = "chain",
            id = Chain.TempChain43,
        },
        {
            type = "chain",
            id = Chain.TempChain44,
        },
        {
            type = "chain",
            id = Chain.TempChain47,
        },
--[==[@debug@
        {
            type = "chain",
            id = Chain.TempChain37,
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
        id = Chain.TempChain29,
    },
    {
        type = "chain",
        id = Chain.TempChain14,
    },
    {
        type = "chain",
        id = Chain.TempChain15,
    },
    {
        type = "chain",
        id = Chain.TempChain16,
    },
    {
        type = "chain",
        id = Chain.TempChain21,
    },
    {
        type = "chain",
        id = Chain.TempChain33,
    },
    {
        type = "chain",
        id = Chain.TempChain34,
    },
    {
        type = "chain",
        id = Chain.TempChain42,
    },
    {
        type = "chain",
        id = Chain.TempChain19,
    },
    {
        type = "chain",
        id = Chain.TempChain23,
    },
    {
        type = "chain",
        id = Chain.TempChain43,
    },
    {
        type = "chain",
        id = Chain.TempChain44,
    },
    {
        type = "chain",
        id = Chain.TempChain47,
    },
--[==[@debug@
    {
        type = "chain",
        id = Chain.TempChain13,
    },
--@end-debug@]==]
})
