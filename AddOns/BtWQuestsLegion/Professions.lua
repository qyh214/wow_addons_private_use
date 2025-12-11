local L = BtWQuests.L;

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_ALCHEMY, {
    name = L["BTWQUESTS_PROFESSION_ALCHEMY"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 171,
        },
    },
    completed = {
        type = "quest",
        id = 42081,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 39325,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39326,
            x = 2,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39390,
            x = 4,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39327,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39328,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39329,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39330,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39331,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39332,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39430,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39334,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39335,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39336,
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39337,
            x = 3,
            y = 12,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39431,
            x = 3,
            y = 13,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 44112,
            x = 3,
            y = 14,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39338,
            x = 3,
            y = 15,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39339,
            x = 3,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39340,
            x = 3,
            y = 17,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39341,
            x = 2,
            y = 18,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39343,
            x = 4,
            y = 18,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39344,
            x = 3,
            y = 19,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39342,
            x = 3,
            y = 20,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39333,
            x = 3,
            y = 21,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39645,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_ALLIANCE,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 39345,
                    restrictions = {
                        {
                            type = "faction",
                            id = BTWQUESTS_FACTION_ID_HORDE,
                        },
                    },
                },
            },
            x = 3,
            y = 22,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39346,
            x = 3,
            y = 23,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39347,
            x = 3,
            y = 24,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 39348,
            x = 1,
            y = 25,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 39349,
            x = 3,
            y = 25,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39350,
            x = 5,
            y = 25,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39351,
            x = 3,
            y = 26,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 42081,
            x = 3,
            y = 27,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_BLACKSMITHING, {
    name = L["BTWQUESTS_PROFESSION_BLACKSMITHING"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 164,
        },
    },
    completed = {
        type = "quest",
        id = 38533,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 38499,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        -- {
        --     type = "quest",
        --     id = 48053,
        --     x = 4,
        --     y = 0,
        --     connections = {
        --         1,
        --     }
        -- },
        {
            type = "quest",
            id = 39681,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 38502,
            x = 2,
            y = 2,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 38501,
            x = 4,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38505,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38506,
            x = 3,
            y = 4,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38507,
            x = 3,
            y = 5,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38515,
            x = 3,
            y = 6,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38500,
            x = 3,
            y = 7,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38563,
            x = 3,
            y = 8,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38513,
            x = 3,
            y = 9,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38514,
            x = 3,
            y = 10,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39699,
            x = 3,
            y = 11,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38519,
            x = 3,
            y = 12,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38518,
            x = 3,
            y = 13,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38522,
            x = 3,
            y = 14,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38523,
            x = 3,
            y = 15,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39702,
            x = 3,
            y = 16,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 39680,
            x = 2,
            y = 17,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 39726,
            x = 4,
            y = 17,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39729,
            x = 3,
            y = 18,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38564,
            x = 3,
            y = 19,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44449,
            x = 3,
            y = 20,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38524,
            x = 3,
            y = 21,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38525,
            x = 3,
            y = 22,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38526,
            x = 3,
            y = 23,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38527,
            x = 3,
            y = 24,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38528,
            x = 3,
            y = 25,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38530,
            x = 3,
            y = 26,
            connections = {
                1, 2
            }
        },
        {
            type = "quest",
            id = 38531,
            x = 2,
            y = 27,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 38532,
            x = 4,
            y = 27,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38559,
            x = 3,
            y = 28,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38833,
            x = 3,
            y = 29,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 38533,
            x = 3,
            y = 30,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_ENCHANTING, {
    name = L["BTWQUESTS_PROFESSION_ENCHANTING"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 333,
        },
    },
    completed = {
        type = "quest",
        id = 39923,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 39874,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39875,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39876,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 39877,
            x = 2,
            y = 3,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 40048,
            x = 4,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39905,
            x = 3,
            y = 4,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39878,
            x = 3,
            y = 5,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 39879,
            x = 2,
            y = 6,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 39880,
            x = 4,
            y = 6,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39883,
            x = 3,
            y = 7,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 39881,
            x = 2,
            y = 8,
            connections = {
                2, 3,
            }
        },
        {
            type = "quest",
            id = 39903,
            x = 4,
            y = 8,
            connections = {
                4,
            }
        },

        
        {
            type = "quest",
            id = 39884,
            x = 1,
            y = 9,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 39889,
            x = 3,
            y = 9,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39882,
            x = 2,
            y = 10,
            connections = {
                3,
            }
        },

        
        {
            type = "quest",
            id = 40265,
            x = 5,
            y = 9,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39904,
            x = 4,
            y = 10,
            connections = {
                1,
            }
        },

        
        {
            type = "quest",
            id = 39891,
            x = 3,
            y = 11,
            connections = {
                1, 2, 3,
            }
        },
        {
            type = "quest",
            id = 39910,
            x = 1,
            y = 12,
        },
        {
            type = "quest",
            id = 40169,
            x = 3,
            y = 12,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 39906,
            x = 5,
            y = 12,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 39916,
            x = 3,
            y = 13,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 39914,
            x = 5,
            y = 13,
        },
        {
            type = "quest",
            id = 40130,
            x = 3,
            y = 14,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39918,
            x = 3,
            y = 15,
            connections = {
                1,
            }
        },

        
        {
            type = "quest",
            id = 39907,
            x = 3,
            y = 16,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39920,
            x = 3,
            y = 17,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39921,
            x = 3,
            y = 18,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 39923,
            x = 3,
            y = 19,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_ENGINEERING, {
    name = L["BTWQUESTS_PROFESSION_ENGINEERING"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 202,
        },
    },
    completed = {
        type = "quest",
        id = 40879,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 40545,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40854,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40855,
            x = 3,
            y = 2,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40859,
            x = 2,
            y = 3,
        },
        {
            type = "quest",
            id = 40856,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40858,
            x = 3,
            y = 4,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40863,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40860,
            x = 5,
            y = 5,
            connections = {
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 40864,
            x = 2,
            y = 6,
            connections = {
                1,
                4,
                5,
                6,
            },
        },
        {
            type = "quest",
            id = 46128,
            x = 0,
            y = 6,
        },
        {
            type = "quest",
            id = 40861,
            x = 4,
            y = 6,
        },
        {
            type = "quest",
            id = 40862,
            x = 6,
            y = 6,
        },
        {
            type = "quest",
            id = 40869,
            x = 0,
            y = 7,
        },
        {
            type = "quest",
            id = 40870,
            x = 2,
            y = 7,
        },
        {
            type = "quest",
            id = 40865,
            x = 4,
            y = 7,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40866,
            x = 3,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40867,
            x = 5,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40868,
            x = 4,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40871,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40872,
            x = 3,
            y = 11,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40873,
            x = 1,
            y = 12,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 40874,
            x = 3,
            y = 12,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40875,
            x = 5,
            y = 12,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40876,
            x = 3,
            y = 13,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40877,
            x = 2,
            y = 14,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40878,
            x = 4,
            y = 14,
        },
        {
            type = "quest",
            id = 40882,
            x = 1,
            y = 15,
        },
        {
            type = "quest",
            id = 40880,
            x = 3,
            y = 15,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40881,
            x = 3,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40879,
            x = 3,
            y = 17,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_INSCRIPTION, {
    name = L["BTWQUESTS_PROFESSION_INSCRIPTION"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 773,
        },
    },
    completed = {
        type = "quest",
        id = 39954,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 39847,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39931,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39932,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39933,
            x = 3,
            y = 3,
        },
        {
            type = "quest",
            id = 40056,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39934,
            x = 4,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40057,
            x = 2,
            y = 5,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 39935,
            x = 4,
            y = 5,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40061,
            x = 2,
            y = 6,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40058,
            x = 4,
            y = 6,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 39940,
            x = 1,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 40063,
            x = 3,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40059,
            x = 5,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39943,
            x = 2,
            y = 8,
        },
        {
            type = "quest",
            id = 40060,
            x = 5,
            y = 8,
        },
        {
            type = "quest",
            id = 39944,
            x = 3,
            y = 9,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 39945,
            x = 2,
            y = 10,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39946,
            x = 4,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39947,
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40052,
            x = 3,
            y = 12,
        },
        {
            type = "quest",
            id = 39948,
            x = 3,
            y = 13,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39949,
            x = 3,
            y = 14,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39950,
            x = 3,
            y = 15,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39953,
            x = 3,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39957,
            x = 3,
            y = 17,
        },
        {
            type = "quest",
            id = 39961,
            x = 3,
            y = 18,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39955,
            x = 3,
            y = 19,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39956,
            x = 3,
            y = 20,
        },
        {
            type = "quest",
            id = 39954,
            x = 3,
            y = 21,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_JEWELCRAFTING, {
    name = L["BTWQUESTS_PROFESSION_JEWELCRAFTING"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 755,
        },
    },
    completed = {
        type = "quest",
        id = 40562,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 40523,
            x = 3,
            y = 0,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40529,
            x = 2,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40524,
            x = 4,
            y = 1,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40530,
            x = 2,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 40525,
            x = 4,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 42214,
            x = 6,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40531,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 40526,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40526,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40527,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40527,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40528,
                },
            },
            x = 4,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 40532,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40532,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40533,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40533,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40534,
                },
            },
            x = 2,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40535,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40536,
            x = 3,
            y = 6,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40538,
            x = 2,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40539,
            x = 4,
            y = 7,
        },
        {
            type = "quest",
            id = 40540,
            x = 3,
            y = 8,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40541,
            x = 2,
            y = 9,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40546,
            x = 4,
            y = 9,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 40542,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40542,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40543,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40543,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40544,
                },
            },
            x = 3,
            y = 10,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 40556,
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40547,
            x = 3,
            y = 12,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40559,
            x = 1,
            y = 13,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 40560,
            x = 3,
            y = 13,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40561,
            x = 5,
            y = 13,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40562,
            x = 3,
            y = 14,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_LEATHERWORKING, {
    name = L["BTWQUESTS_PROFESSION_LEATHERWORKING"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 165,
        },
    },
    completed = {
        type = "quest",
        id = 40415,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 39958,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40183,
            x = 3,
            y = 1,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40177,
            x = 1,
            y = 2,
            connections = {
                7,
                8,
            },
        },
        {
            type = "quest",
            id = 40196,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40180,
            x = 5,
            y = 2,
            connections = {
                7,
                8,
            },
        },
        {
            type = "quest",
            id = 40197,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 41889,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40200,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40201,
            x = 3,
            y = 6,
        },
        {
            type = "quest",
            id = 40178,
            x = 0,
            y = 7,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 40179,
            x = 2,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 40181,
            x = 4,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40182,
            x = 6,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40176,
            x = 3,
            y = 8,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40184,
            x = 1,
            y = 9,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40187,
            x = 5,
            y = 9,
            connections = {
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 40185,
            x = 0,
            y = 10,
            connections = {
                4,
                5,
            },
        },
        {
            type = "quest",
            id = 40186,
            x = 2,
            y = 10,
            connections = {
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 40188,
            x = 4,
            y = 10,
            connections = {
                4,
                5,
            },
        },
        {
            type = "quest",
            id = 40189,
            x = 6,
            y = 10,
            connections = {
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 40191,
            x = 0,
            y = 11,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 40192,
            x = 2,
            y = 11,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 40194,
            x = 4,
            y = 11,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 40195,
            x = 6,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40327,
            x = 6,
            y = 12,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40198,
            x = 1,
            y = 13,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40199,
            x = 5,
            y = 13,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40202,
            x = 1,
            y = 14,
            connections = {
                2,
                4,
                5,
            },
        },
        {
            type = "quest",
            id = 40206,
            x = 5,
            y = 14,
            connections = {
                2,
                5,
                6,
            },
        },
        {
            type = "quest",
            id = 40203,
            x = 1,
            y = 15,
            connections = {
                8,
            },
        },
        {
            type = "quest",
            id = 40208,
            x = 5,
            y = 15,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 40204,
            x = 0,
            y = 16,
            connections = {
                6,
            },
        },
        {
            type = "quest",
            id = 40205,
            x = 2,
            y = 16,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 40209,
            x = 4,
            y = 16,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40207,
            x = 6,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40210,
            x = 5,
            y = 17,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40211,
            x = 3,
            y = 18,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40415,
            x = 1,
            y = 17,
        },
        {
            type = "quest",
            id = 40212,
            x = 2,
            y = 19,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40213,
            x = 4,
            y = 19,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 40214,
            x = 3,
            y = 20,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_TAILORING, {
    name = L["BTWQUESTS_PROFESSION_TAILORING"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 197,
        },
    },
    completed = {
        type = "quest",
        id = 38970,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 38944,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38945,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38946,
            x = 3,
            y = 2,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 38947,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 38948,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38949,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38950,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38951,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38952,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38953,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38954,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38955,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38956,
            x = 3,
            y = 11,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 38957,
            x = 3,
            y = 12,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 38958,
            x = 5,
            y = 12,
        },
        {
            type = "quest",
            id = 38959,
            x = 2,
            y = 13,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 38960,
            x = 4,
            y = 13,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38963,
            x = 3,
            y = 14,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38961,
            x = 3,
            y = 15,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38964,
            x = 3,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39602,
            x = 3,
            y = 17,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39605,
            x = 3,
            y = 18,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39667,
            x = 3,
            y = 19,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38965,
            x = 3,
            y = 20,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38966,
            x = 3,
            y = 21,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 42079,
            onClick = {
                type = "chain",
                id = BTWQUESTS_CHAIN_LEGION_SURAMAR_MASQUERADE,
            },
            x = 5,
            y = 21.5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38962,
            x = 3,
            y = 22,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38967,
            x = 3,
            y = 23,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 38968,
            x = 2,
            y = 24,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 38969,
            x = 4,
            y = 24,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38970,
            x = 3,
            y = 25,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 38975,
            x = 2,
            y = 26,
        },
        {
            type = "quest",
            id = 44741,
            x = 4,
            y = 26,
        },
    },
})
BtWQuestsCharacters:AddAchievement(10596);
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_PROFESSIONS_UNDERLIGHT_ANGLER, {
    name = L["BTWQUESTS_THE_UNDERLIGHT_ANGLER"],
    category = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "profession",
            id = 356,
        },
        {
            type = "achievement",
            id = 10596,
        },
    },
    completed = {
        type = "quest",
        id = 41010,
    },
    range = {98,45},
    items = {
        {
            name = L["BTWQUESTS_FISH_LUMINOUS_PEARL"],
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 40960,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 40961,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            name = L["BTWQUESTS_WAIT_NAT_PAGLE"],
            breadcrumb = true,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 41010,
            x = 3,
            y = 4,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_PROFESSIONS, {
    name = L["BTWQUESTS_PROFESSIONS"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_ALCHEMY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_BLACKSMITHING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_ENCHANTING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_ENGINEERING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_INSCRIPTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_JEWELCRAFTING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_LEATHERWORKING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_TAILORING,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_PROFESSIONS_UNDERLIGHT_ANGLER,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_PROFESSIONS,
})