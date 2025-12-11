local MAP_ID = 21
local ACHIEVEMENT_ID = 4894

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_HIGH_COMMAND, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
        {
            type = "level",
            level = 5,
        },
	},
	completed = {
		type = "quest",
		id = 27056,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 26964,
					restrictions = {
						{
							type = "quest",
							id = 26964,
							status = {'active', 'completed'},
						}
					},
				},
				{
					type = "quest",
					id = 28568,
					restrictions = {
						{
							type = "quest",
							id = 28568,
							status = {'active', 'completed'},
						}
					},
				},
				{
					type = "npc",
					id = 44615,
					-- name = "Go to Grand Executor Mortuus",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5741, 0.1013, "Grand Executor Mortuus")
					-- end,
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
			id = 26965,
			x = 3,
			y = 1,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 26992,
			x = 1,
			y = 2,
		},
		{
			type = "quest",
			id = 26995,
			x = 3,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26989,
			x = 5,
			y = 2,
		},
		{
			type = "quest",
			id = 26998,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27039,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27045,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27056,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_REAR_GUARD,
			aside = true,
			x = 3,
			y = 7,
		}		
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_REAR_GUARD, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
        {
            type = "level",
            level = 5,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_HIGH_COMMAND,
		},
	},
	completed = {
		type = "quest",
		id = 27096,
	},
	items = {
		{
			type = "quest",
			id = 27065,
			x = 3,
			y = 1,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 27082,
			x = 1,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 27069,
			x = 3,
			y = 2,
			connections = {
                3, 4,
            },
		},
		{
			type = "quest",
			id = 27073,
			x = 5,
			y = 2,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 27088,
			connections = {
                3,
            },
			x = 1,
			y = 3,
		},
		{
			type = "quest",
			id = 27093,
			x = 3,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27095,
			x = 5,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27096,
			x = 3,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27094,
			x = 5,
			y = 4,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_SEPULCHER,
			aside = true,
			x = 3,
			y = 5,
		}
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_SEPULCHER, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
        {
            type = "level",
            level = 5,
        },
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_REAR_GUARD,
		},
	},
	completed = {
		type = "quest",
		id = 27290,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_REAR_GUARD,
			x = 3,
			y = 0,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27097,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27099,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27098,
			x = 3,
			y = 3,
			connections = {
                1, 2, 3, 4,
            },
		},

		
		{
			type = "quest",
			id = 27226,
			aside = true,
			x = 0,
			y = 4,
		},
		{
			type = "quest",
			id = 27180,
			x = 2,
			y = 4,
		},

		{
			type = "quest",
			id = 27181,
			x = 4,
			y = 4,
			connections = {
                2,
            },
		},

		{
			type = "quest",
			id = 27231,
			aside = true,
			x = 6,
			y = 4,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 27193,
			x = 4,
			y = 5,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27232,
			aside = true,
			x = 6,
			y = 5,
		},
		{
			type = "quest",
			id = 27194,
			x = 4,
			y = 6,
			connections = {
                1
            },
		},
		{
			type = "quest",
			id = 27195,
			x = 4,
			y = 7,
			connections = {
                
            },
		},


		{
			type = "quest",
			id = 27290,
			x = 3,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_RUINS_OF_GILNEAS,
			aside = true,
			x = 3,
			y = 9,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_RUINS_OF_GILNEAS, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
	category = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
        {
            type = "level",
            level = 5,
        },
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_SEPULCHER,
		},
	},
	completed = {
		type = "quest",
		id = 27438,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_SEPULCHER,
			x = 3,
			y = 0,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 27345,
			x = 1,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 27342,
			x = 3,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27333,
			x = 5,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27349,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27350,
			x = 3,
			y = 3,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 27360,
			x = 2,
			y = 4,
		},
		{
			type = "quest",
			id = 27364,
			x = 4,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27401,
			x = 4,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27405,
			x = 4,
			y = 6,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 27423,
			x = 2,
			y = 7,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27406,
			x = 4,
			y = 7,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27438,
			x = 3,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_AMBERMILL,
			aside = true,
			x = 3,
			y = 9,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_AMBERMILL, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
	category = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
        {
            type = "level",
            level = 5,
        },
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_RUINS_OF_GILNEAS,
		},
	},
	completed = {
		type = "quest",
		id = 27518,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_RUINS_OF_GILNEAS,
			x = 3,
			y = 0,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27472,
			x = 3,
			y = 1,
			connections = {
                2, 3,
			},
		},
		{
			type = "quest",
			id = 27480,
			aside = true,
			x = 0,
			y = 2,
		},
		{
			type = "quest",
			id = 27474,
			x = 2,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27475,
			x = 4,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27476,
			x = 3,
			y = 3,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 27478,
			x = 2,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27483,
			x = 4,
			y = 4,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 27484,
			x = 3,
			y = 5,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 27510,
			aside = true,
			x = 1,
			y = 6,
		},
		{
			type = "quest",
			id = 27512,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27513,
			x = 3,
			y = 7,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27518,
			x = 3,
			y = 8,
			connections = {
                1
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_ON_THE_BATTLEFRONT,
			aside = true,
			x = 3,
			y = 9,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_ON_THE_BATTLEFRONT, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
	category = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
        {
            type = "level",
            level = 5,
        },
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_AMBERMILL,
		},
	},
	completed = {
		type = "quest",
		id = 27601,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_AMBERMILL,
			x = 3,
			y = 0,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27542,
			x = 3,
			y = 1,
			connections = {
                1, 2, 3,
            },
		},

		
		{
			type = "quest",
			id = 27547,
			x = 1,
			y = 2,
			connections = {
                3, 4, 5,
            },
		},
		{
			type = "quest",
			id = 27550,
			x = 3,
			y = 2,
			connections = {
                2, 3, 4,
            },
		},
		{
			type = "quest",
			id = 27548,
			x = 5,
			y = 2,
			connections = {
                1, 2, 3,
            },
		},


		{
			type = "quest",
			id = 27574,
			aside = true,
			x = 1,
			y = 3,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 27580,
			x = 3,
			y = 3,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 27577,
			x = 5,
			y = 3,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 27575,
			aside = true,
			x = 2,
			y = 4,
		},
		{
			type = "quest",
			id = 27594,
			x = 4,
			y = 4,
			connections = {
                1
            },
		},




		{
			type = "quest",
			id = 27601,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27746,
			aside = true,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HILLSBRAD_FOOTHILLS_AZURELODEMINE,
			aside = true,
			active = {
				{
					type = "quest",
					id = 27746,
				},
				{
					type = "quest",
					id = 28096,
					status = {'active', 'completed'},
				}
			},
			x = 3,
			y = 7,
		},
	}
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851086,
		texCoords = {0,1,0,1},
	},
	restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_HORDE,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_HIGH_COMMAND,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_FORSAKEN_REAR_GUARD,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_SEPULCHER,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_THE_RUINS_OF_GILNEAS,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_AMBERMILL,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_SILVERPINE_FOREST_ON_THE_BATTLEFRONT,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
})

BtWQuestsDatabase:AddMapRecursive(684, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SILVERPINE_FOREST,
})