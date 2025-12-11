BtWQuestsDatabase:AddExpansionItems(BTWQUESTS_EXPANSION_LEGION, {
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEATHKNIGHT,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_DEMONHUNTER,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_DRUID,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_HUNTER,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_MAGE,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_MONK,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_PALADIN,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_PRIEST,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_ROGUE,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_SHAMAN,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_WARLOCK,
    },
    {
        type = "category",
        id = BTWQUESTS_CATEGORY_LEGION_CLASSES_WARRIOR,
    },
})

-- Death Knight
BtWQuestsDatabase:AddMapRecursive(647, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
})
BtWQuestsDatabase:AddMapRecursive(648, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEATHKNIGHT_CAMPAIGN,
})
-- Demon Hunter Zone
BtWQuestsDatabase:AddMapRecursive(719, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DEMONHUNTER_CAMPAIGN,
})
-- Druid Dreamgrove
BtWQuestsDatabase:AddMapRecursive(747, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_DRUID_CAMPAIGN,
})
-- Hunter Lodge
BtWQuestsDatabase:AddMapRecursive(739, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_HUNTER_CAMPAIGN,
})
-- Mage
BtWQuestsDatabase:AddMapRecursive(734, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
}, false, true)
BtWQuestsDatabase:AddMapRecursive(735, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MAGE_CAMPAIGN,
}, false, true)
-- Monk
BtWQuestsDatabase:AddMapRecursive(709, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_MONK_CAMPAIGN,
})
-- Paladin
BtWQuestsDatabase:AddMapRecursive(24, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PALADIN_CAMPAIGN,
})
-- Priest
BtWQuestsDatabase:AddMapRecursive(702, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_PRIEST_CAMPAIGN,
})
-- Rogue
BtWQuestsDatabase:AddMapRecursive(626, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_ROGUE_CAMPAIGN,
})
-- Shaman
BtWQuestsDatabase:AddMapRecursive(726, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_SHAMAN_CAMPAIGN,
})
-- Warlock
BtWQuestsDatabase:AddMapRecursive(717, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARLOCK_CAMPAIGN,
})
-- Warrior
BtWQuestsDatabase:AddMapRecursive(695, {
    type = "chain",
    id = BTWQUESTS_CHAIN_LEGION_CLASSES_WARRIOR_CAMPAIGN,
})