local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_LIGHTFORGED_DRAENEI, {
    name = L["LIGHTFORGED_DRAENEI"],
    category = BTWQUESTS_CATEGORY_LEGION_ALLIED_RACES,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_NIGHTBORNE
    },
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        -- {
        --     type = "expansion",
        --     id = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
        --     visible = false,
        -- },
        {
            type = "achievement",
            id = 12066,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2165,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12081,
        --     anyone = true,
        -- },
    },
    completed = {
        type = "achievement",
        id = 12243,
        anyone = true,
    },
    range = {110},
    items = {
        {
            type = "quest",
            id = 49698,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 49266,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 50071,
            x = 3,
            y = 2,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_VOID_ELF, {
    name = L["VOID_ELF"],
    category = BTWQUESTS_CATEGORY_LEGION_ALLIED_RACES,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_HIGHMOUNTAIN_TAUREN
    },
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_ALLIANCE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        -- {
        --     type = "expansion",
        --     id = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
        --     visible = false,
        -- },
        {
            type = "achievement",
            id = 12066,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 2170,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12076,
        --     anyone = true,
        -- },
    },
    completed = {
        type = "achievement",
        id = 12242,
        anyone = true,
    },
    range = {110},
    items = {
        {
            type = "quest",
            id = 49787,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 48962,
            x = 3,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_NIGHTBORNE, {
    name = L["NIGHTBORNE"],
    category = BTWQUESTS_CATEGORY_LEGION_ALLIED_RACES,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_LIGHTFORGED_DRAENEI
    },
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        -- {
        --     type = "expansion",
        --     id = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
        --     visible = false,
        -- },
        {
            type = "achievement",
            id = 11340,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 1859,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 10778,
        --     anyone = true,
        -- },
    },
    completed = {
        type = "achievement",
        id = 12244,
        anyone = true,
    },
    range = {110},
    items = {
        {
            type = "quest",
            id = 49973,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 49613,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 49354,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 49614,
            x = 3,
            y = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_HIGHMOUNTAIN_TAUREN, {
    name = L["HIGHMOUNTAIN TAUREN"],
    category = BTWQUESTS_CATEGORY_LEGION_ALLIED_RACES,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_VOID_ELF
    },
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        -- {
        --     type = "expansion",
        --     id = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
        --     visible = false,
        -- },
        {
            type = "achievement",
            id = 10059,
            anyone = true,
        },
        -- {
        --     name = {
        --         type = "reputation",
        --         id = 1828,
        --         standing = 8,
        --     },
        --     type = "achievement",
        --     id = 12292,
        --     anyone = true,
        -- },
    },
    active = {
        type = "quest",
        id = 48066,
        status = {'active', 'completed'},
    },
    completed = {
        type = "achievement",
        id = 12245,
        anyone = true,
    },
    range = {45},
    items = {
        {
            type = "npc",
            id = 133523,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48066,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48067,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49756,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48079,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 41884,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 41764,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48185,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 41799,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48190,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 41800,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48434,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 41815,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 41840,
            x = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 41882,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 41841,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48403,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48433,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_ALLIED_RACES, {
    name = L["BTWQUESTS_ALLIED_RACES"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_LIGHTFORGED_DRAENEI,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_VOID_ELF,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_NIGHTBORNE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ALLIED_RACES_HIGHMOUNTAIN_TAUREN,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_ALLIED_RACES,
})
