--[[
    This zone is a little disjointed, there are some optional quest chains that most
    will do in the logical progression of the zone but can be skipped if you know where to go.
    There are others that would seem to be optional and have no requirements but are actually needed
    to complete the zone.

    The first 4 quest chains are the main story of the zone, and have no requirements outside of themselves.

    Cycle of Hatred requires the The Battle for Brennadam, when finishing The Battle for Brennadam you'll
    be sent to Survivors which in turn will send you to Cycle of Hatred but its possible to just skip
    Survivors and go right to Cycle of Hatred. Survivors also doesnt require The Battle for Brennadam
    Its probably worth checking what happens if you complete The Battle for Brennadam after completing Survivors
    Survivors will also lead people to Treasure in Deadwash

    The Battle for Brennadam leads people to 3 chains, Survivors as mentioned before, Burton Farmstead which
    requires The Battle for Brennadam although the breadcrumb between the 2 isnt requires and lastly
    Goldfield Farmstead which doesnt require The Battle for Brennadam. It would seem that
    The Battle for Brennadam, Burton Farmstead, and Goldfield Farmstead are all required for Briarback Kraul

    From the Depths They Come has no requirements but has breadcrumbs from Brennadam (The place not the quest line)
    which I'm not what causes it to appear and Cycle of Hatred

    Treasure in Deadwash has no requirements but does have breadcrumbs from Survivors and From the Depths They Come

    Deadliest Cache, Circle the Wagons, I like Turtles, Mayhem at Mildenhall Meadery, and Houndmaster Archibald all seem to have
    no requirements. Deadliest Cache, I like Turtles, and Mayhem at Mildenhall Meadery seem to have breadcrumb that lead to them
]]

