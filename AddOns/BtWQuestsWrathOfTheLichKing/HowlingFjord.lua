local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.HowlingFjord
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.HowlingFjord
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 117
local CONTINENT_ID = 113
local ACHIEVEMENT_ID_ALLIANCE = 34
local ACHIEVEMENT_ID_HORDE = 1356
local LEVEL_RANGE = {10, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 10,
    },
}

Chain.TheIllEquippedPort = 30201
Chain.VisitorsFromTheKeep = 30202
Chain.DescendantsOfTheVrykul = 30203
Chain.AssassinatingBjornHalgurdsson = 30204
Chain.IronRuneConstructs = 30205
Chain.ANewPlagueHorde = 30206
Chain.DoomApproaches = 30207
Chain.TheEndOfJonahSterling = 30208
Chain.TheDebtCollector = 30209
Chain.ANewPlagueAlliance = 30210
Chain.VolatileViscera = 30211
Chain.TheConquerorOfSkornAlliance = 30212
Chain.TheScourgeAndTheVrykulAlliance = 30213
Chain.TheIronDwarvesHorde = 30214
Chain.SistersOfTheFjord = 30215
Chain.TheConquerorOfSkornHorde = 30216
Chain.TheIronDwarvesAlliance = 30217
Chain.TheScourgeAndTheVrykulHorde = 30218
Chain.AlphaWorgAlliance = 30219
Chain.AlphaWorgHorde = 30220

Chain.Chain01 = 30221
Chain.Chain02 = 30222
Chain.Chain03 = 30223
Chain.Chain04 = 30224

Chain.EmbedChain01 = 30231
Chain.EmbedChain02 = 30232
Chain.EmbedChain03 = 30233
Chain.EmbedChain04 = 30234
Chain.EmbedChain05 = 30235
Chain.EmbedChain06 = 30236
Chain.EmbedChain07 = 30237
Chain.EmbedChain08 = 30238
Chain.EmbedChain09 = 30239
Chain.EmbedChain10 = 30240
Chain.EmbedChain11 = 30241
Chain.EmbedChain12 = 30242
Chain.EmbedChain13 = 30243
Chain.EmbedChain14 = 30244
Chain.EmbedChain15 = 30245
Chain.EmbedChain16 = 30246
Chain.EmbedChain17 = 30247
Chain.EmbedChain18 = 30248
Chain.EmbedChain19 = 30249
Chain.EmbedChain20 = 30250
Chain.EmbedChain21 = 30251
Chain.EmbedChain22 = 30252
Chain.EmbedChain23 = 30253
Chain.EmbedChain24 = 30254
Chain.EmbedChain25 = 30255
Chain.EmbedChain26 = 30256
Chain.EmbedChain27 = 30257
Chain.EmbedChain28 = 30258
Chain.EmbedChain29 = 30259
Chain.EmbedChain30 = 30260
Chain.EmbedChain31 = 30261
Chain.EmbedChain32 = 30262
Chain.EmbedChain33 = 30263
Chain.EmbedChain34 = 30264
Chain.EmbedChain35 = 30265
Chain.EmbedChain36 = 30266
Chain.EmbedChain37 = 30267
Chain.EmbedChain38 = 30268
Chain.EmbedChain39 = 30269
Chain.EmbedChain40 = 30270
Chain.EmbedChain41 = 30271
Chain.EmbedChain42 = 30272
Chain.EmbedChain43 = 30273
Chain.EmbedChain44 = 30274
Chain.EmbedChain45 = 30275
Chain.EmbedChain46 = 30276

Chain.OtherAlliance = 30297
Chain.OtherHorde = 30298
Chain.OtherBoth = 30299

