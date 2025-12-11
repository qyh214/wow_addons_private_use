---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "Select an option",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "Auto-Activate for Spec",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "No Artifact Equipped",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl-Click to preview",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift-Click to Link",
    ["Tabs.CollectionTabUI.NoName"] = "No Name",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt-Click to set a Waypoint to the Vendor",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt-Click to view the Achievement",
    ["Tabs.CollectionTabUI.FilterCollected"] = "Collected",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "Not Collected",
    ["Tabs.CollectionTabUI.FilterSources"] = "Sources",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "Check All",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "Uncheck All",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "Show Raid Variants",
    ["Tabs.CollectionTabUI.FilterUnique"] = "Only Remix-Specific Items",
    ["Tabs.CollectionTabUI.Type"] = "Type",
    ["Tabs.CollectionTabUI.Source"] = "Source",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "Search",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "Your collection is worth %s of %s Bronze.\nYou need to spend %s more to collect everything!",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "Legion Remix",
    ["CollectionsTabUI.ResearchProgress"] = "Research: %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "Artifact Traits",
    ["CollectionsTabUI.CollectionTabTitle"] = "Collection",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "Quick-Bar",
    ["QuickActionBarUI.SettingTitlePreview"] = "Action Title here",
    ["QuickActionBarUI.SettingsEditorTitle"] = "Editing Action",
    ["QuickActionBarUI.SettingsTitleLabel"] = "Action Title:",
    ["QuickActionBarUI.SettingsTitleInput"] = "Name of the action",
    ["QuickActionBarUI.SettingsIconLabel"] = "Icon:",
    ["QuickActionBarUI.SettingsIconInput"] = "Texture ID or Path",
    ["QuickActionBarUI.SettingsIDLabel"] = "Action ID:",
    ["QuickActionBarUI.SettingsIDInput"] = "Item/Spell name or ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "Action Type:",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "Spell",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "Item",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "Only when usable:",
    ["QuickActionBarUI.SettingsEditorSave"] = "Save Action",
    ["QuickActionBarUI.SettingsEditorNew"] = "New Action",
    ["QuickActionBarUI.SettingsEditorDelete"] = "Delete Action",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "No action to save.",
    ["QuickActionBarUI.SettingsEditorAction"] = "Action %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "Got an error while saving action: %s",
    ["QuickActionBarUI.CombatToggleError"] = "The Quick Action Bar cannot be opened or closed in combat.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "Max Scrapping Quality",
    ["ScrappingUI.MinItemLevelDifference"] = "Min Item Level Difference",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "x levels lower than equipped",
    ["ScrappingUI.AutoScrap"] = "Auto Scrap",
    ["ScrappingUI.ScraperListTabTitle"] = "Scrapper List",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "More Settings",
    ["ScrappingUI.JewelryTraitsToKeep"] = "Jewelry Traits to Keep",
    ["ScrappingUI.AdvancedJewelryFilter"] = "Advanced Jewelry Filter",
    ["ScrappingUI.FilterCheckAll"] = "Check All",
    ["ScrappingUI.FilterUncheckAll"] = "Uncheck All",
    ["ScrappingUI.Neck"] = "Neck traits",
    ["ScrappingUI.Trinket"] = "Trinket traits",
    ["ScrappingUI.Finger"] = "Ring traits",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "Ignore Items in Equipment Sets",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "No Item Equipped.",
    ["ArtifactTraitUtils.UnknownTrait"] = "Unknown Trait",
    ["ArtifactTraitUtils.ColumnNature"] = "Nature",
    ["ArtifactTraitUtils.ColumnFel"] = "Fel",
    ["ArtifactTraitUtils.ColumnArcane"] = "Arcane",
    ["ArtifactTraitUtils.ColumnStorm"] = "Storm",
    ["ArtifactTraitUtils.ColumnHoly"] = "Holy",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "Max tries reached when purchasing nodes.",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "Artifact Traits",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "Settings for the Artifact Traits feature",
    ["ArtifactTraitUtils.AutoBuy"] = "Automatic Node Purchase",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "Automatically purchases the preset talents when you have enough Artifact Power.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "Sources:",
    ["CollectionUtils.Achievement"] = "Achievement: ",
    ["CollectionUtils.UnknownAchievement"] = "Unknown Achievement",
    ["CollectionUtils.UnknownVendor"] = "Unknown Vendor",
    ["CollectionUtils.Vendor"] = "Vendor, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[Unknown Command!
Usage: /LRH or /LegionRH <subCommand>
Subcommands:
    collections (c) - Open the Collections tab.
    settings (s) - Open the settings menu.
