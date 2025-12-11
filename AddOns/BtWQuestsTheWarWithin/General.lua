local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local Category = BtWQuests.Constant.Category.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.TheWarWithinToF
local ACHIEVEMENT_ID = 20597
local LEVEL_RANGE = {68, 80}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 68,
    },
}

Chain.Introduction = 110001
Chain.AgainstTheCurrent = 110002
Chain.TiesThatBind = 110003
Chain.NewsFromBelow = 110004
Chain.TheMachinesMarchToWar = 110005
Chain.Chapter05 = 110006
Chain.ToKillAQueen = 110007

Database:AddChain(Chain.Introduction, {
    name = BtWQuests.L["Introduction"],
    questline = 5638,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 81930, 78713 },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = { 83543, 78529, }
    },
    items = {
        {
            variations = {
                {
                    type = "area",
                    id = 1519,
                    locations = {
                        [84] = {
                            {
                                x = 0.629261,
                                y = 0.7229,
                            },
                        },
                    },
                    restrictions = 924,
                },
                {
                    type = "area",
                    id = 1637,
                    locations = {
                        [85] = {
                            {
                                x = 0.508051,
                                y = 0.780649,
                            },
                        },
                    },
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
                    id = 81930,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 78713,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78714,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78715,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78716,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80500,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81966,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78717,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 78719,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 78721,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78718,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78722,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79105,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79106,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80321,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 78529,
                    restrictions = {
                        type = "quest",
                        id = 78529,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "quest",
                    id = 83543,
                    restrictions = THREADS_OF_FATE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 78529,
                }
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.AgainstTheCurrent, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = 5551,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 78,
        },
        {
            type = "quest",
            id = 78248,
            status = {'active', 'completed'},
        }
    },
    active = {
        type = "quest",
        id = 79333,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 79344,
    },
    items = {
        {
            type = "npc",
            id = 219252,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79197,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79333,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 79328,
                    restrictions = 923,
                },
                {
                    type = "quest",
                    id = 82153,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83271,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83286,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83315,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79344,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TiesThatBind, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    questline = 5523,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 78,
        },
        {
            type = "quest",
            id = 78248,
            status = {'active', 'completed'},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AgainstTheCurrent,
        }
    },
    active = {
        type = "quest",
        id = 79107,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 79157,
    },
    items = {
        {
            type = "npc",
            id = 223944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79107,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81914,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79124,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79475,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79476,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79129,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79146,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79140,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79145,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81915,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79477,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79147,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81912,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 81913,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79480,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79156,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79157,
            x = 0,
        },
    },
})
Database:AddChain(Chain.NewsFromBelow, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = 5544,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 78,
        },
        {
            type = "quest",
            id = 78248,
            status = {'active', 'completed'},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AgainstTheCurrent,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TiesThatBind,
        }
    },
    active = {
        type = "quest",
        id = 79224,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 79244,
    },
    items = {
        {
            type = "npc",
            id = 223944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79224,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79227,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79230,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79233,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79239,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79240,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79241,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79243,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79244,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheMachinesMarchToWar, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = 5531,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 78,
        },
        {
            type = "quest",
            id = 78248,
            status = {'active', 'completed'},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AgainstTheCurrent,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TiesThatBind,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.NewsFromBelow,
        }
    },
    active = {
        type = "quest",
        id = 79022,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 79030,
    },
    items = {
        {
            type = "npc",
            id = 223944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79022,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79023,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79024,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79025,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79324,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 79026,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 79027,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79325,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79028,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80145,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80517,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79029,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79030,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chapter05, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 5550,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 78,
        },
        {
            type = "quest",
            id = 78248,
            status = {'active', 'completed'},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AgainstTheCurrent,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TiesThatBind,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.NewsFromBelow,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheMachinesMarchToWar,
        }
    },
    active = {
        type = "quest",
        id = 78941,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 83503,
    },
    items = {
        {
            type = "npc",
            id = 223944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78941,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78942,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 78943,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78950,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78948,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83503,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ToKillAQueen, {
    name = { -- To Kill a Queen
        type = "quest",
        id = 82141,
    },
    buttonImage = 5912550,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 78,
        },
    },
    active = {
        type = "quest",
        id = 83587,
    },
    completed = {
        type = "quest",
        id = 82141,
    },
    items = {
        {
            type = "npc",
            id = 227217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 83587,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82124,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82125,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 82126,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 82127,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82130,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82141,
            x = 0,
        },
    },
})
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded;
if not IsAddOnLoaded("BtWQuestsTheWarWithinPrologue") then
    BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
        {
            type = "chain",
            id = Chain.Introduction,
        },
    })
end
BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.AgainstTheCurrent,
    },
    {
        type = "chain",
        id = Chain.TiesThatBind,
    },
    {
        type = "chain",
        id = Chain.NewsFromBelow,
    },
    {
        type = "chain",
        id = Chain.TheMachinesMarchToWar,
    },
    {
        type = "chain",
        id = Chain.Chapter05,
    },
    {
        type = "chain",
        id = Chain.ToKillAQueen,
    },
})

BtWQuestsDatabase:AddQuestItemsForChain(Chain.Introduction)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AgainstTheCurrent)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TiesThatBind)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.NewsFromBelow)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheMachinesMarchToWar)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.Chapter05)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ToKillAQueen)
