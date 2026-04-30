-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

-- Add currency information
private.currencyIds["adventurerCrest"] = 3383
private.currencyIndexes[private.currencyIds.adventurerCrest] = true

private.currencyIds["veteranCrest"] = 3341
private.currencyIndexes[private.currencyIds.veteranCrest] = true

private.currencyIds["championCrest"] = 3343
private.currencyIndexes[private.currencyIds.championCrest] = true

private.currencyIds["heroCrest"] = 3345
private.currencyIndexes[private.currencyIds.heroCrest] = true

private.currencyIds["mythCrest"] = 3347
private.currencyIndexes[private.currencyIds.mythCrest] = true

-- Add preferences
private.Preferences.DefaultValues.profile.DisabledIntegrations.Crests = false;
private.Preferences.DisabledIntegrations.Crests = {
    type = "toggle",
    name = L["GOLD_CREST_UPGRADES"],
    order = 110,
    width = "double",
}

---@type Dictionary<UpgradeData>
local upgradeData = {
    ["adventurerCrests"] = {
        name = L["ADVENTURER_CRESTS"],
        shortName = L["ADVENTURER_CRESTS_SHORT"],
        colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Uncommon),
        icon = 7639517,
        itemId = nil,
        currencyId = private.currencyIds.adventurerCrest
    },

    ["veteranCrests"] = {
        name = L["VETERAN_CRESTS"],
        shortName = L["VETERAN_CRESTS_SHORT"],
        colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Rare),
        icon = 7639525,
        itemId = nil,
        currencyId = private.currencyIds.veteranCrest
    },

    ["championCrests"] = {
        name = L["CHAMPION_CRESTS"],
        shortName = L["CHAMPION_CRESTS_SHORT"],
        colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Epic),
        icon = 7639519,
        itemId = nil,
        currencyId = private.currencyIds.championCrest
    },

    ["heroCrests"] = {
        name = L["HERO_CRESTS"],
        shortName = L["HERO_CRESTS_SHORT"],
        colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Legendary),
        icon = 7639521,
        itemId = nil,
        currencyId = private.currencyIds.heroCrest
    },

    ["mythCrests"] = {
        name = L["MYTH_CRESTS"],
        shortName = L["MYTH_CRESTS_SHORT"],
        colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Artifact),
        icon = 7639523,
        itemId = nil,
        currencyId = private.currencyIds.mythCrest
    },
}

---@type Array<MythicPlusInfo>
private.mythicPlusInfo = {
    {keyLevel = 0,  lootDrops = 246, vaultReward = 256, currency = upgradeData["championCrests"]},
    {keyLevel = 2,  lootDrops = 250, vaultReward = 259, currency = upgradeData["championCrests"]},
    {keyLevel = 3,  lootDrops = 250, vaultReward = 259, currency = upgradeData["championCrests"]},
    {keyLevel = 4,  lootDrops = 253, vaultReward = 263, currency = upgradeData["heroCrests"]},
    {keyLevel = 5,  lootDrops = 256, vaultReward = 263, currency = upgradeData["heroCrests"]},
    {keyLevel = 6,  lootDrops = 259, vaultReward = 266, currency = upgradeData["heroCrests"]},
    {keyLevel = 7,  lootDrops = 259, vaultReward = 269, currency = upgradeData["heroCrests"]},
    {keyLevel = 8,  lootDrops = 263, vaultReward = 269, currency = upgradeData["heroCrests"]},
    {keyLevel = 9,  lootDrops = 263, vaultReward = 269, currency = upgradeData["mythCrests"]},
    {keyLevel = "10+", lootDrops = 266, vaultReward = 272, currency = upgradeData["mythCrests"]},
}

---@type Array<RaidInfo>
private.raidInfo = {
    {boss = 1,                      lfr = 233, normal = 246, heroic = 259, mythic = 272},
    {boss = 2,                      lfr = 233, normal = 246, heroic = 259, mythic = 272},
    {boss = 3,                      lfr = 233, normal = 246, heroic = 259, mythic = 272},
    {boss = L["X_RARE"]:format(3),  lfr = 246, normal = 259, heroic = 272, mythic = 285},
    {boss = 4,                      lfr = 237, normal = 237, heroic = 263, mythic = 276},
    {boss = L["X_RARE"]:format(4),  lfr = 246, normal = 259, heroic = 272, mythic = 285},
    {boss = 5,                      lfr = 237, normal = 237, heroic = 263, mythic = 276},
    {boss = 6,                      lfr = 237, normal = 237, heroic = 263, mythic = 276},
    {boss = L["X_RARE"]:format(6),  lfr = 246, normal = 259, heroic = 272, mythic = 285},
    {boss = 7,                      lfr = 243, normal = 256, heroic = 266, mythic = 279},
    {boss = 8,                      lfr = 243, normal = 256, heroic = 266, mythic = 279},
    {boss = L["X_RARE"]:format(8),  lfr = 246, normal = 259, heroic = 272, mythic = 285},
}

