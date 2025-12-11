local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local CATEGORY_ID = BtWQuests.Constant.Category.WarlordsOfDraenor.Nagrand;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor.Nagrand;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 550
local ACHIEVEMENT_ID_ALLIANCE = 8927
local ACHIEVEMENT_ID_HORDE = 8928
local CONTINENT_ID = 572

Chain.TheMightOfSteelAndBloodAlliance = 60601
Chain.TheRingOfTrialsAlliance = 60602
Chain.CalledToTheThroneAlliance = 60603
Chain.TheShadowOfTheVoidAlliance = 60604
Chain.TheDarkHeartOfOshugunAlliance = 60605
Chain.ABlademastersHonorAlliance = 60606
Chain.TroubleAtTheOverwatchAlliance = 60607
Chain.TheTakingOfLokrathAlliance = 60608
Chain.TheLegacyOfGarroshHellscreamAlliance = 60609

Chain.TheMightOfSteelAndBloodHorde = 60611
Chain.TheRingOfTrialsHorde = 60612
Chain.CalledToTheThroneHorde = 60613
Chain.TheShadowOfTheVoidHorde = 60614
Chain.TheDarkHeartOfOshugunHorde = 60615
Chain.RemainsOfTelaarHorde = 60616
Chain.TroubleAtTheOverwatchHorde = 60617
Chain.TheTakingOfLokrathHorde = 60618
Chain.TheLegacyOfGarroshHellscreamHorde = 60619

Database:AddChain(Chain.TheMightOfSteelAndBloodAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheMightOfSteelAndBloodHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
    },
    active = {
        type = "quest",
        id = 34675,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34769,
    },
    items = {
        {
            type = "npc",
            id = 79263,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34675,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34678,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34682,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34716,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 34717,
        },
        {
            type = "quest",
            id = 34718,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34719,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34746,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34769,
            x = -1,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.TheRingOfTrialsAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheRingOfTrialsHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodAlliance,
        },
    },
    active = {
        type = "quest",
        id = 34662,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34666,
    },
    items = {
        {
            type = "npc",
            id = 79188,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34662,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34663,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34664,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34665,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34666,
            x = 0,
        },
    },
})
Database:AddChain(Chain.CalledToTheThroneAlliance, {
    name = { -- Called to the Throne
        type = "quest",
        id = 35331,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    alternatives = {
        Chain.CalledToTheThroneHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
    },
    active = {
        type = "quest",
        ids = {35332, 35331},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35372,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 35332,
                    restrictions = {
                        type = "quest",
                        id = 35332,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 82138,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35331,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 35333,
            x = -3,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 34881,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 34893,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 34943,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34894,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34932,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34941,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35330,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35372,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheShadowOfTheVoidAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheShadowOfTheVoidHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.CalledToTheThroneAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {35083, 35084, 35386},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35088,
    },
    items = {
        {
            type = "object",
            id = 233263,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "object",
            id = 232024,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35084,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35083,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35386,
        },
        {
            type = "quest",
            id = 35085,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35086,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35087,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35088,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.TheDarkHeartOfOshugunAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheDarkHeartOfOshugunHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.CalledToTheThroneAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {35398, 35397},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35396,
    },
    items = {
        {
            type = "npc",
            id = 82179,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35398,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 35397,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35395,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 35396,
        },
    },
})
-- Is [They Call Him Lantresor of the Blade] required?
Database:AddChain(Chain.ABlademastersHonorAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.RemainsOfTelaarHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {34951, 34952, 34954, 34955},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34957,
    },
    items = {
        {
            type = "npc",
            id = 80624,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 79954,
            aside = true,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34951,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 34952,
            aside = true,
        },
        {
            type = "quest",
            id = 34954,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34955,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34956,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34957,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34747,
            aside = true,
            x = 0,
        },
    },
})
-- Is [Trouble at the Overwatch] a breadcrumb?
Database:AddChain(Chain.TroubleAtTheOverwatchAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TroubleAtTheOverwatchHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {35148, 34572, 34593, 34597},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34596,
    },
    items = {
        {
            type = "npc",
            id = 79954,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35148,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34572,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 34593,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 34597,
            aside = true,
        },
        {
            type = "quest",
            id = 34596,
            x = -1,
        },
        {
            type = "quest",
            id = 34877,
            aside = true,
        },
    },
})
-- Is [Along the Riverside] a breadcrumb?
Database:AddChain(Chain.TheTakingOfLokrathAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheTakingOfLokrathHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodAlliance,
        },
        {
            type = "chain",
            id = Chain.ABlademastersHonorAlliance,
        },
        {
            type = "chain",
            id = Chain.TroubleAtTheOverwatchAlliance,
        },
    },
    active = {
        type = "quest",
        ids = {35059, 35060},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35061,
    },
    items = {
        {
            type = "npc",
            id = 79576,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35059,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35060,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 35068,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 35067,
            aside = true,
        },
        {
            type = "quest",
            id = 35061,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35069,
            aside = true,
        },
        {
            type = "quest",
            id = 35062,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheLegacyOfGarroshHellscreamAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 8),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheLegacyOfGarroshHellscreamHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodAlliance,
        },
        {
            type = "chain",
            id = Chain.ABlademastersHonorAlliance,
        },
        {
            type = "chain",
            id = Chain.TroubleAtTheOverwatchAlliance,
        },
        {
            type = "chain",
            id = Chain.TheTakingOfLokrathAlliance,
        },
        {
            type = "quest",
            id = 35062,
        },
    },
    active = {
        type = "quest",
        id = 35169,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35169,
    },
    items = {
        {
            type = "npc",
            id = 79576,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35169,
            x = 0,
        },
    },
})

