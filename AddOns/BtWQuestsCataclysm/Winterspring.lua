local MAP_ID = 83
local ACHIEVEMENT_ID = 4940
local CONTINENT_ID = 12

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_THE_WINTERFALL_FURBOLG, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 1),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28464,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28472,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN3,
            x = 0,
            y = 0,
            embed = true,
            aside = true,
        },
        {
            type = "npc",
            id = 9298,
            x = 2,
            y = 0,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN4,
            x = 4,
            y = 0,
            embed = true,
            aside = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN5,
            x = 6,
            y = 0,
            embed = true,
            aside = true,
        },
        {
            type = "quest",
            id = 28464,
            x = 2,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28467,
            x = 2,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28530,
            x = 1,
        },
        {
            type = "quest",
            id = 28469,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28470,
            x = 2,
        },
        {
            type = "quest",
            id = 28471,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28472,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_RUINS_OF_KELTHERIL, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 2),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28479,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28848,
    },
    items = {
        {
            type = "npc",
            id = 10920,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28479,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28513,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28534,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28518,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28535,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28519,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28536,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28537,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28848,
            x = 3,
            connections = {
                
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_SUPERIOR_WEAPONS, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 3),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28609,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28628,
    },
    items = {
        {
            type = "npc",
            id = 48965,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28609,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28610,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28618,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28624,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28625,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28626,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28627,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28632,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_YETI_SURPRISE,
        },
        {
            type = "quest",
            id = 28628,
            x = 3,
            connections = {
                
            },
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_SPRAY_IT_AND_SLAY_IT, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 4),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {28674, 28676, 28701, 28703},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28710,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28674,
                    restrictions = {
                        type = "quest",
                        id = 28674,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 11079,
                },
            },
            x = 0,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 28676,
                    restrictions = {
                        type = "quest",
                        id = 28676,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 49407,
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
            id = 28701,
            x = 0,
            aside = true,
        },
        {
            type = "quest",
            id = 28703,
            x = 2,
        },
        {
            type = "quest",
            id = 28706,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28707,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28710,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_THE_HUB_OF_GOODGRUBS_GRUB, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 5),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "chain",
        ids = {BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN6, BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN7, BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN8, BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN9},
        status = {'active', 'completed'},
    },
    completed = {
        type = "chain",
        ids = {BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN6, BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN7, BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN8, BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN9},
        count = 4,
    },
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN6,
            x = 0,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN7,
            x = 2,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN8,
            x = 4,
            y = 0,
            embed = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN9,
            x = 6,
            y = 0,
            embed = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_YETI_SURPRISE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 6),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "quest",
            id = 28627,
        },
    },
    active = {
        type = "quest",
        ids = {28629, 28631},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28722,
    },
    items = {
        {
            type = "npc",
            id = 10305,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 28630,
            aside = true,
            x = 1,
        },
        {
            type = "quest",
            id = 28629,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28631,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28722,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28674,
            x = 2,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_UMBRANSES_DELIVERANCE,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_JADRAGS_FATE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 7),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28829,
        status = {'active', 'completed'},
    },
    completed = {
        {
            type = "quest",
            id = 28830,
        },
        {
            type = "quest",
            id = 28831,
        },
    },
    items = {
        {
            type = "npc",
            id = 50263,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28829,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28830,
            x = 2,
        },
        {
            type = "quest",
            id = 28831,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_UMBRANSES_DELIVERANCE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID, 8),
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_JADRAGS_FATE,
        },
    },
    active = {
        type = "quest",
        id = 28847,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28842,
    },
    items = {
        {
            type = "quest",
            id = 28847,
            x = 3,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28837,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28838,
            x = 3,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28839,
            x = 3,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_JADRAGS_FATE,
            aside = true,
        },
        {
            type = "quest",
            id = 28840,
            x = 3,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 28842,
            x = 2,
        },
        {
            type = "quest",
            id = 28841,
            aside = true,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN1, {
    name = "Winterfall Village",
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {28615, 28614},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {28615, 28614},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 48723,
            x = 2,
            y = 0,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 48722,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 28615,
            x = 2,
        },
        {
            type = "quest",
            id = 28614,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN2, {
    name = { -- They Grow Up So Fast
        type = "quest",
        id = 29034,
    },
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    restrictions = {
        type = "faction",
        id = BTWQUESTS_FACTION_ID_ALLIANCE,
    },
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 29032,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 29034,
    },
    items = {
        {
            type = "npc",
            id = 10618,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 29032,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 29034,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN3, {
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28540,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28540,
    },
    items = {
        {
            type = "npc",
            id = 10307,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28540,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN4, {
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {28524, 28544, 28545, 28768, 28460},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28460,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28524,
                    restrictions = {
                        type = "quest",
                        id = 28524,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28544,
                    restrictions = {
                        type = "quest",
                        id = 28544,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28545,
                    restrictions = {
                        type = "quest",
                        id = 28545,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 28768,
                    restrictions = {
                        type = "quest",
                        id = 28768,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 9298,
                },
            },
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28460,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN5, {
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28656,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28656,
    },
    items = {
        {
            name = "Kill Furbolgs",
            breadcrumb = true,
            x = 0,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 28656,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN6, {
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28638,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28782,
    },
    items = {
        {
            type = "npc",
            id = 49537,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28638,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28745,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28782,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN7, {
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        ids = {28718, 28640},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28742,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 28718,
                    restrictions = {
                        type = "quest",
                        id = 28718,
                        status = {'active', 'completed'},
                    },
                },
                {
                    type = "npc",
                    id = 49396,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28640,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28641,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28742,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN8, {
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28828,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28828,
    },
    items = {
        {
            type = "npc",
            id = 49396,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28828,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN9, {
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    prerequisites = {
        {
            type = "level",
            level = 15,
        },
    },
    active = {
        type = "quest",
        id = 28637,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 28639,
    },
    items = {
        {
            type = "npc",
            id = 49436,
            x = 0,
            y = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28637,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28719,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 28639,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_OTHER_ALLIANCE, {
    name = "Other Alliance",
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 29033,
        },
        {
            type = "quest",
            id = 29035,
        },
        {
            type = "quest",
            id = 29037,
        },
        {
            type = "quest",
            id = 29038,
        },
        {
            type = "quest",
            id = 29040,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_OTHER_HORDE, {
    name = "Other Horde",
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_OTHER_BOTH, {
    name = "Other Both",
    category = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
    range = {15,30},
    items = {
        {
            type = "quest",
            id = 8481,
        },
        {
            type = "quest",
            id = 28523,
        },
        {
            type = "quest",
            id = 28516,
        },
        {
            type = "quest",
            id = 28522,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BtWQuests.Constant.Expansions.Cataclysm,
	buttonImage = {
		texture = 1851114,
		texCoords = {0,1,0,1},
	},
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_THE_WINTERFALL_FURBOLG,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_RUINS_OF_KELTHERIL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_SUPERIOR_WEAPONS,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_SPRAY_IT_AND_SLAY_IT,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_THE_HUB_OF_GOODGRUBS_GRUB,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_YETI_SURPRISE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_JADRAGS_FATE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_UMBRANSES_DELIVERANCE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN1,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN2,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BtWQuests.Constant.Expansions.Cataclysm, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_CLASSIC_WINTERSPRING,
})

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN9,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN6,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN4,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_CLASSIC_WINTERSPRING_CHAIN2,
    },
})
