local MAP_ID = 81
local ACHIEVEMENT_ID = 4934
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
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
        ids = {8320},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 8321,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN03,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "npc",
            id = 15270,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8320,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8321,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_MISTRESS_NATALIA_MARALITH,
            aside = true,
            x = 2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_A_TERRIBLE_PURPOSE,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_MISTRESS_NATALIA_MARALITH, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
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
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
    },
    completed = {
        type = "quest",
        id = 8306,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8304,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 8306,
            x = 2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_UNRAVELING_THE_MYSTERY,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_UNRAVELING_THE_MYSTERY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
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
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
        },
        {
            type = "quest",
            id = 8304,
        },
    },
    active = {
        type = "quest",
        id = 8304,
    },
    completed = {
        type = "quest",
        id = 8314,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_MISTRESS_NATALIA_MARALITH,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 8309,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 8310,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8314,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_A_TERRIBLE_PURPOSE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
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
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
    },
    completed = {
        type = "quest",
        id = 8287,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8284,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8285,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8279,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 8287,
            x = 2,
            connections = {
                
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHT_LEXICON,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHT_LEXICON, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
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
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
        },
        {
            type = "quest",
            id = 8279,
        },
    },
    active = {
        type = "quest",
        id = 8279,
    },
    completed = {
        type = "quest",
        id = 8323,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_A_TERRIBLE_PURPOSE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8323,
            x = 3,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN01, {
    name = "Stepping Up Security",
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
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
        ids = {28527, 28528, 28856, 28859, 8280, 8277},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {8281, 8282},
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN04,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28527,
                    restrictions = {
                        type = "quest",
                        id = 28527,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28528,
                    restrictions = {
                        type = "quest",
                        id = 28528,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28856,
                    restrictions = {
                        type = "quest",
                        id = 28856,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28859,
                    restrictions = {
                        type = "quest",
                        id = 28859,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 15191,
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
            id = 8280,
            x = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8281,
            x = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN05, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 17081,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9416,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 15306,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8318,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN02, {
    name = "Dummy 3",
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "object",
            id = 180448,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8283,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
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
        id = 8277,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 8282,
    },
    items = {
        {
            type = "npc",
            id = 15189,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8277,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8278,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 8282,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN06, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 17082,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 9415,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {

    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILITHUS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 8308,
        },
        {
            type = "quest",
            id = 8319,
        },
        {
            type = "quest",
            id = 8324,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_SILITHUS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851106,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHTS_RUN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_MISTRESS_NATALIA_MARALITH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_UNRAVELING_THE_MYSTERY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_A_TERRIBLE_PURPOSE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_TWILIGHT_LEXICON,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SILITHUS_CHAIN01,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SILITHUS,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