Database:AddChain(Chain.TheIllEquippedPort, {
    name = L["THE_ILL_EQUIPPED_PORT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            49551, 11228, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11291,11436
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        21940, 24260, 26480, 28240, 30510, 32750, 35050, 36800, 39000, 41350, 43100, 45400, 47600, 49350, 51650, 53850, 56200, 57900, 60100, 62500, 64275, 66325, 68750, 70525, 72575, 75000, 77375, 78875, 81250, 83625, 85125, 87500, 89875, 91375, 93750, 96175, 98225, 100000, 102425, 104475, 13265, 13265, 10555, 7850, 5290, 2640, 1325, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21940, 24260, 26480, 28240, 30510, 32750, 35050, 36800, 39000, 41350, 43100, 45400, 47600, 49350, 51650, 53850, 56200, 57900, 60100, 62500, 64275, 64275, 51500, 38400, 25790, 12915, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 6405, 695, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        18500, 66140, 113775, 161415, 209050, 256690, 304325, 351965, 399600, 447240, 494875, 542515, 590150, 637790, 685425, 733065, 780700, 828340, 875975, 923615, 971250, 1031190, 1091130, 1151070, 1211010, 1270950, 1330890, 1390830, 1450770, 1510710, 1570650, 1630590, 1690530, 1750470, 1810410, 1870350, 1929180, 1988010, 2046840, 2105670, 2164500, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        18500, 66140, 113775, 161415, 209050, 256690, 304325, 351965, 399600, 447240, 494875, 542515, 590150, 637790, 685425, 733065, 780700, 828340, 875975, 923615, 971250, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 3865,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 49551,
                    restrictions = {
                        type = "quest",
                        id = 49551,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 23547,
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            aside = true,
            embed = true,
            x = 2,
        },
        {
            type = "quest",
            id = 11228,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11243,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11244,
            x = 0,
            connections = {
                1, 2, 3, 6, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            aside = true,
            embed = true,
            x = -3,
            y = 4,
        },
        {
            type = "quest",
            id = 11255,
            x = -1,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11288,
            aside = true,
            x = 3,
            y = 4,
        },
        {
            type = "quest",
            id = 11290,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11291,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            x = 1,
            y = 4,
        },
    },
})
Database:AddChain(Chain.VisitorsFromTheKeep, {
    name = L["VISITORS_FROM_THE_KEEP"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11270,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11234,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9810, 10865, 11820, 12710, 13665, 14625, 15650, 16500, 17425, 18500, 19350, 20375, 21300, 22150, 23175, 24100, 25100, 25975, 26950, 28000, 28800, 29750, 30800, 31600, 32550, 33600, 34550, 35450, 36400, 37350, 38250, 39200, 40150, 41050, 42000, 43050, 44000, 44800, 45900, 46800, 5905, 5905, 4735, 3510, 2365, 1185, 600, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9810, 10865, 11820, 12710, 13665, 14625, 15650, 16500, 17425, 18500, 19350, 20375, 21300, 22150, 23175, 24100, 25100, 25975, 26950, 28000, 28800, 28800, 23025, 17275, 11535, 5820, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 2900, 315, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        10000, 35750, 61500, 87250, 113000, 138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10000, 35750, 61500, 87250, 113000, 138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 525,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1067,
            amount = 1075,
            restrictions = 923,
        },
    },
    items = {
        {
            visible = false,
            x = -2,
        },
        {
            type = "npc",
            id = 23780,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11270,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11221,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11229,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11230,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11232,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            aside = true,
            embed = true,
            x = 2,
        },
        {
            type = "quest",
            id = 11233,
            x = 0,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11234,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DescendantsOfTheVrykul, {
    name = L["DESCENDANTS_OF_THE_VRYKUL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheIllEquippedPort,
            upto = 11244,
        }
    },
    active = {
        type = "quest",
        id = 11333,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11344,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4200, 4650, 5100, 5400, 5850, 6300, 6750, 7050, 7500, 7950, 8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12750, 13200, 13500, 13950, 14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18900, 19200, 19650, 20100, 2550, 2550, 2025, 1500, 1020, 510, 255, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4200, 4650, 5100, 5400, 5850, 6300, 6750, 7050, 7500, 7950, 8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12300, 9900, 7350, 4950, 2475, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 135, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 23975,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11333,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11343,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11344,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AssassinatingBjornHalgurdsson, {
    name = L["ASSASSINATING_BJORN_HALGURDSSON"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11227,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12481,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11030, 12225, 13260, 14330, 15375, 16410, 17580, 18550, 19560, 20830, 21800, 22970, 23980, 24950, 26120, 27130, 28200, 29270, 30330, 31500, 32425, 33475, 34650, 35575, 36625, 37800, 38825, 39925, 40950, 41975, 43075, 44100, 45125, 46225, 47250, 48425, 49475, 50400, 51625, 52625, 6630, 6630, 5325, 3950, 2650, 1335, 680, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11030, 12225, 13260, 14330, 15375, 16410, 17580, 18550, 19560, 20830, 21800, 22970, 23980, 24950, 26120, 27130, 28200, 29270, 30330, 31500, 32425, 32425, 25860, 19460, 12985, 6560, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 3275, 355, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 891840, 943680, 995520, 1047360, 1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 985,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1067,
            amount = 850,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 23938,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11227,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11253,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11254,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11295,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11282,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11283,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11285,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11303,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12481,
            x = 0,
        },
    },
})
Database:AddChain(Chain.IronRuneConstructs, {
    name = L["IRON_RUNE_CONSTRUCTS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11474, 11475, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11501,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        16130, 17890, 19460, 20880, 22490, 24065, 25820, 27100, 28665, 30420, 31700, 33455, 35020, 36300, 38055, 39620, 41250, 42655, 44220, 46000, 47300, 48800, 50600, 51900, 53400, 55200, 56850, 58150, 59800, 61450, 62750, 64400, 66050, 67350, 69000, 70800, 72300, 73600, 75400, 76900, 9750, 9750, 7785, 5765, 3885, 1940, 985, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16130, 17890, 19460, 20880, 22490, 24065, 25820, 27100, 28665, 30420, 31700, 33455, 35020, 36300, 38055, 39620, 41250, 42655, 44220, 46000, 47300, 47300, 37865, 28315, 18950, 9535, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 4745, 510, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 2865,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1068,
            amount = 2615,
            restrictions = 924,
        },
    },
    items = {
        {
            visible = false,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 11474,
                    restrictions = {
                        type = "quest",
                        id = 11474,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 24807,
                },
            },
            x = 0,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 11475,
            x = 0,
            y = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11483,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11484,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11485,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11489,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11491,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11494,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11495,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11501,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ANewPlagueHorde, {
    name = L["A_NEW_PLAGUE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            49533, 11167, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11307,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7530, 8325, 9110, 9680, 10475, 11260, 12030, 12650, 13410, 14230, 14850, 15620, 16380, 17000, 17770, 18530, 19350, 19920, 20730, 21500, 22075, 22875, 23650, 24225, 25025, 25800, 26575, 27175, 27950, 28725, 29325, 30100, 30875, 31475, 32250, 33025, 33825, 34400, 35225, 35975, 4555, 4555, 3625, 2695, 1820, 915, 455, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7530, 8325, 9110, 9680, 10475, 11260, 12030, 12650, 13410, 14230, 14850, 15620, 16380, 17000, 17770, 18530, 19350, 19920, 20730, 21500, 22075, 22075, 17710, 13210, 8885, 4435, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 2210, 245, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        7000, 25025, 43050, 61075, 79100, 97125, 115150, 133175, 151200, 169225, 187250, 205275, 223300, 241325, 259350, 277375, 295400, 313425, 331450, 349475, 367500, 390180, 412860, 435540, 458220, 480900, 503580, 526260, 548940, 571620, 594300, 616980, 639660, 662340, 685020, 707700, 729960, 752220, 774480, 796740, 819000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7000, 25025, 43050, 61075, 79100, 97125, 115150, 133175, 151200, 169225, 187250, 205275, 223300, 241325, 259350, 277375, 295400, 313425, 331450, 349475, 367500, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 250,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1067,
            amount = 910,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 49533,
                    restrictions = {
                        type = "quest",
                        id = 49533,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 24126,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11167,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11168,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11170,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11304,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11305,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11306,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11307,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DoomApproaches, {
    name = L["DOOM_APPROACHES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11504, 11573, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11572,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        21940, 24215, 26480, 28190, 30465, 32735, 34980, 36750, 38985, 41380, 43150, 45395, 47630, 49400, 51645, 53880, 56200, 57895, 60180, 62450, 64225, 66475, 68750, 70475, 72725, 75000, 77275, 78975, 81250, 83525, 85225, 87500, 89775, 91475, 93750, 96025, 98275, 100000, 102325, 104525, 13215, 13215, 10520, 7860, 5285, 2655, 1330, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21940, 24215, 26480, 28190, 30465, 32735, 34980, 36750, 38985, 41380, 43150, 45395, 47630, 49400, 51645, 53880, 56200, 57895, 60180, 62450, 64225, 64225, 51485, 38385, 25795, 12920, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 6425, 710, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1073,
            amount = 3660,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11573,
                    restrictions = {
                        type = "quest",
                        id = 11573,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 23804,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11504,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11507,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
            aside = true,
            embed = true,
            x = -2,
            y = 3,
        },
        {
            type = "quest",
            id = 11508,
            x = 0,
            y = 3,
            connections = {
                1, -1.2, 
            },
        },
        {
            type = "quest",
            id = 11509,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11510,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 11511,
            x = -3,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 11512,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 11519,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11567,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 11527,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11529,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11530, --@TODO Is this required for 11568 or should it be aside?
            x = 0,
        },
        {
            type = "quest",
            id = 11568,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11572,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheEndOfJonahSterling, {
    name = L["THE_END_OF_JONAH_STERLING"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.DoomApproaches,
            upto = 11509,
        }
    },
    active = {
        type = "quest",
        id = 11434,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11471,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8080, 8945, 9710, 10480, 11245, 12025, 12850, 13600, 14325, 15150, 15900, 16725, 17450, 18200, 19025, 19750, 20600, 21325, 22100, 23000, 23700, 24400, 25300, 26000, 26700, 27600, 28400, 29100, 29900, 30700, 31400, 32200, 33000, 33700, 34500, 35400, 36100, 36800, 37750, 38400, 4850, 4850, 3900, 2890, 1945, 965, 490, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8080, 8945, 9710, 10480, 11245, 12025, 12850, 13600, 14325, 15150, 15900, 16725, 17450, 18200, 19025, 19750, 20600, 21325, 22100, 23000, 23700, 23700, 18925, 14225, 9455, 4790, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 2380, 255, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        2000, 7150, 12300, 17450, 22600, 27750, 32900, 38050, 43200, 48350, 53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 111480, 117960, 124440, 130920, 137400, 143880, 150360, 156840, 163320, 169800, 176280, 182760, 189240, 195720, 202200, 208560, 214920, 221280, 227640, 234000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2000, 7150, 12300, 17450, 22600, 27750, 32900, 38050, 43200, 48350, 53500, 58650, 63800, 68950, 74100, 79250, 84400, 89550, 94700, 99850, 105000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 24537,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11434,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11455,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11473,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11459,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11476,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11479,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11480,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11471,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheDebtCollector, {
    name = L["THE_DEBT_COLLECTOR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheEndOfJonahSterling,
            upto = 11434,
        }
    },
    active = {
        type = "quest",
        id = 11464,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11467,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        3850, 4250, 4600, 5000, 5350, 5700, 6100, 6450, 6800, 7300, 7650, 8050, 8400, 8750, 9150, 9500, 9850, 10250, 10600, 11000, 11350, 11700, 12100, 12450, 12800, 13200, 13550, 13950, 14300, 14650, 15050, 15400, 15750, 16150, 16500, 16900, 17250, 17600, 18000, 18350, 2300, 2300, 1850, 1385, 920, 470, 240, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3850, 4250, 4600, 5000, 5350, 5700, 6100, 6450, 6800, 7300, 7650, 8050, 8400, 8750, 9150, 9500, 9850, 10250, 10600, 11000, 11350, 11350, 9000, 6800, 4550, 2300, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 1145, 125, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 24541,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11464,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11466,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11467,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ANewPlagueAlliance, {
    name = L["A_NEW_PLAGUE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11157,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11332,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17700, 19625, 21400, 22850, 24675, 26450, 28350, 29750, 31500, 33400, 34800, 36700, 38450, 39850, 41750, 43500, 45350, 46800, 48600, 50500, 51875, 53625, 55550, 56925, 58675, 60600, 62425, 63825, 65650, 67475, 68875, 70700, 72525, 73925, 75750, 77675, 79425, 80800, 82775, 84475, 10720, 10720, 8540, 6325, 4270, 2135, 1075, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17700, 19625, 21400, 22850, 24675, 26450, 28350, 29750, 31500, 33400, 34800, 36700, 38450, 39850, 41750, 43500, 45350, 46800, 48600, 50500, 51875, 51875, 41600, 31050, 20825, 10435, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 565, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        23200, 82940, 142680, 202420, 262160, 321900, 381640, 441380, 501120, 560860, 620600, 680340, 740080, 799820, 859560, 919300, 979040, 1038780, 1098520, 1158260, 1218000, 1293170, 1368335, 1443505, 1518670, 1593840, 1669010, 1744175, 1819345, 1894510, 1969680, 2044850, 2120015, 2195185, 2270350, 2345520, 2419295, 2493070, 2566850, 2640625, 2714400, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        23200, 82940, 142680, 202420, 262160, 321900, 381640, 441380, 501120, 560860, 620600, 680340, 740080, 799820, 859560, 919300, 979040, 1038780, 1098520, 1158260, 1218000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1975,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1068,
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain09,
            aside = true,
            embed = true,
            x = -4,
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            type = "npc",
            id = 23749,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 11157,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11187,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11188,
            x = 0,
            y = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 11224,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 11199,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11218,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11202,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11240,
            aside = true,
        },
        {
            type = "quest",
            id = 11327,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11328,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11330,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11331,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11332,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11406,
            aside = true,
            x = 0,
            comment = "Is this always available?",
        },
    },
})
Database:AddChain(Chain.VolatileViscera, {
    name = L["VOLATILE_VISCERA"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.ANewPlagueHorde,
        }
    },
    active = {
        type = "quest",
        id = 11308,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11310,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9460, 10490, 11420, 12260, 13190, 14125, 15150, 15900, 16825, 17850, 18600, 19625, 20550, 21300, 22325, 23250, 24200, 25025, 25950, 27000, 27750, 28650, 29700, 30450, 31350, 32400, 33350, 34150, 35100, 36050, 36850, 37800, 38750, 39550, 40500, 41550, 42450, 43200, 44250, 45150, 5710, 5710, 4570, 3380, 2285, 1140, 580, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9460, 10490, 11420, 12260, 13190, 14125, 15150, 15900, 16825, 17850, 18600, 19625, 20550, 21300, 22325, 23250, 24200, 25025, 25950, 27000, 27750, 27750, 22225, 16625, 11110, 5610, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 2790, 300, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 750,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1067,
            amount = 500,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain12,
            aside = true,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            aside = true,
            embed = true,
        },
    },
})
Database:AddChain(Chain.TheConquerorOfSkornAlliance, {
    name = L["THE_CONQUEROR_OF_SKORN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.ANewPlagueAlliance,
        }
    },
    active = {
        type = "quest",
        id = 11248,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11250,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7880, 8750, 9510, 10230, 11000, 11760, 12630, 13250, 14010, 14880, 15500, 16370, 17130, 17750, 18620, 19380, 20150, 20870, 21630, 22500, 23125, 23875, 24750, 25375, 26125, 27000, 27775, 28475, 29250, 30025, 30725, 31500, 32275, 32975, 33750, 34625, 35375, 36000, 36875, 37625, 4760, 4760, 3810, 2815, 1900, 950, 485, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7880, 8750, 9510, 10230, 11000, 11760, 12630, 13250, 14010, 14880, 15500, 16370, 17130, 17750, 18620, 19380, 20150, 20870, 21630, 22500, 23125, 23125, 18510, 13860, 9260, 4675, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 250, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1460,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 23749,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11248,
            x = 0,
            connections = {
                1.2, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 11245,
            x = -3,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 11246,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11247,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11250,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheScourgeAndTheVrykulAlliance, {
    name = L["THE_SCOURGE_AND_THE_VRYKUL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheConquerorOfSkornAlliance,
        }
    },
    active = {
        type = "quest",
        ids = {
            11235, 11231, 11237, 11452, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11452,11236,11239,11432,11238
        },
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12250, 13600, 14800, 15900, 17100, 18300, 19650, 20600, 21800, 23150, 24100, 25450, 26650, 27600, 28950, 30150, 31350, 32450, 33650, 35000, 35950, 37150, 38500, 39450, 40650, 42000, 43200, 44300, 45500, 46700, 47800, 49000, 50200, 51300, 52500, 53850, 55050, 56000, 57350, 58550, 7400, 7400, 5925, 4375, 2960, 1480, 755, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12250, 13600, 14800, 15900, 17100, 18300, 19650, 20600, 21800, 23150, 24100, 25450, 26650, 27600, 28950, 30150, 31350, 32450, 33650, 35000, 35950, 35950, 28800, 21550, 14400, 7275, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 390, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 2300,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain16,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain17,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
            embed = true,
            x = 3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain19,
            embed = true,
            x = -3,
        },
    },
})
Database:AddChain(Chain.TheIronDwarvesHorde, {
    name = L["THE_IRON_DWARVES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11275,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11352,11367
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12950, 14350, 15700, 16700, 18050, 19400, 20800, 21750, 23100, 24500, 25450, 26850, 28200, 29150, 30550, 31900, 33250, 34250, 35600, 37000, 37950, 39300, 40700, 41650, 43000, 44400, 45750, 46750, 48100, 49450, 50450, 51800, 53150, 54150, 55500, 56900, 58250, 59200, 60600, 61950, 7850, 7850, 6250, 4625, 3140, 1570, 790, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12950, 14350, 15700, 16700, 18050, 19400, 20800, 21750, 23100, 24500, 25450, 26850, 28200, 29150, 30550, 31900, 33250, 34250, 35600, 37000, 37950, 37950, 30500, 22700, 15250, 7650, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 415, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        20000, 71500, 123000, 174500, 226000, 277500, 329000, 380500, 432000, 483500, 535000, 586500, 638000, 689500, 741000, 792500, 844000, 895500, 947000, 998500, 1050000, 1114800, 1179600, 1244400, 1309200, 1374000, 1438800, 1503600, 1568400, 1633200, 1698000, 1762800, 1827600, 1892400, 1957200, 2022000, 2085600, 2149200, 2212800, 2276400, 2340000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        20000, 71500, 123000, 174500, 226000, 277500, 329000, 380500, 432000, 483500, 535000, 586500, 638000, 689500, 741000, 792500, 844000, 895500, 947000, 998500, 1050000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 2100,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain20,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            type = "npc",
            id = 24123,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain21,
            aside = true,
            embed = true,
            x = 2,
        },
        {
            type = "quest",
            id = 11275,
            x = 0,
            y = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
            embed = true,
        },
    },
})
Database:AddChain(Chain.SistersOfTheFjord, {
    name = L["SISTERS_OF_THE_FJORD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11302, 11313, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11428,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8750, 9700, 10600, 11300, 12200, 13100, 14050, 14700, 15600, 16550, 17200, 18150, 19050, 19700, 20650, 21550, 22450, 23150, 24050, 25000, 25650, 26550, 27500, 28150, 29050, 30000, 30900, 31600, 32500, 33400, 34100, 35000, 35900, 36600, 37500, 38450, 39350, 40000, 40950, 41850, 5300, 5300, 4225, 3125, 2120, 1060, 535, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8750, 9700, 10600, 11300, 12200, 13100, 14050, 14700, 15600, 16550, 17200, 18150, 19050, 19700, 20650, 21550, 22450, 23150, 24050, 25000, 25650, 25650, 20600, 15350, 10300, 5175, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 280, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 10,
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
                    id = 11302,
                    restrictions = {
                        type = "quest",
                        id = 11302,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 24117,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11313,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11314,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 11315,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11316,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11319,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11428,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheConquerorOfSkornHorde, {
    name = L["THE_CONQUEROR_OF_SKORN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "quest",
            id = 11281,
        },
    },
    active = {
        type = "quest",
        id = 11256,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11261,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7880, 8750, 9510, 10230, 11000, 11760, 12630, 13250, 14010, 14880, 15500, 16370, 17130, 17750, 18620, 19380, 20150, 20870, 21630, 22500, 23125, 23875, 24750, 25375, 26125, 27000, 27775, 28475, 29250, 30025, 30725, 31500, 32275, 32975, 33750, 34625, 35375, 36000, 36875, 37625, 4760, 4760, 3810, 2815, 1900, 950, 485, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7880, 8750, 9510, 10230, 11000, 11760, 12630, 13250, 14010, 14880, 15500, 16370, 17130, 17750, 18620, 19380, 20150, 20870, 21630, 22500, 23125, 23125, 18510, 13860, 9260, 4675, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 2330, 250, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 1460,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 24129,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11256,
            x = 0,
            connections = {
                1.2, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain24,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 11257,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 11258,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11259,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11261,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheIronDwarvesAlliance, {
    name = L["THE_IRON_DWARVES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11329,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11348,11359
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        16800, 18600, 20350, 21650, 23400, 25150, 26950, 28200, 29950, 31800, 33050, 34850, 36600, 37850, 39650, 41400, 43150, 44450, 46200, 48000, 49250, 51000, 52800, 54050, 55800, 57600, 59350, 60650, 62400, 64150, 65450, 67200, 68950, 70250, 72000, 73800, 75550, 76800, 78600, 80350, 10175, 10175, 8100, 6005, 4070, 2040, 1025, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16800, 18600, 20350, 21650, 23400, 25150, 26950, 28200, 29950, 31800, 33050, 34850, 36600, 37850, 39650, 41400, 43150, 44450, 46200, 48000, 49250, 49250, 39550, 29450, 19800, 9925, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 4935, 540, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        25500, 91165, 156825, 222490, 288150, 353815, 419475, 485140, 550800, 616465, 682125, 747790, 813450, 879115, 944775, 1010440, 1076100, 1141765, 1207425, 1273090, 1338750, 1421370, 1503990, 1586610, 1669230, 1751850, 1834470, 1917090, 1999710, 2082330, 2164950, 2247570, 2330190, 2412810, 2495430, 2578050, 2659140, 2740230, 2821320, 2902410, 2983500, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        25500, 91165, 156825, 222490, 288150, 353815, 419475, 485140, 550800, 616465, 682125, 747790, 813450, 879115, 944775, 1010440, 1076100, 1141765, 1207425, 1273090, 1338750, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 2000,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1068,
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain25,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            type = "npc",
            id = 24056,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
            aside = true,
            embed = true,
            x = 2,
        },
        {
            type = "quest",
            id = 11329,
            x = 0,
            y = 1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
            aside = true,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain28,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain29,
            embed = true,
        },
        {
            type = "quest",
            id = 11410,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheScourgeAndTheVrykulHorde, {
    name = L["THE_SCOURGE_AND_THE_VRYKUL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheConquerorOfSkornHorde,
        }
    },
    active = {
        type = "quest",
        ids = {
            11263, 11265, 11266, 11453, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11264,11268,11433,11453,11267
        },
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12250, 13600, 14800, 15900, 17100, 18300, 19650, 20600, 21800, 23150, 24100, 25450, 26650, 27600, 28950, 30150, 31350, 32450, 33650, 35000, 35950, 37150, 38500, 39450, 40650, 42000, 43200, 44300, 45500, 46700, 47800, 49000, 50200, 51300, 52500, 53850, 55050, 56000, 57350, 58550, 7400, 7400, 5925, 4375, 2960, 1480, 755, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12250, 13600, 14800, 15900, 17100, 18300, 19650, 20600, 21800, 23150, 24100, 25450, 26650, 27600, 28950, 30150, 31350, 32450, 33650, 35000, 35950, 35950, 28800, 21550, 14400, 7275, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 3625, 390, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 2300,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain30,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain31,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain32,
            embed = true,
            x = 3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain33,
            embed = true,
            x = -3,
        },
    },
})
Database:AddChain(Chain.AlphaWorgAlliance, {
    name = L["ALPHA_WORG"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11322,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11326,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11730, 13000, 14210, 15130, 16350, 17560, 18830, 19700, 20910, 22180, 23050, 24320, 25530, 26400, 27670, 28880, 30100, 31020, 32230, 33500, 34375, 35575, 36850, 37725, 38925, 40200, 41425, 42325, 43550, 44775, 45675, 46900, 48125, 49025, 50250, 51525, 52725, 53600, 54875, 56075, 7110, 7110, 5660, 4190, 2840, 1420, 715, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11730, 13000, 14210, 15130, 16350, 17560, 18830, 19700, 20910, 22180, 23050, 24320, 25530, 26400, 27670, 28880, 30100, 31020, 32230, 33500, 34375, 34375, 27610, 20560, 13810, 6925, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 3445, 375, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 850,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1068,
            amount = 510,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain34,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain35,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain36,
            aside = true,
            embed = true,
        },
    },
})
Database:AddChain(Chain.AlphaWorgHorde, {
    name = L["ALPHA_WORG"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11286, 11287, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11324,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10150, 11250, 12300, 13100, 14150, 15200, 16300, 17050, 18100, 19200, 19950, 21050, 22100, 22850, 23950, 25000, 26050, 26850, 27900, 29000, 29750, 30800, 31900, 32650, 33700, 34800, 35850, 36650, 37700, 38750, 39550, 40600, 41650, 42450, 43500, 44600, 45650, 46400, 47500, 48550, 6150, 6150, 4900, 3625, 2460, 1230, 620, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10150, 11250, 12300, 13100, 14150, 15200, 16300, 17050, 18100, 19200, 19950, 21050, 22100, 22850, 23950, 25000, 26050, 26850, 27900, 29000, 29750, 29750, 23900, 17800, 11950, 6000, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 325, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        10000, 35750, 61500, 87250, 113000, 138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10000, 35750, 61500, 87250, 113000, 138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 1100,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain37,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 11287,
                    restrictions = {
                        type = "quest",
                        id = 11287,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 24186,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11286,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11317,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11323,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11415,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11417,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11324,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- It's a Scourge Device
        type = "quest",
        id = 11395,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 11393, 11394, 11395 },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 11394, 11396 },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4730, 5250, 5710, 6130, 6600, 7060, 7580, 7950, 8410, 8930, 9300, 9820, 10280, 10650, 11170, 11630, 12100, 12520, 12980, 13500, 13875, 14325, 14850, 15225, 15675, 16200, 16675, 17075, 17550, 18025, 18425, 18900, 19375, 19775, 20250, 20775, 21225, 21600, 22125, 22575, 2860, 2860, 2285, 1690, 1140, 570, 290, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4730, 5250, 5710, 6130, 6600, 7060, 7580, 7950, 8410, 8930, 9300, 9820, 10280, 10650, 11170, 11630, 12100, 12520, 12980, 13500, 13875, 13875, 11110, 8310, 5560, 2800, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 150, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1068,
            amount = 610,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain38,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain39,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain40,
            aside = true,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- It's a Scourge Device
        type = "quest",
        id = 11398,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 11397, 11398 },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 11397, 11399 },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4730, 5250, 5710, 6130, 6600, 7060, 7580, 7950, 8410, 8930, 9300, 9820, 10280, 10650, 11170, 11630, 12100, 12520, 12980, 13500, 13875, 14325, 14850, 15225, 15675, 16200, 16675, 17075, 17550, 18025, 18425, 18900, 19375, 19775, 20250, 20775, 21225, 21600, 22125, 22575, 2860, 2860, 2285, 1690, 1140, 570, 290, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4730, 5250, 5710, 6130, 6600, 7060, 7580, 7950, 8410, 8930, 9300, 9820, 10280, 10650, 11170, 11630, 12100, 12520, 12980, 13500, 13875, 13875, 11110, 8310, 5560, 2800, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 150, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1067,
            amount = 610,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain41,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain42,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain40,
            aside = true,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Brains! Brains! Brains!
        type = "quest",
        id = 11301,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 11297, 11298, 11301 },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 11298, 11301 },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        2800, 3100, 3400, 3600, 3900, 4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 1700, 1700, 1350, 1000, 680, 340, 170, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2800, 3100, 3400, 3600, 3900, 4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8200, 6600, 4900, 3300, 1650, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 90, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1067,
            amount = 500,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain43,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain44,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- Against Nifflevar
        type = "quest",
        id = 12482,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 11423, 12482 },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 11423, 12482 },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        2800, 3100, 3400, 3600, 3900, 4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 1700, 1700, 1350, 1000, 680, 340, 170, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2800, 3100, 3400, 3600, 3900, 4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8200, 6600, 4900, 3300, 1650, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 90, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 250,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1067,
            amount = 250,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain45,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain46,
            embed = true,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 23730,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11443,
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
        id = 11474,
    },
    items = {
        {
            type = "quest",
            id = 11273,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11274,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11276,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11277,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11299,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11300,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11278,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11448,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11436,
    },
    items = {
        {
            type = "quest",
            id = 11420,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11426,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11427,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11429,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11430,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11421,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11436,
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
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 23784,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11241,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24811,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            variations = {
                {
                    restrictions = {
                        type = "quest",
                        id = 11448,
                        status = { "notcompleted", },
                    },
                    x = -1,
                },
                {
                    x = 0,
                },
            },
            id = 11477,
        },
        {
            type = "quest",
            id = 11478,
            visible = {
                type = "quest",
                id = 11448,
                status = { "notcompleted", },
            },
            comment = "Cannot be accepted if [11448] is already completed, need to check if other way around is true",
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24750,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11460,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11465,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11468,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11470,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11458,
    },
    items = {
        {
            type = "npc",
            id = 24755,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11456,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11457,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11458,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain08, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24784,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11469,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 23773,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11155,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain10, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 23770,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11190,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain11, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 23870,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11182,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain12, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24252,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11424,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain13, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24251,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11308,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11309,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11310,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24157,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11279,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11280,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            name = L["KILL_VRYKUL"],
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11249,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11236,
    },
    items = {
        {
            type = "npc",
            id = 23749,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11235,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11236,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11239,
    },
    items = {
        {
            type = "npc",
            id = 24038,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11231,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11239,
            x = -1,
        },
        {
            type = "quest",
            id = 11432,
        },
    },
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11238,
    },
    items = {
        {
            type = "item",
            id = 33289,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11238,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11452,
    },
    items = {
        {
            type = "item",
            id = 34090,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11452,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain20, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24127,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11271,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24256,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11311,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain22, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11352,
    },
    items = {
        {
            type = "quest",
            id = 11350,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11351,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11352,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11367,
    },
    items = {
        {
            type = "quest",
            id = 11365,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11366,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11367,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain24, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            name = L["KILL_VRYKUL"],
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11260,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain25, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11284,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain26, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24131,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11292,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11418,
    },
    items = {
        {
            type = "npc",
            id = 24139,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11269,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11418,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain28, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11348,
    },
    items = {
        {
            type = "quest",
            id = 11346,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11349,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11348,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain29, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11359,
    },
    items = {
        {
            type = "quest",
            id = 11355,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11358,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11359,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain30, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11264,
    },
    items = {
        {
            type = "npc",
            id = 24129,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11263,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11264,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain31, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11268,
    },
    items = {
        {
            type = "npc",
            id = 24135,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11265,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11268,
            x = -1,
        },
        {
            type = "quest",
            id = 11433,
        },
    },
})
Database:AddChain(Chain.EmbedChain32, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11267,
    },
    items = {
        {
            type = "item",
            id = 33347,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11266,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11267,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain33, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11453,
    },
    items = {
        {
            type = "item",
            id = 34091,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11453,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain34, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24227,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11154,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain35, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24273,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11322,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11325,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11414,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11416,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11326,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain36, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11175,
                    restrictions = {
                        type = "quest",
                        id = 11175,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 23891,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11390,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11391,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain37, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24209,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11296,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain38, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11393,
                    restrictions = {
                        type = "quest",
                        id = 11393,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 23833,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11394,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain39, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "kill",
            id = 24485,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11395,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11396,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain40, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24544,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11422,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain41, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24359,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11397,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain42, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "kill",
            id = 24485,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11398,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11399,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain43, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11297,
                    restrictions = {
                        type = "quest",
                        id = 11297,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 24152,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11298,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain44, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24218,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11301,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain45, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 24548,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11423,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain46, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11391,
    },
    items = {
        {
            type = "npc",
            id = 27922,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12482,
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
        { -- Break the Blockade, Daily
            type = "quest",
            id = 11153,
        },
        { -- [Temporarily Deprecated Awaiting a New Mob]Finlay Is Gutless, Obsolete
            type = "quest",
            id = 11179,
        },
        { -- Stop the Ascension!
            type = "quest",
            id = 11260,
        },
        { -- Find Sage Mistwalker
            type = "quest",
            id = 11287,
        },
        { -- Guided by Honor, Follows 11288
            type = "quest",
            id = 11289,
        },
        { -- Camp Winterhoof, Obsolete
            type = "quest",
            id = 11411,
        },
        { -- The Way to His Heart..., Daily
            type = "quest",
            id = 11472,
        },
        { -- Help for Camp Winterhoof, Leads to Camp Winterhoof but not to a specific quest
            type = "quest",
            id = 12566,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-HowlingFjord]],
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.TheIllEquippedPort,
        },
        {
            type = "chain",
            id = Chain.VisitorsFromTheKeep,
        },
        {
            type = "chain",
            id = Chain.DescendantsOfTheVrykul,
        },
        {
            type = "chain",
            id = Chain.AssassinatingBjornHalgurdsson,
        },
        {
            type = "chain",
            id = Chain.IronRuneConstructs,
        },
        {
            type = "chain",
            id = Chain.ANewPlagueHorde,
        },
        {
            type = "chain",
            id = Chain.DoomApproaches,
        },
        {
            type = "chain",
            id = Chain.TheEndOfJonahSterling,
        },
        {
            type = "chain",
            id = Chain.TheDebtCollector,
        },
        {
            type = "chain",
            id = Chain.ANewPlagueAlliance,
        },
        {
            type = "chain",
            id = Chain.VolatileViscera,
        },
        {
            type = "chain",
            id = Chain.TheConquerorOfSkornAlliance,
        },
        {
            type = "chain",
            id = Chain.TheScourgeAndTheVrykulAlliance,
        },
        {
            type = "chain",
            id = Chain.TheIronDwarvesHorde,
        },
        {
            type = "chain",
            id = Chain.SistersOfTheFjord,
        },
        {
            type = "chain",
            id = Chain.TheConquerorOfSkornHorde,
        },
        {
            type = "chain",
            id = Chain.TheIronDwarvesAlliance,
        },
        {
            type = "chain",
            id = Chain.TheScourgeAndTheVrykulHorde,
        },
        {
            type = "chain",
            id = Chain.AlphaWorgAlliance,
        },
        {
            type = "chain",
            id = Chain.AlphaWorgHorde,
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
