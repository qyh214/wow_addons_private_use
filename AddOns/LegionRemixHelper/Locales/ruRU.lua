---@class AddonPrivate
-- Translator: ZamestoTV
local Private = select(2, ...)

local locales = Private.Locales or {}
Private.Locales = locales
local L = {
    -- UI/Components/Dropdown.lua
    ["Components.Dropdown.SelectOption"] = "Выберите опцию",

    -- UI/Tabs/ArtifactTraitsTabUI.lua
    ["Tabs.ArtifactTraitsTabUI.AutoActivateForSpec"] = "Автоактивация для специализации",
    ["Tabs.ArtifactTraitsTabUI.NoArtifactEquipped"] = "Артефакт не экипирован",

    -- UI/Tabs/CollectionTabUI.lua
    ["Tabs.CollectionTabUI.CtrlClickPreview"] = "Ctrl-Клик для предпросмотра",
    ["Tabs.CollectionTabUI.ShiftClickToLink"] = "Shift-Клик для ссылки",
    ["Tabs.CollectionTabUI.NoName"] = "Без имени",
    ["Tabs.CollectionTabUI.AltClickVendor"] = "Alt-Клик для установки путевой точки к торговцу",
    ["Tabs.CollectionTabUI.AltClickAchievement"] = "Alt-Клик для просмотра достижения",
    ["Tabs.CollectionTabUI.FilterCollected"] = "Собрано",
    ["Tabs.CollectionTabUI.FilterNotCollected"] = "Не собрано",
    ["Tabs.CollectionTabUI.FilterSources"] = "Источники",
    ["Tabs.CollectionTabUI.FilterCheckAll"] = "Выбрать все",
    ["Tabs.CollectionTabUI.FilterUncheckAll"] = "Снять все",
    ["Tabs.CollectionTabUI.FilterRaidVariants"] = "Показать варианты рейда",
    ["Tabs.CollectionTabUI.FilterUnique"] = "Только специфичные предметы Remix",
    ["Tabs.CollectionTabUI.Type"] = "Тип",
    ["Tabs.CollectionTabUI.Source"] = "Источник",
    ["Tabs.CollectionTabUI.SearchInstructions"] = "Поиск",
    ["Tabs.CollectionTabUI.Progress"] = "%d / %d (%.2f%%)",
    ["Tabs.CollectionTabUI.ProgressTooltip"] = "Ваша коллекция стоит %s из %s Бронзы.\nВам нужно потратить еще %s, чтобы собрать все!",

    -- UI/CollectionsTabUI.lua
    ["CollectionsTabUI.TabTitle"] = "Legion Remix",
    ["CollectionsTabUI.ResearchProgress"] = "Исследование: %s/%s",
    ["CollectionsTabUI.TraitsTabTitle"] = "Артефакт",
    ["CollectionsTabUI.CollectionTabTitle"] = "Коллекция",

    -- UI/QuickActionBarUI.lua
    ["QuickActionBarUI.QuickBarTitle"] = "Быстрая панель",
    ["QuickActionBarUI.SettingTitlePreview"] = "Название действия здесь",
    ["QuickActionBarUI.SettingsEditorTitle"] = "Редактирование действия",
    ["QuickActionBarUI.SettingsTitleLabel"] = "Название действия:",
    ["QuickActionBarUI.SettingsTitleInput"] = "Название действия",
    ["QuickActionBarUI.SettingsIconLabel"] = "Иконка:",
    ["QuickActionBarUI.SettingsIconInput"] = "ID или путь текстуры",
    ["QuickActionBarUI.SettingsIDLabel"] = "ID действия:",
    ["QuickActionBarUI.SettingsIDInput"] = "Название или ID предмета/заклинания",
    ["QuickActionBarUI.SettingsTypeLabel"] = "Тип действия:",
    ["QuickActionBarUI.SettingsTypeInputSpell"] = "Заклинание",
    ["QuickActionBarUI.SettingsTypeInputItem"] = "Предмет",
    ["QuickActionBarUI.SettingsCheckUsableLabel"] = "Только при использовании:",
    ["QuickActionBarUI.SettingsEditorSave"] = "Сохранить действие",
    ["QuickActionBarUI.SettingsEditorNew"] = "Новое действие",
    ["QuickActionBarUI.SettingsEditorDelete"] = "Удалить действие",
    ["QuickActionBarUI.SettingsNoActionSaveError"] = "Нет действия для сохранения.",
    ["QuickActionBarUI.SettingsEditorAction"] = "Действие %s",
    ["QuickActionBarUI.SettingsGeneralActionSaveError"] = "Ошибка при сохранении действия: %s",
    ["QuickActionBarUI.CombatToggleError"] = "Панель быстрых действий нельзя открыть или закрыть во время боя.",

    -- UI/ScrappingUI.lua
    ["ScrappingUI.MaxScrappingQuality"] = "Макс. качество разбора",
    ["ScrappingUI.MinItemLevelDifference"] = "Мин. разница уровня предмета",
    ["ScrappingUI.MinItemLevelDifferenceInstructions"] = "уровней ниже экипированного",
    ["ScrappingUI.AutoScrap"] = "Авторазбор",
    ["ScrappingUI.ScraperListTabTitle"] = "Список разбора",
    ["ScrappingUI.AdvancedSettingsTabTitle"] = "Доп. настройки",
    ["ScrappingUI.JewelryTraitsToKeep"] = "Черты украшений для сохранения",
    ["ScrappingUI.AdvancedJewelryFilter"] = "Расширенный фильтр украшений",
    ["ScrappingUI.FilterCheckAll"] = "Выбрать все",
    ["ScrappingUI.FilterUncheckAll"] = "Снять все",
    ["ScrappingUI.Neck"] = "Черты ожерелья",
    ["ScrappingUI.Trinket"] = "Черты аксессуара",
    ["ScrappingUI.Finger"] = "Черты кольца",
    ["ScrappingUI.IgnoreFromEquipmentSets"] = "Игнорировать предметы в комплектах",

    -- Utils/ArtifactTraitUtils.lua
    ["ArtifactTraitUtils.NoItemEquipped"] = "Предмет не экипирован.",
    ["ArtifactTraitUtils.UnknownTrait"] = "Неизвестная особенность",
    ["ArtifactTraitUtils.ColumnNature"] = "Природа",
    ["ArtifactTraitUtils.ColumnFel"] = "Хаос",
    ["ArtifactTraitUtils.ColumnArcane"] = "Тайная магия",
    ["ArtifactTraitUtils.ColumnStorm"] = "Буря",
    ["ArtifactTraitUtils.ColumnHoly"] = "Свет",
    ["ArtifactTraitUtils.JewelryFormat"] = "|T%s:16|t %s (+%d)",
    ["ArtifactTraitUtils.MaxTriesReached"] = "Достигнут максимум попыток при покупке.",
    ["ArtifactTraitUtils.SettingsCategoryPrefix"] = "Особенности артефакта",
    ["ArtifactTraitUtils.SettingsCategoryTooltip"] = "Настройки для функции Особенности артефакта",
    ["ArtifactTraitUtils.AutoBuy"] = "Автоматическое изучение артефакта",
    ["ArtifactTraitUtils.AutoBuyTooltip"] = "Автоматически изучает предустановленные таланты, когда у вас достаточно бесконечной силы.",

    -- Utils/CollectionUtils.lua
    ["CollectionUtils.Sources"] = "Источники:",
    ["CollectionUtils.Achievement"] = "Достижение: ",
    ["CollectionUtils.UnknownAchievement"] = "Неизвестное достижение",
    ["CollectionUtils.UnknownVendor"] = "Неизвестный торговец",
    ["CollectionUtils.Vendor"] = "Торговец, ",

    -- Utils/CommandUtils.lua
    ["CommandUtils.UnknownCommand"] =
[[Неизвестная команда!
Использование: /LRH или /LegionRH <подкоманда>
Подкоманды:
     коллекция (c) — открыть вкладку Коллекции.
     настройки (s) — Открыть меню настроек.
Пример: /LRH s]],
    ["CommandUtils.CollectionsCommand"] = "коллекции",
    ["CommandUtils.CollectionsCommandShort"] = "c",
    ["CommandUtils.SettingsCommand"] = "настройки",
    ["CommandUtils.SettingsCommandShort"] = "s",

    -- Utils/EditModeUtils.lua
    ["EditModeUtils.ShowAddonSystems"] = "Legion-Remix-Helper-Systems",
    ["EditModeUtils.SystemLabel.ToastUI"] = "Уведомления",
    ["EditModeUtils.SystemTooltip.ToastUI"] = "Переместить позицию уведомлений.",

    -- Utils/ItemOpenerUtils.lua
    ["ItemOpenerUtils.SettingsCategoryPrefix"] = "Авто открывание предметов",
    ["ItemOpenerUtils.SettingsCategoryTooltip"] = "Настройки функции автоматического открытия предметов",
    ["ItemOpenerUtils.AutoItemOpen"] = "Автоматически открывать предметы",
    ["ItemOpenerUtils.AutoItemOpenTooltip"] = "Автоматически открывает определённые предметы в вашем инвентаре при их нахождении. (Эта функция всё ещё находится в разработке.)",
    ["ItemOpenerUtils.AutoOpenItemEntryTooltip"] = "Автоматически открывает %s при нахождении в вашем инвентаре.",

    -- Utils/MerchantUtils.lua
    ["MerchantUtils.SettingsCategoryPrefix"] = "Настройки торговца",
    ["MerchantUtils.SettingsCategoryTooltip"] = "Настройки функции Торговец",
    ["MerchantUtils.HideCollectedMerchantItems"] = "Скрыть собранные предметы торговца",
    ["MerchantUtils.HideCollectedMerchantItemsTooltip"] = "Скрывает предметы в окне торговца, которые уже есть в вашей коллекции.",
    ["MerchantUtils.HideCollectedPetsAtLimit"] = "Скрыть собранных питомцев при достижении лимита",
    ["MerchantUtils.HideCollectedPetsAtLimitTooltip"] = "Скрыть питомцев в окне торговца только при достижении лимита коллекции для питомцев.",

    -- Utils/QuestUtils.lua
    ["QuestUtils.SettingsCategoryPrefix"] = "Автозадание",
    ["QuestUtils.SettingsCategoryTooltip"] = "Настройки функции Автозадание",
    ["QuestUtils.AutoTurnIn"] = "Автосдача",
    ["QuestUtils.AutoTurnInTooltip"] = "Автоматически сдавать задания при взаимодействии с НИП.",
    ["QuestUtils.AutoAccept"] = "Автоприем",
    ["QuestUtils.AutoAcceptTooltip"] = "Автоматически принимать задания при взаимодействии с НИП.",
    ["QuestUtils.IgnoreEternus"] = "Игнорировать Вечноса",
    ["QuestUtils.IgnoreEternusTooltip"] = "Игнорируйте задания, от Вечноса.",
    ["QuestUtils.SuppressShift"] = "С помощью Shift",
    ["QuestUtils.SuppressShiftTooltip"] = "Удерживайте клавишу Shift, чтобы отменить автоматическое принятие/сдачу заданий.",
    ["QuestUtils.SuppressWorldTierIcon"] = "Скрыть иконку уровня мира",
    ["QuestUtils.SuppressWorldTierIconTooltip"] = "Скрыть иконку уровня мира, которая находится под мини-картой.",

    -- Utils/QuickActionBarUtils.lua
    ["QuickActionBarUtils.SettingsCategoryPrefix"] = "Быстрая панель действий",
    ["QuickActionBarUtils.SettingsCategoryTooltip"] = "Настройки функции Быстрая панель",
    ["QuickActionBarUtils.ActionNotFound"] = "Действие не найдено",
    ["QuickActionBarUtils.Action"] = "Действие %s",

    -- Utils/ToastUtils.lua
    ["ToastUtils.SettingsCategoryPrefix"] = "Уведомления",
    ["ToastUtils.SettingsCategoryTooltip"] = "Настройки функции Уведомления",
    ["ToastUtils.TypeBronze"] = "Бронзовые вехи",
    ["ToastUtils.TypeBronzeTooltip"] = "Показывать уведомление при достижении новой бронзовой вехи.",
    ["ToastUtils.TypeArtifact"] = "Улучшения артефакта",
    ["ToastUtils.TypeArtifactTooltip"] = "Показывать уведомление при нахождении улучшения артефакта в сумках.",
    ["ToastUtils.TypeUpgrade"] = "Улучшения предметов",
    ["ToastUtils.TypeUpgradeTooltip"] = "Показывать уведомление при нахождении улучшения предмета в сумках.",
    ["ToastUtils.TypeTrait"] = "Новые особенности",
    ["ToastUtils.TypeTraitTooltip"] = "Показывать уведомление при разблокировке новой особенности артефакта.",
    ["ToastUtils.TypeSound"] = "Воспроизвести звук",
    ["ToastUtils.TypeSoundTooltip"] = "Воспроизводить звук при показе любого уведомления.",
    ["ToastUtils.TypeGeneral"] = "Включить уведомления",
    ["ToastUtils.TypeGeneralTooltip"] = "Включить или отключить все уведомления.",
    ["ToastUtils.TestToast"] = "Тест уведомления",
    ["ToastUtils.TestToastButtonTitle"] = "Тест уведомления",
    ["ToastUtils.TestToastTooltip"] = "Показать тестовое уведомление.",
    ["ToastUtils.TestToastTitle"] = "Тестовое уведомление",
    ["ToastUtils.TestToastDescription"] = "Это тестовое уведомление.",
    ["ToastUtils.TypeBronzeTitle"] = "Новая бронзовая веха!",
    ["ToastUtils.TypeBronzeDescription"] = "Вы достигли %d бронзы! (%.2f%% до максимума)",
    ["ToastUtils.TypeArtifactTitle"] = "Новое улучшение артефакта!",
    ["ToastUtils.TypeArtifactDescription"] = "Вы нашли новое улучшение артефакта! Проверьте инвентарь или быструю панель действий.",
    ["ToastUtils.TypeUpgradeTitle"] = "Новое улучшение предмета!",
    ["ToastUtils.TypeUpgradeFallback"] = "Неизвестный предмет",
    ["ToastUtils.TypeTraitTitle"] = "Новая особенность разблокирована!",
    ["ToastUtils.TypeTraitDescription"] = "Новая особенность: %s",
    ["ToastUtils.TypeTraitFallback"] = "Неизвестная особенность",

    -- Utils/TooltipUtils.lua
    ["TooltipUtils.Threads"] = "Нити",
    ["TooltipUtils.InfinitePower"] = "Бесконечная сила",
    ["TooltipUtils.Estimate"] = " (оценка)",
    ["TooltipUtils.SettingsCategoryPrefix"] = "Сила в подсказке",
    ["TooltipUtils.SettingsCategoryTooltip"] = "Настройки функции Сила в подсказке",
    ["TooltipUtils.Activate"] = "Активировать",
    ["TooltipUtils.ActivateTooltip"] = "Показывать информацию о Силе в подсказке",
    ["TooltipUtils.ThreadsInfo"] = "Информация о нитях",
    ["TooltipUtils.ThreadsInfoTooltip"] = "Показывать информацию о нитях Силы в подсказке",
    ["TooltipUtils.PowerInfo"] = "Информация о силе",
    ["TooltipUtils.PowerInfoTooltip"] = "Показывать информацию о Бесконечной силе в подсказке",

    -- Utils/UpdateUtils.lua
    ["UpdateUtils.PatchNotesMessage"] = "Ваша версия изменилась с %s на версию %s. Проверьте Discord аддона для заметок к патчу!",
    ["UpdateUtils.NilVersion"] = "Н/Д",

    -- Utils/UXUtils.lua
    ["UXUtils.SettingsCategoryPrefix"] = "Общие настройки",
    ["UXUtils.SettingsCategoryTooltip"] = "Общие настройки аддона",
}
locales["ruRU"] = L