---@type RaidCurrencyInfo
 private.raidCurrencyInfo = {
    -- LFR
    lfrCurrency = upgradeData["veteranCrests"],

    -- Normal
    normalCurrency = upgradeData["championCrests"],

    -- Heroic
    heroicCurrency = upgradeData["heroCrests"],

    -- Mythic
    mythicCurrency = upgradeData["mythCrests"],
}

---@type Array<UpgradeTrackInfo>
private.upgradeTrackInfo = {
    {
        itemLevel = 220,
        upgrade1 = {rank = 2, upgradeLevel = 1, maxUpgradeLevel = 6},
        currency = upgradeData["adventurerCrests"]
    },
    {
        itemLevel = 224,
        upgrade1 = {rank = 2, upgradeLevel = 2, maxUpgradeLevel = 6},
        currency = upgradeData["adventurerCrests"]
    },
    {
        itemLevel = 227,
        upgrade1 = {rank = 2, upgradeLevel = 3, maxUpgradeLevel = 6},
        currency = upgradeData["adventurerCrests"]
    },
    {
        itemLevel = 230,
        upgrade1 = {rank = 2, upgradeLevel = 4, maxUpgradeLevel = 6},
        currency = upgradeData["adventurerCrests"]
    },
    {
        itemLevel = 233,
        upgrade1 = {rank = 2, upgradeLevel = 5, maxUpgradeLevel = 6},
        upgrade2 = {rank = 3, upgradeLevel = 1, maxUpgradeLevel = 6},
        currency = upgradeData["veteranCrests"]
    },
    {
        itemLevel = 237,
        upgrade1 = {rank = 2, upgradeLevel = 6, maxUpgradeLevel = 6},
        upgrade2 = {rank = 3, upgradeLevel = 2, maxUpgradeLevel = 6},
        currency = upgradeData["veteranCrests"]
    },
    {
        itemLevel = 246,
        upgrade1 = {rank = 3, upgradeLevel = 3, maxUpgradeLevel = 6},
        currency = upgradeData["veteranCrests"]
    },
    {
        itemLevel = 243,
        upgrade1 = {rank = 3, upgradeLevel = 4, maxUpgradeLevel = 6},
        currency = upgradeData["veteranCrests"]
    },
    {
        itemLevel = 246,
        upgrade1 = {rank = 3, upgradeLevel = 5, maxUpgradeLevel = 6},
        upgrade2 = {rank = 4, upgradeLevel = 1, maxUpgradeLevel = 6},
        currency = upgradeData["championCrests"]
    },
    {
        itemLevel = 250,
        upgrade1 = {rank = 3, upgradeLevel = 6, maxUpgradeLevel = 6},
        upgrade2 = {rank = 4, upgradeLevel = 2, maxUpgradeLevel = 6},
        currency = upgradeData["championCrests"]
    },
    {
        itemLevel = 253,
        upgrade1 = {rank = 4, upgradeLevel = 3, maxUpgradeLevel = 6},
        currency = upgradeData["championCrests"]
    },
    {
        itemLevel = 256,
        upgrade1 = {rank = 4, upgradeLevel = 4, maxUpgradeLevel = 6},
        currency = upgradeData["championCrests"]
    },
    {
        itemLevel = 259,
        upgrade1 = {rank = 4, upgradeLevel = 5, maxUpgradeLevel = 6},
        upgrade2 = {rank = 5, upgradeLevel = 1, maxUpgradeLevel = 6},
        currency = upgradeData["heroCrests"]
    },
    {
        itemLevel = 263,
        upgrade1 = {rank = 4, upgradeLevel = 6, maxUpgradeLevel = 6},
        upgrade2 = {rank = 5, upgradeLevel = 2, maxUpgradeLevel = 6},
        currency = upgradeData["heroCrests"]
    },
    {
        itemLevel = 266,
        upgrade1 = {rank = 5, upgradeLevel = 3, maxUpgradeLevel = 6},
        currency = upgradeData["heroCrests"]
    },
    {
        itemLevel = 269,
        upgrade1 = {rank = 5, upgradeLevel = 4, maxUpgradeLevel = 6},
        currency = upgradeData["heroCrests"]
    },
    {
        itemLevel = 272,
        upgrade1 = {rank = 5, upgradeLevel = 5, maxUpgradeLevel = 6},
        upgrade2 = {rank = 6, upgradeLevel = 1, maxUpgradeLevel = 6},
        currency = upgradeData["mythCrests"]
    },
    {
        itemLevel = 276,
        upgrade1 = {rank = 5, upgradeLevel = 6, maxUpgradeLevel = 6},
        upgrade2 = {rank = 6, upgradeLevel = 2, maxUpgradeLevel = 6},
        currency = upgradeData["mythCrests"]
    },
    {
        itemLevel = 279,
        upgrade1 = {rank = 6, upgradeLevel = 3, maxUpgradeLevel = 6},
        currency = upgradeData["mythCrests"]
    },
    {
        itemLevel = 282,
        upgrade1 = {rank = 6, upgradeLevel = 4, maxUpgradeLevel = 6},
        currency = upgradeData["mythCrests"]
    },
    {
        itemLevel = 285,
        upgrade1 = {rank = 6, upgradeLevel = 5, maxUpgradeLevel = 6},
        currency = upgradeData["mythCrests"]
    },
    {
        itemLevel = 289,
        upgrade1 = {rank = 6, upgradeLevel = 6, maxUpgradeLevel = 6},
        currency = upgradeData["mythCrests"]
    },
}

