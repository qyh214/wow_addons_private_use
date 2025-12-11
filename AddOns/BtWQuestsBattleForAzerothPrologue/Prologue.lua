local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE, {
    name = L["BTWQUESTS_PROLOGUE"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    prerequisites = {
        {
            type = "level",
            level = 110,
        },
    },
    completed = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_ALLIANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_HORDE,
        },
    },
    range = {110},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_ALLIANCE,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_HORDE,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_ALLIANCE, {
    name = L["BTWQUESTS_PROLOGUE"],
    questline = 637,
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    prerequisites = {
        {
            type = "level",
            level = 110,
        },
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    completed = {
        type = "quest",
        id = 51795,
    },
    range = {110},
    items = {
        {
            variations = {
                {
                    type = "time",
                    time = 1532498400,
                    visible = BtWQuestsItem_Active,
                    restrictions = {
                        type = "timezone",
                        timezone = BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS
                    },
                },
                {
                    restrictions = false,
                },
            },
            x = 5,
            y = -0.5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52058,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52060,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52062,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52072,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53616,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52116,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52234,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53617,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52240,
            x = 3,
            y = 6,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52245,
            x = 2,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53551,
            x = 4,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52242,
            x = 3,
            y = 8,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53619,
            x = 2,
            y = 9,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53621,
            x = 4,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52256,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52257,
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52197,
            x = 3,
            y = 12,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52279,
            x = 3,
            y = 13,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "time",
                    time = 1533103200,
                    visible = BtWQuestsItem_Active,
                    restrictions = {
                        type = "timezone",
                        timezone = BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS
                    },
                },
                {
                    restrictions = false,
                },
            },
            x = 5,
            y = 13.5,
            connections = {
                1,
            },
        },



        {
            type = "quest",
            id = 52973,
            x = 3,
            y = 14,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 52974,
            x = 1,
            y = 15,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 53622,
            x = 3,
            y = 15,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52975,
            x = 5,
            y = 15,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52977,
            x = 3,
            y = 16,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 53310,
                    restrictions = {
                        type = "quest",
                        id = 53310,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "quest",
                    id = 53095,
                },
            },
            x = 3,
            y = 17,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "time",
                    time = 1533708000,
                    visible = BtWQuestsItem_Active,
                    restrictions = {
                        type = "timezone",
                        timezone = BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS
                    },
                },
                {
                    restrictions = false,
                },
            },
            x = 5,
            y = 17.5,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 53370,
            x = 3,
            y = 18,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51795,
            x = 3,
            y = 19,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_HORDE, {
    name = L["BTWQUESTS_PROLOGUE"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    prerequisites = {
        {
            type = "level",
            level = 110,
        },
    },
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    completed = {
        type = "quest",
        id = 51796,
    },
    range = {110},
    items = {
        {
            variations = {
                {
                    type = "time",
                    time = 1532498400,
                    visible = BtWQuestsItem_Active,
                    restrictions = {
                        type = "timezone",
                        timezone = BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS
                    },
                },
                {
                    restrictions = false,
                },
            },
            x = 5,
            y = -0.5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50476,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50642,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50646,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50647,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50738,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50740,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50772,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50800,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50823,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50837,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50880,
            x = 3,
            y = 10,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53604,
            x = 2,
            y = 11,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53605,
            x = 4,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50878,
            x = 3,
            y = 12,
            connections = {
                1,
            },
        },
        
        {
            type = "quest",
            id = 50879,
            x = 3,
            y = 13,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53606,
            x = 2,
            y = 14,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52436,
            x = 4,
            y = 14,
            connections = {
                1,
            },
        },
        -- { Removed
        --     type = "quest",
        --     id = 53550,
        --     x = 5,
        --     y = 14,
        --     connections = {
        --         1,
        --     },
        -- },
        {
            type = "quest",
            id = 52437,
            x = 3,
            y = 15,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53608,
            x = 2,
            y = 16,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53609,
            x = 4,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53627,
            x = 3,
            y = 17,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52438,
            x = 3,
            y = 18,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52806,
            x = 3,
            y = 19,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "time",
                    time = 1533103200,
                    visible = BtWQuestsItem_Active,
                    restrictions = {
                        type = "timezone",
                        timezone = BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS
                    },
                },
                {
                    restrictions = false,
                },
            },
            x = 5,
            y = 19.5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52967,
            x = 3,
            y = 20,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 52970,
            x = 1,
            y = 21,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 53610,
            x = 3,
            y = 21,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52971,
            x = 5,
            y = 21,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52981,
            x = 3,
            y = 22,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "time",
                    time = 1533708000,
                    visible = BtWQuestsItem_Active,
                    restrictions = {
                        type = "timezone",
                        timezone = BTWQUESTS_TIMEZONE_ID_EUROPE_PARIS
                    },
                },
                {
                    restrictions = false,
                },
            },
            x = 5,
            y = 22.5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53372,
            x = 3,
            y = 23,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51796,
            x = 3,
            y = 24,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE,
    },
})

BtWQuestsDatabase:AddQuestItemsForOtherChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE, BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_ALLIANCE)
BtWQuestsDatabase:AddQuestItemsForOtherChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE, BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_PROLOGUE_HORDE)
