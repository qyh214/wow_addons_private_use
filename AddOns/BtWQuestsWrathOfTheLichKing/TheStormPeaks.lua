-- AUTO GENERATED - NEEDS UPDATING

local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.TheStormPeaks
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.TheStormPeaks
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 120
local CONTINENT_ID = 113
local ACHIEVEMENT_ID = 38
local LEVEL_RANGE = {25, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 25,
    },
}

Chain.DefendingK3 = 30701
Chain.TheHarpyProblem = 30702
Chain.NorgannonsShell = 30703
Chain.BringingDownTheIronColossus = 30704
Chain.PursuingALegend = 30705
Chain.ForTheFrostbornKing = 30706
Chain.TheStoryOfStormhoof = 30707
Chain.BearlyReady = 30708
Chain.Heartbreak = 30709
Chain.TheSonsOfHodir = 30710
Chain.Loken = 30711

Chain.Chain01 = 30721
Chain.Chain02 = 30722

Chain.EmbedChain01 = 30731
Chain.EmbedChain02 = 30732
Chain.EmbedChain03 = 30733
Chain.EmbedChain04 = 30734
Chain.EmbedChain05 = 30735
Chain.EmbedChain06 = 30736
Chain.EmbedChain07 = 30737
Chain.EmbedChain08 = 30738
Chain.EmbedChain09 = 30739
Chain.EmbedChain10 = 30740
Chain.EmbedChain11 = 30741
Chain.EmbedChain12 = 30742

Chain.OtherAlliance = 30797
Chain.OtherHorde = 30798
Chain.OtherBoth = 30799

