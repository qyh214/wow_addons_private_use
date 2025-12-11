-- Alliance Northwatch Hold might require some quests related to [Langridge Shot]
-- Alliance Fort Triumph might actually require parts at Fort Triumph

local MAP_ID = 199
local ACHIEVEMENT_ID_HORDE = 4981
local ACHIEVEMENT_ID_ALLIANCE = 4937
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_HUNTERS_HILL, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24517, 24552, 24514, 24515},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24517, 24519, 24514, 24515},
        count = 4,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN01,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "kill",
            id = 37216,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN02,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 24518,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24519,
            x = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_CAMP_UNAFE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24525, 24529, 24539},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24525, 24534, 24542},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 11857,
            x = 2,
            y = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN03,
            x = 5,
            embed = true,
        },
        {
            type = "quest",
            id = 24525,
            x = 1,
        },
        {
            type = "quest",
            id = 24529,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24534,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_LIFE_FROM_THE_DREAM_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24570, 24571, 24565},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24566, 24601},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 38314,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 37570,
            x = 5,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 24570,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 24571,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24565,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24566,
            x = 2,
        },
        {
            type = "quest",
            id = 24574,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24601,
            x = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_VENDETTA_POINT, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24552, 24543, 24551, 24546},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24552, 24572, 24573},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN04,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "npc",
            id = 3433,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 24543,
                    restrictions = {
                        type = "quest",
                        id = 24543,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 3418,
                },
            },
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24551,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24546,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24569,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24572,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24573,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_DESOLATION_HOLD,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_DESOLATION_HOLD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_VENDETTA_POINT,
        },
    },
    active = {
        type = "quest",
        ids = {24577, 24619, 24631, 24654},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24618, 24637, 24621, 24631, 24654},
        count = 5,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_VENDETTA_POINT,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 24577,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN05,
            x = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 24591,
            x = 3,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN06,
            x = 6,
            embed = true,
        },
        {
            type = "quest",
            id = 24618,
            x = 2,
        },
        {
            type = "quest",
            id = 24634,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24637,
            x = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN07,
            x = 6,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FIRESTONE_POINT_HORDE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24824, 24603, 24606},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24824, 24608, 24633},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN08,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN09,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN10,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_SPEARHEAD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24632, 24684},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 24747,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 24632,
                    restrictions = {
                        type = "quest",
                        id = 24632,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 3341,
                },
            },
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24684,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24685,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24747,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_HONORS_STAND, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {28550, 25852, 24862, 24863},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 25186,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28550,
                    restrictions = {
                        type = "quest",
                        id = 28550,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 25852,
                    restrictions = {
                        type = "quest",
                        id = 25852,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38378,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24862,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24863,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25186,
            x = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN11,
            aside = true,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_NORTHWATCH_HOLD, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {28551, 24921, 25197, 24921, 24934, 24941},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24939, 24948, 24956},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN12,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN13,
            x = 0,
            y = 3,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN14,
            aside = true,
            x = 4,
            y = 6,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN15,
            aside = true,
            x = 6,
            y = 6,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_TEEGANS_EXPEDITION, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {25036, 25015, 25022, 25008},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25027, 25028},
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25036,
                    restrictions = {
                        type = "quest",
                        id = 25036,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 38871,
                },
            },
            x = 2,
            y = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 38873,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25015,
            x = 1,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 25022,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25008,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25027,
            x = 2,
        },
        {
            type = "quest",
            id = 25028,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_LIFE_FROM_THE_DREAM_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24570, 24571, 24565},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24566, 24601},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 38314,
            x = 2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 37570,
            x = 5,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 24570,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 24571,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24565,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24566,
            x = 2,
        },
        {
            type = "quest",
            id = 24574,
            x = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24601,
            x = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FORWARD_COMMAND, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {25034, 25044, 25043, 25045, 25041},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25059, 25074, 25042},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN16,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "npc",
            id = 39003,
            x = 6,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25041,
            x = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25042,
            x = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FIRESTONE_POINT_ALLIANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {24824, 25084, 24606},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24824, 25085, 24653},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN08,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN17,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN10,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FORT_TRIUMPH, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    major = true,
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {25104},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25182, 25185},
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN18,
            aside = true,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 25087,
                    restrictions = {
                        type = "quest",
                        id = 25087,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 39118,
                }
            },
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25104,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25106,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 25108,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25120,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 25151,
            aside = true,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25163,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 25153,
            aside = true,
        },
        {
            type = "quest",
            id = 25175,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 25174,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25182,
            x = 2,
        },
        {
            type = "quest",
            id = 25183,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25185,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_CHAIN01, {
    name = { -- Holdout at Hunter's Hill
        type = "quest",
        id = 24505,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {28549, 26069, 24504, 24512, 25284, 24513},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {24505, 24512, 25284, 24513},
        count = 4,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28549,
                    restrictions = {
                        type = "quest",
                        id = 28549,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 26069,
                    restrictions = {
                        type = "quest",
                        id = 26069,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 37135,
                },
            },
            x = 4,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN19,
            x = 0,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 24504,
            x = 4,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN20,
            x = 6,
            y = 1,
            embed = true,
        },
        {
            type = "quest",
            id = 24505,
            x = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_CHAIN02, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {25082, 25081, 25075},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {25082, 25081, 25080},
        count = 3,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN21,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN22,
            x = 3,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN23,
            x = 5,
            y = 0,
            embed = true,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN01, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37154,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24517,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN02, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37138,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24514,
            x = 0,
        },
        {
            type = "quest",
            id = 24515,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN03, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37515,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24539,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24542,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN04, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 3387,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24552,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN05, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37908,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24619,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24620,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24621,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN06, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37909,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24631,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN07, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37910,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24654,
            x = 0,
            -- connections = {
            --     1, 
            -- },
        },
        -- {
        --     type = "quest",
        --     id = 24667,
        --     x = 0,
        -- },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN08, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37834,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24824,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN09, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37847,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24603,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24608,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN10, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "quest",
            id = 24606,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24653,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24633,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN11, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 38383,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25191,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN12, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "quest",
            id = 28551,
            visible = {
                type = "quest",
                id = 28551,
                status = {
                    "active",
                    "completed",
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 24921,
                    restrictions = {
                        type = "quest",
                        id = 24921,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 25197,
                    restrictions = {
                        type = "quest",
                        id = 25197,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 24921,
                    restrictions = {
                        type = "quest",
                        id = 28551,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 38619,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24934,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24938,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24939,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN13, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 38620,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24941,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24943,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24944,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 24948,
            x = 0,
            -- connections = {
            --     2, 
            -- },
        },
        {
            type = "quest",
            id = 24956,
            -- connections = {
            --     1, 
            -- },
        },
        -- {
        --     type = "quest",
        --     id = 25036,
        --     aside = true,
        --     x = 1,
        -- },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN14, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 38621,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25000,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN15, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 38878,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25002,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN16, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 25034,
                    restrictions = {
                        type = "quest",
                        id = 25034,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 38986,
                },
            },
            x = 0,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 38323,
            x = 3,
            y = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25044,
            x = 0,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 25043,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 25045,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 25059,
            x = 1,
        },
        {
            type = "quest",
            id = 25057,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25074,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN17, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37835,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25084,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25085,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN18, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 39154,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25102,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN19, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37153,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 24512,
            x = 0,
        },
        {
            type = "quest",
            id = 25284,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN20, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 37136,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 24513,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN21, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 39085,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25082,
            x = 0,
            -- connections = {
            --     1, 
            -- },
        },
        -- {
        --     type = "quest",
        --     id = 25086,
        --     x = 0,
        -- },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN22, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 39083,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25081,
            x = 0,
            -- connections = {
            --     1, 
            -- },
        },
        -- {
        --     type = "quest",
        --     id = 25087,
        --     x = 0,
        -- },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_EMBED_CHAIN23, {
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        {
            type = "npc",
            id = 39084,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25075,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25079,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 25080,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
        { -- I think this quest shows up doing [Firestone Point] Horde if you do most of it but dont take [Don't Stop Bereavin']
            type = "quest",
            id = 24604,
        },
        { -- We ignored this quest because it doesnt actually lead to anything directly, its more a breadcrumb to an area
            type = "quest",
            id = 24807,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {10,30},
    items = {
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851087,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_HUNTERS_HILL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_CAMP_UNAFE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_LIFE_FROM_THE_DREAM_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_VENDETTA_POINT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_DESOLATION_HOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FIRESTONE_POINT_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_SPEARHEAD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_HONORS_STAND,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_NORTHWATCH_HOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_TEEGANS_EXPEDITION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_LIFE_FROM_THE_DREAM_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FORWARD_COMMAND,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FIRESTONE_POINT_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_FORT_TRIUMPH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_SOUTHERN_BARRENS_CHAIN02,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_SOUTHERN_BARRENS,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
})
