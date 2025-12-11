local L = BtWQuests.L;
local ACHIEVEMENT_TOOL_ID = 13516

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_ALCHEMY, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 1),
    -- name = { -- A Recipe for Success
    --     type = "quest",
    --     id = 50129,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2478,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {50121, 50112},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {50129, 50120},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50121,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50112,
                },
            },
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50122,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50113,
                },
            },
            x = 2,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50124,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50115,
                },
            },
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50125,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50116,
                },
            },
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50126,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50117,
                },
            },
            x = 2,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50127,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50118,
                },
            },
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50128,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50119,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50129,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50120,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_BLACKSMITHING, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 2),
    -- name = { -- Anvil's Away
    --     type = "quest",
    --     id = 50279,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {110,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2437,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {50123, 50276},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {50275, 50279},
    },
    rewards = {
        {
            type = "money",
            amounts = {
                4700, 16805, 28905, 41010, 53110, 65215, 77315, 89420, 101520, 113625, 125725, 137830, 149930, 162035, 174135, 186240, 198340, 210445, 222545, 234650, 246750, 261980, 277205, 292435, 307660, 322890, 338120, 353345, 368575, 383800, 399030, 414260, 429485, 444715, 459940, 475170, 490115, 505060, 520010, 534955, 549900, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                3340, 3690, 4030, 4290, 4640, 4985, 5330, 5600, 5935, 6280, 6550, 6895, 7230, 7500, 7845, 8180, 8550, 8795, 9130, 9500, 9775, 10075, 10450, 10725, 11025, 11400, 11775, 11975, 12350, 12725, 12925, 13300, 13675, 13875, 14250, 14625, 14925, 15200, 15575, 15875, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50123,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50276,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50114,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50277,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50270,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50278,
                },
            },
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 50271,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50272,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50274,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50288,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50275,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 50279,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_ENCHANTING, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 3),
    -- name = { -- What the Drust Knew
    --     type = "quest",
    --     id = 54161,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {110,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2486,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {54005, 54161},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 54002,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                12400, 44330, 76260, 108190, 140120, 172050, 203980, 235910, 267840, 299770, 331700, 363630, 395560, 427490, 459420, 491350, 523280, 555210, 587140, 619070, 651000, 691180, 731350, 771530, 811700, 851880, 892060, 932230, 972410, 1012580, 1052760, 1092940, 1133110, 1173290, 1213460, 1253640, 1293070, 1332500, 1371940, 1411370, 1450800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                7710, 8550, 9320, 9960, 10750, 11520, 12360, 12950, 13720, 14560, 15150, 15990, 16760, 17350, 18190, 18960, 19750, 20390, 21160, 22000, 22600, 23350, 24200, 24800, 25550, 26400, 27200, 27800, 28600, 29400, 30000, 30800, 31600, 32200, 33000, 33850, 34600, 35200, 36050, 36800, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 54005,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 54161,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 53993,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 55635,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53996,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53997,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53998,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53999,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54000,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54001,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 54002,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_ENGINEERING, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 4),
    -- name = { -- The Ub3r-Spanner
    --     type = "quest",
    --     id = 53949,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2499,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {55028, 55031},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {53949, 53937},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 55028,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 55031,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 53947,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 53783,
                },
            },
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 53802,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 54930,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 53806,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53848,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 53948,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 53833,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 53949,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 53937,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_INSCRIPTION, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 5),
    -- name = { -- Sacrificial Writes
    --     type = "quest",
    --     id = 49873,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {110,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2507,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {40537, 49943},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 49882,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                18700, 66855, 115005, 163160, 211310, 259465, 307615, 355770, 403920, 452075, 500225, 548380, 596530, 644685, 692835, 740990, 789140, 837295, 885445, 933600, 981750, 1042340, 1102925, 1163515, 1224100, 1284690, 1345280, 1405865, 1466455, 1527040, 1587630, 1648220, 1708805, 1769395, 1829980, 1890570, 1950035, 2009500, 2068970, 2128435, 2187900, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                9340, 10290, 11180, 12040, 12940, 13885, 14830, 15600, 16535, 17480, 18300, 19245, 20130, 20950, 21895, 22830, 23750, 24545, 25480, 26450, 27275, 28125, 29100, 29925, 30775, 31800, 32725, 33475, 34450, 35375, 36175, 37100, 38025, 38825, 39750, 40775, 41625, 42400, 43425, 44275, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 40537,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49943,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49694,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49944,
                },
            },
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 49873,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49874,
            connections = {
                1, 
            },
        },
        {
            x = 3,
            connections = {
                1, 
            },
            variations = {
                {
                    type = "quest",
                    id = 49876,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49946,
                },
            },
        },
        {
            type = "quest",
            id = 49877,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 49878,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49879,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49881,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49882,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_JEWELCRAFTING, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 6),
    -- name = { -- A Rocky Start
    --     type = "quest",
    --     id = 49585,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {110,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2517,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {49570, 49585},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {49584, 49599},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 49570,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49585,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49571,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49586,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49574,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49589,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49577,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49583,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55585,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 55592,
                },
            },
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49573,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49588,
                },
            },
            x = 2,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49572,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49587,
                },
            },
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49576,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49581,
                },
            },
            x = 2,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49575,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49582,
                },
            },
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55586,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 55594,
                },
            },
            x = 2,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55590,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 55596,
                },
            },
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49584,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 49599,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_LEATHERWORKING, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 7),
    -- name = { -- Instruments of Destruction
    --     type = "quest",
    --     id = 55223,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2525,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {55227, 53995},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {55235, 55223},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 55227,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 53995,
                },
            },
            x = 3,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55228,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55216,
                },
            },
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55229,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55217,
                },
            },
            x = 1,
            connections = {
                3,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55233,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55221,
                },
            },
            connections = {
                4,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55231,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55219,
                },
            },
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55230,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55218,
                },
            },
            x = 2,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55232,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55220,
                },
            },
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55234,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55222,
                },
            },
            x = 3,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55235,
                    restrictions = {
                        type = "faction",
                        id = "Alliance",
                    },
                },
                {
                    type = "quest",
                    id = 55223,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_TAILORING, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_TOOL_ID, 8),
    -- name = { -- Cut from the Same Cloth
    --     type = "quest",
    --     id = 53962,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "profession",
            id = 2533,
            level = 150,
        },
    },
    active = {
        type = "quest",
        ids = {53805, 53938},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {53881, 53962},
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 53805,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 53938,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 53807,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 53940,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55177,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 55188,
                },
            },
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 53810,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 53813,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53858,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53866,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55214,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53868,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53869,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 53881,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_ALLIANCE,
                    },
                },
                {
                    type = "quest",
                    id = 53962,
                },
            },
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS, {
    name = L["BTWQUESTS_PROFESSIONS"],
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_ALCHEMY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_BLACKSMITHING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_ENCHANTING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_ENGINEERING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_INSCRIPTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_JEWELCRAFTING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_LEATHERWORKING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_8_1_5_TAILORING,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_PROFESSIONS,
})