local MAP_ID = 62
local ACHIEVEMENT_ID = 4928

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_GREAT_ANIMAL_SPIRIT, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
    active = {
        type = "quest",
		ids = {26385, 26383, 28490, 13518, 13522},
		status = {'active', 'completed'},
    },
	completed = {
		type = "quest",
		id = 13569,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 26385,
					restrictions = {
						type = "quest",
						id = 26385,
						status = {'active', 'completed'},
					},
				},
				{
					type = "quest",
					id = 26383,
					restrictions = {
						type = "quest",
						id = 26383,
						status = {'active', 'completed'},
					},
				},
				{
					type = "quest",
					id = 28490,
					restrictions = {
						type = "quest",
						id = 28490,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 32973,				
					-- name = "Go to Dentaria Silverglade",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5179, 0.1801, "Dentaria Silverglade")
					-- end,
				}
			},
			x = 2,
			y = 0,
			connections = {
				2,
			},
		},
		{
			type = "npc",
			id = 32971,
			-- name = "Go to Ranger Glynda Nal'Shea",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5022, 0.1979, "Ranger Glynda Nal'Shea")
			-- end,
			x = 4,
			y = 0,
			connections = {
				2,
			},
		},
		{
			type = "quest",
			id = 13518,
			x = 2,
			y = 1,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 13522,
			x = 4,
			y = 1,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 13520,
			x = 2,
			y = 2,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 13521,
			x = 4,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13527,
			x = 4,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13528,
			x = 4,
			y = 4,
			connections = {
                1, 2, 3, 4,
            },
		},


		{
			type = "quest",
			id = 13831,
			x = 0,
			y = 5,
			connections = {
                5, 6, 7,
            },
		},
		{
			type = "quest",
			id = 13557,
			x = 2,
			y = 5,
			connections = {
                4, 5, 6,
            },
		},
		{
			type = "quest",
			id = 13529,
			x = 4,
			y = 5,
			connections = {
                3, 4, 5,
            },
		},
		{
			type = "quest",
			id = 13554,
			x = 6,
			y = 5,
			connections = {
                2, 3,
            },
		},

		
		{
			type = "quest",
			id = 13561,
			x = 0,
			y = 6,
		},
		{
			type = "quest",
			id = 13562,
			x = 2,
			y = 6,
		},
		{
			type = "quest",
			id = 13564,
			x = 4,
			y = 6,
			connections = {
                2, 3, 4,
            },
		},
		{
			type = "quest",
			id = 13563,
			x = 6,
			y = 6,
		},


		{
			type = "quest",
			id = 13598,
			x = 1,
			y = 7,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13566,
			x = 3,
			y = 7,
			connections = {
                2,
			},
		},
		{
			type = "quest",
			id = 13565,
			x = 5,
			y = 7,
			connections = {
                1,
            },
		},


		{
			type = "quest",
			id = 13569,
			x = 3,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13599,
			aside = true,
			x = 3,
			y = 9,
			connections = {
                1, 2,
            },
		},

		{
			type = "quest",
			id = 13560,
			aside = true,
			x = 2,
			y = 10,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_SHATTERSPEAR,
			aside = true,
			x = 4,
			y = 10,
		}
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_SHATTERSPEAR, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
    active = {
        type = "quest",
		ids = {13589},
		status = {'active', 'completed'},
    },
	completed = {
		type = "quest",
		id = 13515,
	},
	items = {
		{
			type = "quest",
			id = 13589,
			x = 3,
			y = 1,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 13504,
			x = 2,
			y = 2,
			connections = {
                3, 4,
            },
		},
		{
			type = "quest",
			id = 13505,
			x = 4,
			y = 2,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 13506,
			aside = true,
			x = 6,
			y = 2,
			connections = {
                3,
            },
		},


		{
			type = "quest",
			id = 13507,
			x = 2,
			y = 3,
			connections = {
                3, 4, 5,
            },
		},
		{
			type = "quest",
			id = 13509,
			x = 4,
			y = 3,
			connections = {
                2, 3, 4,
            },
		},
		{
			type = "quest",
			id = 13508,
			aside = true,
			x = 6,
			y = 3,
			connections = {
                4,
            },
		},


		{
			type = "quest",
			id = 13844,
			aside = true,
			x = 0,
			y = 4,
		},
		{
			type = "quest",
			id = 13513,
			x = 2,
			y = 4,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 13512,
			x = 4,
			y = 4,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13511,
			aside = true,
			x = 6,
			y = 4,
		},


		{
			type = "quest",
			id = 13514,
			aside = true,
			x = 1,
			y = 5,
		},
		{
			type = "quest",
			id = 13590,
			x = 3,
			y = 5,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 13510,
			aside = true,
			x = 6,
			y = 5,
		},
		{
			type = "quest",
			id = 13515,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},


		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CHAIN1,
			aside = true,
			x = 3,
			y = 7,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_EYE_OF_ALL_STORMS, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
    active = {
        type = "quest",
		ids = {13573, 13577, 13579, 13575},
		status = {'active', 'completed'},
    },
	completed = {
		type = "quest",
		id = 13588,
	},
	items = {
		
		{
			variations = {
				{
					type = "quest",
					id = 13573,
					restrictions = {
						type = "quest",
						id = 13573,
						status = {'active', 'completed'}
					}
				},
				{
					type = "npc",
					id = 33091,
					-- name = "Go to Malfurion Stormrage",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4366, 0.5343, "Malfurion Stormrage")
					-- end,
				}
			},
			x = 3,
			y = 0,
			connections = {
                1, 2, 3,
            },
		},







		{
			type = "quest",
			id = 13577,
			x = 1,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13579,
			x = 3,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13575,
			x = 5,
			y = 1,
			connections = {
                3,
            },
		},


		{
			type = "quest",
			id = 13578,
			x = 1,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13584,
			x = 3,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13576,
			x = 5,
			y = 2,
			connections = {
                3,
            },
		},


		{
			type = "quest",
			id = 13582,
			x = 1,
			y = 3,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13585,
			x = 3,
			y = 3,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 13580,
			x = 5,
			y = 3,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 13583,
			x = 1,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 13581,
			x = 5,
			y = 4,
			connections = {
                1,
            },
		},


		{
			type = "quest",
			id = 13586,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13587,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13940,
			x = 3,
			y = 7,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13588,
			x = 3,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13902,
			aside = true,
			x = 3,
			y = 9,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_DEVOURER,
			aside = true,
			x = 3,
			y = 10,
		}
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_DEVOURER, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
    active = {
        type = "quest",
		ids = {13881},
		status = {'active', 'completed'},
    },
	completed = {
		type = "quest",
		id = 13891,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_BATTLE_FOR_DARKSHORE,
			aside = true,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 13881,
			x = 3,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 13525,
			aside = true,
			x = 5,
			y = 1,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 13882,
			x = 3,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CONSUMED_BY_MADNESS,
			aside = true,
			x = 5,
			y = 2,
		},

		{
			type = "quest",
			id = 13925,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		
		{
			type = "quest",
			id = 13885,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13891,
			x = 3,
			y = 5,
			connections = {
                
            },
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CONSUMED_BY_MADNESS, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
    active = {
        type = "quest",
		ids = {13526},
		status = {'active', 'completed'},
    },
	completed = {
		type = "quest",
		id = 13546,
	},
	items = {
		{
			type = "quest",
			id = 13526,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13544,
			x = 3,
			y = 2,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 13545,
			x = 3,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 13572,
			x = 5,
			y = 3,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 13546,
			x = 3,
			y = 4,
			connections = {
                
            },
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_BATTLE_FOR_DARKSHORE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
    active = {
        type = "quest",
		ids = {13892},
		status = {'active', 'completed'},
    },
	completed = {
		type = "quest",
		id = 13897,
	},
	items = {
		{
			type = "quest",
			id = 13892,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13948,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13896,
			x = 3,
			y = 3,
			connections = {
                3,
            },
		},


		{
			type = "quest",
			id = 13912,
			x = 0,
			y = 4,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 13907,
			x = 2,
			y = 4,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 13893,
			x = 4,
			y = 4,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 13911,
			x = 6,
			y = 4,
			connections = {
                
            },
		},

		
		{
			type = "quest",
			id = 13918,
			x = 0,
			y = 5,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 13909,
			x = 2,
			y = 5,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 13895,
			x = 4,
			y = 5,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 13910,
			x = 2,
			y = 6,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 13953,
			x = 4,
			y = 6,
			connections = {
                1, 2,
            },
		},


		{
			type = "quest",
			id = 13898,
			x = 2,
			y = 7,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 13899,
			x = 4,
			y = 7,
			connections = {
                1,
            },
		},


		{
			type = "quest",
			id = 13900,
			x = 4,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13897,
			x = 4,
			y = 9,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CHAIN1, {
	name = {
		type = "quest",
		id = 13591,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_SHATTERSPEAR,
		},
	},
    active = {
        type = "quest",
		ids = {13591},
		status = {'active', 'completed'},
    },
	completed = {
		{
			type = "quest",
			id = 13570,
		},
		{
			type = "quest",
			id = 13519,
		},
		{
			type = "quest",
			id = 13523,
		},
		{
			type = "quest",
			id = 13601,
		},
	},
	items = {
		{
			type = "quest",
			id = 13591,
			x = 3,
			y = 0,
			connections = {
                1, 2, 3,
            },
		},

		
		{
			type = "quest",
			id = 13570,
			x = 0,
			y = 1,
		},
		{
			type = "quest",
			id = 13519,
			x = 2,
			y = 1,
		},
		{
			type = "quest",
			id = 13596,
			x = 4,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 13523,
			x = 6,
			y = 1,
			connections = {
                
            },
		},

		
		{
			type = "quest",
			id = 13601,
			x = 4,
			y = 2,
			connections = {
                1,
            },
		},

		
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CHAIN2,
			aside = true,
			x = 4,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CHAIN2, {
	name = BtWQuests_GetAreaName(4648), --Auberdine Refugee Camp
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
    active = {
        type = "quest",
		ids = {13547, 13542, 13543, 13605},
		status = {'active', 'completed'},
    },
	completed = {
		{
			type = "quest",
			id = 13542,
		},
		{
			type = "quest",
			id = 13543,
		},
		{
			type = "quest",
			id = 13605,
		},
		{
			type = "quest",
			id = 13558,
		},
	},
	items = {
		{
			type = "quest",
			id = 13547,
			x = 0,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 13542,
			x = 2,
			y = 1,
		},
		{
			type = "quest",
			id = 13543,
			x = 4,
			y = 1,
		},
		{
			type = "quest",
			id = 13605,
			x = 6,
			y = 1,
		},

		
		{
			type = "quest",
			id = 13558,
			x = 0,
			y = 2,
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_EYE_OF_ALL_STORMS,
			aside = true,
			x = 4,
			y = 2,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_OTHER_ALLIANCE, {
	name = "Other Alliance",
	category = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
	completed = {
		type = "quest",
		id = 0,
	},
	items = {
		{ -- Isolated quest
			type = "quest",
			id = 5713,
			x = 2,
			y = 1,
			connections = {
                
            },
		},
		{ -- Fishing
			type = "quest",
			id = 13537,
			x = 2,
			y = 5,
			connections = {
                
            },
		},
		{ -- Unneeded Spirit quest
			type = "quest",
			id = 13567,
			x = 4,
			y = 7,
			connections = {
                
            },
		},
		{ -- Unneeded Spirit quest
			type = "quest",
			id = 13568,
			x = 6,
			y = 7,
			connections = {
                
            },
		},
		{ -- Unneeded Spirit quest
			type = "quest",
			id = 13597,
			x = 0,
			y = 10,
			connections = {
                
            },
		},
		{ -- Isolated quest
			type = "quest",
			id = 28529,
			x = 2,
			y = 11,
			connections = {
                
            },
		},
	}
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
	buttonImage = {
		texture = 1851074,
		texCoords = {0,1,0,1},
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_GREAT_ANIMAL_SPIRIT,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_SHATTERSPEAR,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CHAIN2,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_EYE_OF_ALL_STORMS,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_DEVOURER,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_CONSUMED_BY_MADNESS,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_DARKSHORE_THE_BATTLE_FOR_DARKSHORE,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_DARKSHORE,
})