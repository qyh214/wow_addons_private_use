if select(4, GetBuildInfo()) < 100100 then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local CATEGORY_ID = BtWQuests.Constant.Category.Dragonflight.EmbersOfNeltharion
local Chain = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion
local CONTINENT_ID = 1978
local MAP_ID = 2133
local ACHIEVEMENT_ID_1 = 17739
local LEVEL_RANGE = {70, 70}
    
Chain.BreakingGround = 100601
Chain.SunderedLegacy = 100602
Chain.TheAncientBargain = 100603
Chain.InheritedSin = 100604
Chain.InevitableConfrontation = 100605
Chain.AFlameExtinguished = 100606
Chain.ACrecheDivided = 100607
Chain.TheDragonsAndTheScaleExpedition = 100608
Chain.TheVeiledOssuary = 100609
Chain.UnitedAgain = 100610
Chain.RebelResurgence = 100629
Chain.TyrsFall = 100630

Chain.Chain01 = 100611
Chain.Chain02 = 100612
Chain.Chain03 = 100613
Chain.Chain04 = 100614
Chain.Chain05 = 100615
Chain.EmbedChain01 = 100616
Chain.EmbedChain02 = 100617
Chain.EmbedChain03 = 100618
Chain.EmbedChain04 = 100619
Chain.EmbedChain05 = 100620
Chain.TempChain21 = 100621
Chain.TempChain22 = 100622
Chain.Chain06 = 100623
Chain.Chain07 = 100624
Chain.Chain08 = 100625
Chain.Chain09 = 100626
Chain.Chain10 = 100627
Chain.Chain11 = 100628

Chain.Chain14 = 100621

