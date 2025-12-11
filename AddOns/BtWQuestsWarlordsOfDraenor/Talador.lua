--[[ 
    quest 33645, Tracking Quest - Iskar's Hired Hand, quest for when you are fooled by Iskar and get TPed?

    Second and third sections along with a lot of side quests require partial completion of the first section
    For armory its up to and including these quests: [Gas Guzzlers][Out of Jovite][Iridium Recovery] (Alliance, and probably Horde)
    For Mage tower its up to and including: [Next Steps] (Horde and Alliance)
]]
local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.WarlordsOfDraenor;
local CATEGORY_ID = BtWQuests.Constant.Category.WarlordsOfDraenor.Talador;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor.Talador;
local ALLIANCE_RESTRICTION, HORDE_RESTRICTION = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 535
local ACHIEVEMENT_ID_HORDE = 8919
local ACHIEVEMENT_ID_ALLIANCE = 8920
local CONTINENT_ID = 572

Chain.EstablishingYourMageTowerHorde = 60401
Chain.EstablishingYourArmoryHorde = 60402
Chain.TheBattleForShattrathHorde = 60403
Chain.ThePlightOfTheArakkoaHorde = 60404
Chain.InTheShadowsOfAuchindounHorde = 60405
Chain.EstablishingYourOutpostHorde = 60406

Chain.EstablishingYourMageTowerAlliance = 60411
Chain.EstablishingYourArmoryAlliance = 60412
Chain.TheBattleForShattrathAlliance = 60413
Chain.ThePlightOfTheArakkoaAlliance = 60414
Chain.InTheShadowsOfAuchindounAlliance = 60415
Chain.EstablishingYourOutpostAlliance = 60417

