---@class AddonPrivate
-- Translate Klep-Ysondre (EU)
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "Sélectionnez une option",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "Activation automatique pour la spécialisation",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "Aucun artefact équipé",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl + Clic pour prévisualiser",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Maj + clic pour afficher",
    ["Tabs.CollectionTabUI.NoName"] = "Sans nom",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt + Clic pour définir un point de passage vers le Vendeur",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt + Clic pour voir le Haut fait",
    ["Tabs.CollectionTabUI.FilterCollected"] = "Collecté",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "Pas Collecté",
    ["Tabs.CollectionTabUI.FilterSources"] = "Sources",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "Tout cocher",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "Décocher tout",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "Afficher les variantes de raid",
    ["Tabs.CollectionTabUI.FilterUnique"] = "Uniquement les objets spécifiques à Legion Remix",
    ["Tabs.CollectionTabUI.Type"] = "Type",
    ["Tabs.CollectionTabUI.Source"] = "Source",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "Recherche",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "Votre collection vaut %s de %s Bronze.\nVous devez dépenser %s de plus pour tout collecter !",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "Legion Remix",
    ["CollectionsTabUI.ResearchProgress"] = "Recherche : %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "Traits d’artefact",
    ["CollectionsTabUI.CollectionTabTitle"] = "Collection",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "Barre-Rapide",
    ["QuickActionBarUI.SettingTitlePreview"] = "Titre de l’action ici",
    ["QuickActionBarUI.SettingsEditorTitle"] = "Action d’édition",
    ["QuickActionBarUI.SettingsTitleLabel"] = "Titre de l’action :",
    ["QuickActionBarUI.SettingsTitleInput"] = "Nom de l’action",
    ["QuickActionBarUI.SettingsIconLabel"] = "Icône :",
    ["QuickActionBarUI.SettingsIconInput"] = "Texture ID ou Chemin",
    ["QuickActionBarUI.SettingsIDLabel"] = "Action ID :",
    ["QuickActionBarUI.SettingsIDInput"] = "Nom de l’Objet / Sort ou ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "Type d’Action :",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "Sort",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "Objet",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "Uniquement lorsque utilisable :",
    ["QuickActionBarUI.SettingsEditorSave"] = "Enregistrer l’action",
    ["QuickActionBarUI.SettingsEditorNew"] = "Nouvelle Action",
    ["QuickActionBarUI.SettingsEditorDelete"] = "Supprimer l’action",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "Aucune Action à sauvegarder.",
    ["QuickActionBarUI.SettingsEditorAction"] = "Action %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "Une erreur s’est produite lors de l’enregistrement de l’action : %s",
    ["QuickActionBarUI.CombatToggleError"] = "La barre d’action rapide ne peut pas être ouverte ou fermée en combat.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "Qualité maximale pour le recyclage",
    ["ScrappingUI.MinItemLevelDifference"] = "Différence minimale de niveau d’objet",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "x niveaux inférieurs à ceux équipés",
    ["ScrappingUI.AutoScrap"] = "Recyclage automatique",
    ["ScrappingUI.ScraperListTabTitle"] = "Liste de recyclage",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "Plus de paramètres",
    ["ScrappingUI.JewelryTraitsToKeep"] = "Traits de Joaillerie à conserver",
    ["ScrappingUI.AdvancedJewelryFilter"] = "Filtre avancé de Joaillerie",
    ["ScrappingUI.FilterCheckAll"] = "Tout cocher",
    ["ScrappingUI.FilterUncheckAll"] = "Décocher tout",
    ["ScrappingUI.Neck"] = "Traits des Colliers",
    ["ScrappingUI.Trinket"] = "Traits des Bijoux",
    ["ScrappingUI.Finger"] = "Traits des Anneaux",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "Ignorer les objets dans les ensembles d'équipement",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "Aucun objet équipé.",
    ["ArtifactTraitUtils.UnknownTrait"] = "Trait inconnu",
    ["ArtifactTraitUtils.ColumnNature"] = "Nature",
    ["ArtifactTraitUtils.ColumnFel"] = "Gangregarde",
    ["ArtifactTraitUtils.ColumnArcane"] = "Arcane",
    ["ArtifactTraitUtils.ColumnStorm"] = "Tempête",
    ["ArtifactTraitUtils.ColumnHoly"] = "Sacré",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "Nombre maximal d’essais atteint lors de l’achat de Traits.",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "Traits d’Artefact",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "Paramètres de la fonctionnalité Traits d’Artefact",
    ["ArtifactTraitUtils.AutoBuy"] = "Achat automatique de Traits",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "Achèter automatiquement les talents prédéfinis lorsque vous avez suffisamment de Pouvoir infini.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "Sources :",
    ["CollectionUtils.Achievement"] = "Haut fait : ",
    ["CollectionUtils.UnknownAchievement"] = "Haut fait inconnu",
    ["CollectionUtils.UnknownVendor"] = "Vendeur inconnu",
    ["CollectionUtils.Vendor"] = "Vendeur, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[Commande inconnue !
