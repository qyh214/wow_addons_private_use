local L = BtWQuests.L;
local MAP_ID = 862
local ACHIEVEMENT_ID = 11861
local CONTINENT_ID = 875

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
    },
    active = {
        {
            type = "quest",
            id = 47514,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 49663,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                21800, 77935, 134070, 190205, 246340, 302475, 358610, 414745, 470880, 527015, 583150, 639285, 695420, 751555, 807690, 863825, 919960, 976095, 1032230, 1088365, 1144500, 1215140, 1285760, 1356400, 1427020, 1497660, 1568300, 1638920, 1709560, 1780180, 1850820, 1921460, 1992080, 2062720, 2133340, 2203980, 2273300, 2342620, 2411960, 2481280, 2550600, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                13320, 14775, 16090, 17220, 18575, 19890, 21320, 22400, 23690, 25120, 26200, 27630, 28920, 30000, 31430, 32720, 34100, 35230, 36570, 38000, 39050, 40350, 41800, 42850, 44150, 45600, 46950, 48050, 49400, 50750, 51850, 53200, 54550, 55650, 57000, 58450, 59750, 60800, 62300, 63550, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 150,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 1035,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 47514,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 49615,
            x = 3,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 49488,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49489,
            x = 1,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49490,
            x = 3,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49491,
            x = 5,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49492,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49493,
            x = 1,
            y = 5,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49494,
            x = 3,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51663,
            x = 5,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49495,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49905,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49663,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 2)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 47514,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50881,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                16200, 57915, 99630, 141345, 183060, 224775, 266490, 308205, 349920, 391635, 433350, 475065, 516780, 558495, 600210, 641925, 683640, 725355, 767070, 808785, 850500, 902990, 955475, 1007965, 1060450, 1112940, 1165430, 1217915, 1270405, 1322890, 1375380, 1427870, 1480355, 1532845, 1585330, 1637820, 1689335, 1740850, 1792370, 1843885, 1895400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                9280, 10300, 11210, 12030, 12950, 13860, 14880, 15600, 16510, 17530, 18250, 19270, 20180, 20900, 21920, 22830, 23750, 24570, 25480, 26500, 27225, 28125, 29150, 29875, 30775, 31800, 32725, 33525, 34450, 35375, 36175, 37100, 38025, 38825, 39750, 40775, 41675, 42400, 43425, 44325, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 960,
            restrictions = 923,
        },
    },
    items = {
        -- {
        --     type = "quest",
        --     id = 48176,
        --     x = 0,
        --     y = 0,
        --     connections = {
        --         2, 
        --     },
        -- },
        {
            type = "quest",
            id = 50835,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 46846,
            x = 0,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 46926,
            x = 3,
            y = 1,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 46927,
            x = 0,
            y = 2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 46928,
            x = 2,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 46929,
            x = 4,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN13,
            relationship = {
                breadcrumb = 48456,
                blocker = 48452,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 6,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50881,
            x = 2,
            y = 3,
        },
    },
})
-- @TODO does this actually require BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL?
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 3)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
    },
    completed = {
        type = "quest",
        id = 49310,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                18400, 65780, 113160, 160540, 207920, 255300, 302680, 350060, 397440, 444820, 492200, 539580, 586960, 634340, 681720, 729100, 776480, 823860, 871240, 918620, 966000, 1025620, 1085230, 1144850, 1204460, 1264080, 1323700, 1383310, 1442930, 1502540, 1562160, 1621780, 1681390, 1741010, 1800620, 1860240, 1918750, 1977260, 2035780, 2094290, 2152800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10860, 12050, 13120, 14060, 15150, 16220, 17410, 18250, 19320, 20510, 21350, 22540, 23610, 24450, 25640, 26710, 27800, 28740, 29810, 31000, 31850, 32900, 34100, 34950, 36000, 37200, 38300, 39200, 40300, 41400, 42300, 43400, 44500, 45400, 46500, 47700, 48750, 49600, 50800, 51850, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 825,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
            x = 1,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
            x = 3,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
            x = 5,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49122,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49144,
            x = 1,
            y = 2,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 49145,
            x = 3,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 49146,
            x = 5,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49147,
            x = 1,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49148,
            x = 3,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49149,
            x = 5,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49309,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49310,
            x = 3,
            y = 5,
            connections = {
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WEB_OF_LIES, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 4)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
        },
    },
    completed = {
        type = "quest",
        id = 47528,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                24400, 87230, 150060, 212890, 275720, 338550, 401380, 464210, 527040, 589870, 652700, 715530, 778360, 841190, 904020, 966850, 1029680, 1092510, 1155340, 1218170, 1281000, 1360060, 1439110, 1518170, 1597220, 1676280, 1755340, 1834390, 1913450, 1992500, 2071560, 2150620, 2229670, 2308730, 2387780, 2466840, 2544430, 2622020, 2699620, 2777210, 2842080, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14010, 15550, 16920, 18160, 19550, 20920, 22460, 23550, 24920, 26460, 27550, 29090, 30460, 31550, 33090, 34460, 35850, 37090, 38460, 40000, 41100, 42450, 44000, 45100, 46450, 48000, 49400, 50600, 52000, 53400, 54600, 56000, 57400, 58600, 60000, 61550, 62900, 64000, 65550, 66900, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 800,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47509,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47897,
            x = 2,
            y = 2,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 47915,
            x = 4,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47518,
            x = 2,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47520,
            x = 4,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47521,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47522,
            x = 2,
            y = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47963,
            x = 4,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47527,
            x = 6,
            y = 5,
        },
        {
            type = "quest",
            id = 47528,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_MARCH_OF_THE_LOA,
            aside = true,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_AMONG_THE_PEOPLE, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 5)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
        },
    },
    completed = {
        type = "quest",
        id = 47741,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                35600, 127270, 218940, 310610, 402280, 493950, 585620, 677290, 768960, 860630, 952300, 1043970, 1135640, 1227310, 1318980, 1410650, 1502320, 1593990, 1685660, 1777330, 1869000, 1984350, 2099685, 2215035, 2330370, 2445720, 2561070, 2676405, 2791755, 2907090, 3022440, 3137790, 3253125, 3368475, 3483810, 3599160, 3712365, 3825570, 3938790, 4051995, 4152480, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                21890, 24275, 26480, 28290, 30525, 32730, 35090, 36800, 38980, 41340, 43050, 45410, 47590, 49300, 51660, 53840, 56100, 57910, 60140, 62500, 64175, 66375, 68750, 70425, 72625, 75000, 77225, 79025, 81250, 83475, 85275, 87500, 89725, 91525, 93750, 96125, 98325, 100000, 102425, 104575, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 985,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51101,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51680,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 47733,
            x = 0,
            y = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 47739,
            x = 2,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47735,
            x = 4,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50235,
            x = 6,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51677,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47738,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 51678,
            x = 1,
            y = 6,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 51679,
            x = 3,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47742,
            x = 5,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47737,
            x = 3,
            y = 7,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47736,
            x = 2,
            y = 8,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47740,
            x = 4,
            y = 8,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47797,
            aside = true,
            x = 6,
            y = 8,
        },
        {
            type = "quest",
            id = 47734,
            x = 3,
            y = 9,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47741,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_MARCH_OF_THE_LOA,
            aside = true,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 6)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 47514,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        ids = {47439, 47440},
    },
    rewards = {
        {
            type = "money",
            amounts = {
                26200, 93665, 161130, 228595, 296060, 363525, 430990, 498455, 565920, 633385, 700850, 768315, 835780, 903245, 970710, 1038175, 1105640, 1173105, 1240570, 1308035, 1375500, 1460390, 1545275, 1630165, 1715050, 1799940, 1884830, 1969715, 2054605, 2139490, 2224380, 2309270, 2394155, 2479045, 2563930, 2648820, 2732135, 2815450, 2898770, 2982085, 3065400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14180, 15750, 17110, 18430, 19800, 21160, 22730, 23850, 25210, 26780, 27900, 29470, 30830, 31950, 33520, 34880, 36250, 37570, 38930, 40500, 41625, 42975, 44550, 45675, 47025, 48600, 49975, 51275, 52650, 54025, 55325, 56700, 58075, 59375, 60750, 62325, 63675, 64800, 66375, 67725, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 825,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 47445,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47423,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47433,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47434,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47435,
            x = 4,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47437,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47422,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        { -- 47443 for Gonk, 47436 for Pa'ku
            type = "quest",
            id = 47438,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 47439,
            visible = {
                {
                    type = "quest",
                    id = 47443,
                    completed = false,
                },
                {
                    type = "quest",
                    id = 47436,
                    completed = false,
                },
            },
            x = 2,
            y = 7,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47440,
            visible = {
                {
                    type = "quest",
                    id = 47443,
                    completed = false,
                },
                {
                    type = "quest",
                    id = 47436,
                    completed = false,
                },
            },
            x = 4,
            y = 7,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    ids = {47439, 47440},
                    restrictions = {
                        type = "quest",
                        id = 47443,
                    },
                },
                {
                    type = "quest",
                    ids = {47440, 47439},
                    restrictions = {
                        type = "quest",
                        id = 47436,
                    },
                },
                {
                    name = L["PICK_A_LOA"],
                    visible = false,
                },
            },
            x = 3,
            y = 7,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {47432, 48897},
            aside = true,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_MARCH_OF_THE_LOA, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 7)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WEB_OF_LIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_AMONG_THE_PEOPLE,
        },
    },
    completed = {
        type = "quest",
        id = 49426,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                22400, 80080, 137760, 195440, 253120, 310800, 368480, 426160, 483840, 541520, 599200, 656880, 714560, 772240, 829920, 887600, 945280, 1002960, 1060640, 1118320, 1176000, 1248580, 1321150, 1393730, 1466300, 1538880, 1611460, 1684030, 1756610, 1829180, 1901760, 1974340, 2046910, 2119490, 2192060, 2264640, 2335870, 2407100, 2478340, 2549570, 2620800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                16660, 18250, 19820, 21360, 22950, 24670, 26260, 27650, 29370, 30960, 32500, 34090, 35660, 37200, 38790, 40510, 42100, 43490, 45210, 46800, 48400, 49950, 51550, 53100, 54650, 56400, 58000, 59350, 61100, 62700, 64200, 65800, 67400, 68900, 70500, 72250, 73800, 75200, 76950, 78500, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 675,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 1235,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WEB_OF_LIES,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_AMONG_THE_PEOPLE,
            x = 4,
            y = 0,
            connections = {
                1, 
            },
        },


        {
            variations = {
                {
                    type = "quest",
                    id = 51111,
                    breadcrumb = true,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "quest",
                    id = 50433,
                    breadcrumb = true,
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
            id = 49421,
            breadcrumb = true,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49965,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49422,
            x = 2,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49424,
            x = 4,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49425,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49426,
            x = 3,
            y = 6,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49901,
            aside = true,
            x = 2,
            y = 7,
        },
        {
            type = "quest",
            id = 50963,
            aside = true,
            x = 4,
            y = 7,
        },
    },
})
-- Completed, horde only, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN10, {
    name = { -- Curse of Jani
        type = "quest",
        id = 47442,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 47441,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 47442,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                2800, 3100, 3400, 3600, 3900, 4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 300,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 127665,
            -- name = "Go to Nokano",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1165, 0.402648, 0.190583, "Nokano")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47441,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47442,
            x = 3,
            y = 2,
        },
    },
})
-- Completed, both factions, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN11, {
    name = { -- Hunting the Hunter
        type = "quest",
        id = 47586,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49768,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47583,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47584,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50466,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47585,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 47587,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                28200, 100815, 173430, 246045, 318660, 391275, 463890, 536505, 609120, 681735, 754350, 826965, 899580, 972195, 1044810, 1117425, 1190040, 1262655, 1335270, 1407885, 1480500, 1571870, 1663235, 1754605, 1845970, 1937340, 2028710, 2120075, 2211445, 2302810, 2394180, 2485550, 2576915, 2668285, 2759650, 2851020, 2940695, 3030370, 3120050, 3209725, 3286680, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                15580, 17300, 18810, 20230, 21750, 23260, 24980, 26200, 27710, 29430, 30650, 32370, 33880, 35100, 36820, 38330, 39850, 41270, 42780, 44500, 45725, 47225, 48950, 50175, 51675, 53400, 54925, 56325, 57850, 59375, 60775, 62300, 63825, 65225, 66750, 68475, 69975, 71200, 72925, 74425, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 500,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 500,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 123022,
            -- name = "Go to Tracker Burke",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.675628, 0.177215, "Tracker Burke")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49768,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 0,
            y = 0,
            connections = {
                5,
            },
        },
        {
            type = "npc",
            id = 123026,
            -- name = "Go to Erak the Aloof",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.674482, 0.177204, "Erak the Aloof")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49768,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 2,
            y = 0,
            connections = {
                5,
            },
        },
        {
            type = "npc",
            id = 123005,
            -- name = "Go to Hemet Nesingwary",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.675029, 0.177058, "Hemet Nesingwary")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49768,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 4,
            y = 0,
            connections = {
                5,
            },
        },
        {
            type = "npc",
            id = 123118,
            -- name = "Go to Trapper Custer",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.688548, 0.194381, "Trapper Custer")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49768,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 6,
            y = 0,
            connections = {
                5,
            },
        },

        {
            type = "quest",
            id = 49768,
            visible = BtWQuestsItem_ActiveOrCompleted,
            x = 3,
            y = 0,
            connections = {
                2, 3, 4,
            },
        },



        {
            type = "quest",
            id = 47583,
            x = 0,
            y = 1,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 47584,
            x = 2,
            y = 1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 50466,
            x = 4,
            y = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47585,
            x = 6,
            y = 1,
            connections = {
                2,
            },
        },


        {
            type = "object",
            id = 271706,
            -- name = "Go to the Hunters' Board",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.674402, 0.179215, "Hunters' Board")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 1,
            y = 2,
            connections = {
                3, 4,
            },
        },


        {
            type = "quest",
            id = 47586,
            x = 3,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50178,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            aside = true,
            x = 5,
            y = 2,
        },


        {
            type = "quest",
            id = 47706,
            aside = true,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 51091,
            aside = true,
            x = 2,
            y = 3,
        },
        {
            type = "quest",
            id = 47587,
            x = 4,
            y = 3,
        },
    },
})
-- Completed, horde only, has requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN9, {
    name = { -- Hope's Blue Light
        type = "quest",
        id = 49884,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
        },
    },
    active = {
        {
            type = "quest",
            id = 52210,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49758,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 49884,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                16200, 57915, 99630, 141345, 183060, 224775, 266490, 308205, 349920, 391635, 433350, 475065, 516780, 558495, 600210, 641925, 683640, 725355, 767070, 808785, 850500, 902990, 955475, 1007965, 1060450, 1112940, 1165430, 1217915, 1270405, 1322890, 1375380, 1427870, 1480355, 1532845, 1585330, 1637820, 1689335, 1740850, 1792370, 1843885, 1895400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                8230, 9150, 9910, 10730, 11500, 12260, 13180, 13850, 14610, 15530, 16200, 17120, 17880, 18550, 19470, 20230, 21000, 21820, 22580, 23500, 24175, 24925, 25850, 26525, 27275, 28200, 28975, 29775, 30550, 31325, 32125, 32900, 33675, 34475, 35250, 36175, 36925, 37600, 38525, 39275, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 925,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 52210,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 140590,
                    -- name = "Go to Captain Grez'ko",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(1165, 0.461302, 0.945733, "Captain Grez'ko")
                    -- end,
                    -- breadcrumb = true,
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
            id = 49758,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49775,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49754,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49871,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49785,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49884,
            x = 3,
            y = 7,
        },
    },
})
-- Completed, Both factions, no requirements, 1 breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN15, {
    name = { -- Word from the Deep
        type = "quest",
        id = 51538,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50331,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48014,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51538,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                12400, 44330, 76260, 108190, 140120, 172050, 203980, 235910, 267840, 299770, 331700, 363630, 395560, 427490, 459420, 491350, 523280, 555210, 587140, 619070, 651000, 691180, 731350, 771530, 811700, 851880, 892060, 932230, 972410, 1012580, 1052760, 1092940, 1133110, 1173290, 1213460, 1253640, 1293070, 1332500, 1371940, 1411370, 1450800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                7710, 8550, 9320, 9960, 10750, 11520, 12360, 12950, 13720, 14560, 15150, 15990, 16760, 17350, 18190, 18960, 19750, 20390, 21160, 22000, 22600, 23350, 24200, 24800, 25550, 26400, 27200, 27800, 28600, 29400, 30000, 30800, 31600, 32200, 33000, 33850, 34600, 35200, 36050, 36800, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 460,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50331,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 125047,
                    -- name = "Go to Rokor",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(1165, 0.577624, 0.923117, "Rokor")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48014,
            x = 2,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 48015,
            x = 4,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48025,
            aside = true,
            x = 2,
            y = 2,
        },
        {
            type = "quest",
            id = 49969,
            x = 4,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48026,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51538,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51539,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            aside = true,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, alliance only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN5_ALLIANCE, {
    name = { -- Gorilla Warfare
        type = "quest",
        id = 53452,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 53449,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 53453,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 53450,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 53452,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 53453,
        },
        {
            type = "quest",
            id = 53450,
        },
        {
            type = "quest",
            id = 53452,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                4550, 5050, 5500, 5900, 6350, 6800, 7300, 7650, 8100, 8600, 8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20450, 20800, 21300, 21750, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 300,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 53449,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 143787,
                    -- name = "Go to Flap-Flap",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.515185, 0.529641, "Flap-Flap")
                    -- end,
                    -- breadcrumb = true,
                }
            },
            x = 2,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "npc",
            id = 143792,
            -- name = "Go to Tsunga",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.501715, 0.545688, "Tsunga")
            -- end,
            -- breadcrumb = true,
            x = 5,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 53453,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 53450,
            x = 3,
            y = 1,
        },
        {
            type = "quest",
            id = 53452,
            x = 5,
            y = 1,
        },
    },
})
-- Seems like it requires same as BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_MARCH_OF_THE_LOA but
-- that doesnt make sense with the context of the quests
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN8, {
    name = BtWQuests_GetAreaName(9716), -- The Forward Guard
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WEB_OF_LIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_AMONG_THE_PEOPLE,
        },
    },
    active = {
        {
            type = "quest",
            id = 51555,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51286,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                10200, 36465, 62730, 88995, 115260, 141525, 167790, 194055, 220320, 246585, 272850, 299115, 325380, 351645, 377910, 404175, 430440, 456705, 482970, 509235, 535500, 568550, 601595, 634645, 667690, 700740, 733790, 766835, 799885, 832930, 865980, 899030, 932075, 965125, 998170, 1031220, 1063655, 1096090, 1128530, 1160965, 1193400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                7180, 7950, 8710, 9230, 10000, 10760, 11530, 12050, 12810, 13580, 14100, 14870, 15630, 16150, 16920, 17680, 18450, 18970, 19730, 20500, 21025, 21775, 22550, 23075, 23825, 24600, 25375, 25875, 26650, 27425, 27925, 28700, 29475, 29975, 30750, 31525, 32275, 32800, 33575, 34325, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 375,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WEB_OF_LIES,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_AMONG_THE_PEOPLE,
            x = 4,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 141555,
            -- name = "Go to Baine Bloodhoof",
            -- breadcrumb = true,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51555,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 51248,
            aside = true,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 51246,
            x = 2,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51247,
            x = 4,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51249,
            aside = true,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 51286,
            x = 3,
            y = 4,
        },
    },
})
-- Completed, horde only, No requirements, no breadcrumbs, maybe connect to Who Seeks the Seekers?
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN12, {
    name = BtWQuests_GetAreaName(9355), -- Little Tortolla
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 52472,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48404,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 52472,
        },
        {
            type = "quest",
            id = 48405,
        }
    },
    rewards = {
        {
            type = "money",
            amounts = {
                6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                3150, 3500, 3800, 4100, 4400, 4700, 5050, 5300, 5600, 5950, 6200, 6550, 6850, 7100, 7450, 7750, 8050, 8350, 8650, 9000, 9250, 9550, 9900, 10150, 10450, 10800, 11100, 11400, 11700, 12000, 12300, 12600, 12900, 13200, 13500, 13850, 14150, 14400, 14750, 15050, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 125,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 225,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 300,
        },
    },
    items = {
        {
            type = "npc",
            id = 134346,
            -- name = "Go to Toki",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1165, 0.561589, 0.915987, "Toki")
            -- end,
            -- breadcrumb = true,
            x = 2,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 125312,
            -- name = "Go to Scrollsage Rooka",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1165, 0.559519, 0.888351, "Scrollsage Rooka")
            -- end,
            -- breadcrumb = true,
            x = 4,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52472,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 48404,
            x = 4,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48405,
            x = 4,
            y = 2,
        },
    },
})
-- Completed, horde only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN13, {
    name = { -- Witch Doctor Jala
        type = "quest",
        id = 48456,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48456,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48452,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 48454,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2200, 7865, 13530, 19195, 24860, 30525, 36190, 41855, 47520, 53185, 58850, 64515, 70180, 75845, 81510, 87175, 92840, 98505, 104170, 109835, 115500, 122630, 129755, 136885, 144010, 151140, 158270, 165395, 172525, 179650, 186780, 193910, 201035, 208165, 215290, 222420, 229415, 236410, 243410, 250405, 257400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                1580, 1750, 1910, 2030, 2200, 2360, 2530, 2650, 2810, 2980, 3100, 3270, 3430, 3550, 3720, 3880, 4050, 4170, 4330, 4500, 4625, 4775, 4950, 5075, 5225, 5400, 5575, 5675, 5850, 6025, 6125, 6300, 6475, 6575, 6750, 6925, 7075, 7200, 7375, 7525, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 100,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 48456,
                    restrictions = BtWQuestsItem_ActiveOrCompleted
                },
                {
                    type = "npc",
                    id = 126148,
                    -- name = "Go to Witch Doctor Jala",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(1165, 0.442453, 0.821521, "Witch Doctor Jala")
                    -- end,
                    -- breadcrumb = true,
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
            id = 48452,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48454,
            x = 3,
            y = 2,
        },
    },
})
-- Alliance only, Unknown requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN6_ALLIANCE, {
    name = { -- The Thrill of Exploration
        type = "quest",
        id = 49276,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49059,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49276,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51085,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 49428,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                20000, 71500, 123000, 174500, 226000, 277500, 329000, 380500, 432000, 483500, 535000, 586500, 638000, 689500, 741000, 792500, 844000, 895500, 947000, 998500, 1050000, 1114800, 1179600, 1244400, 1309200, 1374000, 1438800, 1503600, 1568400, 1633200, 1698000, 1762800, 1827600, 1892400, 1957200, 2022000, 2085600, 2149200, 2212800, 2276400, 2340000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10850, 12050, 13100, 14100, 15150, 16200, 17350, 18300, 19300, 20450, 21400, 22550, 23550, 24500, 25650, 26650, 27750, 28750, 29850, 31000, 31850, 32950, 34100, 34950, 36050, 37200, 38200, 39300, 40300, 41300, 42400, 43400, 44400, 45500, 46500, 47650, 48750, 49600, 50850, 51850, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 875,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 49059,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 131777,
                    -- name = "Go to Acadia Chistlestone",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.413323, 0.714221, "Acadia Chistlestone")
                    -- end,
                    -- breadcrumb = true,
                }
            },
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "object",
            id = 287228,
            -- name = "Go to Wanted Sign",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.407947, 0.711349, "Wanted Sign")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 5,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49276,
            x = 3,
            y = 1,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 51085,
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 49274,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50044,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49060,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49282,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49428,
            x = 2,
            y = 4,
        },
        {
            type = "quest",
            id = 49427,
            aside = true,
            x = 4,
            y = 4,
        },
    },
})
-- Completed, both factions, Has no requirements, 1 breadcrumb, breadcrumb requires BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI though
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN3, {
    name = { -- Who seeks the seekers
        type = "quest",
        id = 49283,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49284,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49285,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49315,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51407,
    },
    rewards = {
        {
            type = "toy",
            id = 156871,
        },
        {
            type = "money",
            amounts = {
                19900, 71145, 122385, 173630, 224870, 276115, 327355, 378600, 429840, 481085, 532325, 583570, 634810, 686055, 737295, 788540, 839780, 891025, 942265, 993510, 1044750, 1109230, 1173700, 1238180, 1302650, 1367130, 1431610, 1496080, 1560560, 1625030, 1689510, 1753990, 1818460, 1882940, 1947410, 2011890, 2075170, 2138450, 2201740, 2265020, 2315580, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                12260, 13600, 14820, 15860, 17100, 18320, 19660, 20600, 21820, 23160, 24100, 25440, 26660, 27600, 28940, 30160, 31400, 32440, 33660, 35000, 35950, 37150, 38500, 39450, 40650, 42000, 43250, 44250, 45500, 46750, 47750, 49000, 50250, 51250, 52500, 53850, 55050, 56000, 57350, 58550, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 610,
        },
    },
    items = {
        {
            type = "npc",
            id = 129586,
            -- name = "Go to Batu",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.7070, 0.6530, "Batu")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49283,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 2,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "npc",
            id = 128888,
            -- name = "Go to Koba",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.702984, 0.650605, "Koba")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49283,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 4,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 49283,
            visible = BtWQuestsItem_ActiveOrCompleted,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49284,
            x = 2,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 49285,
            x = 4,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49315,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            aside = true,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 49286,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49287,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49288,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49289,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51407,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN15,
            aside = true,
            relationship = {
                breadcrumb = 50331,
                blockers = {48014, 48015},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 3,
            y = 6,
        },
    },
})
-- Completed, horde only, requries BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN6_HORDE, {
    name = { -- The Bloodwatcher Legacy
        type = "quest",
        id = 47329,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
        },
    },
    active = {
        {
            type = "quest",
            id = 47257,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47329,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51087,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 48399,
        },
        {
            type = "quest",
            id = 48400,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                19000, 67925, 116850, 165775, 214700, 263625, 312550, 361475, 410400, 459325, 508250, 557175, 606100, 655025, 703950, 752875, 801800, 850725, 899650, 948575, 997500, 1059060, 1120620, 1182180, 1243740, 1305300, 1366860, 1428420, 1489980, 1551540, 1613100, 1674660, 1736220, 1797780, 1859340, 1920900, 1981320, 2041740, 2102160, 2162580, 2223000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                11200, 12425, 13550, 14500, 15625, 16750, 17950, 18850, 19950, 21150, 22050, 23250, 24350, 25250, 26450, 27550, 28700, 29650, 30800, 32000, 32850, 34000, 35200, 36050, 37200, 38400, 39500, 40500, 41600, 42700, 43700, 44800, 45900, 46900, 48000, 49200, 50350, 51200, 52450, 53550, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 820,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 47257,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 131582,
                    -- name = "Go to Examiner Tae'shara Bloodwatcher",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.439119, 0.721078, "Examiner Tae'shara Bloodwatcher")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "object",
            id = 287229,
            -- name = "Go to the Wanted Sign",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.443004, 0.721670, "Wanted Sign")
            -- end,
            -- breadcrumb = true,
            x = 6,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47329,
            x = 3,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 51087,
            x = 6,
            y = 2,
        },
        {
            type = "quest",
            id = 47235,
            x = 1,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50043,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47228,
            x = 5,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48317,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48399,
            x = 2,
            y = 5,
        },
        {
            type = "quest",
            id = 48400,
            x = 4,
            y = 5,
        },
    },
})
-- Completed, horde only, no requirements, no breadcrumbs?
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN14, {
    name =  { -- Aggressive Mating Strategy
        type = "quest",
        id = 49801,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49810,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50297,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                16700, 59705, 102705, 145710, 188710, 231715, 274715, 317720, 360720, 403725, 446725, 489730, 532730, 575735, 618735, 661740, 704740, 747745, 790745, 833750, 876750, 930860, 984965, 1039075, 1093180, 1147290, 1201400, 1255505, 1309615, 1363720, 1417830, 1471940, 1526045, 1580155, 1634260, 1688370, 1741475, 1794580, 1847690, 1900795, 1953900, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10690, 11840, 12930, 13790, 14890, 15985, 17080, 18000, 19035, 20130, 21050, 22145, 23180, 24100, 25195, 26230, 27400, 28245, 29380, 30500, 31325, 32425, 33550, 34375, 35475, 36600, 37675, 38575, 39650, 40725, 41625, 42700, 43775, 44675, 45750, 46875, 47975, 48800, 50025, 51025, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 1250,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 130929,
            -- name = "Go to Witch Doctor Jangalar",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.641294, 0.353786, "Witch Doctor Jangalar")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49810,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49814,
            x = 1,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50154,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49801,
            x = 5,
            y = 2,
            connections = {
                2, 
            },
        },

        {
            type = "quest",
            id = 50150,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50074,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50252,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50268,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49870,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50297,
            x = 3,
            y = 7,
        },
    },
})
-- Completed, horde only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN5_HORDE, {
    name =  { -- Gorilla Warfare
        type = "quest",
        id = 49920,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49920,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49919,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49922,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49918,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 49920,
        },
        {
            type = "quest",
            id = 49919,
        },
        {
            type = "quest",
            id = 49922,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1391280, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                7350, 8150, 8900, 9500, 10250, 11000, 11800, 12350, 13100, 13900, 14450, 15250, 16000, 16550, 17350, 18100, 18850, 19450, 20200, 21000, 21550, 22300, 23100, 23650, 24400, 25200, 25950, 26550, 27300, 28050, 28650, 29400, 30150, 30750, 31500, 32300, 33050, 33600, 34400, 35150, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 375,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 130947,
            -- name = "Go to Tsunga",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.501715, 0.545688, "Tsunga")
            -- end,
            -- breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49917,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 132617,
                    -- name = "Go to Bently Greaseflare",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.516049, 0.505771, "Bently Greaseflare")
                    -- end,
                    -- breadcrumb = true,
                }
            },
            x = 3,
            y = 0,
            connections = {
                2, 3,
            },
        },
        
        {
            type = "quest",
            id = 49920,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 49919,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 49922,
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            id = 49918,
            aside = true,
            x = 6,
            y = 1,
        },
    },
})
-- Completed, horde only, no requirements, 1 breadcrumb
BtWQuestsCharacters:AddFriendshipReputation(2370)
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN4, {
    name = { -- How to Train Your Direhorn
        type = "achievement",
        id = 13542,
    },
    -- name = { -- The Orphaned Hatchling
    --     type = "quest",
    --     id = 47226,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50538,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47226,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 55798,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                3025800, 3104595, 3183390, 3262185, 3340980, 3419775, 3498570, 3577365, 3656160, 3734955, 3813750, 3892545, 3971340, 4050135, 4128930, 4207725, 4286520, 4365315, 4444110, 4522905, 4601700, 4700850, 4799985, 4899135, 4998270, 5097420, 5196570, 5295705, 5394855, 5493990, 5593140, 5692290, 5791425, 5890575, 5989710, 6088860, 6186165, 6283470, 6380790, 6478095, 6575400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                16340, 18100, 19680, 21140, 22750, 24330, 26090, 27400, 28980, 30740, 32050, 33810, 35390, 36700, 38460, 40040, 41650, 43110, 44690, 46450, 47825, 49375, 51150, 52475, 54025, 55800, 57425, 58825, 60450, 62075, 63475, 65100, 66725, 68125, 69750, 71525, 73075, 74400, 76175, 77725, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 1150,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50538,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 122939,
                    -- name = "Go to Direhorn Hatchling",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.643344, 0.447053, "Direhorn Hatchling")
                    -- end,
                    -- breadcrumb = true,
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
            id = 47226,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 47259,
            x = 2,
            y = 2,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 48527,
            x = 4,
            y = 2,
            connections = {
                2, 3,
            },
        },

        
        {
            type = "quest",
            id = 47312,
            x = 0,
            y = 3,
            connections = {
                4, 5,
            },
        },
        {
            type = "quest",
            id = 47311,
            x = 2,
            y = 3,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 47272,
            x = 4,
            y = 3,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 51980,
            aside = true,
            x = 6,
            y = 3,
        },


        {
            type = "quest",
            id = 51998,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51990,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },

        {
            type = "quest",
            id = 47418,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47261,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48581,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47310,
            x = 3,
            y = 8,
            connections = {
                2,
            },
        },

        --@TODO put in daily? cooldown marker
        {
            type = "level",
            level = 50,
            x = 5,
            y = 8.5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47260,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52855,
            x = 3,
            connections = {
                1,
            },
        },
        { -- Also completed 55257, which may be a daily quest preventing the next part from being available
            type = "quest",
            id = 52857,
            x = 3,
            connections = {
                1, 
            },
        },

        --@TODO put in daily? cooldown marker

        {
            type = "quest",
            id = 55254,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55252,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55253,
            x = 3,
            connections = {
                1, 
            },
        },
        { -- Also completes 55259, probably daily quest for next part of the chain
            type = "quest",
            id = 55258,
            x = 3,
            connections = {
                1,
            },
        },

        -- { -- Daily quest, also marked 55494 as completed
        --     type = "quest",
        --     id = 55250,
        --     x = 2,
        -- },
        -- { -- Daily quest, also marked 55494 as completed, got as the 5th daily quest
        --     type = "quest",
        --     id = 55249,
        -- },
        -- { -- Daily quest
        --     type = "quest",
        --     id = 55251,
        -- },

        -- GetFriendshipReputation(2370)
        -- Rank 1: Hatchling
        -- Rank 2: Juvenile
        -- Rank 3: Maturity
        {
            name = L["RAISE_YOUR_DIREHORN_TO_A_JUVENILE"],
            type = "friendship",
            id = 2370,
            amount = 4000,
            active = {
                type = "quest",
                id = 55258,
            },
            x = 3,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            visible = {
                {
                    type = "friendship",
                    id = 2370,
                    amount = 4000,
                },
                {
                    type = "quest",
                    id = 55462,
                    status = {'notcompleted'},
                }
            },
            active = {
                type = "quest",
                id = 55494,
            },
            completed = {
                type = "quest",
                id = 55494,
                status = {'notcompleted'},
            },
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55462,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55504,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55503,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55506,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55505,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55507,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            name = L["RAISE_YOUR_DIREHORN_TO_MATURITY"],
            type = "friendship",
            id = 2370,
            amount = 8000,
            active = {
                type = "quest",
                id = 55507,
            },
            x = 3,
            connections = {
                1, 
            },
        },
        -- {
        --     name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
        --     visible = {
        --         {
        --             type = "friendship",
        --             id = 2370,
        --             amount = 8000,
        --         },
        --         {
        --             type = "quest",
        --             id = 55247,
        --             status = {'notcompleted'},
        --         }
        --     },
        --     active = {
        --         type = "quest",
        --         id = 55494,
        --     },
        --     completed = {
        --         type = "quest",
        --         id = 55494,
        --         status = {'nocompleted'},
        --     },
        --     x = 1,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 55247,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55795,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55796,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55797,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 55798,
            x = 3,
        },
    },
})
-- Completed, Horde only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN7, {
    name = { -- Sandscar Breach
        type = "quest",
        id = 49940,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49940,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49678,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49680,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49679,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49681,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 49678,
        },
        {
            type = "quest",
            id = 49680,
        },
        {
            type = "quest",
            id = 49679,
        },
        {
            type = "quest",
            id = 49681,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                10200, 36465, 62730, 88995, 115260, 141525, 167790, 194055, 220320, 246585, 272850, 299115, 325380, 351645, 377910, 404175, 430440, 456705, 482970, 509235, 535500, 568550, 601595, 634645, 667690, 700740, 733790, 766835, 799885, 832930, 865980, 899030, 932075, 965125, 998170, 1031220, 1063655, 1096090, 1128530, 1160965, 1193400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                6130, 6800, 7410, 7930, 8550, 9160, 9830, 10300, 10910, 11580, 12050, 12720, 13330, 13800, 14470, 15080, 15700, 16220, 16830, 17500, 17975, 18575, 19250, 19725, 20325, 21000, 21625, 22125, 22750, 23375, 23875, 24500, 25125, 25625, 26250, 26925, 27525, 28000, 28675, 29275, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 710,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 130450,
            -- name = "Go to Bladeguard Sonji",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.472488, 0.249500, "Bladeguard Sonji")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49940,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 0,
            y = 0,
            connections = {
                4, 5,
            },
        },
        {
            type = "npc",
            id = 131354,
            -- name = "Go to Beastmother Jabati",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.473304, 0.251454, "Beastmother Jabati")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49940,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 3,
            y = 0,
            connections = {
                5,
            },
        },
        {
            type = "npc",
            id = 130468,
            -- name = "Go to Lil' Tika",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.462368, 0.233301, "Lil' Tika")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 49940,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 6,
            y = 0,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 49940,
            visible = BtWQuestsItem_ActiveOrCompleted,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 49678,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 49680,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 49679,
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            id = 49681,
            x = 6,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    items = {
        {
            type = "quest",
            id = 50796,
        },
        {
            type = "quest",
            id = 52305,
        },
        {
            type = "quest",
            id = 50801,
        },
        {
            type = "quest",
            id = 49766,
        },
        {
            type = "quest",
            id = 49767,
        },
        {
            type = "quest",
            id = 50393,
        },
        {
            type = "quest",
            id = 50394,
        },
        {
            type = "quest",
            id = 50395,
        },
        {
            type = "quest",
            id = 50396,
        },
        {
            type = "quest",
            id = 50397,
        },
        {
            type = "quest",
            id = 50401,
        },
        {
            type = "quest",
            id = 50412,
        },
        { -- Emissary
            type = "quest",
            id = 50606,
        },
        {
            type = "quest",
            id = 50791,
        },
        {
            type = "quest",
            id = 50798,
        },
        {
            type = "quest",
            id = 50838,
        },
        {
            type = "quest",
            id = 50839,
        },
        {
            type = "quest",
            id = 50841,
        },
        {
            type = "quest",
            id = 50842,
        },
        {
            type = "quest",
            id = 50860,
        },
        {
            type = "quest",
            id = 50886,
        },
        {
            type = "quest",
            id = 50900,
        },
        {
            type = "quest",
            id = 50930,
        },
        {
            type = "quest",
            id = 50940,
        },
        {
            type = "quest",
            id = 50942,
        },
        {
            type = "quest",
            id = 50943,
        },
        {
            type = "quest",
            id = 50944,
        },
        {
            type = "quest",
            id = 51146,
        },
        {
            type = "quest",
            id = 51147,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    items = {
        {
            type = "quest",
            id = 50332,
        },
        {
            type = "quest",
            id = 51069,
        },
        {
            type = "quest",
            id = 50240,
        },
        {
            type = "quest",
            id = 51071,
        },
        {
            type = "quest",
            id = 52748,
        },
        {
            type = "quest",
            id = 52317,
        },
        {
            type = "quest",
            id = 50402,
        },
        {
            type = "quest",
            id = 52447,
        },
        {
            type = "quest",
            id = 53336,
        },
        {
            type = "quest",
            id = 53337,
        },
        {
            type = "quest",
            id = 50598,
        },
        {
            type = "quest",
            id = 50381,
        },
        {
            type = "quest",
            id = 50887,
        },
        {
            type = "quest",
            id = 51072,
        },
        {
            type = "quest",
            id = 49769,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 1778892,
    listImage = {
        texture = "Interface\\Addons\\BtWQuestsBattleForAzeroth\\UI-CategoryButton",
        texCoords = {0, 0.7353515625, 0.46875, 0.5859375},
    },
    items = {
        {
            type = "header",
            name = L["BTWQUESTS_THE_WAR_CAMPAIGN"],
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_A_GOLDEN_OPPORTUNITY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_THE_STRIKE_ON_ZULDAZAR,
        },


        {
            type = "header",
            name = {
                type = "achievement",
                id = ACHIEVEMENT_ID,
            },
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORTENTS_AND_PROPHECIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_PORT_OF_ZANDALAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WARPORT_RASTARI,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_WEB_OF_LIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_AMONG_THE_PEOPLE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_THE_ZANCHULI_COUNCIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_MARCH_OF_THE_LOA,
        },


        {
            type = "header",
            name = L["BTWQUESTS_SIDE_QUESTS"],
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN4,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN5_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN5_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN6_HORDE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN6_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN9,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN11,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN13,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN14,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN15,
        },


        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN3,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN31,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_OTHER_ALLIANCE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_OTHER_HORDE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_OTHER_BOTH,
        -- },
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
}, true)

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN3,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN4,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN5_HORDE,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN5_ALLIANCE,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN6_HORDE,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN6_ALLIANCE,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN7,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN8,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN9,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN10,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN11,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN12,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN13,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN14,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ZULDAZAR_CHAIN15,
    },
})