Database:AddChain(Chain.EstablishingYourMageTowerHorde, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_HORDE, 27689),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.EstablishingYourMageTowerAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        {
            type = "quest",
            id = 34566,
            status = {'active'},
            restrictions = {
                type = "quest",
                ids = {37301, 37302},
                status = {'notcompleted'},
            },
        },
        {
            type = "quest",
            id = 37302,
        },
    },
    completed = {
        type = "quest",
        id = 34712,
    },
    items = {
        {
            type = "npc",
            id = 79176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34566,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34632,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34814,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34634,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34635,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34636,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34874,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34878,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34879,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34887,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34888,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34889,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34890,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34712,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34949,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EstablishingYourArmoryHorde, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_HORDE, 27688),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.EstablishingYourArmoryAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        {
            type = "quest",
            id = 34566,
            status = {'active'},
            restrictions = {
                type = "quest",
                ids = {37301, 37302},
                status = {'notcompleted'},
            },
        },
        {
            type = "quest",
            id = 37301,
        },
    },
    completed = {
        type = "quest",
        id = 34971,
    },
    items = {
        {
            type = "npc",
            id = 79176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34566,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34569,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35102,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34577,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34576,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34579,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34837,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34840,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34860,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34858,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34855,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34870,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34971,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34972,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheBattleForShattrathHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.TheBattleForShattrathAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            variations = {
                {
                    type = "quest",
                    ids = {34576, 34577, 34579},
                    count = 3,
                    restrictions = {
                        type = "quest",
                        id = 37301,
                    },
                },
                {
                    type = "quest",
                    id = 34874,
                    restrictions = {
                        type = "quest",
                        id = 37302,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourOutpostHorde,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {33754, 33735, 33721, 33720},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33731,
    },
    items = {
        {
            type = "npc",
            id = 75806,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 75808,
            x = 0,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 75873,
            x = 2,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 33754,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "quest",
            id = 33735,
            connections = {
                7, 
            },
        },
        {
            type = "object",
            id = 225726,
            x = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 33722,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35226,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33721,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 33720,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34950,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33736,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33724,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33728,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33729,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33730,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34962,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 33731,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ThePlightOfTheArakkoaHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.ThePlightOfTheArakkoaAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            variations = {
                {
                    type = "quest",
                    ids = {34576, 34577, 34579},
                    count = 3,
                    restrictions = {
                        type = "quest",
                        id = 37301,
                    },
                },
                {
                    type = "quest",
                    id = 34874,
                    restrictions = {
                        type = "quest",
                        id = 37302,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourOutpostHorde,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {34685, 33740, 33578, 33761},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33582,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 34685,
                    restrictions = {
                        type = "quest",
                        id = 34685,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 75896,
                },
            },
            aside = true,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "npc",
            id = 75311,
            x = 1,
            connections = {
                4, 
            },
        },
        {
            type = "object",
            id = 225778,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 33740,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 33734,
            aside = true,
        },
        {
            type = "quest",
            id = 33578,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33761,
            aside = true,
        },
        {
            type = "quest",
            id = 33579,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 33580,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 33582,
        },
        {
            type = "quest",
            id = 33581,
            aside = true,
        },
    },
})
Database:AddChain(Chain.InTheShadowsOfAuchindounHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.InTheShadowsOfAuchindounAlliance,
    },
    restrictions = HORDE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            variations = {
                {
                    type = "chain",
                    id = Chain.EstablishingYourArmoryHorde,
                    restrictions = {
                        type = "quest",
                        id = 37301,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourMageTowerHorde,
                    restrictions = {
                        type = "quest",
                        id = 37302,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourOutpostHorde,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {34696, 34418, 33917, 33920, 35249},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34564,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 34696,
                    restrictions = {
                        type = "quest",
                        id = 34696,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 75121,
                },
            },
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 78482,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 78519,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 78577,
            connections = {
                4, 
            },
        },


        {
            type = "quest",
            id = 34418,
            x = -3,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 33917,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 33920,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 35249,
            connections = {
                1, 2, 
            },
        },


        {
            type = "quest",
            id = 34351,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33530,
            connections = {
                1, 
            },
        },

        
        {
            type = "quest",
            id = 34451,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 33972,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33970,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33971,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34242,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 34234,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 33988,
            aside = true,
        },
        {
            type = "quest",
            id = 34508,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34013,
            aside = true,
        },
        {
            type = "quest",
            id = 33976,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34326,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34092,
            x = -1,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 34122,
            aside = true,
        },
        {
            type = "quest",
            id = 34144,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 34157,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34163,
            aside = true,
        },
        {
            type = "quest",
            id = 34164,
            aside = true,
        },
        {
            type = "quest",
            id = 34564,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 36512,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 34706,
            aside = true,
        },
    },
})
Database:AddChain(Chain.EstablishingYourOutpostHorde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_HORDE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    completed = {
        type = "quest",
        ids = {34712, 34971},
    },
    items = {
        {
            type = "chain",
            id = Chain.EstablishingYourMageTowerHorde,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EstablishingYourArmoryHorde,
            embed = true,
        },
    },
})

Database:AddChain(Chain.EstablishingYourMageTowerAlliance, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 27691),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.EstablishingYourMageTowerHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        {
            type = "quest",
            id = 34558,
            status = {'active'},
            restrictions = {
                type = "quest",
                ids = {37301, 37302},
                status = {'notcompleted'},
            },
        },
        {
            type = "quest",
            id = 37302,
        },
    },
    completed = {
        type = "quest",
        id = 34711,
    },
    items = {
        {
            type = "npc",
            id = 79133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34558,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34631,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34815,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34609,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34612,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34619,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34875,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34908,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34913,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34909,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34910,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34911,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34912,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34711,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34993,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EstablishingYourArmoryAlliance, {
    name = GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_ALLIANCE, 27690),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.EstablishingYourArmoryHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
    },
    active = {
        {
            type = "quest",
            id = 34558,
            status = {'active'},
            restrictions = {
                type = "quest",
                ids = {37301, 37302},
                status = {'notcompleted'},
            },
        },
        {
            type = "quest",
            id = 37301,
        },
    },
    completed = {
        type = "quest",
        id = 34981,
    },
    items = {
        {
            type = "npc",
            id = 79133,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34558,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34563,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 35045,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34571,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34573,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34624,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34578,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34976,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 34977,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34978,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34979,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34980,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34981,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34982,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.TheBattleForShattrathAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 2),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.TheBattleForShattrathHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            variations = {
                {
                    type = "quest",
                    ids = {34571, 34573, 34624},
                    count = 3,
                    restrictions = {
                        type = "quest",
                        id = 37301,
                    },
                },
                {
                    type = "quest",
                    id = 34875,
                    restrictions = {
                        type = "quest",
                        id = 37302,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourOutpostAlliance,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {34087},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34099,
    },
    items = {
        {
            type = "npc",
            id = 75803,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34087,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 34089,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34090,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34091,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34088,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34095,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34094,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34959,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34096,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34097,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34098,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34963,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34099,
            x = 0,
            connections = {
                
            },
        },
    },
})
Database:AddChain(Chain.ThePlightOfTheArakkoaAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 3),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.ThePlightOfTheArakkoaHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            variations = {
                {
                    type = "quest",
                    ids = {34571, 34573, 34624},
                    count = 3,
                    restrictions = {
                        type = "quest",
                        id = 37301,
                    },
                },
                {
                    type = "quest",
                    id = 34875,
                    restrictions = {
                        type = "quest",
                        id = 37302,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourOutpostAlliance,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {34685, 33740, 33734, 33578, 33761},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 33582,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 34685,
                    restrictions = {
                        type = "quest",
                        id = 34685,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 75896,
                },
            },
            aside = true,
            x = -2,
            connections = {
                3, 4, 
            },
        },
        {
            type = "npc",
            id = 75311,
            x = 1,
            connections = {
                4, 
            },
        },
        {
            type = "object",
            id = 225778,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 33740,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 33734,
            aside = true,
        },
        {
            type = "quest",
            id = 33578,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33761,
            aside = true,
        },
        {
            type = "quest",
            id = 33579,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 33580,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 33582,
        },
        {
            type = "quest",
            id = 33581,
            aside = true,
        },
    },
})
Database:AddChain(Chain.InTheShadowsOfAuchindounAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 4),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    alternatives = {
        Chain.InTheShadowsOfAuchindounHorde,
    },
    restrictions = ALLIANCE_RESTRICTION,
    prerequisites = {
        {
            type = "level",
            level = 20,
        },
        {
            variations = {
                {
                    type = "chain",
                    id = Chain.EstablishingYourArmoryAlliance,
                    restrictions = {
                        type = "quest",
                        id = 37301,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourMageTowerAlliance,
                    restrictions = {
                        type = "quest",
                        id = 37302,
                    },
                },
                {
                    type = "chain",
                    id = Chain.EstablishingYourOutpostAlliance,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {34407, 33917, 33920, 34458},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 34154,
    },
    items = {
        {
            type = "npc",
            id = 81789,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 78482,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 78519,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 78577,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34407,
            x = -3,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 33917,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 33920,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 34458,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 33530,
            x = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34351,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34452,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 33969,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 33958,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 33967,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34240,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 34234,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 33988,
            aside = true,
        },
        {
            type = "quest",
            id = 34508,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 34013,
            aside = true,
        },
        {
            type = "quest",
            id = 33976,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 34326,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 34092,
            x = -1,
            connections = {
                2, 3, 4, 5, 
            },
        },
        {
            type = "quest",
            id = 35227,
            aside = true,
        },
        {
            type = "quest",
            id = 34144,
            aside = true,
            x = -3,
        },
        {
            type = "quest",
            id = 34157,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 34163,
            aside = true,
        },
        {
            type = "quest",
            id = 34164,
            aside = true,
        },
        {
            type = "quest",
            id = 34154,
            x = -1,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 36512,
            aside = true,
            x = -2,
        },
        {
            type = "quest",
            id = 34707,
            aside = true,
        },
    },
})
Database:AddChain(Chain.EstablishingYourOutpostAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_ALLIANCE, 1),
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = {20, 60},
    major = true,
    items = {
        {
            type = "chain",
            id = Chain.EstablishingYourMageTowerAlliance,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EstablishingYourArmoryAlliance,
            embed = true,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    items = {
        {
            type = "chain",
            id = Chain.EstablishingYourMageTowerHorde,
        },
        {
            type = "chain",
            id = Chain.EstablishingYourArmoryHorde,
        },
        {
            type = "chain",
            id = Chain.TheBattleForShattrathHorde,
        },
        {
            type = "chain",
            id = Chain.ThePlightOfTheArakkoaHorde,
        },
        {
            type = "chain",
            id = Chain.InTheShadowsOfAuchindounHorde,
        },

        {
            type = "chain",
            id = Chain.EstablishingYourMageTowerAlliance,
        },
        {
            type = "chain",
            id = Chain.EstablishingYourArmoryAlliance,
        },
        {
            type = "chain",
            id = Chain.TheBattleForShattrathAlliance,
        },
        {
            type = "chain",
            id = Chain.ThePlightOfTheArakkoaAlliance,
        },
        {
            type = "chain",
            id = Chain.InTheShadowsOfAuchindounAlliance,
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
