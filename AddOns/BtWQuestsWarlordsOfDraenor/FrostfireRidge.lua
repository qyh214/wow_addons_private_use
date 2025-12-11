local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local CATEGORY_ID = BtWQuests.Constant.Category.WarlordsOfDraenor.FrostfireRidge;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor.FrostfireRidge;
local HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 525
local ACHIEVEMENT_ID = 8671
local CONTINENT_ID = 572

Chain.FootholdInASavageLand = 60101
Chain.SiegeOfBladespireCitadel = 60102
Chain.DefenseOfWorGol = 60103
Chain.GaNarsVengeance = 60104
Chain.ThundersFall = 60105
Chain.TheBattleOfThunderPass = 60106

Chain.Chain01 = 60111
Chain.Chain02 = 60112

Database:AddChain(Chain.FootholdInASavageLand, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {33868, 33815},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34775,
    },
    items = {
        {
            type = "quest",
            id = 33868,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33815,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34402,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34364,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34375,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34592,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34765,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34378,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34822,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34824,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34823,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34461,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34861,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34462,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34775,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 36567,
            aside = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.SiegeOfBladespireCitadel,
            aside = true,
        },
        {
            type = "quest",
            id = 36706,
            aside = true,
        },
    },
})
Database:AddChain(Chain.SiegeOfBladespireCitadel, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.FootholdInASavageLand,
        },
    },
    active = {
        type = "quest",
        ids = {34379},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33527,
    },
    items = {
        {
            type = "npc",
            id = 76411,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 34379,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 34380,
            x = 0,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33784,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33526,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33546,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33408,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33410,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 33344,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33622,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33527,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33657,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DefenseOfWorGol, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.FootholdInASavageLand,
        },
        {
            type = "chain",
            id = Chain.SiegeOfBladespireCitadel,
        },
    },
    active = {
        type = "quest",
        ids = {33468},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33473,
    },
    items = {
        {
            type = "npc",
            id = 70860,
            locations = {
                [526] = {
                    {
                        x = 0.431704,
                        y = 0.412964,
                    },
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 33468,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33807,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33469,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33470,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33473,
            x = 0,
        },
    },
})
Database:AddChain(Chain.GaNarsVengeance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.FootholdInASavageLand,
        },
        {
            type = "chain",
            id = Chain.SiegeOfBladespireCitadel,
        },
        {
            type = "chain",
            id = Chain.DefenseOfWorGol,
        },
    },
    active = {
        type = "quest",
        ids = {32783},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 32796,
    },
    items = {
        {
            type = "npc",
            id = 70860,
            locations = {
                [526] = {
                    {
                        x = 0.431704,
                        y = 0.412964,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 32783,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 32791,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 32792,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 32929,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 32794,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 32804,
            aside = true,
        },
        {
            type = "quest",
            id = 32795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 32796,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ThundersFall, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.FootholdInASavageLand,
        },
        {
            type = "chain",
            id = Chain.SiegeOfBladespireCitadel,
        },
        {
            type = "chain",
            id = Chain.DefenseOfWorGol,
        },
    },
    active = {
        type = "quest",
        ids = {32989},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33828,
    },
    items = {
        {
            type = "npc",
            id = 70860,
            locations = {
                [526] = {
                    {
                        x = 0.431704,
                        y = 0.412964,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 32989,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 32990,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain02,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 32991,
            x = 0,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 32992,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 32993,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 33826,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 33785,
            aside = true,
        },
        {
            type = "quest",
            id = 32994,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 33828,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33493,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheBattleOfThunderPass, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {10,60},
    major = true,
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.FootholdInASavageLand,
        },
        {
            type = "chain",
            id = Chain.SiegeOfBladespireCitadel,
        },
        {
            type = "chain",
            id = Chain.DefenseOfWorGol,
        },
        {
            type = "chain",
            id = Chain.GaNarsVengeance,
        },
        {
            type = "chain",
            id = Chain.ThundersFall,
        },
    },
    active = {
        type = "quest",
        ids = {37291},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34124,
    },
    items = {
        {
            type = "npc",
            id = 74163,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37291,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33010,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34123,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34124,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,60},
    completed = {
        type = "quest",
        id = 33816,
    },
    items = {
        {
            type = "npc",
            id = 80456,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 33816,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,60},
    items = {
        {
            type = "npc",
            id = 74358,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33013,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    restrictions = HORDE_RESTRICTION,
    items = {
        {
            type = "chain",
            id = Chain.FootholdInASavageLand,
        },
        {
            type = "chain",
            id = Chain.SiegeOfBladespireCitadel,
        },
        {
            type = "chain",
            id = Chain.DefenseOfWorGol,
        },
        {
            type = "chain",
            id = Chain.GaNarsVengeance,
        },
        {
            type = "chain",
            id = Chain.ThundersFall,
        },
        {
            type = "chain",
            id = Chain.TheBattleOfThunderPass,
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
-- Garrisons
Database:AddMapRecursive(590, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddContinentItems(CONTINENT_ID, {
})
