--[[
    Known issues:
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN2 is rather messy atm, not sure exactly
        how it should be done.
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN13 Not sure what the requirements are.
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN14 Not sure what the requirements are.
]]

local L = BtWQuests.L;
local MAP_ID = 864
local ACHIEVEMENT_ID = 12478
local CONTINENT_ID = 875

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 2)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
    },
    completed = {
        type = "quest",
        ids = {48549, 48550},
        count = 2,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                54000, 55600, 56900, 58500, 60100, 61400, 63000, 64600, 65900, 67500, 69150, 70850, 72000, 73750, 75350, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 1035,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
            x = 3,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "npc",
            id = 135012,
            -- name = "Go to Vivi",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.551955, 0.483843, "Vivi")
            -- end,
            -- breadcrumb = true,
            x = 6,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47319,
            x = 2,
            y = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 51574,
            x = 4,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50739,
            aside = true,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 47320,
            x = 3,
            y = 2,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 47322,
            aside = true,
            x = 0,
            y = 2.5,
        },
        {
            type = "quest",
            id = 50755,
            aside = true,
            x = 0,
            y = 3.5,
        },
        {
            type = "quest",
            id = 47317,
            x = 2,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 47316,
            x = 4,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47321,
            x = 6,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47959,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48549,
            x = 2,
            y = 5,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 48550,
            x = 4,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN1,
            relationship = {
                breadcrumb = 51829,
                blockers = {48551, 48553, 48555},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 6,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
            aside = true,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 3)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
    },
    completed = {
        type = "quest",
        id = 47874,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2102220, 2201370, 2300505, 2399655, 2498790, 2597940, 2697090, 2796225, 2895375, 2994510, 3093660, 3190965, 3288270, 3385590, 3482895, 3580200, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                60600, 62325, 63925, 65650, 67375, 68975, 70700, 72425, 74025, 75750, 77525, 79425, 80800, 82825, 84475, 
            },
            minLevel = 35,
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
            id = 2158,
            amount = 1065,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48684,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48895,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 49040, -- 49731
            aside = true,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 48993,
            x = 2,
            y = 3,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 48992,
            x = 4,
            y = 3,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 48991,
            x = 6,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48887,
            x = 2,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48888,
            x = 4,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48894,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48715,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48987,
            x = 3,
            y = 7,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48988,
            x = 2,
            y = 8,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49005,
            x = 4,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48889,
            x = 3,
            y = 9,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48996,
            x = 3,
            y = 10,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50913,
            x = 3,
            y = 11,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47874,
            x = 3,
            y = 12,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS,
            aside = true,
            x = 3,
            y = 13,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 4)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
        },
    },
    completed = {
        type = "quest",
        id = 50561,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                33600, 34600, 35400, 36400, 37400, 38200, 39200, 40200, 41000, 42000, 43000, 44100, 44800, 45900, 46900, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 760,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48896,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47716,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48314,
            x = 2,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48313,
            x = 4,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50770,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50539,
            x = 3,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN12,
            aside = true,
            x = 5,
            y = 5,
        },
        {
            type = "quest",
            id = 48315,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50561,
            x = 3,
            y = 7,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_THREE_KEEPERS,
            aside = true,
            x = 2,
            y = 8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN2,
            relationship = {
                breadcrumb = 50794,
                blocker = 51573,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 4,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_THREE_KEEPERS, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 5)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS,
        },
    },
    completed = {
        type = "quest",
        id = 49340,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1030500, 1079100, 1127700, 1176300, 1224900, 1273500, 1322100, 1370700, 1419300, 1467900, 1516500, 1564200, 1611900, 1659600, 1707300, 1755000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                28800, 29650, 30350, 31200, 32050, 32750, 33600, 34450, 35150, 36000, 36850, 37750, 38400, 39300, 40150, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 860,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47324,
            x = 3,
            y = 1,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN6,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 51165,
            aside = true,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 49334,
            x = 1,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50641,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49327,
            x = 5,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49340,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_STORMING_THE_SPIRE,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_STORMING_THE_SPIRE, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 6)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_THREE_KEEPERS,
        },
    },
    completed = {
        type = "quest",
        id = 50550,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 2788440, 2919340, 3050230, 3181130, 3312020, 3442920, 3573820, 3704710, 3835610, 3966500, 4097160, 4225630, 4354100, 4482580, 4598330, 4258800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                68800, 69100, 69400, 69600, 69900, 70200, 70500, 70700, 71000, 71300, 71500, 71800, 72100, 72300, 72600, 72900, 73200, 73400, 73700, 74000, 74200, 74500, 74800, 75000, 75300, 75600, 77750, 79750, 81900, 84050, 86050, 88200, 90350, 92350, 94500, 96850, 99050, 100800, 103250, 105350, 
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
            id = 2158,
            amount = 1795,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_THREE_KEEPERS,
            x = 3,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN7,
            aside = true,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 49662,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50745,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49667,
            aside = true,
            x = 2,
            y = 3,
        },
        {
            type = "quest",
            id = 49664,
            x = 4,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49665,
            x = 3,
            y = 4,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 49666,
            x = 5,
            y = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 49437,
            aside = true,
            x = 1,
            y = 5,
        },
        {
            type = "quest",
            id = 50746,
            x = 3,
            y = 5,
            connections = {
                2, 3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN8,
            aside = true,
            x = 5,
            y = 5,
        },
        {
            type = "quest",
            id = 49141,
            x = 2,
            y = 6,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50748,
            x = 4,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49002,
            aside = true,
            x = 1,
            y = 7,
        },
        {
            type = "quest",
            id = 49003,
            x = 3,
            y = 7,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50750,
            x = 2,
            y = 8,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50752,
            x = 4,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50550,
            x = 3,
            y = 9,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50805,
            aside = true,
            x = 2,
            y = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_ATULAMAN,
            aside = true,
            x = 4,
            y = 10,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_ATULAMAN, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 7)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_THREE_KEEPERS,
        },
    },
    completed = {
        type = "quest",
        id = 50702,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                893100, 935220, 977340, 1019460, 1061580, 1103700, 1145820, 1187940, 1230060, 1272180, 1314300, 1355640, 1396980, 1438320, 1479660, 1521000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                39600, 40650, 41700, 42900, 43950, 45150, 46200, 47250, 48450, 49500, 50700, 51750, 52800, 54050, 55050, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 600,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 1035,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_STORMING_THE_SPIRE,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50751,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50617,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50904,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50702,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50551,
            aside = true,
            x = 2,
            y = 5,
        },
        {
            type = "quest",
            ids = {50703, 52023, 52024},
            aside = true,
            x = 4,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 1)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
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
            id = 47513,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51364,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1057980, 1107880, 1157770, 1207670, 1257560, 1307460, 1357360, 1407250, 1457150, 1507040, 1556940, 1605910, 1654880, 1703860, 1752830, 1801800, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                33600, 34600, 35400, 36400, 37400, 38200, 39200, 40200, 41000, 42000, 43050, 44050, 44800, 45900, 46850, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 960,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 47513,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47313,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47314,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47315,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51357,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49676,
            x = 2,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47327,
            x = 4,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49677,
            x = 2,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51364,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
            x = 3,
            y = 8,
        }
    },
})
-- Completed, Horde Only, No requirements, 1 Breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN1, {
    name = BtWQuests_GetAreaName(9202), -- Withering Gulch
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51829,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48551,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48553,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48555,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 48554,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 525,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 51829,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 126814,
                    -- name = "Go to Ranah",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(864, 0.538743, 0.693901, "Ranah")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 48551,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48553,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48555,
            x = 5,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48554,
            x = 3,
            y = 2,
        },
    },
})
-- Horde Only, no requirements, 1 breadcrumb, rather messy
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN2, {
    name = BtWQuests_GetAreaName(9226), -- Scorched Sands Outpost
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50794,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51573,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51668,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2789220, 2920770, 3052305, 3183855, 3315390, 3446940, 3578490, 3710025, 3841575, 3973110, 4104660, 4233765, 4362870, 4491990, 4621095, 4750200, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                79800, 82175, 84075, 86450, 88825, 90725, 93100, 95475, 97375, 99750, 102275, 104575, 106400, 108925, 111225, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 290,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 1350,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50794,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 126576,
                    -- name = "Go to Razgaji",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(864, 0.433944, 0.753714, "Razgaji")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 51573,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 48529,
            x = 2,
            y = 3,
            connections = {
                2, 3,
            }
        },
        {
            type = "quest",
            id = 48530,
            x = 4,
            y = 3,
            connections = {
                3,
            }
        },
        
        {
            type = "quest",
            id = 48533,
            x = 0,
            y = 4,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 48531,
            aside = true,
            x = 2,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48532,
            aside = true,
            x = 4,
            y = 4,
        },
        {
            type = "quest",
            id = 48585,
            aside = true,
            x = 6,
            y = 4,
        },

        
        {
            type = "quest",
            id = 48655,
            x = 3,
            y = 5,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48656,
            x = 2,
            y = 6,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48657,
            x = 4,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48534,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48846,
            x = 3,
            y = 8,
            connections = {
                1, 2, 3,
            },
        },
        
        {
            type = "quest",
            id = 48850,
            x = 1,
            y = 9,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48790,
            x = 3,
            y = 9,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51602,
            x = 5,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48847,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51668,
            x = 3,
            y = 11,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 51161,
            aside = true,
            x = 0,
            y = 12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN3,
            relationship = {
                breadcrumb = 51773,
                blockers = {47870, 47871},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 2,
            y = 12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN4,
            relationship = {
                breadcrumb = 51775,
                blocker = 48324,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 4,
            y = 12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN5,
            relationship = {
                breadcrumb = 51772,
                blockers = {47577, 47570, 47943},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 6,
            y = 12,
        },
    },
})
-- Completed, Both Factions, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN3, {
    name = { -- The Ashvane Threat
        type = "quest",
        id = 51773,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51773,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47870,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47871,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 47873,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                28800, 29600, 30400, 31200, 32000, 32800, 33600, 34400, 35200, 36000, 36900, 37750, 38400, 39350, 40150, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 150,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 51773,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 124468,
                }
            },
            x = 3,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "npc",
            id = 128422,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            aside = true,
            x = 5,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN15,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 47870,
            x = 2,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47871,
            x = 4,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47939,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            aside = true,
            x = 6,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51810,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49227,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
            aside = true,
            x = 6,
            y = 2,
        },
        {
            type = "quest",
            id = 47873,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, Horde Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN4, {
    name = { -- The Golden Isle
        type = "quest",
        id = 51059,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51775,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48324,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51062,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1515400, 1525700, 1536000, 1546300, 1556600, 1566900, 1577200, 1587500, 1597800, 1608100, 1618400, 1628700, 1639000, 1649300, 1659600, 1669900, 1680200, 1690500, 1700800, 1711100, 1721400, 1734360, 1747320, 1760280, 1773240, 1786200, 2708580, 2832350, 2956115, 3079885, 3203650, 3327420, 3451190, 3574955, 3698725, 3822490, 3944700, 4066175, 4187650, 4309130, 4417885, 1427400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                63400, 63700, 64000, 64200, 64500, 64800, 65100, 65300, 65600, 65900, 66100, 66400, 66700, 66900, 67200, 67500, 67800, 68000, 68300, 68600, 68800, 69100, 69400, 69600, 69900, 70200, 72175, 74075, 76050, 78025, 79925, 81900, 83875, 85775, 87750, 89825, 91975, 93600, 95875, 97825, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 190,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 1290,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 51775,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 125904,
                    -- name = "Go to Norah",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(864, 0.388803, 0.773128, "Norah")
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
            id = 287440,
            -- name = "Go to the Wanted Poster",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.388563, 0.769764, "Wanted Poster")
            -- end,
            -- breadcrumb = true,
            x = 5,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48324,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51162,
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 51053,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51054,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 51056,
            x = 2,
            y = 4,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 51055,
            x = 4,
            y = 4,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 47647,
            aside = true,
            x = 6,
            y = 4,
        },
        
        {
            type = "quest",
            id = 49138,
            aside = true,
            x = 0,
            y = 5,
        },
        {
            type = "quest",
            id = 47499,
            x = 2,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51057,
            x = 4,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51059,
            x = 3,
            y = 6,
            connections = {
                1, 2,
            },
        },

        {
            type = "quest",
            id = 51060,
            x = 2,
            y = 7,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51061,
            x = 4,
            y = 7,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48326,
            x = 3,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51062,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN9,
            relationship = {
                breadcrumb = 48327,
                blockers = {47497},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 3,
            y = 10,
        },
    },
})
-- Completed, Horde Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN5, {
    name = { -- The Tortaka Tribe
        type = "quest",
        id = 51772,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51772,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47577,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47570,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47943,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 47578,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1552620, 1625850, 1699065, 1772295, 1845510, 1918740, 1991970, 2065185, 2138415, 2211630, 2284860, 2356725, 2428590, 2500470, 2572335, 2644200, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                47400, 48775, 49975, 51350, 52725, 53925, 55300, 56675, 57875, 59250, 60725, 62125, 63200, 64775, 66075, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 125,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 770,
        },
    },
    items = {
        {
            type = "quest",
            id = 51772,
            visible = BtWQuestsItem_ActiveOrCompleted,
            x = 3,
            y = 0,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "npc",
            id = 134098,
            -- name = "Go to Torka",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.620276, 0.223275, "Torka")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 51772,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 2,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "npc",
            id = 134128,
            -- name = "Go to Churka",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.619755, 0.221516, "Churka")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 51772,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 5,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47577,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47570,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47943,
            x = 5,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47571,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47965,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 47581,
            x = 1,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47573,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47574,
            x = 5,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47928,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47580,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47576,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47578,
            x = 3,
            y = 8,
        },
    },
})
-- Completed, Horde Only, no requirements, no breadcrumbs (starts in an odd place)
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN6, {
    name = {
        type = "npc",
        id = 135400,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50818,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50817,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                563340, 589910, 616475, 643045, 669610, 696180, 722750, 749315, 775885, 802450, 829020, 855095, 881170, 907250, 933325, 959400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                16200, 16675, 17075, 17550, 18025, 18425, 18900, 19375, 19775, 20250, 20775, 21225, 21600, 22125, 22575, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 375,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "object",
            id = 282498,
            -- name = "Go to the Desert Flute",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.289776, 0.546546, "Desert Flute")
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
            id = 50818,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50817,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50979,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50980,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN11,
            relationship = {
                breadcrumb = 50834,
                blockers = {50771, 52129, 50775},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 3,
            y = 4,
        },
    },
})
-- Completed, Horde Only, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN7, {
    name = BtWQuests_GetAreaName(9776), -- Forward Camp
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50656,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49333,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49335,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 50656,
        },
        {
            type = "quest",
            id = 49333,
        },
        {
            type = "quest",
            id = 49335,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18900, 19200, 19650, 20100, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 225,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 134611,
            -- name = "Go to Seriah",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.326805, 0.484359, "Seriah")
            -- end,
            -- breadcrumb = true,
            x = 1,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 128691,
            -- name = "Go to Izarn",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.323130, 0.483848, "Izarn")
            -- end,
            -- breadcrumb = true,
            x = 4,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 50656,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 49333,
            x = 3,
            y = 1,
        },
        {
            type = "quest",
            id = 49335,
            x = 5,
            y = 1,
        },
    },
})
-- Completed, Horde Only, requirement is part way through Storming the Spires, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN8, {
    name = { -- Free Ride
        type = "quest",
        id = 50749,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_THREE_KEEPERS,
        },
        {
            type = "quest",
            id = 49665,
        },
        {
            type = "quest",
            id = 49666,
        },
    },
    active = {
        {
            type = "quest",
            id = 49668,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50749,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                618300, 647460, 676620, 705780, 734940, 764100, 793260, 822420, 851580, 880740, 909900, 938520, 967140, 995760, 1024380, 1053000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                18000, 18500, 19000, 19500, 20000, 20500, 21000, 21500, 22000, 22500, 23050, 23600, 24000, 24600, 25100, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 310,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_STORMING_THE_SPIRE,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49668,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49669,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50757,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50749,
            x = 3,
            y = 3,
        },
    },
})
--  Completed, Horde Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN9, {
    name = { -- Meet the Goldtusk Gang
        type = "quest",
        id = 47497,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48327,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 47497,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 48322,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2019780, 2115040, 2210290, 2305550, 2400800, 2496060, 2591320, 2686570, 2781830, 2877080, 2972340, 3065830, 3159320, 3252820, 3346310, 3439800, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                56400, 58000, 59500, 61100, 62700, 64200, 65800, 67400, 68900, 70500, 72200, 73900, 75200, 77050, 78600, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 215,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 1255,
            restrictions = 923,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 48327,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 122723,
                    -- name = "Go to Rhan'ka",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(864, 0.435079, 0.602125, "Rhan'ka")
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
            id = 287442,
            -- name = "Go to the Wanted Poster",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.436483, 0.599516, "Wanted Poster")
            -- end,
            -- breadcrumb = true,
            x = 5,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47497,
            x = 3,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 51164,
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 47498,
            x = 2,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 47501,
            x = 4,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 47502,
            x = 1,
            y = 3,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 51717,
            x = 3,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 47503,
            x = 5,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 51718,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50328,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47638,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 48321,
            x = 1,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47564,
            x = 3,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48320,
            x = 5,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48322,
            x = 3,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN10,
            relationship = {
                breadcrumb = 48840,
                blockers = {48332, 49001, 48334},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 3,
            y = 9,
        },
    },
})
-- Completed, Horde Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN10, {
    name = { -- Zandalari Treasure Trove
        type = "quest",
        id = 48330,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48840,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48332,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49001,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 48334,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 48330,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                34800, 35850, 36650, 37700, 38750, 39550, 40600, 41650, 42450, 43500, 44600, 45650, 46400, 47500, 48550, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 600,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 129451,
            -- name = "Go to Omi",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.453642, 0.461572, "Omi")
            -- end,
            -- breadcrumb = true,
            x = 1,
            y = 0,
            connections = {
                3,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 48840,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 129453,
                    -- name = "Go to Kenzou",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(864, 0.453918, 0.461864, "Kenzou")
                    -- end,
                    -- breadcrumb = true,
                }
            },
            x = 3,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "npc",
            id = 129450,
            -- name = "Go to Tacha",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.453890, 0.461530, "Tacha")
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
            id = 48332,
            x = 1,
            y = 1,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 49001,
            x = 3,
            y = 1,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 48334,
            x = 5,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },


        {
            type = "quest",
            id = 49139,
            x = 1,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 48335,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48331,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 48330,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, Horde Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN11, {
    name = { -- Awakened Elements
        type = "quest",
        id = 50812,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50834,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50771,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52129,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50775,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50812,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                700740, 733790, 766835, 799885, 832930, 865980, 899030, 932075, 965125, 998170, 1031220, 1063655, 1096090, 1128530, 1160965, 1193400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                21000, 21625, 22125, 22750, 23375, 23875, 24500, 25125, 25625, 26250, 26925, 27525, 28000, 28675, 29275, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50834,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 135179,
                    -- name = "Go to Merd Archfeld",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(864, 0.262000, 0.736451, "Merd Archfeld")
                    -- end,
                    -- breadcrumb = true,
                }
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50771,
            x = 1,
            y = 1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 52129,
            x = 3,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50775,
            x = 5,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51991,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50812,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, only horde, requires part way through BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN12, {
    name = { -- Power of the Overseer
        type = "quest",
        id = 50535,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
        },
        {
            type = "quest",
            id = 50770,
        },
    },
    active = {
        {
            type = "quest",
            id = 50536,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50535,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                25200, 25950, 26550, 27300, 28050, 28650, 29400, 30150, 30750, 31500, 32300, 33050, 33600, 34400, 35150, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 375,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 134148,
            -- name = "Go to Maaz",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.473185, 0.727297, "Maaz")
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
            id = 50536,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50596,
            aside = true,
            x = 0,
            y = 2,
        },
        {
            type = "quest",
            id = 48871,
            x = 2,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48872,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50535,
            x = 3,
            y = 3,
        },
    },
})
-- Horde Only, Unknown requirements (probably [Crater Conquered] in storming the spire), no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN13, {
    name = { -- Beaten But Not Broken
        type = "quest",
        id = 48329,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48329,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 48329,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2158,
            amount = 75,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 130603,
            -- name = "Kill Beastbreaker Hakid",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.480841, 0.394916, "Beastbreaker Hakid")
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
            id = 48329,
            x = 3,
            y = 1,
        },
    },
})
-- Alliance Only, not sure the requirements exactly, merged with BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_ON_THE_SAND
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN14, {
    name = { -- Curse of Jani
        type = "quest",
        id = 51145,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51142,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51145,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 
            },
            minLevel = 35,
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
            type = "npc",
            id = 136562,
            -- name = "Go to Quartermaster Alfin",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.365715, 0.323048, "Quartermaster Alfin")
            -- end,
            -- breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51142,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51145,
            x = 0,
            y = 2,
        },
    },
})
-- Completed, available for both factions, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN15, {
    name = BtWQuests_GetAreaName(8964), -- Redrock Harbor
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49261,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49262,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 49261,
        },
        {
            type = "quest",
            id = 49262,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
    },
    items = {
        {
            name = L["COLLECT_AN_ASHVANE_DISGUISE"],
            visible = {
                type = "quest",
                ids = {49261, 49262},
                status = {'notcompleted'}
            },
            active = {
                type = "item",
                id = 160735,
            },
            completed = {
                type = "aura",
                id = 266248,
            },
            aside = true,
            x = 3,
            y = 0,
        },
        {
            type = "npc",
            id = 128618,
            -- name = "Go to Dockmaster Herrington",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.445974, 0.882277, "Dockmaster Herrington")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49261,
            x = 2,
            y = 2,
        },
        {
            type = "quest",
            id = 49262,
            x = 4,
            y = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = false,
    items = {
        {
            type = "quest",
            id = 50603,
        }, 
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = false,
    items = {
        { -- Emmissary World Quests
            type = "quest",
            id = 50603,
        },
        {
            type = "quest",
            id = 49731,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = false,
    items = {
        { -- Part of get get Hek'd, requries the first part with Jani and the butt biting to unlock
            type = "quest",
            id = 50901,
        },
        { -- Kill horde players, gives conquest points, so pvp quest, maybe war mode world quest?
            type = "quest",
            id = 52953,
        },
        { -- Kill horde players, gives conquest points, so pvp quest, maybe war mode world quest?
            type = "quest",
            id = 52950,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2178273,
    listImage = {
        texture = "Interface\\Addons\\BtWQuestsBattleForAzeroth\\UI-CategoryButton",
        texCoords = {0, 0.7353515625, 0.703125, 0.8203125},
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
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_ON_THE_SAND,
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
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_UNLIKELY_ALLIES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_DANGERS_IN_THE_DESERT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_WARGUARDS_FATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_A_CITY_OF_SECRETS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_THE_THREE_KEEPERS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_STORMING_THE_SPIRE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_ATULAMAN,
        },


        {
            type = "header",
            name = L["BTWQUESTS_SIDE_QUESTS"],
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN4,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN6,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN9,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN11,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN13,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN15,
        },


        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_OTHER_HORDE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_OTHER_BOTH,
        -- },
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN1,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN2,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN3,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN4,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN5,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN6,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN7,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN8,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN9,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN10,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN11,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN12,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN13,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN15,
    },
})