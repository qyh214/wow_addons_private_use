local L = BtWQuests.L;
local MAP_ID = 1473

-- Other chains might require Back Out to Sea
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01, {
    name = { -- Harnessing the Power
        type = "quest",
        id = 57010,
    },
    questline = 923,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "quest",
            id = 54972,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55053,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
    },
    active = {
        type = "quest",
        id = 55533,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57010,
    },
    rewards = {
        {
            type = "azessence",
            id = 12,
            rank = 1,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1700,
        },
        {
            type = "reputation",
            id = 2164,
            amount = 1000,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
                    completed = {
                        type = "quest",
                        id = 54972,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
                    completed = {
                        type = "quest",
                        id = 55053,
                    },
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 152206,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55533,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55374,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55400,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55407,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55425,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55497,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55618,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57010,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN02,
            x = 2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN03,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN02, {
    name = { -- Healing Nordrassil
        type = "quest",
        id = 55520,
    },
    questline = 920,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    hasLowPriorityPrerequisites = true,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "quest",
            id = 54972,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55053,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
        },
        {
            type = "heartlevel",
            level = 55,
        },
    },
    active = {
        type = "quest",
        id = 55519,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55521,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1500,
        },
        {
            type = "reputation",
            id = 2164,
            amount = 500,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55519,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55520,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55521,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN04,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN03, {
    name = { -- The Stuff Dreams Are Made Of
        type = "quest",
        id = 55396,
    },
    questline = 912,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "quest",
            id = 54972,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55053,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
        },
        {
            type = "heartlevel",
            level = 54,
        },
    },
    active = {
        type = "quest",
        id = 55390,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55398,
    },
    rewards = {
        {
            type = "azessence",
            id = 12,
            rank = 2,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1900,
        },
        {
            type = "reputation",
            id = 2164,
            amount = 1175,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55390,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55392,
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 55394,
            x = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 55393,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 55395,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55465,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55397,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55396,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55398,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN05,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN04, {
    name = { -- Defending the Maelstrom
        type = "quest",
        id = 55735,
    },
    questline = 934,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "quest",
            id = 54972,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55053,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN02,
        },
        {
            type = "heartlevel",
            level = 65,
        },
    },
    active = {
        type = "quest",
        id = 55732,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55737,
    },
    rewards = {
        {
            type = "reputation",
            id = 2164,
            amount = 500,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN02,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55732,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55735,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55737,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN06,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN05, {
    name = { -- In the Shadow of Crimson Wings
        type = "quest",
        id = 55657,
    },
    questline = 958,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "quest",
            id = 54972,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55053,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN03,
        },
        {
            type = "heartlevel",
            level = 60,
        },
    },
    active = {
        type = "quest",
        id = 56167,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55657,
    },
    rewards = {
        {
            type = "azessence",
            id = 12,
            rank = 3,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1800,
        },
        {
            type = "reputation",
            id = 2164,
            amount = 500,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN03,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56167,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55657,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN07,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN06, {
    name = { -- We Stand United
        type = "quest",
        id = 55752,
    },
    questline = 976,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "quest",
            id = 54972,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55053,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN03,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN02,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN05,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN04,
            lowPriority = true,
        },
        {
            type = "heartlevel",
            level = 70,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN07,
        },
    },
    active = {
        type = "quest",
        id = 55752,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55752,
    },
    rewards = {
        {
            type = "toy",
            id = 169768,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN04,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55752,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN07, {
    name = { -- A Bolt From the Blue
        type = "quest",
        id = 56401,
    },
    questline = 961,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "quest",
            id = 54972,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE,
            },
        },
        {
            type = "quest",
            id = 55053,
            lowPriority = true,
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN03,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN02,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN05,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN04,
        },
        {
            type = "heartlevel",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 56401,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56401,
    },
    rewards = {
        {
            type = "azessence",
            id = 12,
            rank = 4,
        },
        {
            type = "reputation",
            id = 2164,
            amount = 150,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN05,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56401,
            x = 3,
        },
    },
})
-- Removed in 8.3?
--[[
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN08, {
    name = { -- On the Trail of the Black Prince
        type = "quest",
        id = 56189,
    },
    questline = 947,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
        },
        {
            type = "achievement",
            id = 13725,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_2,
        },
    },
    active = {
        type = "quest",
        ids = {56185, 56267},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56504,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1450800,
            },
            minLevel = 120,
            maxLevel = 120,
        },
        {
            type = "currency",
            id = 1553,
            amount = 2750,
        },
        {
            type = "reputation",
            id = 2164,
            amount = 1270,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 154464,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "npc",
                    id = 154465,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 56185,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "quest",
                    id = 56267,
                },
            },
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56186,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56187,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56188,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56189,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56190,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56504,
            x = 3,
        },
    },
})
]]

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE, {
    name = { -- The Heart Forge
        type = "quest",
        id = 55618,
    },
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN03,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN02,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN05,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN04,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN07,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN06,
        },
    },
})
BtWQuestsDatabase:AddExpansionItems(BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH, {
    {
        type = "header",
        name = L["RISE_OF_AZSHARA_ZONES"],
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_THE_HEART_FORGE,
})
BtWQuestsDatabase:AddMapRecursive(1472, {
    type = "chain",
    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
})