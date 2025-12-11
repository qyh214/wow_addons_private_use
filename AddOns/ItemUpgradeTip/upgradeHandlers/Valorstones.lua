-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

-- Add currency information
private.currencyIds["Valorstones"] = 3008
private.currencyIndexes[private.currencyIds.Valorstones] = true

private.currencyIds["weatheredCrest"] = 3284
private.currencyIndexes[private.currencyIds.weatheredCrest] = true

private.currencyIds["carvedCrest"] = 3286
private.currencyIndexes[private.currencyIds.carvedCrest] = true

private.currencyIds["runedCrest"] = 3288
private.currencyIndexes[private.currencyIds.runedCrest] = true

private.currencyIds["gildedCrest"] = 3290
private.currencyIndexes[private.currencyIds.gildedCrest] = true

-- Add preferences
private.Preferences.DefaultValues.profile.DisabledIntegrations.Valorstones = false;
private.Preferences.DisabledIntegrations.Valorstones = {
    type = "toggle",
    name = L["VALORSTONE_CREST_UPGRADES"],
    order = 110,
    width = "double",
}

-- ----------------------------------------------------------------------------
-- Valorstone Upgrade Cost
-- ----------------------------------------------------------------------------
---@class ValorstoneUpgradeCostData
---@field weatheredCrests integer
---@field carvedCrests integer
---@field runedCrests integer
---@field gildedCrests integer
---@field valorstones integer


---@type Dictionary<UpgradeData>
local valorstoneUpgradeData = {
    ["valorstones"] = {
       name = L["VALORSTONES"],
       shortName = L["VALORSTONES"],
       colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Common),
       icon = 5868902,
       itemId = nil,
       currencyId = private.currencyIds.Valorstones
    },

    ["weatheredCrests"] = {
       name = L["WEATHERED_CRESTS"],
       shortName = L["WEATHERED_CRESTS_SHORT"],
       colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Uncommon),
       icon = 5872061,
       itemId = nil,
       currencyId = private.currencyIds.weatheredCrest
    },

    ["carvedCrests"] = {
       name = L["CARVED_CRESTS"],
       shortName = L["CARVED_CRESTS_SHORT"],
       colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Rare),
       icon = 5872055,
       itemId = nil,
       currencyId = private.currencyIds.carvedCrest
    },

    ["runedCrests"] = {
       name = L["RUNED_CRESTS"],
       shortName = L["RUNED_CRESTS_SHORT"],
       colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Epic),
       icon = 5872059,
       itemId = nil,
       currencyId = private.currencyIds.runedCrest
    },

    ["gildedCrests"] = {
       name = L["GILDED_CRESTS"],
       shortName = L["GILDED_CRESTS_SHORT"],
       colorData = ColorManager.GetColorDataForItemQuality(Enum.ItemQuality.Legendary),
       icon = 5872057,
       itemId = nil,
       currencyId = private.currencyIds.gildedCrest
    },
}

---@type Array<MythicPlusInfo>
private.mythicPlusInfo = {
    {keyLevel = 0,     lootDrops = 681, vaultReward = 691, currency = valorstoneUpgradeData["carvedCrests"]},
    {keyLevel = 2,     lootDrops = 684, vaultReward = 694, currency = valorstoneUpgradeData["runedCrests"]},
    {keyLevel = 3,     lootDrops = 684, vaultReward = 694, currency = valorstoneUpgradeData["runedCrests"]},
    {keyLevel = 4,     lootDrops = 688, vaultReward = 697, currency = valorstoneUpgradeData["runedCrests"]},
    {keyLevel = 5,     lootDrops = 691, vaultReward = 697, currency = valorstoneUpgradeData["runedCrests"]},
    {keyLevel = 6,     lootDrops = 694, vaultReward = 701, currency = valorstoneUpgradeData["runedCrests"]},
    {keyLevel = 7,     lootDrops = 694, vaultReward = 704, currency = valorstoneUpgradeData["gildedCrests"]},
    {keyLevel = 8,     lootDrops = 697, vaultReward = 704, currency = valorstoneUpgradeData["gildedCrests"]},
    {keyLevel = 9,     lootDrops = 697, vaultReward = 704, currency = valorstoneUpgradeData["gildedCrests"]},
    {keyLevel = "10+", lootDrops = 701, vaultReward = 707, currency = valorstoneUpgradeData["gildedCrests"]},
}

