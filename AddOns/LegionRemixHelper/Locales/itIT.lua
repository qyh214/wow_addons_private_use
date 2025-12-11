---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "Seleziona un'opzione",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "Attivazione automatica per specializzazione",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "Nessun artefatto equipaggiato",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl-Clic per visualizzare anteprima",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift-Clic per creare collegamento nella chat",
    ["Tabs.CollectionTabUI.NoName"] = "Nessun Nome",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt-Clic per impostare un punto di riferimento al mercante",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt-Clic per visualizzare il traguardo",
    ["Tabs.CollectionTabUI.FilterCollected"] = "Raccolto",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "Non Raccolto",
    ["Tabs.CollectionTabUI.FilterSources"] = "Fonti",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "Seleziona tutto",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "Deseleziona tutto",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "Mostra varianti incursione",
    ["Tabs.CollectionTabUI.FilterUnique"] = "Solo oggetti specifici Remix",
    ["Tabs.CollectionTabUI.Type"] = "Tipo",
    ["Tabs.CollectionTabUI.Source"] = "Fonte",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "Cerca",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "La tua collezione vale %s su %s di Bronzo.\nDevi spendere altri %s per completarla!",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "Legion Remix",
    ["CollectionsTabUI.ResearchProgress"] = "Ricerca: %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "Tratti Artefatto",
    ["CollectionsTabUI.CollectionTabTitle"] = "Collezione",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "Barra rapida",
    ["QuickActionBarUI.SettingTitlePreview"] = "Titolo dell'azione qui",
    ["QuickActionBarUI.SettingsEditorTitle"] = "Modifica azione",
    ["QuickActionBarUI.SettingsTitleLabel"] = "Titolo dell'azione:",
    ["QuickActionBarUI.SettingsTitleInput"] = "Nome dell'azione",
    ["QuickActionBarUI.SettingsIconLabel"] = "Icona:",
    ["QuickActionBarUI.SettingsIconInput"] = "ID o percorso della texture",
    ["QuickActionBarUI.SettingsIDLabel"] = "ID azione:",
    ["QuickActionBarUI.SettingsIDInput"] = "Nome o ID incantesimo/oggetto",
    ["QuickActionBarUI.SettingsTypeLabel"] = "Tipo di azione:",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "Incantesimo",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "Oggetto",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "Solo quando utilizzabile:",
    ["QuickActionBarUI.SettingsEditorSave"] = "Salva azione",
    ["QuickActionBarUI.SettingsEditorNew"] = "Nuova azione",
    ["QuickActionBarUI.SettingsEditorDelete"] = "Elimina azione",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "Nessuna azione da salvare.",
    ["QuickActionBarUI.SettingsEditorAction"] = "Azione %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "Errore durante il salvataggio dell'azione: %s",
    ["QuickActionBarUI.CombatToggleError"] = "La Barra rapida non può essere aperta o chiusa durante il combattimento.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "Qualità massima di riciclaggio",
    ["ScrappingUI.MinItemLevelDifference"] = "Differenza minima di livello oggetto",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "x livelli in meno rispetto all'equipaggiato",
    ["ScrappingUI.AutoScrap"] = "Riciclaggio automatico",
    ["ScrappingUI.ScraperListTabTitle"] = "Elenco riciclo",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "Avanzate",
    ["ScrappingUI.JewelryTraitsToKeep"] = "Tratti gioiello da mantenere",
    ["ScrappingUI.AdvancedJewelryFilter"] = "Filtro gioiello avanzato",
    ["ScrappingUI.FilterCheckAll"] = "Seleziona tutto",
    ["ScrappingUI.FilterUncheckAll"] = "Deseleziona tutto",
    ["ScrappingUI.Neck"] = "Tratti collana",
    ["ScrappingUI.Trinket"] = "Tratti monile",
    ["ScrappingUI.Finger"] = "Tratti anello",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "Ignora gli oggetti negli insiemi di equipaggiamento",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "Nessun oggetto equipaggiato.",
    ["ArtifactTraitUtils.UnknownTrait"] = "Tratto sconosciuto",
    ["ArtifactTraitUtils.ColumnNature"] = "Natura",
    ["ArtifactTraitUtils.ColumnFel"] = "Vile",
    ["ArtifactTraitUtils.ColumnArcane"] = "Arcano",
    ["ArtifactTraitUtils.ColumnStorm"] = "Tempesta",
    ["ArtifactTraitUtils.ColumnHoly"] = "Sacro",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "Numero massimo di tentativi raggiunto durante l'acquisto dei nodi.",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "Tratti dell'artefatto",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "Impostazioni per la funzionalità Tratti dell'artefatto",
    ["ArtifactTraitUtils.AutoBuy"] = "Acquisto automatico dei nodi",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "Acquista automaticamente i talenti preimpostati quando hai abbastanza Potere dell'artefatto.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "Fonti:",
    ["CollectionUtils.Achievement"] = "Impresa: ",
    ["CollectionUtils.UnknownAchievement"] = "Impresa sconosciuta",
    ["CollectionUtils.UnknownVendor"] = "Mercante sconosciuto",
    ["CollectionUtils.Vendor"] = "Mercante, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[Comando sconosciuto!
