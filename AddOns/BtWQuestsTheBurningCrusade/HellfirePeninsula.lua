local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheBurningCrusade;
local CATEGORY_ID = BtWQuests.Constant.Category.TheBurningCrusade.HellfirePeninsula;
local Chain = BtWQuests.Constant.Chain.TheBurningCrusade.HellfirePeninsula;
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 100
local ACHIEVEMENT_ID_ALLIANCE = 1189
local ACHIEVEMENT_ID_HORDE = 1271
local CONTINENT_ID = 101
local LEVEL_RANGE = {10, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 10,
    },
}

Chain.DisruptTheBurningLegionAlliance = 20101
Chain.OverthrowTheOverlord = 20102
Chain.InSearchOfSedai = 20103
Chain.TheExorcismOfColonelJules = 20104
Chain.DrillTheDrillmaster = 20105
Chain.TempleOfTelhamat = 20106
Chain.GreenButNotOrcsAlliance = 20107
Chain.CenarionPostAlliance = 20108

Chain.DisruptTheBurningLegionHorde = 20111
Chain.CruelsIntentions = 20112
Chain.TheHandOfKargath = 20113
Chain.SpinebreakerPost = 20114
Chain.TheMaghar = 20115
Chain.FalconWatch = 20116
Chain.GreenButNotOrcsHorde = 20117
Chain.CenarionPostHorde = 20118

Chain.Chain01 = 20121
Chain.Chain02 = 20122
Chain.Chain03 = 20123
Chain.Chain04 = 20124
Chain.Chain05 = 20125
Chain.Chain06 = 20126
Chain.Chain07 = 20127
Chain.Chain08 = 20128
Chain.Chain09 = 20129

Chain.EmbedChain01 = 20131
Chain.EmbedChain02 = 20132
Chain.EmbedChain03 = 20133
Chain.EmbedChain04 = 20134
Chain.EmbedChain05 = 20135
Chain.EmbedChain06 = 20136
Chain.EmbedChain07 = 20137
Chain.EmbedChain08 = 20138
Chain.EmbedChain09 = 20139
Chain.EmbedChain10 = 20140
Chain.EmbedChain11 = 20141
Chain.EmbedChain12 = 20142
Chain.EmbedChain13 = 20143
Chain.EmbedChain14 = 20144
Chain.EmbedChain15 = 20145
Chain.EmbedChain16 = 20146
Chain.EmbedChain17 = 20147
Chain.EmbedChain18 = 20148
Chain.EmbedChain19 = 20149
Chain.EmbedChain20 = 20150
Chain.EmbedChain21 = 20151
Chain.EmbedChain22 = 20152
Chain.EmbedChain23 = 20153
Chain.EmbedChain24 = 20154
Chain.EmbedChain25 = 20155
Chain.EmbedChain26 = 20156
Chain.EmbedChain27 = 20157
Chain.EmbedChain28 = 20158
Chain.EmbedChain29 = 20159
Chain.EmbedChain30 = 20160
Chain.EmbedChain31 = 20161
Chain.EmbedChain32 = 20162

Chain.UnusedChain01 = 20163
Chain.UnusedChain02 = 20164

