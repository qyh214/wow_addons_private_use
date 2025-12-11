-- AUTO GENERATED - NEEDS UPDATING

local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.GrizzlyHills
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.GrizzlyHills
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 116
local CONTINENT_ID = 113
local ACHIEVEMENT_ID_ALLIANCE = 37
local ACHIEVEMENT_ID_HORDE = 1357
local LEVEL_RANGE = {15, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 15,
    },
}

Chain.UrsocTheBearGodAlliance = 30401
Chain.UrsocTheBearGodHorde = 30402
Chain.TheIronThaneAlliance = 30403
Chain.TheFinalShowdown = 30404
Chain.LokensOrdersAlliance = 30405
Chain.TheIronThaneHorde = 30406
Chain.Revelation = 30407
Chain.LokensOrdersHorde = 30408
Chain.HourOfTheWorg = 30409
Chain.EonsOfMisery = 30410

Chain.Chain01 = 30411
Chain.Chain02 = 30412
Chain.Chain03 = 30413
Chain.Chain04 = 30414
Chain.Chain05 = 30415

Chain.EmbedChain01 = 30421
Chain.EmbedChain02 = 30422
Chain.EmbedChain03 = 30423
Chain.EmbedChain04 = 30424
Chain.EmbedChain05 = 30425
Chain.EmbedChain06 = 30426
Chain.EmbedChain07 = 30427
Chain.EmbedChain08 = 30428
Chain.EmbedChain09 = 30429
Chain.EmbedChain10 = 30430
Chain.EmbedChain11 = 30431

Chain.OtherAlliance = 30497
Chain.OtherHorde = 30498
Chain.OtherBoth = 30499

