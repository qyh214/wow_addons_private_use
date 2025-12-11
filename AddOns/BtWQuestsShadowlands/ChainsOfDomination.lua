local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local CATEGORY_ID = BtWQuests.Constant.Category.Shadowlands.ChainsOfDomination
local Chain = BtWQuests.Constant.Chain.Shadowlands.ChainsOfDomination
local LEVEL_RANGE = {60, 60}
local MAP_ID = 1961
local ACHIEVEMENT_ID = 14961

Database:AddChain(Chain.BattleOfArdenweald, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    questline = 1219,
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
    },
    active = {
        type = "quest",
        id = 63576,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63639,
    },
    rewards = {
        {
            type = "money",
            amount = 1132560,
        },
        {
            type = "reputation",
            id = 2465,
            amount = 500,
        },
    },
    items = {
        {
            type = "quest",
            id = 63576,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63856,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63857,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63578,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63638,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63904,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63639,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MawWalkers, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    questline = 1225,
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
            id = Chain.BattleOfArdenweald,
        },
    },
    active = {
        type = "quest",
        id = 63660,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64556,
    },
    rewards = {
        {
            name = L["THE_TRUE_MAW_WALKER"],
            type = "spell",
            id = 353214,
        },
        {
            type = "money",
            amount = 1595880,
        },
        {
            type = "reputation",
            id = 2432,
            amount = 550,
        },
        {
            type = "reputation",
            id = 2470,
            amount = 750,
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
            type = "quest",
            id = 63660,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63661,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63662,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63663,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63994,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63665,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64007,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64555,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64556,
            x = 0,
        },
    },
})
Database:AddChain(Chain.FocusingTheEye, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    questline = 1234,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
        },
    },
    active = {
        type = "quest",
        id = 63848,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63902,
    },
    rewards = {
        {
            name = L["ANIMAFLOW_TELEPORTER_LINK"],
            type = "spell",
            id = 353465,
        },
        {
            name = L["BLIND_THE_EYE"],
            type = "spell",
            id = 353606,
        },
        {
            type = "money",
            amount = 3629340,
        },
        {
            type = "reputation",
            id = 1948,
            amount = 1750,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 2432,
            amount = 2050,
        },
    },
    items = {
        {
            type = "npc",
            id = 177927,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63848,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63855,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63895,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63849,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63810,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63754,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63764,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63811,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63831,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63844,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63845,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64014,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63867,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63896,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63901,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63902,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64106,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheLastSigil, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    questline = 1222,
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
            type = "renown",
            level = 44,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.TheBellTolls or 90609,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Dominion or 90909,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.DrustAndAshes or 90809,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.AssaultOnTheHouseOfRituals or 90709,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
        },
    },
    active = {
        type = "quest",
        id = 63703,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63727,
    },
    rewards = {
        {
            type = "money",
            amount = 4144140,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
        {
            type = "currency",
            id = 1906,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2470,
            amount = 1125,
        },
    },
    items = {
        {
            type = "npc",
            id = 177927,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63703,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 63704,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 63705,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63706,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63709,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63710,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63711,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63712,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63713,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63714,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63717,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63722,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63725,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63726,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63727,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AnArmyOfBoneAndSteel, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    questline = 1224,
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
            type = "renown",
            level = 47,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.TheBellTolls or 90609,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Dominion or 90909,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.DrustAndAshes or 90809,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.AssaultOnTheHouseOfRituals or 90709,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheLastSigil,
        },
    },
    active = {
        type = "quest",
        id = 63612,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63622,
    },
    rewards = {
        {
            type = "money",
            amount = 2368080,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
        {
            type = "reputation",
            id = 2410,
            amount = 750,
        },
    },
    items = {
        {
            type = "npc",
            id = 177194,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63612,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 63613,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 63614,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63615,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63616,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63617,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63618,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63619,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63620,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63622,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63623,
            aside = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63624,
            aside = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheUnseenGuest, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    questline = {1220, 1252},
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
            type = "renown",
            level = 50,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.TheBellTolls or 90609,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Dominion or 90909,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.DrustAndAshes or 90809,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.AssaultOnTheHouseOfRituals or 90709,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheLastSigil,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnArmyOfBoneAndSteel,
        },
    },
    active = {
        type = "quest",
        id = 63659,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63656,
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
        {
            type = "reputation",
            id = 2413,
            amount = 750,
        },
    },
    items = {
        {
            type = "npc",
            id = 177167,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63659,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63644,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 63645,
            x = 0,
            breadcrumb = true,
            connections = {
                1, 
            },
            comment = "Maybe removed? This quest relates to prerequistes for the start of 9.1, which can be skipped, maybe if skipped this is offered for a recap?",
            -- Need to figure out the exact requirements for this to show, maybe hidden achievement for sire kill?
            -- restrictions = {
            --     type = "quest",
            --     id = 60501,
            --     status = {'pending'}
            -- }
        },
        {
            type = "quest",
            id = 63646,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63647,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63648,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63649,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63650,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63651,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63652,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63653,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63654,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 63655,
            aside = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
            x = -1,
        },
        {
            type = "quest",
            id = 63656,
            variations = {
                {
                    x = 1,
                    restrictions = {
                        type = "covenant",
                        id = 2,
                    },
                },
                {
                    x = 0,
                },
            }
        },
    },
})
Database:AddChain(Chain.ThePowerOfNight, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    questline = 1221,
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
            type = "renown",
            level = 52,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.TheBellTolls or 90609,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Dominion or 90909,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.DrustAndAshes or 90809,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.AssaultOnTheHouseOfRituals or 90709,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheLastSigil,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnArmyOfBoneAndSteel,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheUnseenGuest,
        },
    },
    active = {
        type = "quest",
        id = 63672,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63683,
    },
    rewards = {
        {
            type = "money",
            amount = 2960100,
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
            id = 177919,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63672,
            x = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 63673,
                    restrictions = {
                        type = "covenant",
                        id = 3,
                    },
                },
                {
                    type = "quest",
                    id = 63728,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63990,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63674,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 63675,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 63676,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63677,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63678,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63679,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64092,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64091,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64090,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63680,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63681,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64042,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63682,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63683,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64437,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ANewPath, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 8),
    questline = 1218,
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
            type = "renown",
            level = 56,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Kyrian.TheBellTolls or 90609,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Venthyr.Dominion or 90909,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.NightFae.DrustAndAshes or 90809,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Shadowlands.Necrolord.AssaultOnTheHouseOfRituals or 90709,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheLastSigil,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnArmyOfBoneAndSteel,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheUnseenGuest,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ThePowerOfNight,
        },
    },
    active = {
        type = "quest",
        id = 63579,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63593,
    },
    rewards = {
        {
            type = "money",
            amount = 2290860,
        },
        {
            type = "currency",
            id = 1822,
            amount = 1,
        },
        {
            type = "reputation",
            id = 2407,
            amount = 750,
        },
    },
    items = {
        {
            type = "npc",
            id = 179356,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63579,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63580,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63581,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63582,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63583,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63585,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63586,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 63587,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 63588,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63589,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63590,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63584,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 63591,
                    restrictions = {
                        type = "covenant",
                        id = 1,
                    },
                },
                {
                    type = "quest",
                    id = 63592,
                }
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
                    id = 63592,
                    restrictions = {
                        type = "covenant",
                        id = 1,
                    },
                },
                {
                    type = "quest",
                    id = 63593,
                }
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63593,
            restrictions = {
                type = "covenant",
                id = 1,
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.WhatLiesAhead, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 9),
    questline = 1248,
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
            type = "renown",
            level = 58,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheLastSigil,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AnArmyOfBoneAndSteel,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheUnseenGuest,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ThePowerOfNight,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ANewPath,
        },
    },
    active = {
        type = "quest",
        ids = {64211, 64212},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 64314,
    },
    rewards = {
    },
    items = {
        {
            type = "npc",
            id = 177194,
            locations = {
                [1961] = {
                    {
                        x = 0.629635,
                        y = 0.254064,
                    },
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
                    id = 64211,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "quest",
                    id = 64212,
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
                    id = 64213,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "quest",
                    id = 64214,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64314,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64441,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheyCouldBeAnyone, {
    name = L["THEY_COULD_BE_ANYONE"],
    questline = 1228,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
            upto = 64106,
        },
    },
    active = {
        type = "quest",
        id = 63755,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63763,
    },
    rewards = {
        {
            type = "money",
            amount = 2110680,
        },
    },
    items = {
        {
            type = "npc",
            id = 177155,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63755,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 63756,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 63757,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63758,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63759,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63760,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 63761,
            aside = true,
        },
        {
            type = "quest",
            id = 63762,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 63763,
        },
    },
})
Database:AddChain(Chain.ArchivistsOfKorthia, {
    name = L["ARCHIVISTS_OF_KORTHIA"],
    questline = 1236,
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
            id = Chain.BattleOfArdenweald,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
            upto = 64007,
        },
        -- Is part way through maw walkers, seems to require a drop now that I got doing [Surveying Secrets]
        -- but others got from rares
    },
    active = {
        type = "quest",
        id = 63731,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63738,
    },
    rewards = {
        {
            type = "reputation",
            id = 2472,
        },
        {
            type = "money",
            amount = 1685970,
        },
    },
    items = {
        {
            type = "item",
            id = 187177,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63731,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63732,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63733,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 63734,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63736,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63740,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63739,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63737,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63738,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TazaveshTheVeiledMarket, {
    name = L["TAZAVESH_THE_VEILED_MARKET"],
    questline = 1235,
    buttonImage = 4182022,
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
        id = 63976,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 63985,
    },
    rewards = {
        {
            name = L["DUNGEON_TAZAVESH_THE_VEILED_MARKET"],
        },
        {
            type = "money",
            amount = 3474900,
        },
    },
    items = {
        {
            type = "npc",
            id = 156688,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63976,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 63977,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 63979,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63980,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63982,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63983,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63984,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63985,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63986,
            aside = true,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests_GetAchievementName(ACHIEVEMENT_ID),
    expansion = EXPANSION_ID,
    buttonImage = 4182020,
    items = {
        {
            type = "chain",
            id = Chain.BattleOfArdenweald,
        },
        {
            type = "chain",
            id = Chain.MawWalkers,
        },
        {
            type = "chain",
            id = Chain.FocusingTheEye,
        },
        {
            type = "chain",
            id = Chain.TheLastSigil,
        },
        {
            type = "chain",
            id = Chain.AnArmyOfBoneAndSteel,
        },
        {
            type = "chain",
            id = Chain.TheUnseenGuest,
        },
        {
            type = "chain",
            id = Chain.ThePowerOfNight,
        },
        {
            type = "chain",
            id = Chain.ANewPath,
        },
        {
            type = "chain",
            id = Chain.WhatLiesAhead,
        },
        {
            type = "chain",
            id = Chain.ArchivistsOfKorthia,
        },
        {
            type = "chain",
            id = Chain.TheyCouldBeAnyone,
        },
        {
            type = "chain",
            id = Chain.TazaveshTheVeiledMarket,
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