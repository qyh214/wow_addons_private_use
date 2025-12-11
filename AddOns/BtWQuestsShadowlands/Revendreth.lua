local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.Revendreth
local Chain = BtWQuests.Constant.Chain.Shadowlands.Revendreth
local MAP_ID = 1525
local CONTINENT_ID = 1550
local ACHIEVEMENT_ID = 13878
local SIDE_ACHIEVEMENT_ID = 14798
local LEVEL_RANGE = {57, 60}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 57,
    },
}

Database:AddChain(Chain.WelcomeToRevendreth, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = 985,
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
            id = 90306,
        },
    },
    active = {
        type = "quest",
        id = 57025,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56978,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14550, 16105, 17600, 18750, 20255, 21760, 23280, 24450, 25910, 27430, 28600, 30120, 31580, 32750, 34270, 35730, 37300, 38420, 39930, 41500, 42625, 44075, 45650, 46775, 48225, 49800, 51325, 52425, 53950, 55475, 56575, 58100, 59625, 60725, 62250, 63825, 65275, 66400, 68025, 69425, 70550, 72175, 73575, 74750, 76325, 77825, 79300, 80475, 81975, 83450, 84600, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        70550, 72175, 73575, 74750, 76325, 77825, 79300, 80475, 81975, 83450, 84600, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        14550, 16105, 17600, 18750, 20255, 21760, 23280, 24450, 25910, 27430, 28600, 30120, 31580, 32750, 34270, 35730, 37300, 38420, 39930, 41500, 42625, 44075, 45650, 46775, 48225, 49800, 51325, 52425, 53950, 55475, 56575, 58100, 59625, 60725, 62250, 63825, 65275, 66400, 68025, 69425, 70550, 72175, 73575, 74750, 76325, 77825, 79300, 80475, 81975, 80400, 68900, 
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
                        22200, 79370, 136530, 193700, 250860, 308030, 365190, 422360, 479520, 536690, 593850, 651020, 708180, 765350, 822510, 879680, 936840, 994010, 1051170, 1108340, 1165500, 1237430, 1309355, 1381285, 1453210, 1525140, 1597070, 1668995, 1740925, 1812850, 1884780, 1956710, 2028635, 2100565, 2172490, 2244420, 2315015, 2385610, 2456210, 2526805, 2597400, 2623375, 2649350, 2675320, 2701295, 2727270, 2753245, 2779220, 2805190, 2831165, 2857140, 
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
                        22200, 79370, 136530, 193700, 250860, 308030, 365190, 422360, 479520, 536690, 593850, 651020, 708180, 765350, 822510, 879680, 936840, 994010, 1051170, 1108340, 1165500, 1237430, 1309355, 1381285, 1453210, 1525140, 1597070, 1668995, 1740925, 1812850, 1884780, 1956710, 2028635, 2100565, 2172490, 2244420, 2315015, 2385610, 2456210, 2526805, 2597400, 2623375, 2649350, 2675320, 2701295, 2727270, 2753245, 2779220, 2805190, 2813380, 2821570, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 300,
        },
    },
    items = {
        {
            type = "npc",
            id = 159478,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57025,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57026,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            embed = true,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 57007,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 56829,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57381,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56942,
            x = 0,
            y = 5,
            connections = {
                3, 4,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
            aside = true,
            x = 3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            aside = true,
            x = -3,
            y = 6,
        },
        {
            type = "quest",
            id = 56955,
            x = -1,
            y = 6,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58433,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56978,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MeetTheMaster, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    questline = {994, 1145},
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
            id = Chain.WelcomeToRevendreth,
        },
    },
    active = {
        type = "quest",
        id = 57174,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57179,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15810, 16400, 16970, 17410, 18000, 18570, 19110, 19650, 20170, 20760, 21300, 21840, 22360, 22900, 23440, 23960, 24600, 25040, 25660, 26200, 26650, 27250, 27800, 28250, 28850, 29400, 29950, 30450, 31000, 31550, 32050, 32600, 33150, 33650, 34200, 34750, 35350, 35800, 36450, 36950, 37400, 38050, 38550, 39000, 39650, 40150, 40700, 41250, 41750, 42350, 42850, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        37400, 38050, 38550, 39000, 39650, 40150, 40700, 41250, 41750, 42350, 42850, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        15810, 16400, 16970, 17410, 18000, 18570, 19110, 19650, 20170, 20760, 21300, 21840, 22360, 22900, 23440, 23960, 24600, 25040, 25660, 26200, 26650, 27250, 27800, 28250, 28850, 29400, 29950, 30450, 31000, 31550, 32050, 32600, 33150, 33650, 34200, 34750, 35350, 35800, 36450, 36950, 37400, 38050, 38550, 39000, 39650, 40150, 40700, 41250, 41750, 40700, 34650, 
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
                        7900, 28245, 48585, 68930, 89270, 109615, 129955, 150300, 170640, 190985, 211325, 231670, 252010, 272355, 292695, 313040, 333380, 353725, 374065, 394410, 414750, 440350, 465940, 491540, 517130, 542730, 568330, 593920, 619520, 645110, 670710, 696310, 721900, 747500, 773090, 798690, 823810, 848930, 874060, 899180, 924300, 933545, 942790, 952025, 961270, 970515, 979760, 989005, 998240, 1007485, 1016730, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        924300, 933545, 942790, 952025, 961270, 970515, 979760, 989005, 998240, 1007485, 1016730, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        7900, 28245, 48585, 68930, 89270, 109615, 129955, 150300, 170640, 190985, 211325, 231670, 252010, 272355, 292695, 313040, 333380, 353725, 374065, 394410, 414750, 440350, 465940, 491540, 517130, 542730, 568330, 593920, 619520, 645110, 670710, 696310, 721900, 747500, 773090, 798690, 823810, 848930, 874060, 899180, 924300, 933545, 942790, 952025, 961270, 970515, 979760, 989005, 998240, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 156374,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            embed = true,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 57174,
            x = 0,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            embed = true,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 58654,
            x = -1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 60176,
            aside = true,
        },
        {
            visible = false,
        },
        {
            type = "quest",
            id = 57178,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57179,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheAccusersSecret, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = 995,
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
            id = Chain.WelcomeToRevendreth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MeetTheMaster,
        },
    },
    active = {
        type = "quest",
        id = 57161,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57180,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        16470, 18230, 19940, 21220, 22930, 24650, 26350, 27700, 29350, 31050, 32400, 34100, 35750, 37100, 38800, 40450, 42250, 43500, 45250, 47000, 48250, 49950, 51700, 52950, 54650, 56400, 58100, 59400, 61100, 62800, 64100, 65800, 67500, 68800, 70500, 72250, 73950, 75200, 77050, 78650, 79900, 81750, 83350, 84650, 86450, 88150, 89800, 91150, 92850, 94500, 95850, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        79900, 81750, 83350, 84650, 86450, 88150, 89800, 91150, 92850, 94500, 95850, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        16470, 18230, 19940, 21220, 22930, 24650, 26350, 27700, 29350, 31050, 32400, 34100, 35750, 37100, 38800, 40450, 42250, 43500, 45250, 47000, 48250, 49950, 51700, 52950, 54650, 56400, 58100, 59400, 61100, 62800, 64100, 65800, 67500, 68800, 70500, 72250, 73950, 75200, 77050, 78650, 79900, 81750, 83350, 84650, 86450, 88150, 89800, 91150, 92850, 90600, 75700, 
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
                        25000, 89380, 153750, 218130, 282500, 346880, 411250, 475630, 540000, 604380, 668750, 733130, 797500, 861880, 926250, 990630, 1055000, 1119380, 1183750, 1248130, 1312500, 1393500, 1474500, 1555500, 1636500, 1717500, 1798500, 1879500, 1960500, 2041500, 2122500, 2203500, 2284500, 2365500, 2446500, 2527500, 2607000, 2686500, 2766000, 2845500, 2925000, 2954250, 2983500, 3012750, 3042000, 3071250, 3100500, 3129750, 3159000, 3188250, 3217500, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2925000, 2954250, 2983500, 3012750, 3042000, 3071250, 3100500, 3129750, 3159000, 3188250, 3217500, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        25000, 89380, 153750, 218130, 282500, 346880, 411250, 475630, 540000, 604380, 668750, 733130, 797500, 861880, 926250, 990630, 1055000, 1119380, 1183750, 1248130, 1312500, 1393500, 1474500, 1555500, 1636500, 1717500, 1798500, 1879500, 1960500, 2041500, 2122500, 2203500, 2284500, 2365500, 2446500, 2527500, 2607000, 2686500, 2766000, 2845500, 2925000, 2954250, 2983500, 3012750, 3042000, 3071250, 3100500, 3129750, 3159000, 3163680, 3168360, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 156605,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57161,
            x = 0,
            connections = {
                2,
            },
        },
        { -- Padding
            visible = false,
            x = -3,
        },
        {
            type = "quest",
            id = 57173,
            x = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 58931,
            x = -1,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58932,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59021,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57175,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57177,
            aside = true,
        },
        {
            type = "quest",
            id = 59023,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57176,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57180,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57182,
            aside = true,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59232,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheRebellion, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = {996, 1178, 1192, 1189},
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
            id = Chain.WelcomeToRevendreth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MeetTheMaster,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAccusersSecret,
            upto = 59232,
        },
    },
    active = {
        type = "quest",
        id = 57098,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 59256,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        24170, 26790, 29240, 31220, 33690, 36145, 38685, 40675, 43045, 45585, 47575, 50115, 52485, 54475, 57015, 59385, 61950, 63915, 66435, 69000, 70850, 73325, 75900, 77750, 80225, 82800, 85225, 87275, 89700, 92125, 94175, 96600, 99025, 101075, 103500, 106075, 108550, 110400, 113125, 115450, 117300, 120025, 122350, 124350, 126925, 129300, 131825, 133825, 136200, 138725, 140675, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        117300, 120025, 122350, 124350, 126925, 129300, 131825, 133825, 136200, 138725, 140675, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        24170, 26790, 29240, 31220, 33690, 36145, 38685, 40675, 43045, 45585, 47575, 50115, 52485, 54475, 57015, 59385, 61950, 63915, 66435, 69000, 70850, 73325, 75900, 77750, 80225, 82800, 85225, 87275, 89700, 92125, 94175, 96600, 99025, 101075, 103500, 106075, 108550, 110400, 113125, 115450, 117300, 120025, 122350, 124350, 126925, 129300, 131825, 133825, 136200, 138725, 136425, 
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
                        44900, 160520, 276135, 391755, 507370, 622990, 738605, 854225, 969840, 1085460, 1201075, 1316695, 1432310, 1547930, 1663545, 1779165, 1894780, 2010400, 2126015, 2241635, 2357250, 2502730, 2648200, 2793680, 2939150, 3084630, 3230110, 3375580, 3521060, 3666530, 3812010, 3957490, 4102960, 4248440, 4393910, 4539390, 4682170, 4824950, 4967740, 5110520, 5253300, 5305835, 5358370, 5410895, 5463430, 5515965, 5568500, 5621035, 5673560, 5726095, 5778630, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5253300, 5305835, 5358370, 5410895, 5463430, 5515965, 5568500, 5621035, 5673560, 5726095, 5778630, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        44900, 160520, 276135, 391755, 507370, 622990, 738605, 854225, 969840, 1085460, 1201075, 1316695, 1432310, 1547930, 1663545, 1779165, 1894780, 2010400, 2126015, 2241635, 2357250, 2502730, 2648200, 2793680, 2939150, 3084630, 3230110, 3375580, 3521060, 3666530, 3812010, 3957490, 4102960, 4248440, 4393910, 4539390, 4682170, 4824950, 4967740, 5110520, 5253300, 5305835, 5358370, 5410895, 5463430, 5515965, 5568500, 5621035, 5673560, 5726095, 5748325, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 600,
        },
    },
    items = {
        {
            type = "npc",
            id = 156381,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57098,
            x = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "object",
            id = 355296,
            aside = true,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58916,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58936,
            aside = true,
        },
        {
            type = "quest",
            id = 58941,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59014,
            x = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "npc",
            id = 156384,
            aside = true,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57131,
            x = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 60514,
            aside = true,
        },
        {
            type = "quest",
            id = 57136,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57164,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60506,
            x = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "npc",
            id = 156384,
            aside = true,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57159,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58996,
            aside = true,
        },
        {
            type = "quest",
            id = 60313,
            x = 0,
            connections = {
                1, 2, 3, 4
            },
        },
        {
            type = "quest",
            id = 57189,
            variations = {
                {
                    x = -3,
                    restrictions = 87203,
                },
                {
                    x = -2,
                }
            },
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 59209,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57190,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59211,
            restrictions = 87203,
        },
        {
            type = "quest",
            id = 59256,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SecuringSinfall, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 998,
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
            id = Chain.WelcomeToRevendreth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MeetTheMaster,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAccusersSecret,
            upto = 59232,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheRebellion,
        },
    },
    active = {
        type = "quest",
        id = 57240,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57724,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        28760, 30525, 32120, 33610, 35225, 36820, 38560, 39950, 41520, 43310, 44700, 46440, 48010, 49400, 51140, 52710, 54350, 55840, 57460, 59200, 60600, 62200, 63950, 65300, 66900, 68650, 70250, 71750, 73350, 74950, 76450, 78050, 79650, 81150, 82750, 84500, 86100, 87450, 89250, 90800, 92200, 94000, 95550, 97050, 98700, 100250, 102000, 103400, 104950, 106750, 108100, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        92200, 94000, 95550, 97050, 98700, 100250, 102000, 103400, 104950, 106750, 108100, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        28760, 30525, 32120, 33610, 35225, 36820, 38560, 39950, 41520, 43310, 44700, 46440, 48010, 49400, 51140, 52710, 54350, 55840, 57460, 59200, 60600, 62200, 63950, 65300, 66900, 68650, 70250, 71750, 73350, 74950, 76450, 78050, 79650, 81150, 82750, 84500, 86100, 87450, 89250, 90800, 92200, 94000, 95550, 97050, 98700, 100250, 102000, 103400, 104950, 106750, 103900, 
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
                        20900, 74720, 128535, 182355, 236170, 289990, 343805, 397625, 451440, 505260, 559075, 612895, 666710, 720530, 774345, 828165, 881980, 935800, 989615, 1043435, 1097250, 1164970, 1232680, 1300400, 1368110, 1435830, 1503550, 1571260, 1638980, 1706690, 1774410, 1842130, 1909840, 1977560, 2045270, 2112990, 2179450, 2245910, 2312380, 2378840, 2445300, 2469755, 2494210, 2518655, 2543110, 2567565, 2592020, 2616475, 2640920, 2665375, 2689830, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2445300, 2469755, 2494210, 2518655, 2543110, 2567565, 2592020, 2616475, 2640920, 2665375, 2689830, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        20900, 74720, 128535, 182355, 236170, 289990, 343805, 397625, 451440, 505260, 559075, 612895, 666710, 720530, 774345, 828165, 881980, 935800, 989615, 1043435, 1097250, 1164970, 1232680, 1300400, 1368110, 1435830, 1503550, 1571260, 1638980, 1706690, 1774410, 1842130, 1909840, 1977560, 2045270, 2112990, 2179450, 2245910, 2312380, 2378840, 2445300, 2469755, 2494210, 2518655, 2543110, 2567565, 2592020, 2616475, 2640920, 2665375, 
                    },
                    minLevel = 10,
                    maxLevel = 59,
                },
            },
        },
        {
            type = "currency",
            id = 1820,
            amount = 35,
        },
        {
            type = "reputation",
            id = 2413,
            amount = 575,
        },
    },
    items = {
        {
            type = "npc",
            id = 168217,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57240,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57380,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57405,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57426,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57427,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57428,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57442,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
            aside = true,
            x = -2,
            y = 6,
        },
        {
            type = "quest",
            id = 57460,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57461,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 60566,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 57724,
            x = 0,
            y = 9,
        },
    },
})
Database:AddChain(Chain.ThePrinceAndTheTower, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    questline = 1005,
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
            id = Chain.WelcomeToRevendreth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MeetTheMaster,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAccusersSecret,
            upto = 59232,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheRebellion,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SecuringSinfall,
        },
    },
    active = {
        type = "quest",
        id = 59327,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57694,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5780, 6425, 6960, 7530, 8075, 8610, 9180, 9800, 10260, 10830, 11450, 12020, 12480, 13100, 13670, 14130, 14750, 15320, 15930, 16500, 16975, 17575, 18150, 18625, 19225, 19800, 20275, 20975, 21450, 21925, 22625, 23100, 23575, 24275, 24750, 25325, 25925, 26400, 27125, 27575, 28050, 28775, 29225, 29800, 30425, 30875, 31450, 32075, 32525, 33100, 33700, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        28050, 28775, 29225, 29800, 30425, 30875, 31450, 32075, 32525, 33100, 33700, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        5780, 6425, 6960, 7530, 8075, 8610, 9180, 9800, 10260, 10830, 11450, 12020, 12480, 13100, 13670, 14130, 14750, 15320, 15930, 16500, 16975, 17575, 18150, 18625, 19225, 19800, 20275, 20975, 21450, 21925, 22625, 23100, 23575, 24275, 24750, 25325, 25925, 26400, 27125, 27575, 28050, 28775, 29225, 29800, 30425, 30875, 31450, 32075, 32525, 33100, 32075, 
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
                        11200, 40040, 68880, 97720, 126560, 155400, 184240, 213080, 241920, 270760, 299600, 328440, 357280, 386120, 414960, 443800, 472640, 501480, 530320, 559160, 588000, 624290, 660575, 696865, 733150, 769440, 805730, 842015, 878305, 914590, 950880, 987170, 1023455, 1059745, 1096030, 1132320, 1167935, 1203550, 1239170, 1274785, 1310400, 1323505, 1336610, 1349710, 1362815, 1375920, 1389025, 1402130, 1415230, 1428335, 1441440, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1310400, 1323505, 1336610, 1349710, 1362815, 1375920, 1389025, 1402130, 1415230, 1428335, 1441440, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        11200, 40040, 68880, 97720, 126560, 155400, 184240, 213080, 241920, 270760, 299600, 328440, 357280, 386120, 414960, 443800, 472640, 501480, 530320, 559160, 588000, 624290, 660575, 696865, 733150, 769440, 805730, 842015, 878305, 914590, 950880, 987170, 1023455, 1059745, 1096030, 1132320, 1167935, 1203550, 1239170, 1274785, 1310400, 1323505, 1336610, 1349710, 1362815, 1375920, 1389025, 1402130, 1415230, 1428335, 
                    },
                    minLevel = 10,
                    maxLevel = 59,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 158716,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59327,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57689,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57690,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57691,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57693,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57694,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MenagerieOfTheMaster, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    questline = {1038, 1010, 1137},
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
                    level = 58,
                },
            },
        },
        {
            type = "chain",
            id = Chain.WelcomeToRevendreth,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MeetTheMaster,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAccusersSecret,
            upto = 59232,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheRebellion,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SecuringSinfall,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ThePrinceAndTheTower,
        },
    },
    active = {
        type = "quest",
        id = 59644,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58086,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12450, 12875, 13300, 13650, 14075, 14500, 14900, 15300, 15700, 16100, 16500, 16900, 17300, 17700, 18100, 18500, 18950, 19300, 19750, 20150, 20550, 21000, 21400, 21750, 22200, 22600, 23000, 23400, 23800, 24200, 24600, 25000, 25400, 25800, 26200, 26600, 27050, 27400, 27850, 28250, 28650, 29100, 29500, 29850, 30300, 30700, 31100, 31500, 31900, 32300, 32700, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        28650, 29100, 29500, 29850, 30300, 30700, 31100, 31500, 31900, 32300, 32700, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 32700,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        266400, 289575, 312750, 335925, 359100, 382275, 405450, 428625, 451800, 474975, 498150, 521325, 544500, 567675, 590850, 614025, 637200, 660375, 683550, 706725, 729900, 759060, 788220, 817380, 846540, 875700, 904860, 934020, 963180, 992340, 1021500, 1050660, 1079820, 1108980, 1138140, 1167300, 1195920, 1224540, 1253160, 1281780, 1310400, 1320930, 1331460, 1341990, 1352520, 1363050, 1373580, 1384110, 1394640, 1405170, 1415700, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1310400, 1320930, 1331460, 1341990, 1352520, 1363050, 1373580, 1384110, 1394640, 1405170, 1415700, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 1415700,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 162688,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59644,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58086,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57876,
            aside = true,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57877,
            aside = true,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57878,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 3), -- Dirty Jobs
    questline = 1141,
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
        {
            type = "chain",
            id = Chain.WelcomeToRevendreth,
            upto = 56942,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {60509, 57471},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57481,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4910, 5440, 5920, 6360, 6840, 7325, 7850, 8250, 8725, 9250, 9650, 10175, 10650, 11050, 11575, 12050, 12550, 12975, 13450, 14000, 14400, 14850, 15400, 15800, 16250, 16800, 17300, 17700, 18200, 18700, 19100, 19600, 20100, 20500, 21000, 21550, 22000, 22400, 22950, 23400, 23800, 24350, 24800, 25250, 25750, 26250, 26750, 27150, 27650, 28150, 28550, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        23800, 24350, 24800, 25250, 25750, 26250, 26750, 27150, 27650, 28150, 28550, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        4910, 5440, 5920, 6360, 6840, 7325, 7850, 8250, 8725, 9250, 9650, 10175, 10650, 11050, 11575, 12050, 12550, 12975, 13450, 14000, 14400, 14850, 15400, 15800, 16250, 16800, 17300, 17700, 18200, 18700, 19100, 19600, 20100, 20500, 21000, 21550, 22000, 22400, 22950, 23400, 23800, 24350, 24800, 25250, 25750, 26250, 26750, 27150, 27650, 26750, 21300, 
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
                        8500, 30390, 52275, 74165, 96050, 117940, 139825, 161715, 183600, 205490, 227375, 249265, 271150, 293040, 314925, 336815, 358700, 380590, 402475, 424365, 446250, 473790, 501330, 528870, 556410, 583950, 611490, 639030, 666570, 694110, 721650, 749190, 776730, 804270, 831810, 859350, 886380, 913410, 940440, 967470, 994500, 1004445, 1014390, 1024335, 1034280, 1044225, 1054170, 1064115, 1074060, 1084005, 1093950, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        994500, 1004445, 1014390, 1024335, 1034280, 1044225, 1054170, 1064115, 1074060, 1084005, 1093950, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        8500, 30390, 52275, 74165, 96050, 117940, 139825, 161715, 183600, 205490, 227375, 249265, 271150, 293040, 314925, 336815, 358700, 380590, 402475, 424365, 446250, 473790, 501330, 528870, 556410, 583950, 611490, 639030, 666570, 694110, 721650, 749190, 776730, 804270, 831810, 859350, 886380, 913410, 940440, 967470, 994500, 1004445, 1014390, 1024335, 1034280, 1044225, 1054170, 1064115, 1074060, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 300,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 60509,
                    restrictions = {
                        type = "quest",
                        id = 60509,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 157846,
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57471,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57474,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57477,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57481,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 1), -- The Duelist's Debt
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    questline = 1142,
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
            id = Chain.MeetTheMaster,
            upto = 57174,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        id = 59710,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 59726,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        20755, 22937.5, 25035, 26730, 28837.5, 30935, 33005, 34850, 36835, 38905, 40750, 42820, 44805, 46650, 48720, 50705, 52925, 54620, 56830, 58900, 60625, 62825, 64900, 66525, 68725, 70800, 72800, 74700, 76700, 78700, 80600, 82600, 84600, 86500, 88500, 90575, 92775, 94400, 96700, 98675, 100400, 102700, 104675, 106375, 108600, 110575, 112650, 114500, 116475, 118550, 120375, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        100400, 102700, 104675, 106375, 108600, 110575, 112650, 114500, 116475, 118550, 120375, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        20755, 22937.5, 25035, 26730, 28837.5, 30935, 33005, 34850, 36835, 38905, 40750, 42820, 44805, 46650, 48720, 50705, 52925, 54620, 56830, 58900, 60625, 62825, 64900, 66525, 68725, 70800, 72800, 74700, 76700, 78700, 80600, 82600, 84600, 86500, 88500, 90575, 92775, 94400, 96700, 98675, 100400, 102700, 104675, 106375, 108600, 110575, 112650, 114500, 116475, 112650, 89950, 
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
                        25700, 91879, 158055, 224234, 290410, 356589, 422765, 488944, 555120, 621299, 687475, 753654, 819830, 886009, 952185, 1018364, 1084540, 1150719, 1216895, 1283074, 1349250, 1432520, 1515785, 1599055, 1682320, 1765590, 1848860, 1932125, 2015395, 2098660, 2181930, 2265200, 2348465, 2431735, 2515000, 2598270, 2679995, 2761720, 2843450, 2925175, 3006900, 3036970, 3067040, 3097105, 3127175, 3157245, 3187315, 3217385, 3247450, 3277520, 3307590, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3006900, 3036970, 3067040, 3097105, 3127175, 3157245, 3187315, 3217385, 3247450, 3277520, 3307590, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        25700, 91879, 158055, 224234, 290410, 356589, 422765, 488944, 555120, 621299, 687475, 753654, 819830, 886009, 952185, 1018364, 1084540, 1150719, 1216895, 1283074, 1349250, 1432520, 1515785, 1599055, 1682320, 1765590, 1848860, 1932125, 2015395, 2098660, 2181930, 2265200, 2348465, 2431735, 2515000, 2598270, 2679995, 2761720, 2843450, 2925175, 3006900, 3036970, 3067040, 3097105, 3127175, 3157245, 3187315, 3217385, 3247450, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 1050,
        },
    },
    items = {
        {
            type = "npc",
            id = 165859,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59710,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59712,
            x = 0,
            connections = {
                2,
            },
        },
        {
            visible = false,
            x = -3,
        },
        {
            type = "quest",
            id = 59846,
            x = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            embed = true,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 59713,
            x = -1,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59714,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59715,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59716,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 59724,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59868,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59726,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- The Night Market
        type = "quest",
        id = 58060,
    },
    questline = 1185,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = Chain.TheRebellion,
            upto = 60506,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        id = 58060,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58062,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amount = 3050,
                    restrictions = -1,
                },
                {
                    amount = 3050,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amount = 90090,
                    restrictions = -1,
                },
                {
                    amount = 90090,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 160100,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58060,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58062,
            x = 0,
        },
    --[[
        {
            type = "kill",
            id = 156395,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58079,
            x = 0,
        },

        {
            type = "kill",
            id = 158420,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58077,
            x = 0,
        },
    ]]
    },
})
Database:AddChain(Chain.Chain04, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 6), -- Revelations of the Light
    questline = 1147,
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
        id = 60467,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60470,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8400, 9300, 10200, 10800, 11700, 12600, 13500, 14100, 15000, 15900, 16500, 17400, 18300, 18900, 19800, 20700, 21600, 22200, 23100, 24000, 24600, 25500, 26400, 27000, 27900, 28800, 29700, 30300, 31200, 32100, 32700, 33600, 34500, 35100, 36000, 36900, 37800, 38400, 39300, 40200, 40800, 41700, 42600, 43200, 44100, 45000, 45900, 46500, 47400, 48300, 48900, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        40800, 41700, 42600, 43200, 44100, 45000, 45900, 46500, 47400, 48300, 48900, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        8400, 9300, 10200, 10800, 11700, 12600, 13500, 14100, 15000, 15900, 16500, 17400, 18300, 18900, 19800, 20700, 21600, 22200, 23100, 24000, 24600, 25500, 26400, 27000, 27900, 28800, 29700, 30300, 31200, 32100, 32700, 33600, 34500, 35100, 36000, 36900, 37800, 38400, 39300, 40200, 40800, 41700, 42600, 43200, 44100, 45000, 45900, 46500, 47400, 48300, 46500, 
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
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 1418040, 1432080, 1446120, 1460160, 1474200, 1488240, 1502280, 1516320, 1530360, 1544400, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1404000, 1418040, 1432080, 1446120, 1460160, 1474200, 1488240, 1502280, 1516320, 1530360, 1544400, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 1418040, 1432080, 1446120, 1460160, 1474200, 1488240, 1502280, 1516320, 1530360, 
                    },
                    minLevel = 10,
                    maxLevel = 59,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 400,
        },
    },
    items = {
        {
            type = "npc",
            id = 168455,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60467,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 60469,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 60468,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60470,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 5), -- Mirror Maker of the Master
    questline = 1146,
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
            60051, 57531, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 57536,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17325, 19200, 21000, 22350, 24150, 25950, 27825, 29100, 30900, 32775, 34050, 35925, 37725, 39000, 40875, 42675, 44475, 45825, 47625, 49500, 50775, 52575, 54450, 55725, 57525, 59400, 61200, 62550, 64350, 66150, 67500, 69300, 71100, 72450, 74250, 76125, 77925, 79200, 81075, 82875, 84150, 86025, 87825, 89175, 90975, 92775, 94650, 95925, 97725, 99600, 100875, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        84150, 86025, 87825, 89175, 90975, 92775, 94650, 95925, 97725, 99600, 100875, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        17325, 19200, 21000, 22350, 24150, 25950, 27825, 29100, 30900, 32775, 34050, 35925, 37725, 39000, 40875, 42675, 44475, 45825, 47625, 49500, 50775, 52575, 54450, 55725, 57525, 59400, 61200, 62550, 64350, 66150, 67500, 69300, 71100, 72450, 74250, 76125, 77925, 79200, 81075, 82875, 84150, 86025, 87825, 89175, 90975, 92775, 94650, 95925, 97725, 99600, 95925, 
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
                        27000, 96525, 166050, 235575, 305100, 374625, 444150, 513675, 583200, 652725, 722250, 791775, 861300, 930825, 1000350, 1069875, 1139400, 1208925, 1278450, 1347975, 1417500, 1504980, 1592460, 1679940, 1767420, 1854900, 1942380, 2029860, 2117340, 2204820, 2292300, 2379780, 2467260, 2554740, 2642220, 2729700, 2815560, 2901420, 2987280, 3073140, 3159000, 3190590, 3222180, 3253770, 3285360, 3316950, 3348540, 3380130, 3411720, 3443310, 3474900, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3159000, 3190590, 3222180, 3253770, 3285360, 3316950, 3348540, 3380130, 3411720, 3443310, 3474900, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        27000, 96525, 166050, 235575, 305100, 374625, 444150, 513675, 583200, 652725, 722250, 791775, 861300, 930825, 1000350, 1069875, 1139400, 1208925, 1278450, 1347975, 1417500, 1504980, 1592460, 1679940, 1767420, 1854900, 1942380, 2029860, 2117340, 2204820, 2292300, 2379780, 2467260, 2554740, 2642220, 2729700, 2815560, 2901420, 2987280, 3073140, 3159000, 3190590, 3222180, 3253770, 3285360, 3316950, 3348540, 3380130, 3411720, 3443310, 
                    },
                    minLevel = 10,
                    maxLevel = 59,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 950,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 60051,
                    restrictions = {
                        type = "quest",
                        id = 60051,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 158038,
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57531,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57532,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57571,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57533,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57534,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57535,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59427,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57536,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = BtWQuests.GetAreaName(11002), -- Old Gate
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
        ids = {60280, 60278},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {60280, 60278},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amount = 12250,
                    restrictions = -1,
                },
                {
                    amount = 12250,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 550,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain11,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 4), -- The Final Atonement
    questline = 1144,
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
        id = 57919,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58092,
    },
    rewards = {
        {
            name = L["HALLS_OF_ATONEMENT_VENTHYR_RITUALS"],
            type = "spell",
            id = 312427,
        },
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        27040, 29750, 32180, 34940, 37400, 39980, 42690, 45050, 47630, 50440, 52950, 55660, 58090, 60600, 63310, 65890, 68350, 70960, 73540, 76250, 78875, 81275, 84000, 86525, 88925, 91800, 94275, 96825, 99450, 101925, 104625, 107100, 109575, 112275, 114750, 117625, 120025, 122400, 125275, 127675, 130300, 133025, 135425, 138200, 140675, 143225, 145950, 148325, 150875, 153700, 156150, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        130300, 133025, 135425, 138200, 140675, 143225, 145950, 148325, 150875, 153700, 156150, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        27040, 29750, 32180, 34940, 37400, 39980, 42690, 45050, 47630, 50440, 52950, 55660, 58090, 60600, 63310, 65890, 68350, 70960, 73540, 76250, 78875, 81275, 84000, 86525, 88925, 91800, 94275, 96825, 99450, 101925, 104625, 107100, 109575, 112275, 114750, 117625, 120025, 122400, 125275, 127675, 130300, 133025, 135425, 138200, 140675, 143225, 145950, 148325, 150875, 145950, 116625, 
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
                        47600, 170175, 292740, 415315, 537880, 660455, 783020, 905595, 1028160, 1150735, 1273300, 1395875, 1518440, 1641015, 1763580, 1886155, 2008720, 2131295, 2253860, 2376435, 2499000, 2653230, 2807445, 2961675, 3115890, 3270120, 3424350, 3578565, 3732795, 3887010, 4041240, 4195470, 4349685, 4503915, 4658130, 4812360, 4963725, 5115090, 5266470, 5417835, 5569200, 5624895, 5680590, 5736270, 5791965, 5847660, 5903355, 5959050, 6014730, 6070425, 6126120, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5569200, 5624895, 5680590, 5736270, 5791965, 5847660, 5903355, 5959050, 6014730, 6070425, 6126120, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        47600, 170175, 292740, 415315, 537880, 660455, 783020, 905595, 1028160, 1150735, 1273300, 1395875, 1518440, 1641015, 1763580, 1886155, 2008720, 2131295, 2253860, 2376435, 2499000, 2653230, 2807445, 2961675, 3115890, 3270120, 3424350, 3578565, 3732795, 3887010, 4041240, 4195470, 4349685, 4503915, 4658130, 4812360, 4963725, 5115090, 5266470, 5417835, 5569200, 5624895, 5680590, 5736270, 5791965, 5847660, 5903355, 5959050, 6014730, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "reputation",
            id = 2439,
            amount = 1500,
        },
    },
    items = {
        {
            type = "npc",
            id = 160116,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57919,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57920,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57921,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57922,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57923,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57924,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57925,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57926,
            x = -2,
            connections = {
                6,
            },
        },
        {
            type = "quest",
            id = 60127,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57928,
            aside = true,
        },
        {
            type = "quest",
            id = 57927,
            x = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 60128,
            x = 0,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57929,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58092,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain08, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 2), -- Tithes of Darkhaven
    questline = 1145,
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
        ids = {60177, 60176},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60178,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        3500, 3875, 4250, 4500, 4875, 5250, 5600, 5900, 6250, 6600, 6900, 7250, 7600, 7900, 8250, 8600, 9000, 9250, 9650, 10000, 10250, 10650, 11000, 11250, 11650, 12000, 12350, 12650, 13000, 13350, 13650, 14000, 14350, 14650, 15000, 15350, 15750, 16000, 16400, 16750, 17000, 17400, 17750, 18000, 18400, 18750, 19100, 19400, 19750, 20100, 20400, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17000, 17400, 17750, 18000, 18400, 18750, 19100, 19400, 19750, 20100, 20400, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        3500, 3875, 4250, 4500, 4875, 5250, 5600, 5900, 6250, 6600, 6900, 7250, 7600, 7900, 8250, 8600, 9000, 9250, 9650, 10000, 10250, 10650, 11000, 11250, 11650, 12000, 12350, 12650, 13000, 13350, 13650, 14000, 14350, 14650, 15000, 15350, 15750, 16000, 16400, 16750, 17000, 17400, 17750, 18000, 18400, 18750, 19100, 19400, 19750, 19100, 15250, 
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
                        5000, 17875, 30750, 43625, 56500, 69375, 82250, 95125, 108000, 120875, 133750, 146625, 159500, 172375, 185250, 198125, 211000, 223875, 236750, 249625, 262500, 278700, 294900, 311100, 327300, 343500, 359700, 375900, 392100, 408300, 424500, 440700, 456900, 473100, 489300, 505500, 521400, 537300, 553200, 569100, 585000, 590850, 596700, 602550, 608400, 614250, 620100, 625950, 631800, 637650, 643500, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        585000, 590850, 596700, 602550, 608400, 614250, 620100, 625950, 631800, 637650, 643500, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        5000, 17875, 30750, 43625, 56500, 69375, 82250, 95125, 108000, 120875, 133750, 146625, 159500, 172375, 185250, 198125, 211000, 223875, 236750, 249625, 262500, 278700, 294900, 311100, 327300, 343500, 359700, 375900, 392100, 408300, 424500, 440700, 456900, 473100, 489300, 505500, 521400, 537300, 553200, 569100, 585000, 590850, 596700, 602550, 608400, 614250, 620100, 625950, 631800, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "reputation",
            id = 2413,
            amount = 200,
        },
    },
    items = {
        {
            type = "npc",
            id = 167489,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 156822,
            aside = true,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 60177,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 60176,
            aside = true,
        },
        {
            type = "quest",
            id = 60178,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain09, {
    name = { -- Bell of Remembrance
        type = "quest",
        id = 58717,
    },
    questline = 1193,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            name = "Unknown",
        }
    },
    active = {
        type = "quest",
        id = 58717,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58725,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amount = 12250,
                    restrictions = -1,
                },
                {
                    amount = 12250,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amount = 386100,
                    restrictions = -1,
                },
                {
                    amount = 386100,
                },
            },
        },
    },
    items = {
        {
            type = "kill",
            id = 160847,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58717,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58725,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    questline = 1143,
    items = {
        {
            type = "npc",
            id = 168618,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60480,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    questline = 1177,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 352490,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58272,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "kill",
            id = 165253,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60517,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    questline = 1180,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 351889,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60279,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    questline = 1145,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 167489,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60177,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60178,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    questline = 1144,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 168698,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60487,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "item",
            id = 182738,
            breadcrumb = true,
            locations = {
                [1525] = {
                    {
                        x = 0.310485,
                        y = 0.550631,
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
            id = 62189,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain08, {
    questline = 1182,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 351874,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60275,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    questline = 1181,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 351888,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60276,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain10, {
    questline = 1191,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 351885,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60277,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain11, {
    questline = 1183,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 351887,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60280,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain12, {
    questline = 1184,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 351886,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60278,
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
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 3759912,
    items = {
        {
            type = "chain",
            id = Chain.WelcomeToRevendreth,
        },
        {
            type = "chain",
            id = Chain.MeetTheMaster,
        },
        {
            type = "chain",
            id = Chain.TheAccusersSecret,
        },
        {
            type = "chain",
            id = Chain.TheRebellion,
        },
        {
            type = "chain",
            id = Chain.SecuringSinfall,
        },
        {
            type = "chain",
            id = Chain.ThePrinceAndTheTower,
        },
        {
            type = "chain",
            id = Chain.MenagerieOfTheMaster,
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
            id = Chain.Chain08,
            visible = 86994,
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
})

