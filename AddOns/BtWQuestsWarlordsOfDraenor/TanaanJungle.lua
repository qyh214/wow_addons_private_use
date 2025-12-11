local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local CATEGORY_ID = BtWQuests.Constant.Category.WarlordsOfDraenor.TanaanJungle;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor.TanaanJungle;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 534
local ACHIEVEMENT_ID_ALLIANCE = 10067
local ACHIEVEMENT_ID_HORDE = 10074
local CONTINENT_ID = 572

Chain.AllHandsOnDeckAlliance = 60701
Chain.TheInvasionOfTanaanAlliance = 60702
Chain.BaneOfTheBleedingHollowAlliance = 60703
Chain.DarkAscensionAlliance = 60704
Chain.TheFateOfTeronGorAlliance = 60705
Chain.TheCipherOfDamnationAlliance = 60706
Chain.AllHandsOnDeckAllianceDemonHunter = 60707

Chain.AllHandsOnDeckHorde = 60711
Chain.TheInvasionOfTanaanHorde = 60712
Chain.BaneOfTheBleedingHollowHorde = 60713
Chain.DarkAscensionHorde = 60714
Chain.TheFateOfTeronGorHorde = 60715
Chain.TheCipherOfDamnationHorde = 60716
Chain.AllHandsOnDeckHordeDemonHunter = 60717

Database:AddChain(Chain.AllHandsOnDeckAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    questline = 140,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.AllHandsOnDeckAlliance,
        Chain.AllHandsOnDeckAllianceDemonHunter,
        Chain.AllHandsOnDeckHorde,
        Chain.AllHandsOnDeckHordeDemonHunter,
    },
    restrictions = {
        ALLIANCE_RESTRICTION,
        {
            completed = false,
            restrictions = {
                type = "class",
                id = BtWQuests.Constant.Class.DemonHunter,
            },
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            name = "Upgrade your garrison to tier 3",
            type = "achievement",
            id = 9101,
        },
    },
    active = {
        type = "quest",
        id = 38253,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38259,
    },
    items = {
        {
            type = "quest",
            id = 38253,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38257,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38254,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38255,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38256,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38258,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38259,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39082,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39054,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39276,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39055,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheInvasionOfTanaanAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    questline = 142,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.TheInvasionOfTanaanAlliance,
        Chain.AllHandsOnDeckAllianceDemonHunter,
        Chain.TheInvasionOfTanaanHorde,
        Chain.AllHandsOnDeckHordeDemonHunter,
    },
    restrictions = {
        ALLIANCE_RESTRICTION,
        {
            completed = false,
            restrictions = {
                type = "class",
                id = BtWQuests.Constant.Class.DemonHunter,
            },
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 39055,
        },
    },
    active = {
        type = "quest",
        id = 38435,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38445,
    },
    items = {
        {
            type = "npc",
            id = 95002,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38435,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38436,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38444,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38445,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39422,
                    breadcrumb = true,
                    restrictions = {
                        type = "quest",
                        id = 39422,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 93822,
                },
            },
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39056,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39404,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39655,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39666,
            aside = true,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 39067,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39601,
            aside = true,
        },
        {
            type = "quest",
            id = 39068,
            aside = true,
            x = -1,
        },
    },
})
Database:AddChain(Chain.BaneOfTheBleedingHollowAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    questline = 85,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.BaneOfTheBleedingHollowHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38446,
        },
        {
            type = "questline",
            id = 85,
            mapID = 534,
            questID = 38560,
        },
    },
    active = {
        type = "quest",
        id = 38560,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38274,
    },
    items = {
        {
            type = "npc",
            id = 90309,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38560,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38270,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38271,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 38273,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 38272,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38274,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DarkAscensionAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    questline = 123,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.DarkAscensionHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38446,
        },
        {
            type = "questline",
            id = 123,
            mapID = 534,
            questID = 37687,
        },
    },
    active = {
        type = "quest",
        id = 37687,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38223,
    },
    items = {
        {
            type = "npc",
            id = 90309,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37687,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38267,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38213,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38223,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.TheFateOfTeronGorAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    questline = 121,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.TheFateOfTeronGorHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38001,
        },
        {
            type = "questline",
            id = 121,
            mapID = 534,
            questID = 38421,
        },
    },
    active = {
        type = "quest",
        id = 38421,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38562,
    },
    items = {
        {
            type = "npc",
            id = 90309,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38421,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 38562,
            x = -1,
        },
        {
            type = "quest",
            id = 38565,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheCipherOfDamnationAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    questline = 124,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.TheCipherOfDamnationHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38446,
        },
        {
            type = "questline",
            id = 124,
            mapID = 534,
            questID = 38561,
        },
    },
    active = {
        type = "quest",
        id = 38561,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 39394,
    },
    items = {
        {
            type = "npc",
            id = 90309,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38561,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38462,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39394,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.AllHandsOnDeckAllianceDemonHunter, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    questline = 140,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.AllHandsOnDeckAlliance,
        Chain.AllHandsOnDeckAllianceDemonHunter,
        Chain.AllHandsOnDeckHorde,
        Chain.AllHandsOnDeckHordeDemonHunter,
    },
    restrictions = {
        ALLIANCE_RESTRICTION,
        {
            type = "class",
            id = 12,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            name = "Upgrade your garrison to tier 3",
            type = "achievement",
            id = 9101,
        },
    },
    active = {
        type = "quest",
        id = 38253,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38259,
    },
    items = {
        {
            type = "quest",
            id = 38253,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38257,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38254,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38255,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38256,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38258,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38259,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 39082,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39056,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39054,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39404,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39276,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39655,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39055,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 39666,
            aside = true,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 39067,
            aside = true,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39601,
            aside = true,
        },
        {
            type = "quest",
            id = 39068,
            aside = true,
            x = 0,
        },
    },
})

