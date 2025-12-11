local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local CATEGORY_ID = BtWQuests.Constant.Category.WarlordsOfDraenor.Gorgrond;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor.Gorgrond;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 543
local ACHIEVEMENT_ID_ALLIANCE = 8923
local ACHIEVEMENT_ID_HORDE = 8924
local CONTINENT_ID = 572

Chain.WeNeedAnOutpost = 60301
Chain.SupportingYourGarrisonLumberYardAlliance = 60302
Chain.SupportingYourGarrisonSparringArenaAlliance = 60303
Chain.InTheLandOfGiantsLumberYardAlliance = 60304
Chain.InTheLandOfGiantsSparringArenaAlliance = 60305
Chain.TheIronApproachLumberYardAlliance = 60306
Chain.TheIronApproachSparringArenaAlliance = 60307

Chain.YourBaseYourChoice = 60311
Chain.SupportingYourGarrisonLumberYardHorde = 60312
Chain.SupportingYourGarrisonSparringArenaHorde = 60313
Chain.InTheLandOfGiantsLumberYardHorde = 60314
Chain.InTheLandOfGiantsSparringArenaHorde = 60315
Chain.TheIronApproachLumberYardHorde = 60316
Chain.TheIronApproachSparringArenaHorde = 60317

Database:AddChain(Chain.WeNeedAnOutpost, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.YourBaseYourChoice,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 35033,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35063,
    },
    items = {
        {
            type = "npc",
            id = 80978,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35033,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35065,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 35834,
            connections = {
                2, 3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 36595,
                    restrictions = {
                        type = "quest",
                        id = 36595,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 35828,
                },
            },
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35050,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35055,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35063,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SupportingYourGarrisonLumberYardAlliance, {
    name = L['SUPPORTING_YOUR_GARRISON_HIGHPASS_LOGGING_CAMP'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.SupportingYourGarrisonLumberYardHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.WeNeedAnOutpost,
        },
        {
            name = L["HIGHPASS_LOGGING_CAMP_BUILT"],
            type = "quest",
            id = 36249,
        },
    },
    active = {
        type = "quest",
        id = 35708,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {35654, 35651, 35650, 35652},
        count = 4,
    },
    items = {
        {
            type = "npc",
            id = 85119,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35708,
            x = 0,
            connections = {
                1, 5, 
            },
        },
        {
            type = "quest",
            id = 36368,
            x = -1,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35654,
            x = -3,
        },
        {
            type = "quest",
            id = 35651,
        },
        {
            type = "quest",
            id = 35650,
        },
        {
            type = "quest",
            id = 35652,
        },
    },
})
Database:AddChain(Chain.SupportingYourGarrisonSparringArenaAlliance, {
    name = L['SUPPORTING_YOUR_GARRISON_HIGHPASS_SPARRING_RING'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.SupportingYourGarrisonSparringArenaHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.WeNeedAnOutpost,
        },
        {
            name = L["HIGHPASS_SPARRING_RING_BUILT"],
            type = "quest",
            id = 36251,
        },
    },
    active = {
        type = "quest",
        id = 34704,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35137,
    },
    items = {
        {
            type = "npc",
            id = 81076,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34704,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 34012,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 34699,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34698,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 34700,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34702,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34703,
            x = -3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35883,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 35137,
            x = 0,
        },
    },
})
Database:AddChain(Chain.InTheLandOfGiantsLumberYardAlliance, {
    name = L['IN_THE_LAND_OF_GIANTS_HIGHPASS_LOGGING_CAMP'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.InTheLandOfGiantsLumberYardHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.WeNeedAnOutpost,
        },
        {
            name = L["HIGHPASS_LOGGING_CAMP_BUILT"],
            type = "quest",
            id = 36249,
        },
    },
    active = {
        type = "quest",
        ids = {35213, 35214, 35215, 35216},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35255,
    },
    items = {
        {
            type = "npc",
            id = 81589,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 81588,
            connections = {
                4, 
            },
        },
        {
            type = "object",
            id = 231903,
            connections = {
                4, 
            },
        },
        {
            type = "object",
            id = 235129,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35214,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 35213,
            connections = {
                3, 6, 7, 
            },
        },
        {
            type = "quest",
            id = 35215,
            connections = {
                2, 5, 6, 
            },
        },
        {
            type = "quest",
            id = 35216,
            connections = {
                1, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 35208,
            x = -2,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35205,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 36523,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35206,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35204,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35207,
            x = -2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35209,
            x = -2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35225,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35229,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35233,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35234,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35235,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35255,
            x = -1,
        },
        {
            type = "quest",
            id = 35262,
            aside = true,
        },
    },
})
Database:AddChain(Chain.InTheLandOfGiantsSparringArenaAlliance, {
    name = L['IN_THE_LAND_OF_GIANTS_HIGHPASS_SPARRING_RING'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.InTheLandOfGiantsSparringArenaHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.WeNeedAnOutpost,
        },
        {
            name = L["HIGHPASS_SPARRING_RING_BUILT"],
            type = "quest",
            id = 36251,
        },
    },
    active = {
        type = "quest",
        id = 35686,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35702,
    },
    items = {
        {
            type = "npc",
            id = 75127,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35686,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35664,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35693,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35665,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35730,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35026,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35870,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36508,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 35037,
            x = -3,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 35934,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 36208,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 36210,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35925,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36209,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 36223,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35128,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35139,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35702,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheIronApproachLumberYardAlliance, {
    name = L['THE_IRON_APPROACH_HIGHPASS_LOGGING_CAMP'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.YourBaseYourChoice,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.WeNeedAnOutpost,
        },
        {
            name = L["HIGHPASS_LOGGING_CAMP_BUILT"],
            type = "quest",
            id = 36249,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonLumberYardAlliance,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsLumberYardAlliance,
        },
    },
    active = {
        type = "quest",
        id = 36575,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 36575,
    },
    items = {
        {
            type = "npc",
            id = 75127,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36575,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheIronApproachSparringArenaAlliance, {
    name = L['THE_IRON_APPROACH_HIGHPASS_SPARRING_RING'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.TheIronApproachSparringArenaHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.WeNeedAnOutpost,
        },
        {
            name = L["HIGHPASS_SPARRING_RING_BUILT"],
            type = "quest",
            id = 36251,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonSparringArenaAlliance,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsSparringArenaAlliance,
        },
    },
    active = {
        type = "quest",
        id = 36576,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 36576,
    },
    items = {
        {
            type = "npc",
            id = 75127,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36576,
            x = 0,
        },
    },
})

Database:AddChain(Chain.YourBaseYourChoice, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.WeNeedAnOutpost,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 33543,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35151,
    },
    items = {
        {
            type = "npc",
            id = 74594,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33543,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 33544,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33548,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33563,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33593,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36434,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36460,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35151,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SupportingYourGarrisonLumberYardHorde, {
    name = L['SUPPORTING_YOUR_GARRISON_LOWLANDS_LUMBER_YARD'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    alternatives = {
        Chain.SupportingYourGarrisonLumberYardAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.YourBaseYourChoice,
        },
        {
            name = L["LOWLANDS_LUMBER_YARD_BUILT"],
            type = "quest",
            id = 36249,
        },
    },
    active = {
        type = "quest",
        id = 35707,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {35506, 35508, 35527, 35524},
        count = 4,
    },
    items = {
        {
            type = "npc",
            id = 85077,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35707,
            x = 0,
            connections = {
                1, 5, 
            },
        },
        {
            type = "quest",
            id = 35505,
            x = -1,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35508,
            x = -3,
        },
        {
            type = "quest",
            id = 35527,
        },
        {
            type = "quest",
            id = 35524,
        },
        {
            type = "quest",
            id = 35506,
        },
    },
})
Database:AddChain(Chain.SupportingYourGarrisonSparringArenaHorde, {
    name = L['SUPPORTING_YOUR_GARRISON_SAVAGE_FIGHT_CLUB'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.SupportingYourGarrisonSparringArenaAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.YourBaseYourChoice,
        },
        {
            name = L["SAVAGE_FIGHT_CLUB_BUILT"],
            type = "quest",
            id = 36251,
        },
    },
    active = {
        type = "quest",
        id = 34697,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35152,
    },
    items = {
        {
            type = "npc",
            id = 76688,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34697,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 34012,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 34699,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34700,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 34698,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34702,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34703,
            x = -3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35882,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 35152,
            x = 0,
        },
    },
})
Database:AddChain(Chain.InTheLandOfGiantsLumberYardHorde, {
    name = L['IN_THE_LAND_OF_GIANTS_LOWLANDS_LUMBER_YARD'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    alternatives = {
        Chain.InTheLandOfGiantsLumberYardAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.YourBaseYourChoice,
            x = 0,
        },
        {
            name = L["LOWLANDS_LUMBER_YARD_BUILT"],
            type = "quest",
            id = 36249,
        },
    },
    active = {
        type = "quest",
        id = 36474,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35416,
    },
    items = {
        {
            type = "npc",
            id = 74594,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36474,
            x = 0,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "object",
            id = 235129,
            x = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35400,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35399,
            connections = {
                6, 7, 
            },
        },
        {
            type = "quest",
            id = 35402,
            connections = {
                5, 6, 
            },
        },
        {
            type = "quest",
            id = 35406,
            connections = {
                4, 5, 
            },
        },
        {
            type = "quest",
            id = 35430,
            x = -2,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35487,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 36482,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35432,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 35429,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35536,
            x = -2,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35433,
            x = -1,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35434,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36488,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35509,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35507,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35501,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35510,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35416,
            x = -1,
        },
        {
            type = "quest",
            id = 35511,
            aside = true,
        },
    },
})
Database:AddChain(Chain.InTheLandOfGiantsSparringArenaHorde, {
    name = L['IN_THE_LAND_OF_GIANTS_SAVAGE_FIGHT_CLUB'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.InTheLandOfGiantsSparringArenaAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.YourBaseYourChoice,
        },
        {
            name = L["SAVAGE_FIGHT_CLUB_BUILT"],
            type = "quest",
            id = 36251,
        },
    },
    active = {
        type = "quest",
        id = 35880,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35136,
    },
    items = {
        {
            type = "npc",
            id = 74594,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35880,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35248,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35035,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35025,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35730,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35026,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35870,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35036,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 35037,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35934,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35202,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35038,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35925,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35041,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35128,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35129,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35247,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 35139,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36832,
            aside = true,
        },
        {
            type = "quest",
            id = 35136,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheIronApproachLumberYardHorde, {
    name = L['THE_IRON_APPROACH_LOWLANDS_LUMBER_YARD'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    major = true,
    alternatives = {
        Chain.TheIronApproachLumberYardAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.YourBaseYourChoice,
        },
        {
            name = L["LOWLANDS_LUMBER_YARD_BUILT"],
            type = "quest",
            id = 36249,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonLumberYardHorde,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsLumberYardHorde,
        },
    },
    active = {
        type = "quest",
        id = 36574,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 36574,
    },
    items = {
        {
            type = "npc",
            id = 74594,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36574,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheIronApproachSparringArenaHorde, {
    name = L['THE_IRON_APPROACH_SAVAGE_FIGHT_CLUB'],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {15, 60},
    alternatives = {
        Chain.TheIronApproachSparringArenaAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.YourBaseYourChoice,
        },
        {
            name = L["SAVAGE_FIGHT_CLUB_BUILT"],
            type = "quest",
            id = 36251,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonSparringArenaHorde,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsSparringArenaHorde,
        },
    },
    active = {
        type = "quest",
        id = 36573,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 36573,
    },
    items = {
        {
            type = "npc",
            id = 74594,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36573,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.WeNeedAnOutpost,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonLumberYardAlliance,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonSparringArenaAlliance,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsLumberYardAlliance,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsSparringArenaAlliance,
        },
        {
            type = "chain",
            id = Chain.TheIronApproachLumberYardAlliance,
        },
        {
            type = "chain",
            id = Chain.TheIronApproachSparringArenaAlliance,
        },

        {
            type = "chain",
            id = Chain.YourBaseYourChoice,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonLumberYardHorde,
        },
        {
            type = "chain",
            id = Chain.SupportingYourGarrisonSparringArenaHorde,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsLumberYardHorde,
        },
        {
            type = "chain",
            id = Chain.InTheLandOfGiantsSparringArenaHorde,
        },
        {
            type = "chain",
            id = Chain.TheIronApproachLumberYardHorde,
        },
        {
            type = "chain",
            id = Chain.TheIronApproachSparringArenaHorde,
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