local MAP_ID = 10
local ACHIEVEMENT_ID = 4933

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_FAR_WATCH, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 5041,
	},
	items = {
		{
			type = "npc",
			id = 34284,
			-- name = "Go to Dorak",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6710, 0.4552, "Dorak")
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
					id = 840,
					restrictions = {
						type = "quest",
						id = 840,
						status = {'active', 'completed'}
					},
				},
				{
					type = "quest",
					id = 28494,
					restrictions = {
						type = "quest",
						id = 28494,
						status = {'active', 'completed'}
					},
				},
				{
					type = "quest",
					id = 26642,
					restrictions = {
						type = "quest",
						id = 26642,
						status = {'active', 'completed'}
					},
				},
				{
					type = "npc",
					id = 3337,
					-- name = "Go to Kargal Battlescar",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6767, 0.3939, "Kargal Battlescar")
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
			id = 34258,
			-- name = "Go to Halga Bloodeye",
			-- breadcrumb = true,
			-- aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6740, 0.3877, "Halga Bloodeye")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3,
			},
		},
		
		{
			type = "quest",
			id = 13878,
			aside = true,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 871,
			x = 3,
			y = 1,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 844,
			aside = true,
			x = 5,
			y = 1,
		},
		{
			type = "quest",
			id = 872,
			x = 2,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 5041,
			x = 4,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13949,
			aside = true,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_GROLDOM_FARM,
			aside = true,
			active = {
				type = "quest",
				id = 13949,
			},
			x = 3,
			y = 4,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_GROLDOM_FARM, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 13971,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_FAR_WATCH,
			aside = true,
			x = 0,
			y = 0,
			connections = {
				4,
			}
		},
		{
			type = "npc",
			id = 3432,
			-- name = "Go to Mankrik",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5517, 0.4102, "Mankrik")
			-- end,
			x = 2,
			y = 0,
			connections = {
				4,
			}
		},
		{
			type = "npc",
			id = 34513,
			-- name = "Go to Togrik",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5659, 0.4028, "Togrik")
			-- end,
			x = 4,
			y = 0,
			connections = {
				4,
			}
		},
		{
			type = "npc",
			id = 34560,
			-- name = "Go to Una Wolfclaw",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5401, 0.4109, "Una Wolfclaw")
			-- end,
			x = 6,
			y = 0,
			connections = {
				4,
			}
		},



		{
			type = "quest",
			id = 13975,
			aside = true,
			x = 0,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 899,
			aside = true,
			x = 2,
			y = 1,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 13961,
			x = 4,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13973,
			aside = true,
			x = 6,
			y = 1,
			connections = {
                
            },
		},

		
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN1,
			aside = true,
			active = {
				type = "quest",
				id = 13975,
			},
			x = 0,
			y = 2,
		},
		{
			type = "quest",
			id = 13963,
			x = 3,
			y = 2,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 13969,
			x = 2,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 13968,
			aside = true,
			x = 4,
			y = 3,
		},
		{
			type = "quest",
			id = 13970,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13971,
			x = 3,
			y = 5,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_DEFEATING_THE_KOLKAR, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
			id = 13992,
		},
		{
			type = "quest",
			id = 850,
		},
		{
			type = "quest",
			id = 14072,
		},
		{
			type = "quest",
			id = 13995,
		},
		{
			type = "quest",
			id = 851,
		},
	},
	completed = {
		type = "quest",
		id = 4021,
	},
	items = {
		{
			type = "quest",
			id = 14073,
			x = 3,
			y = 0,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 852,
			x = 3,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 855,
			aside = true,
			x = 5,
			y = 1,
		},
		{
			type = "quest",
			id = 4021,
			x = 3,
			y = 2,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_MYSTERIES_OF_THE_OASES, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
			id = 877,
		},
		{
			type = "quest",
			id = 880,
		}
	},
	items = {
		{
			type = "npc",
			id = 34613,
			-- name = "Go to Ta'jari",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3754, 0.4587, "Ta'jari")
			-- end,
			x = 0,
			y = 0,
			connections = {
				4,
			}
		},
		{
			type = "npc",
			id = 3390,
			-- name = "Go to Apothecary Helbrim",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4859, 0.5834, "Apothecary Helbrim")
			-- end,
			x = 2,
			y = 0,
			connections = {
				4,
			},
		},
		{
			type = "npc",
			id = 3448,
			-- name = "Go to Tonga Runetotem",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4949, 0.5866, "Tonga Runetotem")
			-- end,
			x = 4,
			y = 0,
			connections = {
				4,
			},
		},
		{
			type = "npc",
			id = 34841,
			-- name = "Go to Kolkar Wrangler",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3808, 0.4628, "Kolkar Wrangler")
			-- end,
			x = 6,
			y = 0,
			connections = {
				4,
			}
		},

		{
			type = "quest",
			id = 13992,
			aside = true,
			x = 0,
			y = 1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN3,
			aside = true,
            userdata = {scrollTo = false},
			x = 2,
			y = 1,
		},
		{
			type = "quest",
			id = 870,
			x = 4,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 850,
			aside = true,
			x = 6,
			y = 1,
		},



		{
			type = "npc",
			id = 34638,
			-- name = "Go to Shoe",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5520, 0.7840, "Shoe")
			-- end,
			x = 0,
			y = 2,
			connections = {
				3,
			}
		},
		{
			type = "quest",
			id = 13988,
			x = 3,
			y = 2,
			connections = {
                3, 4,
            },
		},
		{
			type = "npc",
			id = 34634,
			-- name = "Go to Gorgal Angerscar",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5511, 0.7854, "Gorgal Angerscar")
			-- end,
			x = 6,
			y = 2,
			connections = {
				4,
			}
		},


		{
			type = "quest",
			id = 14072,
			aside = true,
			x = 0,
			y = 3,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 877,
			x = 2,
			y = 3,
		},
		{
			type = "quest",
			id = 880,
			x = 4,
			y = 3,
		},
		{
			type = "quest",
			id = 13995,
			aside = true,
			x = 6,
			y = 3,
		},


		{
			type = "quest",
			id = 851,
			aside = true,
			x = 0,
			y = 4,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_RATCHET, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		ids = {14042, 14067, 14063, 14050},
		count = 4,
	},
	items = {
		{
			type = "npc",
			id = 3339,
			-- name = "Go to Captain Thalo'thas Brightsun",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6772, 0.7400, "Captain Thalo'thas Brightsun")
			-- end,
			x = 0,
			y = 0,
			connections = {
				4,
			},
		},
		{
			variations = {
				{
					type = "quest",
					id = 13991,
					restrictions = {
						type = "quest",
						id = 13991,
						status = {'active', 'completed'}
					},
				},
				{
					type = "npc",
					id = 3464,
					-- name = "Go to Kargal Battlescar",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6767, 0.3939, "Kargal Battlescar")
					-- end,
				}
			},
			x = 2,
			y = 0,
			connections = {
                4,
            },
		},
		{
			type = "npc",
			id = 3446,
			-- name = "Go to Mebok Mizzyrix",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6786, 0.7150, "Mebok Mizzyrix")
			-- end,
			x = 4,
			y = 0,
			connections = {
				4,
			},
		},
		{
			type = "object",
			id = 3972,
			-- name = "Go to WANTED sign",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6826, 0.7125, "WANTED sign")
			-- end,
			x = 6,
			y = 0,
			connections = {
				4,
			},
		},


		{
			type = "quest",
			id = 891,
			x = 0,
			y = 1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN4,
			active = {
				type = "quest",
				id = 14066,
				status = {'active', 'completed'},
			},
			x = 2,
			y = 1,
		},
		{
			type = "quest",
			id = 865,
			x = 4,
			y = 1,
		},
		{
			type = "quest",
			id = 895,
			x = 6,
			y = 1,
		},


		{
			type = "npc",
			id = 3391,
			-- name = "Go to Gazlowe",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6841, 0.6906, "Gazlowe")
			-- end,
			x = 1,
			y = 2,
			connections = {
				2, 3,
			},
		},
		{
			type = "npc",
			id = 3453,
			-- name = "Go to Wharfmaster Dizzywig",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6960, 0.7298, "Wharfmaster Dizzywig")
			-- end,
			x = 5,
			y = 2,
			connections = {
				3, 4,
			},
		},


		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN5,
			active = {
				type = "quest",
				id = 14034,
				status = {'active', 'completed'},
			},
			x = 0,
			y = 3,
			connections = {
				4,
			},
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN6,
			active = {
				type = "quest",
				id = 14045,
				status = {'active', 'completed'},
			},
			x = 2,
			y = 3,
			connections = {
				3,
			},
		},
		{
			type = "quest",
			id = 887,
			x = 4,
			y = 3,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN7,
			active = {
				type = "quest",
				id = 14052,
				status = {'active', 'completed'},
			},
			x = 6,
			y = 3,
		},
		{
			type = "quest",
			id = 14050,
			x = 1,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26769,
			x = 1,
			y = 5,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_NOZZLEPOTS_OUTPOST, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 29094,
	},
	items = {
		{
			type = "npc",
			id = 3442,
			-- name = "Go to Sputtervalve",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6228, 0.1748, "Sputtervalve")
			-- end,
			x = 1,
			y = 0,
			connections = {
				2, 3,
			},
		},
		{
			type = "npc",
			id = 34698,
			-- name = "Go to Nozzlepot",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6250, 0.1675, "Nozzlepot")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3, 4,
			},
		},


		{
			type = "quest",
			id = 29086,
			x = 0,
			y = 1,
		},
		{
			type = "quest",
			id = 29021,
			x = 2,
			y = 1,
			connections = {
                4,
			},
		},
		{
			type = "quest",
			id = 29087,
			x = 4,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 29088,
			x = 6,
			y = 1,
		},


		{
			type = "quest",
			id = 858,
			x = 0,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 29022,
			x = 2,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 29089,
			x = 4,
			y = 2,
		},



		{
			type = "quest",
			id = 863,
			x = 0,
			y = 3,
		},
		{
			type = "quest",
			id = 29023,
			x = 2,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29024,
			x = 2,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14003,
			x = 2,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29026,
			x = 2,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29027,
			x = 2,
			y = 7,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 29090,
			aside = true,
			x = 4,
			y = 7,
		},
		{
			type = "quest",
			id = 14004,
			x = 3,
			y = 8,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 29015,
			x = 2,
			y = 9,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 14006,
			x = 4,
			y = 9,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29094,
			x = 3,
			y = 10,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_INSPIRATION_AND_HOPE,
			aside = true,
			x = 3,
			y = 11,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_INSPIRATION_AND_HOPE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 29111,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 29094,
					restrictions = {
						type = "quest",
						id = 29094,
						status = {'active'},
					},
				},
				{
					type = "npc",
					id = 3449,
					-- name = "Go to Darsok Swiftdagger",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3058, 0.4593, "Darsok Swiftdagger")
					-- end,
				}
			},
			x = 3,
			y = 0,
			connections = {
				1, 2,
			},
		},
		{
			type = "quest",
			id = 867,
			x = 2,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 875,
			x = 4,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 876,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29095,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29109,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29110,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29112,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 29111,
			x = 3,
			y = 7,
			connections = {
                
            },
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN1, {
	name = BtWQuests_GetAreaName(380), -- The Crossroads
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
			id = 905,
		},
		{
			type = "quest",
			id = 13998,
		},
	},
	items = {
		{
			type = "npc",
			id = 3338,
			-- name = "Go to Sergra Darkthorn",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4999, 0.5985, "Sergra Darkthorn")
			-- end,
			x = 0,
			y = 0,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 3390,
			-- name = "Go to Apothecary Helbrim",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4859, 0.5834, "Apothecary Helbrim")
			-- end,
			x = 2,
			y = 0,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 3448,
			-- name = "Go to Tonga Runetotem",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4949, 0.5866, "Tonga Runetotem")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3, 4,
			},
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN2,
			active = {
				type = "quest",
				id = 845,
				status = {'active', 'completed'},
			},
			x = 0,
			y = 1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN3,
			active = {
				type = "quest",
				id = 848,
				status = {'active', 'completed'},
			},
			x = 2,
			y = 1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_MYSTERIES_OF_THE_OASES,
			active = {
				type = "quest",
				id = 870,
				status = {'active', 'completed'},
			},
			x = 4,
			y = 1,
		},
		{
			type = "quest",
			id = 26878,
			x = 6,
			y = 1,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN2, {
	name = {
		type = "quest",
		id = 881,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 905,
	},
	items = {
		{
			type = "npc",
			id = 3338,
			-- name = "Go to Sergra Darkthorn",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4999, 0.5985, "Sergra Darkthorn")
			-- end,
			x = 3,
			y = 0,
			connections = {
				1, 2,
			},
		},
		{
			type = "quest",
			id = 845,
			x = 2,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 903,
			x = 4,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 881,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 905,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN4,
			aside = true,
			visible = {
				{
					type = "quest",
					id = 14066,
					restrictions = {
						type = "quest",
						id = 13991,
						status = {'notcompleted'}
					},
					status = {'notactive'}
				},
				{
					type = "quest",
					id = 14066,
					restrictions = {
						type = "quest",
						id = 13991,
						status = {'notcompleted'}
					},
					status = {'notcompleted'}
				}
			},
			active = {
				type = "quest",
				id = 13991,
				status = {'active', 'completed'}
			},
			x = 3,
			y = 4,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN3, {
	name = {
		type = "quest",
		id = 13999,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 13999,
	},
	items = {
		{
			type = "npc",
			id = 34613,
			-- name = "Go to Ta'jari",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3754, 0.4587, "Ta'jari")
			-- end,
			x = 0,
			y = 0,
			connections = {
				4,
			}
		},
		{
			type = "npc",
			id = 3390,
			-- name = "Go to Apothecary Helbrim",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4859, 0.5834, "Apothecary Helbrim")
			-- end,
			x = 2,
			y = 0,
			connections = {
				4,
			},
		},
		{
			type = "npc",
			id = 3448,
			-- name = "Go to Tonga Runetotem",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4949, 0.5866, "Tonga Runetotem")
			-- end,
			x = 4,
			y = 0,
			connections = {
				4,
			},
		},
		{
			type = "npc",
			id = 34841,
			-- name = "Go to Kolkar Wrangler",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3808, 0.4628, "Kolkar Wrangler")
			-- end,
			x = 6,
			y = 0,
			connections = {
				4,
			}
		},

		{
			type = "quest",
			id = 13992,
			aside = true,
			x = 0,
			y = 1,
		},
		{
			type = "quest",
			id = 848,
			x = 2,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_MYSTERIES_OF_THE_OASES,
			aside = true,
            userdata = {scrollTo = false},
			x = 4,
			y = 1,
		},
		{
			type = "quest",
			id = 850,
			aside = true,
			x = 6,
			y = 1,
		},

		
		{
			type = "npc",
			id = 34638,
			-- name = "Go to Shoe",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5520, 0.7840, "Shoe")
			-- end,
			x = 0,
			y = 2,
			connections = {
				3,
			}
		},
		{
			type = "quest",
			id = 13998,
			x = 3,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "npc",
			id = 34634,
			-- name = "Go to Gorgal Angerscar",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5511, 0.7854, "Gorgal Angerscar")
			-- end,
			x = 6,
			y = 2,
			connections = {
				3,
			}
		},

		

		{
			type = "quest",
			id = 14072,
			aside = true,
			x = 0,
			y = 3,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13999,
			x = 3,
			y = 3,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13995,
			aside = true,
			x = 6,
			y = 3,
		},


		{
			type = "quest",
			id = 851,
			aside = true,
			x = 0,
			y = 4,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_RATCHET,
			aside = true,
			active = {
				
				type = "quest",
				id = 13999,
			},
			x = 3,
			y = 4,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN4, {
	name = {
		type = "quest",
		id = 14066,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 14067,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 13991,
					restrictions = {
						type = "quest",
						id = 13991,
						status = {'active', 'completed'}
					},
				},
				{
					type = "npc",
					id = 3464,
					-- name = "Go to Kargal Battlescar",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6767, 0.3939, "Kargal Battlescar")
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
			id = 14066,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 869,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14067,
			x = 3,
			y = 3,
		},
		{
			type = "quest",
			id = 14068,
			aside = true,
			x = 5,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN5, {
	name = {
		type = "quest",
		id = 14042,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 14042,
	},
	items = {
		{
			type = "quest",
			id = 14034,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14038,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14042,
			x = 3,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN6, {
	name = {
		type = "quest",
		id = 14049,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 14049,
	},
	items = {
		{
			type = "quest",
			id = 14045,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14046,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14049,
			x = 3,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN7, {
	name = {
		type = "quest",
		id = 14063,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
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
		id = 14063,
	},
	items = {
		{
			type = "quest",
			id = 14052,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14056,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14057,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 14063,
			x = 3,
			y = 4,
		},
	}
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851084,
		texCoords = {0,1,0,1},
	},
	restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_HORDE
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_FAR_WATCH,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_GROLDOM_FARM,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_DEFEATING_THE_KOLKAR,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_MYSTERIES_OF_THE_OASES,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN2,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN3,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_RATCHET,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN4,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN5,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN6,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_CHAIN7,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_NOZZLEPOTS_OUTPOST,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_NORTHERN_BARRENS_INSPIRATION_AND_HOPE,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_NORTHERN_BARRENS,
})