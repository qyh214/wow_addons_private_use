if select(4, GetBuildInfo()) < 110100  then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin.Undermined
local CATEGORY_ID = BtWQuests.Constant.Category.TheWarWithin.Undermined
local ACHIEVEMENT_ID_1 = 40900
local ACHIEVEMENT_ID_2 = 40894
local MAP_ID = 2346
local LEVEL_RANGE = {50, 50}

Chain.TrustIssues = 110601
Chain.UndermineAwaits = 110602
Chain.UncoveringTheTruth = 110603
Chain.BreakingTheShackles = 110604
Chain.IgniteTheFuelOfChange = 110605
Chain.Homecoming = 110606

Chain.TheHighst = 110611
Chain.Fore = 110612
Chain.HazardsOfSlimediving = 110613
Chain.OhRats = 110614
Chain.ThePerfectWedding = 110615
Chain.CopyrightInfringement = 110616
Chain.TheGOLEMOfProgress = 110617
Chain.TheVerdigreaseKnight = 110618
Chain.HardWaysAtTheGallagio = 110619
Chain.PropertyDevalued = 110620
Chain.GETA = 110621
Chain.KajaCuriosity = 110622
Chain.SanitysRest = 110623

Database:AddChain(Chain.TrustIssues, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 5617,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            }
        },
    },
    active = {
        type = "quest",
        id = 83137,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 83151,
    },
    items = {
        {
            type = "npc",
            id = 225571,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83137,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83139,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 83140,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 83141,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83142,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83143,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83144,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84683,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83145,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 85409,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83146,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83147,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 85444,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83148,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83149,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83150,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85410,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83151,
            x = 0,
        },
    }
})
Database:AddChain(Chain.UndermineAwaits, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 5661,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
        },
    },
    active = {
        type = "quest",
        id = 83096,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 83176,
    },
    items = {
        {
            type = "npc",
            id = 225500,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83096,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83109,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 86297,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 85941,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83163,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83167,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83168,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83169,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83170,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83171,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83172,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 83173,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 83174,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83175,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83176,
            x = 0,
        },
    }
})
Database:AddChain(Chain.UncoveringTheTruth, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 5614,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
        },
    },
    active = {
        type = "quest",
        id = 83114,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 83125,
    },
    items = {
        {
            type = "npc",
            id = 229236,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83114,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83115,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83116,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83117,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83118,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83119,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83120,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83933,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84121,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 84122,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 83121,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 83122,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83123,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83124,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83125,
            x = 0,
        },
    }
})
Database:AddChain(Chain.BreakingTheShackles, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 4),
    questline = 5615,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
        },
    },
    active = {
        type = "quest",
        ids = { 83126, 85449 },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 83130,
    },
    items = {
        {
            type = "npc",
            id = 225669,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83126,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 85449,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85450,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83127,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83128,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83129,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83130,
            x = 0,
        },
    }
})
Database:AddChain(Chain.IgniteTheFuelOfChange, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 5),
    questline = 5668,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
        },
    },
    active = {
        type = "quest",
        id = 83138,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85780,
    },
    items = {
        {
            type = "npc",
            id = 225756,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83138,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83194,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85174,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83195,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83196,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83197,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83198,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83199,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83200,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 85562,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 85724,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83201,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83202,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 83203,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83204,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83205,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86417,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83206,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83207,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85780,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Homecoming, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 6),
    questline = 5694,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IgniteTheFuelOfChange,
        },
    },
    active = {
        type = "quest",
        id = 86204,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 87297,
    },
    items = {
        {
            type = "npc",
            id = 233482,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86204,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 87321,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85190,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85191,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85192,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 87297,
            x = 0,
        },
    }
})

