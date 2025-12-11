local MAP_ID = 32
local ACHIEVEMENT_ID = 4910
local CONTINENT_ID = 13

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THORIUM_ADVANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
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
        ids = {28512, 28581, 28582, 27956, 27963},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27964,
    },
    items = {
        {
            type = "npc",
            id = 47269,
            x = 0,
            y = 0,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28512,
                    restrictions = {
                        type = "quest",
                        id = 28512,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28581,
                    restrictions = {
                        type = "quest",
                        id = 28581,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28582,
                    restrictions = {
                        type = "quest",
                        id = 28582,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 47266,
                },
            },
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_EMBED_CHAIN01,
            aside = true,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 27956,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27963,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27957,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27964,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27958,
            aside = true,
            x = 0,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THE_SEAT_OF_THE_BROTHERHOOD,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THE_SEAT_OF_THE_BROTHERHOOD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THORIUM_ADVANCE,
        },
        {
            type = "quest",
            id = 27957,
        },
    },
    active = {
        type = "quest",
        ids = {27965},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27979,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THORIUM_ADVANCE,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_EMBED_CHAIN02,
            aside = true,
            x = 6,
            embed = true,
        },
        {
            type = "quest",
            id = 27965,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 27976,
            x = 0,
            connections = {
                4, 5, 
            },
        },
        {
            type = "quest",
            id = 27981,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27977,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28099,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 27982,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 27979,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_EMBED_CHAIN03,
            aside = true,
            x = 6,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_IN_THE_HALL_OF_THE_MOUNTAINLORD,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_IN_THE_HALL_OF_THE_MOUNTAINLORD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THE_SEAT_OF_THE_BROTHERHOOD,
        },
    },
    active = {
        type = "quest",
        ids = {27986},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28035,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THE_SEAT_OF_THE_BROTHERHOOD,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27986,
            x = 3,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 28028,
            x = 0,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 28029,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28030,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28032,
            aside = true,
        },
        {
            type = "quest",
            id = 28033,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28034,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28035,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_INTO_THE_GORGE,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_INTO_THE_GORGE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
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
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_IN_THE_HALL_OF_THE_MOUNTAINLORD,
        },
    },
    active = {
        type = "quest",
        ids = {28052},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28064,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_IN_THE_HALL_OF_THE_MOUNTAINLORD,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28052,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28054,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 28055,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28056,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28057,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28060,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28062,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 28061,
            aside = true,
        },
        {
            type = "quest",
            id = 28053,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 28064,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 47267,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27960,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27961,
            x = 0,
        },
        {
            type = "quest",
            id = 27962,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 14634,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27980,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 8436,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27984,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27985,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 28058,
        },
        {
            type = "quest",
            id = 7737,
        },
        {
            type = "quest",
            id = 13662,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851105,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THORIUM_ADVANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_THE_SEAT_OF_THE_BROTHERHOOD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_IN_THE_HALL_OF_THE_MOUNTAINLORD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_INTO_THE_GORGE,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SEARING_GORGE,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_SEARING_GORGE_EMBED_CHAIN03,
    },
})
