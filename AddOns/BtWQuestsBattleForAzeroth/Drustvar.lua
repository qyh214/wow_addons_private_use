local BtWQuests = BtWQuests;
local L = BtWQuests.L;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.BattleForAzeroth;
local CATEGORY_ID = BtWQuests.Constant.Category.BattleForAzeroth.Drustvar;
local Chain = BtWQuests.Constant.Chain.BattleForAzeroth.Drustvar;
local ALLIANCE_ID, HORDE_ID = BtWQuests.Constant.Faction.Alliance, BtWQuests.Constant.Faction.Horde;
local MAP_ID = 896
local ACHIEVEMENT_ID = 12497
local CONTINENT_ID = 876

BtWQuestsDatabase:AddChain(Chain.TheFinalEffigy, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40168,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.BattleForAzeroth.AllianceIntroduction,
        },
    },
    active = {
        type = "quest",
        id = 47961,
        status = {"active", "completed"},
    },
    completed = {
        type = "quest",
        id = 47982,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                570600, 607680, 644760, 681840, 718920, 756000, 802660, 849310, 895970, 942620, 989280, 1035940, 1082590, 1129250, 1175900, 1222560, 1269220, 1315870, 1362530, 1409180, 1455840, 1501630, 1547420, 1593220, 1639010, 1684800, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                19380, 20150, 20870, 21630, 22500, 23125, 23875, 24750, 25375, 26125, 27000, 27775, 28475, 29250, 30025, 30725, 31500, 32275, 32975, 33750, 34625, 35375, 36000, 36875, 37625, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "quest",
            id = 47961,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            ids = {48622, 53434},
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        -- { -- Removed?
        --     type = "quest",
        --     id = 47969,
        --     aside = true,
        --     x = 1,
        --     y = 2,
        -- },
        {
            type = "quest",
            id = 47968,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47978,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 47979,
            x = 1,
            y = 4,
        },
        {
            type = "quest",
            id = 47981,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 47980,
            x = 5,
            y = 4,
        },
        {
            type = "quest",
            id = 47982,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
            aside = true,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.TheBurdenOfProof, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40169,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
    },
    active = {
        type = "chain",
        id = Chain.TheFinalEffigy,
    },
    completed = {
        type = "quest",
        id = 48198,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                697400, 742720, 788040, 833360, 878680, 924000, 981030, 1038045, 1095075, 1152090, 1209120, 1266150, 1323165, 1380195, 1437210, 1494240, 1551270, 1608285, 1665315, 1722330, 1779360, 1835325, 1891290, 1947270, 2003235, 2059200, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                27990, 29200, 30110, 31290, 32500, 33375, 34525, 35750, 36625, 37775, 39000, 40175, 41075, 42250, 43425, 44325, 45500, 46675, 47575, 48750, 49975, 51125, 52000, 53275, 54375, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 165,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
            x = 3,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51547,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 48108,
            x = 2,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "chain",
            id = Chain.Chain07,
            x = 4,
            y = 1,
        },
        {
            type = "chain",
            id = Chain.Chain06,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 48283,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48109,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48110,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48111,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 48113,
            x = 0,
            y = 5,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 48170,
            x = 2,
            y = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48165,
            x = 4,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49242,
            aside = true,
            x = 6,
            y = 5,
        },
        {
            type = "quest",
            id = 48198,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
            aside = true,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.AnAirtightAlibi, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40170,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
    },
    active = {
        type = "chain",
        id = Chain.TheBurdenOfProof,
    },
    completed = {
        type = "quest",
        id = 48538,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                249675, 259975, 270275, 280575, 290875, 301175, 311475, 321775, 332075, 342375, 352675, 362975, 373275, 383575, 393875, 404175, 1001040, 1064385, 1127730, 1191075, 1254420, 1324550, 1404255, 1483955, 1563660, 1643360, 1723070, 1802775, 1882475, 1962180, 2041880, 2121590, 2201295, 2280995, 2360700, 2440400, 2519495, 2597720, 2675950, 2754185, 2819690, 1684800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                30790, 31090, 31390, 31590, 31890, 32190, 32490, 32690, 32990, 33290, 33490, 33790, 34090, 34290, 34590, 34890, 36300, 37560, 38940, 40500, 41625, 42975, 44550, 45675, 47025, 48600, 50025, 51225, 52650, 54075, 55275, 56700, 58125, 59325, 60750, 62325, 63675, 64800, 66375, 67725, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48171,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48518,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49295,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48519,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 48521,
            x = 0,
            y = 4,
            connections = {
                4, 5,
            },
        },
        {
            type = "quest",
            id = 48520,
            x = 2,
            y = 4,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 48522,
            x = 4,
            y = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 48525,
            aside = true,
            x = 6,
            y = 4,
        },
        {
            type = "quest",
            id = 48523,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48524,
            x = 4,
            y = 5,
        },
        {
            type = "quest",
            id = 48538,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
            aside = true,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.TheOrderOfEmbers, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40171,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
    },
    active = {
        type = "chain",
        id = Chain.AnAirtightAlibi,
    },
    completed = {
        type = "quest",
        id = 48946,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                879675, 936840, 994005, 1051170, 1108335, 1165500, 1237430, 1309355, 1381285, 1453210, 1525140, 1597070, 1668995, 1740925, 1812850, 1884780, 1956710, 2028635, 2100565, 2172490, 2244420, 2315015, 2385610, 2456210, 2526805, 2597400, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                30580, 31850, 32870, 34130, 35450, 36475, 37725, 39050, 40025, 41275, 42600, 43875, 44875, 46150, 47425, 48425, 49700, 50975, 51975, 53250, 54575, 55825, 56800, 58125, 59375, 
            },
            minLevel = 25,
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
    },
    items = {
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49259,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48941,
            x = 3,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "chain",
            id = Chain.Chain09,
            relationship = {
                breadcrumb = 48947,
                blocker = 52074,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 5,
            y = 2,
        },
        {
            type = "quest",
            id = 48942,
            x = 2,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48943,
            x = 4,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51134,
            aside = true,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 48963,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48944,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48945,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48946,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
            aside = true,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.ANewOrder, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40172,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
    },
    active = {
        type = "chain",
        id = Chain.TheOrderOfEmbers,
    },
    completed = {
        type = "quest",
        id = 49807,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                602300, 641440, 680580, 719720, 758860, 798000, 847250, 896495, 945745, 994990, 1044240, 1093490, 1142735, 1191985, 1241230, 1290480, 1339730, 1388975, 1438225, 1487470, 1536720, 1585055, 1633390, 1681730, 1730065, 1778400, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                20600, 21500, 22250, 23150, 24000, 24650, 25550, 26400, 27050, 27950, 28800, 29550, 30450, 31200, 31950, 32850, 33600, 34350, 35250, 36000, 36850, 37750, 38400, 39400, 40150, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 265,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 3775,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48986,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        { -- Didnt really fit anywhere
            type = "quest",
            id = 52033,
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 49443,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 49805,
            aside = true,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 49804,
            x = 2,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 49803,
            x = 4,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49806,
            aside = true,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 49807,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = Chain.BreakOnThrough,
            aside = true,
            x = 2,
            y = 5,
        },
        {
            type = "chain",
            id = Chain.Chain01,
            aside = true,
            x = 4,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.BreakOnThrough, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40173,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
    },
    active = {
        type = "chain",
        id = Chain.ANewOrder,
    },
    completed = {
        type = "quest",
        id = 50457,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                487425, 497725, 508025, 518325, 528625, 538925, 549225, 559525, 569825, 580125, 590425, 600725, 611025, 621325, 631625, 641925, 1761440, 1873195, 1984950, 2096705, 2208460, 2330990, 2471605, 2612220, 2752835, 2893450, 3034070, 3174685, 3315300, 3455915, 3596530, 3737150, 3877765, 4018380, 4158995, 4299610, 4439255, 4577265, 4715280, 4853295, 4978585, 3182400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                57910, 58210, 58510, 58710, 59010, 59310, 59610, 59810, 60110, 60410, 60610, 60910, 61210, 61410, 61710, 62010, 64600, 66690, 69260, 71950, 73950, 76500, 79200, 81150, 83700, 86400, 88950, 91050, 93600, 96150, 98250, 100800, 103350, 105450, 108000, 110700, 113250, 115200, 117950, 120450, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 240,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 1505,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.ANewOrder,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49926,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50003,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50149,
            x = 3,
            y = 3,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 50152,
            x = 0,
            y = 4,
        },
        {
            type = "quest",
            id = 50151,
            x = 2,
            y = 4,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50173,
            x = 4,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50175,
            x = 6,
            y = 3.5,
        },
        {
            type = "quest",
            id = 50174,
            x = 6,
            y = 4.5,
        },


        {
            type = "quest",
            id = 50253,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3, 4, 5, 6,
            },
        },


        {
            type = "quest",
            id = 51356,
            x = 0,
            y = 5.5,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            x = 0,
            y = 6.5,
        },
        {
            type = "quest",
            id = 50446,
            x = 2,
            y = 6,
            connections = {
                4, 5,
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            aside = true,
            x = 4,
            y = 6,
        },
        {
            type = "quest",
            id = 50448,
            x = 6,
            y = 5.5,
        },
        {
            type = "quest",
            id = 50447,
            x = 6,
            y = 6.5,
        },


        {
            type = "quest",
            id = 50453,
            x = 2,
            y = 7,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50454,
            x = 4,
            y = 7,
        },

        {
            type = "quest",
            id = 50456,
            x = 0,
            y = 7.5,
        },
        {
            type = "quest",
            id = 50455,
            x = 6,
            y = 7.5,
        },

        {
            type = "quest",
            id = 50457,
            x = 2,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.StormingTheManor,
            aside = true,
            x = 2,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.StormingTheManor, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40174,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
        {
            type = "chain",
            id = Chain.BreakOnThrough,
        },
    },
    active = {
        type = "chain",
        id = Chain.BreakOnThrough,
    },
    completed = {
        type = "quest",
        id = 50588,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                681550, 725840, 770130, 814420, 858710, 903000, 958730, 1014455, 1070185, 1125910, 1181640, 1237370, 1293095, 1348825, 1404550, 1460280, 1516010, 1571735, 1627465, 1683190, 1738920, 1793615, 1848310, 1903010, 1957705, 2012400, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                36630, 38100, 39320, 40930, 42350, 43725, 45175, 46600, 47975, 49425, 51000, 52425, 53675, 55250, 56675, 58075, 59500, 60925, 62325, 63750, 65325, 66775, 68000, 69625, 71025, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 600,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 1275,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.BreakOnThrough,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 50583,
            x = 0,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50585,
            x = 2,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50584,
            x = 4,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50586,
            x = 6,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            ids = {50588, 51851, 51852},
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50639,
            aside = true,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49898,
            aside = true,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52149,
            aside = true,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53109,
            aside = true,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.Drustfall, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40175,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 49898,
        status = {"active", "completed"},
    },
    completed = {
        type = "quest",
        id = 49898,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                79250, 84400, 89550, 94700, 99850, 105000, 111480, 117960, 124440, 130920, 137400, 143880, 150360, 156840, 163320, 169800, 176280, 182760, 189240, 195720, 202200, 208560, 214920, 221280, 227640, 234000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 150,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 135085,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49898,
            x = 3,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.FightingWithFire, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40176,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
    },
    active = {
        type = "chain",
        id = Chain.Chain01,
    },
    completed = {
        type = "quest",
        id = 50063,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                804425, 814725, 825025, 835325, 845625, 855925, 866225, 876525, 886825, 897125, 907425, 917725, 928025, 938325, 948625, 958925, 1258990, 1336755, 1414520, 1492285, 1570050, 1663910, 1761755, 1859605, 1957450, 2055300, 2153150, 2250995, 2348845, 2446690, 2544540, 2642390, 2740235, 2838085, 2935930, 3033780, 3130175, 3226210, 3322250, 3418285, 3501600, 702000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                43300, 43600, 43900, 44100, 44400, 44700, 45000, 45200, 45500, 45800, 46000, 46300, 46600, 46800, 47100, 47400, 49400, 50900, 52900, 54950, 56450, 58450, 60500, 61950, 63950, 66000, 68000, 69500, 71500, 73500, 75000, 77000, 79000, 80500, 82500, 84550, 86550, 88000, 90050, 92050, 
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
            id = 2161,
            amount = 1225,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.Chain01,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50001,
            x = 2,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50251,
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            id = 50177,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50091,
            aside = true,
            x = 1,
            y = 3,
        },
        {
            type = "quest",
            id = 49939,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },

        {
            type = "quest",
            id = 51390,
            x = 1,
            y = 4,
        },
        {
            type = "quest",
            id = 50903,
            x = 3,
            y = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 50238,
            x = 5,
            y = 4,
        },

        {
            type = "quest",
            id = 50090,
            x = 2,
            y = 5,
        },
        {
            type = "quest",
            id = 50092,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 50036,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50063,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.StickItToEm,
            aside = true,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.StickItToEm, {
    name = {
        type = "achievement",
        id = ACHIEVEMENT_ID,
        criteriaId = 40177,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    major = true,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.FightingWithFire,
        },
    },
    active = {
        type = "chain",
        id = Chain.FightingWithFire,
    },
    completed = {
        type = "quest",
        id = 50533,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                974775, 1038120, 1101465, 1164810, 1228155, 1291500, 1371210, 1450905, 1530615, 1610310, 1690020, 1769730, 1849425, 1929135, 2008830, 2088540, 2168250, 2247945, 2327655, 2407350, 2487060, 2565285, 2643510, 2721750, 2799975, 2878200, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                37910, 39450, 40790, 42310, 44000, 45200, 46700, 48400, 49600, 51100, 52800, 54350, 55650, 57200, 58750, 60050, 61600, 63150, 64450, 66000, 67700, 69200, 70400, 72100, 73600, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 1085,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.FightingWithFire,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50172,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50265,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50306,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50266,
            x = 5,
            y = 2,
        },
        {
            type = "quest",
            id = 50327,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50370,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 50329,
            x = 0,
            y = 5,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50325,
            x = 2,
            y = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50445,
            x = 4,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50530,
            x = 6,
            y = 5,
            connections = {
                1,
            },
        },

        {
            type = "quest",
            id = 50481,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50533,
            x = 3,
            y = 7,
        },
    },
})
-- Completed, Alliance only, requires A new order, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain01, {
    name = { -- Drustfall
        type = "quest",
        id = 49890,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
    },
    active = {
        type = "chain",
        id = Chain.ANewOrder,
    },
    completed = {
        type = "quest",
        id = 49896,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                332850, 354480, 376110, 397740, 419370, 441000, 468220, 495430, 522650, 549860, 577080, 604300, 631510, 658730, 685940, 713160, 740380, 767590, 794810, 822020, 849240, 875950, 902660, 929380, 956090, 982800, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                15080, 15700, 16220, 16830, 17500, 17975, 18575, 19250, 19725, 20325, 21000, 21625, 22125, 22750, 23375, 23875, 24500, 25125, 25625, 26250, 26925, 27525, 28000, 28675, 29275, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 320,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.ANewOrder,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48504,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48184,
            x = 2,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48517,
            x = 4,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.Drustfall,
            x = 6,
            y = 2,
        },
        {
            type = "quest",
            id = 49890,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49896,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.FightingWithFire,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, Alliance Only, requires part way through Break on Through, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain02, {
    name = { -- Potent Protection
        type = "quest",
        id = 50452,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
        {
            type = "quest",
            id = 50253,
        },
    },
    active = {
        type = "quest",
        id = 50449,
        status = {"active", "completed"},
    },
    completed = {
        type = "quest",
        id = 50452,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                174350, 185680, 197010, 208340, 219670, 231000, 245260, 259510, 273770, 288020, 302280, 316540, 330790, 345050, 359300, 373560, 387820, 402070, 416330, 430580, 444840, 458830, 472820, 486820, 500810, 514800, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                7760, 8100, 8340, 8660, 9000, 9250, 9550, 9900, 10150, 10450, 10800, 11150, 11350, 11700, 12050, 12250, 12600, 12950, 13150, 13500, 13850, 14150, 14400, 14750, 15050, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 235,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.BreakOnThrough,
            completed = {
                type = "quest",
                id = 50253,
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 131639,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50449,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50451,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50450,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50452,
            x = 3,
            y = 4,
        },
    },
})
-- Completed, Alliance Only, requires part way through Break on Through, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain03, {
    name = { -- To Have Loved and Lost
        type = "quest",
        id = 50754,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
        {
            type = "quest",
            id = 50253,
        },
    },
    active = {
        type = "chain",
        id = Chain.BreakOnThrough,
    },
    completed = {
        type = "quest",
        id = 50763,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                451725, 481080, 510435, 539790, 569145, 598500, 635440, 672370, 709310, 746240, 783180, 820120, 857050, 893990, 930920, 967860, 1004800, 1041730, 1078670, 1115600, 1152540, 1188790, 1225040, 1261300, 1297550, 1333800, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                16780, 17500, 18070, 18780, 19500, 20025, 20725, 21450, 21975, 22675, 23400, 24075, 24675, 25350, 26025, 26625, 27300, 27975, 28575, 29250, 29975, 30675, 31200, 31975, 32625, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 470,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.BreakOnThrough,
            completed = {
                type = "quest",
                id = 50253,
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50754,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50758,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50759,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50760,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50761,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50762,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50763,
            x = 3,
            y = 7,
        },
    },
})
-- Completed, Alliance only, No requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain04, {
    name = { -- A Farmer's Fate
        type = "quest",
        id = 50970,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {50970, 50967, 50965},
        status = {"active", "completed"},
    },
    completed = {
        {
            type = "quest",
            id = 50970,
        },
        {
            type = "quest",
            id = 50967,
        },
        {
            type = "quest",
            id = 50965,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                11200, 11650, 12050, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20450, 20800, 21300, 21750, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 225,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 135976,
            x = 2,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "kill",
            id = 135901,
            x = 5,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50970,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 50967,
            x = 3,
            y = 1,
        },
        {
            type = "quest",
            id = 50965,
            x = 5,
            y = 1,
        },
    },
})
-- Completed, Alliance only, No requirements, No breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain05, {
    name = { -- Wicker Worship
        type = "quest",
        id = 48677,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 48677,
        status = {"active", "completed"},
    },
    completed = {
        type = "quest",
        id = 48683,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                202125, 212425, 222725, 233025, 243325, 253625, 263925, 274225, 284525, 294825, 305125, 315425, 325725, 336025, 346325, 356625, 546225, 580215, 614205, 648195, 682185, 722160, 764930, 807695, 850465, 893230, 936000, 978770, 1021535, 1064305, 1107070, 1149840, 1192610, 1235375, 1278145, 1320910, 1363140, 1405115, 1447090, 1489070, 1518325, 491400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                15700, 16000, 16300, 16500, 16800, 17100, 17400, 17600, 17900, 18200, 18400, 18700, 19000, 19200, 19500, 19800, 20650, 21300, 22150, 23000, 23600, 24450, 25300, 25900, 26750, 27600, 28400, 29100, 29900, 30700, 31400, 32200, 33000, 33700, 34500, 35350, 36200, 36800, 37700, 38500, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "npc",
            id = 127296,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48677,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48678,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48679,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48680,
            x = 4,
            y = 3,
        },
        {
            type = "quest",
            id = 48682,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48683,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, alliance only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(Chain.Chain06, {
    name = { -- To Market, To Market
        type = "quest",
        id = 47945,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {47945, 47946, 47947, 47948, 47949},
        status = {"active", "completed"},
    },
    completed = {
        type = "quest",
        ids = {47946, 47947, 47948, 47950},
        count = 4,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                404175, 430440, 456705, 482970, 509235, 535500, 568550, 601595, 634645, 667690, 700740, 733790, 766835, 799885, 832930, 865980, 899030, 932075, 965125, 998170, 1031220, 1063655, 1096090, 1128530, 1160965, 1193400, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                15080, 15700, 16220, 16830, 17500, 17975, 18575, 19250, 19725, 20325, 21000, 21625, 22125, 22750, 23375, 23875, 24500, 25125, 25625, 26250, 26925, 27525, 28000, 28675, 29275, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "object",
            id = 277459,
            x = 0,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 47945,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 124786,
                }
            },
            x = 4,
            y = 0,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 47949,
            x = 0,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 47946,
        },
        {
            type = "quest",
            id = 47947,
        },
        {
            type = "quest",
            id = 47948,
        },
        {
            type = "quest",
            id = 47950,
            x = 0,
        },
    },
})
-- Completed, Alliance only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(Chain.Chain07, {
    name = { -- The Adventurer's Society
        type = "quest",
        id = 48793,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48792,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 48793,
            status = {"active", "completed"},
        },
    },
    completed = {
        type = "quest",
        id = 48853,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                18100, 18850, 19450, 20200, 21000, 21550, 22300, 23100, 23650, 24400, 25200, 25950, 26550, 27300, 28050, 28650, 29400, 30150, 30750, 31500, 32300, 33050, 33600, 34400, 35150, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 48948,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 127015,
                }
            },
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48792,
            aside = true,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 48793,
            x = 4,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48804,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48805,
            aside = true,
            x = 5,
            y = 2,
        },
        {
            type = "quest",
            id = 48853,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, Alliance only, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain08, {
    name = { -- Seeing Spirits
        type = "quest",
        id = 48475,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48475,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 48474,
            status = {"active", "completed"},
        },
    },
    completed = {
        type = "quest",
        id = 48477,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                321000, 331300, 341600, 351900, 362200, 372500, 382800, 393100, 403400, 413700, 424000, 434300, 444600, 454900, 465200, 475500, 585650, 621700, 657750, 693800, 729850, 773880, 819240, 864600, 909960, 955320, 1000680, 1046040, 1091400, 1136760, 1182120, 1227480, 1272840, 1318200, 1363560, 1408920, 1453560, 1498080, 1542600, 1587120, 1618920, 234000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14850, 15150, 15450, 15650, 15950, 16250, 16550, 16750, 17050, 17350, 17550, 17850, 18150, 18350, 18650, 18950, 19700, 20400, 21150, 22000, 22600, 23350, 24200, 24800, 25550, 26400, 27150, 27850, 28600, 29350, 30050, 30800, 31550, 32250, 33000, 33850, 34600, 35200, 36050, 36800, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
    },
    items = {
        {
            type = "npc",
            id = 126210,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48475,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48474,
            restrictions = {
                type = "level",
                level = 49,
                atmost = true,
            },
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 48476,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48477,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, Alliance only, no requirements, 1 breadcrumb (48947), need to do this chain again
BtWQuestsDatabase:AddChain(Chain.Chain09, {
    name = { -- Gol Koval
        type = "quest",
        id = 48947,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48947,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 52074,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 48181,
            status = {"active", "completed"},
        },
    },
    completed = {
        type = "quest",
        id = 53110,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                558750, 569050, 579350, 589650, 599950, 610250, 620550, 630850, 641150, 651450, 661750, 672050, 682350, 692650, 702950, 713250, 838850, 890350, 941850, 993350, 1044850, 1108320, 1173120, 1237920, 1302720, 1367520, 1432320, 1497120, 1561920, 1626720, 1691520, 1756320, 1821120, 1885920, 1950720, 2015520, 2079240, 2142840, 2206440, 2270040, 2320920, 234000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                27800, 28100, 28400, 28600, 28900, 29200, 29500, 29700, 30000, 30300, 30500, 30800, 31100, 31300, 31600, 31900, 33250, 34250, 35600, 37000, 37950, 39300, 40700, 41650, 43000, 44400, 45750, 46750, 48100, 49450, 50450, 51800, 53150, 54150, 55500, 56900, 58250, 59200, 60600, 61950, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 48947,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 125457,
                }
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52074,
            x = 3,
            y = 1,
            connections = {
                2, 3, 4, 5, 6,
            },
        },
        {
            type = "quest",
            id = 48181,
            restrictions = {
                type = "level",
                level = 49,
                atmost = true,
            },
            x = 5,
            y = 1,
        },

        {
            type = "quest",
            id = 48179,
            x = 0,
            y = 2,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 52075,
            x = 2,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 48182,
            x = 4,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48183,
            x = 6,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48180,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53110,
            x = 3,
            y = 4,
        },
    },
})
-- Completed, Alliance only, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain10, {
    name = { -- An Economic Opportunity
        type = "quest",
        id = 50988,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 50988,
        status = {"active", "completed"},
    },
    completed = {
        {
            type = "quest",
            id = 51001,
        },
        {
            type = "quest",
            id = 51018,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                562675, 599240, 635805, 672370, 708935, 745500, 791510, 837515, 883525, 929530, 975540, 1021550, 1067555, 1113565, 1159570, 1205580, 1251590, 1297595, 1343605, 1389610, 1435620, 1480775, 1525930, 1571090, 1616245, 1661400, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                19380, 20150, 20870, 21630, 22500, 23125, 23875, 24750, 25375, 26125, 27000, 27775, 28475, 29250, 30025, 30725, 31500, 32275, 32975, 33750, 34625, 35375, 36000, 36875, 37625, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "npc",
            id = 136458,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50988,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51020,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51019,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50978,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51001,
            x = 2,
            y = 4,
        },
        {
            type = "quest",
            id = 51018,
            x = 4,
            y = 4,
        },
    },
})
-- Completed, Both factions, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain12, {
    name = {
        type = "npc",
        id = 127558,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 48880,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 48904,
            status = {"active", "completed"},
        },
    },
    completed = {
        type = "quest",
        id = 48883,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                17250, 18000, 18500, 19250, 20000, 20500, 21250, 22000, 22500, 23250, 24000, 24750, 25250, 26000, 26750, 27250, 28000, 28750, 29250, 30000, 30750, 31500, 32000, 32750, 33500, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "object",
            id = 276515,
            x = 0,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "npc",
            id = 127558,
            x = 3,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "object",
            id = 276513,
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 48881,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 48880,
            x = 2,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48904,
            x = 4,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48882,
            aside = true,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 48883,
            x = 3,
            y = 2,
        },
    },
})
-- Completed, Alliance only, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain13, {
    name = BtWQuests_GetAreaName(9614), -- Chandlery Wharf
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50960,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 50959,
            status = {"active", "completed"},
        },
    },
    completed = {
        type = "quest",
        id = 50960,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "experience",
            amounts = {
                2800, 3100, 3400, 3600, 3900, 4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "object",
            id = 286016,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50960,
                    x = 2,
                    restrictions = {
                        type = "level",
                        level = 49,
                        atmost = true,
                    },
                },
                {
                    type = "quest",
                    id = 50960,
                    x = 3,
                },
            },
            y = 1,
        },
        {
            type = "quest",
            id = 50959,
            aside = true,
            restrictions = {
                type = "level",
                level = 49,
                atmost = true,
            },
            x = 4,
            y = 1,
        },
    },
})
-- Completed, both factions, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain15, {
    name = { -- Tea Party
        type = "quest",
        id = 44785,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 47289,
        status = {"active", "completed"},
    },
    completed = {
        type = "quest",
        id = 44785,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                162500, 172800, 183100, 193400, 203700, 214000, 224300, 234600, 244900, 255200, 265500, 275800, 286100, 296400, 306700, 317000, 504025, 535440, 566855, 598270, 629685, 666420, 705950, 745475, 785005, 824530, 864060, 903590, 943115, 982645, 1022170, 1061700, 1101230, 1140755, 1180285, 1219810, 1258860, 1297655, 1336450, 1375250, 1401325, 491400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14430, 14730, 15030, 15230, 15530, 15830, 16130, 16330, 16630, 16930, 17130, 17430, 17730, 17930, 18230, 18530, 19300, 19920, 20680, 21500, 22075, 22825, 23650, 24225, 24975, 25800, 26575, 27175, 27950, 28725, 29325, 30100, 30875, 31475, 32250, 33075, 33825, 34400, 35225, 35975, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "npc",
            id = 121603,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47289,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 47428,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 45079,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 45972,
            aside = true,
            x = 4,
            y = 3,
        },
        {
            type = "quest",
            id = 44785,
            x = 3,
            y = 4,
        },
    },
})
-- Completed, Alliance only, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain16, {
    name = { -- Saplings in the Snow
        type = "quest",
        id = 51543,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        type = "quest",
        id = 51543,
        status = {"active", "completed"},
    },
    completed = {
        type = "quest",
        id = 51472,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                12050, 12500, 13000, 13450, 14000, 14400, 14850, 15400, 15800, 16250, 16800, 17250, 17750, 18200, 18650, 19150, 19600, 20050, 20550, 21000, 21550, 22000, 22400, 22950, 23400, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 225,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 135861,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51543,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50953,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51472,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, Horde only, requries BtWQuests.Constant.Chain.BattleForAzeroth.HordeDrustvarFoothold, no breadcrumbs
BtWQuestsDatabase:AddChain(Chain.Chain17, {
    name = { -- Precious Metals
        type = "quest",
        id = 53461,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    prerequisites = {
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.BattleForAzeroth.HordeDrustvarFoothold,
        },
    },
    restrictions = {
        type = "faction",
        id = HORDE_ID,
    },
    active = {
        {
            type = "quest",
            id = 53461,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 53463,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 53462,
            status = {"active", "completed"},
        },
    },
    completed = {
        {
            type = "quest",
            id = 53461,
        },
        {
            type = "quest",
            id = 53463,
        },
        {
            type = "quest",
            id = 53462,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 702000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 225,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 143878,
            x = 1,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 143871,
            x = 4,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 53461,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 53463,
            x = 3,
            y = 1,
        },
        {
            type = "quest",
            id = 53462,
            x = 5,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.Chain18, {
    name = { -- One Man Against the Horde
        type = "quest",
        id = 50911,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    restrictions = {
        type = "faction",
        id = ALLIANCE_ID,
    },
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50911,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 50929,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 50912,
            status = {"active", "completed"},
        },
        {
            type = "quest",
            id = 50897,
            status = {"active", "completed"},
        },
    },
    completed = {
        {
            type = "quest",
            id = 50911,
        },
        {
            type = "quest",
            id = 50929,
        },
        {
            type = "quest",
            id = 50912,
        },
        {
            type = "quest",
            id = 50897,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                14650, 15250, 15750, 16350, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2161,
            amount = 300,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 135673,
            x = 1,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "object",
            id = 284426,
            x = 4,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "kill",
            id = 135541,
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50911,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 50929,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 50912,
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            id = 50897,
            x = 6,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.OtherAlliance, {
    name = "Other Alliance",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = false,
    items = {
        { -- Emissary
            type = "quest",
            id = 50600,
        },
        {
            type = "quest",
            id = 47969,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.OtherHorde, {
    name = "Other Horde",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = false,
    items = {
        {
            type = "quest",
            id = 53455,
        },
        {
            type = "quest",
            id = 53465,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.OtherBoth, {
    name = "Other Both",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {25,50},
    prerequisites = {
        type = "level",
        level = 25,
        visible = false,
    },
    active = false,
    items = {
        { -- @todo missing tooltip, part of achievement http://bfa.wowhead.com/achievement=13082
            type = "quest",
            id = 53432,
        },
        {
            type = "quest",
            id = 53464,
        },
        { -- @todo missing tooltip, part of achievement http://bfa.wowhead.com/achievement=13082
            type = "quest",
            id = 53433,
        },
        { -- @todo What?
            type = "quest",
            id = 50990,
        },
        {
            type = "quest",
            id = 48515,
        },
        { -- @todo Kill rare, Get Pet
            type = "quest",
            id = 52061,
        },
        {
            type = "quest",
            id = 50195,
        },
        { -- @todo PvP?
            type = "quest",
            id = 52958,
        },
        { -- @todo PvP?
            type = "quest",
            id = 50206,
        },
        { -- @todo Not sure the requirements for this
            type = "quest",
            id = 51240,
        },
        { -- @todo missing tooltip, part of achievement http://bfa.wowhead.com/achievement=13082
            type = "quest",
            id = 53431,
        },
        { -- @todo missing tooltip, part of achievement http://bfa.wowhead.com/achievement=13082
            type = "quest",
            id = 53430,
        },
        { -- @todo PvP?
            type = "quest",
            id = 52944,
        },
    },
})

BtWQuestsDatabase:AddCategory(CATEGORY_ID, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 2178278,
    listImage = {
        texture = "Interface\\Addons\\BtWQuestsBattleForAzeroth\\UI-CategoryButton",
        texCoords = {0, 0.7353515625, 0.234375, 0.3515625},
    },
    items = {
        {
            type = "header",
            name = L["BTWQUESTS_THE_WAR_CAMPAIGN"],
            restrictions = {
                type = "faction",
                id = HORDE_ID
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.BattleForAzeroth.HordeDrustvarFoothold,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.BattleForAzeroth.HordeTheMarshalsGrave,
        },


        {
            type = "header",
            name = {
                type = "achievement",
                id = ACHIEVEMENT_ID,
            },
            restrictions = {
                type = "faction",
                id = ALLIANCE_ID
            },
        },
        {
            type = "chain",
            id = Chain.TheFinalEffigy,
        },
        {
            type = "chain",
            id = Chain.TheBurdenOfProof,
        },
        {
            type = "chain",
            id = Chain.AnAirtightAlibi,
        },
        {
            type = "chain",
            id = Chain.TheOrderOfEmbers,
        },
        {
            type = "chain",
            id = Chain.ANewOrder,
        },
        {
            type = "chain",
            id = Chain.BreakOnThrough,
        },
        {
            type = "chain",
            id = Chain.StormingTheManor,
        },
        {
            type = "chain",
            id = Chain.Drustfall,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.FightingWithFire,
        },
        {
            type = "chain",
            id = Chain.StickItToEm,
        },


        {
            type = "header",
            name = L["BTWQUESTS_SIDE_QUESTS"],
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
            id = Chain.Chain10,
        },
        {
            type = "chain",
            id = Chain.Chain12,
        },
        {
            type = "chain",
            id = Chain.Chain13,
        },
        {
            type = "chain",
            id = Chain.Chain15,
        },
        {
            type = "chain",
            id = Chain.Chain16,
        },
        {
            type = "chain",
            id = Chain.Chain17,
        },
        {
            type = "chain",
            id = Chain.Chain18,
        },
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
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
        id = Chain.Chain10,
    },
    {
        type = "chain",
        id = Chain.Chain12,
    },
    {
        type = "chain",
        id = Chain.Chain13,
    },
    {
        type = "chain",
        id = Chain.Chain15,
    },
    {
        type = "chain",
        id = Chain.Chain16,
    },
    {
        type = "chain",
        id = Chain.Chain17,
    },
    {
        type = "chain",
        id = Chain.Chain18,
    },
})