local L = BtWQuests.L;
local MAP_ID = 905
local MACAREE_MAP_ID = 882
local ANTORAN_MAP_ID = 885
local KROKUUN_MAP_ID = 830

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARGUS_THE_ASSAULT_BEGINS, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(12066, 1),
    category = BTWQUESTS_CATEGORY_LEGION_ARGUS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            upto = 46734,
        },
    },
    active = {
        type = "quest",
        id = 46268,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 48929,
    },
    items = {
        {
            type = "npc",
            id = 120215,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46734,
            x = 3,
            y = 1,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 47221,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47835,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47222,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
            x = 3,
            y = 3,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47867,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47223,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47224,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 48440,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46938,
            x = 3,
            y = 7,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 47589,
            x = 1,
            y = 8,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 46297,
            x = 3,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48483,
            x = 5,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47627,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47641,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46732,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46816,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46839,
            x = 3,
            y = 13,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 46840,
            x = 2,
            y = 14,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46841,
            x = 4,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46842,
            x = 3,
            y = 15,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46843,
            x = 3,
            y = 16,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 48500,
            x = 3,
            y = 17,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47431,
            x = 3,
            y = 18,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 46213,
            x = 1,
            y = 19,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 40238,
            x = 3,
            y = 19,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47541,
            x = 5,
            y = 19,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47508,
            x = 3,
            y = 20,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47771,
            x = 3,
            y = 21,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47526,
            x = 3,
            y = 22,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47754,
            x = 3,
            y = 23,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47653,
            x = 3,
            y = 24,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 47743,
            x = 3,
            y = 25,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 49143,
            x = 3,
            y = 26,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47287,
            aside = true,
            x = 5,
            y = 26,
        },
        {
            type = "quest",
            id = 48559,
            x = 3,
            y = 27,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 48199,
            x = 3,
            y = 28,
            connections = {
                1, 2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_WRANGLERS,
            aside = true,
            x = 1,
            y = 29,
        },
        {
            type = "quest",
            id = 48200,
            x = 3,
            y = 29,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 48201,
            breadcrumb = true,
            x = 2,
            y = 30,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48202,
            breadcrumb = true,
            x = 4,
            y = 30,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47473,
            x = 2,
            y = 31,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48929,
            x = 4,
            y = 31,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_DARK_AWAKENINGS,
            x = 3,
            y = 32,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARGUS_DARK_AWAKENINGS, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(12066, 2),
    category = BTWQUESTS_CATEGORY_LEGION_ARGUS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            upto = 46734,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_THE_ASSAULT_BEGINS,
        },
    },
    active = {
        type = "quest",
        id = 47889,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 48107,
    },
    items = {
        {
            type = "npc",
            id = 124312,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47889,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47890,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47891,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47892,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 47986,
            x = 1,
            y = 5,
            connections = {
                5
            },
        },
        {
            type = "quest",
            id = 47987,
            x = 3,
            y = 5,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 47988,
            x = 5,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47991,
            x = 1,
            y = 6,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 47990,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47989,
            x = 5,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47992,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        
        
        
        
        {
            type = "quest",
            id = 47993,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47994,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 48081,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46815,
            x = 3,
            y = 11,
            connections = {
                1, 2
            },
        },
        
        
        
        
        {
            type = "quest",
            id = 46818,
            x = 2,
            y = 12,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 46834,
            x = 4,
            y = 12,
            connections = {
                1
            },
        },
        
        
        
        {
            type = "quest",
            id = 47066,
            x = 3,
            y = 13,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46941,
            x = 3,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47686,
            x = 3,
            y = 15,
            connections = {
                1, 2
            },
        },
        
        
        {
            type = "quest",
            id = 47882,
            x = 2,
            y = 16,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47688,
            x = 4,
            y = 16,
            connections = {
                1
            },
        },
        
        
        {
            type = "quest",
            id = 47883,
            x = 3,
            y = 17,
            connections = {
                1, 2, 3
            },
        },
        
        
        
        {
            type = "quest",
            id = 47689,
            x = 1,
            y = 18,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 47685,
            x = 3,
            y = 18,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47687,
            x = 5,
            y = 18,
            connections = {
                1
            },
        },
        
        
        
        {
            type = "quest",
            id = 47690,
            x = 3,
            y = 19,
            connections = {
                1
            },
        },
        
        
        
        {
            type = "quest",
            id = 48107,
            x = 3,
            y = 20,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 48461,
            x = 3,
            y = 21,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_WAR_OF_LIGHT_AND_SHADOW,
            x = 3,
            y = 22,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARGUS_WAR_OF_LIGHT_AND_SHADOW, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(12066, 3),
    category = BTWQUESTS_CATEGORY_LEGION_ARGUS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            upto = 46734,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_THE_ASSAULT_BEGINS,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_DARK_AWAKENINGS,
            upto = 48461,
        },
    },
    active = {
        type = "quest",
        id = 48461,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 47220,
    },
    items = {
        {
            type = "npc",
            id = 126408,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 48461,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        
        
        
        {
            type = "quest",
            id = 48344,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 47691,
            x = 1,
            y = 3,
            connections = {
                3, 4
            },
        },
        {
            type = "quest",
            id = 47854,
            x = 3,
            y = 3,
            connections = {
                2, 3
            },
        },
        {
            type = "quest",
            id = 47995,
            x = 5,
            y = 3,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 47853,
            x = 2,
            y = 4,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48345,
            x = 4,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47855,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47856,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47416,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47238,
            x = 3,
            y = 8,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 40761,
            x = 2,
            y = 9,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 47101,
            x = 4,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47180,
            x = 2,
            y = 10,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47100,
            x = 4,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47183,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47184,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47203,
            x = 3,
            y = 13,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 47217,
            x = 2,
            y = 14,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 47218,
            x = 4,
            y = 14,
            connections = {
                1
            },
        },
        
        {
            type = "quest",
            id = 47219,
            x = 3,
            y = 15,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 47220,
            x = 3,
            y = 16,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 48560,
            x = 2,
            y = 17,
        },
        {
            type = "quest",
            id = 47654,
            x = 4,
            y = 17,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARGUS_WRANGLERS, {
    name = { -- The Wranglers
        type = "quest",
        id = 48460,
    },
    category = BTWQUESTS_CATEGORY_LEGION_ARGUS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            upto = 46734,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_THE_ASSAULT_BEGINS,
            upto = 48199,
        },
    },
    active = {
        type = "quest",
        ids = {48460, 48453, 48542, 48455},
        status = {'active', 'completed'}
    },  
    completed = {
        type = "quest",
        id = 48601,
    },
    items = {
        {
            type = "npc",
            id = 48460,
            x = 3,
            y = 0,
            connections = {
                2,
            },
        },
        {
            name = L["KILL_EREDAR"],
            breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 48453,
                    active = false,
                },
            },
            x = 1,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48460,
            breadcrumb = true,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 48453,
                    restrictions = {
                        {
                            type = "quest",
                            id = 48453,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 48542,
                },
            },
            x = 1,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47967,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48455,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48544,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48441,
            x = 3,
            y = 4,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 48442,
            x = 2,
            y = 5,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 48910,
            aside = true,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48634,
            aside = true,
            x = 5,
            y = 6,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_WAR_OF_LIGHT_AND_SHADOW,
            x = 1,
            y = 6.5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48443,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48445,
            x = 3,
            y = 7,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 48654,
            aside = true,
            x = 2,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48446,
            x = 4,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48911,
            aside = true,
            x = 2,
            y = 9,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48447,
            x = 4,
            y = 9,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48635,
            aside = true,
            x = 1,
            y = 10,
        },
        {
            type = "quest",
            id = 48448,
            x = 3,
            y = 10,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 48600,
            x = 2,
            y = 11,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48912,
            aside = true,
            x = 4,
            y = 11,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 48601,
            x = 3,
            y = 12,
        },
        {
            type = "quest",
            id = 48636,
            aside = true,
            x = 5,
            y = 12,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_ARGUS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_LEGION,
    buttonImage = 1718211,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_THE_ASSAULT_BEGINS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_DARK_AWAKENINGS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_WAR_OF_LIGHT_AND_SHADOW,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARGUS_WRANGLERS,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_ARGUS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_ARGUS,
})

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_ARGUS_THE_ASSAULT_BEGINS)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_ARGUS_DARK_AWAKENINGS)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_ARGUS_WAR_OF_LIGHT_AND_SHADOW)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_ARGUS_WRANGLERS)