Database:AddChain(Chain.DefendingK3, {
    name = L["DEFENDING_K3"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12827, 12836, 12818, 12831, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12822,12824
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        38810, 40500, 41640, 43310, 45000, 46150, 47800, 49500, 50650, 52300, 54000, 55700, 56800, 58500, 60200, 61300, 63000, 64700, 65800, 67500, 69200, 70850, 72000, 73700, 75350, 9570, 9570, 7595, 5630, 3820, 1910, 955, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        38810, 40500, 41640, 43310, 45000, 46150, 46150, 37120, 27570, 18570, 9275, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 4610, 505, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        887600, 945280, 1002960, 1060640, 1118320, 1176000, 1248580, 1321150, 1393730, 1466300, 1538880, 1611460, 1684030, 1756610, 1829180, 1901760, 1974340, 2046910, 2119490, 2192060, 2264640, 2335870, 2407100, 2478340, 2549570, 2620800, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        887600, 945280, 1002960, 1060640, 1118320, 1176000, 
                    },
                    minLevel = 25,
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
            y = 1,
            connections = {
                [4] = {
                    3, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
            x = 1,
            y = 0,
            connections = {
                [5] = {
                    2, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            x = 3,
            y = 1,
            connections = {
                [3] = {
                    1, 
                }, 
            },
        },
        {
            type = "quest",
            id = 12821,
            x = 0,
            y = 5,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12822,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 12823,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12824,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 12862,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "quest",
                    id = 13060,
                },
            },
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHarpyProblem, {
    name = L["THE_HARPY_PROBLEM"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12863,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12867,12868
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        21980, 22900, 23620, 24530, 25500, 26175, 27075, 28050, 28725, 29625, 30600, 31525, 32225, 33150, 34075, 34775, 35700, 36625, 37325, 38250, 39225, 40125, 40800, 41775, 42675, 5410, 5410, 4310, 3190, 2160, 1080, 545, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21980, 22900, 23620, 24530, 25500, 26175, 26175, 21010, 15660, 10510, 5275, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 2625, 285, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        562675, 599240, 635805, 672370, 708935, 745500, 791510, 837515, 883525, 929530, 975540, 1021550, 1067555, 1113565, 1159570, 1205580, 1251590, 1297595, 1343605, 1389610, 1435620, 1480775, 1525930, 1571090, 1616245, 1661400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        562675, 599240, 635805, 672370, 708935, 745500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1068,
            amount = 250,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1126,
            amount = 1360,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain04,
            aside = true,
            embed = true,
            x = 2,
            y = 0,
        },
        {
            type = "npc",
            id = 29743,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12863,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12864,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12865,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12866,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12867,
        },
        {
            type = "quest",
            id = 12868,
            x = -1,
        },
    },
})
Database:AddChain(Chain.NorgannonsShell, {
    name = L["NORGANNONS_SHELL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12854, 12895, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12872,12928
        },
        count = 1,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        44810, 46800, 48140, 50110, 52000, 53350, 55300, 57200, 58550, 60500, 62400, 64300, 65700, 67600, 69500, 70900, 72800, 74700, 76100, 78000, 79900, 81850, 83200, 85200, 87050, 11035, 11035, 8775, 6510, 4410, 2210, 1100, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        44810, 46800, 48140, 50110, 52000, 53350, 53350, 42870, 31920, 21470, 10720, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 5340, 590, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        1026290, 1092980, 1159675, 1226365, 1293060, 1359750, 1443670, 1527580, 1611500, 1695410, 1779330, 1863250, 1947160, 2031080, 2114990, 2198910, 2282830, 2366740, 2450660, 2534570, 2618490, 2700850, 2783210, 2865580, 2947940, 3030300, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1026290, 1092980, 1159675, 1226365, 1293060, 1359750, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1068,
            amount = 1000,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 520,
            restrictions = 924,
        },
    },
    items = {
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
Database:AddChain(Chain.BringingDownTheIronColossus, {
    name = L["BRINGING_DOWN_THE_IRON_COLOSSUS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            12885, 12929, 12930, 12979, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12965,12978,13007
        },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        54300, 56600, 58300, 60600, 62950, 64650, 66950, 69300, 70950, 73250, 75600, 77900, 79600, 81900, 84200, 85900, 88200, 90500, 92200, 94500, 96850, 99150, 100800, 103150, 105450, 13350, 13350, 10625, 7900, 5340, 2670, 1345, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        54300, 56600, 58300, 60600, 62950, 64650, 64650, 51950, 38650, 25950, 13025, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 6480, 710, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        1426500, 1519200, 1611900, 1704600, 1797300, 1890000, 2006640, 2123280, 2239920, 2356560, 2473200, 2589840, 2706480, 2823120, 2939760, 3056400, 3173040, 3289680, 3406320, 3522960, 3639600, 3754080, 3868560, 3983040, 4097520, 4212000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1426500, 1519200, 1611900, 1704600, 1797300, 1890000, 
                    },
                    minLevel = 25,
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
                    id = 12885,
                    restrictions = {
                        type = "quest",
                        id = 12885,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 12929,
                    restrictions = {
                        type = "quest",
                        id = 12929,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 29801,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12930,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12937,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 12931,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12957,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 12964,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12965,
            x = -2,
        },
        {
            type = "npc",
            id = 29380,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12978,
        },
        {
            type = "quest",
            id = 12979,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12980,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12984,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12988,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12991,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12993,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12998,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13007,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PursuingALegend, {
    name = L["PURSUING_A_LEGEND"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            type = "chain",
            id = Chain.NorgannonsShell,
        },
    },
    active = {
        type = "quest",
        id = 13273,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13285,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11200, 11650, 12050, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20450, 20800, 21300, 21750, 2750, 2750, 2200, 1625, 1100, 550, 280, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11200, 11650, 12050, 12500, 13000, 13350, 13350, 10700, 8000, 5350, 2700, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 145, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        317000, 337600, 358200, 378800, 399400, 420000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 350,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 29579,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13273,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13274,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13285,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ForTheFrostbornKing, {
    name = L["FOR_THE_FROSTBORN_KING"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            type = "chain",
            id = Chain.NorgannonsShell,
        },
    },
    active = {
        type = "quest",
        id = 12871,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12973,12876
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        30590, 31900, 32860, 34140, 35450, 36475, 37725, 39050, 40025, 41275, 42600, 43925, 44825, 46150, 47475, 48375, 49700, 51025, 51925, 53250, 54575, 55825, 56800, 58125, 59375, 7530, 7530, 5980, 4470, 3000, 1500, 755, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        30590, 31900, 32860, 34140, 35450, 36475, 36475, 29280, 21780, 14630, 7325, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 3645, 400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        816275, 869320, 922365, 975410, 1028455, 1081500, 1148250, 1214985, 1281735, 1348470, 1415220, 1481970, 1548705, 1615455, 1682190, 1748940, 1815690, 1882425, 1949175, 2015910, 2082660, 2148165, 2213670, 2279190, 2344695, 2410200, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        816275, 869320, 922365, 975410, 1028455, 1081500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1068,
            amount = 510,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1126,
            amount = 1870,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 29579,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12871,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12873,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12874,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12875,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12876,
        },
        {
            type = "quest",
            id = 12877,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12986,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12878,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12879,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12880,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12973,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheStoryOfStormhoof, {
    name = L["THE_STORY_OF_STORMHOOF"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
    },
    active = {
        type = "quest",
        ids = {
            13034, 13426, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13058,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        21550, 22450, 23150, 24050, 25000, 25650, 26550, 27500, 28150, 29050, 30000, 30900, 31600, 32500, 33400, 34100, 35000, 35900, 36600, 37500, 38450, 39350, 40000, 40950, 41850, 5300, 5300, 4225, 3125, 2120, 1060, 535, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21550, 22450, 23150, 24050, 25000, 25650, 25650, 20600, 15350, 10300, 5175, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 2575, 280, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 1350,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 13426,
                    restrictions = {
                        type = "quest",
                        id = 13426,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 30381,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13034,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13037,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 13038,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13048,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13049,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13058,
            x = 0,
        },
    },
})
Database:AddChain(Chain.BearlyReady, {
    name = L["BEARLY_READY"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12843,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12972,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        24440, 25650, 26385, 27540, 28500, 29275, 30375, 31350, 32125, 33225, 34200, 35175, 36075, 37050, 38025, 38925, 39900, 40875, 41775, 42750, 43725, 44825, 45600, 46825, 47675, 6040, 6040, 4825, 3575, 2415, 1205, 590, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        24440, 25650, 26385, 27540, 28500, 29275, 29275, 23505, 17605, 11765, 5860, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 2940, 330, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        245675, 261640, 277605, 293570, 309535, 325500, 345590, 365675, 385765, 405850, 425940, 446030, 466115, 486205, 506290, 526380, 546470, 566555, 586645, 606730, 626820, 646535, 666250, 685970, 705685, 725400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        245675, 261640, 277605, 293570, 309535, 325500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 29473,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12843,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12844,
            aside = true,
        },
        {
            type = "quest",
            id = 12846,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12841,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12905,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12906,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12907,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12908,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12969,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12970,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12971,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12972,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Heartbreak, {
    name = L["HEARTBREAK"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            type = "chain",
            id = Chain.BearlyReady,
        },
    },
    active = {
        type = "quest",
        id = 12851,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13064,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        45280, 47200, 48695, 50580, 52500, 53975, 55825, 57750, 59225, 61075, 63000, 64875, 66375, 68250, 70125, 71625, 73500, 75375, 76875, 78750, 80675, 82525, 84000, 85975, 87775, 11090, 11090, 8845, 6590, 4435, 2235, 1120, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        45280, 47200, 48695, 50580, 52500, 53975, 53975, 43185, 32285, 21695, 10870, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 5405, 595, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        701370, 746940, 792525, 838095, 883680, 929250, 986600, 1043945, 1101295, 1158640, 1215990, 1273340, 1330685, 1388035, 1445380, 1502730, 1560080, 1617425, 1674775, 1732120, 1789470, 1845755, 1902040, 1958330, 2014615, 2070900, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        701370, 746940, 792525, 838095, 883680, 929250, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 29592,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12851,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12856,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13063,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 12968,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 12925,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 12900,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 12942,
            aside = true,
        },
        {
            type = "quest",
            id = 12953,
            aside = true,
        },
        {
            type = "quest",
            id = 12989,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12983,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12996,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12997,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13061,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13062,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12886,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13064,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheSonsOfHodir, {
    name = L["THE_SONS_OF_HODIR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            type = "chain",
            id = Chain.Heartbreak,
        },
    },
    active = {
        type = "quest",
        ids = {
            12915, 12922, 12975, 12985, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12976, 12987, 13001
        },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        32750, 34200, 35175, 36600, 38000, 39000, 40400, 41800, 42800, 44200, 45600, 47000, 48000, 49400, 50800, 51800, 53200, 54600, 55600, 57000, 58400, 59800, 60800, 62250, 63600, 8055, 8055, 6410, 4760, 3225, 1615, 805, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        32750, 34200, 35175, 36600, 38000, 39000, 39000, 31325, 23325, 15685, 7845, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 3900, 430, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        760805, 810240, 859685, 909120, 958565, 1008000, 1070210, 1132415, 1194625, 1256830, 1319040, 1381250, 1443455, 1505665, 1567870, 1630080, 1692290, 1754495, 1816705, 1878910, 1941120, 2002175, 2063230, 2124290, 2185345, 2246400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        760805, 810240, 859685, 909120, 958565, 1008000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1119,
            amount = 45625,
        },
    },
    items = {
        {
            type = "npc",
            id = 29445,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "kill",
            id = 29375,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12915,
            x = -1,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 12922,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12956,
            x = 1,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
            x = -2,
        },
        {
            type = "quest",
            id = 12924,
            aside = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
            x = 2,
            y = 4,
            connections = {
                [4] = {
                    1, 2, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Loken, {
    name = L["LOKEN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            type = "chain",
            id = Chain.TheSonsOfHodir,
            upto = 12967, -- @TODO Is this correct or is it 12924?
        }
    },
    active = {
        type = "quest",
        id = 13009,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13047,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        27850, 27870, 27880, 27900, 27920, 27930, 29100, 30120, 31280, 32450, 33425, 34575, 35750, 36675, 37825, 39000, 40075, 41175, 42250, 43325, 44425, 45500, 46575, 47675, 48750, 49925, 51075, 52000, 53275, 54325, 6850, 6850, 5490, 4090, 2740, 1370, 695, 
                    },
                    minLevel = 20,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        27850, 27870, 27880, 27900, 27920, 27930, 29100, 30120, 31280, 32450, 33425, 33425, 26760, 20060, 13360, 6745, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 3375, 370, 
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
                        837475, 837990, 838505, 839020, 839535, 840050, 894640, 949230, 1003820, 1058410, 1113000, 1181690, 1250375, 1319065, 1387750, 1456440, 1525130, 1593815, 1662505, 1731190, 1799880, 1868570, 1937255, 2005945, 2074630, 2143320, 2210735, 2278150, 2345570, 2412985, 2480400, 
                    },
                    minLevel = 20,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        837475, 837990, 838505, 839020, 839535, 840050, 894640, 949230, 1003820, 1058410, 1113000, 
                    },
                    minLevel = 20,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1119,
            amount = 350,
        },
    },
    items = {
        {
            type = "npc",
            id = 30127,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13009,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13050,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13051,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13010,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13057,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13005,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13035,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13047,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 29863,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = {
        type = "npc",
        id = 29430,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            type = "chain",
            id = Chain.DefendingK3,
            upto = 12827,
        },
    },
    active = {
        type = "quest",
        ids = {12829, 12830},
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {12829, 12830},
        count = 2
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 1700, 1700, 1350, 1000, 680, 340, 170, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6900, 7200, 7400, 7700, 8000, 8200, 8200, 6600, 4900, 3300, 1650, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 820, 90, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 29430,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12829,
            x = -1,
        },
        {
            type = "quest",
            id = 12830,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- There's Always Time for Revenge
        type = "quest",
        id = 13056,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 13054,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13056,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15500, 16200, 16650, 17350, 18000, 18450, 19150, 19800, 20250, 20950, 21600, 22250, 22750, 23400, 24050, 24550, 25200, 25850, 26350, 27000, 27650, 28350, 28800, 29500, 30150, 3820, 3820, 3040, 2250, 1530, 765, 380, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15500, 16200, 16650, 17350, 18000, 18450, 18450, 14850, 11050, 7425, 3710, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 1850, 205, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        356625, 379800, 402975, 426150, 449325, 472500, 501660, 530820, 559980, 589140, 618300, 647460, 676620, 705780, 734940, 764100, 793260, 822420, 851580, 880740, 909900, 938520, 967140, 995760, 1024380, 1053000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        356625, 379800, 402975, 426150, 449325, 472500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 825,
            restrictions = 924,
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
            aside = true,
            embed = true,
            x = 2,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12822,
    },
    items = {
        {
            type = "npc",
            id = 29428,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12827,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12836,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12828,
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
        id = 12820,
    },
    items = {
        {
            type = "npc",
            id = 29431,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12818,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12819,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12826,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12820,
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
        id = 12832,
    },
    items = {
        {
            type = "npc",
            id = 29434,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12831,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12832,
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
        id = 12880,
    },
    items = {
        {
            type = "npc",
            id = 29744,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12870,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 12872,
    },
    items = {
        {
            type = "npc",
            id = 29650,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12854,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12855,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12858,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12860,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13415,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12872,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 12928,
    },
    items = {
        {
            type = "npc",
            id = 29651,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12895,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12909,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12910,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12913,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12917,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12920,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12926,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12927,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13416,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12928,
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
        id = 13001,
    },
    items = {
        {
            type = "npc",
            id = 30252,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13001,
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
        id = 12967,
    },
    items = {
        {
            type = "npc",
            id = 30105,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12966,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13011,
            aside = true,
        },
        {
            type = "quest",
            id = 12967,
            x = -2,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12976,
    },
    items = {
        {
            type = "quest",
            id = 12975,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 12976,
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
        id = 12987,
    },
    items = {
        {
            type = "quest",
            id = 12985,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 12987,
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
        id = 12880,
    },
    items = {
        {
            type = "npc",
            id = 30247,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13000,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 13054,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13055,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13056,
            x = 1,
        },
    },
})
Database:AddChain(Chain.EmbedChain12, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12880,
    },
    items = {
        {
            type = "npc",
            id = 30472,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12882,
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
        { -- Overstock, Daily
            type = "quest",
            id = 12833,
        },
        { -- Luxurious Getaway!, Follows https://www.wowhead.com/quest=49536/warchiefs-command-storm-peaks
            type = "quest",
            id = 12853,
        },
        { -- Pushed Too Farm, Daily
            type = "quest",
            id = 12869,
        },
        { -- SCRAP-E
        -- Engineer only, scap bot recipe
            type = "quest",
            id = 12888,
        },
        { -- The Prototype Console
        -- Follows 12888
            type = "quest",
            id = 12889,
        },
        { -- Blowing Hodir's Horn, Daily
            type = "quest",
            id = 12977,
        },
        { -- Hot and Cold, Daily
            type = "quest",
            id = 12981,
        },
        { -- Spy Hunter, Daily
            type = "quest",
            id = 12994,
        },
        { -- Thrusting Hodir's Spear, Daily
            type = "quest",
            id = 13003,
        },
        { -- Polishing the Helm, Daily
            type = "quest",
            id = 13006,
        },
        { -- Feeding Arngrim, Daily
            type = "quest",
            id = 13046,
        },
        { -- Everfrost
        -- FYI .. you need to be "FRIENDLY" before obtaining this quest. Otherwise, you will only loot dust.
            type = "quest",
            id = 13420,
        },
        { -- Remember Everfrost!, Repeatable of 13420
            type = "quest",
            id = 13421,
        },
        { -- Maintaining Discipline, Daily
            type = "quest",
            id = 13422,
        },
        { -- Defending Your Title, Daily
            type = "quest",
            id = 13423,
        },
        { -- Back to the Pit, Daily
            type = "quest",
            id = 13424,
        },
        { -- The Aberrations Must Die, Daily
            type = "quest",
            id = 13425,
        },
        { -- Hodir's Tribute, Repeatable
            type = "quest",
            id = 13559,
        },
        { -- The Scrapbot Construction Kit
        -- Follows 12889?
            type = "quest",
            id = 13843,
        },
        { -- Warchief's Command: Storm Peaks!, Breadcrumb to K3
            type = "quest",
            id = 49536,
        },
        { -- Hero's Call: Storm Peaks!, Breadcrumb to K3
            type = "quest",
            id = 49554,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-TheStormPeaks]],
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.DefendingK3,
        },
        {
            type = "chain",
            id = Chain.TheHarpyProblem,
        },
        {
            type = "chain",
            id = Chain.NorgannonsShell,
        },
        {
            type = "chain",
            id = Chain.BringingDownTheIronColossus,
        },
        {
            type = "chain",
            id = Chain.PursuingALegend,
        },
        {
            type = "chain",
            id = Chain.ForTheFrostbornKing,
        },
        {
            type = "chain",
            id = Chain.TheStoryOfStormhoof,
        },
        {
            type = "chain",
            id = Chain.BearlyReady,
        },
        {
            type = "chain",
            id = Chain.Heartbreak,
        },
        {
            type = "chain",
            id = Chain.TheSonsOfHodir,
        },
        {
            type = "chain",
            id = Chain.Loken,
        },
        
        {
            type = "chain",
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.Chain02,
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
