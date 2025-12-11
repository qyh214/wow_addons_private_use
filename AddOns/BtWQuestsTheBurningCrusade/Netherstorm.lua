local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheBurningCrusade;
local CATEGORY_ID = BtWQuests.Constant.Category.TheBurningCrusade.Netherstorm;
local Chain = BtWQuests.Constant.Chain.TheBurningCrusade.Netherstorm;
local MAP_ID = 109
local ACHIEVEMENT_ID = 1194
local CONTINENT_ID = 101
local LEVEL_RANGE = {25, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 25,
    },
}

Chain.Socrethar = 20601
Chain.SocretharAldor = 20602
Chain.SocretharScryers = 20603
Chain.TheVioletTower = 20604
Chain.BuildingTheX52NetherRocket = 20605
Chain.ProtectArea52 = 20606
Chain.TheConsortium = 20607
Chain.DestroyingTheAllDevouring = 20608

Chain.EmbedChain01 = 20611
Chain.EmbedChain02 = 20612
Chain.EmbedChain03 = 20613
Chain.EmbedChain04 = 20614
Chain.EmbedChain05 = 20615
Chain.EmbedChain06 = 20616
Chain.EmbedChain07 = 20617
Chain.EmbedChain08 = 20618
Chain.EmbedChain09 = 20619
Chain.EmbedChain10 = 20620

Chain.Chain01 = 20621
Chain.Chain02 = 20622
Chain.Chain03 = 20623
Chain.Chain04 = 20624
Chain.Chain05 = 20625
Chain.Chain06 = 20626
Chain.Chain07 = 20627
Chain.Chain08 = 20628

Chain.EmbedChain11 = 20631
Chain.EmbedChain12 = 20632
Chain.EmbedChain13 = 20633
Chain.EmbedChain14 = 20634
Chain.EmbedChain15 = 20635
Chain.EmbedChain16 = 20636
Chain.EmbedChain17 = 20637
Chain.EmbedChain18 = 20638
Chain.EmbedChain19 = 20639
Chain.EmbedChain20 = 20640
Chain.EmbedChain21 = 20641
Chain.EmbedChain22 = 20642
Chain.EmbedChain23 = 20643
Chain.EmbedChain24 = 20644
Chain.EmbedChain25 = 20645
Chain.EmbedChain26 = 20646
Chain.EmbedChain27 = 20647
Chain.EmbedChain28 = 20648
Chain.EmbedChain29 = 20649
Chain.EmbedChain30 = 20650
Chain.EmbedChain31 = 20651
Chain.EmbedChain32 = 20652
Chain.EmbedChain33 = 20653
Chain.EmbedChain34 = 20654
Chain.EmbedChain35 = 20655
Chain.EmbedChain36 = 20656
Chain.EmbedChain37 = 20657
Chain.EmbedChain38 = 20658

Chain.OtherChain = 20699

