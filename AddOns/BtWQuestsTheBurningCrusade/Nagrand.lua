local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheBurningCrusade;
local CATEGORY_ID = BtWQuests.Constant.Category.TheBurningCrusade.Nagrand;
local Chain = BtWQuests.Constant.Chain.TheBurningCrusade.Nagrand;
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 107
local ACHIEVEMENT_ID_1 = 1192
local ACHIEVEMENT_ID_2 = 1273
local CONTINENT_ID = 101
local LEVEL_RANGE = {15, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 15,
    },
}

Chain.TheAdventuresOfCorki = 20401
Chain.BirthOfAWarchief = 20402

Chain.TheRingOfBlood = 20403
Chain.ThroneOfTheElements = 20404

Chain.LantresorOfTheBladeAlliance = 20405
Chain.LantresorOfTheBladeHorde = 20406

Chain.TheMurkbloodAlliance = 20407
Chain.TheMurkbloodHorde = 20408

Chain.ThreatsToNagrandAlliance = 20409
Chain.ThreatsToNagrandHorde = 20410

Chain.TheUltimateBloodsport = 20411
Chain.EncounteringTheEthereals = 20412

Chain.EmbedChain01 = 20421
Chain.EmbedChain02 = 20422
Chain.EmbedChain03 = 20423

Chain.EmbedChain04 = 20424
Chain.EmbedChain05 = 20425

Chain.EmbedChain06 = 20426
Chain.EmbedChain07 = 20427

Chain.EmbedChain08 = 20428
Chain.EmbedChain09 = 20429
Chain.EmbedChain10 = 20430

Chain.EmbedChain11 = 20431
Chain.EmbedChain12 = 20432
Chain.EmbedChain13 = 20433

Chain.EmbedChain14 = 20453
Chain.EmbedChain15 = 20464
Chain.EmbedChain16 = 20465
Chain.EmbedChain17 = 20469
Chain.EmbedChain18 = 20459
Chain.EmbedChain19 = 20460
Chain.EmbedChain20 = 20461

Chain.Chain01 = 20470
Chain.Chain02 = 20471
Chain.Chain03 = 20468
Chain.Chain04 = 20452

Chain.EmbedChain21 = 20462
Chain.EmbedChain22 = 20455
Chain.EmbedChain23 = 20457
Chain.EmbedChain24 = 20458
Chain.EmbedChain25 = 20463
Chain.EmbedChain26 = 20466
Chain.EmbedChain27 = 20451
Chain.EmbedChain28 = 20467

Chain.TempChain06 = 20456

