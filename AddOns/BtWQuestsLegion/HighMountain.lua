local L = BtWQuests.L;
local MAP_ID = 650
local CONTINENT_ID = 619

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10059, 1),
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        id = 39733,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39487,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39733,
                    restrictions = {
                        type = "quest",
                        id = 39733,
                        status = {'active', 'completed'}
                    }
                },
                {
                    type = "npc",
                    id = 97666,
                },
            },
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38907,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38911,
            x = 3,
            y = 3,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 39272,
            x = 1,
            y = 4,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39491,
            x = 3,
            y = 4,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39490,
            x = 5,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39496,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 39316,
            x = 1,
            y = 6,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39614,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39277,
            x = 5,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39661,
            x = 3,
            y = 7,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 39488,
            x = 2,
            y = 8,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39489,
            x = 4,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39487,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
            aside = true,
            x = 3,
            y = 10,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10059, 2),
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
        },
    },
    active = {
        type = "quest",
        id = 39498,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 38909,
    },
    items = {
        {
            type = "npc",
            id = 96038,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39498,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42104,
            x = 3,
            y = 2,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 39025,
            x = 2,
            y = 3,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39026,
            x = 4,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39043,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39027,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38909,
            x = 3,
            y = 6,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SKYHORN_TRIBE,
            aside = true,
            x = 1,
            y = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE,
            aside = true,
            x = 3,
            y = 7,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HULNS_WAR,
            aside = true,
            x = 5,
            y = 7,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SKYHORN_TRIBE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10059, 3),
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
        },
    },
    active = {
        type = "quest",
        id = 38913,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39387,
    },
    items = {
        {
            type = "npc",
            id = 93826,
            x = 3,
            y = -1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38913,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39318,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38910,
            x = 3,
            y = 2,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 39321,
            x = 2,
            y = 3,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39429,
            x = 4,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39322,
            x = 3,
            y = 4,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SECRETS_OF_HIGHMOUNTAIN,
            aside = true,
            x = 1,
            y = 5,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39387,
            x = 3,
            y = 5,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE,
            aside = true,
            x = 5,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SNOWBLIND_MESA,
            aside = true,
            x = 3,
            y = 6,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10059, 4),
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
        },
    },
    active = {
        type = "quest",
        id = 38912,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39426,
    },
    items = {
        {
            type = "npc",
            id = 93826,
            x = 3,
            y = -1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38912,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 39372,
            x = 1,
            y = 1,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39373,
            x = 3,
            y = 1,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39873,
            x = 5,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39374,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39455,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39860,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39381,
            x = 3,
            y = 5,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 39425,
            x = 1,
            y = 6,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39391,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39588,
            x = 5,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39426,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40229,
            x = 3,
            y = 8,
            connections = {
                1, 3
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_STONEDARK,
            x = 5,
            y = 8,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SKYHORN_TRIBE,
            aside = true,
            x = 1,
            y = 9,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39456,
            aside = true,
            x = 3,
            y = 9,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SECRETS_OF_HIGHMOUNTAIN,
            aside = true,
            x = 5,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SNOWBLIND_MESA,
            aside = true,
            x = 3,
            y = 10,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HULNS_WAR, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10059, 5),
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
        },
    },
    active = {
        type = "quest",
        id = 40515,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39992,
    },
    items = {
        {
            type = "npc",
            id = 93826,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40515,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40167,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40520,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39983,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40112,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39988,
            x = 3,
            y = 6,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39990,
            x = 3,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40388,
            x = 3,
            y = 8,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39992,
            x = 3,
            y = 9,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SECRETS_OF_HIGHMOUNTAIN,
            aside = true,
            x = 3,
            y = 10,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SECRETS_OF_HIGHMOUNTAIN, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10059, 6),
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HULNS_WAR,
        },
    },
    active = {
        type = "quest",
        id = 38916,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39579,
    },
    items = {
        {
            type = "npc",
            id = 98825,
            x = 3,
            y = 0,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 38916,
            x = 3,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39575,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40219,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39578,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39577,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39579,
            x = 3,
            y = 6,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SKYHORN_TRIBE,
            aside = true,
            x = 1,
            y = 7,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39580,
            aside = true,
            x = 3,
            y = 7,
            connections = {
                2
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE,
            aside = true,
            x = 5,
            y = 7,
            connections = {
                1
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SNOWBLIND_MESA,
            aside = true,
            x = 3,
            y = 8,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SNOWBLIND_MESA, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(10059, 7),
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    major = true,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HULNS_WAR,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SKYHORN_TRIBE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SECRETS_OF_HIGHMOUNTAIN,
        },
    },
    active = {
        type = "quest",
        id = 38915,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39780,
    },
    items = {
        {
            type = "npc",
            id = 108434,
            x = 3,
            y = -1,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 38915,
            x = 3,
            y = 0,
            connections = {
                1, 2, 3
            },
        },
        {
            type = "quest",
            id = 39777,
            x = 1,
            y = 1,
            connections = {
                3
            },
        },
        {
            type = "quest",
            id = 39776,
            x = 3,
            y = 1,
            connections = {
                2
            },
        },
        {
            type = "quest",
            id = 39862,
            x = 5,
            y = 1,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42088,
            x = 3,
            y = 2,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 42512,
            x = 3,
            y = 3,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 40594,
            x = 3,
            y = 4,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39780,
            x = 3,
            y = 5,
            connections = {
                1
            },
        },
        {
            type = "quest",
            id = 39781,
            aside = true,
            x = 3,
            y = 6,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RAZIK, {
    name = { -- Critter Scatter Shot
		type = "quest",
		id = 39670,
	},
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {39386, 39670, 40000},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39656,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39386,
                    restrictions = {
                        type = "quest",
                        id = 39386,
                        status = {'active', 'completed'}
                    },
                },
                {
                    type = "npc",
                    id = 96513,
                    -- name = "Go to Razik Gazbolt",
                    -- breadcrumb = true,
                    -- onClick = function ()
                    --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5763, 0.5661, "Razik Gazbolt")
                    -- end,
                }
            },
            x = 3,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "npc",
            id = 97974,
            -- name = "Go to Lorna Stoutfoot",
            -- breadcrumb = true,
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(MAP_ID, 0.5759, 0.5641, "Lorna Stoutfoot")
            -- end,
            x = 5,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 39670,
            x = 3,
            y = 1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40000,
            x = 5,
            y = 1,
        },
        {
            type = "quest",
            id = 39656,
            x = 3,
            y = 2,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HEMET,
            aside = true,
            visible = {
                {
                    type = "quest",
                    id = 40170,
                    restrictions = {
                        type = "quest",
                        id = 39417,
                        status = {'notcompleted'}
                    },
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 40170,
                    restrictions = {
                        type = "quest",
                        id = 39417,
                        status = {'notcompleted'}
                    },
                    status = {'notcompleted'}
                }
            },
            active = {
                type = "quest",
                id = 39417,
                status = {'active', 'completed'}
            },
            x = 3,
            y = 3,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HEMET, {
    name = BtWQuests_GetAreaName(7733), -- Nesingwary's Retreat
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {39417, 40217, 40170, 39859},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {40228, 39867, 39178},
        count = 3,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39417,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39417,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40217,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40217,
                            active = true,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 39417,
                    restrictions = {
                        {
                            type = "quest",
                            id = 39417,
                        },
                    },
                },
                {
                    type = "quest",
                    id = 40217,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40217,
                        },
                    },
                },
                {
                    type = "npc",
                    id = 94409,
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
            id = 94434,
            x = 6,
            y = 0,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 40170,
            x = 2,
            y = 1,
            connections = {
                2,
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 39859,
            x = 6,
            y = 1,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 39123,
            x = 0,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 39124,
            x = 2,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 39392,
            x = 4,
            y = 2,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 40216,
            x = 6,
            y = 2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 39867,
            x = 0,
            y = 3,
        },
        {
            type = "quest",
            id = 39178,
            x = 2,
            y = 3,
        },
        {
            type = "quest",
            id = 40228,
            x = 5,
            connections = {
                1, 2,
            },
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RAZIK,
            aside = true,
            visible = {
                {
                    type = "quest",
                    id = 39670,
                    restrictions = {
                        type = "quest",
                        id = 39386,
                        status = {'notcompleted'}
                    },
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 39670,
                    restrictions = {
                        type = "quest",
                        id = 39386,
                        status = {'notcompleted'}
                    },
                    status = {'notcompleted'}
                }
            },
            active = {
                type = "quest",
                id = 39386,
                status = {'active', 'completed'}
            },
            x = 4,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_MURKY,
            aside = true,
            visible = {
                {
                    type = "quest",
                    id = 40047,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40244,
                            status = {'notcompleted'}
                        }
                    },
                    status = {'notactive'}
                },
                {
                    type = "quest",
                    id = 40047,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40244,
                            status = {'notcompleted'}
                        }
                    },
                    status = {'notcompleted'}
                },
            },
            active = {
                type = "quest",
                id = 40244,
                status = {'active', 'completed'}
            },
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_STONEDARK, {
    name = { -- You Lift, Brul?
		type = "quest",
		id = 39440,
	},
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
            lowPriority = true,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE,
            upto = 40229,
        },
    },
    active = {
        type = "quest",
        id = 39440,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 39439,
    },
    items = {
        {
            type = "npc",
            id = 95799,
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 39440,
            x = 3,
            y = 1,
            connections = {
                1,
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 39438,
            x = 1,
            y = 2,
        },
        {
            type = "quest",
            id = 39439,
            x = 3,
            y = 2,
        },
        {
            type = "quest",
            id = 39437,
            x = 5,
            y = 2,
        },
    }
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_MURKY, {
    name = { -- Murlocs: The Next Generation
		type = "quest",
		id = 40102,
	},
    category = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {10,45},
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
    },
    active = {
        type = "quest",
        ids = {40244, 40045, 40047, 40049},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 40102,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 40244,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40244,
                        }
                    },
                },
                {
                    type = "quest",
                    id = 40244,
                    restrictions = {
                        {
                            type = "quest",
                            id = 40244,
                            active = true,
                        }
                    },
                },
                {
                    type = "npc",
                    id = 98067,
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
            id = 40045,
            x = 1,
            y = 1,
            connections = {
                3,
                4,
            },
        },
        {
            type = "quest",
            id = 40047,
            x = 3,
            y = 1,
            connections = {
                2,
                3,
            },
        },
        {
            type = "quest",
            id = 40049,
            x = 5,
            y = 1,
            connections = {
                1,
                2,
            },
        },
        {
            type = "quest",
            id = 40102,
            x = 2,
            y = 2,
        },
        {
            type = "quest",
            id = 40230,
            x = 4,
            y = 2,
        },
    }
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN, {
    name = BtWQuests_GetMapName(MAP_ID),
    expansion = BTWQUESTS_EXPANSION_LEGION,
    buttonImage = 1411854,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SKYHORN_TRIBE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HULNS_WAR,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SECRETS_OF_HIGHMOUNTAIN,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SNOWBLIND_MESA,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RAZIK,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HEMET,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_STONEDARK,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_MURKY,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_HIGHMOUNTAIN,
})

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERMANE_TRIBE)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RIVERBEND)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SKYHORN_TRIBE)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_BLOODTOTEM_TRIBE)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HULNS_WAR)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SECRETS_OF_HIGHMOUNTAIN)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_SNOWBLIND_MESA)

BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RAZIK)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HEMET)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_STONEDARK)
BtWQuestsDatabase:AddQuestItemsForChain(BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_MURKY)

BtWQuestsDatabase:AddContinentItems(CONTINENT_ID, {
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_RAZIK,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_HEMET,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_MURKY,
    },
    {
        type = "chain",
        id = BTWQUESTS_CHAIN_LEGION_HIGHMOUNTAIN_STONEDARK,
    },
})
