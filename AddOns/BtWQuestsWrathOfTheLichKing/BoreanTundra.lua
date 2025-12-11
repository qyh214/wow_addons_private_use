local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.WrathOfTheLichKing
local CATEGORY_ID = BtWQuests.Constant.Category.WrathOfTheLichKing.BoreanTundra
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing.BoreanTundra
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local MAP_ID = 114
local CONTINENT_ID = 113
local ACHIEVEMENT_ID_ALLIANCE = 33
local ACHIEVEMENT_ID_HORDE = 1358
local LEVEL_RANGE = {10, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 10,
    },
}

Chain.HidingInPlainSight = 30101
Chain.TheFateOfFarseerGrimwalker = 30102
Chain.ToTheAidOfFarshire = 30103
Chain.ReturnOfTheDreadCitadel = 30104
Chain.DEHTA = 30105
Chain.TheScourgeNecrolord = 30106
Chain.TheBlueDragonflight = 30107
Chain.FriendsFromTheSea = 30108
Chain.HellscreamsChampion = 30109
Chain.ParticipantObservation = 30110
Chain.ToTheAidOfTheTaunka = 30111
Chain.AFamilyReunion = 30112
Chain.SomberRealization = 30113
Chain.LastRites = 30114

Chain.Chain01 = 30121
Chain.Chain02 = 30122
Chain.Chain03 = 30123
Chain.Chain04 = 30124
Chain.Chain05 = 30125
Chain.Chain06 = 30126
Chain.Chain07 = 30127
Chain.Chain08 = 30128
Chain.Chain09 = 30129
Chain.Chain10 = 30130

Chain.EmbedChain01 = 30131
Chain.EmbedChain02 = 30132
Chain.EmbedChain03 = 30133
Chain.EmbedChain04 = 30134
Chain.EmbedChain05 = 30135
Chain.EmbedChain06 = 30136
Chain.EmbedChain07 = 30137
Chain.EmbedChain08 = 30138
Chain.EmbedChain09 = 30139
Chain.EmbedChain10 = 30140
Chain.EmbedChain11 = 30141
Chain.EmbedChain12 = 30142
Chain.EmbedChain13 = 30143
Chain.EmbedChain14 = 30144
Chain.EmbedChain15 = 30145
Chain.EmbedChain16 = 30146
Chain.EmbedChain17 = 30147
Chain.EmbedChain18 = 30148
Chain.EmbedChain19 = 30149
Chain.EmbedChain20 = 30150
Chain.EmbedChain21 = 30151
Chain.EmbedChain22 = 30152
Chain.EmbedChain23 = 30153
Chain.EmbedChain24 = 30154
Chain.EmbedChain25 = 30155
Chain.EmbedChain26 = 30156
Chain.EmbedChain27 = 30157
Chain.EmbedChain28 = 30158
Chain.EmbedChain29 = 30159
Chain.EmbedChain30 = 30160
Chain.EmbedChain31 = 30161
Chain.EmbedChain32 = 30162
Chain.EmbedChain33 = 30163

Chain.TempChain32 = 30171

Chain.IgnoreChain01 = 30181
Chain.IgnoreChain02 = 30182
Chain.IgnoreChain03 = 30183
Chain.IgnoreChain04 = 30184

Chain.OtherAlliance = 30197
Chain.OtherHorde = 30198
Chain.OtherBoth = 30199

