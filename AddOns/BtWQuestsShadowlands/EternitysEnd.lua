local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.EternitysEnd
local Chain = BtWQuests.Constant.Chain.Shadowlands.EternitysEnd
local LEVEL_RANGE = {60, 60}
local MAP_ID = 1970
local ACHIEVEMENT_ID = 15259

Database:AddChain(Chain.IntoTheUnknown, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = 1265,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
        },
    },
    active = {
        type = "quest",
        id = 64942,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64958,
    },
    rewards = {
        {
            type = "money",
            amount = 2496780,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 550,
        },
    },
    items = {
        {
            type = "quest",
            id = 64942,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64944,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64945,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65456,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64947,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64949,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64950,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64951,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65271,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64952,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64953,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64957,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64958,
            x = 0,
        },
    }
})
Database:AddChain(Chain.WeBattleOnward, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    questline = 1266,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
        },
    },
    active = {
        type = "quest",
        ids = { 65768, 65771, 65772, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64825,
    },
    rewards = {
        {
            type = "money",
            amount = 3655080,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 1175,
        },
    },
    items = {
        {
            type = "npc",
            id = 178015,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 181183,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 178016,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65771,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65768,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65772,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64794,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64796,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64797,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64814,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64815,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64817,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64818,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 64820,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 64821,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64822,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64823,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64824,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64825,
            x = 0,
        },
    }
})
Database:AddChain(Chain.FormingAnUnderstanding, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = 1250,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
        },
    },
    active = {
        type = "quest",
        id = 64218,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65305,
    },
    rewards = {
        {
            type = "money",
            amount = 1776060,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
        {
            type = "currency",
            id = 1979,
            amount = 125,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 375,
        },
        {
            name = L["BTWQUESTS_WORLD_QUESTS"],
            type = "spell",
            id = 366935,
        },
    },
    items = {
        {
            type = "npc",
            id = 179611,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64218,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64219,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64223,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64224,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64225,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64226,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64227,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64228,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65149,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64230,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65305,
            x = -1,
        },
        {
            type = "quest",
            id = 65324,
            aside = true,
        },
    }
})
Database:AddChain(Chain.ForgingANewPath, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = 1262,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
        },
    },
    active = {
        type = "quest",
        id = 65335,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64844,
    },
    rewards = {
        {
            type = "money",
            amount = 2985840,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 183677,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65335,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64830,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64833,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64831,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64832,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64837,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64834,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64838,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64969,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 64835,
            x = -2,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 64836,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 64839,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 64840,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 64841,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65331,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64842,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64843,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64844,
            x = 0,
        },
    }
})
Database:AddChain(Chain.CrownOfWills, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 1258,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ForgingANewPath,
        },
        -- { -- Not sure if this is actually required
        --     type = "achievement",
        --     id = 15417,
        --     criteriaId = 53158,
        -- }
    },
    active = {
        type = "quest",
        id = 64799,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64816,
    },
    rewards = {
        {
            type = "money",
            amount = 3294720,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 181183,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64799,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64800,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64802,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64803,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 64801,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64804,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64805,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64853,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64809,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64810,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64811,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64806,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64807,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64808,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64798,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64812,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64813,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64816,
            x = 0,
        },
    }
})
Database:AddChain(Chain.AMeansToAnEnd, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    questline = 1264,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ForgingANewPath,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.CrownOfWills,
        },
    },
    active = {
        type = "quest",
        id = 64875,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65328,
    },
    rewards = {
        {
            type = "money",
            amount = 2664090,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 500,
        },
    },
    items = {
        {
            type = "npc",
            id = 182556,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64875,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64876,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64878,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64888,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 65245,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64889,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64935,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64936,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64937,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65237,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65328,
            x = 0,
        },
    }
})
Database:AddChain(Chain.StartingOver, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    questline = 1260,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ForgingANewPath,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.CrownOfWills,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AMeansToAnEnd,
        },
    },
    active = {
        type = "quest",
        ids = {64879, 64723, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65238,
    },
    rewards = {
        {
            type = "money",
            amount = 4465890,
        },
        {
            type = "reputation",
            id = 2407,
            amount = 250,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 500,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 64879,
                    restrictions = {
                        type = "quest",
                        id = 64879,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 177958,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64723,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64733,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 64718,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 64706,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64720,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64722,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64727,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64726,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64725,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64728,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64730,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64731,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64729,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65238,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65329,
            aside = true,
            x = 0,
        },
    }
})
Database:AddChain(Chain.EpilogueJudgment, {
    name = L["EPILOGUE_JUDGMENT"],
    questline = 1284,
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
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ForgingANewPath,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.CrownOfWills,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AMeansToAnEnd,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.StartingOver,
        },
    },
    active = {
        type = "quest",
        id = 65249,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65297,
    },
    rewards = {
    },
    items = {
        {
            type = "npc",
            id = 181183,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65249,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65250,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65260,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65263,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65297,
            x = 0,
        },
    }
})

