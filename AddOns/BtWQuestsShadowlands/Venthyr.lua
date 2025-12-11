local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.Venthyr
local Chain = BtWQuests.Constant.Chain.Shadowlands.Venthyr
local LEVEL_RANGE = {60, 60}

Database:AddChain(Chain.Sinfall, {
    name = L["SINFALL"],
    questline = 1065,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
        },
    },
    active = {
        type = "quest",
        ids = {
            63215, 59314, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 62921,
    },
    rewards = {
        {
            name = L["SOULBIND_NADJIA_THE_MISTBLADE"],
            type = "spell",
            id = 307337,
        },
        {
            type = "experience",
            amounts = {
                40550, 41350, 42050, 42850, 43700, 44500, 45350, 46200, 46700, 47850, 
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
                        1621620, 1637070, 1652520, 1667940, 1683390, 1698840, 1714290, 1729740, 1745160, 1760610, 1776060, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 1776060,
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
            id = 2413,
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
                    id = 63215,
                    breadcrumb = true,
                },
                { -- When switching the other quest isnt done
                    type = "npc",
                    id = 171589,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59314,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59315,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59321,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59323,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62856,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62857,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62695,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62691,
            completed = {
                type = "quest",
                ids = {62699, 62695},
                count = 2,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62902,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62903,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62904,
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
                    id = 62904,
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
            id = 62914,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62915,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62918,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62919,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62920,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62921,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ReturnToTheMaw, {
    name = L["RETURN_TO_THE_MAW"],
    questline = 1065,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 62904,
        },
    },
    active = {
        type = "quest",
        id = 62905,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 62870, 62796, 62844, 62894 },
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        30525, 30600, 30600, 30750, 30750, 31350, 31900, 32350, 33000, 
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
                        1053000, 1053705, 1054410, 1055100, 1055805, 1056510, 1066575, 1076640, 1086690, 1096755, 1106820, 
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
            id = 164738,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62905,
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
            ids = { 62870, 62796, 62844, 62894 },
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheCourtOfHarvesters, {
    name = L["THE_COURT_OF_HARVESTERS"],
    questline = 1069,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
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
        ids = {
            59701, 61492, 59343, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 59343,
    },
    rewards = {
        {
            name = L["SOULBIND_THEOTAR"],
            type = "spell",
            id = 345654,
        },
        {
            type = "money",
            amount = 1518660,
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
            id = 158653,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 161977,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59701,
            x = -1,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 61492,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 59708,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 59706,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 59707,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 59720,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 59676,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59711,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59719,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 161979,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59343,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Desire, {
    name = L["DESIRE"],
    questline = 1039,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 59324,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCourtOfHarvesters,
            upto = 59719,
        },
        {
            type = "renown",
            level = 8,
        },
    },
    active = {
        type = "quest",
        id = 60904,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57893,
    },
    rewards = {
        {
            name = L["THE_EMBER_COURT_RSVP_THE_COUNTESS"],
            type = "spell",
            id = 335254,
        },
        {
            type = "money",
            amount = 4427280,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "object",
            id = 353948,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60904,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57880,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57881,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57882,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57884,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57885,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57886,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57887,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57888,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57889,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57890,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57891,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57892,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57893,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Avarice, {
    name = L["AVARICE"],
    questline = 1024,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 59324,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCourtOfHarvesters,
            upto = 59719,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Desire,
        },
        {
            type = "renown",
            level = 11,
        },
    },
    active = {
        type = "quest",
        id = 60935,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 58444,
    },
    rewards = {
        {
            type = "money",
            amount = 3886740,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
    },
    items = {
        {
            type = "object",
            id = 353949,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60935,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58842,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 58326,
            x = -2,
            connections = {
                4, 5, 6,
            },
        },
        {
            type = "quest",
            id = 58325,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58337,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 58372,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 58424,
            x = -2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 58421,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58428,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 60673,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58440,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58444,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheCrownedPrince, {
    name = L["THE_CROWNED_PRINCE"],
    questline = 1026,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 59324,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCourtOfHarvesters,
            upto = 59719,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Desire,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Avarice,
        },
        {
            type = "renown",
            level = 13,
        },
    },
    active = {
        type = "quest",
        id = 61050,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59233,
    },
    rewards = {
        {
            type = "money",
            amount = 4813380,
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
            id = 158653,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 61050,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58530,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58555,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 58584,
            x = -2,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 58585,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 58586,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58600,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58603,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58630,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58656,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60993,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 60994,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 60995,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60996,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59233,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ConfrontingSin, {
    name = L["CONFRONTING_SIN"],
    questline = 1017,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 59324,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCourtOfHarvesters,
            upto = 59719,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Desire,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Avarice,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCrownedPrince,
        },
        {
            type = "renown",
            level = 17,
        },
    },
    active = {
        type = "quest",
        id = 61077,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 58395,
    },
    rewards = {
        {
            type = "money",
            amount = 4324320,
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
            id = 158653,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 61077,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58382,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58383,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58426,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 58384,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 58385,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58386,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58387,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58443,
            x = -1,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "kill",
            id = 161469,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 58388,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 58389,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58518,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58391,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58392,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58393,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58394,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58395,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Envy, {
    name = L["ENVY"],
    questline = 1041,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 59324,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCourtOfHarvesters,
            upto = 59719,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Desire,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Avarice,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCrownedPrince,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ConfrontingSin,
        },
        {
            type = "renown",
            level = 20,
        },
    },
    active = {
        type = "quest",
        id = 57727,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 57646,
    },
    rewards = {
        {
            type = "money",
            amount = 2625480,
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
            id = 158653,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57727,
            x = 0,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 57771,
            x = -3,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 57772,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 60145,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 60265,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60183,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57729,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57646,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Dominion, {
    name = L["DOMINION"],
    questline = 1018,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 59324,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCourtOfHarvesters,
            upto = 59719,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Desire,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Avarice,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheCrownedPrince,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ConfrontingSin,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Envy,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Revendreth.Chain05,
        },
        {
            type = "renown",
            level = 22,
        },
    },
    active = {
        type = "quest",
        ids = {
            58406, 59325, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 58407,
    },
    rewards = {
        {
            name = L["SOULBIND_GENERAL_DRAVEN"],
        },
        {
            type = "experience",
            amounts = {
                975, 1000, 1000, 1050, 1050, 1100, 1100, 1100, 1150, 
            },
            minLevel = 51,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        821340, 821575, 821810, 822040, 822275, 822510, 822745, 822980, 823210, 823445, 823680, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 823680,
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
            id = 158653,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58406,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 58407,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 161977,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59325,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain01, {
    name = {
        type = "garrisontalenttree",
        id = 309,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 62915,
            lowPriority = true,
        },
        {
            type = "garrisontalenttree",
            id = 309,
            rank = 1,
        },
        {
            type = "chain",
            id = 90415,
        },
    },
    active = {
        type = "quest",
        ids = { 60060, 60147, 60159, 60160, 60164, 60165, },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = { 60060, 60147, 60159, 60160, 60164, 60165, },
        count = 6,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5850, 6000, 6000, 6300, 6300, 6600, 6600, 6600, 6900, 
                    },
                    minLevel = 51,
                    maxLevel = 59,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        6600, 6900, 
                    },
                    minLevel = 58,
                    maxLevel = 59,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        140400, 141810, 143220, 144600, 146010, 147420, 148830, 150240, 151620, 153030, 154440, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        151620, 153030, 154440, 
                    },
                    minLevel = 58,
                    maxLevel = 60,
                },
            },
        },
    },
    items = {
        {
            type = "garrisontalenttree",
            id = 309,
            rank = 1,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 167160,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60060,
            x = -1,
        },
        {
            type = "quest",
            id = 60147,
        },
        {
            type = "garrisontalenttree",
            id = 309,
            rank = 2,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 167160,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60159,
            x = -1,
        },
        {
            type = "quest",
            id = 60160,
        },
        {
            type = "garrisontalenttree",
            id = 309,
            rank = 3,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 167160,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 60164,
            x = -1,
        },
        {
            type = "quest",
            id = 60165,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = {
        type = "garrisontalenttree",
        id = 314,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 62915,
            lowPriority = true,
        },
        {
            type = "garrisontalenttree",
            id = 314,
            rank = 1,
        },
    },
    active = {
        type = "quest",
        id = 63066,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 60721,
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
            id = 172605,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63066,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60721,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain03, {
    name = {
        type = "garrisontalenttree",
        id = 317,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 62915,
            lowPriority = true,
        },
        {
            type = "garrisontalenttree",
            id = 317,
            rank = 1,
        },
    },
    active = {
        type = "quest",
        id = 63064,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 59319,
    },
    rewards = {
        {
            type = "experience",
            amounts = {
                975, 1000, 1000, 1050, 1050, 1100, 1100, 1100, 1150, 
            },
            minLevel = 51,
            maxLevel = 59,
            restrictions = 86994,
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        49140, 49375, 49610, 49840, 50075, 50310, 50545, 50780, 51010, 51245, 51480, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 51480,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 172605,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63064,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59319,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain04, {
    name = {
        type = "garrisontalenttree",
        id = 324,
    },
    questline = 1196,
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
            id = 2,
        },
        {
            type = "quest",
            ids = {57878, 62000},
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Sinfall,
            upto = 62915,
            lowPriority = true,
        },
        {
            type = "garrisontalenttree",
            id = 324,
            rank = 1,
        },
    },
    active = {
        type = "quest",
        id = 59660,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 61616,
    },
    rewards = {
        {
            type = "money",
            amount = 3088800,
        },
    },
    items = {
        {
            type = "npc",
            id = 161979,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 59660,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = 90417,
            upto = 57927,
            x = -3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 59661,
            x = 0,
            connections = {
                2, 3, 4
            },
        },
        {
            type = "chain",
            id = 90417,
            x = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61704,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 61705,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 61706,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 61404,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 61880,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 61884,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 61882,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61616,
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
    name = L["VENTHYR_CAMPAIGN"],
    expansion = EXPANSION_ID,
    buttonImage = "Interface\\AddOns\\BtWQuestsShadowlands\\UI-Chain-Covenant-Venthyr",
    items = {
        {
            type = "chain",
            id = Chain.Sinfall,
        },
        {
            type = "chain",
            id = Chain.ReturnToTheMaw,
        },
        {
            type = "chain",
            id = Chain.TheCourtOfHarvesters,
        },
        {
            type = "chain",
            id = Chain.Desire,
        },
        {
            type = "chain",
            id = Chain.Avarice,
        },
        {
            type = "chain",
            id = Chain.TheCrownedPrince,
        },
        {
            type = "chain",
            id = Chain.ConfrontingSin,
        },
        {
            type = "chain",
            id = Chain.Envy,
        },
        {
            type = "chain",
            id = Chain.Dominion,
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
        ids = {1, 3, 4},
    },
})
