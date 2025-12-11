local L = BtWQuests.L;
local MAP_ID = 895
local CONTINENT_ID = 876
local ACHIEVEMENT_ID = 12473

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_ASHVANE_TRADING_COMPANY, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 1)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
    },
    active = {
        type = "quest",
        id = 47960,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 50531,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                10100, 36110, 62115, 88125, 114130, 140140, 166145, 192155, 218160, 244170, 270175, 296185, 322190, 348200, 374205, 400215, 426220, 452230, 478235, 504245, 530250, 562980, 595695, 628425, 661140, 693870, 726600, 759315, 792045, 824760, 857490, 890220, 922935, 955665, 988380, 1021110, 1053225, 1085340, 1117470, 1149585, 1181700, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                7190, 7950, 8680, 9240, 10000, 10730, 11490, 12050, 12780, 13590, 14150, 14910, 15640, 16200, 16960, 17690, 18450, 19010, 19740, 20500, 21075, 21775, 22550, 23125, 23825, 24600, 25375, 25875, 26650, 27425, 27925, 28700, 29475, 29975, 30750, 31525, 32225, 32800, 33575, 34275, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 675,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 47960,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47181,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47485,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },

        {
            type = "quest",
            id = 47488,
            x = 0,
            y = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 47486,
            x = 2,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 47487,
            x = 4,
            y = 3,
            connections = {
                2, 
            },
        },

        {
            type = "quest",
            id = 50573,
            x = 6,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50531,
            x = 3,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_FREEHOLD,
            aside = true,
            x = 3,
            y = 5,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_FREEHOLD, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 2)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_ASHVANE_TRADING_COMPANY,
        },
    },
    completed = {
        type = "quest",
        id = 49404,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                35700, 127630, 219555, 311485, 403410, 495340, 587265, 679195, 771120, 863050, 954975, 1046905, 1138830, 1230760, 1322685, 1414615, 1506540, 1598470, 1690395, 1782325, 1874250, 1989920, 2105585, 2221255, 2336920, 2452590, 2568260, 2683925, 2799595, 2915260, 3030930, 3146600, 3262265, 3377935, 3493600, 3609270, 3722795, 3836320, 3949850, 4063375, 4176900, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                25040, 27715, 30380, 32190, 34865, 37535, 40180, 42050, 44685, 47330, 49200, 51845, 54480, 56350, 58995, 61630, 64350, 66145, 68830, 71500, 73325, 75975, 78650, 80475, 83125, 85800, 88475, 90275, 92950, 95625, 97425, 100100, 102775, 104575, 107250, 109925, 112575, 114400, 117125, 119725, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 1735,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 281551,
            relationship = {
                breadcrumb = 50544,
                blockers = {48874, 48873},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            x = 0,
            y = 0,
            aside = true,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 133550,
            aside = true,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 134166,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 136576,
            aside = true,
            connections = {
                4,
            },
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN1,
            relationship = {
                breadcrumb = 50544,
                blockers = {48874, 48873},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 0,
            y = 1
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN2,
            relationship = {
                breadcrumb = 50349,
            },
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 53041,
            x = 4,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN3,
            relationship = {
                breadcrumb = 51149,
            },
            active = BtWQuestsItem_RelationshipSourceActive,
            aside = true,
            x = 6,
            y = 1,
        },

        {
            type = "quest",
            id = 47489,
            x = 4,
            y = 2,
            connections = {
                2, 
            },
        },

        {
            type = "npc",
            id = 126511,
            -- name = "Go to Skinner MacGuff",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.827264, 0.727482, "Skinner MacGuff")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 2,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48419,
            x = 4,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CASTAWAYS_AND_CUTOUTS,
            aside = true,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 48516,
            aside = true,
            x = 2,
            y = 4,
        },
        {
            type = "quest",
            id = 48505,
            x = 4,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48539,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3, 4, 5,
            },
        },
        
        {
            type = "quest",
            id = 48606,
            aside = true,
            x = 5,
            y = 5,
        },
        {
            type = "quest",
            id = 48774,
            aside = true,
            x = 0,
            y = 6,
        },
        {
            type = "quest",
            id = 48776,
            aside = true,
            x = 2,
            y = 6,
        },
        {
            type = "quest",
            id = 48773,
            x = 4,
            y = 6,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 48558,
            x = 6,
            y = 6,
            connections = {
                1, 2,
            },
        },
        
        {
            type = "quest",
            id = 49239,
            x = 3,
            y = 7,
            connections = {
                2, 3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN4,
            aside = true,
            x = 5,
            y = 7,
        },

        {
            type = "quest",
            id = 49401,
            x = 2,
            y = 8,
            connections = {
                2, 3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 49398,
            x = 4,
            y = 8,
            connections = {
                1, 2, 3, 4,
            },
        },


        {
            type = "quest",
            id = 49409,
            aside = true,
            x = 0,
            y = 9,
        },
        {
            type = "quest",
            id = 49399,
            x = 2,
            y = 9,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49400,
            aside = true,
            x = 4,
            y = 9,
        },
        {
            type = "quest",
            id = 49402,
            aside = true,
            x = 6,
            y = 9,
            connections = {
                2, 
            },
        },

        
        {
            type = "quest",
            id = 49404,
            x = 3,
            y = 10,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49403,
            aside = true,
            x = 6,
            y = 10,
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_DEFENDERS_OF_DAELINS_GATE,
            aside = true,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_DEFENDERS_OF_DAELINS_GATE, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 3)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_ASHVANE_TRADING_COMPANY,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_FREEHOLD,
        },
    },
    completed = {
        type = "quest",
        id = 49740,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                25700, 91880, 158055, 224235, 290410, 356590, 422765, 488945, 555120, 621300, 687475, 753655, 819830, 886010, 952185, 1018365, 1084540, 1150720, 1216895, 1283075, 1349250, 1432520, 1515785, 1599055, 1682320, 1765590, 1848860, 1932125, 2015395, 2098660, 2181930, 2265200, 2348465, 2431735, 2515000, 2598270, 2679995, 2761720, 2843450, 2925175, 2994180, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                16980, 18800, 20560, 21880, 23650, 25410, 27230, 28500, 30260, 32130, 33400, 35220, 36980, 38250, 40070, 41830, 43600, 44920, 46680, 48500, 49775, 51525, 53350, 54625, 56375, 58200, 59975, 61275, 63050, 64825, 66125, 67900, 69675, 70975, 72750, 74575, 76325, 77600, 79425, 81175, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1560,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 710,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 130159,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49405,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 52431,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49869,
            x = 3,
            y = 3,
            connections = {
                2, 3, 4, 5,
            },
        },
        {
            type = "npc",
            id = 131654,
            aside = true,
            x = 6,
            connections = {
                4,
            },
        },

        {
            type = "quest",
            id = 52787,
            aside = true,
            x = 0,
            y = 4,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 52750,
            x = 2,
            y = 4,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49737,
            x = 4,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49757,
            aside = true,
            x = 6,
            y = 4,
        },


        
        {
            type = "quest",
            id = 49738,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3, 4,
            },
        },

        {
            type = "quest",
            id = 49741,
            aside = true,
            x = 0,
            y = 6,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 49736,
            x = 2,
            y = 6,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49740,
            x = 4,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49739,
            aside = true,
            x = 6,
            y = 6,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_ENEMIES_WITHIN,
            aside = true,
            x = 2,
            y = 7,
        }
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_ENEMIES_WITHIN, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 4)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_ASHVANE_TRADING_COMPANY,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_FREEHOLD,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_DEFENDERS_OF_DAELINS_GATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_DEFENDERS_OF_DAELINS_GATE,
            upto = 49741,
        },
    },
    completed = {
        type = "quest",
        id = 50972,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                22200, 79365, 136530, 193695, 250860, 308025, 365190, 422355, 479520, 536685, 593850, 651015, 708180, 765345, 822510, 879675, 936840, 994005, 1051170, 1108335, 1165500, 1237430, 1309355, 1381285, 1453210, 1525140, 1597070, 1668995, 1740925, 1812850, 1884780, 1956710, 2028635, 2100565, 2172490, 2244420, 2315015, 2385610, 2456210, 2526805, 2597400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                16080, 17650, 19160, 20680, 22200, 23860, 25430, 26750, 28410, 29980, 31450, 33020, 34530, 36000, 37570, 39230, 40750, 42120, 43780, 45350, 46825, 48325, 49900, 51375, 52875, 54600, 56125, 57475, 59150, 60675, 62175, 63700, 65225, 66725, 68250, 69975, 71475, 72800, 74525, 76025, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 600,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 1060,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 142393,
            locations = {
                [895] = {
                    {
                        x = 0.565062,
                        y = 0.612504,
                    },
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
            id = 50110,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50795,
            x = 3,
            y = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50787,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 50788,
            x = 2,
            y = 4,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 50789,
            x = 4,
            y = 4,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50790,
            x = 3,
            y = 5,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            ids = {50972, 51825, 51826},
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52800,
            aside = true,
            x = 3,
            y = 7,
        },
    },
})
-- Completed, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_SHADOW_OVER_ANGLEPOINT, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 5)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {48347, 48540},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 49302,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                57000, 203775, 350550, 497325, 644100, 790875, 937650, 1084425, 1231200, 1377975, 1524750, 1671525, 1818300, 1965075, 2111850, 2258625, 2405400, 2552175, 2698950, 2845725, 2992500, 3177180, 3361860, 3546540, 3731220, 3915900, 4100580, 4285260, 4469940, 4654620, 4839300, 5023980, 5208660, 5393340, 5578020, 5762700, 5943960, 6125220, 6306480, 6487740, 6643560, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                34700, 38425, 42000, 44750, 48325, 51900, 55600, 58250, 61800, 65500, 68150, 71850, 75400, 78050, 81750, 85300, 88900, 91650, 95250, 98950, 101600, 105200, 108900, 111500, 115100, 118800, 122350, 125150, 128700, 132250, 135050, 138600, 142150, 144950, 148500, 152200, 155800, 158400, 162150, 165700, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 190,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 1420,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 48347,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 125922,
                    -- name = "Go to Brother Therold",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.422778, 0.293083, "Brother Therold")
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
            id = 48540,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 48348,
            x = 1,
            y = 2,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 48352,
            x = 3,
            y = 2,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 49268,
            x = 5,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48353,
            x = 2,
            y = 3,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 49292,
            x = 4,
            y = 3,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 51384,
            aside = true,
            x = 6,
            y = 3,
        },

        {
            type = "quest",
            id = 48354,
            x = 2,
            y = 4,
            connections = {
                2, 3, 4, 5, 6,
            },
        },
        {
            type = "quest",
            id = 48355,
            x = 4,
            y = 4,
            connections = {
                1, 2, 3, 4, 5,
            },
        },

        {
            type = "quest",
            id = 48356,
            x = 1,
            y = 5,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 48365,
            x = 3,
            y = 5,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 48009,
            x = 5,
            y = 5,
            connections = {
                3, 
            },
        },

        {
            type = "quest",
            id = 48008,
            x = 2,
            y = 6,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49299,
            x = 4,
            y = 6,
            connections = {
                1, 
            },
        },


        {
            type = "quest",
            id = 48366,
            x = 3,
            y = 7,
            connections = {
                1, 2, 3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 48367,
            x = 0,
            y = 8,
            connections = {
                6, 
            },
        },
        {
            type = "quest",
            id = 48368,
            x = 2,
            y = 8,
            connections = {
                5, 
            },
        },
        {
            type = "quest",
            id = 49300,
            x = 4,
            y = 8,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 48370,
            x = 6,
            y = 8,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 48372,
            x = 3,
            y = 9,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49300,
            x = 6,
            y = 9,
        },
        {
            type = "quest",
            id = 49302,
            x = 3,
            y = 10,
            connections = {
                1, 
            },
        },
    },
})
-- Completed, no requirements, 2 breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_NORWINGTON_ESTATE, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 6)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {51199, 48070, 48077, 48080, 48616},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 48089,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                43200, 154440, 265680, 376920, 488160, 599400, 710640, 821880, 933120, 1044360, 1155600, 1266840, 1378080, 1489320, 1600560, 1711800, 1823040, 1934280, 2045520, 2156760, 2268000, 2407970, 2547935, 2687905, 2827870, 2967840, 3107810, 3247775, 3387745, 3527710, 3667680, 3807650, 3947615, 4087585, 4227550, 4367520, 4504895, 4642270, 4779650, 4917025, 5054400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                24730, 27375, 29910, 31880, 34425, 36960, 39580, 41500, 44010, 46630, 48550, 51170, 53680, 55600, 58220, 60730, 63300, 65270, 67830, 70450, 72375, 74925, 77550, 79425, 81975, 84600, 87125, 89125, 91650, 94175, 96175, 98700, 101225, 103225, 105750, 108375, 110925, 112800, 115475, 117975, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 190,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 1365,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 51199,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "quest",
                    id = 48070,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 125309,
                    -- name = "Go to Abbey Swiftbrook",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.554502, 0.246649, "Abbey Abbey")
                    -- end,
                    -- breadcrumb = true,
                },
            },
            x = 0,
            y = 0,
            connections = {
                3,
            },
        },
        {
            type = "npc",
            id = 125398,
            -- name = "Go to Harold Beckett",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.555169, 0.245877, "Harold Beckett")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "npc",
            id = 127803,
            -- name = "Go to Caleb Batharen",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.582887, 0.254009, "Caleb Batharen")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },




        {
            type = "quest",
            id = 48077,
            x = 0,
            y = 1,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 48080,
            x = 2,
            y = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 48616,
            x = 4,
            y = 1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48965,
            aside = true,
            x = 6,
            y = 1,
        },

        {
            type = "quest",
            id = 48670,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 48597,
            x = 0,
            y = 3,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 48195,
            x = 2,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 48196,
            x = 4,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 48778,
            x = 6,
            y = 3,
        },
        {
            type = "quest",
            id = 48003,
            x = 3,
            y = 4,
            connections = {
                2, 
            },
        },

        
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN10,
            aside = true,
            x = 1,
            y = 5,
        },
        {
            type = "quest",
            id = 48005,
            x = 3,
            y = 5,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 51367,
            aside = true,
            x = 5,
            y = 5,
        },


        {
            type = "quest",
            id = 48004,
            x = 3,
            y = 6,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48939,
            x = 3,
            y = 7,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 48087,
            x = 3,
            y = 8,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48088,
            x = 2,
            y = 9,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48089,
            x = 4,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49036,
            aside = true,
            x = 3,
            y = 10,
        },
    },
})
-- Need to fix the 2 breadcrumbs
-- Requries part of the main story for alliance [Lovesick and Lost]
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CASTAWAYS_AND_CUTOUTS, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 7)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {49218, 53442, 48421, 53439, 49178, 53443, 49226, 53445, 49230, 53446, 49181, 53444},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {48505, 49178, 49226, 49230, 48421},
        count = 5,
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 143777,
                    -- name = "Go to Tall Hasani",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.8529, 0.8049, "Tall Hasani")
                    -- end,
                    -- breadcrumb = true,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_HORDE,
                    },
                },
                {
                    type = "npc",
                    id = 125342,
                    -- name = "Go to Captain Keelson",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.863578, 0.797432, "Captain Keelson")
                    -- end,
                    -- breadcrumb = true,
                }
            },
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
                    ids = {49218, 53442},
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 128229,
                    -- name = "Go to Abbey Swiftbrook",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.854669, 0.808161, "Stabby Jane")
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
            type = "npc",
            id = 128228,
            -- name = "Go to Hungry Sam",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.854679, 0.807211, "Hungry Sam")
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
        --     ids = {49218, 53442},
        --     x = 3,
        --     y = 1,
        --     connections = {
        --         2, 3, 4,
        --     },
        -- },
        { -- Maybe 48421 isnt part of this chain but should be part of Freehold?
            type = "quest",
            ids = {48421, 53439},
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            ids = {49178, 53443},
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            ids = {49226, 53445},
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            ids = {49230, 53446},
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            ids = {49181,53444},
            x = 0,
            y = 2,
        },
    },
})
-- Completed, Alliance only, no breadcrumbs, although one required quest that looks like a breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN2, {
    name = { -- An Overrun Mine
        type = "quest",
        id = 50349,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        id = 50349,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 50356,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                8200, 29315, 50430, 71545, 92660, 113775, 134890, 156005, 177120, 198235, 219350, 240465, 261580, 282695, 303810, 324925, 346040, 367155, 388270, 409385, 430500, 457070, 483635, 510205, 536770, 563340, 589910, 616475, 643045, 669610, 696180, 722750, 749315, 775885, 802450, 829020, 855095, 881170, 907250, 933325, 959400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                4730, 5250, 5710, 6130, 6600, 7060, 7580, 7950, 8410, 8930, 9300, 9820, 10280, 10650, 11170, 11630, 12100, 12520, 12980, 13500, 13875, 14325, 14850, 15225, 15675, 16200, 16675, 17075, 17550, 18025, 18425, 18900, 19375, 19775, 20250, 20775, 21225, 21600, 22125, 22575, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 300,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 133550,
            -- name = "Go to Junior Miner Joe",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.756956, 0.506281, "Junior Miner Joe")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50349,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            }
        },
        {
            type = "quest",
            id = 50351,
            x = 2,
            y = 2,
            connections = {
                2,
            }
        },
        {
            type = "quest",
            id = 50352,
            x = 4,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            id = 50356,
            x = 3,
            y = 3,
        },
    },
})
-- Completed, Alliance Only, No requirements, couple of breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN5, {
    name = BtWQuests_GetAreaName(9314), -- Thovas Base-Camp
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {50700, 51151, 52258, 49225, 49229, 49234, 49232, 49233},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 49260,
        },
        {
            type = "quest",
            id = 49232,
        },
        {
            type = "quest",
            id = 49233,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                14200, 50765, 87330, 123895, 160460, 197025, 233590, 270155, 306720, 343285, 379850, 416415, 452980, 489545, 526110, 562675, 599240, 635805, 672370, 708935, 745500, 791510, 837515, 883525, 929530, 975540, 1021550, 1067555, 1113565, 1159570, 1205580, 1251590, 1297595, 1343605, 1389610, 1435620, 1480775, 1525930, 1571090, 1616245, 1661400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                8930, 9900, 10810, 11530, 12450, 13360, 14330, 15000, 15910, 16880, 17550, 18520, 19430, 20100, 21070, 21980, 22900, 23620, 24530, 25500, 26175, 27075, 28050, 28725, 29625, 30600, 31525, 32225, 33150, 34075, 34775, 35700, 36625, 37325, 38250, 39225, 40125, 40800, 41775, 42675, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 50,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 460,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 140752,
            -- name = "Go to Jenny Swiftbrook",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.609915, 0.308570, "Jenny Swiftbrook")
            -- end,
            -- breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 128381,
            -- name = "Go to Drogrin Alewhisker",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.627240, 0.299512, "Drogrin Alewhisker")
            -- end,
            -- breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 50700,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 50700,
                    status = {'notcompleted'},
                },
                {
                    type = "quest",
                    id = 51151,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51151,
                    status = {'notcompleted'},
                },
            },
            x = 3,
            y = 0,
            connections = {
                4, 5,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 50700,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "quest",
                    id = 51151,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    visible = false,
                },
            },
            x = 4,
            y = 0,
            connections = {
                3, 4, 5,
            },
        },
        {
            type = "npc",
            id = 130101,
            -- name = "Go to Recruit Brutis",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.629505, 0.299154, "Recruit Brutis")
            -- end,
            -- breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 50700,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 50700,
                    status = {'notcompleted'},
                },
                {
                    type = "quest",
                    id = 51151,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51151,
                    status = {'notcompleted'},
                },
            },
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },


        {
            type = "quest",
            id = 52258,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 49225,
            x = 2,
            y = 1,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 49229,
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            id = 49234,
            x = 6,
            y = 1,
        },

        
        {
            type = "npc",
            id = 128353,
            -- name = "Go to Pendi Cranklefuse",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1171, 0.513119, 0.706588, "Pendi Cranklefuse")
            -- end,
            -- breadcrumb = true,
            x = 4,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "npc",
            id = 128354,
            -- name = "Go to Birch Tomlin",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1171, 0.503748, 0.703355, "Birch Tomlin")
            -- end,
            -- breadcrumb = true,
            x = 6,
            y = 2,
            connections = {
                3,
            },
        },

        {
            type = "quest",
            id = 49260,
            x = 2,
            y = 3,
        },
        {
            type = "quest",
            id = 49232,
            x = 4,
            y = 3,
        },
        {
            type = "quest",
            id = 49233,
            x = 6,
            y = 3,
        },
    },
})
-- Completed, alliance only, requires part way through freehold quest line, no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN4, {
    name = { -- The Long Con
        type = "achievement",
        id = 13049,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_FREEHOLD,
            upto = {
                {
                    type = "quest",
                    id = 48773,
                },
                {
                    type = "quest",
                    id = 48558,
                },
            },
        }
    },
    active = {
        type = "quest",
        id = 49290,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 49223,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                708000, 723455, 738900, 754355, 769800, 785255, 800700, 816155, 831600, 847055, 862500, 877955, 893400, 908855, 924300, 939755, 955200, 970655, 986100, 1001555, 1017000, 1036440, 1055880, 1075320, 1094760, 1114200, 1133640, 1153080, 1172520, 1191960, 1211400, 1230840, 1250280, 1269720, 1289160, 1308600, 1327680, 1346760, 1365840, 1384920, 1404000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                4210, 4640, 5070, 5410, 5840, 6275, 6700, 7050, 7475, 7950, 8300, 8725, 9150, 9500, 9925, 10350, 10800, 11125, 11550, 12000, 12350, 12750, 13200, 13550, 13950, 14400, 14850, 15150, 15600, 16050, 16350, 16800, 17250, 17550, 18000, 18450, 18850, 19200, 19650, 20050, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 75,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 150,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 350,
        },
    },
    items = {
        {
            type = "npc",
            id = 128702,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49290,
            x = 3,
            y = 1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49407,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49522,
            x = 3,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49523,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "level",
            level = 50,
            x = 5,
            y = 4.5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49223,
            x = 3,
            y = 5,
        },
    },
})
-- Completed, alliance only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN6, {
    name = BtWQuests_GetAreaName(9360), -- Fizzsprings Resort
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {50542, 49531, 49897, 51426, 51430},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 49531,
        },
        {
            type = "quest",
            id = 49897,
        },
        {
            type = "quest",
            id = 51426,
        },
        {
            type = "quest",
            id = 51430,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1391280, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                8400, 9300, 10200, 10800, 11700, 12600, 13500, 14100, 15000, 15900, 16500, 17400, 18300, 18900, 19800, 20700, 21600, 22200, 23100, 24000, 24600, 25500, 26400, 27000, 27900, 28800, 29700, 30300, 31200, 32100, 32700, 33600, 34500, 35100, 36000, 36900, 37800, 38400, 39300, 40200, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 200,
            restrictions = 924,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 50542,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 129858,
                    -- name = "Go to Wulferd Fizzbracket",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.674951, 0.558120, "Wulferd Fizzbracket")
                    -- end,
                    -- breadcrumb = true,
                }
            },
            x = 1,
            y = 0,
            connections = {
                2, 3, 
            },
        },
        {
            type = "npc",
            id = 137694,
            -- name = "Go to Parin Tinklocket",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.649917, 0.606135, "Parin Tinklocket")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 50544,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 5,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 49531,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 49897,
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            id = 51426,
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            id = 51430,
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            id = 49529,
            aside = true,
            x = 3,
            y = 2,
        },
    },
})
-- Completed, Alliance only, no requirements, 1 breadcrumb, Seems kinda pointless, its just an area for breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN3, {
    name = BtWQuests_GetAreaName(9381), -- Southwind Station
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    completed = {
        type = "quest",
        id = 51149,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                200, 715, 1230, 1745, 2260, 2775, 3290, 3805, 4320, 4835, 5350, 5865, 6380, 6895, 7410, 7925, 8440, 8955, 9470, 9985, 10500, 11150, 11795, 12445, 13090, 13740, 14390, 15035, 15685, 16330, 16980, 17630, 18275, 18925, 19570, 20220, 20855, 21490, 22130, 22765, 23400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                180, 200, 210, 230, 250, 260, 280, 300, 310, 330, 350, 370, 380, 400, 420, 430, 450, 470, 480, 500, 525, 525, 550, 575, 575, 600, 625, 625, 650, 675, 675, 700, 725, 725, 750, 775, 775, 800, 825, 825, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
    },
    items = {
        {
            type = "npc",
            id = 136576,
            -- name = "Go to Dockmaster Leighton",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.750697, 0.497147, "Dockmaster Leighton")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51149,
            x = 3,
            y = 1,
        },

        {
            type = "npc",
            id = 129956,
            -- name = "Go to Dockmaster Tyndall",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.658408, 0.500967, "Dockmaster Tyndall")
            -- end,
            -- breadcrumb = true,
            relationship = {
                breadcrumb = 51151,
                blockers = {49225, 49229, 50700},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "npc",
            id = 134509,
            -- name = "Go to Lead Guide Zipwrench",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.666848, 0.500323, "Lead Guide Zipwrench")
            -- end,
            -- breadcrumb = true,
            relationship = {
                breadcrumb = 50542,
                blockers = {49531, 49897},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            x = 3,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "object",
            id = 281230,
            -- name = "Go to Formal Invitation",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.671420, 0.247996, "Formal Invitation")
            -- end,
            -- breadcrumb = true,
            relationship = {
                breadcrumb = 48070,
                blockers = {48077, 51199},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            x = 5,
            y = 2,
            connections = {
                3,
            },
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN5,
            relationship = {
                breadcrumb = 51151,
                blockers = {49225, 49229, 50700},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 1,
            y = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN6,
            relationship = {
                breadcrumb = 50542,
                blockers = {49531, 49897},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 3,
            y = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_NORWINGTON_ESTATE,
            relationship = {
                breadcrumb = 48070,
                blockers = {48077, 51199},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 5,
            y = 3,
        },
    },
})
-- Completed, Alliance Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN1, {
    name = { -- The Hunters of Kennings Lodge
        type = "quest",
        id = 50544,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {50544, 48873, 48879, 48874},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 48909,
        },
        {
            type = "quest",
            id = 49066,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                24200, 86515, 148830, 211145, 273460, 335775, 398090, 460405, 522720, 585035, 647350, 709665, 771980, 834295, 896610, 958925, 1021240, 1083555, 1145870, 1208185, 1270500, 1348910, 1427315, 1505725, 1584130, 1662540, 1740950, 1819355, 1897765, 1976170, 2054580, 2132990, 2211395, 2289805, 2368210, 2446620, 2523575, 2600530, 2677490, 2754445, 2831400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                12660, 14000, 15270, 16310, 17600, 18870, 20210, 21200, 22470, 23810, 24800, 26140, 27410, 28400, 29740, 31010, 32300, 33340, 34610, 35950, 37000, 38250, 39600, 40600, 41850, 43200, 44500, 45500, 46800, 48100, 49100, 50400, 51700, 52700, 54000, 55350, 56600, 57600, 58950, 60200, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 1110,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 277199,
            -- name = "Go to Weathered Job List",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.761227, 0.655189, "Weathered Job List")
            -- end,
            -- breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                4, 8,
            },
        },
        {
            type = "quest",
            id = 50544,
            visible = BtWQuestsItem_ActiveOrCompleted,
            x = 4,
            y = 0,
            connections = {
                4, 5, 6,
            },
        },
        {
            type = "npc",
            id = 127646,
            -- name = "Go to Lord Kennings",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.758213, 0.657893, "Lord Kennings")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 50544,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 3,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "npc",
            id = 127161,
            -- name = "Go to Alanna Holton",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.758435, 0.658611, "Alanna Holton")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 50544,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },



        {
            type = "quest",
            id = 49028,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 48873,
            x = 2,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 48879,
            x = 4,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48874,
            x = 6,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49069,
            aside = true,
            x = 0,
            y = 2,
        },
        {
            type = "quest",
            id = 49072,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49039,
            x = 4,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 48909,
            x = 3,
            y = 4,
        },
        {
            type = "quest",
            id = 49066,
            x = 5,
            y = 4,
        },
    },
})
-- Completed, Alliance Only, no requirements, no breadcrumbs but something that looks like one
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN12, {
    name = { -- Save our shipment
        type = "quest",
        id = 50026,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        id = 50026,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 50005,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                12500, 44690, 76875, 109065, 141250, 173440, 205625, 237815, 270000, 302190, 334375, 366565, 398750, 430940, 463125, 495315, 527500, 559690, 591875, 624065, 656250, 696750, 737250, 777750, 818250, 858750, 899250, 939750, 980250, 1020750, 1061250, 1101750, 1142250, 1182750, 1223250, 1263750, 1303500, 1343250, 1383000, 1422750, 1449780, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                8750, 9675, 10600, 11250, 12175, 13100, 14000, 14700, 15600, 16550, 17250, 18150, 19050, 19750, 20650, 21550, 22500, 23150, 24100, 25000, 25650, 26600, 27500, 28150, 29100, 30000, 30900, 31600, 32500, 33400, 34100, 35000, 35900, 36600, 37500, 38400, 39350, 40000, 40950, 41850, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 325,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 131627,
            -- name = "Go to Thomas Pinker",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.494604, 0.312683, "Thomas Pinker")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 50026,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3, 4,
            }
        },
        {
            type = "quest",
            id = 50009,
            aside = true,
            x = 0,
            y = 2,
        },
        {
            type = "quest",
            id = 47755,
            aside = true,
            x = 2,
            y = 2,
        },
        {
            type = "quest",
            id = 50002,
            x = 4,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 50059,
            aside = true,
            x = 6,
            y = 2,
        },
        {
            type = "quest",
            id = 50005,
            x = 4,
            y = 3,
        },
    },
})
-- Completed, Alliance only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN7, {
    name = { -- Trouble at Greystone Keep
        type = "quest",
        id = 49715,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {49715, 49733, 51226},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 50249,
        },
        {
            type = "quest",
            id = 49734,
        },
        {
            type = "quest",
            id = 49716,
        },
        {
            type = "quest",
            id = 49720,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10500, 11650, 12700, 13600, 14650, 15700, 16850, 17650, 18700, 19850, 20650, 21800, 22850, 23650, 24800, 25850, 26900, 27800, 28850, 30000, 30800, 31850, 33000, 33800, 34850, 36000, 37050, 37950, 39000, 40050, 40950, 42000, 43050, 43950, 45000, 46150, 47200, 48000, 49150, 50200, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 610,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 49715,
            visible = BtWQuestsItem_ActiveOrCompleted,
            x = 3,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "npc",
            id = 133035,
            -- name = "Go to Officer Jovan",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.811002, 0.424831, "Officer Jovan")
            -- end,
            -- breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 49715,
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 49715,
                    status = {'notcompleted'}
                },
            },
            x = 2,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 125398,
            -- name = "Go to Harold Beckett",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.555169, 0.245877, "Harold Beckett")
            -- end,
            -- breadcrumb = true,
            visible = {
                {
                    type = "quest",
                    id = 49715,
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 49715,
                    status = {'notcompleted'}
                },
            },
            x = 4,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49733,
            x = 2,
            y = 1,
            connections = {
                2, 3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 51226,
            x = 4,
            y = 1,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 50249,
            x = 0,
            y = 2,
        },
        {
            type = "quest",
            id = 49734,
            x = 2,
            y = 2,
        },
        {
            type = "quest",
            id = 49716,
            x = 4,
            y = 2,
        },
        {
            type = "quest",
            id = 49720,
            x = 6,
            y = 2,
        },
    },
})
-- Completed, Alliance Only, No requirements, seems no breadcrumbs either
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN10, {
    name = L["BTWQUESTS_MAJO_AND_JOMA"],
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {48898, 48902, 48899},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 48903,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                10000, 35750, 61500, 87250, 113000, 138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                5950, 6600, 7200, 7700, 8300, 8900, 9550, 10000, 10600, 11250, 11700, 12350, 12950, 13400, 14050, 14650, 15250, 15750, 16350, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 310,
        },
    },
    items = {
        {
            type = "npc",
            id = 127586,
            -- name = "Go to Joma",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.513127, 0.258978, "Joma")
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
            id = 127492,
            -- name = "Go to Majo",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.512903, 0.258750, "Majo")
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
            id = 48898,
            x = 1,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 48902,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 48899,
            x = 5,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 48903,
            x = 3,
            y = 2,
        },
    },
})
-- Completed, Alliance only, no requrements, is a breadcrumb hub
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN8, {
    name = BtWQuests_GetAreaName(9335), -- Hatherford
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    completed = {
        type = "quest",
        id = 51144,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                6500, 23240, 39975, 56715, 73450, 90190, 106925, 123665, 140400, 157140, 173875, 190615, 207350, 224090, 240825, 257565, 274300, 291040, 307775, 324515, 341250, 362310, 383370, 404430, 425490, 446550, 467610, 488670, 509730, 530790, 551850, 572910, 593970, 615030, 636090, 657150, 677820, 698490, 719160, 739830, 760500, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                2510, 2740, 2970, 3210, 3440, 3675, 3900, 4150, 4375, 4600, 4850, 5075, 5300, 5550, 5775, 6000, 6250, 6475, 6700, 6950, 7250, 7450, 7700, 7950, 8150, 8400, 8650, 8850, 9100, 9350, 9550, 9800, 10050, 10250, 10500, 10750, 10950, 11200, 11450, 11650, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 115,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 124289,
            -- name = "Go to Jenny Swiftbrook",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.609915, 0.308570, "Jenny Swiftbrook")
            -- end,
            -- breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51144,
            x = 3,
            y = 1,
        },
        
        {
            type = "npc",
            id = 139089,
            -- name = "Go to Hatherford Guard",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.663190, 0.248081, "Hatherford Guard")
            -- end,
            -- breadcrumb = true,
            relationship = {
                breadcrumb = 50700,
                blockers = {49225, 49229},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            x = 0,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "object",
            id = 288641,
            -- name = "Go to the Wanted Poster",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.668494, 0.243570, "Wanted Poster")
            -- end,
            -- breadcrumb = true,
            x = 2,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "object",
            id = 281230,
            -- name = "Go to Formal Invitation",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.671420, 0.247996, "Formal Invitation")
            -- end,
            -- breadcrumb = true,
            relationship = {
                breadcrumb = 48070,
                blockers = {48077, 51199},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            x = 4,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "npc",
            id = 134776,
            -- name = "Go to Davey Brindle",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.673976, 0.241373, "Davey Brindle")
            -- end,
            -- breadcrumb = true,
            relationship = {
                breadcrumb = 50699,
                blocker = 49465,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            x = 6,
            y = 2,
            connections = {
                4,
            },
        },



        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN5,
            relationship = {
                breadcrumb = 50700,
                blockers = {49225, 49229},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 51358,
            x = 2,
            y = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_NORWINGTON_ESTATE,
            relationship = {
                breadcrumb = 48070,
                blockers = {48077, 51199},
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 4,
            y = 3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN9,
            relationship = {
                breadcrumb = 50699,
                blocker = 49465,
            },
            visible = BtWQuestsItem_RelationshipSourceVisible,
            active = BtWQuestsItem_RelationshipSourceActive,
            x = 6,
            y = 3,
        },
    },
})
-- Completed, Alliance Only, no requirements, 1 breadcrumb
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN9, {
    name = { -- Witch of the Woods
        type = "quest",
        id = 49467,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {50699, 49465, 49452, 49451},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 49467,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                26200, 93665, 161130, 228595, 296060, 363525, 430990, 498455, 565920, 633385, 700850, 768315, 835780, 903245, 970710, 1038175, 1105640, 1173105, 1240570, 1308035, 1375500, 1460390, 1545275, 1630165, 1715050, 1799940, 1884830, 1969715, 2054605, 2139490, 2224380, 2309270, 2394155, 2479045, 2563930, 2648820, 2732135, 2815450, 2898770, 2982085, 3065400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                16280, 18050, 19710, 21030, 22700, 24360, 26130, 27350, 29010, 30780, 32000, 33770, 35430, 36650, 38420, 40080, 41750, 43070, 44730, 46500, 47725, 49375, 51150, 52375, 54025, 55800, 57475, 58775, 60450, 62125, 63425, 65100, 66775, 68075, 69750, 71525, 73175, 74400, 76175, 77825, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 100,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 975,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 129613,
            -- name = "Go to Maynard Algerson",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.689298, 0.205881, "Maynard Algerson")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 50699,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 3,
            y = 0,
            connections = {
                4, 5,
            },
        },
        {
            type = "npc",
            id = 129669,
            -- name = "Go to Benjamin Algerson",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.688899, 0.198464, "Benjamin Algerson")
            -- end,
            -- breadcrumb = true,
            relationship = {
                blocker = 50699,
            },
            visible = BtWQuestsItem_RelationshipBlockersVisible,
            x = 6,
            y = 0,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 50699,
            visible = BtWQuestsItem_ActiveOrCompleted,
            x = 4,
            y = 0,
            connections = {
                2, 3, 4,
            },
        },


        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN15,
            embed = true,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 49465,
            x = 2,
            y = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 49452,
            x = 4,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49451,
            x = 6,
            y = 1,
            connections = {
                1,
            },
        },
        
        
        {
            type = "quest",
            id = 48369,
            x = 4,
            y = 2,
            connections = {
                2, 3, 4,
            },
        },

        
        {
            type = "quest",
            id = 50058,
            aside = true,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 49468,
            x = 2,
            y = 3,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 49454,
            x = 4,
            y = 3,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 49450,
            x = 6,
            y = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 49467,
            x = 4,
            y = 4,
        },
    },
})
-- Completed, Alliance Only, no requirements, seems like no breadcrumbs
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN11, {
    name = { -- The Roughnecks
        type = "quest",
        id = 49393,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        id = 49393,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 49719,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                36400, 130130, 223860, 317590, 411320, 505050, 598780, 692510, 786240, 879970, 973700, 1067430, 1161160, 1254890, 1348620, 1442350, 1536080, 1629810, 1723540, 1817270, 1911000, 2028940, 2146870, 2264810, 2382740, 2500680, 2618620, 2736550, 2854490, 2972420, 3090360, 3208300, 3326230, 3444170, 3562100, 3680040, 3795790, 3911540, 4027300, 4143050, 4258800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                20360, 22550, 24570, 26310, 28350, 30370, 32560, 34150, 36170, 38360, 39950, 42140, 44160, 45750, 47940, 49960, 52000, 53740, 55760, 57950, 59600, 61600, 63800, 65400, 67400, 69600, 71650, 73350, 75400, 77450, 79150, 81200, 83250, 84950, 87000, 89200, 91200, 92800, 95000, 97000, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 265,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 1145,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "object",
            id = 289313,
            -- name = "Go to Wanted Sign",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.421558, 0.229884, "Wanted Sign")
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
            type = "quest",
            id = 49393,
            x = 3,
            y = 0,
            connections = {
                3, 4,
            },
        },
        {
            type = "npc",
            id = 129392,
            -- name = "Go to\"Helpless\" Henry",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.477050, 0.176317, "\"Helpless\" Henry")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 6,
            y = 0,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 51368,
            aside = true,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 49394,
            x = 2,
            y = 1,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 49395,
            x = 4,
            y = 1,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 49412,
            x = 6,
            y = 1,
            connections = {
                9,
            },
        },

        {
            type = "quest",
            id = 49735,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49710,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49417,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 130478,
            -- name = "Go to Griddon",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.449121, 0.154990, "Griddon")
            -- end,
            -- breadcrumb = true,
            aside = true,
            x = 0,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49418,
            x = 3,
            y = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 49431,
            aside = true,
            x = 0,
            y = 5,
        },
        {
            type = "quest",
            id = 49433,
            x = 2,
            y = 5,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 49435,
            x = 4,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 49419,
            aside = true,
            x = 6,
            y = 5,
        },
        {
            type = "quest",
            id = 49439,
            x = 4,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 49719,
            x = 3,
            y = 7,
        },
    },
})
-- Horde version of Castaways and Cutouts
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN13, {
    name = function ()
        return GetAchievementCriteriaInfo(ACHIEVEMENT_ID, 7)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {49218, 53442, 48421, 53439, 49178, 53443, 49226, 53445, 49230, 53446, 49181,53444},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            ids = {48421, 53439},
        },
        {
            type = "quest",
            ids = {49178, 53443},
        },
        {
            type = "quest",
            ids = {49226, 53445},
        },
        {
            type = "quest",
            ids = {49230, 53446},
        },
        {
            type = "quest",
            ids = {49181,53444},
        },
    },
    items = {
        {
            variations = {
                {
                    type = "npc",
                    id = 143777,
                    -- name = "Go to Tall Hasani",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.8529, 0.8049, "Tall Hasani")
                    -- end,
                    -- breadcrumb = true,
                    restrictions = {
                        type = "faction",
                        id = BTWQUESTS_FACTION_ID_HORDE,
                    },
                },
                {
                    type = "npc",
                    id = 125342,
                    -- name = "Go to Captain Keelson",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.863578, 0.797432, "Captain Keelson")
                    -- end,
                    -- breadcrumb = true,
                }
            },
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
                    ids = {49218, 53442},
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "npc",
                    id = 128229,
                    -- name = "Go to Abbey Swiftbrook",
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(895, 0.854669, 0.808161, "Stabby Jane")
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
            type = "npc",
            id = 128228,
            -- name = "Go to Hungry Sam",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.854679, 0.807211, "Hungry Sam")
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
        --     ids = {49218, 53442},
        --     x = 3,
        --     y = 1,
        --     connections = {
        --         2, 3, 4,
        --     },
        -- },
        { -- Maybe 48421 isnt part of this chain but should be part of Freehold?
            type = "quest",
            ids = {48421, 53439},
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            ids = {49178, 53443},
            x = 2,
            y = 1,
        },
        {
            type = "quest",
            ids = {49226, 53445},
            x = 4,
            y = 1,
        },
        {
            type = "quest",
            ids = {49230, 53446},
            x = 6,
            y = 1,
        },
        {
            type = "quest",
            ids = {49181,53444},
            x = 0,
            y = 2,
        },
    },
})
-- Horde Wanted quests from the Wolf's Den Outpost
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN14, {
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_HORDE,
    },
    prerequisites = {
        type = "quest",
        id = 52127,
    },
    active = {
        type = "quest",
        ids = {53440, 53438},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 53440,
        },
        {
            type = "quest",
            id = 53438,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                4300, 4700, 5100, 5500, 5900, 6300, 6700, 7100, 7500, 7900, 8300, 8700, 9100, 9500, 9900, 10300, 10700, 11100, 11500, 11900, 12400, 12800, 13200, 13600, 14000, 14400, 14800, 15200, 15600, 16000, 16400, 16800, 17200, 17600, 18000, 18400, 18800, 19200, 19600, 20000, 
            },
            minLevel = 10,
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
            id = 298778,
            -- name = "Go to the Wanted Poster",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.628, 0.14, "Wanted Poster")
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
            id = 53440,
            x = 2,
        },
        {
            type = "quest",
            id = 53438,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN15, {
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = {
        type = "quest",
        ids = {49453, 48557},
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 49453,
        },
        {
            type = "quest",
            id = 48557,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                4000, 14300, 24600, 34900, 45200, 55500, 65800, 76100, 86400, 96700, 107000, 117300, 127600, 137900, 148200, 158500, 168800, 179100, 189400, 199700, 210000, 222960, 235920, 248880, 261840, 274800, 287760, 300720, 313680, 326640, 339600, 352560, 365520, 378480, 391440, 404400, 417120, 429840, 442560, 455280, 468000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                2800, 3100, 3400, 3600, 3900, 4200, 4500, 4700, 5000, 5300, 5500, 5800, 6100, 6300, 6600, 6900, 7200, 7400, 7700, 8000, 8200, 8500, 8800, 9000, 9300, 9600, 9900, 10100, 10400, 10700, 10900, 11200, 11500, 11700, 12000, 12300, 12600, 12800, 13100, 13400, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 150,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 129670,
            -- name = "Go to Lyssa Treewarden",
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.666195, 0.173166, "Lyssa Treewarden")
            -- end,
            -- breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 49453,
            x = 0,
            y = 1,
        },
        {
            type = "quest",
            id = 48557,
            x = 2,
            y = 1,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    items = {
        { -- Emissary
            type = "quest",
            id = 50599,
        },
        { -- Emissary
            type = "quest",
            id = 50605,
        },
        {
            type = "quest",
            id = 49661,
        },
        {
            type = "quest",
            id = 50350,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    prerequisites = {
        type = "level",
        level = 10,
        visible = false,
    },
    active = false,
    items = {
        {
            type = "quest",
            id = 49408,
        },
        {
            type = "quest",
            id = 53451,
        },
        {
            type = "quest",
            id = 52956,
        },
        {
            type = "quest",
            id = 47894,
        },
        {
            type = "quest",
            id = 48104,
        },
        {
            type = "quest",
            id = 53454,
        },
        {
            type = "quest",
            id = 53440,
        },
        {
            type = "quest",
            id = 47695,
        },
        {
            type = "quest",
            id = 49464,
        },
        {
            type = "quest",
            id = 53438,
        },
        {
            type = "quest",
            id = 52948,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2178272,
    listImage = {
        texture = "Interface\\Addons\\BtWQuestsBattleForAzeroth\\UI-CategoryButton",
        texCoords = {0, 0.7353515625, 0.1171875, 0.234375},
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
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_FIRST_ASSAULT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_STRIKE_ON_BORALAS,
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
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_ASHVANE_TRADING_COMPANY,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_FREEHOLD,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_DEFENDERS_OF_DAELINS_GATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_ENEMIES_WITHIN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_SHADOW_OVER_ANGLEPOINT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_NORWINGTON_ESTATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CASTAWAYS_AND_CUTOUTS,
        },


        {
            type = "header",
            name = L["BTWQUESTS_SIDE_QUESTS"],
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN3,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN4,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN6,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN9,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN11,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN12,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN13,
        },
        
        


        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_OTHER_ALLIANCE,
        -- },
        -- {
        --     type = "chain",
        --     id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_OTHER_BOTH,
        -- },
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
}, true)

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN1,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN2,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN5,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN6,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN7,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN9,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN10,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN11,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN12,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN14,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN15,
    },
})

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_ASHVANE_TRADING_COMPANY);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_FREEHOLD);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_DEFENDERS_OF_DAELINS_GATE);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_ENEMIES_WITHIN);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_SHADOW_OVER_ANGLEPOINT);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_THE_NORWINGTON_ESTATE);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CASTAWAYS_AND_CUTOUTS);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN1);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN2);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN3);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN4);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN5);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN6);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN7);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN8);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN9);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN10);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN11);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN12);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN13);
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN14);
BtWQuestsDatabase:AddQuestItemsForOtherChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN9, BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND_CHAIN15);