Database:AddChain(Chain.HidingInPlainSight, {
    name = L["HIDING_IN_PLAIN_SIGHT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11790, 11920, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11794,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4390, 4840, 5280, 5640, 6090, 6535, 6980, 7350, 7785, 8280, 8650, 9095, 9530, 9900, 10345, 10780, 11250, 11595, 12030, 12500, 12875, 13275, 13750, 14125, 14525, 15000, 15475, 15775, 16250, 16725, 17025, 17500, 17975, 18275, 18750, 19225, 19625, 20000, 20475, 20875, 2645, 2645, 2105, 1575, 1055, 530, 265, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4390, 4840, 5280, 5640, 6090, 6535, 6980, 7350, 7785, 8280, 8650, 9095, 9530, 9900, 10345, 10780, 11250, 11595, 12030, 12500, 12875, 12875, 10285, 7685, 5170, 2585, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 1280, 140, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 685,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain01,
            embed = true,
            aside = true,
            x = -2,
        },
        {
            type = "object",
            id = 187851,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = { 11920, 11790, },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11791,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11792,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11793,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11794,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheFateOfFarseerGrimwalker, {
    name = L["THE_FATE_OF_FARSEER_GRIMWALKER"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11624, 12486, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11638,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9290, 10300, 11230, 11990, 12950, 13880, 14890, 15600, 16530, 17540, 18250, 19260, 20190, 20900, 21910, 22840, 23800, 24560, 25490, 26500, 27225, 28125, 29150, 29875, 30775, 31800, 32775, 33475, 34450, 35425, 36125, 37100, 38075, 38775, 39750, 40775, 41675, 42400, 43425, 44325, 5630, 5630, 4480, 3320, 2240, 1120, 565, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9290, 10300, 11230, 11990, 12950, 13880, 14890, 15600, 16530, 17540, 18250, 19260, 20190, 20900, 21910, 22840, 23800, 24560, 25490, 26500, 27225, 27225, 21830, 16280, 10930, 5475, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 2725, 295, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1052,
            amount = 250,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 870,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12486,
                    restrictions = {
                        type = "quest",
                        id = 12486,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 25339,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11624,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11627,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11649,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11629,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11631,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11635,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11639,
            aside = true,
        },
        {
            type = "quest",
            id = 11637,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11638,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ToTheAidOfFarshire, {
    name = L["TO_THE_AID_OF_FARSHIRE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11928, 11901, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11913,12035,11965
        },
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10520, 11605, 12690, 13520, 14605, 15700, 16750, 17650, 18700, 19850, 20750, 21800, 22850, 23750, 24800, 25850, 27000, 27800, 28900, 30000, 30850, 31900, 33000, 33850, 34900, 36000, 37100, 37900, 39000, 40100, 40900, 42000, 43100, 43900, 45000, 46100, 47150, 48000, 49150, 50150, 6340, 6340, 5055, 3770, 2540, 1275, 635, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10520, 11605, 12690, 13520, 14605, 15700, 16750, 17650, 18700, 19850, 20750, 21800, 22850, 23750, 24800, 25850, 27000, 27800, 28900, 30000, 30850, 30850, 24700, 18450, 12395, 6205, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 3080, 340, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1675,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11928,
                    restrictions = {
                        type = "quest",
                        id = 11928,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 26083,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11901,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11902,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            embed = true,
        },
    },
})
Database:AddChain(Chain.ReturnOfTheDreadCitadel, {
    name = L["RETURN_OF_THE_DREAD_CITADEL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {
            11585, 11586, 11595, 11596, 11597, 28711, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11652,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14250, 15740, 17200, 18300, 19790, 21255, 22740, 23850, 25305, 26790, 27900, 29385, 30840, 31950, 33435, 34890, 36400, 37485, 38940, 40450, 41625, 43025, 44550, 45675, 47075, 48600, 50125, 51125, 52650, 54175, 55175, 56700, 58225, 59225, 60750, 62275, 63675, 64800, 66325, 67725, 8590, 8590, 6825, 5100, 3425, 1710, 860, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14250, 15740, 17200, 18300, 19790, 21255, 22740, 23850, 25305, 26790, 27900, 29385, 30840, 31950, 33435, 34890, 36400, 37485, 38940, 40450, 41625, 41625, 33405, 24855, 16690, 8360, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 4155, 455, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 2555,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28711,
                    restrictions = {
                        type = "quest",
                        id = 28711,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 25273,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 11586,
                    restrictions = {
                        type = "quest",
                        id = 11586,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 11585,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {
                11596, 11595, 11597, 
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            aside = true,
            embed = true,
            x = -2,
        },
        {
            type = "quest",
            id = 11598,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11611,
            aside = true,
        },
        {
            type = "quest",
            id = 11602,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 11634,
            x = 0,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11636,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11642,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11643,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11644,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11651,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11652,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DEHTA, {
    name = L["DEHTA"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11864, 11892, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11892,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        16860, 18650, 20320, 21760, 23450, 25120, 26910, 28250, 29920, 31760, 33100, 34890, 36560, 37900, 39690, 41360, 43050, 44490, 46160, 47950, 49350, 51000, 52800, 54150, 55800, 57600, 59300, 60700, 62400, 64100, 65500, 67200, 68900, 70300, 72000, 73800, 75450, 76800, 78600, 80250, 10145, 10145, 8095, 6035, 4050, 2030, 1030, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16860, 18650, 20320, 21760, 23450, 25120, 26910, 28250, 29920, 31760, 33100, 34890, 36560, 37900, 39690, 41360, 43050, 44490, 46160, 47950, 49350, 49350, 39520, 29520, 19770, 9950, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 4955, 540, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 3120,
        },
    },
    items = {
        {
            type = "npc",
            id = 25809,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11864,
            x = 0,
            connections = {
                1, 2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 11866,
            aside = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
            x = -3,
            connections = {
                [2] = {
                    4, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
            connections = {
                [3] = {
                    3, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
            connections = {
                [5] = {
                    2, 
                }, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            embed = true,
            connections = {
                [4] = {
                    1, 
                }, 
            },
        },
        {
            type = "quest",
            id = 11892,
            x = 0,
            y = 8,
        },
    },
})
Database:AddChain(Chain.TheScourgeNecrolord, {
    name = L["THE_SCOURGE_NECROLORD"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.ReturnOfTheDreadCitadel,
            upto = 11598,
        },
    },
    active = {
        type = "quest",
        id = 11614,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11705,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12000, 13210, 14400, 15400, 16610, 17820, 19010, 20050, 21220, 22460, 23500, 24690, 25860, 26900, 28090, 29260, 30550, 31490, 32660, 33950, 35050, 36100, 37400, 38450, 39500, 40800, 42100, 42900, 44200, 45500, 46300, 47600, 48900, 49700, 51000, 52300, 53350, 54400, 55700, 56750, 7185, 7185, 5725, 4305, 2870, 1430, 720, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 13210, 14400, 15400, 16610, 17820, 19010, 20050, 21220, 22460, 23500, 24690, 25860, 26900, 28090, 29260, 30550, 31490, 32660, 33950, 35050, 35050, 28020, 20920, 14010, 7040, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 3485, 380, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 2020,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25394,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11614,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11615,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11616,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            aside = true,
            embed = true,
            x = -3,
        },
        {
            type = "quest",
            id = 11618,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11686,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 11676,
            aside = true,
        },
        {
            visible = false,
        },
        {
            type = "quest",
            id = 11703,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11705,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11709,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11711,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11714,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheBlueDragonflight, {
    name = L["THE_BLUE_DRAGONFLIGHT"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11576, 11587, 11912, 11918, 11910, 11900, 11941, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            12728,11733,11969,11931,11914
        },
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        38250, 41640, 44950, 47450, 50790, 54105, 57440, 60000, 63255, 66790, 69350, 72685, 75940, 78500, 81835, 85090, 88500, 90985, 94340, 97700, 100175, 103625, 107250, 109925, 113375, 117000, 120525, 123225, 126750, 130275, 132975, 136500, 140025, 142725, 146250, 149875, 153325, 156000, 159725, 163075, 20640, 20640, 16450, 12225, 8250, 4140, 2075, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        38250, 41640, 44950, 47450, 50790, 54105, 57440, 60000, 63255, 66790, 69350, 72685, 75940, 78500, 81835, 85090, 88500, 90985, 94340, 97700, 100175, 100175, 80280, 59930, 40250, 20165, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 10030, 1100, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        282850, 402855, 522840, 642845, 762830, 882835, 1002820, 1122825, 1242810, 1362815, 1482800, 1602805, 1722790, 1842795, 1962780, 2082785, 2202770, 2322775, 2442760, 2562765, 2682750, 2848320, 3013875, 3179445, 3345000, 3510570, 3676140, 3841695, 4007265, 4172820, 4338390, 4503960, 4669515, 4835085, 5000640, 5166210, 5328705, 5491200, 5653710, 5816205, 5978700, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        282850, 402855, 522840, 642845, 762830, 882835, 1002820, 1122825, 1242810, 1362815, 1482800, 1602805, 1722790, 1842795, 1962780, 2082785, 2202770, 2322775, 2442760, 2562765, 2682750, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1090,
            amount = 3070,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 1091,
            amount = 2710,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
        },
        {
            type = "npc",
            id = 26110,
            x = -3,
            connections = {
                3, 4, 
            },
        },
        {
            type = "npc",
            id = 26117,
            x = 0,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 25314,
            x = 2,
            connections = {
                4, 5, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            aside = true,
            embed = true,
            x = -4,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
            embed = true,
        },
        {
            type = "quest",
            id = 11910,
            aside = true,
        },
        {
            type = "quest",
            id = 11900,
            x = 2,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain16,
            embed = true,
            x = 0,
            y = 17,
        },
    },
})
Database:AddChain(Chain.FriendsFromTheSea, {
    name = L["FRIENDS_FROM_THE_SEA"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11613, 11949, 12141, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11626,11968
        },
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14050, 15500, 16900, 18100, 19500, 20900, 22350, 23500, 24900, 26500, 27650, 29100, 30500, 31650, 33100, 34500, 35900, 37100, 38500, 39950, 41150, 42550, 44000, 45150, 46550, 48000, 49400, 50600, 52000, 53400, 54600, 56000, 57400, 58600, 60000, 61450, 62850, 64000, 65450, 66850, 8425, 8425, 6725, 5040, 3370, 1700, 860, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14050, 15500, 16900, 18100, 19500, 20900, 22350, 23500, 24900, 26500, 27650, 29100, 30500, 31650, 33100, 34500, 35900, 37100, 38500, 39950, 41150, 41150, 32900, 24600, 16500, 8300, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 4130, 455, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        5500, 19665, 33825, 47990, 62150, 76315, 90475, 104640, 118800, 132965, 147125, 161290, 175450, 189615, 203775, 217940, 232100, 246265, 260425, 274590, 288750, 306570, 324390, 342210, 360030, 377850, 395670, 413490, 431310, 449130, 466950, 484770, 502590, 520410, 538230, 556050, 573540, 591030, 608520, 626010, 643500, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5500, 19665, 33825, 47990, 62150, 76315, 90475, 104640, 118800, 132965, 147125, 161290, 175450, 189615, 203775, 217940, 232100, 246265, 260425, 274590, 288750, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1073,
            amount = 2300,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain17,
            aside = true,
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
Database:AddChain(Chain.HellscreamsChampion, {
    name = L["HELLSCREAMS_CHAMPION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.ReturnOfTheDreadCitadel,
        },
        {
            type = "chain",
            id = Chain.TheScourgeNecrolord,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
    },
    active = {
        type = "quest",
        id = 11916,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11916,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        2150, 2350, 2550, 2750, 2950, 3150, 3350, 3550, 3750, 3950, 4150, 4350, 4550, 4750, 4950, 5150, 5350, 5550, 5750, 5950, 6200, 6400, 6600, 6800, 7000, 7200, 7400, 7600, 7800, 8000, 8200, 8400, 8600, 8800, 9000, 9200, 9400, 9600, 9800, 10000, 1250, 1250, 1000, 775, 500, 250, 130, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2150, 2350, 2550, 2750, 2950, 3150, 3350, 3550, 3750, 3950, 4150, 4350, 4550, 4750, 4950, 5150, 5350, 5550, 5750, 5950, 6200, 6200, 4950, 3700, 2450, 1250, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 625, 70, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 500,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11916,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ParticipantObservation, {
    name = L["PARTICIPANT_OBSERVATION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11571, 11702, 11704, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11570,11569,11566,11564,11561
        },
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        13310, 14750, 16120, 17160, 18550, 19920, 21360, 22350, 23720, 25160, 26150, 27590, 28960, 29950, 31390, 32760, 34150, 35190, 36560, 38000, 39000, 40350, 41800, 42800, 44150, 45600, 47000, 48000, 49400, 50800, 51800, 53200, 54600, 55600, 57000, 58450, 59800, 60800, 62250, 63600, 8070, 8070, 6420, 4755, 3220, 1610, 810, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        13310, 14750, 16120, 17160, 18550, 19920, 21360, 22350, 23720, 25160, 26150, 27590, 28960, 29950, 31390, 32760, 34150, 35190, 36560, 38000, 39000, 39000, 31320, 23320, 15670, 7850, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 3905, 425, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        20000, 71500, 123000, 174500, 226000, 277500, 329000, 380500, 432000, 483500, 535000, 586500, 638000, 689500, 741000, 792500, 844000, 895500, 947000, 998500, 1050000, 1114800, 1179600, 1244400, 1309200, 1374000, 1438800, 1503600, 1568400, 1633200, 1698000, 1762800, 1827600, 1892400, 1957200, 2022000, 2085600, 2149200, 2212800, 2276400, 2340000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        20000, 71500, 123000, 174500, 226000, 277500, 329000, 380500, 432000, 483500, 535000, 586500, 638000, 689500, 741000, 792500, 844000, 895500, 947000, 998500, 1050000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 1110,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11704,
                    restrictions = {
                        type = "quest",
                        id = 11704,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 11702,
                    restrictions = {
                        type = "quest",
                        id = 11702,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 25197,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11571,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11559,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
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
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
            embed = true,
        },
    },
})
Database:AddChain(Chain.ToTheAidOfTheTaunka, {
    name = L["TO_THE_AID_OF_THE_TAUNKA"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11674, 11888, 11890, 11684, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            11689,11906,11907,11909,11706
        },
        count = 5,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        23980, 26600, 29010, 31030, 33450, 35860, 38480, 40300, 42710, 45330, 47150, 49770, 52180, 54000, 56620, 59030, 61450, 63470, 65880, 68500, 70325, 72725, 75350, 77175, 79575, 82200, 84625, 86625, 89050, 91475, 93475, 95900, 98325, 100325, 102750, 105375, 107775, 109600, 112225, 114625, 14510, 14510, 11585, 8565, 5800, 2900, 1470, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        23980, 26600, 29010, 31030, 33450, 35860, 38480, 40300, 42710, 45330, 47150, 49770, 52180, 54000, 56620, 59030, 61450, 63470, 65880, 68500, 70325, 70325, 56410, 42110, 28210, 14200, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 7070, 765, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        38000, 135850, 233700, 331550, 429400, 527250, 625100, 722950, 820800, 918650, 1016500, 1114350, 1212200, 1310050, 1407900, 1505750, 1603600, 1701450, 1799300, 1897150, 1995000, 2118120, 2241240, 2364360, 2487480, 2610600, 2733720, 2856840, 2979960, 3103080, 3226200, 3349320, 3472440, 3595560, 3718680, 3841800, 3962640, 4083480, 4204320, 4325160, 4446000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        38000, 135850, 233700, 331550, 429400, 527250, 625100, 722950, 820800, 918650, 1016500, 1114350, 1212200, 1310050, 1407900, 1505750, 1603600, 1701450, 1799300, 1897150, 1995000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 4410,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain24,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain25,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
            embed = true,
            x = 3,
        },
    },
})
Database:AddChain(Chain.AFamilyReunion, {
    name = L["A_FAMILY_REUNION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            28709, 11672, 11599, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12088,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12280, 13555, 14810, 15780, 17055, 18320, 19510, 20650, 21820, 23110, 24250, 25440, 26610, 27750, 28940, 30110, 31500, 32440, 33760, 35000, 36000, 37250, 38500, 39500, 40750, 42000, 43250, 44250, 45500, 46750, 47750, 49000, 50250, 51250, 52500, 53750, 55000, 56000, 57400, 58500, 7400, 7400, 5905, 4400, 2960, 1485, 735, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12280, 13555, 14810, 15780, 17055, 18320, 19510, 20650, 21820, 23110, 24250, 25440, 26610, 27750, 28940, 30110, 31500, 32440, 33760, 35000, 36000, 36000, 28820, 21570, 14465, 7225, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 3600, 400, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1770,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28709,
                    restrictions = {
                        type = "quest",
                        id = 28709,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 25307,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11672,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11727,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11797,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11889,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11897,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 11927,
                    restrictions = {
                        type = "quest",
                        id = 11927,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 25251,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11599,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11600,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11601,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11603,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11604,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11932,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12086,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12088,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SomberRealization, {
    name = L["SOMBER_REALIZATION"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11881, 11628, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11930,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        17680, 19600, 21410, 22830, 24650, 26460, 28380, 29700, 31510, 33430, 34750, 36670, 38480, 39800, 41720, 43530, 45350, 46770, 48580, 50500, 51825, 53625, 55550, 56875, 58675, 60600, 62425, 63825, 65650, 67475, 68875, 70700, 72525, 73925, 75750, 77675, 79475, 80800, 82725, 84525, 10710, 10710, 8535, 6315, 4280, 2140, 1080, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        17680, 19600, 21410, 22830, 24650, 26460, 28380, 29700, 31510, 33430, 34750, 36670, 38480, 39800, 41720, 43530, 45350, 46770, 48580, 50500, 51825, 51825, 41610, 31010, 20810, 10450, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 5200, 565, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        26000, 92950, 159900, 226850, 293800, 360750, 427700, 494650, 561600, 628550, 695500, 762450, 829400, 896350, 963300, 1030250, 1097200, 1164150, 1231100, 1298050, 1365000, 1449240, 1533480, 1617720, 1701960, 1786200, 1870440, 1954680, 2038920, 2123160, 2207400, 2291640, 2375880, 2460120, 2544360, 2628600, 2711280, 2793960, 2876640, 2959320, 3042000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        26000, 92950, 159900, 226850, 293800, 360750, 427700, 494650, 561600, 628550, 695500, 762450, 829400, 896350, 963300, 1030250, 1097200, 1164150, 1231100, 1298050, 1365000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 2360,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 260,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25849,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 11881,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11893,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11894,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 24703,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11628,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11630,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11633,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 11641,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 11640,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11647,
            aside = true,
        },
        {
            type = "quest",
            id = 11898,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11929,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11930,
            x = 0,
        },
    },
})
Database:AddChain(Chain.LastRites, {
    name = L["LAST_RITES"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11956,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 12019,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        6350, 7000, 7650, 8150, 8800, 9450, 10100, 10600, 11250, 11900, 12400, 13050, 13700, 14200, 14850, 15500, 16150, 16650, 17300, 17950, 18500, 19150, 19800, 20300, 20950, 21600, 22250, 22750, 23400, 24050, 24550, 25200, 25850, 26350, 27000, 27650, 28300, 28800, 29450, 30100, 3800, 3800, 3025, 2275, 1520, 760, 385, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6350, 7000, 7650, 8150, 8800, 9450, 10100, 10600, 11250, 11900, 12400, 13050, 13700, 14200, 14850, 15500, 16150, 16650, 17300, 17950, 18500, 18500, 14850, 11050, 7400, 3725, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 1855, 205, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 26170,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11956,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11938,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11942,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12019,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Trophies of Gammoth
        type = "quest",
        id = 11722,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11716,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 11722,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5610, 6200, 6770, 7210, 7800, 8370, 8960, 9400, 9970, 10610, 11050, 11640, 12210, 12650, 13240, 13810, 14400, 14840, 15410, 16000, 16450, 17000, 17600, 18050, 18600, 19200, 19800, 20200, 20800, 21400, 21800, 22400, 23000, 23400, 24000, 24600, 25150, 25600, 26200, 26750, 3395, 3395, 2695, 2010, 1350, 680, 340, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5610, 6200, 6770, 7210, 7800, 8370, 8960, 9400, 9970, 10610, 11050, 11640, 12210, 12650, 13240, 13810, 14400, 14840, 15410, 16000, 16450, 16450, 13170, 9820, 6620, 3300, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 1640, 180, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 920,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11716,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11717,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11719,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11720,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11721,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11722,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Into the Mist
        type = "quest",
        id = 11655,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11655, 11660, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {11661, 11656},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7350, 8150, 8900, 9500, 10250, 11000, 11800, 12350, 13100, 13900, 14450, 15250, 16000, 16550, 17350, 18100, 18850, 19450, 20200, 21000, 21550, 22300, 23100, 23650, 24400, 25200, 25950, 26550, 27300, 28050, 28650, 29400, 30150, 30750, 31500, 32300, 33050, 33600, 34400, 35150, 4450, 4450, 3550, 2625, 1780, 890, 450, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7350, 8150, 8900, 9500, 10250, 11000, 11800, 12350, 13100, 13900, 14450, 15250, 16000, 16550, 17350, 18100, 18850, 19450, 20200, 21000, 21550, 21550, 17300, 12900, 8650, 4350, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 235, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 334440, 353880, 373320, 392760, 412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        6000, 21450, 36900, 52350, 67800, 83250, 98700, 114150, 129600, 145050, 160500, 175950, 191400, 206850, 222300, 237750, 253200, 268650, 284100, 299550, 315000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1073,
            amount = 1000,
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
            visible = false,
            x = -3,
        },
        {
            type = "npc",
            id = 25476,
            x = 0,
            connections = {
                2, 3
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain28,
            embed = true,
            aside = true,
            x = 3,
        },
        {
            type = "quest",
            id = 11660,
            x = -1,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11655,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11661,
            x = -1,
            -- connections = {
            --     2, 
            -- },
        },
        {
            type = "quest",
            id = 11656,
            -- connections = {
            --     1, 
            -- },
        },
        -- @TODO Might be a breadcrumb to the other area
        -- {
        --     type = "quest",
        --     id = 11662,
        --     x = 0,
        -- },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- The Gearmaster
        type = "quest",
        id = 11798,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            11707, 11708, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11798,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7010, 7800, 8420, 9160, 9800, 10420, 11210, 11800, 12420, 13210, 13800, 14590, 15210, 15800, 16590, 17210, 17850, 18590, 19210, 20000, 20600, 21200, 22000, 22600, 23200, 24000, 24650, 25350, 26000, 26650, 27350, 28000, 28650, 29350, 30000, 30800, 31400, 32000, 32800, 33400, 4220, 4220, 3395, 2505, 1680, 840, 435, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7010, 7800, 8420, 9160, 9800, 10420, 11210, 11800, 12420, 13210, 13800, 14590, 15210, 15800, 16590, 17210, 17850, 18590, 19210, 20000, 20600, 20600, 16420, 12370, 8220, 4175, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 2085, 220, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1320,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11707,
                    restrictions = {
                        type = "quest",
                        id = 11707,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 25590,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11708,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain29,
            embed = true,
            aside = true,
            x = 2,
        },
        {
            type = "quest",
            id = 11712,
            x = 0,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11788,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11798,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- Might As Well Wipe Out the Scourge
        type = "quest",
        id = 11698,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            upto = 11708,
        },
    },
    active = {
        type = "quest",
        id = 11710,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 11701,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10510, 11650, 12720, 13560, 14650, 15720, 16860, 17650, 18720, 19860, 20650, 21790, 22860, 23650, 24790, 25860, 26950, 27790, 28860, 30000, 30800, 31850, 33000, 33800, 34850, 36000, 37100, 37900, 39000, 40100, 40900, 42000, 43100, 43900, 45000, 46150, 47200, 48000, 49150, 50200, 6370, 6370, 5070, 3755, 2540, 1270, 640, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10510, 11650, 12720, 13560, 14650, 15720, 16860, 17650, 18720, 19860, 20650, 21790, 22860, 23650, 24790, 25860, 26950, 27790, 28860, 30000, 30800, 30800, 24720, 18420, 12370, 6200, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 335, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1870,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25702,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11710,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11692,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11693,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11694,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11697,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11698,
            aside = true,
        },
        {
            type = "quest",
            id = 11699,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11700,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11701,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = { -- Dirty, Stinkin' Snobolds!
        type = "quest",
        id = 11645,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            upto = 11708,
        },
    },
    active = {
        type = "quest",
        id = 11645,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 11670,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9100, 10100, 11000, 11800, 12700, 13600, 14600, 15300, 16200, 17200, 17900, 18900, 19800, 20500, 21500, 22400, 23300, 24100, 25000, 26000, 26700, 27600, 28600, 29300, 30200, 31200, 32100, 32900, 33800, 34700, 35500, 36400, 37300, 38100, 39000, 40000, 40900, 41600, 42600, 43500, 5500, 5500, 4400, 3250, 2200, 1100, 560, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9100, 10100, 11000, 11800, 12700, 13600, 14600, 15300, 16200, 17200, 17900, 18900, 19800, 20500, 21500, 22400, 23300, 24100, 25000, 26000, 26700, 26700, 21400, 16000, 10700, 5400, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 2690, 290, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 891840, 943680, 995520, 1047360, 1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1700,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25477,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11645,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11650,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11653,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11658,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain30,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 11670,
            x = -1,
            y = 5,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = { -- Finding Pilot Tailspin
        type = "quest",
        id = 11725,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            upto = 11712,
        },
    },
    active = {
        type = "quest",
        id = 11725,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 11873,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7530, 8350, 9110, 9730, 10500, 11260, 12080, 12650, 13410, 14230, 14800, 15620, 16380, 16950, 17770, 18530, 19300, 19920, 20680, 21500, 22075, 22825, 23650, 24225, 24975, 25800, 26575, 27175, 27950, 28725, 29325, 30100, 30875, 31475, 32250, 33075, 33825, 34400, 35225, 35975, 4560, 4560, 3635, 2690, 1820, 910, 460, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7530, 8350, 9110, 9730, 10500, 11260, 12080, 12650, 13410, 14230, 14800, 15620, 16380, 16950, 17770, 18530, 19300, 19920, 20680, 21500, 22075, 22075, 17710, 13210, 8860, 4450, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 2215, 240, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1360,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25590,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11725,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11726,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11728,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11796,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 11873,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = { -- Deploy the Shake-n-Quake!
        type = "quest",
        id = 11723,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            upto = 11712,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain06,
            upto = 11796,
        },
    },
    active = {
        type = "quest",
        id = 11713,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 11723,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5950, 6600, 7200, 7700, 8300, 8900, 9550, 10000, 10600, 11250, 11700, 12350, 12950, 13400, 14050, 14650, 15250, 15750, 16350, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 3600, 3600, 2875, 2125, 1440, 720, 365, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5950, 6600, 7200, 7700, 8300, 8900, 9550, 10000, 10600, 11250, 11700, 12350, 12950, 13400, 14050, 14650, 15250, 15750, 16350, 17000, 17450, 17450, 14000, 10450, 7000, 3525, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 190, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1050,
            amount = 1100,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 25780,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11713,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11715,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11718,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11723,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain08, {
    name = { -- The Honored Ancestors
        type = "quest",
        id = 11605,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {11612, 11605},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {11623, 11610},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10150, 11250, 12300, 13100, 14150, 15200, 16300, 17050, 18100, 19200, 19950, 21050, 22100, 22850, 23950, 25000, 26050, 26850, 27900, 29000, 29750, 30800, 31900, 32650, 33700, 34800, 35850, 36650, 37700, 38750, 39550, 40600, 41650, 42450, 43500, 44600, 45650, 46400, 47500, 48550, 6150, 6150, 4900, 3625, 2460, 1230, 620, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10150, 11250, 12300, 13100, 14150, 15200, 16300, 17050, 18100, 19200, 19950, 21050, 22100, 22850, 23950, 25000, 26050, 26850, 27900, 29000, 29750, 29750, 23900, 17800, 11950, 6000, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 2985, 325, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 891840, 943680, 995520, 1047360, 1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1073,
            amount = 1950,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain31,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain32,
            embed = true,
        },
    }
})
Database:AddChain(Chain.Chain09, {
    name = BtWQuests_GetAreaName(4127), -- Steeljaw's Caravan
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {11591, 11592, 11593, 11594},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {11592, 11593, 11594},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4550, 5050, 5500, 5900, 6350, 6800, 7300, 7650, 8100, 8600, 8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13800, 14300, 14650, 15100, 15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20450, 20800, 21300, 21750, 2750, 2750, 2200, 1625, 1100, 550, 280, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        4550, 5050, 5500, 5900, 6350, 6800, 7300, 7650, 8100, 8600, 8950, 9450, 9900, 10250, 10750, 11200, 11650, 12050, 12500, 13000, 13350, 13350, 10700, 8000, 5350, 2700, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 1345, 145, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 1064,
            amount = 350,
            restrictions = 923,
        },
        {
            type = "reputation",
            id = 1085,
            amount = 850,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11591,
                    restrictions = {
                        type = "quest",
                        id = 11591,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 25336,
                },
            },
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 25335,
            x = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 11593,
            x = -2,
        },
        {
            type = "quest",
            id = 11594,
        },
        {
            type = "quest",
            id = 11592,
        },
    }
})
Database:AddChain(Chain.Chain10, {
    name = { -- Massive Moth Omelet?
        type = "quest",
        id = 11724,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 11724,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 11724,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4250, 4400, 4500, 4650, 4800, 4950, 5050, 5200, 5350, 5450, 5600, 5750, 5850, 6000, 6150, 6300, 6400, 6550, 6700, 850, 850, 675, 500, 340, 170, 85, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1400, 1550, 1700, 1800, 1950, 2100, 2250, 2350, 2500, 2650, 2750, 2900, 3050, 3150, 3300, 3450, 3600, 3700, 3850, 4000, 4100, 4100, 3300, 2450, 1650, 825, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 410, 45, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 1085,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 187905,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11724,
            x = 0,
        },
    }
})

Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25825,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11789,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11913,
    },
    items = {
        {
            type = "quest",
            id = 11913,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 12035,
    },
    items = {
        {
            type = "quest",
            id = 11903,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11904,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11963,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11965,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11965,
    },
    items = {
        {
            type = "quest",
            id = 11908,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12035,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11608,
    },
    items = { -- Apparently requires 11596
        {
            type = "quest",
            id = 11606,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11608,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "kill",
            id = 25453,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11632,
            x = 0,
        },
    }
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25812,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11884,
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
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25811,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11865,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11868,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25810,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11869,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11870,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11871,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11872,
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
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25809,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11876,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11878,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11879,
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
        id = 11690,
    },
    items = {
        {
            type = "npc",
            id = 25607,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11688,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11690,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain12, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 12728,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11575,
                    restrictions = {
                        type = "quest",
                        id = 11575,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 11574,
                    restrictions = {
                        type = "quest",
                        id = 11574,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 25262,
                }
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain33,
            embed = true,
        },
        {
            type = "quest",
            id = 11587,
            x = 0,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11590,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11646,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11648,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11663,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11671,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11679,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11680,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11681,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11682,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11733,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain13, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "quest",
            id = 13412,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 13413,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11733,
    },
    items = {
        {
            type = "quest",
            id = 11912,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11914,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11969,
    },
    items = {
        {
            type = "quest",
            id = 11918,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11936,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11919,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11931,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11931,
    },
    items = {
        {
            type = "kill",
            id = 25719,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11941,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11943,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11946,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11951,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11957,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11967,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11969,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "kill",
            id = 25636,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12471,
            x = 0,
        },
    }
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11626,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 12141,
                    restrictions = {
                        type = "quest",
                        id = 12141,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 25435,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11613,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11619,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11620,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11625,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11626,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11968,
    },
    items = {
        {
            type = "npc",
            id = 26169,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11949,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11950,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11961,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11968,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.EmbedChain20, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11561,
    },
    items = {
        {
            type = "npc",
            id = 25208,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11570,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11570,
    },
    items = {
        {
            type = "npc",
            id = 25199,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11561,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain22, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11566,
    },
    items = {
        {
            type = "npc",
            id = 25197,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11560,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11562,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 11563,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11564,
        },
        {
            type = "quest",
            id = 11565,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11566,
            x = -1,
        },
    },
})
Database:AddChain(Chain.EmbedChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11564,
    },
    items = {
        {
            type = "npc",
            id = 28375,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11569,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain24, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11689,
    },
    items = {
        {
            type = "npc",
            id = 25602,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11674,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11675,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11677,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11678,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11687,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11689,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain25, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11907,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 11888,
                },
                {
                    type = "npc",
                    id = 25982,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11895,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 11906,
            x = 0,
        },
        {
            type = "quest",
            id = 11899,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11896,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 11909,
            x = -1,
        },
        {
            type = "quest",
            id = 11907,
        },
    },
})
Database:AddChain(Chain.EmbedChain26, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 11706,
    },
    items = {
        {
            type = "npc",
            id = 24702,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11684,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11685,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11695,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11706,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25984,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11887,
            x = 0,
        },
    }
})
Database:AddChain(Chain.EmbedChain28, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25504,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11664,
            x = 0,
        },
    }
})
Database:AddChain(Chain.EmbedChain29, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11730,
    },
    items = {
        {
            type = "kill",
            id = 25758,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11729,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11730,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain30, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "npc",
            id = 25589,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11673,
            x = 0,
        },
    }
})
Database:AddChain(Chain.EmbedChain31, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11623,
    },
    items = {
        {
            type = "npc",
            id = 25292,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11612,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11617,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11623,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain32, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11610,
    },
    items = {
        {
            type = "object",
            id = 187565,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11605,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11607,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11609,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11610,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain33, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11914,
    },
    items = {
        {
            type = "npc",
            id = 25291,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11576,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 11582,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 12728,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TempChain32, {
    name = "Shatter the Orbs!",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 11659,
    },
    items = {
        {
            type = "quest",
            id = 11654,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 11659,
            x = 0,
        },
    },
})

Database:AddChain(Chain.IgnoreChain01, {
    name = "The Stuff of Legends",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29309,
    },
    items = {
        {
            type = "quest",
            id = 29308,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 29309,
            x = 0,
        },
    },
})
Database:AddChain(Chain.IgnoreChain02, {
    name = "The Stuff of Legends",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29312,
    },
    items = {
        {
            type = "quest",
            id = 29307,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 29312,
            x = 0,
        },
    },
})
Database:AddChain(Chain.IgnoreChain03, {
    name = "Alignment",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29285,
    },
    items = {
        {
            type = "quest",
            id = 29270,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 29285,
            x = 0,
        },
    },
})
Database:AddChain(Chain.IgnoreChain04, {
    name = "Actionable Intelligence",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    completed = {
        type = "quest",
        id = 29225,
    },
    items = {
        {
            type = "quest",
            id = 29194,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 29225,
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
        { -- The Tablet of Leviroth, Obsolete
            type = "quest",
            id = 11621,
        },
        { -- Secrets of Riplash, Obsolete
            type = "quest",
            id = 11622,
        },
        { -- Fallen Necropolis, apparently requires chain starting from 11674, lacks room
            type = "quest",
            id = 11683,
        },
        { -- Can't Get Ear-nough..., repeatable
            type = "quest",
            id = 11867,
        },
        { -- ?????, obsolete
            type = "quest",
            id = 11939,
        },
        { -- Drake Hunt, Daily
            type = "quest",
            id = 11940,
        },
        { -- Preparing for the Worst, Daily
            type = "quest",
            id = 11945,
        },
        { -- Veehja's Revenge, obsolete
            type = "quest",
            id = 12490,
        },
        { -- Aces High!, Dungeon Daily
            type = "quest",
            id = 13414,
        },
        { -- Nordrassil's Bough, Dragonwrath, Tarecgosa's Rest.
            type = "quest",
            id = 29239,
        },
        { -- Emergency Extraction, Dragonwrath, Tarecgosa's Rest.
            type = "quest",
            id = 29240,
        },
        { -- At One, Dragonwrath, Tarecgosa's Rest.
            type = "quest",
            id = 29269,
        },
        { -- A Gift From Your Tadpole, Weekly
            type = "quest",
            id = 46049,
        },
        { -- Adopt a Tadpole, Micro holiday
            type = "quest",
            id = 46061,
        },
        { -- A Tadpole's Request, Micro holiday
            type = "quest",
            id = 46062,
        },
        { -- The Ways of the World, Micro holiday
            type = "quest",
            id = 46064,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
	buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsWrathOfTheLichKing\UI-Category-BoreanTundra]],
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = Chain.HidingInPlainSight,
        },
        {
            type = "chain",
            id = Chain.TheFateOfFarseerGrimwalker,
        },
        {
            type = "chain",
            id = Chain.ToTheAidOfFarshire,
        },
        {
            type = "chain",
            id = Chain.ReturnOfTheDreadCitadel,
        },
        {
            type = "chain",
            id = Chain.DEHTA,
        },
        {
            type = "chain",
            id = Chain.TheScourgeNecrolord,
        },
        {
            type = "chain",
            id = Chain.TheBlueDragonflight,
        },
        {
            type = "chain",
            id = Chain.FriendsFromTheSea,
        },
        {
            type = "chain",
            id = Chain.HellscreamsChampion,
        },
        {
            type = "chain",
            id = Chain.ParticipantObservation,
        },
        {
            type = "chain",
            id = Chain.ToTheAidOfTheTaunka,
        },
        {
            type = "chain",
            id = Chain.AFamilyReunion,
        },
        {
            type = "chain",
            id = Chain.SomberRealization,
        },
        {
            type = "chain",
            id = Chain.LastRites,
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
        {
            type = "chain",
            id = Chain.Chain09,
        },
        {
            type = "chain",
            id = Chain.Chain10,
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

-- Database:AddContinentItems(CONTINENT_ID, {})