Database:AddChain(Chain.TheAdventuresOfCorki, {
    name = L["THE_ADVENTURES_OF_CORKI"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.BirthOfAWarchief
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "reputation",
            id = 978,
            standing = 4,
        },
    },
    active = {
        type = "quest",
        id = 9923,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9955,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8900, 9550, 10000, 10600, 11250, 11700, 12350, 12950, 13400, 14050, 14650, 15250, 15750, 16350, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 3600, 3600, 2875, 2125, 1440, 720, 365, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8900, 9550, 10000, 10600, 11250, 11700, 12350, 12950, 13400, 14050, 14650, 15250, 15750, 16350, 17000, 17450, 17450, 14000, 10450, 7000, 3525, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 190, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 978,
            amount = 1100,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 18369,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9923,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9924,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9954,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9955,
            x = 0,
        },
    },
})
Database:AddChain(Chain.BirthOfAWarchief, {
    name = L["BIRTH_OF_A_WARCHIEF"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheAdventuresOfCorki
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.LantresorOfTheBladeHorde,
        },
        {
            type = "chain",
            id = Chain.ThreatsToNagrandAlliance,
            upto = 10011,
        },
        {
            type = "chain",
            id = Chain.TheMurkbloodHorde,
            upto = 9868,
        },
    },
    active = {
        type = "quest",
        id = 10044,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10172,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        21990, 23520, 24750, 26190, 27720, 29000, 30530, 31920, 33200, 34730, 36170, 37600, 38930, 40370, 41900, 43250, 44600, 46150, 47450, 48800, 50400, 51850, 53100, 54600, 56050, 57350, 58800, 60250, 61550, 63000, 64600, 65950, 67200, 68800, 70150, 8890, 8890, 7090, 5285, 3535, 1770, 900, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21990, 23520, 24750, 26190, 27720, 29000, 30530, 31920, 33200, 34730, 36170, 37600, 38930, 40370, 41900, 43250, 43250, 34590, 25890, 17290, 8700, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 4340, 470, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 935,
            amount = 1200,
        },
        {
            type = "reputation",
            id = 941,
            amount = 3105,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 18063,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10044,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10045,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10081,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10082,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10085,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10101,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10102,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10167,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10168,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10170,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10171,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10172,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheRingOfBlood, {
    name = L["THE_RING_OF_BLOOD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9962,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9977,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        18900, 20100, 21300, 22500, 23700, 24900, 26100, 27300, 28500, 29700, 30900, 32100, 33300, 34500, 35700, 37200, 38400, 39600, 40800, 42000, 43200, 44400, 45600, 46800, 48000, 49200, 50400, 51600, 52800, 54000, 55200, 56400, 57600, 58800, 60000, 7500, 7500, 6000, 4650, 3000, 1500, 780, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        18900, 20100, 21300, 22500, 23700, 24900, 26100, 27300, 28500, 29700, 30900, 32100, 33300, 34500, 35700, 37200, 37200, 29700, 22200, 14700, 7500, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 420, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        499500, 592200, 684900, 777600, 870300, 963000, 1055700, 1148400, 1241100, 1333800, 1426500, 1519200, 1611900, 1704600, 1797300, 1890000, 2006640, 2123280, 2239920, 2356560, 2473200, 2589840, 2706480, 2823120, 2939760, 3056400, 3173040, 3289680, 3406320, 3522960, 3639600, 3754080, 3868560, 3983040, 4097520, 4212000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        499500, 592200, 684900, 777600, 870300, 963000, 1055700, 1148400, 1241100, 1333800, 1426500, 1519200, 1611900, 1704600, 1797300, 1890000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 18471,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9967,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9970,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9972,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9973,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9977,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ThroneOfTheElements, {
    name = L["THRONE_OF_THE_ELEMENTS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9815, 9800, 9818, 9861},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9862, 9810, 9853},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        25200, 26950, 28250, 30000, 31750, 33050, 34800, 36550, 37850, 39600, 41350, 43100, 44400, 46150, 47900, 49300, 51050, 52800, 54100, 55850, 57600, 59350, 60650, 62400, 64150, 65450, 67200, 68950, 70250, 72000, 73750, 75500, 76800, 78550, 80300, 10150, 10150, 8075, 6050, 4060, 2030, 1025, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        25200, 26950, 28250, 30000, 31750, 33050, 34800, 36550, 37850, 39600, 41350, 43100, 44400, 46150, 47900, 49300, 49300, 39600, 29450, 19750, 9925, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 4940, 545, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
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
            x = 1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            x = 3,
        },
    },
})

Database:AddChain(Chain.LantresorOfTheBladeAlliance, {
    name = L["LANTRESOR_OF_THE_BLADE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.LantresorOfTheBladeHorde
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9917,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9933,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        21450, 23000, 24100, 25550, 27150, 28250, 29800, 31250, 32350, 33900, 35350, 36800, 38000, 39450, 41000, 42100, 43550, 45100, 46200, 47650, 49200, 50650, 51850, 53300, 54750, 55950, 57400, 58850, 60050, 61500, 63050, 64500, 65600, 67150, 68600, 8675, 8675, 6925, 5130, 3470, 1740, 880, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21450, 23000, 24100, 25550, 27150, 28250, 29800, 31250, 32350, 33900, 35350, 36800, 38000, 39450, 41000, 42100, 42100, 33750, 25200, 16900, 8500, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 4230, 460, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 978,
            amount = 1860,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 18353,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9917,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9918,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9920,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9922,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10108,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9928,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 9927,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9931,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9932,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9933,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LantresorOfTheBladeHorde, {
    name = L["LANTRESOR_OF_THE_BLADE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.LantresorOfTheBladeAlliance
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9888,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9934,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        24860, 26630, 27950, 29610, 31430, 32750, 34520, 36180, 37500, 39270, 40930, 42650, 44020, 45680, 47500, 48825, 50425, 52250, 53575, 55175, 57000, 58725, 60025, 61750, 63475, 64775, 66500, 68225, 69525, 71250, 73075, 74675, 76000, 77825, 79425, 10055, 10055, 8025, 5955, 4020, 2010, 1015, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        24860, 26630, 27950, 29610, 31430, 32750, 34520, 36180, 37500, 39270, 40930, 42650, 44020, 45680, 47500, 48825, 48825, 39110, 29210, 19580, 9845, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 4890, 530, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 941,
            amount = 2610,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 18106,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9888,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9889,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9891,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 9906,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 9907,
            x = -1,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10107,
            x = 0,
            y = 7,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9928,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 9927,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9931,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9932,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9934,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheMurkbloodAlliance, {
    name = L["THE_MURKBLOOD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheMurkbloodHorde
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9871, 9879},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9879, 9873},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11000, 11800, 12350, 13100, 13900, 14450, 15250, 16000, 16550, 17350, 18100, 18850, 19450, 20200, 21000, 21550, 22300, 23100, 23650, 24400, 25200, 25950, 26550, 27300, 28050, 28650, 29400, 30150, 30750, 31500, 32300, 33050, 33600, 34400, 35150, 4450, 4450, 3550, 2625, 1780, 890, 450, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11000, 11800, 12350, 13100, 13900, 14450, 15250, 16000, 16550, 17350, 18100, 18850, 19450, 20200, 21000, 21550, 21550, 17300, 12900, 8650, 4350, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 235, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 978,
            amount = 1350,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain23,
            embed = true,
            aside = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain24,
            embed = true,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheMurkbloodHorde, {
    name = L["THE_MURKBLOOD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheMurkbloodAlliance
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "reputation",
            id = 941,
            x = 0,
            connections = {
                1, 2, 
            },
            standing = 4,
        },
    },
    active = {
        type = "quest",
        ids = {9864, 9868},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9866, 9868},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10475, 11200, 11800, 12475, 13200, 13800, 14525, 15200, 15800, 16525, 17200, 17950, 18525, 19250, 20000, 20550, 21250, 22000, 22550, 23250, 24000, 24700, 25300, 26000, 26700, 27300, 28000, 28700, 29300, 30000, 30750, 31450, 32000, 32800, 33450, 4230, 4230, 3385, 2505, 1695, 845, 425, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10475, 11200, 11800, 12475, 13200, 13800, 14525, 15200, 15800, 16525, 17200, 17950, 18525, 19250, 20000, 20550, 20550, 16475, 12325, 8235, 4145, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 2065, 225, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 941,
            amount = 1200,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain15,
            embed = true,
            aside = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain16,
            embed = true,
            aside = true,
        },
    },
})

Database:AddChain(Chain.ThreatsToNagrandAlliance, {
    name = L["THREATS_TO_NAGRAND"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.ThreatsToNagrandHorde
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9936, 9940, 9982, 9983, 9991},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9938, 10011},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        20475, 21850, 23000, 24375, 25750, 26900, 28275, 29650, 30800, 32175, 33550, 35000, 36075, 37500, 38900, 40100, 41500, 42900, 44000, 45400, 46800, 48200, 49300, 50700, 52100, 53200, 54600, 56000, 57100, 58500, 59900, 61300, 62400, 63850, 65200, 8230, 8230, 6560, 4930, 3295, 1645, 830, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        20475, 21850, 23000, 24375, 25750, 26900, 28275, 29650, 30800, 32175, 33550, 35000, 36075, 37500, 38900, 40100, 40100, 32175, 23975, 16035, 8070, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 445, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 978,
            amount = 850,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
            x = 2,
        },
    },
})
Database:AddChain(Chain.ThreatsToNagrandHorde, {
    name = L["THREATS_TO_NAGRAND"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.ThreatsToNagrandAlliance
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9935, 9939, 9982, 9983, 9991},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9937, 10011},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        20475, 21850, 23000, 24375, 25750, 26900, 28275, 29650, 30800, 32175, 33550, 35000, 36075, 37500, 38900, 40100, 41500, 42900, 44000, 45400, 46800, 48200, 49300, 50700, 52100, 53200, 54600, 56000, 57100, 58500, 59900, 61300, 62400, 63850, 65200, 8230, 8230, 6560, 4930, 3295, 1645, 830, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        20475, 21850, 23000, 24375, 25750, 26900, 28275, 29650, 30800, 32175, 33550, 35000, 36075, 37500, 38900, 40100, 40100, 32175, 23975, 16035, 8070, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 4020, 445, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 941,
            amount = 850,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain10,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
            x = 2,
        },
    },
})