---@type Array<BountifulDelveInfo>
private.bountifulDelveInfo = {
    {
        tier = 1,
        loot = {itemLevel = 220, upgradeTrack = L["UPGRADE_TRACK_ADVENTURER"]},
        vault = {itemLevel = 233, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = upgradeData["adventurerCrests"]
    },
    {
        tier = 2,
        loot = {itemLevel = 224, upgradeTrack = L["UPGRADE_TRACK_ADVENTURER"]},
        vault = {itemLevel = 237, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = upgradeData["adventurerCrests"]
    },
    {
        tier = 3,
        loot = {itemLevel = 227, upgradeTrack = L["UPGRADE_TRACK_ADVENTURER"]},
        vault = {itemLevel = 240, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = upgradeData["adventurerCrests"]
    },
    {
        tier = 4,
        loot = {itemLevel = 230, upgradeTrack = L["UPGRADE_TRACK_ADVENTURER"]},
        vault = {itemLevel = 243, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = upgradeData["adventurerCrests"]
    },
    {
        tier = 5,
        loot = {itemLevel = 233, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 246, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        currency = upgradeData["veteranCrests"]
    },
    {
        tier = 6,
        loot = {itemLevel = 237, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 253, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        currency = upgradeData["veteranCrests"]
    },
    {
        tier = 7,
        loot = {itemLevel = 250, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 256, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        currency = upgradeData["championCrests"]
    },
    {
        tier = 8,
        loot = {itemLevel = 250, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 259, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = upgradeData["championCrests"]
    },
    {
        tier = 9,
        loot = {itemLevel = 250, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 259, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = upgradeData["championCrests"]
    },
    {
        tier = 10,
        loot = {itemLevel = 250, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 259, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = upgradeData["championCrests"]
    },
    {
        tier = 11,
        loot = {itemLevel = 250, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 259, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = upgradeData["heroCrests"]
    }
}

---@type Array<CraftingInfo>
private.craftingInfo = {
    -- Adventurer
    {itemLevel = 220, currency = upgradeData["adventurerCrests"], currencyAmount = 30, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 224, currency = upgradeData["adventurerCrests"], currencyAmount = 30, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 227, currency = upgradeData["adventurerCrests"], currencyAmount = 30, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 230, currency = upgradeData["adventurerCrests"], currencyAmount = 30, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 233, currency = upgradeData["adventurerCrests"], currencyAmount = 30, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},

    -- Line break
    {itemLevel = 0, currencyAmount = 0, rank = 0, iconPath = ""},

    -- Veteran
    {itemLevel = 233, currency = upgradeData["veteranCrests"], currencyAmount = 45, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 237, currency = upgradeData["veteranCrests"], currencyAmount = 45, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 240, currency = upgradeData["veteranCrests"], currencyAmount = 45, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 243, currency = upgradeData["veteranCrests"], currencyAmount = 45, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 246, currency = upgradeData["veteranCrests"], currencyAmount = 45, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},

    -- Line break
    {itemLevel = 0, currencyAmount = 0, rank = 0, iconPath = ""},

    -- Champion
    {itemLevel = 246, currency = upgradeData["championCrests"], currencyAmount = 45, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 250, currency = upgradeData["championCrests"], currencyAmount = 45, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 253, currency = upgradeData["championCrests"], currencyAmount = 45, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 256, currency = upgradeData["championCrests"], currencyAmount = 45, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 259, currency = upgradeData["championCrests"], currencyAmount = 45, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},

    -- Line break
    {itemLevel = 0, currencyAmount = 0, rank = 0, iconPath = ""},

    -- Hero
    {itemLevel = 259, currency = upgradeData["heroCrests"], currencyAmount = 45, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 263, currency = upgradeData["heroCrests"], currencyAmount = 45, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 266, currency = upgradeData["heroCrests"], currencyAmount = 45, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 269, currency = upgradeData["heroCrests"], currencyAmount = 45, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 272, currency = upgradeData["heroCrests"], currencyAmount = 45, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},

    -- Line break
    {itemLevel = 0, currencyAmount = 0, rank = 0, iconPath = ""},

    -- Myth
    {itemLevel = 272, currency = upgradeData["mythCrests"], currencyAmount = 60, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 276, currency = upgradeData["mythCrests"], currencyAmount = 60, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 279, currency = upgradeData["mythCrests"], currencyAmount = 60, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 282, currency = upgradeData["mythCrests"], currencyAmount = 60, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 285, currency = upgradeData["mythCrests"], currencyAmount = 60, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},
}

---@type Array<ItemBonusInfo>
local itemBonusIds = {

    -- Adventurer (6)
    [12769] = {
        itemLevel = 220,
        rank = 2,
        upgradeLevel = 1,
        maxUpgradeLevel = 6,
        upgradeGroup = 608,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3383, amount = 20}
            }
        }
    },
    [12770] = {
        itemLevel = 224,
        rank = 2,
        upgradeLevel = 2,
        maxUpgradeLevel = 6,
        upgradeGroup = 608,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3383, amount = 20}
            }
        }
    },
    [12771] = {
        itemLevel = 227,
        rank = 2,
        upgradeLevel = 3,
        maxUpgradeLevel = 6,
        upgradeGroup = 608,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3383, amount = 20}
            }
        }
    },
    [12772] = {
        itemLevel = 230,
        rank = 2,
        upgradeLevel = 4,
        maxUpgradeLevel = 6,
        upgradeGroup = 608,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3383, amount = 20}
            }
        }
    },
    [12773] = {
        itemLevel = 233,
        rank = 2,
        upgradeLevel = 5,
        maxUpgradeLevel = 6,
        upgradeGroup = 608,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3383, amount = 20}
            }
        }
    },
    [12774] = {
        itemLevel = 237,
        rank = 2,
        upgradeLevel = 6,
        maxUpgradeLevel = 6,
        upgradeGroup = 608,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3383, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3383, amount = 20}
            }
        }
    },

    -- Veteran (6)
    [12777] = {
        itemLevel = 233,
        rank = 3,
        upgradeLevel = 1,
        maxUpgradeLevel = 6,
        upgradeGroup = 609,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3341, amount = 20}
            }
        }
    },
    [12778] = {
        itemLevel = 237,
        rank = 3,
        upgradeLevel = 2,
        maxUpgradeLevel = 6,
        upgradeGroup = 609,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3341, amount = 20}
            }
        }
    },
    [12779] = {
        itemLevel = 240,
        rank = 3,
        upgradeLevel = 3,
        maxUpgradeLevel = 6,
        upgradeGroup = 609,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3341, amount = 20}
            }
        }
    },
    [12780] = {
        itemLevel = 243,
        rank = 3,
        upgradeLevel = 4,
        maxUpgradeLevel = 6,
        upgradeGroup = 609,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3341, amount = 20}
            }
        }
    },
    [12781] = {
        itemLevel = 246,
        rank = 3,
        upgradeLevel = 5,
        maxUpgradeLevel = 6,
        upgradeGroup = 609,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3341, amount = 20}
            }
        }
    },
    [12782] = {
        itemLevel = 250,
        rank = 3,
        upgradeLevel = 6,
        maxUpgradeLevel = 6,
        upgradeGroup = 609,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3341, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3341, amount = 20}
            }
        }
    },

    -- Champion (6)
    [12785] = {
        itemLevel = 246,
        rank = 4,
        upgradeLevel = 1,
        maxUpgradeLevel = 6,
        upgradeGroup = 610,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3343, amount = 20}
            }
        }
    },
    [12786] = {
        itemLevel = 250,
        rank = 4,
        upgradeLevel = 2,
        maxUpgradeLevel = 6,
        upgradeGroup = 610,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3343, amount = 20}
            }
        }
    },
    [12787] = {
        itemLevel = 253,
        rank = 4,
        upgradeLevel = 3,
        maxUpgradeLevel = 6,
        upgradeGroup = 610,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3343, amount = 20}
            }
        }
    },
    [12788] = {
        itemLevel = 256,
        rank = 4,
        upgradeLevel = 4,
        maxUpgradeLevel = 6,
        upgradeGroup = 610,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3343, amount = 20}
            }
        }
    },
    [12789] = {
        itemLevel = 259,
        rank = 4,
        upgradeLevel = 5,
        maxUpgradeLevel = 6,
        upgradeGroup = 610,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3343, amount = 20}
            }
        }
    },
    [12790] = {
        itemLevel = 263,
        rank = 4,
        upgradeLevel = 6,
        maxUpgradeLevel = 6,
        upgradeGroup = 610,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3343, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3343, amount = 20}
            }
        }
    },

    -- Hero (6)
    [12793] = {
        itemLevel = 259,
        rank = 5,
        upgradeLevel = 1,
        maxUpgradeLevel = 6,
        upgradeGroup = 611,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3345, amount = 20}
            }
        }
    },
    [12794] = {
        itemLevel = 263,
        rank = 5,
        upgradeLevel = 2,
        maxUpgradeLevel = 6,
        upgradeGroup = 611,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3345, amount = 20}
            }
        }
    },
    [12795] = {
        itemLevel = 266,
        rank = 5,
        upgradeLevel = 3,
        maxUpgradeLevel = 6,
        upgradeGroup = 611,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3345, amount = 20}
            }
        }
    },
    [12796] = {
        itemLevel = 269,
        rank = 5,
        upgradeLevel = 4,
        maxUpgradeLevel = 6,
        upgradeGroup = 611,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3345, amount = 20}
            }
        }
    },
    [12797] = {
        itemLevel = 272,
        rank = 5,
        upgradeLevel = 5,
        maxUpgradeLevel = 6,
        upgradeGroup = 611,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3345, amount = 20}
            }
        }
    },
    [12798] = {
        itemLevel = 276,
        rank = 5,
        upgradeLevel = 6,
        maxUpgradeLevel = 6,
        upgradeGroup = 611,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3345, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3345, amount = 20}
            }
        }
    },

    -- Myth (6)
    [12801] = {
        itemLevel = 272,
        rank = 6,
        upgradeLevel = 1,
        maxUpgradeLevel = 6,
        upgradeGroup = 612,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3347, amount = 20}
            }
        }
    },
    [12802] = {
        itemLevel = 276,
        rank = 6,
        upgradeLevel = 2,
        maxUpgradeLevel = 6,
        upgradeGroup = 612,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3347, amount = 20}
            }
        }
    },
    [12803] = {
        itemLevel = 279,
        rank = 6,
        upgradeLevel = 3,
        maxUpgradeLevel = 6,
        upgradeGroup = 612,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3347, amount = 20}
            }
        }
    },
    [12804] = {
        itemLevel = 282,
        rank = 6,
        upgradeLevel = 4,
        maxUpgradeLevel = 6,
        upgradeGroup = 612,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3347, amount = 20}
            }
        }
    },
    [12805] = {
        itemLevel = 285,
        rank = 6,
        upgradeLevel = 5,
        maxUpgradeLevel = 6,
        upgradeGroup = 612,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3347, amount = 20}
            }
        }
    },
    [12806] = {
        itemLevel = 289,
        rank = 6,
        upgradeLevel = 6,
        maxUpgradeLevel = 6,
        upgradeGroup = 612,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [5448] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [68100] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8404992] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [8192] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67272704] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [67117056] = {
                 [1] = {currencyId = 3347, amount = 20}
            },
            [131072] = {
                 [1] = {currencyId = 3347, amount = 20}
            }
        }
    }
}

