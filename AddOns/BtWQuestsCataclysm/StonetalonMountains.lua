local MAP_ID = 65
local ACHIEVEMENT_ID_ALLIANCE = 4936
local ACHIEVEMENT_ID_HORDE = 4980
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_CLEARING_A_PATH, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {28539, 25607, 13913, 13979},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 25642,
        },
        {
            type = "quest",
            id = 25646,
        },
        {
            type = "quest",
            id = 25650,
        },
    },
    items = {
        {
            type = "npc",
            id = 40895,
            x = 1,
            y = 0,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28539,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 34354,
                },
            },
            x = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 25607,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13913,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13979,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25613,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25614,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25615,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25616,
            x = 2,
            aside = true,
        },
        {
            type = "quest",
            id = 25621,
            x = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25622,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25640,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25642,
            x = 1,
            aside = true,
        },
        {
            type = "quest",
            id = 25647,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25646,
            aside = true,
        },
        {
            type = "quest",
            id = 25649,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25650,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
            x = 3,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_CLEARING_A_PATH,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_CLEARING_A_PATH,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25669,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_CLEARING_A_PATH,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25652,
            x = 3,
            connections = {
                3, 4,
            },
        },
        {
            type = "object",
            id = 203186,
            x = 6,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25729,
            x = 0,
            aside = true,
        },
        {
            type = "quest",
            id = 25673,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25662,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25730,
            aside = true,
        },
        {
            type = "quest",
            id = 25728,
            x = 2,
            aside = true,
        },
        {
            type = "quest",
            id = 25669,
            connections = {
                1, 2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SELDARRIA,
            x = 3,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_AN_UNCONVENTIONAL_ALLY,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SELDARRIA, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_CLEARING_A_PATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25931,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 25767,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25766,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25769,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25768,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25878,
            x = 1,
            aside = true,
        },
        {
            type = "quest",
            id = 25875,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25879,
            x = 5,
            aside = true,
        },
        {
            type = "quest",
            id = 25876,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25877,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25880,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25889,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25891,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 25912,
            x = 0,
            aside = true,
        },
        {
            type = "quest",
            id = 25913,
            aside = true,
        },
        {
            type = "quest",
            id = 25914,
            aside = true,
        },
        {
            type = "quest",
            id = 25925,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25934,
            x = 1,
            aside = true,
        },
        {
            type = "quest",
            id = 25930,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25935,
            aside = true,
        },
        {
            type = "quest",
            id = 25931,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_AN_UNCONVENTIONAL_ALLY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_CLEARING_A_PATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25851,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 25739,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25741,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25765,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25793,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25811,
            x = 1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25806,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25809,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25808,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25821,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25834,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25837,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25844,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25845,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25822,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25823,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25846,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25847,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25848,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25851,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25852,
            x = 3,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_A_SHORTLIVED_VICTORY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {28532, 25945, 25999},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26010,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28532,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "quest",
                    id = 25945,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 34341,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25999,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26001,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26003,
            aside = true,
        },
        {
            type = "quest",
            id = 26002,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26004,
            x = 3,
            y = 4,
            connections = {
                2, 3, 4, 5,
            },
        },
        {
            type = "object",
            id = 203186,
            x = 6,
            aside = true,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 28084,
            x = 0,
            y = 4,
            aside = true,
        },
        {
            type = "quest",
            id = 26011,
            x = 0,
            y = 5,
            aside = true,
        },
        {
            type = "quest",
            id = 26026,
            x = 2,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26010,
            x = 4,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26043,
            x = 6,
            aside = true,
        },
        {
            type = "quest",
            id = 26028,
            x = 2,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_LEGIONNAIRE,
            x = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_LEGIONNAIRE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_A_SHORTLIVED_VICTORY,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_A_SHORTLIVED_VICTORY,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26058,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_A_SHORTLIVED_VICTORY,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26020,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26044,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26046,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26045,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26047,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26048,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26058,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_DA_VOODOO,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_DA_VOODOO, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_LEGIONNAIRE,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_LEGIONNAIRE,
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 26067,
        },
        {
            type = "quest",
            id = 26068,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_LEGIONNAIRE,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26059,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26064,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 26060,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 26061,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26062,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26066,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26067,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26068,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_HONOR_NEVER_FORSAKE_IT,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_HONOR_NEVER_FORSAKE_IT, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_DA_VOODOO,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_DA_VOODOO,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26115,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_DA_VOODOO,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26073,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26074,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26075,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26076,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26077,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26082,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26097,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26098,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26099,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26100,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26101,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26115,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "quest",
            id = 25671,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        { -- No longer available?
            type = "quest",
            id = 26016,
        },
        { -- Daily
            type = "quest",
            id = 26009,
        },
        { -- Not sure where to put it
            type = "quest",
            id = 26063,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851107,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_CLEARING_A_PATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SLAY_THE_WARLORD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_SELDARRIA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_AN_UNCONVENTIONAL_ALLY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_A_SHORTLIVED_VICTORY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_LEGIONNAIRE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_DA_VOODOO,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_STONETALON_MOUNTAINS_HONOR_NEVER_FORSAKE_IT,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_STONETALON_MOUNTAINS,
})
