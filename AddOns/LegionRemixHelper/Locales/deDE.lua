---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "Option auswählen",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "Auto-Activate for Spec",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "Bitte rüste deine Artefaktwaffe aus!",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Strg-Klick für Vorschau",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift-Klick zum Verlinken",
    ["Tabs.CollectionTabUI.NoName"] = "Kein Name",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt-Klick, um einen Wegpunkt zum Händler zu setzen",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt-Klick, um den Erfolg anzusehen",
    ["Tabs.CollectionTabUI.FilterCollected"] = "Gesammelt",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "Nicht gesammelt",
    ["Tabs.CollectionTabUI.FilterSources"] = "Quellen",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "Alle auswählen",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "Alle abwählen",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "Raid-Varianten anzeigen",
    ["Tabs.CollectionTabUI.FilterUnique"] = "Nur Remix-Spezifische Gegenstände",
    ["Tabs.CollectionTabUI.Type"] = "Typ",
    ["Tabs.CollectionTabUI.Source"] = "Quelle",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "Suchen",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "Deine Sammlung hat einen Wert von %s von möglichen %s Bronze.\nDu musst noch %s ausgeben um alles zu sammeln!",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "Legion-Remix",
    ["CollectionsTabUI.ResearchProgress"] = "Forschung: %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "Artefakt-Talente",
    ["CollectionsTabUI.CollectionTabTitle"] = "Sammlung",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "Schnellleiste",
    ["QuickActionBarUI.SettingTitlePreview"] = "Aktionstitel hier",
    ["QuickActionBarUI.SettingsEditorTitle"] = "Aktion bearbeiten",
    ["QuickActionBarUI.SettingsTitleLabel"] = "Aktionstitel:",
    ["QuickActionBarUI.SettingsTitleInput"] = "Name der Aktion",
    ["QuickActionBarUI.SettingsIconLabel"] = "Symbol:",
    ["QuickActionBarUI.SettingsIconInput"] = "Textur-ID oder Pfad",
    ["QuickActionBarUI.SettingsIDLabel"] = "Aktions-ID:",
    ["QuickActionBarUI.SettingsIDInput"] = "Gegenstand-/Zaubername oder ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "Aktionstyp:",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "Zauber",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "Gegenstand",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "Nur wenn verwendbar:",
    ["QuickActionBarUI.SettingsEditorSave"] = "Aktion speichern",
    ["QuickActionBarUI.SettingsEditorNew"] = "Neue Aktion",
    ["QuickActionBarUI.SettingsEditorDelete"] = "Aktion löschen",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "Keine Aktion zum Speichern vorhanden.",
    ["QuickActionBarUI.SettingsEditorAction"] = "Aktion %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "Fehler beim Speichern der Aktion: %s",
    ["QuickActionBarUI.CombatToggleError"] = "Die Schnellleiste kann im Kampf nicht geöffnet oder geschlossen werden.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "Maximale Qualität zum Verschrotten",
    ["ScrappingUI.MinItemLevelDifference"] = "Minimale Itemlevel-Differenz",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "x Stufen unter dem ausgerüsteten Gegenstand",
    ["ScrappingUI.AutoScrap"] = "Auto-Verschrotten",
    ["ScrappingUI.ScraperListTabTitle"] = "Item-Liste",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "Mehr Einstellungen",
    ["ScrappingUI.JewelryTraitsToKeep"] = "Schmuck-Traits zum Behalten",
    ["ScrappingUI.AdvancedJewelryFilter"] = "Erweiterter Schmuck-Filter",
    ["ScrappingUI.FilterCheckAll"] = "Alle auswählen",
    ["ScrappingUI.FilterUncheckAll"] = "Alle abwählen",
    ["ScrappingUI.Neck"] = "Hals-Traits",
    ["ScrappingUI.Trinket"] = "Schmuckstück-Traits",
    ["ScrappingUI.Finger"] = "Ring-Traits",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "Items in Ausrüstungssets ignorieren",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "Kein Gegenstand ausgerüstet.",
    ["ArtifactTraitUtils.UnknownTrait"] = "Unbekanntes Talent",
    ["ArtifactTraitUtils.ColumnNature"] = "Natur",
    ["ArtifactTraitUtils.ColumnFel"] = "Chaos",
    ["ArtifactTraitUtils.ColumnArcane"] = "Arkan",
    ["ArtifactTraitUtils.ColumnStorm"] = "Sturm",
    ["ArtifactTraitUtils.ColumnHoly"] = "Heilig",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "Maximale Versuche beim Kauf von Knoten erreicht.",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "Artefakt-Talente",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "Einstellungen für die Artefakt-Talente-Funktion",
    ["ArtifactTraitUtils.AutoBuy"] = "Automatischer Kauf von Knoten",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "Kauft automatisch die voreingestellten Talente, wenn du genug Artefaktmacht hast.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "Quellen:",
    ["CollectionUtils.Achievement"] = "Erfolg: ",
    ["CollectionUtils.UnknownAchievement"] = "Unbekannter Erfolg",
    ["CollectionUtils.UnknownVendor"] = "Unbekannter Händler",
    ["CollectionUtils.Vendor"] = "Händler, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[Unbekannter Befehl!
