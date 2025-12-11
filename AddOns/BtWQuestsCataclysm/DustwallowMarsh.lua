local MAP_ID = 70
local ACHIEVEMENT_ID_HORDE = 4978
local ACHIEVEMENT_ID_ALLIANCE = 4929
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_WILD_THREATS, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_DISGRACE_THE_DEFECTORS,
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
        ids = {27229, 26701, 28554, 25051, 26682},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27229, 25051, 26682},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN01,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN02,
            x = 3,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_WORK_LEFT_UNDONE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_TERROR_OF_THERAMORE,
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
        ids = {1201, 9437},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {1202, 9437},
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN03,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN04,
            x = 4,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_SWAMP_EYE_STORY_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_SWAMP_EYE_STORY_ALLIANCE,
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
        ids = {27244, 27182, 27215, 27183, 27188},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27244, 27191, 27186, 27190},
        count = 4,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN05,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN06,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN07,
            x = 6,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CONNECTION_TO_THE_GRIMTOTEM, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_HYAL_FAMILY,
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
        ids = {27253, 27260, 27259, 27254},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27297,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN08,
            aside = true,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "npc",
            id = 21042,
            x = 1,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "object",
            id = 20992,
            connections = {
                3, 
            },
        },
        {
            type = "object",
            id = 187273,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27260,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27259,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 27254,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27306,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27255,
            x = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27261,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27256,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27257,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27258,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27292,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27293,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27294,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN09,
            aside = true,
            x = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 27295,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN10,
            aside = true,
            x = 4,
            embed = true,
        },
        {
            type = "quest",
            id = 27296,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27297,
            x = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_ONYXIAS_BROOD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_DEFIAS_IN_DUSTWALLOW,
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
        ids = {27414},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27415,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN11,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN12,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN13,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHALLENGING_THE_OVERLORD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_PRISONERS_OF_THE_GRIMTOTEM,
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
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_ONYXIAS_BROOD,
        },
    },
    active = {
        type = "quest",
        ids = {27418},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27418,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_ONYXIAS_BROOD,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27418,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_CHALLENGE_OF_THE_STONEMAUL_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_CHALLENGE_OF_THE_STONEMAUL_ALLIANCE,
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
        ids = {27407},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27411,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN14,
            aside = true,
            x = 1,
            embed = true,
        },
        {
            type = "npc",
            id = 23579,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN15,
            aside = true,
            x = 5,
            embed = true,
        },
        {
            type = "quest",
            id = 27407,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27408,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27409,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27410,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27411,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_DISGRACE_THE_DEFECTORS, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_WILD_THREATS,
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
        ids = {26702, 28552, 27210},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27213,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26702,
                    restrictions = {
                        type = "quest",
                        id = 26702,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28552,
                    restrictions = {
                        type = "quest",
                        id = 28552,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 23566,
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
            id = 27210,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27211,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27212,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27213,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_SWAMP_EYE_STORY_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_SWAMP_EYE_STORY_HORDE,
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
        ids = {27246, 27182, 27215, 27183, 27188},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27247, 27191, 27186, 27190},
        count = 4,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN16,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN06,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN07,
            x = 6,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_TERROR_OF_THERAMORE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_WORK_LEFT_UNDONE,
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
        ids = {27216},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27222,
    },
    items = {
        {
            type = "npc",
            id = 23835,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27216,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27217,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27218,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27219,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27220,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27221,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27222,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_DEFIAS_IN_DUSTWALLOW, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_ONYXIAS_BROOD,
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
        ids = {27214, 27234},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27241,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27214,
                    restrictions = {
                        type = "quest",
                        id = 27214,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 5086,
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
            id = 27234,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27235,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27236,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27237,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27238,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27239,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27240,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27241,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_PRISONERS_OF_THE_GRIMTOTEM, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHALLENGING_THE_OVERLORD,
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
        ids = {27242},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27245,
    },
    items = {
        {
            type = "npc",
            id = 23723,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27242,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27243,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 27245,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_HYAL_FAMILY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CONNECTION_TO_THE_GRIMTOTEM,
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
        ids = {27251, 27249},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27291,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27251,
                    restrictions = {
                        type = "quest",
                        id = 27251,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 4944,
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
            id = 27249,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27263,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27262,
            connections = {
                8, 
            },
        },
        {
            type = "quest",
            id = 27252,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27264,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27284,
            x = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27286,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27285,
            x = 5,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27287,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27288,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27425,
            x = 3,
            y = 7,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27426,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27427,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN09,
            aside = true,
            x = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 27428,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN10,
            aside = true,
            x = 4,
            embed = true,
        },
        {
            type = "quest",
            id = 27429,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27430,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27291,
            x = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_CHALLENGE_OF_THE_STONEMAUL_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_CHALLENGE_OF_THE_STONEMAUL_HORDE,
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
        ids = {27407},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27411,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN14,
            aside = true,
            x = 1,
            embed = true,
        },
        {
            type = "npc",
            id = 23579,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN15,
            aside = true,
            x = 5,
            embed = true,
        },
        {
            type = "quest",
            id = 27407,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27408,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27409,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27410,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27411,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN01, {
    name = { -- The Zeppelin Crash
        type = "quest",
        id = 27346,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {27346, 27347, 27348},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 11208,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27346,
                    restrictions = {
                        type = "quest",
                        id = 27346,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 23797,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27347,
            x = 2,
        },
        {
            type = "quest",
            id = 27348,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11208,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN02, {
    name = { -- Morgan Stern
        type = "npc",
        id = 4794,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
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
        ids = {1204},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 1258,
    },
    items = {
        {
            type = "npc",
            id = 4794,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1204,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1258,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN03, {
    name = { -- "Stinky" Ignatz
        type = "npc",
        id = 4880,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN04,
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
        ids = {1222},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 1271,
    },
    items = {
        {
            type = "npc",
            id = 4880,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1222,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 1141,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1271,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN04, {
    name = { -- "Stinky" Ignatz
        type = "npc",
        id = 4880,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN03,
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
        ids = {1270},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 1270,
    },
    items = {
        {
            type = "npc",
            id = 4880,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1270,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "object",
            id = 205332,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27229,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26701,
                    restrictions = {
                        type = "quest",
                        id = 26701,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28554,
                    restrictions = {
                        type = "quest",
                        id = 28554,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 4926,
                },
            },
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25051,
            x = 0,
        },
        {
            type = "quest",
            id = 26682,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 4791,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1201,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1202,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 17095,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9437,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN05, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 20985,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27244,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN06, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27182,
                    restrictions = {
                        type = "quest",
                        id = 27182,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 27215,
                    restrictions = {
                        type = "quest",
                        id = 27215,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 4792,
                },
            },
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27183,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27184,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27191,
            x = 0,
        },
        {
            type = "quest",
            id = 27186,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN07, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 23843,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27188,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27189,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27190,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN08, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 4926,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27253,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN09, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 23600,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27340,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN10, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 23601,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27336,
            x = 0,
        },
        {
            type = "quest",
            id = 27339,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN11, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 4500,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27424,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN12, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 4501,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27414,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27416,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27417,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27415,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN13, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 4502,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 1168,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN14, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "object",
            id = 186426,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27412,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN15, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 23570,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27413,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_EMBED_CHAIN16, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 20985,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27246,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27247,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 26687,
        },
        {
            type = "quest",
            id = 27248,
        },
        {
            type = "quest",
            id = 11212,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 1205,
        },
        {
            type = "quest",
            id = 25292,
        },
        {
            type = "quest",
            id = 11213,
        },
        {
            type = "quest",
            id = 11215,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 11211,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851099,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_WILD_THREATS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_WORK_LEFT_UNDONE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_SWAMP_EYE_STORY_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CONNECTION_TO_THE_GRIMTOTEM,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_ONYXIAS_BROOD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHALLENGING_THE_OVERLORD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_CHALLENGE_OF_THE_STONEMAUL_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_DISGRACE_THE_DEFECTORS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_SWAMP_EYE_STORY_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_TERROR_OF_THERAMORE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_DEFIAS_IN_DUSTWALLOW,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_PRISONERS_OF_THE_GRIMTOTEM,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_HYAL_FAMILY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_THE_CHALLENGE_OF_THE_STONEMAUL_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN02,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN03,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DUSTWALLOW_MARSH_CHAIN04,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_DUSTWALLOW_MARSH,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
