local MAP_ID = 15
local ACHIEVEMENT_ID = 4900
local CONTINENT_ID = 13

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
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
        ids = {27762, 28579, 28580, 27763, 27774},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27769,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27762,
                    restrictions = {
                        type = "quest",
                        id = 27762,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28579,
                    restrictions = {
                        type = "quest",
                        id = 28579,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28580,
                    restrictions = {
                        type = "quest",
                        id = 28580,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 46650,
                },
            },
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN09,
            aside = true,
            x = 1,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 27763,
            breadcrumb = true,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27774,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27764,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27765,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27766,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27770,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27771,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27769,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27772,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27789,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_ALLIANCE,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_HORDE,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_FATE_OF_A_DRAGONFLIGHT_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_ALLIANCE,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_ALLIANCE,
    },
    completed = {
        type = "quest",
        id = 27859,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_ALLIANCE,
            x = 3,
            y = 0,
            connections = {
               2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN14,
            aside = true,
            x = 1,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 27826,
            x = 3,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN15,
            aside = true,
            x = 5,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 27827,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27828,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27834,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27835,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27829,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27830,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27831,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27832,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27858,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27930,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27859,
            x = 3,
            connections = {
                
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_FATE_OF_A_DRAGONFLIGHT_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_HORDE,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_HORDE,
    },
    completed = {
        type = "quest",
        id = 27859,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_HORDE,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN12,
            aside = true,
            x = 1,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 27889,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN13,
            aside = true,
            x = 5,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 27890,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 27891,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27892,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27893,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27894,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27895,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27896,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27897,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27898,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27930,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27859,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
    },
    completed = {
        type = "quest",
        id = 27794,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN04,
            x = 0,
            y = 1,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 27791,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27792,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27796,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27797,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27693,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27709,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27793,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27912,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27794,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_FATE_OF_A_DRAGONFLIGHT_ALLIANCE,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
    },
    completed = {
        type = "quest",
        id = 27888,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN11,
            aside = true,
            x = 1,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 27881,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN10,
            aside = true,
            x = 5,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 27882,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27883,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 27884,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27885,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27886,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27887,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27913,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27888,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_FATE_OF_A_DRAGONFLIGHT_HORDE,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_DAY_THAT_DEATHWING_CAME, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
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
        ids = {27927, 27713},
    },
    completed = {
        type = "quest",
        id = 27715,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27927,
                    restrictions = {
                        type = "quest",
                        id = 27927,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 2785,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27713,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27714,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27715,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    completed = {
        type = "quest",
        id = 27824,
    },
    items = {
        {
            type = "npc",
            id = 2860,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27823,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27824,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN09, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    completed = {
        type = "quest",
        id = 27776,
    },
    items = {
        {
            type = "npc",
            id = 46653,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27775,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27776,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN10, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 46758,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27878,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN11, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 46759,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27877,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN12, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 46660,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27879,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN13, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 1068,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27880,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN14, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 46930,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27825,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_TEMP_CHAIN15, {
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 46972,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27833,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_BADLANDS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_BADLANDS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851093,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_RHEA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_FATE_OF_A_DRAGONFLIGHT_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_FATE_OF_A_DRAGONFLIGHT_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_TITANS_KNOWLEDGE_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_BADLANDS_THE_DAY_THAT_DEATHWING_CAME,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_BADLANDS,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