local L = BtWQuests.L;
local MAP_ID = 942
local ACHIEVEMENT_ID = 12496
local CONTINENT_ID = 876

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_TIDESAGES_OF_STORMSONG, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 1)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
    },
    active = {
        {
            type = "quest",
            id = 47962,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51401,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                535860, 561140, 586400, 611680, 636940, 662220, 687500, 712760, 738040, 763300, 788580, 813380, 838180, 863000, 887800, 912600, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                15600, 16050, 16450, 16900, 17350, 17750, 18200, 18650, 19050, 19500, 20000, 20400, 20800, 21350, 21700, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 575,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 47962,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47952,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51487,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51488,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51489,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51490,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51401,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_A_HOUSE_IN_PERIL,
            aside = true,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_A_HOUSE_IN_PERIL, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 2)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_TIDESAGES_OF_STORMSONG,
        },
    },
    completed = {
        type = "quest",
        id = 49997,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2143440, 2244530, 2345615, 2446705, 2547790, 2648880, 2749970, 2851055, 2952145, 3053230, 3154320, 3253535, 3352750, 3451970, 3551185, 3650400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                64200, 66025, 67725, 69550, 71375, 73075, 74900, 76725, 78425, 80250, 82225, 84175, 85600, 87725, 89525, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 125,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 1985,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_TIDESAGES_OF_STORMSONG,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49725,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49703,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 49704,
            x = 1,
            y = 3,
            connections = {
                3, 4, 5, 6,
            },
        },
        {
            type = "quest",
            id = 49705,
            x = 3,
            y = 3,
            connections = {
                2, 3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 49706,
            x = 5,
            y = 3,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 49791,
            x = 0,
            y = 4,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 49793,
            x = 2,
            y = 4,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 49794,
            x = 4,
            y = 4,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 49887,
            x = 6,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49792,
            x = 6,
            y = 5,
            connections = {
                2, 
            },
        },
        
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN6,
            aside = true,
            relationship = {
                breadcrumb = 51582,
                blocker = 50343,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 1,
            y = 6,
        },
        {
            type = "quest",
            id = 49975,
            x = 3,
            y = 6,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN1,
            aside = true,
            x = 5,
            y = 6,
        },


        {
            type = "quest",
            id = 49995,
            x = 1,
            y = 7,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49996,
            x = 3,
            y = 7,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50139,
            x = 5,
            y = 7,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49997,
            x = 3,
            y = 8,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_GROWING_TEMPEST,
            aside = true,
            x = 3,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_GROWING_TEMPEST, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 3)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_TIDESAGES_OF_STORMSONG,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_A_HOUSE_IN_PERIL,
        },
    },
    completed = {
        type = "quest",
        id = 50611,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                30000, 30850, 31650, 32500, 33350, 34150, 35000, 35850, 36650, 37500, 38400, 39350, 40000, 41000, 41850, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 785,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_A_HOUSE_IN_PERIL,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49998,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50594,
            x = 1,
            y = 2,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 50595,
            x = 3,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            ids = {50593, 50694},
            x = 5,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50608,
            x = 1,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50609,
            x = 3,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50610,
            x = 5,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50611,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_AT_THE_EDGE_OF_MADNESS,
            aside = true,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_AT_THE_EDGE_OF_MADNESS, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 4)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_TIDESAGES_OF_STORMSONG,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_A_HOUSE_IN_PERIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_GROWING_TEMPEST,
        },
    },
    completed = {
        type = "quest",
        id = 50824,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1391740, 1402040, 1412340, 1422640, 1432940, 1443240, 1453540, 1463840, 1474140, 1484440, 1494740, 1505040, 1515340, 1525640, 1535940, 1546240, 1556540, 1566840, 1577140, 1587440, 1597740, 1610700, 1623660, 1636620, 1649580, 1662540, 2304290, 2409265, 2514240, 2619215, 2724190, 2829170, 2934145, 3039120, 3144095, 3249070, 3352595, 3455625, 3558660, 3661695, 3752005, 959400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                73600, 73900, 74200, 74400, 74700, 75000, 75300, 75500, 75800, 76100, 76300, 76600, 76900, 77100, 77400, 77700, 78000, 78200, 78500, 78800, 79000, 79300, 79600, 79800, 80100, 80400, 82650, 84700, 87100, 89350, 91550, 93800, 96050, 98250, 100500, 103000, 105300, 107200, 109800, 112000, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 675,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 1605,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_GROWING_TEMPEST,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50612,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50777,
            x = 0,
            y = 2,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 50778,
            x = 2,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50780,
            x = 4,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50779,
            aside = true,
            x = 6,
            y = 2,
        },
        {
            type = "quest",
            id = 50783,
            x = 2,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50784,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50781,
            x = 3,
            y = 5,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51278,
            x = 2,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51320,
            x = 4,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51319,
            x = 3,
            y = 7,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {50824, 51845, 51846},
            x = 3,
            y = 8,
            connections = {
                1,  2,
            },
        },
        {
            type = "quest",
            id = 50825,
            aside = true,
            x = 2,
            y = 9,
        },
        {
            type = "quest",
            id = 50733,
            x = 4,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CYCLE_OF_HATRED, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 5)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN1,
        },
    },
    completed = {
        type = "quest",
        id = 51712,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                42000, 43200, 44300, 45500, 46700, 47800, 49000, 50200, 51300, 52500, 53850, 55050, 56000, 57350, 58550, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 600,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 138924,
            -- name = "Go to Holger Nash",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1182, 0.663832, 0.384946, "Holger Nash")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 0,
            y = 0,
            connections = {
                3,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 52065,
                    restrictions = {
                        type = "quest",
                        id = 52065,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 138735,
                    -- name = "Go to Felecia Gladstone",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.468851, 0.476818, "Felecia Gladstone")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "kill",
            id = 138521,
            -- name = "Kill a Mine Technician",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1182, 0.365926, 0.187975, "Mine Technician")
            -- end,
            -- breadcrumb = true,
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },
        -- {
        --     type = "quest",
        --     id = 52876,
        --     x = 6,
        --     y = 0,
        -- },

        {
            type = "quest",
            id = 51726,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 51711,
            x = 2,
            y = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 51752,
            x = 4,
            y = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 51881,
            x = 6,
            y = 1,
            connections = {
                3, 
            },
        },


        {
            type = "quest",
            id = 51723,
            x = 1,
            y = 2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 51720,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51728,
            x = 5,
            y = 2,
            connections = {
                1, 
            },
        },


        {
            type = "quest",
            id = 51712,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_FROM_THE_DEPTHS_THEY_COME,
            aside = true,
            visible = {
                {
                    type = "quest",
                    id = 50614,
                    restrictions = {
                        type = "quest",
                        id = 52070,
                        status = {'notcompleted'}
                    },
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 50614,
                    restrictions = {
                        type = "quest",
                        id = 52070,
                        status = {'notcompleted'}
                    },
                    status = {'notcompleted'}
                }
            },
            active = {
                type = "quest",
                id = 52070,
                status = {'active', 'completed'},
            },
            x = 3,
            y = 4,
        },
    },
})
-- No prerequisites
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_FROM_THE_DEPTHS_THEY_COME, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 6)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 49818,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52070,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50621,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50616,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50614,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 49831,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2109090, 2208560, 2308025, 2407495, 2506960, 2606430, 2705900, 2805365, 2904835, 3004300, 3103770, 3201395, 3299020, 3396650, 3494275, 3591900, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                70200, 72375, 73875, 76050, 78225, 79725, 81900, 84075, 85575, 87750, 89975, 92075, 93600, 95825, 97925, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 1125,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 131002,
            -- name = "Go to Lieutenant Bauer",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.301586, 0.591988, "Lieutenant Bauer")
            -- end,
            -- breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 49818,
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 52070,
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 49818,
                    status = {'notcompleted'}
                },
                {
                    type = "quest",
                    id = 52070,
                    status = {'notcompleted'}
                },
            },
            x = 3,
            y = 0,
            connections = {
                3, 4, 5,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 49818,
                    restrictions = {
                        type = "quest",
                        id = 49818,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "npc",
                    id = 131002,
                    -- name = "Go to Lieutenant Bauer",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.301586, 0.591988, "Lieutenant Bauer")
                    -- end,
                    -- breadcrumb = true,
                    visible = {
                        type = "quest",
                        ids = {49818, 52070},
                        status = {'active', 'completed'}
                    },
                },
            },
            visible = {
                type = "quest",
                ids = {49818, 52070},
                status = {'active', 'completed'}
            },
            x = 2,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 52070,
                    restrictions = {
                        type = "quest",
                        id = 52070,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "npc",
                    id = 131002,
                    -- name = "Go to Lieutenant Bauer",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.301586, 0.591988, "Lieutenant Bauer")
                    -- end,
                    -- breadcrumb = true,
                    visible = {
                        type = "quest",
                        ids = {49818, 52070},
                        status = {'active', 'completed'}
                    },
                },
            },
            x = 5,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50621,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50616,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50614,
            x = 5,
            y = 1,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 50635,
            x = 3,
            y = 2,
            connections = {
                2, 3, 4, 5,
            },
        },
        
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN8,
            aside = true,
            relationship = {
                breadcrumb = 49832,
                blockers = {51343, 50797},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 6,
            y = 2,
        },
        {
            type = "quest",
            id = 50644,
            x = 0,
            y = 3,
            connections = {
                4, 5, 6,
            },
        },
        {
            type = "quest",
            id = 50653,
            x = 2,
            y = 3,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 50645,
            aside = true,
            x = 4,
            y = 3,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 50649,
            aside = true,
            x = 6,
            y = 3,
            connections = {
                4,
            },
        },


        {
            type = "quest",
            id = 50672,
            x = 0,
            y = 4,
            connections = {
                4, 5,
            },
        },
        {
            type = "quest",
            id = 50679,
            x = 2,
            y = 4,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 50698,
            x = 4,
            y = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 50773,
            aside = true,
            x = 6,
            y = 4,
        },


        {
            type = "quest",
            id = 50705,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50706,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49831,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN12,
            aside = true,
            visible = {
                {
                    type = "quest",
                    id = 50376,
                    restrictions = {
                        type = "quest",
                        id = 53045,
                        status = {'notcompleted'}
                    },
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 50376,
                    restrictions = {
                        type = "quest",
                        id = 53045,
                        status = {'notcompleted'}
                    },
                    status = {'notcompleted'}
                }
            },
            active = {
                type = "quest",
                id = 53045,
                status = {'active', 'completed'}
            },
            x = 1,
            y = 7,
        },
        {
            type = "quest",
            id = 49908,
            aside = true,
            x = 3,
            y = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_TREASURE_IN_DEADWASH,
            aside = true,
            relationship = {
                breadcrumb = 52069,
                blocker = 50810,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 5,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_BRIARBACK_KRAUL, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 7)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN3,
        },
    },
    completed = {
        type = "quest",
        id = 50640,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1387740, 1453190, 1518635, 1584085, 1649530, 1714980, 1780430, 1845875, 1911325, 1976770, 2042220, 2106455, 2170690, 2234930, 2299165, 2363400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                45000, 46375, 47375, 48750, 50125, 51125, 52500, 53875, 54875, 56250, 57675, 59025, 60000, 61425, 62775, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 150,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 535,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 282457,
            -- name = "Go to the Brambleguard Totem",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.440473, 0.724700, "Brambleguard Totem")
            -- end,
            -- breadcrumb = true,
            x = 0,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50622,
            x = 3,
            y = 1,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 50111,
            x = 0,
            y = 2,
        },
        {
            type = "quest",
            id = 50353,
            x = 2,
            y = 2,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 50354,
            x = 4,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 50367,
            x = 6,
            y = 2,
            connections = {
                4, 
            },
        },


        {
            type = "quest",
            id = 50363,
            x = 1,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50365,
            x = 3,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50340,
            x = 5,
            y = 3,
        },


        {
            type = "quest",
            id = 50368,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50640,
            x = 3,
            y = 5,
            connections = {
            },
        },
    },
})
-- Completed, Alliance Only
--  breadcrumb from BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_FROM_THE_DEPTHS_THEY_COME ([52069] More Fodder)
--  breadcrumb from BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN7 ([51554] Reloading)
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_TREASURE_IN_DEADWASH, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 8)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 52069,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51554,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50802,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50674,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50810,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51140,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2445720, 2561070, 2676405, 2791755, 2907090, 3022440, 3137790, 3253125, 3368475, 3483810, 3599160, 3712365, 3825570, 3938790, 4051995, 4165200, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                75000, 77225, 79025, 81250, 83475, 85275, 87500, 89725, 91525, 93750, 96125, 98325, 100000, 102425, 104575, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 150,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 1295,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 52069,
                    restrictions = {
                        type = "quest",
                        id = 52069,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "quest",
                    id = 51554,
                    restrictions = {
                        type = "quest",
                        id = 51554,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 134720,
                    -- name = "Go to Leo Shealds",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(942, 0.429716, 0.565976, "Leo Shealds")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50802,
            x = 1,
            y = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50674,
            x = 3,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50810,
            x = 5,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50675,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },

        {
            type = "quest",
            id = 50691,
            x = 0,
            y = 3,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 50704,
            x = 2,
            y = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 50696,
            x = 4,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50697,
            x = 6,
            y = 3,
            connections = {
                2, 
            },
        },
        
        {
            type = "quest",
            id = 50814,
            aside = true,
            x = 0,
            y = 4,
        },
        {
            type = "quest",
            id = 50741,
            aside = true,
            x = 3,
            y = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 51140,
            x = 6,
            y = 4,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN8,
            aside = true,
            relationship = {
                breadcrumb = 50797,
                blockers = {51343, 49832},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 1,
            y = 5,
        },
        {
            type = "quest",
            id = 50753,
            aside = true,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50774,
            aside = true,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50793,
            aside = true,
            x = 3,
            y = 7,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 50803,
            aside = true,
            x = 0,
            y = 8,
            connections = {
            },
        },
        {
            type = "quest",
            id = 50955,
            aside = true,
            x = 2,
            y = 8,
            connections = {
            },
        },
        {
            type = "quest",
            id = 52132,
            aside = true,
            x = 4,
            y = 8,
            connections = {
            },
        },
        {
            type = "quest",
            id = 50742,
            aside = true,
            x = 6,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50956,
            aside = true,
            x = 3,
            y = 9,
        },
    },
})
-- Completed, Alliance only, optional, doesnt have any requirements and leads to nothing
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN5, {
    name = { -- Circle the Wagons
        type = "quest",
        id = 52793,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 52796,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52793,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52795,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 52796,
        },
        {
            type = "quest",
            id = 52793,
        },
        {
            type = "quest",
            id = 52795,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                13200, 13550, 13950, 14300, 14650, 15050, 15400, 15750, 16150, 16500, 16900, 17250, 17600, 18000, 18350, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 200,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 141769,
            -- name = "Go to Marilyn Hood",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.601840, 0.704933, "Marilyn Hood")
            -- end,
            -- breadcrumb = true,
            x = 2,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "npc",
            id = 141603,
            -- name = "Go to Mallory Hood",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.648863, 0.767777, "Mallory Hood")
            -- end,
            -- breadcrumb = true,
            x = 5,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52796,
            x = 1,
            y = 1,
        },
        {
            type = "quest",
            id = 52793,
            x = 3,
            y = 1,
        },
        {
            type = "quest",
            id = 52795,
            x = 5,
            y = 1,
        },
    },
})
-- Completed, Alliance Only, I think this chain and/or Burton Farmstead and/or Farmer Max lead to Briarback Kraul
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN3, {
    name = BtWQuests_GetAreaName(9422), -- Goldfield Farmstead
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50157,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50041,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50065,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50088,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                618300, 647460, 676620, 705780, 734940, 764100, 793260, 822420, 851580, 880740, 909900, 938520, 967140, 995760, 1024380, 1053000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                18000, 18500, 19000, 19500, 20000, 20500, 21000, 21500, 22000, 22500, 23050, 23600, 24000, 24600, 25100, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 235,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50157,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 129808,
                    -- name = "Go to Farmer Goldfield",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(942, 0.507566, 0.731545, "Farmer Goldfield")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 2,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "object",
            id = 244983,
            -- name = "Go to the Dirty Pocketwatch",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.498505, 0.735291, "Dirty Pocketwatch")
            -- end,
            -- breadcrumb = true,
            x = 4,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50041,
            x = 2,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50065,
            x = 4,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50069,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN2,
            aside = true,
            x = 1,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50088,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_BRIARBACK_KRAUL,
            aside = true,
            x = 2,
            y = 4,
        },
    },
})
-- Completed, alliance only, no breadcrumbs, no requirements
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN10, {
    name = {
        type = "npc",
        id = 137094,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 35,
            visible = false,
        },
        {
            name = L["BTWQUESTS_BEGIN_THE_BATTLE_FOR_BRENNADAM"],
            type = "quest",
            id = 51163,
        },
    },
    active = {
        {
            type = "quest",
            id = 51310,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51314,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 51310,
        },
        {
            type = "quest",
            id = 51314,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 150,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 137094,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51310,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 51314,
            x = 4,
            y = 1,
        },
    },
})
-- Completed, Alliance only, except updating the optional chains at the end
--  leads to BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN3 ([50157] There's Gold in Them There Fields)
--  leads to BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN2 ([50158] Checking Out the Collapse)
--  leads to BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN7 ([52067] Survivors)
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN1, {
    name = { -- The Battle for Brennadam
        type = "quest",
        id = 51534,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51552,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49744,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49745,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49746,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51534,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 49755,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                278800, 289100, 299400, 309700, 320000, 330300, 340600, 350900, 361200, 371500, 381800, 392100, 402400, 412700, 423000, 433300, 443600, 453900, 464200, 474500, 484800, 497760, 510720, 523680, 536640, 549600, 1125120, 1176960, 1228800, 1280640, 1332480, 1384320, 1436160, 1488000, 1539840, 1591680, 1643040, 1693920, 1744800, 1795680, 1833840, 936000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                24400, 24700, 25000, 25200, 25500, 25800, 26100, 26300, 26600, 26900, 27100, 27400, 27700, 27900, 28200, 28500, 28800, 29000, 29300, 29600, 29800, 30100, 30400, 30600, 30900, 31200, 32100, 32900, 33800, 34700, 35500, 36400, 37300, 38100, 39000, 40000, 40900, 41600, 42600, 43500, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 450,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 51552,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 130190,
                    -- name = "Sergeant Calvin",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.576072, 0.664058, "Sergeant Calvin")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 0,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 130694,
            -- name = "Go to Mayor Roz",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.576298, 0.664928, "Mayor Roz")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 49744,
            x = 0,
            y = 1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 49745,
            x = 2,
            y = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49746,
            x = 4,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51534,
            x = 6,
            y = 1,
        },

        {
            type = "quest",
            id = 49755,
            x = 2,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN3,
            aside = true,
            relationship = {
                breadcrumb = 50157,
                blocker = 50041,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 0,
            y = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN2,
            x = 2,
            y = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN7,
            aside = true,
            relationship = {
                breadcrumb = 52067,
                blockers = {50908, 50910, 50909},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 4,
            y = 3,
        },
    },
})
-- Both factions
-- level 120, no requirements
-- local forgottenCoveQuestLine = {}
-- local function IsActiveCompletedOrAvailableDelay(item)
--     return forgottenCoveQuestLine.questID == item.questID or BtWQuests_IsQuestActive(item.questID) or BtWQuests_IsQuestCompleted(item.questID)
-- end
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN4, {
    name = BtWQuests_GetAreaName(9955), -- Forgotten Cove
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
    },
    active = {
        {
            type = "quest",
            id = 50417,
            status = {'active', 'completed'}
        },
    },
    completed = {
        type = "quest",
        id = 53099,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2380800, 2393760, 2406720, 2419680, 2432640, 2445600, 2458560, 2471520, 2484480, 2497440, 2510400, 2523120, 2535840, 2548560, 2561280, 2574000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                6000, 6150, 6350, 6500, 6650, 6850, 7000, 7150, 7350, 7500, 7700, 7850, 8000, 8200, 8350, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 300,
        },
    },
    items = {
        {
            type = "quest",
            id = 50417,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50386,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53097,
            x = 3,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            name = L["WAIT_UNTIL_AVAILABLE"],
            visible = {
                type = "quest",
                id = 53097,
            },
            restrictions = {
                type = "quest",
                id = 50387,
                status = {'notcompleted'},
            },
            active = true,
            completed = {
                type = "questline",
                id = 577,
                mapID = MAP_ID,
                questID = 50387,
            },
            -- questID = 50387,
            -- completed = function (item)
            --     local questLines = C_QuestLine.GetAvailableQuestLines(MAP_ID)
            --     for _,questLine in ipairs(questLines) do
            --         if questLine.questLineID == 577 then
            --             forgottenCoveQuestLine = questLine
            --             break
            --         end
            --     end
            --     return IsActiveCompletedOrAvailableDelay(item)
            -- end,
            x = 5,
            y = 3.5,
            connections = {
                1, 
            },
        },
        { -- Unlocks either with 7th legion rep or doing Chasing Darness or azerite level(<= 14), or because Blizzard willed it so
            type = "quest",
            id = 50387,
            x = 3,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            name = L["WAIT_UNTIL_AVAILABLE"],
            visible = {
                type = "quest",
                id = 50387,
            },
            restrictions = {
                type = "quest",
                id = 50388,
                status = {'notcompleted'},
            },
            active = true,
            completed = {
                type = "questline",
                id = 577,
                mapID = MAP_ID,
                questID = 50388,
            },
            -- questID = 50388,
            -- completed = IsActiveCompletedOrAvailableDelay,
            x = 5,
            y = 4.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50388,
            x = 3,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            name = L["WAIT_UNTIL_AVAILABLE"],
            visible = {
                type = "quest",
                id = 50388,
            },
            restrictions = {
                type = "quest",
                id = 53105,
                status = {'notcompleted'},
            },
            active = true,
            completed = {
                type = "questline",
                id = 577,
                mapID = MAP_ID,
                questID = 53105,
            },
            -- questID = 53105,
            -- completed = IsActiveCompletedOrAvailableDelay,
            x = 5,
            y = 5.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53105,
            x = 3,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            name = L["WAIT_UNTIL_AVAILABLE"],
            visible = {
                type = "quest",
                id = 53105,
            },
            restrictions = {
                type = "quest",
                id = 50385,
                status = {'notcompleted'},
            },
            active = true,
            completed = {
                type = "questline",
                id = 577,
                mapID = MAP_ID,
                questID = 50385,
            },
            -- questID = 50385,
            -- completed = IsActiveCompletedOrAvailableDelay,
            x = 5,
            y = 6.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50385,
            x = 3,
            y = 7,
            connections = {
                2, 
            },
        },
        {
            name = L["WAIT_UNTIL_AVAILABLE"],
            visible = {
                type = "quest",
                id = 50385,
            },
            restrictions = {
                type = "quest",
                id = 50389,
                status = {'notcompleted'},
            },
            active = true,
            completed = {
                type = "questline",
                id = 577,
                mapID = MAP_ID,
                questID = 50389,
            },
            -- questID = 50389,
            -- completed = IsActiveCompletedOrAvailableDelay,
            x = 5,
            y = 7.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50389,
            x = 3,
            y = 8,
            connections = {
                2, 
            },
        },
        {
            name = L["WAIT_UNTIL_AVAILABLE"],
            visible = {
                type = "quest",
                id = 50389,
            },
            restrictions = {
                type = "quest",
                id = 53099,
                status = {'notcompleted'},
            },
            active = true,
            completed = {
                type = "questline",
                id = 577,
                mapID = MAP_ID,
                questID = 53099,
            },
            -- questID = 53099,
            -- completed = IsActiveCompletedOrAvailableDelay,
            x = 5,
            y = 8.5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 53099,
            x = 3,
            y = 9,
        },
    },
})
-- Completed, both factions, doesnt seem to have any requirements and doesnt seem to lead anywhere
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN8, {
    name = { -- I like Turtles
        type = "quest",
        id = 51427,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 50797,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49832,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51352,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51339,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51343,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51386,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1868640, 1956770, 2044895, 2133025, 2221150, 2309280, 2397410, 2485535, 2573665, 2661790, 2749920, 2836415, 2922910, 3009410, 3095905, 3182400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                54600, 56225, 57525, 59150, 60775, 62075, 63700, 65325, 66625, 68250, 69925, 71575, 72800, 74525, 76125, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 1010,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 1085,
        },
    },
    items = {
        {
            type = "npc",
            id = 135795,
            -- name = "Go to Toki",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.405925, 0.454583, "Toki")
            -- end,
            -- breadcrumb = true,
            x = 1,
            y = 0,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50797,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "quest",
                    id = 49832,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 135794,
                    -- name = "Go to Scrollsage Nola",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(942, 0.406770, 0.456041, "Scrollsage Nola")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 4,
            y = 0,
            connections = {
                2, 3,
            },
        },
        -- {
        --     type = "quest",
        --     id = 49832,
        --     x = 4,
        --     y = 0,
        --     connections = {
        --         1, 2, 3,
        --     }
        -- },
        {
            type = "quest",
            id = 51352,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51339,
            x = 3,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51343,
            x = 5,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53369,
            x = 2,
            y = 2,
            connections = {
            }
        },
        {
            type = "quest",
            id = 51353,
            x = 4,
            y = 2,
            connections = {
                1, 2, 3,
            }
        },
        
        {
            type = "quest",
            id = 51540,
            x = 1,
            y = 3,
            connections = {
                3,
            }
        },
        {
            type = "quest",
            id = 51371,
            x = 3,
            y = 3,
            connections = {
                3,
            }
        },
        {
            type = "quest",
            id = 51221,
            x = 5,
            y = 3,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 51545,
            x = 2,
            y = 4,
        },
        {
            type = "quest",
            id = 51427,
            x = 4,
            y = 4,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 51220,
            x = 2,
            y = 5,
        },
        {
            type = "quest",
            id = 51222,
            x = 4,
            y = 5,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 51386,
            x = 3,
            y = 6,
        },
    },
})
-- Completed, Alliance only, no requirements, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN9, {
    name = {
        type = "npc",
        id = 131656,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 35,
            visible = false,
        },
        {
            name = L["BTWQUESTS_BEGIN_THE_BATTLE_FOR_BRENNADAM"],
            type = "quest",
            id = 51163,
        },
    },
    active = {
        {
            type = "quest",
            id = 50797,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49960,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 49886,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 49960,
        },
        {
            type = "quest",
            id = 49886,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                412200, 431640, 451080, 470520, 489960, 509400, 528840, 548280, 567720, 587160, 606600, 625680, 644760, 663840, 682920, 702000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10800, 11100, 11400, 11700, 12000, 12300, 12600, 12900, 13200, 13500, 13850, 14150, 14400, 14750, 15050, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 150,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 131656,
            -- name = "Go to Houndmaster Archibald",
            -- onClick = function()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.510161, 0.701896, "Houndmaster Archibald")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49960,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 49886,
            x = 4,
            y = 1,
        },
    },
})
-- Completed, Alliance Only
-- requires [btwquests:chain:80615:ffffff00:The Battle for Brennadam]
-- Breadcrumb is optional but should most likely be completed
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN2, {
    name = BtWQuests_GetAreaName(9444), -- Burton Farmstead
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN1,
    },
    active = {
        {
            type = "quest",
            id = 50158,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50133,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50134,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50135,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50136,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                416200, 426500, 436800, 447100, 457400, 467700, 478000, 488300, 498600, 508900, 519200, 529500, 539800, 550100, 560400, 570700, 581000, 591300, 601600, 611900, 622200, 635160, 648120, 661080, 674040, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "experience",
            amounts = {
                17200, 17500, 17800, 18000, 18300, 18600, 18900, 19100, 19400, 19700, 19900, 20200, 20500, 20700, 21000, 21300, 21600, 21800, 22100, 22400, 22600, 22900, 23200, 23400, 23700, 24000, 24750, 25250, 26000, 26750, 27250, 28000, 28750, 29250, 30000, 30750, 31500, 32000, 32750, 33500, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 225,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50158,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 132118,
                    -- name = "Go to Farmer Burton",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(942, 0.515843, 0.659661, "Farmer Burton")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 0,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 50133,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 50134,
            x = 2,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50135,
            x = 4,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50136,
            x = 3,
            y = 2,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN3,
            aside = true,
            x = 5,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_BRIARBACK_KRAUL,
            aside = true,
            x = 4,
            y = 3,
        },
    },
})
-- Completed, Alliance only, make sure no requirements
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN12, {
    name = { -- Deadliest Cache
        type = "achievement",
        id = 13053,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 53045,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50376,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 52130,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                24000, 24600, 25400, 26000, 26600, 27400, 28000, 28600, 29400, 30000, 30800, 31400, 32000, 32800, 33400, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 600,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 53045,
                    restrictions = {
                        type = "quest",
                        id = 53045,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 133576,
                    -- name = "Go to Coxswain Hook",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.260037, 0.552169, "Coxswain Hook")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50376,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50391,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50418,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52130,
            x = 3,
            y = 4,
        },
    },
})
-- Completed, Alliance Only, no requirements, has 1 breadcrumb as an aside from BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_A_HOUSE_IN_PERIL
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN6, {
    name = { -- Mayhem at Mildenhall Meadery
        type = "quest",
        id = 50343,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51582,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50343,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 50553,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1813680, 1899220, 1984750, 2070290, 2155820, 2241360, 2326900, 2412430, 2497970, 2583500, 2669040, 2752990, 2836940, 2920900, 3004850, 3088800, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                56400, 58100, 59400, 61100, 62800, 64100, 65800, 67500, 68800, 70500, 72300, 73950, 75200, 77000, 78650, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 750,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 51582,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 131793,
                    -- name = "Go to Ancel Mildenhall",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(942, 0.688853, 0.651630, "Ancel Mildenhall")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50343,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50070,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50359,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50064,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50161,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50168,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50162,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50504,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 50165,
            x = 0,
            y = 7,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50534,
            x = 2,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50264,
            x = 4,
            y = 7,
        },
        {
            type = "quest",
            id = 50493,
            x = 6,
            y = 7,
        },
        {
            type = "quest",
            id = 50553,
            x = 3,
            y = 8,
        },
    },
})
-- Completed, Alliance Only, Optional
--  breadcrumb from BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN1 ([52067] Survivors)
--  leads to BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CYCLE_OF_HATRED ([52065] Worse Than It Looks)
--  leads to BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_TREASURE_IN_DEADWASH ([51554] Reloading)
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN7, {
    name = { -- Survivors
        type = "quest",
        id = 52067,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    active = {
        {
            type = "quest",
            id = 52065,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50908,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50910,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 50909,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51159,
            status = {'active', 'completed'},
        },
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    completed = {
        {
            type = "quest",
            id = 50908,
        },
        {
            type = "quest",
            id = 50910,
        },
        {
            type = "quest",
            id = 50909,
        },
        {
            type = "quest",
            id = 51159,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1112940, 1165430, 1217915, 1270405, 1322890, 1375380, 1427870, 1480355, 1532845, 1585330, 1637820, 1689335, 1740850, 1792370, 1843885, 1895400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                28200, 29025, 29725, 30550, 31375, 32075, 32900, 33725, 34425, 35250, 36125, 36925, 37600, 38475, 39275, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 165,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 625,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 52067,
            visible = {
                type = "quest",
                id = 52067,
                status = {'active', 'completed'}
            },
            x = 3,
            y = 0,
            connections = {
                4, 5, 6, 7,
            },
        },
        {
            type = "npc",
            id = 135682,
            -- name = "Go to Patrick Eckhart",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.578504, 0.553204, "Patrick Eckhart")
            -- end,
            -- breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 52067,
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 52067,
                    status = {'notcompleted'}
                },
            },
            x = 1,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "npc",
            id = 135874,
            -- name = "Go to Lea Martinel",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.579519, 0.555802, "Lea Martinel")
            -- end,
            -- breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 52067,
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 52067,
                    status = {'notcompleted'}
                },
            },
            x = 4,
            y = 0,
            connections = {
                4, 5,
            },
        },

        

        {
            type = "quest",
            id = 51217,
            aside = true,
            x = 6,
            y = 0,
        },


        {
            type = "quest",
            id = 50908,
            x = 0,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 50910,
            x = 2,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 50909,
            x = 4,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 51159,
            x = 6,
            y = 1,
        },

        
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CYCLE_OF_HATRED,
            aside = true,
            relationship = {
                breadcrumb = 52065,
                blockers = {51711, 51752},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 2,
            y = 2,
        },
        
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_TREASURE_IN_DEADWASH,
            aside = true,
            relationship = {
                breadcrumb = 51554,
                blockers = {50802, 50674, 50810},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 4,
            y = 2,
        },
    },
})
-- completed, alliance only, no requirements, 1 breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN11, {
    name = BtWQuests_GetAreaName(9402), -- Millstone Hamlet
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        {
            type = "quest",
            id = 51218,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51214,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51251,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51492,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51205,
            status = {'active', 'completed'},
        },
    },
    completed = {
        {
            type = "quest",
            id = 51208,
        },
        {
            type = "quest",
            id = 51209,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2074740, 2172590, 2270435, 2368285, 2466130, 2563980, 2661830, 2759675, 2857525, 2955370, 3053220, 3149255, 3245290, 3341330, 3437365, 3533400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                61800, 63625, 65125, 66950, 68775, 70275, 72100, 73925, 75425, 77250, 79225, 81025, 82400, 84375, 86175, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 165,
        },
        {
            type = "reputation",
            id = 2162,
            amount = 1225,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 51218,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 136658,
                    -- name = "Marie Davenport",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(942, 0.303383, 0.668032, "Marie Davenport")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 0,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 136574,
            -- name = "Go to Charles Davenport",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.297903, 0.671066, "Charles Davenport")
            -- end,
            -- breadcrumb = true,
            x = 4,
            y = 0,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 51214,
            x = 0,
            y = 1,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 51251,
            x = 2,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 51492,
            x = 4,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51205,
            x = 6,
            y = 1,
            connections = {
                2,
            },
        },

        {
            type = "object",
            id = 287958,
            -- name = "Go to the Bulletin Board",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.306864, 0.681406, "Bulletin Board")
            -- end,
            -- breadcrumb = true,
            x = 0,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51215,
            x = 2,
            y = 2.5,
            connections = {
                5,
            },
        },
        {
            type = "npc",
            id = 136414,
            -- name = "Go to Shepherd Milbrooke",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.318554, 0.695202, "Shepherd Milbrooke")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 5,
            y = 2,
            connections = {
                2, 3,
            },
        },

        {
            type = "quest",
            id = 51204,
            aside = true,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 51200,
            aside = true,
            x = 4,
            y = 3,
        },
        {
            type = "quest",
            id = 51203,
            aside = true,
            x = 6,
            y = 3,
        },


        {
            type = "quest",
            id = 51335,
            x = 2,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51207,
            x = 1,
            y = 5,
        },
        {
            type = "quest",
            id = 51504,
            x = 3,
            y = 5,
            connections = {
                1, 2,
            },
        },

        
        {
            type = "quest",
            id = 51208,
            x = 2,
            y = 6,
        },
        {
            type = "quest",
            id = 51209,
            x = 4,
            y = 6,
        },
    },
})
-- completed, horde only, no requirements, 1 breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN13, {
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {35,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = {
        type = "quest",
        id = 53330,
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 53330,
        },
        {
            type = "quest",
            id = 53348,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                13200, 13550, 13950, 14300, 14650, 15050, 15400, 15750, 16150, 16500, 16900, 17250, 17600, 18000, 18350, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 230,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 500,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "object",
            id = 297492,
            -- name = "Go to the Bulletin Board",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(942, 0.51, 0.336, "Bulletin Board")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53330,
            x = 2,
        },
        {
            type = "quest",
            id = 53348,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = false,
    items = {
        { -- Not sure where to put this
            type = "quest",
            id = 49730,
        },
        { -- Probably a breadcrumb to From the Depths They Come after the Treasure in Deadwash
            type = "quest",
            id = 52068,
        },
        {
            type = "quest",
            id = 52876,
        },
        {
            type = "quest",
            id = 53347,
        },
        {
            type = "quest",
            id = 53371,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = false,
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {1,50},
    prerequisites = {
        type = "level",
        level = 35,
        visible = false,
    },
    active = false,
    items = {
        {
            type = "quest",
            id = 51557,
        },
        {
            type = "quest",
            id = 50690,
        },
        {
            type = "quest",
            id = 50779,
        },
        {
            type = "quest",
            id = 51354,
        },
        {
            type = "quest",
            id = 52782,
        },
        {
            type = "quest",
            id = 53330,
        },
        {
            type = "quest",
            id = 53348,
        },
        {
            type = "quest",
            id = 50601,
        },
        {
            type = "quest",
            id = 50743,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2178271,
    listImage = {
        texture = "Interface\\Addons\\BtWQuestsBattleForAzeroth\\UI-CategoryButton",
        texCoords = {0, 0.7353515625, 0.3515625, 0.46875},
    },
    items = {
        {
            type = "header",
            name = L["BTWQUESTS_THE_WAR_CAMPAIGN"],
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_HORDE
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DEATH_OF_A_TIDESAGE,
        },

        
        {
            type = "header",
            name = {
                type = "achievement",
                id = ACHIEVEMENT_ID,
            },
            restrictions = {
                type = "faction",
                id = BTWQUESTS_FACTION_ID_ALLIANCE
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_TIDESAGES_OF_STORMSONG,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_A_HOUSE_IN_PERIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_THE_GROWING_TEMPEST,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_AT_THE_EDGE_OF_MADNESS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CYCLE_OF_HATRED,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_FROM_THE_DEPTHS_THEY_COME,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_BRIARBACK_KRAUL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_TREASURE_IN_DEADWASH,
        },


        {
            type = "header",
            name = L["BTWQUESTS_SIDE_QUESTS"],
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN4,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN6,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN9,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN11,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN12,
        },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_OTHER_ALLIANCE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_OTHER_BOTH,
        -- },
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN5,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN6,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN7,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN8,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN9,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN10,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN11,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN12,
    },
})