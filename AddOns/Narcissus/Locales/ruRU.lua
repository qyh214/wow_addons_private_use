--Coutesy of Hubbotu. Thank you!    --Translator: Hubbotu as of 1.0.9 

if not (GetLocale() == "ruRU") then
    return;
end

local L = Narci.L



L["Press Copy"] = NARCI_COLOR_GREY_70.. "Нажмите |r".. NARCI_SHORTCUTS_COPY.. NARCI_COLOR_GREY_70 .." чтобы скопировать";
L["Copied"] = NARCI_COLOR_GREEN_MILD.. "Ссылка Скопирована";

L["Movement Speed"] = "СД";
L["Damage Reduction Percentage"] = "СУ%";

L["Advanced Info"] = "Щелкните ЛКМ для переключения расширенной информации.";

L["Photo Mode"] = "Фото Режим";
L["Photo Mode Tooltip Open"] = "Откройте Панель инструментов скриншоты.";
L["Photo Mode Tooltip Close"] = "Закройте панель инструментов скриншотов.";
L["Photo Mode Tooltip Special"] = "Ваши захваченные скриншоты в папке WoW Screenshots не будут включать этот виджет.";

L["Xmog Button"] = "Поделиться Трансмогом";
L["Xmog Button Tooltip Open"] = "Показать предметы трансмога вместо реальных предметов.";
L["Xmog Button Tooltip Close"] = "Отображает фактическую экипировку, без трансмога.";
L["Xmog Button Tooltip Special"] = "Вы можете попробовать разные макеты.";

L["Emote Button"] = "Сделать Эмоцию";
L["Emote Button Tooltip Open"] = "Делайте эмоции с уникальными анимациями.";
L["Auto Capture"] = "Авто Захват";

L["HideTexts Button"] = "Скрыть Тексты";
L["HideTexts Button Tooltip Open"] = "Скрыть все имена, пузырьки чата и боевые тексты.";
L["HideTexts Button Tooltip Close"] = "Восстановите имена, пузыри чата и боевые тексты.";
L["HideTexts Button Tooltip Special"] = "Предыдущие настройки будут восстановлены при выходе из системы.";

L["TopQuality Button"] = "Высокое качество";
L["TopQuality Button Tooltip Open"] = "Установите все параметры качества графики на максимум.";
L["TopQuality Button Tooltip Close"] = "Восстановите настройки графики.";

--Special Source--
L["Heritage Armor"] = "Традиционные Доспехи";
ITEMSOURCE_SECRETFINDING = "Секретная Находка"

HEART_QUOTE_1 = "то, что существенно, невидимо для глаза.";

--Title Manager--
NARCI_TITLE_MANAGER_OPEN = "Открыть Меню Титулов";
NARCI_TITLE_MANAGER_CLOSE = "Закрыть Меню Титулов";

--Alias--
NARCI_ALIAS_USE_ALIAS = "Переключиться на псевдоним"
NARCI_ALIAS_USE_PLAYER_NAME = "Переключиться на "..CALENDAR_PLAYER_NAME;

L["Minimap Tooltip Double Click"] = "Двойное нажатие";
L["Minimap Tooltip Left Click"] = "ЛКМ|r";
L["Minimap Tooltip To Open"] = "|cffffffffОткрыть "..CHARACTER_INFO;
L["Minimap Tooltip Enter Photo Mode"] = "|cffffffffВойдите в фото режим";
L["Minimap Tooltip Right Click"] = "ПКМ";
L["Minimap Tooltip Shift Left Click"] = "Shift + ЛКМ";
L["Minimap Tooltip Shift Right Click"] = "Shift + ПКМ";
L["Minimap Tooltip Hide Button"] = "|cffffffffСкрыть эту кнопку|r"
L["Minimap Tooltip Middle Button"] = "|CFFFF1000Средняя кнопка |cffffffffСброс камеры";
L["Minimap Tooltip Set Scale"] = "Установите Масштаб: |cffffffff/narci [масштаб 0.8~1.2]";
L["Corrupted Item Parser"] = "|cffffffffПереключить парсер порченого предмета|r";
L["Toggle Dressing Room"] = "|cffffffffПереключить на "..DRESSUP_FRAME.."|r";

