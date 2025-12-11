local MAP_ID = 17
local ACHIEVEMENT_ID = 4909
local CONTINENT_ID = 13

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_RAZELIKH_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_RAZELIKH_HORDE,
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
        ids = {27919, 25715},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26171,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27919,
                    restrictions = {
                        type = "quest",
                        id = 27919,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 9540,
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
            id = 25715,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25708,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25709,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25714,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25716,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26157,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26158,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26159,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26172,
            aside = true,
        },
        {
            type = "quest",
            id = 26160,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26167,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26168,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26169,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26163,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_EMBED_CHAIN01,
            aside = true,
            x = 6,
            embed = true,
        },
        {
            type = "quest",
            id = 26164,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26165,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26166,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26161,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26162,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26170,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26171,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_RAZELIKH_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_RAZELIKH_ALLIANCE,
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
        ids = {28553, 28671, 28858, 28865, 25674},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25701,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28553,
                    restrictions = {
                        type = "quest",
                        id = 28553,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28671,
                    restrictions = {
                        type = "quest",
                        id = 28671,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28858,
                    restrictions = {
                        type = "quest",
                        id = 28858,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28865,
                    restrictions = {
                        type = "quest",
                        id = 28865,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 41124,
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
            id = 25674,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25676,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25675,
            aside = true,
        },
        {
            type = "quest",
            id = 25677,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25678,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25679,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25680,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25681,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25682,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25683,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25684,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25685,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25690,
            aside = true,
        },
        {
            type = "quest",
            id = 25686,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25687,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25688,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25689,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_EMBED_CHAIN02,
            aside = true,
            x = 6,
            embed = true,
        },
        {
            type = "quest",
            id = 25691,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25692,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25693,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25697,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25698,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25699,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25700,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25701,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_THE_TAINTED_FOREST_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_THE_TAINTED_FOREST_HORDE,
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
        ids = {26175, 26184},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26187,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26175,
                    restrictions = {
                        type = "quest",
                        id = 26175,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 42349,
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
            id = 26184,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26185,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26186,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26187,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_THE_TAINTED_FOREST_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_THE_TAINTED_FOREST_HORDE,
    },
    restrictions = {
        type = "faction",
        id = "Horde",
    },
    active = {
        type = "quest",
        ids = {25696, 25717},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25720,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25696,
                    restrictions = {
                        type = "quest",
                        id = 25696,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 42344,
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
            id = 25717,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25718,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25719,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25720,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_AVENGING_THE_ROCKPOOL, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
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
        ids = {25702, 25703},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25705, 25706},
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25702,
                    restrictions = {
                        type = "quest",
                        id = 25702,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 41354,
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
            id = 25703,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_EMBED_CHAIN03,
            aside = true,
            x = 6,
            embed = true,
        },
        {
            type = "quest",
            id = 25705,
            x = 2,
        },
        {
            type = "quest",
            id = 25706,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_CHAIN01, {
    name = { -- Nethergarde Needs You!
        type = "quest",
        id = 28867,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
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
        ids = {28673, 28857, 28867, 25710},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25711, 25712, 25713},
        count = 3,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28673,
                    restrictions = {
                        type = "quest",
                        id = 28673,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28857,
                    restrictions = {
                        type = "quest",
                        id = 28857,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28867,
                    restrictions = {
                        type = "quest",
                        id = 28867,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 5393,
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
            id = 25710,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25711,
            x = 1,
        },
        {
            type = "quest",
            id = 25712,
        },
        {
            type = "quest",
            id = 25713,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 16841,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26173,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26174,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 19254,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25694,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25695,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 41402,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25707,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 25772,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851094,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_RAZELIKH_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_RAZELIKH_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_THE_TAINTED_FOREST_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_THE_TAINTED_FOREST_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_AVENGING_THE_ROCKPOOL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BLASTED_LANDS_CHAIN01,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_BLASTED_LANDS,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})