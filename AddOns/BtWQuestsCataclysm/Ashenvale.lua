local L = BtWQuests.L
local MAP_ID = 63
local ACHIEVEMENT_ID_ALLIANCE = 4925
local ACHIEVEMENT_ID_HORDE = 4976
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_MAESTRAS_POST, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_DIPLOMAT_FROM_SILVERMOON,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {13624},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13626,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN02,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN01,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN03,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SAVING_ASTRANAAR, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {13849},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13853,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN04,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN05,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN06,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN07,
            aside = true,
            x = 1,
            y = 2,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_STARDUST_SPIRE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SPLINTERTREES_DEMONIC_DEFENSE,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {13965, 13976, 13964, 26470, 13979, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {13987, 26470, 13979, 13913},
        count = 4,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN08,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN09,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN10,
            x = 4,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_POWER_OF_DARTOLS_ROD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_ZORAMGAR_OUTPOST,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "quest",
            id = 26475,
        },
    },
    active = {
        type = "quest",
        ids = {26476},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26482,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN03,
            x = 3,
            y = 0,
            completed = {
                type = "quest",
                id = 26475,
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26476,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26477,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26478,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26479,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26480,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13989,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26481,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26482,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_BRINGING_HARMONY_TO_THE_ELEMENTS_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_BRINGING_HARMONY_TO_THE_ELEMENTS_HORDE,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "quest",
            id = 13877,
        },
    },
    active = {
        type = "quest",
        ids = {13880, 13884},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13886,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SAVING_ASTRANAAR,
            x = 0,
            y = 0,
            completed = {
                type = "quest",
                id = 13877,
            },
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13880,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13884,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13886,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_SATYR_OF_SATYRNAAR, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_WEAPONS_OF_THEIR_DESTRUCTION,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {26455, 26467, 26453, 26454},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {26455, 26469, 13683, 13869},
        count = 4,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN11,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN12,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN13,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_HORDE,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {26446},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {13796, 26472},
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN14,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN15,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN16,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN17,
            aside = true,
            x = 1,
            y = 2,
            embed = true,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {28493, 28876, 13866, 13612, 13618},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13805,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN18,
            aside = true,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN19,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN20,
            aside = true,
            x = 6,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN21,
            aside = true,
            x = 0,
            y = 10,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_DIPLOMAT_FROM_SILVERMOON, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_MAESTRAS_POST,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_HORDE,
        },
    },
    active = {
        type = "quest",
        ids = {13808},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13873,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_HORDE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13808,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13815,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13865,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13870,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13871,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13873,
            x = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN22,
            aside = true,
            x = 3,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SPLINTERTREES_DEMONIC_DEFENSE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_STARDUST_SPIRE,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "quest",
            id = 13803,
        },
    },
    active = {
        type = "quest",
        ids = {13730},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13842,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN23,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN24,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN25,
            aside = true,
            x = 4,
            y = 2,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_ZORAMGAR_OUTPOST, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_POWER_OF_DARTOLS_ROD,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {6442, 6641, 13890, 13920, 13883, 26890},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {13901, 6641, 13890, 13920, 13883, 26890},
        count = 6,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN26,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN27,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN28,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN29,
            x = 2,
            y = 3,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SAVING_ASTRANAAR,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {13936},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13947,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN30,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN31,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN32,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_WEAPONS_OF_THEIR_DESTRUCTION, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_SATYR_OF_SATYRNAAR,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
        },
    },
    active = {
        type = "quest",
        ids = {13974},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {13980, 13983},
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN33,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN34,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN35,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_BRINGING_HARMONY_TO_THE_ELEMENTS_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_BRINGING_HARMONY_TO_THE_ELEMENTS_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
        },
    },
    active = {
        type = "quest",
        ids = {13879},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13888,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13879,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13884,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13880,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13888,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN01, {
    name = { -- Stalemate
        type = "quest",
        id = 13962,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN02,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
        },
    },
    active = {
        type = "quest",
        ids = {13958},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13962,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13958,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13962,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN02, {
    name = { -- West to the Strand
        type = "quest",
        id = 13617,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN01,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {13617, 26465, 13602},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {26466, 13602},
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN36,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN37,
            x = 4,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN03, {
    name = { -- Orendil's Cure
        type = "quest",
        id = 26474,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
    active = {
        type = "quest",
        ids = {26473},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13924,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN38,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN39,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN40,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN41,
            aside = true,
            x = 6,
            y = 3,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN42,
            aside = true,
            x = 0,
            y = 7,
            embed = true,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 11806,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13624,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13626,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 11219,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13632,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 33276,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13630,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 3691,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13867,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN05, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 4079,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13849,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13853,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN06, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            name = L["KILL_FURBOLGS"],
            breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13868,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13872,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13874,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13877,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN07, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 34251,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13876,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN08, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 13965,
                    restrictions = {
                        type = "quest",
                        id = 13965,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 24739,
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13976,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13982,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13985,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13987,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN09, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 13964,
                    restrictions = {
                        type = "quest",
                        id = 13964,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 3885,
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26470,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN10, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 34354,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13979,
            x = 0,
        },
        {
            type = "quest",
            id = 13913,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN11, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 3848,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26455,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN12, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 3901,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26467,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26468,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26469,
            x = 0,
        },
        {
            type = "quest",
            id = 13683,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN13, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26453,
                    restrictions = {
                        type = "quest",
                        id = 26453,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 17291,
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26454,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13869,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN14, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 17303,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26444,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN15, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 17310,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26446,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13766,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13792,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13796,
            x = 0,
        },
        {
            type = "quest",
            id = 26472,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN16, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 17287,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26457,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13698,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN17, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "quest",
            id = 26443,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26445,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN18, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 33284,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13615,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN19, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28493,
                    restrictions = {
                        type = "quest",
                        id = 28493,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28876,
                    restrictions = {
                        type = "quest",
                        id = 28876,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 13866,
                    restrictions = {
                        type = "quest",
                        id = 13866,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 8582,
                },
            },
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13612,
            x = 0,
        },
        {
            type = "quest",
            id = 13618,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13619,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13620,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13621,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13628,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13640,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13651,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13653,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13712,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13803,
            x = 1,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13805,
            x = 0,
            connections = {
                3, 4, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SPLINTERTREES_DEMONIC_DEFENSE,
            aside = true,
        },
        {
            type = "quest",
            id = 13801,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_DIPLOMAT_FROM_SILVERMOON,
            x = 0,
            aside = true,
        },
        {
            type = "quest",
            id = 13848,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN20, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 33263,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13613,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN21, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 12867,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 6503,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN22, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 34242,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13875,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN23, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_HORDE,
            x = 0,
            y = 0,
            completed = {
                type = "quest",
                id = 13803,
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13730,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13751,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13797,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13798,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13841,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13842,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN24, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 17355,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26448,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN25, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "quest",
            id = 26447,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26449,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13806,
            x = 0,
        },
        {
            type = "quest",
            id = 6441,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN26, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 12719,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 6442,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13901,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN27, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 12717,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 6641,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN28, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 34122,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13920,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN29, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 34303,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13883,
            x = 0,
        },
        {
            type = "quest",
            id = 26890,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN30, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 12721,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 6462,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN31, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 34359,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13936,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13942,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13943,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13947,
            x = 1,
            y = 4,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_WEAPONS_OF_THEIR_DESTRUCTION,
            aside = true,
            x = -1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_BRINGING_HARMONY_TO_THE_ELEMENTS_HORDE,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN01,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN32, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 12757,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 216,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN33, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 34559,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25,
            x = 0,
        },
        {
            type = "quest",
            id = 1918,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN34, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13974,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13977,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13980,
            x = 0,
        },
        {
            type = "quest",
            id = 13983,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN35, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 12696,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13967,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 6621,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN36, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 13617,
                    restrictions = {
                        type = "quest",
                        id = 13617,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 3846,
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26465,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26466,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN37, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 3845,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13602,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN38, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 33204,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26473,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13623,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13642,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26463,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26464,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26474,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13645,
        },
        {
            type = "quest",
            id = 26475,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13919,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_POWER_OF_DARTOLS_ROD,
            aside = true,
        },
        {
            type = "quest",
            ids = {
                13921, 14018,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13922,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13924,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN39, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28492,
                    restrictions = {
                        type = "quest",
                        id = 28492,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 33187,
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13594,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN40, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 33182,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13595,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN41, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 33443,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13644,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_EMBED_CHAIN42, {
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "npc",
            id = 3880,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13928,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13935,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26456,
            x = 0,
            connections = {
                
            },
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "quest",
            id = 25607,
        },
        {
            type = "quest",
            id = 26408,
        },
        {
            type = "quest",
            id = 13979,
        },
        {
            type = "quest",
            id = 13981,
        },
        {
            type = "quest",
            id = 13595,
        },
        {
            type = "quest",
            id = 7863,
        },
        {
            type = "quest",
            id = 7864,
        },
        {
            type = "quest",
            id = 7865,
        },
        {
            type = "quest",
            id = 13646,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
        {
            type = "quest",
            id = 13923,
        },
        {
            type = "quest",
            id = 23,
        },
        {
            type = "quest",
            id = 24,
        },
        {
            type = "quest",
            id = 6544,
        },
        {
            type = "quest",
            id = 6546,
        },
        {
            type = "quest",
            id = 6482,
        },
        {
            type = "quest",
            id = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {7,30},
    items = {
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851070,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_MAESTRAS_POST,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SAVING_ASTRANAAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_STARDUST_SPIRE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_POWER_OF_DARTOLS_ROD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_BRINGING_HARMONY_TO_THE_ELEMENTS_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_SATYR_OF_SATYRNAAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_CORRUPTED_HEART_OF_THE_FOREST_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_DIPLOMAT_FROM_SILVERMOON,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_SPLINTERTREES_DEMONIC_DEFENSE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_ZORAMGAR_OUTPOST,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_THE_BOMBING_OF_ASTRANAAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_WEAPONS_OF_THEIR_DESTRUCTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_BRINGING_HARMONY_TO_THE_ELEMENTS_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN02,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_ASHENVALE_CHAIN03,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_ASHENVALE,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})

