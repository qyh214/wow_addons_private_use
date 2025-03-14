local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local CATEGORY_ID = BtWQuests.Constant.Category.TheWarWithin.TheRingingDeeps
local Chain = BtWQuests.Constant.Chain.TheWarWithin.TheRingingDeeps
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.TheWarWithinToF
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 724, 723
local MAP_ID = 2214
local CONTINENT_ID = 2274
local ACHIEVEMENT_ID_1 = 19560
local ACHIEVEMENT_ID_2 = 40799
local LEVEL_RANGE = {73, 75}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        variations = {
            { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
            { level = 71, },
        }
    },
}

Chain.ByCandlelight = 110201
Chain.DarkRevelations = 110202
Chain.TheMonsterAndTheMachine = 110203
Chain.TheCaretakerOfBrunwinsTerrace = 110211
Chain.BrokenTools = 110212
Chain.RoutineMaintenance = 110213
Chain.DeadInTheDen = 110214
Chain.EnvenomedInvasion = 110215
Chain.Fearbreaker = 110216
Chain.IntoTheFog = 110217
Chain.Magmanificence = 110218
Chain.KoboldCultureAndIntegration = 110219
Chain.RampageAtNibelgazMine = 110220
Chain.AbysmalExtraction = 110221
Chain.RevengeInTheRumblingWastes = 110222
Chain.TempChain13 = 110223
Chain.TiredOfRest = 110224
Chain.FrolickingInTheFetidGrotto = 110225
Chain.TempChain16 = 110226
Chain.TempChain17 = 110227
Chain.TempChain21 = 110231
Chain.TempChain22 = 110232
Chain.TempChain23 = 110233
Chain.TempChain24 = 110234
Chain.TempChain25 = 110235
Chain.TempChain27 = 110237
Chain.TempChain28 = 110238
Chain.TempChain30 = 110240
Chain.TempChain31 = 110241
Chain.TempChain32 = 110242
Chain.TempChain33 = 110243
Chain.TempChain34 = 110244
Chain.TempChain35 = 110245
Chain.OtherAlliance = 110297
Chain.OtherHorde = 110298
Chain.OtherBoth = 110299

