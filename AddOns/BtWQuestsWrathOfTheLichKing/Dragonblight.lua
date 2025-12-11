local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.Dragonblight
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.Dragonblight
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 115
local CONTINENT_ID = 113
local ACHIEVEMENT_ID_ALLIANCE = 35
local ACHIEVEMENT_ID_HORDE = 1359
local LEVEL_RANGE = {15, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 15,
    },
}

Chain.TheWardensTask = 30301
Chain.TheTaunka = 30302
Chain.RedirectingTheLeyLinesAlliance = 30303
Chain.TraitorsToTheHorde = 30304
Chain.InformingTheQueenAlliance = 30305
Chain.RedirectingTheLeyLinesHorde = 30306
Chain.TheDragonflights = 30307
Chain.ContainingTheRot = 30308
Chain.AngratharTheWrathgateAlliance = 30309
Chain.AngratharTheWrathgateHorde = 30310
Chain.Frostmourne = 30311
Chain.InformingTheQueenHorde = 30312
Chain.StrategicAlliance = 30313
Chain.TheScarletOnslaught = 30314
Chain.Oachanoa = 30315

Chain.Chain01 = 30321
Chain.Chain02 = 30322
Chain.Chain03 = 30323
Chain.Chain04 = 30324
Chain.Chain05 = 30325
Chain.Chain06 = 30326
Chain.Chain07 = 30327

Chain.EmbedChain01 = 30331
Chain.EmbedChain02 = 30332
Chain.EmbedChain03 = 30333
Chain.EmbedChain04 = 30334
Chain.EmbedChain05 = 30335
Chain.EmbedChain06 = 30336
Chain.EmbedChain07 = 30337
Chain.EmbedChain08 = 30338
Chain.EmbedChain09 = 30339
Chain.EmbedChain10 = 30340
Chain.EmbedChain11 = 30341
Chain.EmbedChain12 = 30342
Chain.EmbedChain13 = 30343
Chain.EmbedChain14 = 30344
Chain.EmbedChain15 = 30345
Chain.EmbedChain16 = 30346
Chain.EmbedChain17 = 30347
Chain.EmbedChain18 = 30348
Chain.EmbedChain19 = 30349
Chain.EmbedChain20 = 30350
Chain.EmbedChain21 = 30351

Chain.IgnoreChain01 = 30361

Chain.OtherAlliance = 30397
Chain.OtherHorde = 30398
Chain.OtherBoth = 30399