Database:AddChain(Chain.DisruptTheBurningLegionAlliance, {
    name = L["DISRUPT_THE_BURNING_LEGION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.DisruptTheBurningLegionHorde,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10141,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10397,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12800, 14200, 15450, 16550, 17850, 19100, 20500, 21500, 22750, 24150, 25150, 26550, 27800, 28800, 30200, 31450, 32750, 33850, 35100, 36500, 37525, 38725, 40150, 41175, 42375, 43800, 45125, 46125, 47450, 48775, 49775, 51100, 52425, 53425, 54750, 56175, 57375, 58400, 59825, 61025, 7750, 7750, 6175, 4575, 3080, 1540, 780, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12800, 14200, 15450, 16550, 17850, 19100, 20500, 21500, 22750, 24150, 25150, 26550, 27800, 28800, 30200, 31450, 32750, 33850, 35100, 36500, 37525, 37525, 30050, 22450, 15050, 7550, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 3760, 405, 
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
            id = 946,
            amount = 2385,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 16819,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10141,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10142,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10143,
            x = 3,
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
            id = 10144,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10146,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10340,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10344,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10163,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10382,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10394,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10396,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10397,
            x = 3,
        },
    },
})
Database:AddChain(Chain.OverthrowTheOverlord, {
    name = L["OVERTHROW_THE_OVERLORD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.CruelsIntentions,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10395,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10399, 10400},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4250, 4675, 5100, 5450, 5875, 6300, 6700, 7100, 7500, 7900, 8300, 8700, 9100, 9500, 9900, 10300, 10750, 11100, 11550, 11950, 12350, 12800, 13200, 13550, 14000, 14400, 14800, 15200, 15600, 16000, 16400, 16800, 17200, 17600, 18000, 18400, 18850, 19200, 19650, 20050, 2520, 2520, 2015, 1525, 1010, 505, 255, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4250, 4675, 5100, 5450, 5875, 6300, 6700, 7100, 7500, 7900, 8300, 8700, 9100, 9500, 9900, 10300, 10750, 11100, 11550, 11950, 12350, 12350, 9900, 7400, 4925, 2485, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 1245, 140, 
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
            id = 946,
            amount = 1000,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "kill",
            id = 19298,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10395,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10399,
            x = 2,
        },
        {
            type = "quest",
            id = 10400,
        },
    },
})
Database:AddChain(Chain.InSearchOfSedai, {
    name = L["IN_SEARCH_OF_SEDAI"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheHandOfKargath,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9390,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9545,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5450, 6030, 6550, 7050, 7580, 8110, 8680, 9150, 9660, 10230, 10700, 11270, 11780, 12250, 12820, 13330, 13900, 14370, 14880, 15500, 15975, 16425, 17050, 17525, 17975, 18600, 19175, 19575, 20150, 20725, 21125, 21700, 22275, 22675, 23250, 23875, 24325, 24800, 25425, 25875, 3280, 3280, 2625, 1950, 1310, 650, 330, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5450, 6030, 6550, 7050, 7580, 8110, 8680, 9150, 9660, 10230, 10700, 11270, 11780, 12250, 12820, 13330, 13900, 14370, 14880, 15500, 15975, 15975, 12760, 9560, 6380, 3220, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 1595, 170, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 930,
            amount = 660,
        },
    },
    items = {
        {
            type = "npc",
            id = 16834,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9390,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9423,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9424,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9543,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9430,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9545,
            x = 3,
        },
    },
})
Database:AddChain(Chain.TheExorcismOfColonelJules, {
    name = L["THE_EXORCISM_OF_COLONEL_JULES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.SpinebreakerPost,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10160,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10935,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12270, 13580, 14840, 15820, 17080, 18350, 19600, 20650, 21850, 23100, 24150, 25400, 26600, 27650, 28900, 30100, 31450, 32400, 33700, 35000, 35950, 37200, 38500, 39450, 40700, 42000, 43250, 44250, 45500, 46750, 47750, 49000, 50250, 51250, 52500, 53800, 55050, 56000, 57400, 58550, 7410, 7410, 5920, 4385, 2970, 1480, 740, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12270, 13580, 14840, 15820, 17080, 18350, 19600, 20650, 21850, 23100, 24150, 25400, 26600, 27650, 28900, 30100, 31450, 32400, 33700, 35000, 35950, 35950, 28850, 21550, 14420, 7240, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 3605, 395, 
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
            id = 946,
            amount = 1850,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 16819,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10160,
            x = 3,
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
            id = 10482,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10483,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10484,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10485,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10903,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10909,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10916,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10935,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = Chain.DrillTheDrillmaster,
            aside = true,
            x = 3,
        },
    },
})
Database:AddChain(Chain.DrillTheDrillmaster, {
    name = L["DRILL_THE_DRILLMASTER"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheMaghar,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.TheExorcismOfColonelJules,
        },
    },
    active = {
        type = "quest",
        id = 10936,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10937,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1930, 2150, 2310, 2530, 2700, 2860, 3080, 3250, 3410, 3630, 3800, 4020, 4180, 4350, 4570, 4730, 4900, 5120, 5280, 5500, 5675, 5825, 6050, 6225, 6375, 6600, 6775, 6975, 7150, 7325, 7525, 7700, 7875, 8075, 8250, 8475, 8625, 8800, 9025, 9175, 1160, 1160, 935, 690, 460, 230, 120, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1930, 2150, 2310, 2530, 2700, 2860, 3080, 3250, 3410, 3630, 3800, 4020, 4180, 4350, 4570, 4730, 4900, 5120, 5280, 5500, 5675, 5675, 4510, 3410, 2260, 1150, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 575, 60, 
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
            id = 946,
            amount = 1000,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 22430,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10936,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10937,
            x = 3,
        },
    },
})
Database:AddChain(Chain.TempleOfTelhamat, {
    name = L["TEMPLE_OF_TELHAMAT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.FalconWatch,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9490, 9399, 9426, 9383},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9399, 9490, 9427, 9383},
        count = 4,
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
            id = 930,
            amount = 1600,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            x = 4,
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
            aside = true,
            x = 0,
            y = 2,
            embed = true,
        },
    },
})
Database:AddChain(Chain.GreenButNotOrcsAlliance, {
    name = L["GREEN_BUT_NOT_ORCS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.GreenButNotOrcsHorde,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9349, 10161, 10236},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {
            9356, 9351, 10630, 
        },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 38250, 39600, 40500, 41850, 43200, 44550, 45450, 46800, 48150, 49050, 50400, 51750, 52650, 54000, 55350, 56700, 57600, 58950, 60300, 7650, 7650, 6075, 4500, 3060, 1530, 765, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 36900, 29700, 22050, 14850, 7425, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 405, 
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
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain07,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
        },
    },
})
Database:AddChain(Chain.CenarionPostAlliance, {
    name = L["CENARION_POST"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.CenarionPostHorde,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10134, 10442, 10443, 9372},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10255, 10351},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9980, 11075, 12060, 12930, 13925, 14910, 15980, 16800, 17760, 18830, 19650, 20720, 21680, 22500, 23570, 24530, 25550, 26420, 27430, 28500, 29275, 30275, 31350, 32125, 33125, 34200, 35175, 36075, 37050, 38025, 38925, 39900, 40875, 41775, 42750, 43825, 44825, 45600, 46725, 47675, 6030, 6030, 4825, 3565, 2410, 1205, 610, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9980, 11075, 12060, 12930, 13925, 14910, 15980, 16800, 17760, 18830, 19650, 20720, 21680, 22500, 23570, 24530, 25550, 26420, 27430, 28500, 29275, 29275, 23460, 17560, 11735, 5910, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 320, 
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
                        17200, 61490, 105780, 150070, 194360, 238650, 282940, 327230, 371520, 415810, 460100, 504390, 548680, 592970, 637260, 681550, 725840, 770130, 814420, 858710, 903000, 958730, 1014455, 1070185, 1125910, 1181640, 1237370, 1293095, 1348825, 1404550, 1460280, 1516010, 1571735, 1627465, 1683190, 1738920, 1793615, 1848310, 1903010, 1957705, 2012400, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17200, 61490, 105780, 150070, 194360, 238650, 282940, 327230, 371520, 415810, 460100, 504390, 548680, 592970, 637260, 681550, 725840, 770130, 814420, 858710, 903000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 1785,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain10,
            aside = true,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
            aside = true,
            x = 4,
            y = 3,
            embed = true,
        },
    },
})