NARCI_CLIPBOARD = "Буфер Обмена";
NARCI_LAYOUT = "Место";
NARCI_LAYOUT_SYMMETRY = "Симметрия";
NARCI_LAYOUT_ASYMMETRY = "Асимметрия";
NARCI_COPY_TEXTS = "Скопировать Текст";
NARCI_SYNTAX = "Синтаксис";
NARCI_SYNTAX_PLAIN_TEXT = "Обычный Текст";
NARCI_SYNTAX_BBCODE = "BB Code";
NARCI_SYNTAX_MARKDOWN = "Снижение";
NARCI_EXPORT_INCLUDES = "Экспорт Включает В Себя...";
NARCI_ITEM_ID = "ID Предмета";

NARCI_3DMODEL = "3D Модель";
NARCI_EQUIPMENTSLOTS = "Слоты Экипировки";

--Preferences--
NARCI_PREFERENCE = "Предпочтения-PH";
NARCI_INTERFACE = "Интерфейс";
NARCI_THEME = "Темы";
NARCI_EFFECTS = "Эффекты";
NARCI_CAMERA = "Камера";
NARCI_TRANSMOG = "Трансмог";
NARCI_PHOTO_MODE = L["Фото Режим"];
NARCI_EXTENSIONS = "Расширения";
L["Credits"] = "Титры";
NARCI_ABOUT = "О нас";
NARCI_PREFERENCE_TOOLTIP = "Нажмите, чтобы открыть рамку предпочтений.";
NARCI_TRUNCATE_TEXT = "Усечение Текста";
NARCI_ATTRIBUTE_FRAME = "Статический Лист";
NARCI_TEXT_WIDTH = "Ширина Текста";
NARCI_HOTKEY = "Клавиша";
NARCI_DOUBLE_TAP = "Двойное нажатие";
NARCI_DOUBLE_TAP_DESCRIPTION = "Дважды коснитесь клавиши, привязанной к панели персонажа, чтобы открыть Narcissus."
NARCI_OVERRIDE = "Переопределение";
NARCI_INVALID_KEY = "Недопустимая комбинация клавиш.";
NARCI_MINIMAP_BUTTON = "Кнопка на Миникарте";
NARCI_SHORTCUTS = "Доступ";
NARCI_FILTERS = "Фильтры";
NARCI_FILTERS_DESCRIPTION = "Все фильтры, за исключением затемнения будет отключен в режиме трансмогрификации.";
NARCI_GRAIN_EFFECT = "Зерновой Эффект";
NARCI_CAMERA_MOVEMENT = "Движение камеры";
NARCI_CAMERA_ORBIT = "Сферическая камера";
NARCI_CAMERA_ORBIT_ENABLED_DESCRIPTION = "Когда вы откроете этот аддон, камера будет повернута к вам спереди и начнет вращаться по орбите.";
NARCI_CAMERA_ORBIT_DISABLED_DESCRIPTION = "Когда вы откроете этот аддон, камера будет увеличена без поворота";
NARCI_CAMERA_SAFE_MODE = "Безопасный Режим Камеры";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION = "Полностью отключить экшн-камеру после закрытия этого аддона.";
NARCI_CAMERA_SAFE_MODE_DESCRIPTION_EXTRA = "Не используется, потому что вы используете динамическую камеру."
NARCI_FADEOUT = "Появляется при наведении мыши";
NARCI_FADEOUT_DESCRIPTION = "Кнопка исчезает, когда вы убираете курсор от нее.";
NARCI_FADE_MUSIC = "Приглушить Музыку ввод/вывод";
NARCI_VIGNETTE_STRENGTH = "Уровень Затемнения";
NARCI_WEATHER_EFFECT = "Погодные эффекты";
NARCI_LETTERBOX_EFFECT = "Широкоформатный режим";
NARCI_LETTERBOX_RATIO = "Соотношение"
NARCI_LETTERBOX_EFFECT_ALERT1 = "Соотношение сторон вашего монитора превышает выбранное соотношение!"
NARCI_LETTERBOX_EFFECT_ALERT2 = "Рекомендуется установить масштаб пользовательского интерфейса на %0.1f\n(текущий масштаб %0.1f)"
NARCI_DEFAULT_LAYOUT = "Макет по умолчанию";
NARCI_LAYOUT_1 = "Симметрия, 1 Модель";
NARCI_LAYOUT_2 = "2 модели";
NARCI_LAYOUT_3 = "Компактный Режим";
NARCI_BORDER_THEME = "Тема Границы";
NARCI_BORDER_THEME_BRIGHT = "Яркая";
NARCI_BORDER_THEME_DARK = "Темная";
NARCI_ALWAYS_SHOW_MODEL = "Всегда Показывайте Модель";
NARCI_SHOW_FULL_BODY = "Показать Все Тело";
NARCI_AFK_SCREEN_DESCRIPTION = "Автоматически открывает Narcissus когда вы АФК.";
NARCI_AFK_SCREEN_DESCRIPTION_EXTRA = "Это будет переопределять ElvUI режим АФК.";
NARCI_GEMMA = "\"Камни\"";
NARCI_GEMMY_DESCRIPTION = "Показать список камней, когда вы носите экипировку.";
NARCI_DRESSING_ROOM = "Гардеробная"
NARCI_DRESSING_ROOM_DESCRIPTION = "Большая панель гардеробной с возможностью просмотра и копирования списков предметов других игроков и создания ссылок на гардеробную Wowhead.";
NARCI_REQUIRE_RELOAD = NARCI_COLOR_RED_MILD.. "Требуется перезагрузка пользовательского интерфейса.|r";
NARCI_PREFERENCE_GENERAL = "Общие";   --General options

