local MAP_ID = 26
local ACHIEVEMENT_ID = 4897

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_STORMFEATHER_OUTPOST, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
	restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
	},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
	completed = {
		type = "quest",
		id = 26462,
	},
	items = {
		{
			type = "npc",
			id = 43109,
			-- name = "Go to Dron Blastbrew",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6624, 0.4427, "Dron Blastbrew")
			-- end,
			x = 1,
			y = 0,
			connections = {
				2, 3,
			},
		},
		{
			variations = {
				{
					type = "quest",
					id = 26548,
					restrictions = {
						type = "quest",
						id = 26548,
						status = {'active'},
					},
				},
				{
					type = "npc",
					id = 43108,
					-- name = "Go to Kerr Ironsight",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6636, 0.4428, "Kerr Ironsight")
					-- end,
				}
			},
			x = 5,
			y = 0,
			connections = {
				3, 4,
			},
		},


		{
			type = "quest",
			id = 26485,
			x = 0,
			y = 1,
		},
		{
			type = "quest",
			id = 26486,
			x = 2,
			y = 1,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 26462,
			x = 4,
			y = 1,
			connections = {
                2, 3, 4,
            },
		},
		{
			type = "quest",
			id = 26483,
			x = 6,
			y = 1,
			connections = {
                1, 2, 3,
            },
		},

		
		{
			type = "quest",
			id = 26490,
			x = 2,
			y = 2,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 26491,
			x = 4,
			y = 2,
			connections = {
				2,
            },
		},
		{
			type = "quest",
			id = 26492,
			x = 6,
			y = 2,
			connections = {
				1,
            },
		},
		{
			type = "quest",
			id = 26496,
			aside = true,
			x = 5,
			y = 3,
			connections = {
				1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_JINTHAALOR_ALLIANCE,
			aside = true,
			x = 5,
			y = 4,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_JINTHAALOR_ALLIANCE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
	restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
	},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
	completed = {
		type = "quest",
		id = 26526,
	},
	items = {
		{
			type = "npc",
			id = 43156,		
			-- name = "Go to Fraggar Thundermantle",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6373, 0.5995, "Fraggar Thundermantle")
			-- end,
			x = 1,
			y = 0,
			connections = {
				2, 3,
			},
		},
		{
			variations = {
				{
					type = "quest",
					id = 26496,
					restrictions = {
						type = "quest",
						id = 26496,
						status = {'active'},
					},
				},
				{
					type = "npc",
					id = 43157,
					-- name = "Go to Doran Steelwing",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6389, 0.5987, "Doran Steelwing")
					-- end,
				}
			},
			x = 5,
			y = 0,
			connections = {
				3, 4,
			},
		},


		{
			type = "quest",
			id = 26521,
			x = 0,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 26523,
			x = 2,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26497,
			x = 4,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26518,
			x = 6,
			y = 1,
			connections = {
                3,
            },
		},

		
		{
			type = "quest",
			id = 26524,
			x = 1,
			y = 2,
			connections = {
                
            },
		},
		{
			type = "quest",
			id = 26498,
			x = 4,
			y = 2,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 26515,
			x = 6,
			y = 2,
			connections = {
                
            },
		},


		{
			type = "quest",
			id = 26517,
			x = 3,
			y = 3,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 26516,
			x = 5,
			y = 3,
			connections = {
                
            },
		},

		{
			type = "quest",
			id = 26526,
			x = 2,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26525,
			x = 4,
			y = 4,
		},
		{
			type = "quest",
			id = 27725,
			aside = true,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_QUELDANIL_LODGE,
			aside = true,
			x = 3,
			y = 6,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_QUELDANIL_LODGE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
	restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
	},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
	completed = {
		type = "quest",
		id = 26532,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_JINTHAALOR_ALLIANCE,
			x = 3,
			y = 0,
			connections = {
				1, 2,
			},
		},
		{
			type = "quest",
			id = 27625,
			x = 2,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27626,
			x = 4,
			y = 1,
			connections = {
                1,
            },
		},

		{
			type = "npc",
			id = 43200,		
			-- name = "Go to Gilda Cloudcaller",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3068, 0.4707, "Gilda Cloudcaller")
			-- end,
			x = 3,
			y = 2,
			connections = {
				1, 2,
			},
		},

		
		{
			type = "quest",
			id = 26528,
			x = 2,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26641,
			x = 4,
			y = 3,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 26529,
			x = 2,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26643,
			x = 4,
			y = 4,
		},


		{
			type = "quest",
			id = 26530,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26531,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26532,
			x = 3,
			y = 7,
		},

	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_JINTHAALOR_HORDE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
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
		{
			type = "quest",
			id = 26357,
		},
		{
			type = "quest",
			id = 26308,
		},
		{
			type = "quest",
			id = 26368,
		},
		{
			type = "quest",
			id = 26369,
		},
	},
	items = {
		{
			type = "npc",
			id = 42624,		
			-- name = "Go to Kotonga",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6779, 0.6628, "Kotonga")
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
					id = 26432,
					restrictions = {
						type = "quest",
						id = 26432,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 42642,				
					-- name = "Go to Primal Torntusk",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6782, 0.6651, "Primal Torntusk")
					-- end,
				}
			},
			x = 3,
			y = 0,
			connections = {
				3, 4,
			},
		},
		{
			type = "npc",
			id = 42622,
			-- name = "Go to Eliza Darkgrin",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6764, 0.6660, "Eliza Darkgrin")
			-- end,
			x = 5,
			y = 0,
			connections = {
				4,
			},
		},

		
		{
			type = "quest",
			id = 26357,
			x = 0,
			y = 1,
		},
		{
			type = "quest",
			id = 26306,
			x = 2,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26366,
			x = 4,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26310,
			x = 6,
			y = 1,
			connections = {
                3,
            },
		},


		{
			type = "quest",
			id = 26307,
			x = 2,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26367,
			x = 4,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26309,
			x = 6,
			y = 2,
			connections = {
                3,
            },
		},

		{
			type = "quest",
			id = 26308,
			x = 2,
			y = 3,
		},
		{
			type = "quest",
			id = 26363,
			x = 4,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26368,
			x = 6,
			y = 3,
		},


		{
			type = "quest",
			id = 26369,
			x = 4,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26384,
			aside = true,
			x = 4,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26384,
			aside = true,
			x = 4,
			y = 6,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_HIRIWATHA, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
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
		{
			type = "quest",
			id = 26387,
		},
		{
			type = "quest",
			id = 26419,
		},
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 26384,
					restrictions = {
						type = "quest",
						id = 26384,
						status = {'active'},
					},
				},
				{
					type = "npc",
					id = 42898,
					-- name = "Go to Darkcleric Marnal",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3186, 0.5839, "Darkcleric Marnal")
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
			id = 42896,
			-- name = "Go to Apothecary Surlis",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3182, 0.5856, "Apothecary Surlis")
			-- end,
			x = 4,
			y = 0,
			connections = {
				2,
			},
		},


		{
			type = "quest",
			id = 26381,
			x = 2,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26382,
			x = 4,
			y = 1,
			connections = {
                2,
            },
		},


		{
			type = "quest",
			id = 26406,
			x = 2,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26387,
			x = 4,
			y = 2,
		},


		{
			type = "quest",
			id = 26418,
			x = 2,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26558,
			x = 2,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26419,
			x = 2,
			y = 5,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_REVANTUSK_VILLAGE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
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
		{
			type = "quest",
			id = 26283,
		},
		{
			type = "quest",
			id = 26267,
		},
		{
			type = "quest",
			id = 26268,
		},
		{
			type = "quest",
			id = 26212,
		},
		{
			type = "quest",
			id = 26225,
		},
		{
			type = "quest",
			id = 26240,
		},
		{
			type = "quest",
			id = 26210,
		},
		{
			type = "quest",
			id = 26211,
		},
		{
			type = "quest",
			id = 26224,
		},
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 26430,
					restrictions = {
						type = "quest",
						id = 26430,
						status = {'active'},
					},
				},
				{
					type = "quest",
					id = 28574,
					restrictions = {
						type = "quest",
						id = 28574,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 42613,
					-- name = "Go to Elder Torntusk",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7818, 0.8130, "Elder Torntusk")
					-- end,
				}
			},
			x = 1,
			y = 0,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 14731,		
			-- name = "Go to Lard",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7813, 0.8139, "Lard")
			-- end,
			x = 3,
			y = 0,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 14741,
			-- name = "Go to Huntsman Markhor",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7916, 0.7953, "Huntsman Markhor")
			-- end,
			x = 5,
			y = 0,
			connections = {
				3,
			},
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN2,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 26212,
			x = 3,
			y = 1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN3,
			x = 5,
			y = 1,
		},

		
		{
			type = "npc",
			id = 42464,
			-- name = "Go to Grognard",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7729, 0.7997, "Grognard")
			-- end,
			x = 0,
			y = 2,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 14739,
			-- name = "Go to Mystic Yayo'jin",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7880, 0.7824, "Mystic Yayo'jin")
			-- end,
			x = 2,
			y = 2,
			connections = {
				3,
			},
		},
		{
			type = "npc",
			id = 14740,
			-- name = "Go to Katoom the Angler",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.8033, 0.8154, "Katoom the Angler")
			-- end,
			x = 5,
			y = 2,
			connections = {
				3, 4,
			},
		},
		{
			type = "quest",
			id = 26225,
			x = 0,
			y = 3,
		},
		{
			type = "quest",
			id = 26240,
			x = 2,
			y = 3,
		},
		{
			type = "quest",
			id = 26210,
			x = 4,
			y = 3,
		},
		{
			type = "quest",
			id = 26211,
			x = 6,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN1, {
	name = {
		type = "quest",
		id = 26546,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
	restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
	},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
	completed = {
		type = "quest",
		id = 26548,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 26542,
					restrictions = {
						type = "quest",
						id = 26542,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 5636,
					-- name = "Go to Gryphon Master Talonaxe",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.0990, 0.4423, "Gryphon Master Talonaxe")
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
			id = 26546,
			x = 2,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26547,
			x = 4,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26548,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_STORMFEATHER_OUTPOST,
			aside = true,
			x = 3,
			y = 3,
		}
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN2, {
	name = {
		type = "quest",
		id = 26238,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
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
		id = 26238,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 26430,
					restrictions = {
						type = "quest",
						id = 26430,
						status = {'active'},
					},
				},
				{
					type = "quest",
					id = 28574,
					restrictions = {
						type = "quest",
						id = 28574,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 42613,
					-- name = "Go to Elder Torntusk",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7818, 0.8130, "Elder Torntusk")
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
			id = 26238,
			x = 2,
			y = 1,
			connections = {
				2, 3, 4,
			},
		},
		{
			type = "quest",
			id = 26263,
			x = 4,
			y = 1,
			connections = {
				1, 2, 3,
			},
		},

		{
			type = "quest",
			id = 26283,
			x = 0,
			y = 2,
		},
		{
			type = "quest",
			id = 26267,
			x = 2,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26268,
			x = 4,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_JINTHAALOR_HORDE,
			x = 3,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN3, {
	name = {
		type = "quest",
		id = 26224,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {10,30},
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
		id = 26224,
	},
	items = {
		{
			type = "npc",
			id = 14741,
			-- name = "Go to Huntsman Markhor",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7916, 0.7953, "Huntsman Markhor")
			-- end,
			x = 3,
			y = 0,
			connections = {
				1,
			},
		},
		{
			type = "quest",
			id = 26223,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26224,
			x = 3,
			y = 2,
		},
	}
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851103,
		texCoords = {0,1,0,1},
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_STORMFEATHER_OUTPOST,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_JINTHAALOR_ALLIANCE,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_QUELDANIL_LODGE,
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_REVANTUSK_VILLAGE,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN2,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_CHAIN3,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_JINTHAALOR_HORDE,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_HINTERLANDS_HIRIWATHA,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_HINTERLANDS,
})