Database:AddChain(Chain.NotAlAreLost, {
    name = L["NOT_AL_ARE_LOST"],
    questline = 1291,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
        },
    },
    active = {
        type = "quest",
        id = 64771,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64760,
    },
    rewards = {
        {
            type = "money",
            amount = 1608750,
        },
    },
    items = {
        {
            type = "npc",
            id = 181003,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64771,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64741,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64742,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64744,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64743,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64758,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64760,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SmallPetProblems, {
    name = L["SMALL_PET_PROBLEMS"],
    questline = 1296,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
        },
    },
    active = {
        type = "quest",
        id = 65064,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65070,
    },
    rewards = {
        {
            type = "money",
            amount = 1544400,
        },
        {
            type = "pet",
            id = 3237,
        },
    },
    items = {
        {
            type = "npc",
            id = 184486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65064,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65066,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65067,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65068,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65069,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65070,
            x = 0,
            connections = {
                1, 
            },
        },
    },
})
Database:AddChain(Chain.TheWatersOfGrace, {
    name = L["THE_WATERS_OF_GRACE"],
    questline = 1297,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
        },
    },
    active = {
        type = "quest",
        ids = {65463, 65349},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65448,
    },
    rewards = {
        {
            type = "money",
            amount = 772200,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 65463,
                    restrictions = {
                        type = "quest",
                        id = 65463,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 182146,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65349,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65350,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65353,
            aside = true,
        },
        {
            type = "quest",
            id = 65448,
            x = 0,
        },
    },
})
Database:AddChain(Chain.CyphersOfTheFirstOnes, {
    name = L["CYPHERS_OF_THE_FIRST_ONES"],
    questline = 1288,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65431,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65433,
    },
    rewards = {
        {
            type = "money",
            amount = 334620,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
        {
            type = "currency",
            id = 1979,
            amount = 120,
        },
    },
    items = {
        {
            type = "quest",
            id = 64230,
        },
        {
            type = "npc",
            id = 177958,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65431,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65432,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65433,
            x = 0,
        },
    },
})

