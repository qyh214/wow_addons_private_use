local MAP_ID = 22

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_FIRST_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4893, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
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
            level = 15,
        },
    },
    completed = {
        type = "quest",
        id = 27165,
    },
    range = {15,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 27158,
                    restrictions = {
                        {
                            type = "quest",
                            id = 27158,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 27158,
                    restrictions = {
                        {
                            type = "quest",
                            id = 27158,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28505,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28505,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28505,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28505,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28576,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28576,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28576,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28576,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28749,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28749,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28749,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28749,
                            active = true,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 44453,
                    -- name = "Go to Thassarian",
                    -- breadcrumb = true,
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4106, 0.7045, "Thassarian")
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
            type = "quest",
            id = 27161,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 27159,
            x = 3,
            y = 1,
            connections = {
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 27160,
            x = 5,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 27164,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 27162,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27163,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27165,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_ALLIANCE,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_FIRST_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4893, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    completed = {
        type = "quest",
        id = 26926,
    },
    range = {15,30},
    items = {
        {
            variations = {
				{
					type = "quest",
					id = 26920,
					restrictions = {
						type = "quest",
						id = 26920,
						status = {'active', 'completed'},
					},
				},
				{
					type = "quest",
					id = 28508,
					restrictions = {
						type = "quest",
						id = 28508,
						status = {'active', 'completed'},
					},
				},
				{
					type = "quest",
					id = 28575,
					restrictions = {
						type = "quest",
						id = 28575,
						status = {'active', 'completed'},
					},
				},
				{
					type = "quest",
					id = 28750,
					restrictions = {
						type = "quest",
						id = 28750,
						status = {'active', 'completed'},
					},
				},
                {
                    type = "npc",
                    id = 44452,
                    -- name = "Go to Koltira Deathweaver",
                    -- breadcrumb = true,
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4777, 0.6521, "Koltira Deathweaver")
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
            type = "quest",
            id = 26922,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26921,
            x = 3,
            y = 1,
            connections = {
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 26923,
            x = 5,
            y = 1,
            connections = {
                2, 3,
            },
        },

        {
            type = "quest",
            id = 26925,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26924,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27117,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 26926,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_ALLIANCE,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4893, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
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
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_FIRST_ALLIANCE,
        },
    },
    completed = {
        type = "quest",
        id = 27174,
    },
    range = {15,30},
    items = {
        {
            type = "npc",
            id = 45165,
            -- name = "Go to Commander Ashlam Valorfist",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4270, 0.8401, "Commander Ashlam Valorfist")
            -- end,
            x = 3,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = 12701,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 27167,
            x = 3,
            y = 1,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 27166,
            x = 5,
            y = 1,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 27169,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27168,
            x = 5,
            y = 2,
        },
        {
            type = "quest",
            id = 27170,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27171,
            x = 3,
            y = 4,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 27172,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27175,
            x = 4,
            y = 5,
        },
        {
            type = "quest",
            id = 27173,
            x = 2,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27174,
            x = 2,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_SECOND_ALLIANCE,
            x = 2,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4893, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_FIRST_HORDE,
        },
    },
    completed = {
        type = "quest",
        id = 26938,
    },
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 26931,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26934,
            x = 3,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26930,
            x = 5,
            y = 1,
        },

        {
            type = "quest",
            id = 26933,
            x = 1,
            y = 2,
        },
        {
            type = "quest",
            id = 26978,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },

        {
            type = "quest",
            id = 26936,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_STEAD,
            x = 5,
            y = 3,
        },
        {
            type = "quest",
            id = 26979,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26937,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26938,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_SECOND_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4893, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
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
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_ALLIANCE,
        },
    },
    completed = {
        type = "quest",
        id = 27206,
    },
    range = {15,30},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_ALLIANCE,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 45012,
            -- name = "Go to Durnt Brightfalcon",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5046, 0.5270, "Durnt Brightfalcon")
            -- end,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27197,
            x = 3,
            y = 2,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 27198,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27199,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27205,
            x = 3,
            y = 4,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 27202,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27201,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27204,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27206,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_SECOND_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4893, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_HORDE,
        },
    },
    completed = {
        type = "quest",
        id = 27144,
    },
    range = {15,30},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_HORDE,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 45013,
            -- name = "Go to Damion Steel",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4925, 0.5314, "Damion Steel")
            -- end,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27083,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 27084,
            x = 1,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 27085,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27086,
            x = 5,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27087,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27089,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27090,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27144,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsCharacters:AddAchievement(4893);
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_STEAD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(4893, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    completed = {
        type = "achievement",
        id = 4893,
        criteria = 4,
    },
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 26953,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26999,
            x = 3,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26956,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 26954,
            x = 1,
            y = 2,
        },
        {
            type = "quest",
            id = 26935,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 27000,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27013,
            x = 5,
            y = 3,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 27001,
            x = 2,
            y = 4,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 27011,
            x = 4,
            y = 4,
        },
        {
            type = "quest",
            id = 27012,
            x = 6,
            y = 4,
        },
        {
            type = "quest",
            id = 26957,
            x = 0,
            y = 5,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 27002,
            x = 2,
            y = 5,
        },
        {
            type = "quest",
            id = 27151,
            x = 4,
            y = 5,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 27156,
            x = 6,
            y = 5,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 27017,
            x = 0,
            y = 6,
        },
        {
            type = "quest",
            id = 27053,
            x = 2,
            y = 6,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 27152,
            x = 4,
            y = 6,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 27157,
            x = 6,
            y = 6,
        },
        {
            type = "quest",
            id = 27057,
            x = 2,
            y = 7,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 27153,
            x = 4,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26955,
            x = 0,
            y = 8,
        },
        {
            type = "quest",
            id = 27054,
            x = 2,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27154,
            x = 4,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 27055,
            x = 2,
            y = 9,
        },
        {
            type = "quest",
            id = 27155,
            x = 4,
            y = 9,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851112,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_FIRST_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_FIRST_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_PEACE_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_SECOND_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_SECOND_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WESTERN_PLAGUELANDS_STEAD,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_WESTERN_PLAGUELANDS,
})