L["Show Detailed Stats"] = "Показать Подробную Статистику";
L["Tooltip Color"] = "Цвет Всплывающей Подсказки";
L["Entrance Visual"] = "Визуал Вход";
L["Entrance Visual Description"] = "Воспроизведение визуальных эффектов заклинаний, когда появляется ваша модель.";
L["Panel Scale"] = "Масштаб панели";
L["Exit Confirmation"] = "Подтверждение Выхода";
L["Exit Confirmation Texts"] = "Выйти из группового фото?";
L["Exit Confirmation Leave"] = "Да";
L["Exit Confirmation Cancel"] = "Нет";
L["Ultra-wide"] = "Ультра-широкий";
L["Ultra-wide Optimization"] = "Сверхширокая оптимизация";
L["Baseline Offset"] = "Смещение Базовой Линии";
L["Ultra-wide Tooltip"] = "Вы можете увидеть эту опцию, потому что используете %s:9 монитор.";
L["Interactive Area"] = "Интерактивная Зона";
L["Item Socketing Tooltip"] = "Дважды щелкните, чтобы вставить";
L["No Available Gem"] = "|cffd8d8d8Нет в наличии каменя|r";
L["Use Bust Shot"] = "Эффект Приближения";
L["Use Escape Button"] = "Клавиша Esc";
L["Use Escape Button Description"] = "Нажмите клавишу Esc для выхода.\nИли выйдите, нажав скрытую кнопку X в правом верхнем углу экрана.";
L["Handled by Other Addons"] = "Обрабатывается другими аддонами";
L["AFK Screen"] = "АФК-экран";
L["Keep Standing"] = "Продолжай Стоять";
L["Keep Standing Description"] = "Используйте /встать время от времени, когда вы находитесь в АФК. Это не помешает выходу из системы.";
L["None"] = "Нет";
L["NPC"] = "НПС";
L["Database"] = "База данных";
L["Creature Tooltip"] = "Создание всплывающей подсказки";
L["RAM Usage"] = "Использование оперативной памяти";
L["Others"] = "Другие";
L["Find Relatives"] = "Найти Родственников";
L["Find Related Creatures Description"] = "Поиск НПС с одной и той же фамилией.";
L["Find Relatives Hotkey Format"] = "Нажмите %s чтобы найти родственников.";
L["Translate Names"] = "Перевод Имен";
L["Translate Names Description On"] = "Показать переведенное название НПС на...";
L["Translate Names Description Off"] = "";
L["Select A Language"] = "Выбранный язык:";
L["Select Multiple Languages"] = "Выбранные языки:";
L["Load on Demand"] = "Загрузка по требованию";
L["Load on Demand Description On"] = "Не загружайте базу данных до тех пор, пока не воспользуетесь функциями поиска.";
L["Load on Demand Description Off"] = "Загрузите базу данных существ при входе в систему.";
L["Load on Demand Description Disabled"] = NARCI_COLOR_YELLOW.. "Этот переключатель заблокирован, потому что вы включили всплывающую подсказку существа.";
L["Tooltip"] = "Подсказка";
L["Name Plate"] = "Табличка с именем";
L["Y Offset"] = "Смещение Y";
L["Sceenshot Quality"] = "Качество Скриншота";
L["Screenshot Quality Description"] = "Более высокое качество приводит к большему размеру файла.";