Database:AddChain(Chain.JiroToHero, {
    name = L["JIRO_TO_HERO"],
    questline = 1277,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            upto = 64230,
        },
        {
            type = "garrisontalent",
            id = 1902,
        }
    },
    active = {
        type = "quest",
        id = 64772,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65219,
    },
    rewards = {
        {
            type = "money",
            amount = 1287000,
        },
    },
    items = {
        {
            type = "npc",
            id = 181091,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64772,
            completed = {
                type = "quest",
                id = 64772,
                status = { "active", "completed", },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 64773,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 64713,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65370,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64772,
            active = {
                type = "quest",
                ids = {
                    64773, 64713, 65370, 
                },
                count = 3,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64775,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64739,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 64779,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 64778,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64780,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65219,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheFinalSong, {
    name = L["THE_FINAL_SONG"],
    questline = 1285,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            upto = 64230,
        },
        {
            type = "garrisontalent",
            id = 1931,
        }
    },
    active = {
        type = "quest",
        id = 64829,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65420,
    },
    rewards = {
        {
            type = "money",
            amount = 2007720,
        },
    },
    items = {
        {
            type = "npc",
            id = 180630,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64829,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64745,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64759,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64761,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64762,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64763,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64766,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64767,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65420,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ReapWhatYouSow, {
    name = L["REAP_WHAT_YOU_SOW"],
    questline = 1290,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            upto = 64230,
        },
        {
            type = "garrisontalent",
            id = 1931,
        }
    },
    active = {
        type = "quest",
        id = 64641,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64648,
    },
    rewards = {
        {
            type = "money",
            amount = 2059200,
        },
    },
    items = {
        {
            type = "npc",
            id = 180799,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64641,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64642,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64643,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64644,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64645,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64646,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64647,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64648,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ANewArchitect, {
    name = L["A_NEW_ARCHITECT"],
    questline = 1293,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Torghast,
            upto = 61099,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
            upto = 64230,
        },
        {
            type = "garrisontalent",
            id = 1931,
        },
        {
            type = "chain",
            id = Chain.TheFinalSong,
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_DAILY_RESET"],
            type = "chain",
            id = Chain.TheFinalSong,
            restrictions = {
                type = "quest",
                id = 65619,
                status = {'pending'}
            }
        }
    },
    active = {
        type = "quest",
        id = 65426,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65427,
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
            id = 181273,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65426,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65427,
            x = 0,
        },
        {
            type = "quest",
            id = 65380,
            restrictions = false,
        },
    }
})
Database:AddChain(Chain.Chain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65419,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65419,
    },
    rewards = {
        {
            type = "money",
            amount = 25740,
        },
    },
    items = {
        {
            type = "garrisontalent",
            id = 1932,
        },
        {
            type = "npc",
            id = 181059,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65419,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65700,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65700,
    },
    rewards = {
        {
            type = "money",
            amount = 128700,
        },
    },
    items = {
        {
            type = "garrisontalent",
            id = 1932,
        },
        {
            type = "npc",
            id = 177958,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65700,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65749,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65749,
    },
    rewards = {
        {
            type = "money",
            amount = 257400,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 50,
        },
    },
    items = {
        {
            type = "quest",
            id = 64230,
        },
        {
            type = "npc",
            id = 177958,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65749,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65748,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65748,
    },
    rewards = {
        {
            type = "money",
            amount = 514800,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 75,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
        },
        {
            type = "npc",
            id = 185713,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65748,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65727,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65727,
    },
    rewards = {
    },
    items = {
        {
            name = "One or more of the first 3 quests in We Battle Onwards",
        },
        {
            type = "npc",
            id = 180950,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65727,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65735,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65735,
    },
    rewards = {
        {
            type = "money",
            amount = 514800,
        },
        {
            type = "reputation",
            id = 2478,
            amount = 200,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
        },
        {
            type = "object",
            id = 375972,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65735,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        ids = {65460, 65461, 65466},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {65460, 65461, 65466},
        count = 3,
    },
    rewards = {
        {
            type = "money",
            amount = 77220,
        },
        {
            type = "currency",
            id = 1979,
            amount = 15,
        },
    },
    items = {
        {
            type = "npc",
            id = 177958,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65460,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65461,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 65466,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Chain08, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 65674,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 65674,
    },
    rewards = {
        {
            type = "money",
            amount = 128700,
        },
    },
    items = {
        {
            type = "item",
            id = 190579,
        },
        {
            type = "quest",
            id = 65674,
        },
    }
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests_GetAchievementName(ACHIEVEMENT_ID),
    expansion = EXPANSION_ID,
    buttonImage = 4423752,
    items = {
        {
            type = "chain",
            id = Chain.IntoTheUnknown,
        },
        {
            type = "chain",
            id = Chain.WeBattleOnward,
        },
        {
            type = "chain",
            id = Chain.FormingAnUnderstanding,
        },
        {
            type = "chain",
            id = Chain.ForgingANewPath,
        },
        {
            type = "chain",
            id = Chain.CrownOfWills,
        },
        {
            type = "chain",
            id = Chain.AMeansToAnEnd,
        },
        {
            type = "chain",
            id = Chain.StartingOver,
        },
        {
            type = "chain",
            id = Chain.EpilogueJudgment,
        },
        
        {
            type = "chain",
            id = Chain.NotAlAreLost,
        },
        {
            type = "chain",
            id = Chain.SmallPetProblems,
        },
        {
            type = "chain",
            id = Chain.TheWatersOfGrace,
        },
        {
            type = "chain",
            id = Chain.JiroToHero,
        },
        {
            type = "chain",
            id = Chain.TheFinalSong,
        },
        {
            type = "chain",
            id = Chain.ReapWhatYouSow,
        },
        {
            type = "chain",
            id = Chain.ANewArchitect,
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