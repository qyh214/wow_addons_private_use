local L = BtWQuests.L
local MAP_ID = 66
local ACHIEVEMENT_ID = 4930
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THE_NAGA_THREAT, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {14255, 14365, 14256},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 14302,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 14255,
                    restrictions = {
                        type = "quest",
                        id = 14255,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 14365,
                    restrictions = {
                        type = "quest",
                        id = 14365,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 35773,
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
            id = 14256,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14257,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14260,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14264,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14268,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14282,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14292,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14284,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14301,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14302,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_KARNUMS_GLADE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {14307, 14305, 14304},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {14307, 14327, 14309},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN01,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "npc",
            id = 36060,
            x = 3,
            y = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN02,
            x = 6,
            y = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 14305,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14306,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14311,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14312,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 14316,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14314,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14318,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14325,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14327,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_UNITING_THE_TRIBES,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_HORDE,
    },
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
        ids = {14372, 14373, 14374},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 14381,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 14372,
                    restrictions = {
                        type = "quest",
                        id = 14372,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 36329,
                },
            },
            x = 3,
            y = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN03,
            aside = true,
            x = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 14373,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 14374,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 14378,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14379,
        },
        {
            type = "quest",
            id = 14380,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14381,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_ALLIANCE,
    },
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
        ids = {14338, 14339},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 14346,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN07,
            aside = true,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 14338,
                    restrictions = {
                        type = "quest",
                        id = 14338,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 4498,
                },
            },
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN08,
            x = 4,
            embed = true,
        },
        {
            type = "quest",
            id = 14339,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14343,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN03,
            x = 5,
            embed = true,
        },
        {
            type = "quest",
            id = 14346,
            x = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_UNITING_THE_TRIBES, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_KARNUMS_GLADE,
        },
    },
    active = {
        type = "quest",
        ids = {14328},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 14394,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_KARNUMS_GLADE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14328,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN04,
            aside = true,
            x = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 14329,
            x = 2,
        },
        {
            type = "quest",
            id = 14330,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN05,
            aside = true,
            x = 6,
            embed = true,
        },
        {
            type = "quest",
            id = 14332,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14393,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14394,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_HORDE,
    },
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
        ids = {25938, 28531, 14384},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {14364, 1456},
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25938,
                    restrictions = {
                        type = "quest",
                        id = 25938,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28531,
                    restrictions = {
                        type = "quest",
                        id = 28531,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 36410,
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
            id = 14384,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14387,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14354,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN06,
            x = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 14361,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 1454,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN07,
        },
        {
            type = "quest",
            id = 14363,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 1455,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14364,
            x = 2,
        },
        {
            type = "quest",
            id = 1456,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_ON_BEHALF_OF_THE_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_ALLIANCE,
    },
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
        ids = {28548, 26134, 14184, 14342, 5581, 14337, 5421, 14334, 14335},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {14227, 14198, 14342, 5581, 5421, 14334, 14335},
        count = 7,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN01,
            x = 1,
            y = 0,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN08,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN01, {
    name = { -- Rider on the Storm
        type = "quest",
        id = 14198,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
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
        ids = {28548, 26134, 14184},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {14227, 14198},
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28548,
                    restrictions = {
                        type = "quest",
                        id = 28548,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 26134,
                    restrictions = {
                        type = "quest",
                        id = 26134,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 35286,
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
            id = 14184,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14188,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14189,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14191,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN06,
            x = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 14223,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14360,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14225,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14195,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 14227,
            x = 2,
        },
        {
            type = "quest",
            id = 14196,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14198,
            x = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN02, {
    name = { -- Heavy Metal
        type = "quest",
        id = 14254,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {14246, 14247},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 14254,
    },
    items = {
        {
            type = "npc",
            id = 35661,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 14246,
            x = 2,
        },
        {
            type = "quest",
            id = 14247,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14254,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN03, {
    name = { -- Hornizz Brimbuzzle
        type = "npc",
        id = 6019,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 6134,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 6134,
    },
    items = {
        {
            type = "npc",
            id = 6019,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 6134,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN04, {
    name = {
        type = "npc",
        id = 11596,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 5561,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 5561,
    },
    items = {
        {
            type = "npc",
            id = 11596,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 5561,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN05, {
    name = {
        type = "npc",
        id = 11438,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 5501,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 5501,
    },
    items = {
        {
            type = "npc",
            id = 11438,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 5501,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN06, {
    name = {
        type = "npc",
        id = 35757,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {14251, 14252, 14253},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {14251, 14252, 14253},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 35757,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 14251,
            x = 1,
        },
        {
            type = "quest",
            id = 14252,
        },
        {
            type = "quest",
            id = 14253,
        },
    },
})
-- @TODO Alliance only for now
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN07, {
    name = L["SHRINES"],
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
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
        ids = {14193, 14358, 14213, 14357, 14219},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {14193, 14358, 14213, 14357, 14219},
        count = 5,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN09,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN10,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN11,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN08, {
    name = { -- Shadowprey Village
        type = "quest",
        id = 14337,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
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
        ids = {14337, 5421, 14334, 14335},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {5421, 14334, 14335},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 11317,
            x = 1,
            y = 0,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 14337,
                    restrictions = {
                        type = "quest",
                        id = 14337,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 12031,
                },
            },
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 11624,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 5421,
            x = 1,
        },
        {
            type = "quest",
            id = 14334,
        },
        {
            type = "quest",
            id = 14335,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 36034,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14307,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 36048,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14304,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14309,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "quest",
            ids = {
                14376, 14344, 
            },
            x = 0,
            y = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 12277,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 6132,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN05, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "object",
            id = 196393,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14333,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN06, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            name = L["KILL_BURNING_BLADE_WARLOCKS"],
            breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                14362, 14232, 
            },
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN07, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 11259,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14341,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN08, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 5395,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 14342,
            x = 0,
        },
        {
            type = "quest",
            id = 5581,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN09, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "object",
            id = 195438,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 14193,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN10, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "object",
            id = 195497,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                14358, 14213, 
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                14359, 14217, 
            },
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_EMBED_CHAIN11, {
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "object",
            id = 195517,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                14357, 14219, 
            },
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "quest",
            id = 6143,
        },
        {
            type = "quest",
            id = 6142,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DESOLACE_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "quest",
            id = 1467,
        },
        {
            type = "quest",
            id = 5943,
        },
        {
            type = "quest",
            id = 5821,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_DESOLACE, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851097,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THE_NAGA_THREAT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_KARNUMS_GLADE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_THREATS_FROM_SARTHERIS_STAND_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_UNITING_THE_TRIBES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_ON_BEHALF_OF_THE_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN08,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN07,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN02,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN03,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN05,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_DESOLACE_CHAIN06,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_DESOLACE,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})

