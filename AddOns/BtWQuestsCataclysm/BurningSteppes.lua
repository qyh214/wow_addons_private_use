local MAP_ID = 36
local ACHIEVEMENT_ID = 4901
local CONTINENT_ID = 13

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_HORDE,
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
        ids = {28666, 28174, 28416},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28183,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28666,
                    restrictions = {
                        type = "quest",
                        id = 28666,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 47811,
                },
            },
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28514,
                    restrictions = {
                        type = "quest",
                        id = 28514,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 47779,
                },
            },
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            ids = {
                28174, 28416, 
            },
            x = 3,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28172,
            aside = true,
        },
        {
            type = "quest",
            id = 28177,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28178,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28179,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28180,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28181,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28182,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28183,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_ALLIANCE,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_ALLIANCE,
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
        ids = {28667, 28418},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28425,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28667,
                    restrictions = {
                        type = "quest",
                        id = 28667,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 48559,
                },
            },
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28515,
                    restrictions = {
                        type = "quest",
                        id = 28515,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 47779,
                },
            },
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28418,
            x = 3,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28417,
            aside = true,
        },
        {
            type = "quest",
            id = 28419,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28420,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28421,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28422,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28423,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28424,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28425,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = 13006,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_HORDE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_ALLIANCE,
        },
        {
            type = "quest",
            id = 28172,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_ALLIANCE,
        },
    },
    active = {
        type = "quest",
        ids = {28317, 28318, 28319},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28322,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_ALLIANCE,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28317,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28318,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28319,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28327,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28320,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28321,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28322,
            x = 3,
            connections = {
                
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_ALLIANCE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_HORDE,
        },
        {
            type = "quest",
            id = 28417,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_HORDE,
        },
    },
    active = {
        type = "quest",
        ids = {28450, 28451, 28452},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28456,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_HORDE,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28450,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28451,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28452,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28453,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28454,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28455,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28456,
            x = 3,
            connections = {
                
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_HORDE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_ALLIANCE,
        },
        {
            type = "quest",
            id = 28172,
        },
    },
    active = {
        type = "quest",
        ids = {28184},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28286,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_ALLIANCE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28184,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28225,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28226,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28254,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28227,
            x = 2,
        },
        {
            type = "quest",
            ids = {
                28202, 28203, 28204, 28205, 
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28239,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28245,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28246,
        },
        {
            type = "quest",
            id = 28252,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28253,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28265,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28266,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28278,
            x = 2,
        },
        {
            type = "quest",
            id = 28279,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28286,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_ALLIANCE,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_ALLIANCE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_HORDE,
        },
        {
            type = "quest",
            id = 28417,
        },
    },
    active = {
        type = "quest",
        ids = {28426},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28441,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_HORDE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28426,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28225,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28226,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28427,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28227,
            x = 2,
            connections = {
                
            },
        },
        {
            type = "quest",
            ids = {
                28428, 28429, 28430, 28431, 
            },
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28432,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28433,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28434,
        },
        {
            type = "quest",
            id = 28435,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28436,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28437,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28438,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28439,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 28440,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28441,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_HORDE,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_HORDE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_ALLIANCE,
        },
        {
            type = "quest",
            id = 28172,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_ALLIANCE,
        },
    },
    active = {
        type = "quest",
        ids = {28310},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28326,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_ALLIANCE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28310,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28415,
            x = 0,
        },
        {
            type = "quest",
            id = 28311,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 28312,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28313,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28314,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28315,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28316,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28326,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_ALLIANCE,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_ALLIANCE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_HORDE,
        },
        {
            type = "quest",
            id = 28417,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_HORDE,
        },
    },
    active = {
        type = "quest",
        ids = {28442},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28449,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_HORDE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28442,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28491,
            x = 0,
        },
        {
            type = "quest",
            id = 28443,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 28444,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28445,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28446,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28447,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28448,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28449,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_HORDE,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851095,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_PREPARATION_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANNIHILATION_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_INFILTRATION_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BURNING_STEPPES_ANTICIPATION_HORDE,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_BURNING_STEPPES,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})