--Model Control--
NARCI_HOLD_WEAPON = "С Оружием";
NARCI_STAND_IDLY = "Без Оружия";
NARCI_RANGED_WEAPON = "Дальний бой";
NARCI_MELEE_WEAPON = "Ближний бой";
NARCI_SPELLCASTING = "Заклинание";
NARCI_ANIMATION_ID = "ID Анимации";
NARCI_LINK_LIGHT_SETTINGS = "Настройки Освещения";
NARCI_LINK_MODEL_SCALE = "Масштаб Модели";
NARCI_GROUP_PHOTO = "Групповое фото";
NARCI_GROUP_PHOTO_AVAILABLE = "Теперь доступен в Narcissus";
NARCI_GROUP_PHOTO_NOTIFICATION = "Пожалуйста, выберите цель.";
NARCI_GROUP_PHOTO_STATUS_HIDDEN = "Скрыть";
NARCI_GROUP_PHOTO_ADD_MODEL = "ЛКМ: Добавьте свою цель в сцену.\nПКМ: создать из коллекции."
NARCI_DIRECTIONAL_AMBIENT_LIGHT = "Направленный/Рассеянный Свет";
NARCI_DIRECTIONAL_AMBIENT_LIGHT_TOOLTIP = "Переключение между ними\n- Направленный свет, который может быть заблокирован объектом и отбрасывать тень\n- Рассеянный свет, который влияет на всю модель";
L["Reset"] = "Сброс";
L["Actor Index"] = "Индекс";
L["Move To Font"] = "|cff40c7ebПеред|r";
L["Actor Index Tooltip"] = "Перетащите кнопку индекса, чтобы изменить слой модели.";
L["Play Button Tooltip"] = "ЛКМ: воспроизвести эту анимацию\nПКМ: Возобновить все модели\' анимации";
L["Pause Button Tooltip"] = "ЛКМ: Приостановите эту анимацию\nПКМ: Приостановка всех моделей\' анимаций";
L["Save Layers"] = "Сохранение Слоев";
L["Save Layers Tooltip"] = "Автоматический захват 6 скриншотов для композиции изображения.\nПожалуйста, не перемещайте курсор и не нажимайте никаких кнопок во время этого процесса. В противном случае ваш персонаж может стать невидимым после выхода из аддона. Если это произойдет, используйте эту команду:\n/console showplayer";
L["Ground Shadow"] = "Тень на Земле";
L["Ground Shadow Tooltip"] = "Добавьте подвижную тень на земле под вашей моделью.";
L["Hide Player"] = "Скрыть Игрока";
L["Hide Player Tooltip"] = "Сделайте своего персонажа невидимым для себя.";
L["Virtual Actor"] = "Виртуальный";
L["Virtual Actor Tooltip"] = "На этой модели видно только визуальное заклинание."
L["Self"] = "Себя";
L["Target"] = "Цель";
L["Compact Mode Tooltip"] = "Используйте только левую часть экрана, чтобы представить свой трансмог.";
L["Toggle Equipment Slots"] = "Отобразить/Скрыть слоты экипировки";
L["Toggle Text Mask"] = "Переключить текстовую маску";
L["Toggle 3D Model"] = "Переключить 3D модель";
L["Toggle Model Mask"] = "Переключить маску модели";
L["Show Color Sliders"] = "Показать цветные ползунки";
L["Show Color Presets"] = "Показать цветовые пресеты";
L["Keep Druid Form"] = "Удерживайте "..NARCI_MODIFIER_ALT.." чтобы сохранить форму друида"
L["Race Change Tooltip"] = "Переход к другой игровой расе";
L["Sex Change Tooltip"] = "Сменить пол";

