local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheBurningCrusade;
local CATEGORY_ID = BtWQuests.Constant.Category.TheBurningCrusade.BladesEdgeMountains;
local Chain = BtWQuests.Constant.Chain.TheBurningCrusade.BladesEdgeMountains;
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 105
local ACHIEVEMENT_ID = 1193
local CONTINENT_ID = 101
local LEVEL_RANGE = {20, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 20,
    },
}

Chain.Sylvanaar = 20501
Chain.ThunderlordStronghold = 20502
Chain.ToshleysStation = 20503
Chain.Reunion = 20504
Chain.TheGronnThreat = 20505
Chain.TheMoknathal = 20506
Chain.RuuanWeald = 20507

Chain.EmbedChain01 = 20511
Chain.EmbedChain02 = 20512
Chain.EmbedChain03 = 20513
Chain.EmbedChain04 = 20514
Chain.EmbedChain05 = 20515
Chain.EmbedChain06 = 20516
Chain.EmbedChain07 = 20517
Chain.EmbedChain08 = 20518
Chain.EmbedChain09 = 20519
Chain.EmbedChain10 = 20520
Chain.EmbedChain11 = 20521
Chain.EmbedChain12 = 20522
Chain.EmbedChain13 = 20523
Chain.EmbedChain14 = 20524
Chain.EmbedChain15 = 20525

Chain.Chain01 = 20526
Chain.Chain02 = 20527
Chain.Chain03 = 20528

Chain.EmbedChain16 = 20529
Chain.EmbedChain17 = 20530
Chain.EmbedChain18 = 20531
Chain.EmbedChain19 = 20532
Chain.EmbedChain20 = 20533
Chain.EmbedChain21 = 20534
Chain.EmbedChain22 = 20535
Chain.EmbedChain23 = 20536
Chain.EmbedChain24 = 20537
Chain.EmbedChain25 = 20538
Chain.EmbedChain26 = 20539
Chain.EmbedChain27 = 20540

Chain.TempChain01 = 20541
Chain.TempChain02 = 20542
Chain.TempChain03 = 20543

Chain.OtherChain = 20599

Database:AddChain(Chain.Sylvanaar, {
    name = L["SYLVANAAR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.ThunderlordStronghold
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10455, 10502, 10516, 39199, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {10457, 10518, 10504},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        44050, 46450, 48800, 50450, 52850, 55200, 57550, 59250, 61600, 64000, 65650, 68000, 70400, 72050, 74400, 76800, 79150, 80850, 83200, 85550, 87250, 89600, 91950, 93650, 96000, 98400, 100750, 102400, 104800, 107150, 13575, 13575, 10800, 8005, 5430, 2720, 1365, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        44050, 46450, 48800, 50450, 52850, 55200, 57550, 59250, 61600, 64000, 65650, 65650, 52750, 39250, 26400, 13225, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 6575, 720, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        856000, 938400, 1020800, 1103200, 1185600, 1268000, 1350400, 1432800, 1515200, 1597600, 1680000, 1783680, 1887360, 1991040, 2094720, 2198400, 2302080, 2405760, 2509440, 2613120, 2716800, 2820480, 2924160, 3027840, 3131520, 3235200, 3336960, 3438720, 3540480, 3642240, 3744000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        856000, 938400, 1020800, 1103200, 1185600, 1268000, 1350400, 1432800, 1515200, 1597600, 1680000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain16,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain17,
            aside = true,
            embed = true,
            x = -3,
            y = 7,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain19,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain20,
            aside = true,
            embed = true,
        },
    },
})
Database:AddChain(Chain.ThunderlordStronghold, {
    name = L["THUNDERLORD_STRONGHOLD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.Sylvanaar
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10486, 10503, 10542, 39198, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {10488, 10544, 10545, 10505},
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        31650, 33400, 35050, 36250, 38000, 39650, 41300, 42600, 44250, 46000, 47200, 48850, 50600, 51800, 53450, 55200, 56850, 58150, 59800, 61450, 62750, 64400, 66050, 67350, 69000, 70750, 72400, 73600, 75350, 77000, 9750, 9750, 7775, 5750, 3900, 1950, 985, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        31650, 33400, 35050, 36250, 38000, 39650, 41300, 42600, 44250, 46000, 47200, 47200, 37900, 28250, 18950, 9525, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 4740, 515, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        695500, 762450, 829400, 896350, 963300, 1030250, 1097200, 1164150, 1231100, 1298050, 1365000, 1449240, 1533480, 1617720, 1701960, 1786200, 1870440, 1954680, 2038920, 2123160, 2207400, 2291640, 2375880, 2460120, 2544360, 2628600, 2711280, 2793960, 2876640, 2959320, 3042000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        695500, 762450, 829400, 896350, 963300, 1030250, 1097200, 1164150, 1231100, 1298050, 1365000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain21,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
            aside = true,
            embed = true,
        },
    },
})

