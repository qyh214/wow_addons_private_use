local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.MistsOfPandaria;
local CATEGORY_ID = BtWQuests.Constant.Category.MistsOfPandaria.TheJadeForest;
local Chain = BtWQuests.Constant.Chain.MistsOfPandaria.TheJadeForest;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 371
local ACHIEVEMENT_ID_ALLIANCE = 6300
local ACHIEVEMENT_ID_HORDE = 6534
local CONTINENT_ID = 424

Chain.PawDonVillage = 50101
Chain.TheWaterspeakingCeremony = 50102
Chain.TheWhitePawn = 50103
Chain.PearlfinVillage = 50104

Chain.TheRemainsOfHellscreamsFist = 50105
Chain.FirstContact = 50106
Chain.StrangeBedfellows = 50107
Chain.GrookinHill = 50108

Chain.DawnsBlossom = 50109
Chain.GreenstoneQuarry = 50110
Chain.TianMonastery = 50111
Chain.TerraceOfTenThunders = 50112
Chain.TheTempleOfTheJadeSerpent = 50113
Chain.NectarbreezeOrchard = 50114

Chain.TheBattleForTheForestAlliance = 50115
Chain.TheBattleForTheForestHorde = 50116

Chain.OvercomingDoubt = 50117

Chain.Chain01 = 50121
Chain.Chain02 = 50122
Chain.Chain03 = 50123

Chain.Chain04 = 50124
Chain.Chain05 = 50125
Chain.Chain06 = 50126
Chain.Chain07 = 50127

Database:AddChain(Chain.PawDonVillage, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.TheRemainsOfHellscreamsFist,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 29547,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31745,
    },
    items = {
        {
            type = "npc",
            id = 1750,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29547,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29548,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31732,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31733,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 30069,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31734,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31735,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 31736,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 31737,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 31738,
            x = -2,
            connections = {
                4, 5, 6, 7, 
            },
        },
        {
            type = "quest",
            id = 31739,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29552,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 31740,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 31741,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 31742,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31743,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31744,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30070,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31745,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheWaterspeakingCeremony, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.FirstContact,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.PawDonVillage,
        },
    },
    active = {
        type = "quest",
        ids = {29555, 29556},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29894,
    },
    items = {
        {
            type = "npc",
            id = 66292,
            locations = {
                [371] = {
                    {
                        x = 0.480502,
                        y = 0.883926,
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
            id = 29555,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29556,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29553,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 29558,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29559,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29560,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29759,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29562,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29883,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 29885,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29887,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29762,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29894,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheWhitePawn, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.StrangeBedfellows,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.PawDonVillage,
        },
        {
            type = "chain",
            id = Chain.TheWaterspeakingCeremony,
        },
    },
    active = {
        type = "quest",
        id = 29733,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29901,
    },
    items = {
        {
            type = "npc",
            id = 55333,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29733,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29725,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29726,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29727,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29888,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29903,
            aside = true,
        },
        {
            type = "quest",
            id = 29889,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31130,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 29891,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29892,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29893,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29890,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 29898,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29899,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29900,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29901,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PearlfinVillage, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.GrookinHill,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.PawDonVillage,
        },
        {
            type = "chain",
            id = Chain.TheWaterspeakingCeremony,
        },
        {
            type = "quest",
            id = 29903,
        },
    },
    active = {
        type = "quest",
        id = 35708,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {29905, 29906},
        count = 2,
    },
    items = {
        {
            type = "quest",
            id = 29904,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29905,
            x = -1,
        },
        {
            type = "quest",
            id = 29906,
        },
    },
})

Database:AddChain(Chain.TheRemainsOfHellscreamsFist, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.PawDonVillage,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {29612, 29611},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29694,
    },
    items = {
        {
            type = "npc",
            id = 54870,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                29612, 29611, 
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31853,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29690,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31765,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31766,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 31767,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31768,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31769,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 31770,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 29694,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 31771,
            aside = true,
        },
        {
            type = "quest",
            id = 31773,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 31978,
            aside = true,
        },
    },
})
Database:AddChain(Chain.FirstContact, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.TheWaterspeakingCeremony,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheRemainsOfHellscreamsFist,
        },
        {
            type = "quest",
            id = 31771,
        },
        {
            type = "quest",
            id = 31773,
        },
    },
    active = {
        type = "quest",
        id = 31774,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31779,
    },
    items = {
        {
            type = "npc",
            id = 66845,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31774,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29765,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29743,
            aside = true,
        },
        {
            type = "quest",
            id = 29804,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 31775,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 31776,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 31777,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 31778,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31779,
            x = 0,
        },
    },
})
Database:AddChain(Chain.StrangeBedfellows, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.TheWhitePawn,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheRemainsOfHellscreamsFist,
        },
        {
            type = "quest",
            id = 31771,
        },
        {
            type = "quest",
            id = 31773,
        },
        {
            type = "chain",
            id = Chain.TheRemainsOfHellscreamsFist,
        },
    },
    active = {
        type = "quest",
        id = 31999,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29879,
    },
    items = {
        {
            type = "object",
            id = 215844,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31999,
            x = 0,
            connections = {
                1, 3, 
            },
        },
        {
            type = "quest",
            id = 29821,
            aside = true,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31112,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 29815,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29827,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29822,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31121,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31132,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31134,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31152,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31167,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29879,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.GrookinHill, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.PearlfinVillage,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheRemainsOfHellscreamsFist,
        },
    },
    active = {
        type = "quest",
        id = 29935,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29967,
    },
    items = {
        {
            type = "npc",
            id = 56313,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29935,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29936,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29941,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29937,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 31239,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29939,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29942,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29730,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29731,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29823,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29824,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29968,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29943,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29967,
            x = -1,
        },
        {
            type = "quest",
            id = 29966,
        },
    },
})