Database:AddChain(Chain.ByCandlelight, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 5533,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.IsleOfDorn.EarthenFissures,
        },
    },
    active = {
        type = "quest",
        ids = {
            78555, 78557, 80434, 83550, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80082, -- Actually 78642 in the achievement, check if 80082 is actually required for the next chapter
    },
    items = {
        {
            type = "npc",
            id = 217887,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 83550,
                    restrictions = {
                        type = "quest",
                        id = 83550,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 80434,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78555,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78557,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78837,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78838,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78631,
            x = 0,
            connections = {
                1.2, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = Chain.TempChain28,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 78839,
            x = -3,
            y = 6,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 78634,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 78635,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78637,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78638,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78636,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78640,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78639,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 79205,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78641,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79267,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78642,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80082,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DarkRevelations, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 5534,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.IsleOfDorn.EarthenFissures,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ByCandlelight,
        },
    },
    active = {
        type = "quest",
        id = 80079,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78706,
    },
    items = {
        {
            type = "npc",
            id = 218714,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80079,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78685,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78696,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78697,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78700,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78701,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78703,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78704,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78705,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78706,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheMonsterAndTheMachine, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 5535,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.IsleOfDorn.EarthenFissures,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ByCandlelight,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DarkRevelations,
        },
    },
    active = {
        type = "quest",
        id = 78738,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 81689,
    },
    items = {
        {
            type = "npc",
            id = 212741,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78738,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78741,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78742,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81798,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
            comment = "Probably a breadcrumb back to Moira if you hand in Battle of the Earthenworks before Sympathetic Speakers",
        },
        {
            type = "quest",
            id = 78760,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78761,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79354,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81689,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheCaretakerOfBrunwinsTerrace, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    questline = 5620,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 80392,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80407,
    },
    items = {
        {
            type = "npc",
            id = 219784,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80392,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80408,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80401,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80402,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80404,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80689,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80405,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80406,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 80407,
        },
    },
})
Database:AddChain(Chain.BrokenTools, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    questline = 5597,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.ByCandlelight,
            upto = 78838,
        },
    },
    active = {
        type = "quest",
        id = 78562,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 78564,
    },
    items = {
        {
            type = "npc",
            id = 212695,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78562,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78563,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78564,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RoutineMaintenance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    questline = 5611,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.DarkRevelations,
            upto = 78697,
        },
    },
    active = {
        type = "quest",
        id = 82773,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 82814,
    },
    items = {
        {
            type = "npc",
            id = 224602,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82773,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82774,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82785,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82990,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 82969,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82786,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82814,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DeadInTheDen, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    questline = 5624,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        { -- Was also renown 4 with council of dornogal
            type = "chain",
            id = Chain.ByCandlelight,
            upto = 78642, --- 78838 old
        },
    },
    active = {
        type = "quest",
        id = 80508,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 80516,
    },
    items = {
        {
            type = "npc",
            id = 222234,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80508,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80510,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80509,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80511,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80512,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80513,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80514,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80515,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80516,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EnvenomedInvasion, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    questline = 5625,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 79367,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79372,
    },
    items = {
        {
            type = "npc",
            id = 215737,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79367,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 79368,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 79369,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79481,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79370,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "object",
            id = 423581,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79371,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 79372,
        },
    },
})
Database:AddChain(Chain.Fearbreaker, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    questline = 5598,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.TheMonsterAndTheMachine,
            upto = 78761,
        },
    },
    active = {
        type = "quest",
        id = 79256,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79266,
    },
    items = {
        {
            type = "npc",
            id = 212742,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79256,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79258,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79259,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79260,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79261,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79263,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79262,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79264,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79265,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79266,
            x = 0,
        },
    },
})
Database:AddChain(Chain.IntoTheFog, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    questline = 5655,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 68,
        },
        {
            type = "chain",
            id = Chain.DarkRevelations,
            upto = 78697,
        },
    },
    active = {
        type = "quest",
        id = 81556,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 81559,
    },
    items = {
        {
            type = "npc",
            id = 221043,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81556,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 81557,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 81558,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81559,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Magmanificence, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    questline = 5654,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            83092, 83152, 83153, 83160, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 83160,
    },
    items = {
        {
            type = "npc",
            id = 225582,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "npc",
            id = 225583,
            x = 1,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 225616,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 83092,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 83152,
            aside = true,
        },
        {
            type = "quest",
            id = 83153,
            aside = true,
        },
        {
            type = "quest",
            id = 83160,
        },
    },
})
Database:AddChain(Chain.KoboldCultureAndIntegration, {
    name = "Kobold Culture and Integration",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.ByCandlelight,
            upto = 78642,
        },
    },
    active = {
        type = "quest",
        ids = {
            79504, 79683, 80058, 81999, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            80202,79682,79510
        },
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 222803,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79683,
            aside = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.TempChain16,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.TempChain17,
            embed = true,
            x = 2,
        },
        {
            type = "chain",
            id = Chain.TempChain13,
            embed = true,
            x = 0,
            y = 8,
        },
    },
})
Database:AddChain(Chain.RampageAtNibelgazMine, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    questline = 5619,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            79148, 79149, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 79327,
    },
    items = {
        {
            type = "npc",
            id = 215208,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 215234,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79148,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79149,
            aside = true,
        },
        {
            type = "quest",
            id = 79679,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79193,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79194,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "kill",
            id = 216025,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79944,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 79327,
        },
    },
})
Database:AddChain(Chain.AbysmalExtraction, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    questline = 5623,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.ByCandlelight,
            upto = 80434,
        },
    },
    active = {
        type = "quest",
        id = 83155,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 83162,
    },
    items = {
        {
            type = "npc",
            id = 225608,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83155,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83159,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83162,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RevengeInTheRumblingWastes, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 11),
    questline = 5621,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            81655, 81669, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 81672,
    },
    items = {
        {
            type = "npc",
            id = 220417,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 81655,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 81669,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81672,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain13, {
    questline = 5627,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 80202,
    },
    items = {
        {
            type = "npc",
            id = 216438,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79504,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79505,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79507,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79508,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79510,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TiredOfRest, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 12),
    questline = 5626,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 80576,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 82144,
    },
    items = {
        {
            type = "npc",
            id = 220600,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80576,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80676,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81613,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80577,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80578,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80593,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80682,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82144,
            x = 0,
        },
    },
})
Database:AddChain(Chain.FrolickingInTheFetidGrotto, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 13),
    questline = 5622,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 81693,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "npc",
            id = 220415,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81693,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 81712,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 81713,
        },
    },
})
Database:AddChain(Chain.TempChain16, {
    questline = 5622,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "npc",
            id = 216567,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81999,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79552,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 79998,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80202,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80000,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79565,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain17, {
    questline = 5622,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "npc",
            id = 216568,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80058,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79556,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79680,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79681,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79682,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain21, {
    name = { -- Brax's Brass Knuckles
        type = "quest",
        id = 78918,
    },
    questline = 5622,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "npc",
            id = 213840,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78918,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain22, {
    questline = 5622,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            name = "Rogue only. There are quests for other classes too.",
        },
        {
            name = "For priest/paladin version of the quest, probably the same for all classes",
            type = "quest",
            id = 78838,
        },
        {
            type = "object",
            id = 413694,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78827,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78860,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83326,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.TempChain23, {
    name = { -- Delver's Call: Dread Pit
        type = "quest",
        id = 83766,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "object",
            id = 455685,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83766,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain24, {
    name = { -- Papers? Please!
        type = "quest",
        id = 82226,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "npc",
            id = 223184,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82226,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain25, {
    name = { -- Delves: The Waterworks
        type = "quest",
        id = 83749,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 83749,
    },
    items = {
        {
            name = "Something something delves?",
        },
        {
            type = "npc",
            id = 227477,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83749,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain27, {
    name = { -- On Cold, Dark Wings
        type = "quest",
        id = 78900,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.ByCandlelight,
            upto = 78838,
        },
    },
    active = {
        type = "quest",
        id = 78900,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 78900,
    },
    items = {
        {
            type = "npc",
            id = 213869,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78900,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain28, {
    name = { -- Broken Memories
        type = "quest",
        id = 79206,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "quest",
            id = 78634,
            status = {'active', 'completed'}
        }
    },
    active = {
        type = "quest",
        id = 79206,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 79206,
    },
    items = {
        {
            type = "loot",
            id = 411756,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79206,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain30, {
    name = { -- An Opportunity to Relax
        type = "quest",
        id = 82952,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 82952,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "npc",
            id = 224966,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82952,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82956,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain31, {
    name = {
        type = "quest",
        id = 82195,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        { -- possibly earlier during the questline
            type = "chain",
            id = Chain.ByCandlelight,
            upto = 78631
        },
    },
    active = {
        type = "quest",
        id = 82195,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 82195,
    },
    items = {
        {
            type = "object",
            id = 443532,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82195,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain32, {
    name = { -- Badly Behaved Bot
        type = "quest",
        id = 83165,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.ByCandlelight,
        },
    },
    active = {
        type = "quest",
        id = 83165,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 83165,
    },
    items = {
        {
            type = "npc",
            id = 223759,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83165,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain33, {
    name = { -- Daily Diagnostics
        type = "quest",
        id = 83108,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 68, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 71, },
            }
        },
        {
            type = "chain",
            id = Chain.TheMonsterAndTheMachine,
            upto = 79354,
        },
    },
    active = {
        type = "quest",
        id = 83108,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 83108,
    },
    items = {
        {
            type = "npc",
            id = 225533,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83108,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain34, {
    name = { -- Preserve and Pretend
        type = "quest",
        id = 83331,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 81713,
    },
    items = {
        {
            type = "npc",
            id = 226255,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83331,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain35, {
    name = { -- Knicknack's Knickknacks
        type = "quest",
        id = 83154,
    },
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
        id = 83154,
        status = { "active", "completed" }
    },
    completed = {
        type = "quest",
        id = 83154,
    },
    items = {
        {
            type = "npc",
            id = 225555,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83154,
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
        { -- Go Take Candle!
            type = "quest",
            id = 78827,
        },
        {
            type = "quest",
            id = 78860,
        },
        { -- Conjured Help
            type = "quest",
            id = 78874,
        },
        { -- Bless These Homes
            type = "quest",
            id = 78877,
        },
        { -- Evoking the Forge
            type = "quest",
            id = 78879,
        },
        { -- A Shadow Over Gundargaz
            type = "quest",
            id = 78895,
        },
        { -- On Cold, Dark Wings
            type = "quest",
            id = 78900,
        },
        { -- Brax's Brass Knuckles
            type = "quest",
            id = 78918,
        },
        { -- A Mysterious Signal
            type = "quest",
            id = 79022,
        },
        { -- Small Friend, Big Plans
            type = "quest",
            id = 79023,
        },
        { -- Factory Recon
            type = "quest",
            id = 79024,
        },
        { -- A Plan Comes Together
            type = "quest",
            id = 79025,
        },
        { -- Putting the Works in Waterworks
            type = "quest",
            id = 79026,
        },
        { -- Elemental Trepidation
            type = "quest",
            id = 79027,
        },
        { -- We Require More Minerals
            type = "quest",
            id = 79028,
        },
        { -- It's Sabotage
            type = "quest",
            id = 79029,
        },
        { -- The Voice of the Speakers
            type = "quest",
            id = 79030,
        },
        { -- Back to Base
            type = "quest",
            id = 79217,
        },
        { -- Clean Up House
            type = "quest",
            id = 79262,
        },
        { -- To the Waterworks
            type = "quest",
            id = 79324,
        },
        { -- Shadowvein Extraction
            type = "quest",
            id = 79325,
        },
        { -- Everyday I'm Snufflin'
            type = "quest",
            id = 79343,
        },
        { -- Tending to the Terrified
            type = "quest",
            id = 79481,
        },
        { -- The Motherlode
            type = "quest",
            id = 80145,
        },
        {
            type = "quest",
            id = 80208,
        },
        { -- Foggy Faceoff
            type = "quest",
            id = 80323,
        },
        { -- Back to Where it Began
            type = "quest",
            id = 80517,
        },
        { -- Listener Lost
            type = "quest",
            id = 80576,
        },
        { -- Readying the Recitation
            type = "quest",
            id = 80577,
        },
        { -- Let's Not Worry Her
            type = "quest",
            id = 81613,
        },
        { -- Nothing to Waste
            type = "quest",
            id = 81656,
        },
        {
            type = "quest",
            id = 81691,
        },
        { -- The Flame Within
            type = "quest",
            id = 81692,
        },
        { -- Cloud Farming
            type = "quest",
            id = 81750,
        },
        { -- Fire and Gemstone
            type = "quest",
            id = 81751,
        },
        { -- Scrounge that Scrap!
            type = "quest",
            id = 81767,
        },
        { -- Sparks of War: The Ringing Deeps
            type = "quest",
            id = 81794,
        },
        { -- Skyrider Racing - Ringing Deeps Ramble
            type = "quest",
            id = 81808,
        },
        { -- Skyrider Racing - Chittering Concourse
            type = "quest",
            id = 81810,
        },
        { -- Can Catch More Fires with Honey
            type = "quest",
            id = 81869,
        },
        { -- New and Improved
            type = "quest",
            id = 81896,
        },
        {
            type = "quest",
            id = 81925,
        },
        {
            type = "quest",
            id = 81926,
        },
        {
            type = "quest",
            id = 81927,
        },
        { -- What Army?
            type = "quest",
            id = 81981,
        },
        { -- Special Assignment: When the Deeps Stir
            type = "quest",
            id = 82156,
        },
        { -- Rust and Redemption
            type = "quest",
            id = 82195,
        },
        { -- Papers? Please!
            type = "quest",
            id = 82226,
        },
        {
            type = "quest",
            id = 82238,
        },
        {
            type = "quest",
            id = 82244,
        },
        {
            type = "quest",
            id = 82256,
        },
        { -- The Power of Friendship
            type = "quest",
            id = 82293,
        },
        { -- Major Malfunction
            type = "quest",
            id = 82300,
        },
        { -- Restored Coffer Key
            type = "quest",
            id = 82334,
        },
        { -- A Flickering Candle
            type = "quest",
            id = 82366,
        },
        { -- Weathered Crests
            type = "quest",
            id = 82367,
        },
        { -- Pipe Patcher
            type = "quest",
            id = 82518,
        },
        { -- You Go Take Candle
            type = "quest",
            id = 82519,
        },
        {
            type = "quest",
            id = 82523,
        },
        {
            type = "quest",
            id = 82552,
        },
        {
            type = "quest",
            id = 82580,
        },
        { -- Reclaiming the Waterworks
            type = "quest",
            id = 82615,
        },
        { -- Aggregation of Horrors
            type = "quest",
            id = 82653,
        },
        { -- Rollin' Down in the Deeps
            type = "quest",
            id = 82946,
        },
        { -- An Opportunity to Relax
            type = "quest",
            id = 82952,
        },
        { -- To Opportunity Point
            type = "quest",
            id = 82956,
        },
        { -- Thanks for the Wax
            type = "quest",
            id = 82957,
        },
        { -- Wax Contribution
            type = "quest",
            id = 82994,
        },
        {
            type = "quest",
            id = 83028,
        },
        { -- Wayward Walkers
            type = "quest",
            id = 83048,
        },
        { -- Mineral Buildup
            type = "quest",
            id = 83079,
        },
        { -- Taelloch Cleanup
            type = "quest",
            id = 83080,
        },
        { -- Reaching for Resources
            type = "quest",
            id = 83101,
        },
        { -- Badly Behaved Bot
            type = "quest",
            id = 83165,
        },
        { -- Special Assignment: When the Deeps Stir
            type = "quest",
            id = 83229,
        },
        {
            type = "quest",
            id = 83326,
        },
        { -- Preserve and Pretend
            type = "quest",
            id = 83331,
        },
        { -- Gearing Up for Trouble
            type = "quest",
            id = 83333,
        },
        {
            type = "quest",
            id = 83501,
        },
        {
            type = "quest",
            id = 83537,
        },
        {
            type = "quest",
            id = 83538,
        },
        {
            type = "quest",
            id = 83715,
        },
        { -- Delves: The Waterworks
            type = "quest",
            id = 83749,
        },
        { -- Threats of Zekvir
            type = "quest",
            id = 83752,
        },
        { -- Delves: Nightfall Sanctum
            type = "quest",
            id = 83755,
        },
        { -- Delves: The Underkeep
            type = "quest",
            id = 83761,
        },
        { -- Deworming Solution
            type = "quest",
            id = 83930,
        },
        {
            type = "quest",
            id = 84429,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 5912554,
    items = {
        {
            type = "chain",
            id = Chain.ByCandlelight,
        },
        {
            type = "chain",
            id = Chain.DarkRevelations,
        },
        {
            type = "chain",
            id = Chain.TheMonsterAndTheMachine,
        },
        {
            type = "chain",
            id = Chain.TheCaretakerOfBrunwinsTerrace,
        },
        {
            type = "chain",
            id = Chain.BrokenTools,
        },
        {
            type = "chain",
            id = Chain.RoutineMaintenance,
        },
        {
            type = "chain",
            id = Chain.DeadInTheDen,
        },
        {
            type = "chain",
            id = Chain.EnvenomedInvasion,
        },
        {
            type = "chain",
            id = Chain.Fearbreaker,
        },
        {
            type = "chain",
            id = Chain.IntoTheFog,
        },
        {
            type = "chain",
            id = Chain.Magmanificence,
        },
        {
            type = "chain",
            id = Chain.KoboldCultureAndIntegration,
        },
        {
            type = "chain",
            id = Chain.RampageAtNibelgazMine,
        },
        {
            type = "chain",
            id = Chain.AbysmalExtraction,
        },
        {
            type = "chain",
            id = Chain.RevengeInTheRumblingWastes,
        },
        {
            type = "chain",
            id = Chain.TiredOfRest,
        },
        {
            type = "chain",
            id = Chain.FrolickingInTheFetidGrotto,
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
            id = Chain.TempChain24,
        },
        {
            type = "chain",
            id = Chain.TempChain27,
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
            id = Chain.TempChain35,
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

BtWQuestsDatabase:AddQuestItemsForChain(Chain.ByCandlelight)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.DarkRevelations)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheMonsterAndTheMachine)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheCaretakerOfBrunwinsTerrace)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.BrokenTools)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RoutineMaintenance)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.DeadInTheDen)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.EnvenomedInvasion)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.Fearbreaker)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.IntoTheFog)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.Magmanificence)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.KoboldCultureAndIntegration)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RampageAtNibelgazMine)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AbysmalExtraction)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RevengeInTheRumblingWastes)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TempChain13)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TiredOfRest)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.FrolickingInTheFetidGrotto)

--[==[@debug@
Database:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = Chain.TheCaretakerOfBrunwinsTerrace,
    },
    {
        type = "chain",
        id = Chain.BrokenTools,
    },
    {
        type = "chain",
        id = Chain.RoutineMaintenance,
    },
    {
        type = "chain",
        id = Chain.DeadInTheDen,
    },
    {
        type = "chain",
        id = Chain.EnvenomedInvasion,
    },
    {
        type = "chain",
        id = Chain.Fearbreaker,
    },
    {
        type = "chain",
        id = Chain.IntoTheFog,
    },
    {
        type = "chain",
        id = Chain.Magmanificence,
    },
    {
        type = "chain",
        id = Chain.KoboldCultureAndIntegration,
    },
    {
        type = "chain",
        id = Chain.RampageAtNibelgazMine,
    },
    {
        type = "chain",
        id = Chain.AbysmalExtraction,
    },
    {
        type = "chain",
        id = Chain.RevengeInTheRumblingWastes,
    },
    {
        type = "chain",
        id = Chain.TempChain13,
    },
    {
        type = "chain",
        id = Chain.TiredOfRest,
    },
    {
        type = "chain",
        id = Chain.FrolickingInTheFetidGrotto,
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
