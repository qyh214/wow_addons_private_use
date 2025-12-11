local BtWQuests = BtWQuests;
local L = BtWQuests.L;
local Chain = BtWQuests.Constant.Chain.BattleForAzeroth;
local Restrictions = BtWQuests.Constant.Restrictions;

local HORDE_CAMPAIGN_ACHIEVEMENT_ID = 12509
local ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID = 12510

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION, {
    name = L["BTWQUESTS_INTRODUCTION"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    crest = "alliance",
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "time",
            time = 1534197600,
            visible = BtWQuestsItem_Active,
        },
    },
    active = {
        type = "quest",
        id = 46727,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 47189,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                9900, 35395, 60885, 86380, 111870, 137365, 162855, 188350, 213840, 239335, 264825, 290320, 315810, 341305, 366795, 392290, 417780, 443275, 468765, 494260, 519750, 551830, 583900, 615980, 648050, 680130, 712210, 744280, 776360, 808430, 840510, 872590, 904660, 936740, 968810, 1000890, 1032370, 1063850, 1095340, 1126820, 1158300, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                5960, 6600, 7170, 7710, 8300, 8870, 9410, 10100, 10570, 11160, 11850, 12390, 12860, 13550, 14090, 14560, 15250, 15790, 16460, 17000, 17500, 18150, 18700, 19200, 19850, 20400, 20900, 21600, 22100, 22600, 23300, 23800, 24300, 25000, 25500, 26050, 26700, 27200, 27950, 28400, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2160,
            amount = 1025,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "npc",
            id = 49748,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 46727,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 46728,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51341,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47098,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 47099,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 46729,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 47186,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 52128,
        },
        {
            type = "quest",
            id = 47189,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION, {
    name = L["BTWQUESTS_INTRODUCTION"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    crest = "horde",
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "time",
            time = 1534197600,
            visible = BtWQuestsItem_Active,
        },
    },
    active = {
        type = "quest",
        id = 51443,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 46931,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                10400, 37180, 63960, 90740, 117520, 144300, 171080, 197860, 224640, 251420, 278200, 304980, 331760, 358540, 385320, 412100, 438880, 465660, 492440, 519220, 546000, 579700, 613390, 647090, 680780, 714480, 748180, 781870, 815570, 849260, 882960, 916660, 950350, 984050, 1017740, 1051440, 1084510, 1117580, 1150660, 1183730, 1216800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                5310, 5850, 6370, 6810, 7350, 7870, 8410, 8850, 9370, 9910, 10350, 10890, 11410, 11850, 12390, 12910, 13450, 13890, 14410, 14950, 15450, 15950, 16500, 16950, 17450, 18000, 18550, 18950, 19500, 20050, 20450, 21000, 21550, 21950, 22500, 23050, 23550, 24000, 24550, 25050, 
            },
            minLevel = 10,
            maxLevel = 49,
        },
        {
            type = "reputation",
            id = 2103,
            amount = 110,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "npc",
            id = 49750,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 51443,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 50769,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 46957,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 46930,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 46931,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 1778893,
    crest = "alliance",
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
    },
    active = {
        type = "quest",
        ids = {52654, 52544},
        status = {'active', 'completed'}
    },
    completed = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_THE_STRIKE_ON_ZULDAZAR,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2321820, 2366540, 2411240, 2455960, 2500660, 2545380, 2597880, 2650350, 2702850, 2755320, 2807820, 2859330, 2910840, 2962380, 3013890, 3065400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                40400, 41450, 42150, 43200, 44250, 44950, 46200, 47450, 48250, 49500, 50750, 51900, 52800, 54100, 55200, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1000,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 10,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 52654,
            breadcrumb = true,
            x = 2,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52544,
            x = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53332,
            x = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51714,
            x = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51715,
            x = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53074,
            x = 2,
        },



        {
            type = "quest",
            id = 51569,
            x = 4,
            y = 1,
            connections = {
                1,
            },
        },

        {
            variations = {
                {
                    name = L["AN_ALLIANCE_FOOTHOLD"],
                    breadcrumb = true,
                    restrictions = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                        },
                        count = 0,
                        notequals = true,
                    },
                    completed = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                        },
                        count = 0,
                        morethan = true,
                    },
                    -- restrictions = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and 1 or 0) ~= 0
                    -- end,
                    -- completed = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and 1 or 0) >= 1
                    -- end,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    name = L["AN_ALLIANCE_FOOTHOLD"],
                },
            },
            x = 4,
            y = 6,
            connections = {
                1, 2,
            },
        },

        {
            type = "quest",
            id = 53583,
            x = 2,
            y = 7,
            connections = {
                2,
            },
        },
        { -- If you are already past level 116 this isnt offered
            type = "quest",
            id = 53052,
            breadcrumb = true,
            x = 4,
            y = 7,
            connections = {
                2,
            },
        },

        {
            type = "quest",
            id = 53061,
            breadcrumb = true,
            x = 2,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51961,
            x = 4,
            y = 8,
            connections = {
                2,
            },
        },

        {
            type = "quest",
            id = 51903,
            breadcrumb = true,
            x = 2,
            y = 9,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    name = L["AN_ALLIANCE_FOOTHOLD"],
                    breadcrumb = true,
                    restrictions = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                        },
                        count = 1,
                        notequals = true,
                    },
                    completed = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                        },
                        count = 1,
                        morethan = true,
                    },
                    -- restrictions = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and 1 or 0) ~= 1
                    -- end,
                    -- completed = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and 1 or 0) >= 2
                    -- end,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    name = L["AN_ALLIANCE_FOOTHOLD"],
                },
            },
            x = 4,
            y = 9,
            connections = {
                2,
            },
        },

        {
            type = "quest",
            id = 51904,
            completed = {
                type = "quest",
                id = 51994,
            },
            x = 2,
            y = 10,
        },
        { -- Requires [51904] Island Expedition
            type = "quest",
            id = 53055,
            breadcrumb = true,
            x = 4,
            y = 10,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 52443,
            x = 4,
            y = 11,
            connections = {
                1,
            },
        },


        {
            variations = {
                {
                    name = L["AN_ALLIANCE_FOOTHOLD"],
                    breadcrumb = true,
                    restrictions = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                        },
                        count = 2,
                        notequals = true,
                    },
                    completed = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                        },
                        count = 2,
                        morethan = true,
                    },
                    -- restrictions = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and 1 or 0) ~= 2
                    -- end,
                    -- completed = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and 1 or 0) >= 3
                    -- end,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    name = L["AN_ALLIANCE_FOOTHOLD"],
                },
            },
            x = 4,
            y = 12,
            connections = {
                3,
            },
        },

        {
            visible = false,
            x = 0,
            y = 12.5,
        },
        {
            type = "level",
            level = 50,
            x = 6,
            y = 12.5,
            connections = {
                1,
            },
        },
        -- { -- Might be either this or the next one, depending on if you were at the ship when they became available
        --     type = "quest",
        --     id = 53063,
        --     breadcrumb = true,
        --     x = 4,
        --     y = 13,
        --     connections = {
        --         1,
        --     },
        -- },
        {
            type = "quest",
            id = 51918, -- 53064
            completed = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                },
                {
                    type = "quest",
                    id = 51918,
                },
            },
            -- completed = function (item, character)
            --     return character:IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and
            --     character:IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and
            --     character:IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and
            --     character:IsQuestCompleted(51918)
            -- end,
            x = 4,
            y = 13,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 53194,
            aside = true,
            breadcrumb = true,
            x = 2,
            y = 14,
            connections = {
                3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_ON_THE_SAND,
            x = 4,
            y = 14,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 53185,
            aside = true,
            visible = false,
            x = 6,
            y = 14,
        },
        {
            type = "quest",
            id = 53197,
            aside = true,
            breadcrumb = true,
            x = 2,
            y = 15,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CHASING_DARKNESS,
            x = 4,
            y = 15,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53198,
            aside = true,
            completed = {
                type = "quest",
                id = 53206,
            },
            x = 2,
            y = 16,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_A_GOLDEN_OPPORTUNITY,
            x = 4,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_IN_THE_WATER,
            x = 4,
            y = 17,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_THE_STRIKE_ON_ZULDAZAR,
            x = 4,
            y = 18,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1,
            aside = true,
            x = 4,
            y = 19,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 1778893,
    crest = "horde",
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
    },
    active = {
        type = "quest",
        ids = {52749, 52746},
        status = {'active', 'completed'}
    },
    completed = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_STRIKE_ON_BORALAS,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2321820, 2366540, 2411240, 2455960, 2500660, 2545380, 2597880, 2650350, 2702850, 2755320, 2807820, 2859330, 2910840, 2962380, 3013890, 3065400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                40400, 41450, 42150, 43200, 44250, 44950, 46200, 47450, 48250, 49500, 50750, 51900, 52800, 54100, 55200, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1000,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 10,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 52749,
            breadcrumb = true,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52746,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53333,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51770,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51771,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51803,
            x = 4,
            y = 5,
            connections = {
                2,
            },
        },

        {
            type = "quest",
            id = 53079,
            x = 2,
            y = 6,
        },
        {
            variations = {
                {
                    name = L["A_HORDE_FOOTHOLD"],
                    breadcrumb = true,
                    restrictions = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                        },
                        count = 0,
                        notequals = true,
                    },
                    completed = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                        },
                        count = 0,
                        morethan = true,
                    },
                    -- restrictions = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and 1 or 0) ~= 0
                    -- end,
                    -- completed = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and 1 or 0) >= 1
                    -- end,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    name = L["A_HORDE_FOOTHOLD"],
                },
            },
            x = 4,
            y = 6,
            connections = {
                1, 2,
            },
        },

        {
            type = "quest",
            id = 53602,
            x = 2,
            y = 7,
            connections = {
                2,
            },
        },
        { -- If you are already past level 116 this isnt offered
            type = "quest",
            id = 53050,
            breadcrumb = true,
            x = 4,
            y = 7,
            connections = {
                2,
            },
        },

        {
            type = "quest",
            id = 53062,
            breadcrumb = true,
            x = 2,
            y = 8,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51979,
            x = 4,
            y = 8,
            connections = {
                2,
            },
        },

        {
            type = "quest",
            id = 51870,
            breadcrumb = true,
            x = 2,
            y = 9,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    name = L["A_HORDE_FOOTHOLD"],
                    breadcrumb = true,
                    restrictions = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                        },
                        count = 1,
                        notequals = true,
                    },
                    completed = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                        },
                        count = 1,
                        morethan = true,
                    },
                    -- restrictions = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and 1 or 0) ~= 1
                    -- end,
                    -- completed = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and 1 or 0) >= 2
                    -- end,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    name = L["A_HORDE_FOOTHOLD"],
                },
            },
            x = 4,
            y = 9,
            connections = {
                2,
            },
        },

        {
            type = "quest",
            id = 51888,
            completed = {
                type = "quest",
                id = 51994,
            },
            x = 2,
            y = 10,
        },
        {
            type = "quest",
            id = 53056,
            breadcrumb = true,
            x = 4,
            y = 10,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 52444,
            x = 4,
            y = 11,
            connections = {
                1,
            },
        },


        {
            variations = {
                {
                    name = L["A_HORDE_FOOTHOLD"],
                    breadcrumb = true,
                    restrictions = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                        },
                        count = 2,
                        notequals = true,
                    },
                    completed = {
                        type = "chain",
                        ids = {
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                        },
                        count = 2,
                        morethan = true,
                    },
                    -- restrictions = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and 1 or 0) ~= 2
                    -- end,
                    -- completed = function ()
                    --     return (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and 1 or 0) + (BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and 1 or 0) >= 3
                    -- end,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                    restrictions = {
                        {
                            type = "chain",
                            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                            status = {'active'},
                        },
                    },
                },
                {
                    name = L["A_HORDE_FOOTHOLD"],
                },
            },
            x = 4,
            y = 12,
            connections = {
                3,
            },
        },


        {
            visible = false,
            x = 0,
            y = 12.5,
        },
        {
            type = "level",
            level = 50,
            x = 6,
            y = 12.5,
            connections = {
                1,
            },
        },
        -- { -- Might be either this or the next one, depending on if you were at the ship when they became available
        --     type = "quest",
        --     id = 53064,
        --     breadcrumb = true,
        --     x = 4,
        --     y = 13,
        --     connections = {
        --         1,
        --     },
        -- },
        {
            type = "quest",
            id = 51916, -- 52451
            completed = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                },
                {
                    type = "quest",
                    id = 51916,
                },
            },
            -- completed = function (item, character)
            --     return BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and
            --     BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and
            --     BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and
            --     BtWQuests_IsQuestCompleted(51916)
            -- end,
            x = 4,
            y = 13,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 53208,
            aside = true,
            breadcrumb = true,
            x = 2,
            y = 14,
            connections = {
                3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_FIRST_ASSAULT,
            x = 4,
            y = 14,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 53209,
            aside = true,
            visible = false,
            x = 6,
            y = 14,
        },
        {
            type = "quest",
            id = 53210,
            aside = true,
            breadcrumb = true,
            x = 2,
            y = 15,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_MARSHALS_GRAVE,
            x = 4,
            y = 15,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53212,
            aside = true,
            completed = {
                type = "quest",
                id = 53220,
            },
            x = 2,
            y = 16,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DEATH_OF_A_TIDESAGE,
            x = 4,
            y = 16,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_AT_THE_BOTTOM_OF_THE_SEA,
            x = 4,
            y = 17,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_STRIKE_ON_BORALAS,
            x = 4,
            y = 18,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1,
            aside = true,
            x = 4,
            y = 19,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN_8_1"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2482729,
    range = {120,50},
    crest = "alliance",
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 7,
        -- },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN,
    },
    completed = {
        type = "quest",
        id = 54183,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 750,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_1,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_2,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_3,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_4,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54163,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54183,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN_8_1"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2482729,
    range = {120,50},
    crest = "horde",
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 7,
        -- },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN,
    },
    completed = {
        type = "quest",
        id = 54165,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 750,
        },
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_1,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_2,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_3,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_4,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54164,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54165,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN_8_1_5"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2498193,
    range = {120,50},
    crest = "alliance",
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1,
    },
    completed = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_1,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_2,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_2,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN_8_1_5"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 2498193,
    range = {120,50},
    crest = "horde",
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1,
    },
    completed = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_2,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_HIGH_OVERLORD,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_1,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_2,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_2,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_2, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN_8_2"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 3025320,
    range = {120,50},
    crest = "alliance",
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_2,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5,
    },
    completed = {
        type = "chain",
        id = Chain.Alliance825Campaign,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_2_PART_1,
            x = 3,
            connections = {1},
        },
        {
            type = "chain",
            id = Chain.Alliance825Campaign,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_2, {
    name = L["BTWQUESTS_THE_WAR_CAMPAIGN_8_2"],
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    buttonImage = 3025320,
    range = {120,50},
    crest = "horde",
    major = true,
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_2,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5,
    },
    completed = {
        type = "chain",
        ids = {Chain.Horde825SylvanasCampaign, Chain.Horde825SaurfangCampaign},
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_2_PART_1,
            x = 3,
            connections = {1}
        },
        {
            variations = {
                {
                    type = "chain",
                    id = Chain.Horde825SylvanasCampaign,
                },
                {
                    type = "chain",
                    id = Chain.Horde825SaurfangCampaign,
                },
            },
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 3)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "quest",
                    id = 51570,
                },
                {
                    type = "quest",
                    id = 51569,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51961,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 52443,
                    status = {'notactive'},
                },
            },
            -- onEval = function ()
            --     return BtWQuests_IsQuestCompleted(51570) and not BtWQuests_IsQuestActive(51569) and not BtWQuests_IsQuestActive(51961) and not BtWQuests_IsQuestActive(52443)
            -- end
        },
    },
    active = {
        type = "quest",
        id = 51570,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 51968,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1662540, 1740950, 1819355, 1897765, 1976170, 2054580, 2132990, 2211395, 2289805, 2368210, 2446620, 2523575, 2600530, 2677490, 2754445, 2831400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                54600, 56275, 57475, 59150, 60825, 62025, 63700, 65375, 66575, 68250, 69975, 71625, 72800, 74525, 76175, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 250,
        },
    },
    items = {
        {
            type = "quest",
            id = 51308,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51201,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 51191,
            x = 0,
            y = 2,
            connections = {
                5,
            },
        },
        {
            type = "quest",
            id = 51190,
            x = 2,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 51544,
            x = 3,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51192,
            x = 4,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51193,
            x = 6,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51418,
            x = 3,
            y = 4,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51331,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51309,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51359,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52003,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51968,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 2)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "quest",
                    id = 51572,
                },
                {
                    type = "quest",
                    id = 51569,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51961,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 52443,
                    status = {'notactive'},
                },
            },
            -- onEval = function ()
            --     return BtWQuests_IsQuestCompleted(51572) and not BtWQuests_IsQuestActive(51569) and not BtWQuests_IsQuestActive(51961) and not BtWQuests_IsQuestActive(52443)
            -- end
        },
    },
    active = {
        type = "quest",
        id = 51572,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 51969,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1607580, 1683400, 1759210, 1835030, 1910840, 1986660, 2062480, 2138290, 2214110, 2289920, 2365740, 2440150, 2514560, 2588980, 2663390, 2737800, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                52800, 54400, 55600, 57200, 58800, 60000, 61600, 63200, 64400, 66000, 67650, 69250, 70400, 72100, 73650, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 250,
        },
    },
    items = {
        {
            type = "quest",
            id = 51283,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51170,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51229,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51349,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51350,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51351,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51366,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51369,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3,
            },
        },

        {
            type = "quest",
            id = 51391,
            x = 1,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51394,
            x = 3,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51389,
            x = 5,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51395,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51402,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52008,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51969,
            x = 3,
            y = 11,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 1)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "quest",
                    id = 51571,
                },
                {
                    type = "quest",
                    id = 51569,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51961,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 52443,
                    status = {'notactive'},
                },
            },
            -- onEval = function ()
            --     return BtWQuests_IsQuestCompleted(51571) and not BtWQuests_IsQuestActive(51569) and not BtWQuests_IsQuestActive(51961) and not BtWQuests_IsQuestActive(52443)
            -- end
        },
    },
    active = {
        type = "quest",
        id = 51571,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 51967,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1525140, 1597070, 1668995, 1740925, 1812850, 1884780, 1956710, 2028635, 2100565, 2172490, 2244420, 2315015, 2385610, 2456210, 2526805, 2597400, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                53400, 55075, 56175, 57850, 59525, 60625, 62300, 63975, 65075, 66750, 68425, 70075, 71200, 72875, 74525, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 250,
        },
    },
    items = {
        {
            type = "quest",
            id = 51088,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51129,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51167,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51150,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51168,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51169,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51281,
            x = 3,
            y = 5,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51279,
            x = 2,
            y = 6,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51280,
            x = 4,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51282,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51177,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52013,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51967,
            x = 3,
            y = 10,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_ON_THE_SAND, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 4)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_VOLDUN,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_FIRST_ASSAULT,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
                },
                {
                    type = "quest",
                    id = 51918,
                },
            },
            -- onEval = function (item, character)
            --     return BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD) and
            --     BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD) and
            --     BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD) and
            --     BtWQuests_IsQuestCompleted(51918)
            -- end,
        },
        {
            type = "level",
            level = 50,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 5,
        -- },
    },
    active = {
        type = "quest",
        id = 52026,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 52146,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                3550800, 3563760, 3576720, 3589680, 3602640, 3615600, 3628560, 3641520, 3654480, 3667440, 3680400, 3693120, 3705840, 3718560, 3731280, 3744000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
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
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 1850,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 52026,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52027,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_VOLDUN_CHAIN14,
            embed = true,
            aside = true,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 52028,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52029,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52030,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52031,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52032,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 52034,
            x = 1,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52035,
            x = 3,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52036,
            x = 5,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52038,
            x = 3,
            y = 8,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52039,
            x = 2,
            y = 9,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52040,
            x = 4,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52041,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52042,
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52146,
            x = 3,
            y = 12,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CHASING_DARKNESS, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 5)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZMIR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_MARSHALS_GRAVE,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_ON_THE_SAND,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 5,
        --     amount = 4500,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53069,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52147,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 52219,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2370900, 2401800, 2432700, 2463600, 2494500, 2525400, 2564280, 2603160, 2642040, 2680920, 2719800, 2758680, 2797560, 2836440, 2875320, 2914200, 2953080, 2991960, 3030840, 3069720, 3108600, 3146760, 3184920, 3223080, 3261240, 3299400, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                10300, 10700, 11100, 11500, 11900, 12400, 12800, 13200, 13600, 14000, 14400, 14800, 15200, 15600, 16000, 16400, 16800, 17200, 17600, 18000, 18400, 18800, 19200, 19600, 20000, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 1030,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 1450,
            restrictions = 924,
        },
        {
            type = "reputation",
            id = 2163,
            amount = 250,
        },
    },
    items = {
        {
            type = "quest",
            id = 53069,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52147,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },

        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN12,
            embed = true,
            aside = true,
            x = 0,
            y = 2,
        },
        {
            type = "quest",
            id = 52150,
            x = 3,
            y = 2,
            connections = {
                2, 3,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZMIR_CHAIN13,
            embed = true,
            aside = true,
            x = 6,
            y = 2,
        },

        {
            type = "quest",
            id = 52156,
            x = 2,
            y = 3,
            connections = {
                2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 52158,
            x = 4,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },

        {
            type = "quest",
            id = 52170,
            x = 1,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52171,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52172,
            x = 5,
            y = 4,
            connections = {
                1,
            },
        },

        {
            type = "quest",
            id = 52208,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52219,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_A_GOLDEN_OPPORTUNITY, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 6)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DEATH_OF_A_TIDESAGE,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CHASING_DARKNESS,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 6,
        --     amount = 3000,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53070,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52154,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 52261,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 1250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 53070,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52154,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52173,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 52205,
            x = 1,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52204,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52203,
            x = 5,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52241,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52247,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52259,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52260,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52261,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_IN_THE_WATER, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 7)
    end,
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_AT_THE_BOTTOM_OF_THE_SEA,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_A_GOLDEN_OPPORTUNITY,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 6,
        --     amount = 7500,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53071,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52308,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 52496,
    },
    rewards = {
        {
            name = L["DUNGEON_KINGS_REST"],
        },
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 1250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 53071,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52308,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52489,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52490,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52491,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52492,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 52493,
            x = 1,
            y = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52494,
            x = 3,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53131,
            x = 5,
            y = 5,
        },
        {
            type = "quest",
            id = 52495,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52496,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_THE_STRIKE_ON_ZULDAZAR, {
    name = function ()
        return GetAchievementCriteriaInfo(ALLIANCE_CAMPAIGN_ACHIEVEMENT_ID, 8)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_ZULDAZAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_STRIKE_ON_BORALAS,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_IN_THE_WATER,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 7,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53072,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52473,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 52790,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2159,
            amount = 1700,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "quest",
            id = 53072,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52473,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52282,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52281,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52283,
            x = 2,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52284,
            x = 4,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52285,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52290,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 52286,
            x = 1,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52287,
            x = 3,
            y = 7,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52288,
            x = 5,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52289,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52291,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52788,
            x = 3,
            y = 10,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52789,
            x = 3,
            y = 11,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52790,
            x = 3,
            y = 12,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53098,
            aside = true,
            x = 3,
            y = 13,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 2)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_ZULDAZAR_FOOTHOLD,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "quest",
                    id = 51800,
                },
                {
                    type = "quest",
                    id = 51803,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51979,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 52444,
                    status = {'notactive'},
                },
            },
            -- onEval = function ()
            --     return BtWQuests_IsQuestCompleted(51803) and not BtWQuests_IsQuestActive(51979) and not BtWQuests_IsQuestActive(51961) and not BtWQuests_IsQuestActive(52444)
            -- end
        },
    },
    active = {
        {
            type = "quest",
            id = 51421,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51984,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1264080, 1323700, 1383310, 1442930, 1502540, 1562160, 1621780, 1681390, 1741010, 1800620, 1860240, 1918750, 1977260, 2035780, 2094290, 2152800, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                37200, 38250, 39250, 40300, 41350, 42350, 43400, 44450, 45450, 46500, 47650, 48750, 49600, 50850, 51850, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 250,
        },
    },
    items = {
        {
            type = "quest",
            id = 51421,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51435,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51436,
            x = 3,
            y = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51437,
            x = 2,
            y = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 51439,
            x = 4,
            y = 4,
            connections = {
                1, 2,
            },
        },

        {
            type = "quest",
            id = 51440,
            x = 2,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51441,
            x = 4,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51442,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51438,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51975,
            x = 3,
            y = 8,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51984,
            x = 3,
            y = 9,
            connections = {
                1,
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 1)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_DRUSTVAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_VOLDUN_FOOTHOLD,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "quest",
                    id = 51801,
                },
                {
                    type = "quest",
                    id = 51803,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51979,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 52444,
                    status = {'notactive'},
                },
            },
            -- onEval = function ()
            --     return BtWQuests_IsQuestCompleted(51801) and not BtWQuests_IsQuestActive(51979) and not BtWQuests_IsQuestActive(51961) and not BtWQuests_IsQuestActive(52444)
            -- end
        },
    },
    active = {
        {
            type = "quest",
            id = 51332,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51985,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                568490, 604540, 640590, 676640, 712690, 748740, 794100, 839460, 884820, 930180, 975540, 2258150, 2362475, 2466805, 2571130, 2675460, 2779790, 2884115, 2988445, 3092770, 3197100, 3300575, 3402970, 3505370, 3607765, 3710160, 2106000, 
            },
            minLevel = 25,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                46750, 47250, 47850, 48350, 48950, 49500, 50000, 50600, 51100, 51600, 52200, 53675, 55075, 56550, 58025, 59425, 60900, 62375, 63775, 65250, 66875, 68325, 69600, 71225, 72675, 
            },
            minLevel = 25,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 595,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 750,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 51332,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51340,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51224,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51231,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51233,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51234,
            x = 3,
            y = 6,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53456,
            x = 0,
            y = 7,
        },
        {
            type = "quest",
            id = 51987,
            x = 2,
            y = 7,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 53458,
            x = 4,
            y = 7,
        },
        {
            type = "quest",
            id = 53459,
            x = 6,
            y = 7,
        },
        {
            type = "quest",
            id = 51985,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 3)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_NAZMIR_FOOTHOLD,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 35,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "quest",
                    id = 51802,
                },
                {
                    type = "quest",
                    id = 51803,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 51979,
                    status = {'notactive'},
                },
                {
                    type = "quest",
                    id = 52444,
                    status = {'notactive'},
                },
            },
            -- onEval = function ()
            --     return BtWQuests_IsQuestCompleted(51802) and not BtWQuests_IsQuestActive(51979) and not BtWQuests_IsQuestActive(51961) and not BtWQuests_IsQuestActive(52444)
            -- end
        },
    },
    active = {
        {
            type = "quest",
            id = 51526,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51986,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1690020, 1769730, 1849425, 1929135, 2008830, 2088540, 2168250, 2247945, 2327655, 2407350, 2487060, 2565285, 2643510, 2721750, 2799975, 2878200, 
            },
            minLevel = 35,
            maxLevel = 50,
        },
        {
            type = "experience",
            amounts = {
                48600, 50075, 51175, 52650, 54125, 55225, 56700, 58175, 59275, 60750, 62275, 63675, 64800, 66325, 67725, 
            },
            minLevel = 35,
            maxLevel = 49,
        },
        {
            type = "currency",
            id = 1553,
            amount = 480,
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
            type = "quest",
            id = 51526,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51532,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51643,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51536,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51587,
            x = 3,
            y = 4,
            connections = {
                1, 2, 3,
            },
        },


        {
            type = "quest",
            id = 51675,
            x = 1,
            y = 5,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51691,
            x = 3,
            y = 5,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51674,
            x = 5,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51696,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51753,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51986,
            x = 3,
            y = 8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY_CHAIN13,
            embed = true,
            aside = true,
            x = 0,
            y = 10,
        }
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_FIRST_ASSAULT, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 4)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_ON_THE_SAND,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            completed = {
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD,
                },
                {
                    type = "chain",
                    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD,
                },
                {
                    type = "quest",
                    id = 51916,
                },
            },
            -- onEval = function (item, character)
            --     return BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_TIRAGARDE_SOUND_FOOTHOLD) and
            --     BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DRUSTVAR_FOOTHOLD) and
            --     BtWQuests_IsChainCompleted(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_STORMSONG_VALLEY_FOOTHOLD) and
            --     BtWQuests_IsQuestCompleted(51916)
            -- end,
        },
        {
            type = "level",
            level = 50,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 5,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 51589,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51601,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 3042000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 1550,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 51589,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51590,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51591,
            x = 3,
            y = 2,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 51592,
            x = 2,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51593,
            x = 4,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51594,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51595,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 51596,
            x = 1,
            y = 6,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51597,
            x = 3,
            y = 6,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51598,
            x = 5,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51599,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51601,
            x = 3,
            y = 8,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_MARSHALS_GRAVE, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 5)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_DRUSTVAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CHASING_DARKNESS,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_FIRST_ASSAULT,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 5,
        --     amount = 4500,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53065,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51784,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 51789,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 1450800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 950,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 53065,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51784,
            x = 3,
            y = 1,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 51785,
            x = 1,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51786,
            x = 3,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51787,
            x = 5,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51788,
            x = 3,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51789,
            x = 3,
            y = 4,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DEATH_OF_A_TIDESAGE, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 6)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_STORMSONG_VALLEY,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_A_GOLDEN_OPPORTUNITY,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_MARSHALS_GRAVE,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 6,
        --     amount = 3000,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53066,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 51797,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 52122,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 1250,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 53066,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51797,
            x = 3,
            y = 1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51798,
            x = 3,
            y = 2,
            connections = {
                1, 2, 3,
            },
        },


        {
            type = "quest",
            id = 51805,
            x = 1,
            y = 3,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 51818,
            x = 3,
            y = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 51819,
            x = 5,
            y = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51830,
            x = 3,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 51837,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52122,
            x = 3,
            y = 6,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_AT_THE_BOTTOM_OF_THE_SEA, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 7)
    end,
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_BLOOD_IN_THE_WATER,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_DEATH_OF_A_TIDESAGE,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 6,
        --     amount = 7500,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53067,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52764,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 52978,
    },
    rewards = {
        {
            name = L["DUNGEON_SIEGE_OF_BORALUS"],
        },
        {
            type = "money",
            amounts = {
                2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 2620800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 1250,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 53067,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52764,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52765,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52766,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52767,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52768,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52769,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52770,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52772,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52773,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52774,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53121,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52978,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_STRIKE_ON_BORALAS, {
    name = function ()
        return GetAchievementCriteriaInfo(HORDE_CAMPAIGN_ACHIEVEMENT_ID, 8)
    end,
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_THE_STRIKE_ON_ZULDAZAR,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_AT_THE_BOTTOM_OF_THE_SEA,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 7,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53068,
            status = {'active', 'completed'},
        },
        {
            type = "quest",
            id = 52183,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 53003,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 2714400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 800,
        },
        {
            type = "reputation",
            id = 2157,
            amount = 1700,
            restrictions = 923,
        },
    },
    items = {
        {
            type = "quest",
            id = 53068,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52183,
            x = 3,
            y = 1,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 52186,
            x = 2,
            y = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52187,
            x = 4,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52185,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 52184,
            x = 1,
            y = 4,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52189,
            x = 3,
            y = 4,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52188,
            x = 5,
            y = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52190,
            x = 3,
            y = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52990,
            x = 3,
            y = 6,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52191,
            x = 3,
            y = 7,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52192,
            x = 3,
            y = 8,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53003,
            x = 2,
            y = 9,
        },
        {
            type = "quest",
            id = 52861,
            aside = true,
            x = 4,
            y = 9,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_1, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13467, 1),
    -- BtWQuests_GetAchievementNameDelayed(13384), -- Kul Tirans Don't Look at Explosions
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_1,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_THE_STRIKE_ON_ZULDAZAR,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 7,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53986,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 53887,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 2450,
        },
    },
    items = {
        {
            type = "quest",
            id = 53986,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53888,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53896,
            x = 3,
            connections = {
                1, 3, 4, 5,
            },
        },
        {
            type = "quest",
            id = 53909,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53916,
            x = 0,
            connections = {
                4, 5,
            },
        },
        {
            type = "quest",
            id = 53910,
            x = 2,
            connections = {
                3, 4,
            },
        },
        {
            type = "quest",
            id = 54519,
            x = 4,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 54518,
            x = 6,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 53978,
            x = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 54787,
            x = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54559,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53919,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53936,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54703,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53887,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_2, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13467, 2),
    -- name = { -- The Embiggining
    --     type = "quest",
    --     id = 54203,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_2,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_1,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 7,
        --     amount = 7000,
        -- },
    },
    active = {
        {
            type = "quest",
            ids = {54191, 54192},
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 54206,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 2465,
        },
    },
    items = {
        {
            type = "quest",
            id = 54191,
            breadcrumb = true,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54192,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54193,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54194,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54195,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54196,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54197,
            x = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54198,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54199,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54200,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54201,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54202,
            x = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54203,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54204,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54205,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54206,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_3, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13467, 3),
    -- name = { -- The Abyssal Scepter
    --     type = "quest",
    --     id = 54171,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_3,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_2,
        },
        -- {
        --     type = "reputation",
        --     id = 2159,
        --     standing = 7,
        --     amount = 14000,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 54171,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 54169,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 750,
        },
    },
    items = {
        {
            type = "quest",
            id = 54171,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54169,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54510,
            aside = true,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_4, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13467, 4),
    -- name = {
    --     type = "quest",
    --     id = 54302,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_4,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_3,
        },
    },
    active = {
        {
            type = "quest",
            id = 54302,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 54485,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 3650,
        },
    },
    items = {
        {
            type = "quest",
            id = 54302,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54303,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54310,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54404,
            x = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54312,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54407,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54412,
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 54417,
            x = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 54421,
            x = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54418,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54441,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54459,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54485,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_1, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13466, 1),
    -- name = { -- Our War Continues
    --     type = "quest",
    --     id = 53850,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_1,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_STRIKE_ON_BORALAS,
        },
    },
    active = {
        {
            type = "quest",
            ids = {
                53850, 53851,
            },
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 53981,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 250,
        },
    },
    items = {
        {
            type = "quest",
            ids = {
                53851, 53850,
            },
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53852,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53856,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 53879,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 53880,
            x = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53913,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53912,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53973,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53981,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_2, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13466, 2),
    -- name = { -- A Mech for a Goblin
    --     type = "quest",
    --     id = 53941,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_2,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_1,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 7,
        --     amount = 7000,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 53941,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 54094,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1300,
        },
    },
    items = {
        {
            type = "quest",
            id = 53941,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54123,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54124,
            x = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53942,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54128,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54004,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54007,
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 54008,
            x = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 54009,
            x = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54022,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54028,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54094,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_3, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13466, 3),
    -- name = { -- Breaking Out Ashvane
    --     type = "quest",
    --     id = 54121,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_3,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_2,
        },
        -- {
        --     type = "reputation",
        --     id = 2157,
        --     standing = 7,
        --     amount = 14000,
        -- },
    },
    active = {
        {
            type = "quest",
            id = 54121,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 54179,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1250,
        },
    },
    items = {
        {
            type = "quest",
            id = 54121,
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 54175,
            x = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 54176,
            x = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54177,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54178,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54179,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_4, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(13466, 4),
    -- name = { -- The Fall of Zuldazar
    --     type = "quest",
    --     id = 54302,
    -- },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_TIRAGARDE_SOUND,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    major = true,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_4,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_3,
        },
    },
    active = {
        {
            type = "quest",
            id = 54139,
            status = {'active', 'completed'},
        },
    },
    completed = {
        type = "quest",
        id = 54280,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 4000,
        },
    },
    items = {
        {
            type = "quest",
            id = 54139,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54140,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54157,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54156,
            x = 4,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54207,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54211,
            x = 2,
            connections = {
                2,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 54208,
                    restrictions = {
                        type = "class",
                        id = BtWQuests.Constant.Class.Rogue
                    },
                },
                {
                    type = "quest",
                    id = 54212,
                }
            },
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54213,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54224,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54244,
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 54249,
            x = 1,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 54269,
            x = 3,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54270,
            x = 5,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54271,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54275,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54280,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54282,
            aside = true,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_1, {
    name = { -- My Brother's Keeper
        type = "quest",
        id = 55045,
    },
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_1,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_4,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_PART_4,
    },
    completed = {
        type = "quest",
        id = 55045,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 1684800, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 750,
        },
        {
            type = "currency",
            id = 1560,
            amount = 20,
        },
    },
    items = {
        {
            type = "quest",
            id = 55118,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 55033,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 55117,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55116,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55119,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55044,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55045,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_2, {
    name = { -- A Gathering of Foes
        type = "quest",
        id = 55090,
    },
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_2,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_1,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_1,
    },
    completed = {
        type = "quest",
        id = 55090,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 1474200, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 750,
        },
    },
    items = {
        {
            type = "quest",
            id = 55171,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55087,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55179,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 55088,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 55182,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55183,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55185,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55089,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55090,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_HIGH_OVERLORD, {
    name = { -- The High Overlord
        type = "quest",
        id = 54099,
    },
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_1,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_4,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_PART_4,
    },
    completed = {
        type = "quest",
        ids = {54109, 54754},
    },
    rewards = {
        {
            type = "toy",
            id = 165791,
        },
        {
            type = "money",
            amounts = {
                1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 1638000, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
    },
    items = {
        {
            type = "quest",
            id = 54097,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54099,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54100,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54101,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54102,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54103,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54104,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54105,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54106,
            x = 3,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 54754,
                    restrictions = BtWQuestsItem_ActiveOrCompleted,
                },
                {
                    type = "quest",
                    id = 54107,
                },
            },
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54108,
            visible = Restrictions.SidedWithSaurfang,
            -- {
            --     {
            --         type = "quest",
            --         id = 54754,
            --         status = {'notactive'},
            --     },
            --     {
            --         type = "quest",
            --         id = 54754,
            --         status = {'notcompleted'},
            --     },
            -- },
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54109,
            visible = Restrictions.SidedWithSaurfang,
            -- visible = {
            --     {
            --         type = "quest",
            --         id = 54754,
            --         status = {'notactive'},
            --     },
            --     {
            --         type = "quest",
            --         id = 54754,
            --         status = {'notcompleted'},
            --     },
            -- },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_1, {
    name = { -- Righting Wrongs
        type = "quest",
        id = 55124,
    },
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_1,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_HIGH_OVERLORD,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_THE_HIGH_OVERLORD,
    },
    completed = {
        type = "quest",
        ids = {
            54999, 55034,
        },
    },
    rewards = {
        {
            type = "money",
            amounts = {
                1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 1193400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 750,
        },
        {
            type = "currency",
            id = 1560,
            amount = 20,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 54961,
                    restrictions = Restrictions.SidedWithSylvanas,
                    -- { -- For The Queen
                    --     type = "quest",
                    --     id = 54754
                    -- },
                },
                {
                    type = "quest",
                    id = 55124,
                }
            },
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54958,
            x = 3,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 54959,
            x = 2,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 54997,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 54960,
            x = 3,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55034,
                    restrictions = Restrictions.SidedWithSylvanasRightingWrongsOnwards,
                    -- restrictions = { -- For The Queen
                    --     type = "quest",
                    --     id = 54754
                    -- },
                },
                {
                    type = "quest",
                    id = 54999,
                },
            },
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_2, {
    name = { -- A Display of Power
        type = "quest",
        id = 55051,
    },
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {10,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_1_5_PART_2,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_1,
        },
    },
    active = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_1_5_PART_1,
    },
    completed = {
        type = "quest",
        id = 55051,
    },
    rewards = {
        {
            type = "money",
            amounts = {
                608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 608400, 
            },
            minLevel = 10,
            maxLevel = 50,
        },
        {
            type = "currency",
            id = 1553,
            amount = 750,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 55052,
                    restrictions = Restrictions.SidedWithSylvanasRightingWrongsOnwards,
                    -- restrictions = { -- For The Queen
                    --     type = "quest",
                    --     id = 54754
                    -- },
                },
                {
                    type = "quest",
                    id = 55047,
                },
            },
            x = 3,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 55048,
            x = 1,
            connections = {
               3
            },
        },
        {
            type = "quest",
            id = 55049,
            connections = {
               2
            },
        },
        {
            type = "quest",
            id = 55050,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55051,
            x = 3,
        },
    },
})


BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_2_PART_1, {
    name = { -- Stay of Execution
        type = "quest",
        id = 55783,
    },
    questline = 972,
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_2_PART_1,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN01,
        },
    },
    active = {
        type = "quest",
        id = 55784,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 55783,
    },
    rewards = {
        {
            type = "currency",
            id = 1553,
            amount = 1000,
        },
    },
    items = {
        {
            type = "quest",
            id = 55784,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 55783,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_2_PART_1, {
    name = { -- Stay of Execution
        type = "quest",
        id = 55779,
    },
    questline = 973,
    category = nil,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_2_PART_1,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN02,
        },
    },
    active = {
        type = "quest",
        id = 55778,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {55779, 55782},
    },
    items = {
        {
            type = "quest",
            id = 55778,
            x = 3,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55780,
                    restrictions = Restrictions.SidedWithSylvanasRightingWrongsOnwards,
                    -- restrictions = { -- For The Queen
                    --     type = "quest",
                    --     id = 54754
                    -- },
                },
                {
                    type = "quest",
                    id = 55781,
                },
            },
            x = 3,
            connections = {
                1,
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 55782,
                    restrictions = Restrictions.SidedWithSylvanasStayOfExecutionOnwards,
                    -- restrictions = { -- For The Queen
                    --     type = "quest",
                    --     id = 54754
                    -- },
                },
                {
                    type = "quest",
                    id = 55779,
                },
            },
            x = 3,
        },
    },
})

