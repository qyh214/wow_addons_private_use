local L = BtWQuests.L;
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_DISCIPLINE, {
    name = L["DISCIPLINE_LIGHTS_WRATH"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_BLOOD,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_HAVOC,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_BALANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_BEASTMASTERY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_ARCANE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_BREWMASTER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_HOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_ASSASSINATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ELEMENTAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_AFFLICTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_ARMS,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PRIEST,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("PRIEST", 1),
    active = BtWQuests.LegionArtifactActive("PRIEST", 1),
    completed = {
        type = "quest",
        id = 41632,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Priest-Discipline",
    items = {
        {
            type = "quest",
            id = 41625,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41626,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41627,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41628,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41629,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41630,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41631,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41632,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_HOLY, {
    name = L["HOLY_TUURE_BEACON_OF_THE_NAARU"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FERAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MARKSMANSHIP,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FIRE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_WINDWALKER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_PROTECTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_OUTLAW,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_ENHANCEMENT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DEMONOLOGY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FURY,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PRIEST,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("PRIEST", 2),
    active = BtWQuests.LegionArtifactActive("PRIEST", 2),
    completed = {
        type = "quest",
        id = 42074,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Priest-Holy",
    items = {
        {
            type = "quest",
            id = 41957,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41966,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41967,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 41993,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42074,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_SHADOW, {
    name = L["SHADOW_XALATATH_BLADE_OF_THE_BLACK_EMPIRE"],
    category = BTWQUESTS_CATEGORY_LEGION_ARTIFACT,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_UNHOLY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_VENGEANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_GUARDIAN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_SURVIVAL,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FROST,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MISTWEAVER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_RETRIBUTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_SUBTLETY,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_RESTORATION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_DESTRUCTION,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_PROTECTION,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PRIEST,
        },
    },
    prerequisites = BtWQuests.LegionArtifactPrerequisites("PRIEST", 3),
    active = BtWQuests.LegionArtifactActive("PRIEST", 3),
    completed = {
        type = "quest",
        id = 40710,
    },
    range = {98,45},
    buttonImage = "Interface\\AddOns\\BtWQuestsLegion\\UI-Chain-Priest-Shadow",
    items = {
        {
            type = "quest",
            id = 40710,
            x = 3,
            y = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_CAMPAIGN, {
    name = L["BTWQUESTS_PRIEST_CAMPAIGN"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_CAMPAIGN,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_CAMPAIGN,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PRIEST,
        },
    },
    completed = {
        type = "quest",
        id = 43402,
    },
    range = {98,45},
    items = {
        {
            type = "quest",
            id = 40705,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40706,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3, 4,
            },
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_DISCIPLINE,
            active = {
                type = "quest",
                id = 40706,
            },
            visible = BtWQuests.LegionArtifactNonSelected("PRIEST"),
            x = 1,
            y = 2,
            connections = {
                4
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_HOLY,
            active = {
                type = "quest",
                id = 40706,
            },
            visible = BtWQuests.LegionArtifactNonSelected("PRIEST"),
            x = 3,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_SHADOW,
            active = {
                type = "quest",
                id = 40706,
            },
            visible = BtWQuests.LegionArtifactNonSelected("PRIEST"),
            x = 5,
            y = 2,
            connections = {
                2
            },
        },


        {
            variations = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_DISCIPLINE,
                    restrictions = {
                        type = "quest",
                        id = 40709,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_HOLY,
                    restrictions = {
                        type = "quest",
                        id = 40708,
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_SHADOW,
                    restrictions = {
                        type = "quest",
                        id = 40707,
                    },
                },
                {
                    visible = false,
                },
            },
            x = 3,
            y = 2,
            connections = {
                1
            },
        },



        {
            type = "quest",
            id = 40938,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        -- {
        --     type = "quest",
        --     id = 41015,
        --     x = 3,
        --     y = 4,
        --     connections = {
        --         1
        --     },
        -- },
        -- {
        --     type = "quest",
        --     id = 41017,
        --     x = 3,
        --     y = 5,
        --     connections = {
        --         1
        --     },
        -- },
        {
            type = "quest",
            id = 41019,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },



        {
            type = "level",
            level = 101,
            x = 5,
            y = 6.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 44100,
            breadcrumb = true,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43270,
            x = 3,
            y = 8,
            connections = {
                1--, 2
            },
        },
        -- {
            -- type = "quest",
            -- id = 43271,
            -- x = 2,
            -- y = 9,
            -- connections = {
                -- 2
            -- },
        -- },
        -- {
            -- type = "quest",
            -- id = 43272,
            -- x = 4,
            -- y = 9,
            -- connections = {
                -- 1
            -- },
        -- },
        {
            type = "quest",
            id = 43273,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43275,
            x = 3,
            y = 10,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43276,
            x = 3,
            y = 11,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43277,
            x = 3,
            y = 12,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43371,
            x = 3,
            y = 13,
            connections = {
                2
            },
        },



        {
            type = "level",
            level = 103,
            x = 5,
            y = 13.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43372,
            x = 3,
            y = 14,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43373,
            x = 3,
            y = 15,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43374,
            x = 2,
            y = 16,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43375,
            x = 4,
            y = 16,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43376,
            x = 3,
            y = 17,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 42137,
            x = 2,
            y = 18,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 42138,
            x = 4,
            y = 18,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43378,
            x = 3,
            y = 19,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43379,
            x = 3,
            y = 20,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 43851,
            x = 1,
            y = 21,
        },
        {
            type = "quest",
            id = 43377,
            x = 3,
            y = 21,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43384,
            x = 5,
            y = 21,
        },


        {
            type = "quest",
            id = 43383,
            x = 3,
            y = 22,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43380,
            x = 3,
            y = 23,
            connections = {
                2
            },
        },



        {
            type = "level",
            level = 45,
            x = 5,
            y = 23.5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43385,
            x = 3,
            y = 24,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43386,
            x = 3,
            y = 25,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43387,
            x = 2,
            y = 26,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43388,
            x = 4,
            y = 26,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43389,
            x = 3,
            y = 27,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43381,
            x = 3,
            y = 28,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43390,
            x = 3,
            y = 29,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43391,
            x = 3,
            y = 30,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43392,
            x = 3,
            y = 31,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43382,
            x = 3,
            y = 32,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43393,
            x = 3,
            y = 33,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43394,
            x = 3,
            y = 34,
            connections = {
                1, 2
            },
        },


        {
            type = "quest",
            id = 43396,
            x = 2,
            y = 35,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43395,
            x = 4,
            y = 35,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43397,
            x = 3,
            y = 36,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43797,
            x = 3,
            y = 37,
            connections = {
                1, 2, 3
            },
        },


        {
            type = "quest",
            id = 43400,
            x = 1,
            y = 38,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 43399,
            x = 3,
            y = 38,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 43832,
            x = 5,
            y = 38,
            connections = {
                1
            },
        },


        {
            type = "quest",
            id = 43401,
            x = 3,
            y = 39,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43402,
            x = 3,
            y = 40,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43398,
            x = 3,
            y = 41,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 43420,
            x = 3,
            y = 42,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_FOLLOWER, {
    name = { -- Champion: Aelthalyste
		type = "quest",
		id = 46034,
	},
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_FOLLOWER_HORDE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_FOLLOWER,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_ALLIANCE,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_FOLLOWER_HORDE,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PRIEST,
        },
    },
    completed = {
        type = "quest",
        id = 46034,
    },
    range = {110},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45343,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 45344,
            x = 1,
            y = 2,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 45346,
            x = 3,
            y = 2,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45345,
            x = 5,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45347,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45348,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45349,
            x = 3,
            y = 5,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 45350,
            x = 2,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 45342,
            x = 4,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46145,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 46034,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            aside = true,
            x = 3,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_MOUNT, {
    name = L["BTWQUESTS_PRIEST_MOUNT"],
    category = BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_MOUNT,
        BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_MOUNT,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PRIEST,
        },
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
        },
    },
    completed = {
        type = "quest",
        id = 45789,
    },
    range = {110},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_BROKENSHORE_BREACHING_THE_TOMB,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45788,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 45789,
            x = 3,
            y = 2,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST, {
    name = LOCALIZED_CLASS_NAMES_MALE["PRIEST"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    alternatives = {
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_HUNTER,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARLOCK,
        BTWQUESTS_CATEGORY_LEGION_CLASSES_WARRIOR,
    },
    restrictions = {
        {
            type = "class",
            id = BTWQUESTS_CLASS_ID_PRIEST,
        }
    },
    -- buttonImage = 1041999,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_FOLLOWER,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_MOUNT,
        },
    },
})