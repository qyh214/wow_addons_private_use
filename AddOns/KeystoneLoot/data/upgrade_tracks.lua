local AddonName, KeystoneLoot = ...;

local L = KeystoneLoot.L;

local function CreateTrackEntry(ilvl, bonusId, quality, suffix, rank)
    return {
        rank = rank,
        ilvl = ilvl,
        bonusId = bonusId,
        label = string.format(RECENT_ALLY_RAID_NAME_STRING_FORMAT, ColorManager.GetFormattedStringForItemQuality(ilvl, quality), suffix)
    };
end

KeystoneLoot.UpgradeTrackOrder = {
    dungeon = { "champion", "hero", "greatvault" },
    raid = { "lfr", "normal", "heroic", "mythic" }
};


KeystoneLoot.UpgradeTracks = {
    dungeon = {
        champion = {
            CreateTrackEntry(246, 12785, Enum.ItemQuality.Uncommon, "+0", L["Champion"]),
            CreateTrackEntry(250, 12786, Enum.ItemQuality.Uncommon, "+2 +3", L["Champion"]),
            CreateTrackEntry(253, 12787, Enum.ItemQuality.Uncommon, "+4", L["Champion"]),
            CreateTrackEntry(256, 12788, Enum.ItemQuality.Uncommon, "+5", L["Champion"]),
            CreateTrackEntry(259, 12789, Enum.ItemQuality.Rare, ITEM_UPGRADE, L["Champion"]),
            CreateTrackEntry(263, 12790, Enum.ItemQuality.Rare, ITEM_UPGRADE, L["Champion"])
        },
        hero = {
            CreateTrackEntry(259, 12793, Enum.ItemQuality.Rare, "+6 +7", L["Hero"]),
            CreateTrackEntry(263, 12794, Enum.ItemQuality.Rare, "+8 +9", L["Hero"]),
            CreateTrackEntry(266, 12795, Enum.ItemQuality.Rare, "+10", L["Hero"]),
            CreateTrackEntry(269, 12796, Enum.ItemQuality.Rare, ITEM_UPGRADE, L["Hero"]),
            CreateTrackEntry(272, 12797, Enum.ItemQuality.Epic, ITEM_UPGRADE, L["Hero"]),
            CreateTrackEntry(276, 12798, Enum.ItemQuality.Epic, ITEM_UPGRADE, L["Hero"])
        },
        greatvault = {
            CreateTrackEntry(272, 12801, Enum.ItemQuality.Epic, "+10", L["Myth"]),
            CreateTrackEntry(276, 12802, Enum.ItemQuality.Epic, ITEM_UPGRADE, L["Myth"]),
            CreateTrackEntry(279, 12803, Enum.ItemQuality.Epic, ITEM_UPGRADE, L["Myth"]),
            CreateTrackEntry(282, 12804, Enum.ItemQuality.Epic, ITEM_UPGRADE, L["Myth"]),
            CreateTrackEntry(285, 12805, Enum.ItemQuality.Legendary, ITEM_UPGRADE, L["Myth"]),
            CreateTrackEntry(289, 12806, Enum.ItemQuality.Legendary, ITEM_UPGRADE, L["Myth"])
        }
    },
    raid = {
        lfr = {
            CreateTrackEntry(233, 12777, Enum.ItemQuality.Poor, BOSS),
            CreateTrackEntry(237, 12778, Enum.ItemQuality.Poor, BOSS),
            CreateTrackEntry(240, 12779, Enum.ItemQuality.Poor, BOSS),
            CreateTrackEntry(243, 12780, Enum.ItemQuality.Poor, BOSS),
            CreateTrackEntry(246, 12781, Enum.ItemQuality.Uncommon, ITEM_UPGRADE),
            CreateTrackEntry(250, 12782, Enum.ItemQuality.Uncommon, ITEM_UPGRADE)
        },
        normal = {
            CreateTrackEntry(246, 12785, Enum.ItemQuality.Uncommon, BOSS),
            CreateTrackEntry(250, 12786, Enum.ItemQuality.Uncommon, BOSS),
            CreateTrackEntry(253, 12787, Enum.ItemQuality.Uncommon, BOSS),
            CreateTrackEntry(256, 12788, Enum.ItemQuality.Uncommon, BOSS),
            CreateTrackEntry(259, 12789, Enum.ItemQuality.Rare, ITEM_UPGRADE),
            CreateTrackEntry(263, 12790, Enum.ItemQuality.Rare, ITEM_UPGRADE)
        },
        heroic = {
            CreateTrackEntry(259, 12793, Enum.ItemQuality.Rare, BOSS),
            CreateTrackEntry(263, 12794, Enum.ItemQuality.Rare, BOSS),
            CreateTrackEntry(266, 12795, Enum.ItemQuality.Rare, BOSS),
            CreateTrackEntry(269, 12796, Enum.ItemQuality.Rare, BOSS),
            CreateTrackEntry(272, 12797, Enum.ItemQuality.Epic, ITEM_UPGRADE),
            CreateTrackEntry(276, 12798, Enum.ItemQuality.Epic, ITEM_UPGRADE)
        },
        mythic = {
            CreateTrackEntry(272, 12801, Enum.ItemQuality.Epic, BOSS),
            CreateTrackEntry(276, 12802, Enum.ItemQuality.Epic, BOSS),
            CreateTrackEntry(279, 12803, Enum.ItemQuality.Epic, BOSS),
            CreateTrackEntry(282, 12804, Enum.ItemQuality.Epic, BOSS),
            CreateTrackEntry(285, 12805, Enum.ItemQuality.Legendary, ITEM_UPGRADE),
            CreateTrackEntry(289, 12806, Enum.ItemQuality.Legendary, ITEM_UPGRADE)
        }
    }
};
