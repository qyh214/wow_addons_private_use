local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.Cataclysm;
local CATEGORY_ID = BtWQuests.Constant.Category.Cataclysm.MountHyjal;
local Chain = BtWQuests.Constant.Chain.Cataclysm.MountHyjal;
local ALLIANCE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance;
local MAP_ID = 198
local ACHIEVEMENT_ID = 4870
local CONTINENT_ID = 12

Chain.TheReturnOfTheAncients = 40101
Chain.ShrineOfGoldrinn = 40102
Chain.ForayIntoTheFirelands = 40103
Chain.GroveOfAessina = 40104
Chain.AwakeningTortolla = 40105
Chain.ShrineOfAviana = 40106
Chain.TheAncients = 40107
Chain.CavortingWithCultists = 40108
Chain.ExtinguishTheFirelord = 40109

Database:AddChain(Chain.TheReturnOfTheAncients, {
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
        ids = {25317},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25584,
    },
    items = {
        {
            type = "npc",
            id = 40289,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25317,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25472,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25319,
            aside = true,
        },
        {
            type = "quest",
            id = 25323,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25464,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25430,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25320,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25321,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25424,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25324,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25325,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25578,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25584,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ShrineOfGoldrinn, {
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
        {
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
    },
    active = {
        type = "quest",
        ids = {25255, 25233, 25234},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25312, 25298, 25332},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 39429,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 39427,
            x = 1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25255,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25233,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25234,
            aside = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25268,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25269,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25271,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25270,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 25297,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25300,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25328,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25298,
            x = -2,
        },
        {
            type = "quest",
            id = 25301,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25332,
        },
        {
            type = "quest",
            id = 25303,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25312,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ForayIntoTheFirelands, {
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
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {25278, 25277},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25353, 25355, 25611, 25612},
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 39433,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "npc",
                    id = 39432,
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25278,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25277,
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
                    id = 25353,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25355,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25352,
            aside = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    ids = {
                        25618, 25623, 
                    },
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    ids = {
                        25617, 25624, 
                    },
                },
            },
            aside = true,
            x = -2,
        },
        {
            name = "Open the Portal",
            breadcrumb = true,
            completed = {
                type = "quest",
                ids = {
                    25618, 25623, 25617, 25624, 
                },
                status = {
                    "active",
                    "completed",
                },
            },
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25575,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25576,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25577,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25599,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25600,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25611,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25612,
                },
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.GroveOfAessina, {
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
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25611,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25612,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {25385, 25404, 25382, 25381},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25382, 25392, 29066},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 39930,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 39928,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 39927,
            x = 2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 25385,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25404,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25382,
        },
        {
            type = "quest",
            id = 25381,
            aside = true,
        },
        {
            type = "quest",
            id = 25392,
            x = -3,
        },
        {
            type = "quest",
            id = 25408,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25411,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25412,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25428,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29066,
            x = -1,
        },
    },
})
Database:AddChain(Chain.AwakeningTortolla, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
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
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25611,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25612,
                },
            },
        },
        {
            type = "chain",
            id = Chain.GroveOfAessina,
        },
    },
    active = {
        type = "quest",
        ids = {25462},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25520,
    },
    items = {
        {
            type = "npc",
            id = 39932,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25462,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25490,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25492,
            aside = true,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25493,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25491,
            aside = true,
        },
        {
            type = "quest",
            id = 25502,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 25507,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25510,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25514,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25519,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25520,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ShrineOfAviana, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
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
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25611,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25612,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {25663, 25655, 25656},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25832,
    },
    items = {
        {
            type = "npc",
            id = 41005,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 41006,
            x = 1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25663,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25655,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25656,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25664,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25731,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25740,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25758,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25746,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25763,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25761,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25764,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25776,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25807,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25810,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25523,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25525,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25544,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25560,
            x = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 25832,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheAncients, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
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
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25611,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25612,
                },
            },
        },
        {
            type = "quest",
            id = 25810,
        },
        {
            type = "quest",
            id = 25520,
        },
        {
            type = "quest",
            id = 25502,
        },
        {
            type = "quest",
            id = 25491,
        },
    },
    active = {
        type = "quest",
        ids = {25830},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25653,
    },
    items = {
        {
            type = "npc",
            id = 40289,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25830,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25842,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25372,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "npc",
            id = 41507,
            aside = true,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25843,
                    restrictions = {
                        type = "quest",
                        id = 25843,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 41504,
                },
            },
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 41497,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25899,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 25881,
            aside = true,
        },
        {
            type = "quest",
            id = 25904,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25901,
            aside = true,
        },
        {
            type = "quest",
            id = 25906,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25910,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 25915,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25923,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25928,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25653,
            x = 0,
        },
    },
})
Database:AddChain(Chain.CavortingWithCultists, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 8),
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
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25611,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25612,
                },
            },
        },
        {
            type = "quest",
            id = 25810,
        },
        {
            type = "quest",
            id = 25520,
        },
        {
            type = "quest",
            id = 25502,
        },
        {
            type = "quest",
            id = 25491,
        },
        {
            type = "chain",
            id = Chain.TheAncients,
        },
    },
    active = {
        type = "quest",
        ids = {25597},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25531,
    },
    items = {
        {
            type = "npc",
            id = 40289,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25597,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25274,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25276,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25223,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25224,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25330,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25291,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25509,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25294,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25296,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25499,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25494,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25308,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 25299,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25496,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25309,
            x = -2,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25310,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25311,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25314,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25601,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25315,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25531,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ExtinguishTheFirelord, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 9),
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
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25273,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25272,
                },
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25611,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 25612,
                },
            },
        },
        {
            type = "quest",
            id = 25810,
        },
        {
            type = "quest",
            id = 25520,
        },
        {
            type = "quest",
            id = 25502,
        },
        {
            type = "quest",
            id = 25491,
        },
        {
            type = "chain",
            id = Chain.TheAncients,
        },
        {
            type = "chain",
            id = Chain.CavortingWithCultists,
        },
    },
    active = {
        type = "quest",
        ids = {25608},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25551,
    },
    items = {
        {
            type = "npc",
            id = 40772,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25608,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25548,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25554,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25644,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25549,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25555,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 25552,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25550,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25553,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25551,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
		texture = 1851126,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.TheReturnOfTheAncients,
        },
        {
            type = "chain",
            id = Chain.ShrineOfGoldrinn,
        },
        {
            type = "chain",
            id = Chain.ForayIntoTheFirelands,
        },
        {
            type = "chain",
            id = Chain.GroveOfAessina,
        },
        {
            type = "chain",
            id = Chain.AwakeningTortolla,
        },
        {
            type = "chain",
            id = Chain.ShrineOfAviana,
        },
        {
            type = "chain",
            id = Chain.TheAncients,
        },
        {
            type = "chain",
            id = Chain.CavortingWithCultists,
        },
        {
            type = "chain",
            id = Chain.ExtinguishTheFirelord,
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
