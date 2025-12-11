local L = BtWQuests.L
local MAP_ID = 49

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_THEGNOLLOFFENSIVE, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(4902, 1),
	category = BTWQUESTS_CATEGORY_CLASSIC_REDRIDGE_MOUNTAINS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {7,30},
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
	completed = {
		type = "quest",
		id = 26545,
	},
	items = {
        {
			type = "npc",
			id = 342,
            -- name = "Go to Martie Jainrose",
            -- breadcrumb = true,
            aside = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2204, 0.4270, "Martie Jainrose")
            -- end,
			x = 0,
			y = 0,
			connections = {
				4,
			},
        },
        {
			type = "npc",
			id = 900,
            -- name = "Go to Bailiff Conacher",
            -- breadcrumb = true,
            aside = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2868, 0.4096, "Bailiff Conacher")
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
                    id = 26505,
                    restrictions = {
                        type = "quest",
                        id = 26505,
                        status = {'active'}
                    },
				},
				{
					type = "quest",
					id = 28563,
                    restrictions = {
                        type = "quest",
                        id = 28563,
                        status = {'active'}
                    },
				},
				{
					type = "npc",
					id = 344,
					-- name = "Go to Magistrate Solomon",
                    -- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2891, 0.4110, "Magistrate Solomon")
					-- end,
				},
			},
			x = 4,
			y = 0,
			connections = {
				4,
			},
        },
        {
			type = "npc",
			id = 8965,
            -- name = "Go to Shawn",
            -- breadcrumb = true,
            aside = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.2835, 0.4888, "Shawn")
            -- end,
			x = 6,
			y = 0,
			connections = {
				4,
			},
        },
		{
			type = "quest",
			id = 26509,
            aside = true,
			x = 0,
			y = 1,
		},
		{
			type = "quest",
			id = 26511,
            aside = true,
			x = 2,
			y = 1,
		},
		{
			type = "quest",
			id = 26510,
			x = 4,
			y = 1,
			connections = {
                2, 3,
            },
		},
		{
			type = "quest",
			id = 26508,
            aside = true,
			x = 6,
			y = 1,
		},
		{
			type = "quest",
			id = 26512,
			x = 3,
			y = 2,
			connections = {
                3,
            },
		},
		{
			type = "quest",
            id = 26513,
            aside = true,
			x = 5,
			y = 2,
		},
		{
            name = L["KILL_GNOLLS"],
            breadcrumb = true,
            aside = true,
			x = 1,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26514,
			x = 3,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26519,
            aside = true,
			x = 1,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26544,
			x = 3,
			y = 4,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26520,
            aside = true,
			x = 1,
			y = 5,
		},
		{
			type = "quest",
			id = 26545,
			x = 3,
			y = 5,
			connections = {
                1,
            },
        },
		{
			type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_KEESHANSRAIDERS,
            aside = true,
			x = 3,
			y = 6,
        },
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_KEESHANSRAIDERS, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(4902, 2),
	category = BTWQUESTS_CATEGORY_CLASSIC_REDRIDGE_MOUNTAINS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {7,30},
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_THEGNOLLOFFENSIVE,
        },
    },
	completed = {
		type = "quest",
		id = 26607,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_THEGNOLLOFFENSIVE,
			x = 3,
			y = 0,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26567,
			x = 3,
			y = 1,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26568,
			x = 3,
			y = 2,
			connections = {
                2, 3, 4, 5,
            },
        },

		{
			type = "quest",
            id = 26520,
            aside = true,
			x = 6,
			y = 2,
			connections = {
                4,
            },
        },
        
		{
			type = "quest",
			id = 26570,
            aside = true,
			x = 0,
			y = 3,
		},
		{
			type = "quest",
			id = 26571,
			x = 2,
			y = 3,
			connections = {
                7,
            },
		},
		{
			type = "quest",
			id = 26586,
			x = 4,
			y = 3,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26569,
            aside = true,
			x = 6,
			y = 3,
		},
		{
			type = "quest",
			id = 26587,
			x = 4,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26560,
			x = 4,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26561,
			x = 4,
			y = 6,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26562,
			x = 4,
			y = 7,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26573,
			x = 2,
			y = 8,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26563,
			x = 4,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26607,
			x = 3,
			y = 9,
			connections = {
                1,
            },
        },
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_FIRSTBLOOD,
			x = 3,
			y = 10,
        },
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_FIRSTBLOOD, {
	name = BtWQuests_GetAchievementCriteriaNameDelayed(4902, 3),
	category = BTWQUESTS_CATEGORY_CLASSIC_REDRIDGE_MOUNTAINS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {7,30},
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_KEESHANSRAIDERS,
        },
    },
	completed = {
		type = "quest",
		id = 26726,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_KEESHANSRAIDERS,
			x = 3,
			y = 0,
			connections = {
                1,
            },
        },
		{
			type = "quest",
			id = 26616,
			x = 3,
			y = 1,
			connections = {
                1, 2, 3, 4,
            },
		},
		{
			type = "quest",
			id = 26637,
			x = 0,
			y = 2,
			connections = {
                5,
            },
		},
		{
			type = "quest",
			id = 26638,
			x = 2,
			y = 2,
			connections = {
                4,
            },
		},
		{
			type = "quest",
			id = 26639,
			x = 4,
			y = 2,
			connections = {
                2,
            },
        },
		{
			type = "quest",
			id = 26636,
			x = 6,
			y = 2,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26640,
			x = 3,
			y = 3,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26646,
			x = 3,
			y = 4,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26651,
			x = 3,
			y = 5,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26668,
			x = 3,
			y = 6,
			connections = {
                1, 2,
            },
		},
		{
			type = "quest",
			id = 26693,
			x = 2,
			y = 7,
			connections = {
                2,
            },
		},
		{
			type = "quest",
            id = 26692,
            aside = true,
			x = 4,
			y = 7,
		},
		{
			type = "quest",
			id = 26694,
			x = 3,
			y = 8,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26708,
			x = 3,
			y = 9,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26713,
			x = 3,
			y = 10,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26714,
			x = 3,
			y = 11,
			connections = {
                1,
            },
		},
		{
			type = "quest",
			id = 26726,
			x = 3,
			y = 12,
			connections = {
            },
		},
	}
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_CHAIN1, {
	name = BtWQuests_GetAreaName(5327), -- Tower Watch
	category = BTWQUESTS_CATEGORY_CLASSIC_REDRIDGE_MOUNTAINS,
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	range = {7,30},
    prerequisites = {
        {
            type = "level",
            level = 7,
        },
    },
	completed = {
		type = "quest",
		id = 26505,
	},
	items = {
        {
            variations = {
				{
                    type = "quest",
                    id = 26365,
                    restrictions = {
                        type = "quest",
                        id = 26365,
                        status = {'active', 'completed'}
                    },
				},
				{
					type = "quest",
					id = 28563,
                    restrictions = {
                        type = "quest",
                        id = 28563,
                        status = {'active', 'completed'}
                    },
				},
				{
					type = "npc",
					id = 464,
					-- name = "Go to Watch Captain Parker",
					-- breadcrumb = true,
					-- onClick = function ()
					-- 	BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.1532, 0.6459, "Watch Captain Parker")
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
			id = 26504,
			x = 1,
			y = 1,
		},
		{
			type = "quest",
			id = 26503,
			x = 3,
			y = 1,
			connections = {
                2,
            },
		},
		{
			type = "quest",
			id = 26506,
			x = 5,
			y = 1,
        },
		{ -- Not a standard breadcrumb quest, can be completed even if the next quest has been taken or completed
			type = "quest",
			id = 26505,
            x = 3,
            y = 2,
			connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_THEGNOLLOFFENSIVE,
            aside = true,
            active = {
                {
                    type = "quest",
                    id = 26505,
                },
                {
                    type = "quest",
                    id = 26510,
                    status = {'active', 'completed'},
                }
            },
            x = 3,
            y = 3
        },
	}
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_REDRIDGE_MOUNTAINS, {
	name = BtWQuests_GetMapName(MAP_ID),
	expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851085,
		texCoords = {0,1,0,1},
	},
	restrictions = {
		type = "faction",
		id = BTWQUESTS_FACTION_ID_ALLIANCE,
	},
	items = {
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_CHAIN1,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_THEGNOLLOFFENSIVE,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_KEESHANSRAIDERS,
		},
		{
			type = "chain",
			id = BTWQUESTS_CHAIN_CLASSIC_REDRIDGE_MOUNTAINS_FIRSTBLOOD,
		},
	}
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_REDRIDGE_MOUNTAINS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_REDRIDGE_MOUNTAINS,
})