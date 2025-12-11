local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local CATEGORY_ID = BtWQuests.Constant.Category.WarlordsOfDraenor.SpiresOfArak;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor.SpiresOfArak;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 542
local ACHIEVEMENT_ID_ALLIANCE = 8925
local ACHIEVEMENT_ID_HORDE = 8926
local CONTINENT_ID = 572

Chain.ShadowsGatherAlliance = 60501
Chain.ShadowsGatherHorde = 60502
Chain.AdmiralTaylorsGarrisonAlliance = 60503
Chain.AdmiralTaylorsGarrisonHorde = 60504
Chain.SecretsOfTheTalonpriests = 60505
Chain.TheGodsOfArak = 60506
Chain.LegacyOfTheApexis = 60507
Chain.TerokksLegend = 60508
Chain.SecuringSouthportVeilZekk = 60509
Chain.EstablishingAxefallVeilZekk = 60510
Chain.SecuringSouthportTheAntidote = 60511
Chain.EstablishingAxefallTheAntidote = 60512
Chain.PinchwhistleGearworks = 60513
Chain.WhenTheRavenSwallowsTheDay = 60514

Database:AddChain(Chain.ShadowsGatherAlliance, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26023),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.ShadowsGatherHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        id = 34655,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35671,
    },
    items = {
        {
            type = "npc",
            id = 79539,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34655,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34656,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34657,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34658,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34659,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34756,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35636,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34805,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35668,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35671,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35274,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35276,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35286,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35611,
            aside = true,
            x = -1,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.ShadowsGatherHorde, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_HORDE, 26023),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.ShadowsGatherAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        id = 34655,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35671,
    },
    items = {
        {
            type = "npc",
            id = 79539,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34655,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34656,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34657,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34658,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34659,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34756,
            x = -2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35636,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34805,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35668,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35671,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35272,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35275,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35277,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35611,
            aside = true,
            x = -1,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.AdmiralTaylorsGarrisonAlliance, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26022),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.AdmiralTaylorsGarrisonHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 35286,
        },
    },
    active = {
        type = "quest",
        id = 35293,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35482,
    },
    items = {
        {
            type = "npc",
            id = 81949,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35293,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35329,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35339,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35353,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35380,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35407,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35408,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35482,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35549,
            aside = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36353,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.AdmiralTaylorsGarrisonHorde, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_HORDE, 26035),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.AdmiralTaylorsGarrisonAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 35277,
        },
    },
    active = {
        type = "quest",
        id = 35295,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 36183,
    },
    items = {
        {
            type = "npc",
            id = 81959,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35295,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35322,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35339,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35353,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35380,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35407,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35408,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36183,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35550,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SecretsOfTheTalonpriests, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26024),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 35611,
        },
    },
    active = {
        type = "quest",
        id = 34827,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34942,
    },
    items = {
        {
            type = "npc",
            id = 80153,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34827,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34829,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 34828,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36425,
            aside = true,
        },
        {
            type = "quest",
            id = 34830,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34882,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34883,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34942,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheGodsOfArak, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26025),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 35611,
        },
    },
    active = {
        type = "quest",
        id = 34998,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {35245, 35012},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 81770,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 81514,
            aside = true,
            x = -2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34998,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34999,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 35000,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35001,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 35002,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35004,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 35011,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 35003,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35013,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35012,
        },
        {
            type = "quest",
            id = 35245,
            x = -1,
        },
    },
})
Database:AddChain(Chain.LegacyOfTheApexis, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26027),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 35611,
        },
    },
    active = {
        type = "quest",
        ids = {35257, 35258, 35259, 35260},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35634,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 35257,
                    restrictions = {
                        type = "quest",
                        id = 35257,
                        status = {"active", "completed"},
                    },
                },
                {
                    type = "npc",
                    id = 80157,
                },
            },
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 80155,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35258,
            x = -2,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 35260,
            aside = true,
        },
        {
            type = "quest",
            id = 35259,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35261,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35273,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35634,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.TerokksLegend, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26028),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 35611,
        },
    },
    active = {
        type = "quest",
        id = 34884,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35896,
    },
    items = {
        {
            type = "npc",
            id = 81770,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34884,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.SecretsOfTheTalonpriests,
            x = -2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35733,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35734,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35897,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35245,
            x = 2,
            connections = {
                -1, 
            },
        },
        {
            type = "quest",
            id = 35895,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36059,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35896,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.SecuringSouthportVeilZekk, {
    name = L["SECURING_SOUTHPORT_VEIL_ZEKK"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.EstablishingAxefallVeilZekk,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            name = L["SMUGGLERS_DEN_BUILT"],
            type = "quest",
            id = 35284,
        },
    },
    active = {
        type = "quest",
        id = 35699,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35835,
    },
    items = {
        {
            type = "npc",
            id = 82709,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35699,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37296,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37331,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35713,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35878,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35716,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35719,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35739,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35782,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35835,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EstablishingAxefallVeilZekk, {
    name = L["ESTABLISHING_AXEFALL_VEIL_ZEKK"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.SecuringSouthportVeilZekk,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            name = L["SMUGGLERS_DEN_BUILT"],
            type = "quest",
            id = 35284,
        },
    },
    active = {
        type = "quest",
        id = 35697,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35797,
    },
    items = {
        {
            type = "npc",
            id = 82691,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35697,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37296,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37330,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35705,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35879,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35706,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35718,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35738,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35766,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35797,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SecuringSouthportTheAntidote, {
    name = L["SECURING_SOUTHPORT_THE_ANTIDOTE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.EstablishingAxefallTheAntidote,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            name = L["STOKTRON_BREWERY_BUILT"],
            type = "quest",
            id = 35283,
        },
    },
    active = {
        type = "quest",
        id = 34655,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 36165,
    },
    items = {
        {
            type = "npc",
            id = 81929,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37327,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37296,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37329,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35915,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35926,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35959,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36023,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36029,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36048,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36165,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37281,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EstablishingAxefallTheAntidote, {
    name = L["ESTABLISHING_AXEFALL_THE_ANTIDOTE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    alternatives = {
        Chain.SecuringSouthportTheAntidote,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            name = L["HEARTHFIRE_TAVERN_BUILT"],
            type = "quest",
            id = 35283,
        },
    },
    active = {
        type = "quest",
        id = 37326,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 36166,
    },
    items = {
        {
            type = "npc",
            id = 81920,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37326,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37296,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37328,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35907,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35924,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35947,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36022,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36028,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36047,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36166,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 37276,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PinchwhistleGearworks, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26030),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
    },
    active = {
        type = "quest",
        ids = {35077, 35079, 36179},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35298,
    },
    items = {
        {
            type = "npc",
            id = 81109,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 81128,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 85062,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35077,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35079,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36179,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35080,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 35081,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 35082,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35285,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 35089,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 35090,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36384,
            connections = {
                2, 3, 
            },
        },
        {
            type = "quest",
            id = 35091,
            x = -2,
            connections = {
                
            },
        },
        {
            type = "quest",
            id = 35211,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36428,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35298,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36062,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.WhenTheRavenSwallowsTheDay, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 26029),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {30,60},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 30,
        },
        {
            type = "quest",
            id = 35611,
        },
        {
            type = "chain",
            id = Chain.TheGodsOfArak,
        },
        {
            type = "chain",
            id = Chain.LegacyOfTheApexis,
        },
    },
    active = {
        type = "quest",
        id = 34921,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 35704,
    },
    items = {
        {
            type = "npc",
            id = 80648,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34921,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34991,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35010,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35007,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34922,
            x = -1,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 34923,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 34924,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34938,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34939,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 36790,
            aside = true,
        },
        {
            type = "quest",
            id = 35009,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36085,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35704,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 36316,
            aside = true,
            x = 0,
            connections = {
                
            },
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.ShadowsGatherAlliance,
        },
        {
            type = "chain",
            id = Chain.ShadowsGatherHorde,
        },
        {
            type = "chain",
            id = Chain.AdmiralTaylorsGarrisonAlliance,
        },
        {
            type = "chain",
            id = Chain.AdmiralTaylorsGarrisonHorde,
        },

        {
            type = "chain",
            id = Chain.SecretsOfTheTalonpriests,
        },
        {
            type = "chain",
            id = Chain.TheGodsOfArak,
        },
        {
            type = "chain",
            id = Chain.LegacyOfTheApexis,
        },
        {
            type = "chain",
            id = Chain.TerokksLegend,
        },
        {
            type = "chain",
            id = Chain.SecuringSouthportVeilZekk,
        },
        {
            type = "chain",
            id = Chain.EstablishingAxefallVeilZekk,
        },
        {
            type = "chain",
            id = Chain.SecuringSouthportTheAntidote,
        },
        {
            type = "chain",
            id = Chain.EstablishingAxefallTheAntidote,
        },
        {
            type = "chain",
            id = Chain.PinchwhistleGearworks,
        },
        {
            type = "chain",
            id = Chain.WhenTheRavenSwallowsTheDay,
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