-- Not sure what to do with these really
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_2_FOLLOWER, {
    name = { -- The Missing Crew
        type = "quest",
        id = 55783,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_2_FOLLOWER,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03,
        },
    },
    active = {
        type = "quest",
        id = 56378,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56378,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN03,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 135681,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56378,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_2_FOLLOWER, {
    name = { --The Missing Crew
        type = "quest",
        id = 55779,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_NAZJATAR,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_2_FOLLOWER,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04,
        },
    },
    active = {
        type = "quest",
        id = 56379,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 56379,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_NAZJATAR_CHAIN04,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "npc",
            id = 135690,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 56379,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(Chain.Alliance825Campaign, {
    name = { -- The Price of Victory
        type = "quest",
        id = 56993,
    },
    questline = 1004,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        Chain.Horde825SylvanasCampaign,
        Chain.Horde825SaurfangCampaign,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_8_2_PART_1,
        }
    },
    active = {
        type = "quest",
        id = 56494,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57002,
    },
    items = {
        {
            type = "npc",
            id = 135614,
            x = 3,
            y = 0,
            connections = {1}
        },
        {
            type = "quest",
            id = 56494,
            x = 3,
            connections = {1}
        },
        {
            type = "quest",
            id = 56719,
            x = 3,
            connections = {1,2,3}
        },
        {
            type = "quest",
            id = 56979,
            x = 1,
            connections = {3},
        },
        {
            type = "quest",
            id = 56980,
            connections = {2},
        },
        {
            type = "quest",
            id = 56981,
            connections = {1},
        },
        {
            type = "quest",
            id = 56982,
            x = 3,
            connections = {1},
        },
        {
            type = "quest",
            id = 56993,
            x = 3,
            connections = {1},
        },
        {
            type = "quest",
            id = 57002,
            x = 3,
        },
    },
})
-- When displaying both the Sylvannas and Saurfang versions, put the Sylvannas one first
BtWQuestsDatabase:AddChain(Chain.Horde825SaurfangCampaign, {
    name = { -- The Price of Victory
        type = "quest",
        id = 56993,
    },
    questline = 1003,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        Chain.Alliance825Campaign,
        Chain.Horde825SylvanasCampaign,
    },
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
        -- {
        --     type = "quest",
        --     id = 54107, -- Sided with Saurfang
        -- },
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_2_PART_1,
        }
    },
    active = {
        type = "quest",
        id = 56496,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57095,
    },
    items = {
        {
            type = "npc",
            id = 155789,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56496,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57088,
            x = 3,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 57090,
            x = 1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 57091,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 57092,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57093,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57094,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57095,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.Horde825SylvanasCampaign, {
    name = { -- The Price of Victory
        type = "quest",
        id = 56993,
    },
    questline = 1003,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        Chain.Alliance825Campaign,
        Chain.Horde825SaurfangCampaign,
    },
    restrictions = {
        {
            type = "faction",
            id = BTWQUESTS_FACTION_ID_HORDE,
        },
        Restrictions.SidedWithSylvanasStayOfExecutionOnwards,
        -- {
        --     type = "quest",
        --     id = 54754, -- Sided with Sylvanas
        -- },
    },
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_8_2_PART_1,
        }
    },
    active = {
        type = "quest",
        id = 56495,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {57095, 57152},
        count = 1,
    },
    items = {
        {
            type = "npc",
            id = 135691,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56495,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 56833,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 57147,
            visible = {
                type = "quest",
                id = 55620,
                status = {
                    "notcompleted",
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57088,
                    restrictions = {
                        type = "quest",
                        id = 55620,
                        status = {
                            "notcompleted",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 57130,
                    y = 4,
                },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57090,
                    restrictions = {
                        type = "quest",
                        id = 55620,
                        status = {
                            "notcompleted",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 57148,
                },
            },
            x = -2,
            connections = {
                3, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57091,
                    restrictions = {
                        type = "quest",
                        id = 55620,
                        status = {
                            "notcompleted",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 57149,
                },
            },
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57092,
                    restrictions = {
                        type = "quest",
                        id = 55620,
                        status = {
                            "notcompleted",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 57151,
                },
            },
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57093,
                    restrictions = {
                        type = "quest",
                        id = 55620,
                        status = {
                            "notcompleted",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 57150,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 57094,
                    restrictions = {
                        type = "quest",
                        id = 55620,
                        status = {
                            "notcompleted",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 57152,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57095,
            visible = {
                type = "quest",
                id = 55620,
                status = {
                    "notcompleted",
                },
            },
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddChain(Chain.Alliance825Calia, {
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        Chain.Horde825Calia,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            id = Chain.Alliance825Campaign,
        },
    },
    active = {
        type = "quest",
        id = 57126,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57126,
    },
    items = {
        {
            type = "npc",
            id = 150633,
            x = 3,
            y = 0,
            connections = {1},
        },
        {
            type = "quest",
            id = 57126,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.Horde825Calia, {
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        Chain.Alliance825Calia,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            name = L["BTWQUESTS_PROGRESS_THE_WAR_CAMPAIGN"],
            type = "chain",
            ids = {Chain.Horde825SylvanasCampaign, Chain.Horde825SaurfangCampaign},
        },
    },
    active = {
        type = "quest",
        id = 57198,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57198,
    },
    items = {
        {
            type = "npc",
            id = 141961,
            x = 3,
            y = 0,
            connections = {1}
        },
        {
            type = "quest",
            id = 57198,
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddChain(Chain.Alliance83Calia, {
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        Chain.Horde83Calia,
    },
    restrictions = 924,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = Chain.Alliance825Calia,
        },
    },
    active = {
        type = "quest",
        id = 57324,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57324,
    },
    items = {
        {
            type = "npc",
            id = 150633,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57324,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(Chain.Horde83Calia, {
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {120,50},
    alternatives = {
        Chain.Alliance83Calia,
    },
    restrictions = 923,
    prerequisites = {
        {
            type = "level",
            level = 50,
        },
        {
            type = "chain",
            id = Chain.Horde825Calia,
        },
    },
    active = {
        type = "quest",
        id = 57376,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 57376,
    },
    items = {
        {
            type = "npc",
            id = 141961,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 57376,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_1_5,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_1_5,
    },

    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_CAMPAIGN_8_2,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_CAMPAIGN_8_2,
    },
})

BtWQuestsDatabase:AddMap(1161, {
    type = "chain",
    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
    restrictions = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_ALLIANCE_INTRODUCTION,
        status = {'active'},
    },
})
BtWQuestsDatabase:AddMap(1165, {
    type = "chain",
    id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
    restrictions = {
        type = "chain",
        id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_HORDE_INTRODUCTION,
        status = {'active'},
    },
})