---@type Dictionary<integer>
local inventoryTypeSlotMasks = {

    -- InventoryTypeSlotMask 1048738
    ["INVTYPE_HEAD"] = 1048738,
    ["INVTYPE_CHEST"] = 1048738,
    ["INVTYPE_LEGS"] = 1048738,
    ["INVTYPE_ROBE"] = 1048738,

    -- InventoryTypeSlotMask 5448
    ["INVTYPE_SHOULDER"] = 5448,
    ["INVTYPE_WAIST"] = 5448,
    ["INVTYPE_FEET"] = 5448,
    ["INVTYPE_HAND"] = 5448,
    ["INVTYPE_TRINKET"] = 5448,

    -- InventoryTypeSlotMask 68100
    ["INVTYPE_NECK"] = 68100,
    ["INVTYPE_WRIST"] = 68100,
    ["INVTYPE_FINGER"] = 68100,
    ["INVTYPE_CLOAK"] = 68100,

    -- InventoryTypeSlotMask 8404992
    ["INVTYPE_HOLDABLE"] = 8404992,
    ["INVTYPE_SHIELD"] = 8404992,

    -- InventoryTypeSlotMask 8192
    ["INVTYPE_WEAPON"] = 8192,

    -- InventoryTypeSlotMask 67272704
    ["INVTYPE_RANGED"] = 67272704,
    ["INVTYPE_2HWEAPON"] = 67272704,
    ["INVTYPE_RANGEDRIGHT"] = 67272704,
}