Database:AddChain(Chain.TheHighst, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    questline = 5663,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        ids = { 84214, 84215, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 84218,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 84214,
                    restrictions = {
                        type = "quest",
                        id = 84214,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 228286,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84215,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84216,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84218,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Fore, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    questline = 5662,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits, -- Or Renown 3
        },
    },
    active = {
        type = "quest",
        id = 84140,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 84142,
    },
    items = {
        {
            type = "npc",
            id = 228158,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84140,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84141,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84142,
            x = 0,
        },
    }
})
Database:AddChain(Chain.HazardsOfSlimediving, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    questline = 5659,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
        },
    },
    active = {
        type = "quest",
        ids = { 83088, 83089, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 83091,
    },
    items = {
        {
            type = "npc",
            id = 225481,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83088,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83089,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83091,
            x = 0,
        },
    }
})
Database:AddChain(Chain.OhRats, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    questline = 5631,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
        },
    },
    active = {
        type = "quest",
        id = 83484,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85711,
    },
    items = {
        {
            type = "npc",
            id = 226728,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83484,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83485,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83487,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85711,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ThePerfectWedding, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    questline = 5642,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits, -- Or Renown 3
        },
    },
    active = {
        type = "quest",
        id = 85438,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 87008,
    },
    items = {
        {
            type = "npc",
            id = 233235,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85438,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83417,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83419,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83418,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83420,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83421,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 87008,
            x = 0,
        },
    }
})
Database:AddChain(Chain.CopyrightInfringement, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    questline = 5660,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits, -- Or Renown 3
        },
    },
    active = {
        type = "quest",
        id = 83442,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 83446,
    },
    items = {
        {
            type = "npc",
            id = 226569,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83442,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83445,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83446,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheGOLEMOfProgress, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    questline = 5741,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
        },
    },
    active = {
        type = "quest",
        ids = { 84667, 84672, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 84675,
    },
    items = {
        {
            type = "npc",
            id = 230554,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 230555,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84667,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84672,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84673,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84674,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84675,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheVerdigreaseKnight, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    questline = 5678,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 79559,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 79563,
    },
    items = {
        {
            type = "npc",
            id = 230841,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79559,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84621,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79561,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 84821,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 80144,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 80096,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79564,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79563,
            x = 0,
        },
    }
})
Database:AddChain(Chain.HardWaysAtTheGallagio, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    questline = 5641,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IgniteTheFuelOfChange,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Homecoming,
        },
    },
    active = {
        type = "quest",
        id = 83519,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 83566,
    },
    items = {
        {
            type = "npc",
            id = 226273,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83519,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83569,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84221,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84242,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83522,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83524,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 83527,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 83528,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84249,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83540,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83541,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83542,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84244,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83534,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83535,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 85189,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83546,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83558,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83563,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83566,
            x = 0,
        },
    }
})
Database:AddChain(Chain.PropertyDevalued, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    questline = 5685,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 84376,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86408,
    },
    items = {
        {
            type = "object",
            id = 461478,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84376,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 84379,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 84378,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84380,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86408,
            x = 0,
        },
    }
})
Database:AddChain(Chain.GETA, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 11),
    questline = 5686,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
        },
    },
    active = {
        type = "quest",
        id = 84885,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 84891, 84892, 84893, },
        count = 3,
    },
    items = {
        {
            type = "object",
            id = 456747,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84885,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84891,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84892,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84893,
            x = 0,
        },
    }
})
Database:AddChain(Chain.KajaCuriosity, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 12),
    questline = 5669,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TrustIssues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
        },
    },
    active = {
        type = "quest",
        id = 84298,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 84439,
    },
    items = {
        {
            type = "object",
            id = 456747,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84298,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84300,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84301,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84302,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 84303,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 84304,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 84439,
            x = 0,
        },
    }
})
Database:AddChain(Chain.SanitysRest, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 13),
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    questline = 5736,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 86271,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 86277, 86276, 86697, },
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 233420,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86271,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86272,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86273,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 86274,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 86275,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 86575,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 86276,
            x = -2,
        },
        {
            type = "quest",
            id = 86277,
        },
        {
            type = "quest",
            id = 86697,
        },
    }
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 6422411,
    items = {
        {
            type = "chain",
            id = Chain.TrustIssues,
        },
        {
            type = "chain",
            id = Chain.UndermineAwaits,
        },
        {
            type = "chain",
            id = Chain.UncoveringTheTruth,
        },
        {
            type = "chain",
            id = Chain.BreakingTheShackles,
        },
        {
            type = "chain",
            id = Chain.IgniteTheFuelOfChange,
        },
        {
            type = "chain",
            id = Chain.Homecoming,
        },
        {
            type = "chain",
            id = Chain.TheHighst,
        },
        {
            type = "chain",
            id = Chain.Fore,
        },
        {
            type = "chain",
            id = Chain.HazardsOfSlimediving,
        },
        {
            type = "chain",
            id = Chain.OhRats,
        },
        {
            type = "chain",
            id = Chain.ThePerfectWedding,
        },
        {
            type = "chain",
            id = Chain.CopyrightInfringement,
        },
        {
            type = "chain",
            id = Chain.TheGOLEMOfProgress,
        },
        {
            type = "chain",
            id = Chain.TheVerdigreaseKnight,
        },
        {
            type = "chain",
            id = Chain.HardWaysAtTheGallagio,
        },
        {
            type = "chain",
            id = Chain.PropertyDevalued,
        },
        {
            type = "chain",
            id = Chain.GETA,
        },
        {
            type = "chain",
            id = Chain.KajaCuriosity,
        },
        {
            type = "chain",
            id = Chain.SanitysRest,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "category",
        id = CATEGORY_ID,
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
}, true, true)

BtWQuestsDatabase:AddQuestItemsForChain(Chain.TrustIssues)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.UndermineAwaits)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.UncoveringTheTruth)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.BreakingTheShackles)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.IgniteTheFuelOfChange)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.Homecoming)