Database:AddChain(Chain.DawnsBlossom, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.PearlfinVillage,
        },
        {
            type = "chain",
            id = Chain.GrookinHill,
        },
    },
    active = {
        type = "quest",
        ids = {29922, 30015},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {29882, 29920, 29881, 29865, 29723},
        count = 5,
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 54960,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "npc",
                    id = 56339,
                    locations = {
                        [371] = {
                            {
                                x = 0.286677,
                                y = 0.475361,
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
                    id = 29922,
                    restrictions = ALLIANCE_RESTRICTION,
                },
                {
                    type = "quest",
                    id = 30015,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31230,
            x = 0,
            connections = {
                1, 2, 3, 3.2, 2.3, 2.5, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain01,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            embed = true,
        },
    },
})
Database:AddChain(Chain.GreenstoneQuarry, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.PearlfinVillage,
        },
        {
            type = "chain",
            id = Chain.GrookinHill,
        },
        {
            type = "quest",
            id = 29723,
        },
    },
    active = {
        type = "quest",
        id = 29925,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29930,
    },
    items = {
        {
            type = "npc",
            id = 56348,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29925,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29928,
            x = 0,
            connections = {
                1, 3, 
            },
        },
        {
            type = "quest",
            id = 29927,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29929,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29926,
            aside = true,
        },
        {
            type = "quest",
            id = 29930,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TianMonastery, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 29618,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {29646, 29647, 29639},
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 54913,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29618,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29619,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29620,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain04,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain05,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain06,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain07,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                29639, 29646, 29647, 
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.TerraceOfTenThunders, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 8),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 29745,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29755,
    },
    items = {
        {
            type = "npc",
            id = 55438,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29745,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29747,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29748,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29749,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 29750,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29751,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29752,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29753,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29756,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29754,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29755,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheTempleOfTheJadeSerpent, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 9),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.PearlfinVillage,
        },
        {
            type = "chain",
            id = Chain.GrookinHill,
        },
        {
            type = "quest",
            id = 29723,
        },
        {
            type = "chain",
            id = Chain.GreenstoneQuarry,
        },
    },
    active = {
        type = "quest",
        id = 29931,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 30000,
    },
    items = {
        {
            type = "npc",
            id = 56346,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29931,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30495,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29932,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 29997,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 29999,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 30005,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 29998,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 30011,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 30001,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30002,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30004,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30000,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.NectarbreezeOrchard, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 10),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {29578, 29579, 29580, 29585},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29670,
    },
    items = {
        {
            type = "npc",
            id = 54697,
            x = -2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 54854,
            x = 2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 29578,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 29579,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 29580,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29585,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29586,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29587,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 29670,
        },
    },
})

