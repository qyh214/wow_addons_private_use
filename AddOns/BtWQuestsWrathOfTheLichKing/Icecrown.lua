-- AUTO GENERATED - NEEDS UPDATING

local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.Icecrown
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.Icecrown
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 118
local CONTINENT_ID = 113
local ACHIEVEMENT_ID = 40
local LEVEL_RANGE = {25, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 25,
    },
}

Chain.CrusaderBridenbrad = 30801
Chain.TheUnthinkable = 30802
Chain.TeachingTheMeaningOfFear = 30803
Chain.TheHeartOfTheLichKingAlliance = 30804
Chain.TheHeartOfTheLichKingHorde = 30805
Chain.WhatsYoursIsMine01 = 30806
Chain.WhatsYoursIsMine02 = 30807
Chain.SeizingSaronite = 30808
Chain.MalykrissTheVileHold = 30809
Chain.InDefianceOfTheScourge = 30810
Chain.MordretharTheDeathGate01 = 30811
Chain.MordretharTheDeathGate02 = 30812
Chain.AldurtharTheDesolationGate01 = 30813
Chain.AldurtharTheDesolationGate02 = 30814
Chain.CorpretharTheHorrorGate01 = 30815
Chain.CorpretharTheHorrorGate02 = 30816

Chain.Chain01 = 30821
Chain.Chain02 = 30822

Chain.TempChain22 = 30831
Chain.TempChain30 = 30832
Chain.TempChain31 = 30833
Chain.TempChain32 = 30834
Chain.TempChain33 = 30835
Chain.TempChain34 = 30836
Chain.TempChain36 = 30837
Chain.TempChain43 = 30838

Chain.OtherAlliance = 30897
Chain.OtherHorde = 30898
Chain.OtherBoth = 30899

