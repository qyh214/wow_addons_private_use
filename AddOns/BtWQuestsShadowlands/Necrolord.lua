local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.Necrolord
local Chain = BtWQuests.Constant.Chain.Shadowlands.Necrolord
local LEVEL_RANGE = {60, 60}

Database:AddChain(Chain.LoyalToThePrimus, {
    name = L["LOYAL_TO_THE_PRIMUS"],
    questline = 1087,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
        },
    },
    active = {
        type = "quest",
        ids = {
            63212, 58609, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 59609,
    },
    rewards = {
        {
            name = L["SOULBIND_PLAGUE_DEVISER_MARILETH"],
            type = "spell",
            id = 344967,
        },
        {
            type = "experience",
            amounts = {
                21200, 21650, 22000, 22500, 22900, 23350, 23750, 24200, 24500, 25050, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        1275300, 1281620, 1287940, 1294250, 1300570, 1306890, 1313210, 1319530, 1325840, 1332160, 1338480, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 1338480,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
        {
            type = "reputation",
            id = 2410,
            amount = 1500,
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
            variations = {
                {
                    type = "quest",
                    id = 63212,
                    breadcrumb = true,
                },
                { -- When switching the other quest isnt done
                    type = "npc",
                    id = 171821,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58609,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59556,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61359,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62833,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62834,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62835,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62694,
            completed = {
                type = "quest",
                ids = {62699, 62835},
                count = 2,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62839,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62840,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61397,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
            completed = {
                {
                    type = "quest",
                    id = 61397,
                },
                {
                    type = "chain",
                    id = Chain.ReturnToTheMaw,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62845,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62846,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 63003,
                    restrictions = {
                        type = "quest",
                        id = 63001,
                    },
                },
                {
                    type = "quest",
                    id = 59596,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59597,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61388,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62848,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59609,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ReturnToTheMaw, {
    name = L["RETURN_TO_THE_MAW"],
    questline = 1087,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            upto = 61397,
        },
    },
    active = {
        type = "quest",
        id = 62843,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 62844, 62796, 62894, 62870 },
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        28575, 28600, 28600, 28650, 28650, 29150, 29700, 30150, 30700, 
                    },
                    minLevel = 51,
                    maxLevel = 59,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        27600, 28050, 28600, 29050, 29550, 
                    },
                    minLevel = 55,
                    maxLevel = 59,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        1057680, 1057915, 1058150, 1058380, 1058615, 1058850, 1068445, 1078040, 1087630, 1097225, 1106820, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        1060020, 1069380, 1078740, 1088100, 1097460, 1106820, 
                    },
                    minLevel = 55,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "currency",
            id = 1810,
            amount = 5,
        },
        {
            type = "reputation",
            id = 2432,
            amount = 20,
        },
    },
    items = {
        {
            type = "npc",
            id = 167748,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62843,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.TheMawEmbed,
            embed = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = { 62844, 62796, 62894, 62870 },
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHouseOfEyes, {
    name = L["THE_HOUSE_OF_EYES"],
    questline = 1088,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 60272,
        },
        {
            type = "renown",
            level = 5,
        },
    },
    active = {
        type = "quest",
        id = 59555,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57648,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                76175, 77625, 79150, 80750, 82350, 83800, 85400, 86900, 88300, 89850, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        2995200, 3025155, 3055110, 3085050, 3115005, 3144960, 3174915, 3204870, 3234810, 3264765, 3294720, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 3294720,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "npc",
            id = 161907,
            x = 0,
            connections = {
                1, 
            },
        },
        -- { -- Renown requirement
        --     type = "quest",
        --     id = 62448,
        --     x = 0,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 59555,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58007,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 57649,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 59265,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 61230,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61227,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61226,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61252,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61335,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 57644,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61323,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57648,
            x = 0,
        },
    },
})
Database:AddChain(Chain.GrandTheftNecropolis, {
    name = L["GRAND_THEFT_NECROPOLIS"],
    questline = 1134,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
        },
        {
            type = "renown",
            level = 8,
        },
    },
    active = {
        type = "quest",
        id = 57778,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {59722, 58820},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                55900, 57050, 58100, 59300, 60400, 61550, 62650, 63800, 64800, 65950, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        2808000, 2828360, 2848720, 2869070, 2889430, 2909790, 2930150, 2950510, 2970860, 2991220, 3011580, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 3011580,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "npc",
            id = 161907,
            x = 0,
            connections = {
                1, 
            },
        },
        -- { -- Renown requirement
        --     type = "quest",
        --     id = 62169,
        --     x = 0,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 57778,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61485,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61518,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60112,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61548,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61551,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61569,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61594,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 59722,
            x = -1,
        },
        {
            type = "quest",
            id = 61869,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58820,
            aside = true,
            x = 1,
        },
    },
})
Database:AddChain(Chain.DoNotForget, {
    name = L["DO_NOT_FORGET"],
    questline = 1119,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GrandTheftNecropolis,
        },
        {
            type = "renown",
            level = 11,
        },
    },
    active = {
        type = "quest",
        id = 59625,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59894,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                91625, 93425, 95250, 97050, 98950, 100750, 102650, 104500, 106200, 108000, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        3814200, 3852345, 3890490, 3928620, 3966765, 4004910, 4043055, 4081200, 4119330, 4157475, 4195620, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 4195620,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "npc",
            id = 161988,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59625,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 59645,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 59648,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 59650,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59653,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 59659,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 59678,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59698,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59700,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59709,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59748,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59922,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59894,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AGoldenDawn, {
    name = L["A_GOLDEN_DAWN"],
    questline = 1120,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GrandTheftNecropolis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DoNotForget,
        },
        {
            type = "renown",
            level = 13,
        },
    },
    active = {
        type = "quest",
        id = 61145,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57636,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                98400, 100150, 102150, 104200, 106400, 108150, 110350, 112200, 113900, 116100, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        4071600, 4109750, 4147900, 4186010, 4224160, 4262310, 4300460, 4338610, 4376720, 4414870, 4453020, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 4453020,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "npc",
            id = 166535,
            x = 0,
            connections = {
                1, 
            },
        },
        -- { -- Renown requirement
        --     type = "quest",
        --     id = 61586,
        --     x = 0,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 61145,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59910,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 59916,
            x = -2,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 60043,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 61396,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 60510,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61180,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 61412,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60050,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 60044,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 60114,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 61567,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61246,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60098,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60067,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57470,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57530,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57473,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57475,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57636,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheWagesOfSin, {
    name = L["THE_WAGES_OF_SIN"],
    questline = 1121,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GrandTheftNecropolis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DoNotForget,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AGoldenDawn,
        },
        {
            type = "renown",
            level = 17,
        },
    },
    active = {
        type = "quest",
        id = 58504,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 58624,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                43425, 44275, 45150, 45950, 46850, 47700, 48600, 49500, 50300, 51150, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        2012400, 2032525, 2052650, 2072770, 2092895, 2113020, 2133145, 2153270, 2173390, 2193515, 2213640, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 2213640,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "npc",
            id = 161907,
            x = 0,
            connections = {
                1, 
            },
        },
        -- { -- Renown requirement
        --     type = "quest",
        --     id = 62161,
        --     x = 0,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 58504,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58523,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58599,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58472,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58608,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58624,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheHouseOfRituals, {
    name = L["THE_HOUSE_OF_RITUALS"],
    questline = 1115,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GrandTheftNecropolis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DoNotForget,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AGoldenDawn,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheWagesOfSin,
        },
        {
            type = "renown",
            level = 20,
        },
    },
    active = {
        type = "quest",
        id = 61739,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 61761,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                173550, 176950, 180350, 184000, 187550, 190950, 194500, 198000, 201150, 204700, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        6575400, 6641160, 6706920, 6772650, 6838410, 6904170, 6969930, 7035690, 7101420, 7167180, 7232940, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 7232940,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "npc",
            id = 173172,
            x = 0,
            connections = {
                1, 
            },
        },
        -- { -- Renown requirement
        --     type = "quest",
        --     id = 62388,
        --     x = 0,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 61739,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 61740,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61741,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62414,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61742,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 61743,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62297,
            aside = true,
        },
        {
            type = "quest",
            id = 61744,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61745,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 61746,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 61747,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61748,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 61749,
            x = -1,
            connections = {
                2, 3, 4
            },
        },
        {
            type = "quest",
            id = 62317,
            aside = true,
        },
        {
            type = "quest",
            id = 61750,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61751,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62320,
            aside = true,
        },
        {
            type = "quest",
            id = 61752,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61753,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 61754,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 61755,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 61756,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62308,
            aside = true,
        },
        {
            type = "quest",
            id = 61757,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61758,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61759,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61760,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61761,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AssaultOnTheHouseOfRituals, {
    name = L["ASSAULT_ON_THE_HOUSE_OF_RITUALS"],
    questline = 1118,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.GrandTheftNecropolis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DoNotForget,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AGoldenDawn,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheWagesOfSin,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfRituals,
        },
        {
            type = "renown",
            level = 22,
        },
    },
    active = {
        type = "quest",
        id = 58833,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 62406,
    },
    rewards = {
        {
            name = L["SOULBIND_BONESMITH_HEIRMIR"],
            type = "spell",
            id = 344969,
        },
        {
            type = "experience",
            amounts = {
                23150, 23600, 24050, 24550, 25000, 25450, 25900, 26400, 26800, 27300, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        1825200, 1835730, 1846260, 1856790, 1867320, 1877850, 1888380, 1898910, 1909440, 1919970, 1930500, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 1930500,
                },
            },
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "npc",
            id = 161907,
            x = 0,
            connections = {
                1, 
            },
        },
        -- {
        --     type = "quest",
        --     id = 62391,
        --     x = 0,
        --     connections = {
        --         1, 
        --     },
        -- },
        {
            type = "quest",
            id = 58833,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59020,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62406,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60111,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = {
        type = "garrisontalenttree",
        id = 310,
    },
    questline = 1040,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            upto = 62846,
            lowPriority = true,
        },
        {
            type = "garrisontalenttree",
            id = 310,
            rank = 1,
        },
    },
    active = {
        type = "quest",
        id = 63055,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63059,
    },
    rewards = {
        {
            type = "money",
            amount = 154440,
        },
    },
    items = {
        {
            type = "npc",
            id = 161909,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63055,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63059,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = {
        type = "garrisontalenttree",
        id = 313,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            upto = 62846,
            lowPriority = true,
        },
        {
            type = "garrisontalenttree",
            id = 313,
            rank = 1,
        },
    },
    active = {
        type = "quest",
        id = 63057,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 60722,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                3850, 3950, 4000, 4100, 4150, 4250, 4300, 4400, 4450, 4550, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        245700, 246870, 248040, 249210, 250380, 251550, 252720, 253890, 255060, 256230, 257400, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 257400,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 161909,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63057,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60722,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = {
        type = "garrisontalenttree",
        id = 318,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
            upto = 62846,
            lowPriority = true,
        },
        {
            type = "garrisontalenttree",
            id = 318,
            rank = 1,
        },
    },
    active = {
        type = "quest",
        id = 63054,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59603,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                3850, 3950, 4000, 4100, 4150, 4250, 4300, 4400, 4450, 4550, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        245700, 246870, 248040, 249210, 250380, 251550, 252720, 253890, 255060, 256230, 257400, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 257400,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 161909,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63054,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59603,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = {
        type = "garrisontalenttree",
        id = 321,
    },
    questline = 1089,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "covenant",
            id = 4,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
        },
    },
    active = {
        type = "quest",
        id = 58665,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 60042,
    },
    rewards = {
        {
            name = L["SOULBIND_PRINCESS_EMENI"],
            type = "spell",
            id = 344968,
        },
        {
            type = "experience",
            amounts = {
                67450, 68850, 70050, 71600, 72900, 74300, 75600, 77000, 78100, 79650, 
            },
            minLevel = 50,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        2199600, 2221600, 2243600, 2265580, 2287580, 2309580, 2331580, 2353580, 2375560, 2397560, 2419560, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 2419560,
                },
            },
        },
        {
            type = "reputation",
            id = 2462,
            amount = 275,
        },
    },
    items = {
        {
            type = "npc",
            id = 162222,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58665,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58668,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58680,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58677,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58686,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59042,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 58670,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 58671,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58727,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            visible = false,
            x = -3,
        },
        {
            type = "quest",
            id = 60048,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 60049,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
            aside = true,
            connections = {
                2, 
            },
        },
        { -- Unlocks Abomination Stitching
            type = "quest",
            id = 60041,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Requires quest 57648
            type = "quest",
            id = 60110,
            x = 2,
            aside = true,
        },
        {
            type = "quest",
            id = 60042,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60195,
            aside = true,
            x = -1,
        },
    },
})
Database:AddChain(Chain.TempChain12, {
    name = "Adventurer: Secutor Mevix",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "renown",
            level = 4,
            x = 0,
        },
        {
            type = "npc",
            id = 165321,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62309,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.TempChain13, {
    name = "Adventurer: Gunn Gorgebone",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        {
            type = "quest",
            id = 59722,
            x = -1,
            comment = "One of these 2",
        },
        {
            type = "quest",
            id = 61869,
        },
        {
            type = "npc",
            id = 165321,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62312,
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
            type = "quest",
            id = 59722,
            x = -1,
            comment = "One of these 2",
        },
        {
            type = "quest",
            id = 61869,
        },
        {
            type = "npc",
            id = 173306,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60184,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.TempChain15, {
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
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = L["NECROLORD_CAMPAIGN"],
    expansion = EXPANSION_ID,
    buttonImage = "Interface\\AddOns\\BtWQuestsShadowlands\\UI-Chain-Covenant-Necrolord",
    items = {
        {
            type = "chain",
            id = Chain.LoyalToThePrimus,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfEyes,
        },
        {
            type = "chain",
            id = Chain.GrandTheftNecropolis,
        },
        {
            type = "chain",
            id = Chain.DoNotForget,
        },
        {
            type = "chain",
            id = Chain.AGoldenDawn,
        },
        {
            type = "chain",
            id = Chain.TheWagesOfSin,
        },
        {
            type = "chain",
            id = Chain.TheHouseOfRituals,
        },
        {
            type = "chain",
            id = Chain.AssaultOnTheHouseOfRituals,
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
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
    restrictions = {
        type = "covenant",
        ids = {1, 2, 3},
    },
})
