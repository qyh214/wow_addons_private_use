-- Current we only want this for BCC since not all these are available in Mainline
if WOW_PROJECT_ID ~= WOW_PROJECT_BURNING_CRUSADE_CLASSIC then return end

local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheBurningCrusade;
local CATEGORY_ID = BtWQuests.Constant.Category.TheBurningCrusade.Attunements;
local Chain = BtWQuests.Constant.Chain.TheBurningCrusade.Attunements;
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local LEVEL_RANGE = {10, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 10,
    },
}

Chain.TheBlackMorass = 20801
Chain.TheArcatraz = 20802
Chain.ShatteredHallsAlliance = 20803
Chain.ShatteredHallsHorde = 20804
Chain.Karazhan = 20805
Chain.SerpentshrineCavern = 20806
Chain.TempestKeep = 20807
Chain.MountHyjal = 20808

Database:AddChain(Chain.TheBlackMorass, {
    name = L["THE_BLACK_MORASS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10279,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10296,
    },
    items = {
        {
            type = "npc",
            id = 20142,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10279,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10277,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10282,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10283,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10284,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10285,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10296,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10297,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10298,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheArcatraz, {
    name = L["THE_ARCATRAZ"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {10263, 10264, 10265},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10276,
    },
    items = {
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheBurningCrusade.Netherstorm.EmbedChain06 or 20616,
            embed = true,
        },
    },
})
Database:AddChain(Chain.ShatteredHallsAlliance, {
    name = L["THE_SHATTERED_HALLS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    alternatives = {
        Chain.ShatteredHallsHorde
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10754,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10764,
    },
    items = {
        {
            type = "kill",
            id = 22037,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10754,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10762,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10763,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10764,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ShatteredHallsHorde, {
    name = L["THE_SHATTERED_HALLS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    alternatives = {
        Chain.ShatteredHallsAlliance
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10755,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10758,
    },
    items = {
        {
            type = "kill",
            id = 22037,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10755,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10756,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10757,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10758,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Karazhan, {
    name = L["KARAZHAN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9824, 9825},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9837,
    },
    items = {
        {
            type = "npc",
            id = 17613,
            x = 0,
            y = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9824,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9825,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9826,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9829,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9831,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9832,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9836,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9837,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9838,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SerpentshrineCavern, {
    name = L["SERPENTSHRINE_CAVERN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {13431, 10901},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {13431, 10901},
    },
    items = {
        {
            type = "npc",
            id = 22421,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {13431, 10901},
            x = 0,
        },
    },
})
Database:AddChain(Chain.TempestKeep, {
    name = L["TEMPEST_KEEP"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheBurningCrusade.ShadowmoonValley.TheCipherOfDamnation or 20712,
        },
    },
    active = {
        type = "quest",
        id = 10883,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10888,
    },
    items = {
        {
            type = "npc",
            id = 18166,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10883,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 10884,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 10885,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10886,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10888,
            x = 0,
        },
    },
})
Database:AddChain(Chain.MountHyjal, {
    name = L["MOUNT_HYJAL"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "reputation",
            id = 989,
            standing = 7,
        },
    },
    active = {
        type = "quest",
        id = 10445,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 10445,
    },
    items = {
        {
            type = "npc",
            id = 19935,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10445,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = L["ATTUNEMENTS"],
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.TheBlackMorass,
        },
        {
            type = "chain",
            id = Chain.TheArcatraz,
        },
        {
            type = "chain",
            id = Chain.ShatteredHallsAlliance,
        },
        {
            type = "chain",
            id = Chain.ShatteredHallsHorde,
        },
        {
            type = "chain",
            id = Chain.Karazhan,
        },
        {
            type = "chain",
            id = Chain.SerpentshrineCavern,
        },
        {
            type = "chain",
            id = Chain.TempestKeep,
        },
        {
            type = "chain",
            id = Chain.MountHyjal,
        },
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
})

if not C_QuestLine then
    Database:AddContinentItems(1414, {
        {
            type = "chain",
            id = Chain.TheBlackMorass,
        },
        {
            type = "chain",
            id = Chain.MountHyjal,
        },
    });
    Database:AddContinentItems(1415, {
        {
            type = "chain",
            id = Chain.Karazhan,
        },
    });
    Database:AddContinentItems(1945, {
        {
            type = "chain",
            id = Chain.TheArcatraz,
        },
        {
            type = "chain",
            id = Chain.ShatteredHallsAlliance,
        },
        {
            type = "chain",
            id = Chain.ShatteredHallsHorde,
        },
        {
            type = "chain",
            id = Chain.Karazhan,
        },
        {
            type = "chain",
            id = Chain.SerpentshrineCavern,
        },
        {
            type = "chain",
            id = Chain.TempestKeep,
        },
        {
            type = "chain",
            id = Chain.MountHyjal,
        },
    })
end
