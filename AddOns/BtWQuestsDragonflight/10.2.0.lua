if select(4, GetBuildInfo()) < 100200 then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local CATEGORY_ID = BtWQuests.Constant.Category.Dragonflight.GuardiansOfTheDream
local Chain = BtWQuests.Constant.Chain.Dragonflight.GuardiansOfTheDream
local CONTINENT_ID = 1978
local MAP_ID = 2200
local ACHIEVEMENT_ID_1 = 19026
local LEVEL_RANGE = {70, 70}

Chain.EnterTheDream = 100701
Chain.DruidsOfTheFlame = 100702
Chain.IceAndFire = 100703
Chain.EyeOfYsera = 100704
Chain.ADreamOfFieldsAndFire = 100705
Chain.NewBeginnings = 100706

Chain.MisfitDragons = 100707

Chain.TempChain01 = 100708
Chain.TempChain02 = 100709
Chain.TempChain03 = 100710
Chain.TempChain04 = 100711
Chain.TempChain05 = 100712
Chain.TempChain06 = 100713
Chain.TempChain07 = 100714
Chain.TempChain08 = 100715
Chain.TempChain09 = 100716
Chain.TempChain10 = 100717
Chain.TempChain11 = 100718
Chain.TempChain12 = 100719
Chain.TempChain13 = 100720
Chain.TempChain14 = 100721
Chain.TempChain15 = 100722
Chain.TempChain16 = 100723
Chain.TempChain17 = 100724
Chain.TempChain18 = 100725
Chain.TempChain19 = 100726

