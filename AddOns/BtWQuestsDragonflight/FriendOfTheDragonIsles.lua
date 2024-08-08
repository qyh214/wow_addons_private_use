local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.Dragonflight
local CATEGORY_ID = BtWQuests.Constant.Category.Dragonflight.Dragonflight
local Chain = BtWQuests.Constant.Chain.Dragonflight.Dragonflight
local THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.DragonflightToF
local NOT_THREADS_OF_FATE_RESTRICTION = BtWQuests.Constant.Restrictions.NOTDragonflightToF
local CONTINENT_ID = 1978
local ACHIEVEMENT_ID_1 = 16808
local LEVEL_RANGE = {70, 70}

Database:AddChain(Chain.TheChieftainsDuty, {
    name = function ()
        return GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_1, 57034)
    end,
    questline = 1385,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "currency",
            id = 2087,
            amount = 11,
        },
    },
    active = {
        type = "quest",
        id = 68640,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66444,
    },
    items = {
        { -- Dont track this quest for active since its flagged completed account bound
            type = "quest",
            id = 68863,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 68640,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66409,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66410,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66411,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66417,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66418,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66414,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66440,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66431,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66415,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66443,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66444,
            x = 0,
        },
        {
            visible = false,
            x = -3,
            y = 3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain01,
            embed = true,
            x = 3,
            y = 3,
        },
    },
})
Database:AddChain(Chain.AMysterySealed, {
    name = function ()
        return GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_1, 57032)
    end,
    questline = 1386,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "currency",
            id = 2021,
            amount = 13,
        },
    },
    active = {
        type = "quest",
        id = 66012,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66128,
    },
    items = {
        { -- Dont track this quest for active since its flagged completed account bound
            type = "quest",
            id = 69093,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66012,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66013,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66673,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 66094,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 70784,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 70785,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 70507,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 70503,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66814,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66128,
            x = 0
        },
    },
})
Database:AddChain(Chain.TheSilverPurpose, {
    name = function ()
        return GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_1, 57037)
    end,
    questline = 1389,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            name = {
                type = "currency",
                id = 2088,
                amount = 12,
            },
            type = "achievement",
            id = 16988, -- Account bound achievement for Rank 12
        }
    },
    active = {
        type = "quest",
        id = 67074,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 67084,
    },
    items = {
        { -- Dont track this quest for active since its flagged completed account bound
            type = "quest",
            id = 68794,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67074,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 70703,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67075,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67076,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67077,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67078,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67079,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67081,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67084,
            x = 0,
        },
    },
})
Database:AddChain(Chain.InTheHallsOfTitans, {
    name = function ()
        return GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_1, 57033)
    end,
    questline = 1384,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.AMysterySealed,
        },
        {
            type = "currency",
            id = 2021,
            amount = 24,
        },
    },
    active = {
        type = "quest",
        id = 67722,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66547,
    },
    items = {
        {
            type = "quest",
            id = 69097,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 67722,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66636,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66173,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66174,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 71152,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66546,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66547,
            x = 0,
            connections = {
                2, 
            },
        },
        {
            name = L["BTWQUESTS_WAIT_FOR_WEEKLY_RESET"],
            visible = {
                {
                    type = "quest",
                    id = 66547,
                },
                {
                    type = "quest",
                    id = 69888,
                    status = { "notcompleted", },
                },
            },
            completed = {
                type = "quest",
                id = 72822,
                status = { "pending", },
            },
            aside = true,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 69888,
            x = 0,
            aside = true,
        },
    }
})
Database:AddChain(Chain.GardenOfSecrets, {
    name = function ()
        return GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_1, 57035)
    end,
    questline = 1387,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.TheSilverPurpose,
        },
        {
            type = "currency",
            id = 2088,
            amount = 19,
        },
    },
    active = {
        type = "quest",
        id = 66178,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66191,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 66620,
                },
                {
                    type = "npc",
                    id = 186955,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66178,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66179,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66180,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66182,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66183,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66181,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66184,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66393,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66395,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66396,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66190,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66191,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheDreamer, {
    name = function ()
        return GetAchievementCriteriaInfoByID(ACHIEVEMENT_ID_1, 57036)
    end,
    questline = 1388,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = {
        type = "chain",
        id = Chain.GardenOfSecrets,
    },
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "chain",
            id = Chain.TheSilverPurpose,
        },
        {
            type = "currency",
            id = 2088,
            amount = 19,
        },
        {
            type = "chain",
            id = Chain.GardenOfSecrets,
        },
    },
    active = {
        type = "quest",
        id = 66392,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66402,
    },
    items = {
        {
            type = "npc",
            id = 187561,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66392,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66185,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66186,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66188,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66189,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 66394,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 66397,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66635,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66398,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66399,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66400,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66401,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66402,
            x = 0,
        },
    },
})

Database:AddChain(Chain.EmbedChain01, {
    questline = 1388,
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 70,
        },
        {
            type = "currency",
            id = 2087,
            amount = 11,
        },
    },
    active = {
        type = "quest",
        id = 66413,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 66413,
    },
    items = {
        {
            type = "object",
            id = 384405,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 66413,
            x = 0,
        },
    }
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests_GetAchievementNameDelayed(ACHIEVEMENT_ID_1),
    expansion = EXPANSION_ID,
    buttonImage = 4742925,
    items = {
        {
            type = "chain",
            id = Chain.TheChieftainsDuty,
        },
        {
            type = "chain",
            id = Chain.AMysterySealed,
        },
        {
            type = "chain",
            id = Chain.TheSilverPurpose,
        },
        {
            type = "chain",
            id = Chain.InTheHallsOfTitans,
        },
        {
            type = "chain",
            id = Chain.GardenOfSecrets,
        },
        {
            type = "chain",
            id = Chain.TheDreamer,
        },
    },
})
BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "category",
        id = CATEGORY_ID,
    },
})

Database:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = Chain.EmbedChain01,
    },
})
