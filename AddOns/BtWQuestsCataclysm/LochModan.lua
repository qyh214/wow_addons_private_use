local MAP_ID = 48
local ACHIEVEMENT_ID = 4899

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_ROAD_TO_THELSAMAR, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN2,
		},
		{
			type = "quest",
			id = 25118,
		},
		{
			type = "quest",
			id = 26842,
		},
		{
			type = "quest",
			id = 26860,
		},
		{
			type = "quest",
			id = 13648,
		},
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN1,
			x = 2,
			y = 0,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN2,
			x = 4,
			y = 0,
		},
		{
			type = "npc",
			id = 1777,
			-- name = "Go to Dakk Blunderblast",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3602, 0.4426, "Dakk Blunderblast")
			-- end,
			x = 0,
			y = 1,
			connections = {
				4,
			},
		},
		{
			variations = {
				{
					type = "quest",
					id = 26176,
					restrictions = {
						{
							type = "quest",
							id = 26176,
							status = {'active', 'completed'},
						}
					},
				},
				{
					type = "npc",
					id = 1340,
					-- name = "Go to Mountaineer Kadrell",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3507, 0.4658, "Mountaineer Kadrell")
					-- end,
				}
			},
			x = 2,
			y = 1,
			connections = {
				4,
			},
		},
		{
			type = "npc",
			id = 1963,
			-- name = "Go to Vidra Hearthstove",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3482, 0.4928, "Vidra Hearthstove")
			-- end,
			x = 4,
			y = 1,
			connections = {
				4,
			},
		},
		{
			type = "object",
			id = 256,
			-- name = "Go to the Wanted! sign",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.3730, 0.4651, "Wanted! sign")
			-- end,
			x = 6,
			y = 1,
			connections = {
				4,
			},
		},
		{
			type = "quest",
			id = 25118,
			x = 0,
			y = 2,
		},
		{
			type = "quest",
			id = 26842,
			x = 2,
			y = 2,
		},
		{
			type = "quest",
			id = 26860,
			x = 4,
			y = 2,
		},
		{
			type = "quest",
			id = 13648,
			x = 6,
			y = 2,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_AXIS_OF_AWFUL,
			x = 2,
			y = 3,
		},
		{
			type = "quest",
			id = 13656,
			x = 6,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_AXIS_OF_AWFUL, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
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
		id = 26868,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 13636,
					restrictions = {
						type = "quest",
						id = 13636,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 1343,
					-- name = "Go to Mountaineer Stormpike",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2545, 0.1796, "Mountaineer Stormpike")
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
			id = 26843,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26844,
			x = 3,
			y = 2,
			connections = {
                1, 2, 3,
            },
		},
		

		{
			type = "quest",
			id = 26863,
			aside = true,
			x = 1,
			y = 3,
		},
		{
			type = "quest",
			id = 26845,
			x = 3,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26846,
			aside = true,
			x = 5,
			y = 3,
		},
		{
			type = "quest",
			id = 26864,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26927,
			x = 3,
			y = 5,
			connections = {
                1, 2, 3,
            },
		},
		{
			type = "quest",
			id = 26932,
			aside = true,
			x = 1,
			y = 6,
		},
		{
			type = "quest",
			id = 26928,
			x = 3,
			y = 6,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 26929,
			aside = true,
			x = 5,
			y = 6,
		},
		{
			type = "quest",
			id = 13655,
			aside = true,
			x = 1,
			y = 7,
		},
		{
			type = "quest",
			id = 26868,
			x = 3,
			y = 7,
			connections = {
				1,
			},
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN3,
			aside = true,
			x = 3,
			y = 8,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_TWILIGHT_THREATS, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
		{
			type = "quest",
			id = 27033,
		}
	},
	completed = {
		type = "quest",
		id = 27116,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_FARSTRIDER_LODGE,
			completed = {
				type = "quest",
				id = 27033,
			},
			x = 3,
			y = 0,
			connections = {
                1,
            },
		},

		{
			type = "quest",
			id = 27034,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27035,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27074,
			x = 3,
			y = 3,
			connections = {
                1, 2,
            },
		},

		
		{
			type = "quest",
			id = 27075,
			x = 2,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27077,
			x = 4,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27078,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27115,
			x = 3,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 27116,
			x = 3,
			y = 7,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_FARSTRIDER_LODGE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
	category = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
	},
	completed = {
		{
			type = "quest",
			id = 27028,
		},
		{
			type = "quest",
			id = 27030,
		},
		{
			type = "quest",
			id = 27026,
		},
		{
			type = "quest",
			id = 27033,
		},
		{
			type = "quest",
			id = 27037,
		},
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 13647,
					restrictions = {
						{
							type = "quest",
							id = 13647,
							status = {'active'}
						},
					},
				},
				{
					type = "npc",
					id = 1154,
					-- name = "Go to Marek Ironheart",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.8176, 0.6166, "Marek Ironheart")
					-- end,
				},
			},
			x = 0,
			y = 0,
			connections = {
                4,
            },
		},
		{
			type = "npc",
			id = 44859,		
			-- name = "Go to Safety Warden Pipsy",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.8278, 0.6347, "Safety Warden Pipsy")
			-- end,
			x = 2,
			y = 0,
			connections = {
                4,
            },
		},
		{
			type = "npc",
			id = 6577,
			-- name = "Go to Bingles Blastenheimer",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.8165, 0.6475, "Bingles Blastenheimer")
			-- end,
			x = 4,
			y = 0,
			connections = {
                4,
            },
		},
		{
			type = "npc",
			id = 1187,
			-- name = "Go to Daryl the Younglin",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.8349, 0.6537, "Daryl the Youngling")
			-- end,
			x = 6,
			y = 0,
			connections = {
                4,
            },
		},

		{
			type = "quest",
			id = 27028,
			x = 0,
			y = 1,
		},
		{
			type = "quest",
			id = 27025,
			x = 2,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 27031,
			x = 4,
			y = 1,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 27016,
			x = 6,
			y = 1,
			connections = {
                4,
            },
		},


		{
			type = "quest",
			id = 27030,
			x = 0,
			y = 2,
		},
		{
			type = "quest",
			id = 27026,
			x = 2,
			y = 2,
		},
		{
			type = "quest",
			id = 27032,
			x = 4,
			y = 2,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 27036,
			x = 6,
			y = 2,
			connections = {
                4,
            },
		},

		{
			type = "quest",
			id = 13659,
			aside = true,
			x = 0,
			y = 3,
		},
		{
			type = "quest",
			id = 13660,
			aside = true,
			x = 2,
			y = 3,
		},
		{
			type = "quest",
			id = 27033,
			x = 4,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 27037,
			x = 6,
			y = 3,
		},


		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_TWILIGHT_THREATS,
			x = 4,
			y = 4,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN1, {
	name = {
		type = "quest",
		id = 26855
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
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
		id = 26855,
	},
	items = {
		{
			variations = {
				{
					type = "quest",
					id = 26131,
					restrictions = {
						{
							type = "quest",
							id = 26131,
							status = {'active'},
						}
					},
				},
				{
					type = "quest",
					id = 28567,
					restrictions = {
						{
							type = "quest",
							id = 28567,
							status = {'active', 'completed'},
						}
					},
				},
				{
					type = "npc",
					id = 1960,
					-- name = "Go to Pilot Hammerfoot",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1401, 0.5649, "Pilot Hammerfoot")
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
			id = 26854,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26855,
			x = 3,
			y = 2,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN2,
			aside = true,
            visible = {
                {
                    type = "quest",
                    id = 26145,
                    restrictions = {
                        type = "quest",
                        id = 13635,
                        status = {'notcompleted'}
                    },
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 26145,
                    restrictions = {
                        type = "quest",
                        id = 13635,
                        status = {'notcompleted'}
                    },
                    status = {'notcompleted'}
                }
            },
            active = {
                type = "quest",
                id = 13635,
                status = {'active', 'completed'}
            },
			x = 3,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN2, {
	name = {
		type = "quest",
		id = 26148,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
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
		ids = {26145, 26148, 26147},
		count = 3,
	},
	items = {
		{
			type = "npc",
			id = 1089,
			-- name = "Go to Mountaineer Cobbleflint",
			-- breadcrumb = true,
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2333, 0.7492, "Mountaineer Cobbleflint")
			-- end,
			x = 2,
			y = 0,
			connections = {
                2,
            },
		},
		{
			variations = {
				{
					type = "quest",
					id = 13635,
					restrictions = {
						type = "quest",
						id = 13635,
						status = {'active', 'completed'},
					},
				},
				{
					type = "npc",
					id = 1092,
					-- name = "Go to Captain Rugelfuss",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2338, 0.7505, "Captain Rugelfuss")
					-- end,
				},
			},
			x = 4,
			y = 0,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26145,
			x = 2,
			y = 1,
		},
		{
			type = "quest",
			id = 26146,
			x = 4,
			y = 1,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 26148,
			x = 2,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26147,
			x = 4,
			y = 2,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_ROAD_TO_THELSAMAR,
			aside = true,
            visible = {
                {
                    type = "quest",
                    id = 26842,
                    restrictions = {
                        type = "quest",
                        id = 26176,
                        status = {'notcompleted'}
                    },
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 26842,
                    restrictions = {
                        type = "quest",
                        id = 26176,
                        status = {'notcompleted'}
                    },
                    status = {'notcompleted'}
                }
            },
            active = {
                type = "quest",
                id = 26176,
                status = {'active', 'completed'}
            },
			x = 3,
			y = 3,
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN3, {
	name = {
		type = "quest",
		id = 13639,
	},
	category = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {5,30},
	prerequisites = {
		{
			type = "level",
			level = 5,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_AXIS_OF_AWFUL,
		},
	},
	completed = {
		{
			type = "quest",
			id = 13650,
		},
		{
			type = "quest",
			id = 13647,
		},
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_AXIS_OF_AWFUL,
			x = 3,
			y = 0,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13639,
			x = 3,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "object",
			id = 194388,
			-- name = "Go to Stolen Explorers' League Document",
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6170, 0.7318, "Stolen Explorers' League Document")
			-- end,
			-- breadcrumb = true,
			aside = true,
			x = 5,
			y = 1,
			connections = {
                3,
            },
		},
		{
			type = "object",
			id = 194389,
			-- name = "Go to Stolen Explorers' League Document",
			-- onClick = function ()
			-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.6811, 0.6614, "Stolen Explorers' League Document")
			-- end,
			-- breadcrumb = true,
			aside = true,
			x = 1,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 309,
			x = 3,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
			id = 13657,
			aside = true,
			x = 5,
			y = 2,
		},
		{
			type = "quest",
			id = 13658,
			aside = true,
			x = 1,
			y = 3,
		},
		{
			type = "quest",
			id = 13650,
			x = 3,
			y = 3,
		},
		{
			type = "quest",
			id = 26961,
			x = 5,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 13647,
			x = 5,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_FARSTRIDER_LODGE,
			aside = true,
			x = 5,
			y = 5,
		}
	}
})

-- {
-- 	type = "quest",
-- 	id = 13661,
-- 	x = 6,
-- 	y = 3,
-- 	connections = {
		
-- 	},
-- },

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851081,
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
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN2,
		},

		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_ROAD_TO_THELSAMAR,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_AXIS_OF_AWFUL,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_CHAIN3,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_THE_FARSTRIDER_LODGE,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_LOCH_MODAN_TWILIGHT_THREATS,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_LOCH_MODAN,
})