Database:AddChain(Chain.TheMightOfSteelAndBloodHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheMightOfSteelAndBloodAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
    },
    active = {
        type = "quest",
        id = 34795,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34899,
    },
    items = {
        {
            type = "npc",
            id = 80001,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34795,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34808,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34818,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 34826,
            aside = true,
        },
        {
            type = "quest",
            id = 34849,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34850,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34866,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34868,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34770,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 34899,
        },
    },
})
Database:AddChain(Chain.TheRingOfTrialsHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheRingOfTrialsAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodHorde,
        },
    },
    active = {
        type = "quest",
        id = 34662,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34666,
    },
    items = {
        {
            type = "npc",
            id = 79188,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34662,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34663,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34664,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34665,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34666,
            x = 0,
        },
    },
})
Database:AddChain(Chain.CalledToTheThroneHorde, {
    name = { -- Called to the Throne
        type = "quest",
        id = 34965,
    },
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    alternatives = {
        Chain.CalledToTheThroneAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
    },
    active = {
        type = "quest",
        ids = {34964, 34965},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35232,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 34964,
                    restrictions = {
                        type = "quest",
                        id = 34964,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 80597,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34965,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 34891,
            x = -3,
            connections = {
                7, 
            },
        },
        {
            type = "quest",
            id = 34881,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 34893,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 34943,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34894,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34932,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34941,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35265,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35232,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheShadowOfTheVoidHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheShadowOfTheVoidAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.CalledToTheThroneHorde,
        },
    },
    active = {
        type = "quest",
        ids = {35084, 35083, 35271},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35088,
    },
    items = {
        {
            type = "object",
            id = 233263,
            x = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "object",
            id = 232024,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35084,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35083,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35271,
            aside = true,
        },
        {
            type = "quest",
            id = 35085,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35086,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35087,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35088,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheDarkHeartOfOshugunHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheDarkHeartOfOshugunAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.CalledToTheThroneHorde,
        },
    },
    active = {
        type = "quest",
        ids = {35144, 35145},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35317,
    },
    items = {
        {
            type = "npc",
            id = 81335,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35144,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 35145,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34271,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 35317,
        },
    },
})
-- Is [Target of Opportunity: Telaar] required or a breadcrumb?
Database:AddChain(Chain.RemainsOfTelaarHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 5),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.ABlademastersHonorAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodHorde,
        },
    },
    active = {
        type = "quest",
        ids = {34914, 34915, 34916, 34917},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34918,
    },
    items = {
        {
            type = "npc",
            id = 81189,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34914,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34915,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34916,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34917,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34918,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TroubleAtTheOverwatchHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 6),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TroubleAtTheOverwatchAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodHorde,
        },
    },
    active = {
        type = "quest",
        ids = {35150, 35155, 35156, 35157},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35158,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 35150,
                    restrictions = {
                        type = "quest",
                        id = 35150,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 79281,
                },
            },
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "object",
            id = 231901,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35155,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 35157,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 35156,
            aside = true,
        },
        {
            type = "quest",
            id = 35158,
            x = -1,
        },
        {
            type = "quest",
            id = 35159,
            aside = true,
        },
    },
})
Database:AddChain(Chain.TheTakingOfLokrathHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 7),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheTakingOfLokrathAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodHorde,
        },
        {
            type = "chain",
            id = Chain.RemainsOfTelaarHorde,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.TroubleAtTheOverwatchHorde,
        },
    },
    active = {
        type = "quest",
        ids = {35095, 35096},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35097,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 35095,
                    restrictions = {
                        type = "quest",
                        id = 35095,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 81186,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35096,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 35099,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 35100,
            aside = true,
        },
        {
            type = "quest",
            id = 35097,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35101,
            aside = true,
        },
        {
            type = "quest",
            id = 35098,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheLegacyOfGarroshHellscreamHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 8),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {35,60},
    major = true,
    alternatives = {
        Chain.TheLegacyOfGarroshHellscreamAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodHorde,
        },
        {
            type = "chain",
            id = Chain.RemainsOfTelaarHorde,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.TroubleAtTheOverwatchHorde,
        },
        {
            type = "chain",
            id = Chain.TheTakingOfLokrathHorde,
        },
        {
            type = "quest",
            id = 35098,
        },
    },
    active = {
        type = "quest",
        id = 35171,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35171,
    },
    items = {
        {
            type = "npc",
            id = 80003,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35171,
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
            id = Chain.TheMightOfSteelAndBloodAlliance,
        },
        {
            type = "chain",
            id = Chain.TheRingOfTrialsAlliance,
        },
        {
            type = "chain",
            id = Chain.CalledToTheThroneAlliance,
        },
        {
            type = "chain",
            id = Chain.TheShadowOfTheVoidAlliance,
        },
        {
            type = "chain",
            id = Chain.TheDarkHeartOfOshugunAlliance,
        },
        {
            type = "chain",
            id = Chain.ABlademastersHonorAlliance,
        },
        {
            type = "chain",
            id = Chain.TroubleAtTheOverwatchAlliance,
        },
        {
            type = "chain",
            id = Chain.TheTakingOfLokrathAlliance,
        },
        {
            type = "chain",
            id = Chain.TheLegacyOfGarroshHellscreamAlliance,
        },

        {
            type = "chain",
            id = Chain.TheMightOfSteelAndBloodHorde,
        },
        {
            type = "chain",
            id = Chain.TheRingOfTrialsHorde,
        },
        {
            type = "chain",
            id = Chain.CalledToTheThroneHorde,
        },
        {
            type = "chain",
            id = Chain.TheShadowOfTheVoidHorde,
        },
        {
            type = "chain",
            id = Chain.TheDarkHeartOfOshugunHorde,
        },
        {
            type = "chain",
            id = Chain.RemainsOfTelaarHorde,
        },
        {
            type = "chain",
            id = Chain.TroubleAtTheOverwatchHorde,
        },
        {
            type = "chain",
            id = Chain.TheTakingOfLokrathHorde,
        },
        {
            type = "chain",
            id = Chain.TheLegacyOfGarroshHellscreamHorde,
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