Utilisation : /LRH ou /LegionRH <sous-Commande>
Sous-commandes :
    collections (c) - Ouvrez l’onglet Collections.
    settings (s) - Ouvrez le menu des paramètres.
Exemple: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "collections",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "paramètres",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Legion-Remix-Helper-Systems",
    ["EditModeUtils.SystemLabel.ToastUI"] = "Notifications",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "Déplacez la position des notifications.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "Auto-Item-Opener",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "Paramètres de la fonction Auto-Item-Opener",
    ["ItemOpenerUtils.AutoItemOpen"] = "Ouvrir automatiquement les objets",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "Ouvre automatiquement certains objets de votre inventaire lorsqu’ils sont trouvés. (Cette fonctionnalité est encore en développement)",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "Ouvre automatiquement %s lorsqu’il est dans votre inventaire.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "Paramètres du Marchand",
    ["MerchantUtils.SettingsCategoryTooltip"] = "Paramètres de la fonctionnalité Marchand",
    ["MerchantUtils.HideCollectedMerchantItems"] = "Masquer les objets Marchands collectés",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "Masquer les objets dans la fenêtre du Marchand que vous avez déjà dans votre collection.",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "Masquer les animaux de compagnie collectés à la limite",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "Masquer les animaux de compagnie dans la fenêtre du Marchand uniquement lorsque vous avez atteint la limite de collection pour les animaux de compagnie.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "Quête-Auto",
    ["QuestUtils.SettingsCategoryTooltip"] = "Paramètres de la fonctionnalité Quête-Auto",
    ["QuestUtils.AutoTurnIn"] = "Rendre automatiquement",
    ["QuestUtils.AutoTurnInTooltip"] = "Rendre automatiquement les quêtes lorsque vous interagissez avec des PNJ.",
    ["QuestUtils.AutoAccept"] = "Accepter automatiquement",
    ["QuestUtils.AutoAcceptTooltip"] = "Accepter automatiquement les quêtes lorsque vous interagissez avec des PNJ.",
    ["QuestUtils.IgnoreEternus"] = "Ignorer Éternia",
    ["QuestUtils.IgnoreEternusTooltip"] = "Ignorer les quêtes qui viennent d’Éternia.",
    ["QuestUtils.SuppressShift"] = "Supprimer avec Maj",
    ["QuestUtils.SuppressShiftTooltip"] = "Maintenir la touche Maj pour supprimer l’acceptation / le rendu automatique de la quête.",
    ["QuestUtils.SuppressWorldTierIcon"] = "Masquer l'icône de niveau mondial",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "Masquer l’icône de niveau mondial sur la minicarte.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "Quick Action Bar",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "Paramètres de la fonctionnalité Quick-Bar",
    ["QuickActionBarUtils.ActionNotFound"] = "Action introuvable",
    ["QuickActionBarUtils.Action"] = "Action %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "Notifications",
    ["ToastUtils.SettingsCategoryTooltip"] = "Paramètres de la fonctionnalité Notifications",
    ["ToastUtils.TypeBronze"] = "Bronze",
    ["ToastUtils.TypeBronzeTooltip"] = "Afficher une notification lorsque vous recevez des Bronze.",
    ["ToastUtils.TypeArtifact"] = "Améliorations de l’Artefact",
    ["ToastUtils.TypeArtifactTooltip"] = "Afficher une notification lorsque vous avez une amélioration d’Artefact dans vos sacs.",
    ["ToastUtils.TypeUpgrade"] = "Améliorations d’objet",
    ["ToastUtils.TypeUpgradeTooltip"] = "Afficher une notification lorsque vous avez une amélioration d’objet dans vos sacs.",
    ["ToastUtils.TypeTrait"] = "Nouveaux Traits",
    ["ToastUtils.TypeTraitTooltip"] = "Afficher une notification lorsque vous débloquez un nouveau Trait d’Artefact.",
    ["ToastUtils.TypeSound"] = "Jouer un son",
    ["ToastUtils.TypeSoundTooltip"] = "Jouer un son pour chaque notification.",
    ["ToastUtils.TypeGeneral"] = "Activer les notifications",
    ["ToastUtils.TypeGeneralTooltip"] = "Activer / désactiver toutes les notifications.",
    ["ToastUtils.TestToast"] = "Test de Notification",
    ["ToastUtils.TestToastButtonTitle"] = "Tester une nouvelle notification",
    ["ToastUtils.TestToastTooltip"] = "Afficher un test de notification.",
    ["ToastUtils.TestToastTitle"] = "Test de notification",
    ["ToastUtils.TestToastDescription"] = "Ceci est un test de notification.",
    ["ToastUtils.TypeBronzeTitle"] = "Nouveau Bronze",
    ["ToastUtils.TypeBronzeDescription"] = "Vous avez atteint %d bronze ! (%.2f%% jusqu’au plafond)",
    ["ToastUtils.TypeArtifactTitle"] = "Nouvelle amélioration d’Artefact !",
    ["ToastUtils.TypeArtifactDescription"] = "Vous avez trouvé une nouvelle amélioration d’Artefact ! Vérifiez votre inventaire ou votre barre d’action rapide.",
    ["ToastUtils.TypeUpgradeTitle"] = "Nouvelle améliorer d’objet",
    ["ToastUtils.TypeUpgradeFallback"] = "Objet inconnu",
    ["ToastUtils.TypeTraitTitle"] = "Nouveau Talent débloqué",
    ["ToastUtils.TypeTraitDescription"] = "Nouveau Talent : %s",
    ["ToastUtils.TypeTraitFallback"] = "Talent inconnu",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "Sujets",
    ["TooltipUtils.InfinitePower"] = "Pouvoir infini",
    ["TooltipUtils.Estimate"] = " (Estimation)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "Infobulle de Puissance",
    ["TooltipUtils.SettingsCategoryTooltip"] = "Paramètres de la fonctionnalité Infobulle de Puissance",
    ["TooltipUtils.Activate"] = "Activer",
    ["TooltipUtils.ActivateTooltip"] = "Afficher l’information pour Infobulle de Puissance",
    ["TooltipUtils.ThreadsInfo"] = "Information Sujets",
    ["TooltipUtils.ThreadsInfoTooltip"] = "Afficher les informations des Sujets dans l’Infobulle de Puissance",
    ["TooltipUtils.PowerInfo"] = "Information sur le Pouvoir",
    ["TooltipUtils.PowerInfoTooltip"] = "Afficher l’information de l’Infobulle de Puissance du Pouvoir infini",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "Votre version est passée de %s à la version %s. Consultez Discord pour les notes de mise à jour !",
    ["UpdateUtils.NilVersion"] = "N/A",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "Paramètres généraux",
    ["UXUtils.SettingsCategoryTooltip"] = "Paramètres généraux de l’AddOn",
}
locales["frFR"] = L
