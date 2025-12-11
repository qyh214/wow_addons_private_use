local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Cataclysm
local CATEGORY_ID = BtWQuests.Constant.Category.Classic.TheCapeOfStranglethorn
local Chain = BtWQuests.Constant.Chain.Classic.TheCapeOfStranglethorn
local MAP_ID = 210
local CONTINENT_ID = 13
local ACHIEVEMENT_ID = 4905
local LEVEL_RANGE = {10, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 10,
    },
}

Database:AddChain(Chain.TheTrollsOfZulgurubAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheTrollsOfZulgurubHorde,
    },
    restrictions = 924,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {28702, 26805, 26825, 26826},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 26814,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28702,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28702,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28702,
                    restrictions = {
                        {
                            type = "quest",
                            id = 28702,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 26805,
                    restrictions = {
                        {
                            type = "quest",
                            id = 26805,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 26805,
                    restrictions = {
                        {
                            type = "quest",
                            id = 26805,
                            active = true,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 44082,                
                    -- name = "Go to Bronwyn Hewstrike",
                    -- breadcrumb = true,
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5524, 0.4248, "Bronwyn Hewstrike")
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
            ids = {26825, 26826},
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26823,
            x = 3,
            connections = {
                2, 3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 26822,
            x = 5,
        },
        {
            type = "quest",
            id = 26818,
            x = 0,
        },
        {
            type = "quest",
            id = 26817,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26819,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26820,
        },
        {
            type = "quest",
            id = 26815,
            x = 1,
            connections = {
                2, 3
            },
        },
        {
            type = "quest",
            id = 26808,
            x = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26816,
            x = 0,
        },
        {
            type = "quest",
            id = 26824,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26809,
            x = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26821,
            x = 2,
        },
        {
            type = "quest",
            id = 26810,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26811,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26812,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26813,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26814,
            x = 5,
        },
    },
})
Database:AddChain(Chain.TheTrollsOfZulgurubHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheTrollsOfZulgurubAlliance,
    },
    restrictions = 923,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {26590, 28704, 26404, 26489, 26487, 26450},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 26555,
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain01,
            aside = true,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
            x = 2,
        },
    },
})
Database:AddChain(Chain.BustlingBootyBay, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {26603, 26593, 26599, 26597, 26617},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 26613,
    },
    items = {
        {
            type = "object",
            id = 204406,
            -- name = "Find a Half-Buried Bottle along the coast",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5024, 0.7602, "Half-Buried Bottle")
            -- end,
            x = 0,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 2501,
            -- name = "Go to \"Sea Wolf\" MacKinley",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4208, 0.7338, "\"Sea Wolf\" MacKinley")
            -- end,
            x = 2,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 2500,
            -- name = "Go to Captain Hecklebury Smotts",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4032, 0.6779, "Captain Hecklebury Smotts")
            -- end,
            x = 4,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 2486,
            -- name = "Go to Fin Fizracket",
            -- breadcrumb = true,
            aside = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.4180, 0.7283, "Fin Fizracket")
            -- end,
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 26603,
            x = 0,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 26593,
            x = 2,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 26599,
            x = 4,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 26597,
            aside = true,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 26604,
            x = 0,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26594,
            x = 2,
            y = 2,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 26600,
            x = 4,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26605,
            x = 0,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26602,
            x = 4,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26606,
            x = 0,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26595,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26601,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26609,
            x = 2,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26610,
            x = 2,
            y = 6,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26617,
            aside = true,
            x = 4,
            y = 6,
        },
        {
            type = "quest",
            id = 26611,
            x = 2,
            y = 7,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 26614,
            aside = true,
            x = 0,
            y = 8,
        },
        {
            type = "quest",
            id = 26612,
            aside = true,
            x = 2,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26613,
            x = 4,
            y = 8,
        },
        {
            type = "chain",
            id = Chain.APiratesLifeForYou,
            aside = true,
            x = 2,
            y = 9,
        },
    },
})
Database:AddChain(Chain.APiratesLifeForYou, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.BustlingBootyBay,
            upto = 26612,
        },
    },
    active = {
        type = "quest",
        id = 26624,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 26665,
    },
    items = {
        {
            name = {
                type = "quest",
                id = 26612,
            },
            type = "chain",
            id = Chain.BustlingBootyBay,
            userdata = {
                scrollTo = {
                    type = "quest",
                    id = 26612,
                }
            },
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26624,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26629,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26631,
            x = 3,
            y = 4,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 26635,
            x = 1,
            y = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26633,
            x = 3,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26634,
            x = 5,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26644,
            x = 3,
            y = 6,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 26648,
            aside = true,
            x = 1,
            y = 7,
        },
        {
            type = "quest",
            id = 26647,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26649,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26650,
            x = 3,
            y = 9,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 26662,
            x = 1,
            y = 10,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26663,
            x = 3,
            y = 10,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26664,
            x = 5,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26665,
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.BloodsailAndBrashtide,
            x = 3,
            y = 12,
        },
    },
})
Database:AddChain(Chain.BloodsailAndBrashtide, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.APiratesLifeForYou,
        },
    },
    active = {
        type = "quest",
        id = 26678,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 26703,
    },
    items = {
        {
            type = "chain",
            id = Chain.APiratesLifeForYou,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26678,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26679,
            x = 3,
            y = 2,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 26695,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26698,
            x = 4,
            y = 3,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 26697,
            x = 1,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 26700,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 26699,
            x = 5,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 26703,
            x = 3,
            y = 5,
        },
    },
})
Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 26435,
    },
    items = {
        {
            type = "npc",
            id = 43096,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26590,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26434,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26592,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26435,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 26555,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28704,
                    restrictions = {
                        type = "quest",
                        id = 28704,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "quest",
                    id = 26404,
                    restrictions = {
                        type = "quest",
                        id = 26404,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "npc",
                    id = 43095,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 26489,
                    restrictions = {
                        type = "race",
                        id = BtWQuests.Constant.Race.Goblin,
                    },
                },
                {
                    type = "quest",
                    id = 26487,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26450,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26493,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26495,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26494,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26550,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26533,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26551,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26534,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26552,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26535,
            aside = true,
        },
        {
            type = "quest",
            id = 26553,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26554,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26555,
            x = -1,
        },
    },
})
Database:AddChain(Chain.OtherAlliance, {
    name = "Other Alliance",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherHorde, {
    name = "Other Horde",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherBoth, {
    name = "Other Both",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        { -- An OOX of Your Own
            type = "quest",
            id = 3721,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
		texture = 1851096,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.TheTrollsOfZulgurubAlliance,
        },
        {
            type = "chain",
            id = Chain.TheTrollsOfZulgurubHorde,
        },
        {
            type = "chain",
            id = Chain.BustlingBootyBay,
        },
        {
            type = "chain",
            id = Chain.APiratesLifeForYou,
        },
        {
            type = "chain",
            id = Chain.BloodsailAndBrashtide,
        },
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
})