Uso: /LRH o /LegionRH <sottoComando>
Sottocomandi:
    collezioni (c) - Apri la scheda Collezioni.
    impostazioni (i) - Apri il menu delle impostazioni.
Esempio: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "collezioni",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "impostazioni",
    ["CommandUtils.SettingsCommandShort"] = "i",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Assistente Legion Remix",
    ["EditModeUtils.SystemLabel.ToastUI"] = "Notifiche",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "Sposta la posizione delle notifiche.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "Apertura automatica oggetti",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "Impostazioni per la funzione di apertura automatica degli oggetti",
    ["ItemOpenerUtils.AutoItemOpen"] = "Apri automaticamente gli oggetti",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "Apre automaticamente alcuni oggetti nell'inventario quando vengono trovati. (Funzionalità ancora in sviluppo)",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "Apre automaticamente l'oggetto %s quando viene trovato nel tuo inventario.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "Impostazioni Mercante",
    ["MerchantUtils.SettingsCategoryTooltip"] = "Impostazioni per la funzionalità Mercante",
    ["MerchantUtils.HideCollectedMerchantItems"] = "Nascondi oggetti mercante raccolti",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "Nasconde gli oggetti che hai già nella tua collezione dalla finestra del mercante.",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "Nascondi animali domestici raccolti al limite",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "Nasconde gli animali domestici nella finestra del mercante solo quando hai raggiunto il limite di raccolta per gli animali domestici.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "Missioni automatiche",
    ["QuestUtils.SettingsCategoryTooltip"] = "Impostazioni per la funzione Missioni automatiche",
    ["QuestUtils.AutoTurnIn"] = "Consegna automatica",
    ["QuestUtils.AutoTurnInTooltip"] = "Consegna automaticamente le missioni quando interagisci con gli NPC.",
    ["QuestUtils.AutoAccept"] = "Accettazione automatica",
    ["QuestUtils.AutoAcceptTooltip"] = "Accetta automaticamente le missioni quando interagisci con gli NPC.",
    ["QuestUtils.IgnoreEternus"] = "Ignora Eternus",
    ["QuestUtils.IgnoreEternusTooltip"] = "Ignora le missioni provenienti da Eternus.",
    ["QuestUtils.SuppressShift"] = "Disattiva con Shift",
    ["QuestUtils.SuppressShiftTooltip"] = "Tieni premuto Shift per disattivare l'accettazione o la consegna automatica delle missioni.",
    ["QuestUtils.SuppressWorldTierIcon"] = "Sopprimere l'icona del livello mondiale",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "Nascondere l'icona del livello mondiale che si trova sotto la mini-mappa.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "Barra rapida",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "Impostazioni per la funzione Barra rapida",
    ["QuickActionBarUtils.ActionNotFound"] = "Azione non trovata",
    ["QuickActionBarUtils.Action"] = "Azione %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "Notifiche",
    ["ToastUtils.SettingsCategoryTooltip"] = "Impostazioni per la funzione Notifiche",
    ["ToastUtils.TypeBronze"] = "Traguardi di Bronzo",
    ["ToastUtils.TypeBronzeTooltip"] = "Mostra una notifica quando raggiungi un nuovo traguardo di bronzo.",
    ["ToastUtils.TypeArtifact"] = "Miglioramenti Artefatto",
    ["ToastUtils.TypeArtifactTooltip"] = "Mostra una notifica quando trovi un miglioramento per un artefatto nelle tue borse.",
    ["ToastUtils.TypeUpgrade"] = "Miglioramenti Oggetto",
    ["ToastUtils.TypeUpgradeTooltip"] = "Mostra una notifica quando trovi un miglioramento per un oggetto nelle tue borse.",
    ["ToastUtils.TypeTrait"] = "Nuovi Tratti",
    ["ToastUtils.TypeTraitTooltip"] = "Mostra una notifica quando sblocchi un nuovo tratto dell'artefatto.",
    ["ToastUtils.TypeSound"] = "Riproduci suono",
    ["ToastUtils.TypeSoundTooltip"] = "Riproduce un suono quando viene mostrata una notifica.",
    ["ToastUtils.TypeGeneral"] = "Abilita notifiche",
    ["ToastUtils.TypeGeneralTooltip"] = "Abilita o disabilita tutte le notifiche.",
    ["ToastUtils.TestToast"] = "Notifica di prova",
    ["ToastUtils.TestToastButtonTitle"] = "Test notifica",
    ["ToastUtils.TestToastTooltip"] = "Mostra una notifica di prova.",
    ["ToastUtils.TestToastTitle"] = "Notifica di prova",
    ["ToastUtils.TestToastDescription"] = "Questa è una notifica di prova.",
    ["ToastUtils.TypeBronzeTitle"] = "Nuovo traguardo di Bronzo!",
    ["ToastUtils.TypeBronzeDescription"] = "Hai raggiunto %d Bronzo! (%.2f%% al limite)",
    ["ToastUtils.TypeArtifactTitle"] = "Nuovo miglioramento Artefatto!",
    ["ToastUtils.TypeArtifactDescription"] = "Controlla l'inventario o la barra rapida.",
    ["ToastUtils.TypeUpgradeTitle"] = "Nuovo miglioramento oggetto!",
    ["ToastUtils.TypeUpgradeFallback"] = "Oggetto sconosciuto",
    ["ToastUtils.TypeTraitTitle"] = "Nuovo tratto sbloccato!",
    ["ToastUtils.TypeTraitDescription"] = "Nuovo tratto: %s",
    ["ToastUtils.TypeTraitFallback"] = "Tratto sconosciuto",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "Fili",
    ["TooltipUtils.InfinitePower"] = "Potere Infinito",
    ["TooltipUtils.Estimate"] = " (Stima)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "Tooltip Potere",
    ["TooltipUtils.SettingsCategoryTooltip"] = "Impostazioni per la funzione Tooltip-Potere",
    ["TooltipUtils.Activate"] = "Attiva",
    ["TooltipUtils.ActivateTooltip"] = "Mostra le informazioni del Tooltip-Potere",
    ["TooltipUtils.ThreadsInfo"] = "Informazioni sui Fili",
    ["TooltipUtils.ThreadsInfoTooltip"] = "Mostra le informazioni sui Fili nel Tooltip-Potere",
    ["TooltipUtils.PowerInfo"] = "Informazioni sul Potere",
    ["TooltipUtils.PowerInfoTooltip"] = "Mostra le informazioni sul Potere Infinito nel Tooltip-Potere",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "La tua versione è passata da %s alla versione %s. Controlla il canale Discord dell'Addon per le Note della patch!",
    ["UpdateUtils.NilVersion"] = "N/D",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "Impostazioni generali",
    ["UXUtils.SettingsCategoryTooltip"] = "Impostazioni generali dell'addon",
}
locales["itIT"] = L