Verwendung: /LRH oder /LegionRH <unterbefehl>
Unterbefehle:
    sammlung (s) - Öffne den Sammlungs-Tab.
    einstellungen (e) - Öffne das Einstellungsmenü.
Beispiel: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "sammlung",
    ["CommandUtils.CollectionsCommandShort"] = "s",
    ["CommandUtils.SettingsCommand"] = "einstellungen",
    ["CommandUtils.SettingsCommandShort"] = "e",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Legion-Remix-Helper-Systeme",
    ["EditModeUtils.SystemLabel.ToastUI"] = "Benachrichtigungen",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "Verschiebe die Position der Benachrichtigungen.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "Auto-Gegenstand-Öffner",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "Einstellungen für die Auto-Gegenstand-Öffner-Funktion",
    ["ItemOpenerUtils.AutoItemOpen"] = "Automatisch Gegenstände öffnen",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "Öffnet automatisch bestimmte Gegenstände in deinem Inventar, wenn sie gefunden werden. (Dieses Feature wird noch entwickelt)",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "Öffnet %s automatisch, wenn es im Inventar gefunden wird.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "Händler Einstellungen",
    ["MerchantUtils.SettingsCategoryTooltip"] = "Einstellungen für die Händler-Funktion",
    ["MerchantUtils.HideCollectedMerchantItems"] = "Gesammelte Händlergegenstände ausblenden",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "Blendet Gegenstände aus dem Händlerfenster aus, die du bereits in deiner Sammlung hast.",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "Gesammelte Haustiere nur bei Limit ausblenden",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "Blendet Haustiere aus dem Händlerfenster nur aus, wenn du das Sammellimit für Haustiere erreicht hast.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "Auto-Quest",
    ["QuestUtils.SettingsCategoryTooltip"] = "Einstellungen für die Auto-Quest-Funktion",
    ["QuestUtils.AutoTurnIn"] = "Automatisch abgeben",
    ["QuestUtils.AutoTurnInTooltip"] = "Quests automatisch abgeben, wenn du mit NPCs interagierst.",
    ["QuestUtils.AutoAccept"] = "Automatisch annehmen",
    ["QuestUtils.AutoAcceptTooltip"] = "Quests automatisch annehmen, wenn du mit NPCs interagierst.",
    ["QuestUtils.IgnoreEternus"] = "Eternus ignorieren",
    ["QuestUtils.IgnoreEternusTooltip"] = "Quests ignorieren, die von Eternus kommen.",
    ["QuestUtils.SuppressShift"] = "Mit Shift unterdrücken",
    ["QuestUtils.SuppressShiftTooltip"] = "Shift gedrückt halten, um das automatische Annehmen/Abgeben von Quests zu unterdrücken.",
    ["QuestUtils.SuppressWorldTierIcon"] = "Weltstufen-Icon unterdrücken",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "Das Weltstufen-Icon, das sich unter der Minikarte befindet, ausblenden.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "Schnellleiste",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "Einstellungen für die Schnellleisten-Funktion",
    ["QuickActionBarUtils.ActionNotFound"] = "Aktion nicht gefunden",
    ["QuickActionBarUtils.Action"] = "Aktion %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "Benachrichtigungen",
    ["ToastUtils.SettingsCategoryTooltip"] = "Einstellungen für die Benachrichtigungsfunktion",
    ["ToastUtils.TypeBronze"] = "Bronze-Meilensteine",
    ["ToastUtils.TypeBronzeTooltip"] = "Zeige eine Benachrichtigung an, wenn du einen neuen Bronze-Meilenstein erreichst.",
    ["ToastUtils.TypeArtifact"] = "Artefakt-Upgrades",
    ["ToastUtils.TypeArtifactTooltip"] = "Zeige eine Benachrichtigung an, wenn du ein Artefakt-Upgrade in deinem Inventar findest.",
    ["ToastUtils.TypeUpgrade"] = "Gegenstands-Upgrades",
    ["ToastUtils.TypeUpgradeTooltip"] = "Zeige eine Benachrichtigung an, wenn du ein Gegenstands-Upgrade in deinem Inventar findest.",
    ["ToastUtils.TypeTrait"] = "Neue Talente",
    ["ToastUtils.TypeTraitTooltip"] = "Zeige eine Benachrichtigung an, wenn du ein neues Artefakt-Talent freischaltest.",
    ["ToastUtils.TypeSound"] = "Ton abspielen",
    ["ToastUtils.TypeSoundTooltip"] = "Spiele einen Ton ab, wenn eine Benachrichtigung angezeigt wird.",
    ["ToastUtils.TypeGeneral"] = "Benachrichtigungen aktivieren",
    ["ToastUtils.TypeGeneralTooltip"] = "Aktiviere oder deaktiviere alle Benachrichtigungen.",
    ["ToastUtils.TestToast"] = "Testbenachrichtigung",
    ["ToastUtils.TestToastButtonTitle"] = "Benachrichtigung testen",
    ["ToastUtils.TestToastTooltip"] = "Zeige eine Testbenachrichtigung an.",
    ["ToastUtils.TestToastTitle"] = "Testbenachrichtigung",
    ["ToastUtils.TestToastDescription"] = "Dies ist eine Testbenachrichtigung.",
    ["ToastUtils.TypeBronzeTitle"] = "Neuer Bronze-Meilenstein!",
    ["ToastUtils.TypeBronzeDescription"] = "Du hast %d Bronze erreicht! (%.2f%% bis zum Limit)",
    ["ToastUtils.TypeArtifactTitle"] = "Neues Artefakt-Upgrade!",
    ["ToastUtils.TypeArtifactDescription"] = "Du hast ein neues Artefakt-Upgrade gefunden! Überprüfe dein Inventar oder die Schnellaktionsleiste.",
    ["ToastUtils.TypeUpgradeTitle"] = "Neues Item-Upgrade!",
    ["ToastUtils.TypeUpgradeFallback"] = "Unbekannter Gegenstand",
    ["ToastUtils.TypeTraitTitle"] = "Neues Talent freigeschaltet!",
    ["ToastUtils.TypeTraitDescription"] = "Neues Talent: %s",
    ["ToastUtils.TypeTraitFallback"] = "Unbekanntes Talent",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "Fäden",
    ["TooltipUtils.InfinitePower"] = "Unendliche Macht",
    ["TooltipUtils.Estimate"] = " (Schätzung)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "Tooltip-Power",
    ["TooltipUtils.SettingsCategoryTooltip"] = "Einstellungen für die Tooltip-Power-Funktion",
    ["TooltipUtils.Activate"] = "Aktivieren",
    ["TooltipUtils.ActivateTooltip"] = "Tooltip-Power Informationen anzeigen",
    ["TooltipUtils.ThreadsInfo"] = "Fäden-Informationen",
    ["TooltipUtils.ThreadsInfoTooltip"] = "Tooltip-Power Fäden Informationen",
    ["TooltipUtils.PowerInfo"] = "Power Informationen",
    ["TooltipUtils.PowerInfoTooltip"] = "Tooltip-Power Unendliche Macht Informationen anzeigen",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "Deine Version wurde von %s auf Version %s aktualisiert. Sieh im Addon-Discord nach den Patchnotes!",
    ["UpdateUtils.NilVersion"] = "N/A",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "Allgemeine Einstellungen",
    ["UXUtils.SettingsCategoryTooltip"] = "Allgemeine Addon-Einstellungen",
}
locales["deDE"] = L
