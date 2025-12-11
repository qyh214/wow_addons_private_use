---@class AddonPrivate
local Private = select(2, ...)
local const = Private.constants

local defaultDatabase = {
    scrapping = {
        maxQuality = Enum.ItemQuality.Rare,
        minLevelDiff = 0,
        autoScrap = false,
        advancedJeweleryFilter = false,
        ignoreFromEquipmentSets = false,
    },
    collectionsTab = {
        selected = 1,
    },
    artifactTraits = {
        autoActive = {},
        autoBuy = false,
    },
    quickActionBar = {
        actions = nil,
    },
    quest = {
        autoAccept = false,
        autoTurnIn = false,
        suppressShift = false,
        ignoreEternus = true,
        suppressWorldTierIcon = false,
    },
    toast = {
        activate = false,
        bronze = false,
        artifact = false,
        upgrade = false,
        trait = false,
        sound = false,
    },
    tooltip = {
        activate = false,
        threads = false,
        power = false,
    },
    itemOpener = {
        autoItemOpen = false,
    },
    merchant = {
        hideCollectedItems = false,
        hideCollectedPetsAtLimit = true, -- we set this to true as it was default behavior before adding the setting
    },
    editMode = {
        ToastUI = {
            point = "TOP",
            relativePoint = "TOP",
            relativeTo = "UIParent",
            xOfs = 0,
            yOfs = -50,
        }
    },
    version = nil
}

local defaultCharDatabase = {
    char = {
        scrapping = {
            jeweleryTraitsToKeep = {
                Neck = CopyTable(const.SCRAPPING_MACHINE.JEWELRY.NECK),
                Finger = CopyTable(const.SCRAPPING_MACHINE.JEWELRY.FINGER),
                Trinket = CopyTable(const.SCRAPPING_MACHINE.JEWELRY.TRINKET),
            },
        },
    }
}

---@class LegionRH : RasuAddonBase
local addon = LibStub("RasuAddon"):CreateAddon(
    const.ADDON_NAME,
    "LegionRemixHelperDB",
    defaultDatabase,
    nil,
    nil,
    nil,
    "LegionRemixHelperCharDB",
    defaultCharDatabase
)

Private.Addon = addon

local localeObj = LibStub("RasuLocale"):CreateLocale(const.ADDON_NAME)
localeObj:AddFullTranslationTbl(Private.Locales)
localeObj:SetLocale(GetLocale())

Private.L = localeObj:GetTranslationObj()