--Spell Visual Browser--
L["Visuals"] = "Визуал";
L["Visual ID"] = "Визуал ID";
L["Animation ID Abbre"] = "Аним. ID";
L["Category"] = "Категория";
L["Sub-category"] = "Под-Категория";
L["My Favorites"] = "Избранные";
L["Reset Visual Tooltip"] = "Удалить примененные визуальные эффекты";
L["Remove Visual Tooltip"] = "ЛКМ: Удаление выбранного визуального элемента\nЗатяжное нажатие: Удалите все примененные визуальные эффекты";
L["Apply"] = "Применить";
L["Applied"] = "Применены";   --Viusals that were "Applied" to the model
L["Remove"] = "Удалить";
L["Rename"] = "Переименовать";
L["Refresh Model"] = "Обновить Модель";
L["Toggle Browser"] = "Переключить заклинание визуального браузера";
L["Next And Previous"] = "ЛКМ: Перейти к следующему\nПКМ: Перейти к предыдущем";
L["New Favorite"] = "Новое в избранном";
L["Favorites Add"] = "Добавить в избранное";
L["Favorites Remove"] = "Удалить из избранного";
L["Auto-play"] = "Воспроиз.";   --Auto-play suggested animation
L["Auto-play Tooltip"] = "Автовоспроизведение анимации \n привязаного к выбранному визуалу.";
L["Delete Entry Plural"] = "Удалить запись %s";
L["Delete Entry Singular"] = "Буду удалять запись %s";
L["History Panel Note"] = "Примененные визуальные эффекты";
L["Return"] = "Вернуться";
L["Close"] = "Закрыть";

--Dressing Room--
L["Favorited"] = "Избранное";
L["Unfavorited"] = "Удалить из избранного";
L["Item List"] = "Список предметов";
L["Use Target Model"] = "Использовать модель цели";
L["Use Your Model"] = "Используйте вашу модель";
L["Cannot Inspect Target"] = "Невозможно проверить цель"
L["External Link"] = "Внешняя Ссылка";
L["Add to MogIt Wishlist"] = "Добавить в список желаний MogIt";

--NPC Browser--
L["NPC Browser"] = "Выбор НПС";
L["NPC Browser Tooltip"] = "Выбрать персонажа из списка.";
L["Search for NPC"] = "Поиск НПС";
L["Name or ID"] = "Имя или ID";
L["NPC Has Weapons"] = "Имеет собственное оружие";
L["Retrieving NPC Info"] = "Получение информации о НПС";
L["Loading Database"] = "Загрузка Базы Данных...\nВаш экран зависнет на несколько секунд.";
L["Other Last Name Format"] = "Другой "..NARCI_COLOR_GREY_70.."%s(s)|r:\n";
L["Too Many Matches Format"] = "\nБолее %s соответствует.";

--Solving Lower-case or Abbreviation Issue--
NARCI_STAT_STRENGTH = SPEC_FRAME_PRIMARY_STAT_STRENGTH;
NARCI_STAT_AGILITY = SPEC_FRAME_PRIMARY_STAT_AGILITY;
NARCI_STAT_INTELLECT = SPEC_FRAME_PRIMARY_STAT_INTELLECT;
NARCI_CRITICAL_STRIKE = STAT_CRITICAL_STRIKE;


--Equipment Comparison--
NARCI_AZERITE_POWERS = "Сила Азерита";
L["Gem Tooltip Format1"] = "%s и %s";
L["Gem Tooltip Format2"] = "%s, %s и %s больше...";

--Equipment Set Manager
L["Equipped Item Level Format"] = "Экипировано %s";
L["Equipped Item Level Tooltip"] = "Средний уровень предметов вашего надетого снаряжения.";
L["Equipment Manager"] = EQUIPMENT_MANAGER;
L["Toggle Equipment Set Manager"] = "ЛКМ, чтобы переключить диспетчер комплектов снаряжения.";
L["Duplicated Set"] = "Дублированный Набор";
L["Low Item Level"] = "Низкий уровень предмета";
L["1 Missing Item"] = "1 недостающий предмет";
L["n Missing Items"] = "%s недостающие предметы";
L["Update Items"] = "Обновление Предметов";
L["Don't Update Items"] = "Не обновляйте предметы";
L["Update Talents"] = "Обновление Талантов";
L["Don't Update Talents"] = "Не обновляйте таланты";
L["Old Icon"] = "Старая Иконка";
NARCI_ICON_SELECTOR = "Переключатель Иконок";
NARCI_DELETE_SET_WITH_LONG_CLICK = "Удалить Набор\n|cff808080(нажмите и удерживайте кнопку)|r";