Database:AddChain(Chain.TheBattleForTheForestAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 11),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.TheBattleForTheForestHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfTheJadeSerpent,
        },
    },
    active = {
        type = "quest",
        ids = {30498, 30568, 30565},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31362,
    },
    items = {
        {
            type = "npc",
            id = 57242,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30498,
            aside = true,
            x = 0,
        },
        {
            type = "npc",
            id = 55122,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 59550,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30568,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30565,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31362,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.TheBattleForTheForestHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 11),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    alternatives = {
        Chain.TheBattleForTheForestAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfTheJadeSerpent,
        },
    },
    active = {
        type = "quest",
        id = 35708,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {30499, 30466},
        count = 4,
    },
    completed = {
        type = "quest",
        id = 30485,
    },
    items = {
        {
            type = "npc",
            id = 57242,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30499,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30466,
            x = -1,
        },
        {
            type = "quest",
            id = 30484,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 30485,
            x = 0,
        },
    },
})

Database:AddChain(Chain.OvercomingDoubt, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 12),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {80,35},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfTheJadeSerpent,
        },
        {
            type = "chain",
            id = Chain.TheBattleForTheForestAlliance,
        },
        {
            type = "chain",
            id = Chain.TheBattleForTheForestHorde,
        },
    },
    active = {
        type = "quest",
        id = 31303,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 31319,
    },
    items = {
        {
            type = "npc",
            id = 59411,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 31303,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 30502,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 31319,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 30500,
            aside = true,
        },
        {
            type = "quest",
            id = 30648,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    completed = {
        type = "quest",
        id = 29881,
    },
    items = {
        {
            type = "quest",
            id = 29865,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.Chain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    completed = {
        type = "quest",
        id = 29920,
    },
    items = {
        {
            type = "quest",
            id = 29866,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29993,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29882,
            x = -2,
        },
        {
            type = "quest",
            id = 29995,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29881,
        },
        {
            type = "quest",
            id = 29920,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    completed = {
        type = "quest",
        id = 29723,
    },
    items = {
        {
            type = "quest",
            id = 29716,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29717,
        },
        {
            type = "quest",
            id = 29723,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain04, {
    name = { -- Instructor Xann
        type = "npc",
        id = 54917,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    active = {
        type = "quest",
        id = 29622,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 29624,
    },
    items = {
        {
            type = "quest",
            id = 29622,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29623,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29624,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = { -- Master Stone Fist
        type = "npc",
        id = 54922,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    active = {
        type = "quest",
        id = 29632,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 29635,
    },
    items = {
        {
            type = "quest",
            id = 29632,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 29633,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 29634,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29635,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = { -- Groundskeeper Wu
        type = "npc",
        id = 54915,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    active = {
        type = "quest",
        id = 29626,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {29628, 29629, 29630, 29631},
        count = 4
    },
    items = {
        {
            type = "quest",
            id = 29626,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29627,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 29628,
            x = -3,
        },
        {
            type = "quest",
            id = 29629,
        },
        {
            type = "quest",
            id = 29630,
        },
        {
            type = "quest",
            id = 29631,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = { -- Instructor Myang
        type = "npc",
        id = 54918,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {1,35},
    active = {
        type = "quest",
        id = 29636,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 29637,
    },
    items = {
        {
            type = "quest",
            id = 29636,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29637,
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
            id = Chain.PawDonVillage,
        },
        {
            type = "chain",
            id = Chain.TheWaterspeakingCeremony,
        },
        {
            type = "chain",
            id = Chain.TheWhitePawn,
        },
        {
            type = "chain",
            id = Chain.PearlfinVillage,
        },

        {
            type = "chain",
            id = Chain.TheRemainsOfHellscreamsFist,
        },
        {
            type = "chain",
            id = Chain.FirstContact,
        },
        {
            type = "chain",
            id = Chain.StrangeBedfellows,
        },
        {
            type = "chain",
            id = Chain.GrookinHill,
        },

        {
            type = "chain",
            id = Chain.DawnsBlossom,
        },
        {
            type = "chain",
            id = Chain.GreenstoneQuarry,
        },
        {
            type = "chain",
            id = Chain.TianMonastery,
        },
        {
            type = "chain",
            id = Chain.TerraceOfTenThunders,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfTheJadeSerpent,
        },
        {
            type = "chain",
            id = Chain.NectarbreezeOrchard,
        },

        {
            type = "chain",
            id = Chain.TheBattleForTheForestAlliance,
        },
        {
            type = "chain",
            id = Chain.TheBattleForTheForestHorde,
        },

        {
            type = "chain",
            id = Chain.OvercomingDoubt,
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