Database:AddChain(Chain.Socrethar, {
    name = L["SOCRETHAR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.Socrethar,
        Chain.SocretharAldor,
        Chain.SocretharScyers,
    },
    restrictions = {
        type = "quest",
        ids = {10551, 10552},
        equals = true,
        count = 0,
    },
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
        {
            name = L["CHOOSE_THE_ALDOR_OR_THE_SCRYERS"],
        },
    },
    active = {
        type = "quest",
        id = 10587,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10651,
    },
    items = {
        {
            name = L["CHOOSE_THE_ALDOR_OR_THE_SCRYERS"],
        },
    },
})
Database:AddChain(Chain.SocretharAldor, {
    name = L["SOCRETHAR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.Socrethar,
        Chain.SocretharAldor,
        Chain.SocretharScyers,
    },
    restrictions = {
        {
            type = "reputation",
            id = 932,
            standing = 4,
        },
        {
            type = "quest",
            id = 10551,
        },
    },
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {11038, 10241},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10409,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        56900, 59300, 61125, 63500, 65950, 67800, 70150, 72600, 74400, 76750, 79200, 81600, 83400, 85800, 88200, 90000, 92400, 94800, 96600, 99000, 101450, 103800, 105600, 108050, 110400, 13960, 13960, 11120, 8290, 5585, 2800, 1410, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        56900, 59300, 61125, 63500, 65950, 67800, 67800, 54375, 40525, 27210, 13660, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 6790, 745, 
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
                        871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 932,
            amount = 4075,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11038,
                    restrictions = {
                        type = "quest",
                        id = 11038,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 19466,
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 10241,
            x = 0,
            y = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10313,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 10243,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10245,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10299,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10321,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 10246,
            aside = true,
        },
        {
            type = "quest",
            id = 10322,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10328,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10323,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 10431,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10380,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10407,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10410,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10409,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SocretharScryers, {
    name = L["SOCRETHAR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.Socrethar,
        Chain.SocretharAldor,
        Chain.SocretharScyers,
    },
    restrictions = {
        {
            type = "reputation",
            id = 934,
            standing = 4,
        },
        {
            type = "quest",
            id = 10552,
        },
    },
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {11039, 10189},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10507,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        55590, 57950, 59760, 62090, 64450, 66275, 68575, 70950, 72725, 75025, 77400, 79725, 81525, 83850, 86175, 87975, 90300, 92625, 94425, 96750, 99125, 101425, 103200, 105625, 107875, 13650, 13650, 10870, 8105, 5450, 2735, 1375, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        55590, 57950, 59760, 62090, 64450, 66275, 66275, 53130, 39630, 26605, 13335, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 6640, 730, 
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
                        1030250, 1097200, 1164150, 1231100, 1298050, 1365000, 1449240, 1533480, 1617720, 1701960, 1786200, 1870440, 1954680, 2038920, 2123160, 2207400, 2291640, 2375880, 2460120, 2544360, 2628600, 2711280, 2793960, 2876640, 2959320, 3042000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1030250, 1097200, 1164150, 1231100, 1298050, 1365000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 934,
            amount = 4245,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11039,
                    restrictions = {
                        type = "quest",
                        id = 11039,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 19468,
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 10189,
            x = 0,
            y = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10193,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10204,
        },
        {
            type = "quest",
            id = 10329,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10194,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10652,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10197,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10198,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10330,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10200,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 19469,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10338,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10341,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10365,
            x = -1,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 10202,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10432,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10508,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10509,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10507,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheVioletTower, {
    name = L["THE_VIOLET_TOWER"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10173,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10257, 10320, 10223, 10233, 10240},
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        78450, 81800, 84200, 87550, 90950, 93400, 96650, 100050, 102500, 105750, 109200, 112550, 114900, 118300, 121650, 124050, 127400, 130750, 133150, 136500, 139950, 143200, 145600, 149050, 152300, 19320, 19320, 15365, 11385, 7725, 3860, 1935, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        78450, 81800, 84200, 87550, 90950, 93400, 93400, 75050, 55850, 37520, 18795, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 9340, 1020, 
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
                        1743500, 1856800, 1970100, 2083400, 2196700, 2310000, 2452560, 2595120, 2737680, 2880240, 3022800, 3165360, 3307920, 3450480, 3593040, 3735600, 3878160, 4020720, 4163280, 4305840, 4448400, 4588320, 4728240, 4868160, 5008080, 5148000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1743500, 1856800, 1970100, 2083400, 2196700, 2310000, 
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
            id = 19217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10173,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10300,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10174,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10188,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            embed = true,
            x = -3,
            y = 5,
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
            connections = {
                {
                    0.2, 5, 
                }, 
            },
        },
        {
            type = "npc",
            id = 19488,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 10185,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            x = 1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            embed = true,
            x = 1,
            y = 8,
        },
    },
})
Database:AddChain(Chain.BuildingTheX52NetherRocket, {
    name = L["BUILDING_THE_X52_NETHERROCKET"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10183, 11036, 11037, 11040, 11042, 39201, 39202, 10186},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10221,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10350, 10800, 11100, 11550, 12000, 12300, 12750, 13200, 13500, 13950, 14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18900, 19200, 19650, 20100, 2550, 2550, 2025, 1500, 1020, 510, 255, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10350, 10800, 11100, 11550, 12000, 12300, 12300, 9900, 7350, 4950, 2475, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 135, 
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
                        237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        237750, 253200, 268650, 284100, 299550, 315000, 
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
                    id = 10183,
                    restrictions = {
                        type = "quest",
                        id = 10183,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 11036,
                    restrictions = {
                        type = "quest",
                        id = 11036,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 11037,
                    restrictions = {
                        type = "quest",
                        id = 11037,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 11040,
                    restrictions = {
                        type = "quest",
                        id = 11040,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 11042,
                    restrictions = {
                        type = "quest",
                        id = 11042,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 39201,
                    restrictions = {
                        type = "quest",
                        id = 39201,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 39202,
                    restrictions = {
                        type = "quest",
                        id = 39202,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 19570,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10186,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 10203,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10221,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ProtectArea52, {
    name = L["PROTECT_AREA_52"],
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
            id = Chain.TheConsortium,
            upto = 10265,
        },
    },
    active = {
        type = "quest",
        id = 10206,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10249,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        24110, 25150, 25915, 26910, 27950, 28800, 29750, 30800, 31600, 32550, 33600, 34650, 35350, 36400, 37450, 38150, 39200, 40250, 40950, 42000, 43050, 44000, 44800, 45850, 46800, 5930, 5930, 4715, 3535, 2365, 1180, 595, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        24110, 25150, 25915, 26910, 27950, 28800, 28800, 23095, 17195, 11530, 5785, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 2875, 315, 
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
    },
    items = {
        {
            type = "npc",
            id = 19645,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10206,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10232,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 10333,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10234,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10235,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10247,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10248,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10249,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheConsortium, {
    name = L["THE_CONSORTIUM"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10263, 10264, 10265, 10270, 10339, 10417},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10440, 10274, 10408, 10276},
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        91260, 95200, 98115, 102010, 105850, 108950, 112700, 116550, 119550, 123300, 127200, 131000, 133950, 137800, 141600, 144600, 148400, 152200, 155200, 159000, 162900, 166650, 169600, 173650, 177250, 22435, 22435, 17875, 13325, 8970, 4485, 2250, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        91260, 95200, 98115, 102010, 105850, 108950, 108950, 87395, 65195, 43675, 21910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 10910, 1200, 
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
                        2060500, 2194400, 2328300, 2462200, 2596100, 2730000, 2898480, 3066960, 3235440, 3403920, 3572400, 3740880, 3909360, 4077840, 4246320, 4414800, 4583280, 4751760, 4920240, 5088720, 5257200, 5422560, 5587920, 5753280, 5918640, 6084000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2060500, 2194400, 2328300, 2462200, 2596100, 2730000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 933,
            amount = 4575,
        },
        {
            type = "reputation",
            id = 935,
            amount = 2000,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
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
Database:AddChain(Chain.DestroyingTheAllDevouring, {
    name = L["DESTROYING_THE_ALLDEVOURING"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10437,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10439,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12050, 12550, 12950, 13450, 13950, 14400, 14900, 15400, 15800, 16300, 16800, 17300, 17700, 18200, 18700, 19100, 19600, 20100, 20500, 21000, 21500, 22000, 22400, 22900, 23400, 2950, 2950, 2350, 1775, 1180, 590, 300, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12050, 12550, 12950, 13450, 13950, 14400, 14400, 11550, 8600, 5750, 2900, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 1445, 160, 
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
                        237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 933,
            amount = 1000,
        },
    },
    items = {
        {
            type = "npc",
            id = 20907,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10437,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10438,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10439,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
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
            id = Chain.TheVioletTower,
            upto = 10188,
        },
    },
    active = {
        type = "quest",
        id = 10343,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10240,
    },
    items = {
        {
            type = "npc",
            id = 19489,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10343,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10239,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10240,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
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
            id = Chain.TheVioletTower,
            upto = 10188,
        },
    },
    active = {
        type = "quest",
        id = 10192,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10257,
    },
    items = {
        {
            type = "quest",
            id = 10192,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10301,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10209,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10256,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10257,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
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
            id = Chain.TheVioletTower,
            upto = 10188,
        },
    },
    active = {
        type = "quest",
        id = 10222,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10223,
    },
    items = {
        {
            type = "quest",
            id = 10222,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 10223,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
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
            id = Chain.TheVioletTower,
            upto = 10188,
        },
    },
    active = {
        type = "quest",
        id = 10184,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10320,
    },
    items = {
        {
            type = "quest",
            id = 10184,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10312,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10316,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10314,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10319,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10320,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
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
            id = Chain.TheVioletTower,
            upto = 10188,
        },
    },
    active = {
        type = "quest",
        id = 10233,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10233,
    },
    items = {
        {
            type = "npc",
            id = 19489,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10233,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10263, 10264, 10265, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10276,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 10263,
                    restrictions = {
                        type = "quest",
                        id = 10263,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 10264,
                    restrictions = {
                        type = "quest",
                        id = 10264,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 19880,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10265,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10262,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10205,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10266,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10267,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10268,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10269,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10275,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10276,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10280,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10704,
            aside = true,
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
        id = 10270,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10274,
    },
    items = {
        {
            type = "npc",
            id = 20071,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10270,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10271,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10281,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10272,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10273,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10274,
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
        id = 10339,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10408,
    },
    items = {
        {
            type = "npc",
            id = 20448,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10339,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10384,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10385,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10405,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10406,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10408,
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
        id = 10417,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10440,
    },
    items = {
        {
            type = "npc",
            id = 20810,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10417,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10418,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10423,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10424,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10430,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10436,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10440,
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
        id = 10261,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10261,
    },
    items = {
        {
            type = "object",
            id = 183811,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10261,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAreaName(3712), -- Area 52
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10225, 10309, 10342, 10701, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10199, 10226, 10309, 10701, 
        },
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        21130, 22050, 22670, 23580, 24500, 25125, 26025, 26950, 27575, 28475, 29400, 30325, 30925, 31850, 32775, 33375, 34300, 35225, 35825, 36750, 37675, 38575, 39200, 40125, 41025, 5210, 5210, 4135, 3065, 2080, 1040, 520, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21130, 22050, 22670, 23580, 24500, 25125, 25125, 20210, 15010, 10110, 5050, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 2510, 275, 
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
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain11,
            embed = true,
            x = -1,
            y = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
            x = -3,
            y = 1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            embed = true,
            x = 1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = BtWQuests_GetAreaName(3725), -- Ruins of Enkaat
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10190, 10191, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10190, 10191, 
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7750, 8050, 8350, 8650, 9000, 9250, 9550, 9900, 10150, 10450, 10800, 11100, 11400, 11700, 12000, 12300, 12600, 12900, 13200, 13500, 13850, 14150, 14400, 14750, 15050, 1900, 1900, 1525, 1125, 760, 380, 195, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7750, 8050, 8350, 8650, 9000, 9250, 9250, 7400, 5550, 3700, 1875, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 935, 100, 
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
                        237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        237750, 253200, 268650, 284100, 299550, 315000, 
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
            id = Chain.EmbedChain15,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain16,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = BtWQuests_GetAreaName(3877), -- Eco-Dome Midrealm
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10311, 10348, 10433, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10310, 10348, 10435, 
        },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15510, 16150, 16690, 17310, 18000, 18500, 19100, 19800, 20300, 20900, 21600, 22250, 22750, 23400, 24050, 24550, 25200, 25850, 26350, 27000, 27700, 28300, 28800, 29500, 30100, 3820, 3820, 3045, 2255, 1520, 760, 385, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15510, 16150, 16690, 17310, 18000, 18500, 18500, 14820, 11070, 7420, 3725, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 200, 
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
                        396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        396250, 422000, 447750, 473500, 499250, 525000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 933,
            amount = 610,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain17,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain19,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = BtWQuests_GetAreaName(3738), -- The Stormspire
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10290, 10335, 10336, 10426, 10855, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10293, 10335, 10336, 10429, 10857, 
        },
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        36200, 37700, 38900, 40400, 42000, 43100, 44600, 46200, 47300, 48800, 50400, 51900, 53100, 54600, 56100, 57300, 58800, 60300, 61500, 63000, 64600, 66100, 67200, 68800, 70300, 8900, 8900, 7100, 5250, 3560, 1780, 900, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        36200, 37700, 38900, 40400, 42000, 43100, 43100, 34600, 25800, 17300, 8700, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 4330, 470, 
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
            id = 933,
            amount = 1850,
        },
        {
            type = "reputation",
            id = 942,
            amount = 850,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain20,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain21,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
            embed = true,
            x = 3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
            embed = true,
            x = 3,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = BtWQuests_GetAreaName(3852), -- Tuluman's landing
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10315, 10317, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10315, 10318, 
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10350, 10800, 11100, 11550, 12000, 12300, 12750, 13200, 13500, 13950, 14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18900, 19200, 19650, 20100, 2550, 2550, 2025, 1500, 1020, 510, 255, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10350, 10800, 11100, 11550, 12000, 12300, 12300, 9900, 7350, 4950, 2475, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 1230, 135, 
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
        {
            type = "reputation",
            id = 933,
            amount = 500,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain24,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain25,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = BtWQuests_GetAreaName(3854), -- Tuluman's landing
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 25,
        },
    },
    active = {
        type = "quest",
        ids = {
            10345, 10353, 10411, 10413, 10422, 10425, 10969, 10970, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10345, 10353, 10411, 10413, 10422, 10425, 10974, 
        },
        count = 7,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        37050, 38600, 39800, 41350, 42950, 44150, 45700, 47300, 48450, 50000, 51600, 53150, 54350, 55900, 57450, 58650, 60200, 61750, 62950, 64500, 66100, 67650, 68800, 70400, 71950, 9100, 9100, 7250, 5400, 3640, 1820, 920, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        37050, 38600, 39800, 41350, 42950, 44150, 44150, 35450, 26400, 17700, 8900, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 4430, 485, 
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
                        1109500, 1181600, 1253700, 1325800, 1397900, 1470000, 1560720, 1651440, 1742160, 1832880, 1923600, 2014320, 2105040, 2195760, 2286480, 2377200, 2467920, 2558640, 2649360, 2740080, 2830800, 2919840, 3008880, 3097920, 3186960, 3276000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1109500, 1181600, 1253700, 1325800, 1397900, 1470000, 
                    },
                    minLevel = 25,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 933,
            amount = 3100,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain26,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain28,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain29,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain30,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain31,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain32,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = BtWQuests_GetAreaName(3724), -- Cosmowrench
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10924,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10924,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
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
                        79250, 84400, 89550, 94700, 99850, 105000, 111480, 117960, 124440, 130920, 137400, 143880, 150360, 156840, 163320, 169800, 176280, 182760, 189240, 195720, 202200, 208560, 214920, 221280, 227640, 234000, 
                    },
                    minLevel = 25,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        79250, 84400, 89550, 94700, 99850, 105000, 
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
            id = 22479,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10924,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain08, {
    name = BtWQuests_GetAreaName(3732), -- Protectorate Watch Post
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10182, 10305, 10306, 10307, 10331, 10334, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10182, 10305, 10306, 10307, 10332, 10337, 
        },
        count = 6,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        26750, 27900, 28700, 29850, 31000, 31800, 32950, 34100, 34900, 36050, 37200, 38350, 39150, 40300, 41450, 42250, 43400, 44550, 45350, 46500, 47650, 48800, 49600, 50750, 51900, 6575, 6575, 5225, 3880, 2630, 1320, 660, 
                    },
                    minLevel = 25,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        26750, 27900, 28700, 29850, 31000, 31800, 31800, 25550, 19000, 12800, 6400, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 3180, 350, 
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
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain33,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain34,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain35,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain36,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain37,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain38,
            embed = true,
        },
    },
})

Database:AddChain(Chain.EmbedChain11, {
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
            id = Chain.BuildingTheX52NetherRocket,
            upto = 10186,
        },
    },
    active = {
        type = "quest",
        id = 10225,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10226,
    },
    items = {
        {
            type = "chain",
            id = Chain.BuildingTheX52NetherRocket,
            connections = {
                1, 
            },
            upto = 10186,
        },
        {
            type = "npc",
            id = 19570,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10225,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10224,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10226,
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
        id = 10701,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10701,
    },
    items = {
        {
            type = "object",
            id = 183811,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10701,
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
        id = 10342,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10199,
    },
    items = {
        {
            type = "npc",
            id = 19617,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10342,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10199,
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
        id = 10309,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10309,
    },
    items = {
        {
            type = "npc",
            id = 19690,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10309,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10190,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10190,
    },
    items = {
        {
            type = "npc",
            id = 19578,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10190,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10191,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10191,
    },
    items = {
        {
            type = "npc",
            id = 19589,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10191,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10433,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10435,
    },
    items = {
        {
            type = "npc",
            id = 20921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10433,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10434,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10435,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10311,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10310,
    },
    items = {
        {
            type = "npc",
            id = 20066,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10311,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10310,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10348,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10348,
    },
    items = {
        {
            type = "npc",
            id = 20810,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10348,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain20, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10290,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10293,
    },
    items = {
        {
            type = "npc",
            id = 20067,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10290,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10293,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10336, 10855, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            10336, 10857, 
        },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 20471,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 10855,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10336,
        },
        {
            type = "quest",
            id = 10856,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10857,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain22, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10335,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10335,
    },
    items = {
        {
            type = "npc",
            id = 20470,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10335,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10426,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10429,
    },
    items = {
        {
            type = "npc",
            id = 20871,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10426,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10427,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10429,
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
        id = 10317,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10318,
    },
    items = {
        {
            type = "npc",
            id = 20112,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10317,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10318,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain25, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10315,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10315,
    },
    items = {
        {
            type = "npc",
            id = 20341,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10315,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain26, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            10969, 10970, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10974,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 10969,
                    restrictions = {
                        type = "quest",
                        id = 10969,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 20448,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Required honored?
            type = "quest",
            id = 10970,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10971,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10973,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10974,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10411,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10411,
    },
    items = {
        {
            type = "npc",
            id = 20449,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10411,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain28, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10422,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10422,
    },
    items = {
        {
            type = "npc",
            id = 20450,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10422,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain29, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10425,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10425,
    },
    items = {
        {
            type = "kill",
            id = 20854,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10425,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain30, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10413,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10413,
    },
    items = {
        {
            type = "kill",
            id = 20779,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10413,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain31, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10345,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10345,
    },
    items = {
        {
            type = "npc",
            id = 20551,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10345,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain32, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10353,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10353,
    },
    items = {
        {
            type = "npc",
            id = 20552,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10353,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain33, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10331,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10332,
    },
    items = {
        {
            type = "npc",
            id = 20463,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10331,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10332,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain34, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10334,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10337,
    },
    items = {
        {
            type = "npc",
            id = 20464,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10334,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10337,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain35, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10182,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10182,
    },
    items = {
        {
            type = "kill",
            id = 19543,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10182,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain36, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10305,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10305,
    },
    items = {
        {
            type = "kill",
            id = 19546,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10305,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain37, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10306,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10306,
    },
    items = {
        {
            type = "kill",
            id = 19544,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10306,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain38, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10307,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10307,
    },
    items = {
        {
            type = "kill",
            id = 19545,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10307,
            x = 0,
        },
    },
})
Database:AddChain(Chain.OtherChain, {
    name = "Others",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        { -- Removed?
            type = "quest",
            id = 10179,
        },
        { -- Removed?
            type = "quest",
            id = 10187,
        },
        { -- Removed?
            type = "quest",
            id = 10441,
        },
        { -- Repeatable A Heap of Ethereals
            type = "quest",
            id = 10308,
        },
        { -- Repeatable rep quest
            type = "quest",
            id = 10972,
        },
        { -- Daily from Shattrath
            type = "quest",
            id = 11877,
        },
        { -- Part of the quest Fel Reavers, No Thanks!"
            type = "quest",
            id = 10850,
        },
    },
})


Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsTheBurningCrusade\UI-Category-Netherstorm]],
		texCoords = {0,1,0,1},
    },
    items = {
        {
            type = "chain",
            id = Chain.Socrethar,
        },
        {
            type = "chain",
            id = Chain.SocretharAldor,
        },
        {
            type = "chain",
            id = Chain.SocretharScryers,
        },
        {
            type = "chain",
            id = Chain.TheVioletTower,
        },
        {
            type = "chain",
            id = Chain.BuildingTheX52NetherRocket,
        },
        {
            type = "chain",
            id = Chain.ProtectArea52,
        },
        {
            type = "chain",
            id = Chain.TheConsortium,
        },
        {
            type = "chain",
            id = Chain.DestroyingTheAllDevouring,
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
            id = Chain.SocretharAldor,
        },
        {
            type = "chain",
            id = Chain.SocretharScryers,
        },
        {
            type = "chain",
            id = Chain.TheVioletTower,
        },
        {
            type = "chain",
            id = Chain.BuildingTheX52NetherRocket,
        },
        {
            type = "chain",
            id = Chain.ProtectArea52,
        },
        {
            type = "chain",
            id = Chain.DestroyingTheAllDevouring,
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
            id = Chain.Chain07,
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
        {
            type = "chain",
            id = Chain.EmbedChain33,
        },
        {
            type = "chain",
            id = Chain.EmbedChain34,
        },
        {
            type = "chain",
            id = Chain.EmbedChain35,
        },
        {
            type = "chain",
            id = Chain.EmbedChain36,
        },
        {
            type = "chain",
            id = Chain.EmbedChain37,
        },
        {
            type = "chain",
            id = Chain.EmbedChain38,
        },
    })
end