Database:AddChain(Chain.AllHandsOnDeckHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    questline = 139,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.AllHandsOnDeckAlliance,
        Chain.AllHandsOnDeckAllianceDemonHunter,
        Chain.AllHandsOnDeckHorde,
        Chain.AllHandsOnDeckHordeDemonHunter,
    },
    restrictions = {
        HORDE_RESTRICTION,
        {
            completed = false,
            restrictions = {
                type = "class",
                id = BtWQuests.Constant.Class.DemonHunter,
            },
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            name = "Upgrade your garrison to tier 3",
            type = "achievement",
            id = 9101,
        },
    },
    active = {
        type = "quest",
        id = 38567,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38574,
    },
    items = {
        {
            type = "quest",
            id = 38567,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38568,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38570,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38571,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38572,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38573,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38574,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39236,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39241,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39242,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheInvasionOfTanaanHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    questline = 141,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.TheInvasionOfTanaanAlliance,
        Chain.AllHandsOnDeckAllianceDemonHunter,
        Chain.TheInvasionOfTanaanHorde,
        Chain.AllHandsOnDeckHordeDemonHunter,
    },
    restrictions = {
        HORDE_RESTRICTION,
        {
            completed = false,
            restrictions = {
                type = "class",
                id = BtWQuests.Constant.Class.DemonHunter,
            },
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 39242,
        },
    },
    active = {
        type = "quest",
        id = 37889,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 37935,
    },
    items = {
        {
            type = "npc",
            id = 94429,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37889,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37934,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37935,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 39423,
                    breadcrumb = true,
                    restrictions = {
                        type = "quest",
                        id = 39423,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 94789,
                },
            },
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39243,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39401,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39674,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39675,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39676,
            aside = true,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 39245,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39604,
            aside = true,
        },
        {
            type = "quest",
            id = 39246,
            aside = true,
            x = -1,
        },
    },
})
Database:AddChain(Chain.BaneOfTheBleedingHollowHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    questline = 84,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.BaneOfTheBleedingHollowAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38001,
        },
        {
            type = "questline",
            id = 84,
            mapID = 534,
            questID = 38453,
        },
    },
    active = {
        type = "quest",
        id = 38453,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38274,
    },
    items = {
        {
            type = "npc",
            id = 90481,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38453,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38270,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38271,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 38273,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 38272,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38274,
            x = 0,
        },
    },
})
Database:AddChain(Chain.DarkAscensionHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    questline = 125,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.DarkAscensionAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38001,
        },
        {
            type = "questline",
            id = 125,
            mapID = 534,
            questID = 37688,
        },
    },
    active = {
        type = "quest",
        id = 37688,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38223,
    },
    items = {
        {
            type = "npc",
            id = 90481,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37688,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38269,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38213,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38223,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.TheFateOfTeronGorHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    questline = 122,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.TheFateOfTeronGorAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38001,
        },
        {
            type = "questline",
            id = 122,
            mapID = 534,
            questID = 38415,
        },
    },
    active = {
        type = "quest",
        id = 38415,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38416,
    },
    items = {
        {
            type = "npc",
            id = 90481,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38415,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 38416,
            x = -1,
        },
        {
            type = "quest",
            id = 38417,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheCipherOfDamnationHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 6),
    questline = 126,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.TheCipherOfDamnationAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            type = "quest",
            id = 38001,
        },
        {
            type = "questline",
            id = 126,
            mapID = 534,
            questID = 38458,
        },
    },
    active = {
        type = "quest",
        id = 38458,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38463,
    },
    items = {
        {
            type = "npc",
            id = 90481,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38458,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38462,
            x = 0,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 38463,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.AllHandsOnDeckHordeDemonHunter, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    questline = 139,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {40,60},
    major = true,
    alternatives = {
        Chain.AllHandsOnDeckAlliance,
        Chain.AllHandsOnDeckAllianceDemonHunter,
        Chain.AllHandsOnDeckHorde,
        Chain.AllHandsOnDeckHordeDemonHunter,
    },
    restrictions = {
        HORDE_RESTRICTION,
        {
            type = "class",
            id = BtWQuests.Constant.Class.DemonHunter,
        },
    },
    prerequisites = {
        {
            type = "level",
            level = 40,
        },
        {
            name = "Upgrade your garrison to tier 3",
            type = "achievement",
            id = 9101,
        },
    },
    active = {
        type = "quest",
        id = 38567,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 38574,
    },
    items = {
        {
            type = "quest",
            id = 38567,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38568,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38570,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38571,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38572,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38573,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 38574,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 39236,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39243,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39241,
            aside = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39401,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39242,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 39674,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39675,
            aside = true,
            x = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 39676,
            aside = true,
            x = 1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 39245,
            aside = true,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 39604,
            aside = true,
        },
        {
            type = "quest",
            id = 39246,
            aside = true,
            x = 0,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.AllHandsOnDeckAlliance,
        },
        {
            type = "chain",
            id = Chain.TheInvasionOfTanaanAlliance,
        },
        {
            type = "chain",
            id = Chain.AllHandsOnDeckAllianceDemonHunter,
        },
        {
            type = "chain",
            id = Chain.BaneOfTheBleedingHollowAlliance,
        },
        {
            type = "chain",
            id = Chain.DarkAscensionAlliance,
        },
        {
            type = "chain",
            id = Chain.TheFateOfTeronGorAlliance,
        },
        {
            type = "chain",
            id = Chain.TheCipherOfDamnationAlliance,
        },

        {
            type = "chain",
            id = Chain.AllHandsOnDeckHorde,
        },
        {
            type = "chain",
            id = Chain.TheInvasionOfTanaanHorde,
        },
        {
            type = "chain",
            id = Chain.AllHandsOnDeckHordeDemonHunter,
        },
        {
            type = "chain",
            id = Chain.BaneOfTheBleedingHollowHorde,
        },
        {
            type = "chain",
            id = Chain.DarkAscensionHorde,
        },
        {
            type = "chain",
            id = Chain.TheFateOfTeronGorHorde,
        },
        {
            type = "chain",
            id = Chain.TheCipherOfDamnationHorde,
        },
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddContinentItems(CONTINENT_ID, {
})