Database:AddChain(Chain.DisruptTheBurningLegionHorde, {
    name = L["DISRUPT_THE_BURNING_LEGION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.DisruptTheBurningLegionAlliance,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10121,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10388,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6490, 7200, 7830, 8390, 9050, 9680, 10390, 10900, 11530, 12240, 12750, 13460, 14090, 14600, 15310, 15940, 16600, 17160, 17790, 18500, 19025, 19625, 20350, 20875, 21475, 22200, 22875, 23375, 24050, 24725, 25225, 25900, 26575, 27075, 27750, 28475, 29075, 29600, 30325, 30925, 3930, 3930, 3130, 2320, 1560, 780, 395, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6490, 7200, 7830, 8390, 9050, 9680, 10390, 10900, 11530, 12240, 12750, 13460, 14090, 14600, 15310, 15940, 16600, 17160, 17790, 18500, 19025, 19025, 15230, 11380, 7630, 3825, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 1905, 205, 
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
        {
            type = "reputation",
            id = 947,
            amount = 1435,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 3230,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10121,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10123,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10124,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10208,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10129,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10162,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 10388,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = Chain.CruelsIntentions,
            aside = true,
            x = 3,
        },
    },
})
Database:AddChain(Chain.CruelsIntentions, {
    name = L["CRUELS_INTENTIONS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.OverthrowTheOverlord,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.DisruptTheBurningLegionHorde,
        },
    },
    active = {
        type = "quest",
        id = 10390,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10136, 10389},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8450, 9325, 10200, 10850, 11725, 12600, 13450, 14150, 15000, 15850, 16550, 17400, 18250, 18950, 19800, 20650, 21550, 22200, 23100, 23950, 24650, 25550, 26400, 27050, 27950, 28800, 29650, 30350, 31200, 32050, 32750, 33600, 34450, 35150, 36000, 36850, 37750, 38400, 39300, 40150, 5070, 5070, 4040, 3025, 2030, 1015, 510, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8450, 9325, 10200, 10850, 11725, 12600, 13450, 14150, 15000, 15850, 16550, 17400, 18250, 18950, 19800, 20650, 21550, 22200, 23100, 23950, 24650, 24650, 19800, 14750, 9875, 4960, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 2475, 275, 
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
            id = 947,
            amount = 1750,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 3230,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 10390,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10391,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10392,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10136,
            x = 2,
        },
        {
            type = "quest",
            id = 10389,
        },
    },
})
Database:AddChain(Chain.TheHandOfKargath, {
    name = L["THE_HAND_OF_KARGATH"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.InSearchOfSedai,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10450,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10876,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9140, 10110, 10980, 11840, 12710, 13600, 14550, 15350, 16200, 17150, 17950, 18900, 19750, 20550, 21500, 22350, 23300, 24100, 24950, 26000, 26800, 27550, 28600, 29400, 30150, 31200, 32150, 32850, 33800, 34750, 35450, 36400, 37350, 38050, 39000, 40050, 40800, 41600, 42650, 43400, 5490, 5490, 4405, 3270, 2200, 1090, 555, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9140, 10110, 10980, 11840, 12710, 13600, 14550, 15350, 16200, 17150, 17950, 18900, 19750, 20550, 21500, 22350, 23300, 24100, 24950, 26000, 26800, 26800, 21400, 16050, 10690, 5415, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 2680, 285, 
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
                        15500, 55420, 95325, 135245, 175150, 215070, 254975, 294895, 334800, 374720, 414625, 454545, 494450, 534370, 574275, 614195, 654100, 694020, 733925, 773845, 813750, 863970, 914190, 964410, 1014630, 1064850, 1115070, 1165290, 1215510, 1265730, 1315950, 1366170, 1416390, 1466610, 1516830, 1567050, 1616340, 1665630, 1714920, 1764210, 1813500, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15500, 55420, 95325, 135245, 175150, 215070, 254975, 294895, 334800, 374720, 414625, 454545, 494450, 534370, 574275, 614195, 654100, 694020, 733925, 773845, 813750, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 2200,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 21256,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10450,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10449,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10242,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10538,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10835,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10864,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10838,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10875,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10876,
            x = 3,
        },
    },
})
Database:AddChain(Chain.SpinebreakerPost, {
    name = L["SPINEBREAKER_POST"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheExorcismOfColonelJules,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10809, 10278, 10229},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10834, 10295, 10258},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15230, 16875, 18460, 19630, 21225, 22810, 24430, 25600, 27160, 28780, 29950, 31570, 33130, 34300, 35920, 37480, 39100, 40270, 41880, 43500, 44625, 46225, 47850, 48975, 50575, 52200, 53775, 54975, 56550, 58125, 59325, 60900, 62475, 63675, 65250, 66875, 68475, 69600, 71275, 72825, 9230, 9230, 7350, 5440, 3690, 1845, 925, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15230, 16875, 18460, 19630, 21225, 22810, 24430, 25600, 27160, 28780, 29950, 31570, 33130, 34300, 35920, 37480, 39100, 40270, 41880, 43500, 44625, 44625, 35860, 26710, 17935, 8985, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 4475, 490, 
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
                        19000, 67925, 116850, 165775, 214700, 263625, 312550, 361475, 410400, 459325, 508250, 557175, 606100, 655025, 703950, 752875, 801800, 850725, 899650, 948575, 997500, 1059060, 1120620, 1182180, 1243740, 1305300, 1366860, 1428420, 1489980, 1551540, 1613100, 1674660, 1736220, 1797780, 1859340, 1920900, 1981320, 2041740, 2102160, 2162580, 2223000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        19000, 67925, 116850, 165775, 214700, 263625, 312550, 361475, 410400, 459325, 508250, 557175, 606100, 655025, 703950, 752875, 801800, 850725, 899650, 948575, 997500, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 2685,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain16,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain17,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
            aside = true,
            x = 6,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain19,
            x = 6,
            y = 2,
            embed = true,
        },
    },
})
Database:AddChain(Chain.TheMaghar, {
    name = L["THE_MAGHAR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.DrillTheDrillmaster,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.DisruptTheBurningLegionHorde,
            upto = 10124,
        },
    },
    active = {
        type = "quest",
        id = 9400,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9406,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6300, 6975, 7650, 8100, 8775, 9450, 10100, 10600, 11250, 11900, 12400, 13050, 13700, 14200, 14850, 15500, 16200, 16650, 17350, 18000, 18450, 19150, 19800, 20250, 20950, 21600, 22250, 22750, 23400, 24050, 24550, 25200, 25850, 26350, 27000, 27650, 28350, 28800, 29500, 30150, 3820, 3820, 3040, 2250, 1530, 765, 380, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6300, 6975, 7650, 8100, 8775, 9450, 10100, 10600, 11250, 11900, 12400, 13050, 13700, 14200, 14850, 15500, 16200, 16650, 17350, 18000, 18450, 18450, 14850, 11050, 7425, 3710, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 205, 
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
        {
            type = "reputation",
            id = 941,
            amount = 600,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 947,
            amount = 825,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 3230,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9400,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9401,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9405,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9410,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9406,
            x = 3,
        },
    },
})
Database:AddChain(Chain.FalconWatch, {
    name = L["FALCON_WATCH"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TempleOfTelhamat,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9498, 9499, 9340, 9397, 9366, 9374},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9391, 9397, 9472, 9370},
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        22050, 24425, 26700, 28450, 30725, 33000, 35350, 37050, 39300, 41700, 43400, 45750, 48000, 49700, 52050, 54300, 56600, 58350, 60650, 63000, 64650, 66950, 69300, 70950, 73250, 75600, 77850, 79650, 81900, 84150, 85950, 88200, 90450, 92250, 94500, 96850, 99150, 100800, 103200, 105450, 13345, 13345, 10640, 7880, 5340, 2675, 1345, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22050, 24425, 26700, 28450, 30725, 33000, 35350, 37050, 39300, 41700, 43400, 45750, 48000, 49700, 52050, 54300, 56600, 58350, 60650, 63000, 64650, 64650, 51900, 38700, 25975, 13035, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 6490, 710, 
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
                        29000, 103675, 178350, 253025, 327700, 402375, 477050, 551725, 626400, 701075, 775750, 850425, 925100, 999775, 1074450, 1149125, 1223800, 1298475, 1373150, 1447825, 1522500, 1616460, 1710420, 1804380, 1898340, 1992300, 2086260, 2180220, 2274180, 2368140, 2462100, 2556060, 2650020, 2743980, 2837940, 2931900, 3024120, 3116340, 3208560, 3300780, 3393000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        29000, 103675, 178350, 253025, 327700, 402375, 477050, 551725, 626400, 701075, 775750, 850425, 925100, 999775, 1074450, 1149125, 1223800, 1298475, 1373150, 1447825, 1522500, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 911,
            amount = 3625,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain20,
            aside = true,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain21,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
            aside = true,
            x = 6,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain24,
            aside = true,
            x = 4,
            y = 2,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain25,
            aside = true,
            x = 6,
            y = 2,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
            aside = true,
            x = 0,
            y = 5,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
            x = 2,
            y = 5,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain28,
            x = 4,
            y = 5,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain29,
            aside = true,
            x = 6,
            y = 5,
            embed = true,
        },
    },
})
Database:AddChain(Chain.GreenButNotOrcsHorde, {
    name = L["GREEN_BUT_NOT_ORCS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.GreenButNotOrcsAlliance,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9349, 10161, 10236},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9356, 9351, 10630},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 38250, 39600, 40500, 41850, 43200, 44550, 45450, 46800, 48150, 49050, 50400, 51750, 52650, 54000, 55350, 56700, 57600, 58950, 60300, 7650, 7650, 6075, 4500, 3060, 1530, 765, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 36900, 29700, 22050, 14850, 7425, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 405, 
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
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain07,
            x = 1,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
        },
    },
})
Database:AddChain(Chain.CenarionPostHorde, {
    name = L["CENARION_POST"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.CenarionPostAlliance,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10134, 10442, 10443, 9372},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10255, 10351},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9980, 11075, 12060, 12930, 13925, 14910, 15980, 16800, 17760, 18830, 19650, 20720, 21680, 22500, 23570, 24530, 25550, 26420, 27430, 28500, 29275, 30275, 31350, 32125, 33125, 34200, 35175, 36075, 37050, 38025, 38925, 39900, 40875, 41775, 42750, 43825, 44825, 45600, 46725, 47675, 6030, 6030, 4825, 3565, 2410, 1205, 610, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9980, 11075, 12060, 12930, 13925, 14910, 15980, 16800, 17760, 18830, 19650, 20720, 21680, 22500, 23570, 24530, 25550, 26420, 27430, 28500, 29275, 29275, 23460, 17560, 11735, 5910, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 2950, 320, 
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
                        17200, 61490, 105780, 150070, 194360, 238650, 282940, 327230, 371520, 415810, 460100, 504390, 548680, 592970, 637260, 681550, 725840, 770130, 814420, 858710, 903000, 958730, 1014455, 1070185, 1125910, 1181640, 1237370, 1293095, 1348825, 1404550, 1460280, 1516010, 1571735, 1627465, 1683190, 1738920, 1793615, 1848310, 1903010, 1957705, 2012400, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17200, 61490, 105780, 150070, 194360, 238650, 282940, 327230, 371520, 415810, 460100, 504390, 548680, 592970, 637260, 681550, 725840, 770130, 814420, 858710, 903000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 1785,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain10,
            aside = true,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            aside = true,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
            aside = true,
            x = 4,
            y = 3,
            embed = true,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Through the Dark Portal
        type = "quest",
        id = 10119,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    alternatives = {
        Chain.Chain02,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10119, 28708, 10288},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10254,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        900, 980, 1050, 1150, 1230, 1310, 1380, 1500, 1560, 1630, 1750, 1820, 1880, 2000, 2070, 2130, 2250, 2320, 2380, 2500, 2625, 2625, 2750, 2875, 2875, 3000, 3125, 3125, 3250, 3375, 3375, 3500, 3625, 3625, 3750, 3875, 3875, 4000, 4125, 4125, 530, 530, 425, 325, 210, 100, 50, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        900, 980, 1050, 1150, 1230, 1310, 1380, 1500, 1560, 1630, 1750, 1820, 1880, 2000, 2070, 2130, 2250, 2320, 2380, 2500, 2625, 2625, 2060, 1560, 1030, 520, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 250, 25, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 946,
            amount = 500,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 10119,
                    restrictions = {
                        type = "quest",
                        id = 10119,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28708,
                    restrictions = {
                        type = "quest",
                        id = 28708,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 19229,
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
            id = 10288,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10140,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10254,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Through the Dark Portal
        type = "quest",
        id = 9407
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    alternatives = {
        Chain.Chain01,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9407, 28705, 10120},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10291,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1420, 1555, 1690, 1820, 1955, 2100, 2200, 2400, 2500, 2600, 2800, 2900, 3000, 3200, 3300, 3400, 3600, 3700, 3850, 4000, 4150, 4250, 4400, 4550, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6250, 6400, 6600, 6650, 840, 840, 680, 510, 340, 165, 80, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1420, 1555, 1690, 1820, 1955, 2100, 2200, 2400, 2500, 2600, 2800, 2900, 3000, 3200, 3300, 3400, 3600, 3700, 3850, 4000, 4150, 4150, 3300, 2500, 1645, 830, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 500,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9407,
                    restrictions = {
                        type = "quest",
                        id = 9407,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28705,
                    restrictions = {
                        type = "quest",
                        id = 28705,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 19253,
                },
            },
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10120,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10289,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10291,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Honor Guard Wesilow
        type = "npc",
        id = 16827,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "quest",
            id = 10483,
        },
    },
    active = {
        type = "quest",
        id = 10050,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10057,
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
            type = "money",
            variations = {
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 946,
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 16827,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain30,
            aside = true,
            x = 5,
            y = 0,
            embed = true,
        },
        {
            type = "quest",
            id = 10050,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10057,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = L["FOR_THE_HORDE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10086,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10087,
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
            id = 947,
            amount = 500,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 21283,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10086,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10087,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = { -- Arzeth's Demise
        type = "quest",
        id = 10369,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10403, 10367},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10369,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4550, 5050, 5500, 5900, 6350, 6800, 7300, 7650, 8100, 8600, 8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20450, 20800, 21300, 21750, 2750, 2750, 2200, 1625, 1100, 550, 280, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4550, 5050, 5500, 5900, 6350, 6800, 7300, 7650, 8100, 8600, 8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13350, 10700, 8000, 5350, 2700, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 145, 
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
            variations = {
                {
                    type = "quest",
                    id = 10403,
                    restrictions = {
                        type = "quest",
                        id = 10403,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 19361,
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
            id = 10367,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10368,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10369,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = { -- Warp-Scryer Kryv
        type = "npc",
        id = 16839,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "quest",
            id = 10483,
        },
    },
    active = {
        type = "quest",
        id = 10047,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10093,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1760, 1940, 2120, 2260, 2440, 2625, 2800, 2950, 3125, 3300, 3450, 3625, 3800, 3950, 4125, 4300, 4500, 4625, 4800, 5000, 5150, 5300, 5500, 5650, 5800, 6000, 6200, 6300, 6500, 6700, 6800, 7000, 7200, 7300, 7500, 7700, 7850, 8000, 8200, 8350, 1060, 1060, 845, 630, 425, 210, 105, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1760, 1940, 2120, 2260, 2440, 2625, 2800, 2950, 3125, 3300, 3450, 3625, 3800, 3950, 4125, 4300, 4500, 4625, 4800, 5000, 5150, 5150, 4125, 3075, 2060, 1035, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 55, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 930,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 16839,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10047,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10093,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = { -- Foreman Biggums
        type = "npc",
        id = 16837,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "quest",
            id = 10483,
        },
    },
    active = {
        type = "quest",
        ids = {
            9355, 10079, 
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10099,
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
            type = "money",
            variations = {
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 946,
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 16837,
            x = 3,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9355,
            x = 2,
            aside = true,
        },
        {
            type = "quest",
            id = 10079,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10099,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain08, {
    name = { -- Grelag
        type = "npc",
        id = 16858,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9345,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10213,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1760, 1940, 2120, 2260, 2440, 2625, 2800, 2950, 3125, 3300, 3450, 3625, 3800, 3950, 4125, 4300, 4500, 4625, 4800, 5000, 5150, 5300, 5500, 5650, 5800, 6000, 6200, 6300, 6500, 6700, 6800, 7000, 7200, 7300, 7500, 7700, 7850, 8000, 8200, 8350, 1060, 1060, 845, 630, 425, 210, 105, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1760, 1940, 2120, 2260, 2440, 2625, 2800, 2950, 3125, 3300, 3450, 3625, 3800, 3950, 4125, 4300, 4500, 4625, 4800, 5000, 5150, 5150, 4125, 3075, 2060, 1035, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 510, 55, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 250,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 16858,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9345,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10213,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain09, {
    name = { -- The Longbeards
        type = "quest",
        id = 9558,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9563, 9558, 9417, 9385},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9420, 9417, 9385},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7000, 7750, 8500, 9000, 9750, 10500, 11250, 11750, 12500, 13250, 13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 21250, 22000, 22500, 23250, 24000, 24750, 25250, 26000, 26750, 27250, 28000, 28750, 29250, 30000, 30750, 31500, 32000, 32750, 33500, 4250, 4250, 3375, 2500, 1700, 850, 425, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7000, 7750, 8500, 9000, 9750, 10500, 11250, 11750, 12500, 13250, 13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 20500, 16500, 12250, 8250, 4125, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 225, 
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
            id = 946,
            amount = 1000,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain31,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain24,
            x = 2,
            y = 2,
            embed = true,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain32,
            x = 4,
            y = 1,
            embed = true,
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
        id = 10895,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10895,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1750, 1950, 2100, 2300, 2450, 2600, 2800, 2950, 3100, 3300, 3450, 3650, 3800, 3950, 4150, 4300, 4450, 4650, 4800, 5000, 5150, 5300, 5500, 5650, 5800, 6000, 6150, 6350, 6500, 6650, 6850, 7000, 7150, 7350, 7500, 7700, 7850, 8000, 8200, 8350, 1050, 1050, 850, 625, 420, 210, 110, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1750, 1950, 2100, 2300, 2450, 2600, 2800, 2950, 3100, 3300, 3450, 3650, 3800, 3950, 4150, 4300, 4450, 4650, 4800, 5000, 5150, 5150, 4100, 3100, 2050, 1050, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 55, 
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
            id = 946,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 19409,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10895,
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
        id = 10055,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10078,
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
            id = 946,
            amount = 500,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 21209,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10055,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10078,
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
        ids = {
            9399, 9490, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            9490, 9399, 
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        3150, 3500, 3800, 4100, 4400, 4700, 5050, 5300, 5600, 5950, 6200, 6550, 6850, 7100, 7450, 7750, 8050, 8350, 8650, 9000, 9250, 9550, 9900, 10150, 10450, 10800, 11100, 11400, 11700, 12000, 12300, 12600, 12900, 13200, 13500, 13850, 14150, 14400, 14750, 15050, 1900, 1900, 1525, 1125, 760, 380, 195, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3150, 3500, 3800, 4100, 4400, 4700, 5050, 5300, 5600, 5950, 6200, 6550, 6850, 7100, 7450, 7750, 8050, 8350, 8650, 9000, 9250, 9250, 7400, 5550, 3700, 1875, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 100, 
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
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 930,
            amount = 600,
        },
    },
    items = {
        {
            type = "npc",
            id = 16799,
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9490,
            x = 0,
        },
        {
            type = "quest",
            id = 9399,
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
        id = 9426,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9427,
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
            id = 930,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 16796,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9426,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9427,
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
        id = 9383,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9383,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 930,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 17006,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9383,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9398,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9398,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 930,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 16797,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9398,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9349,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9356,
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
            id = 19344,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9349,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9361,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9356,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain08, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10161,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9351,
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
    },
    items = {
        {
            type = "npc",
            id = 19367,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10161,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9351,
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
        id = 10236,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10630,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5600, 6200, 6800, 7200, 7800, 8400, 9000, 9400, 10000, 10600, 11000, 11600, 12200, 12600, 13200, 13800, 14400, 14800, 15400, 16000, 16400, 17000, 17600, 18000, 18600, 19200, 19800, 20200, 20800, 21400, 21800, 22400, 23000, 23400, 24000, 24600, 25200, 25600, 26200, 26800, 3400, 3400, 2700, 2000, 1360, 680, 340, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5600, 6200, 6800, 7200, 7800, 8400, 9000, 9400, 10000, 10600, 11000, 11600, 12200, 12600, 13200, 13800, 14400, 14800, 15400, 16000, 16400, 16400, 13200, 9800, 6600, 3300, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 180, 
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
    },
    items = {
        {
            type = "npc",
            id = 16915,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10236,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10238,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10629,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10630,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain10, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10132,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10132,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1750, 1950, 2100, 2300, 2450, 2600, 2800, 2950, 3100, 3300, 3450, 3650, 3800, 3950, 4150, 4300, 4450, 4650, 4800, 5000, 5150, 5300, 5500, 5650, 5800, 6000, 6150, 6350, 6500, 6650, 6850, 7000, 7150, 7350, 7500, 7700, 7850, 8000, 8200, 8350, 1050, 1050, 850, 625, 420, 210, 110, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1750, 1950, 2100, 2300, 2450, 2600, 2800, 2950, 3100, 3300, 3450, 3650, 3800, 3950, 4150, 4300, 4450, 4650, 4800, 5000, 5150, 5150, 4100, 3100, 2050, 1050, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 55, 
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
            id = 942,
            amount = 350,
        },
    },
    items = {
        {
            type = "npc",
            id = 19293,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10132,
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
        id = 10134,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10351,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        2630, 2925, 3160, 3430, 3675, 3910, 4180, 4450, 4660, 4930, 5200, 5470, 5680, 5950, 6220, 6430, 6700, 6970, 7230, 7500, 7725, 7975, 8250, 8475, 8725, 9000, 9225, 9525, 9750, 9975, 10275, 10500, 10725, 11025, 11250, 11525, 11775, 12000, 12325, 12525, 1580, 1580, 1275, 940, 630, 315, 160, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2630, 2925, 3160, 3430, 3675, 3910, 4180, 4450, 4660, 4930, 5200, 5470, 5680, 5950, 6220, 6430, 6700, 6970, 7230, 7500, 7725, 7725, 6160, 4660, 3085, 1560, 785, 785, 785, 785, 785, 785, 785, 785, 785, 785, 785, 785, 785, 785, 85, 
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
                        5200, 18590, 31980, 45370, 58760, 72150, 85540, 98930, 112320, 125710, 139100, 152490, 165880, 179270, 192660, 206050, 219440, 232830, 246220, 259610, 273000, 289850, 306695, 323545, 340390, 357240, 374090, 390935, 407785, 424630, 441480, 458330, 475175, 492025, 508870, 525720, 542255, 558790, 575330, 591865, 608400, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5200, 18590, 31980, 45370, 58760, 72150, 85540, 98930, 112320, 125710, 139100, 152490, 165880, 179270, 192660, 206050, 219440, 232830, 246220, 259610, 273000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 435,
        },
    },
    items = {
        {
            type = "kill",
            id = 19188,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10134,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10349,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10351,
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
            9372, 10442, 10443, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10255,
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
            id = 942,
            amount = 500,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 10442,
                    restrictions = {
                        type = "quest",
                        id = 10442,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 10443,
                    restrictions = {
                        type = "quest",
                        id = 10443,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 16991,
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9372,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10255,
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
        id = 10159,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10159,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 942,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 16888,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10159,
            x = 0,
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
        id = 9373,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9373,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 942,
            amount = 250,
        },
    },
    items = {
        {
            type = "kill",
            id = 16857,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9373,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.DisruptTheBurningLegionHorde,
        },
    },
    active = {
        type = "quest",
        id = 10393,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10393,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        700, 775, 850, 900, 975, 1050, 1100, 1200, 1250, 1300, 1400, 1450, 1500, 1600, 1650, 1700, 1800, 1850, 1950, 2000, 2050, 2150, 2200, 2250, 2350, 2400, 2450, 2550, 2600, 2650, 2750, 2800, 2850, 2950, 3000, 3050, 3150, 3200, 3300, 3350, 420, 420, 340, 250, 170, 85, 40, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        700, 775, 850, 900, 975, 1050, 1100, 1200, 1250, 1300, 1400, 1450, 1500, 1600, 1650, 1700, 1800, 1850, 1950, 2000, 2050, 2050, 1650, 1250, 825, 410, 210, 210, 210, 210, 210, 210, 210, 210, 210, 210, 210, 210, 210, 210, 25, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 250,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "kill",
            id = 20798,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10393,
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
        id = 10809,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10834,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5250, 5825, 6350, 6800, 7325, 7850, 8400, 8850, 9350, 9900, 10350, 10900, 11400, 11850, 12400, 12900, 13450, 13900, 14450, 15000, 15400, 15950, 16500, 16900, 17450, 18000, 18500, 19000, 19500, 20000, 20500, 21000, 21500, 22000, 22500, 23050, 23600, 24000, 24600, 25100, 3170, 3170, 2540, 1875, 1270, 635, 320, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5250, 5825, 6350, 6800, 7325, 7850, 8400, 8850, 9350, 9900, 10350, 10900, 11400, 11850, 12400, 12900, 13450, 13900, 14450, 15000, 15400, 15400, 12350, 9250, 6175, 3110, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 1555, 170, 
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
                        11000, 39325, 67650, 95975, 124300, 152625, 180950, 209275, 237600, 265925, 294250, 322575, 350900, 379225, 407550, 435875, 464200, 492525, 520850, 549175, 577500, 613140, 648780, 684420, 720060, 755700, 791340, 826980, 862620, 898260, 933900, 969540, 1005180, 1040820, 1076460, 1112100, 1147080, 1182060, 1217040, 1252020, 1287000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11000, 39325, 67650, 95975, 124300, 152625, 180950, 209275, 237600, 265925, 294250, 322575, 350900, 379225, 407550, 435875, 464200, 492525, 520850, 549175, 577500, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 925,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "object",
            id = 185166,
            x = 1,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10809,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10792,
            aside = true,
            x = 0,
        },
        {
            type = "quest",
            id = 10813,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10834,
            x = 1,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10278,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10295,
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
            type = "money",
            variations = {
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 750,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 19683,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10278,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10294,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10295,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10220,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10220,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 947,
            amount = 250,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 19682,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10220,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10229,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10258,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4380, 4850, 5310, 5630, 6100, 6560, 7030, 7350, 7810, 8280, 8600, 9070, 9530, 9850, 10320, 10780, 11250, 11570, 12030, 12500, 12825, 13275, 13750, 14075, 14525, 15000, 15475, 15775, 16250, 16725, 17025, 17500, 17975, 18275, 18750, 19225, 19675, 20000, 20475, 20925, 2660, 2660, 2110, 1565, 1060, 530, 265, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4380, 4850, 5310, 5630, 6100, 6560, 7030, 7350, 7810, 8280, 8600, 9070, 9530, 9850, 10320, 10780, 11250, 11570, 12030, 12500, 12825, 12825, 10310, 7660, 5160, 2575, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 140, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 760,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 10229,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10230,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10250,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10258,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain20, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9466,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9466,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1750, 1950, 2100, 2300, 2450, 2600, 2800, 2950, 3100, 3300, 3450, 3650, 3800, 3950, 4150, 4300, 4450, 4650, 4800, 5000, 5150, 5300, 5500, 5650, 5800, 6000, 6150, 6350, 6500, 6650, 6850, 7000, 7150, 7350, 7500, 7700, 7850, 8000, 8200, 8350, 1050, 1050, 850, 625, 420, 210, 110, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1750, 1950, 2100, 2300, 2450, 2600, 2800, 2950, 3100, 3300, 3450, 3650, 3800, 3950, 4150, 4300, 4450, 4650, 4800, 5000, 5150, 5150, 4100, 3100, 2050, 1050, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 55, 
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
            id = 911,
            amount = 350,
        },
    },
    items = {
        {
            type = "object",
            id = 181638,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9466,
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
        ids = {
            9340, 9498, 9499, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9391,
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
        {
            type = "reputation",
            id = 911,
            amount = 500,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9498,
                    restrictions = {
                        type = "quest",
                        id = 9498,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 9499,
                    restrictions = {
                        type = "quest",
                        id = 9499,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 16789,
                }
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9340,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9391,
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
        id = 9397,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9397,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 911,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 16790,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9397,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9396,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9396,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 911,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 16792,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9396,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain24, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9418,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9418,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
    },
    items = {
        {
            type = "kill",
            id = 17084,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9418,
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
        id = 9375,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9376,
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
            id = 911,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 16993,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9375,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9376,
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
        id = 9387,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9387,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 911,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 16794,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9387,
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
        id = 9366,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9370,
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
            id = 911,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 16791,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9366,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9370,
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
        id = 9374,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9472,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4900, 5425, 5900, 6350, 6825, 7300, 7800, 8250, 8700, 9250, 9700, 10200, 10650, 11100, 11600, 12050, 12550, 13000, 13500, 14000, 14400, 14900, 15400, 15800, 16300, 16800, 17250, 17750, 18200, 18650, 19150, 19600, 20050, 20550, 21000, 21500, 22000, 22400, 22950, 23400, 2945, 2945, 2365, 1755, 1180, 595, 300, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4900, 5425, 5900, 6350, 6825, 7300, 7800, 8250, 8700, 9250, 9700, 10200, 10650, 11100, 11600, 12050, 12550, 13000, 13500, 14000, 14400, 14400, 11500, 8650, 5775, 2910, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 1455, 160, 
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
            id = 911,
            amount = 775,
        },
    },
    items = {
        {
            type = "npc",
            id = 16793,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9374,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10286,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10287,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9472,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain29, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9381,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9381,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 911,
            amount = 250,
        },
    },
    items = {
        {
            type = "npc",
            id = 16790,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9381,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain30, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10058,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10058,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
        {
            type = "reputation",
            id = 946,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 16825,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10058,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain31, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9563,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9420,
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
        {
            type = "reputation",
            id = 946,
            amount = 500,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 16851,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9563,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9420,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain32, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9385, 9417, 9558, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            9385, 9417, 
        },
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
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 946,
            amount = 500,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9558,
                    restrictions = {
                        type = "quest",
                        id = 9558,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 16850,
                },
            },
            x = 1,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9417,
            x = 0,
        },
        {
            type = "quest",
            id = 9385,
        },
    },
})

Database:AddChain(Chain.UnusedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 13408,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13408,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1050, 1150, 1250, 1350, 1450, 1550, 1650, 1750, 1850, 2000, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000, 3100, 3200, 3300, 3400, 3500, 3600, 3700, 3800, 3900, 4000, 4100, 4200, 4300, 4400, 4500, 4600, 4700, 4800, 4900, 5000, 625, 625, 500, 380, 250, 130, 65, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1050, 1150, 1250, 1350, 1450, 1550, 1650, 1750, 1850, 2000, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000, 3100, 3100, 2450, 1850, 1250, 625, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 35, 
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
                        1500, 5365, 9225, 13090, 16950, 20815, 24675, 28540, 32400, 36265, 40125, 43990, 47850, 51715, 55575, 59440, 63300, 67165, 71025, 74890, 78750, 83610, 88470, 93330, 98190, 103050, 107910, 112770, 117630, 122490, 127350, 132210, 137070, 141930, 146790, 151650, 156420, 161190, 165960, 170730, 175500, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1500, 5365, 9225, 13090, 16950, 20815, 24675, 28540, 32400, 36265, 40125, 43990, 47850, 51715, 55575, 59440, 63300, 67165, 71025, 74890, 78750, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 946,
            amount = 150,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 18266,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13408,
            x = 0,
        },
    },
})
Database:AddChain(Chain.UnusedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 13409,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13409,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1050, 1150, 1250, 1350, 1450, 1550, 1650, 1750, 1850, 2000, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000, 3100, 3200, 3300, 3400, 3500, 3600, 3700, 3800, 3900, 4000, 4100, 4200, 4300, 4400, 4500, 4600, 4700, 4800, 4900, 5000, 625, 625, 500, 380, 250, 130, 65, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1050, 1150, 1250, 1350, 1450, 1550, 1650, 1750, 1850, 2000, 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000, 3100, 3100, 2450, 1850, 1250, 625, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 310, 35, 
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
                        1500, 5365, 9225, 13090, 16950, 20815, 24675, 28540, 32400, 36265, 40125, 43990, 47850, 51715, 55575, 59440, 63300, 67165, 71025, 74890, 78750, 83610, 88470, 93330, 98190, 103050, 107910, 112770, 117630, 122490, 127350, 132210, 137070, 141930, 146790, 151650, 156420, 161190, 165960, 170730, 175500, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1500, 5365, 9225, 13090, 16950, 20815, 24675, 28540, 32400, 36265, 40125, 43990, 47850, 51715, 55575, 59440, 63300, 67165, 71025, 74890, 78750, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 947,
            amount = 150,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 18267,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13409,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsTheBurningCrusade\UI-Category-HellfirePeninsula]],
		texCoords = {0,1,0,1},
    },
    items = {
        {
            type = "chain",
            id = Chain.DisruptTheBurningLegionAlliance,
        },
        {
            type = "chain",
            id = Chain.OverthrowTheOverlord,
        },
        {
            type = "chain",
            id = Chain.InSearchOfSedai,
        },
        {
            type = "chain",
            id = Chain.TheExorcismOfColonelJules,
        },
        {
            type = "chain",
            id = Chain.DrillTheDrillmaster,
        },
        {
            type = "chain",
            id = Chain.TempleOfTelhamat,
        },
        {
            type = "chain",
            id = Chain.GreenButNotOrcsAlliance,
        },
        {
            type = "chain",
            id = Chain.CenarionPostAlliance,
        },
        {
            type = "chain",
            id = Chain.DisruptTheBurningLegionHorde,
        },
        {
            type = "chain",
            id = Chain.CruelsIntentions,
        },
        {
            type = "chain",
            id = Chain.TheHandOfKargath,
        },
        {
            type = "chain",
            id = Chain.SpinebreakerPost,
        },
        {
            type = "chain",
            id = Chain.TheMaghar,
        },
        {
            type = "chain",
            id = Chain.FalconWatch,
        },
        {
            type = "chain",
            id = Chain.GreenButNotOrcsHorde,
        },
        {
            type = "chain",
            id = Chain.CenarionPostHorde,
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
        {
            type = "chain",
            id = Chain.Chain08,
        },
        {
            type = "chain",
            id = Chain.Chain09,
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
            id = Chain.DisruptTheBurningLegionAlliance,
        },
        {
            type = "chain",
            id = Chain.OverthrowTheOverlord,
        },
        {
            type = "chain",
            id = Chain.InSearchOfSedai,
        },
        {
            type = "chain",
            id = Chain.TheExorcismOfColonelJules,
        },
        {
            type = "chain",
            id = Chain.DrillTheDrillmaster,
        },
        {
            type = "chain",
            id = Chain.TempleOfTelhamat,
        },
        {
            type = "chain",
            id = Chain.GreenButNotOrcsAlliance,
        },
        {
            type = "chain",
            id = Chain.CenarionPostAlliance,
        },


        {
            type = "chain",
            id = Chain.DisruptTheBurningLegionHorde,
        },
        {
            type = "chain",
            id = Chain.CruelsIntentions,
        },
        {
            type = "chain",
            id = Chain.TheHandOfKargath,
        },
        {
            type = "chain",
            id = Chain.SpinebreakerPost,
        },
        {
            type = "chain",
            id = Chain.TheMaghar,
        },
        {
            type = "chain",
            id = Chain.FalconWatch,
        },
        {
            type = "chain",
            id = Chain.GreenButNotOrcsHorde,
        },
        {
            type = "chain",
            id = Chain.CenarionPostHorde,
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
        {
            type = "chain",
            id = Chain.Chain08,
        },
        {
            type = "chain",
            id = Chain.Chain09,
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
        {
            type = "chain",
            id = Chain.EmbedChain29,
        },
        {
            type = "chain",
            id = Chain.EmbedChain30,
        },
        {
            type = "chain",
            id = Chain.EmbedChain31,
        },
        {
            type = "chain",
            id = Chain.EmbedChain32,
        },
    })
end