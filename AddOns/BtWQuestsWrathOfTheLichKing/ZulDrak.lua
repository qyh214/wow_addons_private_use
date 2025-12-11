-- AUTO GENERATED - NEEDS UPDATING

local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.ZulDrak
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.ZulDrak
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 121
local CONTINENT_ID = 113
local ACHIEVEMENT_ID = 36
local LEVEL_RANGE = {20, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 20,
    },
}

Chain.Sseratus = 30501
Chain.Quetzlun = 30502
Chain.Akali = 30503
Chain.TheAmphitheaterOfAnguish = 30504
Chain.FindingAllies = 30505
Chain.TheStormKingsCrusade = 30506
Chain.Betrayal = 30507
Chain.TheArgentPatrol = 30508

Chain.Chain01 = 30511
Chain.Chain02 = 30512
Chain.Chain03 = 30513
Chain.Chain04 = 30514

Chain.EmbedChain01 = 30521
Chain.EmbedChain02 = 30522
Chain.EmbedChain03 = 30523
Chain.EmbedChain04 = 30524

Chain.IgnoreChain01 = 30531
Chain.IgnoreChain02 = 30532

Chain.OtherAlliance = 30597
Chain.OtherHorde = 30598
Chain.OtherBoth = 30599

Database:AddChain(Chain.Sseratus, {
    name = L["SSERATUS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12507,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12516,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17900, 18875, 19800, 20500, 21475, 22400, 23350, 24075, 25000, 26000, 26700, 27600, 28600, 29300, 30200, 31200, 32150, 32850, 33800, 34750, 35450, 36400, 37350, 38050, 39000, 40000, 40900, 41600, 42600, 43500, 5510, 5510, 4395, 3255, 2205, 1100, 555, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17900, 18875, 19800, 20500, 21475, 22400, 23350, 24075, 25000, 26000, 26700, 26700, 21425, 15975, 10710, 5385, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 290, 
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
                        334375, 366565, 398750, 430940, 463125, 495315, 527500, 559690, 591875, 624065, 656250, 696750, 737250, 777750, 818250, 858750, 899250, 939750, 980250, 1020750, 1061250, 1101750, 1142250, 1182750, 1223250, 1263750, 1303500, 1343250, 1383000, 1422750, 1462500, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        334375, 366565, 398750, 430940, 463125, 495315, 527500, 559690, 591875, 624065, 656250, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1106,
            amount = 500,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain01,
            aside = true,
            embed = true,
            x = 2,
            y = 0,
        },
        {
            type = "item",
            id = 38321,
            breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12507,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12510,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12562,
            aside = true,
        },
        {
            type = "quest",
            id = 12527,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12514,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12516,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Quetzlun, {
    name = L["QUETZLUN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.Sseratus,
        },
    },
    active = {
        type = "quest",
        id = 12623,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12685,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        53450, 56270, 58930, 61200, 64020, 66680, 69600, 71770, 74680, 77500, 79525, 82425, 85250, 87275, 90175, 93000, 95675, 98075, 100750, 103425, 105825, 108500, 111175, 113575, 116250, 119075, 121975, 124000, 127075, 129725, 16410, 16410, 13110, 9690, 6570, 3285, 1645, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        53450, 56270, 58930, 61200, 64020, 66680, 69600, 71770, 74680, 77500, 79525, 79525, 63860, 47710, 31935, 16025, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 8005, 880, 
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
                        53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 111480, 117960, 124440, 130920, 137400, 143880, 150360, 156840, 163320, 169800, 176280, 182760, 189240, 195720, 202200, 208560, 214920, 221280, 227640, 234000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 
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
            id = 28062,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12623,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 12627,
            x = 0,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12628,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12632,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12655,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12642,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12646,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12647,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12653,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12665,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12666,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12667,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12672,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12668,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12674,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12675,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12684,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12685,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12707,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12708,
            aside = true,
        },
        {
            type = "quest",
            id = 12709,
            aside = true,
        },
    },
})
Database:AddChain(Chain.Akali, {
    name = L["AKALI"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12712,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12730,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14500, 15300, 15950, 16600, 17400, 18050, 18700, 19500, 20150, 20950, 21650, 22300, 23100, 23750, 24400, 25200, 25850, 26650, 27300, 27950, 28750, 29400, 30050, 30850, 31500, 32300, 32950, 33600, 34400, 35050, 4400, 4400, 3550, 2650, 1760, 880, 460, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14500, 15300, 15950, 16600, 17400, 18050, 18700, 19500, 20150, 20950, 21650, 21650, 17250, 13000, 8600, 4400, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 2200, 235, 
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
                        160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
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
            id = 28401,
            locations = {
                [121] = {
                    {
                        x = 0.602567,
                        y = 0.577414,
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
            id = 12712,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12721,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12729,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12730,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheAmphitheaterOfAnguish, {
    name = L["THE_AMPHITHEATER_OF_ANGUISH"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12954, 12974, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12948,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        24900, 26100, 27300, 28500, 29700, 30900, 32100, 33300, 34500, 35700, 37200, 38400, 39600, 40800, 42000, 43200, 44400, 45600, 46800, 48000, 49200, 50400, 51600, 52800, 54000, 55200, 56400, 57600, 58800, 60000, 7500, 7500, 6000, 4650, 3000, 1500, 780, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        24900, 26100, 27300, 28500, 29700, 30900, 32100, 33300, 34500, 35700, 37200, 37200, 29700, 22200, 14700, 7500, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 3750, 420, 
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
                        963000, 1055700, 1148400, 1241100, 1333800, 1426500, 1519200, 1611900, 1704600, 1797300, 1890000, 2006640, 2123280, 2239920, 2356560, 2473200, 2589840, 2706480, 2823120, 2939760, 3056400, 3173040, 3289680, 3406320, 3522960, 3639600, 3754080, 3868560, 3983040, 4097520, 4212000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        963000, 1055700, 1148400, 1241100, 1333800, 1426500, 1519200, 1611900, 1704600, 1797300, 1890000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12974,
                    restrictions = {
                        type = "quest",
                        id = 12974,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 30007,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12954,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12933,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12934,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12935,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12936,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12948,
            x = 0,
        },
    },
})
Database:AddChain(Chain.FindingAllies, {
    name = L["FINDING_ALLIES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12859, 12861, 12902, 49534, 49552, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12859,12861,12883
        },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17250, 18175, 19050, 19750, 20675, 21550, 22450, 23175, 24050, 25000, 25700, 26550, 27500, 28200, 29050, 30000, 30900, 31600, 32500, 33400, 34100, 35000, 35900, 36600, 37500, 38450, 39300, 40000, 40950, 41800, 5285, 5285, 4220, 3135, 2115, 1060, 535, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17250, 18175, 19050, 19750, 20675, 21550, 22450, 23175, 24050, 25000, 25700, 25700, 20575, 15375, 10310, 5185, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 280, 
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
                        374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 25,
        },
        {
            type = "reputation",
            id = 1106,
            amount = 1000,
        },
    },
    items = {
        {
            type = "npc",
            id = 29733,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49534,
                    restrictions = {
                        type = "quest",
                        id = 49534,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 49552,
                    restrictions = {
                        type = "quest",
                        id = 49552,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 29687,
                },
            },
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 29690,
            connections = {
                4, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 12859,
            x = -2,
            y = 1,
        },
        {
            type = "quest",
            id = 12902,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12861,
        },
        {
            type = "quest",
            id = 12883,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12884,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
            comment = "This quest may have alternatives so might need to move this, alternatives and the next quest over to its own chain",
        },
        {
            type = "quest",
            id = 12630,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheStormKingsCrusade, {
    name = L["THE_STORM_KINGS_CRUSADE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.FindingAllies,
            upto = 12883,
        },
    },
    active = {
        type = "quest",
        id = 12894,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12903,12901,12904,12919
        },
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        18300, 19245, 20130, 20950, 21895, 22780, 23750, 24545, 25480, 26450, 27275, 28175, 29150, 29925, 30825, 31800, 32725, 33525, 34450, 35375, 36175, 37100, 38025, 38825, 39750, 40725, 41625, 42400, 43425, 44275, 5590, 5590, 4470, 3345, 2235, 1115, 565, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        18300, 19245, 20130, 20950, 21895, 22780, 23750, 24545, 25480, 26450, 27275, 27275, 21835, 16335, 10895, 5495, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 2740, 300, 
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
                        267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1106,
            amount = 1700,
        },
    },
    items = {
        {
            type = "npc",
            id = 29687,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 29455,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12894,
            x = 0,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "npc",
            id = 29647,
            x = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 12904,
            x = -3,
        },
        {
            type = "quest",
            id = 12903,
        },
        {
            type = "quest",
            id = 12901,
        },
        {
            type = "quest",
            id = 12912,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12914,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12916,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12919,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Betrayal, {
    name = L["BETRAYAL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12629, 12629, 12629, 12631, 12631, 12631, 12633, 12637, 12637, 12637, 12638, 12643, 12648, 12648, 12648, 12649, 12661, 12663, 12664, 12673, 12686, 12690, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12713,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        26200, 27550, 28900, 30000, 31350, 32700, 34150, 35150, 36600, 37950, 39000, 40450, 41800, 42800, 44250, 45600, 46950, 48050, 49400, 50750, 51850, 53200, 54550, 55650, 57000, 58350, 59800, 60800, 62250, 63600, 8040, 8040, 6405, 4775, 3220, 1610, 805, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        26200, 27550, 28900, 30000, 31350, 32700, 34150, 35150, 36600, 37950, 39000, 39000, 31350, 23350, 15650, 7845, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 3915, 435, 
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
        {
            type = "reputation",
            id = 1098,
            amount = 1500,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "item",
                    id = 38660,
                    restrictions = {
                        type = "quest",
                        id = 12631,
                    },
                },
                {
                    type = "item",
                    id = 38660,
                    restrictions = {
                        type = "item",
                        id = 38660,
                    },
                },
                {
                    type = "item",
                    id = 38673,
                    restrictions = {
                        type = "quest",
                        id = 12238,
                    },
                },
                {
                    type = "item",
                    id = 38660,
                },
            },
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 12631,
                    restrictions = {
                        type = "quest",
                        id = 12631,
                    },
                },
                {
                    type = "quest",
                    id = 12631,
                    restrictions = {
                        type = "item",
                        id = 38660,
                    },
                },
                {
                    type = "quest",
                    id = 12633,
                    restrictions = {
                        type = "quest",
                        id = 12238,
                    },
                },
                {
                    type = "quest",
                    id = 12631,
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
                    id = 12637,
                    restrictions = {
                        type = "quest",
                        id = 12631,
                    },
                },
                {
                    type = "quest",
                    id = 12637,
                    restrictions = {
                        type = "item",
                        id = 38660,
                    },
                },
                {
                    type = "quest",
                    id = 12638,
                    restrictions = {
                        type = "quest",
                        id = 12238,
                    },
                },
                {
                    type = "quest",
                    id = 12637,
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
                    id = 12629,
                    restrictions = {
                        type = "quest",
                        id = 12631,
                    },
                },
                {
                    type = "quest",
                    id = 12629,
                    restrictions = {
                        type = "item",
                        id = 38660,
                    },
                },
                {
                    type = "quest",
                    id = 12643,
                    restrictions = {
                        type = "quest",
                        id = 12238,
                    },
                },
                {
                    type = "quest",
                    id = 12629,
                },
            },
            x = 0,
            connections = {
                3, 1.2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            aside = true,
            embed = true,
        },
        {
            type = "npc",
            id = 28503,
            x = -2,
            y = 4,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 12648,
                    restrictions = {
                        type = "quest",
                        id = 12631,
                    },
                },
                {
                    type = "quest",
                    id = 12648,
                    restrictions = {
                        type = "item",
                        id = 38660,
                    },
                },
                {
                    type = "quest",
                    id = 12649,
                    restrictions = {
                        type = "quest",
                        id = 12238,
                    },
                },
                {
                    type = "quest",
                    id = 12648,
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            aside = true,
            ids = {
                12663, 12664, 
            },
            x = -2,
        },
        {
            type = "quest",
            id = 12661,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 28503,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 28503,
            aside = true,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12669,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12673,
            aside = true,
        },
        {
            type = "quest",
            id = 12686,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12677,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 28503,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12676,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12690,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12713,
            x = 0,
        },
        {
            type = "quest",
            id = 12710,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheArgentPatrol, {
    name = L["THE_ARGENT_PATROL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12503, 12512, 12557, 12597, 12598, 12599, 12740, 12795, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12504, 12506, 12508, 12512, 12554, 12555, 12584, 12596
        },
        count = 8,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        40250, 42445, 44580, 46100, 48295, 50430, 52600, 54145, 56280, 58500, 60025, 62125, 64350, 65875, 67975, 70200, 72375, 73875, 76050, 78225, 79725, 81900, 84075, 85575, 87750, 89975, 92075, 93600, 95825, 97925, 12420, 12420, 9880, 7320, 4965, 2480, 1245, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        40250, 42445, 44580, 46100, 48295, 50430, 52600, 54145, 56280, 58500, 60025, 60025, 48235, 35885, 24120, 12085, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 6005, 655, 
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
                        799825, 876825, 953810, 1030810, 1107795, 1184795, 1261780, 1338780, 1415765, 1492765, 1569750, 1666630, 1763500, 1860380, 1957250, 2054130, 2151010, 2247880, 2344760, 2441630, 2538510, 2635390, 2732260, 2829140, 2926010, 3022890, 3117970, 3213050, 3308140, 3403220, 3498300, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        799825, 876825, 953810, 1030810, 1107795, 1184795, 1261780, 1338780, 1415765, 1492765, 1569750, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1106,
            amount = 3585,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12795,
                    restrictions = {
                        type = "quest",
                        id = 12795,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 28059,
                },
            },
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 28125,
            x = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12503,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12740,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 12512,
            x = 3,
        },
        {
            type = "quest",
            id = 12506,
            x = -2,
        },
        {
            type = "quest",
            id = 12505,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12596,
        },
        {
            type = "quest",
            id = 12504,
            x = -1,
        },
        {
            type = "quest",
            id = 12508,
        },
        {
            type = "npc",
            id = 28043,
            aside = true,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 28042,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 28044,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 28205,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 12599,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 12597,
            aside = true,
        },
        {
            type = "quest",
            id = 12598,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 12557,
            aside = true,
        },
        {
            type = "quest",
            id = 12606,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12552,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12553,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12554,
            x = -1,
        },
        {
            type = "quest",
            id = 12584,
        },
        {
            type = "quest",
            id = 12583,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12555,
            x = 3,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Siphoning the Spirits
        type = "quest",
        id = 12799,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12799,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 12609, 12610 },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12750, 13200, 13500, 13950, 14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18900, 19200, 19650, 20100, 2550, 2550, 2025, 1500, 1020, 510, 255, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12300, 9900, 7350, 4950, 2475, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 135, 
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
                        160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1106,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 28045,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12799,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12609,
            x = -1,
        },
        {
            type = "quest",
            id = 12610,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Bringing Down Heb'Jin
        type = "quest",
        id = 12662,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.Sseratus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Quetzlun,
            upto = 12623,
        },
    },
    active = {
        type = "quest",
        id = 12622,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {12659, 12662},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 21250, 22000, 22500, 23250, 24000, 24750, 25250, 26000, 26750, 27250, 28000, 28750, 29250, 30000, 30750, 31500, 32000, 32750, 33500, 4250, 4250, 3375, 2500, 1700, 850, 425, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 20500, 16500, 12250, 8250, 4125, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 225, 
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
                        267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 
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
            id = 28484,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12622,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12640,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12639,
            aside = true,
        },
        {
            type = "quest",
            id = 12659,
            x = -1,
        },
        {
            type = "quest",
            id = 12662,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Tails Up
        type = "quest",
        id = 13549,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            type = "chain",
            id = Chain.Sseratus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Quetzlun,
            upto = 12627,
        },
    },
    active = {
        type = "quest",
        id = 12635,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 12650, 13549, },
        count = 2
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12750, 13200, 13500, 13950, 14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18900, 19200, 19650, 20100, 2550, 2550, 2025, 1500, 1020, 510, 255, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12300, 9900, 7350, 4950, 2475, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 135, 
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
                        53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 111480, 117960, 124440, 130920, 137400, 143880, 150360, 156840, 163320, 169800, 176280, 182760, 189240, 195720, 202200, 208560, 214920, 221280, 227640, 234000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 
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
            id = 28527,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12635,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12650,
            x = -1,
        },
        {
            type = "quest",
            id = 13549,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- Eggs for Dubra'Jin
        type = "quest",
        id = 13556,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 13556,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13556,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 33025,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13556,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12514,
    },
    items = {
        {
            type = "npc",
            id = 28062,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12565,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12514,
    },
    items = {
        {
            type = "npc",
            id = 28479,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12615,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12514,
    },
    items = {
        {
            type = "object",
            id = 191728,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12857,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12514,
    },
    items = {
        {
            type = "npc",
            id = 28589,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12652,
            x = 0,
        },
    },
})

Database:AddChain(Chain.IgnoreChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12514,
    },
    items = {
        {
            type = "npc",
            id = 28039,
        },
        {
            type = "quest",
            id = 12792,
            comment = "Kinda breadcrumb, 12793 and 12770 are alternatives. Maybe more",
        },
    },
})
Database:AddChain(Chain.IgnoreChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12514,
    },
    items = {
        {
            type = "npc",
            id = 28479,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12793,
            x = 0,
            comment = "Kinda breadcrumb, 12792 and 12770 are alternatives. Maybe more",
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
        { -- Troll Patrol, Daily, Obsolete
            type = "quest",
            id = 12501,
        },
        { -- Troll Patrol: High Standards, Daily
            type = "quest",
            id = 12502,
        },
        { -- Troll Patrol: Intestinal Fortitude, Daily
            type = "quest",
            id = 12509,
        },
        { -- Troll Patrol: Whatdya Want, a Medal?, Daily
            type = "quest",
            id = 12519,
        },
        { -- Troll Patrol: The Alchemist's Apprentice, Daily
            type = "quest",
            id = 12541,
        },
        { -- Troll Patrol, Obsolete
            type = "quest",
            id = 12563,
        },
        { -- Troll Patrol: Something for the Pain, Daily
            type = "quest",
            id = 12564,
        },
        { -- Blessing of Zim'Abwa, Repeatable
            type = "quest",
            id = 12567,
        },
        { -- Troll Patrol: Done to Death, Daily
            type = "quest",
            id = 12568,
        },
        { -- Troll Patrol: Creature Comforts, Daily
            type = "quest",
            id = 12585,
        },
        { -- Troll Patrol, Daily
            type = "quest",
            id = 12587,
        },
        { -- Troll Patrol: Can You Dig It?, Daily
            type = "quest",
            id = 12588,
        },
        { -- Blahblah[PH], Obsolete
            type = "quest",
            id = 12590,
        },
        { -- Troll Patrol: Throwing Down, Daily
            type = "quest",
            id = 12591,
        },
        { -- Troll Patrol: Couldn't Care Less, Daily
            type = "quest",
            id = 12594,
        },
        { -- Congratulations!, Daily
            type = "quest",
            id = 12604,
        },
        { -- Blessing of Zim'Torga, Repeatable
            type = "quest",
            id = 12618,
        },
        { -- Blessing of Zim'Rhuk, Repeatable
            type = "quest",
            id = 12656,
        },
        { -- Into the Breach!, Breadbrumb to Zul'Drak, doesnt seem to lead to a specific quest,
          -- may always be available too. There are multiple quests that lead to this npc.
          -- 12792, 12793, and 12770 are possible alternatives
            type = "quest",
            id = 12789,
        },
        { -- Zul'Drak, This is a an alternative of 12884 from the adventure journal but was apparently bugged
          -- because you didnt get the item required that came with 12884, might not even be available anymore
            type = "quest",
            id = 39208,
        }
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-ZulDrak]],
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.Sseratus,
        },
        {
            type = "chain",
            id = Chain.Quetzlun,
        },
        {
            type = "chain",
            id = Chain.Akali,
        },
        {
            type = "chain",
            id = Chain.TheAmphitheaterOfAnguish,
        },
        {
            type = "chain",
            id = Chain.FindingAllies,
        },
        {
            type = "chain",
            id = Chain.TheStormKingsCrusade,
        },
        {
            type = "chain",
            id = Chain.Betrayal,
        },
        {
            type = "chain",
            id = Chain.TheArgentPatrol,
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

Database:AddContinentItems(CONTINENT_ID, {})