-- Override costs for Intellect items
---@type Dictionary<integer>
local inventoryTypeSlotMaskOverrides = {
    -- InventoryTypeSlotMask 131072
    ["INVTYPE_2HWEAPON"] = 131072,

    -- InventoryTypeSlotMask 67117056
    ["INVTYPE_WEAPON"] = 67117056,
    ["INVTYPE_RANGEDRIGHT"] = 67117056,
}

--- Fetches all the upgrade costs for a given upgrade info
---@param inventoryTypeSlotMask integer
---@param upgradeInfo ItemBonusInfo
---@return UpgradeCostData?
local function GetItemUpgradeCosts(inventoryTypeSlotMask, upgradeInfo)
    ---@type UpgradeCostData
    local results = {
        adventurerCrests = 0,
        veteranCrests = 0,
        championCrests = 0,
        heroCrests = 0,
        mythCrests = 0
    }

    for _, upgradeCost in pairs(upgradeInfo.costs[inventoryTypeSlotMask]) do
        if upgradeCost.currencyId == private.currencyIds["adventurerCrest"] then
            results.adventurerCrests = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["veteranCrest"] then
            results.veteranCrests = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["championCrest"] then
            results.championCrests = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["heroCrest"] then
            results.heroCrests = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["mythCrest"] then
            results.mythCrests = upgradeCost.amount
        end
    end

    return results
