local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local Category = BtWQuests.Constant.Category.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = 924, 923
local LEVEL_RANGE = {68, 80}

Chain.Introduction = 110001
Chain.Prologue = 110091

Database:AddChain(Chain.Introduction, {
    name = BtWQuests.L["Introduction"],
    questline = 5638,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 68,
        },
        {
            name = BtWQuests_GetAchievementName(40382),
            type = "chain",
            id = 100028,
            completed = {
                type = "quest",
                id = 79021,
            },
        }
    },
    active = {
        type = "quest",
        ids = { 81930, 78713 },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 82540,
    },
    items = {
        {
            variations = {
                {
                    type = "area",
                    id = 1519,
                    locations = {
                        [84] = {
                            {
                                x = 0.629261,
                                y = 0.7229,
                            },
                        },
                    },
                    restrictions = 924,
                },
                {
                    type = "area",
                    id = 1637,
                    locations = {
                        [85] = {
                            {
                                x = 0.508051,
                                y = 0.780649,
                            },
                        },
                    },
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
                    id = 81930,
                    restrictions = 924,
                },
                {
                    type = "quest",
                    id = 78713,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78714,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78715,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 78716,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 80500,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82540,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Prologue, {
    name = BtWQuests.L["Prologue"],
    questline = 0,
    expansion = EXPANSION_ID,
    range = { 10, 68 },
    major = true,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 82539,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 82540,
    },
    items = {
        {
            type = "npc",
            id = 213627,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82539,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 82540,
            x = 0,
        },
    },
})
BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.Introduction,
        restrictions = function (item, character)
            return character:GetLevel() >= 68 or GetExpansionLevel() >= 10
        end
    },
    {
        type = "chain",
        id = Chain.Prologue,
        restrictions = function (item, character)
            return character:GetLevel() < 68 and GetExpansionLevel() < 10
        end
    },
})
