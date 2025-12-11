---@class AddonPrivate
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "Selecciona una opción",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "Activación automática para especializaciones",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "No tienes un arma artefacto equipada",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl-click para previsualizar",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift-click para enlazar",
    ["Tabs.CollectionTabUI.NoName"] = "Sin nombre",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt-click para establecer un punto de referencia para el vendedor",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt-click para ver el logro",
    ["Tabs.CollectionTabUI.FilterCollected"] = "Conocido",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "No conocido",
    ["Tabs.CollectionTabUI.FilterSources"] = "Fuentes",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "Marcar todo",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "Desmarcar todo",
	["Tabs.CollectionTabUI.FilterRaidVariants"] = "Mostrar variantes de banda",
    ["Tabs.CollectionTabUI.FilterUnique"] = "Solo items específicos de Remix",
    ["Tabs.CollectionTabUI.Type"] = "Tipo",
    ["Tabs.CollectionTabUI.Source"] = "Fuente",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "Buscar",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "Tu colección vale %s de %s de Bronce.\n¡Necesitas gastar %s más de bronce para conseguirlo todo!",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "Legion Remix",
    ["CollectionsTabUI.ResearchProgress"] = "Investigación: %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "Artefacto",
    ["CollectionsTabUI.CollectionTabTitle"] = "Colección",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "Barra rápida",
    ["QuickActionBarUI.SettingTitlePreview"] = "Título de la acción aquí",
    ["QuickActionBarUI.SettingsEditorTitle"] = "Acción de edición",
    ["QuickActionBarUI.SettingsTitleLabel"] = "Título de la acción:",
    ["QuickActionBarUI.SettingsTitleInput"] = "Nombre de la acción",
    ["QuickActionBarUI.SettingsIconLabel"] = "Icono:",
    ["QuickActionBarUI.SettingsIconInput"] = "Textura ID o Parche",
    ["QuickActionBarUI.SettingsIDLabel"] = "Acción ID:",
    ["QuickActionBarUI.SettingsIDInput"] = "Item/Hechizo nombre o ID",
    ["QuickActionBarUI.SettingsTypeLabel"] = "Tipo de acción:",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "Hechizo",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "Item",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "Solo cuando sea utilizable:",
    ["QuickActionBarUI.SettingsEditorSave"] = "Guardar acción",
    ["QuickActionBarUI.SettingsEditorNew"] = "Nueva acción",
    ["QuickActionBarUI.SettingsEditorDelete"] = "Borrar acción",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "No hay ninguna acción para guardar.",
    ["QuickActionBarUI.SettingsEditorAction"] = "Acción %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "Se produjo un error al guardar la acción: %s",
	["QuickActionBarUI.CombatToggleError"] = "La barra de acción rápida no se puede abrir ni cerrar en combate.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "Calidad máxima de los items para el desguace",
    ["ScrappingUI.MinItemLevelDifference"] = "Diferencia mínima de nivel de objeto",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "x niveles inferiores a los equipados",
    ["ScrappingUI.AutoScrap"] = "Auto desguace",
    ["ScrappingUI.ScraperListTabTitle"] = "Lista de basura",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "Más opciones",
    ["ScrappingUI.JewelryTraitsToKeep"] = "Rasgos de las joyas",
    ["ScrappingUI.AdvancedJewelryFilter"] = "Filtro avanzado de joyería",
    ["ScrappingUI.FilterCheckAll"] = "Marcar todo",
    ["ScrappingUI.FilterUncheckAll"] = "Desmarcar todo",
    ["ScrappingUI.Neck"] = "Rasgos del collar",
    ["ScrappingUI.Trinket"] = "Rasgos de los abalorios",
    ["ScrappingUI.Finger"] = "Rasgos de los anillos",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "Ignorar items en conjuntos de equipo",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "No hay ningún objeto equipado.",
    ["ArtifactTraitUtils.UnknownTrait"] = "Rasgo desconocido",
	["ArtifactTraitUtils.ColumnNature"] = "Naturaleza",
    ["ArtifactTraitUtils.ColumnFel"] = "Vil",
    ["ArtifactTraitUtils.ColumnArcane"] = "Arcano",
    ["ArtifactTraitUtils.ColumnStorm"] = "Tormenta",
    ["ArtifactTraitUtils.ColumnHoly"] = "Sagrado",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "Se ha alcanzado el número máximo de intentos al comprar nodos.",
	["ArtifactTraitUtils.SettingsCategoryPrefix"] = "Rasgos de artefacto",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "Configuración de la función Rasgos de artefacto",
    ["ArtifactTraitUtils.AutoBuy"] = "Compra automática de nodos",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "Compra automáticamente los talentos preestablecidos cuando tienes suficiente poder de artefacto.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "Fuentes: ",
    ["CollectionUtils.Achievement"] = "Logro: ",
    ["CollectionUtils.UnknownAchievement"] = "Logro desconocido",
    ["CollectionUtils.UnknownVendor"] = "Vendedor desconocido",
    ["CollectionUtils.Vendor"] = "Vendedor: ",

	-- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[ Comando desconocido!
Uso: /LRH o /LegionRH <subCommand>
Subcomandos:
    colecciones (c) - Abrir la pestaña de colecciones.
    ajustes (s) - Abrir el menú de ajustes.
Ejemplo: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "colecciones",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "ajustes",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Legion-Remix-Helper-Systems",
    ["EditModeUtils.SystemLabel.ToastUI"] = "Notificaciones emergentes",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "Mover la posición de las notificaciones emergentes.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "Apertura automática de items",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "Configuración de la función de apertura automática de items",
    ["ItemOpenerUtils.AutoItemOpen"] = "Abrir items automáticamente",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "Abre automáticamente ciertos items de tu inventario al encontrarlos. (Esta función aún está en desarrollo)",
	["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "Abre automáticamente %s cuando se encuentra en tu inventario.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "Configuración del vendedor",
    ["MerchantUtils.SettingsCategoryTooltip"] = "Configuración de la función Vendedor",
    ["MerchantUtils.HideCollectedMerchantItems"] = "Ocultar los items del vendedor conocidos",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "Oculta los items de la ventana del vendedor que ya tienes en tu colección.",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "Ocultar mascotas recolectadas al límite",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "Oculta las mascotas en la ventana del vendedor solo cuando hayas alcanzado el límite de colección para mascotas.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "Misión automática",
    ["QuestUtils.SettingsCategoryTooltip"] = "Configuración de la función Misión automática",
    ["QuestUtils.AutoTurnIn"] = "Entregar automática",
    ["QuestUtils.AutoTurnInTooltip"] = "Entrega misiones automáticamente al interactuar con NPCs.",
    ["QuestUtils.AutoAccept"] = "Aceptar automáticamente",
    ["QuestUtils.AutoAcceptTooltip"] = "Acepta misiones automáticamente al interactuar con NPCs.",
	["QuestUtils.IgnoreEternus"] = "Ignorar Eternus",
    ["QuestUtils.IgnoreEternusTooltip"] = "Ignora las misiones que vienen de Eternus.",
    ["QuestUtils.SuppressShift"] = "Suprimir con Shift",
    ["QuestUtils.SuppressShiftTooltip"] = "Mantén pulsada la tecla Shift para suprimir la aceptación/entrega automática de misiones.",
    ["QuestUtils.SuppressWorldTierIcon"] = "Suprimir el icono de nivel de mundo",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "Ocultar el icono de nivel de mundo que se encuentra debajo del minimapa.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "Barra de acción rápida",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "Configuración de la función Barra rápida",
    ["QuickActionBarUtils.ActionNotFound"] = "Acción no encontrada",
    ["QuickActionBarUtils.Action"] = "Acción %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "Notificación emergente",
    ["ToastUtils.SettingsCategoryTooltip"] = "Configuración de la función Notificación emergente",
    ["ToastUtils.TypeBronze"] = "Hitos de bronce",
    ["ToastUtils.TypeBronzeTooltip"] = "Muestra una notificación emergente cuando alcances un nuevo hito de bronce.",
    ["ToastUtils.TypeArtifact"] = "Mejoras de artefactos",
    ["ToastUtils.TypeArtifactTooltip"] = "Muestra una notificación emergente cuando encuentres una mejora de artefacto en tus bolsas.",
    ["ToastUtils.TypeUpgrade"] = "Mejoras de objetos",
    ["ToastUtils.TypeUpgradeTooltip"] = "Muestra una notificación emergente cuando encuentres una mejora de objeto en tus bolsas.",
    ["ToastUtils.TypeTrait"] = "Nuevos rasgos",
    ["ToastUtils.TypeTraitTooltip"] = "Muestra una notificación emergente cuando desbloquees un nuevo rasgo de artefacto.",
    ["ToastUtils.TypeSound"] = "Reproducir sonido",
    ["ToastUtils.TypeSoundTooltip"] = "Reproduce un sonido al mostrar cualquier notificación emergente.",
    ["ToastUtils.TypeGeneral"] = "Activar notificaciones emergentes",
    ["ToastUtils.TypeGeneralTooltip"] = "Activa o desactiva todas las notificaciones emergentes.",
    ["ToastUtils.TestToast"] = "Probar notificación emergente",
    ["ToastUtils.TestToastButtonTitle"] = "Probar notificación emergente",
    ["ToastUtils.TestToastTooltip"] = "Muestra una notificación emergente de prueba.",
    ["ToastUtils.TestToastTitle"] = "Prueba de notificación emergente",
    ["ToastUtils.TestToastDescription"] = "Esta es una notificación emergente de prueba.",
    ["ToastUtils.TypeBronzeTitle"] = "¡Nuevo hito de bronce!",
    ["ToastUtils.TypeBronzeDescription"] = "¡Has alcanzado %d de bronce! (%.2f%% to cap)",
    ["ToastUtils.TypeArtifactTitle"] = "¡Nueva mejora de artefacto!",
    ["ToastUtils.TypeArtifactDescription"] = "¡Has encontrado una nueva mejora para tu arma artefacto! Comprueba tu inventario o la barra de acciones rápidas.",
    ["ToastUtils.TypeUpgradeTitle"] = "¡Nueva mejora de objeto!",
    ["ToastUtils.TypeUpgradeFallback"] = "Item desconocido",
    ["ToastUtils.TypeTraitTitle"] = "¡Nuevo rasgo desbloqueado!",
    ["ToastUtils.TypeTraitDescription"] = "Nuevo rasgo: %s",
    ["ToastUtils.TypeTraitFallback"] = "Rasgo desconocido",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "Hilos",
    ["TooltipUtils.InfinitePower"] = "Poder infinito",
    ["TooltipUtils.Estimate"] = " (Estimar)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "Información emergente Poder infinito",
    ["TooltipUtils.SettingsCategoryTooltip"] = "Configuración de la función información emergente Poder infinito",
    ["TooltipUtils.Activate"] = "Activar",
    ["TooltipUtils.ActivateTooltip"] = "Muestra información emergente: información de poder infinito",
    ["TooltipUtils.ThreadsInfo"] = "Información sobre hilos",
    ["TooltipUtils.ThreadsInfoTooltip"] = "Muestra información emergente: Hilos",
    ["TooltipUtils.PowerInfo"] = "Información sobre poder",
    ["TooltipUtils.PowerInfoTooltip"] = "Muestra información emergente: Poder infinito",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "Tu versión ha cambiado de %s a la versión %s. ¡Consulta las notas del parche en el Discord del complemento!",
    ["UpdateUtils.NilVersion"] = "N/A",

	-- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "Configuración general",
    ["UXUtils.SettingsCategoryTooltip"] = "Configuración general de complementos",
}
locales["esES"] = L
