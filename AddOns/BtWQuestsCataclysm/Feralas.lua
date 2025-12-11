local MAP_ID = 69
local ACHIEVEMENT_ID_HORDE = 4979
local ACHIEVEMENT_ID_ALLIANCE = 4932
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_FATE_OF_TAERAR_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_FATE_OF_TAERAR_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {28510, 26589, 25210},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25250,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_EMBED_CHAIN01,
            aside = true,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28510,
                    restrictions = {
                        type = "quest",
                        id = 28510,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 26589,
                    restrictions = {
                        type = "quest",
                        id = 26589,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 39377,
                },
            },
            x = 4,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25210,
            x = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25230,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25237,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25241,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25250,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25386,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_TWILIGHT_SERMON_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_TWILIGHT_SERMON_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25209, 25341},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25329,
    },
    items = {
        {
            type = "npc",
            id = 39656,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25209,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25341,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25342,
            x = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25252,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25344,
            x = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25329,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25387,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_MUISEK, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_FORCES_OF_NATURE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25336},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25391,
    },
    items = {
        {
            type = "npc",
            id = 39894,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25336,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25337,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25641,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25338,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25345,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25361,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25346,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25362,
            aside = true,
        },
        {
            type = "quest",
            id = 25391,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_FREED_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_FREED_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25643},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25645,
    },
    items = {
        {
            type = "npc",
            id = 5390,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25643,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25422,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25423,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25368,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25645,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_DRAGONS_OF_NIGHTMARE_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_DRAGONS_OF_NIGHTMARE_ALLIANCE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25349},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25383,
    },
    items = {
        {
            type = "npc",
            id = 39847,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25349,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25378,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25379,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25383,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_FATE_OF_TAERAR_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_FATE_OF_TAERAR_HORDE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {14410, 28511, 25447},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25398,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 14410,
                    restrictions = {
                        type = "quest",
                        id = 14410,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28511,
                    restrictions = {
                        type = "quest",
                        id = 28511,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 40032,
                },
            },
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_EMBED_CHAIN02,
            aside = true,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 25447,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25394,
            x = 3,
            y = 2,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25396,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25397,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25398,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_TWILIGHT_SERMON_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_TWILIGHT_SERMON_HORDE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25400, 25401},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25333,
    },
    items = {
        {
            type = "npc",
            id = 39653,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25400,
            x = 2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25401,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25402,
            x = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25403,
            x = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25406,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25208,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25333,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_FREED_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_FREED_HORDE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25350},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26401,
    },
    items = {
        {
            type = "npc",
            id = 40132,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25350,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25422,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25423,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25368,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26401,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_FORCES_OF_NATURE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_MUISEK,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25407},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25468, 25469},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 40078,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25407,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25409,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25410,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 40913,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25468,
            x = 2,
        },
        {
            type = "quest",
            id = 25469,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_DRAGONS_OF_NIGHTMARE_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_DRAGONS_OF_NIGHTMARE_HORDE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {26574, 25426, 25432},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25438,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26574,
                    restrictions = {
                        type = "quest",
                        id = 26574,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 39725,
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
            id = 25426,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25432,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25427,
            x = 1,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 25433,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25434,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25429,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25431,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25436,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25437,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25379,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25438,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN01, {
    name = { -- The Mark of Quality
        type = "quest",
        id = 25449,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN02,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25449, 25450},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25451,
    },
    items = {
        {
            type = "npc",
            id = 40226,
            x = 2,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25449,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "kill",
            id = 39896,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25450,
            x = 2,
        },
        {
            type = "quest",
            id = 25451,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN02, {
    name = { -- The Mark of Quality
        type = "quest",
        id = 25452,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN01,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25452, 25453},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25454,
    },
    items = {
        {
            type = "npc",
            id = 7854,
            x = 2,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25452,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "kill",
            id = 39896,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25453,
            x = 2,
        },
        {
            type = "quest",
            id = 25454,
        },
    },
})
-- Need to take a closer look at this, probably should be attached to the next part
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26402,
                    restrictions = {
                        type = "quest",
                        id = 26402,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 3936,
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
            id = 25304,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN04, {
    name = { -- Tambre
        type = "npc",
        id = 39723,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25458, 25399},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25463, 25399},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 39723,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25458,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25399,
        },
        {
            type = "quest",
            id = 25463,
            x = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN05, {
    name = { -- Zorbin Fandazzle
        type = "npc",
        id = 14637,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
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
        ids = {25465, 25466},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25465, 25466},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 14637,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25465,
            x = 2,
        },
        {
            type = "quest",
            id = 25466,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN06, {
    name = { -- Chief Spirithorn
        type = "npc",
        id = 39847,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25373},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25374, 25375},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 39847,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25373,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25374,
            x = 2,
        },
        {
            type = "quest",
            id = 25375,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN07, {
    name = { -- Hadoken Swiftstrider
        type = "npc",
        id = 7875,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {25363},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25364, 25369, 25367},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 7875,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25363,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25365,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25364,
        },
        {
            type = "quest",
            id = 25366,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25369,
            x = 2,
        },
        {
            type = "quest",
            id = 25367,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 7776,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25339,
            x = 0,
        },
        {
            type = "quest",
            id = 25340,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 40035,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25448,
            x = 0,
        },
        {
            type = "quest",
            id = 25654,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FERALAS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 41395,
        },
        {
            type = "quest",
            id = 25305,
        },
        {
            type = "quest",
            id = 41394,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_FERALAS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851102,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_FATE_OF_TAERAR_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_TWILIGHT_SERMON_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_MUISEK,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_FREED_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_DRAGONS_OF_NIGHTMARE_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_FATE_OF_TAERAR_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_TWILIGHT_SERMON_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_FREED_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_FORCES_OF_NATURE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_THE_DRAGONS_OF_NIGHTMARE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN02,
        },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN03,
        -- },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN06,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN07,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FERALAS_CHAIN05,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_FERALAS,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