Database:AddChain(Chain.ToshleysStation, {
    name = L["TOSHLEYS_STATION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.Reunion
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10557, 10580, 10581, 10584, 10608, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {10675, 10712, 10594, 10671},
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        33800, 35550, 37250, 38700, 40450, 42150, 44050, 45350, 47200, 49000, 50300, 52100, 53900, 55200, 57000, 58800, 60550, 61950, 63700, 65450, 66850, 68600, 70350, 71750, 73500, 75300, 77100, 78400, 80350, 82000, 10380, 10380, 8285, 6135, 4160, 2075, 1035, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        33800, 35550, 37250, 38700, 40450, 42150, 44050, 45350, 47200, 49000, 50300, 50300, 40400, 30150, 20195, 10125, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 5045, 555, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        722250, 791780, 861300, 930830, 1000350, 1069880, 1139400, 1208930, 1278450, 1347980, 1417500, 1504980, 1592460, 1679940, 1767420, 1854900, 1942380, 2029860, 2117340, 2204820, 2292300, 2379780, 2467260, 2554740, 2642220, 2729700, 2815560, 2901420, 2987280, 3073140, 3159000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        722250, 791780, 861300, 930830, 1000350, 1069880, 1139400, 1208930, 1278450, 1347980, 1417500, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
            x = -1,
            connections = {
                [6] = {
                    0.8, 1.4, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
            x = 3,
            y = 1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
            x = -1,
            y = 6,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
            aside = true,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Reunion, {
    name = L["REUNION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.ToshleysStation
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10524,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10526, 10742},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        37950, 39980, 41870, 43450, 45480, 47370, 49350, 50980, 52870, 54950, 56600, 58400, 60500, 62100, 63900, 66000, 68000, 69500, 71500, 73500, 75000, 77000, 79000, 80500, 82500, 84600, 86400, 88000, 90100, 91900, 11635, 11635, 9280, 6925, 4640, 2320, 1175, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        37950, 39980, 41870, 43450, 45480, 47370, 49350, 50980, 52870, 54950, 56600, 56600, 45290, 33840, 22660, 11395, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 5665, 615, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        749000, 821100, 893200, 965300, 1037400, 1109500, 1181600, 1253700, 1325800, 1397900, 1470000, 1560720, 1651440, 1742160, 1832880, 1923600, 2014320, 2105040, 2195760, 2286480, 2377200, 2467920, 2558640, 2649360, 2740080, 2830800, 2919840, 3008880, 3097920, 3186960, 3276000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        749000, 821100, 893200, 965300, 1037400, 1109500, 1181600, 1253700, 1325800, 1397900, 1470000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            name = L["KILL_BLADESPIRE_ORGRES"],
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10524,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10525,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10526,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10718,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10614,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10709,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10714,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10783,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10715,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10749,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 10784,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 10720,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10721,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10785,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 10723,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10786,
            aside = true,
        },
        {
            type = "quest",
            id = 10724,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10742,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheGronnThreat, {
    name = L["THE_GRONN_THREAT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheMoknathal
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10797,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10806,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        20700, 21830, 22820, 23700, 24830, 25820, 26850, 27830, 28820, 29950, 30900, 31850, 33000, 33900, 34850, 36000, 37050, 37950, 39000, 40050, 40950, 42000, 43050, 43950, 45000, 46150, 47100, 48000, 49150, 50100, 6340, 6340, 5065, 3785, 2520, 1260, 645, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        20700, 21830, 22820, 23700, 24830, 25820, 26850, 27830, 28820, 29950, 30900, 30900, 24690, 18490, 12340, 6225, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 3105, 335, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        535000, 586500, 638000, 689500, 741000, 792500, 844000, 895500, 947000, 998500, 1050000, 1114800, 1179600, 1244400, 1309200, 1374000, 1438800, 1503600, 1568400, 1633200, 1698000, 1762800, 1827600, 1892400, 1957200, 2022000, 2085600, 2149200, 2212800, 2276400, 2340000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        535000, 586500, 638000, 689500, 741000, 792500, 844000, 895500, 947000, 998500, 1050000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "kill",
            id = 20753,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10797,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10798,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10799,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10800,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 10801,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10803,
            aside = true,
        },
        {
            type = "quest",
            id = 10802,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10818,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10805,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10806,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheMoknathal, {
    name = L["THE_MOKNATHAL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheGronnThreat
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10565,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10615, 10867},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        33400, 35195, 36930, 38250, 40045, 41780, 43600, 44895, 46680, 48500, 49775, 51525, 53350, 54625, 56375, 58200, 59975, 61275, 63050, 64825, 66125, 67900, 69675, 70975, 72750, 74575, 76325, 77600, 79475, 81175, 10290, 10290, 8195, 6070, 4115, 2055, 1030, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        33400, 35195, 36930, 38250, 40045, 41780, 43600, 44895, 46680, 48500, 49775, 49775, 39985, 29785, 19995, 10020, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 4985, 545, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain24,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            type = "npc",
            id = 21496,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain25,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 10565,
            x = 0,
            y = 1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
            aside = true,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            embed = true,
        },
        {
            visible = false,
        },
    },
})

Database:AddChain(Chain.RuuanWeald, {
    name = L["RUUAN_WEALD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10567, 10682, 10770, 10771, 10810, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {10607, 10771, 10821, 10912, 10748},
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        55150, 58090, 60960, 63150, 66090, 68960, 71900, 74090, 76960, 79950, 82200, 85000, 88000, 90200, 93000, 96000, 98950, 101050, 104000, 106950, 109050, 112000, 114950, 117050, 120000, 123000, 125800, 128000, 131000, 133800, 16940, 16940, 13485, 10050, 6770, 3390, 1705, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        55150, 58090, 60960, 63150, 66090, 68960, 71900, 74090, 76960, 79950, 82200, 82200, 65920, 49120, 32990, 16545, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 8220, 900, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        1029875, 1129020, 1228150, 1327295, 1426425, 1525570, 1624700, 1723845, 1822975, 1922120, 2021250, 2145990, 2270730, 2395470, 2520210, 2644950, 2769690, 2894430, 3019170, 3143910, 3268650, 3393390, 3518130, 3642870, 3767610, 3892350, 4014780, 4137210, 4259640, 4382070, 4504500, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1029875, 1129020, 1228150, 1327295, 1426425, 1525570, 1624700, 1723845, 1822975, 1922120, 2021250, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 4470,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain14,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
            embed = true,
            aside = true,
            x = 3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            embed = true,
            x = 1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
            x = 3,
            y = 5,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10455, 39199, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10457,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39199,
                    restrictions = {
                        type = "quest",
                        id = 39199,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 21066,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10455,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10456,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10457,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10506,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10502,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10504,
    },
    items = {
        {
            type = "npc",
            id = 21158,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10502,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10504,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10516,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10518,
    },
    items = {
        {
            type = "npc",
            id = 21277,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10516,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10517,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10518,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10486, 39198, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10488,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39198,
                    restrictions = {
                        type = "quest",
                        id = 39198,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 21117,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10487,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10488,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10503,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10505,
    },
    items = {
        {
            type = "npc",
            id = 21147,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10503,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10505,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10542,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10544,
    },
    items = {
        {
            type = "npc",
            id = 21349,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10542,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10545,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10543,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10544,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10608,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10594,
    },
    items = {
        {
            type = "npc",
            id = 21755,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10608,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10594,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain08, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10580, 10581, 10584, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10671, 10675, 
        },
        count = 2,
    },
    items = {
        {
            type = "quest",
            id = 10580,
            visible = {
                type = "quest",
                id = 10580,
                status = { "active", "completed", },
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
                    id = 10581,
                    restrictions = {
                        type = "quest",
                        id = 10580,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 21691,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10584,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 10632,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 10620,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10657,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10671,
            x = 0,
        },
        {
            type = "quest",
            id = 10674,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10675,
            x = 2,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10557,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10712,
    },
    items = {
        {
            type = "npc",
            id = 21460,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10557,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10710,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10711,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10712,
            x = 0,
            comment = "Unknown exact requirements",
        },
    },
})
Database:AddChain(Chain.EmbedChain10, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.TheMoknathal,
            upto = 10565,
        },
    },
    active = {
        type = "quest",
        id = 10566,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10615,
    },
    items = {
        {
            type = "quest",
            id = 10566,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 10615,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain11, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.TheMoknathal,
            upto = 10565,
        },
    },
    active = {
        type = "quest",
        id = 10846,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10867,
    },
    items = {
        {
            type = "quest",
            id = 10846,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10843,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10845,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 22312,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10851,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10853,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10859,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10865,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10867,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain12, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10567,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10607,
    },
    items = {
        {
            type = "npc",
            id = 21782,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10567,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10607,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain13, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10682,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10748,
    },
    items = {
        {
            type = "npc",
            id = 22007,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10682,
            x = 0,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 10719,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 10717,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 10713,
            aside = true,
        },
        {
            type = "quest",
            id = 10894,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10747,
            aside = true,
        },
        {
            type = "quest",
            id = 10893,
            x = -2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10722,
            x = -2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10748,
            x = -2,
        },
    },
})
Database:AddChain(Chain.EmbedChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10810,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10912,
    },
    items = {
        {
            type = "kill",
            id = 21300,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10810,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10812,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10819,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10820,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10821,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10910,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10904,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10911,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10912,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10771,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10771,
    },
    items = {
        {
            type = "npc",
            id = 22053,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 10770,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 10771,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Exorcising the Trees
        type = "quest",
        id = 10830,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10825,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10830,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4150, 4390, 4560, 4750, 4990, 5160, 5350, 5590, 5760, 6000, 6200, 6350, 6600, 6800, 6950, 7200, 7400, 7600, 7800, 8000, 8200, 8400, 8600, 8800, 9000, 9250, 9400, 9600, 9850, 10000, 1270, 1270, 1020, 755, 500, 250, 130, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4150, 4390, 4560, 4750, 4990, 5160, 5350, 5590, 5760, 6000, 6200, 6200, 4920, 3720, 2470, 1250, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 65, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            name = L["KILL_GRISHNATH_ARAKKOA"],
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10825,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10829,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10830,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- A Date with Dorgok
        type = "quest",
        id = 10795,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10795, 10796},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10795, 10796},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 1700, 1700, 1350, 1000, 680, 340, 170, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8200, 6600, 4900, 3300, 1650, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 90, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 22149,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 22150,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10795,
            x = -1,
        },
        {
            type = "quest",
            id = 10796,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Mog'dorg the Wizened
        type = "quest",
        id = 10983,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10983, 10983, 10984, 10989, 10995, 10996, 10997, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11009,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        22850, 23925, 25000, 26150, 27225, 28350, 29450, 30525, 31650, 32750, 34100, 35150, 36250, 37400, 38450, 39600, 40700, 41750, 42900, 44000, 45100, 46200, 47300, 48400, 49500, 50650, 51700, 52800, 53950, 55000, 6910, 6910, 5520, 4230, 2760, 1380, 710, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22850, 23925, 25000, 26150, 27225, 28350, 29450, 30525, 31650, 32750, 34100, 34100, 27225, 20375, 13510, 6860, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 3425, 380, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1038,
            amount = 25,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 22995,
                    restrictions = {
                        type = "quest",
                        id = 10989,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 23053,
                    restrictions = {
                        type = "quest",
                        id = 11022,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 10984,
                    restrictions = {
                        type = "quest",
                        id = 10984,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 22940,
                    restrictions = {
                        type = "quest",
                        id = 10983,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 22995,
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
                    id = 10983,
                    restrictions = {
                        {
                            type = "quest",
                            id = 10984,
                            status = { "active", "completed", },
                        },
                        {
                            type = "quest",
                            id = 10989,
                            status = { "pending", },
                        },
                    },
                },
                {
                    type = "quest",
                    id = 10983,
                    restrictions = {
                        type = "quest",
                        id = 10983,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 11022,
                    restrictions = {
                        type = "quest",
                        id = 11022,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 10989,
                },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 10995,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 10996,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10997,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10998,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11000,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11009,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10927,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10927,
    },
    items = {
        {
            type = "npc",
            id = 22488,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10927,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10555,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10556,
    },
    items = {
        {
            type = "npc",
            id = 21469,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10555,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10556,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10511,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10512,
    },
    items = {
        {
            type = "npc",
            id = 21151,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10511,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10512,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10510,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10510,
    },
    items = {
        {
            type = "npc",
            id = 21197,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10510,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain20, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10690,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10690,
    },
    items = {
        {
            type = "object",
            id = 185035,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10690,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10928,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10928,
    },
    items = {
        {
            type = "npc",
            id = 22489,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10928,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain22, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10489,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10489,
    },
    items = {
        {
            type = "object",
            id = 184660,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10489,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10609,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10609,
    },
    items = {
        {
            type = "npc",
            id = 21110,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10609,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain24, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10617,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10617,
    },
    items = {
        {
            type = "npc",
            id = 21895,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10617,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain25, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10618,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10618,
    },
    items = {
        {
            type = "npc",
            id = 21896,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10618,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain26, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10860,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10860,
    },
    items = {
        {
            type = "npc",
            id = 21088,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10860,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10753,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10753,
    },
    items = {
        {
            type = "npc",
            id = 22133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10753,
            x = 0,
        },
    },
})

-- Stuff to move outside of zone
Database:AddChain(Chain.TempChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 11080,
    },
    items = {
        {
            type = "npc",
            id = 23233,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11025,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11058,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11030,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 11080,
            x = -2,
        },
        {
            type = "quest",
            id = 11061,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11062,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11079,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.TempChain02,
        },
    },
})
Database:AddChain(Chain.TempChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    completed = {
        type = "quest",
        id = 11023,
    },
    items = {
        {
            type = "quest",
            id = 11062,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 11010,
                    restrictions = {
                        type = "class",
                        id = BtWQuests.Constant.Class.Druid,
                    },
                },
                {
                    type = "quest",
                    id = 11102,
                },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 11023,
            x = -2,
        },
        {
            type = "quest",
            id = 11119,
        },
        {
            type = "quest",
            id = 11065,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11066,
            x = 1,
        },
    },
})
Database:AddChain(Chain.TempChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        type = "level",
        level = 25,
    },
    completed = {
        type = "quest",
        id = 10977,
    },
    items = {
        {
            type = "quest",
            id = 10976,
            x = 0,
            connections = {
                1, 
            },
            comment = "Consortum stuff",
        },
        {
            type = "quest",
            id = 10977,
            x = 0,
        },
    },
})

Database:AddChain(Chain.OtherChain, {
    name = "Others",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        { -- Breadcrumb to Sylvanaar but doesnt actually lead to a quest
            type = "quest",
            id = 9794,
        },
        { -- Breadcrumb to area, Horde
            type = "quest",
            id = 9795,
        },

        { -- The Consortium quest
            type = "quest",
            id = 10974,
        },
        { -- The Consortium quest
            type = "quest",
            id = 10975,
        },
        { -- "you must be exalted with "The Consortium" to get this quest"
            type = "quest",
            id = 10982,
        },

        { -- Ogri'la quest, requires honored?
            type = "quest",
            id = 11026,
        },
        { -- Ogri'la Daily
            type = "quest",
            id = 11051,
        },
        { -- Ogri'la intro quest @TODO
            type = "quest",
            id = 11057,
        },
        { -- Ogri'la quest
            type = "quest",
            id = 11059,
        },
        { -- Ogri'la quest
            type = "quest",
            id = 11078,
        },
        { -- One time friendly with Ogri'la
            type = "quest",
            id = 11091,
        },
        { -- Daily for Shattered Sun Offensive
            type = "quest",
            id = 11513,
        },
        { -- Daily from Shattrath
            type = "quest",
            id = 11514,
        },
        { -- Doug Test - Completable Quest4
            type = "quest",
            id = 50384,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsTheBurningCrusade\UI-Category-BladesEdgeMountains]],
		texCoords = {0,1,0,1},
    },
    items = {
        {
            type = "chain",
            id = Chain.Sylvanaar,
        },
        {
            type = "chain",
            id = Chain.ThunderlordStronghold,
        },
        {
            type = "chain",
            id = Chain.ToshleysStation,
        },
        {
            type = "chain",
            id = Chain.Reunion,
        },
        {
            type = "chain",
            id = Chain.TheGronnThreat,
        },
        {
            type = "chain",
            id = Chain.TheMoknathal,
        },
        {
            type = "chain",
            id = Chain.RuuanWeald,
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

if not C_QuestLine then
    Database:AddContinentItems(CONTINENT_ID, {
        {
            type = "chain",
            id = Chain.Reunion,
        },
        {
            type = "chain",
            id = Chain.TheGronnThreat,
        },
        {
            type = "chain",
            id = Chain.TheMoknathal,
        },
        {
            type = "chain",
            id = Chain.RuuanWeald,
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
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
            id = Chain.EmbedChain16,
        },
        {
            type = "chain",
            id = Chain.EmbedChain17,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
        },
        {
            type = "chain",
            id = Chain.EmbedChain19,
        },
        {
            type = "chain",
            id = Chain.EmbedChain20,
        },
        {
            type = "chain",
            id = Chain.EmbedChain21,
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
        },
        {
            type = "chain",
            id = Chain.EmbedChain24,
        },
        {
            type = "chain",
            id = Chain.EmbedChain25,
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
        },
    })
end
