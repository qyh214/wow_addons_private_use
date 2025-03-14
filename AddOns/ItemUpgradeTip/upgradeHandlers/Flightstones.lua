-- ----------------------------------------------------------------------------
-- AddOn Namespace
-- ----------------------------------------------------------------------------
local AddOnFolderName = ... ---@type string
local private = select(2, ...) ---@class PrivateNamespace

---@type Localizations
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnFolderName)

-- Add currency information
private.currencyIds["Flightstones"] = 2245
private.currencyIndexes[private.currencyIds.Flightstones] = true

private.currencyIds["whelpCrest"] = 2806
private.currencyIndexes[private.currencyIds.whelpCrest] = true

private.currencyIds["drakeCrest"] = 2807
private.currencyIndexes[private.currencyIds.drakeCrest] = true

private.currencyIds["wyrmCrest"] = 2809
private.currencyIndexes[private.currencyIds.wyrmCrest] = true

private.currencyIds["aspectCrest"] = 2812
private.currencyIndexes[private.currencyIds.aspectCrest] = true

-- Add preferences
private.Preferences.DefaultValues.profile.DisabledIntegrations.Flightstones = false;
private.Preferences.DisabledIntegrations.Flightstones = {
    type = "toggle",
    name = L["FLIGHTSTONE_CREST_UPGRADES"],
    order = 110,
    width = "double",
}

-- ----------------------------------------------------------------------------
-- Flightstone Upgrade Cost
-- ----------------------------------------------------------------------------
---@class FlightstoneUpgradeCostData
---@field whelpCrests integer
---@field drakeCrests integer
---@field wyrmCrests integer
---@field aspectCrests integer
---@field flightstones integer


---@type Dictionary<UpgradeData>
local flightstoneUpgradeData = {
    ["flightstones"] = {
        name = L["FLIGHTSTONES"],
        shortName = L["FLIGHTSTONES"],
        color = WHITE_FONT_COLOR,
        icon = 5172976,
        itemId = nil,
        currencyId = private.currencyIds.Flightstones
    },

    ["whelpCrests"] = {
        name = L["WHELP_CRESTS"],
        shortName = L["WHELP_CRESTS_SHORT"],
        color = UNCOMMON_GREEN_COLOR,
        icon = 5646099,
        itemId = nil,
        currencyId = private.currencyIds.whelpCrest
    },

    ["drakeCrests"] = {
        name = L["DRAKE_CRESTS"],
        shortName = L["DRAKE_CRESTS_SHORT"],
        color = RARE_BLUE_COLOR,
        icon = 5646097,
        itemId = nil,
        currencyId = private.currencyIds.drakeCrest
    },

    ["wyrmCrests"] = {
        name = L["WYRM_CRESTS"],
        shortName = L["WYRM_CRESTS_SHORT"],
        color = EPIC_PURPLE_COLOR,
        icon = 5646101,
        itemId = nil,
        currencyId = private.currencyIds.wyrmCrest
    },

    ["aspectCrests"] = {
        name = L["ASPECT_CRESTS"],
        shortName = L["ASPECT_CRESTS_SHORT"],
        color = LEGENDARY_ORANGE_COLOR,
        icon = 5646095,
        itemId = nil,
        currencyId = private.currencyIds.aspectCrest
    },
}

