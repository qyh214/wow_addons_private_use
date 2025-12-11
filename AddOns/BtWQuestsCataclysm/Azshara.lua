local MAP_ID = 76
local CONTINENT_ID = 12
local ACHIEVEMENT_ID = 4927

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_DEFENDING_ORGRIMMAR, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		type = "quest",
		id = 14155,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 25275,
					restrictions = {
						type = "race",
						id = BTWQUESTS_RACE_ID_GOBLIN,
					},
				},
				{
					type = "quest",
					id = 28496,
					restrictions = {
						type = "quest",
						id = 28496,
						status = {'active', 'completed'},
					},
				},
				{
					type = "quest",
					id = 25648,
					restrictions = {
						type = "quest",
						id = 25648,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 35086,
					-- name = "Go to Labor Captain Grabbit",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2700, 0.7708, "Labor Captain Grabbit")
					-- end,
				}
			},
			x = 3,
			y = 0,
			connections = {
				3,
			},
		},
		{
			type = "quest",
			id = 14127,
			aside = true,
			x = 0,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 14117,
			aside = true,
			x = 2,
			y = 1,
		},
		{
			type = "quest",
			id = 14129,
			x = 4,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 14118,
			aside = true,
			x = 6,
			y = 1,
		},

		{
			type = "quest",
			id = 14128,
			aside = true,
			x = 0,
			y = 2,
		},
		{
			type = "quest",
			id = 14134,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14135,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14146,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14155,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_REDIRECTING_THE_LEY_LINES,
			aside = true,
			visible = {
				{
					type = "quest",
					id = 14161,
					restrictions = {
						type = "quest",
						id = 14162,
						status = {'notcompleted'}
					},
					status = {'notactive'}
				},
				{
					type = "quest",
					id = 14161,
					restrictions = {
						type = "quest",
						id = 14162,
						status = {'notcompleted'}
					},
					status = {'notcompleted'}
				}
			},
			active = {
				type = "quest",
				id = 14162,
				status = {'active', 'completed'}
			},
			x = 3,
			y = 6,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_REDIRECTING_THE_LEY_LINES, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		type = "quest",
		id = 14216,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 14162,
					restrictions = {
						type = "quest",
						id = 14162,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 35091,
					-- name = "Go to Horzak Zignibble",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2915, 0.6624, "Horzak Zignibble")
					-- end,
					connections = {
						2, 3,
					},
				}
			},
			x = 2,
			y = 0,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 35085,
			-- name = "Go to Foreman Fisk",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2908, 0.6629, "Foreman Fisk")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3,
			},
		},


		{
			type = "quest",
			id = 14161,
			aside = true,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 14165,
			x = 3,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14197,
			aside = true,
			x = 5,
			y = 1,
		},



		{
			type = "quest",
			id = 14190,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14192,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14194,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14468,
			x = 3,
			y = 5,
			connections = {
                1, 2, 3,
            },
		},

		
		{
			type = "quest",
			id = 14469,
			x = 1,
			y = 6,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 14470,
			x = 3,
			y = 6,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14471,
			x = 5,
			y = 6,
			connections = {
                1,
            },
		},
		
		{
			type = "quest",
			id = 14472,
			x = 3,
			y = 7,
			connections = {
                1,
            },
		},
		
		{
			type = "quest",
			id = 24452,
			x = 3,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 24453,
			x = 3,
			y = 9,
			connections = {
                1, 2, 3,
            },
		},

		
		{
			type = "quest",
			id = 14202,
			aside = true,
			x = 1,
			y = 10,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 14201,
			x = 3,
			y = 10,
			connections = {
                3,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_HEART_OF_ARKKOROC,
			aside = true,
			x = 5,
			y = 10,
		},
		{
			type = "quest",
			id = 14209,
			aside = true,
			x = 1,
			y = 11,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14215,
			x = 3,
			y = 11,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14423,
			aside = true,
			x = 1,
			y = 12,
			connections = {
                2
            },
		},
		{
			type = "quest",
			id = 14216,
			x = 3,
			y = 12,
		},
	
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN1,
			aside = true,
			visible = {
				{
					type = "quest",
					id = 14308,
					restrictions = {
						type = "quest",
						id = 14424,
						status = {'notcompleted'}
					},
					status = {'notactive'}
				},
				{
					type = "quest",
					id = 14308,
					restrictions = {
						type = "quest",
						id = 14424,
						status = {'notcompleted'}
					},
					status = {'notcompleted'}
				}
			},
			active = {
				type = "quest",
				id = 14424,
				status = {'active', 'completed'}
			},
			x = 1,
			y = 13,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SISTERS_OF_THE_SEA, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
		{
			type = "quest",
			id = 14258,
		},
	},
	completed = {
		type = "quest",
		id = 14295,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN1,
			completed = {
				type = "quest",
				id = 14295,
			},
			x = 3,
			y = 0,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14262,
			aside = true,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 14267,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14270,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14271,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14295,
			x = 3,
			y = 4,
			connections = {
                
            },
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SUBJECT_NINE_FROM_SPACE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		type = "quest",
		id = 14422,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 14442,
					restrictions = {
						type = "quest",
						id = 14442,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 36500,
					-- name = "Go to Assistant Greely",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5041, 0.7429, "Assistant Greely")
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
			id = 14408,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14422,
			x = 3,
			y = 2,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_RAREST_SUBSTANCE_ON_AZEROTH, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
		{
			type = "quest",
			id = 14308,
		},
		{
			type = "quest",
			id = 14310,
		},
	},
	completed = {
		type = "quest",
		ids = {14383, 14388},
		count = 2,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN1,
			completed = {
				type = "quest",
				id = 14310,
			},
			x = 3,
			y = 0,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 14370,
			x = 2,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14371,
			x = 4,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14377,
			x = 3,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14383,
			x = 1,
			y = 3,
		},
		{
			type = "quest",
			id = 14385,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14388,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 24458,
			aside = true,
			x = 3,
			y = 5,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_BEST_APPRENTICE,
			aside = true,
			x = 2,
			y = 6,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_HEART_OF_ARKKOROC,
			aside = true,
			x = 4,
			y = 6,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_HEART_OF_ARKKOROC, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
		{
			type = "quest",
			id = 24453,
		},
	},
	completed = {
		type = "quest",
		id = 24449,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_REDIRECTING_THE_LEY_LINES,
			completed = {
				type = "quest",
				id = 24453,
			},
			x = 3,
			y = 0,
			connections = {
                2,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_BEST_APPRENTICE,
			aside = true,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 14478,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 24455,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14479,
			x = 3,
			y = 3,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 24436,
			x = 2,
			y = 4,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 24435,
			x = 4,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 24437,
			aside = true,
			x = 6,
			y = 4,
		},
		{
			type = "quest",
			id = 24448,
			x = 3,
			y = 5,
			connections = {
                1, 2, 3, 4, 5,
            },
		},
		{
			type = "quest",
			id = 14487,
			x = 0,
			y = 6,
			connections = {
                5,
            },
		},
		{
			type = "quest",
			id = 14480,
			x = 2,
			y = 6,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 14484,
			x = 4,
			y = 6,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 14485,
			x = 6,
			y = 6,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14486,
			x = 3,
			y = 7,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 24449,
			x = 3,
			y = 8,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_BEST_APPRENTICE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		type = "quest",
		id = 14392,
	},
	items = {
		{
			type = "npc",
			id = 36999,		
			-- name = "Go to Teemo",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5933, 0.5074, "Teemo")
			-- end,
			x = 3,
			y = 0,
			connections = {
				2,
			},
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_HEART_OF_ARKKOROC,
			aside = true,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 14407,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14130,
			x = 3,
			y = 2,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 14131,
			x = 1,
			y = 3,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 14323,
			x = 3,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14132,
			x = 5,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14324,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},

		{
			type = "quest",
			id = 14345,
			x = 3,
			y = 5,
			connections = {
                2,
            },
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN3,
			aside = true,
			x = 1,
			y = 6,
		},
		{
			type = "quest",
			id = 14340,
			x = 3,
			y = 6,
			connections = {
                2, 3, 4,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN2,
			aside = true,
			x = 5,
			y = 6,
		},

		
		{
			type = "quest",
			id = 14249,
			x = 1,
			y = 7,
			connections = {
                3, 4,
            },
		},
		{
			type = "quest",
			id = 14263,
			x = 3,
			y = 7,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 14250,
			x = 5,
			y = 7,
			connections = {
                1, 2,
            },
		},

		
		{
			type = "quest",
			id = 14230,
			x = 2,
			y = 8,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14226,
			x = 4,
			y = 8,
			connections = {
                1,
            },
		},


		{
			type = "quest",
			id = 14413,
			x = 3,
			y = 9,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14296,
			x = 3,
			y = 10,
			connections = {
                1, 2, 3,
            },
		},

		
		{
			type = "quest",
			id = 14300,
			x = 1,
			y = 11,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 24478,
			x = 3,
			y = 11,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 24479,
			x = 5,
			y = 11,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14299,
			x = 3,
			y = 12,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14389,
			x = 3,
			y = 13,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14390,
			x = 3,
			y = 14,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14391,
			x = 3,
			y = 15,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 14297,
			x = 1,
			y = 16,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 24467,
			x = 3,
			y = 16,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14261,
			x = 5,
			y = 16,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14392,
			x = 3,
			y = 17,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_CONQUEST_OF_AZSHARA,
			aside = true,
			x = 3,
			y = 18,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_CONQUEST_OF_AZSHARA, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 8),
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		type = "quest",
		id = 24439,
	},
	items = {
		{
			type = "npc",
			id = 36728,		
			-- name = "Go to Chawg",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1401, 0.6484, "Chawg")
			-- end,
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
					id = 24497,
					restrictions = {
						type = "quest",
						id = 24497,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 36730,
					-- name = "Go to Chawg",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1401, 0.6484, "Chawg")
					-- end,
					connections = {
						3, 4,
					},
				}
			},
			x = 3,
			y = 0,
			connections = {
				4,
			},
		},
		{
			type = "npc",
			id = 36919,
			-- name = "Go to Andorel Sunsworn",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1385, 0.6449, "Andorel Sunsworn")
			-- end,
			x = 6,
			y = 0,
			connections = {
				4,
			},
		},


		{
			type = "quest",
			id = 14475,
			x = 0,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 24433,
			x = 2,
			y = 1,
			connections = {
                7,
            },
		},
		{
			type = "quest",
			id = 14462,
			x = 4,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 24434,
			x = 6,
			y = 1,
			connections = {
                5,
            },
		},


		{
			type = "quest",
			id = 14476,
			x = 0,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14464,
			x = 4,
			y = 2,
			connections = {
                3,
            },
		},

		
		{
			type = "quest",
			id = 14477,
			x = 0,
			y = 3,
			connections = {
                1,
            },
		},
		
		{
			type = "quest",
			id = 24430,
			x = 0,
			y = 4,
			connections = {
                1,
            },
		},

		{
			type = "quest",
			id = 24439,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},

		{
			type = "quest",
			id = 24463,
			aside = true,
			x = 3,
			y = 6,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN1, {
	name = BtWQuests_GetAreaName(4828), -- Southern Rocketway Exchange
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		{
			type = "quest",
			id = 14322,
		},
		{
			type = "quest",
			id = 14310,
		},
		{
			type = "quest",
			id = 14258,
		},
	},
	items = {
		{
			type = "npc",
			id = 36146,
			-- name = "Go to Twistex Happytongs",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4506, 0.7549, "Twistex Happytongs")
			-- end,
			x = 1,
			y = 0,
			connections = {
				3,
			},
		},
		{
			variations = {
				{
					type = "quest",
					id = 14424,
					restrictions = {
						type = "quest",
						id = 14424,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 36077,
					-- name = "Go to Assistant Greely",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5041, 0.7429, "Assistant Greely")
					-- end,
				}
			},
			x = 3,
			y = 0,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 35817,
			-- name = "Go to Bombardier Captain Smooks",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5222, 0.7424, "Bombardier Captain Smooks")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3,
			},
		},


		{
			type = "quest",
			id = 14322,
			x = 1,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 14308,
			x = 3,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 14258,
			x = 5,
			y = 1,
			connections = {
                3,
            },
		},


		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SUBJECT_NINE_FROM_SPACE,
			aside = true,
			visible = {
				{
					type = "quest",
					id = 14408,
					restrictions = {
						type = "quest",
						id = 14442,
						status = {'notcompleted'}
					},
					status = {'notactive'}
				},
				{
					type = "quest",
					id = 14408,
					restrictions = {
						type = "quest",
						id = 14442,
						status = {'notcompleted'}
					},
					status = {'notcompleted'}
				}
			},
			active = {
				type = "quest",
				id = 14442,
				status = {'active', 'completed'}
			},
			x = 1,
			y = 2,
		},
		{
			type = "quest",
			id = 14310,
			x = 3,
			y = 2,
			connections = {
				2,
			}
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SISTERS_OF_THE_SEA,
			aside = true,
			x = 5,
			y = 2,
		},


		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_RAREST_SUBSTANCE_ON_AZEROTH,
			aside = true,
			x = 3,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN2, {
	name = {
		type = "quest",
		id = 14431,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		type = "quest",
		id = 14435,
	},
	items = {
		{
			type = "quest",
			id = 14431,
			x = 3,
			y = 0,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 14432,
			x = 2,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14433,
			x = 4,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14435,
			x = 3,
			y = 2,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN3, {
	name = { -- Hacking the Construct
		type = "quest",
		id = 14430,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		type = "quest",
		id = 14430,
	},
	items = {
		{
			type = "quest",
			id = 14428,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14429,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14430,
			x = 3,
			y = 3,
		},
	}
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_AZSHARA, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851071,
		texCoords = {0,1,0,1},
	},
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_DEFENDING_ORGRIMMAR,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_REDIRECTING_THE_LEY_LINES,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SISTERS_OF_THE_SEA,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SUBJECT_NINE_FROM_SPACE,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_RAREST_SUBSTANCE_ON_AZEROTH,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_HEART_OF_ARKKOROC,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_BEST_APPRENTICE,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_CONQUEST_OF_AZSHARA,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN2,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN3,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_AZSHARA,
})

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_DEFENDING_ORGRIMMAR)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_REDIRECTING_THE_LEY_LINES)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SISTERS_OF_THE_SEA)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SUBJECT_NINE_FROM_SPACE)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_RAREST_SUBSTANCE_ON_AZEROTH)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_HEART_OF_ARKKOROC)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_BEST_APPRENTICE)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_CONQUEST_OF_AZSHARA)

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN1)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN2)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN3)

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_DEFENDING_ORGRIMMAR,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_REDIRECTING_THE_LEY_LINES,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SISTERS_OF_THE_SEA,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_SUBJECT_NINE_FROM_SPACE,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_RAREST_SUBSTANCE_ON_AZEROTH,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_HEART_OF_ARKKOROC,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_BEST_APPRENTICE,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_THE_CONQUEST_OF_AZSHARA,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN1,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN2,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_AZSHARA_CHAIN3,
    },
})