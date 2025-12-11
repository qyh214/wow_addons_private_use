if select(4, GetBuildInfo()) < 100007 then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local Chain = BtWQuests.Constant.Chain.Dragonflight
local LEVEL_RANGE = {70, 70}

Database:AddChain(Chain.OldHatreds, {
    name = L["OLD_HATREDS"],
    questline = 1407,
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
        id = 72591,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72611,
    },
    items = {
        {
            type = "npc",
            id = 202656,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72591,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72592,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72593,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72595,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72662,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74946,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72594,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72663,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72599,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72600,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72601,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72602,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72603,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72604,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72605,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72606,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72607,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72609,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72611,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 75258,
            restrictions = false,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ReturnToTheReach, {
    name = { -- Return to the Reach
        type = "quest",
        id = 73076,
    },
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
        id = 74381,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 73156,
    },
    items = {
        {
            type = "quest",
            id = 74381,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73076,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 73157,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 74769,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 75050,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74847,
            x = 0,
            breadcrumb = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72712,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72713,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 73107,
            visible = false,
        },
        {
            type = "quest",
            id = 72545,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73094,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72715,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72714,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73137,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72717,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73156,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ZskeraVaults, {
    name = L["ZSKERA_VAULTS"],
    questline = 5359,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "quest",
            id = 73157,
        },
        {
            type = "quest",
            id = 74769,
        },
        {
            type = "quest",
            id = 75050,
        },
    },
    active = {
        type = "quest",
        id = 73160,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 73089, 74355 },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 199201,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 73160,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 201180,
            x = -3,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 73159,
            x = -1,
            connections = {
                3, 4, 5, 
            },
        },
        {
            type = "object",
            id = 385952,
            connections = {
                4, 
            },
        },
        {
            type = "npc",
            id = 201517,
            x = 3,
            aside = true,
            connections = {
                4, 
            },
        },
        {
            type = "quest",
            id = 74983,
            x = -3,
            aside = true,
        },
        {
            type = "quest",
            id = 72953,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 73155,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 74442,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 73089,
            x = -1,
            comment = "Unsure of requirement",
        },
        {
            type = "quest",
            id = 74355,
        },
        {
            type = "quest",
            id = 74443,
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 74447,
            aside = true,
            x = 3,
        },
    },
})
Database:AddChain(Chain.AcademicAcquisitions, {
    name = { -- Academic Acquisitions
        type = "quest",
        id = 72547,
    },
    questline = 5359,
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
        ids = { 72588, 72589 },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 72547,
    },
    items = {
        {
            type = "quest",
            id = 72546,
            x = 0,
            restrictions = false,
        },
        {
            type = "npc",
            id = 189401,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 72588,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 72589,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 72547,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.OldHatreds,
    },
    {
        type = "chain",
        id = Chain.ReturnToTheReach,
    },
    {
        type = "chain",
        id = Chain.ZskeraVaults,
    },
    {
        type = "chain",
        id = Chain.AcademicAcquisitions,
    },
})