Database:AddChain(Chain.TheWardensTask, {
    name = L["THE_WARDENS_TASK"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12166,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12169,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7060, 7580, 7950, 8410, 8930, 9300, 9820, 10280, 10650, 11170, 11630, 12100, 12520, 12980, 13500, 13875, 14325, 14850, 15225, 15675, 16200, 16675, 17075, 17550, 18025, 18425, 18900, 19375, 19775, 20250, 20775, 21225, 21600, 22125, 22575, 2860, 2860, 2285, 1690, 1140, 570, 290, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7060, 7580, 7950, 8410, 8930, 9300, 9820, 10280, 10650, 11170, 11630, 12100, 12520, 12980, 13500, 13875, 13875, 11110, 8310, 5560, 2800, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 1395, 150, 
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
            id = 1050,
            amount = 860,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 26973,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12166,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "item",
            id = 36958,
            breadcrumb = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12167,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12168,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12169,
            x = 1,
        },
    },
})
Database:AddChain(Chain.TheTaunka, {
    name = L["THE_TAUNKA"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11979, 11977, 11978, 11980, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12008,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7300, 7800, 8200, 8700, 9300, 9700, 10200, 10700, 11100, 11600, 12100, 12600, 13000, 13500, 14000, 14400, 14900, 15400, 15800, 16300, 16800, 17300, 17700, 18200, 18700, 19100, 19600, 20100, 20500, 21000, 21500, 22000, 22400, 22900, 23400, 2950, 2950, 2350, 1760, 1180, 600, 300, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7300, 7800, 8200, 8700, 9300, 9700, 10200, 10700, 11100, 11600, 12100, 12600, 13000, 13500, 14000, 14400, 14400, 11500, 8600, 5800, 2900, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 1440, 160, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 400,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 800,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11979,
                    restrictions = {
                        type = "quest",
                        id = 11979,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 11977,
                    restrictions = {
                        type = "quest",
                        id = 11977,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 26181,
                },
            },
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 26180,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11978,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11980,
            aside = true,
        },
        {
            type = "quest",
            id = 11983,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12008,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RedirectingTheLeyLinesAlliance, {
    name = L["REDIRECTING_THE_LEY_LINES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11995, 12000, 12440, 39204, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12107,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        25650, 27500, 28850, 30550, 32400, 33750, 35600, 37300, 38650, 40500, 42200, 43950, 45400, 47150, 49000, 50300, 52050, 53900, 55200, 56950, 58800, 60500, 62000, 63700, 65400, 66900, 68600, 70300, 71800, 73500, 75350, 77100, 78400, 80300, 82000, 10370, 10370, 8290, 6125, 4150, 2075, 1050, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        25650, 27500, 28850, 30550, 32400, 33750, 35600, 37300, 38650, 40500, 42200, 43950, 45400, 47150, 49000, 50300, 50300, 40350, 30150, 20175, 10160, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 5065, 550, 
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
                        388500, 460600, 532700, 604800, 676900, 749000, 821100, 893200, 965300, 1037400, 1109500, 1181600, 1253700, 1325800, 1397900, 1470000, 1560720, 1651440, 1742160, 1832880, 1923600, 2014320, 2105040, 2195760, 2286480, 2377200, 2467920, 2558640, 2649360, 2740080, 2830800, 2919840, 3008880, 3097920, 3186960, 3276000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        388500, 460600, 532700, 604800, 676900, 749000, 821100, 893200, 965300, 1037400, 1109500, 1181600, 1253700, 1325800, 1397900, 1470000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 500,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1090,
            amount = 2025,
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
            id = Chain.EmbedChain01,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 11995,
                    restrictions = {
                        type = "quest",
                        id = 11995,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 12440,
                    restrictions = {
                        type = "quest",
                        id = 12440,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 39204,
                    restrictions = {
                        type = "quest",
                        id = 39204,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26673,
                },
            },
            x = -1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12000,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "item",
            id = 36742,
            breadcrumb = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12004,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12055,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12060,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12065,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12067,
            aside = true,
        },
        {
            type = "quest",
            id = 12083,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12092,
            aside = true,
        },
        {
            type = "quest",
            id = 12098,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12107,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TraitorsToTheHorde, {
    name = L["TRAITORS_TO_THE_HORDE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            name = "Unknown",
            type = "quest",
            id = 12036,
        },
    },
    active = {
        type = "quest",
        id = 12057,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12136,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14410, 15430, 16200, 17160, 18180, 18950, 19970, 20930, 21700, 22720, 23680, 24650, 25470, 26430, 27450, 28275, 29225, 30250, 31025, 31975, 33000, 33975, 34775, 35750, 36725, 37525, 38500, 39475, 40275, 41250, 42275, 43225, 44000, 45025, 45975, 5810, 5810, 4635, 3465, 2320, 1160, 590, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14410, 15430, 16200, 17160, 18180, 18950, 19970, 20930, 21700, 22720, 23680, 24650, 25470, 26430, 27450, 28275, 28275, 22660, 16910, 11310, 5700, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 2840, 310, 
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
        {
            type = "reputation",
            id = 1085,
            amount = 1860,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "item",
            id = 36744,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12057,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12115,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12125,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12126,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12127,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12132,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12136,
            x = 0,
        },
    },
})
Database:AddChain(Chain.InformingTheQueenAlliance, {
    name = L["INFORMING_THE_QUEEN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.RedirectingTheLeyLinesAlliance,
        }
    },
    active = {
        type = "quest",
        id = 12119,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12123,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9150, 9800, 10350, 10900, 11550, 12100, 12750, 13300, 13850, 14500, 15050, 15700, 16250, 16800, 17500, 18075, 18525, 19250, 19825, 20275, 21000, 21675, 22075, 22750, 23425, 23825, 24500, 25175, 25575, 26250, 26975, 27425, 28000, 28725, 29175, 3720, 3720, 2965, 2210, 1470, 730, 370, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9150, 9800, 10350, 10900, 11550, 12100, 12750, 13300, 13850, 14500, 15050, 15700, 16250, 16800, 17500, 18075, 18075, 14400, 10800, 7220, 3620, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 1795, 190, 
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
                        120715, 143115, 165520, 187920, 210325, 232725, 255130, 277530, 299935, 322335, 344740, 367140, 389545, 411945, 434350, 456750, 484940, 513125, 541315, 569500, 597690, 625880, 654065, 682255, 710440, 738630, 766820, 795005, 823195, 851380, 879570, 907235, 934900, 962570, 990235, 1017900, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        120715, 143115, 165520, 187920, 210325, 232725, 255130, 277530, 299935, 322335, 344740, 367140, 389545, 411945, 434350, 456750, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 10,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1091,
            amount = 1165,
        },
    },
    items = {
        {
            type = "npc",
            id = 26673,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12119,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12766,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12460,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12416,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12417,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "item",
            id = 37833,
            breadcrumb = true,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12418,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12419,
            aside = true,
        },
        {
            type = "quest",
            id = 12768,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12123,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12435,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RedirectingTheLeyLinesHorde, {
    name = L["REDIRECTING_THE_LEY_LINES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            39203, 11996, 11999, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12110,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        20950, 22450, 23550, 24950, 26450, 27550, 29050, 30450, 31550, 33050, 34450, 35900, 37050, 38500, 40000, 41050, 42500, 44000, 45050, 46500, 48000, 49400, 50600, 52000, 53400, 54600, 56000, 57400, 58600, 60000, 61500, 62950, 64000, 65550, 66950, 8470, 8470, 6765, 5000, 3390, 1695, 855, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        20950, 22450, 23550, 24950, 26450, 27550, 29050, 30450, 31550, 33050, 34450, 35900, 37050, 38500, 40000, 41050, 41050, 32950, 24600, 16475, 8285, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 450, 
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
                        305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 15,
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
            id = 1085,
            amount = 250,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1090,
            amount = 2025,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39203,
                    restrictions = {
                        type = "quest",
                        id = 39203,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 11996,
                    restrictions = {
                        type = "quest",
                        id = 11996,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26471,
                },
            },
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11999,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "item",
            id = 36746,
            breadcrumb = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12005,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12059,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12061,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12066,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12096,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12084,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12085,
            aside = true,
        },
        {
            type = "quest",
            id = 12106,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12110,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheDragonflights, {
    name = L["THE_DRAGONFLIGHTS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12470, 12447, 12458, 12454, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12266,12459,12456,13343
        },
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        28770, 30860, 32400, 34270, 36360, 37900, 39990, 41860, 43400, 45490, 47360, 49250, 50990, 52860, 54950, 56550, 58400, 60500, 62050, 63900, 66000, 67900, 69600, 71500, 73400, 75100, 77000, 78900, 80600, 82500, 84600, 86450, 88000, 90100, 91950, 11620, 11620, 9295, 6905, 4640, 2320, 1185, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        28770, 30860, 32400, 34270, 36360, 37900, 39990, 41860, 43400, 45490, 47360, 49250, 50990, 52860, 54950, 56550, 56550, 45270, 33870, 22620, 11425, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 5695, 615, 
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
                        505050, 598780, 692510, 786240, 879970, 973700, 1067430, 1161160, 1254890, 1348620, 1442350, 1536080, 1629810, 1723540, 1817270, 1911000, 2028940, 2146870, 2264810, 2382740, 2500680, 2618620, 2736550, 2854490, 2972420, 3090360, 3208300, 3326230, 3444170, 3562100, 3680040, 3795790, 3911540, 4027300, 4143050, 4258800, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        505050, 598780, 692510, 786240, 879970, 973700, 1067430, 1161160, 1254890, 1348620, 1442350, 1536080, 1629810, 1723540, 1817270, 1911000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1091,
            amount = 3670,
        },
    },
    items = {
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
            id = Chain.EmbedChain04,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            embed = true,
        },
    },
})
Database:AddChain(Chain.ContainingTheRot, {
    name = L["CONTAINING_THE_ROT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.AngratharTheWrathgateHorde,
            upto = 12034
        }
    },
    active = {
        type = "quest",
        id = 12100,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12111,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6820, 7310, 7650, 8120, 8610, 8950, 9440, 9910, 10250, 10740, 11210, 11700, 12040, 12510, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16100, 16400, 16900, 17400, 17700, 18200, 18700, 19000, 19500, 20000, 20450, 20800, 21300, 21750, 2770, 2770, 2195, 1630, 1100, 550, 275, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6820, 7310, 7650, 8120, 8610, 8950, 9440, 9910, 10250, 10740, 11210, 11700, 12040, 12510, 13000, 13350, 13350, 10720, 7970, 5370, 2675, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 145, 
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
            id = 1085,
            amount = 770,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 26504,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12100,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12101,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12102,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12104,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12111,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AngratharTheWrathgateAlliance, {
    name = L["ANGRATHAR_THE_WRATHGATE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12174, 12235, 12251, 12275, 12281, 12298, 12312, 12325, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12499,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        54475, 58300, 61350, 64875, 68700, 71750, 75575, 79100, 82150, 85975, 89500, 93250, 96375, 99950, 103850, 107050, 110450, 114400, 117450, 120850, 124800, 128550, 131450, 135200, 138950, 141850, 145600, 149350, 152250, 156000, 159950, 163350, 166400, 170400, 173750, 22000, 22000, 17550, 13115, 8765, 4375, 2220, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        54475, 58300, 61350, 64875, 68700, 71750, 75575, 79100, 82150, 85975, 89500, 93250, 96375, 99950, 103850, 107050, 107050, 85675, 64025, 42805, 21540, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 10725, 1165, 
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
        {
            type = "reputation",
            id = 1050,
            amount = 6150,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1091,
            amount = 360,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12174,
                    restrictions = {
                        type = "quest",
                        id = 12174,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 12298,
                    restrictions = {
                        type = "quest",
                        id = 12298,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 27136,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12235,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12251,
            x = 0,
            connections = {
                1, 2, 5.3, 
            },
        },
        {
            type = "quest",
            id = 12253,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12258,
            aside = true,
        },
        {
            type = "quest",
            id = 12309,
            x = 0,
            connections = {
                1, 3.2, 
            },
        },
        {
            type = "quest",
            id = 12311,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
            x = -2,
            y = 3,
            connections = {
                [4] = {
                    2, 
                }, [7] = {
                    2, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
            x = 2,
            y = 5,
            connections = {
                [5] = {
                    1, 
                }, 
            },
        },
        {
            type = "quest",
            id = 12281,
            x = 0,
            connections = {
                1.2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
            x = 0,
            connections = {
                [18] = {
                    1, 
                }, 
            },
        },
        {
            type = "quest",
            id = 12499,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AngratharTheWrathgateHorde, {
    name = L["ANGRATHAR_THE_WRATHGATE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.TheTaunka,
        }
    },
    active = {
        type = "quest",
        ids = {
            12034, 12188, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12500,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        30105, 32190, 33850, 35855, 38040, 39700, 41785, 43790, 45450, 47535, 49540, 51600, 53285, 55290, 57400, 59175, 61125, 63250, 64925, 66875, 69000, 71075, 72675, 74750, 76825, 78425, 80500, 82575, 84175, 86250, 88375, 90325, 92000, 94125, 96075, 12140, 12140, 9675, 7260, 4845, 2430, 1230, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        30105, 32190, 33850, 35855, 38040, 39700, 41785, 43790, 45450, 47535, 49540, 51600, 53285, 55290, 57400, 59175, 59175, 47355, 35355, 23690, 11910, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 5925, 650, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 900,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1064,
            amount = 900,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1067,
            amount = 900,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 1555,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1091,
            amount = 360,
        },
    },
    items = {
        {
            type = "npc",
            id = 26379,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12034,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12036,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12063,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12053,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12064,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12071,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12069,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12072,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12140,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
            x = 2,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12224,
            x = 0,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12496,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12497,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12498,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12500,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Frostmourne, {
    name = L["FROSTMOURNE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.AngratharTheWrathgateAlliance,
            upto = 12251
        }
    },
    active = {
        type = "quest",
        id = 12282,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12478,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        22000, 23550, 24750, 26200, 27750, 28950, 30500, 31950, 33150, 34700, 36150, 37650, 38900, 40350, 41950, 43200, 44600, 46200, 47400, 48800, 50400, 51900, 53100, 54600, 56100, 57300, 58800, 60300, 61500, 63000, 64600, 66000, 67200, 68800, 70200, 8870, 8870, 7090, 5285, 3550, 1770, 900, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22000, 23550, 24750, 26200, 27750, 28950, 30500, 31950, 33150, 34700, 36150, 37650, 38900, 40350, 41950, 43200, 43200, 34600, 25850, 17270, 8720, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 4335, 470, 
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
        {
            type = "reputation",
            id = 1050,
            amount = 2500,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1106,
            amount = 1000,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain10,
            aside = true,
            embed = true,
            x = 2,
            y = 5,
        },
        {
            type = "npc",
            id = 27314,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12282,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12287,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12290,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12291,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12301,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12305,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12477,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12475,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12476,
            aside = true,
        },
        {
            type = "quest",
            id = 12478,
            x = 0,
        },
    },
})
Database:AddChain(Chain.InformingTheQueenHorde, {
    name = L["INFORMING_THE_QUEEN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.RedirectingTheLeyLinesHorde,
        }
    },
    active = {
        type = "quest",
        id = 12122,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12124,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8365, 8970, 9450, 9965, 10570, 11050, 11655, 12170, 12650, 13255, 13770, 14350, 14855, 15370, 16000, 16500, 16950, 17600, 18100, 18550, 19200, 19800, 20200, 20800, 21400, 21800, 22400, 23000, 23400, 24000, 24650, 25100, 25600, 26250, 26700, 3400, 3400, 2710, 2015, 1345, 670, 340, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8365, 8970, 9450, 9965, 10570, 11050, 11655, 12170, 12650, 13255, 13770, 14350, 14855, 15370, 16000, 16500, 16500, 13165, 9865, 6600, 3310, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 1645, 175, 
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
                        113775, 134890, 156005, 177120, 198235, 219350, 240465, 261580, 282695, 303810, 324925, 346040, 367155, 388270, 409385, 430500, 457070, 483635, 510205, 536770, 563340, 589910, 616475, 643045, 669610, 696180, 722750, 749315, 775885, 802450, 829020, 855095, 881170, 907250, 933325, 959400, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        113775, 134890, 156005, 177120, 198235, 219350, 240465, 261580, 282695, 303810, 324925, 346040, 367155, 388270, 409385, 430500, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 10,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1091,
            amount = 805,
        },
    },
    items = {
        {
            type = "npc",
            id = 26471,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12122,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12767,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12461,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12448,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12449,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12450,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12769,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12124,
            x = 0,
        },
    },
})
Database:AddChain(Chain.StrategicAlliance, {
    name = L["STRATEGIC_ALLIANCE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12075, 12112, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12078,12080
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        13650, 14600, 15300, 16250, 17200, 17900, 18850, 19800, 20500, 21450, 22400, 23350, 24050, 25000, 25950, 26700, 27650, 28600, 29300, 30250, 31200, 32150, 32850, 33800, 34750, 35450, 36400, 37350, 38050, 39000, 39950, 40900, 41600, 42550, 43500, 5500, 5500, 4375, 3275, 2200, 1100, 555, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        13650, 14600, 15300, 16250, 17200, 17900, 18850, 19800, 20500, 21450, 22400, 23350, 24050, 25000, 25950, 26700, 26700, 21450, 15950, 10700, 5375, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 2675, 295, 
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
                        222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 891840, 943680, 995520, 1047360, 1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 
                    },
                    minLevel = 15,
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
                    id = 12112,
                    restrictions = {
                        type = "quest",
                        id = 12112,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26659,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12075,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12076,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12079,
            aside = true,
        },
        {
            type = "quest",
            id = 12077,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12078,
            x = -1,
        },
        {
            type = "quest",
            id = 12080,
        },
    },
})
Database:AddChain(Chain.TheScarletOnslaught, {
    name = L["THE_SCARLET_ONSLAUGHT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12206, 12234, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12285,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        40110, 42980, 45000, 47760, 50630, 52650, 55520, 58280, 60300, 63170, 65930, 68750, 70820, 73630, 76500, 78475, 81275, 84150, 86125, 88925, 91800, 94575, 96675, 99450, 102225, 104325, 107100, 109875, 111975, 114750, 117625, 120425, 122400, 125325, 128075, 16230, 16230, 12925, 9565, 6490, 3245, 1630, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        40110, 42980, 45000, 47760, 50630, 52650, 55520, 58280, 60300, 63170, 65930, 68750, 70820, 73630, 76500, 78475, 78475, 63060, 46960, 31535, 15810, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 7870, 860, 
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
                        571650, 677740, 783830, 889920, 996010, 1102100, 1208190, 1314280, 1420370, 1526460, 1632550, 1738640, 1844730, 1950820, 2056910, 2163000, 2296490, 2429975, 2563465, 2696950, 2830440, 2963930, 3097415, 3230905, 3364390, 3497880, 3631370, 3764855, 3898345, 4031830, 4165320, 4296335, 4427350, 4558370, 4689385, 4820400, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        571650, 677740, 783830, 889920, 996010, 1102100, 1208190, 1314280, 1420370, 1526460, 1632550, 1738640, 1844730, 1950820, 2056910, 2163000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1067,
            amount = 4785,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain11,
            aside = true,
            embed = true,
            x = -2,
            y = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
            aside = true,
            embed = true,
            x = 3,
            y = 0,
        },
        {
            type = "npc",
            id = 27248,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12206,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12211,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12230,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12232,
            aside = true,
            x = -2,
        },
        {
            type = "npc",
            id = 27337,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12240,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12234,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12243,
            aside = true,
        },
        {
            type = "quest",
            id = 12239,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12254,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12260,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12274,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12283,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12285,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Oachanoa, {
    name = L["OACHANOA"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11958, 12117, 12118, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12032,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        20660, 22180, 23250, 24610, 26130, 27200, 28720, 30080, 31150, 32670, 34030, 35400, 36620, 37980, 39500, 40575, 41925, 43450, 44525, 45875, 47400, 48775, 49975, 51350, 52725, 53925, 55300, 56675, 57875, 59250, 60775, 62125, 63200, 64725, 66075, 8360, 8360, 6685, 4940, 3340, 1670, 850, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        20660, 22180, 23250, 24610, 26130, 27200, 28720, 30080, 31150, 32670, 34030, 35400, 36620, 37980, 39500, 40575, 40575, 32510, 24310, 16260, 8200, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 4085, 440, 
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
                        335775, 398090, 460405, 522720, 585035, 647350, 709665, 771980, 834295, 896610, 958925, 1021240, 1083555, 1145870, 1208185, 1270500, 1348910, 1427315, 1505725, 1584130, 1662540, 1740950, 1819355, 1897765, 1976170, 2054580, 2132990, 2211395, 2289805, 2368210, 2446620, 2523575, 2600530, 2677490, 2754445, 2831400, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        335775, 398090, 460405, 522720, 585035, 647350, 709665, 771980, 834295, 896610, 958925, 1021240, 1083555, 1145870, 1208185, 1270500, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1073,
            amount = 2710,
        },
    },
    items = {
        {
            visible = false,
            x = -3,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 12117,
                    restrictions = {
                        type = "quest",
                        id = 12117,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 12118,
                    restrictions = {
                        type = "quest",
                        id = 12118,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26194,
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 11958,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11959,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12009,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12028,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12030,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12031,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12032,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Wanted!
        type = "object",
        id = 188418,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12089, 12090, 12091, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12097,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15410, 16530, 17400, 18360, 19480, 20350, 21470, 22430, 23300, 24420, 25380, 26350, 27370, 28330, 29450, 30375, 31325, 32450, 33325, 34275, 35400, 36375, 37375, 38350, 39325, 40325, 41300, 42275, 43275, 44250, 45375, 46325, 47200, 48325, 49275, 6210, 6210, 4985, 3715, 2480, 1240, 640, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15410, 16530, 17400, 18360, 19480, 20350, 21470, 22430, 23300, 24420, 25380, 26350, 27370, 28330, 29450, 30375, 30375, 24260, 18210, 12110, 6150, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 3070, 330, 
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
                        305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 350,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 1710,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain14,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
            aside = true,
            embed = true,
            x = 3,
            y = 1,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- The Lost Empire
        type = "quest",
        id = 12041,
    },
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
            id = Chain.TheTaunka,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AngratharTheWrathgateHorde,
            upto = 12034
        },
    },
    active = {
        type = "quest",
        ids = {12056, 12039, 12040},
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {12056, 12048, 12041},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9950, 10650, 11150, 11850, 12600, 13100, 13800, 14500, 15000, 15700, 16400, 17100, 17600, 18300, 19000, 19500, 20200, 20900, 21400, 22100, 22800, 23500, 24000, 24700, 25400, 25900, 26600, 27300, 27800, 28500, 29200, 29900, 30400, 31100, 31800, 4025, 4025, 3200, 2380, 1610, 810, 405, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9950, 10650, 11150, 11850, 12600, 13100, 13800, 14500, 15000, 15700, 16400, 17100, 17600, 18300, 19000, 19500, 19500, 15650, 11650, 7850, 3925, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 1950, 215, 
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
            id = 1052,
            amount = 150,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain16,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain17,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Wanted!
        type = "object",
        id = 190020,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = Chain.AngratharTheWrathgateAlliance,
            upto = 12251
        }
    },
    active = {
        type = "quest",
        ids = {
            12438, 12441, 12442,
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12438, 12441, 12442,
        },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7800, 8400, 8850, 9300, 9900, 10350, 10950, 11400, 11850, 12450, 12900, 13350, 13950, 14400, 15000, 15450, 15900, 16500, 16950, 17400, 18000, 18450, 19050, 19500, 19950, 20550, 21000, 21450, 22050, 22500, 23100, 23550, 24000, 24600, 25050, 3150, 3150, 2550, 1875, 1260, 630, 330, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7800, 8400, 8850, 9300, 9900, 10350, 10950, 11400, 11850, 12450, 12900, 13350, 13950, 14400, 15000, 15450, 15450, 12300, 9300, 6150, 3150, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 1575, 165, 
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
                        166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1050,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 190020,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12438,
            x = -2,
        },
        {
            type = "quest",
            id = 12441,
        },
        {
            type = "quest",
            id = 12442,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = BtWQuests_GetAreaName(4185), -- The Forgotten Shore
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12304, 12303,
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12304, 12303,
        },
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
            id = Chain.EmbedChain19,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain20,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = BtWQuests_GetAreaName(4396), -- Nozzlerust Post
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12469, 12044, 12045, 12043
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12044, 12043, 12049, 12050, 12052
        },
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17300, 18550, 19400, 20600, 21850, 22700, 23950, 25150, 26000, 27250, 28450, 29650, 30550, 31750, 33000, 33850, 35050, 36300, 37150, 38350, 39600, 40800, 41700, 42900, 44100, 45000, 46200, 47400, 48300, 49500, 50750, 51950, 52800, 54050, 55250, 7000, 7000, 5575, 4125, 2800, 1400, 705, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17300, 18550, 19400, 20600, 21850, 22700, 23950, 25150, 26000, 27250, 28450, 29650, 30550, 31750, 33000, 33850, 33850, 27200, 20250, 13600, 6825, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 3395, 370, 
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
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12469,
                    restrictions = {
                        type = "quest",
                        id = 12469,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26660,
                },
            },
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 26661,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 26647,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12044,
            x = -2,
        },
        {
            type = "quest",
            id = 12045,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12043,
        },
        {
            type = "quest",
            id = 12046,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12047,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12049,
        },
        {
            type = "quest",
            id = 12050,
            x = -1,
        },
        {
            type = "quest",
            id = 12052,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = { -- Disturbing Implications
        type = "quest",
        id = 12146,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12146, 12147, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12151,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9950, 10650, 11200, 11850, 12550, 13100, 13800, 14450, 15000, 15700, 16350, 17000, 17600, 18250, 18950, 19550, 20200, 20900, 21450, 22100, 22800, 23450, 24050, 24700, 25350, 25950, 26600, 27250, 27850, 28500, 29200, 29850, 30400, 31100, 31750, 4000, 4000, 3200, 2400, 1600, 800, 410, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9950, 10650, 11200, 11850, 12550, 13100, 13800, 14450, 15000, 15700, 16350, 17000, 17600, 18250, 18950, 19550, 19550, 15650, 11700, 7800, 3950, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 1970, 215, 
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
                        194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1091,
            amount = 1200,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "kill",
                    id = 27004,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Horde,
                    },
                },
                {
                    type = "kill",
                    id = 27005,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                12146, 12147, 
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12148,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12149,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12150,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12151,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = { -- The Cleansing Of Jintha'kalar
        type = "quest",
        id = 12545,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12542, 12545,
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12545,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
            id = 1106,
            amount = 250,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12542,
                    restrictions = {
                        type = "quest",
                        id = 12542,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 28228,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12545,
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
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 26501,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12006,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12013,
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
        id = 13343,
    },
    items = {
        {
            type = "npc",
            id = 27856,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12470,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13343,
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
        id = 12266,
    },
    items = {
        {
            type = "npc",
            id = 27765,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12447,
            x = 0,
            y = 2,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12262,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12261,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12263,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12264,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12265,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12267,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12266,
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
        id = 12459,
    },
    items = {
        {
            type = "npc",
            id = 27785,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12458,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12459,
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
        id = 12456,
    },
    items = {
        {
            type = "npc",
            id = 27255,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12454,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12456,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12277,
    },
    items = {
        {
            type = "quest",
            id = 12251,
            restrictions = false,
        },
        {
            type = "npc",
            id = 27136,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12275,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12272,
            x = -2,
        },
        {
            type = "quest",
            id = 12276,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12269,
            restrictions = false,
        },
        {
            type = "quest",
            id = 12277,
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
        id = 12320,
    },
    items = {
        {
            type = "object",
            id = 189311,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12312,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12319,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12320,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12321,
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
        id = 12472,
    },
    items = {
        {
            type = "quest",
            id = 12281,
            restrictions = false,
        },
        {
            type = "npc",
            id = 27136,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12325,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12326,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12462,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12455,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12457,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12463,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12465,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12466,
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
        },
        {
            type = "quest",
            id = 12467,
            x = 0,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12472,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12473,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12474,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12495,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12497,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12498,
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
        id = 12078,
    },
    items = {
        {
            type = "npc",
            id = 27172,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12188,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12200,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12218,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12221,
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
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 27784,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12464,
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
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 27267,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12209,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12214,
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
        id = 12013,
    },
    items = {
        {
            type = "object",
            id = 188649,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12205,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12245,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12252,
            x = -1,
        },
        {
            type = "quest",
            id = 12271,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12273,
            x = 1,
        },
    },
})
Database:AddChain(Chain.EmbedChain13, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12016,
    },
    items = {
        {
            type = "object",
            id = 188364,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12011,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12016,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12017,
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
        id = 12097,
    },
    items = {
        {
            type = "object",
            id = 188418,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12089,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12090,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12091,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12095,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12097,
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
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 26979,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12144,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12145,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 26618,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12056,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 26564,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12039,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12048,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 26653,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12040,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12041,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 32599,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12304,
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
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 27267,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12303,
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
        id = 12013,
    },
    items = {
        {
            type = "npc",
            id = 26978,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12142,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12143,
            x = 0,
        },
    },
})

Database:AddChain(Chain.IgnoreChain01, {
    name = "Of Traitors and Treason",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12171,
    },
    items = {
        -- Breadcrumbs to 12235
        {
            type = "quest",
            id = 12157,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 12171,
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
        { -- Planning for the Future, Daily
            type = "quest",
            id = 11960,
        },
        { -- Message from the West
        -- Following other wowhead comments, and just confirming this tonight, for those of you who never ran any Borean Tundra quests, you must do the following to become eligible for this quest:
        -- Defense of Warsong Hold chain https://www.wowhead.com/?quest=11595
        -- The Wondrous Bloodspore chain https://www.wowhead.com/?quest=11716
            type = "quest",
            id = 12033,
        },
        { -- Rustling Some Feathers, Obsolete
            type = "quest",
            id = 12051,
        },
        { -- Give it a Name, leads to https://www.wowhead.com/quest=12182/to-venomspite which is a breadcrumb to https://www.wowhead.com/quest=12188/the-forsaken-blight-and-you-how-not-to-die
            type = "quest",
            id = 12181,
        },
        { -- To Venomspite!, breadcrumb to https://www.wowhead.com/quest=12188/the-forsaken-blight-and-you-how-not-to-die
            type = "quest",
            id = 12182,
        },
        { -- Of Traitors and Treason
            type = "quest",
            id = 12297,
        },
        { -- Defending Wyrmrest Temple, Daily
            type = "quest",
            id = 12372,
        },
        { -- A Disturbance In The West, Breadcrumb to a Breadcrumb
            type = "quest",
            id = 12439,
        },
        { -- The High Executor Needs You, breadcrmb to Venomspite but doesnt seem to go to a specific quest
            type = "quest",
            id = 12488,
        },
        { -- The Key to the Focusing Iris, Naxx quest
            type = "quest",
            id = 13372,
        },
        { -- The Heroic Key to the Focusing Iris, Naxx quest
            type = "quest",
            id = 13375,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-Dragonblight]],
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.TheWardensTask,
        },
        {
            type = "chain",
            id = Chain.TheTaunka,
        },
        {
            type = "chain",
            id = Chain.RedirectingTheLeyLinesAlliance,
        },
        {
            type = "chain",
            id = Chain.TraitorsToTheHorde,
        },
        {
            type = "chain",
            id = Chain.InformingTheQueenAlliance,
        },
        {
            type = "chain",
            id = Chain.RedirectingTheLeyLinesHorde,
        },
        {
            type = "chain",
            id = Chain.TheDragonflights,
        },
        {
            type = "chain",
            id = Chain.ContainingTheRot,
        },
        {
            type = "chain",
            id = Chain.AngratharTheWrathgateAlliance,
        },
        {
            type = "chain",
            id = Chain.AngratharTheWrathgateHorde,
        },
        {
            type = "chain",
            id = Chain.Frostmourne,
        },
        {
            type = "chain",
            id = Chain.InformingTheQueenHorde,
        },
        {
            type = "chain",
            id = Chain.StrategicAlliance,
        },
        {
            type = "chain",
            id = Chain.TheScarletOnslaught,
        },
        {
            type = "chain",
            id = Chain.Oachanoa,
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

Database:AddContinentItems(CONTINENT_ID, {})
