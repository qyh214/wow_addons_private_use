local L = BtWQuests.L
local MAP_ID = 50

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_OHGANANKA, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4906, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_ALLIANCE,
        },
    },
    completed = {
        type = "quest",
        id = 26775,
    },
    range = {10,30},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_ALLIANCE,
            x = 4,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26805,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 26782,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 26749,
            x = 4,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26781,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 26772,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26773,
            x = 4,
            y = 3,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 26779,
            x = 2,
            y = 4,
        },
        {
            type = "quest",
            id = 26774,
            x = 4,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26780,
            x = 6,
            y = 4,
        },
        {
            type = "quest",
            id = 26775,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26776,
            x = 4,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_REBEL_CAMP, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4906, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    completed = {
        type = "quest",
        id = 26731,
    },
    range = {10,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26838,
                    restrictions = {
                        {
                            type = "quest",
                            id = 26838,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 26838,
                    restrictions = {
                        {
                            type = "quest",
                            id = 26838,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28699,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28699,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28699,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28699,
                            active = true,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 469,
                    -- name = "Go to Lieutenant Doren",
                    -- breadcrumb = true,
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4757, 0.1025, "Lieutenant Doren")
                    -- end,
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
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_ALLIANCE,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 26735,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26740,
            x = 6,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26736,
            x = 3,
            y = 2,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 26763,
            x = 6,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26729,
            x = 2,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26737,
            x = 4,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26765,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 26730,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26742,
            x = 4,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26731,
            x = 2,
            y = 5,
        },
        {
            type = "quest",
            id = 26743,
            x = 4,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_NESINGWARY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4906, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    completed = {
        type = "quest",
        id = 208,
    },
    range = {10,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 26340,
                    restrictions = {
                        {
                            type = "quest",
                            id = 26340,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 26340,
                    restrictions = {
                        {
                            type = "quest",
                            id = 26340,
                            active = true,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 716,
                    -- name = "Go to Barnil Stonepot",
                    -- breadcrumb = true,
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4424, 0.2213, "Barnil Stonepot")
                    -- end,
                },
            },
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 2495,
            -- name = "Go to Drizzlik",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4364, 0.2338, "Drizzlik")
            -- end,
            x = 6,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 583,
            x = 2,
            y = 1,
            connections = {
                1,
                3,
                4,
                5,
            },
        },
        {
            type = "quest",
            id = 26269,
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            id = 26343,
            x = 6,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 185,
            x = 0,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 190,
            x = 2,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 194,
            x = 4,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 26344,
            x = 6,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 186,
            x = 0,
            y = 3,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 191,
            x = 2,
            y = 3,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 195,
            x = 4,
            y = 3,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 26345,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 187,
            x = 0,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 192,
            x = 2,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 196,
            x = 4,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 188,
            x = 0,
            y = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 193,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 197,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 208,
            x = 2,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_ALLIANCE, {
    name = L["HATCHLING"],
    category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    completed = {
        type = "quest",
        id = 26748,
    },
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 739,
            -- name = "Go to Brother Nimetz",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4724, 0.1110, "Brother Nimetz")
            -- end,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26732,
            x = 3,
            y = 1,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 26733,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26738,
            x = 4,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26734,
            x = 2,
            y = 3,
        },
        {
            type = "quest",
            id = 26739,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26744,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26745,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26746,
            x = 3,
            y = 6,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 26751,
            x = 2,
            y = 7,
        },
        {
            type = "quest",
            id = 26747,
            x = 4,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26748,
            x = 4,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_OHGANANKA,
            x = 4,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_YENNIKU, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4906, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
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
    completed = {
        type = "quest",
        id = 26305,
    },
    range = {10,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28688,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28688,
                            status = {'active', 'completed'}
                        }
                    },
                },
                {
                    type = "quest",
                    id = 26417,
                    restrictions = {
                        {
                            type = "quest",
                            id = 26417,
                            status = {'active', 'completed'}
                        }
                    },
                },
                {
                    type = "npc",
                    id = 2464,
                    -- name = "Go to Commander Aggro'gosh",
                    -- breadcrumb = true,
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3843, 0.5049, "Commander Aggro'gosh")
                    -- end,
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
            id = 26278,
            x = 3,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_HORDE,
            x = 6,
            y = 1,
        },

        
        {
            type = "quest",
            id = 26280,
            x = 1,
            y = 2,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 26279,
            x = 3,
            y = 2,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 26407,
            x = 5,
            y = 2,
        },

        
        {
            type = "quest",
            id = 26281,
            x = 1,
            y = 3,
        },
        {
            type = "quest",
            id = 26298,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 9436,
            x = 5,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26299,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 9457,
            x = 5,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26300,
            x = 3,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_NESINGWARY,
            x = 5,
            y = 5,
        },
        {
            type = "quest",
            id = 26301,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26302,
            x = 3,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26399,
            x = 1,
            y = 8,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 26303,
            x = 3,
            y = 8,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 26404,
            x = 5,
            y = 8,
        },
        {
            type = "quest",
            id = 26400,
            x = 0,
            y = 9,
        },
        {
            type = "quest",
            id = 26403,
            x = 2,
            y = 9,
        },
        {
            type = "quest",
            id = 26352,
            x = 4,
            y = 9,
        },
        {
            type = "quest",
            id = 26305,
            x = 6,
            y = 9,
        },
        {
            type = "quest",
            id = 26304,
            x = 2,
            y = 10,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_HORDE, {
    name = L["HATCHLING"],
    category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
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
    completed = {
        type = "quest",
        id = 26362,
    },
    range = {10,30},
    items = {
        {
            type = "quest",
            id = 26317,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26321,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26323,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        
        {
            type = "quest",
            id = 26338,
            x = 2,
            y = 4,
        },
        {
            type = "quest",
            id = 26330,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        
        {
            type = "quest",
            id = 26332,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },

        {
            type = "quest",
            id = 26334,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },

        {
            type = "quest",
            id = 26350,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26351,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26359,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26360,
            x = 3,
            y = 10,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 26405,
            x = 2,
            y = 11,
        },
        {
            type = "quest",
            id = 26362,
            x = 4,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26386,
            x = 3,
            y = 12,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851104,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_REBEL_CAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_YENNIKU,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_NESINGWARY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_HATCHLING_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_STRANGLETHORN_OHGANANKA,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_STRANGLETHORN,
})