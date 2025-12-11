-- AUTO GENERATED - NEEDS UPDATING

local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.SholazarBasin
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.SholazarBasin
local MAP_ID = 119
local CONTINENT_ID = 113
local ACHIEVEMENT_ID = 39
local LEVEL_RANGE = {20, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 20,
    },
}

Chain.HuntingBiggerGame = 30601
Chain.TeethSpikesAndTalons = 30602
Chain.TheWolvar = 30603
Chain.TheOracles = 30604
Chain.TheLifewarden = 30605
Chain.WatchingOverTheBasin = 30606

Chain.Chain01 = 30611
Chain.Chain02 = 30612
Chain.Chain03 = 30613

Chain.EmbedChain01 = 30621
Chain.EmbedChain02 = 30622
Chain.EmbedChain03 = 30623
Chain.EmbedChain04 = 30624
Chain.EmbedChain05 = 30625
Chain.EmbedChain06 = 30626

Chain.OtherAlliance = 30697
Chain.OtherHorde = 30698
Chain.OtherBoth = 30699

Database:AddChain(Chain.HuntingBiggerGame, {
    name = L["HUNTING_BIGGER_GAME"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12522, 12524, 12624, 12688, 49535, 49553, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12595,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        47250, 49760, 52190, 54100, 56610, 59040, 61550, 63460, 65940, 68450, 70375, 72825, 75350, 77225, 79675, 82200, 84675, 86575, 89050, 91525, 93425, 95900, 98375, 100275, 102750, 105275, 107725, 109600, 112175, 114575, 14500, 14500, 11545, 8605, 5790, 2905, 1460, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        47250, 49760, 52190, 54100, 56610, 59040, 61550, 63460, 65940, 68450, 70375, 70375, 56430, 42080, 28255, 14160, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 7050, 775, 
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
                        1016500, 1114355, 1212200, 1310055, 1407900, 1505755, 1603600, 1701455, 1799300, 1897155, 1995000, 2118120, 2241240, 2364360, 2487480, 2610600, 2733720, 2856840, 2979960, 3103080, 3226200, 3349320, 3472440, 3595560, 3718680, 3841800, 3962640, 4083480, 4204320, 4325160, 4446000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1016500, 1114355, 1212200, 1310055, 1407900, 1505755, 1603600, 1701455, 1799300, 1897155, 1995000, 
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
                    id = 49535,
                    restrictions = {
                        type = "quest",
                        id = 49535,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 49553,
                    restrictions = {
                        type = "quest",
                        id = 49553,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 28160,
                },
            },
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12521,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12489,
            aside = true,
            x = 0,
        },
        {
            type = "npc",
            id = 28032,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 28033,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 28497,
            aside = true,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 12522,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 12524,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 28787,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 12624,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 12523,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 12525,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12688,
            aside = true,
        },
        {
            type = "quest",
            id = 12549,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12520,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12550,
            x = -2,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 12551,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12526,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12560,
            x = 0,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 12543,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12544,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12558,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12569,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12556,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12595,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TeethSpikesAndTalons, {
    name = L["TEETH_SPIKES_AND_TALONS"],
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
            id = Chain.HuntingBiggerGame,
            upto = 12558,
        },
        {
            type = "chain",
            id = Chain.HuntingBiggerGame,
            upto = 12569,
        },
        {
            type = "chain",
            id = Chain.HuntingBiggerGame,
            upto = 12556,
        },
    },
    active = {
        type = "quest",
        ids = {
            12683, 12603, 12605, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12614,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        19300, 20350, 21350, 22100, 23150, 24150, 25150, 25950, 26950, 28000, 28750, 29750, 30800, 31550, 32550, 33600, 34600, 35400, 36400, 37400, 38200, 39200, 40200, 41000, 42000, 43050, 44050, 44800, 45850, 46850, 5925, 5925, 4725, 3505, 2370, 1190, 600, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        19300, 20350, 21350, 22100, 23150, 24150, 25150, 25950, 26950, 28000, 28750, 28750, 23050, 17200, 11550, 5800, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 2885, 315, 
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
                        414625, 454540, 494450, 534365, 574275, 614190, 654100, 694015, 733925, 773840, 813750, 863970, 914190, 964410, 1014630, 1064850, 1115070, 1165290, 1215510, 1265730, 1315950, 1366170, 1416390, 1466610, 1516830, 1567050, 1616340, 1665630, 1714920, 1764210, 1813500, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        414625, 454540, 494450, 534365, 574275, 614190, 654100, 694015, 733925, 773840, 813750, 
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
            id = 28771,
            aside = true,
            x = -3,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 28376,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12683,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 12603,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 12605,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12607,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12681,
            aside = true,
        },
        {
            type = "quest",
            id = 12658,
            aside = true,
        },
        {
            type = "quest",
            id = 12614,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheWolvar, {
    name = L["THE_WOLVAR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12528,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12540,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        31650, 33350, 35050, 36250, 37950, 39650, 41400, 42550, 44250, 46000, 47200, 48850, 50600, 51800, 53450, 55200, 56950, 58050, 59800, 61550, 62650, 64400, 66150, 67250, 69000, 70750, 72400, 73600, 75350, 77000, 9770, 9770, 7765, 5760, 3910, 1950, 975, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        31650, 33350, 35050, 36250, 37950, 39650, 41400, 42550, 44250, 46000, 47200, 47200, 37950, 28200, 18970, 9495, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 4710, 515, 
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
                        615250, 674480, 733700, 792930, 852150, 911380, 970600, 1029830, 1089050, 1148280, 1207500, 1282020, 1356540, 1431060, 1505580, 1580100, 1654620, 1729140, 1803660, 1878180, 1952700, 2027220, 2101740, 2176260, 2250780, 2325300, 2398440, 2471580, 2544720, 2617860, 2691000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        615250, 674480, 733700, 792930, 852150, 911380, 970600, 1029830, 1089050, 1148280, 1207500, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1104,
            amount = 4800,
        },
    },
    items = {
        {
            type = "kill",
            id = 28097,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12528,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12529,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12530,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12533,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12534,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12532,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12531,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12535,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12536,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12537,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12538,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12539,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12540,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheOracles, {
    name = L["THE_ORACLES"],
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
            id = Chain.TheWolvar,
            upto = 12540,
        },
    },
    active = {
        type = "quest",
        id = 12570,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12581,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        30350, 31900, 33450, 34750, 36300, 37850, 39550, 40700, 42400, 43950, 45150, 46850, 48400, 49550, 51250, 52800, 54350, 55650, 57200, 58750, 60050, 61600, 63150, 64450, 66000, 67550, 69250, 70400, 72100, 73650, 9310, 9310, 7420, 5525, 3730, 1865, 930, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        30350, 31900, 33450, 34750, 36300, 37850, 39550, 40700, 42400, 43950, 45150, 45150, 36300, 27050, 18125, 9080, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 4535, 505, 
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
                        668750, 733125, 797500, 861875, 926250, 990625, 1055000, 1119375, 1183750, 1248125, 1312500, 1393500, 1474500, 1555500, 1636500, 1717500, 1798500, 1879500, 1960500, 2041500, 2122500, 2203500, 2284500, 2365500, 2446500, 2527500, 2607000, 2686500, 2766000, 2845500, 2925000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        668750, 733125, 797500, 861875, 926250, 990625, 1055000, 1119375, 1183750, 1248125, 1312500, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1105,
            amount = 3550,
        },
    },
    items = {
        {
            type = "npc",
            id = 28217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12570,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12572,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12571,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12573,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12574,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12575,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12576,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12577,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12578,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12580,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12579,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12581,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheLifewarden, {
    name = L["THE_LIFEWARDEN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12561, 12803, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12805,12561
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20450, 20800, 21300, 21750, 2750, 2750, 2200, 1625, 1100, 550, 280, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13350, 10700, 8000, 5350, 2700, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 145, 
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
                        214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 
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
                    id = 12803,
                    restrictions = {
                        type = "quest",
                        id = 12803,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 27801,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12561,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12611,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12805,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WatchingOverTheBasin, {
    name = L["WATCHING_OVER_THE_BASIN"],
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
            id = Chain.TheLifewarden,
            upto = 12611,
        },
    },
    active = {
        type = "quest",
        id = 12612,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12546,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        30800, 32370, 33930, 35250, 36820, 38380, 40000, 41270, 42880, 44450, 45775, 47375, 48950, 50225, 51825, 53400, 54975, 56275, 57850, 59425, 60725, 62300, 63875, 65175, 66750, 68325, 69925, 71200, 72825, 74375, 9380, 9380, 7475, 5610, 3750, 1895, 950, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        30800, 32370, 33930, 35250, 36820, 38380, 40000, 41270, 42880, 44450, 45775, 45775, 36610, 27360, 18385, 9210, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 4585, 510, 
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
                        548375, 601170, 653950, 706745, 759525, 812320, 865100, 917895, 970675, 1023470, 1076250, 1142670, 1209090, 1275510, 1341930, 1408350, 1474770, 1541190, 1607610, 1674030, 1740450, 1806870, 1873290, 1939710, 2006130, 2072550, 2137740, 2202930, 2268120, 2333310, 2398500, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        548375, 601170, 653950, 706745, 759525, 812320, 865100, 917895, 970675, 1023470, 1076250, 
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
            id = 27801,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12612,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12608,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12617,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12660,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12620,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12621,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12559,
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
        },
        {
            type = "quest",
            id = 12613,
            x = 0,
            y = 7,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12548,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12547,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12797,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12546,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- The Great Hunter's Challenge
        type = "quest",
        id = 12592,
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
            id = Chain.HuntingBiggerGame,
            upto = 12525,
            comment = "Maybe requires https://www.wowhead.com/quest=12523 too",
        },
    },
    active = {
        type = "quest",
        id = 12589,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12592,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        3800, 4020, 4180, 4350, 4570, 4730, 4900, 5120, 5280, 5500, 5675, 5825, 6050, 6225, 6375, 6600, 6775, 6975, 7150, 7325, 7525, 7700, 7875, 8075, 8250, 8475, 8625, 8800, 9025, 9175, 1160, 1160, 935, 690, 460, 230, 120, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3800, 4020, 4180, 4350, 4570, 4730, 4900, 5120, 5280, 5500, 5675, 5675, 4510, 3410, 2260, 1150, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 60, 
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
            id = 28328,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12589,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12592,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- The Taste Test
        type = "quest",
        id = 12645,
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
            id = Chain.HuntingBiggerGame,
            upto = 12549,
        },
        {
            type = "chain",
            id = Chain.HuntingBiggerGame,
            upto = 12520,
        },
    },
    active = {
        type = "quest",
        ids = {
            12634, 12804,
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 12645, 12804 },
        count = 2
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11050, 11650, 12200, 12650, 13250, 13800, 14350, 14850, 15400, 16000, 16450, 17000, 17600, 18050, 18600, 19200, 19750, 20250, 20800, 21350, 21850, 22400, 22950, 23450, 24000, 24600, 25150, 25600, 26200, 26750, 3375, 3375, 2700, 2005, 1350, 680, 345, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11050, 11650, 12200, 12650, 13250, 13800, 14350, 14850, 15400, 16000, 16450, 16450, 13150, 9850, 6600, 3325, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 1655, 180, 
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
                        254125, 278590, 303050, 327515, 351975, 376440, 400900, 425365, 449825, 474290, 498750, 529530, 560310, 591090, 621870, 652650, 683430, 714210, 744990, 775770, 806550, 837330, 868110, 898890, 929670, 960450, 990660, 1020870, 1051080, 1081290, 1111500, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        254125, 278590, 303050, 327515, 351975, 376440, 400900, 425365, 449825, 474290, 498750, 
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
            id = Chain.EmbedChain02,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = BtWQuests_GetAreaName(4290), -- River's Heart
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
            id = Chain.HuntingBiggerGame,
            upto = 12523,
        },
    },
    active = {
        type = "quest",
        ids = {
            12696, 12699, 12654
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 12696, 12671, 12654 },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8950, 9425, 9900, 10250, 10725, 11200, 11700, 12025, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16100, 16400, 16900, 17400, 17700, 18200, 18700, 19000, 19500, 20000, 20450, 20800, 21300, 21750, 2760, 2760, 2195, 1630, 1105, 550, 275, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8950, 9425, 9900, 10250, 10725, 11200, 11700, 12025, 12500, 13000, 13350, 13350, 10725, 7975, 5360, 2685, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 1330, 145, 
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
            id = Chain.EmbedChain06,
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
        id = 12558,
    },
    items = {
        {
            type = "object",
            id = 190768,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12691,
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
        id = 12645,
    },
    items = {
        {
            type = "npc",
            id = 29157,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12634,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12644,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12645,
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
        id = 12558,
    },
    items = {
        {
            type = "npc",
            id = 28046,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12804,
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
        id = 12696,
    },
    items = {
        {
            type = "npc",
            id = 28266,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12696,
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
        id = 12671,
    },
    items = {
        {
            type = "npc",
            id = 28746,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12699,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12671,
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
        id = 12558,
    },
    items = {
        {
            type = "npc",
            id = 28568,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12654,
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
        { -- Frenzyheart Champion, Daily, Alliance
            type = "quest",
            id = 12582,
        },
        { -- Hand of the Oracles, Daily, Alliance
            type = "quest",
            id = 12689,
        },
        { -- Return of the Lich Hunter, Seems to be a return quest for a Daily, maybe just first time?
            type = "quest",
            id = 12692,
        },
        { -- Return of the Friendly Dryskin, Seems to be a return quest for a Daily, maybe just first time?
            type = "quest",
            id = 12695,
        },
        { -- Chicken Party!, Daily
            type = "quest",
            id = 12702,
        },
        { -- Kartak's Rampage, Daily
            type = "quest",
            id = 12703,
        },
        { -- Appeasing the Great Rain Stone, Daily
            type = "quest",
            id = 12704,
        },
        { -- Will of the Titans, Daily
            type = "quest",
            id = 12705,
        },
        { -- Song of Wind and Water, Daily
            type = "quest",
            id = 12726,
        },
        { -- The Heartblood's Strength, Daily
            type = "quest",
            id = 12732,
        },
        { -- Rejek: First Blood, Daily
            type = "quest",
            id = 12734,
        },
        { -- A Cleansing Song, Daily
            type = "quest",
            id = 12735,
        },
        { -- Song of Reflection, Daily
            type = "quest",
            id = 12736,
        },
        { -- Song of Fecundity, Daily
            type = "quest",
            id = 12737,
        },
        { -- Strength of the Tempest, Daily
            type = "quest",
            id = 12741,
        },
        { -- A Hero's Headgear, Daily
            type = "quest",
            id = 12758,
        },
        { -- Tools of War, Daily
            type = "quest",
            id = 12759,
        },
        { -- Secret Strength of the Frenzyheart, Daily
            type = "quest",
            id = 12760,
        },
        { -- Mastery of the Crystals, Daily
            type = "quest",
            id = 12761,
        },
        { -- Power of the Great Ones, Daily
            type = "quest",
            id = 12762,
        },
        { -- Sholazar Basin
            type = "quest",
            id = 39209,
        },
        { -- Sholazar Basin
            type = "quest",
            id = 39212,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-SholazarBasin]],
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.HuntingBiggerGame,
        },
        {
            type = "chain",
            id = Chain.TeethSpikesAndTalons,
        },
        {
            type = "chain",
            id = Chain.TheWolvar,
        },
        {
            type = "chain",
            id = Chain.TheOracles,
        },
        {
            type = "chain",
            id = Chain.TheLifewarden,
        },
        {
            type = "chain",
            id = Chain.WatchingOverTheBasin,
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

Database:AddContinentItems(CONTINENT_ID, {})
