local MAP_ID = 56
local ACHIEVEMENT_ID = 12429

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_SLABCHISEL_SURVEY, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		{
			type = "quest",
			id = 25736,
		},
		{
			type = "quest",
			id = 25734,
		},
		{
			type = "quest",
			id = 25733,
		},
		{
			type = "quest",
			id = 25735,
		},
	},
	items = {
        {
			type = "npc",
			id = 41129,
			-- name = "Go to Surveyor Thurdan",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5747, 0.7142, "Surveyor Thurdan")
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
					id = 25770,
					restrictions = {
						type = "quest",
						id = 25770,
						status = {'active'},
					}
				},
				{
					type = "npc",
					id = 41086,
					-- name = "Go to Forba Slabchisel",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5751, 0.7175, "Forba Slabchisel")
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
			id = 41128,
			-- name = "Go to Dunlor Marblebeard",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5783, 0.7149, "Dunlor Marblebeard")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3,
			},
		},


		{
			type = "quest",
			id = 25722,
			x = 1,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 25721,
			x = 3,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 25723,
			x = 5,
			y = 1,
			connections = {
                3,
            },
		},


		{
			type = "quest",
			id = 25726,
			x = 1,
			y = 2,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 25727,
			x = 3,
			y = 2,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 25725,
			x = 5,
			y = 2,
			connections = {
                4,
            },
		},



		{
			type = "quest",
			id = 25736,
			x = 0,
			y = 3,
		},
		{
			type = "quest",
			id = 25734,
			x = 2,
			y = 3,
		},
		{
			type = "quest",
			id = 25733,
			x = 4,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 25735,
			x = 6,
			y = 3,
		},

		{
			type = "quest",
			id = 25777,
			aside = true,
			x = 4,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_THE_FLOODING_OF_MENETHIL,
			aside = true,
			x = 4,
			y = 5,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_THE_FLOODING_OF_MENETHIL, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		{
			type = "quest",
			id = 25780,
		},
		{
			type = "quest",
			id = 25819,
		},
		{
			type = "quest",
			id = 25805,
		},
		{
			type = "quest",
			id = 25820,
		},
	},
	items = {
        {
			type = "npc",
			id = 1484,
			-- name = "Go to Derina Rumdnul",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1185, 0.5790, "Derina Rumdnul")
			-- end,
			x = 0,
			y = 0,
			connections = {
				4,
			},
		},
        {
			type = "npc",
			id = 41297,
			-- name = "Go to Karl Boran",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1109, 0.5778, "Karl Boran")
			-- end,
			x = 2,
			y = 0,
			connections = {
				4,
			},
		},
        {
			variations = {
				{
					type = "quest",
					id = 25777,
					restrictions = {
						type = "quest",
						id = 25777,
						status = {'active'},
					}
				},
				{
					type = "npc",
					id = 2104,
					-- name = "Go to Captain Stoutfist",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1052, 0.5571, "Captain Stoutfist")
					-- end,
				}
			},
			x = 4,
			y = 0,
			connections = {
				4,
			},
		},
        {
			type = "npc",
			id = 1239,
			-- name = "Go to First Mate Fitzsimmons",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1096, 0.5974, "First Mate Fitzsimmons")
			-- end,
			x = 6,
			y = 0,
			connections = {
				4,
			},
		},

		
		{
			type = "quest",
			id = 25820,
			x = 0,
			y = 1,
			connections = {
				4,
			},
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN2,
			x = 2,
			y = 1,
			connections = {
				3,
			},
		},
		{
			type = "quest",
			id = 25780,
			x = 4,
			y = 1,
			connections = {
				2,
			},
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN3,
			x = 6,
			y = 1,
			connections = {
				1,
			},
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN4,
			aside = true,
			x = 3,
			y = 2,
		}
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_ENGINEERS_AND_ARCHAEOLOGISTS, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		{
			type = "quest",
			id = 25853,
		},
		{
			type = "quest",
			id = 26189,
		},
		{
			type = "quest",
			id = 25850,
		},
	},
	items = {
        {
			type = "npc",
			id = 41413,
			-- name = "Go to Merrin Rockweaver",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3884, 0.3972, "Merrin Rockweaver")
			-- end,
			x = 1,
			y = 0,
			connections = {
				4,
			},
		},
        {
			variations = {
				{
					type = "quest",
					id = 26981,
					restrictions = {
						type = "quest",
						id = 26981,
						status = {'active'},
					}
				},
				{
					type = "npc",
					id = 41411,
					-- name = "Go to Prospector Whelgar",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3893, 0.3936, "Prospector Whelgar")
					-- end,
				}
			},
			x = 3,
			y = 0,
			connections = {
				2,
			},
		},
        {
			type = "npc",
			id = 41412,
			-- name = "Go to Ormer Ironbraid",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3862, 0.3951, "Ormer Ironbraid")
			-- end,
			x = 5,
			y = 0,
			connections = {
				4,
			},
		},

		
		{
			type = "quest",
			id = 25849,
			x = 3,
			y = 1,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 25853,
			x = 1,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26189,
			x = 3,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 25850,
			x = 5,
			y = 2,
			connections = {
                1,
            },
		},


		{
			type = "quest",
			id = 26195,
			aside = true,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN5,
			aside = true,
			x = 3,
			y = 4,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_WARDENS_OF_THE_WETLANDS, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		{
			type = "quest",
			id = 26120,
		},
		{
			type = "quest",
			id = 25927,
		},
		{
			type = "quest",
			id = 26196,
		},
		{
			type = "quest",
			id = 26128,
		}
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN5,
			x = 1,
			y = 0,
		},
        {
			variations = {
				{
					type = "quest",
					id = 26327,
					restrictions = {
						type = "quest",
						id = 26327,
						status = {'active', 'completed'},
					}
				},
				{
					type = "npc",
					id = 42160,
					-- name = "Go to Thargas Anvilmar",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4943, 0.1720, "Thargas Anvilmar")
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
			id = 26127,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26128,
			x = 3,
			y = 2,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN1, {
	name = BtWQuests_GetAreaName(836),
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		type = "quest",
		id = 25770,
	},
	items = {
        {
			type = "npc",
			id = 41074,
			-- name = "Go to Mountaineer Grugelm",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4991, 0.7924, "Mountaineer Grugelm")
			-- end,
			x = 1,
			y = 0,
			connections = {
				2,
			},
		},
        {
            variations = {
				{
					type = "quest",
					id = 26137,
                    restrictions = {
                        type = "quest",
                        id = 26137,
                        status = {'active', 'completed'}
                    },
				},
				{
					type = "quest",
					id = 28565,
                    restrictions = {
                        type = "quest",
                        id = 28565,
                        status = {'active', 'completed'}
                    },
				},
				{
					type = "npc",
					id = 41075,
					-- name = "Go to Mountaineer Rharen",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4995, 0.7916, "Mountaineer Rharen")
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
			id = 25211,
			aside = true,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 25395,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25770,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_SLABCHISEL_SURVEY, 
			active = {
				type = "quest",
				id = 25395,
			},
			x = 3,
			y = 3,
		}
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN2, {
	name = { -- Return the Statuette
		type = "quest",
		id = 25805,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		type = "quest",
		id = 25805,
	},
	items = {
        {
			type = "npc",
			id = 41297,
			-- name = "Go to Karl Boran",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1109, 0.5778, "Karl Boran")
			-- end,
			x = 3,
			y = 0,
			connections = {
				1,
			},
		},
		{
			type = "quest",
			id = 25800,
			x = 3,
			y = 1,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 25801,
			x = 2,
			y = 2,
		},
		{
			type = "quest",
			id = 25802,
			x = 4,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25803,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25804,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25805,
			x = 3,
			y = 5,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN3, {
	name = { -- The Eye of Paleth
		type = "quest",
		id = 25819,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		type = "quest",
		id = 25819,
	},
	items = {
		{
			type = "quest",
			id = 25815,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25816,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25817,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25818,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25819,
			x = 3,
			y = 5,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN4, {
	name = { -- The Mosshide Job
		type = "quest",
		id = 25865,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		type = "quest",
		id = 25865,
	},
	items = {
        {
			type = "npc",
			id = 41435,
			-- name = "Go to Fradd Swiftgear",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2682, 0.2587, "Fradd Swiftgear")
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
					id = 26980,
					restrictions = {
						type = "quest",
						id = 26980,
						status = {'active'},
					}
				},
				{
					type = "npc",
					id = 41415,
					-- name = "Go to Shilah Slabchisel",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2693, 0.2608, "Shilah Slabchisel")
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
			id = 41433,
			-- name = "Go to James Halloran",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2677, 0.2673, "James Halloran")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3,
			},
		},


		{
			type = "quest",
			id = 25854,
			x = 1,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 25864,
			x = 3,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 25856,
			x = 5,
			y = 1,
			connections = {
                3,
            },
		},

		
		{
			type = "quest",
			id = 25855,
			x = 1,
			y = 2,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 25865,
			x = 3,
			y = 2,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 25857,
			x = 5,
			y = 2,
			connections = {
                
            },
		},
		
		{
			type = "quest",
			id = 25867,
			x = 2,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 25866,
			x = 4,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 25868,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_ENGINEERS_AND_ARCHAEOLOGISTS,
			aside = true,
			x = 3,
			y = 5,
		}
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN5, {
	name = { -- The Threat of Flame
		type = "quest",
		id = 25927,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
    prerequisites = {
        {
            type = "level",
            level = 10,
		},
    },
	completed = {
		{
			type = "quest",
			id = 26120,
		},
		{
			type = "quest",
			id = 25927,
		},
		{
			type = "quest",
			id = 26196,
		}
	},
	items = {
        {
			type = "npc",
			id = 41612,
			-- name = "Go to Huntress Iczelia",
			-- breadcrumb = true,
			aside = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5636, 0.3984, "Huntress Iczelia")
			-- end,
			x = 1,
			y = 0,
			connections = {
				2,
			},
		},
        {
			type = "npc",
			id = 41503,
			-- name = "Go to Rethiel the Greenwarden",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5633, 0.4037, "Rethiel the Greenwarden")
			-- end,
			x = 3,
			y = 0,
			connections = {
				2,
			},
		},
		{
			type = "quest",
			id = 26120,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 25926,
			x = 3,
			y = 1,
			connections = {
                1, 2,
            },
		},


		{
			type = "quest",
			id = 25927,
			x = 2,
			y = 2,
		},
		{
			type = "quest",
			id = 25939,
			x = 4,
			y = 2,
			connections = {
                1,
            },
		},

		
		{
			type = "quest",
			id = 26196,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_WARDENS_OF_THE_WETLANDS,
			aside = true,
			x = 3,
			y = 4,
		},
	}
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_WETLANDS, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851113,
		texCoords = {0,1,0,1},
	},
	restrictions = {
		{
			type = "faction",
			id = BTWQUESTS_FACTION_ID_ALLIANCE,
		}
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_SLABCHISEL_SURVEY,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_THE_FLOODING_OF_MENETHIL,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN2,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN3,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN4,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_ENGINEERS_AND_ARCHAEOLOGISTS,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_CHAIN5,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_WETLANDS_WARDENS_OF_THE_WETLANDS,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_WETLANDS,
})