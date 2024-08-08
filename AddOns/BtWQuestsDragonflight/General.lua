local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local Category = BtWQuests.Constant.Category.Dragonflight
local Chain = BtWQuests.Constant.Chain.Dragonflight
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.DragonflightToF
local NOT_THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.NOTDragonflightToF
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local LEVEL_RANGE = {58, 70}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 58,
    },
}

Database:AddChain(Chain.DracthyrAwaken, {
    name = BtWQuests_GetAchievementNameDelayed(15638),
    questline = 1289,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    restrictions = {
        type = "class",
        id = 13,
    },
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
    },
    active = {
        type = "quest",
        id = 64864,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = { 65613, 65101, },
    },
    items = {
        {
            type = "quest",
            id = 64864,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 64865,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64863,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64866,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64871,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65615,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 64872,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 64873,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65036,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65060,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65063,
            x = 0,
            connections = {
                3, 4, 
            },
        },
        {
            type = "npc",
            id = 184166,
            aside = true,
            x = 3,
            connections = {
                4, 
            },
        },
        {
            visible = false,
            x = -3,
        },
        {
            type = "quest",
            id = 65073,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65074,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65071,
            aside = true,
        },
        {
            type = "quest",
            id = 65307,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66324,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65075,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 65045,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        {
            type = "quest",
            id = 72263,
        },
        {
            type = "quest",
            id = 65049,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 65050,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 65046,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65052,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65057,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65701,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65084,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65087,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65097,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65098,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 65100,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 65286,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 66237,
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
                    id = 66513,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 66534,
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
                    id = 66577,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65437,
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
                    id = 65101,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 65613,
                },
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.DragonIslesEmissary, {
    name = L["DRAGON_ISLES_EMISSARY"],
    questline = 1367,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 71232,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72585,
    },
    items = {
        {
            name = "Not sure if this is really needed in the addon, or what exactly the requirements are, check vod?",
        },
        {
            type = "npc",
            id = 187678,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 71232,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72585,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70750,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72068,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72373,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72374,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72375,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheMotherOathstone, {
    name = L["THE_MOTHER_OATHSTONE"],
    questline = 1333,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            variations = {
                { level = 58, restrictions = THREADS_OF_FATE_RESTRICTION, },
                { level = 66, },
            },
        },
        {
            type = "achievement",
            id = 16336,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.Thaldraszus.ValdrakkenCityOfDragons,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.Thaldraszus.TimeManagement,
            lowPriority = true,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
        {
            type = "chain",
            id = Chain.Thaldraszus.BigTimeAdventurer,
            restrictions = NOT_THREADS_OF_FATE_RESTRICTION,
        },
    },
    completed = {
        type = "quest",
        id = 72380,
    },
    items = {
        {
            type = "npc",
            id = 187678,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70437,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66675,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67073,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66847,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72380,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheSparkOfIngenuity, {
    name = L["SPARK_OF_INGENUITY"],
    questline = 1390,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        ids = {70846, 72773, 70180,},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 70900,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 70846,
                    restrictions = {
                        type = "quest",
                        id = 70846,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 72773,
                    restrictions = {
                        type = "quest",
                        id = 72773,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 196066,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70180,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70845,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70181,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70182,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70633,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72783,
            aside = true,
            x = -1,
        },
        {
            type = "quest",
            id = 70339,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70376,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70341,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70650,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70509,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70621,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70510,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70881,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70899,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70900,
            x = 0,
        },
    }
})
Database:AddChain(Chain.DragonShardOfKnowledge, {
    name = L["DRAGON_SHARD_OF_KNOWLEDGE"],
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 58,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.TheWakingShores.IntoTheArchives,
            upto = 65686,
        }
    },
    active = {
        type = "quest",
        id = 67295,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {69979, 67298},
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 192539,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 67295,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 69946,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 67298,
        },
        {
            type = "quest",
            id = 69979,
            x = -1,
        },
    },
})
local IsAddOnLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded;
if not IsAddOnLoaded("BtWQuestsDragonflightPrologue") then
    BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
        {
            type = "chain",
            id = Chain.DracthyrAwaken,
        },
    })
end
BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
--[==[@debug@
    {
        type = "chain",
        id = Chain.DragonIslesEmissary,
    },
    {
        type = "chain",
        id = Chain.TheMotherOathstone,
    },
--@end-debug@]==]
    {
        type = "chain",
        id = Chain.TheSparkOfIngenuity,
    },
    {
        type = "chain",
        id = Chain.DragonShardOfKnowledge,
    },
})

-- The Forbidden Reach
Database:AddMapRecursive(2107, {
    type = "chain",
    id = Chain.DracthyrAwaken,
})
