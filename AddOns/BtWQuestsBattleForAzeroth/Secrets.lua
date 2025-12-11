
local L = BtWQuests.L;

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_SECRETS_BAAL, {
    name = {
        type = "pet",
        id = 2352,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_SECRETS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {50,50},
    active = {
        type = "quest",
        id = 52819,
    },
    completed = {
        type = "pet",
        id = 2352,
    },
    rewards = {
        {
            type = "pet",
            id = 2352,
        },
    },
    items = {
        {
            type = "quest",
            id = 52819,
            name = "Conspicuous Note",
            onClick = {
                type = "coords",
                mapID = 863,
                x = 0.51,
                y = 0.59,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(863, 0.51, 0.59, "Conspicuous Note")
            -- end,
            -- type = "object",
            -- id = 293849,
            -- completed = {
            --     type = "quest",
            --     id = 52819,
            -- },
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52809,
            name = "Pebble #1",
            onClick = {
                type = "coords",
                name = "Pebble #1",
                mapID = 646,
                x = 0.37,
                y = 0.71,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(646, 0.37, 0.71, "Pebble #1")
            -- end,
            -- type = "object",
            -- id = 293837,
            -- completed = {
            --     type = "quest",
            --     id = 52809,
            -- },
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52810,
            name = "Pebble #2",
            onClick = {
                type = "coords",
                name = "Pebble #2",
                mapID = 1161,
                x = 0.49,
                y = 0.40,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(1161, 0.49, 0.40, "Pebble #2")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52818,
            name = "Pebble #3",
            onClick = {
                type = "coords",
                name = "Pebble #3",
                mapID = 862,
                x = 0.31935,
                y = 0.35296,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(862, 0.31, 0.35, "Pebble #3")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52817,
            name = "Pebble #4",
            onClick = {
                {
                    type = "coords",
                    name = "Pebble #4 - In the statue",
                    mapID = 896,
                    x = 0.3630,
                    y = 0.5382,
                },
                {
                    type = "coords",
                    name = "Pebble #4 - Cave Entrance",
                    mapID = 896,
                    x = 0.3499,
                    y = 0.5487,
                },
            },
            -- onClick = function ()
            --     BtWQuests_AddWaypoint(896, 0.3630, 0.5382, "Pebble #4 - In the statue")
            --     BtWQuests_ShowMapWithWaypoint(896, 0.3499, 0.5487, "Pebble #4 - Cave Entrance")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52816,
            name = "Pebble #5",
            onClick = {
                type = "coords",
                name = "Pebble #5",
                mapID = 864,
                x = 0.6321,
                y = 0.2133,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(864, 0.6321, 0.2133, "Pebble #5")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52815,
            name = "Pebble #6",
            onClick = {
                {
                    type = "coords",
                    name = "Pebble #6 - In the wheelbarrow",
                    mapID = 942,
                    x = 0.6793,
                    y = 0.1298,
                },
                {
                    type = "coords",
                    name = "Pebble #6 - Cave Entrance",
                    mapID = 942,
                    x = 0.6683,
                    y = 0.1476,
                },
            },
            -- onClick = function ()
            --     BtWQuests_AddWaypoint(942, 0.6793, 0.1298, "Pebble #6 - In the wheelbarrow")
            --     BtWQuests_ShowMapWithWaypoint(942, 0.6683, 0.1476, "Pebble #6 - Cave Entrance")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52814,
            name = "Pebble #7",
            onClick = {
                type = "coords",
                name = "Pebble #7",
                mapID = 875,
                x = 0.5454,
                y = 0.073,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(875, 0.5454, 0.073, "Pebble #7")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52813,
            name = "Pebble #8",
            onClick = {
                {
                    type = "coords",
                    name = "Pebble #8",
                    mapID = 1161,
                    x = 0.3727,
                    y = 0.7980,
                },
                {
                    type = "coords",
                    name = "Pebble #8 - Cave Entrance",
                    mapID = 1161,
                    x = 0.3747,
                    y = 0.8035,
                },
            },
            -- onClick = function ()
            --     BtWQuests_AddWaypoint(1161, 0.3727, 0.7980, "Pebble #8")
            --     BtWQuests_ShowMapWithWaypoint(1161, 0.3747, 0.8035, "Pebble #8 - Cave Entrance")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52812,
            name = "Pebble #9",
            onClick = {
                {
                    type = "coords",
                    name = "Pebble #9",
                    mapID = 896,
                    x = 0.1715,
                    y = 0.064,
                },
                {
                    type = "coords",
                    name = "Pebble #9 - Path Start",
                    mapID = 896,
                    x = 0.1827,
                    y = 0.0721,
                },
            },
            -- onClick = function ()
            --     BtWQuests_AddWaypoint(896, 0.1715, 0.064, "Pebble #9")
            --     BtWQuests_ShowMapWithWaypoint(896, 0.1827, 0.0721, "Pebble #9 - Path Start")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53632,
            name = "Pebble #10",
            onClick = {
                {
                    type = "coords",
                    name = "Pebble #10",
                    mapID = 895,
                    x = 0.7429,
                    y = 0.7087,
                },
                {
                    type = "coords",
                    name = "Pebble #10 - Cave Entrance",
                    mapID = 895,
                    x = 0.7543,
                    y = 0.7065,
                },
            },
            -- onClick = function ()
            --     BtWQuests_AddWaypoint(895, 0.7429, 0.7087, "Pebble #10")
            --     BtWQuests_ShowMapWithWaypoint(895, 0.7543, 0.7065, "Pebble #10 - Cave Entrance")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53633,
            name = "Pebble #11",
            onClick = {
                type = "coords",
                name = "Pebble #11",
                mapID = 895,
                x = 0.8023,
                y = 0.1959,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(895, 0.8023, 0.1959, "Pebble #11")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 53634,
            name = "Pebble #12",
            onClick = {
                {
                    type = "coords",
                    name = "Pebble #12",
                    mapID = 895,
                    x = 0.5970,
                    y = 0.4184,
                },
                {
                    type = "coords",
                    name = "Pebble #12 - Cave Entrance",
                    mapID = 1161,
                    x = 0.1001,
                    y = 0.8259,
                },
            },
            -- onClick = function ()
            --     BtWQuests_AddWaypoint(895, 0.5970, 0.4184, "Pebble #12")
            --     BtWQuests_ShowMapWithWaypoint(1161, 0.1001, 0.8259, "Pebble #12 - Cave Entrance")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52827,
            name = "Pebble #13",
            onClick = {
                {
                    type = "coords",
                    name = "Pebble #13 - Underwater Cave",
                    mapID = 875,
                    x = 0.5572,
                    y = -0.1021,
                },
                {
                    type = "coords",
                    name = "Pebble #13 - Fatigue Reset Zone",
                    mapID = 875,
                    x = 0.477,
                    y = -0.03,
                },
                {
                    type = "coords",
                    name = "Pebble #13 - Path Start",
                    mapID = 875,
                    x = 0.4587,
                    y = 0.0378,
                },
            },
            -- onClick = function ()
            --     BtWQuests_AddWaypoint(875, 0.5572, -0.1021, "Pebble #13 - Underwater Cave")
            --     BtWQuests_AddWaypoint(875, 0.477, -0.03, "Pebble #13 - Fatigue Reset Zone")
            --     BtWQuests_ShowMapWithWaypoint(875, 0.4587, 0.0378, "Pebble #13 - Path Start")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52828,
            name = "Defeat Baa'l",
            onClick = {
                type = "coords",
                name = "Baa'l",
                mapID = 525,
                x = 0.62,
                y = 0.22,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(525, 0.62, 0.22, "Baa'l")
            -- end,
            x = 3,
        },
    },
})
-- /run local a,q=0,{{52900,52922}} for x, y in ipairs(q) do for i = y[1], y[2] or y[1], y[3] or 1 do a=a+1 print("Step #"..a.." ("..i.."): "..tostring(IsQuestFlaggedCompleted(i))) end end
-- BtWQuests_ShowMapWithWaypoint(107, 0.4287, 0.4246, "Aldraan")
-- BtWQuests_ShowMapWithWaypoint(111, 0.3613, 0.4370, "Recorder Lidio")
-- BtWQuests_ShowMapWithWaypoint(111, 0.5589, 0.7434, "Scribe Lanloer")
-- BtWQuests_ShowMapWithWaypoint(116, 0.3498, 0.5504, "Aspen Grove Trader")
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_SECRETS_WAIST_OF_TIME, {
    name = L["WAIST_OF_TIME"],
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_SECRETS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {50,50},
    prerequisites = {
        {
            type = "quest",
            id = 52828,
            name = {
                type = "chain",
                id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_SECRETS_BAAL,
            },
        },
    },
    active = {
        type = "quest",
        id = 52830,
    },
    completed = {
        type = "quest",
        id = 52922,
    },
    rewards = {
        {
            name = L["BTWQUESTS_COSMETIC_WAIST_OF_TIME"],
            -- function ()
            --     return string.format(BTWQUESTS_PREFIX, BTWQUESTS_COSMETIC, "Waist of Time")
            -- end
        }
    },
    items = {
        {
            type = "quest",
            id = 52829,
            name = "Summon Baa'l",
            x = 3,
            y = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52830,
            name = "Lit Orb",
            onClick = {
                type = "coords",
                mapID = 542,
                x = 0.355,
                y = 0.32,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(542, 0.355, 0.32, "Lit Orb")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52831,
            name = "Small Red Strange Seed",
            onClick = {
                type = "coords",
                mapID = 37,
                x = 0.1747,
                y = 0.5648,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(37, 0.1747, 0.5648, "Small Red Strange Seed")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52898,
            name = "Tiny Frog",
            onClick = {
                type = "coords",
                mapID = 542,
                x = 0.535,
                y = 0.1070,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(542, 0.535, 0.1070, "Tiny Frog")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52899,
            name = "Brittle Bone",
            onClick = {
                type = "coords",
                mapID = 105,
                x = 0.336,
                y = 0.5810,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(105, 0.336, 0.5810, "Brittle Bone")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52900,
            name = "Misplaced Candle",
            onClick = {
                type = "coords",
                mapID = 542,
                x = 0.68,
                y = 0.41,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(542, 0.68, 0.41, "Misplaced Candle")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52901,
            name = "Odd Cup",
            onClick = {
                type = "coords",
                mapID = 539,
                x = 0.457,
                y = 0.26,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(539, 0.457, 0.26, "Odd Cup")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52902,
            name = "Interesting Rock",
            onClick = {
                type = "coords",
                mapID = 104,
                x = 0.5163,
                y = 0.4376,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(104, 0.5163, 0.4376, "Interesting Rock")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52903,
            name = "Blooming Lily",
            onClick = {
                type = "coords",
                mapID = 51,
                x = 0.58,
                y = 0.3165,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(51, 0.58, 0.3165, "Blooming Lily")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52904,
            name = "Pretty Flower",
            onClick = {
                type = "coords",
                mapID = 23,
                x = 0.24,
                y = 0.78,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(23, 0.24, 0.78, "Pretty Flower")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52905,
            name = "Old Book",
            onClick = {
                type = "coords",
                mapID = 42,
                x = 0.41,
                y = 0.79,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(42, 0.41, 0.79, "Old Book")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52906,
            name = "Dead Fish",
            onClick = {
                type = "coords",
                mapID = 33,
                x = 0.7783,
                y = 0.4420,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(33, 0.7783, 0.4420, "Dead Fish")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52907,
            name = "Scratched Board",
            onClick = {
                type = "coords",
                mapID = 47,
                x = 0.5199,
                y = 0.6234,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(47, 0.5199, 0.6234, "Scratched Board")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52908,
            name = "Lost Ring",
            onClick = {
                type = "coords",
                mapID = 25,
                x = 0.446,
                y = 0.2634,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(25, 0.446, 0.2634, "Lost Ring")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52909,
            name = "Spoiled Apple",
            onClick = {
                type = "coords",
                mapID = 15,
                x = 0.90,
                y = 0.38,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(15, 0.90, 0.38, "Spoiled Apple")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52910,
            name = "Broken Tooth",
            onClick = {
                type = "coords",
                mapID = 17,
                x = 0.3678,
                y = 0.2760,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(17, 0.3678, 0.2760, "Broken Tooth")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52911,
            name = "Worn Helm",
            onClick = {
                type = "coords",
                mapID = 36,
                x = 0.2710,
                y = 0.4703,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(36, 0.2710, 0.4703, "Worn Helm")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52912,
            name = "Leafy Leaf",
            onClick = {
                type = "coords",
                mapID = 125,
                x = 0.4275,
                y = 0.2018,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(125, 0.4275, 0.2018, "Leafy Leaf")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52913,
            name = "Musty Cloth",
            onClick = {
                type = "coords",
                mapID = 108,
                x = 0.4021,
                y = 0.7249,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(108, 0.4021, 0.7249, "Musty Cloth")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52914,
            name = "Broken Tablet",
            onClick = {
                type = "coords",
                mapID = 241,
                x = 0.1705,
                y = 0.5786,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(241, 0.1705, 0.5786, "Broken Tablet")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52915,
            name = "Ashed Torch",
            onClick = {
                type = "coords",
                mapID = 69,
                x = 0.6078,
                y = 0.6778,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(69, 0.6078, 0.6778, "Ashed Torch")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },

        {
            type = "quest",
            id = 52916,
            name = "Grimmy's List of Friends",
            onClick = {
                type = "coords",
                mapID = 14,
                x = 0.85,
                y = 0.73,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.85, 0.73, "Grimmy's List of Friends")
            -- end,
            x = 3,
            connections = {
                1, 2, 3, 4,
            },
        },


        {
            name = "Equip Windwool",
            breadcrumb = true,
            completed = {
                {
                    type = "quest",
                    id = 52916,
                },
                {
                    type = "equipped",
                    id = 82397,
                },
            },
            -- function (item, character)
            --     return character:IsQuestCompleted(52916) and IsEquippedItem(82397)
            -- end,
            x = 0,
            connections = {
                4,
            },
        },
        {
            name = "Equip Deathsilk Shoulders",
            breadcrumb = true,
            completed = {
                {
                    type = "quest",
                    id = 52916,
                },
                {
                    type = "equipped",
                    id = 54474,
                },
            },
            -- completed = function (item, character)
            --     return character:IsQuestCompleted(52916) and IsEquippedItem(54474)
            -- end,
            connections = {
                3,
            },
        },
        {
            name = "Equip Netherweave Tunic",
            breadcrumb = true,
            completed = {
                {
                    type = "quest",
                    id = 52916,
                },
                {
                    type = "equipped",
                    id = 21855,
                },
            },
            -- completed = function (item, character)
            --     return character:IsQuestCompleted(52916) and IsEquippedItem(21855)
            -- end,
            connections = {
                2,
            },
        },
        {
            name = "Equip Frostwoven Leggings",
            breadcrumb = true,
            completed = {
                {
                    type = "quest",
                    id = 52916,
                },
                {
                    type = "equipped",
                    id = 41519,
                },
            },
            -- completed = function (item, character)
            --     return character:IsQuestCompleted(52916) and IsEquippedItem(41519)
            -- end,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 52917,
            name = "Talk to Grimmy",
            onClick = {
                type = "coords",
                mapID = 14,
                x = 0.85,
                y = 0.73,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.85, 0.73, "Grimmy")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52918,
            name = "Grimmy's List of Enemies",
            onClick = {
                type = "coords",
                mapID = 14,
                x = 0.8524,
                y = 0.7372,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.8524, 0.7372, "Grimmy's List of Enemies")
            -- end,
            x = 3,
            connections = {
                1, 2, 3, 4
            },
        },


        {
            name = "Collect Formula: Enchant Ring - Striking from Karazhan",
            breadcrumb = true,
            completed = {
                {
                    type = "quest",
                    id = 52918,
                },
                {
                    type = "item",
                    id = 22535,
                },
            },
            -- completed = function (item, character)
            --     return character:IsQuestCompleted(52918) and GetItemCount(22535) > 0
            -- end,
            x = 0,
            connections = {
                4,
            },
        },
        {
            name = "Collect Punctured Pelt from Aspen Grove Trader",
            breadcrumb = true,
            onClick = {
                type = "coords",
                name = "Aspen Grove Trader",
                mapID = 116,
                x = 0.3498,
                y = 0.5504,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(116, 0.3498, 0.5504, "Aspen Grove Trader")
            -- end,
            completed = {
                {
                    type = "quest",
                    id = 52918,
                },
                {
                    type = "item",
                    id = 40360,
                },
            },
            -- completed = function (item, character)
            --     return character:IsQuestCompleted(52918) and GetItemCount(40360) > 0
            -- end,
            connections = {
                4,
            },
        },
        {
            name = "Collect Rough Wooden Staff",
            breadcrumb = true,
            onClick = {
                type = "coords",
                name = "Scribe Lanloer",
                mapID = 111,
                x = 0.5589,
                y = 0.7434,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(111, 0.5589, 0.7434, "Scribe Lanloer")
            -- end,
            completed = {
                {
                    type = "quest",
                    id = 52918,
                },
                {
                    type = "item",
                    id = 1515,
                },
            },
            -- completed = function (item, character)
            --     return character:IsQuestCompleted(52918) and GetItemCount(1515) > 0
            -- end,
            connections = {
                4,
            },
        },
        {
            name = "Collect Proximo's Rudius from Aldraan",
            breadcrumb = true,
            onClick = {
                type = "coords",
                name = "Aldraan",
                mapID = 107,
                x = 0.4287,
                y = 0.4246,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(107, 0.4287, 0.4246, "Aldraan")
            -- end,
            completed = {
                {
                    type = "quest",
                    id = 52918,
                },
                {
                    type = "item",
                    id = 30569,
                },
            },
            -- completed = function (item, character)
            --     return character:IsQuestCompleted(52918) and GetItemCount(30569) > 0
            -- end,
            connections = {
                4,
            },
        },


        {
            type = "quest",
            id = 52822,
            name = "Slap Aquinastrasz",
            onClick = {
                type = "coords",
                name = "Aquinastrasz",
                mapID = 241,
                x = 0.284,
                y = 0.248,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(241, 0.284, 0.248, "Aquinastrasz")
            -- end,
            x = 0,
            connections = {
                4,
            },
        },
        {
            type = "quest",
            id = 52823,
            name = "Wave at Karnum Marshweaver",
            onClick = {
                type = "coords",
                name = "Karnum Marshweaver",
                mapID = 66,
                x = 0.5746,
                y = 0.4773,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(66, 0.5746, 0.4773, "Karnum Marshweaver")
            -- end,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 52824,
            name = "Cheer at Noggra",
            onClick = {
                type = "coords",
                name = "Noggra",
                mapID = 121,
                x = 0.4059,
                y = 0.6870,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(121, 0.4059, 0.6870, "Noggra")
            -- end,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 52826,
            name = "Dance with Stained Mug",
            onClick = {
                type = "coords",
                name = "Stained Mug",
                mapID = 379,
                x = 0.4443,
                y = 0.9030,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(379, 0.4443, 0.9030, "Stained Mug")
            -- end,
            connections = {
                1,
            },
        },


        {
            type = "quest",
            id = 52919,
            name = "Talk to Grimmy",
            onClick = {
                type = "coords",
                name = "Grimmy",
                mapID = 14,
                x = 0.85,
                y = 0.73,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.85, 0.73, "Grimmy")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52920,
            name = "Grimmy's Favorite Recipe",
            onClick = {
                type = "coords",
                mapID = 14,
                x = 0.8535,
                y = 0.7396,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.8535, 0.7396, "Grimmy's Favorite Recipe")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            name = "Get to 144 stacks of Rotten Potato",
            breadcrumb = true,
            completed = {
                {
                    type = "quest",
                    id = 52920,
                },
                {
                    type = "aura",
                    id = 278475,
                },
            },
            -- completed = function (item, character)
            --     if not character:IsQuestCompleted(52920) then
            --         return false
            --     end

            --     local index = 1
            --     local name, _, count, _, _, _, _, _, _, spellId = UnitAura("player", index)
            --     while name do
            --         if spellId == 278475 then
            --             return true
            --         end
            --         index = index + 1
            --         name, _, count, _, _, _, _, _, _, spellId = UnitAura("player", index)
            --     end
            -- end,
            onClick = {
                type = "coords",
                name = "Rotten Potato",
                mapID = 14,
                x = 0.8838,
                y = 0.6921,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.8838, 0.6921, "Rotten Potato")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52921,
            name = "Talk to Grimmy",
            onClick = {
                type = "coords",
                name = "Grimmy",
                mapID = 14,
                x = 0.85,
                y = 0.73,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.85, 0.73, "Grimmy")
            -- end,
            x = 3,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 52922,
            name = "Collect the Waist of Time from Grimmy's Rusty Lockbox",
            onClick = {
                type = "coords",
                name = "Grimmy's Rusty Lockbox",
                mapID = 14,
                x = 0.8513,
                y = 0.7330,
            },
            -- onClick = function ()
            --     BtWQuests_ShowMapWithWaypoint(14, 0.8513, 0.7330, "Grimmy's Rusty Lockbox")
            -- end,
            x = 3,
        },
    },
})
BtWQuestsDatabase:AddChain(BtWQuests.Constant.Chain.BattleForAzeroth.Secrets.HoneybackHive, {
    name = { -- Honeyback Hive
        type = "reputation",
        id = 2395,
    },
    category = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_SECRETS,
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    range = {50,50},
    restrictions = {
        type = "faction",
        id = BtWQuests.Constant.Faction.Alliance,
    },
    prerequisites = {
        {
            name = L["PET_BUMBLES_OR_SEABREEZE_BUMBLEBEE"],
            type = "pet",
            ids = {2442, 2404},
        }
    },
    active = {
        type = "quest",
        id = 55906,
    },
    completed = {
        type = "quest",
        id = 57528,
    },
    rewards = {
        {
            type = "reputation",
            id = 2395,
        }
    },
    items = {
        {
            type = "npc",
            id = 153393,
            x = 3,
            y = 0,
            connections = {1}
        },
        {
            name = L["SUMMON_BUMBLES_OR_SEABREEZE_BUMBLEBEE"],
            type = "quest",
            id = 55906,
            x = 3,
            connections = {1}
        },
        {
            type = "npc",
            id = 153365,
            x = 3,
            completed = {
                type = "quest",
                id = 55904,
            },
            connections = {1}
        },
        {
            type = "item",
            id = 169106,
            breadcrumb = true,
            x = 3,
            onClick = {
                type = "coords",
                mapID = 942,
                x = 0.631963,
                y = 0.284735,
            },
            connections = {1}
        },
        {
            type = "talk",
            id = 153365,
            x = 3,
            completed = {
                type = "quest",
                id = 56104,
            },
            connections = {1}
        },
        {
            type = "talk",
            id = 153393,
            locations = {
                [942] = {
                    {
                        x = 0.629933,
                        y = 0.266155,
                    },
                },
            },
            completed = {
                type = "quest",
                id = 56105,
            },
            x = 3,
            connections = {1}
        },
        {
            type = "talk",
            id = 153393,
            locations = {
                [942] = {
                    {
                        x = 0.625589,
                        y = 0.263803,
                    },
                },
            },
            completed = {
                type = "quest",
                id = 56735,
            },
            x = 3,
            connections = {1}
        },
        {
            type = "talk",
            id = 154023,
            completed = {
                type = "quest",
                id = 57528,
            },
            x = 3,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_SECRETS, {
    name = L["BTWQUESTS_SECRET"],
    expansion = BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH,
    items = {
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_SECRETS_BAAL,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_BATTLE_FOR_AZEROTH_SECRETS_WAIST_OF_TIME,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.BattleForAzeroth.Secrets.HoneybackHive,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(BTWQUESTS_EXPANSION_BATTLE_FOR_AZEROTH, {
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_BATTLE_FOR_AZEROTH_SECRETS,
    },
})