--Corruption System
L["Corruption System"] = "Порча";
L["Eye Color"] = "Цвет Глаза";
L["Blizzard UI"] = "Интерфейс Blizzard";
L["Corruption Bar"] = "Ячейка Порчи";
L["Corruption Bar Description"] = "Включите панель порчи рядом с панелью персонажа.";
L["Corruption Debuff Tooltip"] = "Всплывающая Подсказка Дебаффа";
L["Corruption Debuff Tooltip Description"] = "Замените всплывающую подсказку негативных эффектов по умолчанию на ее числовые аналоги.";
L["No Corrupted Item"] = "Порченная экипировка не одета.";
L["Total Corruption Format"] = CORRUPTION_TOOLTIP_LINE.." - "..CORRUPTION_RESISTANCE_TOOLTIP_LINE.." = ".."%s";

L["Crit Gained"] = CRIT_ABBR.." Приобрел";
L["Haste Gained"] = STAT_HASTE.." Приобрел";
L["Mastery Gained"] = STAT_MASTERY.." Приобрел";
L["Versatility Gained"] = STAT_VERSATILITY.." Приобрел";

L["Proc Crit"] = "Прок "..CRIT_ABBR;
L["Proc Haste"] = "Прок "..STAT_HASTE;
L["Proc Mastery"] = "Прок "..STAT_MASTERY;
L["Proc Versatility"] =  "Прок "..STAT_VERSATILITY;

L["Critical Damage"] = CRIT_ABBR.."DMG";

L["Corruption Effect Format1"] = "Уменьшение скорости на |cffffffff%s%%|r";
L["Corruption Effect Format2"] = "|cffffffff%s|r начальный урон\n|cffffffff%s ярдов|r радиус";
L["Corruption Effect Format3"] = "|cffffffff%s|r повреждение\n|cffffffff%s%%|r вашего HP";
L["Corruption Effect Format4"] = "Поражение потусторонней тварью накладывает другие дебаффы";
L["Corruption Effect Format5"] = "|cffffffff%s%%|r Урон/исцеление пропорционально уровню порчи.";

