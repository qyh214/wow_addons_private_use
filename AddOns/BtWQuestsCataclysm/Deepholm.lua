local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.Cataclysm;
local CATEGORY_ID = BtWQuests.Constant.Category.Cataclysm.Deepholm;
local Chain = BtWQuests.Constant.Chain.Cataclysm.Deepholm;
local MAP_ID = 207
local ACHIEVEMENT_ID = 4871
local CONTINENT_ID = 948

Chain.TheMiddleWorldPillarFragment = 40301
Chain.TheUpperWorldPillarFragment = 40302
Chain.TheStoneLords = 40303
Chain.MendingTheWound = 40304

Database:AddChain(Chain.TheMiddleWorldPillarFragment, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {26409},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 27938,
    },
    items = {
        {
            type = "npc",
            id = 42573,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26409,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26410,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27135,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26411,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26413,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26484,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27931,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 27932,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 27933,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27934,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                27935, 27936, 
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26499,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26500,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26501,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 26502,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 26537,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26591,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26564,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26625,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27126,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26632,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26755,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26762,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26770,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26834,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26791,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26792,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26835,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26836,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27937,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27938,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheUpperWorldPillarFragment, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {26245, 26244, 27136, 26246},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {26427, 26251, 26259, 26876},
        count = 4,
    },
    items = {
        {
            type = "npc",
            id = 43065,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 43397,
            x = 0,
            connections = {
                3, 4, 
            },
        },
        {
            type = "object",
            id = 204274,
            x = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 26245,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 26244,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 27136,
            aside = true,
        },
        {
            type = "quest",
            id = 26246,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26247,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26248,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 26249,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26251,
            x = -2,
        },
        {
            type = "quest",
            id = 26250,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26427,
        },
        {
            type = "quest",
            id = 26254,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26255,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26258,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26259,
        },
        {
            type = "quest",
            id = 26256,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26261,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26260,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27007,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27010,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 27061,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26768,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26766,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26771,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26857,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26861,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26876,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheStoneLords, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 27938,
        },
        {
            type = "quest",
            id = 26876,
        },
    },
    active = {
        type = "quest",
        ids = {26326},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {26437, 26438, 26659, 26578, 26579, 26583, 26584, 26585},
        count = 8,
    },
    items = {
        {
            type = "npc",
            id = 43065,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26326,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26312,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26313,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26314,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26315,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26328,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26376,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26377,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26375,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26426,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26869,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26871,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26436,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26437,
            x = -2,
        },
        {
            type = "quest",
            id = 26439,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26438,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28869,
                    restrictions = {
                        type = "quest",
                        id = 28869,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 43116,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26440,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26441,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26507,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 26575,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 26576,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26577,
            x = 2,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 26656,
            x = -3,
            connections = {
                4, 5, 
            },
        },
        {
            type = "quest",
            id = 26578,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 26580,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 26579,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 26657,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 26658,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26581,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26582,
            x = 1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 26659,
            x = -3,
        },
        {
            type = "quest",
            id = 26584,
        },
        {
            type = "quest",
            id = 26585,
        },
        {
            type = "quest",
            id = 26583,
        },
    },
})
Database:AddChain(Chain.MendingTheWound, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 27938,
        },
        {
            type = "quest",
            id = 26876,
        },
        {
            type = "quest",
            id = 26659,
        },
        {
            type = "quest",
            id = 26584,
        },
        {
            type = "quest",
            id = 26585,
        },
    },
    active = {
        type = "quest",
        ids = {26750},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 26971,
    },
    items = {
        {
            type = "npc",
            id = 42472,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 42466,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26750,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26752,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26827,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26828,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 26829,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 26831,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 26832,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26833,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26875,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 26971,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
		texture = 1851123,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.TheMiddleWorldPillarFragment,
        },
        {
            type = "chain",
            id = Chain.TheUpperWorldPillarFragment,
        },
        {
            type = "chain",
            id = Chain.TheStoneLords,
        },
        {
            type = "chain",
            id = Chain.MendingTheWound,
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

Database:AddContinentItems(CONTINENT_ID, {
})