end

--- Parses the given upgrade costs to generate a table for use in tooltip
---@param upgradeCostData UpgradeCostData
---@return table
local function ParseUpgradeCost(upgradeCostData)
    local lines = {}
    local compactCostLine = {}

    for upgradeId, upgradeItem in pairs(upgradeData) do
        if upgradeCostData[upgradeId] ~= nil and upgradeCostData[upgradeId] > 0 then
            local icon = upgradeItem.icon and CreateTextureMarkup(upgradeItem.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or
            ""
            local costLine = ""
            local upgradeCost = upgradeCostData[upgradeId];

            if upgradeItem.currencyId ~= nil then
                -- Check currency against cap
                local currencyInfo = private.currencyInfo[upgradeItem.currencyId]
                if currencyInfo == nil then
                    costLine = WHITE_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost))

                    table.insert(compactCostLine, icon .. " " .. costLine)
                else
                    local itemCount = currencyInfo.quantity;
                    local requiredColor = itemCount >= upgradeCost and GREEN_FONT_COLOR or ERROR_COLOR;
                    local heldColor = (currencyInfo.maxQuantity > 0 and currencyInfo.quantity == currencyInfo.maxQuantity) and
                    ERROR_COLOR or WHITE_FONT_COLOR

                    costLine = requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)) ..
                    " / " .. heldColor:WrapTextInColorCode(BreakUpLargeNumbers(currencyInfo.quantity))

                    table.insert(compactCostLine,
                        icon .. " " .. requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)))
                end
            elseif upgradeItem.itemId ~= nil then
                -- Get item count and compare to required
                local itemCount = C_Item.GetItemCount(upgradeItem.itemId, true);
                local requiredColor = itemCount >= upgradeCost and GREEN_FONT_COLOR or ERROR_COLOR;

                costLine = requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)) ..
                " / " .. WHITE_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(itemCount))

                table.insert(compactCostLine,
                    icon .. " " .. requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)))
            else
                costLine = WHITE_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost))

                table.insert(compactCostLine, icon .. " " .. costLine)
            end

            if not private.DB.profile.CompactTooltips then
                table.insert(lines, {
                    left = icon .. " " .. upgradeItem.colorData.color:WrapTextInColorCode(upgradeItem.name),
                    right = costLine,
                    color = upgradeItem.colorData.color
                })
            end
        end
    end

    if private.DB.profile.CompactTooltips then
        table.insert(lines, {
            left = "",
            right = table.concat(compactCostLine, " "),
            color = WHITE_FONT_COLOR
        })
    end

    if #lines == 0 then
        private.Debug("Parsing Crests upgrade cost returned no tooltip lines");
    end

    return lines;
end