---@type Array<ItemBonusInfo>
local itemBonusIds = {

        -- Explorer (8)
        [10321] = {
            itemLevel = 454,
            rank = 1,
            upgradeLevel = 1,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 100}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 100}
                }
            }
        },
        [10322] = {
            itemLevel = 457,
            rank = 1,
            upgradeLevel = 2,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 100}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 100}
                }
            }
        },
        [10323] = {
            itemLevel = 460,
            rank = 1,
            upgradeLevel = 3,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 100}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 100}
                }
            }
        },
        [10324] = {
            itemLevel = 463,
            rank = 1,
            upgradeLevel = 4,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 25}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 50}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 100}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 100}
                }
            }
        },
        [10325] = {
            itemLevel = 467,
            rank = 1,
            upgradeLevel = 5,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },
        [10326] = {
            itemLevel = 470,
            rank = 1,
            upgradeLevel = 6,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },
        [10327] = {
            itemLevel = 473,
            rank = 1,
            upgradeLevel = 7,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },
        [10328] = {
            itemLevel = 476,
            rank = 1,
            upgradeLevel = 8,
            maxUpgradeLevel = 8,
            upgradeGroup = 354,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },

        -- Adventurer (8)
        [10305] = {
            itemLevel = 467,
            rank = 2,
            upgradeLevel = 1,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },
        [10306] = {
            itemLevel = 470,
            rank = 2,
            upgradeLevel = 2,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },
        [10307] = {
            itemLevel = 473,
            rank = 2,
            upgradeLevel = 3,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },
        [10308] = {
            itemLevel = 476,
            rank = 2,
            upgradeLevel = 4,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 75}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 65}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 40}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 80}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 160}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 120}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 160}
                }
            }
        },
        [10309] = {
            itemLevel = 480,
            rank = 2,
            upgradeLevel = 5,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },
        [10310] = {
            itemLevel = 483,
            rank = 2,
            upgradeLevel = 6,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },
        [10311] = {
            itemLevel = 486,
            rank = 2,
            upgradeLevel = 7,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },
        [10312] = {
            itemLevel = 489,
            rank = 2,
            upgradeLevel = 8,
            maxUpgradeLevel = 8,
            upgradeGroup = 342,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },

        -- Veteran (8)
        [10341] = {
            itemLevel = 480,
            rank = 3,
            upgradeLevel = 1,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },
        [10342] = {
            itemLevel = 483,
            rank = 3,
            upgradeLevel = 2,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },
        [10343] = {
            itemLevel = 486,
            rank = 3,
            upgradeLevel = 3,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },
        [10344] = {
            itemLevel = 489,
            rank = 3,
            upgradeLevel = 4,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 65},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 125},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2806, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 250},
                     [2] = {currencyId = 2806, amount = 15}
                }
            }
        },
        [10345] = {
            itemLevel = 493,
            rank = 3,
            upgradeLevel = 5,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10346] = {
            itemLevel = 496,
            rank = 3,
            upgradeLevel = 6,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10347] = {
            itemLevel = 499,
            rank = 3,
            upgradeLevel = 7,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10348] = {
            itemLevel = 502,
            rank = 3,
            upgradeLevel = 8,
            maxUpgradeLevel = 8,
            upgradeGroup = 355,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },

        -- Champion (8)
        [10313] = {
            itemLevel = 493,
            rank = 4,
            upgradeLevel = 1,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10314] = {
            itemLevel = 496,
            rank = 4,
            upgradeLevel = 2,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10315] = {
            itemLevel = 499,
            rank = 4,
            upgradeLevel = 3,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10316] = {
            itemLevel = 502,
            rank = 4,
            upgradeLevel = 4,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 120},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 225},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10317] = {
            itemLevel = 506,
            rank = 4,
            upgradeLevel = 5,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10318] = {
            itemLevel = 509,
            rank = 4,
            upgradeLevel = 6,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10319] = {
            itemLevel = 512,
            rank = 4,
            upgradeLevel = 7,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10320] = {
            itemLevel = 515,
            rank = 4,
            upgradeLevel = 8,
            maxUpgradeLevel = 8,
            upgradeGroup = 356,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },

        -- Hero (6)
        [10329] = {
            itemLevel = 506,
            rank = 5,
            upgradeLevel = 1,
            maxUpgradeLevel = 6,
            upgradeGroup = 357,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10330] = {
            itemLevel = 509,
            rank = 5,
            upgradeLevel = 2,
            maxUpgradeLevel = 6,
            upgradeGroup = 357,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10331] = {
            itemLevel = 512,
            rank = 5,
            upgradeLevel = 3,
            maxUpgradeLevel = 6,
            upgradeGroup = 357,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10332] = {
            itemLevel = 515,
            rank = 5,
            upgradeLevel = 4,
            maxUpgradeLevel = 6,
            upgradeGroup = 357,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 140},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 90},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 275},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 350},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10333] = {
            itemLevel = 519,
            rank = 5,
            upgradeLevel = 5,
            maxUpgradeLevel = 6,
            upgradeGroup = 357,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 160},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10334] = {
            itemLevel = 522,
            rank = 5,
            upgradeLevel = 6,
            maxUpgradeLevel = 6,
            upgradeGroup = 357,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 160},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },

        -- Myth (4)
        [10335] = {
            itemLevel = 519,
            rank = 6,
            upgradeLevel = 1,
            maxUpgradeLevel = 4,
            upgradeGroup = 358,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 160},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10336] = {
            itemLevel = 522,
            rank = 6,
            upgradeLevel = 2,
            maxUpgradeLevel = 4,
            upgradeGroup = 358,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 160},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10337] = {
            itemLevel = 525,
            rank = 6,
            upgradeLevel = 3,
            maxUpgradeLevel = 4,
            upgradeGroup = 358,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 160},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10338] = {
            itemLevel = 528,
            rank = 6,
            upgradeLevel = 4,
            maxUpgradeLevel = 4,
            upgradeGroup = 358,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 160},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 300},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 400},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },

        -- Awakened (12)
        [10407] = {
            itemLevel = 493,
            rank = 7,
            upgradeLevel = 1,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10408] = {
            itemLevel = 496,
            rank = 7,
            upgradeLevel = 2,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10409] = {
            itemLevel = 499,
            rank = 7,
            upgradeLevel = 3,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10410] = {
            itemLevel = 502,
            rank = 7,
            upgradeLevel = 4,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10411] = {
            itemLevel = 506,
            rank = 7,
            upgradeLevel = 5,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10412] = {
            itemLevel = 509,
            rank = 7,
            upgradeLevel = 6,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10413] = {
            itemLevel = 512,
            rank = 7,
            upgradeLevel = 7,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10414] = {
            itemLevel = 515,
            rank = 7,
            upgradeLevel = 8,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10415] = {
            itemLevel = 519,
            rank = 7,
            upgradeLevel = 9,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10416] = {
            itemLevel = 522,
            rank = 7,
            upgradeLevel = 10,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10417] = {
            itemLevel = 525,
            rank = 7,
            upgradeLevel = 11,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10418] = {
            itemLevel = 528,
            rank = 7,
            upgradeLevel = 12,
            maxUpgradeLevel = 12,
            upgradeGroup = 360,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },

        -- Awakened (14)
        [10490] = {
            itemLevel = 493,
            rank = 8,
            upgradeLevel = 1,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10491] = {
            itemLevel = 496,
            rank = 8,
            upgradeLevel = 2,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10492] = {
            itemLevel = 499,
            rank = 8,
            upgradeLevel = 3,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10493] = {
            itemLevel = 502,
            rank = 8,
            upgradeLevel = 4,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10494] = {
            itemLevel = 506,
            rank = 8,
            upgradeLevel = 5,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10495] = {
            itemLevel = 509,
            rank = 8,
            upgradeLevel = 6,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10496] = {
            itemLevel = 512,
            rank = 8,
            upgradeLevel = 7,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10497] = {
            itemLevel = 515,
            rank = 8,
            upgradeLevel = 8,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10498] = {
            itemLevel = 519,
            rank = 8,
            upgradeLevel = 9,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10499] = {
            itemLevel = 522,
            rank = 8,
            upgradeLevel = 10,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10500] = {
            itemLevel = 525,
            rank = 8,
            upgradeLevel = 11,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10501] = {
            itemLevel = 528,
            rank = 8,
            upgradeLevel = 12,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10502] = {
            itemLevel = 532,
            rank = 8,
            upgradeLevel = 13,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10503] = {
            itemLevel = 535,
            rank = 8,
            upgradeLevel = 14,
            maxUpgradeLevel = 14,
            upgradeGroup = 382,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10951] = {
            itemLevel = 493,
            rank = 8,
            upgradeLevel = 1,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10952] = {
            itemLevel = 496,
            rank = 8,
            upgradeLevel = 2,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10953] = {
            itemLevel = 499,
            rank = 8,
            upgradeLevel = 3,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10954] = {
            itemLevel = 502,
            rank = 8,
            upgradeLevel = 4,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 145},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 60},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 38},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 75},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 113},
                     [2] = {currencyId = 2807, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2807, amount = 15}
                }
            }
        },
        [10955] = {
            itemLevel = 506,
            rank = 8,
            upgradeLevel = 5,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10956] = {
            itemLevel = 509,
            rank = 8,
            upgradeLevel = 6,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10957] = {
            itemLevel = 512,
            rank = 8,
            upgradeLevel = 7,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10958] = {
            itemLevel = 515,
            rank = 8,
            upgradeLevel = 8,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 170},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 70},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 45},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 88},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 138},
                     [2] = {currencyId = 2809, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 175},
                     [2] = {currencyId = 2809, amount = 15}
                }
            }
        },
        [10959] = {
            itemLevel = 519,
            rank = 8,
            upgradeLevel = 9,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10960] = {
            itemLevel = 522,
            rank = 8,
            upgradeLevel = 10,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10961] = {
            itemLevel = 525,
            rank = 8,
            upgradeLevel = 11,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10962] = {
            itemLevel = 528,
            rank = 8,
            upgradeLevel = 12,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10963] = {
            itemLevel = 532,
            rank = 8,
            upgradeLevel = 13,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                }
            }
        },
        [10964] = {
            itemLevel = 535,
            rank = 8,
            upgradeLevel = 14,
            maxUpgradeLevel = 14,
            upgradeGroup = 405,
            costs = {
                [1048738] = {
                     [1] = {currencyId = 2245, amount = 190},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [5448] = {
                     [1] = {currencyId = 2245, amount = 80},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [68100] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8404992] = {
                     [1] = {currencyId = 2245, amount = 50},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [8192] = {
                     [1] = {currencyId = 2245, amount = 100},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67272704] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [67117056] = {
                     [1] = {currencyId = 2245, amount = 150},
                     [2] = {currencyId = 2812, amount = 15}
                },
                [131072] = {
                     [1] = {currencyId = 2245, amount = 200},
                     [2] = {currencyId = 2812, amount = 15}
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
---@return FlightstoneUpgradeCostData?
local function GetItemUpgradeCosts(inventoryTypeSlotMask, upgradeInfo)
    ---@type FlightstoneUpgradeCostData
    local results = {
        whelpCrests = 0,
        drakeCrests = 0,
        wyrmCrests = 0,
        aspectCrests = 0,
        flightstones = 0
    }

    for _, upgradeCost in pairs(upgradeInfo.costs[inventoryTypeSlotMask]) do
        if upgradeCost.currencyId == private.currencyIds["Flightstones"] then
            results.flightstones = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["whelpCrest"] then
            results.whelpCrests = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["drakeCrest"] then
            results.drakeCrests = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["wyrmCrest"] then
            results.wyrmCrests = upgradeCost.amount
        elseif upgradeCost.currencyId == private.currencyIds["aspectCrest"] then
            results.aspectCrests = upgradeCost.amount
        end
    end

    return results
end

--- Parses the given upgrade costs to generate a table for use in tooltip
---@param upgradeCostData FlightstoneUpgradeCostData
---@return table
local function ParseUpgradeCost(upgradeCostData)
    local lines = {}
    local compactCostLine = {}

    for upgradeId, upgradeItem in pairs(flightstoneUpgradeData) do
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
                    left = icon .. " " .. upgradeItem.color:WrapTextInColorCode(upgradeItem.name),
                    right = costLine,
                    color = upgradeItem.color
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
        private.Debug("Parsing Flightstones upgrade cost returned no tooltip lines");
    end

    return lines;
end

--- Updates the tooltip when a Flightstone item is the item in question
---@param tooltip GameTooltip
---@param inventoryTypeSlotMask integer
---@param bonusId integer
---@param bonusInfo ItemBonusInfo
---@param itemLink string
local function HandleFlightstones(tooltip, inventoryTypeSlotMask, bonusId, bonusInfo, itemLink)
    if not bonusId or not bonusInfo then
        private.Debug(bonusId, "or Flightstones bonus info table was not found");
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

    ---@type FlightstoneUpgradeCostData?
    local nextUpgradeCost = nil

    ---@type ItemBonusInfo?
    local nextUpgrade = nil

    ---@type ItemBonusInfo?
    local maxUpgrade = nil

    ---@type FlightstoneUpgradeCostData
    local totalUpgradeCosts = {
        whelpCrests = 0,
        drakeCrests = 0,
        wyrmCrests = 0,
        aspectCrests = 0,
        flightstones = 0,
    }

    for _, upgradeInfo in pairs(itemBonusIds) do
        if upgradeInfo.rank == bonusInfo.rank and upgradeInfo.upgradeGroup == bonusInfo.upgradeGroup and upgradeInfo.upgradeLevel > bonusInfo.upgradeLevel then
            local upgradeCosts = GetItemUpgradeCosts(inventoryTypeSlotMask, upgradeInfo);
            if upgradeCosts ~= nil then
                local isCharacterDiscounted = upgradeInfo.itemLevel <= characterHighWatermark
                local isAccountDiscounted = upgradeInfo.itemLevel <= accountHighWatermark

                local whelpCrests = upgradeCosts.whelpCrests * (isCharacterDiscounted and 0 or 1)
                local drakeCrests = upgradeCosts.drakeCrests * (isCharacterDiscounted and 0 or 1)
                local wyrmCrests = upgradeCosts.wyrmCrests * (isCharacterDiscounted and 0 or 1)
                local aspectCrests = upgradeCosts.aspectCrests * (isCharacterDiscounted and 0 or 1)
                local flightstones = Round(upgradeCosts.flightstones * (isAccountDiscounted and 0.5 or 1))

                if upgradeInfo.upgradeLevel == (bonusInfo.upgradeLevel + 1) then
                    nextUpgrade = upgradeInfo

                    nextUpgradeCost = {
                        whelpCrests = whelpCrests,
                        drakeCrests = drakeCrests,
                        wyrmCrests = wyrmCrests,
                        aspectCrests = aspectCrests,
                        flightstones = flightstones,
                    }
                end

                totalUpgradeCosts.whelpCrests = totalUpgradeCosts.whelpCrests + whelpCrests
                totalUpgradeCosts.drakeCrests = totalUpgradeCosts.drakeCrests + drakeCrests
                totalUpgradeCosts.wyrmCrests = totalUpgradeCosts.wyrmCrests + wyrmCrests
                totalUpgradeCosts.aspectCrests = totalUpgradeCosts.aspectCrests + aspectCrests
                totalUpgradeCosts.flightstones = totalUpgradeCosts.flightstones + flightstones

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
            tooltip:AddLine(ARTIFACT_GOLD_COLOR:WrapTextInColorCode(L["FLIGHTSTONE_CREST_UPGRADES"]))

            if nextLevelLines then
                if not private.DB.profile.CompactTooltips then
                    -- Standard tooltip
                    tooltip:AddLine(HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(L["COST_FOR_NEXT_LEVEL"] .. " (" .. nextUpgrade.itemLevel .. ")"))

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

                    tooltip:AddLine(HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(L["COST_TO_UPGRADE_TO_MAX"] .. " (" .. maxUpgrade.itemLevel .. ")"))

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
        private.Debug("No next Flightstones upgrade cost could be found for", itemLink);
    end
end

--- Checks for valid bonus IDs and chains call to HandleFlightstones if found
---@diagnostic disable: unused-local
---@param tooltip GameTooltip
---@param itemId integer
---@param itemLink string
---@param currentUpgrade integer
---@param maxUpgrade integer
---@param bonusIds table<integer, integer>
---@return boolean
local function CheckFlightstoneBonusIDs(tooltip, itemId, itemLink, currentUpgrade, maxUpgrade, bonusIds)
    if private.DB.profile.DisabledIntegrations.Flightstones then
        private.Debug("Flightstones integration is disabled");

        return false
    end

    for i = 1, #bonusIds do
        private.Debug("Checking Flightstone bonus IDs for", bonusIds[i]);

        ---@type ItemBonusInfo?
        local bonusInfo = itemBonusIds[bonusIds[i]]
        if bonusInfo ~= nil then
            private.Debug(bonusIds[i], "matched a Flightstone bonus ID");

            local equipLoc = select(9, C_Item.GetItemInfo(itemLink))
            private.Debug(itemLink, "has equipLoc", equipLoc);

            local inventoryTypeSlotMask = inventoryTypeSlotMasks[equipLoc]
            if not inventoryTypeSlotMask then
                private.Debug(equipLoc, "was not found in the Flightstones inventory slot mask table");
                return false
            end

            local inventoryTypeSlotMaskOverride = inventoryTypeSlotMaskOverrides[equipLoc];
            if inventoryTypeSlotMaskOverride then
                local stats = C_Item.GetItemStats(itemLink)
                if not stats then
                    private.Debug("Could not extract Flightstones item stats from", itemLink);
                    return false
                end
                local hasInt = (stats["ITEM_MOD_INTELLECT_SHORT"] and stats["ITEM_MOD_INTELLECT_SHORT"] > 0)
                if hasInt then
                    private.Debug("Upgrade cost for has been overridden because the item has Intellect on it.");
                    inventoryTypeSlotMask = inventoryTypeSlotMaskOverride
                end
            end

            if not bonusInfo.costs[inventoryTypeSlotMask] then
                private.Debug(inventoryTypeSlotMask, "was not found in the Flightstones item extended cost lookup table");
                return false
            end

            HandleFlightstones(tooltip, inventoryTypeSlotMask, i, bonusInfo, itemLink)
            return true
        end
    end

    private.Debug(itemId, "did not match a Flightstones bonus ID");
    return false;
end

table.insert(private.upgradeHandlers, CheckFlightstoneBonusIDs)
