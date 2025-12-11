local L = BtWQuests.L;
-- BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIDDEN_KOSUMOTH, {
--     name = L["BTWQUESTS_RARE_KOSUMOTH"],
--     category = BTWQUESTS_CATEGORY_LEGION_HIDDEN,
--     expansion = BTWQUESTS_EXPANSION_LEGION,
--     completed = {
--         type = "quest",
--         id = 46744,
--     },
--     range = {110},
--     items = {
--         {
--             type = "quest",
--             id = 46744,
--             x = 3,
--             y = 0,
--             connections = {
--                 1,
--             }
--         },
--     },
-- }

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIDDEN_MINDWORM, {
    name = L["BTWQUESTS_MOUNT_RIDDLERS"],
    category = BTWQUESTS_CATEGORY_LEGION_HIDDEN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
    },
    active = {
        type = "quest",
        id = 45470,
        status = {'active', 'completed'}
    },
    completed = {
        type = "mount",
        id = 947,
    },
    items = {
        {
            type = "quest",
            name = "Page 9 found in The Legerdemain Lounge",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(627, 0.49, 0.42, "Step 1: Page 9")
            end,
            id = 45470,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Page 78 found in Duskwood",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(47, 0.49, 0.33, "Step 2: Page 78")
            end,
            id = 47207,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Page 161 found in Firelands",
            onClick = function ()
                if GetRealZoneText() ~= "Firelands" then
                    BtWQuests_ShowMapWithWaypoint(198, 0.4777, 0.7784, "Step 3: Firelands")
                    BtWQuests_AddWaypoint(369, 0.47, 0.1658, "Step 3: Page 161")
                else
                    BtWQuests_ShowMapWithWaypoint(369, 0.47, 0.1658, "Step 3: Page 161")
                end
            end,
            id = 47208,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Page 655 found in Uldum",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(249, 0.7045, 0.7808, "Step 4: Page 655")
            end,
            id = 47209,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Page 845 found in the Siege of Orgrimmar",
            onClick = function ()
                if GetRealZoneText() ~= "Siege of Orgrimmar" then
                    BtWQuests_ShowMapWithWaypoint(390, 0.7393, 0.4221, "Step 5: Siege of Orgrimmar")
                    BtWQuests_AddWaypoint(559, 0.1991, 0.8232, "Step 5: Page 845")
                else
                    BtWQuests_ShowMapWithWaypoint(559, 0.1991, 0.8232, "Step 5: Page 845")
                end
            end,
            id = 47210,
            x = 3,
            y = 4,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Page 1127 found in the Well of Eternity",
            onClick = function ()
                if GetRealZoneText() ~= "Well of Eternity" then
                    BtWQuests_ShowMapWithWaypoint(75, 0.2295, 0.6437, "Step 6: Well of Eternity")
                    BtWQuests_AddWaypoint(398, 0.753, 0.66, "Step 6: Page 1127")
                else
                    BtWQuests_ShowMapWithWaypoint(398, 0.753, 0.66, "Step 6: Page 1127")
                end
            end,
            id = 47211,
            x = 3,
            y = 5,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Page 2351 found in Kun-Lai Summit",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(379, 0.3463, 0.5089, "Step 7: Page 2351")
            end,
            id = 47212,
            x = 3,
            y = 6,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Page 5555 found in Uldum",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(249, 0.7644, 0.5358, "Step 8: Page 5555")
            end,
            id = 47213,
            x = 3,
            y = 7,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Riddler's Mind-Worm in Westfall",
            id = 47214,
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(52, 0.3051, 0.2755, "Step 9: Riddler's Mind-Worm")
            end,
            x = 3,
            y = 8
        },
    },
})

-- BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIDDEN_SUNDARTER, {
--     name = L["BTWQUESTS_PET_SUNDARTER"],
--     category = BTWQUESTS_CATEGORY_LEGION_HIDDEN,
--     expansion = BTWQUESTS_EXPANSION_LEGION,
--     completed = {
--         type = "quest",
--         id = 45866,
--     },
--     range = {110},
--     items = {
--         {
--             type = "quest",
--             id = 46744,
--             x = 3,
--             y = 0,
--             connections = {
--                 1,
--             }
--         },
--     },
-- }

BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIDDEN_LUCIDNIGHTMARE, {
    name = L["BTWQUESTS_MOUNT_LUCID_NIGHTMARE"],
    category = BTWQUESTS_CATEGORY_LEGION_HIDDEN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
    },
    active = {
        type = "quest",
        id = 47826,
        status = {'active', 'completed'}
    },
    completed = {
        type = "mount",
        id = 961,
    },
    items = {
        {
            type = "quest",
            name = "Inconspicuous Note in Curiosities & Moore",
            id = 47826,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Inconspicuous Note in Ulduar",
            id = 47837,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Inconspicuous Note in the Temple of Ahn'Qiraj",
            id = 47841,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Inconspicuous Note in Deepholm",
            id = 47850,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Inconspicuous Note in Gnomeregan",
            id = 47852,
            x = 3,
            y = 4,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Inconspicuous Note in Val'Sharah",
            id = 47863,
            x = 3,
            y = 5,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Inconspicuous Note in the Endless Halls",
            id = 47881,
            x = 3,
            y = 6,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Your Lucid Nightmare below Karazhan",
            id = 47885,
            x = 3,
            y = 7,
        },
    },
})
BtWQuestsDatabase:AddChain(BTWQUESTS_CHAIN_LEGION_HIDDEN_UUNA, {
    name = { -- Uuna
        type = "pet",
        id = 2136,
    },
    category = BTWQUESTS_CATEGORY_LEGION_HIDDEN,
    expansion = BTWQUESTS_EXPANSION_LEGION,
    range = {45},
    prerequisites = {
        {
            type = "level",
            level = 45,
        },
    },
    active = {
        type = "quest",
        id = 50098,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 50147,
    },
    items = {
        {
            name = "Collect Uuna from the Many-Faced Devourer",
            type = "pet",
            id = 2136,
            -- completed = function ()
            --     return select(1, C_PetJournal.GetNumCollectedInfo(2136)) > 0
            -- end,
            x = 3,
            y = 0,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Summon Uuna and wait for her to emote",
            id = 50098,
            x = 3,
            y = 1,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "/whistle at Uuna",
            id = 50099,
            x = 3,
            y = 2,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "/roar at Uuna",
            id = 50100,
            x = 3,
            y = 3,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "/cry at Uuna",
            id = 50101,
            x = 3,
            y = 4,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to A'dal in Shattrath",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(111, 0.5398, 0.4477, "A'dal")
            end,
            id = 50102,
            x = 3,
            y = 5,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Lake Falathim in Ashenvale",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(63, 0.1889, 0.4161, "Lake Falathim")
            end,
            id = 50103,
            x = 3,
            y = 6,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Nuu in Mac'Aree",
            onClick = function ()
                BtWQuests_AddWaypoint(882, 0.3272, 0.7552, "Nuu")
                BtWQuests_AddWaypoint(882, 0.2516, 0.5989, "Jump and glide from the highest point to the next island")
                BtWQuests_ShowMapWithWaypoint(882, 0.2401, 0.5864, "Glide from here to the first island")
            end,
            id = 50104,
            x = 3,
            y = 7,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Jessera of Mac'Aree",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(106, 0.5653, 0.5646, "Jessera of Mac'Aree")
            end,
            id = 50105,
            x = 3,
            y = 8,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to a camp in Shadowmoon Valley",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(539, 0.5602, 0.4113, "Camp in Shadowmoon Valley")
            end,
            id = 50106,
            x = 3,
            y = 9,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Wait for poor Uuna to get taken by darkness",
            id = 50107,
            x = 3,
            y = 10,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Speak to any Spirit Healer",
            id = 50108,
            x = 3,
            y = 11,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Go to the Emerald Dragonshrine, /cheer at Uuna and place a camp fire",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(115, 0.6614, 0.7462, "Shadow Tear in Dragonblight")
            end,
            id = 50109,
            x = 3,
            y = 12,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to the Gate of the Setting Sun",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(390, 0.08, 0.59, "The Gate of the Setting Sun")
            end,
            id = 50140,
            x = 3,
            y = 13,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to the Nighthold Entrance",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(680, 0.62, 0.83, "Nighthold Entrance")
            end,
            id = 50141,
            x = 3,
            y = 14,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Krasus Landing",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(627, 0.74, 0.46, "Krasus Landing")
            end,
            id = 50142,
            x = 3,
            y = 15,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Wyrmrest Temple",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(115, 0.5783, 0.5453, "Wyrmrest Temple")
            end,
            id = 50143,
            x = 3,
            y = 16,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Mount Hyjal",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(198, 0.59, 0.24, "Mount Hyjal")
            end,
            id = 50144,
            x = 3,
            y = 17,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Neverest Pinnacle",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(379, 0.4476, 0.5239, "Neverest Pinnacle")
            end,
            id = 50145,
            x = 3,
            y = 18,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Blackrock Mountain",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(36, 0.18, 0.31, "Blackrock Mountain")
            end,
            id = 50146,
            x = 3,
            y = 19,
            connections = {
                1,
            }
        },
        {
            type = "quest",
            name = "Take Uuna to Karabor",
            onClick = function ()
                BtWQuests_ShowMapWithWaypoint(539, 0.7070, 0.4660, "Karabor")
            end,
            id = 50147,
            x = 3,
            y = 20,
        },
    },
})

BtWQuestsDatabase:AddCategory(BTWQUESTS_CATEGORY_LEGION_HIDDEN, {
    name = L["BTWQUESTS_SECRET"],
    expansion = BTWQUESTS_EXPANSION_LEGION,
    items = {
        -- {
            -- type = "chain",
            -- id = BTWQUESTS_CHAIN_LEGION_HIDDEN_KOSUMOTH,
        -- },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIDDEN_MINDWORM,
        },
        -- {
            -- type = "chain",
            -- id = BTWQUESTS_CHAIN_LEGION_HIDDEN_SUNDARTER,
        -- },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIDDEN_LUCIDNIGHTMARE,
        },
        {
            type = "chain",
            id = BTWQUESTS_CHAIN_LEGION_HIDDEN_UUNA,
        },
    },
})

BtWQuestsDatabase:AddExpansionItem(BTWQUESTS_EXPANSION_LEGION, {
    type = "category",
    id = BTWQUESTS_CATEGORY_LEGION_HIDDEN,
})