Database:AddChain(Chain.TheUltimateBloodsport, {
    name = L["THE_ULTIMATE_BLOODSPORT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9789, 9854, 9857, 10113, 10114, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9852,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        23550, 25250, 26500, 28050, 29750, 31000, 32700, 34250, 35500, 37200, 38750, 40300, 41700, 43250, 44950, 46250, 47800, 49500, 50750, 52300, 54000, 55550, 56950, 58500, 60050, 61450, 63000, 64550, 65950, 67500, 69200, 70750, 72000, 73700, 75250, 9500, 9500, 7600, 5650, 3800, 1900, 970, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        23550, 25250, 26500, 28050, 29750, 31000, 32700, 34250, 35500, 37200, 38750, 40300, 41700, 43250, 44950, 46250, 46250, 37050, 27700, 18500, 9350, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 4660, 505, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        416250, 493500, 570750, 648000, 725250, 802500, 879750, 957000, 1034250, 1111500, 1188750, 1266000, 1343250, 1420500, 1497750, 1575000, 1672200, 1769400, 1866600, 1963800, 2061000, 2158200, 2255400, 2352600, 2449800, 2547000, 2644200, 2741400, 2838600, 2935800, 3033000, 3128400, 3223800, 3319200, 3414600, 3510000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        416250, 493500, 570750, 648000, 725250, 802500, 879750, 957000, 1034250, 1111500, 1188750, 1266000, 1343250, 1420500, 1497750, 1575000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain11,
            embed = true,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            embed = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9852,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EncounteringTheEthereals, {
    name = L["ENCOUNTERING_THE_ETHEREALS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9900, 9925},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {
            9900, 9925, 
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10500, 11250, 11750, 12500, 13250, 13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 21250, 22000, 22500, 23250, 24000, 24750, 25250, 26000, 26750, 27250, 28000, 28750, 29250, 30000, 30750, 31500, 32000, 32750, 33500, 4250, 4250, 3375, 2500, 1700, 850, 425, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10500, 11250, 11750, 12500, 13250, 13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 20500, 16500, 12250, 8250, 4125, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 225, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        141525, 167790, 194055, 220320, 246585, 272850, 299115, 325380, 351645, 377910, 404175, 430440, 456705, 482970, 509235, 535500, 568550, 601595, 634645, 667690, 700740, 733790, 766835, 799885, 832930, 865980, 899030, 932075, 965125, 998170, 1031220, 1063655, 1096090, 1128530, 1160965, 1193400, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        141525, 167790, 194055, 220320, 246585, 272850, 299115, 325380, 351645, 377910, 404175, 430440, 456705, 482970, 509235, 535500, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 933,
            amount = 2000,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain17,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
            aside = true,
            embed = true,
            x = -1,
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
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9800, 9815, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9810,
    },
    items = {
        {
            type = "npc",
            id = 18073,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9815,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 9800,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9804,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9805,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9810,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9818,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9853,
    },
    items = {
        {
            type = "npc",
            id = 18071,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9818,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9819,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9821,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9849,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9853,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9861,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9862,
    },
    items = {
        {
            type = "kill",
            id = 17158,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9861,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9862,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9871,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9873,
    },
    items = {
        {
            type = "kill",
            id = 18238,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9871,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9873,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9879,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9879,
    },
    items = {
        {
            type = "npc",
            id = 18209,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9879,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "reputation",
            id = 941,
            standing = 4,
        },
    },
    active = {
        type = "quest",
        id = 9864,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9866,
    },
    items = {
        {
            type = "npc",
            id = 18067,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9864,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9865,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9866,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "reputation",
            id = 941,
            standing = 4,
        },
    },
    active = {
        type = "quest",
        id = 9868,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9868,
    },
    items = {
        {
            type = "npc",
            id = 18210,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9868,
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
            9936, 9940, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9938,
    },
    items = {
        {
            type = "object",
            id = 182393,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9936,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9940,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9938,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9982, 9983, 9991, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10011,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9982,
                    restrictions = {
                        type = "quest",
                        id = 9982,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 9983,
                    restrictions = {
                        type = "quest",
                        id = 9983,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 18417,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9991,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9999,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10001,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10004,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10009,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10010,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10011,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain10, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9935, 9939, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9937,
    },
    items = {
        {
            type = "object",
            id = 182392,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9935,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9939,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9937,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain11, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9854, 10114, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9856,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 10114,
                    restrictions = {
                        type = "quest",
                        id = 10114,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 18200,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9854,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9855,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9856,
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
        ids = {
            9789, 10113, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9851,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 10113,
                    restrictions = {
                        type = "quest",
                        id = 10113,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 18180,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9789,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9850,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9851,
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
        id = 9857,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9859,
    },
    items = {
        {
            type = "npc",
            id = 18218,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9857,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9858,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9859,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.LantresorOfTheBladeHorde,
            upto = 9891,
        }
    },
    active = {
        type = "quest",
        id = 9910,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9916,
    },
    items = {
        {
            type = "quest",
            id = 9910,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9916,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9867,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9867,
    },
    items = {
        {
            type = "npc",
            id = 18068,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9867,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9872,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9872,
    },
    items = {
        {
            type = "kill",
            id = 18238,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9872,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9900, 9925},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {
            9900, 9925, 
        },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 18276,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9900,
            x = -1,
        },
        {
            type = "quest",
            id = 9925,
        },
    },
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9913, 9882},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9882,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9913,
                    restrictions = {
                        type = "quest",
                        id = 9913,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 18265,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9882,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9883,
            aside = true,
            active = {
                type = "quest",
                id = 9882,
            },
            completed = {
                type = "reputation",
                id = 933,
                standing = 5,
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9914,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9914,
    },
    items = {
        {
            type = "npc",
            id = 18333,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9914,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9915,
            aside = true,
            active = {
                type = "quest",
                id = 9914,
            },
            completed = {
                type = "reputation",
                id = 933,
                standing = 5,
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain20, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        type = "level",
        level = 15,
    },
    active = {
        type = "quest",
        id = 9893,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9893,
    },
    items = {
        {
            type = "reputation",
            id = 933,
            x = 0,
            connections = {
                1, 
            },
            standing = 5,
        },
        {
            type = "npc",
            id = 18265,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9893,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9892,
            aside = true,
            active = {
                type = "quest",
                id = 9893,
            },
            completed = {
                {
                    type = "quest",
                    id = 9893,
                },
                {
                    type = "reputation",
                    id = 933,
                    standing = 8,
                },
            },
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAreaName(3626), -- Telaar
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9956, 39197, 10476},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {9956, 10476},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 1700, 1700, 1350, 1000, 680, 340, 170, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8200, 6600, 4900, 3300, 1650, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 90, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        27750, 32900, 38050, 43200, 48350, 53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 111480, 117960, 124440, 130920, 137400, 143880, 150360, 156840, 163320, 169800, 176280, 182760, 189240, 195720, 202200, 208560, 214920, 221280, 227640, 234000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        27750, 32900, 38050, 43200, 48350, 53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 978,
            amount = 850,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain21,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = BtWQuests_GetAreaName(3613), -- Garadar
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9863, 10479},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {9863, 10479},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 1700, 1700, 1350, 1000, 680, 340, 170, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8200, 6600, 4900, 3300, 1650, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 90, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 941,
            amount = 750,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain25,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = BtWQuests_GetAreaName(3672), -- Mag'hari Procession
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9944, 9945, 9948},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {9946, 9948},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6800, 7300, 7650, 8100, 8600, 8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20450, 20800, 21300, 21750, 2750, 2750, 2200, 1625, 1100, 550, 280, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6800, 7300, 7650, 8100, 8600, 8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13350, 10700, 8000, 5350, 2700, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 145, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 941,
            amount = 950,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain27,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain28,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- Bring Me The Egg!
        type = "quest",
        id = 10111,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10109,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 10111,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4700, 5050, 5300, 5600, 5950, 6200, 6550, 6850, 7100, 7450, 7750, 8050, 8350, 8650, 9000, 9250, 9550, 9900, 10150, 10450, 10800, 11100, 11400, 11700, 12000, 12300, 12600, 12900, 13200, 13500, 13850, 14150, 14400, 14750, 15050, 1900, 1900, 1525, 1125, 760, 380, 195, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4700, 5050, 5300, 5600, 5950, 6200, 6550, 6850, 7100, 7450, 7750, 8050, 8350, 8650, 9000, 9250, 9250, 7400, 5550, 3700, 1875, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 100, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 19035,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10109,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10111,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9956,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 9956,
    },
    items = {
        {
            type = "npc",
            id = 18416,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9956,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain22, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {39197, 10476},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 10476,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39197,
                    restrictions = {
                        type = "quest",
                        id = 39197,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 18408,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10476,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10477,
            aside = true,
            active = {
                type = "quest",
                id = 10477,
            },
            completed = {
                {
                    type = "quest",
                    id = 10477,
                },
                {
                    type = "reputation",
                    id = 978,
                    standing = 8,
                },
            },
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
        id = 9874,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 9874,
    },
    items = {
        {
            type = "npc",
            id = 18222,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9874,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain24, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9878,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 9878,
    },
    items = {
        {
            type = "npc",
            id = 18224,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9878,
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
        id = 9863,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 9863,
    },
    items = {
        {
            type = "npc",
            id = 18066,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9863,
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
        id = 10479,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 10479,
    },
    items = {
        {
            type = "npc",
            id = 18407,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10479,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10478,
            aside = true,
            active = {
                type = "quest",
                id = 10479,
            },
            completed = {
                {
                    type = "quest",
                    id = 10479,
                },
                {
                    type = "reputation",
                    id = 941,
                    standing = 8,
                },
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9944, 9945},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 9946,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9944,
                    restrictions = {
                        type = "quest",
                        id = 9944,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 18414,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9945,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9946,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain28, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9948,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 9948,
    },
    items = {
        {
            type = "npc",
            id = 18415,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9948,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TempChain06, {
    name = "Others",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        { -- Breadcrumb to Talaar but doesnt directly lead to a quest
            type = "quest",
            id = 9792,
        },
        { -- Breadcrumb to Garadar but doesnt directly lead to a quest
            type = "quest",
            id = 9797,
        },
        { -- Breadcrumb that doesnt really fit anywhere
            type = "quest",
            id = 9869,
        },
        { -- Breadcrumb that doesnt really fit anywhere
            type = "quest",
            id = 9870,
        },
        { -- Membership Benefits
            type = "quest",
            id = 9884,
        },
        { -- Membership Benefits
            type = "quest",
            id = 9885,
        },
        { -- Membership Benefits
            type = "quest",
            id = 9886,
        },
        { -- Membership Benefits
            type = "quest",
            id = 9887,
        },
        { -- Kind of a strange quest, not sure what to do with it
            type = "quest",
            id = 9897,
        },
        { -- Halaa daily, Horde
            type = "quest",
            id = 10074,
        },
        { -- Halaa daily, Horde
            type = "quest",
            id = 10075,
        },
        { -- Halaa daily, Alliance
            type = "quest",
            id = 10076,
        },
        { -- Halaa daily, Alliance
            type = "quest",
            id = 10077,
        },
        { -- Maybe not available?
            type = "quest",
            id = 10375,
        },
        { -- Halaa daily, Alliance
            type = "quest",
            id = 11502,
        },
        { -- Halaa daily, Horde
            type = "quest",
            id = 11503,
        },
        { -- Daily starting from Shattrath
            type = "quest",
            id = 11880,
        },
        { -- Warchief's Command: Nagrand!
            type = "quest",
            id = 39189,
        },
        { -- Warchief's Command: Nagrand!
            type = "quest",
            id = 39196,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsTheBurningCrusade\UI-Category-Nagrand]],
		texCoords = {0,1,0,1},
    },
    items = {
        {
            type = "chain",
            id = Chain.TheAdventuresOfCorki,
        },
        {
            type = "chain",
            id = Chain.BirthOfAWarchief,
        },

        {
            type = "chain",
            id = Chain.TheRingOfBlood,
        },
        {
            type = "chain",
            id = Chain.ThroneOfTheElements,
        },

        {
            type = "chain",
            id = Chain.LantresorOfTheBladeAlliance,
        },
        {
            type = "chain",
            id = Chain.LantresorOfTheBladeHorde,
        },

        {
            type = "chain",
            id = Chain.TheMurkbloodAlliance,
        },
        {
            type = "chain",
            id = Chain.TheMurkbloodHorde,
        },

        {
            type = "chain",
            id = Chain.ThreatsToNagrandAlliance,
        },
        {
            type = "chain",
            id = Chain.ThreatsToNagrandHorde,
        },

        {
            type = "chain",
            id = Chain.TheUltimateBloodsport,
        },
        {
            type = "chain",
            id = Chain.EncounteringTheEthereals,
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
            id = Chain.TheAdventuresOfCorki,
        },
        {
            type = "chain",
            id = Chain.BirthOfAWarchief,
        },
        {
            type = "chain",
            id = Chain.TheRingOfBlood,
        },
        {
            type = "chain",
            id = Chain.LantresorOfTheBladeAlliance,
        },
        {
            type = "chain",
            id = Chain.LantresorOfTheBladeHorde,
        },
        {
            type = "chain",
            id = Chain.EncounteringTheEthereals,
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
            id = Chain.Chain04,
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
        {
            type = "chain",
            id = Chain.EmbedChain28,
        },
    })
end