Database:AddChain(Chain.EnterTheDream, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 5456,
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
            id = BtWQuests.Constant.Chain.Dragonflight.TheCoalitionOfFlames,
        }
    },
    active = {
        type = "quest",
        id = 76317,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77283,
    },
    items = {
        {
            type = "quest",
            id = 76317,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76318,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76319,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76320,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76321,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76322,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77818,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76323,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76324,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76325,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76326,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77283,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DruidsOfTheFlame, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 5471,
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
            id = BtWQuests.Constant.Chain.Dragonflight.TheCoalitionOfFlames,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EnterTheDream,
        },
    },
    active = {
        type = "quest",
        id = 77436,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76443
    },
    items = {
        {
            type = "npc",
            id = 206896,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77436,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76433,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76434,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76435,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76437,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76441,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76442,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76443,
            x = 0,
        },
    },
})
Database:AddChain(Chain.IceAndFire, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 5472,
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
            id = BtWQuests.Constant.Chain.Dragonflight.TheCoalitionOfFlames,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EnterTheDream,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DruidsOfTheFlame,
        },
    },
    active = {
        type = "quest",
        id = 76403,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77178,
    },
    items = {
        {
            type = "npc",
            id = 208506,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76403,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76342,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 76343,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76344,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76345,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76532,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76348,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76347,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77178,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EyeOfYsera, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 4),
    questline = 5460,
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
            id = BtWQuests.Constant.Chain.Dragonflight.TheCoalitionOfFlames,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EnterTheDream,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DruidsOfTheFlame,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IceAndFire,
        },
    },
    active = {
        type = "quest",
        id = 76327,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76337,
    },
    items = {
        {
            type = "npc",
            id = 206408,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76327,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76328,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78646,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76329,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76330,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76334,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76332,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76331,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76335,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76333,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76336,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76337,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ADreamOfFieldsAndFire, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 5),
    questline = 5465,
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
            id = BtWQuests.Constant.Chain.Dragonflight.TheCoalitionOfFlames,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EnterTheDream,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DruidsOfTheFlame,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IceAndFire,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EyeOfYsera,
        },
    },
    active = {
        type = "quest",
        id = 76384,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76401,
    },
    items = {
        {
            type = "npc",
            id = 206896,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76384,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76416,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76385,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 76386,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76387,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76436,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76388,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76389,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76398,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76401,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76402,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.NewBeginnings, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 6),
    questline = 5473,
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
            id = BtWQuests.Constant.Chain.Dragonflight.TheCoalitionOfFlames,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EnterTheDream,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DruidsOfTheFlame,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IceAndFire,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EyeOfYsera,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ADreamOfFieldsAndFire,
            upto = 76402,
        },
    },
    active = {
        type = "quest",
        id = 77780,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76283,
    },
    items = {
        {
            type = "npc",
            id = 211634,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77780,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76276,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77329,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77200,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 77201,
                    restrictions = {
                        type = "race",
                        id = BtWQuests.Constant.Race.NightElf,
                    },
                },
                {
                    type = "quest",
                    id = 76280,
                },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 76281,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 77781,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76282,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76283,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MisfitDragons, {
    name = L["MISFIT_DRAGONS"],
    questline = 5474,
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
            id = BtWQuests.Constant.Chain.Dragonflight.TheCoalitionOfFlames,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.EnterTheDream,
            upto = 76317,
        },
    },
    active = {
        type = "quest",
        id = 76460,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 76465,
    },
    items = {
        {
            type = "npc",
            id = 207350,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76460,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76461,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77195,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76462,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77197,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76463,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77198,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76464,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76465,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain01, {
    name = { -- Dreaming of Crests
        type = "quest",
        id = 78271,
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
            id = Chain.EnterTheDream,
            upto = 76317,
        },
    },
    active = {
        type = "quest",
        id = 78262,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78271,
    },
    items = {
        {
            type = "npc",
            id = 211328,
            x = 0,
            connections = {
                1, 
            },
            comment = "10.2 crafting introduction",
        },
        {
            type = "quest",
            id = 78262,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78271,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain02, {
    name = { -- Burning Out
        type = "quest",
        id = 77948,
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
            id = Chain.EnterTheDream,
            upto = 76317,
        },
    },
    active = {
        type = "quest",
        id = 77948,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77948,
    },
    items = {
        {
            type = "npc",
            id = 210196,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77948,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain03, {
    name = { -- A Worthy Ally: Dream Wardens
        type = "quest",
        id = 78444,
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
            id = Chain.EnterTheDream,
            upto = 76326,
        },
    },
    active = {
        type = "quest",
        id = 78444,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78444,
    },
    items = {
        {
            type = "npc",
            id = 208143,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78444,
            comment = "weekly?",
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain04, {
    name = { -- Dreams Unified
        type = "quest",
        id = 78381,
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
            id = Chain.EnterTheDream,
            upto = 76326,
        },
    },
    active = {
        type = "quest",
        id = 78381,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78381,
    },
    items = {
        {
            type = "npc",
            id = 208669,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78381,
            comment = "Bi-weekly crafting?",
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain05, {
    name = { -- Blooming Dreamseeds
        type = "quest",
        id = 78821,
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
            id = Chain.EnterTheDream,
            upto = 76326,
        },
    },
    active = {
        type = "quest",
        id = 78821,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78821,
    },
    items = {
        {
            type = "npc",
            id = 212797,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78821,
            comment = "A weekly",
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain06, {
    name = { -- Great Crates!
        type = "quest",
        id = 78427,
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
            id = Chain.EnterTheDream,
            upto = 76326,
            completed = {
                type = "quest",
                id = 77887, -- or maybe 77572
            }
        },
    },
    active = {
        type = "quest",
        id = 78427,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78428,
    },
    items = {
        {
            type = "npc",
            id = 211240,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78427,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78428,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain07, {
    name = { -- A Passed Torch
        type = "quest",
        id = 77978,
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
            id = Chain.EnterTheDream,
            upto = 76317,
        },
        {
            type = "quest",
            id = 77948,
            status = {'active', 'completed'}
        },
    },
    active = {
        type = "quest",
        id = 77978,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77978,
    },
    items = {
        {
            type = "object",
            id = 409077,
            x = 0,
            connections = {
                1, 
            },
            comment = "unknown requirement, not right after getting in to zone",
        },
        {
            type = "quest",
            id = 77978,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain08, {
    name = { -- Trouble at the Tree
        type = "quest",
        id = 77316,
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
            id = Chain.IceAndFire,
            comment = "probably",
            completed = {
                type = "quest",
                id = 78904,
            }
        },
    },
    active = {
        type = "quest",
        id = 77316,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77318,
    },
    items = {
        {
            type = "npc",
            id = 208669,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77316,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77317,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77318,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain09, {
    name = { -- Sleepy Druid in Emerald Dream
        type = "quest",
        id = 77958,
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
            id = Chain.IceAndFire,
            comment = "probably",
            completed = {
                type = "quest",
                id = 78904,
            }
        },
    },
    active = {
        type = "quest",
        id = 77896,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77958,
    },
    items = {
        {
            type = "npc",
            id = 210133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77896,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 77911,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 77922,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77955,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77958,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain11, {
    name = { -- A Better Future, Together
        type = "quest",
        id = 77675,
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
            id = Chain.IceAndFire,
            comment = "probably",
            completed = {
                type = "quest",
                id = 78904,
            }
        },
    },
    active = {
        type = "quest",
        id = 77662,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77675,
    },
    items = {
        {
            type = "npc",
            id = 209516,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77662,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77739,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77664,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77665,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77673,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77674,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77675,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain12, {
    name = { -- Memory of the Dreamer
        type = "quest",
        id = 77310,
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
            id = Chain.IceAndFire,
            comment = "probably",
            completed = {
                type = "quest",
                id = 78904,
            }
        },
    },
    active = {
        type = "quest",
        id = 77310,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77315,
    },
    items = {
        {
            type = "npc",
            id = 210022,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77310,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77311,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 77312,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 77313,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77314,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77315,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain13, {
    name = { -- The Superbloom
        type = "quest",
        id = 78319,
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
            id = Chain.EnterTheDream,
            upto = 76326,
            completed = {
                type = "quest",
                id = 77887, -- or maybe 77572
            }
        },
    },
    active = {
        type = "quest",
        id = 78319,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78319,
    },
    items = {
        {
            type = "npc",
            id = 208474,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78319,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain15, {
    name = { -- A Poisonous Promotion
        type = "quest",
        id = 76572,
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
            id = Chain.IceAndFire,
            comment = "probably",
            completed = {
                type = "quest",
                id = 78904,
            }
        },
    },
    active = {
        type = "quest",
        ids = { 76567, 76568 },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77802,
    },
    items = {
        {
            type = "quest",
            id = 76566,
            restrictions = false,
        },
        {
            type = "npc",
            id = 207779,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76567,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76568,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76569,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 76570,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 76571,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76572,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77802,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain10, {
    name = { -- The Q'onzu Query
        type = "quest",
        id = 78065,
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
            id = Chain.IceAndFire,
            comment = "probably",
            completed = {
                type = "quest",
                id = 78904,
            }
        },
    },
    active = {
        type = "quest",
        id = 78065,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78066,
    },
    items = {
        {
            type = "npc",
            id = 209318,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78065,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78163,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78064,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78162,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78066,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempChain16, {
    name = { -- Overseer Oversight
        type = "quest",
        id = 78046,
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
            id = BtWQuests.Constant.Chain.Dragonflight.GuardiansOfTheDream.TempChain10,
        },
    },
    active = {
        type = "quest",
        id = 78041,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78046,
    },
    items = {
        {
            type = "npc",
            id = 209318,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78041,
            x = 0,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "item",
            id = 208775,
            breadcrumb = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 78042,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 78043,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 77788,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78044,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78045,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78046,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain14, {
    name = { -- Emerald Reawakening
        type = "quest",
        id = 78386,
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
            name = {
                type = "currency",
                id = 2653,
                amount = 5,
            },
            type = "achievement",
            id = 19220,
        }
    },
    active = {
        type = "quest",
        id = 78386,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78431,
    },
    items = {
        {
            type = "npc",
            id = 211962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78386,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78430,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78431,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain17, {
    name = { -- Emerald Bounty
        type = "quest",
        id = 78206,
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
            id = Chain.EnterTheDream,
            upto = 76326,
            completed = {
                type = "quest",
                id = 77887, -- or maybe 77572
            }
        },
    },
    active = {
        type = "quest",
        id = 78172,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78206,
    },
    items = {
        {
            type = "item",
            id = 210050,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78172,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77209,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78170,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78171,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78206,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TempChain18, {
    name = { -- Burning Out
        type = "quest",
        id = 77948,
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
            id = Chain.EnterTheDream,
            upto = 76317,
        },
    },
    active = {
        type = "quest",
        id = 77948,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 77948, 77978 },
        count = 2,
    },
    items = {
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.GuardiansOfTheDream.TempChain02,
            aside = true,
            embed = true,
            connections = {
                { 0.2, 1.2, }, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.GuardiansOfTheDream.TempChain07,
            aside = true,
            embed = true,
        },
    }
})
Database:AddChain(Chain.TempChain19, {
    name = L["TYRS_RETURN"],
    questline = 5476,
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
            id = BtWQuests.Constant.Chain.Dragonflight.ReforgingTheTyrsGuard,
        },
    },
    active = {
        type = "quest",
        id = 77339,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77344,
    },
    items = {
        {
            type = "npc",
            id = 208703,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77339,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77377,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77340,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77342,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77343,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77344,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_WEEKLY_RESET"],
            aside = true,
            active = {
                type = "quest",
                id = 77344,
            },
            completed = {
                {
                    type = "quest",
                    id = 77344,
                },
                {
                    type = "quest",
                    id = 77820,
                    status = { "pending", },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77341,
            aside = true,
            x = 0,
        },
    }
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests_GetAchievementNameDelayed(ACHIEVEMENT_ID_1),
    expansion = EXPANSION_ID,
    buttonImage = 5409261,
    items = {
        {
            type = "chain",
            id = Chain.EnterTheDream,
        },
        {
            type = "chain",
            id = Chain.DruidsOfTheFlame,
        },
        {
            type = "chain",
            id = Chain.IceAndFire,
        },
        {
            type = "chain",
            id = Chain.EyeOfYsera,
        },
        {
            type = "chain",
            id = Chain.ADreamOfFieldsAndFire,
        },
        {
            type = "chain",
            id = Chain.NewBeginnings,
        },
        {
            type = "chain",
            id = Chain.TempChain19,
        },
        {
            type = "chain",
            id = Chain.MisfitDragons,
        },
        
        {
            type = "chain",
            id = Chain.TempChain18,
        },
        {
            type = "chain",
            id = Chain.TempChain06,
        },
        {
            type = "chain",
            id = Chain.TempChain13,
        },
        {
            type = "chain",
            id = Chain.TempChain17,
        },
        {
            type = "chain",
            id = Chain.TempChain08,
        },
        {
            type = "chain",
            id = Chain.TempChain09,
        },
        {
            type = "chain",
            id = Chain.TempChain11,
        },
        {
            type = "chain",
            id = Chain.TempChain12,
        },
        {
            type = "chain",
            id = Chain.TempChain15,
        },
        {
            type = "chain",
            id = Chain.TempChain10,
        },
        {
            type = "chain",
            id = Chain.TempChain16,
        },
        {
            type = "chain",
            id = Chain.TempChain14,
        },
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
        id = Chain.TempChain02,
    },
    {
        type = "chain",
        id = Chain.TempChain06,
    },
    {
        type = "chain",
        id = Chain.TempChain07,
    },
    {
        type = "chain",
        id = Chain.TempChain08,
    },
    {
        type = "chain",
        id = Chain.TempChain09,
    },
    {
        type = "chain",
        id = Chain.TempChain11,
    },
    {
        type = "chain",
        id = Chain.TempChain12,
    },
    {
        type = "chain",
        id = Chain.TempChain13,
    },
    {
        type = "chain",
        id = Chain.TempChain15,
    },
    {
        type = "chain",
        id = Chain.TempChain10,
    },
    {
        type = "chain",
        id = Chain.TempChain16,
    },
    {
        type = "chain",
        id = Chain.TempChain14,
    },
    {
        type = "chain",
        id = Chain.TempChain17,
    },
})
