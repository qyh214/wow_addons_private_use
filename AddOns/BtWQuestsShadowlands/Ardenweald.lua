--[[
    [Supplies Needed: More Husks!] requires ATLEAST [Unsafe Workplace] to be active, NOT available with JUST [Supplies Needed: Amber Grease] completed
]]

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.Ardenweald
local Chain = BtWQuests.Constant.Chain.Shadowlands.Ardenweald
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde
local MAP_ID = 1565
local CONTINENT_ID = 1550
local ACHIEVEMENT_ID = 14164
local SIDE_ACHIEVEMENT_ID = 14800
local LEVEL_RANGE = {55, 57}
local LEVEL_PREREQUISITE = {
    type = "level",
    level = 55,
}

Database:AddChain(Chain.WelcomeToArdenweald, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = 1002,
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
            id = 90207,
        }
    },
    active = {
        type = "quest",
        id = 60338,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57787,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7360, 8175, 8870, 9560, 10275, 10970, 11760, 12400, 13070, 13860, 14500, 15290, 15960, 16600, 17390, 18060, 18800, 19490, 20210, 21000, 21600, 22300, 23100, 23700, 24400, 25200, 25900, 26600, 27300, 28000, 28700, 29400, 30100, 30800, 31500, 32300, 33000, 33600, 34450, 35100, 35700, 36550, 37200, 37900, 38650, 39300, 40100, 40750, 41400, 42200, 42800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        35700, 36550, 37200, 37900, 38650, 39300, 40100, 40750, 41400, 42200, 42800, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        7360, 8175, 8870, 9560, 10275, 10970, 11760, 12400, 13070, 13860, 14500, 15290, 15960, 16600, 17390, 18060, 18800, 19490, 20210, 21000, 21600, 22300, 23100, 23700, 24400, 25200, 25900, 26600, 27300, 28000, 28700, 29400, 30100, 30800, 31500, 32300, 33000, 33600, 34450, 35100, 35700, 36550, 37200, 37900, 38650, 39300, 37900, 30350, 22750, 15170, 7585, 
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
                        13400, 47905, 82410, 116915, 151420, 185925, 220430, 254935, 289440, 323945, 358450, 392955, 427460, 461965, 496470, 530975, 565480, 599985, 634490, 668995, 703500, 746920, 790330, 833750, 877160, 920580, 964000, 1007410, 1050830, 1094240, 1137660, 1181080, 1224490, 1267910, 1311320, 1354740, 1397350, 1439960, 1482580, 1525190, 1567800, 1583480, 1599160, 1614830, 1630510, 1646190, 1661870, 1677550, 1693220, 1708900, 1724580, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1567800, 1583480, 1599160, 1614830, 1630510, 1646190, 1661870, 1677550, 1693220, 1708900, 1724580, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        13400, 47905, 82410, 116915, 151420, 185925, 220430, 254935, 289440, 323945, 358450, 392955, 427460, 461965, 496470, 530975, 565480, 599985, 634490, 668995, 703500, 746920, 790330, 833750, 877160, 920580, 964000, 1007410, 1050830, 1094240, 1137660, 1181080, 1224490, 1267910, 1311320, 1354740, 1397350, 1439960, 1482580, 1525190, 1567800, 1583480, 1599160, 1614830, 1630510, 1646190, 
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
            id = 173383,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60338,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60763,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60341,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60778,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60857,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60859,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57787,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TranquilPools, { -- [Aiding Tirna Vaal]
    name = L["AIDING_TIRNA_VAAL_TRANQUIL_POOLS"],
    questline = 1008,
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
            id = Chain.WelcomeToArdenweald,
        },
    },
    active = {
        type = "quest",
        id = 57816,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60594,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6480, 7175, 7860, 8330, 9025, 9710, 10380, 10900, 11560, 12230, 12750, 13420, 14080, 14600, 15270, 15930, 16650, 17120, 17830, 18500, 18975, 19675, 20350, 20825, 21525, 22200, 22875, 23375, 24050, 24725, 25225, 25900, 26575, 27075, 27750, 28425, 29125, 29600, 30325, 30975, 31450, 32175, 32825, 33300, 34025, 34675, 35350, 35875, 36525, 37200, 37700, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        31450, 32175, 32825, 33300, 34025, 34675, 35350, 35875, 36525, 37200, 37700, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        6480, 7175, 7860, 8330, 9025, 9710, 10380, 10900, 11560, 12230, 12750, 13420, 14080, 14600, 15270, 15930, 16650, 17120, 17830, 18500, 18975, 19675, 20350, 20825, 21525, 22200, 22875, 23375, 24050, 24725, 25225, 25900, 26575, 27075, 27750, 28425, 29125, 29600, 30325, 30975, 31450, 32175, 32825, 33300, 34025, 34675, 35350, 34025, 27275, 20350, 13620, 
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
                        9200, 32890, 56580, 80270, 103960, 127650, 151340, 175030, 198720, 222410, 246100, 269790, 293480, 317170, 340860, 364550, 388240, 411930, 435620, 459310, 483000, 512810, 542615, 572425, 602230, 632040, 661850, 691655, 721465, 751270, 781080, 810890, 840695, 870505, 900310, 930120, 959375, 988630, 1017890, 1047145, 1076400, 1087165, 1097930, 1108690, 1119455, 1130220, 1140985, 1151750, 1162510, 1173275, 1184040, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1076400, 1087165, 1097930, 1108690, 1119455, 1130220, 1140985, 1151750, 1162510, 1173275, 1184040, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        9200, 32890, 56580, 80270, 103960, 127650, 151340, 175030, 198720, 222410, 246100, 269790, 293480, 317170, 340860, 364550, 388240, 411930, 435620, 459310, 483000, 512810, 542615, 572425, 602230, 632040, 661850, 691655, 721465, 751270, 781080, 810890, 840695, 870505, 900310, 930120, 959375, 988630, 1017890, 1047145, 1076400, 1087165, 1097930, 1108690, 1119455, 1130220, 1140985, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 158487,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57816,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60567,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 60563,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60575,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60577,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60594,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SpiritGlen, { -- [Aiding Tirna Vaal]
    name = L["AIDING_TIRNA_VAAL_SPIRIT_GLEN"],
    questline = {1008,1011},
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
            id = Chain.WelcomeToArdenweald,
        },
    },
    active = {
        type = "quest",
        id = 57947,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57951,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4560, 5050, 5520, 5860, 6350, 6820, 7310, 7650, 8120, 8610, 8950, 9440, 9910, 10250, 10740, 11210, 11700, 12040, 12510, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16100, 16400, 16900, 17400, 17700, 18200, 18700, 19000, 19500, 20000, 20450, 20800, 21300, 21750, 22100, 22600, 23050, 23400, 23900, 24350, 24850, 25200, 25650, 26150, 26450, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22100, 22600, 23050, 23400, 23900, 24350, 24850, 25200, 25650, 26150, 26450, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        4560, 5050, 5520, 5860, 6350, 6820, 7310, 7650, 8120, 8610, 8950, 9440, 9910, 10250, 10740, 11210, 11700, 12040, 12510, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16100, 16400, 16900, 17400, 17700, 18200, 18700, 19000, 19500, 20000, 20450, 20800, 21300, 21750, 22100, 22600, 23050, 23400, 23900, 24350, 23400, 18850, 14150, 9420, 4710, 
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
                        6400, 22880, 39360, 55840, 72320, 88800, 105280, 121760, 138240, 154720, 171200, 187680, 204160, 220640, 237120, 253600, 270080, 286560, 303040, 319520, 336000, 356740, 377470, 398210, 418940, 439680, 460420, 481150, 501890, 522620, 543360, 564100, 584830, 605570, 626300, 647040, 667390, 687740, 708100, 728450, 748800, 756290, 763780, 771260, 778750, 786240, 793730, 801220, 808700, 816190, 823680, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        748800, 756290, 763780, 771260, 778750, 786240, 793730, 801220, 808700, 816190, 823680, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        6400, 22880, 39360, 55840, 72320, 88800, 105280, 121760, 138240, 154720, 171200, 187680, 204160, 220640, 237120, 253600, 270080, 286560, 303040, 319520, 336000, 356740, 377470, 398210, 418940, 439680, 460420, 481150, 501890, 522620, 543360, 564100, 584830, 605570, 626300, 647040, 667390, 687740, 708100, 728450, 748800, 756290, 763780, 771260, 778750, 786240, 
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
            id = 158487,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57947,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 57948,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 57949,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57950,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57951,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WaningGrove, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = 1125,
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
            id = Chain.WelcomeToArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
        },
    },
    active = {
        type = "quest",
        id = 60600,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60519,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11730, 13000, 14210, 15130, 16350, 17560, 18730, 19800, 20910, 22080, 23150, 24320, 25430, 26500, 27670, 28780, 30100, 31020, 32330, 33500, 34375, 35675, 36850, 37725, 39025, 40200, 41325, 42425, 43550, 44675, 45775, 46900, 48025, 49125, 50250, 51425, 52725, 53600, 54975, 56075, 56950, 58325, 59425, 60350, 61675, 62775, 63950, 65025, 66125, 67300, 68350, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        56950, 58325, 59425, 60350, 61675, 62775, 63950, 65025, 66125, 67300, 68350, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        11730, 13000, 14210, 15130, 16350, 17560, 18730, 19800, 20910, 22080, 23150, 24320, 25430, 26500, 27670, 28780, 30100, 31020, 32330, 33500, 34375, 35675, 36850, 37725, 39025, 40200, 41325, 42425, 43550, 44675, 45775, 46900, 48025, 49125, 50250, 51425, 52725, 53600, 54975, 56075, 56950, 58325, 59425, 60350, 61675, 62775, 63950, 61675, 49375, 36850, 24620, 
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
                        18200, 65065, 111930, 158795, 205660, 252525, 299390, 346255, 393120, 439985, 486850, 533715, 580580, 627445, 674310, 721175, 768040, 814905, 861770, 908635, 955500, 1014470, 1073435, 1132405, 1191370, 1250340, 1309310, 1368275, 1427245, 1486210, 1545180, 1604150, 1663115, 1722085, 1781050, 1840020, 1897895, 1955770, 2013650, 2071525, 2129400, 2150695, 2171990, 2193280, 2214575, 2235870, 2257165, 2278460, 2299750, 2321045, 2342340, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2129400, 2150695, 2171990, 2193280, 2214575, 2235870, 2257165, 2278460, 2299750, 2321045, 2342340, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        18200, 65065, 111930, 158795, 205660, 252525, 299390, 346255, 393120, 439985, 486850, 533715, 580580, 627445, 674310, 721175, 768040, 814905, 861770, 908635, 955500, 1014470, 1073435, 1132405, 1191370, 1250340, 1309310, 1368275, 1427245, 1486210, 1545180, 1604150, 1663115, 1722085, 1781050, 1840020, 1897895, 1955770, 2013650, 2071525, 2129400, 2150695, 2171990, 2193280, 2214575, 2235870, 2257165, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 169031,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60600,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60624,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 60637,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 60638,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 60639,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60647,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60648,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60671,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60709,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60724,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60519,
            x = 0,
        },
    },
})
Database:AddChain(Chain.GlitterfallHeights, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = 1126,
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
            id = Chain.WelcomeToArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WaningGrove,
        },
    },
    active = {
        type = "quest",
        id = 60521,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60520,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9630, 10675, 11660, 12430, 13425, 14410, 15430, 16200, 17160, 18180, 18950, 19970, 20930, 21700, 22720, 23680, 24700, 25470, 26480, 27500, 28225, 29225, 30250, 30975, 31975, 33000, 33975, 34775, 35750, 36725, 37525, 38500, 39475, 40275, 41250, 42275, 43275, 44000, 45075, 46025, 46750, 47825, 48775, 49550, 50575, 51525, 52550, 53325, 54275, 55300, 56050, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        46750, 47825, 48775, 49550, 50575, 51525, 52550, 53325, 54275, 55300, 56050, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        9630, 10675, 11660, 12430, 13425, 14410, 15430, 16200, 17160, 18180, 18950, 19970, 20930, 21700, 22720, 23680, 24700, 25470, 26480, 27500, 28225, 29225, 30250, 30975, 31975, 33000, 33975, 34775, 35750, 36725, 37525, 38500, 39475, 40275, 41250, 42275, 43275, 44000, 45075, 46025, 46750, 47825, 48775, 49550, 50575, 51525, 52550, 50575, 40525, 30250, 20270, 
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
                        15200, 54340, 93480, 132620, 171760, 210900, 250040, 289180, 328320, 367460, 406600, 445740, 484880, 524020, 563160, 602300, 641440, 680580, 719720, 758860, 798000, 847250, 896495, 945745, 994990, 1044240, 1093490, 1142735, 1191985, 1241230, 1290480, 1339730, 1388975, 1438225, 1487470, 1536720, 1585055, 1633390, 1681730, 1730065, 1778400, 1796185, 1813970, 1831750, 1849535, 1867320, 1885105, 1902890, 1920670, 1938455, 1956240, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1778400, 1796185, 1813970, 1831750, 1849535, 1867320, 1885105, 1902890, 1920670, 1938455, 1956240, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        15200, 54340, 93480, 132620, 171760, 210900, 250040, 289180, 328320, 367460, 406600, 445740, 484880, 524020, 563160, 602300, 641440, 680580, 719720, 758860, 798000, 847250, 896495, 945745, 994990, 1044240, 1093490, 1142735, 1191985, 1241230, 1290480, 1339730, 1388975, 1438225, 1487470, 1536720, 1585055, 1633390, 1681730, 1730065, 1778400, 1796185, 1813970, 1831750, 1849535, 1867320, 1885105, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 169031,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60521,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60628,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 60629,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60631,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60630,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60632,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60522,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60520,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ThisIsTheWay, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 1127,
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
            id = Chain.WelcomeToArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WaningGrove,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GlitterfallHeights,
        },
    },
    active = {
        type = "quest",
        id = 60738,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60905,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9280, 10275, 11260, 11930, 12925, 13910, 14830, 15650, 16560, 17480, 18300, 19220, 20130, 20950, 21870, 22780, 23850, 24520, 25580, 26500, 27175, 28225, 29150, 29825, 30875, 31800, 32725, 33525, 34450, 35375, 36175, 37100, 38025, 38825, 39750, 40675, 41725, 42400, 43475, 44375, 45050, 46125, 47025, 47700, 48775, 49675, 50600, 51425, 52325, 53250, 54050, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        45050, 46125, 47025, 47700, 48775, 49675, 50600, 51425, 52325, 53250, 54050, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        9280, 10275, 11260, 11930, 12925, 13910, 14830, 15650, 16560, 17480, 18300, 19220, 20130, 20950, 21870, 22780, 23850, 24520, 25580, 26500, 27175, 28225, 29150, 29825, 30875, 31800, 32725, 33525, 34450, 35375, 36175, 37100, 38025, 38825, 39750, 40675, 41725, 42400, 43475, 44375, 45050, 46125, 47025, 47700, 48775, 49675, 50600, 51425, 49675, 39750, 29800, 
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
                        13200, 47190, 81180, 115170, 149160, 183150, 217140, 251130, 285120, 319110, 353100, 387090, 421080, 455070, 489060, 523050, 557040, 591030, 625020, 659010, 693000, 735770, 778535, 821305, 864070, 906840, 949610, 992375, 1035145, 1077910, 1120680, 1163450, 1206215, 1248985, 1291750, 1334520, 1376495, 1418470, 1460450, 1502425, 1544400, 1559845, 1575290, 1590730, 1606175, 1621620, 1637065, 1652510, 1667950, 1683395, 1698840, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1544400, 1559845, 1575290, 1590730, 1606175, 1621620, 1637065, 1652510, 1667950, 1683395, 1698840, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        13200, 47190, 81180, 115170, 149160, 183150, 217140, 251130, 285120, 319110, 353100, 387090, 421080, 455070, 489060, 523050, 557040, 591030, 625020, 659010, 693000, 735770, 778535, 821305, 864070, 906840, 949610, 992375, 1035145, 1077910, 1120680, 1163450, 1206215, 1248985, 1291750, 1334520, 1376495, 1418470, 1460450, 1502425, 1544400, 1559845, 1575290, 1590730, 1606175, 1621620, 1637065, 1652510, 
                    },
                    minLevel = 10,
                    maxLevel = 57,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 169142,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60738,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60764,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60839,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60840,
            aside = true,
        },
        {
            type = "quest",
            id = 60856,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60881,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60901,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60905,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheFallenTree, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    questline = 1025,
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
            id = Chain.WelcomeToArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WaningGrove,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GlitterfallHeights,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ThisIsTheWay,
        },
    },
    active = {
        type = "quest",
        id = 58473,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58524,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7880, 8725, 9560, 10130, 10975, 11810, 12630, 13250, 14060, 14880, 15500, 16320, 17130, 17750, 18570, 19380, 20250, 20820, 21680, 22500, 23075, 23925, 24750, 25325, 26175, 27000, 27825, 28425, 29250, 30075, 30675, 31500, 32325, 32925, 33750, 34575, 35425, 36000, 36875, 37675, 38250, 39125, 39925, 40500, 41375, 42175, 43000, 43625, 44425, 45250, 45850, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        38250, 39125, 39925, 40500, 41375, 42175, 43000, 43625, 44425, 45250, 45850, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        7880, 8725, 9560, 10130, 10975, 11810, 12630, 13250, 14060, 14880, 15500, 16320, 17130, 17750, 18570, 19380, 20250, 20820, 21680, 22500, 23075, 23925, 24750, 25325, 26175, 27000, 27825, 28425, 29250, 30075, 30675, 31500, 32325, 32925, 33750, 34575, 35425, 36000, 36875, 37675, 38250, 39125, 39925, 40500, 41375, 42175, 43000, 43625, 42175, 33750, 25300, 
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
                        11200, 40040, 68880, 97720, 126560, 155400, 184240, 213080, 241920, 270760, 299600, 328440, 357280, 386120, 414960, 443800, 472640, 501480, 530320, 559160, 588000, 624290, 660575, 696865, 733150, 769440, 805730, 842015, 878305, 914590, 950880, 987170, 1023455, 1059745, 1096030, 1132320, 1167935, 1203550, 1239170, 1274785, 1310400, 1323505, 1336610, 1349710, 1362815, 1375920, 1389025, 1402130, 1415230, 1428335, 1441440, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1310400, 1323505, 1336610, 1349710, 1362815, 1375920, 1389025, 1402130, 1415230, 1428335, 1441440, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        11200, 40040, 68880, 97720, 126560, 155400, 184240, 213080, 241920, 270760, 299600, 328440, 357280, 386120, 414960, 443800, 472640, 501480, 530320, 559160, 588000, 624290, 660575, 696865, 733150, 769440, 805730, 842015, 878305, 914590, 950880, 987170, 1023455, 1059745, 1096030, 1132320, 1167935, 1203550, 1239170, 1274785, 1310400, 1323505, 1336610, 1349710, 1362815, 1375920, 1389025, 1402130, 
                    },
                    minLevel = 10,
                    maxLevel = 57,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 160963,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58473,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 58480,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 58484,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58483,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58488,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58524,
            x = 0,
        },
    },
})
Database:AddChain(Chain.VisionsOfTheDreamer, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    questline = 1027,
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
            id = Chain.WelcomeToArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WaningGrove,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GlitterfallHeights,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ThisIsTheWay,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheFallenTree,
        },
    },
    active = {
        type = "quest",
        ids = {
            60572, 58591, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 58593,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9280, 10300, 11210, 12030, 12950, 13860, 14880, 15600, 16510, 17530, 18250, 19270, 20180, 20900, 21920, 22830, 23750, 24570, 25480, 26500, 27225, 28125, 29150, 29875, 30775, 31800, 32725, 33525, 34450, 35375, 36175, 37100, 38025, 38825, 39750, 40775, 41675, 42400, 43425, 44325, 45050, 46075, 46975, 47800, 48725, 49625, 50650, 51375, 52275, 53300, 54000, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        45050, 46075, 46975, 47800, 48725, 49625, 50650, 51375, 52275, 53300, 54000, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        9280, 10300, 11210, 12030, 12950, 13860, 14880, 15600, 16510, 17530, 18250, 19270, 20180, 20900, 21920, 22830, 23750, 24570, 25480, 26500, 27225, 28125, 29150, 29875, 30775, 31800, 32725, 33525, 34450, 35375, 36175, 37100, 38025, 38825, 39750, 40775, 41675, 42400, 43425, 44325, 45050, 46075, 46975, 47800, 48725, 49625, 50650, 51375, 52275, 50950, 40675, 
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
                        16200, 57915, 99630, 141345, 183060, 224775, 266490, 308205, 349920, 391635, 433350, 475065, 516780, 558495, 600210, 641925, 683640, 725355, 767070, 808785, 850500, 902990, 955475, 1007965, 1060450, 1112940, 1165430, 1217915, 1270405, 1322890, 1375380, 1427870, 1480355, 1532845, 1585330, 1637820, 1689335, 1740850, 1792370, 1843885, 1895400, 1914355, 1933310, 1952260, 1971215, 1990170, 2009125, 2028080, 2047030, 2065985, 2084940, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1895400, 1914355, 1933310, 1952260, 1971215, 1990170, 2009125, 2028080, 2047030, 2065985, 2084940, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        16200, 57915, 99630, 141345, 183060, 224775, 266490, 308205, 349920, 391635, 433350, 475065, 516780, 558495, 600210, 641925, 683640, 725355, 767070, 808785, 850500, 902990, 955475, 1007965, 1060450, 1112940, 1165430, 1217915, 1270405, 1322890, 1375380, 1427870, 1480355, 1532845, 1585330, 1637820, 1689335, 1740850, 1792370, 1843885, 1895400, 1914355, 1933310, 1952260, 1971215, 1990170, 2009125, 2028080, 2047030, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 160894,
            x = 0,
            connections = {
                1, 4, 
            },
        },
        {
            type = "quest",
            id = 60572,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58589,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 58592,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 58591,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60578,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58590,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58593,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AwakenTheDreamer, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 8),
    questline = 1033,
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
            id = Chain.WelcomeToArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WaningGrove,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GlitterfallHeights,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ThisIsTheWay,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheFallenTree,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VisionsOfTheDreamer,
        },
    },
    active = {
        type = "quest",
        ids = {
            58714, 58719, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 58723,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8460, 9350, 10170, 10910, 11750, 12570, 13360, 14250, 14970, 15760, 16650, 17440, 18160, 19050, 19840, 20560, 21500, 22240, 23160, 23950, 24700, 25600, 26400, 27100, 28000, 28800, 29550, 30450, 31200, 31950, 32850, 33600, 34350, 35250, 36000, 36800, 37700, 38400, 39400, 40100, 40850, 41850, 42550, 43300, 44250, 44950, 45750, 46650, 47350, 48150, 49000, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        40850, 41850, 42550, 43300, 44250, 44950, 45750, 46650, 47350, 48150, 49000, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        8460, 9350, 10170, 10910, 11750, 12570, 13360, 14250, 14970, 15760, 16650, 17440, 18160, 19050, 19840, 20560, 21500, 22240, 23160, 23950, 24700, 25600, 26400, 27100, 28000, 28800, 29550, 30450, 31200, 31950, 32850, 33600, 34350, 35250, 36000, 36800, 37700, 38400, 39400, 40100, 40850, 41850, 42550, 43300, 44250, 44950, 45750, 46650, 47350, 45750, 36600, 
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
                        16400, 58630, 100860, 143090, 185320, 227550, 269780, 312010, 354240, 396470, 438700, 480930, 523160, 565390, 607620, 649850, 692080, 734310, 776540, 818770, 861000, 914140, 967270, 1020410, 1073540, 1126680, 1179820, 1232950, 1286090, 1339220, 1392360, 1445500, 1498630, 1551770, 1604900, 1658040, 1710190, 1762340, 1814500, 1866650, 1918800, 1937990, 1957180, 1976360, 1995550, 2014740, 2033930, 2053120, 2072300, 2091490, 2110680, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1918800, 1937990, 1957180, 1976360, 1995550, 2014740, 2033930, 2053120, 2072300, 2091490, 2110680, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        16400, 58630, 100860, 143090, 185320, 227550, 269780, 312010, 354240, 396470, 438700, 480930, 523160, 565390, 607620, 649850, 692080, 734310, 776540, 818770, 861000, 914140, 967270, 1020410, 1073540, 1126680, 1179820, 1232950, 1286090, 1339220, 1392360, 1445500, 1498630, 1551770, 1604900, 1658040, 1710190, 1762340, 1814500, 1866650, 1918800, 1937990, 1957180, 1976360, 1995550, 2014740, 2033930, 2053120, 2072300, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 161847,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 160894,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58714,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58719,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58720,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60621,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58869,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60661,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58721,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58723,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58724,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 2), -- When a Gorm Eats a God
    questline = {1194,1161},
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
            id = Chain.WelcomeToArdenweald,
            lowPriority = true,
            visible = 87203,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
            lowPriority = true,
            visible = 87203,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
            lowPriority = true,
            visible = 87203,
        },
        {
            type = "chain",
            id = Chain.WaningGrove,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {
            57952, 58024, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            58024, 58026, 
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10905, 12070, 13110, 14080, 15170, 16225, 17375, 18300, 19325, 20475, 21400, 22550, 23575, 24500, 25650, 26675, 27825, 28750, 29775, 31000, 31950, 32850, 34100, 35050, 35950, 37200, 38375, 39125, 40300, 41475, 42225, 43400, 44575, 45325, 46500, 47750, 48650, 49600, 50850, 51750, 52700, 53950, 54850, 55875, 57050, 58100, 59200, 60150, 61200, 62300, 63125, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        52700, 53950, 54850, 55875, 57050, 58100, 59200, 60150, 61200, 62300, 63125, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        10905, 12070, 13110, 14080, 15170, 16225, 17375, 18300, 19325, 20475, 21400, 22550, 23575, 24500, 25650, 26675, 27825, 28750, 29775, 31000, 31950, 32850, 34100, 35050, 35950, 37200, 38375, 39125, 40300, 41475, 42225, 43400, 44575, 45325, 46500, 47750, 48650, 49600, 50850, 51750, 52700, 53950, 54850, 55875, 57050, 58100, 59200, 57050, 45550, 34100, 22850, 
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
                        17500, 62570, 107626, 152696, 197750, 242820, 287876, 332946, 378000, 423070, 468126, 513196, 558250, 603320, 648376, 693446, 738500, 783570, 828626, 873696, 918750, 975460, 1032145, 1088855, 1145540, 1202250, 1258960, 1315645, 1372355, 1429040, 1485750, 1542460, 1599145, 1655855, 1712540, 1769250, 1824895, 1880540, 1936210, 1991855, 2047500, 2067981, 2088460, 2108916, 2129395, 2149876, 2170355, 2190836, 2211290, 2231771, 2252250, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2047500, 2067981, 2088460, 2108916, 2129395, 2149876, 2170355, 2190836, 2211290, 2231771, 2252250, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        17500, 62570, 107626, 152696, 197750, 242820, 287876, 332946, 378000, 423070, 468126, 513196, 558250, 603320, 648376, 693446, 738500, 783570, 828626, 873696, 918750, 975460, 1032145, 1088855, 1145540, 1202250, 1258960, 1315645, 1372355, 1429040, 1485750, 1542460, 1599145, 1655855, 1712540, 1769250, 1824895, 1880540, 1936210, 1991855, 2047500, 2067981, 2088460, 2108916, 2129395, 2149876, 2170355, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                },
            },
        },
        {
            type = "reputation",
            id = 2465,
            amount = 640,
        },
    },
    items = {
        {
            type = "npc",
            id = 158921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57952,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57818,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57824,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57825,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61051,
            x = 0,
            connections = {
                1.2, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            embed = true,
        },
        {
            type = "quest",
            id = 58022,
            x = -2,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58023,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58025,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58026,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57660,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 5), -- When a Gorm Eats a God
    questline = 1164,
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
            id = Chain.WaningGrove,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {
            58161, 62186, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 58166,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12790, 14175, 15480, 16490, 17825, 19130, 20515, 21475, 22780, 24165, 25125, 26510, 27815, 28775, 30160, 31465, 32800, 33810, 35115, 36500, 37475, 38750, 40150, 41125, 42400, 43800, 45150, 46100, 47450, 48800, 49750, 51100, 52450, 53400, 54750, 56150, 57425, 58400, 59800, 61075, 62050, 63450, 64725, 65750, 67100, 68375, 69775, 70750, 72025, 73425, 74325, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        62050, 63450, 64725, 65750, 67100, 68375, 69775, 70750, 72025, 73425, 74325, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        12790, 14175, 15480, 16490, 17825, 19130, 20515, 21475, 22780, 24165, 25125, 26510, 27815, 28775, 30160, 31465, 32800, 33810, 35115, 36500, 37475, 38750, 40150, 41125, 42400, 43800, 45150, 46100, 47450, 48800, 49750, 51100, 52450, 53400, 54750, 56150, 57425, 58400, 59800, 61075, 62050, 63450, 64725, 65750, 67100, 68375, 69775, 67600, 56275, 44200, 30835, 
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
                        19600, 70070, 120540, 171010, 221480, 271950, 322420, 372890, 423360, 473830, 524300, 574770, 625240, 675710, 726180, 776650, 827120, 877590, 928060, 978530, 1029000, 1092510, 1156005, 1219515, 1283010, 1346520, 1410030, 1473525, 1537035, 1600530, 1664040, 1727550, 1791045, 1854555, 1918050, 1981560, 2043885, 2106210, 2168550, 2230875, 2293200, 2316135, 2339070, 2361990, 2384925, 2407860, 2430795, 2435475, 2440155, 
                    },
                    minLevel = 10,
                    maxLevel = 58,
                },
            },
        },
        {
            type = "reputation",
            id = 2465,
            amount = 1050,
        },
    },
    items = {
        {
            type = "npc",
            id = 160440,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58161,
            x = 0,
            connections = {
                2, 3, 4
            },
        },
        {
            type = "object",
            id = 349515,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 58164,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 58162,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58163,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59802,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
        },
        {
            type = "quest",
            id = 58165,
            x = -2,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 59801,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58166,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 3), -- Trouble at the Gormling Corral
    questline = {1162, 1167},
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
            id = Chain.GlitterfallHeights,
            upto = 60632,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {
            57651, 57652, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 59656,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17160, 19000, 20820, 22060, 23900, 25720, 27560, 28800, 30620, 32460, 33700, 35540, 37360, 38600, 40440, 42260, 44100, 45340, 47160, 49000, 50250, 52050, 53900, 55150, 56950, 58800, 60650, 61850, 63700, 65550, 66750, 68600, 70450, 71650, 73500, 75350, 77150, 78400, 80250, 82050, 83300, 85150, 86950, 88200, 90050, 91850, 93700, 94950, 96750, 98600, 99800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        83300, 85150, 86950, 88200, 90050, 91850, 93700, 94950, 96750, 98600, 99800, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        17160, 19000, 20820, 22060, 23900, 25720, 27560, 28800, 30620, 32460, 33700, 35540, 37360, 38600, 40440, 42260, 44100, 45340, 47160, 49000, 50250, 52050, 53900, 55150, 56950, 58800, 60650, 61850, 63700, 65550, 66750, 68600, 70450, 71650, 73500, 75350, 77150, 78400, 80250, 82050, 83300, 85150, 86950, 88200, 90050, 91850, 93700, 90050, 72250, 53900, 36140, 
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
                        24400, 87230, 150060, 212890, 275720, 338550, 401380, 464210, 527040, 589870, 652700, 715530, 778360, 841190, 904020, 966850, 1029680, 1092510, 1155340, 1218170, 1281000, 1360060, 1439110, 1518170, 1597220, 1676280, 1755340, 1834390, 1913450, 1992500, 2071560, 2150620, 2229670, 2308730, 2387780, 2466840, 2544430, 2622020, 2699620, 2777210, 2854800, 2883350, 2911900, 2940440, 2968990, 2997540, 3026090, 3054640, 3083180, 3111730, 3140280, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2854800, 2883350, 2911900, 2940440, 2968990, 2997540, 3026090, 3054640, 3083180, 3111730, 3140280, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        24400, 87230, 150060, 212890, 275720, 338550, 401380, 464210, 527040, 589870, 652700, 715530, 778360, 841190, 904020, 966850, 1029680, 1092510, 1155340, 1218170, 1281000, 1360060, 1439110, 1518170, 1597220, 1676280, 1755340, 1834390, 1913450, 1992500, 2071560, 2150620, 2229670, 2308730, 2387780, 2466840, 2544430, 2622020, 2699620, 2777210, 2854800, 2883350, 2911900, 2940440, 2968990, 2997540, 3026090, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                },
            },
        },
        {
            type = "reputation",
            id = 2465,
            amount = 1280,
        },
    },
    items = {
        {
            type = "npc",
            id = 158345,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57651,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 59621,
            x = -2,
            y = 2,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 59622,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 57656,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 57653,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 57655,
            aside = true,
            connections = {
                1.3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 57657,
            x = -2,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59656,
            x = -1,
            y = 5,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 1), -- Thread of Hope
    questline = 1166,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 57661,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 60066,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amount = 42750,
                    restrictions = -1,
                },
                {
                    amount = 42750,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amount = 1338480,
                    restrictions = -1,
                },
                {
                    amount = 1338480,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 158556,
            x = -2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57661,
            x = -2,
            connections = {
                2, 3, 
            },
        },
        {
            type = "object",
            id = 350804,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60061,
            x = -2,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 60062,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60064,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60063,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60065,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60066,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 4), -- Tricky Spriggans
    questline = 1163,
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
            id = Chain.Chain03,
        },
    },
    active = {
        type = "quest",
        ids = {
            57866, 57865, 57867, 57868, 57870, 57869, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 57871,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15225, 16875, 18450, 19650, 21225, 22800, 24450, 25575, 27150, 28800, 29925, 31575, 33150, 34275, 35925, 37500, 39075, 40275, 41850, 43500, 44625, 46200, 47850, 48975, 50550, 52200, 53775, 54975, 56550, 58125, 59325, 60900, 62475, 63675, 65250, 66900, 68475, 69600, 71250, 72825, 73950, 75600, 77175, 78375, 79950, 81525, 83175, 84300, 85875, 87525, 88650, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        73950, 75600, 77175, 78375, 79950, 81525, 83175, 84300, 85875, 87525, 88650, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        15225, 16875, 18450, 19650, 21225, 22800, 24450, 25575, 27150, 28800, 29925, 31575, 33150, 34275, 35925, 37500, 39075, 40275, 41850, 43500, 44625, 46200, 47850, 48975, 50550, 52200, 53775, 54975, 56550, 58125, 59325, 60900, 62475, 63675, 65250, 66900, 68475, 69600, 71250, 72825, 73950, 75600, 77175, 78375, 79950, 81525, 83175, 79950, 64125, 47850, 32100, 
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
                        24000, 85800, 147600, 209400, 271200, 333000, 394800, 456600, 518400, 580200, 642000, 703800, 765600, 827400, 889200, 951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 2836080, 2864160, 2892240, 2920320, 2948400, 2976480, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                },
            },
        },
        {
            type = "reputation",
            id = 2465,
            amount = 1120,
        },
    },
    items = {
        {
            type = "npc",
            id = 158345,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 160045,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 57866,
            x = -2,
        },
        {
            type = "quest",
            id = 57865,
        },
        {
            type = "quest",
            id = 57867,
        },
        {
            type = "npc",
            id = 159427,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 159465,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 159428,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 57868,
            x = -2,
        },
        {
            type = "quest",
            id = 57870,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 57869,
        },
        {
            type = "quest",
            id = 57871,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(SIDE_ACHIEVEMENT_ID, 6), -- Wicked Plan
    questline = 1165,
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
        { -- Most likely
            type = "chain",
            id = Chain.TheFallenTree,
            visible = 87203,
        },
    },
    active = {
        type = "quest",
        ids = {
            58265, 58266, 58264, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 58267,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        8400, 9300, 10200, 10800, 11700, 12600, 13500, 14100, 15000, 15900, 16500, 17400, 18300, 18900, 19800, 20700, 21600, 22200, 23100, 24000, 24600, 25500, 26400, 27000, 27900, 28800, 29700, 30300, 31200, 32100, 32700, 33600, 34500, 35100, 36000, 36900, 37800, 38400, 39300, 40200, 40800, 41700, 42600, 43200, 44100, 45000, 45900, 46500, 47400, 48300, 48900, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        40800, 41700, 42600, 43200, 44100, 45000, 45900, 46500, 47400, 48300, 48900, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        8400, 9300, 10200, 10800, 11700, 12600, 13500, 14100, 15000, 15900, 16500, 17400, 18300, 18900, 19800, 20700, 21600, 22200, 23100, 24000, 24600, 25500, 26400, 27000, 27900, 28800, 29700, 30300, 31200, 32100, 32700, 33600, 34500, 35100, 36000, 36900, 37800, 38400, 39300, 40200, 40800, 41700, 42600, 43200, 44100, 45000, 45900, 46500, 45000, 36000, 27000, 
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
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 1418040, 1432080, 1446120, 1460160, 1474200, 1488240, 1502280, 1516320, 1530360, 1544400, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1404000, 1418040, 1432080, 1446120, 1460160, 1474200, 1488240, 1502280, 1516320, 1530360, 1544400, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 1418040, 1432080, 1446120, 1460160, 1474200, 1488240, 1502280, 
                    },
                    minLevel = 10,
                    maxLevel = 57,
                },
            },
        },
        {
            type = "reputation",
            id = 2465,
            amount = 640,
        },
    },
    items = {
        {
            type = "npc",
            id = 160929,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 160749,
            x = 1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 58265,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 58266,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58264,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58267,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TempChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            name = "Check Requirements",
            aside = true,
        },
        {
            type = "npc",
            id = 174341,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62458,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain15, {
    questline = 1188,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            name = "Check Requirements",
            aside = true,
        },
        {
            type = "npc",
            id = 168032,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62371,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            name = "embed?",
            aside = true,
        },
        {
            type = "item",
            id = 183129,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62259,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            name = "embed?",
            aside = true,
        },
        {
            type = "item",
            id = 183091,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62246,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain01, {
    questline = 1161,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "npc",
            id = 171195,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58024,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "item",
            id = 182730,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62186,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    questline = 1167,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "object",
            id = 348747,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57652,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59623,
            x = 0,
            y = 3,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
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
        { -- Rotbriar Trouble
            type = "quest",
            id = 59600,
        },
        { -- Seed Hunting
            type = "quest",
            id = 59825,
        },
        { -- Seize the Means of Production
            type = "quest",
            id = 60476,
        },
        { -- Terrors in Tirna Scithe
            type = "quest",
            id = 60533,
        },
        { -- Shaking 'Shrooms
            type = "quest",
            id = 60574,
        },
        { -- Spriggan Riot
            type = "quest",
            id = 60585,
        },
        { -- Trouble at the Gormling Corral
            type = "quest",
            id = 60597,
        },
        { -- Who Devours the Devourers?
            type = "quest",
            id = 60609,
        },
        { -- A Thorn In Their Side
            type = "quest",
            id = 60649,
        },
        { -- Tough Crowd
            type = "quest",
            id = 60739,
        },
        { -- Gormageddon
            type = "quest",
            id = 60855,
        },
        { -- A Night in the Woods
            type = "quest",
            id = 60899,
        },
        { -- A Matter of Stealth
            type = "quest",
            id = 60950,
        },
        { -- It's Raining Sparkles
            type = "quest",
            id = 61303,
        },
        { -- Our Heart Will Go On
            type = "quest",
            id = 61411,
        },
        { -- Natural Defenders
            type = "quest",
            id = 61946,
        },
        { -- Lurking In The Shadows
            type = "quest",
            id = 61947,
        },
        { -- Airborne Defense Force
            type = "quest",
            id = 61948,
        },
        { -- Ardenweald's Tricksters
            type = "quest",
            id = 61949,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 3759909,
    items = {
        {
            type = "chain",
            id = Chain.WelcomeToArdenweald,
        },
        {
            type = "chain",
            id = Chain.TranquilPools,
        },
        {
            type = "chain",
            id = Chain.SpiritGlen,
        },
        {
            type = "chain",
            id = Chain.WaningGrove,
        },
        {
            type = "chain",
            id = Chain.GlitterfallHeights,
        },
        {
            type = "chain",
            id = Chain.ThisIsTheWay,
        },
        {
            type = "chain",
            id = Chain.TheFallenTree,
        },
        {
            type = "chain",
            id = Chain.VisionsOfTheDreamer,
        },
        {
            type = "chain",
            id = Chain.AwakenTheDreamer,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.Chain03,
        },
        {
            type = "chain",
            id = Chain.Chain05,
        },
        {
            type = "chain",
            id = Chain.Chain02,
        },
        {
            type = "chain",
            id = Chain.Chain06,
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

Database:AddContinentItems(CONTINENT_ID, {
})