---@type Array<RaidInfo>
private.raidInfo = {
    {boss = 1,                      lfr = 671, normal = 684, heroic = 697, mythic = 710},
    {boss = 2,                      lfr = 671, normal = 684, heroic = 697, mythic = 710},
    {boss = 3,                      lfr = 671, normal = 684, heroic = 697, mythic = 710},
    {boss = L["X_RARE"]:format(3),  lfr = 684, normal = 697, heroic = 710, mythic = 723},
    {boss = 4,                      lfr = 675, normal = 688, heroic = 701, mythic = 717},
    {boss = L["X_RARE"]:format(4),  lfr = 684, normal = 697, heroic = 710, mythic = 723},
    {boss = 5,                      lfr = 675, normal = 688, heroic = 701, mythic = 717},
    {boss = 6,                      lfr = 675, normal = 688, heroic = 701, mythic = 717},
    {boss = L["X_RARE"]:format(6),  lfr = 684, normal = 697, heroic = 710, mythic = 723},
    {boss = 7,                      lfr = 678, normal = 691, heroic = 704, mythic = 717},
    {boss = 8,                      lfr = 678, normal = 691, heroic = 704, mythic = 717},
    {boss = L["X_RARE"]:format(8),  lfr = 684, normal = 697, heroic = 710, mythic = 723},
}

---@type RaidCurrencyInfo
 private.raidCurrencyInfo = {
    -- LFR
    lfrCurrency = valorstoneUpgradeData["weatheredCrests"],

    -- Normal
    normalCurrency = valorstoneUpgradeData["carvedCrests"],

    -- Heroic
    heroicCurrency = valorstoneUpgradeData["runedCrests"],

    -- Mythic
    mythicCurrency = valorstoneUpgradeData["gildedCrests"],
}

