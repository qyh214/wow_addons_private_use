local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.Maldraxxus
local Chain = BtWQuests.Constant.Chain.Shadowlands.Maldraxxus
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde
local MAP_ID = 1536
local CONTINENT_ID = 1550
local ACHIEVEMENT_ID = 14206
local SIDE_ACHIEVEMENT_ID = 14799
local LEVEL_RANGE = {52, 54}
local LEVEL_PREREQUISITE = {
    type = "level",
    variations = {
        { level = 50, restrictions = 86994, },
        { level = 52, },
    },
}

Database:AddChain(Chain.ChampionOfPain, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = {1133, 1057},
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
                    level = 10,
                },
            },
        },
    },
    active = {
        type = "quest",
        id = 61096,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57515,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12790, 14175, 15480, 16490, 17825, 19130, 20490, 21500, 22780, 24140, 25150, 26510, 27790, 28800, 30160, 31440, 32800, 33810, 35140, 36500, 37475, 38775, 40150, 41125, 42425, 43800, 45125, 46125, 47450, 48775, 49775, 51100, 52425, 53425, 54750, 56125, 57425, 58400, 59825, 61075, 62050, 63475, 64725, 65750, 67125, 68375, 69750, 70775, 72025, 73400, 74350, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        62050, 63475, 64725, 65750, 67125, 68375, 69750, 70775, 72025, 73400, 74350, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        12790, 14175, 15480, 16490, 17825, 19130, 20490, 21500, 22780, 24140, 25150, 26510, 27790, 28800, 30160, 31440, 32800, 33810, 35140, 36500, 37475, 38775, 40150, 41125, 42425, 43800, 45125, 46125, 47450, 48775, 49775, 51100, 52425, 53425, 54750, 56125, 57425, 58400, 59825, 61075, 62050, 63475, 64725, 65750, 63600, 50825, 38000, 25610, 12795, 6395, 
                    },
                    minLevel = 10,
                    maxLevel = 59,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        19600, 70070, 120540, 171010, 221480, 271950, 322420, 372890, 423360, 473830, 524300, 574770, 625240, 675710, 726180, 776650, 827120, 877590, 928060, 978530, 1029000, 1092510, 1156005, 1219515, 1283010, 1346520, 1410030, 1473525, 1537035, 1600530, 1664040, 1727550, 1791045, 1854555, 1918050, 1981560, 2043885, 2106210, 2168550, 2230875, 2293200, 2316135, 2339070, 2361990, 2384925, 2407860, 2430795, 2453730, 2476650, 2499585, 2522520, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2293200, 2316135, 2339070, 2361990, 2384925, 2407860, 2430795, 2453730, 2476650, 2499585, 2522520, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        19600, 70070, 120540, 171010, 221480, 271950, 322420, 372890, 423360, 473830, 524300, 574770, 625240, 675710, 726180, 776650, 827120, 877590, 928060, 978530, 1029000, 1092510, 1156005, 1219515, 1283010, 1346520, 1410030, 1473525, 1537035, 1600530, 1664040, 1727550, 1791045, 1854555, 1918050, 1981560, 2043885, 2106210, 2168550, 2230875, 2293200, 2316135, 2339070, 2361990, 
                    },
                    minLevel = 10,
                    maxLevel = 53,
                },
            },
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
            id = 61096,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61107,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57386,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57390,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60020,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60021,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57425,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 57512,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 57511,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60179,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60181,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57515,
            x = 0,
        },
    },
})
Database:AddChain(Chain.HouseOfTheChosen, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    questline = 1058,
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
            id = Chain.ChampionOfPain,
        },
    },
    active = {
        type = "quest",
        id = 57514,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 60886,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11570, 12825, 13990, 14920, 16125, 17290, 18520, 19450, 20590, 21820, 22750, 23980, 25120, 26050, 27280, 28420, 29650, 30580, 31770, 33000, 33900, 35050, 36300, 37200, 38350, 39600, 40800, 41700, 42900, 44100, 45000, 46200, 47400, 48300, 49500, 50750, 51900, 52800, 54100, 55200, 56100, 57400, 58500, 59450, 60700, 61800, 63050, 64000, 65100, 66350, 67200, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        56100, 57400, 58500, 59450, 60700, 61800, 63050, 64000, 65100, 66350, 67200, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        11570, 12825, 13990, 14920, 16125, 17290, 18520, 19450, 20590, 21820, 22750, 23980, 25120, 26050, 27280, 28420, 29650, 30580, 31770, 33000, 33900, 35050, 36300, 37200, 38350, 39600, 40800, 41700, 42900, 44100, 45000, 46200, 47400, 48300, 49500, 50750, 51900, 52800, 54100, 55200, 56100, 57400, 58500, 59450, 60700, 58500, 46650, 35050, 23450, 11570, 5785, 
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
                        17800, 63635, 109470, 155305, 201140, 246975, 292810, 338645, 384480, 430315, 476150, 521985, 567820, 613655, 659490, 705325, 751160, 796995, 842830, 888665, 934500, 992180, 1049840, 1107520, 1165180, 1222860, 1280540, 1338200, 1395880, 1453540, 1511220, 1568900, 1626560, 1684240, 1741900, 1799580, 1856180, 1912780, 1969400, 2026000, 2082600, 2103430, 2124260, 2145070, 2165900, 2186730, 2207560, 2228390, 2249200, 2270030, 2290860, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2082600, 2103430, 2124260, 2145070, 2165900, 2186730, 2207560, 2228390, 2249200, 2270030, 2290860, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        17800, 63635, 109470, 155305, 201140, 246975, 292810, 338645, 384480, 430315, 476150, 521985, 567820, 613655, 659490, 705325, 751160, 796995, 842830, 888665, 934500, 992180, 1049840, 1107520, 1165180, 1222860, 1280540, 1338200, 1395880, 1453540, 1511220, 1568900, 1626560, 1684240, 1741900, 1799580, 1856180, 1912780, 1969400, 2026000, 2082600, 2103430, 2124260, 2145070, 2165900, 
                    },
                    minLevel = 10,
                    maxLevel = 54,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 159065,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57514,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58351,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58617,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60451,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57516,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58616,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58618,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58726,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60428,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60453,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60461,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60886,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MatronOfSpies, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = 1059,
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
            id = Chain.ChampionOfPain,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HouseOfTheChosen,
        },
    },
    active = {
        type = "quest",
        id = 58751,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59009,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10160, 11250, 12320, 13060, 14150, 15220, 16260, 17100, 18120, 19160, 20000, 21040, 22060, 22900, 23940, 24960, 26100, 26840, 27960, 29000, 29750, 30850, 31900, 32650, 33750, 34800, 35850, 36650, 37700, 38750, 39550, 40600, 41650, 42450, 43500, 44550, 45650, 46400, 47550, 48550, 49300, 50450, 51450, 52200, 53350, 54350, 55400, 56250, 57250, 58300, 59100, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        49300, 50450, 51450, 52200, 53350, 54350, 55400, 56250, 57250, 58300, 59100, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        10160, 11250, 12320, 13060, 14150, 15220, 16260, 17100, 18120, 19160, 20000, 21040, 22060, 22900, 23940, 24960, 26100, 26840, 27960, 29000, 29750, 30850, 31900, 32650, 33750, 34800, 35850, 36650, 37700, 38750, 39550, 40600, 41650, 42450, 43500, 44550, 45650, 46400, 47550, 48550, 49300, 50450, 51450, 52200, 53350, 51850, 42550, 32400, 22100, 11660, 5830, 
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
                        14400, 51480, 88560, 125640, 162720, 199800, 236880, 273960, 311040, 348120, 385200, 422280, 459360, 496440, 533520, 570600, 607680, 644760, 681840, 718920, 756000, 802660, 849310, 895970, 942620, 989280, 1035940, 1082590, 1129250, 1175900, 1222560, 1269220, 1315870, 1362530, 1409180, 1455840, 1501630, 1547420, 1593220, 1639010, 1684800, 1701650, 1718500, 1735340, 1752190, 1769040, 1785890, 1802740, 1819580, 1836430, 1853280, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1684800, 1701650, 1718500, 1735340, 1752190, 1769040, 1785890, 1802740, 1819580, 1836430, 1853280, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        14400, 51480, 88560, 125640, 162720, 199800, 236880, 273960, 311040, 348120, 385200, 422280, 459360, 496440, 533520, 570600, 607680, 644760, 681840, 718920, 756000, 802660, 849310, 895970, 942620, 989280, 1035940, 1082590, 1129250, 1175900, 1222560, 1269220, 1315870, 1362530, 1409180, 1455840, 1501630, 1547420, 1593220, 1639010, 1684800, 1701650, 1718500, 1735340, 1752190, 1754530, 
                    },
                    minLevel = 10,
                    maxLevel = 55,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 168381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58751,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 59171,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58821,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59172,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 59210,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 59185,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 59188,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59190,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59025,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59009,
            x = 0,
        },
    },
})
Database:AddChain(Chain.HouseOfConstructs, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = 1060,
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
            id = Chain.ChampionOfPain,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HouseOfTheChosen,
        },
    },
    active = {
        type = "quest",
        id = 57912,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 60733,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17680, 19575, 21460, 22730, 24625, 26510, 28330, 29750, 31560, 33380, 34800, 36620, 38430, 39850, 41670, 43480, 45450, 46720, 48680, 50500, 51775, 53725, 55550, 56825, 58775, 60600, 62425, 63825, 65650, 67475, 68875, 70700, 72525, 73925, 75750, 77575, 79525, 80800, 82775, 84575, 85850, 87825, 89625, 90900, 92875, 94675, 96500, 97925, 99725, 101550, 102950, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        85850, 87825, 89625, 90900, 92875, 94675, 96500, 97925, 99725, 101550, 102950, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        17680, 19575, 21460, 22730, 24625, 26510, 28330, 29750, 31560, 33380, 34800, 36620, 38430, 39850, 41670, 43480, 45450, 46720, 48680, 50500, 51775, 53725, 55550, 56825, 58775, 60600, 62425, 63825, 65650, 67475, 68875, 70700, 72525, 73925, 75750, 77575, 79525, 80800, 82775, 84575, 85850, 87825, 89625, 90900, 92875, 89625, 71400, 53725, 35900, 17680, 8840, 
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
                        25200, 90090, 154980, 219870, 284760, 349650, 414540, 479430, 544320, 609210, 674100, 738990, 803880, 868770, 933660, 998550, 1063440, 1128330, 1193220, 1258110, 1323000, 1404650, 1486295, 1567945, 1649590, 1731240, 1812890, 1894535, 1976185, 2057830, 2139480, 2221130, 2302775, 2384425, 2466070, 2547720, 2627855, 2707990, 2788130, 2868265, 2948400, 2977885, 3007370, 3036850, 3066335, 3095820, 3125305, 3154790, 3184270, 3213755, 3243240, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2948400, 2977885, 3007370, 3036850, 3066335, 3095820, 3125305, 3154790, 3184270, 3213755, 3243240, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        25200, 90090, 154980, 219870, 284760, 349650, 414540, 479430, 544320, 609210, 674100, 738990, 803880, 868770, 933660, 998550, 1063440, 1128330, 1193220, 1258110, 1323000, 1404650, 1486295, 1567945, 1649590, 1731240, 1812890, 1894535, 1976185, 2057830, 2139480, 2221130, 2302775, 2384425, 2466070, 2547720, 2627855, 2707990, 2788130, 2868265, 2948400, 2977885, 3007370, 3036850, 3066335, 
                    },
                    minLevel = 10,
                    maxLevel = 54,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 168381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57912,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 57976,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 60557,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58268,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57979,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59616,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57983,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57984,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 57985,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 57986,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 57987,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57982,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57993,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57994,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60733,
            x = 0,
        },
    },
})
Database:AddChain(Chain.HouseOfPlagues, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 1061,
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
            id = Chain.ChampionOfPain,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HouseOfTheChosen,
        },
    },
    active = {
        type = "quest",
        id = 59130,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59231,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15410, 17075, 18670, 19860, 21475, 23070, 24710, 25900, 27470, 29110, 30300, 31940, 33510, 34700, 36340, 37910, 39550, 40740, 42360, 44000, 45150, 46750, 48400, 49550, 51150, 52800, 54400, 55600, 57200, 58800, 60000, 61600, 63200, 64400, 66000, 67650, 69250, 70400, 72100, 73650, 74800, 76500, 78050, 79250, 80900, 82450, 84100, 85300, 86850, 88500, 89650, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        74800, 76500, 78050, 79250, 80900, 82450, 84100, 85300, 86850, 88500, 89650, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        15410, 17075, 18670, 19860, 21475, 23070, 24710, 25900, 27470, 29110, 30300, 31940, 33510, 34700, 36340, 37910, 39550, 40740, 42360, 44000, 45150, 46750, 48400, 49550, 51150, 52800, 54400, 55600, 57200, 58800, 60000, 61600, 63200, 64400, 66000, 67650, 69250, 70400, 72100, 73650, 74800, 76500, 78050, 79250, 80900, 78050, 62200, 46750, 31300, 15410, 7705, 
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
                        23400, 83655, 143910, 204165, 264420, 324675, 384930, 445185, 505440, 565695, 625950, 686205, 746460, 806715, 866970, 927225, 987480, 1047735, 1107990, 1168245, 1228500, 1304320, 1380130, 1455950, 1531760, 1607580, 1683400, 1759210, 1835030, 1910840, 1986660, 2062480, 2138290, 2214110, 2289920, 2365740, 2440150, 2514560, 2588980, 2663390, 2737800, 2765180, 2792560, 2819930, 2847310, 2874690, 2902070, 2929450, 2956820, 2984200, 3011580, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2737800, 2765180, 2792560, 2819930, 2847310, 2874690, 2902070, 2929450, 2956820, 2984200, 3011580, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        23400, 83655, 143910, 204165, 264420, 324675, 384930, 445185, 505440, 565695, 625950, 686205, 746460, 806715, 866970, 927225, 987480, 1047735, 1107990, 1168245, 1228500, 1304320, 1380130, 1455950, 1531760, 1607580, 1683400, 1759210, 1835030, 1910840, 1986660, 2062480, 2138290, 2214110, 2289920, 2365740, 2440150, 2514560, 2588980, 2663390, 2737800, 2765180, 2792560, 2819930, 2847310, 
                    },
                    minLevel = 10,
                    maxLevel = 54,
                },
            },
        },
        {
            type = "reputation",
            id = 2410,
            amount = 270,
        },
    },
    items = {
        {
            type = "npc",
            id = 168381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59130,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58011,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58016,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58027,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 58031,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 58036,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 58045,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Chain04,
            embed = true,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 59223,
            x = 0,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60831,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59231,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RitualForTheDamned, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    questline = 1062,
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
                    level = 10,
                },
            },
        },
        {
            type = "chain",
            id = Chain.ChampionOfPain,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HouseOfTheChosen,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MatronOfSpies,
        },
        {
            type = "chain",
            id = Chain.HouseOfConstructs,
        },
        {
            type = "chain",
            id = Chain.HouseOfPlagues,
        },
    },
    active = {
        type = "quest",
        id = 59202,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59974,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12440, 13775, 15080, 15990, 17325, 18630, 19940, 20900, 22180, 23490, 24450, 25760, 27040, 28000, 29310, 30590, 31950, 32860, 34190, 35500, 36425, 37725, 39050, 39975, 41275, 42600, 43925, 44825, 46150, 47475, 48375, 49700, 51025, 51925, 53250, 54575, 55875, 56800, 58175, 59425, 60350, 61725, 62975, 63900, 65275, 66525, 67850, 68825, 70075, 71400, 72300, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        60350, 61725, 62975, 63900, 65275, 66525, 67850, 68825, 70075, 71400, 72300, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        12440, 13775, 15080, 15990, 17325, 18630, 19940, 20900, 22180, 23490, 24450, 25760, 27040, 28000, 29310, 30590, 31950, 32860, 34190, 35500, 36425, 37725, 39050, 39975, 41275, 42600, 43925, 44825, 46150, 47475, 48375, 49700, 51025, 51925, 53250, 54575, 55875, 56800, 58175, 59425, 60350, 61725, 62975, 63900, 65275, 66525, 66525, 53250, 39900, 26610, 13320, 
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
                        17600, 62920, 108240, 153560, 198880, 244200, 289520, 334840, 380160, 425480, 470800, 516120, 561440, 606760, 652080, 697400, 742720, 788040, 833360, 878680, 924000, 981030, 1038045, 1095075, 1152090, 1209120, 1266150, 1323165, 1380195, 1437210, 1494240, 1551270, 1608285, 1665315, 1722330, 1779360, 1835325, 1891290, 1947270, 2003235, 2059200, 2079795, 2100390, 2120970, 2141565, 2162160, 2182755, 2203350, 2223930, 2244525, 2265120, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2059200, 2079795, 2100390, 2120970, 2141565, 2162160, 2182755, 2203350, 2223930, 2244525, 2265120, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        17600, 62920, 108240, 153560, 198880, 244200, 289520, 334840, 380160, 425480, 470800, 516120, 561440, 606760, 652080, 697400, 742720, 788040, 833360, 878680, 924000, 981030, 1038045, 1095075, 1152090, 1209120, 1266150, 1323165, 1380195, 1437210, 1494240, 1551270, 1608285, 1665315, 1722330, 1779360, 1835325, 1891290, 1947270, 2003235, 2059200, 2079795, 2100390, 2120970, 2141565, 2162160, 
                    },
                    minLevel = 10,
                    maxLevel = 55,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 168381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59202,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59874,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59897,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60972,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59960,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59959,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59966,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59973,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61190,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62654,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59974,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheEmptyThrone, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    questline = 1063,
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
                    level = 10,
                },
            },
        },
        {
            type = "chain",
            id = Chain.ChampionOfPain,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HouseOfTheChosen,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MatronOfSpies,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HouseOfConstructs,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.HouseOfPlagues,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.RitualForTheDamned,
        },
    },
    active = {
        type = "quest",
        id = 59011,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 60737,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5260, 5850, 6320, 6860, 7350, 7820, 8410, 8850, 9320, 9910, 10350, 10940, 11410, 11850, 12440, 12910, 13400, 13940, 14410, 15000, 15450, 15900, 16500, 16950, 17400, 18000, 18500, 19000, 19500, 20000, 20500, 21000, 21500, 22000, 22500, 23100, 23550, 24000, 24600, 25050, 25500, 26100, 26550, 27100, 27600, 28050, 28650, 29100, 29550, 30150, 30550, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        25500, 26100, 26550, 27100, 27600, 28050, 28650, 29100, 29550, 30150, 30550, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        11330, 11750, 12060, 12480, 12800, 13110, 13530, 13850, 14160, 14580, 14900, 15320, 15630, 15950, 16370, 16680, 17000, 17420, 17730, 18150, 18475, 18775, 19200, 19525, 19825, 20250, 20575, 20975, 21300, 21625, 22025, 22350, 22675, 23075, 23400, 23825, 24125, 24450, 24875, 25175, 25500, 26100, 26550, 27100, 27600, 28050, 28225, 24475, 20625, 16920, 13040, 
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
                        10400, 37180, 63960, 90740, 117520, 144300, 171080, 197860, 224640, 251420, 278200, 304980, 331760, 358540, 385320, 412100, 438880, 465660, 492440, 519220, 546000, 579700, 613390, 647090, 680780, 714480, 748180, 781870, 815570, 849260, 882960, 916660, 950350, 984050, 1017740, 1051440, 1084510, 1117580, 1150660, 1183730, 1216800, 1228970, 1241140, 1253300, 1265470, 1277640, 1289810, 1301980, 1314140, 1326310, 1338480, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1216800, 1228970, 1241140, 1253300, 1265470, 1277640, 1289810, 1301980, 1314140, 1326310, 1338480, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        265600, 286715, 307830, 328945, 350060, 371175, 392290, 413405, 434520, 455635, 476750, 497865, 518980, 540095, 561210, 582325, 603440, 624555, 645670, 666785, 687900, 714470, 741035, 767605, 794170, 820740, 847310, 873875, 900445, 927010, 953580, 980150, 1006715, 1033285, 1059850, 1086420, 1112495, 1138570, 1164650, 1190725, 1216800, 1228970, 1241140, 1253300, 1265470, 1277640, 1280215, 1282790, 1285360, 1287935, 1290510, 
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
            id = 162801,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59011,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60737,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59206,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61715,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61716,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 1), -- Theater of Pain
    questline = 1156,
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
            id = Chain.ChampionOfPain,
            upto = 57425,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {58068, 59750, 59781, 59867, 62462},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57316,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        26870, 29750, 32415, 34695, 37400, 40065, 42945, 45050, 47715, 50595, 52700, 55580, 58245, 60350, 63230, 65895, 68600, 70880, 73545, 76425, 78625, 81250, 84150, 86275, 88900, 91800, 94525, 96725, 99450, 102175, 104375, 107100, 109825, 112025, 114750, 117650, 120275, 122400, 125300, 127925, 130125, 133025, 135650, 137950, 140675, 143300, 146200, 148325, 150950, 153850, 155875, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        133125, 135725, 138050, 140050, 142475, 144800, 147400, 149225, 151550, 154150, 155875, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        58920, 61100, 63165, 64745, 66850, 68915, 71095, 72600, 74665, 76845, 78350, 80530, 82595, 84100, 86280, 88345, 90450, 92030, 94095, 96275, 97800, 99825, 102025, 103550, 105575, 107775, 109900, 111400, 113525, 115650, 117150, 119275, 121400, 122900, 125025, 127225, 129250, 130775, 132975, 135000, 136525, 138725, 140750, 142350, 144475, 142000, 125325, 104975, 84625, 63750, 51262.5, 
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
                        47800, 170885, 293970, 417055, 540140, 663225, 786310, 909395, 1032480, 1155565, 1278650, 1401735, 1524820, 1647905, 1770990, 1894075, 2017160, 2140245, 2263330, 2386415, 2509500, 2664380, 2819240, 2974120, 3128980, 3283860, 3438740, 3593600, 3748480, 3903340, 4058220, 4213100, 4367960, 4522840, 4677700, 4832580, 4984580, 5136580, 5288600, 5440600, 5592600, 5648530, 5704460, 5760370, 5816300, 5872230, 5928160, 5984090, 6040000, 6095930, 6151860, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5697900, 5743300, 5788700, 5834080, 5879480, 5924880, 5970280, 6015680, 6061060, 6106460, 6151860, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        2218700, 2298010, 2377320, 2456630, 2535940, 2615250, 2694560, 2773870, 2853180, 2932490, 3011800, 3091110, 3170420, 3249730, 3329040, 3408350, 3487660, 3566970, 3646280, 3725590, 3804900, 3904700, 4004480, 4104280, 4204060, 4303860, 4403660, 4503440, 4603240, 4703020, 4802820, 4902620, 5002400, 5102200, 5201980, 5301780, 5399720, 5497660, 5595620, 5693560, 5791500, 5827540, 5863580, 5899600, 5935640, 5942895, 
                    },
                    minLevel = 10,
                    maxLevel = 55,
                },
            },
        },
        {
            type = "reputation",
            id = 2410,
            amount = 1665,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
            x = -3,
            connections = {
                [4] = {0.5, 4}, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            aside = true,
            embed = true,
            x = 3,
        },
        {
            type = "quest",
            id = 59879,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59203,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59837,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58900,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57316,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 4), -- Wasteland Work
    questline = 1159,
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
            id = Chain.ChampionOfPain,
            upto = 57425,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {58785, 58750},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 58794,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6300, 6975, 7650, 8100, 8775, 9450, 10125, 10575, 11250, 11925, 12375, 13050, 13725, 14175, 14850, 15525, 16200, 16650, 17325, 18000, 18450, 19125, 19800, 20250, 20925, 21600, 22275, 22725, 23400, 24075, 24525, 25200, 25875, 26325, 27000, 27675, 28350, 28800, 29475, 30150, 30600, 31275, 31950, 32400, 33075, 33750, 34425, 34875, 35550, 36225, 36675, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        30600, 31275, 31950, 32400, 33075, 33750, 34425, 34875, 35550, 36225, 36675, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        6300, 6975, 7650, 8100, 8775, 9450, 10125, 10575, 11250, 11925, 12375, 13050, 13725, 14175, 14850, 15525, 16200, 16650, 17325, 18000, 18450, 19125, 19800, 20250, 20925, 21600, 22275, 22725, 23400, 24075, 24525, 25200, 25875, 26325, 27000, 27675, 28350, 28800, 29475, 30150, 30600, 31275, 31950, 32400, 33075, 33750, 32400, 26100, 19575, 13050, 6525, 
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
                        9000, 32175, 55350, 78525, 101700, 124875, 148050, 171225, 194400, 217575, 240750, 263925, 287100, 310275, 333450, 356625, 379800, 402975, 426150, 449325, 472500, 501660, 530820, 559980, 589140, 618300, 647460, 676620, 705780, 734940, 764100, 793260, 822420, 851580, 880740, 909900, 938520, 967140, 995760, 1024380, 1053000, 1063530, 1074060, 1084590, 1095120, 1105650, 1116180, 1126710, 1137240, 1147770, 1158300, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1053000, 1063530, 1074060, 1084590, 1095120, 1105650, 1116180, 1126710, 1137240, 1147770, 1158300, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        9000, 32175, 55350, 78525, 101700, 124875, 148050, 171225, 194400, 217575, 240750, 263925, 287100, 310275, 333450, 356625, 379800, 402975, 426150, 449325, 472500, 501660, 530820, 559980, 589140, 618300, 647460, 676620, 705780, 734940, 764100, 793260, 822420, 851580, 880740, 909900, 938520, 967140, 995760, 1024380, 1053000, 1063530, 1074060, 1084590, 1095120, 1105650, 
                    },
                    minLevel = 10,
                    maxLevel = 55,
                },
            },
        },
        {
            type = "reputation",
            id = 2410,
            amount = 405,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58794,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 2), -- Archival Protection
    questline = 1157,
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
            id = Chain.ChampionOfPain,
            upto = 57425,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {
            58619, 62605, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 58623,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        16800, 18600, 20400, 21600, 23400, 25200, 27000, 28200, 30000, 31800, 33000, 34800, 36600, 37800, 39600, 41400, 43200, 44400, 46200, 48000, 49200, 51000, 52800, 54000, 55800, 57600, 59400, 60600, 62400, 64200, 65400, 67200, 69000, 70200, 72000, 73800, 75600, 76800, 78600, 80400, 81600, 83400, 85200, 86400, 88200, 90000, 91800, 93000, 94800, 96600, 97800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        81600, 83400, 85200, 86400, 88200, 90000, 91800, 93000, 94800, 96600, 97800, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        16800, 18600, 20400, 21600, 23400, 25200, 27000, 28200, 30000, 31800, 33000, 34800, 36600, 37800, 39600, 41400, 43200, 44400, 46200, 48000, 49200, 51000, 52800, 54000, 55800, 57600, 59400, 60600, 62400, 64200, 65400, 67200, 69000, 70200, 72000, 73800, 75600, 76800, 78600, 80400, 81600, 83400, 85200, 86400, 88200, 85200, 67800, 51000, 34200, 16800, 8400, 
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
                        24000, 85800, 147600, 209400, 271200, 333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 2836080, 2864160, 2892240, 2920320, 2948400, 2976480, 3004560, 3032640, 3060720, 3088800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2808000, 2836080, 2864160, 2892240, 2920320, 2948400, 2976480, 3004560, 3032640, 3060720, 3088800, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        24000, 85800, 147600, 209400, 271200, 333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 2836080, 2864160, 2892240, 2920320, 
                    },
                    minLevel = 10,
                    maxLevel = 54,
                },
            },
        },
        {
            type = "reputation",
            id = 2410,
            amount = 1080,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 62605,
                    restrictions = {
                        type = "quest",
                        id = 62605,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 166657,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58619,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58621,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 59917,
            aside = true,
        },
        {
            type = "quest",
            id = 58620,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58622,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60900,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59994,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58623,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 3), -- Mixing Monstrosities
    questline = 1158,
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
            id = Chain.ChampionOfPain,
            upto = 57425,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        id = 59430,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 58431,
    },
    items = {
        {
            type = "npc",
            id = 165049,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59430,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58431,
            x = 0,
            -- connections = {
            --     1, 
            -- },
        },
        -- {
        --     name = "Unlocks weeklies",
        --     x = 0,
        -- },
        -- {
        --     type = "quest",
        --     id = 57301,
        -- },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    questline = {1156, 1169},
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 61878,
    },
    items = {
        {
            type = "npc",
            id = 159689,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58068,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58088,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58090,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58095,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    questline = 1156,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 60050,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 62785,
                    restrictions = {
                        type = "quest",
                        id = 62785,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 161559,
                }
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 59750,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 59781,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58575,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 59800,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58947,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    questline = 1171,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 61769,
    },
    items = {
        {
            type = "object",
            id = 349612,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59867,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    questline = 1170,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 60067,
    },
    items = {
        {
            type = "object",
            id = 358382,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62462,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    questline = 1159,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 60067,
    },
    items = {
        {
            type = "npc",
            id = 162615,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58785,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    questline = 1159,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 60067,
    },
    items = {
        {
            type = "npc",
            id = 162474,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58750,
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
    buttonImage = 3759911,
    items = {
        {
            type = "chain",
            id = Chain.ChampionOfPain,
        },
        {
            type = "chain",
            id = Chain.HouseOfTheChosen,
        },
        {
            type = "chain",
            id = Chain.MatronOfSpies,
        },
        {
            type = "chain",
            id = Chain.HouseOfConstructs,
        },
        {
            type = "chain",
            id = Chain.HouseOfPlagues,
        },
        {
            type = "chain",
            id = Chain.RitualForTheDamned,
        },
        {
            type = "chain",
            id = Chain.TheEmptyThrone,
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
            restrictions = 86994,
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
})
