local MAP_ID = 51
local ACHIEVEMENT_ID = 4904
local CONTINENT_ID = 13

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_BOGPADDLE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
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
        ids = {28569, 28570, 28675, 28677, 27587},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27600,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28569,
                    restrictions = {
                        type = "quest",
                        id = 28569,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 28570,
                    restrictions = {
                        type = "quest",
                        id = 28570,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 28675,
                    restrictions = {
                        type = "quest",
                        id = 28675,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 28677,
                    restrictions = {
                        type = "quest",
                        id = 28677,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 45786,
                },
            },
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_EMBED_CHAIN01,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 27587,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27536,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27656,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27663,
            aside = true,
        },
        {
            type = "quest",
            id = 27597,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27598,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27599,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27600,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27740,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_BLOODMIRE_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_BLOODMIRE_HORDE,
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
        ids = {27870, 27821, 27822},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {27849, 27851},
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27870,
                    restrictions = {
                        type = "quest",
                        id = 27870,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 46676,
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
            id = 27821,
            x = 2,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 27822,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27795,
            x = 1,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 27843,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27845,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27851,
            x = 2,
        },
        {
            type = "quest",
            id = 27849,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_BLOODMIRE_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_BLOODMIRE_ALLIANCE,
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
        ids = {27871, 27852, 27853},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27857,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27871,
                    restrictions = {
                        type = "quest",
                        id = 27871,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 7623,
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
            id = 27852,
            x = 2,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 27853,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27854,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27855,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27856,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27857,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27906,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SHIFTING_MIRE_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SHIFTING_MIRE_HORDE,
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
        ids = {27875, 27876},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24913,
    },
    items = {
        {
            type = "npc",
            id = 17127,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27875,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27876,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27902,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27904,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24913,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SHIFTING_MIRE_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SHIFTING_MIRE_ALLIANCE,
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
        ids = {27907, 27908},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27911,
    },
    items = {
        {
            type = "npc",
            id = 47041,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27907,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27908,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27909,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27910,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27911,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27916,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SUNKEN_TEMPLE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
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
        ids = {27869, 27694},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27914,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27869,
                    restrictions = {
                        type = "quest",
                        id = 27869,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 46071,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27694,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27704,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27705,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27768,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27773,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27914,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_CHAIN01, {
    name = { -- Baba Bogbrew
        type = "npc",
        id = 46172,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
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
        ids = {27691},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27818,
    },
    items = {
        {
            type = "npc",
            id = 46172,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27691,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27757,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27818,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_CHAIN02, {
    name = { -- Holaaru
        type = "npc",
        id = 18221,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
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
        ids = {27860, 27840},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27918,
    },
    items = {
        {
            type = "npc",
            id = 18221,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27860,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27840,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27918,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 46010,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27592,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851108,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_BOGPADDLE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_BLOODMIRE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_BLOODMIRE_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SHIFTING_MIRE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SHIFTING_MIRE_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_THE_SUNKEN_TEMPLE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SWAMP_OF_SORROWS_CHAIN02,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SWAMP_OF_SORROWS,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