Database:AddChain(Chain.CrusaderBridenbrad, {
    name = L["CRUSADER_BRIDENBRAD"],
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
            id = Chain.InDefianceOfTheScourge,
            upto = 13141,
        },
    },
    active = {
        type = "quest",
        id = 13068,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13083,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        34940, 36400, 37560, 38990, 40450, 41675, 43075, 44550, 45725, 47125, 48600, 50075, 51175, 52650, 54125, 55225, 56700, 58175, 59275, 60750, 62225, 63625, 64800, 66275, 67675, 8555, 8555, 6805, 5110, 3410, 1720, 865, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        34940, 36400, 37560, 38990, 40450, 41675, 41675, 33330, 24880, 16730, 8375, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 4165, 460, 
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
                        915345, 974820, 1034310, 1093785, 1153275, 1212750, 1287600, 1362435, 1437285, 1512120, 1586970, 1661820, 1736655, 1811505, 1886340, 1961190, 2036040, 2110875, 2185725, 2260560, 2335410, 2408865, 2482320, 2555790, 2629245, 2702700, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        915345, 974820, 1034310, 1093785, 1153275, 1212750, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1106,
            amount = 1980,
        },
    },
    items = {
        {
            type = "npc",
            id = 31044,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13068,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13072,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13073,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13074,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13075,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13076,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13077,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13078,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13079,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13080,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13081,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13082,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13083,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheUnthinkable, {
    name = L["THE_UNTHINKABLE"],
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
            id = Chain.WhatsYoursIsMine01,
        },
        {
            type = "chain",
            id = Chain.WhatsYoursIsMine02,
        },
    },
    active = {
        type = "quest",
        id = 12938,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13219,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        70940, 73750, 76410, 79190, 82150, 85025, 87775, 90750, 93275, 96025, 99000, 101825, 104425, 107250, 110075, 112675, 115500, 118325, 120925, 123750, 126725, 129475, 132000, 134975, 137725, 17330, 17330, 13855, 10495, 6920, 3460, 1780, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        70940, 73750, 76410, 79190, 82150, 85025, 85025, 67980, 50830, 33830, 17150, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 8560, 940, 
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
                        2623175, 2793640, 2964105, 3134570, 3305035, 3475500, 3689990, 3904475, 4118965, 4333450, 4547940, 4762430, 4976915, 5191405, 5405890, 5620380, 5834870, 6049355, 6263845, 6478330, 6692820, 6903335, 7113850, 7324370, 7534885, 7745400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2623175, 2793640, 2964105, 3134570, 3305035, 3475500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 3070,
        },
    },
    items = {
        {
            type = "npc",
            id = 29343,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12938,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12955,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12999,
            x = 0,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "npc",
            id = 30406,
            x = 3,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 13042,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 13092,
            aside = true,
        },
        {
            type = "quest",
            id = 13043,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13059,
            aside = true
        },
        {
            type = "quest",
            id = 13091,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13121,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13137,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13142,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13213,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13214,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13215,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13216,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13218,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13219,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TeachingTheMeaningOfFear, {
    name = L["TEACHING_THE_MEANING_OF_FEAR"],
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
            id = Chain.WhatsYoursIsMine01,
            upto = 12896,
        },
        {
            type = "chain",
            id = Chain.WhatsYoursIsMine02,
            upto = 12897,
        },
    },
    active = {
        type = "quest",
        ids = {
            13106, 13117, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13235,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        48300, 50350, 51850, 53900, 56000, 57450, 59500, 61600, 63050, 65100, 67200, 69250, 70750, 72800, 74850, 76350, 78400, 80450, 81950, 84000, 86100, 88150, 89600, 91700, 93750, 11875, 11875, 9450, 7005, 4750, 2380, 1195, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        48300, 50350, 51850, 53900, 56000, 57450, 57450, 46150, 34350, 23100, 11575, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 5755, 630, 
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
                        1168940, 1244900, 1320865, 1396825, 1472790, 1548750, 1644330, 1739910, 1835490, 1931070, 2026650, 2122230, 2217810, 2313390, 2408970, 2504550, 2600130, 2695710, 2791290, 2886870, 2982450, 3076260, 3170070, 3263880, 3357690, 3451500, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1168940, 1244900, 1320865, 1396825, 1472790, 1548750, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 2250,
        },
        {
            type = "reputation",
            id = 1106,
            amount = 1250,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 13106,
                    restrictions = {
                        type = "quest",
                        id = 13106,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 30631,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13117,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13119,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 13120,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13136,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 13221,
            aside = true,
        },
        {
            type = "quest",
            id = 13134,
            connections = {
                4, 5, 
            },
        },
        {
            type = "quest",
            id = 13138,
            x = -3,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 13140,
            connections = {
                2, 3, 
            },
        },
        {
            visible = false,
            x = 3,
        },
        {
            type = "quest",
            id = 13211,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13152,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13144,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13212,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13220,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13235,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHeartOfTheLichKingAlliance, {
    name = L["THE_HEART_OF_THE_LICH_KING"],
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
            id = Chain.WhatsYoursIsMine01,
        },
        {
            type = "chain",
            id = Chain.MordretharTheDeathGate01,
            upto = 13225,
        },
    },
    active = {
        type = "quest",
        id = 13386,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13403,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        45990, 48000, 49585, 51540, 53450, 55025, 56925, 58850, 60375, 62275, 64200, 66025, 67725, 69550, 71375, 73075, 74900, 76725, 78425, 80250, 82175, 84075, 85600, 87725, 89425, 11295, 11295, 9035, 6730, 4515, 2260, 1135, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        45990, 48000, 49585, 51540, 53450, 55025, 55025, 44055, 33005, 22040, 11075, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 610, 
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
                        966855, 1029680, 1092515, 1155340, 1218175, 1281000, 1360060, 1439110, 1518170, 1597220, 1676280, 1755340, 1834390, 1913450, 1992500, 2071560, 2150620, 2229670, 2308730, 2387780, 2466840, 2544430, 2622020, 2699620, 2777210, 2854800, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        966855, 1029680, 1092515, 1155340, 1218175, 1281000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1225,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 500,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1098,
            amount = 500,
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
            id = 29799,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13386,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13387,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13388,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13389,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13390,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13391,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13392,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13393,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13394,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13395,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13396,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13397,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 13398,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13399,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13400,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13401,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13402,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13403,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHeartOfTheLichKingHorde, {
    name = L["THE_HEART_OF_THE_LICH_KING"],
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
            id = Chain.WhatsYoursIsMine02,
        },
        {
            type = "chain",
            id = Chain.MordretharTheDeathGate02,
            upto = 13224,
        },
    },
    active = {
        type = "quest",
        id = 13258,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13364,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        45990, 48000, 49585, 51540, 53450, 55025, 56925, 58850, 60375, 62275, 64200, 66025, 67725, 69550, 71375, 73075, 74900, 76725, 78425, 80250, 82175, 84075, 85600, 87725, 89425, 11295, 11295, 9035, 6730, 4515, 2260, 1135, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        45990, 48000, 49585, 51540, 53450, 55025, 55025, 44055, 33005, 22040, 11075, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 5535, 610, 
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
                        966855, 1029680, 1092515, 1155340, 1218175, 1281000, 1360060, 1439110, 1518170, 1597220, 1676280, 1755340, 1834390, 1913450, 1992500, 2071560, 2150620, 2229670, 2308730, 2387780, 2466840, 2544430, 2622020, 2699620, 2777210, 2854800, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        966855, 1029680, 1092515, 1155340, 1218175, 1281000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 575,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 900,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1098,
            amount = 500,
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
            id = 29795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13258,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13259,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13262,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13263,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13271,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13275,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13282,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13304,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13305,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13236,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13348,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13349,
            x = -1,
        },
        {
            type = "quest",
            id = 13359,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13360,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13361,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13362,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13363,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13364,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WhatsYoursIsMine01, {
    name = L["WHATS_YOURS_IS_MINE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12887,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12898,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15930, 16550, 17170, 17780, 18500, 19025, 19625, 20350, 20875, 21475, 22200, 22825, 23425, 24050, 24675, 25275, 25900, 26525, 27125, 27750, 28475, 29075, 29600, 30325, 30925, 3910, 3910, 3135, 2315, 1560, 780, 400, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15930, 16550, 17170, 17780, 18500, 19025, 19025, 15210, 11410, 7610, 3850, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 205, 
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
                        483425, 514840, 546255, 577670, 609085, 640500, 680030, 719555, 759085, 798610, 838140, 877670, 917195, 956725, 996250, 1035780, 1075310, 1114835, 1154365, 1193890, 1233420, 1272215, 1311010, 1349810, 1388605, 1427400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        483425, 514840, 546255, 577670, 609085, 640500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 860,
        },
    },
    items = {
        {
            type = "npc",
            id = 29799,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12887,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12891,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12893,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12896,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12898,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WhatsYoursIsMine02, {
    name = L["WHATS_YOURS_IS_MINE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 12892,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12899,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15930, 16550, 17170, 17780, 18500, 19025, 19625, 20350, 20875, 21475, 22200, 22825, 23425, 24050, 24675, 25275, 25900, 26525, 27125, 27750, 28475, 29075, 29600, 30325, 30925, 3910, 3910, 3135, 2315, 1560, 780, 400, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15930, 16550, 17170, 17780, 18500, 19025, 19025, 15210, 11410, 7610, 3850, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 1920, 205, 
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
                        483425, 514840, 546255, 577670, 609085, 640500, 680030, 719555, 759085, 798610, 838140, 877670, 917195, 956725, 996250, 1035780, 1075310, 1114835, 1154365, 1193890, 1233420, 1272215, 1311010, 1349810, 1388605, 1427400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        483425, 514840, 546255, 577670, 609085, 640500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 860,
        },
    },
    items = {
        {
            type = "npc",
            id = 29795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12892,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12891,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12893,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12897,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12899,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SeizingSaronite, {
    name = L["SEIZING_SARONITE"],
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
            id = Chain.TheHeartOfTheLichKingAlliance,
            upto = 13389,
        },
        {
            type = "chain",
            id = Chain.TheHeartOfTheLichKingHorde,
            upto = 13263,
        },
    },
    active = {
        type = "quest",
        id = 13168,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            13172,13174
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17680, 18450, 18970, 19730, 20500, 21025, 21775, 22550, 23075, 23825, 24600, 25375, 25875, 26650, 27425, 27925, 28700, 29475, 29975, 30750, 31525, 32275, 32800, 33575, 34325, 4360, 4360, 3460, 2565, 1740, 870, 435, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17680, 18450, 18970, 19730, 20500, 21025, 21025, 16910, 12560, 8460, 4225, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 2100, 230, 
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
                        404175, 430440, 456705, 482970, 509235, 535500, 568550, 601595, 634645, 667690, 700740, 733790, 766835, 799885, 832930, 865980, 899030, 932075, 965125, 998170, 1031220, 1063655, 1096090, 1128530, 1160965, 1193400, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        404175, 430440, 456705, 482970, 509235, 535500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 1260,
        },
    },
    items = {
        {
            type = "npc",
            id = 30946,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13168,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13171,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 13169,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 13170,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13172,
            x = -1,
        },
        {
            type = "quest",
            id = 13174,
        },
    },
})
Database:AddChain(Chain.MalykrissTheVileHold, {
    name = L["MALYKRISS_THE_VILE_HOLD"],
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
            id = Chain.SeizingSaronite,
        },
    },
    active = {
        type = "quest",
        id = 13155,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13164,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        37000, 38500, 39850, 41350, 42950, 44200, 45700, 47300, 48500, 50000, 51600, 53050, 54450, 55900, 57350, 58750, 60200, 61650, 63050, 64500, 66100, 67600, 68800, 70450, 71900, 9070, 9070, 7265, 5400, 3630, 1815, 925, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        37000, 38500, 39850, 41350, 42950, 44200, 44200, 35400, 26500, 17675, 8935, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 4460, 485, 
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
                        1149125, 1223800, 1298475, 1373150, 1447825, 1522500, 1616460, 1710420, 1804380, 1898340, 1992300, 2086260, 2180220, 2274180, 2368140, 2462100, 2556060, 2650020, 2743980, 2837940, 2931900, 3024120, 3116340, 3208560, 3300780, 3393000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1149125, 1223800, 1298475, 1373150, 1447825, 1522500, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 2875,
        },
    },
    items = {
        {
            type = "npc",
            id = 30946,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13155,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13143,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13145,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13146,
            x = -2,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 13147,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 13160,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13161,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13162,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13163,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13164,
            x = 0,
        },
    },
})
Database:AddChain(Chain.InDefianceOfTheScourge, {
    name = L["IN_DEFIANCE_OF_THE_SCOURGE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            13036, 13226, 13227, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13157,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        55540, 57850, 59710, 61990, 64350, 66325, 68575, 70950, 72775, 75025, 77400, 79725, 81525, 83850, 86175, 87975, 90300, 92625, 94425, 96750, 99125, 101375, 103200, 105575, 107825, 13630, 13630, 10855, 8145, 5440, 2720, 1380, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        55540, 57850, 59710, 61990, 64350, 66325, 66325, 53180, 39630, 26530, 13350, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 6650, 730, 
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
                        634000, 675200, 716400, 757600, 798800, 840000, 891840, 943680, 995520, 1047360, 1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        634000, 675200, 716400, 757600, 798800, 840000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1037,
            amount = 10,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1098,
            amount = 1000,
        },
        {
            type = "reputation",
            id = 1106,
            amount = 4360,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 13226,
                    restrictions = {
                        type = "quest",
                        id = 13226,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 13227,
                    restrictions = {
                        type = "quest",
                        id = 13227,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 28179,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13036,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13040,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13008,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13039,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13044,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13045,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13070,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13086,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                13104, 13105, 
            },
            x = 0,
            connections = {
                1, 2, 3, 4, 6, 
            },
        },
        {
            type = "quest",
            id = 13118,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 13122,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13130,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 13135,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13125,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13110,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13139,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13141,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13157,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MordretharTheDeathGate01, {
    name = L["MORDRETHAR_THE_DEATH_GATE"],
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
            id = Chain.InDefianceOfTheScourge,
        },
    },
    active = {
        type = "quest",
        id = 13225,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {13295, 13298},
        count = 2
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        29690, 30950, 31960, 33140, 34450, 35525, 36625, 37950, 38975, 40075, 41400, 42675, 43575, 44850, 46125, 47025, 48300, 49575, 50475, 51750, 53075, 54175, 55200, 56525, 57625, 7300, 7300, 5820, 4355, 2910, 1450, 735, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        29690, 30950, 31960, 33140, 34450, 35525, 35525, 28430, 21230, 14200, 7145, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 3550, 385, 
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
                        812315, 865100, 917890, 970675, 1023465, 1076250, 1142670, 1209090, 1275510, 1341930, 1408350, 1474770, 1541190, 1607610, 1674030, 1740450, 1806870, 1873290, 1939710, 2006130, 2072550, 2137740, 2202930, 2268120, 2333310, 2398500, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        812315, 865100, 917890, 970675, 1023465, 1076250, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 60,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 31241,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13225,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 13341,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 13296,
            aside = true,
        },
        {
            type = "quest",
            id = 13231,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 13232,
            aside = true,
        },
        {
            type = "quest",
            id = 13290,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13286,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13291,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 13287,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13294,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13295,
            x = -1,
        },
        {
            type = "quest",
            id = 13298,
        },
    },
})
Database:AddChain(Chain.MordretharTheDeathGate02, {
    name = L["MORDRETHAR_THE_DEATH_GATE"],
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
            id = Chain.InDefianceOfTheScourge,
        },
    },
    active = {
        type = "quest",
        id = 13224,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {13278, 13279},
        count = 2
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        28840, 30050, 31060, 32190, 33500, 34475, 35525, 36850, 37825, 38875, 40200, 41425, 42325, 43550, 44775, 45675, 46900, 48125, 49025, 50250, 51575, 52625, 53600, 54925, 55975, 7100, 7100, 5670, 4205, 2830, 1410, 715, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        28840, 30050, 31060, 32190, 33500, 34475, 34475, 27580, 20630, 13800, 6945, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 3450, 370, 
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
                        740990, 789140, 837295, 885445, 933600, 981750, 1042340, 1102925, 1163515, 1224100, 1284690, 1345280, 1405865, 1466455, 1527040, 1587630, 1648220, 1708805, 1769395, 1829980, 1890570, 1950035, 2009500, 2068970, 2128435, 2187900, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        740990, 789140, 837295, 885445, 933600, 981750, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 60,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 31240,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13224,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 13340,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 13293,
            aside = true,
        },
        {
            type = "quest",
            id = 13228,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 13230,
            aside = true,
        },
        {
            type = "quest",
            id = 13238,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13260,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13239,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 13237,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13277,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13278,
            x = -1,
        },
        {
            type = "quest",
            id = 13279,
        },
    },
})
Database:AddChain(Chain.AldurtharTheDesolationGate01, {
    name = L["ALDURTHAR_THE_DESOLATION_GATE"],
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
            id = Chain.MordretharTheDeathGate01,
            upto = 13287,
        },
    },
    active = {
        type = "quest",
        id = 13288,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13346,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        31900, 33250, 34250, 35600, 36950, 38000, 39350, 40700, 41700, 43050, 44400, 45750, 46750, 48100, 49450, 50450, 51800, 53150, 54150, 55500, 56850, 58200, 59200, 60550, 61900, 7825, 7825, 6225, 4655, 3130, 1570, 790, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        31900, 33250, 34250, 35600, 36950, 38000, 38000, 30500, 22700, 15250, 7650, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 420, 
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
                        851940, 907300, 962665, 1018025, 1073390, 1128750, 1198410, 1268070, 1337730, 1407390, 1477050, 1546710, 1616370, 1686030, 1755690, 1825350, 1895010, 1964670, 2034330, 2103990, 2173650, 2242020, 2310390, 2378760, 2447130, 2515500, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        851940, 907300, 962665, 1018025, 1073390, 1128750, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
    },
    items = {
        {
            visible = false,
            x = -3,
        },
        {
            type = "npc",
            id = 29799,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13288,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13315,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13319,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 13318,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 13320,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13342,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 13345,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13321,
            aside = true,
        },
        {
            type = "quest",
            id = 13346,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AldurtharTheDesolationGate02, {
    name = L["ALDURTHAR_THE_DESOLATION_GATE"],
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
            id = Chain.MordretharTheDeathGate02,
            upto = 13237,
        },
    },
    active = {
        type = "quest",
        id = 13264,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13367,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        31900, 33250, 34250, 35600, 36950, 38000, 39350, 40700, 41700, 43050, 44400, 45750, 46750, 48100, 49450, 50450, 51800, 53150, 54150, 55500, 56850, 58200, 59200, 60550, 61900, 7825, 7825, 6225, 4655, 3130, 1570, 790, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        31900, 33250, 34250, 35600, 36950, 38000, 38000, 30500, 22700, 15250, 7650, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 3805, 420, 
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
                        851940, 907300, 962665, 1018025, 1073390, 1128750, 1198410, 1268070, 1337730, 1407390, 1477050, 1546710, 1616370, 1686030, 1755690, 1825350, 1895010, 1964670, 2034330, 2103990, 2173650, 2242020, 2310390, 2378760, 2447130, 2515500, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        851940, 907300, 962665, 1018025, 1073390, 1128750, 
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
            id = 29795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13264,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13351,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 13354,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 13352,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 13355,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            visible = false,
            x = -3,
        },
        {
            type = "quest",
            id = 13358,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 13366,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13356,
            aside = true,
        },
        {
            type = "quest",
            id = 13367,
            x = 0,
        },
    },
})
Database:AddChain(Chain.CorpretharTheHorrorGate01, {
    name = L["CORPRETHAR_THE_HORROR_GATE"],
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
            id = Chain.AldurtharTheDesolationGate01,
            upto = 13345,
        },
    },
    active = {
        type = "quest",
        ids = {
            13332, 13346, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {13338, 13339},
        count = 2
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        31850, 33100, 34300, 35550, 36950, 38050, 39300, 40700, 41750, 43000, 44400, 45650, 46850, 48100, 49350, 50550, 51800, 53050, 54250, 55500, 56900, 58150, 59200, 60600, 61850, 7800, 7800, 6250, 4650, 3120, 1560, 800, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        31850, 33100, 34300, 35550, 36950, 38050, 38050, 30450, 22800, 15200, 7700, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 415, 
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
                        951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        951000, 1012800, 1074600, 1136400, 1198200, 1260000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 250,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1098,
            amount = 1800,
        },
    },
    items = {
        {
            type = "npc",
            id = 29799,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13332,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 13346,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13334,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13314,
            aside = true,
        },
        {
            type = "quest",
            id = 13337,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13335,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13338,
            x = -1,
        },
        {
            type = "quest",
            id = 13339,
        },
    },
})
Database:AddChain(Chain.CorpretharTheHorrorGate02, {
    name = L["CORPRETHAR_THE_HORROR_GATE"],
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
            id = Chain.AldurtharTheDesolationGate02,
            upto = 13366,
        },
    },
    active = {
        type = "quest",
        ids = {
            13306, 13367, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {13316, 13328},
        count = 2
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        31850, 33100, 34300, 35550, 36950, 38050, 39300, 40700, 41750, 43000, 44400, 45650, 46850, 48100, 49350, 50550, 51800, 53050, 54250, 55500, 56900, 58150, 59200, 60600, 61850, 7800, 7800, 6250, 4650, 3120, 1560, 800, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        31850, 33100, 34300, 35550, 36950, 38050, 38050, 30450, 22800, 15200, 7700, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 3840, 415, 
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
                        951000, 1012800, 1074600, 1136400, 1198200, 1260000, 1337760, 1415520, 1493280, 1571040, 1648800, 1726560, 1804320, 1882080, 1959840, 2037600, 2115360, 2193120, 2270880, 2348640, 2426400, 2502720, 2579040, 2655360, 2731680, 2808000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        951000, 1012800, 1074600, 1136400, 1198200, 1260000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 250,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1098,
            amount = 1800,
        },
    },
    items = {
        {
            type = "npc",
            id = 29795,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13306,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 13367,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13307,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 13313,
            aside = true,
        },
        {
            type = "quest",
            id = 13312,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13329,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 13316,
            x = -1,
        },
        {
            type = "quest",
            id = 13328,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- The Admiral Revealed
        type = "quest",
        id = 12852,
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
            id = Chain.WhatsYoursIsMine01,
        },
        {
            type = "chain",
            id = Chain.WhatsYoursIsMine02,
        },
    },
    active = {
        type = "quest",
        id = 12938,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = { 12814, 12852, },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        48260, 50300, 51865, 53860, 56000, 57500, 59450, 61600, 63100, 65050, 67200, 69250, 70750, 72800, 74850, 76350, 78400, 80450, 81950, 84000, 86150, 88100, 89600, 91750, 93700, 11880, 11880, 9465, 7010, 4745, 2370, 1195, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        48260, 50300, 51865, 53860, 56000, 57500, 57500, 46145, 34395, 23080, 11585, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 5760, 625, 
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
                        1208565, 1287100, 1365640, 1444175, 1522715, 1601250, 1700070, 1798890, 1897710, 1996530, 2095350, 2194170, 2292990, 2391810, 2490630, 2589450, 2688270, 2787090, 2885910, 2984730, 3083550, 3180540, 3277530, 3374520, 3471510, 3568500, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1208565, 1287100, 1365640, 1444175, 1522715, 1601250, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1098,
            amount = 3495,
        },
    },
    items = {
        {
            type = "npc",
            id = 29343,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12938,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12939,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12943,
            aside = true,
            x = -1,
        },
        {
            type = "npc",
            id = 30056,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12949,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12951,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 12992,
            aside = true,
            x = -2,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 13085,
                    restrictions = {
                        type = "quest",
                        id = 13085,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 30218,
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 13084,
            aside = true,
        },
        {
            type = "quest",
            id = 12982,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 12806,
                    restrictions = {
                        type = "quest",
                        id = 12806,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 29344,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12807,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 12810,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12838,
            breadcrumb = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 12814,
            x = -1,
        },
        {
            type = "quest",
            id = 12839,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12840,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12847,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12852,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Mind Tricks
        type = "quest",
        id = 13308,
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
            id = Chain.InDefianceOfTheScourge,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MordretharTheDeathGate01,
            upto = 13225,
        },
        {
            type = "chain",
            id = Chain.MordretharTheDeathGate02,
            upto = 13224,
        },
    },
    active = {
        type = "quest",
        id = 13308,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 13308,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4300, 4450, 4650, 4800, 5000, 5150, 5300, 5500, 5650, 5800, 6000, 6150, 6350, 6500, 6650, 6850, 7000, 7150, 7350, 7500, 7700, 7850, 8000, 8200, 8350, 1050, 1050, 850, 625, 420, 210, 110, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4300, 4450, 4650, 4800, 5000, 5150, 5150, 4100, 3100, 2050, 1050, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 525, 55, 
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
            id = 31892,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13308,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TempChain22, {
    name = "The Sunreaver Plan",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 14457,
    },
    items = { -- Battered Hilt, Dungeon Chain
        {
            type = "quest",
            id = 14443,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 14444,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 14457,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain30, {
    name = "Preparations for War",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 13419,
    },
    items = {
        { -- Warchief's Command: Icecrown!, Horde Breadcrumb to zone? Requires cold weather flying
            type = "quest",
            id = 49537,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 13419,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain31, {
    name = "Preparations for War",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 13418,
    },
    items = {
        { -- Hero's Call: Icecrown!, Alliance breadcrumb to zone? Requires cold weather flying
            type = "quest",
            id = 49555,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 13418,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain32, {
    name = "The Halls Of Reflection",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 24561,
    },
    items = {
        { -- Dungeon/Raid quest
            type = "quest",
            id = 24560,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 24561,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain33, {
    name = "Return To Myralion Sunblaze",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 24558,
    },
    items = {
        { -- Battered Hilt quest
            type = "quest",
            id = 24556,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 24451,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 24558,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain34, {
    name = "The Silver Covenant's Scheme",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 24557,
    },
    items = {
        { -- Battered Hilt quest
            type = "quest",
            id = 24554,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 24555,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 24557,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain36, {
    name = "Return To Caladis Brightspear",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 24454,
    },
    items = { -- Battered Hilt
        {
            type = "quest",
            id = 20438,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 20439,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 24454,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain43, {
    name = "The Halls Of Reflection",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 24480,
    },
    items = {
        { -- Dungeon/Raid quest
            type = "quest",
            id = 24476,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 24480,
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
        { -- From Their Corpses, Rise!, Daily
            type = "quest",
            id = 12813,
        },
        { -- No Fly Zone, Daily
            type = "quest",
            id = 12815,
        },
        { -- Intelligence Gathering, Daily
            type = "quest",
            id = 12838,
        },
        { -- Leave Our Mark, Daily
            type = "quest",
            id = 12995,
        },
        { -- Shoot 'Em Up, Daily
            type = "quest",
            id = 13069,
        },
        { -- Reading the Bones, Repeatable, Follows 13092
            type = "quest",
            id = 13093,
        },
        { -- I'm Not Dead Yet!, possibly alternative to 13229
        -- requiures https://www.wowhead.com/?quest=13120 and/or https://www.wowhead.com/?quest=13119
            type = "quest",
            id = 13229,
        },
        { -- No Mercy!, Daily PvP
            type = "quest",
            id = 13233,
        },
        { -- Make Them Pay!, Daily PvP
            type = "quest",
            id = 13234,
        },
        { -- Volatility, Daily
            type = "quest",
            id = 13261,
        },
        { -- That's Abominable!, Daily Group
            type = "quest",
            id = 13276,
        },
        { -- Neutralizing the Plague, Daily
            type = "quest",
            id = 13281,
        },
        { -- Assault by Ground, Daily
            type = "quest",
            id = 13284,
        },
        { -- That's Abominable!, Daily
            type = "quest",
            id = 13289,
        },
        { -- The Solution Solution, Daily
            type = "quest",
            id = 13292,
        },
        { -- Neutralizing the Plague, Daily Group
            type = "quest",
            id = 13297,
        },
        { -- Slaves to Saronite, Daily
            type = "quest",
            id = 13300,
        },
        { -- Assault by Ground, Daily
            type = "quest",
            id = 13301,
        },
        { -- Slaves to Saronite, Daily
            type = "quest",
            id = 13302,
        },
        { -- Assault by Air, Daily
            type = "quest",
            id = 13309,
        },
        { -- Assault by Air, Daily
            type = "quest",
            id = 13310,
        },
        { -- Retest Now, Daily
            type = "quest",
            id = 13322,
        },
        { -- Drag and Drop, Daily
            type = "quest",
            id = 13323,
        },
        { -- Blood of the Chosen, Daily
            type = "quest",
            id = 13330,
        },
        { -- Keeping the Alliance Blind, Daily
            type = "quest",
            id = 13331,
        },
        { -- Capture More Dispatches, Daily
            type = "quest",
            id = 13333,
        },
        { -- Blood of the Chosen, Daily
            type = "quest",
            id = 13336,
        },
        { -- Not a Bug, Daily
            type = "quest",
            id = 13344,
        },
        { -- No Rest For The Wicked, Daily
            type = "quest",
            id = 13350,
        },
        { -- Drag and Drop, Daily
            type = "quest",
            id = 13353,
        },
        { -- Retest Now, Daily
            type = "quest",
            id = 13357,
        },
        { -- Not a Bug, Daily
            type = "quest",
            id = 13365,
        },
        { -- No Rest For The Wicked, Daily
            type = "quest",
            id = 13368,
        },
        { -- Amped for Revolt!, Repeatable
            type = "quest",
            id = 13374,
        },
        { -- Watts My Target, Repeatable
            type = "quest",
            id = 13381,
        },
        { -- Let's Get Out of Here!
        -- This quest is mutually exclusive with I'm Not Dead Yet! https://www.wowhead.com/?quest=13229
        -- Which quest you get will depend on which "phase" the area is in when you encounter Father Kamaros.
        -- Replaces 13229 after completing https://www.wowhead.com/?quest=13144?
            type = "quest",
            id = 13481,
        },
        { -- Let's Get Out of Here
        -- Not sure if this quest is missed mark as alliance or if there are 2 different quests depending
        -- on what stage your at for the invasion but I can't get this quest. Instead I got
        -- I'm not dead yet which I did before the invasion started.
            type = "quest",
            id = 13482,
        },
        { -- Takes One to Know One, Maybe alternative to 13260?
            type = "quest",
            id = 14447,
        },
        { -- Takes One to Know One, Maybe alternative to 13260?
            type = "quest",
            id = 14448,
        },
        { -- Battle Plans Of The Kvaldir, Argent Tournament
            type = "quest",
            id = 24442,
        },
        { -- A Victory For The Silver Covenant, Follows https://www.wowhead.com/quest=24595/the-purification-of-queldelar
            type = "quest",
            id = 24795,
        },
        { -- A Victory For The Silver Covenant, Follows https://www.wowhead.com/quest=24553/the-purification-of-queldelar
            type = "quest",
            id = 24796,
        },
        { -- A Victory For The Sunreavers, Follows https://www.wowhead.com/quest=24596/the-purification-of-queldelar
            type = "quest",
            id = 24798,
        },
        { -- A Victory For The Sunreavers, Follows https://www.wowhead.com/quest=24598/the-purification-of-queldelar
            type = "quest",
            id = 24799,
        },
        { -- A Victory For The Sunreavers, Follows https://www.wowhead.com/quest=24594/the-purification-of-queldelar
            type = "quest",
            id = 24800,
        },
        { -- A Victory For The Sunreavers, Follows https://www.wowhead.com/quest=24564/the-purification-of-queldelar
            type = "quest",
            id = 24801,
        },
        { -- Pitch Black Scourgestones, Shadowlands Prepatch
            type = "quest",
            id = 62292,
        },
        { -- Darkened Scourgestones, Shadowlands Prepatch
            type = "quest",
            id = 62293,
        },
        { -- King of the Mountain, Daily PvP
            type = "quest",
            id = 13280,
        },
        { -- King of the Mountain, Daily PvP
            type = "quest",
            id = 13283,
        },
        { -- Vile Like Fire!, Daily
            type = "quest",
            id = 13071,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-Icecrown]],
    items = {
        {
            type = "chain",
            id = Chain.CrusaderBridenbrad,
        },
        {
            type = "chain",
            id = Chain.TheUnthinkable,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.TeachingTheMeaningOfFear,
        },
        {
            type = "chain",
            id = Chain.TheHeartOfTheLichKingAlliance,
        },
        {
            type = "chain",
            id = Chain.TheHeartOfTheLichKingHorde,
        },
        {
            type = "chain",
            id = Chain.WhatsYoursIsMine01,
        },
        {
            type = "chain",
            id = Chain.WhatsYoursIsMine02,
        },
        {
            type = "chain",
            id = Chain.SeizingSaronite,
        },
        {
            type = "chain",
            id = Chain.MalykrissTheVileHold,
        },
        {
            type = "chain",
            id = Chain.InDefianceOfTheScourge,
        },
        {
            type = "chain",
            id = Chain.MordretharTheDeathGate01,
        },
        {
            type = "chain",
            id = Chain.MordretharTheDeathGate02,
        },
        {
            type = "chain",
            id = Chain.AldurtharTheDesolationGate01,
        },
        {
            type = "chain",
            id = Chain.AldurtharTheDesolationGate02,
        },
        {
            type = "chain",
            id = Chain.CorpretharTheHorrorGate01,
        },
        {
            type = "chain",
            id = Chain.CorpretharTheHorrorGate02,
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