---@type Array<UpgradeTrackInfo>
private.upgradeTrackInfo = {
    {
        itemLevel = 655,
        upgrade1 = {rank = 2, upgradeLevel = 1, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["valorstones"]
    },
    {
        itemLevel = 658,
        upgrade1 = {rank = 2, upgradeLevel = 2, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["valorstones"]
    },
    {
        itemLevel = 661,
        upgrade1 = {rank = 2, upgradeLevel = 3, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["valorstones"]
    },
    {
        itemLevel = 664,
        upgrade1 = {rank = 2, upgradeLevel = 4, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["valorstones"]
    },
    {
        itemLevel = 668,
        upgrade1 = {rank = 2, upgradeLevel = 5, maxUpgradeLevel = 8},
        upgrade2 = {rank = 3, upgradeLevel = 1, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        itemLevel = 671,
        upgrade1 = {rank = 2, upgradeLevel = 6, maxUpgradeLevel = 8},
        upgrade2 = {rank = 3, upgradeLevel = 2, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        itemLevel = 675,
        upgrade1 = {rank = 2, upgradeLevel = 7, maxUpgradeLevel = 8},
        upgrade2 = {rank = 3, upgradeLevel = 3, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        itemLevel = 678,
        upgrade1 = {rank = 2, upgradeLevel = 8, maxUpgradeLevel = 8},
        upgrade2 = {rank = 3, upgradeLevel = 4, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        itemLevel = 681,
        upgrade1 = {rank = 3, upgradeLevel = 5, maxUpgradeLevel = 8},
        upgrade2 = {rank = 4, upgradeLevel = 1, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["carvedCrests"]
    },
    {
        itemLevel = 684,
        upgrade1 = {rank = 3, upgradeLevel = 6, maxUpgradeLevel = 8},
        upgrade2 = {rank = 4, upgradeLevel = 2, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["carvedCrests"]
    },
    {
        itemLevel = 688,
        upgrade1 = {rank = 3, upgradeLevel = 7, maxUpgradeLevel = 8},
        upgrade2 = {rank = 4, upgradeLevel = 3, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["carvedCrests"]
    },
    {
        itemLevel = 691,
        upgrade1 = {rank = 3, upgradeLevel = 8, maxUpgradeLevel = 8},
        upgrade2 = {rank = 4, upgradeLevel = 4, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["carvedCrests"]
    },
    {
        itemLevel = 694,
        upgrade1 = {rank = 4, upgradeLevel = 5, maxUpgradeLevel = 8},
        upgrade2 = {rank = 5, upgradeLevel = 1, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["runedCrests"]
    },
    {
        itemLevel = 697,
        upgrade1 = {rank = 4, upgradeLevel = 6, maxUpgradeLevel = 8},
        upgrade2 = {rank = 5, upgradeLevel = 2, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["runedCrests"]
    },
    {
        itemLevel = 701,
        upgrade1 = {rank = 4, upgradeLevel = 7, maxUpgradeLevel = 8},
        upgrade2 = {rank = 5, upgradeLevel = 3, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["runedCrests"]
    },
    {
        itemLevel = 704,
        upgrade1 = {rank = 4, upgradeLevel = 8, maxUpgradeLevel = 8},
        upgrade2 = {rank = 5, upgradeLevel = 4, maxUpgradeLevel = 8},
        currency = valorstoneUpgradeData["runedCrests"]
    },
    {
        itemLevel = 707,
        upgrade1 = {rank = 5, upgradeLevel = 5, maxUpgradeLevel = 6},
        upgrade2 = {rank = 6, upgradeLevel = 1, maxUpgradeLevel = 6},
        currency = valorstoneUpgradeData["gildedCrests"]
    },
    {
        itemLevel = 710,
        upgrade1 = {rank = 5, upgradeLevel = 6, maxUpgradeLevel = 6},
        upgrade2 = {rank = 6, upgradeLevel = 2, maxUpgradeLevel = 6},
        currency = valorstoneUpgradeData["gildedCrests"]
    },
    {
        itemLevel = 714,
        upgrade1 = {rank = 6, upgradeLevel = 3, maxUpgradeLevel = 6},
        currency = valorstoneUpgradeData["gildedCrests"]
    },
    {
        itemLevel = 717,
        upgrade1 = {rank = 6, upgradeLevel = 4, maxUpgradeLevel = 6},
        currency = valorstoneUpgradeData["gildedCrests"]
    },
    {
        itemLevel = 720,
        upgrade1 = {rank = 6, upgradeLevel = 5, maxUpgradeLevel = 6},
        currency = valorstoneUpgradeData["gildedCrests"]
    },
    {
        itemLevel = 723,
        upgrade1 = {rank = 6, upgradeLevel = 6, maxUpgradeLevel = 6},
        currency = valorstoneUpgradeData["gildedCrests"]
    },
}

---@type Array<BountifulDelveInfo>
private.bountifulDelveInfo = {
    {
        tier = 1,
        loot = {itemLevel = 655, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 668, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 2,
        loot = {itemLevel = 658, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 671, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 3,
        loot = {itemLevel = 661, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 675, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 4,
        loot = {itemLevel = 664, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 678, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 5,
        loot = {itemLevel = 668, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 681, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 6,
        loot = {itemLevel = 671, upgradeTrack = L["UPGRADE_TRACK_VETERAN"]},
        vault = {itemLevel = 688, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        currency = valorstoneUpgradeData["carvedCrests"]
    },
    {
        tier = 7,
        loot = {itemLevel = 681, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 691, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 8,
        loot = {itemLevel = 684, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 694, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 9,
        loot = {itemLevel = 684, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 694, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 10,
        loot = {itemLevel = 684, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 694, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = valorstoneUpgradeData["weatheredCrests"]
    },
    {
        tier = 11,
        loot = {itemLevel = 684, upgradeTrack = L["UPGRADE_TRACK_CHAMPION"]},
        vault = {itemLevel = 694, upgradeTrack = L["UPGRADE_TRACK_HERO"]},
        currency = valorstoneUpgradeData["gildedCrests"]
    }
}

---@type Array<CraftingInfo>
private.craftingInfo = {
    -- Weathered
    {itemLevel = 662, itemId = 231767, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 665, itemId = 231767, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 668, itemId = 231767, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 671, itemId = 231767, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 675, itemId = 231767, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},

    -- Line break
    {itemLevel = 0, itemId = 0, rank = 0, iconPath = ""},

    -- Spark
    {itemLevel = 678, itemId = 231756, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 681, itemId = 231756, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 684, itemId = 231756, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 688, itemId = 231756, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 691, itemId = 231756, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},

    -- Line break
    {itemLevel = 0, itemId = 0, rank = 0, iconPath = ""},

    -- Runed
    {itemLevel = 691, itemId = 231769, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 694, itemId = 231769, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 697, itemId = 231769, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 701, itemId = 231769, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 704, itemId = 231769, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},

    -- Line break
    {itemLevel = 0, itemId = 0, rank = 0, iconPath = ""},

    -- Gilded
    {itemLevel = 707, itemId = 231768, rank = 1, iconPath = "Professions-ChatIcon-Quality-Tier1"},
    {itemLevel = 710, itemId = 231768, rank = 2, iconPath = "Professions-ChatIcon-Quality-Tier2"},
    {itemLevel = 714, itemId = 231768, rank = 3, iconPath = "Professions-ChatIcon-Quality-Tier3"},
    {itemLevel = 717, itemId = 231768, rank = 4, iconPath = "Professions-ChatIcon-Quality-Tier4"},
    {itemLevel = 720, itemId = 231768, rank = 5, iconPath = "Professions-ChatIcon-Quality-Tier5"},
}

---@type Array<ItemBonusInfo>
local itemBonusIds = {

    -- Explorer (8)
    [12265] = {
        itemLevel = 642,
        rank = 1,
        upgradeLevel = 1,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 100}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 100}
            }
        }
    },
    [12266] = {
        itemLevel = 645,
        rank = 1,
        upgradeLevel = 2,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 100}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 100}
            }
        }
    },
    [12267] = {
        itemLevel = 649,
        rank = 1,
        upgradeLevel = 3,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 100}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 100}
            }
        }
    },
    [12268] = {
        itemLevel = 652,
        rank = 1,
        upgradeLevel = 4,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 25}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 50}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 100}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 100}
            }
        }
    },
    [12269] = {
        itemLevel = 655,
        rank = 1,
        upgradeLevel = 5,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },
    [12270] = {
        itemLevel = 658,
        rank = 1,
        upgradeLevel = 6,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },
    [12271] = {
        itemLevel = 662,
        rank = 1,
        upgradeLevel = 7,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },
    [12272] = {
        itemLevel = 665,
        rank = 1,
        upgradeLevel = 8,
        maxUpgradeLevel = 8,
        upgradeGroup = 513,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },

    -- Adventurer (8)
    [12274] = {
        itemLevel = 655,
        rank = 2,
        upgradeLevel = 1,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },
    [12275] = {
        itemLevel = 658,
        rank = 2,
        upgradeLevel = 2,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },
    [12276] = {
        itemLevel = 662,
        rank = 2,
        upgradeLevel = 3,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },
    [12277] = {
        itemLevel = 665,
        rank = 2,
        upgradeLevel = 4,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 75}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 65}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 40}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 80}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 160}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 120}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 160}
            }
        }
    },
    [12278] = {
        itemLevel = 668,
        rank = 2,
        upgradeLevel = 5,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },
    [12279] = {
        itemLevel = 671,
        rank = 2,
        upgradeLevel = 6,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },
    [12280] = {
        itemLevel = 675,
        rank = 2,
        upgradeLevel = 7,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },
    [12281] = {
        itemLevel = 678,
        rank = 2,
        upgradeLevel = 8,
        maxUpgradeLevel = 8,
        upgradeGroup = 514,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },

    -- Veteran (8)
    [12282] = {
        itemLevel = 668,
        rank = 3,
        upgradeLevel = 1,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },
    [12283] = {
        itemLevel = 671,
        rank = 3,
        upgradeLevel = 2,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },
    [12284] = {
        itemLevel = 675,
        rank = 3,
        upgradeLevel = 3,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },
    [12285] = {
        itemLevel = 678,
        rank = 3,
        upgradeLevel = 4,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 65},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 125},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3284, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 250},
                 [2] = {currencyId = 3284, amount = 15}
            }
        }
    },
    [12286] = {
        itemLevel = 681,
        rank = 3,
        upgradeLevel = 5,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },
    [12287] = {
        itemLevel = 684,
        rank = 3,
        upgradeLevel = 6,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },
    [12288] = {
        itemLevel = 688,
        rank = 3,
        upgradeLevel = 7,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },
    [12289] = {
        itemLevel = 691,
        rank = 3,
        upgradeLevel = 8,
        maxUpgradeLevel = 8,
        upgradeGroup = 515,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },

    -- Champion (8)
    [12290] = {
        itemLevel = 681,
        rank = 4,
        upgradeLevel = 1,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },
    [12291] = {
        itemLevel = 684,
        rank = 4,
        upgradeLevel = 2,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },
    [12292] = {
        itemLevel = 688,
        rank = 4,
        upgradeLevel = 3,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },
    [12293] = {
        itemLevel = 691,
        rank = 4,
        upgradeLevel = 4,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 145},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 120},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 75},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 150},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 225},
                 [2] = {currencyId = 3286, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3286, amount = 15}
            }
        }
    },
    [12294] = {
        itemLevel = 694,
        rank = 4,
        upgradeLevel = 5,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },
    [12295] = {
        itemLevel = 697,
        rank = 4,
        upgradeLevel = 6,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },
    [12296] = {
        itemLevel = 701,
        rank = 4,
        upgradeLevel = 7,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },
    [12297] = {
        itemLevel = 704,
        rank = 4,
        upgradeLevel = 8,
        maxUpgradeLevel = 8,
        upgradeGroup = 516,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },

    -- Hero (8)
    [12350] = {
        itemLevel = 694,
        rank = 5,
        upgradeLevel = 1,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },
    [12351] = {
        itemLevel = 697,
        rank = 5,
        upgradeLevel = 2,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },
    [12352] = {
        itemLevel = 701,
        rank = 5,
        upgradeLevel = 3,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },
    [12353] = {
        itemLevel = 704,
        rank = 5,
        upgradeLevel = 4,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 170},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 140},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 90},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 175},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 275},
                 [2] = {currencyId = 3288, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 350},
                 [2] = {currencyId = 3288, amount = 15}
            }
        }
    },
    [12354] = {
        itemLevel = 707,
        rank = 5,
        upgradeLevel = 5,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [12355] = {
        itemLevel = 710,
        rank = 5,
        upgradeLevel = 6,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [13443] = {
        itemLevel = 714,
        rank = 5,
        upgradeLevel = 7,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [13444] = {
        itemLevel = 717,
        rank = 5,
        upgradeLevel = 8,
        maxUpgradeLevel = 8,
        upgradeGroup = 517,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },

    -- Myth (8)
    [12356] = {
        itemLevel = 707,
        rank = 6,
        upgradeLevel = 1,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [12357] = {
        itemLevel = 710,
        rank = 6,
        upgradeLevel = 2,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [12358] = {
        itemLevel = 714,
        rank = 6,
        upgradeLevel = 3,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [12359] = {
        itemLevel = 717,
        rank = 6,
        upgradeLevel = 4,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [12360] = {
        itemLevel = 720,
        rank = 6,
        upgradeLevel = 5,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [12361] = {
        itemLevel = 723,
        rank = 6,
        upgradeLevel = 6,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [13445] = {
        itemLevel = 727,
        rank = 6,
        upgradeLevel = 7,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            }
        }
    },
    [13446] = {
        itemLevel = 730,
        rank = 6,
        upgradeLevel = 8,
        maxUpgradeLevel = 8,
        upgradeGroup = 518,
        costs = {
            [1048738] = {
                 [1] = {currencyId = 3008, amount = 190},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [5448] = {
                 [1] = {currencyId = 3008, amount = 160},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [68100] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8404992] = {
                 [1] = {currencyId = 3008, amount = 100},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [8192] = {
                 [1] = {currencyId = 3008, amount = 200},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67272704] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [67117056] = {
                 [1] = {currencyId = 3008, amount = 300},
                 [2] = {currencyId = 3290, amount = 15}
            },
            [131072] = {
                 [1] = {currencyId = 3008, amount = 400},
                 [2] = {currencyId = 3290, amount = 15}
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
---@return ValorstoneUpgradeCostData?
local function GetItemUpgradeCosts(inventoryTypeSlotMask, upgradeInfo)
    ---@type ValorstoneUpgradeCostData
    local results = {
       weatheredCrests = 0,
       carvedCrests = 0,
       runedCrests = 0,
       gildedCrests = 0,
       valorstones = 0
    }

    for _, upgradeCost in pairs(upgradeInfo.costs[inventoryTypeSlotMask]) do
       if upgradeCost.currencyId == private.currencyIds["Valorstones"] then
          results.valorstones = upgradeCost.amount
       elseif upgradeCost.currencyId == private.currencyIds["weatheredCrest"] then
          results.weatheredCrests = upgradeCost.amount
       elseif upgradeCost.currencyId == private.currencyIds["carvedCrest"] then
          results.carvedCrests = upgradeCost.amount
       elseif upgradeCost.currencyId == private.currencyIds["runedCrest"] then
          results.runedCrests = upgradeCost.amount
       elseif upgradeCost.currencyId == private.currencyIds["gildedCrest"] then
          results.gildedCrests = upgradeCost.amount
       end
    end

    return results
end

--- Parses the given upgrade costs to generate a table for use in tooltip
---@param upgradeCostData ValorstoneUpgradeCostData
---@return table
local function ParseUpgradeCost(upgradeCostData)
    local lines = {}
    local compactCostLine = {}

    for upgradeId, upgradeItem in pairs(valorstoneUpgradeData) do
       if upgradeCostData[upgradeId] ~= nil and upgradeCostData[upgradeId] > 0 then
          local icon = upgradeItem.icon and CreateTextureMarkup(upgradeItem.icon, 64, 64, 0, 0, 0.1, 0.9, 0.1, 0.9) or ""
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
                local heldColor = (currencyInfo.maxQuantity > 0 and currencyInfo.quantity == currencyInfo.maxQuantity) and ERROR_COLOR or WHITE_FONT_COLOR

                costLine = requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)) .. " / " .. heldColor:WrapTextInColorCode(BreakUpLargeNumbers(currencyInfo.quantity))

                table.insert(compactCostLine, icon .. " " .. requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)))
             end
          elseif upgradeItem.itemId ~= nil then
             -- Get item count and compare to required
             local itemCount = C_Item.GetItemCount(upgradeItem.itemId, true);
             local requiredColor = itemCount >= upgradeCost and GREEN_FONT_COLOR or ERROR_COLOR;

             costLine = requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)) .. " / " .. WHITE_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(itemCount))

             table.insert(compactCostLine, icon .. " " .. requiredColor:WrapTextInColorCode(BreakUpLargeNumbers(upgradeCost)))
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
          right = table.concat(compactCostLine, "  "),
          color = WHITE_FONT_COLOR
       })
    end

    if #lines == 0 then
       private.Debug("Parsing Valorstones upgrade cost returned no tooltip lines");
    end

    return lines;
end

--- Updates the tooltip when a Valorstone item is the item in question
---@param tooltip GameTooltip
---@param inventoryTypeSlotMask integer
---@param bonusId integer
---@param bonusInfo ItemBonusInfo
---@param itemLink string
local function HandleValorstones(tooltip, inventoryTypeSlotMask, bonusId, bonusInfo, itemLink)
    if not bonusId or not bonusInfo then
       private.Debug(bonusId, "or Valorstones bonus info table was not found");
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

          if mainHandCharacterWatermark  > highestCharacterWatermarkForSet and offHandCharacterWatermark > highestCharacterWatermarkForSet then
             highestCharacterWatermarkForSet = min(mainHandCharacterWatermark, offHandCharacterWatermark)
          end

          if mainHandAccountWatermark  > highestAccountWatermarkForSet and offHandAccountWatermark > highestAccountWatermarkForSet then
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

    ---@type ValorstoneUpgradeCostData?
    local nextUpgradeCost = nil

    ---@type ItemBonusInfo?
    local nextUpgrade = nil

    ---@type ItemBonusInfo?
    local maxUpgrade = nil

    ---@type ValorstoneUpgradeCostData
    local totalUpgradeCosts = {
       weatheredCrests = 0,
       carvedCrests = 0,
       runedCrests = 0,
       gildedCrests = 0,
       valorstones = 0,
    }

    for _, upgradeInfo in pairs(itemBonusIds) do
       if upgradeInfo.rank == bonusInfo.rank and upgradeInfo.upgradeGroup == bonusInfo.upgradeGroup and upgradeInfo.upgradeLevel > bonusInfo.upgradeLevel then
          local upgradeCosts = GetItemUpgradeCosts(inventoryTypeSlotMask, upgradeInfo);
          if upgradeCosts ~= nil then
             local isCharacterDiscounted = upgradeInfo.itemLevel <= characterHighWatermark
             local isAccountDiscounted = upgradeInfo.itemLevel <= accountHighWatermark

             local weatheredCrests = Round(upgradeCosts.weatheredCrests * (isCharacterDiscounted and 0 or (isAccountDiscounted and 0.66 or 1)))
             local carvedCrests = Round(upgradeCosts.carvedCrests * (isCharacterDiscounted and 0 or (isAccountDiscounted and 0.66 or 1)))
             local runedCrests = Round(upgradeCosts.runedCrests * (isCharacterDiscounted and 0 or (isAccountDiscounted and 0.66 or 1)))
             local gildedCrests = Round(upgradeCosts.gildedCrests * (isCharacterDiscounted and 0 or (isAccountDiscounted and 0.66 or 1)))
             local valorstones = Round(upgradeCosts.valorstones * (isAccountDiscounted and 0.5 or 1))

             if upgradeInfo.upgradeLevel == (bonusInfo.upgradeLevel + 1) then
                nextUpgrade = upgradeInfo

                nextUpgradeCost = {
                    weatheredCrests = weatheredCrests,
                    carvedCrests = carvedCrests,
                    runedCrests = runedCrests,
                    gildedCrests = gildedCrests,
                    valorstones = valorstones,
                }
             end

             totalUpgradeCosts.weatheredCrests = totalUpgradeCosts.weatheredCrests + weatheredCrests
             totalUpgradeCosts.carvedCrests = totalUpgradeCosts.carvedCrests + carvedCrests
             totalUpgradeCosts.runedCrests = totalUpgradeCosts.runedCrests + runedCrests
             totalUpgradeCosts.gildedCrests = totalUpgradeCosts.gildedCrests + gildedCrests
             totalUpgradeCosts.valorstones = totalUpgradeCosts.valorstones + valorstones

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
          tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(L["VALORSTONE_CREST_UPGRADES"], Enum.ItemQuality.Artifact))

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

                tooltip:AddLine(ColorManager.GetFormattedStringForItemQuality(L["COST_TO_UPGRADE_TO_MAX"] .. " (" .. maxUpgrade.itemLevel .. ")", Enum.ItemQuality.Heirloom))

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
       private.Debug("No next Valorstones upgrade cost could be found for", itemLink);
    end
end

--- Checks for valid bonus IDs and chains call to HandleValorstones if found
---@diagnostic disable: unused-local
---@param tooltip GameTooltip
---@param itemId integer
---@param itemLink string
---@param currentUpgrade integer
---@param maxUpgrade integer
---@param bonusIds table<integer, integer>
---@return boolean
local function CheckValorstoneBonusIDs(tooltip, itemId, itemLink, currentUpgrade, maxUpgrade, bonusIds)
    if private.DB.profile.DisabledIntegrations.Valorstones then
       private.Debug("Valorstones integration is disabled");

       return false
    end

    for i = 1, #bonusIds do
       private.Debug("Checking Valorstone bonus IDs for", bonusIds[i]);

       ---@type ItemBonusInfo?
       local bonusInfo = itemBonusIds[bonusIds[i]]
       if bonusInfo ~= nil then
          private.Debug(bonusIds[i], "matched a Valorstone bonus ID");

          local equipLoc = select(9, C_Item.GetItemInfo(itemLink))
          private.Debug(itemLink, "has equipLoc", equipLoc);

          local inventoryTypeSlotMask = inventoryTypeSlotMasks[equipLoc]
          if not inventoryTypeSlotMask then
             private.Debug(equipLoc, "was not found in the Valorstones inventory slot mask table");
             return false
          end

          local inventoryTypeSlotMaskOverride = inventoryTypeSlotMaskOverrides[equipLoc];
          if inventoryTypeSlotMaskOverride then
             local stats = C_Item.GetItemStats(itemLink)
             if not stats then
                private.Debug("Could not extract Valorstones item stats from", itemLink);
                return false
             end
             local hasInt = (stats["ITEM_MOD_INTELLECT_SHORT"] and stats["ITEM_MOD_INTELLECT_SHORT"] > 0)
             if hasInt then
                private.Debug("Upgrade cost for has been overridden because the item has Intellect on it.");
                inventoryTypeSlotMask = inventoryTypeSlotMaskOverride
             end
          end

          if not bonusInfo.costs[inventoryTypeSlotMask] then
             private.Debug(inventoryTypeSlotMask, "was not found in the Valorstones item extended cost lookup table");
             return false
          end

          HandleValorstones(tooltip, inventoryTypeSlotMask, i, bonusInfo, itemLink)
          return true
       end
    end

    private.Debug(itemId, "did not match a Valorstones bonus ID");
    return false;
end

table.insert(private.upgradeHandlers, CheckValorstoneBonusIDs)
