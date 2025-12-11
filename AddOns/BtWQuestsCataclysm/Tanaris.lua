local L = BtWQuests.L;
local MAP_ID = 71
local ACHIEVEMENT_ID = 4935
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_HORDE,
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
            type = "quest",
            id = 25050,
        },
    },
    active = {
        type = "quest",
        ids = {25121, 25053, 25052, 25054},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25166,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25121,
                    restrictions = {
                        type = "quest",
                        id = 25121,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38704,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25053,
            x = 1,
        },
        {
            type = "quest",
            id = 25052,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25054,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26886,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26887,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25166,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_BUG_FREE,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_ALLIANCE,
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
            type = "quest",
            id = 24910,
        },
    },
    active = {
        type = "quest",
        ids = {24947, 24928, 24927, 24949},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24950,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 24947,
                    restrictions = {
                        type = "quest",
                        id = 24947,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38703,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 24928,
            x = 1,
        },
        {
            type = "quest",
            id = 24927,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24949,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25534,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25541,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24950,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_BUG_FREE,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_BUG_FREE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
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
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_HORDE,
        },
    },
    active = {
        type = "quest",
        ids = {26889, 24932},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24953,
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_ALLIANCE,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_HORDE,
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
                    id = 26889,
                    restrictions = {
                        type = "quest",
                        id = 26889,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 25103,
                },
            },
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24932,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25072,
        },
        {
            type = "quest",
            id = 24931,
            x = 1,
        },
        {
            type = "quest",
            id = 24933,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24951,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24953,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_ADVANCING_OUR_INTERESTS_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_ADVANCING_OUR_INTERESTS_HORDE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_ALLIANCE,
        },
    },
    active = {
        type = "quest",
        ids = {25061, 25060, 25062},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25065,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25061,
                    restrictions = {
                        type = "quest",
                        id = 25061,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 39059,
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
            id = 25060,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25062,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25063,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25065,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_ADVANCING_OUR_INTERESTS_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_ADVANCING_OUR_INTERESTS_ALLIANCE,
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
        ids = {24905, 24955},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25001,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 24905,
                    restrictions = {
                        type = "quest",
                        id = 24905,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38849,
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
            id = 24955,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24957,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24963,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN01,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 25001,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_GRUDGE_MATCH, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {26895, 26896, 25067},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25513, 25591},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26895,
                    restrictions = {
                        type = "quest",
                        id = 26895,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 26896,
                    restrictions = {
                        type = "quest",
                        id = 26896,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 39034,
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
            id = 25067,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25094,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25095,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25513,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 25591,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_THE_TITANS_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_THE_TITANS_HORDE,
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
        ids = {28881, 25420},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25421,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28881,
                    restrictions = {
                        type = "quest",
                        id = 28881,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 40109,
                },
            },
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25420,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25559,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25565,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25566,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25070,
            x = 3,
        },
        {
            type = "quest",
            id = 25421,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_THE_TITANS_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_THE_TITANS_ALLIANCE,
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
        ids = {25019},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25107,
    },
    items = {
        {
            type = "npc",
            id = 38922,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25019,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25020,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25017,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25069,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25068,
            aside = true,
        },
        {
            type = "quest",
            id = 25070,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25107,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN01, {
    name = L["BTWQUESTS_INTRODUCTION"],
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN02,
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
        ids = {26895, 26896, 25067, 28507, 25049, 25048, 25112},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_GRUDGE_MATCH,
        },
        {
            type = "quest",
            ids = {25050, 25091},
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_GRUDGE_MATCH,
            x = -3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN02,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN04,
            x = 6,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN02, {
    name = L["BTWQUESTS_INTRODUCTION"],
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN01,
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
        ids = {26895, 26896, 25067, 28509, 24907, 24906, 25112},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_GRUDGE_MATCH,
        },
        {
            type = "quest",
            ids = {24910, 25091},
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_GRUDGE_MATCH,
            x = -3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN03,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN04,
            x = 6,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN03, {
    name = { -- Sandsorrow Watch
        type = "quest",
        id = 25091,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
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
        ids = {25021},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25032,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN05,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "npc",
            id = 38927,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25021,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25025,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25026,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25032,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "object",
            id = 202407,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25014,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25018,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28507,
                    restrictions = {
                        type = "quest",
                        id = 28507,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38535,
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
            id = 25049,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25048,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25050,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_ALLIANCE,
            x = 1,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28509,
                    restrictions = {
                        type = "quest",
                        id = 28509,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38534,
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
            id = 24907,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24906,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24910,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_HORDE,
            x = 1,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 39178,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25112,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25111,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25115,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25091,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_EMBED_CHAIN05, {
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 40580,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25521,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25522,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 25061,
        },
        {
            type = "quest",
            id = 27446,
        },
        {
            type = "quest",
            id = 26895,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 27447,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_TANARIS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 42237,
        },
        {
            type = "quest",
            id = 43293,
        },
        {
            type = "quest",
            id = 38892,
        },
        {
            type = "quest",
            id = 38896,
        },
        {
            type = "quest",
            id = 43294,
        },
        {
            type = "quest",
            id = 9268,
        },
        {
            type = "quest",
            id = 8765,
        },
        {
            type = "quest",
            id = 8764,
        },
        {
            type = "quest",
            id = 43244,
        },
        {
            type = "quest",
            id = 8766,
        },
        {
            type = "quest",
            id = 38890,
        },
        {
            type = "quest",
            id = 43243,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_TANARIS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851109,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_SOUTHSEA_PIRATES_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_BUG_FREE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_ADVANCING_OUR_INTERESTS_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_ADVANCING_OUR_INTERESTS_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_GRUDGE_MATCH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_THE_TITANS_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_THE_TITANS_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN02,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_TANARIS_CHAIN03,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_TANARIS,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
