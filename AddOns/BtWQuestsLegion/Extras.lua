local L = BtWQuests.L;

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_EPILOGUE, {
    name = L["BTWQUESTS_EPILOGUE"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
    },
    active = {
        type = "quest",
        ids = {50046, 50052, 50047, 50053, 50229},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {50374, 50364},
        count = 1,
    },
    items = {
        --[[
        {
            variations = {
                {
                    type = "quest",
                    id = 50371,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 49977,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            breadcrumb = true,
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
                    id = 49976,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50341,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            breadcrumb = true,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49981,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 49982,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            breadcrumb = true,
            x = 3,
            y = 2,
            connections = {
                1, 2, 
            },
        },
        ]]



        {
            variations = {
                {
                    type = "npc",
                    id = 130030,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 132045,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 1,
            y = 0,
            aside = true,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "npc",
                    id = 131963,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 132147,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            connections = {
                2,
            },
        },




        {
            variations = {
                {
                    type = "quest",
                    id = 50046,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50052,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            aside = true,
            x = 1,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50047,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50053,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            connections = {
                2, 3,
            },
        },
        {
            type = "object",
            id = 280948,
            aside = true,
            connections = {
                3,
            },
        },
        


        
        {
            variations = {
                {
                    type = "quest",
                    id = 50372,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50358,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
            x = 2,
            connections = {
                3, 4
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50228,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50232,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
            connections = {
                4
            },
        },
        {
            type = "quest",
            id = 50229,
            aside = true,
        },

        
        {
            variations = {
                {
                    type = "quest",
                    id = 50226,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50230,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
            x = 1,
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50227,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50231,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
        },
        
        {
            variations = {
                {
                    type = "quest",
                    id = 50373,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50360,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
            connections = {
                1
            },
        },
        
        {
            variations = {
                {
                    type = "quest",
                    id = 50049,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50055,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
            x = 3,
            connections = {
                1
            },
        },
        
        {
            variations = {
                {
                    type = "quest",
                    id = 50374,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50364,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
            x = 3,
        },
        --[[
        {
            variations = {
                {
                    type = "quest",
                    id = 50056,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 50300,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                }
            },
            breadcrumb = true,
            x = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 50057,
            x = 3,
        },
        ]]
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_LOST_MAIL, {
    name = { -- Lost Mail
        type = "quest",
        id = 41368,
    },
    category = nil,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 41368,
    },
    completed = {
        type = "quest",
        id = 50247,
    },
    items = {
        {
            type = "quest",
            id = 41368,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            name = L["HEAD_TO_THE_DALARAN_MAILROOM"],
            breadcrumb = true,
            onClick = {
                type = "coords",
                mapID = 627,
                x = 0.3342,
                y = 0.3164,
                name = L["DALARAN_MAILROOM_ENTRANCE"],
            },
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46278,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41397,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41367,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41394,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41395,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            name = L["RETURN_TO_THE_DALARAN_MAILROOM"],
            breadcrumb = true,
            onClick = {
                type = "coords",
                mapID = 627,
                x = 0.3342,
                y = 0.3164,
                name = L["DALARAN_MAILROOM_ENTRANCE"],
            },
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 50247,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_EPILOGUE,
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_LOST_MAIL,
})


BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_EPILOGUE)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_LOST_MAIL)