local L = BtWQuests.L;
local MAP_ID = 863
local ACHIEVEMENT_ID = 11868
local CONTINENT_ID = 875

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 1)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
    },
    active = {
        type = "quest",
        id = 47512,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 47188,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                388325, 413560, 438795, 464030, 489265, 514500, 546260, 578000, 609760, 641500, 673260, 705020, 736760, 768520, 800260, 832020, 863780, 895520, 927280, 959020, 990780, 1021940, 1053100, 1084280, 1115440, 1146600, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                17220, 18000, 18530, 19270, 20000, 20550, 21250, 22000, 22550, 23250, 24000, 24750, 25250, 26000, 26750, 27250, 28000, 28750, 29250, 30000, 30750, 31450, 32000, 32800, 33450, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 515,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 47512,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47103,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48535,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47105,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47130,
            x = 2,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47264,
            x = 4,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47262,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47263,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47188,
            x = 3,
            y = 7,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
            aside = true,
            x = 2,
            y = 8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN2,
            aside = true,
            x = 4,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 2)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
    },
    completed = {
        type = "quest",
        id = 47250,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                645925, 656225, 666525, 676825, 687125, 697425, 707725, 718025, 728325, 738625, 748925, 759225, 769525, 779825, 790125, 800425, 1018865, 1081695, 1144525, 1207355, 1270185, 1346450, 1425505, 1504560, 1583615, 1662670, 1741730, 1820785, 1899840, 1978895, 2057950, 2137010, 2216065, 2295120, 2374175, 2453230, 2531075, 2608665, 2686260, 2763855, 2828725, 491400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                30360, 30660, 30960, 31160, 31460, 31760, 32060, 32260, 32560, 32860, 33060, 33360, 33660, 33860, 34160, 34460, 35900, 37040, 38460, 39950, 41100, 42500, 44000, 45100, 46500, 48000, 49450, 50550, 52000, 53450, 54550, 56000, 57450, 58550, 60000, 61500, 62900, 64000, 65500, 66900, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 1150,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47868,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47880,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4, 5, 6,
            },
        },
        {
            type = "quest",
            id = 47248,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 48934,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 47247,
            x = 0,
            y = 4,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 47491,
            x = 2,
            y = 4,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49348,
            x = 4,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49432,
            x = 6,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47249,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47250,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 3)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
    },
    completed = {
        type = "quest",
        id = 49082,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                328925, 339225, 349525, 359825, 370125, 380425, 390725, 401025, 411325, 421625, 431925, 442225, 452525, 462825, 473125, 483425, 911090, 968255, 1025420, 1082585, 1139750, 1205030, 1276955, 1348885, 1420810, 1492740, 1564670, 1636595, 1708525, 1780450, 1852380, 1924310, 1996235, 2068165, 2140090, 2212020, 2283215, 2353810, 2424410, 2495005, 2552880, 1170000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                29030, 29330, 29630, 29830, 30130, 30430, 30730, 30930, 31230, 31530, 31730, 32030, 32330, 32530, 32830, 33130, 34600, 35620, 37080, 38450, 39525, 40975, 42350, 43375, 44825, 46200, 47575, 48675, 50050, 51425, 52525, 53900, 55275, 56375, 57750, 59125, 60575, 61600, 63075, 64425, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 1225,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49440,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48699,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48890,
            x = 2,
            y = 3,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 48801,
            x = 4,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49078,
            x = 2,
            y = 4,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 48800,
            x = 4,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49406,
            x = 6,
            y = 4,
        },
        {
            type = "quest",
            id = 49079,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49081,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49082,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN3,
            aside = true,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 4)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
    },
    completed = {
        type = "quest",
        id = 49160,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                812350, 822650, 832950, 843250, 853550, 863850, 874150, 884450, 894750, 905050, 915350, 925650, 935950, 946250, 956550, 966850, 1410080, 1497630, 1585180, 1672730, 1760280, 1864060, 1974220, 2084375, 2194535, 2304690, 2414860, 2525020, 2635175, 2745335, 2855490, 2965660, 3075820, 3185975, 3296135, 3406290, 3514990, 3623105, 3731230, 3839360, 3934755, 1123200, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                44550, 44850, 45150, 45350, 45650, 45950, 46250, 46450, 46750, 47050, 47250, 47550, 47850, 48050, 48350, 48650, 50750, 52300, 54350, 56400, 58075, 60075, 62150, 63725, 65725, 67800, 69875, 71375, 73450, 75525, 77025, 79100, 81175, 82675, 84750, 86825, 88825, 90400, 92525, 94475, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 215,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 800,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 3150,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
            x = 4,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49185,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49064,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN6,
            aside = true,
            x = 5,
            y = 2,
        },
        {
            type = "quest",
            id = 49067,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49070,
            x = 1,
            y = 4,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49071,
            x = 3,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49080,
            x = 5,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49120,
            x = 3,
            y = 5,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49125,
            x = 3,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51689,
            aside = true,
            x = 5,
            y = 6,
        },
        {
            type = "quest",
            id = 49126,
            x = 3,
            y = 7,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49130,
            x = 1,
            y = 8,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49131,
            x = 3,
            y = 8,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49132,
            x = 5,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49136,
            x = 3,
            y = 9,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49160,
            x = 3,
            y = 10,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49902,
            aside = true,
            x = 3,
            y = 11,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
            aside = true,
            x = 2,
            y = 12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM,
            aside = true,
            x = 4,
            y = 12,
        },
        {
            type = "quest",
            id = 52477,
            x = 6,
            y = 12,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 5)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
        },
    },
    completed = {
        type = "quest",
        id = 47696,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                737025, 784920, 832815, 880710, 928605, 976500, 1036770, 1097025, 1157295, 1217550, 1277820, 1338090, 1398345, 1458615, 1518870, 1579140, 1639410, 1699665, 1759935, 1820190, 1880460, 1939605, 1998750, 2057910, 2117055, 2176200, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                27090, 28250, 29210, 30340, 31500, 32375, 33475, 34650, 35525, 36625, 37800, 38875, 39875, 40950, 42025, 43025, 44100, 45175, 46175, 47250, 48425, 49525, 50400, 51675, 52675, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 720,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49902,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47525,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 47659,
            x = 2,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47660,
            x = 4,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48402,
            aside = true,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 47623,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47621,
            x = 2,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47622,
            x = 4,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47540,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47696,
            x = 3,
            y = 7,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN9,
            relationship = {
                breadcrumb = 47918,
                blockers = {48090, 48092, 48334},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 2,
            y = 8,
        },
        {
            type = "quest",
            id = 47697,
            aside = true,
            x = 4,
            y = 8,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_EVERYTHING_CONTAINED,
            aside = true,
            active = {
                type = "quest",
                id = 47697,
            },
            x = 3,
            y = 9,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN7,
            aside = true,
            active = {
                type = "quest",
                id = 47697,
            },
            x = 5,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_EVERYTHING_CONTAINED, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 6)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM,
        },
    },
    completed = {
        type = "quest",
        id = 49985,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1188750, 1266000, 1343250, 1420500, 1497750, 1575000, 1672200, 1769400, 1866600, 1963800, 2061000, 2158200, 2255400, 2352600, 2449800, 2547000, 2644200, 2741400, 2838600, 2935800, 3033000, 3128400, 3223800, 3319200, 3414600, 3510000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                41300, 43050, 44450, 46200, 47950, 49300, 51050, 52800, 54100, 55850, 57600, 59250, 60750, 62400, 64050, 65550, 67200, 68850, 70350, 72000, 73750, 75500, 76800, 78650, 80300, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 495,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM,
            x = 4,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49932,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49935,
            x = 1,
            y = 2,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 49937,
            x = 3,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 49938,
            x = 5,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49941,
            x = 1,
            y = 3,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 49949,
            x = 3,
            y = 3,
            connections = {
                2, 3, 4
            },
        },
        {
            type = "quest",
            id = 49950,
            x = 5,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49955,
            x = 1,
            y = 4,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49956,
            x = 3,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49957,
            x = 5,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49980,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49985,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BLEEDING_THE_BLOOD_TROLLS,
            aside = true,
            x = 3,
            y = 7,
        }
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 7)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
        },
    },
    completed = {
        type = "quest",
        id = 47601,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                487425, 497725, 508025, 518325, 528625, 538925, 549225, 559525, 569825, 580125, 590425, 600725, 611025, 621325, 631625, 641925, 897615, 953235, 1008855, 1064475, 1120095, 1186490, 1256475, 1326455, 1396440, 1466420, 1536410, 1606395, 1676375, 1746360, 1816340, 1886330, 1956315, 2026295, 2096280, 2166260, 2235275, 2303960, 2372650, 2441345, 2497310, 631800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                28190, 28490, 28790, 28990, 29290, 29590, 29890, 30090, 30390, 30690, 30890, 31190, 31490, 31690, 31990, 32290, 33650, 34760, 36090, 37500, 38525, 39825, 41250, 42275, 43575, 45000, 46325, 47425, 48750, 50075, 51175, 52500, 53825, 54925, 56250, 57675, 58975, 60000, 61475, 62725, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 500,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49902,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47245,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47631,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 47597,
            x = 2,
            y = 4,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 47599,
            x = 4,
            y = 4,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 47756,
            aside = true,
            x = 6,
            y = 4,
        },
        {
            type = "quest",
            id = 47596,
            x = 1,
            y = 5,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47711,
            x = 3,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47598,
            x = 5,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47601,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47602,
            aside = true,
            x = 3,
            y = 7,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_EVERYTHING_CONTAINED,
            aside = true,
            active = {
                type = "quest",
                id = 47602,
            },
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BLEEDING_THE_BLOOD_TROLLS, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 8)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_EVERYTHING_CONTAINED,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM,
        },
    },
    completed = {
        type = "quest",
        id = 50087,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1172900, 1249120, 1325340, 1401560, 1477780, 1554000, 1649910, 1745805, 1841715, 1937610, 2033520, 2129430, 2225325, 2321235, 2417130, 2513040, 2608950, 2704845, 2800755, 2896650, 2992560, 3086685, 3180810, 3274950, 3369075, 3463200, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                50390, 52400, 54160, 56290, 58300, 60225, 62175, 64200, 66075, 68025, 70200, 72175, 73925, 76050, 78025, 79925, 81900, 83875, 85775, 87750, 89925, 91875, 93600, 95825, 97725, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 1525,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_EVERYTHING_CONTAINED,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM,
            x = 4,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49569,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50076,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50138,
            x = 2,
            y = 3,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 50078,
            x = 4,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50079,
            x = 2,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50081,
            x = 4,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50082,
            x = 3,
            y = 5,
            connections = {
                1,  2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN8,
            aside = true,
            x = 1,
            y = 6,
        },
        {
            type = "quest",
            id = 52073,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50087,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51244,
            aside = true,
            x = 3,
            y = 8,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51302,
            aside = true,
            x = 2,
            y = 9,
        },
        {
            type = "quest",
            id = 50808,
            aside = true,
            x = 4,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1, {
    name = { -- The Shadow of Death
        type = "quest",
        id = 47241,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
    },
    active = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
    },
    completed = {
        type = "quest",
        id = 49278,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                515125, 548600, 582075, 615550, 649025, 682500, 724620, 766740, 808860, 850980, 893100, 935220, 977340, 1019460, 1061580, 1103700, 1145820, 1187940, 1230060, 1272180, 1314300, 1355640, 1396980, 1438320, 1479660, 1521000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14600, 15200, 15750, 16350, 16950, 17500, 18100, 18700, 19200, 19800, 20400, 20950, 21550, 22100, 22650, 23250, 23800, 24350, 24950, 25500, 26100, 26700, 27200, 27850, 28400, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 500,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47241,
            x = 3,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51089,
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 47244,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49278,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
            aside = true,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
            aside = true,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
            aside = true,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, Horde only, requires BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN2, {
    name = { -- Urok, Terror of the Wetlands
        type = "quest",
        id = 48669,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
    },
    active = {
        type = "quest",
        id = 48669,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 48591,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                162500, 172800, 183100, 193400, 203700, 214000, 224300, 234600, 244900, 255200, 265500, 275800, 286100, 296400, 306700, 317000, 979525, 1041840, 1104155, 1166470, 1228785, 1296420, 1374830, 1453235, 1531645, 1610050, 1688460, 1766870, 1845275, 1923685, 2002090, 2080500, 2158910, 2237315, 2315725, 2394130, 2472060, 2549015, 2625970, 2702930, 2767165, 1895400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                32530, 32830, 33130, 33330, 33630, 33930, 34230, 34430, 34730, 35030, 35230, 35530, 35830, 36030, 36330, 36630, 38150, 39370, 40880, 42500, 43625, 45125, 46750, 47875, 49375, 51000, 52525, 53725, 55250, 56775, 57975, 59500, 61025, 62225, 63750, 65375, 66875, 68000, 69625, 71125, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 1200,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48669,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48573,
            x = 2,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 48574,
            x = 4,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },

        
        {
            type = "quest",
            id = 48576,
            x = 1,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48577,
            x = 3,
            y = 3,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 48578,
            x = 5,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },

        
        {
            type = "quest",
            id = 48584,
            x = 2,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48590,
            x = 4,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48588,
            aside = true,
            x = 6,
            y = 4,
        },
        {
            type = "quest",
            id = 48591,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, horde only, requires BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN3, {
    name = { -- Stopping Zardrax
        type = "quest",
        id = 48852,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
    },
    active = {
        type = "quest",
        id = 49314,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 48869,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                479500, 489800, 500100, 510400, 520700, 531000, 541300, 551600, 561900, 572200, 582500, 592800, 603100, 613400, 623700, 634000, 920875, 978040, 1035205, 1092370, 1149535, 1217340, 1289270, 1361195, 1433125, 1505050, 1576980, 1648910, 1720835, 1792765, 1864690, 1936620, 2008550, 2080475, 2152405, 2224330, 2295300, 2365895, 2436490, 2507090, 2564965, 725400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                26910, 27210, 27510, 27710, 28010, 28310, 28610, 28810, 29110, 29410, 29610, 29910, 30210, 30410, 30710, 31010, 32250, 33390, 34610, 36000, 37000, 38200, 39600, 40600, 41800, 43200, 44450, 45550, 46800, 48050, 49150, 50400, 51650, 52750, 54000, 55400, 56600, 57600, 59000, 60200, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 125,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 675,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49314,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48854,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN4,
            aside = true,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 48823,
            x = 2,
            y = 3,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 48825,
            x = 4,
            y = 3,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 48852,
            x = 6,
            y = 3,
        },
        
        {
            type = "quest",
            id = 48855,
            x = 1,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48856,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48857,
            x = 5,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48869,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, Horde only, requires part way through BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN3, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN4, {
    name = { -- Catch Me if You Can
        type = "quest",
        id = 49781,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "quest",
            id = 48854,
        },
    },
    active = {
        type = "quest",
        id = 50933,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 49777,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                602300, 641440, 680580, 719720, 758860, 798000, 847250, 896495, 945745, 994990, 1044240, 1093490, 1142735, 1191985, 1241230, 1290480, 1339730, 1388975, 1438225, 1487470, 1536720, 1585055, 1633390, 1681730, 1730065, 1778400, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                23680, 24700, 25470, 26480, 27500, 28225, 29225, 30250, 30975, 31975, 33000, 33975, 34775, 35750, 36725, 37525, 38500, 39475, 40275, 41250, 42275, 43275, 44000, 45075, 46025, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 125,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 535,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN3,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50933,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49777,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 49774,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49776,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49778,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49779,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49780,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49781,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, both factions, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN5, {
    name = { -- The Fall of Kel'vax
        type = "quest",
        id = 48480,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48468,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48473,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 48480,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                18100, 18850, 19450, 20200, 21000, 21550, 22300, 23100, 23650, 24400, 25200, 25950, 26550, 27300, 28050, 28650, 29400, 30150, 30750, 31500, 32300, 33050, 33600, 34400, 35150, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 700,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 130481,
            -- name = "Go to Shinga Deathwalker",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(863, 0.390648, 0.606691, "Shinga Deathwalker")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48468,
            x = 2,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 48473,
            x = 4,
            y = 1,
            connections = {
                1, 2,
            },
        },

        
        {
            type = "quest",
            id = 48478,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48479,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48480,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, both factions, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN6, {
    name = { -- Shoak's on the Menu
        type = "quest",
        id = 47925,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 47924,
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 47998,
        },
        {
            type = "quest",
            id = 47919,
        },
        {
            type = "quest",
            id = 47925,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                321000, 331300, 341600, 351900, 362200, 372500, 382800, 393100, 403400, 413700, 424000, 434300, 444600, 454900, 465200, 475500, 585650, 621700, 657750, 693800, 729850, 773880, 819240, 864600, 909960, 955320, 1000680, 1046040, 1091400, 1136760, 1182120, 1227480, 1272840, 1318200, 1363560, 1408920, 1453560, 1498080, 1542600, 1587120, 1618920, 234000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                17450, 17750, 18050, 18250, 18550, 18850, 19150, 19350, 19650, 19950, 20150, 20450, 20750, 20950, 21250, 21550, 22450, 23150, 24050, 25000, 25650, 26550, 27500, 28150, 29050, 30000, 30900, 31600, 32500, 33400, 34100, 35000, 35900, 36600, 37500, 38450, 39350, 40000, 40950, 41850, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 375,
        },
    },
    items = {
        {
            type = "npc",
            id = 124666,
            -- name = "Go to Kajosh",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(863, 0.551530, 0.367119, "Kajosh")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47924,
            x = 3,
            y = 1,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 47996,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 47998,
            x = 1,
            y = 2,
        },
        {
            type = "quest",
            id = 47919,
            x = 3,
            y = 2,
        },
        {
            type = "quest",
            id = 47925,
            x = 5,
            y = 2,
        },
    },
})
-- Completed, Horde only, requries A friend of the frogs, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN7, {
    name = { -- It Seems You've Made a Friend
        type = "quest",
        id = 49382,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
        },
    },
    active = {
        type = "quest",
        id = 50934,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 49382,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                562675, 599240, 635805, 672370, 708935, 745500, 791510, 837515, 883525, 929530, 975540, 1021550, 1067555, 1113565, 1159570, 1205580, 1251590, 1297595, 1343605, 1389610, 1435620, 1480775, 1525930, 1571090, 1616245, 1661400, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                21930, 22900, 23620, 24580, 25500, 26175, 27125, 28050, 28725, 29675, 30600, 31475, 32275, 33150, 34025, 34825, 35700, 36575, 37375, 38250, 39175, 40125, 40800, 41825, 42675, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 650,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50934,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49366,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49380,
            x = 1,
            y = 3,
            connections = {
            },
        },
        -- {
        --     type = "quest",
        --     id = 49376,
        --     x = 3,
        --     y = 1,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 49370,
            x = 3,
            y = 3,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 49377,
            x = 5,
            y = 3,
            connections = {
            },
        },

        
        {
            type = "quest",
            id = 49378,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49379,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49382,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, Horde only, requires part way through BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BLEEDING_THE_BLOOD_TROLLS, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN8, {
    name =  { -- The Crawg Ma'da
        type = "quest",
        id = 50083,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_EVERYTHING_CONTAINED,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM,
        },
        {
            type = "quest",
            id = 50082,
        },
    },
    active = {
        type = "quest",
        id = 50083,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 50085,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 406550, 432300, 458050, 483800, 509550, 537960, 570360, 602760, 635160, 667560, 699960, 732360, 764760, 797160, 829560, 861960, 894360, 926760, 959160, 991560, 1023720, 1055520, 1087320, 1119120, 1138200, 702000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10550, 10850, 11150, 11350, 11650, 11950, 12250, 12450, 12750, 13050, 13250, 13550, 13850, 14050, 14350, 14650, 15250, 15750, 16350, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 225,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BLEEDING_THE_BLOOD_TROLLS,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50083,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50085,
            x = 3,
            y = 2,
        },
        {
            type = "quest",
            id = 50080,
            aside = true,
            restrictions = {
                type = "level",
                level = 49,
                atmost = true,
            },
            -- restrictions = function(item, character)
            --     return character:GetLevel() < 120
            -- end,
            x = 5,
            y = 2,
        },
    },
})
-- Completed, Horde Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN9, {
    name = { -- Vengeance of the Frogs
        type = "quest",
        id = 48092,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 47918,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48090,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48092,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 48090,
        },
        {
            type = "quest",
            id = 48092,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 406550, 432300, 458050, 483800, 509550, 537960, 570360, 602760, 635160, 667560, 699960, 732360, 764760, 797160, 829560, 861960, 894360, 926760, 959160, 991560, 1023720, 1055520, 1087320, 1119120, 1138200, 702000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10550, 10850, 11150, 11350, 11650, 11950, 12250, 12450, 12750, 13050, 13250, 13550, 13850, 14050, 14350, 14650, 15250, 15750, 16350, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 400,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 47918,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 125317,
                    -- name = "Go to Shadow Hunter Narez",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(863, 0.777447, 0.531751, "Shadow Hunter Narez")
                    -- end,
                    -- breadcrumb = true,
                }
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 48090,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 48092,
            x = 3,
            y = 1,
        },
        {
            type = "quest",
            id = 48093,
            aside = true,
            x = 5,
            y = 1,
        },
    },
})
-- Completed, Horde only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN10, {
    name = { -- Reuniting the Company
        type = "quest",
        id = 48496,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49477,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48492,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 48499,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                332850, 354480, 376110, 397740, 419370, 441000, 468220, 495430, 522650, 549860, 577080, 604300, 631510, 658730, 685940, 713160, 740380, 767590, 794810, 822020, 849240, 875950, 902660, 929380, 956090, 982800, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14660, 15300, 15740, 16360, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21050, 21450, 22100, 22750, 23150, 23800, 24450, 24850, 25500, 26150, 26750, 27200, 27850, 28450, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 325,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 49477,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 126289,
                    -- name = "Go to Chadwick Paxton",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(863, 0.286269, 0.437555, "Chadwick Paxton")
                    -- end,
                    -- breadcrumb = true,
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
            id = 48492,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 48497,
            x = 1,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 48496,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48498,
            x = 5,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49479,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48499,
            x = 3,
            y = 4,
        },
    },
})
-- Completed, both factions, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN11, {
    name = { -- An Ancient Curse
        type = "quest",
        id = 50976,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 50976,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 50976,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                4300, 4450, 4650, 4800, 5000, 5150, 5300, 5500, 5650, 5800, 6000, 6150, 6350, 6500, 6650, 6850, 7000, 7150, 7350, 7500, 7700, 7850, 8000, 8200, 8350, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2156,
            amount = 250,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 287081,
            -- name = "Go to Ancient Tablet",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(863, 0.528920, 0.759925, "Ancient Tablet")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50976,
            x = 3,
            y = 1,
        },
    },
})
-- Alliance only, unknown requirements, part of BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CHASING_DARKNESS
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN12, {
    name = { -- WANTED: Ayame
        type = "quest",
        id = 52480,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 52480,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 52480,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                5150, 5350, 5550, 5750, 5950, 6200, 6400, 6600, 6800, 7000, 7200, 7400, 7600, 7800, 8000, 8200, 8400, 8600, 8800, 9000, 9200, 9400, 9600, 9800, 10000, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 250,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 250,
        },
    },
    items = {
        {
            type = "object",
            id = 293568,

            -- name = "Go to the Wanted Poster",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(863, 0.0623950, 0.0413126, "Wanted Poster")
            -- end,
            -- breadcrumb = true,

            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52480,
            x = 0,
            y = 1,
        },
    },
})
-- Alliance only, unknown requirements, part of BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CHASING_DARKNESS
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN13, {
    name = { -- WANTED: Tojek
        type = "quest",
        id = 51139,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 51139,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 51139,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                5150, 5350, 5550, 5750, 5950, 6200, 6400, 6600, 6800, 7000, 7200, 7400, 7600, 7800, 8000, 8200, 8400, 8600, 8800, 9000, 9200, 9400, 9600, 9800, 10000, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 287327,
            -- name = "Go to the Scouting Report",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(863, 0.621462, 0.410255, "Scouting Report")
            -- end,
            -- breadcrumb = true,
            -- aside = true,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51139,
            x = 0,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = false,
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = false,
    items = {
        { -- Seems to be another version of 47660
            type = "quest",
            id = 52294,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = false,
    items = {
        { -- http://bfa.wowhead.com/achievement=12482/get-hekd
            type = "quest",
            id = 50444,
        },
        { -- LARRY TEST QUEST
            type = "quest",
            id = 49375,
        },
        {
            type = "quest",
            id = 52954,
        },
        {
            type = "quest",
            id = 52949,
        },
        { -- Emissary
            type = "quest",
            id = 50602,
        },
        {
            type = "quest",
            id = 48905,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2178275,
    listImage = {
        texture = "Interface\\Addons\\BtWQuestsBattleForAzeroth\\UI-CategoryButton",
        texCoords = {0, 0.7353515625, 0.5859375, 0.703125},
    },
    items = {
        {
            type = "header",
            name = L["BTWQUESTS_THE_WAR_CAMPAIGN"],
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CHASING_DARKNESS,
        },
        

        {
            type = "header",
            name = {
                type = "achievement",
                id = ACHIEVEMENT_ID,
            },
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_DEEP_IN_THE_SWAMP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_PACT_WITH_DEATH,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_UNDERCOVER_SISTA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_TURTLE_POWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_A_FRIEND_OF_THE_FROGS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_EVERYTHING_CONTAINED,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BRING_THE_BOOM,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_BLEEDING_THE_BLOOD_TROLLS,
        },

        
        {
            type = "header",
            name = L["BTWQUESTS_SIDE_QUESTS"],
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN4,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN6,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN9,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN11,
        },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_OTHER_ALLIANCE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_OTHER_BOTH,
        -- },
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN2,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN3,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN4,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN5,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN6,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN7,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN8,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN9,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN10,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN11,
    },
})