--- Updates the tooltip when a Crest item is the item in question
---@param tooltip GameTooltip
---@param inventoryTypeSlotMask integer
---@param bonusId integer
---@param bonusInfo ItemBonusInfo
---@param itemLink string
local function HandleCrests(tooltip, inventoryTypeSlotMask, bonusId, bonusInfo, itemLink)
    if not bonusId or not bonusInfo then
        private.Debug(bonusId, "or Crests bonus info table was not found");
        return
    end

    local WeaponSetHighWatermarkSlots = {
        Enum.ItemRedundancySlot.Twohand,
        Enum.ItemRedundancySlot.OnehandWeapon,
        Enum.ItemRedundancySlot.MainhandWeapon,
        Enum.ItemRedundancySlot.Offhand,
    };

    local characterHighWatermark, accountHighWatermark

    local highWatermarkSlot = C_ItemUpgrade.GetHighWatermarkSlotForItem(itemLink);
    if highWatermarkSlot then
        if tContains(WeaponSetHighWatermarkSlots, highWatermarkSlot) then
            local twoHandCharacterWatermark, twoHandAccountWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(Enum.ItemRedundancySlot.Twohand)
            local oneHandCharacterWatermark, oneHandAccountWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(Enum.ItemRedundancySlot.OnehandWeapon)
            local mainHandCharacterWatermark, mainHandAccountWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(Enum.ItemRedundancySlot.MainhandWeapon)
            local offHandCharacterWatermark, offHandAccountWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(Enum.ItemRedundancySlot.Offhand)

            local highestCharacterWatermarkForSet = 0
            local highestAccountWatermarkForSet = 0

            if twoHandCharacterWatermark > highestCharacterWatermarkForSet then highestCharacterWatermarkForSet = twoHandCharacterWatermark end
            if twoHandAccountWatermark > highestAccountWatermarkForSet then highestAccountWatermarkForSet = twoHandAccountWatermark end

            if oneHandCharacterWatermark > highestCharacterWatermarkForSet then highestCharacterWatermarkForSet = oneHandCharacterWatermark end
            if oneHandAccountWatermark > highestAccountWatermarkForSet then highestAccountWatermarkForSet = oneHandAccountWatermark end

            if mainHandCharacterWatermark   > highestCharacterWatermarkForSet and offHandCharacterWatermark > highestCharacterWatermarkForSet then
                highestCharacterWatermarkForSet = min(mainHandCharacterWatermark, offHandCharacterWatermark)
            end

            if mainHandAccountWatermark > highestAccountWatermarkForSet and offHandAccountWatermark > highestAccountWatermarkForSet then
                highestAccountWatermarkForSet = min(mainHandAccountWatermark, offHandAccountWatermark)
            end

            characterHighWatermark, accountHighWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(highWatermarkSlot)

            private.Debug("2H Character Watermark:", twoHandCharacterWatermark)
            private.Debug("2H Account Watermark:", twoHandAccountWatermark)
            private.Debug("1H Character Watermark:", oneHandCharacterWatermark)
            private.Debug("1H Account Watermark:", oneHandAccountWatermark)
            private.Debug("Mainhand Character Watermark:", mainHandCharacterWatermark)
            private.Debug("Mainhand Account Watermark:", mainHandAccountWatermark)
            private.Debug("Off-Hand Character Watermark:", offHandCharacterWatermark)
            private.Debug("Off-Hand Account Watermark:", offHandAccountWatermark)

            if highWatermarkSlot == Enum.ItemRedundancySlot.Twohand then
             -- 2H weapons can receive a partial discount if player has upgraded 1H weapons
             -- but I don't have info on what that partial discount looks like
            end

            -- all weapons benefit from the highest ilvl "set" of all weapon slots (set = one 2H, two 1H, or main + offhand)
            characterHighWatermark = max(characterHighWatermark, highestCharacterWatermarkForSet)
            accountHighWatermark = max(accountHighWatermark, highestAccountWatermarkForSet)
        else
            -- Regular discount specific to this HWM slot
            characterHighWatermark, accountHighWatermark = C_ItemUpgrade.GetHighWatermarkForSlot(highWatermarkSlot)
        end
    else
        characterHighWatermark, accountHighWatermark = C_ItemUpgrade.GetHighWatermarkForItem(itemLink)
    end

    ---@type UpgradeCostData?
    local nextUpgradeCost = nil

    ---@type ItemBonusInfo?
    local nextUpgrade = nil

    ---@type ItemBonusInfo?
    local maxUpgrade = nil

    ---@type UpgradeCostData
    local totalUpgradeCosts = {
        adventurerCrests = 0,
        veteranCrests = 0,
        championCrests = 0,
        heroCrests = 0,
        mythCrests = 0
    }

    for _, upgradeInfo in pairs(itemBonusIds) do
        if upgradeInfo.rank == bonusInfo.rank and upgradeInfo.upgradeGroup == bonusInfo.upgradeGroup and upgradeInfo.upgradeLevel > bonusInfo.upgradeLevel then
            local upgradeCosts = GetItemUpgradeCosts(inventoryTypeSlotMask, upgradeInfo);
            if upgradeCosts ~= nil then
                local isCharacterDiscounted = upgradeInfo.itemLevel <= characterHighWatermark
                --local isAccountDiscounted = upgradeInfo.itemLevel <= accountHighWatermark

                local adventurerCrests = Round(upgradeCosts.adventurerCrests * (isCharacterDiscounted and 0 or (--[[isAccountDiscounted and 0.66 or]] 1)))
                local veteranCrests = Round(upgradeCosts.veteranCrests * (isCharacterDiscounted and 0 or (--[[isAccountDiscounted and 0.66 or]] 1)))
                local championCrests = Round(upgradeCosts.championCrests * (isCharacterDiscounted and 0 or (--[[isAccountDiscounted and 0.66 or]] 1)))
                local heroCrests = Round(upgradeCosts.heroCrests * (isCharacterDiscounted and 0 or (--[[isAccountDiscounted and 0.66 or]] 1)))
                local mythCrests = Round(upgradeCosts.mythCrests * (isCharacterDiscounted and 0 or (--[[isAccountDiscounted and 0.66 or]] 1)))

                if upgradeInfo.upgradeLevel == (bonusInfo.upgradeLevel + 1) then
                    nextUpgrade = upgradeInfo

                    nextUpgradeCost = {
                        adventurerCrests = adventurerCrests,
                        veteranCrests = veteranCrests,
                        championCrests = championCrests,
                        heroCrests = heroCrests,
                        mythCrests = mythCrests,
                    }
                end

                totalUpgradeCosts.adventurerCrests = totalUpgradeCosts.adventurerCrests + adventurerCrests
                totalUpgradeCosts.veteranCrests = totalUpgradeCosts.veteranCrests + veteranCrests
                totalUpgradeCosts.championCrests = totalUpgradeCosts.championCrests + championCrests
                totalUpgradeCosts.heroCrests = totalUpgradeCosts.heroCrests + heroCrests
                totalUpgradeCosts.mythCrests = totalUpgradeCosts.mythCrests + mythCrests

                if not maxUpgrade or maxUpgrade.upgradeLevel < upgradeInfo.upgradeLevel then
                    maxUpgrade = upgradeInfo
                end
            end
        end
    end

    if nextUpgradeCost and nextUpgrade then
        local nextLevelLines = ParseUpgradeCost(nextUpgradeCost)
        local totalLines = ParseUpgradeCost(totalUpgradeCosts)

        if #nextLevelLines > 0 or #totalLines > 0 then
            tooltip:AddLine("\n")
            tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(L["GOLD_CREST_UPGRADES"], Enum.ItemQuality.Artifact))

            if nextLevelLines then
                if not private.DB.profile.CompactTooltips then
                    -- Standard tooltip
                    tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(L["COST_FOR_NEXT_LEVEL"] .. " (" .. nextUpgrade.itemLevel .. ")", Enum.ItemQuality.Heirloom))

                    for _, newLine in pairs(nextLevelLines) do
                        tooltip:AddDoubleLine(newLine.left, newLine.right)
                    end
                else
                    -- Compact tooltips
                    tooltip:AddDoubleLine(
                        WHITE_FONT_COLOR:WrapTextInColorCode(L["NEXT_UPGRADE_X"]:format(nextUpgrade.itemLevel)),
                        nextLevelLines[1].right
                    )
                end
            end

            if totalLines and maxUpgrade then
                if not private.DB.profile.CompactTooltips then
                    -- Standard tooltip
                    if nextLevelLines then
                        tooltip:AddLine("\n")
                    end

                    tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(
                    L["COST_TO_UPGRADE_TO_MAX"] .. " (" .. maxUpgrade.itemLevel .. ")", Enum.ItemQuality.Heirloom))

                    for _, newLine in pairs(totalLines) do
                        tooltip:AddDoubleLine(newLine.left, newLine.right)
                    end
                else
                    -- Compact tooltips
                    tooltip:AddDoubleLine(
                        WHITE_FONT_COLOR:WrapTextInColorCode(L["MAX_UPGRADE_X"]:format(maxUpgrade.itemLevel)),
                        totalLines[1].right
                    )
                end
            end
        end
    else
        private.Debug("No next Crests upgrade cost could be found for", itemLink);
    end
