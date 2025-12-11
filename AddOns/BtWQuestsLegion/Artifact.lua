local L = BtWQuests.L;
BtWQuestsCharacters:AddAchievement(10746);
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_BALANCEOFPOWER, {
    name = { -- Balance of Power
        type = "quest",
        id = 43533
    },
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_BEHINDENEMYLINES,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_AZSUNA_DEFENDINGAZUREWINGREPOSE,
        },
        {
            name = L["BTWQUESTS_COMPLETE_ORDER_HALL_CAMPAIGN"],
            type = "achievement",
            id = 10746,
        },
    },
    active = {
        type = "quest",
        ids = {43496, 43503, 43501, 43505},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 43533,
    },
    major = true,
    range = {110},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Artifact-BalanceofPower",
    items = {
        {
            variations = {
                {
                    type = "quest",
                    ids = {43496, 43503},
                    restrictions = {
                        type = "chain",
                        id = BTWQUESTS_CHAIN_LEGION_AZSUNA_DEFENDINGAZUREWINGREPOSE,
                    },
                },
                {
                    type = "quest",
                    ids = {43496, 43503},
                    restrictions = {
                        type = "quest",
                        ids = {43496, 43503},
                        status = {'active'}
                    },
                },
                {
                    type = "quest",
                    ids = {43501, 43505},
                },
            },
            x = 2.75,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40668,
            userdata = {
                source = {
                    type = "map",
                    mapID = 630,
                    x = 0.48,
                    y = 0.26,
                },
            },
            x = 3.25,
            y = 1,
            connections = {
                2, 3, 4
            },
        },


        {
            type = "reputation",
            id = 1900,
            standing = 6,
            x = 0.5,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43514,
            x = 1,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 43517,
            x = 3,
            y = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43518,
            x = 5,
            y = 2,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43519,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43581,
            breadcrumb = true,
            x = 3,
            y = 4,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43520,
            x = 2,
            y = 5,
            atlas = "groupfinder-button-raids-legion",
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43521,
            x = 4,
            y = 5,
            atlas = "groupfinder-button-raids-legion",
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43522,
            x = 2.75,
            y = 6,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43527,
            breadcrumb = 1,
            onClick = {
                type = "chain",
                id = BTWQUESTS_CHAIN_LEGION_SURAMAR_MOON_GUARD_STRONGHOLD,
            },
            x = 2.9,
            y = 7,
            connections = {
                1
            },
        },




        {
            type = "quest",
            id = 43523,
            x = 3.1,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "reputation",
            id = 1859,
            standing = 7,
            x = 5.25,
            y = 8.5,
            onClick = {
                type = "category",
                id = BTWQUESTS_CATEGORY_LEGION_SURAMAR,
            },
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40673,
            x = 3.25,
            y = 9,
            connections = {
                1, 2, 3
            },
        },



        {
            type = "quest",
            id = 43525,
            x = 1,
            y = 10,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 40675,
            x = 3,
            y = 10,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43524,
            x = 5,
            y = 10,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 40678,
            x = 3.25,
            y = 11,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43526,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 40603,
            x = 2.75,
            y = 13,
            connections = {
                2
            },
        },


        {
            type = "reputation",
            id = 1948,
            standing = 7,
            x = 5.25,
            y = 13.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40608,
            x = 3.25,
            y = 14,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 40613,
            x = 3,
            y = 15,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 40614,
            x = 2,
            y = 16,
            connections = {
                2
            },
        },


        {
            type = "quest",
            id = 40672,
            x = 4,
            y = 16,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 40615,
            x = 2.75,
            y = 17,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43528,
            x = 3.25,
            y = 18,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43531,
            x = 2,
            y = 19,
            connections = {
                2
            },
        },


        {
            type = "quest",
            id = 43530,
            x = 4,
            y = 19,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43532,
            x = 3,
            y = 20,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43533,
            x = 3,
            y = 21,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM, {
    name = L["BTWQUESTS_THE_THIEVING_APPRENTICE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
    },
    restrictions = {
        {
            type = "class",
            ids = {
                BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                BTWQUESTS_CLASS_ID_DEMONHUNTER,
                BTWQUESTS_CLASS_ID_HUNTER,
                BTWQUESTS_CLASS_ID_ROGUE,
                BTWQUESTS_CLASS_ID_WARRIOR,
            },
        },
    },
    active = {
        type = "quest",
        ids = {46744, 46765},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 45865,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 46744,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 46765,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 47000,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44782,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44821,
            x = 3,
            y = 4,
            connections = {
                1, 2,
                3,
                4, 5,
                6, 7,
                8, 9,
                10, 11, 12, 13, 14
            }
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 47025,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47057,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 46314,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 4,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 47018,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47039,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47051,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47058,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47056,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 45412,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "quest",
            id = 47046,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            x = 3,
            y = 5,
            connections = {
                5
            }
        },
        {
            type = "quest",
            id = 47043,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
                }
            },
            x = 2,
            y = 5,
            connections = {
                4
            }
        },
        {
            type = "quest",
            id = 47047,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            x = 5,
            y = 5,
            connections = {
                3
            }
        },
        {
            type = "quest",
            id = 47048,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            x = 5,
            y = 5,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 44914,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            x = 1,
            y = 5,
            connections = {
                1
            }
        },


        {
            type = "quest",
            id = 44915,
            x = 3,
            y = 6,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 44920,
            x = 3,
            y = 7,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 44924,
            x = 3,
            y = 8,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46177,
            x = 3,
            y = 9,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45865,
            x = 3,
            y = 10,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 44925,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN, {
    name = L["BTWQUESTS_FATE_OF_THE_TIDESKORN"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
    },
    restrictions = {
        {
            type = "class",
            ids = {
                BTWQUESTS_CLASS_ID_PALADIN,
                BTWQUESTS_CLASS_ID_MAGE,
                BTWQUESTS_CLASS_ID_ROGUE,
                BTWQUESTS_CLASS_ID_SHAMAN,
                BTWQUESTS_CLASS_ID_WARLOCK,
            },
        },
    },
    active = {
        type = "quest",
        ids = {46744, 46765},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 45862,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 46744,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 46765,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 47000,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44782,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44821,
            x = 3,
            y = 4,
            connections = {
                1, 2,
                3, 4,
                5, 6,
                7, 8,
                9, 10,
                11, 12, 13, 14, 15
            }
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 46078,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 45412,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47055,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 45182,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 45123,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 47003,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47058,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 47048,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47041,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 45560,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "quest",
            id = 47052,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            x = 5,
            y = 5,
            connections = {
                5
            }
        },
        {
            type = "quest",
            id = 45482,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            x = 1,
            y = 5,
            connections = {
                4
            }
        },
        {
            type = "quest",
            id = 47051,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            x = 1,
            y = 5,
            connections = {
                3
            }
        },
        {
            type = "quest",
            id = 47050,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            x = 3,
            y = 5,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 47049,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            x = 3,
            y = 5,
            connections = {
                1
            }
        },


        {
            type = "quest",
            id = 45486,
            x = 3,
            y = 6,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45522,
            x = 3,
            y = 7,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45523,
            x = 3,
            y = 8,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45524,
            x = 3,
            y = 9,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45525,
            x = 3,
            y = 10,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46340,
            x = 3,
            y = 11,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45862,
            x = 3,
            y = 12,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45526,
            x = 3,
            y = 13,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS, {
    name = L["BTWQUESTS_AID_OF_THE_ILLIDARI"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
    },
    restrictions = {
        {
            type = "class",
            ids = {
                BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                BTWQUESTS_CLASS_ID_DEMONHUNTER,
                BTWQUESTS_CLASS_ID_DRUID,
                BTWQUESTS_CLASS_ID_MONK,
                BTWQUESTS_CLASS_ID_PALADIN,
                BTWQUESTS_CLASS_ID_WARRIOR,
            },
        },
    },
    active = {
        type = "quest",
        ids = {46744, 46765},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 45863,
    },
    range = {110},
    items = {
        {
            type = "quest",
            id = 46744,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 46765,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 47000,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44782,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44821,
            x = 3,
            y = 4,
            connections = {
                1, 2,
                3,
                4, 5, 6,
                7, 8,
                9, 10,
                11, 12,
                13, 14, 15, 16, 17, 18
            }
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 47046,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47058,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 47043,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 2,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47037,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 0,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47059,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 2,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 47003,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 6,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 46078,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47052,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 47005,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 47019,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 44914,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47056,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "quest",
            id = 47025,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            x = 1,
            y = 5,
            connections = {
                6
            }
        },
        {
            type = "quest",
            id = 46314,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEMONHUNTER,
                }
            },
            x = 4,
            y = 5,
            connections = {
                5
            }
        },
        {
            type = "quest",
            id = 47023,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            x = 4,
            y = 5,
            connections = {
                4
            }
        },
        {
            type = "quest",
            id = 47024,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            x = 1,
            y = 5,
            connections = {
                3
            }
        },
        {
            type = "quest",
            id = 47022,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            x = 3,
            y = 5,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 45412,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            x = 5,
            y = 5,
            connections = {
                1
            }
        },


        {
            type = "quest",
            id = 45413,
            x = 3,
            y = 6,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45414,
            x = 3,
            y = 7,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45415,
            x = 3,
            y = 8,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45843,
            x = 3,
            y = 9,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45863,
            x = 3,
            y = 10,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45416,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS, {
    name = L["BTWQUESTS_THE_BRADENSBROOK_INVESTIGATION"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
    },
    restrictions = {
        {
            type = "class",
            ids = {
                BTWQUESTS_CLASS_ID_DRUID,
                BTWQUESTS_CLASS_ID_PALADIN,
                BTWQUESTS_CLASS_ID_PRIEST,
                BTWQUESTS_CLASS_ID_MONK,
                BTWQUESTS_CLASS_ID_SHAMAN,
            },
        },
    },
    active = {
        type = "quest",
        ids = {46744, 46765},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 45864,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 46744,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 46765,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 47000,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44782,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44821,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3,
                4, 5,
                6, 7,
                8, 9,
                10, 11,
                12, 13, 14, 15, 16
            }
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47037,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 0,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47059,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 2,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 47023,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 4,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 45412,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47052,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 47020,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47042,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 47024,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 47019,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 45123,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47050,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "quest",
            id = 47004,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            x = 6,
            y = 5,
            connections = {
                5
            }
        },
        {
            type = "quest",
            id = 47006,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PALADIN,
                }
            },
            x = 1,
            y = 5,
            connections = {
                4
            }
        },
        {
            type = "quest",
            id = 46078,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            x = 3,
            y = 5,
            connections = {
                3
            }
        },
        {
            type = "quest",
            id = 47005,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            x = 3,
            y = 5,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 47003,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            x = 5,
            y = 5,
            connections = {
                1
            }
        },


        {
            type = "quest",
            id = 46079,
            x = 3,
            y = 6,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46082,
            x = 3,
            y = 7,
            connections = {
                1, 2
            }
        },
        {
            type = "quest",
            id = 46080,
            x = 2,
            y = 8,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 46106,
            x = 4,
            y = 8,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46107,
            x = 3,
            y = 9,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46200,
            x = 3,
            y = 10,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45864,
            x = 3,
            y = 11,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46035,
            x = 3,
            y = 12,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM, {
    name = L["BTWQUESTS_RUMBLINGS_NEAR_FELTOTEM"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
    },
    restrictions = {
        {
            type = "class",
            ids = {
                BTWQUESTS_CLASS_ID_HUNTER,
                BTWQUESTS_CLASS_ID_PRIEST,
                BTWQUESTS_CLASS_ID_MONK,
                BTWQUESTS_CLASS_ID_WARLOCK,
            },
        },
    },
    active = {
        type = "quest",
        ids = {46744, 46765},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 45842,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 46744,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 46765,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 47000,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44782,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44821,
            x = 3,
            y = 4,
            connections = {
                1, 2,
                3, 4,
                5, 6,
                7, 8,
                9, 10, 11, 12
            }
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47039,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 47047,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 46078,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47042,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 47024,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 47005,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47041,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47049,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "quest",
            id = 47018,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            x = 1,
            y = 5,
            connections = {
                4
            }
        },
        {
            type = "quest",
            id = 47020,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            x = 1,
            y = 5,
            connections = {
                3
            }
        },
        {
            type = "quest",
            id = 47019,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MONK,
                }
            },
            x = 5,
            y = 5,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 45560,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            x = 5,
            y = 5,
            connections = {
                1
            }
        },


        {
            type = "quest",
            id = 45564,
            x = 3,
            y = 6,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45726,
            x = 3,
            y = 7,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45575,
            x = 3,
            y = 8,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45587,
            x = 3,
            y = 9,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45796,
            x = 3,
            y = 10,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45841,
            x = 3,
            y = 11,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45842,
            x = 3,
            y = 12,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45627,
            x = 3,
            y = 13,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER, {
    name = L["BTWQUESTS_THE_FOLLY_OF_LEVIA_LAURENCE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
    },
    restrictions = {
        {
            type = "class",
            ids = {
                BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                BTWQUESTS_CLASS_ID_DRUID,
                BTWQUESTS_CLASS_ID_MAGE,
                BTWQUESTS_CLASS_ID_ROGUE,
                BTWQUESTS_CLASS_ID_SHAMAN,
                BTWQUESTS_CLASS_ID_WARRIOR,
            },
        },
    },
    active = {
        type = "quest",
        ids = {46744, 46765},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 45861,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 46744,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 46765,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 47000,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44782,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44821,
            x = 3,
            y = 4,
            connections = {
                1, 2,
                3, 4, 5,
                6, 7,
                8, 9,
                10, 11,
                12, 13,
                14, 15, 16, 17, 18, 19
            }
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 47025,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 47046,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 47037,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 0,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 47023,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 4,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 47003,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 6,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47051,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 47048,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47050,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 47003,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 45482,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
            name = {
                type = "quest",
                id = 45182,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 44914,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 45412,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "quest",
            id = 45123,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_SHAMAN,
                }
            },
            x = 1,
            y = 5,
            connections = {
                6
            }
        },
        {
            type = "quest",
            id = 47059,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            x = 2,
            y = 5,
            connections = {
                5
            }
        },
        {
            type = "quest",
            id = 47055,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            x = 3,
            y = 5,
            connections = {
                4
            }
        },
        {
            type = "quest",
            id = 47056,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARRIOR,
                }
            },
            x = 3,
            y = 5,
            connections = {
                3
            }
        },
        {
            type = "quest",
            id = 47058,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_ROGUE,
                }
            },
            x = 3,
            y = 5,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 47057,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DEATHKNIGHT,
                }
            },
            x = 5,
            y = 5,
            connections = {
                1
            }
        },


        {
            type = "quest",
            id = 46327,
            x = 3,
            y = 6,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45916,
            x = 3,
            y = 7,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45125,
            x = 3,
            y = 8,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45917,
            x = 3,
            y = 9,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45126,
            x = 3,
            y = 10,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45127,
            x = 3,
            y = 11,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45861,
            x = 3,
            y = 12,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46065,
            x = 3,
            y = 13,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS, {
    name = L["BTWQUESTS_THE_TWISTED_TWINS"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
        BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
    },
    restrictions = {
        {
            type = "class",
            ids = {
                BTWQUESTS_CLASS_ID_DRUID,
                BTWQUESTS_CLASS_ID_HUNTER,
                BTWQUESTS_CLASS_ID_PRIEST,
                BTWQUESTS_CLASS_ID_MAGE,
                BTWQUESTS_CLASS_ID_WARLOCK,
            },
        },
    },
    active = {
        type = "quest",
        ids = {46744, 46765},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 45866,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 46744,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 46765,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 47000,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44782,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 44821,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3,
                4, 5,
                6, 7,
                8, 9,
                10, 11,
                12, 13, 14, 15, 16
            }
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47059,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 2,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
            name = {
                type = "quest",
                id = 47023,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 4,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 47003,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 6,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 47018,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
            name = {
                type = "quest",
                id = 47047,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 47020,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
            name = {
                type = "quest",
                id = 46078,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 45482,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 1,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
            name = {
                type = "quest",
                id = 47055,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
            name = {
                type = "quest",
                id = 47049,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 3,
            y = 5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
            name = {
                type = "quest",
                id = 45560,
            },
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            aside = true,
            userdata = {scrollTo = false},
            x = 5,
            y = 5,
        },


        {
            type = "quest",
            id = 47041,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_WARLOCK,
                }
            },
            x = 1,
            y = 5,
            connections = {
                5
            }
        },
        {
            type = "quest",
            id = 47037,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_DRUID,
                },
            },
            x = 0,
            y = 5,
            connections = {
                4
            }
        },
        {
            type = "quest",
            id = 45182,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_MAGE,
                }
            },
            x = 5,
            y = 5,
            connections = {
                3
            }
        },
        {
            type = "quest",
            id = 47039,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_HUNTER,
                }
            },
            x = 3,
            y = 5,
            connections = {
                2
            }
        },
        {
            type = "quest",
            id = 47042,
            restrictions = {
                {
                    type = "class",
                    id = BTWQUESTS_CLASS_ID_PRIEST,
                }
            },
            x = 5,
            y = 5,
            connections = {
                1
            }
        },



        {
            type = "quest",
            id = 45185,
            x = 3,
            y = 6,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45187,
            x = 3,
            y = 7,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45188,
            x = 3,
            y = 8,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45190,
            x = 3,
            y = 9,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45192,
            x = 3,
            y = 10,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45193,
            x = 3,
            y = 11,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 45866,
            x = 3,
            y = 12,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 46127,
            x = 3,
            y = 13,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_ARTIFACT, {
    name = L["BTWQUESTS_ARTIFACT"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    buttonImage = 1411857,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_RESTORATION,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_BEASTMASTERY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MARKSMANSHIP,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_SURVIVAL,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_HOLY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_PROTECTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_RETRIBUTION,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_DISCIPLINE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_HOLY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_SHADOW,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_AFFLICTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DEMONOLOGY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DESTRUCTION,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_ARMS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FURY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_PROTECTION,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_XYLEM,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TIDESKORN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TANKS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_HEALERS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_FELTOTEM,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_IMPMOTHER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_TWINS,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_ARTIFACT_BALANCEOFPOWER,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
})