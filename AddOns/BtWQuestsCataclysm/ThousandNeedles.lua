local L = BtWQuests.L;
local MAP_ID = 64
local ACHIEVEMENT_ID = 4938
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_HORDE,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
        },
    },
    active = {
        type = "quest",
        ids = {25590},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25627,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25585,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 25590,
            x = 3,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25588,
            aside = true,
        },
        {
            type = "quest",
            id = 25609,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25627,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
        },
    },
    active = {
        type = "quest",
        ids = {25596},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25628,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25586,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 25596,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25589,
            aside = true,
        },
        {
            type = "quest",
            id = 25610,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25628,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_BUGS_IN_THE_ICE_CREAM, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
        },
    },
    active = {
        type = "quest",
        ids = {28031, 28042},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28048,
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28031,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 28042,
                },
            },
            x = 3,
            y = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28045,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28051,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28047,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 28048,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_HORDE,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN03,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
        },
    },
    active = {
        type = "quest",
        ids = {25835},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27327,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN03,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25835,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25869,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 25871,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25873,
            aside = true,
        },
        {
            type = "quest",
            id = 27275,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 27310,
            x = 0,
        },
        {
            type = "quest",
            id = 27316,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27314,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27312,
        },
        {
            type = "quest",
            id = 27320,
            aside = true,
            x = 1,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 27325,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27318,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27323,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27327,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27357,
            aside = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27329,
            aside = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_MIND_THE_DROP,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
        },
    },
    active = {
        type = "quest",
        ids = {25836},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27328,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN04,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25836,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25870,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 25872,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25874,
            aside = true,
        },
        {
            type = "quest",
            id = 27276,
            x = 3,
            connections = {
                1, 3, 4, 2, 
            },
        },
        {
            type = "quest",
            id = 27311,
            aside = true,
            x = 0,
        },
        {
            type = "quest",
            id = 27317,
            aside = true,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27315,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27313,
            aside = true,
        },
        {
            type = "quest",
            id = 27321,
            aside = true,
            x = 1,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 27326,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27319,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27324,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27328,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27358,
            aside = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27330,
            aside = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_MIND_THE_DROP,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_MIND_THE_DROP, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "quest",
            id = 27330,
        },
    },
    active = {
        type = "quest",
        ids = {28085},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28098,
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_ALLIANCE,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_HORDE,
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
            id = 28085,
            x = 3,
            y = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28086,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28087,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28088,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28098,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_EVIL_YOU_KNOW,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_EVIL_YOU_KNOW, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_MIND_THE_DROP,
        },
    },
    active = {
        type = "quest",
        ids = {28124, 28125},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28160, 28161},
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_MIND_THE_DROP,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28124,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28125,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28127,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28136,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28139,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28140,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28142,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28157,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28158,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28159,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28160,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 28161,
                },
            },
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01, {
    name = L["BTWQUESTS_INTRODUCTION"],
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25479, 25481, 28503, 25486},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25542},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25479,
                    restrictions = {
                        type = "quest",
                        id = 25479,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 25481,
                    restrictions = {
                        type = "quest",
                        id = 25481,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28503,
                    restrictions = {
                        type = "quest",
                        id = 28503,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 39946,
                },
            },
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25486,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25488,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25504,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25517,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25515,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25524,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25532,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25542,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_BUGS_IN_THE_ICE_CREAM,
            aside = true,
            x = 1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_ALLIANCE,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN03,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02, {
    name = L["BTWQUESTS_INTRODUCTION"],
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {28504, 25356, 25478, 25487},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25543},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28504,
                    restrictions = {
                        type = "quest",
                        id = 28504,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 40344,
                },
            },
            x = 3,
            y = 1,
            connections = {
                1, 2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25356,
                    restrictions = {
                        type = "quest",
                        id = 25356,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 25478,
                },
            },
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25487,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25489,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25505,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25526,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25516,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25518,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25533,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25543, 
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_BUGS_IN_THE_ICE_CREAM,
            aside = true,
            x = 1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_HORDE,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN04,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN03, {
    name = { -- Negotiations
        type = "quest",
        id = 25744,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN04,
    },
    restrictions = {
        type = "faction",
        id = "Alliance",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
        },
    },
    active = {
        type = "quest",
        ids = {25744},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25825,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25744,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25756,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_EMBED_CHAIN01,
            aside = true,
            x = 5,
            y = 2,
            embed = true,
        },
        {
            type = "quest",
            id = 25774,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25778,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25790,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25796,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25798,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25813,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25825,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_ALLIANCE,
            x = 4,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN04, {
    name = { -- Negotiations
        type = "quest",
        id = 25745,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN03,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
        },
    },
    active = {
        type = "quest",
        ids = {25745},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25826,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25745,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25757,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_EMBED_CHAIN01,
            aside = true,
            x = 5,
            y = 2,
            embed = true,
        },
        {
            type = "quest",
            id = 25775,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25779,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25791,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25797,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25799,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25814,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25826,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_HORDE,
            x = 4,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05, {
    name = "The Mad Magus",
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_HORDE,
        },
    },
    active = {
        type = "quest",
        ids = {25660},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25704,
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_ALLIANCE,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_HORDE,
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
            id = 25660,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25661,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25672,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN03,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN04,
                },
            },
            x = 1,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25704,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_ALLIANCE,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_HORDE,
                },
            },
            x = 2,
            aside = true,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 40082,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25762,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 28601,
        },
        {
            type = "quest",
            id = 28143,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851110,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN02,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_TREASURE_TROVE_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_BUGS_IN_THE_ICE_CREAM,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_CHIEF_OF_CHIEFS_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_MIND_THE_DROP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_THE_EVIL_YOU_KNOW,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN03,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_THOUSAND_NEEDLES_CHAIN05,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_THOUSAND_NEEDLES,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