Database:AddChain(Chain.UrsocTheBearGodAlliance, {
    name = L["URSOC_THE_BEAR_GOD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12292, 12307, 12511, 39207, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12249,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        35575, 38000, 40000, 42375, 45000, 47000, 49425, 51800, 53800, 56225, 58600, 61100, 63025, 65450, 67950, 69950, 72300, 74800, 76750, 79100, 81600, 84050, 85950, 88400, 90850, 92750, 95200, 97650, 99550, 102000, 104500, 106850, 108800, 111350, 113650, 14350, 14350, 11450, 8560, 5745, 2885, 1450, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        35575, 38000, 40000, 42375, 45000, 47000, 49425, 51800, 53800, 56225, 58600, 61100, 63025, 65450, 67950, 69950, 69950, 55975, 41825, 28055, 14090, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 7000, 770, 
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
                        215065, 254975, 294890, 334800, 374715, 414625, 454540, 494450, 534365, 574275, 614190, 654100, 694015, 733925, 773840, 813750, 863970, 914190, 964410, 1014630, 1064850, 1115070, 1165290, 1215510, 1265730, 1315950, 1366170, 1416390, 1466610, 1516830, 1567050, 1616340, 1665630, 1714920, 1764210, 1813500, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        215065, 254975, 294890, 334800, 374715, 414625, 454540, 494450, 534365, 574275, 614190, 654100, 694015, 733925, 773840, 813750, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 3375,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 400,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39207,
                    restrictions = {
                        type = "quest",
                        id = 39207,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 12511,
                    restrictions = {
                        type = "quest",
                        id = 12511,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26875,
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
            id = 12292,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12293,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12294,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12295,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 27545,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12299,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12307,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12300,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12302,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12308,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12310,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12219,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12220,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12246,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12247,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12248,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12250,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12249,
            x = 0,
        },
    },
})
Database:AddChain(Chain.UrsocTheBearGodHorde, {
    name = L["URSOC_THE_BEAR_GOD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12468, 12487, 39206, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12236,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        30375, 32500, 34100, 36175, 38400, 40000, 42125, 44200, 45800, 47925, 50000, 52100, 53725, 55800, 57950, 59600, 61650, 63800, 65400, 67450, 69600, 71700, 73300, 75400, 77500, 79100, 81200, 83300, 84900, 87000, 89150, 91200, 92800, 94950, 97000, 12260, 12260, 9770, 7290, 4905, 2460, 1240, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        30375, 32500, 34100, 36175, 38400, 40000, 42125, 44200, 45800, 47925, 50000, 52100, 53725, 55800, 57950, 59600, 59600, 47775, 35625, 23910, 12010, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 5970, 655, 
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
                        187315, 222075, 256840, 291600, 326365, 361125, 395890, 430650, 465415, 500175, 534940, 569700, 604465, 639225, 673990, 708750, 752490, 796230, 839970, 883710, 927450, 971190, 1014930, 1058670, 1102410, 1146150, 1189890, 1233630, 1277370, 1321110, 1364850, 1407780, 1450710, 1493640, 1536570, 1579500, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        187315, 222075, 256840, 291600, 326365, 361125, 395890, 430650, 465415, 500175, 534940, 569700, 604465, 639225, 673990, 708750, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 3400,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39206,
                    restrictions = {
                        type = "quest",
                        id = 39206,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 12487,
                    restrictions = {
                        type = "quest",
                        id = 12487,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26860,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12468,
            x = 0,
            connections = {
                2, 3, 
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
            id = 12257,
            x = -1,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12256,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12259,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12412,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12413,
            x = 0,
            connections = {
                2, 3, 4, 
            },
        },
        {
            visible = false,
            x = -3,
        },
        {
            type = "quest",
            id = 12207,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 12213,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12453,
            aside = true,
        },
        {
            type = "quest",
            id = 12229,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12231,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12241,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12242,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12236,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheIronThaneAlliance, {
    name = L["THE_IRON_THANE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11998,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12153,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        34310, 36780, 38500, 40860, 43380, 45100, 47570, 49930, 51650, 54120, 56480, 58850, 60670, 63030, 65500, 67225, 69575, 72050, 73775, 76125, 78600, 80975, 82775, 85150, 87525, 89325, 91700, 94075, 95875, 98250, 100725, 103075, 104800, 107275, 109625, 13885, 13885, 11060, 8195, 5550, 2780, 1400, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        34310, 36780, 38500, 40860, 43380, 45100, 47570, 49930, 51650, 54120, 56480, 58850, 60670, 63030, 65500, 67225, 67225, 53960, 40210, 27010, 13550, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 6740, 735, 
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
                        409315, 485275, 561240, 637200, 713165, 789125, 865090, 941050, 1017015, 1092975, 1168940, 1244900, 1320865, 1396825, 1472790, 1548750, 1644330, 1739910, 1835490, 1931070, 2026650, 2122230, 2217810, 2313390, 2408970, 2504550, 2600130, 2695710, 2791290, 2886870, 2982450, 3076260, 3170070, 3263880, 3357690, 3451500, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        409315, 485275, 561240, 637200, 713165, 789125, 865090, 941050, 1017015, 1092975, 1168940, 1244900, 1320865, 1396825, 1472790, 1548750, 
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
            id = 26212,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            aside = true,
            embed = true,
            x = -2,
            y = 1,
        },
        {
            type = "quest",
            id = 11998,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12002,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 12003,
            x = 0,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12010,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12014,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12128,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12129,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12130,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12131,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12138,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12153,
            x = -1,
        },
        {
            type = "quest",
            id = 12154,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheFinalShowdown, {
    name = L["THE_FINAL_SHOWDOWN"],
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
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.UrsocTheBearGodHorde,
            upto = 12413,
        },
    },
    active = {
        type = "quest",
        id = 12427,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12431,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14100, 15100, 15950, 16800, 17800, 18650, 19650, 20500, 21350, 22350, 23200, 24050, 25050, 25900, 26900, 27850, 28700, 29700, 30550, 31400, 32400, 33250, 34250, 35100, 35950, 36950, 37800, 38650, 39650, 40500, 41500, 42350, 43200, 44200, 45050, 5650, 5650, 4550, 3425, 2260, 1130, 590, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14100, 15100, 15950, 16800, 17800, 18650, 19650, 20500, 21350, 22350, 23200, 24050, 25050, 25900, 26900, 27850, 27850, 22200, 16700, 11050, 5650, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 2825, 305, 
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
            id = 1085,
            amount = 500,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 27719,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12427,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12428,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12429,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12430,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12431,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LokensOrdersAlliance, {
    name = L["LOKENS_ORDERS"],
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
            id = Chain.TheIronThaneAlliance,
            upto = 12014,
        },
    },
    active = {
        type = "quest",
        id = 12180,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12185,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8400, 9000, 9400, 10000, 10600, 11000, 11600, 12200, 12600, 13200, 13800, 14400, 14800, 15400, 16000, 16400, 17000, 17600, 18000, 18600, 19200, 19800, 20200, 20800, 21400, 21800, 22400, 23000, 23400, 24000, 24600, 25200, 25600, 26200, 26800, 3400, 3400, 2700, 2000, 1360, 680, 340, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8400, 9000, 9400, 10000, 10600, 11000, 11600, 12200, 12600, 13200, 13800, 14400, 14800, 15400, 16000, 16400, 16400, 13200, 9800, 6600, 3300, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 180, 
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
    },
    items = {
        {
            type = "quest",
            id = 12180,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12183,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12184,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12185,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheIronThaneHorde, {
    name = L["THE_IRON_THANE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12195,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12199,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15200, 16300, 17050, 18100, 19200, 19950, 21050, 22100, 22850, 23950, 25000, 26050, 26850, 27900, 29000, 29750, 30800, 31900, 32650, 33700, 34800, 35850, 36650, 37700, 38750, 39550, 40600, 41650, 42450, 43500, 44600, 45650, 46400, 47500, 48550, 6150, 6150, 4900, 3625, 2460, 1230, 620, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15200, 16300, 17050, 18100, 19200, 19950, 21050, 22100, 22850, 23950, 25000, 26050, 26850, 27900, 29000, 29750, 29750, 23900, 17800, 11950, 6000, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 325, 
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
        {
            type = "reputation",
            id = 1064,
            amount = 1850,
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
            id = 27221,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            aside = true,
            embed = true,
            x = 2,
        },
        {
            type = "quest",
            id = 12195,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12165,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12196,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12197,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12198,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12199,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Revelation, {
    name = L["REVELATION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11984, 12208, 12210, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12068,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        22575, 24150, 25300, 26875, 28450, 29600, 31175, 32750, 33900, 35475, 37050, 38700, 39775, 41400, 43000, 44100, 45700, 47300, 48400, 50000, 51600, 53200, 54300, 55900, 57500, 58600, 60200, 61800, 62900, 64500, 66100, 67700, 68800, 70450, 72000, 9130, 9130, 7260, 5380, 3655, 1825, 910, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22575, 24150, 25300, 26875, 28450, 29600, 31175, 32750, 33900, 35475, 37050, 38700, 39775, 41400, 43000, 44100, 44100, 35475, 26375, 17735, 8870, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 4410, 485, 
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
                        201190, 238525, 275865, 313200, 350540, 387875, 425215, 462550, 499890, 537225, 574565, 611900, 649240, 686575, 723915, 761250, 808230, 855210, 902190, 949170, 996150, 1043130, 1090110, 1137090, 1184070, 1231050, 1278030, 1325010, 1371990, 1418970, 1465950, 1512060, 1558170, 1604280, 1650390, 1696500, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        201190, 238525, 275865, 313200, 350540, 387875, 425215, 462550, 499890, 537225, 574565, 611900, 649240, 686575, 723915, 761250, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            visible = false,
            x = -2,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 12208,
                    restrictions = {
                        type = "quest",
                        id = 12208,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 12210,
                    restrictions = {
                        type = "quest",
                        id = 12210,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26424,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11984,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11989,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11990,
            x = 0,
            connections = {
                1.2, 2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 11991,
            x = 0,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12007,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12042,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12802,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12068,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LokensOrdersHorde, {
    name = L["LOKENS_ORDERS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12026,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12203,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        16250, 17400, 18200, 19350, 20550, 21350, 22500, 23650, 24450, 25600, 26750, 27900, 28700, 29850, 31000, 31800, 32950, 34100, 34900, 36050, 37200, 38350, 39150, 40300, 41450, 42250, 43400, 44550, 45350, 46500, 47650, 48800, 49600, 50750, 51900, 6575, 6575, 5225, 3880, 2630, 1320, 660, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16250, 17400, 18200, 19350, 20550, 21350, 22500, 23650, 24450, 25600, 26750, 27900, 28700, 29850, 31000, 31800, 31800, 25550, 19000, 12800, 6400, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 350, 
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
                        215065, 254975, 294890, 334800, 374715, 414625, 454540, 494450, 534365, 574275, 614190, 654100, 694015, 733925, 773840, 813750, 863970, 914190, 964410, 1014630, 1064850, 1115070, 1165290, 1215510, 1265730, 1315950, 1366170, 1416390, 1466610, 1516830, 1567050, 1616340, 1665630, 1714920, 1764210, 1813500, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        215065, 254975, 294890, 334800, 374715, 414625, 454540, 494450, 534365, 574275, 614190, 654100, 694015, 733925, 773840, 813750, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 750,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 188261,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12026,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12054,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12058,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12073,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12204,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12201,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12202,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12203,
            x = 0,
        },
    },
})
Database:AddChain(Chain.HourOfTheWorg, {
    name = L["HOUR_OF_THE_WORG"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {12105, 12423},
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12164,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11525, 12250, 13000, 13725, 14500, 15250, 15975, 16700, 17450, 18175, 18900, 19750, 20375, 21200, 21950, 22650, 23450, 24200, 24850, 25650, 26400, 27150, 27850, 28600, 29350, 30050, 30800, 31550, 32250, 33000, 33750, 34550, 35200, 36050, 36750, 4625, 4625, 3700, 2785, 1855, 930, 465, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11525, 12250, 13000, 13725, 14500, 15250, 15975, 16700, 17450, 18175, 18900, 19750, 20375, 21200, 21950, 22650, 22650, 18125, 13575, 9060, 4555, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 255, 
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
    },
    items = {
        {
            type = "chain",
            ids = {
                Chain.EmbedChain08, Chain.EmbedChain09, 
            },
            embed = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12328,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12327,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12329,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12134,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 12330,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12411,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12164,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EonsOfMisery, {
    name = L["EONS_OF_MISERY"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12116,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12152,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17250, 18500, 19400, 20550, 21850, 22750, 24000, 25150, 26050, 27300, 28450, 29600, 30600, 31750, 33000, 33900, 35050, 36300, 37200, 38350, 39600, 40750, 41750, 42900, 44050, 45050, 46200, 47350, 48350, 49500, 50750, 51900, 52800, 54050, 55200, 6975, 6975, 5575, 4130, 2790, 1400, 710, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17250, 18500, 19400, 20550, 21850, 22750, 24000, 25150, 26050, 27300, 28450, 29600, 30600, 31750, 33000, 33900, 33900, 27150, 20300, 13600, 6850, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 3410, 370, 
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
            type = "chain",
            id = Chain.EmbedChain10,
            aside = true,
            embed = true,
            x = -3,
        },
        {
            type = "npc",
            id = 26886,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            aside = true,
            embed = true,
            x = 2,
        },
        {
            type = "quest",
            id = 12116,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12120,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12121,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12137,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12152,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Delivery to Krenna
        type = "quest",
        id = 12178,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12175,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12178,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6300, 6700, 7100, 7500, 7900, 8300, 8700, 9100, 9500, 9900, 10300, 10800, 11100, 11600, 12000, 12300, 12800, 13200, 13500, 14000, 14400, 14800, 15200, 15600, 16000, 16400, 16800, 17200, 17600, 18000, 18400, 18900, 19200, 19700, 20100, 2540, 2540, 2030, 1500, 1020, 510, 250, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6300, 6700, 7100, 7500, 7900, 8300, 8700, 9100, 9500, 9900, 10300, 10800, 11100, 11600, 12000, 12300, 12300, 9900, 7400, 4950, 2470, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 1240, 140, 
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
            amount = 650,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 27037,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12175,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12177,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12178,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Replenishing the Storehouse
        type = "quest",
        id = 12212,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 12212, 12215, },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 12217, 12215, },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7850, 8400, 8800, 9350, 9950, 10350, 10900, 11450, 11850, 12400, 12950, 13500, 13900, 14450, 15000, 15400, 15950, 16500, 16900, 17450, 18000, 18550, 18950, 19500, 20050, 20450, 21000, 21550, 21950, 22500, 23050, 23600, 24000, 24550, 25100, 3175, 3175, 2525, 1880, 1270, 640, 320, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7850, 8400, 8800, 9350, 9950, 10350, 10900, 11450, 11850, 12400, 12950, 13500, 13900, 14450, 15000, 15400, 15400, 12350, 9200, 6200, 3100, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 1540, 170, 
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
                        104065, 123375, 142690, 162000, 181315, 200625, 219940, 239250, 258565, 277875, 297190, 316500, 335815, 355125, 374440, 393750, 418050, 442350, 466650, 490950, 515250, 539550, 563850, 588150, 612450, 636750, 661050, 685350, 709650, 733950, 758250, 782100, 805950, 829800, 853650, 877500, 
                    },
                    minLevel = 15,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        104065, 123375, 142690, 162000, 181315, 200625, 219940, 239250, 258565, 277875, 297190, 316500, 335815, 355125, 374440, 393750, 
                    },
                    minLevel = 15,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 900,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 27277,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12212,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12215,
        },
        {
            type = "quest",
            id = 12216,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12217,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = BtWQuests_GetAreaName(4207), -- Voldrune
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
            id = Chain.UrsocTheBearGodAlliance,
            upto = 12294,
        },
    },
    active = {
        type = "quest",
        ids = { 12222, 12223, },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12255,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6300, 6750, 7050, 7500, 7950, 8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12750, 13200, 13500, 13950, 14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18900, 19200, 19650, 20100, 2550, 2550, 2025, 1500, 1020, 510, 255, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6300, 6750, 7050, 7500, 7950, 8250, 8700, 9150, 9450, 9900, 10350, 10800, 11100, 11550, 12000, 12300, 12300, 9900, 7350, 4950, 2475, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 135, 
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
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 27391,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12222,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12223,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12255,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- Free at Last
        type = "quest",
        id = 12099,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = { 12074, 11981, 11982, },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12099,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        13360, 14330, 15000, 15910, 16880, 17550, 18520, 19430, 20100, 21070, 21980, 22900, 23620, 24530, 25500, 26175, 27075, 28050, 28725, 29625, 30600, 31525, 32225, 33150, 34075, 34775, 35700, 36625, 37325, 38250, 39225, 40125, 40800, 41775, 42675, 5410, 5410, 4310, 3190, 2160, 1080, 545, 
                    },
                    minLevel = 15,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        13360, 14330, 15000, 15910, 16880, 17550, 18520, 19430, 20100, 21070, 21980, 22900, 23620, 24530, 25500, 26175, 26175, 21010, 15660, 10510, 5275, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 285, 
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
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12074,
                    restrictions = {
                        type = "quest",
                        id = 12074,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 11981,
                    restrictions = {
                        type = "quest",
                        id = 11981,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 26260,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11982,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12070,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11985,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12081,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12093,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12094,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12099,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = { -- A Bear of an Appetite
        type = "quest",
        id = 12279,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12279,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12279,
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
    },
    items = {
        {
            type = "npc",
            id = 26484,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12279,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "object",
            id = 188667,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12225,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12226,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12227,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "npc",
            id = 26868,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12436,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "npc",
            id = 26588,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12027,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "object",
            id = 188261,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11986,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11988,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11993,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "npc",
            id = 26377,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12414,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "npc",
            id = 26944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12415,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "npc",
            id = 26519,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12484,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12483,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12029,
        },
        {
            type = "quest",
            id = 12190,
            x = -1,
        },
    },
})
Database:AddChain(Chain.EmbedChain08, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "item",
            id = 36940,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12105,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12109,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12158,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12159,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12160,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12161,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "item",
            id = 37830,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12423,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12424,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12422,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 27102,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12425,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain10, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "npc",
            id = 26884,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12113,
            x = -1,
        },
        {
            type = "quest",
            id = 12114,
        },
    },
})
Database:AddChain(Chain.EmbedChain11, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
    },
    items = {
        {
            type = "npc",
            id = 26814,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12082,
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
        { -- Seared Scourge, Daily
            type = "quest",
            id = 12038,
        },
        { -- Blackriver Brawl, Daily
            type = "quest",
            id = 12170,
        },
        { -- [Depricated]Sewing Your Seed, Obsolete
            type = "quest",
            id = 12233,
        },
        { -- Shredder Repair, Daily
            type = "quest",
            id = 12244,
        },
        { -- Pieces Parts, Daily
            type = "quest",
            id = 12268,
        },
        { -- Shred the Alliance, Daily
            type = "quest",
            id = 12270,
        },
        { -- Making Repairs, Daily
            type = "quest",
            id = 12280,
        },
        { -- Keep 'Em on Their Heels, Daily
            type = "quest",
            id = 12284,
        },
        { -- Overwhelmed!, Daily
            type = "quest",
            id = 12288,
        },
        { -- Kick 'Em While They're Down, Daily
            type = "quest",
            id = 12289,
        },
        { -- Life or Death, Daily
            type = "quest",
            id = 12296,
        },
        { -- Down With Captain Zorna!, Daily
            type = "quest",
            id = 12314,
        },
        { -- Crush Captain Brightwater!, Daily
            type = "quest",
            id = 12315,
        },
        { -- Keep Them at Bay!, Daily
            type = "quest",
            id = 12316,
        },
        { -- Keep Them at Bay, Daily
            type = "quest",
            id = 12317,
        },
        { -- Smoke 'Em Out, Daily
            type = "quest",
            id = 12323,
        },
        { -- Smoke 'Em Out, Daily
            type = "quest",
            id = 12324,
        },
        { -- Riding the Red Rocket, Daily
            type = "quest",
            id = 12432,
        },
        { -- Seeking Solvent
            type = "quest",
            id = 12433,
        },
        { -- Always Seeking Solvent, Repeatable
            type = "quest",
            id = 12434,
        },
        { -- Riding the Red Rocket, Daily
            type = "quest",
            id = 12437,
        },
        { -- Seeking Solvent
            type = "quest",
            id = 12443,
        },
        { -- Blackriver Skirmish, Daily
            type = "quest",
            id = 12444,
        },
        { -- Always Seeking Solvent, Repeatable
            type = "quest",
            id = 12446,
        },
        { -- Onward to Camp Oneqwah, Doesnt seem to lead to a specific quest
            type = "quest",
            id = 12451,
        },
        { -- Shifting Priorities, Breadcrumb to Zul'Drak?
            type = "quest",
            id = 12763,
        },
        { -- Reallocating Resources, Breadcrumb to Zul'Drak?
            type = "quest",
            id = 12770,
        },
        { -- Glimmerfin Scale, Intro to the murloc mini event?
            type = "quest",
            id = 60605,
        },
        { -- Glimmerfin Welcome, Part of the murloc mini event?
            type = "quest",
            id = 60606,
        },
        { -- A Big Horkin' Task, Part of the murloc mini event?
            type = "quest",
            id = 60614,
        },
        { -- Seer of the Waves, Part of the murloc mini event?
            type = "quest",
            id = 60615,
        },
        { -- Pearl in the Deeps, Part of the murloc mini event?
            type = "quest",
            id = 60616,
        },
        { -- Trainer's Test, Part of the murloc mini event?
            type = "quest",
            id = 60617,
        },
        { -- Wrap it Up, Part of the murloc mini event?
            type = "quest",
            id = 60619,
        },
        { -- Guardian of the Smallest, Part of the murloc mini event?
            type = "quest",
            id = 60620,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-GrizzlyHills]],
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.UrsocTheBearGodAlliance,
        },
        {
            type = "chain",
            id = Chain.UrsocTheBearGodHorde,
        },
        {
            type = "chain",
            id = Chain.TheIronThaneAlliance,
        },
        {
            type = "chain",
            id = Chain.TheFinalShowdown,
        },
        {
            type = "chain",
            id = Chain.LokensOrdersAlliance,
        },
        {
            type = "chain",
            id = Chain.TheIronThaneHorde,
        },
        {
            type = "chain",
            id = Chain.Revelation,
        },
        {
            type = "chain",
            id = Chain.LokensOrdersHorde,
        },
        {
            type = "chain",
            id = Chain.HourOfTheWorg,
        },
        {
            type = "chain",
            id = Chain.EonsOfMisery,
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