Database:AddChain(Chain.BreakingGround, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 1392,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.ReturnToTheReach,
            upto = 72717,
        }
    },
    active = {
        type = "quest",
        id = 72975,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75644,
    },
    items = {
        {
            type = "quest",
            id = 75456,
            restrictions = false,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72975,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72976,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72977,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72978,
            x = 0,
            connections = {
                1.2, 2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 72981,
            x = 0,
            y = 4,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72873,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72872,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72970,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72980,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72874,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72979,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72973,
            x = 0,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 76101,
            x = -3,
            aside = true,
        },
        {
            type = "quest",
            id = 72974,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 75643,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75644,
            x = 0,
        },
        {
            visible = false,
            x = -3,
            y = 10,
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            aside = true,
            embed = true,
            x = 3,
            y = 10,
        },
    },
})
Database:AddChain(Chain.SunderedLegacy, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 1393,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
        },
    },
    active = {
        type = "quest",
        id = 74334,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72965,
    },
    items = {
        {
            type = "npc",
            id = 201366,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74334,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72958,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 74375,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72959,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72961,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75419,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72963,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72964,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72965,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheAncientBargain, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 4),
    questline = 1394,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SunderedLegacy,
        },
    },
    active = {
        type = "quest",
        id = 72966,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75145,
    },
    items = {
        {
            type = "npc",
            id = 199849,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72966,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72908,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72909,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72910,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72911,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72912,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72913,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72914,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72915,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72916,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74494,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72917,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72918,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72919,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72920,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75145,
            x = 0,
        },
    },
})
Database:AddChain(Chain.InheritedSin, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 5),
    questline = 1395,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SunderedLegacy,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAncientBargain,
        },
    },
    active = {
        type = "quest",
        id = 72987,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 74562,  74563, }
    },
    items = {
        {
            type = "npc",
            id = 203965,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72987,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75367,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74393,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 74538,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 74539,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 74540,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74542,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74557,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 74562,
            x = -1,
        },
        {
            type = "quest",
            id = 74563,
        },
    },
})
Database:AddChain(Chain.InevitableConfrontation, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 6),
    questline = 1396,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SunderedLegacy,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAncientBargain,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InheritedSin,
        },
    },
    active = {
        type = "quest",
        id = 72922,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72930,
    },
    items = {
        {
            type = "npc",
            id = 202995,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72922,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72923,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72924,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72925,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 72926,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 72928,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72931,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72927,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72929,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72930,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75694,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AFlameExtinguished, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 7),
    questline = 1397,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.SunderedLegacy,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheAncientBargain,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InheritedSin,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.InevitableConfrontation,
        },
    },
    active = {
        type = "quest",
        id = 74521,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75417,
    },
    items = {
        {
            type = "npc",
            id = 201727,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74521,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 74522,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 74523,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 74525,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75018,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75028,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75029,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75417,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ACrecheDivided, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 1393,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 72591,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72611,
    },
    items = {
        
    },
})
Database:AddChain(Chain.TheDragonsAndTheScaleExpedition, { -- Seems to require TheAncientBargain chapter of the campaign on 1 character, cant find a tracking quest though
    name = L["THE_DRAGONS_AND_THE_SCALE_EXPEDITION"],
    questline = 5353,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "achievement",
            id = ACHIEVEMENT_ID_1,
            criteria = 3,
        }
    },
    active = {
        type = "quest",
        ids = { 73036, 73037, },
        status = {'active', 'completed'},
        count = 1
    },
    completed = {
        type = "quest",
        id = 73045,
    },
    items = {
        {
            type = "npc",
            id = 200298,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 200291,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 73036,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 73037,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73046,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 73038,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 73040,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 73047,
                    restrictions = {
                        type = "quest",
                        id = 73047,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 200953,
                },
            },
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73041,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73042,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 73043,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 73039,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 73044,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73045,
            x = 0,
        },
        {
            visible = false,
            x = -3,
            y = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            aside = true,
            embed = true,
            x = 3,
            y = 0,
        },
    },
})
Database:AddChain(Chain.TheVeiledOssuary, {
    name = L["THE_VEILED_OSSUARY"],
    questline = 1398,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 72900,
        status = {'active', 'completed'},
    },
    completed = {
        type = "chain",
        ids = {
            100624, 100625, 100626, 100627, 100628, 
        },
        count = 5,
    },
    items = {
        {
            type = "npc",
            id = 187676,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72900,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72933,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72934,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73069,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75023,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72935,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72936,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72937,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72938,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 72940,
                    restrictions = {
                        type = "chain",
                        ids = {
                            100624, 100625, 100626, 100627, 100628, 
                        },
                        count = 1,
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                        status = { "active", },
                    },
                },
                {
                    type = "quest",
                    id = 72940,
                },
            },
            completed = {
                type = "chain",
                ids = {
                    100624, 100625, 100626, 100627, 100628, 
                },
                count = 1,
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
                    id = 73399,
                    restrictions = {
                        type = "chain",
                        ids = {
                            100624, 100625, 100626, 100627, 100628, 
                        },
                        count = 1,
                        notequals = true,
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                        status = { "active", },
                    },
                },
                {
                    type = "quest",
                    id = 73399,
                },
            },
            completed = {
                type = "chain",
                ids = {
                    100624, 100625, 100626, 100627, 100628, 
                },
                count = 2,
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
                    id = 73404,
                    restrictions = {
                        type = "chain",
                        ids = {
                            100624, 100625, 100626, 100627, 100628, 
                        },
                        count = 2,
                        notequals = true,
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                        status = { "active", },
                    },
                },
                {
                    type = "quest",
                    id = 73404,
                },
            },
            completed = {
                type = "chain",
                ids = {
                    100624, 100625, 100626, 100627, 100628, 
                },
                count = 3,
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
                    id = 73405,
                    restrictions = {
                        type = "chain",
                        ids = {
                            100624, 100625, 100626, 100627, 100628, 
                        },
                        count = 3,
                        notequals = true,
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                        status = { "active", },
                    },
                },
                {
                    type = "quest",
                    id = 73405,
                },
            },
            completed = {
                type = "chain",
                ids = {
                    100624, 100625, 100626, 100627, 100628, 
                },
                count = 4,
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
                    id = 73406,
                    restrictions = {
                        type = "chain",
                        ids = {
                            100624, 100625, 100626, 100627, 100628, 
                        },
                        count = 4,
                        notequals = true,
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain07,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain08,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain09,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain10,
                        status = { "active", },
                    },
                },
                {
                    type = "chain",
                    id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                    restrictions = {
                        type = "chain",
                        id = BtWQuests.Constant.Chain.Dragonflight.EmbersOfNeltharion.Chain11,
                        status = { "active", },
                    },
                },
                {
                    type = "quest",
                    id = 73406,
                },
            },
            completed = {
                type = "chain",
                ids = {
                    100624, 100625, 100626, 100627, 100628, 
                },
                count = 5,
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.UnitedAgain, {
    name = L["UNITED_AGAIN"],
    questline = 1404,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.TheVeiledOssuary,
        },
    },
    active = {
        type = "quest",
        id = 75244,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 72951,
    },
    items = {
        {
            type = "npc",
            id = 190000,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75244,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72942,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72946,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72947,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72948,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72949,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72950,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72951,
            x = 0,
        },
        {
            type = "quest",
            id = 72943,
            restrictions = false,
            x = -3,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = { -- Flightstones
        type = "quest",
        id = 72658,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
            upto = 72973,
        },
    },
    active = {
        type = "quest",
        id = 76101,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75507,
    },
    items = {
        {
            type = "npc",
            id = 204522,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76101,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72658,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75506,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75507,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Smells like Kith Spirit
        type = "quest",
        id = 72879,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
        },
    },
    active = {
        type = "quest",
        id = 72878,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72880,
    },
    items = {
        {
            type = "npc",
            id = 200054,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72878,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72879,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72880,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- Suss Out the Imposter
        type = "quest",
        id = 72886,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
        },
    },
    active = {
        type = "quest",
        id = 72881,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72886,
    },
    items = {
        {
            type = "npc",
            id = 200053,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72881,
            x = -1,
            connections = {
                1.2, 2, 
            },
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
            embed = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72882,
            x = -1,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72884,
            x = 0,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72886,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- The Buddy System
        type = "quest",
        id = 74876,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.Chain03,
        },
    },
    active = {
        type = "quest",
        id = 74877,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 74878,
    },
    items = {
        {
            type = "npc",
            id = 201426,
            restrictions = {
                {
                    type = "quest",
                    id = 74876,
                    status = { "active", "completed", },
                    restrictions = {
                        type = "quest",
                        id = 75241,
                        status = { "completed", },
                    },
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 201426,
            restrictions = {
                {
                    type = "quest",
                    id = 74876,
                    status = { "pending", },
                },
                {
                    type = "quest",
                    id = 75241,
                    status = { "completed", },
                },
            },
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 74876,
            restrictions = {
                {
                    type = "quest",
                    id = 74876,
                    status = { "active", "completed", },
                    restrictions = {
                        type = "quest",
                        id = 75241,
                        status = { "completed", },
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74877,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74953,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74878,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain05, { -- Are some of these quests repeatable?
    name = { -- TICKET: Glimmerogg Games
        type = "quest",
        id = 73707,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        ids = { 73707, 73708, 73709 },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 74787, 73711 },
        count = 2,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 73707,
                    restrictions = {
                        type = "quest",
                        id = 73707,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 201098,
                },
            },
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 73708,
            x = -2,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 73709,
            connections = {
                1, 2,
            },
        },
        {
            type = "npc",
            id = 201100,
            x = -2,
            connections = {
                2, 
            },
        },
        -- {
        --     type = "npc",
        --     id = 201099,
        --     connections = {
        --         3, 
        --     },
        -- },
        {
            type = "npc",
            id = 201752,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 73710,
            x = -2,
            connections = {
                2, 
            },
        },
        -- {
        --     variations = {
        --         type = "quest",
        --         id = 75707,
        --     },
        --     completed = {
        --         type = "quest",
        --         id = 75708,
        --     }
        -- },
        {
            type = "quest",
            id = 74787,
        },
        {
            type = "quest",
            id = 73711,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            aside = true,
            embed = true,
            x = 2,
            y = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    name = { -- Rest Well, Warrior
        type = "quest",
        id = 75985,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
            upto = 72978,
        },
    },
    active = {
        type = "quest",
        id = 75985,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75985,
    },
    items = {
        {
            type = "npc",
            id = 202788,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75985,
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
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 72591,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72611,
    },
    items = {
        {
            type = "npc",
            id = 204693,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75885,
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
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 75233,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75233,
    },
    items = {
        {
            type = "npc",
            id = 203378,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75233,
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
            level = 70,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            upto = 72881,
        }
    },
    active = {
        type = "quest",
        id = 72883,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72883,
    },
    items = {
        {
            type = "npc",
            id = 200238,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72883,
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
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 75440,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75440,
    },
    items = {
        {
            type = "npc",
            id = 200953,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75440,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TempChain22, {
    name = "Unnamed",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 72591,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72611,
    },
    items = {
        
    },
})
Database:AddChain(Chain.TempChain21, {
    name = "WEEKLY",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.BreakingGround,
            upto = 72973,
        },
    },
    active = {
        type = "quest",
        id = 75665,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75665,
    },
    items = {
        {
            type = "npc",
            id = 204254,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75665,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain06, { -- Agrulculture
    name = {
        type = "quest",
        id = 74858,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 74857,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75462,
    },
    items = {
        {
            type = "npc",
            id = 202597,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74857,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 74858,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 74859,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74860,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74861,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75462,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain07, {
    name = { -- Crystalsong Forest
        type = "quest",
        id = 73091,
    },
    questline = 1399,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 73091,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 74783,
    },
    items = {
        {
            type = "quest",
            id = 73091,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73090,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72670,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72674,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72679,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74783,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain08, {
    name = { -- Theramore
        type = "quest",
        id = 72939,
    },
    questline = 1400,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 72939,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 74335,
    },
    items = {
        {
            type = "quest",
            id = 72939,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73188,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72831,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72832,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72833,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74335,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain09, {
    name = { -- Booty Bay
        type = "quest",
        id = 73026,
    },
    questline = 1401,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 73026,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 73181,
    },
    items = {
        {
            type = "quest",
            id = 73026,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72988,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72527,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72529,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72530,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72532,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72533,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72534,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73181,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain10, {
    name = { -- Jade Forest
        type = "quest",
        id = 73227,
    },
    questline = 1402,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 73227,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 74291,
    },
    items = {
        {
            type = "quest",
            id = 73227,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72650,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72651,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72653,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72654,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72652,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72655,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74291,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain11, {
    name = { -- Winterspring
        type = "quest",
        id = 72656,
    },
    questline = 1403,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 72656,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 74356,
    },
    items = {
        {
            type = "quest",
            id = 72656,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72657,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74354,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72659,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72660,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72661,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74356,
            x = 0,
        },
    },
})
Database:AddChain(Chain.RebelResurgence, {
    name = L["REBEL_RESURGENCE"],
    questline = 5368,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Thaldraszus.TempChain08,
        },
    },
    active = {
        type = "quest",
        id = 72411,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75230,
    },
    items = {
        {
            type = "npc",
            id = 189842,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72411,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72412,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 72413,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 72414,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72415,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72416,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72417,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72418,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72419,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 72420,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 72421,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72422,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75230,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TyrsFall, {
    name = { -- Tyr's Fall
        type = "quest",
        id = 72443,
    },
    questline = 1377,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            name = {
                type = "currency",
                id = 2088,
                amount = 12,
            },
            type = "achievement",
            id = 16988, -- Account bound achievement for Rank 12
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Dragonflight.TheSilverPurpose,
        },
    },
    active = {
        type = "quest",
        id = 72440,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72444,
    },
    items = {
        {
            type = "npc",
            id = 198941,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72440,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72441,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72442,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72526,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72443,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72444,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests_GetAchievementNameDelayed(ACHIEVEMENT_ID_1),
    expansion = EXPANSION_ID,
    buttonImage = 5149418,
    items = {
        {
            type = "chain",
            id = Chain.BreakingGround,
        },
        {
            type = "chain",
            id = Chain.SunderedLegacy,
        },
        {
            type = "chain",
            id = Chain.TheAncientBargain,
        },
        {
            type = "chain",
            id = Chain.InheritedSin,
        },
        {
            type = "chain",
            id = Chain.InevitableConfrontation,
        },
        {
            type = "chain",
            id = Chain.AFlameExtinguished
        },
        {
            type = "chain",
            id = Chain.TheDragonsAndTheScaleExpedition
        },
        {
            type = "chain",
            id = Chain.TheVeiledOssuary
        },
        {
            type = "chain",
            id = Chain.UnitedAgain
        },
        {
            type = "chain",
            id = Chain.RebelResurgence,
        },
        {
            type = "chain",
            id = Chain.TyrsFall,
        },
        -- {
        --     type = "chain",
        --     id = Chain.Chain01,
        -- },
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
        }
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "category",
        id = CATEGORY_ID,
    },
})

Database:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddContinentItems(CONTINENT_ID, {
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
        id = Chain.EmbedChain05,
    },
})