--Tutorial--
L["Alert"] = "Предупреждение";
L["Race Change"] = "Изменение Расы/Пола";
L["Race Change Line1"] = "Вы можете снова изменить свою расу и пол. Но есть некоторые ограничения:\n1. Ваше оружие исчезнет.\n2. Визуальные эффекты заклинаний больше не могут быть удалены.\n3. Он не работает на других игроках или НПС.";
L["Guide Spell Headline"] = "Попробуйте или примените";
L["Guide Spell Criteria1"] = "ЛКМ, чтобы попробовать";
L["Guide Spell Criteria2"] = "ПКМ, чтобы ПРИМЕНИТЬ";
L["Guide Spell Line1"] = "Большинство визуальных эффектов заклинаний, которые вы добавляете, нажимая левую кнопку, исчезнут за считанные секунды, в то время как те, которые вы добавляете, нажимая правую кнопку, не исчезнут.\n\nТеперь перейдите к записи, затем:";
L["Guide Spell Choose Category"] = "Вы можете добавить визуальные эффекты заклинаний в свою модель. Выберите любую категорию, которая вам нравится. Затем выберите подкатегорию.";
L["Guide History Headline"] = "Панель Истории";
L["Guide History Line1"] = "Здесь можно сохранить не более 5 недавно примененных визуальных элементов. Вы можете выбрать один из них и удалить его, нажав кнопку Удалить в правом углу.";
L["Guide Refresh Line1"] = "Используйте эту кнопку, чтобы удалить все неприменимые визуальные эффекты заклинаний. Те, которые были в панели истории, будут применены.";
L["Guide Input Headline"] = "Ручной ввод";
L["Guide Input Line1"] = "Вы также можете ввести SpellVisualKitID самостоятельно. По состоянию на 8.3, его кап составляет около 124,000.\nВращайте колесо мыши, чтобы попробовать следующий/предыдущий ID.\nОчень немногие ID могут привести к сбою игры.";
L["Guide Equipment Manager Line1"] = "Двойной щелчок: использовать набор\nПКМ: изменить набор.\n\nПредыдущая функция этой кнопки была перемещена в Настройки.";
L["Guide Model Control Headline"] = "Модель Управления";
L["Guide Model Control Line1"] = format("Эта модель имеет те же действия мыши, которые вы используете в гардеробной, плюс:\n\n1.Удерживайте %s и левую кнопку: Поверните модель вокруг оси Y.\n2.Удерживайте %s и правую кнопку: выполните увеличение.", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
L["Guide Minimap Button Headline"] = "Кнопка на Миникарте";
L["Guide Minimap Button Line1"] = "Кнопка Narcissus на миникарте теперь может быть обработана другими аддонами.\nВы можете изменить этот параметр в панели настроек. Это может потребовать перезагрузки интерфейса."
L["Guide NPC Entrance Line1"] = "Доступ к этой новой функции находится здесь."
L["Guide NPC Browser Line1"] = "Известные НПС перечислены в каталоге ниже.\nВы также можете искать любых существ по имени или по ID.\nОбратите внимание, что при первом использовании функции поиска это может занять несколько секунд для построения таблицы поиска, и ваш экран также может зависнуть.\nВы можете отменить \"Загрузка по требованию\" в панели настроек, чтобы база данных была создана сразу после входа в систему.";

--Splash--
NARCI_SPELL_VISUALS = "Визуал. Эффекты Заклинаний";
NARCI_PATCH_NOTES = "v1.0.7 Описание Патча";
NARCI_SPLASH_CLOSE_AND_CONTINUE = "Закройте это окно и продолжайте";
NARCI_SPLASH_SOUNDS_GREAT_BYE = "Звучит здорово. Увидимся!";
NARCI_TRY_IT_NOW = "Нажмите здесь, чтобы включить...";
NARCI_DISABLE_IT_NOW = "Нажмите здесь, чтобы отключить...";
    --Patch-specific
    NARCI_DRESSING_ROOM_ENABLED_BY_DEFAULT = NARCI_COLOR_GREEN_MILD.."Включенный по умолчанию.|r "..NARCI_DISABLE_IT_NOW;
    NARCI_DRESSING_ROOM_DISABLED = NARCI_COLOR_RED_MILD.. "Отключено.|r Требуется перезагрузка интерфейса. Вы можете включить его через Настройки - Расширения.";
    NARCI_CAMERA_SAFE_MODE_ENABLED_BY_DEFAULT = NARCI_COLOR_GREEN_MILD.."Включено по умолчанию, потому что вы не используете аддон DynamicCam.|r\n"..NARCI_DISABLE_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_DISABLED_BY_DEFAULT = NARCI_COLOR_RED_MILD.."По умолчанию отключено, потому что вы используете DynamicCam.|r\n"..NARCI_TRY_IT_NOW;
    NARCI_CAMERA_SAFE_MODE_ENABLED = NARCI_COLOR_GREEN_MILD.."Включено.|r Вы можете отключить его через Настройки - Камера.";
    NARCI_CAMERA_SAFE_MODE_DISABLED = NARCI_COLOR_RED_MILD.."Отключено.|r Вы можете включить его через Настройки - Камера.";
    --
NARCI_SHOW_DETAILS = "+ Показать детали...";
NARCI_SPLASH_HEADER3 = "Разное";
NARCI_SPLASH_MESSAGE0 = "|cffd9cdb41. Теперь вы можете применять специальные визуальные эффекты к вашей сцене.|r\nВы можете накладывать заклинания, гаджеты на актеров и даже контролировать погоду. Доступ к этой функции в панели управления моделями."
NARCI_SPLASH_MESSAGE1 = format("|cffd9cdb42. Переключать модели и увеличивать их.|r\nВы можете удерживать %s и левую кнопку, чтобы повернуть модель вокруг оси Y. Или удерживайте %s и правую кнопку, чтобы выполнить увеличение.", NARCI_MODIFIER_ALT, NARCI_MODIFIER_ALT);
NARCI_SPLASH_MESSAGE2 = "|cffd9cdb4Вы можете открыть его, нажав на шестиугольную кнопку в правом верхнем углу (где показан ваш максимальный уровень предметов).";
NARCI_SPLASH_MESSAGE3 = "|cffd9cdb41.Экран АФК будет автоматически закрыт при движении или входе в бой.\n2. Улучшенная гардеробная доступна.|r";

L["Show Whats New"] = "Показать что нового";
NARCI_SPLASH_WHATS_NEW_FORMAT = "Что нового в Narcissus %s";
NARCI_SPLASH_HEADER1 = "Браузер НПС";
NARCI_SPLASH_HEADER2 = "Разное";
NARCI_SPLASH_INTERACTIVE_TEXT1 = NARCI_COLOR_GREY_85.."Групповое фото|r\n- Вы можете добавить любого НПС в вашу сцену независимо от вашего текущего местоположения.\n- Выберите из списка или совершите поиск по имени или ID.\n\n".. NARCI_COLOR_GREY_85.."Подсказка Существа (Необязательно)|r\n- Находите существ с такой же фамилией при наведении указателя мыши на НПС.\n- Показать переведенные имена НПС на его именной табличке или в всплывающей подсказке.";
NARCI_SPLASH_INTERACTIVE_TEXT2 = NARCI_COLOR_GREY_85.."";
NARCI_SPLASH_INTERACTIVE_TEXT3 = NARCI_COLOR_GREY_85.."АФК Экран|r\nФункция автоматической подставки стала необязательной.\n\n" ..NARCI_COLOR_GREY_85.."Качество скриншота|r\n- Больше не отменяет качество до 10\n- На панель настроек был добавлен ползунок качества.\n\n" ..NARCI_COLOR_GREY_85.."Модуль Порчи|r\n- Теперь совместимо с всплывающей подсказкой.\n- Урон от Глаза Порчи был обновлен до ( 0.5*порчи + 15 ) * HP";

--Project Details--
NARCI_ALL_PROJECTS = "Все проекты";
NARCI_PROJECT_DETAILS = "|cFFFFD100Разработчик: Peterodox\nДата выхода: 26 Апреля, 2020|r\n\nСпасибо, что используете этот аддон! Если у вас есть какие-либо вопросы, предложения, идеи, пожалуйста, оставьте комментарий на странице curseforge или свяжитесь со мной по адресу...";
NARCI_PROJECT_AAA_TITLE = "|cff008affA|cff0d8ef2z|cff1a92e5e|cff2696d9r|cff339acco|cff409ebft|cff4da1b2h |cff59a5a6A|cff66a999d|cff73ad8cv|cff7fb180e|cff8cb573n|cff99b966t|cffa6bd59u|cffb2c14dr|cffbfc440e |cffccc833A|cffd9cc26l|cffe5d01ab|cfff2d40du|cffffd800m";
NARCI_PROJECT_AAA_SUMMARY = "Исследуйте достопримечательности и собирайте знания и фотографии со всего Азерота.|cff636363";
NARCI_PROJECT_NARCISSUS_SUMMARY = "Захватывающая панель персонажа и ваш лучший скриншот.";



-----------------------------------------------------
--
L["Heritage Armor"] = "Традиционные Доспехи";
ITEMSOURCE_SECRETFINDING = "Секретная";

NARCI_ALIAS_USE_ALIAS = "Псевдони́м";
NARCI_ALIAS_USE_PLAYER_NAME = CALENDAR_PLAYER_NAME;

L["Minimap Tooltip Middle Button"] = "|CFFFF1000Middle button |cffffffffСбросить камеру";

NARCI_STAT_STRENGTH = "Сила";
NARCI_STAT_AGILITY = "Ловкость";
NARCI_STAT_INTELLECT = "Интеллект";

--Model Control--
NARCI_GROUP_PHOTO = "Групповое Фото";
NARCI_GROUP_PHOTO_NOTIFICATION = "Пожалуйста, выберите игрока.";

--NPC Browser--
NARCI_NPC_BROWSER_TITLE_LEVEL = "%?.*";      --Level ?? --Use this to check if the second line of the tooltip is NPC's title or unit type 