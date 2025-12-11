local L = BtWQuests.L;
local MAP_ID = 77
local ACHIEVEMENT_ID = 4931
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMERALD_SANCTUARY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
        ids = {28542, 28543, 27997, 28100, 28148},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27997, 27995, 28148},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN01,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "npc",
            id = 11554,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN02,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 28100,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27989,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27994,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27995,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_RUINS_OF_CONSTELLAS, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
        ids = {28150, 28000},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28288,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28150,
                    restrictions = {
                        type = "quest",
                        id = 28150,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 47341,
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
            id = 28000,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28049,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28044,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28113,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28102,
            aside = true,
        },
        {
            type = "quest",
            id = 28288,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WILDHEART_POINT, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
        ids = {28152, 28116},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28128, 28126, 28155},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN03,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28152,
                    restrictions = {
                        type = "quest",
                        id = 28152,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 10922,
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
            id = 28116,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28119,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28128,
            x = 1,
        },
        {
            type = "quest",
            id = 28129,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28126,
        },
        {
            type = "quest",
            id = 28131,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28153,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28155,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_BLOODVENOM_POST, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
        ids = {28305, 28190, 28207},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28214, 28213},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 47692,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28305,
                    restrictions = {
                        type = "quest",
                        id = 28305,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 47696,
                },
            },
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28190,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28207,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28208,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28214,
            x = 2,
        },
        {
            type = "quest",
            id = 28213,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WHISPERWIND_GROVE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
        ids = {28341, 28342, 28358, 28359, 28306, 28360},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28341, 28342, 28358, 28359, 28374},
        count = 5,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN04,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN05,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN06,
            x = 2,
            y = 2,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_REJOINING_THE_FOREST, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
            id = 28374,
        },
    },
    active = {
        type = "quest",
        ids = {28229},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28228,
    },
    items = {
        {
            type = "npc",
            id = 48126,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28229,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28219,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28220,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28221,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28222,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28224,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28228,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_A_DESTINY_OF_FLAME_AND_SORROW, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
            id = 28374,
        },
    },
    active = {
        type = "quest",
        ids = {28217},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28264,
    },
    items = {
        {
            type = "npc",
            id = 47843,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28217,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28218,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28256,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28257,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28261,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28264,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WAR_IN_THE_FOREST_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 8),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WAR_IN_THE_FOREST_HORDE,
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
        ids = {28381, 28383, 28382},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28389,
    },
    items = {
        {
            type = "npc",
            id = 48492,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28381,
                    restrictions = {
                        type = "quest",
                        id = 28381,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 47931,
                },
            },
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28383,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28382,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28384,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28337,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28385,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28386,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28387,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28388,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28389,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WAR_IN_THE_FOREST_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 8),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WAR_IN_THE_FOREST_ALLIANCE,
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
        ids = {28372, 28333, 28334},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28340, 28368},
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28372,
                    restrictions = {
                        type = "quest",
                        id = 28372,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 48127,
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
            id = 28333,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28334,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28357,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28370,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28339,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28336,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28380,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28335,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28340,
        },
        {
            type = "quest",
            id = 28368,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_THE_TIMBERMAWS_ALLY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 9),
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
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
        ids = {28373, 28392, 28338, 28366, 28362},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28338, 28366, 28364},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN07,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN08,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN09,
            aside = true,
            x = 6,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28542,
                    restrictions = {
                        type = "quest",
                        id = 28542,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28543,
                    restrictions = {
                        type = "quest",
                        id = 28543,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 10923,
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
            id = 27997,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 10921,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28148,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 11019,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28121,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 48339,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28341,
            x = 0,
        },
        {
            type = "quest",
            id = 28342,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN05, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 48349,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28358,
            x = 0,
        },
        {
            type = "quest",
            id = 28359,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN06, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28306,
                    restrictions = {
                        type = "quest",
                        id = 28306,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 48459,
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
            id = 28360,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28361,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28374,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_REJOINING_THE_FOREST,
            x = 0,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_A_DESTINY_OF_FLAME_AND_SORROW,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN07, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28373,
                    restrictions = {
                        type = "quest",
                        id = 28373,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28392,
                    restrictions = {
                        type = "quest",
                        id = 28392,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 15395,
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
            id = 28338,
            x = 0,
        },
        {
            type = "quest",
            id = 28366,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN08, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 48461,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28362,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28364,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMBED_CHAIN09, {
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            name = L["KILL_DEADWOOD_FURBOLGS"],
            breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8470,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_FELWOOD_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 6031,
        },
        {
            type = "quest",
            id = 28396,
        },
        {
            type = "quest",
            id = 29028,
        },
        {
            type = "quest",
            id = 28395,
        },
        {
            type = "quest",
            id = 28521,
        },
        {
            type = "quest",
            id = 28342,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_FELWOOD, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851101,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_EMERALD_SANCTUARY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_RUINS_OF_CONSTELLAS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WILDHEART_POINT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_BLOODVENOM_POST,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WHISPERWIND_GROVE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_REJOINING_THE_FOREST,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_A_DESTINY_OF_FLAME_AND_SORROW,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WAR_IN_THE_FOREST_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_WAR_IN_THE_FOREST_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_FELWOOD_THE_TIMBERMAWS_ALLY,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_FELWOOD,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
