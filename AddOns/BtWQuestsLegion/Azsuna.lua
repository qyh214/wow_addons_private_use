local L = BtWQuests.L;
local MAP_ID = 630
local CONTINENT_ID = 619
local ACHIEVEMENT_ID = 10763

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_BEHINDENEMYLINES, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10763, 1),
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 38834,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 37449,
    },
    items = {
        {
            type = "npc",
            id = 93337,
            x = 3,
            y = 0,
            connections = {
                1,
            }, 
        },
        {
            type = "quest",
            id = 38834,
            x = 3,
            connections = {
                1, 2
            }, 
        },
        {
            type = "quest",
            id = 37658,
            x = 2,
            connections = {
                2
            }, 
        },
        {
            type = "quest",
            id = 37653,
            x = 4,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 37660,
            x = 3,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 36920,
            x = 3,
            connections = {
                1, 2, 3
            }, 
        },
        {
            type = "quest",
            id = 36811,
            aside = true,
            x = 5,
            y = 4.25,
        },
        {
            type = "quest",
            id = 37450,
            x = 2,
            y = 5,
            connections = {
                2,
            }, 
        },
        {
            type = "quest",
            id = 37656,
            x = 4,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 37449,
            x = 3,
            connections = {
                1
            }, 
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_DEFENDINGAZUREWINGREPOSE,
            x = 3,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_DEFENDINGAZUREWINGREPOSE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10763, 2),
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_BEHINDENEMYLINES,
        },
    },
    active = {
        type = "quest",
        id = 38443,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 42756,
    },
    items = {
        {
            type = "npc",
            id = 93326,
            x = 3,
            y = 0,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 38443,
            x = 3,
            y = 1,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 37853,
            x = 3,
            y = 2,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 37991,
            x = 3,
            y = 3,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 42271,
            x = 3,
            y = 4,
            connections = {
                1, 2
            }, 
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_AZSUNAVERSUSAZSHARA,
            aside = true,
            x = 5,
            y = 4.25,
        },
        {
            type = "quest",
            id = 37855,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3
            }, 
        },
        {
            type = "quest",
            id = 37856,
            x = 1,
            y = 6,
            connections = {
                4
            }, 
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 37858,
                    restrictions = {
                        type = "quest",
                        id = 37858,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "npc",
                    id = 90065,
                }
            },
            x = 3,
            y = 6,
            connections = {
                2
            }, 
        },
        {
            type = "quest",
            id = 37859,
            x = 5,
            y = 6,
            connections = {
                2
            }, 
        },
        {
            type = "quest",
            id = 37957,
            x = 3,
            y = 7,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 37857,
            x = 3,
            y = 8,
            connections = {
                1, 2, 3
            }, 
        },
        {
            type = "quest",
            id = 37960,
            x = 2,
            y = 9,
            connections = {
                3, 4
            }, 
        },
        {
            type = "quest",
            id = 37959,
            x = 4,
            y = 9,
            connections = {
                2, 3
            }, 
        },
        {
            type = "quest",
            id = 37963,
            aside = true,
            x = 5,
            y = 8.25, 
        },
        {
            type = "quest",
            id = 37861,
            x = 2,
            y = 10,
            connections = {
                2
            }, 
        },
        {
            type = "quest",
            id = 37860,
            x = 4,
            y = 10,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 37862,
            x = 3,
            y = 11,
            connections = {
                1, 2
            }, 
        },
        {
            type = "quest",
            id = 38014,
            x = 2,
            y = 12,
            connections = {
                2
            }, 
        },
        {
            type = "quest",
            id = 38015,
            x = 4,
            y = 12,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 42567,
            x = 3,
            y = 13,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 42756,
            x = 3,
            y = 14,
            connections = {
                1
            }, 
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_BALANCEOFPOWER,
            x = 5,
            y = 14.25,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_AZSUNAVERSUSAZSHARA, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10763, 3),
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_BEHINDENEMYLINES,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_DEFENDINGAZUREWINGREPOSE,
            upto = 42271,
        },
    },
    active = {
        type = "quest",
        id = 37690,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 37470,
    },
    items = {
        {
            type = "npc",
            id = 89975,
            x = 3,
            y = 0,
            connections = {
                1
            }, 
        },
        {
            type = "quest",
            id = 37690,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37256,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "npc",
            id = 89341,
            x = 1,
            y = 3,
            aside = true,
            connections = {
                3, 4
            }, 
        },
        {
            type = "quest",
            id = 37733,
            connections = {
                4
            },
        },
        {
            type = "npc",
            id = 88798,
            aside = true,
            connections = {
                4
            }, 
        },



        
        {
            type = "quest",
            id = 37727,
            aside = true,
            x = 0,
            y = 4,
        },
        {
            type = "quest",
            id = 37728,
            aside = true,
            x = 2,
            y = 4,
        },

        {
            type = "quest",
            id = 37257,
            x = 4,
            y = 4,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 37492,
            aside = true,
            x = 6,
            y = 4,
        },
        {
            type = "npc",
            id = 89326,
            aside = true,
            x = 0,
            connections = {
                4
            },
        },
        {
            type = "npc",
            id = 108328,
            aside = true,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 37497,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_AGAINSTTHEGIANTS,
            aside = true,
        },



        {
            type = "quest",
            id = 42692,
            aside = true,
            x = 0,
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 42693,
            aside = true,
            connections = {
                3
            },
        },
        


        {
            type = "quest",
            id = 37486,
            connections = {
                3
            },
        },

        {
            type = "quest",
            id = 37466,
            aside = true,
        },

        {
            type = "quest",
            id = 42694,
            aside = true,
            x = 1,
            y = 7,
        },


        {
            type = "quest",
            id = 37467,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37468,
            x = 3,
            y = 8,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 37736,
            x = 2,
            y = 9,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 37678,
            x = 4,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37518,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42370,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42371,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37729,
            x = 3,
            y = 13,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37730,
            x = 3,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37469,
            x = 3,
            y = 15,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 37530,
            x = 3,
            y = 16,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 37779,
            aside = true,
            x = 1,
            y = 17,
        },
        {
            type = "quest",
            id = 37470,
            x = 3,
            y = 17,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38286,
            aside = true,
            x = 3,
            y = 18,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42213,
            aside = true,
            x = 3,
            y = 19,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_AGAINSTTHEGIANTS, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10763, 4),
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 38407,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 37566,
    },
    items = {
        {
            name = L["KILL_MURLOCS_AROUND_ELDRANIL_SHALLOWS"],
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38407,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37496,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37507,
            x = 3,
            y = 3,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 37542,
            x = 2,
            y = 4,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 37528,
            x = 4,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37510,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37536,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 37538,
            x = 3,
            y = 7,
            connections = {
                3
            },
        },
        {
            type = "npc",
            id = 88863,
            aside = true,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 37495,
            aside = true,
            x = 1,
            y = 8,
        },
        {
            type = "quest",
            id = 37565,
            x = 3,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 38857,
            aside = true,
            x = 5,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 37566,
            x = 3,
            y = 9,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_MAKRANA,
            aside = true,
            x = 5.5,
            y = 9,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_MAKRANA, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10763, 5),
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {38857, 37654, 37657},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {37657, 40794},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 88863,
            aside = true,
            x = 0,
            y = 0,
            connections = {
                3
            },
        },
        {
            type = "npc",
            id = 91419,
            x = 3,
            connections = {
                3, 4
            },
        },
        {
            type = "area",
            id = 7345,
            x = 6,
            locations = {
                [630] = {
                    {
                        x = 0.6141,
                        y = 0.585917,
                    },
                },
            },
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 38857,
            aside = true,
            x = 0,
        },
        {
            type = "quest",
            id = 37654,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 37657,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 42220,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 42268,
                }
            },
            aside = true,
        },
        {
            type = "quest",
            id = 37659,
            x = 3,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 40794,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 42244,
                },
            },
            x = 3,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_DAGLOP, {
    name = { -- Missing Demon
		type = "quest",
		id = 42238,
	},
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {42238, 38460},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 38237,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 42238,
                    restrictions = {
                        type = "quest",
                        id = 42238,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "npc",
                    id = 91166,
                }
            },
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38460,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38232,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38237,
            x = 3,
            y = 3,
        },
        -- {
        --     type = "quest",
        --     name = L["BTWQUESTS_TREASURE"],
        --     id = 42278,
        --     x = 5,
        --     y = 3,
        -- }
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_VINEYARD, {
    name = { -- Challiane Vineyards
		type = "quest",
		id = 38203,
	},
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {98,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {37965, 38203},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 38203,
    },
    items = {
        {
            type = "area",
            id = 7517,
            x = -1,
            y = 0,
            locations = {
                [630] = {
                    {
                        x = 0.4432,
                        y = 0.0910,
                    },
                },
            },
            connections = {
                2
            },
        },
        {
            type = "npc",
            id = 91061,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 37965,
            x = -1,
        },
        {
            type = "quest",
            id = 38203,
        },
        -- {
        --     type = "quest",
        --     id = 38367,
        --     name = "Treasure: Cask of Special Reserve",
        --     x = 5,
        --     y = 0,
        -- },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_FELBLAZE, {
    name = { -- Felblaze Ingress
		type = "quest",
		id = 42372,
	},
    category = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {37965, 38203},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 42369,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 42372,
                    restrictions = {
                        type = "quest",
                        id = 42372,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "npc",
                    id = 107244,
                }
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 42375,
            x = 3,
            y = 1,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 42367,
            x = 1,
            y = 2,
        },
        {
            type = "quest",
            id = 42368,
            x = 3,
            y = 2,
        },
        {
            type = "quest",
            id = 42369,
            x = 5,
            y = 2,
        },
    }
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_AZSUNA, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_LEGION,
    buttonImage = 1498157,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_BEHINDENEMYLINES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_DEFENDINGAZUREWINGREPOSE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_AZSUNAVERSUSAZSHARA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_AGAINSTTHEGIANTS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_MAKRANA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_DAGLOP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_VINEYARD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_FELBLAZE,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_AZSUNA,
})

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_BEHINDENEMYLINES)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_DEFENDINGAZUREWINGREPOSE)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_AZSUNAVERSUSAZSHARA)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_AGAINSTTHEGIANTS)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_MAKRANA)

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_DAGLOP)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_VINEYARD)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_AZSUNA_FELBLAZE)

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_AZSUNA_DAGLOP,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_AZSUNA_VINEYARD,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_AZSUNA_FELBLAZE,
    },
})