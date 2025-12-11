local MAP_ID = 78
local ACHIEVEMENT_ID = 4939
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_THE_PYLONS_OF_UNGORO, {
    name = {
        type = "achievement",
        id = 4939,
        criteria = 1,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24720,
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN3,
        },
        {
            type = "quest",
            id = 24720,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN1,
            x = 0,
            y = 0,
            connections = {
                4, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN2,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24720,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = 13802,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_OBSERVE_THE_WORLD, {
    name = {
        type = "achievement",
        id = 4939,
        criteria = 2,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_THE_PYLONS_OF_UNGORO,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_THE_PYLONS_OF_UNGORO,
    },
    completed = {
        type = "quest",
        id = 24695,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_THE_PYLONS_OF_UNGORO,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 24694,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 24695,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_THE_BALLAD_OF_MAXIMILLIAN, {
    name = {
        type = "achievement",
        id = 4939,
        criteria = 3,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24703,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24707,
    },
    items = {
        {
            type = "quest",
            id = 24703,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24704,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24705,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24706,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24707,
            x = 3,
            connections = {
                
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN1, {
    name = { -- The Northern Pylon
        type = "quest",
        id = 24722,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24742,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24723,
    },
    items = {
        {
            type = "npc",
            id = 10302,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24742,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24794,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24734,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24735,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24692,
            x = 2,
        },
        {
            type = "quest",
            id = 24691,
            connections = {
                2, 
            },
        },
        
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN9,
            x = 0,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 24693,
            x = 4,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 24701,
            x = 2,
            connections = {
                4, 5, 
            },
        },
        {
            type = "quest",
            id = 24737,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 24700,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 24699,
            x = 4,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24714,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 24717,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 24718,
        },
        {
            type = "quest",
            id = 24715,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24722,
        },
        {
            type = "quest",
            id = 24926,
            x = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN2, {
    name = { -- The Eastern Pylon
        type = "quest",
        id = 24721,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {24854, 24719},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24721,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN5,
            x = 1,
            y = 0,
            embed = true,
            aside = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 24854,
                    restrictions = {
                        type = "quest",
                        id = 24854,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38274,
                },
            },
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN6,
            x = 5,
            y = 0,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 24719,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24686,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24689,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN7,
            x = 1,
            y = 4,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 24687,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 24855,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24721,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN3, {
    name = { -- The Western Pylon
        type = "quest",
        id = 24723,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {24698, 24730},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24723,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 24698,
                    restrictions = {
                        type = "quest",
                        id = 24698,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 9272,
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
            id = 24730,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24708,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24709,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24723,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN4, {
    name = "Marshal's Stand",
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {24911, 28525, 28526, 24697, 24740},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24690,
    },
    items = {
        {
            type = "npc",
            id = 38270,
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
                    id = 24911,
                    restrictions = {
                        type = "quest",
                        id = 24911,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28525,
                    restrictions = {
                        type = "quest",
                        id = 28525,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28526,
                    restrictions = {
                        type = "quest",
                        id = 28526,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 9270,
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
            id = 24697,
            x = 1,
        },
        {
            type = "quest",
            id = 24740,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24690,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN5, {
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24742,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 13906,
    },
    items = {
        {
            type = "npc",
            id = 11701,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13850,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13887,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13906,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN6, {
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24731,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24733,
    },
    items = {
        {
            type = "npc",
            id = 9619,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24731,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24732,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24733,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN7, {
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24865,
        status = {'active'},
    },
    completed = {
        type = "quest",
        id = 24865,
    },
    items = {
        {
            type = "object",
            id = 161526,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24865,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN8, {
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24866,
        status = {'active'},
    },
    completed = {
        type = "quest",
        id = 24723,
    },
    items = {
        {
            type = "object",
            id = 161521,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24866,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN9, {
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 24736,
        status = {'active'},
    },
    completed = {
        type = "quest",
        id = 24736,
    },
    items = {
        {
            type = "npc",
            id = 9998,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24736,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 13903,
        },
        {
            type = "quest",
            id = 13904,
        },
        {
            type = "quest",
            id = 13905,
        },
        {
            type = "quest",
            id = 13889,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 24724,
        },
        {
            type = "quest",
            id = 24725,
        },
        {
            type = "quest",
            id = 24726,
        },
        {
            type = "quest",
            id = 24727,
        },
        {
            type = "quest",
            id = 24728,
        },
        {
            type = "quest",
            id = 24729,
        },
        {
            type = "quest",
            id = 24702,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851111,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_THE_PYLONS_OF_UNGORO,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_OBSERVE_THE_WORLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_THE_BALLAD_OF_MAXIMILLIAN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_UNGORO_CRATER_CHAIN4,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_UNGORO_CRATER,
})
