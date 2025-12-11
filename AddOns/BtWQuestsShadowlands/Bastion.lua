local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.Bastion
local Chain = BtWQuests.Constant.Chain.Shadowlands.Bastion
local MAP_ID = 1533
local CONTINENT_ID = 1550
local ACHIEVEMENT_ID = 14281
local SIDE_ACHIEVEMENT_ID = 14801
local LEVEL_RANGE = {50, 52}

Database:AddChain(Chain.EternitysCall, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = 1001,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
        {
            type = "chain",
            id = 90002
        },
    },
    active = {
        type = "quest",
        id = 59773,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57677,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11560, 12800, 13945, 14935, 16100, 17245, 18385, 19500, 20545, 21760, 22875, 24015, 25060, 26175, 27315, 28360, 29625, 30615, 31860, 33000, 33925, 35150, 36300, 37225, 38450, 39600, 40675, 41825, 42900, 43975, 45125, 46200, 47275, 48425, 49500, 50650, 51875, 52800, 54150, 55175, 56100, 57450, 58475, 59475, 60750, 61775, 62925, 64050, 65075, 66300, 67375, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        56100, 57450, 58475, 59475, 60750, 61775, 62925, 64050, 65075, 66300, 67375, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        11560, 12800, 13945, 14935, 16100, 17245, 18385, 19500, 20545, 21760, 22875, 24015, 25060, 26175, 27315, 28360, 29625, 30615, 31860, 33000, 33925, 35150, 36300, 37225, 38450, 39600, 40675, 41825, 42900, 43975, 45125, 46200, 47275, 48425, 49500, 50650, 51875, 52800, 54150, 55175, 56100, 57450, 55175, 44050, 33000, 22035, 11065, 5502.5, 
                    },
                    minLevel = 10,
                    maxLevel = 57,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        18650, 66678, 114698, 162725, 210745, 258773, 306793, 354820, 402840, 450868, 498888, 546915, 594935, 642963, 690983, 739010, 787030, 835058, 883078, 931105, 979125, 1039555, 1099975, 1160405, 1220825, 1281255, 1341685, 1402105, 1462535, 1522955, 1583385, 1643815, 1704235, 1764665, 1825085, 1885515, 1944820, 2004125, 2063440, 2122745, 2182050, 2203873, 2225695, 2247508, 2269330, 2291153, 2312975, 2334798, 2356610, 2378433, 2400255, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2182050, 2203873, 2225695, 2247508, 2269330, 2291153, 2312975, 2334798, 2356610, 2378433, 2400255, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        18650, 66678, 114698, 162725, 210745, 258773, 306793, 354820, 402840, 450868, 498888, 546915, 594935, 642963, 690983, 739010, 787030, 835058, 883078, 931105, 979125, 1039555, 1099975, 1160405, 1220825, 1281255, 1341685, 1402105, 1462535, 1522955, 1583385, 1643815, 1704235, 1764665, 1825085, 1885515, 1944820, 2004125, 2063440, 2122745, 2182050, 2203873, 
                    },
                    minLevel = 10,
                    maxLevel = 51,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 300,
        },
    },
    items = {
        {
            type = "npc",
            id = 175133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59773,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59774,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57102,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57584,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60735,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57261,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57676,
            aside = true,
            x = -1,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57677,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            aside = true,
            embed = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheAspirantsCrucible, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    questline = {1055, 1154},
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            upto = 57677,
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            upto = 57676,
        },
    },
    active = {
        type = "quest",
        id = 57709,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58174,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        19100, 21150, 23075, 24625, 26600, 28525, 30575, 32050, 33975, 36100, 37575, 39625, 41550, 43025, 45075, 47000, 48975, 50525, 52450, 54500, 56000, 57875, 59950, 61450, 63325, 65400, 67400, 68850, 70850, 72850, 74300, 76300, 78300, 79750, 81750, 83825, 85700, 87200, 89275, 91150, 92650, 94725, 96600, 98175, 100175, 102050, 104125, 105625, 107500, 109650, 111025, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        92650, 94725, 96600, 98175, 100175, 102050, 104125, 105625, 107500, 109650, 111025, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        19100, 21150, 23075, 24625, 26600, 28525, 30575, 32050, 33975, 36100, 37575, 39625, 41550, 43025, 45075, 47000, 48975, 50525, 52450, 54500, 56000, 57875, 59950, 61450, 63325, 65400, 67400, 68850, 70850, 72850, 74300, 76300, 78300, 79750, 81750, 83825, 85700, 87200, 89275, 91150, 92650, 94725, 91150, 72925, 54500, 36175, 18325, 9162.5, 
                    },
                    minLevel = 10,
                    maxLevel = 57,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        29250, 104573, 179888, 255210, 330525, 405848, 481163, 556485, 631800, 707123, 782438, 857760, 933075, 1008398, 1083713, 1159035, 1234350, 1309673, 1384988, 1460310, 1535625, 1630405, 1725160, 1819940, 1914695, 2009475, 2104255, 2199010, 2293790, 2388545, 2483325, 2578105, 2672860, 2767640, 2862395, 2957175, 3050185, 3143195, 3236230, 3329240, 3422250, 3456478, 3490705, 3524908, 3559135, 3593363, 3627590, 3661818, 3696020, 3730248, 3764475, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3422250, 3456478, 3490705, 3524908, 3559135, 3593363, 3627590, 3661818, 3696020, 3730248, 3764475, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        29250, 104573, 179888, 255210, 330525, 405848, 481163, 556485, 631800, 707123, 782438, 857760, 933075, 1008398, 1083713, 1159035, 1234350, 1309673, 1384988, 1460310, 1535625, 1630405, 1725160, 1819940, 1914695, 2009475, 2104255, 2199010, 2293790, 2388545, 2483325, 2578105, 2672860, 2767640, 2862395, 2957175, 3050185, 3143195, 3236230, 3329240, 3422250, 3456478, 
                    },
                    minLevel = 10,
                    maxLevel = 51,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 200,
        },
    },
    items = {
        {
            type = "npc",
            id = 165107,
            locations = {
                [1533] = {
                    {
                        x = 0.482014,
                        y = 0.726004,
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
            id = 57709,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57710,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57711,
            x = 0,
            connections = {
                1.2, 2, 3, 4
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 57263,
            x = -3,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57267,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57265,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59920,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57713,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57908,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57909,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57288,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57714,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57291,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57266,
            x = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57715,
                },
                {
                    type = "quest",
                    id = 60217,
                },
                {
                    type = "quest",
                    id = 60218,
                },
                {
                    type = "quest",
                    id = 60219,
                },
                {
                    type = "quest",
                    id = 60220,
                },
                {
                    type = "quest",
                    id = 60221,
                },
                {
                    type = "quest",
                    id = 60222,
                },
                {
                    type = "quest",
                    id = 60223,
                },
                {
                    type = "quest",
                    id = 60224,
                },
                {
                    type = "quest",
                    id = 60225,
                },
                {
                    type = "quest",
                    id = 60226,
                },
                {
                    type = "quest",
                    id = 60229,
                },
            },
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 58174,
            x = -1,
        },
        {
            type = "quest",
            id = 60316,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheTempleOfPurity, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = {1056,1186},
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            upto = 57676,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAspirantsCrucible,
            x = 0,
        },
    },
    active = {
        type = "quest",
        id = 57270,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57447,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        13485, 14925, 16295, 17385, 18775, 20145, 21585, 22625, 23995, 25510, 26550, 27990, 29360, 30400, 31840, 33210, 34600, 35690, 37060, 38500, 39550, 40900, 42350, 43400, 44750, 46200, 47600, 48650, 50050, 51450, 52500, 53900, 55300, 56350, 57750, 59200, 60550, 61600, 63050, 64400, 65450, 66900, 68250, 69350, 70750, 72100, 73550, 74600, 75950, 77475, 78475, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        65450, 66900, 68250, 69350, 70750, 72100, 73550, 74600, 75950, 77475, 78475, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        13485, 14925, 16295, 17385, 18775, 20145, 21585, 22625, 23995, 25510, 26550, 27990, 29360, 30400, 31840, 33210, 34600, 35690, 37060, 38500, 39550, 40900, 42350, 43400, 44750, 46200, 47600, 48650, 50050, 51450, 52500, 53900, 55300, 56350, 57750, 59200, 60550, 61600, 63050, 64400, 65450, 66900, 64400, 51500, 38500, 25560, 12940, 6470, 
                    },
                    minLevel = 10,
                    maxLevel = 57,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        20650, 73828, 126998, 180175, 233345, 286523, 339693, 392870, 446040, 499218, 552388, 605565, 658735, 711913, 765083, 818260, 871430, 924608, 977778, 1030955, 1084125, 1151035, 1217935, 1284845, 1351745, 1418655, 1485565, 1552465, 1619375, 1686275, 1753185, 1820095, 1886995, 1953905, 2020805, 2087715, 2153380, 2219045, 2284720, 2350385, 2416050, 2440213, 2464375, 2488528, 2512690, 2536853, 2561015, 2585178, 2609330, 2633493, 2657655, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2416050, 2440213, 2464375, 2488528, 2512690, 2536853, 2561015, 2585178, 2609330, 2633493, 2657655, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        20650, 73828, 126998, 180175, 233345, 286523, 339693, 392870, 446040, 499218, 552388, 605565, 658735, 711913, 765083, 818260, 871430, 924608, 977778, 1030955, 1084125, 1151035, 1217935, 1284845, 1351745, 1418655, 1485565, 1552465, 1619375, 1686275, 1753185, 1820095, 1886995, 1953905, 2020805, 2087715, 2153380, 2219045, 2284720, 2350385, 2416050, 2440213, 
                    },
                    minLevel = 10,
                    maxLevel = 51,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 157673,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57270,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 57977,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57264,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57716,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57717,
            x = 0,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 57037,
            x = -3,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 59147,
            connections = {
                3,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57719,
                },
                {
                    type = "quest",
                    id = 60292,
                },
            },
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57444,
            aside = true,
        },
        {
            type = "quest",
            id = 57446,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57269,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57447,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ChasingAMemory, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = 1109,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            upto = 57676,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAspirantsCrucible,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfPurity,
        },
    },
    active = {
        type = "quest",
        id = 58976,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60013,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14530, 16100, 17610, 18730, 20250, 21760, 23280, 24450, 25910, 27430, 28600, 30120, 31580, 32750, 34270, 35730, 37300, 38420, 39980, 41500, 42575, 44125, 45650, 46725, 48275, 49800, 51275, 52475, 53950, 55425, 56625, 58100, 59575, 60775, 62250, 63775, 65325, 66400, 68025, 69475, 70550, 72175, 73625, 74750, 76325, 77775, 79300, 80475, 81925, 83450, 84600, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        70550, 72175, 73625, 74750, 76325, 77775, 79300, 80475, 81925, 83450, 84600, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        14530, 16100, 17610, 18730, 20250, 21760, 23280, 24450, 25910, 27430, 28600, 30120, 31580, 32750, 34270, 35730, 37300, 38420, 39980, 41500, 42575, 44125, 45650, 46725, 48275, 49800, 51275, 52475, 53950, 55425, 56625, 58100, 59575, 60775, 62250, 63775, 65325, 66400, 68025, 69475, 70550, 72175, 73625, 70550, 56575, 42500, 28440, 14020, 7015, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        22200, 79365, 136530, 193695, 250860, 308025, 365190, 422355, 479520, 536685, 593850, 651015, 708180, 765345, 822510, 879675, 936840, 994005, 1051170, 1108335, 1165500, 1237430, 1309355, 1381285, 1453210, 1525140, 1597070, 1668995, 1740925, 1812850, 1884780, 1956710, 2028635, 2100565, 2172490, 2244420, 2315015, 2385610, 2456210, 2526805, 2597400, 2623375, 2649350, 2675320, 2701295, 2727270, 2753245, 2779220, 2805190, 2831165, 2857140, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2597400, 2623375, 2649350, 2675320, 2701295, 2727270, 2753245, 2779220, 2805190, 2831165, 2857140, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        22200, 79365, 136530, 193695, 250860, 308025, 365190, 422355, 479520, 536685, 593850, 651015, 708180, 765345, 822510, 879675, 936840, 994005, 1051170, 1108335, 1165500, 1237430, 1309355, 1381285, 1453210, 1525140, 1597070, 1668995, 1740925, 1812850, 1884780, 1956710, 2028635, 2100565, 2172490, 2244420, 2315015, 2385610, 2456210, 2526805, 2597400, 2623375, 2649350, 
                    },
                    minLevel = 10,
                    maxLevel = 52,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 156238,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58976,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58771,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58799,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58800,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58977,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58978,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59015,
            aside = true,
        },
        {
            type = "quest",
            id = 58979,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58980,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58843,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60180,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60013,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ByTheArchonsWill, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 1068,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            upto = 57676,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAspirantsCrucible,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfPurity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ChasingAMemory,
        },
    },
    active = {
        type = "quest",
        id = 59196,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 59200,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8410, 9350, 10120, 10960, 11750, 12520, 13360, 14250, 14920, 15760, 16650, 17490, 18160, 19050, 19890, 20560, 21450, 22290, 23160, 24000, 24700, 25550, 26400, 27100, 27950, 28800, 29500, 30500, 31200, 31900, 32900, 33600, 34300, 35300, 36000, 36850, 37700, 38400, 39450, 40100, 40800, 41850, 42500, 43350, 44250, 44900, 45750, 46650, 47300, 48150, 49000, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        40800, 41850, 42500, 43350, 44250, 44900, 45750, 46650, 47300, 48150, 49000, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        8410, 9350, 10120, 10960, 11750, 12520, 13360, 14250, 14920, 15760, 16650, 17490, 18160, 19050, 19890, 20560, 21450, 22290, 23160, 24000, 24700, 25550, 26400, 27100, 27950, 28800, 29500, 30500, 31200, 31900, 32900, 33600, 34300, 35300, 36000, 36850, 37700, 38400, 39450, 40100, 40800, 41850, 42500, 40800, 32750, 24500, 16280, 8140, 4080, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        16400, 58630, 100860, 143090, 185320, 227550, 269780, 312010, 354240, 396470, 438700, 480930, 523160, 565390, 607620, 649850, 692080, 734310, 776540, 818770, 861000, 914140, 967270, 1020410, 1073540, 1126680, 1179820, 1232950, 1286090, 1339220, 1392360, 1445500, 1498630, 1551770, 1604900, 1658040, 1710190, 1762340, 1814500, 1866650, 1918800, 1937990, 1957180, 1976360, 1995550, 2014740, 2033930, 2053120, 2072300, 2091490, 2110680, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1918800, 1937990, 1957180, 1976360, 1995550, 2014740, 2033930, 2053120, 2072300, 2091490, 2110680, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        16400, 58630, 100860, 143090, 185320, 227550, 269780, 312010, 354240, 396470, 438700, 480930, 523160, 565390, 607620, 649850, 692080, 734310, 776540, 818770, 861000, 914140, 967270, 1020410, 1073540, 1126680, 1179820, 1232950, 1286090, 1339220, 1392360, 1445500, 1498630, 1551770, 1604900, 1658040, 1710190, 1762340, 1814500, 1866650, 1918800, 1937990, 1957180, 
                    },
                    minLevel = 10,
                    maxLevel = 52,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 200,
        },
    },
    items = {
        {
            type = "npc",
            id = 167038,
            x = 0,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "object",
            id = 348558,
            visible = {
                type = "quest",
                id = 57549,
                status = {'pending'},
                restrictions = {
                    type = "quest",
                    id = 59554,
                    status = {'pending'}
                },
            },
            aside = true,
            x = -3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 59196,
            x = 0,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            visible = {
                type = "quest",
                id = 57549,
                status = {'pending'},
                restrictions = {
                    type = "quest",
                    id = 59554,
                    status = {'pending'}
                },
            },
            aside = true,
            x = -3,
            y = 2,
        },
        {
            type = "quest",
            id = 59426,
            x = -1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59197,
            x = 0,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59198,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59199,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59200,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheTempleOfCourage, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    questline = {1066, 1187, 1133},
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 10,
                },
            },
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EternitysCall,
            upto = 57676,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAspirantsCrucible,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfPurity,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ChasingAMemory,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ByTheArchonsWill,
        },
    },
    active = {
        type = "quest",
        id = 60005,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60055,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        13100, 14440, 15660, 16700, 17940, 19160, 20500, 21440, 22660, 24000, 24940, 26280, 27500, 28440, 29780, 31000, 32240, 33280, 34500, 35840, 36790, 37990, 39340, 40290, 41490, 42840, 44090, 45090, 46340, 47590, 48590, 49840, 51090, 52090, 53340, 54690, 55890, 56840, 58190, 59390, 59590, 60940, 62140, 63190, 64440, 65640, 66990, 67940, 69140, 70490, 71390, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        100450, 102550, 104500, 106450, 108450, 110550, 112650, 114350, 116450, 118550, 120350, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        53210, 54550, 55770, 56810, 58050, 59270, 60610, 61550, 62770, 64110, 65050, 66390, 67610, 68550, 69890, 71110, 72350, 73390, 74610, 75950, 76900, 78100, 79450, 80400, 81600, 82950, 84200, 85200, 86450, 87700, 88700, 89950, 91200, 92200, 93450, 94800, 96000, 96950, 98300, 99500, 100450, 102550, 104500, 106450, 107200, 95650, 83750, 71820, 60060, 54480, 55380, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        956400, 1008930, 1061460, 1113990, 1166520, 1219050, 1271580, 1324110, 1376640, 1429170, 1481700, 1534230, 1586760, 1639290, 1691820, 1744350, 1796880, 1849410, 1901940, 1954470, 2007000, 2073100, 2139190, 2205290, 2271380, 2337480, 2403580, 2469670, 2535770, 2601860, 2667960, 2734060, 2800150, 2866250, 2932340, 2998440, 3063310, 3128180, 3193060, 3257930, 3322800, 3356030, 3389260, 3422480, 3455710, 3488940, 3522170, 3555400, 3588620, 3621850, 3655080, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3322800, 3356030, 3389260, 3422480, 3455710, 3488940, 3522170, 3555400, 3588620, 3621850, 3655080, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        956400, 1008930, 1061460, 1113990, 1166520, 1219050, 1271580, 1324110, 1376640, 1429170, 1481700, 1534230, 1586760, 1639290, 1691820, 1744350, 1796880, 1849410, 1901940, 1954470, 2007000, 2073100, 2139190, 2205290, 2271380, 2337480, 2403580, 2469670, 2535770, 2601860, 2667960, 2734060, 2800150, 2866250, 2932340, 2998440, 3063310, 3128180, 3193060, 3257930, 3322800, 3356030, 3389260, 3422480, 3431840, 3441200, 3450560, 3459920, 3469280, 3478640, 3488000, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 160037,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60005,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60006,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 60007,
            x = -2,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 60008,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 60009,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 60052,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 60053,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60054,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60055,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 60056,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 60057,
            aside = true,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    questline = 1151,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
    },
    completed = {
        type = "quest",
        id = 60466,
    },
    items = {
        {
            type = "npc",
            id = 160598,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60466,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62714,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62715,
            x = 0,
        },
    }
})
Database:AddChain(Chain.EmbedChain02, {
    questline = 1195,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
    },
    completed = {
        type = "quest",
        id = 57712,
    },
    items = {
        {
            type = "npc",
            id = 166738,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57712,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    questline = {1152, 1153},
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 50, restrictions = 86994, },
                { level = 51, },
            },
        },
    },
    completed = {
        type = "quest",
        ids = {60315, 60366},
        count = 2,
    },
    items = {
        {
            type = "object",
            id = 352027,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 60315,
            x = -1,
        },
        {
            type = "quest",
            id = 60366,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 3), -- In the Garden of Respite
    questline = 1149,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {
            57529, 57538, 57545, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 57568,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8925, 9900, 10800, 11550, 12450, 13350, 14325, 15000, 15900, 16875, 17550, 18525, 19425, 20100, 21075, 21975, 22875, 23625, 24525, 25500, 26175, 27075, 28050, 28725, 29625, 30600, 31500, 32250, 33150, 34050, 34800, 35700, 36600, 37350, 38250, 39225, 40125, 40800, 41775, 42675, 43350, 44325, 45225, 45975, 46875, 47775, 48750, 49425, 50325, 51300, 51975, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        43350, 44325, 45225, 45975, 46875, 47775, 48750, 49425, 50325, 51300, 51975, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        8925, 9900, 10800, 11550, 12450, 13350, 14325, 15000, 15900, 16875, 17550, 18525, 19425, 20100, 21075, 21975, 22875, 23625, 24525, 25500, 26175, 27075, 28050, 28725, 29625, 30600, 31500, 32250, 33150, 34050, 34800, 35700, 36600, 37350, 38250, 39225, 40125, 40800, 41775, 42675, 43350, 44325, 45225, 43350, 34725, 26100, 17475, 8625, 4312.5, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        15000, 53625, 92250, 130875, 169500, 208125, 246750, 285375, 324000, 362625, 401250, 439875, 478500, 517125, 555750, 594375, 633000, 671625, 710250, 748875, 787500, 836100, 884700, 933300, 981900, 1030500, 1079100, 1127700, 1176300, 1224900, 1273500, 1322100, 1370700, 1419300, 1467900, 1516500, 1564200, 1611900, 1659600, 1707300, 1755000, 1772550, 1790100, 1807650, 1825200, 1842750, 1860300, 1877850, 1895400, 1912950, 1930500, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1755000, 1772550, 1790100, 1807650, 1825200, 1842750, 1860300, 1877850, 1895400, 1912950, 1930500, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        15000, 53625, 92250, 130875, 169500, 208125, 246750, 285375, 324000, 362625, 401250, 439875, 478500, 517125, 555750, 594375, 633000, 671625, 710250, 748875, 787500, 836100, 884700, 933300, 981900, 1030500, 1079100, 1127700, 1176300, 1224900, 1273500, 1322100, 1370700, 1419300, 1467900, 1516500, 1564200, 1611900, 1659600, 1707300, 1755000, 1772550, 1790100, 
                    },
                    minLevel = 10,
                    maxLevel = 52,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 400,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 57529,
                    restrictions = {
                        type = "quest",
                        id = 57529,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 158004,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 57538,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 57545,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57547,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57568,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 1), -- In Agthia's Memory
    questline = 1148,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {59554, 57549},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57555,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11565, 12810, 13980, 14940, 16110, 17287.5, 18525, 19425, 20587.5, 21825, 22725, 23962.5, 25125, 26025, 27262.5, 28425, 29625, 30562.5, 31725, 33000, 33900, 35025, 36300, 37200, 38325, 39600, 40800, 41700, 42900, 44100, 45000, 46200, 47400, 48300, 49500, 50775, 51900, 52800, 54075, 55200, 56100, 57375, 58500, 59475, 60675, 61875, 63075, 63975, 65175, 66375, 67275, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        56100, 57375, 58500, 59475, 60675, 61875, 63075, 63975, 65175, 66375, 67275, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        11565, 12810, 13980, 14940, 16110, 17287.5, 18525, 19425, 20587.5, 21825, 22725, 23962.5, 25125, 26025, 27262.5, 28425, 29625, 30562.5, 31725, 33000, 33900, 35025, 36300, 37200, 38325, 39600, 40800, 41700, 42900, 44100, 45000, 46200, 47400, 48300, 49500, 50775, 51900, 52800, 54075, 55200, 56100, 57375, 58500, 56100, 44925, 33750, 22612.5, 11160, 5580, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        18750, 67035, 115313, 163598, 211875, 260160, 308438, 356723, 405000, 453285, 501563, 549848, 598125, 646410, 694688, 742973, 791250, 839535, 887813, 936098, 984375, 1045125, 1105875, 1166625, 1227375, 1288125, 1348875, 1409625, 1470375, 1531125, 1591875, 1652625, 1713375, 1774125, 1834875, 1895625, 1955250, 2014875, 2074500, 2134125, 2193750, 2215688, 2237625, 2259563, 2281500, 2303438, 2325375, 2347313, 2369250, 2391188, 2413125, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2193750, 2215688, 2237625, 2259563, 2281500, 2303438, 2325375, 2347313, 2369250, 2391188, 2413125, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        18750, 67035, 115313, 163598, 211875, 260160, 308438, 356723, 405000, 453285, 501563, 549848, 598125, 646410, 694688, 742973, 791250, 839535, 887813, 936098, 984375, 1045125, 1105875, 1166625, 1227375, 1288125, 1348875, 1409625, 1470375, 1531125, 1591875, 1652625, 1713375, 1774125, 1834875, 1895625, 1955250, 2014875, 2074500, 2134125, 2193750, 2215688, 2237625, 
                    },
                    minLevel = 10,
                    maxLevel = 52,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 500,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 59554,
                    restrictions = {
                        type = "quest",
                        id = 59554,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 158078,
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57549,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57551,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57552,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57554,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57553,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57555,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Part of the Pride
        type = "quest",
        id = 58037,
    },
    questline = 1150,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {58184, 58037},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 58042,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 38250, 39600, 40500, 41850, 43200, 44550, 45450, 46800, 48150, 49050, 50400, 51750, 52650, 54000, 55350, 56700, 57600, 58950, 60300, 61200, 62550, 63900, 64800, 66150, 67500, 68850, 69750, 71100, 72450, 73350, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        61200, 62550, 63900, 64800, 66150, 67500, 68850, 69750, 71100, 72450, 73350, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 38250, 39600, 40500, 41850, 43200, 44550, 45450, 46800, 48150, 49050, 50400, 51750, 52650, 54000, 55350, 56700, 57600, 58950, 60300, 61200, 62550, 63900, 61200, 49050, 36900, 24750, 12150, 6075, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 2127060, 2148120, 2169180, 2190240, 2211300, 2232360, 2253420, 2274480, 2295540, 2316600, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2106000, 2127060, 2148120, 2169180, 2190240, 2211300, 2232360, 2253420, 2274480, 2295540, 2316600, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 2127060, 2148120, 
                    },
                    minLevel = 10,
                    maxLevel = 52,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 600,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 58184,
                    restrictions = {
                        type = "quest",
                        id = 58184,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 157696,
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58037,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58038,
            x = -1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 58039,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58040,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58041,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58042,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- We Can Rebuild Him
        type = "quest",
        id = 57933,
    },
    questline = 1150,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 8,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {58185, 57931, 57932},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57937,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        16800, 18600, 20400, 21600, 23400, 25200, 27000, 28200, 30000, 31800, 33000, 34800, 36600, 37800, 39600, 41400, 43200, 44400, 46200, 48000, 49200, 51000, 52800, 54000, 55800, 57600, 59400, 60600, 62400, 64200, 65400, 67200, 69000, 70200, 72000, 73800, 75600, 76800, 78600, 80400, 81600, 83400, 85200, 86400, 88200, 90000, 91800, 93000, 94800, 96600, 97800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        81600, 83400, 85200, 86400, 88200, 90000, 91800, 93000, 94800, 96600, 97800, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        16800, 18600, 20400, 21600, 23400, 25200, 27000, 28200, 30000, 31800, 33000, 34800, 36600, 37800, 39600, 41400, 43200, 44400, 46200, 48000, 49200, 51000, 52800, 54000, 55800, 57600, 59400, 60600, 62400, 64200, 65400, 67200, 69000, 70200, 72000, 73800, 75600, 76800, 78600, 80400, 81600, 83400, 85200, 81600, 65400, 49200, 33000, 16200, 8100, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        24000, 85800, 147600, 209400, 271200, 333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 2836080, 2864160, 2892240, 2920320, 2948400, 2976480, 3004560, 3032640, 3060720, 3088800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2808000, 2836080, 2864160, 2892240, 2920320, 2948400, 2976480, 3004560, 3032640, 3060720, 3088800, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        24000, 85800, 147600, 209400, 271200, 333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 2836080, 2864160, 
                    },
                    minLevel = 10,
                    maxLevel = 52,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 800,
        },
    },
    items = {
        {
            type = "quest",
            id = 58185,
            x = 0,
            visible = {
                type = "quest",
                id = 58185,
                status = {'active', 'completed'}
            },
            connections = {
                3, 4
            },
        },
        {
            type = "npc",
            id = 158765,
            x = -1,
            y = 0,
            visible = {
                type = "quest",
                id = 58185,
                status = {'pending'}
            },
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 159609,
            visible = {
                type = "quest",
                id = 58185,
                status = {'pending'}
            },
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57931,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57932,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57933,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57934,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57935,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57936,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57937,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 5), -- Pride or Unit
    questline = 1150,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = Chain.Chain03,
        },
        {
            type = "chain",
            id = Chain.Chain04,
        },
    },
    active = {
        type = "chain",
        ids = {Chain.Chain03, Chain.Chain04},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {
            58103, 60296, 
        },
    },
    items = {
        {
            type = "npc",
            id = 157696,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 158765,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.Chain04,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            ids = {
                60296, 58103,
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 4), -- The Spear of Kalliope
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        ids = {57860, 59207},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {60906, 57967},
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amount = 55125,
                    restrictions = -1,
                },
                {
                    amount = 55125,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amount = 1737450,
                    restrictions = -1,
                },
                {
                    amount = 1737450,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 400,
        },
    },
    items = {
        {
            type = "npc",
            id = 159248,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57860,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59207,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57861,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57875,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57914,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57966,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57989,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            ids = {60906, 57967},
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 2), -- Wings of Freedom
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 59262,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59865,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amount = 70575,
                    restrictions = -1,
                },
                {
                    amount = 70575,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amount = 2220075,
                    restrictions = -1,
                },
                {
                    amount = 2220075,
                },
            },
        },
        {
            type = "reputation",
            id = 2407,
            amount = 700,
        },
    },
    items = {
        {
            type = "npc",
            id = 164640,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59262,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59263,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60660,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 59348,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59351,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59311,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59865,
            x = 0,
        },
    },
})
Database:AddChain(Chain.OtherAlliance, {
    name = "Other Alliance",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherHorde, {
    name = "Other Horde",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.OtherBoth, {
    name = "Other Both",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        { -- A Friendly Rivalry, not sure how best to handle this
            type = "quest",
            id = 59674,
        },
        { -- Newfound Power, maybe removed?
            type = "quest",
            id = 60235,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 3759913,
    items = {
        {
            type = "chain",
            id = Chain.EternitysCall,
        },
        {
            type = "chain",
            id = Chain.TheAspirantsCrucible,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfPurity,
        },
        {
            type = "chain",
            id = Chain.ChasingAMemory,
        },
        {
            type = "chain",
            id = Chain.ByTheArchonsWill,
        },
        {
            type = "chain",
            id = Chain.TheTempleOfCourage,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.Chain02,
        },
        {
            type = "chain",
            id = Chain.Chain03,
        },
        {
            type = "chain",
            id = Chain.Chain04,
        },
        {
            type = "chain",
            id = Chain.Chain05,
        },
        {
            type = "chain",
            id = Chain.Chain06,
        },
        {
            type = "chain",
            id = Chain.Chain07,
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
    {
        type = "chain",
        id = Chain.Chain01,
    },
    {
        type = "chain",
        id = Chain.Chain02,
    },
    {
        type = "chain",
        id = Chain.Chain03,
    },
    {
        type = "chain",
        id = Chain.Chain04,
    },
    {
        type = "chain",
        id = Chain.Chain05,
    },
    {
        type = "chain",
        id = Chain.Chain06,
    },
    {
        type = "chain",
        id = Chain.Chain07,
    },
})