end

--- Checks for valid bonus IDs and chains call to HandleCrests if found
---@diagnostic disable: unused-local
---@param tooltip GameTooltip
---@param itemId integer
---@param itemLink string
---@param currentUpgrade integer
---@param maxUpgrade integer
---@param bonusIds table<integer, integer>
---@return boolean
local function CheckCrestBonusIDs(tooltip, itemId, itemLink, currentUpgrade, maxUpgrade, bonusIds)
    if private.DB.profile.DisabledIntegrations.Crests then
        private.Debug("Crest upgrade integration is disabled");

        return false
    end

    for i = 1, #bonusIds do
        private.Debug("Checking Crest bonus IDs for", bonusIds[i]);

        ---@type ItemBonusInfo?
        local bonusInfo = itemBonusIds[bonusIds[i]]
        if bonusInfo ~= nil then
            private.Debug(bonusIds[i], "matched a Crest bonus ID");

            local equipLoc = select(9, C_Item.GetItemInfo(itemLink))
            private.Debug(itemLink, "has equipLoc", equipLoc);

            local inventoryTypeSlotMask = inventoryTypeSlotMasks[equipLoc]
            if not inventoryTypeSlotMask then
                private.Debug(equipLoc, "was not found in the Crests inventory slot mask table");
                return false
            end

            local inventoryTypeSlotMaskOverride = inventoryTypeSlotMaskOverrides[equipLoc];
            if inventoryTypeSlotMaskOverride then
                local stats = C_Item.GetItemStats(itemLink)
                if not stats then
                    private.Debug("Could not extract Crests item stats from", itemLink);
                    return false
                end

                local hasInt = (stats["ITEM_MOD_INTELLECT_SHORT"] and stats["ITEM_MOD_INTELLECT_SHORT"] > 0)
                if hasInt then
                    private.Debug("Upgrade cost for has been overridden because the item has Intellect on it.");
                    inventoryTypeSlotMask = inventoryTypeSlotMaskOverride
                end
            end

            if not bonusInfo.costs[inventoryTypeSlotMask] then
                private.Debug(inventoryTypeSlotMask, "was not found in the Crests item extended cost lookup table");
                return false
            end

            HandleCrests(tooltip, inventoryTypeSlotMask, i, bonusInfo, itemLink)
            return true
        end
    end

    private.Debug(itemId, "did not match a Crests bonus ID");
    return false;
end

table.insert(private.upgradeHandlers, CheckCrestBonusIDs)