Example: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "collections",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "settings",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Legion-Remix-Helper-Systems",
    ["EditModeUtils.SystemLabel.ToastUI"] = "Toasts",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "Move the position of the toasts.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "Auto-Item-Opener",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "Settings for the Auto-Item-Opener feature",
    ["ItemOpenerUtils.AutoItemOpen"] = "Automatically Open Items",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "Automatically opens certain items in your inventory when found. (This feature is still in development)",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "Automatically opens %s when found in your inventory.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "Merchant Settings",
    ["MerchantUtils.SettingsCategoryTooltip"] = "Settings for the Merchant feature",
    ["MerchantUtils.HideCollectedMerchantItems"] = "Hide Collected Merchant Items",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "Hides items in the merchant window that you already have in your collection.",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "Hide Collected Pets at Limit",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "Hide pets in the merchant window only when you have reached the collection limit for pets.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "Auto-Quest",
    ["QuestUtils.SettingsCategoryTooltip"] = "Settings for the Auto-Quest feature",
    ["QuestUtils.AutoTurnIn"] = "Auto Turn-In",
    ["QuestUtils.AutoTurnInTooltip"] = "Automatically turn in quests when interacting with NPCs.",
    ["QuestUtils.AutoAccept"] = "Auto Accept",
    ["QuestUtils.AutoAcceptTooltip"] = "Automatically accept quests when interacting with NPCs.",
    ["QuestUtils.IgnoreEternus"] = "Ignore Eternus",
    ["QuestUtils.IgnoreEternusTooltip"] = "Ignore quests that come from Eternus.",
    ["QuestUtils.SuppressShift"] = "Suppress with Shift",
    ["QuestUtils.SuppressShiftTooltip"] = "Hold Shift to suppress automatic quest acceptance/turn-in.",
    ["QuestUtils.SuppressWorldTierIcon"] = "Suppress World Tier Icon",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "Hide the World Tier icon that is below the minimap.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "Quick Action Bar",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "Settings for the Quick-Bar feature",
    ["QuickActionBarUtils.ActionNotFound"] = "Action not found",
    ["QuickActionBarUtils.Action"] = "Action %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "Toasts",
    ["ToastUtils.SettingsCategoryTooltip"] = "Settings for the Toasts feature",
    ["ToastUtils.TypeBronze"] = "Bronze Milestones",
    ["ToastUtils.TypeBronzeTooltip"] = "Show a toast when you reach a new bronze milestone.",
    ["ToastUtils.TypeArtifact"] = "Artifact Upgrades",
    ["ToastUtils.TypeArtifactTooltip"] = "Show a toast when you find an artifact upgrade in your bags.",
    ["ToastUtils.TypeUpgrade"] = "Item Upgrades",
    ["ToastUtils.TypeUpgradeTooltip"] = "Show a toast when you find an item upgrade in your bags.",
    ["ToastUtils.TypeTrait"] = "New Traits",
    ["ToastUtils.TypeTraitTooltip"] = "Show a toast when you unlock a new artifact trait.",
    ["ToastUtils.TypeSound"] = "Play Sound",
    ["ToastUtils.TypeSoundTooltip"] = "Play a sound when showing any toast.",
    ["ToastUtils.TypeGeneral"] = "Enable Toasts",
    ["ToastUtils.TypeGeneralTooltip"] = "Enable or disable all toast notifications.",
    ["ToastUtils.TestToast"] = "Test Toast",
    ["ToastUtils.TestToastButtonTitle"] = "Test Toast Notification",
    ["ToastUtils.TestToastTooltip"] = "Show a test toast notification.",
    ["ToastUtils.TestToastTitle"] = "Test Toast Notification",
    ["ToastUtils.TestToastDescription"] = "This is a test toast notification.",
    ["ToastUtils.TypeBronzeTitle"] = "New Bronze Milestone!",
    ["ToastUtils.TypeBronzeDescription"] = "You have reached %d bronze! (%.2f%% to cap)",
    ["ToastUtils.TypeArtifactTitle"] = "New Artifact Upgrade!",
    ["ToastUtils.TypeArtifactDescription"] = "You have found a new artifact upgrade! Check your inventory or quick action bar.",
    ["ToastUtils.TypeUpgradeTitle"] = "New Item Upgrade!",
    ["ToastUtils.TypeUpgradeFallback"] = "Unknown Item",
    ["ToastUtils.TypeTraitTitle"] = "New Trait Unlocked!",
    ["ToastUtils.TypeTraitDescription"] = "New Trait: %s",
    ["ToastUtils.TypeTraitFallback"] = "Unknown Trait",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "Threads",
    ["TooltipUtils.InfinitePower"] = "Infinite Power",
    ["TooltipUtils.Estimate"] = " (Estimate)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "Tooltip Power",
    ["TooltipUtils.SettingsCategoryTooltip"] = "Settings for the Tooltip-Power feature",
    ["TooltipUtils.Activate"] = "Activate",
    ["TooltipUtils.ActivateTooltip"] = "Show Tooltip-Power information",
    ["TooltipUtils.ThreadsInfo"] = "Threads Information",
    ["TooltipUtils.ThreadsInfoTooltip"] = "Show Tooltip-Power Threads information",
    ["TooltipUtils.PowerInfo"] = "Power Information",
    ["TooltipUtils.PowerInfoTooltip"] = "Show Tooltip-Power Infinite Power information",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "Your Version changed from %s to Version %s. Check the Addon Discord for Patch Notes!",
    ["UpdateUtils.NilVersion"] = "N/A",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "General Settings",
    ["UXUtils.SettingsCategoryTooltip"] = "General Addon Settings",
}
locales["enUS"] = L
