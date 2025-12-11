--[[
    There are 2 quests for each assault,
    one is the quest on the map, the other is hidden
    in the quest log while the assault is active

    Vale,    Mogu:    57563, 57008 The Warring Clans
    Vale,    Nzoth:   57567, 56064 The Black Empire
    Uldum,   Amathet: 57562, 55350 Amathet Advance
    Uldum,   Nzoth:   57566, 57157 The Black Empire
    Vale,    Mantid:  57564, 57728 The Endless Swarm
    Uldum,   Aqir:    57565, 56308 Aqir Unearthed
]]
local L = BtWQuests.L;

local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.BattleForAzeroth;
local CATEGORY_ID = BtWQuests.Constant.Category.BattleForAzeroth.VisionsOfNZoth;
local Class = BtWQuests.Constant.Class;
local Restrictions = BtWQuests.Constant.Restrictions;
local Chain = BtWQuests.Constant.Chain.BattleForAzeroth.VisionsOfNZoth;

Database:AddChain(Chain.Chain01, {
    name = { -- Return of the Black Prince
        type = "quest",
        id = 58582,
    },
    questline = 1030,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120,50},
    alternatives = {
        Chain.Chain02,
    },
    restrictions = Restrictions.Alliance,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51918, 52450},
            count = 1,
        },
        {
            type = "quest",
            id = 54972,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
        },
    },
    active = {
        type = "quest",
        id = 58496,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58506,
    },
    items = {
        {
            type = "quest",
            id = 58496,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58498,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58502,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58506,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain02, {
    name = { -- Return of the Black Prince
        type = "quest",
        id = 58582,
    },
    questline = 1030,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120,50},
    alternatives = {
        Chain.Chain01,
    },
    restrictions = Restrictions.Horde,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "quest",
            ids = {51916, 52451},
            count = 1,
        },
        {
            type = "quest",
            id = 55053,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_THE_HEART_FORGE_CHAIN01,
        },
    },
    active = {
        type = "quest",
        id = 58582,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58506,
    },
    items = {
        {
            type = "quest",
            id = 58582,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58583,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58506,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.Chain03,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain03, {
    name = { -- The Halls of Origination
        type = "quest",
        id = 56209,
    },
    questline = 950,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
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
            id = Chain.Chain01,
        },
        {
            type = "chain",
            id = Chain.Chain02,
        },
    },
    active = {
        type = "quest",
        id = 56374,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56377,
    },
    rewards = {
        {
            type = "azessence",
            id = 35,
            rank = 1,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1500,
        },
    },
    items = {
        {
            type = "npc",
            id = 152206,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56374,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56209,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56375,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56472,
            x = 0,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "chain",
            id = Chain.Chain10,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 56376,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = Chain.Chain07,
            aside = true,
        },
        { -- This might not be required
            type = "quest",
            id = 56377,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = Chain.Chain04,
            x = 0,
            aside = true,
        },
    },
})
Database:AddChain(Chain.Chain04, {
    name = { -- The Engine of Nalak'sha
        type = "quest",
        id = 56541,
    },
    questline = 983,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
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
            id = Chain.Chain01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain03,
        },
    },
    active = {
        type = "quest",
        id = 56536,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56542,
    },
    rewards = {
        {
            type = "azessence",
            id = 24,
            rank = 1,
            restrictions = {
                type = "class",
                ids = {
                    Class.Paladin,
                    Class.Priest,
                    Class.Shaman,
                    Class.Monk,
                    Class.Druid,
                },
            },
        },
        {
            type = "azessence",
            id = 33,
            rank = 1,
            restrictions = {
                type = "class",
                ids = {
                    Class.Warrior,
                    Class.Paladin,
                    Class.DeathKnight,
                    Class.Monk,
                    Class.Druid,
                    Class.DemonHunter,
                },
            },
        },
        {
            type = "currency",
            id = 1553,
            amount = 1500,
        },
    },
    items = {
        {
            type = "npc",
            id = 152206,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56536,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56537,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56538,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56539,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56771,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56540,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56541,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56542,
            x = 0,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "chain",
            id = Chain.Chain09,
            aside = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.Chain05,
            aside = true,
        },
        {
            type = "chain",
            id = Chain.Chain08,
            aside = true,
        },
    },
})
Database:AddChain(Chain.Chain05, {
    name = { -- Into the Darkest Depths
        type = "quest",
        id = 57374,
    },
    questline = 1012,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
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
            id = Chain.Chain01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain04,
        },
    },
    active = {
        type = "quest",
        id = 57220,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57524,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 5000,
        },
        {
            type = "currency",
            id = 1719,
            amount = 100,
        },
        {
            type = "currency",
            id = 1755,
            amount = 20000,
        },
    },
    items = {
        {
            type = "npc",
            id = 152206,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58737,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57220,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57221,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57222,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57290,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57362,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57373,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58634,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57374,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57524,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.Chain06,
            aside = true,
            embed = true,
        },
        {
            type = "quest",
            id = 57378,
        },
    },
})
Database:AddChain(Chain.Chain06, {
    name = "Whispers in the Dark",
    questline = 1028,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
    },
    active = {
        type = "quest",
        id = 58615,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58632,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 3000,
        },
    },
    items = {
        {
            type = "quest",
            id = 58615,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58631,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58632,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain07, {
    name = { -- Eyes on the Amathet
        type = "quest",
        id = 58636,
    },
    questline = 1029,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
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
            id = Chain.Chain01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            lowPriority = true,
        },
        {
            type = "quest",
            id = 56472,
        },
        {
            name = L["ASSAULT_AMATHET_ADVANCE_ACTIVE"],
            type = "quest",
            id = 57562,
            status = {'active'}
        },
    },
    active = {
        type = "quest",
        id = 58636,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58645,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1500,
        },
    },
    items = {
        {
            type = "npc",
            id = 155102,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58636,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58638,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58639,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58646,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58640,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58641,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58642,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58643,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58645,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain08, {
    name = { -- Mogu at the Gates
        type = "quest",
        id = 57067,
    },
    questline = 992,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
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
            id = Chain.Chain01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain04,
        },
        {
            name = L["ASSAULT_THE_WARRING_CLANS_ACTIVE"],
            type = "quest",
            id = 57563,
            status = {'active'}
        },
    },
    active = {
        type = "quest",
        id = 57067,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57076,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1500,
        },
    },
    items = {
        {
            type = "npc",
            id = 154444,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57067,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57068,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57069,
            x = -2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 57071,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57070,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57072,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57074,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57075,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57076,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain09, {
    name = { -- The Mantid Threat
        type = "quest",
        id = 56647,
    },
    questline = 1009,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
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
            id = Chain.Chain01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain03,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain04,
        },
        {
            name = L["ASSAULT_THE_ENDLESS_SWARM_ACTIVE"],
            type = "quest",
            id = 57564,
            status = {'active'}
        },
    },
    active = {
        type = "quest",
        id = 56574,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56647,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1500,
        },
    },
    items = {
        {
            name = L["KILL_RARES"],
            breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56574,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 56575,
            x = -1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 56577,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 56578,
            x = -1,
            connections = {
                 2
            },
        },
        {
            type = "quest",
            id = 56580,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56616,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56617,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56645,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56647,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Chain10, {
    name = { -- Aqir Extermination
        type = "quest",
        id = 56576,
    },
    questline = 1016,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
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
            id = Chain.Chain01,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Chain02,
            lowPriority = true,
        },
        {
            type = "quest",
            id = 56472,
        },
        {
            name = L["ASSAULT_AQIR_UNEARTHED_ACTIVE"],
            type = "quest",
            id = 57565,
            status = {'active'}
        },
    },
    active = {
        type = "quest",
        id = 57873,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 58009,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1500,
        },
    },
    items = {
        {
            type = "npc",
            id = 159544,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57873,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57915,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57955,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 57954,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 57956,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57971,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 57969,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 57970,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 58606,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 57990,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 58008,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 56576,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 58009,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = L["VISIONS_OF_NZOTH"],
    expansion = EXPANSION_ID,
    items = {
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
            id = Chain.Chain07,
        },
        {
            type = "chain",
            id = Chain.Chain08,
        },
        {
            type = "chain",
            id = Chain.Chain10,
        },
        {
            type = "chain",
            id = Chain.Chain09,
        },
    },
})
Database:AddExpansionItems(EXPANSION_ID, {
    {
        type = "category",
        id = CATEGORY_ID,
    },
})
Database:AddMapRecursive(1527, {
    type = "category",
    id = CATEGORY_ID,
})
Database:AddMapRecursive(1530, {
    type = "category",
    id = CATEGORY_ID,
})
