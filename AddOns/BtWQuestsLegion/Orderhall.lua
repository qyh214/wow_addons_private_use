local L = BtWQuests.L;
BtWQuestsCharacters:AddAchievement(697);
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ORDERHALL_LIGHTSHEART, {
    name = L["BTWQUESTS_LIGHTS_HEART"],
    category = BTWQUESTS_CATEGORY_LEGION_ORDERHALL,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {42866, 44009},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 45177,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
            breadcrumb = true,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                },
            },
            userdata = {
                scrollTo = {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_ORDERHALL_LIGHTSHEART,
                },
            },
            x = 3,
            y = -1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 42866,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44257,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                },
            },
            x = 3,
            y = 1,
            connections = {
                3,
            }
        },
        {
            type = "npc",
            id = 90417,
            restrictions = {
                type = "class",
                ids = {
                    BTWQUESTS_CLASS_ID_WARRIOR,
                    BTWQUESTS_CLASS_ID_HUNTER,
                    BTWQUESTS_CLASS_ID_ROGUE,
                    BTWQUESTS_CLASS_ID_PRIEST,
                    BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                    BTWQUESTS_CLASS_ID_SHAMAN,
                    BTWQUESTS_CLASS_ID_MAGE,
                    BTWQUESTS_CLASS_ID_WARLOCK,
                    BTWQUESTS_CLASS_ID_MONK,
                    BTWQUESTS_CLASS_ID_DRUID,
                    BTWQUESTS_CLASS_ID_DEMONHUNTER,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44009,
            restrictions = {
                {
                    type = "class",
                    ids = {
                        BTWQUESTS_CLASS_ID_WARRIOR,
                        BTWQUESTS_CLASS_ID_HUNTER,
                        BTWQUESTS_CLASS_ID_ROGUE,
                        BTWQUESTS_CLASS_ID_PRIEST,
                        BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                        BTWQUESTS_CLASS_ID_SHAMAN,
                        BTWQUESTS_CLASS_ID_MAGE,
                        BTWQUESTS_CLASS_ID_WARLOCK,
                        BTWQUESTS_CLASS_ID_MONK,
                        BTWQUESTS_CLASS_ID_DRUID,
                        BTWQUESTS_CLASS_ID_DEMONHUNTER,
                    },
                },
            },
            x = 3,
            y = 1,
            connections = {
                2,
            }
        },
        {
            type = "npc",
            id = 110695,
            aside = true,
            x = 1,
            y = 1,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 44004,
            x = 3,
            y = 2,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 43705,
            aside = true,
            x = 1,
            y = 2,
        },
        {
            type = "quest",
            id = 44153,
            x = 3,
            y = 3,
            connections = {
                1, 3,
            }
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
            aside = true,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                },
            },
            userdata = {
                scrollTo = {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_ORDERHALL_LIGHTSHEART,
                },
            },
            x = 1,
            y = 4,
        },
        
        
        {
            type = "level",
            level = 45,
            x = 5,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44337,
            x = 3,
            y = 4,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44448,
            x = 3,
            y = 5,
            connections = {
                1,
            }
        },
        {
            name = L["BTWQUESTS_RETURN_TO_ORDER_HALL"],
            breadcrumb = true,
            x = 3,
            y = 6,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44464,
            x = 3,
            y = 7,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44466,
            x = 3,
            y = 8,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44479,
            x = 3,
            y = 9,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44480,
            x = 3,
            y = 10,
            connections = {
                1, 2, 3,
            }
        },
        {
            type = "quest",
            id = 44481,
            restrictions = {
                {
                    type = "class",
                    ids = {
                        BTWQUESTS_CLASS_ID_WARRIOR,
                        BTWQUESTS_CLASS_ID_PALADIN,
                        BTWQUESTS_CLASS_ID_HUNTER,
                        BTWQUESTS_CLASS_ID_ROGUE,
                        BTWQUESTS_CLASS_ID_PRIEST,
                        BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                        BTWQUESTS_CLASS_ID_SHAMAN,
                        BTWQUESTS_CLASS_ID_MAGE,
                        BTWQUESTS_CLASS_ID_WARLOCK,
                        BTWQUESTS_CLASS_ID_MONK,
                        BTWQUESTS_CLASS_ID_DRUID,
                    },
                },
                {
                    type = "achievement",
                    id = 697,
                    completed = true,
                },
                {
                    type = "quest",
                    id = 44496,
                    active = false,
                },
            },
            x = 3,
            y = 11,
            connections = {
                3,
            }
        },
        {
            type = "quest",
            id = 44496,
            restrictions = {
                {
                    type = "class",
                    ids = {
                        BTWQUESTS_CLASS_ID_WARRIOR,
                        BTWQUESTS_CLASS_ID_PALADIN,
                        BTWQUESTS_CLASS_ID_HUNTER,
                        BTWQUESTS_CLASS_ID_ROGUE,
                        BTWQUESTS_CLASS_ID_PRIEST,
                        BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                        BTWQUESTS_CLASS_ID_SHAMAN,
                        BTWQUESTS_CLASS_ID_MAGE,
                        BTWQUESTS_CLASS_ID_WARLOCK,
                        BTWQUESTS_CLASS_ID_MONK,
                        BTWQUESTS_CLASS_ID_DRUID,
                    },
                },
                {
                    type = "achievement",
                    id = 697,
                    completed = false,
                },
                {
                    type = "quest",
                    id = 44481,
                    active = false,
                },
            },
            x = 3,
            y = 11,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 44497,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
                },
            },
            x = 3,
            y = 11,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 45174,
            x = 3,
            y = 12,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 45175,
            x = 3,
            y = 13,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 45176,
            x = 3,
            y = 14,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 45177,
            x = 3,
            y = 15,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ORDERHALL_MEATBALL, {
    name = { -- Meatball
        type = "follower",
        id = 986,
    },
    category = BTWQUESTS_CATEGORY_LEGION_ORDERHALL,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "achievement",
            id = 11558,
            anyone = true,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_ALLIANCE,
                },
            },
        },
        {
            type = "achievement",
            id = 11559,
            anyone = true,
            restrictions = {
                {
                    type = "faction",
                    id = BTWQUESTS_FACTION_ID_HORDE,
                },
            },
        },
    },
    active = {
        type = "quest",
        id = 45302,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 45312,
    },
    range = {110},
    items = {
        {
            type = "quest",
            id = 45302,
            breadcrumb = true,
            name = "Complete a Brawl",
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "mission",
            id = 1502,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        
        
        {
            type = "quest",
            id = 45111,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "mission",
            id = 1503,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        
        
        {
            type = "quest",
            id = 45162,
            x = 3,
            y = 4,
            connections = {
                1,
            }
        },
        {
            type = "mission",
            id = 1504,
            x = 3,
            y = 5,
            connections = {
                1,
            }
        },
        
        
        {
            type = "quest",
            id = 45163,
            x = 3,
            y = 6,
            connections = {
                1,
            }
        },
        {
            type = "mission",
            id = 1512,
            x = 3,
            y = 7,
            connections = {
                1,
            }
        },
        
        
        {
            type = "quest",
            id = 45304,
            x = 3,
            y = 8,
            connections = {
                1,
            }
        },
        {
            type = "mission",
            id = 1513,
            x = 3,
            y = 9,
            connections = {
                1,
            }
        },
        
        
        {
            type = "quest",
            id = 45312,
            x = 3,
            y = 10,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_ORDERHALL, {
    name = L["BTWQUESTS_ORDERHALL"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ORDERHALL_LIGHTSHEART,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ORDERHALL_MEATBALL,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_ORDERHALL,
})

BtWQuestsDatabase:AddMission(1502, {
    name = "There is no Brawlers Guild",
})

BtWQuestsDatabase:AddMission(1503, {
    name = "Council of War",
})

BtWQuestsDatabase:AddMission(1504, {
    name = "Its Clean Up Time",
})

BtWQuestsDatabase:AddMission(1512, {
    name = "Master of Shadows",
})

BtWQuestsDatabase:AddMission(1513, {
    name = "I've Got A Strange Feeling About This",
})

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_ORDERHALL_LIGHTSHEART)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_ORDERHALL_MEATBALL)