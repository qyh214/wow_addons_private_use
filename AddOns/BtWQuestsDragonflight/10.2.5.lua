if select(4, GetBuildInfo()) < 100205 then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local Chain = BtWQuests.Constant.Chain.Dragonflight
local LEVEL_RANGE = {70, 70}

Chain.SeedsOfRenewal = 100017
Chain.GilneasReclamation = 100018
Chain.AzerothianArchives = 100019
Chain.Embed01 = 100020
Chain.Embed02 = 100021
Chain.Embed03 = 100022
Chain.Embed04 = 100023
Chain.Embed05 = 100024
Chain.Embed06 = 100025

Database:AddChain(Chain.SeedsOfRenewal, {
    name = L["SEEDS_OF_RENEWAL"],
    questline = 5456,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        id = 78643,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 78864,
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
            id = 78643,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78863,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78865,
        },
        {
            type = "quest",
            id = 78864,
            x = 0,
        },
    }
})
Database:AddChain(Chain.GilneasReclamation, {
    name = BtWQuests_GetAchievementName(19719),
    questline = 5511,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
    },
    active = {
        type = "quest",
        ids = { 78596, 78597, 78177, 78178, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 79137, 78597 },
        count = 1,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 78596,
                    restrictions = {
                        type = "quest",
                        id = 78596,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "quest",
                    id = 78597,
                    restrictions = {
                        type = "quest",
                        id = 78597,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 214538,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "npc",
                    id = 210965,
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
                    id = 78177,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "quest",
                    id = 78178,
                },
            },
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78180,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78181,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78182,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78184,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78183,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78185,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 78187,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 78186,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78188,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78189,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 79137,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "quest",
                    id = 78597,
                },
            },
            x = 0,
        },
    }
})
Database:AddChain(Chain.AzerothianArchives, {
    name = L["AZEROTHIAN_ARCHIVES"],
    questline = 5528,
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
        id = 77325,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77331,
    },
    items = {
        {
            type = "object",
            id = 405593,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77325,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Embed01,
            embed = true,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Embed02,
            embed = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77327,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76217,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76241,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76242,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77328,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79223,
            x = 0,
            connections = {
                1, 2, 3, 4, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Embed04,
            embed = true,
            x = -3,
            connections = {
                4, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Embed05,
            embed = true,
            connections = {
                3, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Embed03,
            embed = true,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.Dragonflight.Embed06,
            embed = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 79231,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77331,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Embed01, {
    name = { -- Technoscrying 101
        type = "quest",
        id = 77231,
    },
    questline = 5528,
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
        id = 77231,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75868,
    },
    items = {
        {
            type = "npc",
            id = 208355,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77231,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77166,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77176,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77434,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75729,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75867,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75868,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Embed02, {
    name = { -- Excavation 101
        type = "quest",
        id = 77267,
    },
    questline = 5528,
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
        id = 77267,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75603,
    },
    items = {
        {
            type = "npc",
            id = 208614,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77267,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78762,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77268,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77433,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 75493,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75518,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75603,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Embed03, {
    name = { -- Excavation: Gaze of Neltharion
        type = "quest",
        id = 77486,
    },
    questline = 5528,
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
        id = 77486,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 75604,
    },
    items = {
        {
            type = "npc",
            id = 208614,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77486,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76026,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76032,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75604,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Embed04, {
    name = { -- Excavation: Winglord's Perch
        type = "quest",
        id = 77487,
    },
    questline = 5528,
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
        id = 77487,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77154,
    },
    items = {
        {
            type = "npc",
            id = 208614,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77487,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77100,
            breadcrumb = true,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77151,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77154,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Embed05, {
    name = { -- Technoscrying: Dragonskull Island
        type = "quest",
        id = 77483,
    },
    questline = 5528,
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
        id = 77483,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77415,
    },
    items = {
        {
            type = "npc",
            id = 208355,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77483,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76448,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76557,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77415,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Embed06, {
    name = { -- Technoscrying: Igira's Watch
        type = "quest",
        id = 77484,
    },
    questline = 5528,
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
        id = 77484,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 77425,
    },
    items = {
        {
            type = "npc",
            id = 208355,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77484,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76564,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 76576,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 77425,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.SeedsOfRenewal,
    },
    {
        type = "chain",
        id = Chain.GilneasReclamation,
    },
    {
        type = "chain",
        id = Chain.AzerothianArchives,
    },
})
