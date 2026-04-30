-- Populate DF_AllLocales["ruRU"] so Core.lua's ADDON_LOADED handler
-- can apply this locale's translations as an overlay if the user's
-- languageOverride selects it. No AceLocale interaction here — the
-- overlay step happens once the SavedVariable is actually populated,
-- which is only guaranteed at ADDON_LOADED time (not file-scope).
DF_AllLocales = DF_AllLocales or {}
DF_AllLocales.ruRU = {}
local L = DF_AllLocales.ruRU
L["    Show Frame Glow"] = "    Свечение рамки"
L["    Show ZZZ Icon"] = "    Иконка отдыха (Zzz)"
L["— click to edit"] = "- нажмите для изменения"
L[" indicator"] = " индикатор"
L[" indicators"] = " индикаторы"
L["⚠ Note: Click-through icons will not show tooltips."] = "⚠ Примечание: на сквозных иконках подсказки не отображаются."
L["\"%s\" will be overwritten."] = "\"%s\" будет перезаписан."
L["%d - %d players"] = "%d - %d игроков"
L["%d binds"] = "Привязок: %d"
L["%d blacklisted"] = "%d в черном списке"
L["%d override"] = "%d переопределение"
L["%d overrides"] = "%d переопределений"
L["%d players"] = "%d игроков"
L["%d-%d players"] = "%d-%d игроков"
L["%s (Copy)"] = "%s (Копия)"
L["%s (currently %s)"] = "%s (сейчас %s)"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = "Обнаружен %s. Какой аддон для каста по клику вы хотите использовать?"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = "Обнаружен %s. Какой аддон для каста по клику вы хотите использовать?"
L["%s settings reset to defaults."] = "Настройки %s сброшены по умолчанию."
L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"] = "%sОбщие: 80%s %s- Значение совпадает с общим, переопределение не сохранено%s"
L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"] = "%sИзменено%s %s- Значение отличается от общего. Нажмите%s %sсброс%s, %sчтобы вернуть.%s"
L["(none)"] = "(нет)"
L["(offline)"] = "(не в сети)"
L["(skipped)"] = "(пропущено)"
L["[Linked]"] = "[Связано]"
L["[Override]"] = "[Переопределение]"
L["[Unassigned]"] = "[Не назначено]"
L["+ Add"] = "+ Добавить"
L["+ Add aura"] = "+ Добавить ауру"
L["+ Add Indicator"] = "+ Добавить индикатор"
L["+ Add Layout"] = "+ Добавить макет"
L["+ Add Option"] = "+ Добавить опцию"
L["+ Add Step"] = "+ Добавить шаг"
L["+ Add Trigger"] = "+ Добавить триггер"
L["+ Create Group"] = "+ Создать группу"
L["+ New"] = "+ Новый"
L["+ New Wizard"] = "+ Новый мастер настройки"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = "Возникли проблемы с отображением определенных баффов или дебаффов? • Этот мастер-настройки поможет вам выбрать правильные настройки ауры."
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = "Возникли проблемы с отображением определенных баффов или дебаффов? • Этот мастер-настройки поможет вам выбрать правильные настройки ауры."
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• Текст имени
• Текст здоровья
• Текст статуса (Мертв/Не в сети)
• Стаки и время бафов
• Стаки и время дебаффов
• Текст фрейма питомца
• Время произнесения заклинания в цель
• Время действия защитных иконок
• Текст иконок статуса (Воскр., Призыв и т.д.)
• Метки групп (Рейд)]=]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• Текст имени
• Текст здоровья
• Текст статуса (Мертв/Оффлайн)
• Стаки и время бафов
• Стаки и время дебаффов
• Текст фрейма питомца
• Время произнесения заклинания в цель
• Время действия защитных иконок
• Текст иконок статуса (Воскр., Призыв и т.д.)
• Метки групп (Рейд)]=]
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• Рекомендуемые настройки подходят большинству игроков
• Ручной режим позволяет точно настроить каждый фильтр]=]
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• Рекомендуемые настройки подходят большинству игроков
• Ручной режим позволяет точно настроить каждый фильтр]=]
L["0=Auto, Higher=On top of more elements"] = "0=Авто, чем выше - тем больше элементов перекрывается"
L["1"] = "1"
L["1 = High"] = "1 = Высокий"
L["1. Open ElvUI config with %s/ec%s"] = "1. Откройте настройки ElvUI через %s/ec%s"
L["10 = Low"] = "10 = Низкий"
L["2. Go to %sUnitFrames%s (left sidebar)"] = "2. Перейдите в %sРамки юнитов%s (меню слева)"
L["20 players (fixed)"] = "20 игроков (фикс.)"
L["3. Click %sGeneral%s at the top"] = "3. Нажмите %sОбщие%s сверху"
L["4. Scroll down to %sDisabled Blizzard Frames%s"] = "4. Прокрутите вниз до %sОтключенные рамки Blizzard%s"
L["5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"] = "5. В разделе %sГруппы%s снимите галочки с %sГруппа%s и %sРейд%s"
L["6. Click the reload button when prompted"] = "6. Нажмите кнопку перезагрузки при появлении запроса"
L["A layout with this name already exists in %s"] = "Макет с таким названием уже существует в %s"
L["a placed indicator to remove it from the frame"] = "размещенный индикатор, чтобы удалить его из рамки"
L["a placed indicator to reposition it on the frame"] = "размещенный индикатор, чтобы изменить его положение"
L["A profile with this name already exists"] = "Профиль с таким названием уже существует"
L["A to Z"] = "От А до Я"
L["Abbreviate (K/M)"] = "Сокращать (K/M)"
L["Above Health Bar"] = "Над полосой здоровья"
L["Above Owner"] = "Над владельцем"
L["Above Party"] = "Над группой"
L["Above Raid"] = "Над рейдом"
L["Absorb Shield"] = "Щит поглощения"
L["Absorbs"] = "Поглощение"
L["Actions"] = "Действия"
L["Active"] = "Активен"
L["Active Bindings"] = "Активные привязки"
L["Active Bindings (%d)"] = "Активные привязки (%d)"
L["ACTIVE INDICATORS"] = "АКТИВНЫЕ ИНДИКАТОРЫ"
L["Active:"] = "Активно:"
L["Actually, disable it"] = "На самом деле, отключить"
L["Add"] = "Добавить"
L["Add #showtooltip"] = "Добавить #showtooltip"
L["Add /stopcasting"] = "Добавить /stopcasting"
L["Add Layout"] = "Добавить макет"
L["Add New Binding"] = "Добавить новую привязку"
L["Add Offline Player"] = "Добавить игрока не в сети"
L[ [=[Add players from the roster
or use quick add buttons]=] ] = "Добавьте игроков из списка состава или используйте кнопки быстрого добавления"
L[ [=[Add players from the roster
or use quick add buttons]=] ] = "Добавьте игроков из списка состава или используйте кнопки быстрого добавления"
L["Additive (ADD)"] = "Аддитивное (ADD)"
L["Advanced"] = "Расширенные"
L["Affected Elements"] = "Затронутые элементы"
L["AFK"] = "АФК"
L["AFK Icon"] = "Иконка АФК"
L["Aggro Highlight"] = "Подсветка угрозы"
L["Aggro Settings"] = "Настройки угрозы"
L["Alert if anyone is missing the buff"] = "Оповещать, если баф отсутствует на ком-либо"
L["Alert only if nobody has the buff"] = "Оповещать, только если бафа нет ни на ком"
L["Alert When Expiring"] = "Оповещать об истечении"
L["All"] = "Все"
L["ALL (AND)"] = "ВСЕ (И)"
L["All Buffs"] = "Все бафы"
L["All Debuffs"] = "Все дебаффы"
L["All Dispellable"] = "Все рассеиваемые"
L["All players in a unified grid. Sorting applies raid-wide."] = "Все игроки в единой сетке. Сортировка применяется ко всему рейду."
L["ALL triggers must be active"] = "ДОЛЖНЫ быть активны ВСЕ триггеры"
L["Alpha"] = "Прозрачность"
L["Alphabetical"] = "По алфавиту"
L["Alphabetical (within class/role)"] = "По алфавиту (внутри класса/роли)"
L["Always"] = "Всегда"
L["Always First"] = "Всегда первый"
L["Always Green"] = "Всегда зеленый"
L["Always Last"] = "Всегда последний"
L["an indicator on the frame to expand its settings"] = "индикатор на рамке, чтобы развернуть его настройки"
L["Anchor"] = "Привязка"
L["Anchor Point"] = "Точка привязки"
L["Anchor Position"] = "Позиция привязки"
L["Anchor To"] = "Привязать к"
L["Animated Border"] = "Анимированная рамка"
L["ANY (OR)"] = "ЛЮБОЙ (ИЛИ)"
L["Any Target"] = "Любая цель"
L["ANY trigger activates the effect"] = "ЛЮБОЙ триггер активирует эффект"
L["Appearance"] = "Внешний вид"
L["Apply"] = "Применить"
L["Apply to All"] = "Применить ко всем"
L["Apply to Frames:"] = "Применить к рамкам:"
L["Arcane Intellect (Mage)"] = "Чародейский интеллект (Маг)"
L["are secret-tracked"] = "отслеживаются скрыто"
L["Are you sure?"] = "Вы уверены?"
L["Arena"] = "Арена"
L["Arena header will show using raid1-5 unit IDs"] = "Заголовок арены будет отображаться с использованием Unit ID raid1-5"
L["Arena mode %sDISABLED%s"] = "Режим арены %sОТКЛЮЧЕН%s"
L["Arena mode %sENABLED%s for testing"] = "Режим арены %sВКЛЮЧЕН%s для тестирования"
L["Arrange Groups In"] = "Расположить группы в"
L["Arrange In"] = "Расположить в"
L["Arrange Players In"] = "Расположить игроков в"
L["Attach the handle to the container, the first visible unit, or the last visible unit."] = "Прикрепите якорь к контейнеру, первому или последнему видимому юниту."
L["Attach To"] = "Прикрепить к"
L["Attached + Overflow"] = "Прикреплено + Переполнение"
L["Attached to Health"] = "Привязано к полосе здоровья"
L["Attached to Owner"] = "Привязано к владельцу"
L["Aura Blacklist"] = "Черный список аур"
L["Aura Data Source"] = "Источник данных аур"
L["Aura Designer"] = "Конструктор аур"
L["Aura Designer Alpha"] = "Конструктор аур (Альфа)"
L["Aura Designer is active alongside Buffs."] = "Конструктор аур активен вместе с бафами."
L["Aura Designer is disabled"] = "Конструктор аур отключен"
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = "Конструктор аур поддерживает специализации лекарей и «Насыщателей» (пробудителей). Вы можете вручную выбрать специализацию в выпадающем списке выше, чтобы заранее настроить индикаторы."
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = "Конструктор аур поддерживает специализации лекарей и «Насыщателей» (пробудителей). Вы можете вручную выбрать специализацию в выпадающем списке выше, чтобы заранее настроить индикаторы."
L["Aura Filter Setup"] = "Настройка фильтров аур"
L["Aura Filters"] = "Фильтры аур"
L["Auras"] = "Ауры"
L["Auras Alpha"] = "Прозрачность аур"
L["Auto (%s)"] = "Авто (%s)"
L["Auto (detect class)"] = "Авто (опред. класс)"
L["Auto (detect spec)"] = "Авто (опред. специализацию)"
L["Auto (detect)"] = "Авто (определение)"
L["Auto (Spec Default)"] = "Авто (спец. по умолчанию)"
L["Auto Layouts"] = "Авто-макеты"
L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."] = "Авто-макеты - функция только для рейдов. Переключитесь в режим рейда, чтобы настроить автоматическую смену макета в зависимости от типа контента и размера группы."
L["Auto Layouts module not loaded."] = "Модуль авто-макетов не загружен."
L["Auto-add DPS"] = "Авто-добавление ДД"
L["Auto-add Healers"] = "Авто-добавление лекарей"
L["Auto-add Tanks"] = "Авто-добавление танков"
L["Auto-create disabled"] = "Авто-создание отключено"
L["Auto-Create Profiles"] = "Авто-создание профилей"
L["Auto-create profiles for loadouts"] = "Создавать профили для наборов талантов"
L["Auto-detect (your class's buff)"] = "Авто-определение (баф вашего класса)"
L["Auto-Fit Border to Frame Size"] = "Подгонять рамку под размер фрейма"
L["Automatically add players by role when they join your group."] = "Автоматически добавлять игроков по ролям, когда они вступают в группу."
L["Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."] = "Автоматически обнаруживает дебаффы, которые вы можете рассеять (фильтр RAID_PLAYER_DISPELLABLE). Настройте это на странице «Рассеивание»."
L["Auto-Populate"] = "Авто-заполнение"
L["Auto-profile \"%s\" activated (%s, %d players)"] = "Авто-профиль \"%s\" активирован (%s, %d игроков)"
L["Auto-profile deactivated (profile deleted)"] = "Авто-профиль деактивирован (профиль удален)"
L["Auto-profile deactivated, using global settings"] = "Авто-профиль деактивирован, используются общие настройки"
L["Auto-Switch by Spec"] = "Авто-смена по специализации"
L["Auto-switched to profile: %s"] = "Автоматическое переключение на профиль: %s"
L["Auto-switching disabled"] = "Авто-переключение отключено"
L["Available Profiles"] = "Доступные профили"
L["A-Z"] = "А-Я"
L["Back"] = "Назад"
L["Back to List"] = "Вернуться к списку"
L["Background"] = "Фон"
L["Background Alpha"] = "Прозрачность фона"
L["Background Color"] = "Цвет фона"
L["Background Fill"] = "Заполнение фона"
L["Background Mode"] = "Режим фона"
L["Background Only"] = "Только фон"
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = "Только фон: Обычный сплошной фон. Только недостающее здоровье: Цветная полоса в месте потери здоровья. Оба варианта: Отображать и то, и другое"
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = "Только фон: Обычный сплошной фон. Только недостающее здоровье: Цветная полоса в месте потери здоровья. Оба варианта: Отображать и то, и другое"
L["Background Texture"] = "Текстура фона"
L["Bar"] = "Полоса"
L["Bar Color"] = "Цвет полосы"
L["Bar Texture"] = "Текстура полосы"
L["Bars"] = "Полосы"
L["Battle Shout (Warrior)"] = "Боевой крик (Воин)"
L["Battlegrounds"] = "Поля боя"
L["Before You Enable"] = "Прежде чем включить"
L["Below Health Bar"] = "Под полосой здоровья"
L["Below Owner"] = "Под владельцем"
L["Below Party"] = "Под группой"
L["Below Raid"] = "Под рейдом"
L["Big Defensives"] = "Сильные защитные способности"
L["Bind Action"] = "Назначить действие"
L["Bind Item"] = "Назначить предмет"
L["Bind Spell"] = "Назначить заклинание"
L["Binding Tooltips"] = "Подсказки назначений"
L["Binding:"] = "Назначение:"
L["Bindings only cast their assigned spell"] = "Назначения применяют только выбранное заклинание"
L["BINDS"] = "КЛАВИШИ"
L["Bleed / Enrage"] = "Кровотечение / Иступление"
L["Blend %"] = "% смешивания"
L["Blend Mode"] = "Режим смешивания"
L["Blessing of the Bronze (Evoker)"] = "Дар бронзовых драконов (Пробудитель)"
L["Blizzard"] = "Blizzard"
L["Blizzard (Default)"] = "Blizzard (По умолчанию)"
L["Blizzard Click-Casting"] = "Назначение клавиш Blizzard"
L["Blizzard Frame Settings"] = "Настройки фреймов Blizzard"
L["Blizzard Frames"] = "Фреймы Blizzard"
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[Blizzard: • Дублирует баффы/дебаффы из стандартных фреймов Blizzard • Требует корректной настройки параметров рейда в Blizzard • Чуть сильнее нагружает систему в больших группах
Прямой API: • Позволяет полностью контролировать отображение на ваших фреймах • Некоторые фильтры могут пропускать определенные баффы/дебаффы • Другие могут показывать лишние эффекты • Можно тонко настроить для достижения лучших результатов]=]
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[Blizzard: • Дублирует баффы/дебаффы из стандартных фреймов Blizzard • Требует корректной настройки параметров рейда в Blizzard • Чуть сильнее нагружает систему в больших группах
Прямой API: • Позволяет полностью контролировать отображение на ваших фреймах • Некоторые фильтры могут пропускать определенные баффы/дебаффы • Другие могут показывать лишние эффекты • Можно тонко настроить для достижения лучших результатов]=]
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = "Встроенное «назначение клавиш» Blizzard может конфликтовать с настройками DandersFrames. Рекомендуется очистить стандартные привязки Blizzard для фреймов, на которых вы используете DandersFrames."
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = "Встроенное «назначение клавиш» Blizzard может конфликтовать с настройками DandersFrames. Рекомендуется очистить стандартные привязки Blizzard для фреймов, на которых вы используете DandersFrames."
L["Border"] = "Граница"
L["Border Color"] = "Цвет границы"
L["Border Inset"] = "Отступ границы"
L["Border Mode:"] = "Режим границы:"
L["Border Opacity"] = "Непрозрачность границы"
L["Border Scale"] = "Масштаб границы"
L["Border Size"] = "Размер границы"
L["Border Thickness"] = "Толщина границы"
L["Boss Debuffs"] = "Дебаффы боссов"
L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."] = "Дебаффы боссов (Скрытые ауры) - это особые эффекты, которые Blizzard скрывает от аддонов."
L["Both"] = "Оба"
L["Bottom"] = "Внизу"
L["Bottom Edge"] = "Нижний край"
L["Bottom Left"] = "Внизу слева"
L["Bottom Right"] = "Внизу справа"
L["Bottom to Top"] = "Снизу вверх"
L["Bounce"] = "Отскок"
L["Bound: %s"] = "Назначено: %s"
L["Branch"] = "Ветка"
L["Branching Rules"] = "Условия ветвления"
L["BUFF BLACKLIST"] = "СПИСОК ИГНОРИРУЕМЫХ БАФФОВ"
L["Buff Filters"] = "Фильтр баффов"
L["Buff Icon"] = "Иконка баффа"
L["Buff Icons"] = "Иконки баффов"
L["Buff Icons Click-Through"] = "Клик сквозь иконки баффов"
L["Buff Tooltips"] = "Подсказка баффов"
L["Buffs"] = "Баффы"
L["Buffs are disabled. Aura Designer is managing your auras."] = "Баффы отключены. Управление аурами передано в конструктор аур."
L["Buffs flagged by Blizzard to show up on raid frames."] = "Баффы, отмеченные Blizzard для отображения на рейдовых фреймах."
L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."] = "Баффы, отображаемые на рейдовых фреймах в бою (например, ваши HoT-эффекты)."
L["Buffs that can be right-click cancelled."] = "Баффы, которые можно отменить нажатием ПКМ."
L["Buffs that cannot be cancelled by the player."] = "Баффы, которые игрок не может отменить."
L["Buffs to Check (Manual Mode)"] = "Проверка баффов (ручной режим)"
L["Building: "] = "Сборка: "
L["Built-in Wizards"] = "Встроенные помощники"
L["By Health %"] = "По % здоровья"
L["Cancel"] = "Отмена"
L["Cancel Fade on Dispellable Debuff"] = "Отменять 'Уход в тень' при дебаффе, который можно снять"
L["Cancelable"] = "Можно отменить"
L["Cannot delete Default profile."] = "Нельзя удалить профиль по умолчанию."
L["Cannot disable test mode while frames are unlocked. Lock frames first."] = "Нельзя отключить тестовый режим, пока рамки разблокированы. Сначала закрепите рамки."
L["Cannot Edit"] = "Редактирование невозможно"
L["Cannot enter test mode during combat."] = "Нельзя войти в тестовый режим во время боя."
L["Cannot toggle arena mode during combat"] = "Нельзя переключить режим арены во время боя"
L["Cannot toggle test mode during combat."] = "Нельзя переключить тестовый режим во время боя."
L["Cannot unlock - container doesn't exist!"] = "Не удалось разблокировать - контейнер не существует!"
L["Cannot unlock - failed to create mover frame!"] = "Не удалось разблокировать - ошибка создания рамки перемещения!"
L["Cannot unlock frames during combat."] = "Нельзя разблокировать рамки во время боя."
L["Cannot use this action in combat."] = "Это действие недоступно в бою."
L["Cast on DOWN"] = "Применять при нажатии"
L["Categories"] = "Категории"
L["Category Filters"] = "Фильтры категорий"
L["CC effects like stuns, roots, and incapacitates."] = "Эффекты контроля (CC), такие как оглушение, корни и паралич."
L["Center"] = "Центр"
L["Center (Horizontal)"] = "Центр (горизонтально)"
L["Center (Vertical)"] = "Центр (вертикально)"
L["Center of Group"] = "Центр группы"
L["Character"] = "Персонаж"
L["Character Import"] = "Импорт персонажа"
L["Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."] = "Выберите, как DandersFrames считывает данные аур для баффов, дебаффов, защитных умений и обнаружения диспела."
L["Choose Icon"] = "Выбрать иконку"
L["Choose whether to enable the frame border overlay."] = "Включить отображение границ фреймов."
L["Choose which groups to display."] = "Выберите, какие группы отображать."
L["Clamp Mode"] = "Режим фиксации"
L["Class"] = "Класс"
L["Class Color"] = "Цвет класса"
L["Class Color Alpha"] = "Прозрачность цвета класса"
L["Class Colors"] = "Цвета классов"
L["Class Filter"] = "Фильтр классов"
L["Class Power"] = "Ресурс класса"
L["Class Power Pips"] = "Деления ресурса класса"
L["Class Priority"] = "Приоритет классов"
L["Clear"] = "Очистить"
L["Clear All"] = "Очистить всё"
L["Clear All Bindings"] = "Очистить все назначения клавиш"
L["Clear Blizzard Bindings"] = "Очистить назначения клавиш Blizzard"
L["Clear Log"] = "Очистить журнал"
L["Click"] = "Клик"
L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."] = "Нажмите %sИзменить настройки%s в профиле, чтобы настроить его. Вы перейдете на вкладки настроек с баннером редактирования вверху. Во время редактирования любое измененное значение будет сохранено как приоритетное только для этого профиля."
L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."] = "Нажмите %sВыйти из редактирования%s по завершении. Ваши изменения будут сохранены в профиле. Если вы вернете настройку к глобальному значению, приоритет будет автоматически удален."
L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."] = "Нажмите на образец цвета, чтобы открыть палитру. Эти настройки применяются одновременно к фреймам группы и рейда."
L["Click a setting to link it to your wizard"] = "Нажмите на настройку, чтобы привязать её к мастеру настройки"
L["Click item slot to bind"] = "Нажмите на ячейку предмета, чтобы назначить клавишу"
L["Click macro to bind"] = "Нажмите на макрос, чтобы назначить клавишу"
L["Click or drag a spell onto the frame to place it"] = "Нажмите или перетащите заклинание на фрейм, чтобы разместить его"
L["Click spell to bind"] = "Нажмите на заклинание, чтобы назначить клавишу"
L["Click to bind..."] = "Нажмите, чтобы назначить..."
L["Click to cycle through steps"] = "Нажмите, чтобы переключаться между шагами"
L["Click to edit"] = "Нажмите, чтобы изменить"
L["Click to edit range"] = "Нажмите, чтобы изменить диапазон"
L["Click to set branch target"] = "Нажмите, чтобы установить цель ветвления"
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = "Нажмите, чтобы синхронизировать настройки %s для группы и рейда. Изменения в одном режиме будут автоматически применены к другому."
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = "Нажмите, чтобы синхронизировать настройки %s для группы и рейда. Изменения в одном режиме будут автоматически применены к другому."
L["Click to toggle"] = "Нажмите, чтобы переключить"
L["Click-cast profile: %s"] = "Профиль заклинаний по клику: %s"
L["Click-Casting"] = "Заклинания по клику"
L["Click-Casting Addon Conflict"] = "Конфликт аддонов для заклинаний по клику"
L["Click-Through Icons"] = "Иконки, пропускающие клики"
L["Clip Border to Frame"] = "Ограничить границы рамкой"
L["Close"] = "Закрыть"
L["Color"] = "Цвет"
L["Color and opacity of the empty/inactive pips."] = "Цвет и прозрачность пустых/неактивных делений."
L["Color Bar by Duration"] = "Цвет полосы по длительности"
L["Color by Dispel Type"] = "Цвет по типу рассеивания"
L["Color by Time"] = "Цвет по времени"
L["Color by Time Remaining"] = "Цвет по оставшемуся времени"
L["Color Duration by Time"] = "Цвет длительности по времени"
L["Color Mode"] = "Режим цвета"
L["Color Name Text"] = "Цвет текста имени"
L["Color Picker"] = "Выбор цвета"
L["Color shown when in combat to indicate the handle is locked."] = "Цвет, отображаемый в бою, указывающий на то, что панель заблокирована."
L["Colors"] = "Цвета"
L["Column Growth"] = "Рост колонок"
L["Column Spacing"] = "Межстрочный интервал колонок"
L["Columns"] = "Колонки"
L["Columns Grow From"] = "Колонки растут от"
L["Combat"] = "Бой"
L["Combat Color"] = "Цвет в бою"
L["Combat Limitation: All groups will not update with new players that join mid-combat."] = "Ограничение боя: Состав всех групп не будет обновляться, если игроки присоединятся во время боя."
L["Combat Limitation: Your group will not update with new players that join mid-combat."] = "Ограничение боя: Состав вашей группы не будет обновляться, если игроки присоединятся во время боя."
L["Combat Mode"] = "Режим боя"
L["Combat Only"] = "Только в бою"
L["Compatible (%d)"] = "Совместимо (%d)"
L["Compatible Bindings"] = "Совместимые назначения клавиш"
L["Compatible Only"] = "Только совместимые"
L["Confirm"] = "Подтвердить"
L["Console"] = "Консоль"
L["Container"] = "Контейнер"
L["Content type filters configured in Party tab."] = "Фильтры типов контента настроены во вкладке «Группа»."
L["Content Types"] = "Типы контента"
L["Content:"] = "Контент:"
L["Controls Blizzard's debuff filtering (affects our display too)."] = "Управляет стандартной фильтрацией отрицательных эффектов Blizzard (также влияет на наше отображение)."
L["Controls how multiple defensive icons are arranged when using Direct aura mode."] = "Управляет расположением нескольких иконок защитных способностей при использовании режима аур «Напрямую»."
L["Copied %d settings from %s to %s."] = "Скопировано настроек (%d) из %s в %s."
L["Copied settings from %s to %s."] = "Настройки скопированы из %s в %s."
L["Copies these settings from %s to %s."] = "Копирует эти настройки из %s в %s."
L["Copy"] = "Копировать"
L["Copy %s Settings"] = "Копировать настройки: %s"
L["Copy %s settings to %s?"] = "Скопировать настройки %s в %s?"
L["Copy all settings between Party and Raid modes."] = "Копировать все настройки между режимами группы и рейда."
L["COPY APPEARANCE FROM"] = "СКОПИРОВАТЬ ВНЕШНИЙ ВИД ИЗ"
L["Copy Layout"] = "Копировать макет"
L["Copy Settings"] = "Копировать настройки"
L["Copy Settings to %s"] = "Копировать настройки в %s"
L["Copy the string below to share this wizard:"] = "Скопируйте строку ниже, чтобы поделиться этим мастером настройки:"
L["Copy this string to share your profile:"] = "Скопируйте эту строку, чтобы поделиться своим профилем:"
L["Copy To"] = "Копировать в"
L["Copy to Clipboard"] = "Копировать в буфер обмена"
L["Copy to Party"] = "Копировать в настройки группы"
L["Copy to Raid"] = "Копировать в настройки рейда"
L["Corners Only"] = "Только углы"
L["Create"] = "Создать"
L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."] = "Создание и управление мастерами настройки, которые помогают пользователям конфигурировать аддон. Мастерами можно делиться с другими через строки импорта/экспорта."
L["Create Custom Macro"] = "Создать свой макрос"
L["Create Empty"] = "Создать пустой"
L["Create Layout"] = "Создать макет"
L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."] = "Создавайте макеты ниже для разного количества игроков в каждом типе контента. Макеты хранят только те настройки, которые %sотличаются%s от глобальных - всё остальное наследуется автоматически."
L["Create Macro"] = "Создать макрос"
L["Create New Profile"] = "Создать новый профиль"
L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."] = "Создавайте отдельные группы фреймов, чтобы закрепить определенных игроков, например танков, целителей или ключевых участников рейда. Перетаскивайте игроков из списка группы, чтобы добавить их."
L["Created new profile: %s"] = "Создан новый профиль: %s"
L["Crowd Control"] = "Контроль (CC)"
L["Current / Max"] = "Текущее / Макс."
L["Current Health"] = "Текущее здоровье"
L["Current Profile"] = "Текущий профиль"
L["CURRENT STATUS"] = "ТЕКУЩИЙ СТАТУС"
L["Currently: Percent. Click for Seconds."] = "Сейчас: Проценты. Нажмите для переключения на секунды."
L["Currently: Seconds. Click for Percent."] = "Сейчас: Секунды. Нажмите для переключения на проценты."
L["Curse"] = "Проклятие"
L["Cursor"] = "Курсор"
L["Custom"] = "Пользовательский"
L["Custom Border"] = "Своя граница"
L["Custom buff and frame effect indicators"] = "Пользовательские индикаторы баффов и эффектов фреймов"
L["Custom Color"] = "Свой цвет"
L["Custom Dead Background"] = "Свой фон для мертвых целей"
L["Custom Dispel Colors"] = "Свои цвета рассеивания"
L["Custom Health Color"] = "Свой цвет здоровья"
L["Custom Macro"] = "Свой макрос"
L["Custom Sound Path"] = "Путь к своему звуку"
L["Custom Spell ID"] = "ID своего заклинания"
L["Customise"] = "Настроить"
L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."] = "Настройка цветов классов в DandersFrames. Изменения коснутся полос здоровья, имен, границ и других элементов с цветом класса."
L["Customize resource bar colors per power type. Shared across party and raid frames."] = "Настройка цветов полос ресурса для каждого типа энергии. Применяется к фреймам группы и рейда."
L["Cut"] = "Вырезать"
L["Cycle Next CC Profile"] = "След. профиль контроля (CC)"
L["Cycle Next Profile"] = "Следующий профиль"
L["Damage"] = "Урон"
L["DandersFrames Auto-Profile Overrides:"] = "Приоритеты авто-профилей DandersFrames:"
L["Darken Amount"] = "Степень затемнения"
L["Darken Behind Gradient"] = "Затемнение за градиентом"
L["Darken Effect"] = "Эффект затемнения"
L["Dashed Border"] = "Пунктирная граница"
L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"] = "Мертв + В бою: Воскрешение в бою (БР)"
L["Dead + Out of combat: Cast Mass Res or normal Res"] = "Мертв + Вне боя: Массовое или обычное воскрешение"
L["Dead Background Color"] = "Цвет фона мертвых целей"
L["Dead/Offline Fading"] = "Прозрачность мертвых/не в сети игроков"
L["Death Knight"] = "Рыцарь смерти"
L["DEBUFF BLACKLIST"] = "ЧЕРНЫЙ СПИСОК ДЕБАФФОВ"
L["Debuff Filters"] = "Фильтры дебаффов"
L["Debuff Icon"] = "Иконка дебаффа"
L["Debuff Icons"] = "Иконки дебаффов"
L["Debuff Icons Click-Through"] = "Иконки дебаффов, пропускающие клики"
L["Debuff Tooltips"] = "Подсказки дебаффов"
L["Debuffs"] = "Дебаффы"
L["Debuffs relevant during combat in a raid context."] = "Дебаффы, важные во время боя в рейде."
L["Debuffs relevant in a raid context."] = "Дебаффы, важные в контексте рейда."
L["Debug"] = "Отладка"
L["Debug Console"] = "Консоль отладки"
L["Debug Log Export (Filtered)"] = "Экспорт журнала отладки (с фильтром)"
L["Debug logging %s"] = "Журнал отладки: %s"
L["Debug mode %s"] = "Режим отладки: %s"
L["Debug Mode (print to chat)"] = "Режим отладки (вывод в чат)"
L["Deduplication"] = "Удаление дубликатов"
L["Default (Slot Order)"] = "По умолчанию (по порядку слотов)"
L["Default Frame Level"] = "Уровень фрейма по умолчанию"
L["Default Frame Strata"] = "Слой фрейма по умолчанию"
L["Default Icon Size"] = "Размер иконок по умолчанию"
L["Default Scale"] = "Масштаб по умолчанию"
L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."] = "Защитные эффекты от других игроков (например, Подавление боли или Жертвенное благословение)."
L["Defensive Icon"] = "Иконка защиты"
L["Defensive Icon Alpha"] = "Прозрачность иконки защиты"
L["Defensive Icon Click-Through"] = "Иконка защиты, пропускающая клики"
L["Defensive Icon Tooltips"] = "Подсказки иконок защиты"
L["Defensives"] = "Защитные способности"
L["Del"] = "Удал."
L["Delete"] = "Удалить"
L["Delete Current Profile"] = "Удалить текущий профиль"
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = "Удалить импортированный макрос '%s'? Все назначения клавиш, использующие этот макрос, будут удалены. (Оригинальный макрос WoW затронут не будет)"
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = "Удалить импортированный макрос '%s'? Все назначения клавиш, использующие этот макрос, будут удалены. (Оригинальный макрос WoW затронут не будет)"
L["Delete Layout"] = "Удалить макет"
L["Delete layout \"%s\"?"] = "Удалить макет \"%s\"?"
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = "Удалить макрос '%s'? Все назначения клавиш, использующие этот макрос, будут удалены."
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = "Удалить макрос '%s'? Все назначения клавиш, использующие этот макрос, будут удалены."
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = "Удалить профиль '%s'? Это действие нельзя отменить."
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = "Удалить профиль '%s'? Это действие нельзя отменить."
L["Delete Step"] = "Удалить шаг"
L["Deleted profile: %s"] = "Профиль удален: %s"
L["Demon Hunter"] = "Охотник на демонов"
L["Desaturate When Missing"] = "Обесцвечивать при отсутствии"
L["Description"] = "Описание"
L["Description (optional)"] = "Описание (необязательно)"
L["Dialog"] = "Диалог"
L["Direct API"] = "Прямой API"
L["Direction"] = "Направление"
L["Disable (set to false)"] = "Отключить (установить false)"
L["Disable Buffs"] = "Отключить баффы"
L["Disable in Combat"] = "Отключить в бою"
L["Disable Overlay"] = "Отключить оверлей"
L["Disable While Mounted"] = "Отключить верхом"
L["Disable while mounted/flying"] = "Отключить верхом или в полете"
L["Disabled"] = "Отключено"
L["disabled"] = "отключено"
L["Disease"] = "Болезнь"
L["Dispel Detection"] = "Обнаружение диспела"
L["Dispel Overlay"] = "Оверлей диспела"
L["Dispel Overlay Alpha"] = "Прозрачность оверлея диспела"
L["Dispel Type Colors"] = "Цвета по типу диспела"
L["Dispel Type Icon"] = "Иконка типа диспела"
L["Dispellable By Me"] = "Я могу рассеять"
L["Display"] = "Отображение"
L["Display labels above or beside each raid group."] = "Отображать метки над или рядом с каждой рейдовой группой."
L["Display Mode"] = "Режим отображения"
L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."] = "Отображает специфические ресурсы класса (Энергия Света, Энергия Ци, Приемы серии, Осколки душ, Чародейские заряды, Сущность) в виде цветных делений на фрейме игрока."
L["Done"] = "Готово"
L["Don't show this warning again"] = "Больше не показывать это предупреждение"
L["Down"] = "Вниз"
L["DPS"] = "Урон"
L["Drag"] = "Перетащить"
L["Drag to reorder groups. Top = first."] = "Перетащите, чтобы изменить порядок групп. Верхняя = первая."
L["Drag to reorder. Top = first."] = "Перетащите, чтобы изменить порядок. Верхний = первый."
L["Drop on an anchor point to move %s"] = "Отпустите на точке привязки, чтобы переместить %s"
L["Drop on an anchor point to place %s"] = "Отпустите на точке привязки, чтобы разместить %s"
L["Druid"] = "Друид"
L["Dungeons"] = "Подземелья"
L["Duplicate"] = "Дублировать"
L["Duplicate Current"] = "Дублировать текущий"
L["Duplicated profile '%s' to '%s'."] = "Профиль '%s' продублирован в '%s'."
L["Duration"] = "Длительность"
L["Duration & stack display"] = "Отображение длительности и стаков"
L["Duration Anchor"] = "Точка привязки длительности"
L["Duration Color"] = "Цвет длительности"
L["Duration Font"] = "Шрифт длительности"
L["Duration in seconds for the Pull Timer quick action."] = "Длительность в секундах для быстрого действия «Таймер пулла»."
L["Duration Offset X"] = "Смещение длительности по X"
L["Duration Offset Y"] = "Смещение длительности по Y"
L["Duration Outline"] = "Контур длительности"
L["Duration Position"] = "Позиция длительности"
L["Duration Scale"] = "Масштаб длительности"
L["Duration Text"] = "Текст длительности"
L["Duration Text Color"] = "Цвет текста длительности"
L["Echo to Chat"] = "Выводить в чат"
L["Edge Glow (All Sides)"] = "Свечение краев (со всех сторон)"
L["Edit"] = "Изменить"
L["Edit Binding"] = "Изменить назначение клавиши"
L["Edit Copy"] = "Изменить копию"
L["Edit Layout Range"] = "Изменить диапазон макета"
L["Edit Macro"] = "Изменить макрос"
L["Edit Settings"] = "Изменить настройки"
L["Edit Steps"] = "Изменить шаги"
L["Editing"] = "Редактирование"
L["Editing:"] = "Редактирование:"
L["Editing: %s"] = "Редактирование: %s"
L["Effects"] = "Эффекты"
L["Ellipsis (...)"] = "Многоточие (...)"
L["Enable"] = "Включить"
L["Enable (set to true)"] = "Включить (установить true)"
L["Enable AFK Icon"] = "Включить иконку АФК"
L["Enable Aura Designer"] = "Включить конструктор аур"
L["Enable Binding Tooltips"] = "Включить подсказки назначений клавиш"
L["Enable Boss Debuffs"] = "Включить дебаффы боссов"
L["Enable Buff Tooltips"] = "Включить подсказки баффов"
L["Enable Buffs"] = "Включить баффы"
L["Enable Class Power Pips"] = "Включить деления ресурса класса"
L["Enable Custom Sorting"] = "Включить свою сортировку"
L["Enable Dead Fade"] = "Включить прозрачность мертвых"
L["Enable Debuff Tooltips"] = "Включить подсказки дебаффов"
L["Enable Debug Logging"] = "Включить журнал отладки"
L["Enable Defensive Icon"] = "Включить иконку защиты"
L["Enable Defensive Icon Tooltips"] = "Включить подсказки иконки защиты"
L["Enable Dispel Overlay"] = "Включить оверлей диспела"
L["Enable Element-Specific Alpha"] = "Включить прозрачность для отдельных элементов"
L["Enable Expiring Indicators"] = "Включить индикаторы истекающих эффектов"
L["Enable Frame Border Overlay"] = "Включить оверлей границ фрейма"
L["Enable Frame Tooltips"] = "Включить подсказки фреймов"
L["Enable Group Labels"] = "Включить метки групп"
L["Enable Heal Prediction"] = "Включить предсказание исцеления"
L["Enable Health Threshold Fade"] = "Включить прозрачность при пороге здоровья"
L["Enable Leader Icon"] = "Включить иконку лидера"
L["Enable Missing Buff Icon"] = "Включить иконку отсутствующего баффа"
L["Enable Offscreen Nameplates"] = "Включить индикаторы вне экрана"
L["Enable Overlay"] = "Включить оверлей"
L["Enable Permanent Mover"] = "Включить постоянную рамку перемещения"
L["Enable Personal Targeted Spells"] = "Включить заклинания, нацеленные на себя"
L["Enable Pet Frames"] = "Включить фреймы питомцев"
L["Enable Phased Icon"] = "Включить иконку фазирования"
L["Enable Raid Auto-Switching Layouts"] = "Включить автопереключение макетов рейда"
L["Enable Raid Role Icon"] = "Включить иконку роли в рейде"
L["Enable Raid Target Icon"] = "Включить иконку метки рейда"
L["Enable Ready Check Icon"] = "Включить иконку проверки готовности"
L["Enable Resource Bar"] = "Включить полосу ресурса"
L["Enable Resurrection Icon"] = "Включить иконку воскрешения"
L["Enable Resurrection Icon Tooltips"] = "Включить подсказки иконки воскрешения"
L["Enable Sound Alert"] = "Включить звуковое оповещение"
L["Enable Spec Auto-Switch"] = "Включить автопереключение специализации"
L["Enable Status Text"] = "Включить текст состояния"
L["Enable Summon Icon"] = "Включить иконку призыва"
L["Enable Targeted Spells"] = "Включить заклинания, нацеленные на игроков"
L["Enable the checkbox above to use"] = "Активируйте галочку выше, чтобы использовать"
L["Enable Vehicle Icon"] = "Включить иконку транспорта"
L["enabled"] = "включено"
L["Enabled"] = "Включено"
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = "Включено: Игроки распределены по рейдовым группам (1-8). Отключено: Все игроки отображаются единым списком (сеткой)."
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = "Включено: Игроки распределены по рейдовым группам (1-8). Отключено: Все игроки отображаются единым списком (сеткой)."
L["End"] = "Конец"
L["END"] = "КОНЕЦ"
L["End (Right/Bottom)"] = "Конец (Справа/Снизу)"
L["End of Group"] = "Конец группы"
L["Energy"] = "Энергия"
L["Enter a layout name"] = "Введите название макета"
L["Enter a profile name"] = "Введите название профиля"
L["Enter a spell name above..."] = "Введите название заклинания выше..."
L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."] = "Введите ID любого заклинания для проверки дистанции. Нажмите Enter для применения. Оставьте пустым, чтобы использовать выбор из списка."
L["Enter name for copy of '%s':"] = "Введите название для копии '%s':"
L["Enter new name for '%s':"] = "Введите новое название для '%s':"
L["Enter new profile name:"] = "Введите название нового профиля:"
L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."] = "Введите пути к текстурам WoW (расширения файлов удаляются автоматически). Оставьте пустым, чтобы использовать иконки DF по умолчанию."
L["Errors Only"] = "Только ошибки"
L["Evoker"] = "Пробудитель"
L["Exit Editing"] = "Выйти из редактирования"
L["Expire Alert"] = "Оповещение об истечении"
L["Expiring"] = "Истекающие"
L["Expiring Alpha"] = "Прозрачность истекающих"
L["Expiring Alpha Override"] = "Приоритет прозрачности истекающих"
L["Expiring Color"] = "Цвет истекающих"
L["Expiring Color Override"] = "Приоритет цвета истекающих"
L["Expiring Indicator"] = "Индикатор истекающих эффектов"
L["Expiring indicator tracks the trigger with the least time remaining."] = "Индикатор истекающих эффектов отслеживает триггер с наименьшим оставшимся временем."
L["Expiring indicator tracks the trigger with the most time remaining."] = "Индикатор истекающих эффектов отслеживает триггер с наибольшим оставшимся временем."
L["Expiring Threshold (%)"] = "Порог истечения (%)"
L["Expiring Threshold (seconds)"] = "Порог истечения (секунды)"
L["Export"] = "Экспорт"
L["Export failed. Please try again or check for errors."] = "Экспорт не удался. Пожалуйста, попробуйте еще раз или проверьте наличие ошибок."
L["Export Settings"] = "Экспорт настроек"
L["Export Wizard"] = "Экспорт мастера настройки"
L["External"] = "Внешние"
L["External Defensives"] = "Внешние защитные способности"
L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."] = "Скрывать фреймы или элементы, когда здоровье цели выше заданного порога (например, 100% или 80%)."
L["Fading"] = "Затухание"
L["Fill Color"] = "Цвет заполнения"
L["Fill Direction"] = "Направление заполнения"
L["Fill Pulsate"] = "Пульсация заполнения"
L["Finish"] = "Готово"
L["First question"] = "Первый вопрос"
L["First Unit"] = "Первая единица"
L["Fixed at 20 players (Mythic)"] = "Фиксировано на 20 игроках (Эпоха)"
L["Flat Grid Settings"] = "Настройки единой сетки"
L["Floating Bar"] = "Плавающая панель"
L["Floating Bar Anchor"] = "Якорь плавающей панели"
L["Floating Bar Position"] = "Позиция плавающей панели"
L["Focus"] = "Фокус"
L["Font"] = "Шрифт"
L["Font Outline"] = "Контур шрифта"
L["Font Settings"] = "Настройки шрифта"
L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"] = "Настройки шрифта для иконок, отображаемых текстом (призыв, воскрешение, АФК и т.д.)"
L["Font Size"] = "Размер шрифта"
L["For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."] = "Для предметов/макросов, требующих @cursor, @mouseover и т.д. Перехватывает клавишу и блокирует её использование на панели команд."
L["For nameplates & world units. %sDoes not work with action bar binds.%s"] = "Для индикаторов и мировых объектов. %sНе работает с биндами панелей команд.%s"
L["Frame"] = "Фрейм"
L["Frame Alpha"] = "Прозрачность фрейма"
L["Frame Alpha (Above Threshold)"] = "Прозрачность фрейма (выше порога)"
L["Frame Alpha (Out of Range)"] = "Прозрачность фрейма (вне зоны действия)"
L["Frame Border Overlay"] = "Оверлей границ фрейма"
L["Frame Display"] = "Отображение фрейма"
L["Frame Growth"] = "Рост фреймов"
L["Frame Height"] = "Высота фрейма"
L["Frame Level"] = "Уровень фрейма"
L["Frame Level Offset"] = "Смещение уровня фрейма"
L["Frame opacity when health is above the threshold."] = "Непрозрачность фрейма, когда здоровье выше порога."
L["Frame Padding"] = "Внутренние отступы фрейма"
L["FRAME PREVIEW"] = "ПРЕДПРОСМОТР ФРЕЙМА"
L["Frame Scale"] = "Масштаб фрейма"
L["Frame Size"] = "Размер фрейма"
L["Frame Spacing"] = "Межфреймовый интервал"
L["Frame Strata"] = "Слой фрейма"
L["Frame Tooltips"] = "Подсказки фрейма"
L["Frame Width"] = "Ширина фрейма"
L["FRAME-LEVEL EFFECTS"] = "ЭФФЕКТЫ УРОВНЯ ФРЕЙМА"
L["Frames centered on screen."] = "Фреймы центрированы на экране."
L["Frames Grow From"] = "Фреймы растут от"
L["Frames locked."] = "Фреймы закреплены."
L["Frames unlocked. Drag to move, right-click to lock."] = "Фреймы разблокированы. Тяните для перемещения, ПКМ - для закрепления."
L["Frames: %s"] = "Фреймы: %s"
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = "Обнаружен аддон FrameSort. Включите, чтобы позволить FrameSort управлять порядком фреймов. %sЭкспериментально:%s Это новая функция, которая может работать нестабильно в некоторых ситуациях. Пожалуйста, сообщайте о любых ошибках."
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = "Обнаружен аддон FrameSort. Включите, чтобы позволить FrameSort управлять порядком фреймов. %sЭкспериментально:%s Это новая функция, которая может работать нестабильно в некоторых ситуациях. Пожалуйста, сообщайте о любых ошибках."
L["FrameSort Integration"] = "Интеграция с FrameSort"
L["Friendly Only"] = "Только дружественные"
L["Full Frame"] = "Весь фрейм"
L["Fully Combat Safe: Frames will update normally during combat."] = "Полная безопасность в бою: фреймы будут обновляться в обычном режиме."
L["Fury"] = "Неистовство"
L["G1"] = "Г1"
L["Game Default"] = "По умолчанию"
L["Gap Between Pips"] = "Разрыв между делениями"
L["General"] = "Общие"
L["General Import"] = "Общий импорт"
L["Generate Export String"] = "Создать строку экспорта"
L["Gets its own independent border overlay. Multiple custom borders can be visible at the same time."] = "Получает собственный независимый оверлей границ. Одновременно могут быть видны несколько пользовательских границ."
L["Global"] = "Общие"
L["Global Font Settings"] = "Общие настройки шрифтов"
L["Global Fonts"] = "Общие шрифты"
L["Global Keybind:"] = "Общая клавиша:"
L["Glow"] = "Свечение"
L["Glow (ADD)"] = "Свечение (ADD)"
L["Glow Alpha"] = "Прозрачность свечения"
L["Glow Color"] = "Цвет свечения"
L["Glow Style"] = "Стиль свечения"
L["Go Back"] = "Назад"
L["Goes to: %s"] = "Назначение: %s"
L["Gradient"] = "Градиент"
L["Gradient Color Alpha"] = "Прозрачность цвета градиента"
L["Gradient Intensity"] = "Интенсивность градиента"
L["Gradient Opacity"] = "Непрозрачность градиента"
L["Gradient Position"] = "Позиция градиента"
L["Gradient Size"] = "Размер градиента"
L["Grid"] = "Сетка"
L["Grid Layout"] = "Макет сетки"
L["Group"] = "Группа"
L["Group 1"] = "Группа 1"
L["Group Display Order"] = "Порядок отображения групп"
L["Group Labels"] = "Метки групп"
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = "Метки групп недоступны в режиме единой сетки. Включите «Использовать групповой макет» в настройках фрейма, чтобы использовать метки групп."
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = "Метки групп недоступны в режиме единой сетки. Включите «Использовать групповой макет» в настройках фрейма, чтобы использовать метки групп."
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = "Метки групп доступны только для рейдовых фреймов. Переключитесь в режим «Рейд» с помощью переключателя в верхней части панели настроек, чтобы настроить метки групп."
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = "Метки групп доступны только для рейдовых фреймов. Переключитесь в режим «Рейд» с помощью переключателя в верхней части панели настроек, чтобы настроить метки групп."
L["Group Layout Settings"] = "Настройки макета групп"
L["GROUP NAME"] = "НАЗВАНИЕ ГРУППЫ"
L["Group Position"] = "Позиция группы"
L["Group Roster"] = "Состав группы"
L["Group Settings"] = "Настройки группы"
L["Group Spacing"] = "Межгрупповой интервал"
L["Group Visibility"] = "Видимость группы"
L["Group X Offset"] = "Смещение группы по X"
L["Group Y Offset"] = "Смещение группы по Y"
L["Groups Grow From"] = "Группы растут от"
L["Groups Per Column"] = "Групп в столбце"
L["Groups Per Row"] = "Групп в ряду"
L["Growth"] = "Рост"
L["GROWTH"] = "РОСТ"
L["Growth Direction"] = "Направление роста"
L["GUI reset to default size, scale, and position."] = "Интерфейс сброшен к стандартному размеру, масштабу и позиции."
L["Guided setup for configuring which buffs and debuffs appear on your frames."] = "Пошаговое руководство по настройке отображения баффов и дебаффов на ваших фреймах."
L["Guided setup for the frame border overlay that highlights boss debuffs."] = "Пошаговое руководство по настройке оверлея границ фрейма, подсвечивающего дебаффы боссов."
L["Handle Color"] = "Цвет регулятора"
L["Handle Height"] = "Высота регулятора"
L["Handle is invisible until you hover over it. Fades in and out smoothly."] = "Регулятор невидим, пока вы не наведете на него курсор. Плавно появляется и исчезает."
L["Handle Position"] = "Позиция регулятора"
L["Handle Width"] = "Ширина регулятора"
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = "Использование нескольких аддонов для заклинаний по клику может вызвать конфликты и непредсказуемое поведение. %sИспользуйте на свой страх и риск!%s"
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = "Использование нескольких аддонов для заклинаний по клику может вызвать конфликты и непредсказуемое поведение. %sИспользуйте на свой страх и риск!%s"
L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."] = "Проблемы с баффами или дебаффами? Запустите мастер настройки для получения помощи."
L["Heal Absorb"] = "Поглощение исцеления"
L["Heal Prediction"] = "Прогноз исцеления"
L["Heal Prediction Color"] = "Цвет прогноза исцеления"
L["Healer"] = "Лекарь"
L["Healers"] = "Лекари"
L["Health"] = "Здоровье"
L["Health Bar"] = "Полоса здоровья"
L["Health Bar Alpha"] = "Прозрачность полосы здоровья"
L["Health Bar Color"] = "Цвет полосы здоровья"
L["Health Bar Texture"] = "Текстура полосы здоровья"
L["Health Deficit"] = "Дефицит здоровья"
L["Health Format"] = "Формат здоровья"
L["Health Gradient"] = "Градиент здоровья"
L["Health Text"] = "Текст здоровья"
L["Health Text Alpha"] = "Прозрачность текста здоровья"
L["Health Text Anchor"] = "Точка привязки текста здоровья"
L["Health Text Color"] = "Цвет текста здоровья"
L["Health Threshold (%)"] = "Порог здоровья (%)"
L["Health Threshold Fading"] = "Затухание по порогу здоровья"
L["Health X Offset"] = "Смещение здоровья по X"
L["Health Y Offset"] = "Смещение здоровья по Y"
L["Height"] = "Высота"
L["Height / Thickness"] = "Высота / Толщина"
L["Here's what we'll set up:"] = "Вот что мы настроим:"
L["Hidden"] = "Скрыто"
L["Hide % Symbol"] = "Скрыть символ %"
L["Hide Above (seconds)"] = "Скрывать, если больше (сек.)"
L["Hide Above Threshold"] = "Скрывать выше порога"
L["Hide Blizzard Party Frames"] = "Скрыть рамки группы Blizzard"
L["Hide Blizzard Player Frame"] = "Скрыть рамку игрока Blizzard"
L["Hide Blizzard Raid Frames"] = "Скрыть рейдовые рамки Blizzard"
L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."] = "Скрывать положительные эффекты из полосы баффов, если они уже отображаются на панели защитных способностей или в конструкторе аур."
L["Hide Cooldown Swipe"] = "Скрыть анимацию перезарядки"
L["Hide duplicate buffs"] = "Скрыть дубликаты баффов"
L["Hide Duration Above Threshold"] = "Скрывать длительность выше порога"
L["Hide Icon (Text Only)"] = "Скрыть иконку (только текст)"
L["Hide in Combat"] = "Скрывать в бою"
L["Hide raid buffs from buff bar"] = "Скрывать рейдовые баффы из полосы баффов"
L["Hide Self from Party Frames"] = "Скрыть себя из рамок группы"
L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."] = "Скрывайте определенные баффы и дебаффы на ваших фреймах. Нажмите на заклинание, чтобы добавить его в черный список. Ауры из черного списка не будут отображаться на панелях баффов или в индикаторах конструктора аур."
L["Hide Tooltip on Mouseover"] = "Скрывать подсказку при наведении"
L["Hides Blizzard frames but keeps them active for aura filtering."] = "Скрывает стандартные рамки Blizzard, но оставляет их активными для фильтрации аур."
L["Hides the default Blizzard player portrait and health bar."] = "Скрывает стандартный портрет и полосу здоровья игрока Blizzard."
L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."] = "Скрывает регулятор во время боя. Если отключено, регулятор меняет цвет, указывая на то, что он заблокирован."
L["High"] = "Высокий"
L["High Health (100%)"] = "Высокое здоровье (100%)"
L["High Threat (Yellow)"] = "Высокая угроза (желтый)"
L["Higher values render the bar above other elements. Frame border is at level 10."] = "Более высокие значения отображают полосу поверх других элементов. Уровень границы фрейма - 10."
L["Highest Threat (Orange)"] = "Наивысшая угроза (оранжевый)"
L["Highlight"] = "Подсветка"
L["Highlight Color"] = "Цвет подсветки"
L["Highlight Dispellable"] = "Подсветка рассеиваемых эффектов"
L["Highlight for User"] = "Выделить для пользователя"
L["Highlight for user to configure"] = "Выделить для настройки пользователем"
L["Highlight Important Spells"] = "Подсветка важных заклинаний"
L["Highlight Settings"] = "Настройки подсветки"
L["Highlight Settings (comma-separated dbKeys)"] = "Настройки подсветки (dbKeys через запятую)"
L["Highlight Style"] = "Стиль подсветки"
L["Highlighted Units"] = "Подсвеченные юниты"
L["Highlights"] = "Подсветка"
L["Highlights: %s"] = "Подсветка: %s"
L["Horizontal"] = "Горизонтально"
L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."] = "Горизонтальные привязки располагают деления слева направо. Привязки Слева/Справа располагают деления вертикально вдоль края фрейма."
L["Horizontal Spacing"] = "Горизонтальный интервал"
L["Horizontal: Players stack vertically, groups grow left-to-right."] = "Горизонтально: игроки располагаются вертикально, группы растут слева направо."
L["Hostile Only"] = "Только враждебные"
L["Hover Highlight"] = "Подсветка при наведении"
L["Hover Settings"] = "Настройки при наведении"
L["How it works"] = "Как это работает"
L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"] = "Как часто проверять дистанцию (в секундах). Меньшее значение - быстрее реакция, но выше нагрузка на ЦПУ. По умолчанию: 0.5 сек."
L["How would you like to configure the filters?"] = "Как бы вы хотели настроить фильтры?"
L["HP"] = "ХП"
L["Hunter"] = "Охотник"
L["I understand, enable it"] = "Я понимаю, включить"
L["I, II, III..."] = "I, II, III..."
L["Icon"] = "Иконка"
L["Icon Height"] = "Высота иконки"
L["Icon Offset X"] = "Смещение иконки по X"
L["Icon Offset Y"] = "Смещение иконки по Y"
L["Icon Opacity"] = "Прозрачность иконки"
L["Icon Position"] = "Позиция иконки"
L["Icon Ratio"] = "Соотношение сторон иконки"
L["Icon Size"] = "Размер иконки"
L["Icon size, scale & border"] = "Размер, масштаб и граница иконки"
L["Icon Spacing"] = "Интервал иконок"
L["Icon Style"] = "Стиль иконки"
L["Icon Width"] = "Ширина иконки"
L["Icons"] = "Иконки"
L["Icons Alpha"] = "Прозрачность иконок"
L["Icons Per Row"] = "Иконок в ряду"
L["Ignore"] = "Игнорировать"
L["Ignore Full Health Fade"] = "Игнорировать затухание при полном здоровье"
L["Import"] = "Импорт"
L["Import All"] = "Импортировать всё"
L["Import All (%d)"] = "Импортировать всё (%d)"
L["Import Buffs Tab Defaults"] = "Импорт настроек по умолчанию для вкладок баффов"
L["Import Click Casting Profile"] = "Импортировать профиль заклинаний по клику"
L["Import failed"] = "Импорт не удался"
L["Import from Buffs Tab"] = "Импортировать из вкладки баффов"
L["Import Selected"] = "Импортировать выбранное"
L["Import Settings"] = "Настройки импорта"
L["Import String"] = "Строка импорта"
L["Import Wizard"] = "Мастер импорта"
L["Import WoW Macros"] = "Импортировать макросы WoW"
L["Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."] = "Импортируйте текущие настройки вкладки «Баффы» как стандартные для всех аур. Совместимые параметры будут применены автоматически."
L["Import/Export"] = "Импорт/Экспорт"
L["Important Spells"] = "Важные заклинания"
L["Important Spells Only"] = "Только важные заклинания"
L["Imported Profile"] = "Импортированный профиль"
L["Imported!"] = "Импортировано!"
L["In Combat Only"] = "Только в бою"
L["In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."] = "В режиме «Direct» для каждого юнита отображаются все активные крупные и внешние защитные способности (а не только одна). Настройте максимальное количество и расположение на странице «Иконки защиты»."
L["Incompatible Bindings"] = "Несовместимые назначения клавиш"
L["Indicators"] = "Индикаторы"
L["INFERRED TRACKING"] = "КОСВЕННОЕ ОТСЛЕЖИВАНИЕ"
L["Info (All)"] = "Инфо (Все)"
L["Inherit (Frame)"] = "Наследовать (от фрейма)"
L["Insanity"] = "Безумие"
L["Inset"] = "Вставка"
L["Inside (Bottom)"] = "Внутри (снизу)"
L["Inside (Top)"] = "Внутри (сверху)"
L["Instanced / PvP"] = "Подземелья / PvP"
L["Integration"] = "Интеграция"
L["Integration (advanced):"] = "Интеграция (расширенная):"
L["Integrations"] = "Интеграции"
L["Interrupt Settings"] = "Настройки прерываний"
L["Interrupted Visual"] = "Визуал прерывания"
L["is secret-tracked"] = "отслеживается скрыто"
L["Items"] = "Предметы"
L["Join a raid group (2-5 players works best)"] = "Вступите в рейдовую группу (лучше всего - от 2 до 5 игроков)"
L["Keep Buffs"] = "Сохранять баффы"
L["Keep when offline/left"] = "Не удалять при выходе из игры или группы"
L["Label Color"] = "Цвет метки"
L["Label Format"] = "Формат метки"
L["Label Name"] = "Название метки"
L["Label Position"] = "Позиция метки"
L["Label:"] = "Метка:"
L["Last Unit"] = "Последний юнит"
L["Layout"] = "Макет"
L["Layout (Direct Mode)"] = "Макет (прямой режим)"
L["Layout Direction"] = "Направление макета"
L["Layout Group"] = "Группа макета"
L["Layout Groups"] = "Группы макета"
L["Layout Mode"] = "Режим макета"
L["Layout Name"] = "Название макета"
L["Layout:"] = "Макет:"
L["Leader Icon"] = "Иконка лидера"
L["Left"] = "Слева"
L["Left Click"] = "ЛКМ"
L["Left Edge"] = "Левый край"
L["Left of Health Bar"] = "Слева от полоски здоровья"
L["Left of Owner"] = "Слева от владельца"
L["Left of Party"] = "Слева от группы"
L["Left of Raid"] = "Слева от рейда"
L["Left to Right"] = "Слева направо"
L["Left-click to add/edit binding"] = "ЛКМ: добавить/изменить назначение"
L["Left-click: Bind"] = "ЛКМ: назначить"
L["Let Masque Control Aura Borders"] = "Позволить Masque управлять границами аур"
L["Let me configure it myself"] = "Я настрою всё самостоятельно"
L["Line"] = "Линия"
L["Link: %s"] = "Связь: %s"
L["Linked Settings"] = "Связанные настройки"
L["List"] = "Список"
L["Loading..."] = "Загрузка..."
L["LOADOUT ASSIGNMENTS"] = "НАЗНАЧЕНИЯ КОМПЛЕКТОВ"
L["Loadout expects: %s"] = "Комплект ожидает: %s"
L["Lock"] = "Заблокировать"
L["Lock Frames"] = "Закрепить фреймы"
L["Lock Position"] = "Закрепить позицию"
L["Log Viewer"] = "Просмотр логов"
L["Loop Interval (sec)"] = "Интервал цикла (сек)"
L["Low"] = "Низкий"
L["Low Health (0%)"] = "Низкое здоровье (0%)"
L["Lunar Power"] = "Энергия луны"
L["Macro Options:"] = "Параметры макроса:"
L["Macro Text:"] = "Текст макроса:"
L["Macros"] = "Макросы"
L["Mage"] = "Маг"
L["Magic"] = "Магия"
L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."] = "Основные защитные способности, такие как «Божественный щит», «Ледяная глыба» или «Дубовая кожа»."
L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."] = "Сделать иконки сквозными для сторонних аддонов на клик-каст. Не требуется для встроенной системы Dragonflight."
L["Makes this binding work everywhere, consuming the keybind."] = "Это назначение будет работать везде, перехватывая нажатие клавиши."
L["Mana"] = "Мана"
L["Manage"] = "Управление"
L["Manage Profiles"] = "Управление профилями"
L["Marching Ants"] = "Бегущие муравьи"
L["Mark of the Wild (Druid)"] = "Знак дикой природы (Друид)"
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = "Аддон Masque не установлен. Masque позволяет применять кастомные текстуры к иконкам баффов и дебаффов. Установите Masque с CurseForge, чтобы включить эту функцию."
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = "Аддон Masque не установлен. Masque позволяет применять кастомные текстуры к иконкам баффов и дебаффов. Установите Masque с CurseForge, чтобы включить эту функцию."
L["Masque Integration"] = "Интеграция с Masque"
L["Match Frame Height"] = "Соотв. высоте фрейма"
L["Match Frame Width"] = "Соотв. ширине фрейма"
L["Match Health Bar Width/Height"] = "Соотв. ширине/высоте полоски здоровья"
L["Match Owner Height"] = "Соотв. высоте владельца"
L["Match Owner Width"] = "Соотв. ширине владельца"
L["Matched (not applied)"] = "Совпало (не применено)"
L["Max Buffs"] = "Макс. баффов"
L["Max Debuffs"] = "Макс. дебаффов"
L["Max Health"] = "Макс. здоровья"
L["Max Icons"] = "Макс. иконок"
L["Max Length (0=off)"] = "Макс. длина (0=выкл)"
L["Max Log Entries"] = "Макс. записей в логе"
L["Max Name Length"] = "Макс. длина имени"
L["Max Slots"] = "Макс. слотов"
L["Medium"] = "Средний"
L["Medium Health (50%)"] = "Среднее здоровье (50%)"
L["Melee DPS"] = "Мили ДД"
L["MEMBERS"] = "УЧАСТНИКИ"
L["Min Stacks to Show"] = "Мин. стаков для отображения"
L["Minimum Log Level"] = "Мин. уровень логирования"
L["Missing Buff Alpha"] = "Прозрачность отсутствующего баффа"
L["Missing Buffs"] = "Отсутствующие баффы"
L["Missing Health"] = "Недостающее здоровье"
L["Missing Health Alpha"] = "Прозрачность недостающего здоровья"
L["Missing Health Color"] = "Цвет недостающего здоровья"
L["Missing Health Only"] = "Только недостающее здоровье"
L["Missing Health Texture"] = "Текстура недостающего здоровья"
L["Mode"] = "Режим"
L["Modified"] = "Изменено"
L["Monk"] = "Монах"
L["Monochrome"] = "Монохром"
L["Moves the glow to the opposite side (no HP side instead of max HP side)."] = "Перемещает свечение на противоположную сторону (на сторону пустого, а не полного здоровья)."
L["Multi Select"] = "Множественный выбор"
L["My Group First"] = "Моя группа первой"
L["My Wizards"] = "Мои мастера настройки"
L["Mythic"] = "Эпохальный"
L["Mythic has fixed range"] = "В эпохальном режиме фиксированная дистанция"
L["Name"] = "Имя"
L["Name Alpha"] = "Прозрачность имени"
L["Name already exists"] = "Имя уже существует"
L["Name Anchor"] = "Точка привязки имени"
L["Name Color"] = "Цвет имени"
L["Name Text"] = "Текст имени"
L["Name Text Alpha"] = "Прозрачность текста имени"
L["Name Text Color"] = "Цвет текста имени"
L["Name X Offset"] = "Смещение имени по X"
L["Name Y Offset"] = "Смещение имени по Y"
L["Name:"] = "Имя:"
L["New"] = "Новый"
L["New Binding"] = "Новое назначение"
L["New Feature: Frame Border Overlay"] = "Новая функция: Наложение границ фрейма"
L["New Option"] = "Новая опция"
L["New question"] = "Новый вопрос"
L["Next"] = "Далее"
L["No"] = "Нет"
L["No %s effects configured."] = "Эффекты %s не настроены."
L["No action selected"] = "Действие не выбрано"
L["No auto-profile is currently active or being edited."] = "Нет активных или редактируемых авто-профилей."
L["no branch"] = "нет ветки"
L["No built-in wizards available yet. Check back after updates!"] = "Встроенные мастера настройки пока недоступны. Проверьте после обновлений!"
L["No changelog available."] = "Список изменений недоступен."
L["No custom wizards yet. Click 'New Wizard' to create one!"] = "Пользовательских мастеров еще нет. Нажмите «Новый мастер», чтобы создать его!"
L["No data to export"] = "Нет данных для экспорта"
L["No default profile set"] = "Профиль по умолчанию не установлен"
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = "Эффекты еще не настроены. Нажмите '+ Добавить индикатор', чтобы начать."
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = "Эффекты еще не настроены. Нажмите '+ Добавить индикатор', чтобы начать."
L["No item equipped"] = "Предмет не экипирован"
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = "Группы макетов еще не созданы. Нажмите '+ Создать группу', чтобы начать."
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = "Группы макетов еще не созданы. Нажмите '+ Создать группу', чтобы начать."
L["No layout set. Using global settings."] = "Макет не задан. Используются глобальные настройки."
L["No loadout detected"] = "Набор талантов не обнаружен"
L["No macros match the current filter."] = "Нет макросов, соответствующих фильтру."
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = "Макросов пока нет. Нажмите '+ Новый', чтобы создать макрос, или Импорт, чтобы перенести его из WoW."
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = "Макросов пока нет. Нажмите '+ Новый', чтобы создать макрос, или Импорт, чтобы перенести его из WoW."
L["No members yet"] = "Участников еще нет"
L["No saved position to reset to."] = "Нет сохраненной позиции для сброса."
L["No sound file selected. Choose a sound from the dropdown or enter a custom path."] = "Звуковой файл не выбран. Выберите звук из списка или введите путь вручную."
L["No spells available for this class"] = "Для этого класса нет доступных заклинаний"
L["No thanks"] = "Нет, спасибо"
L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."] = "Мастер не выбран. Перейдите во вкладку «Мои мастера», чтобы выбрать или создать мастера."
L["None"] = "Нет"
L["None (no clamping)"] = "Нет (без ограничений)"
L["None / Physical"] = "Нет / Физический"
L["None active (using global settings)"] = "Нет активных (используются глобальные настройки)"
L["Normal (BLEND)"] = "Обычный (BLEND)"
L["Not Cancelable"] = "Нельзя отменить"
L["Not in a raid group"] = "Не в группе рейда"
L["Not Set"] = "Не задано"
L["Note: Cmd + Left Click unavailable on Mac"] = "Примечание: Cmd + ЛКМ недоступно на Mac"
L["Note: Font sizes are not changed. Adjust sizes in each element's page."] = "Примечание: размер шрифта не изменен. Настройте размеры на страницах соответствующих элементов."
L["Notice"] = "Уведомление"
L["Off"] = "Выкл."
L["Offset X"] = "Смещение по X"
L["Offset Y"] = "Смещение по Y"
L["OK"] = "ОК"
L["Only changed settings will be saved"] = "Будут сохранены только измененные настройки"
L["Only Dispellable Debuffs"] = "Только рассеиваемые дебаффы"
L["Only My Buffs"] = "Только мои баффы"
L["Only show buffs that you cast. Applies to all buff filters."] = "Показывать только наложенные вами эффекты. Применяется ко всем фильтрам баффов."
L["Only Show When Tanking"] = "Показывать только в роли танка"
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = "Во время работы авто-макетов можно редактировать только активный макет."
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = "Во время работы авто-макетов можно редактировать только активный макет."
L["OOC"] = "Вне боя"
L["Open Aura Designer"] = "Открыть конструктор аур"
L["Open Cast History"] = "Открыть историю заклинаний"
L["Open Settings"] = "Открыть настройки"
L["Open Settings Tab"] = "Открыть вкладку настроек"
L["Open the Profiles tab to manage profiles"] = "Откройте вкладку «Профили» для управления профилями"
L["Open Unit Menu"] = "Открыть меню юнита"
L["Open World"] = "Открытый мир"
L["Opens tab: %s"] = "Открывает вкладку: %s"
L["Option A"] = "Вариант А"
L["Option B"] = "Вариант Б"
L["Options"] = "Параметры"
L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"] = "Опции: [S] = Привязать настр. [->] = Ветка [x] = Удалить"
L["Or enter Icon ID:"] = "Или введите ID значка:"
L["Orientation"] = "Ориентация"
L["Other"] = "Прочее"
L["Other (%d)"] = "Прочее (%d)"
L["Other Frames"] = "Другие фреймы"
L["Out of combat"] = "Вне боя"
L["Out of Combat Only"] = "Только вне боя"
L["Out of Range"] = "Вне зоны досягаемости"
L["Outline"] = "Контур"
L["Overlaps with \"%s\""] = "Перекрывается с \"%s\""
L["Overlaps with \"%s\" (%d-%d)"] = "Перекрывается с \"%s\" (%d-%d)"
L["Overlay (on health bar)"] = "Наложение (на полосе здоровья)"
L["Overridden by Auto Layout"] = "Переопределено авто-макетом"
L["Overridden in this layout"] = "Переопределено в этом макете"
L["Override Details"] = "Подробности переопределения"
L["Owner's Class Color"] = "Цвет класса владельца"
--[[Translation missing --]]
--[[ L["Paladin"] = "Paladin"--]] 
--[[Translation missing --]]
--[[ L["Parse String"] = "Parse String"--]] 
--[[Translation missing --]]
--[[ L["Party"] = "Party"--]] 
--[[Translation missing --]]
--[[ L["PARTY"] = "PARTY"--]] 
--[[Translation missing --]]
--[[ L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[Party & Raid %s settings are synced.
Click to stop syncing.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Party to Raid"] = "Party to Raid"--]] 
--[[Translation missing --]]
--[[ L["Party: %s"] = "Party: %s"--]] 
--[[Translation missing --]]
--[[ L["Paste a profile string to import:"] = "Paste a profile string to import:"--]] 
--[[Translation missing --]]
--[[ L["Paste the wizard export string below:"] = "Paste the wizard export string below:"--]] 
--[[Translation missing --]]
--[[ L["Pattern:"] = "Pattern:"--]] 
--[[Translation missing --]]
--[[ L["Per-aura overrides"] = "Per-aura overrides"--]] 
--[[Translation missing --]]
--[[ L["Percent"] = "Percent"--]] 
--[[Translation missing --]]
--[[ L["Percentage"] = "Percentage"--]] 
--[[Translation missing --]]
--[[ L["Permanent Mover"] = "Permanent Mover"--]] 
--[[Translation missing --]]
--[[ L["Per-setting reset is not available for Aura Designer"] = "Per-setting reset is not available for Aura Designer"--]] 
--[[Translation missing --]]
--[[ L["Persist (sec)"] = "Persist (sec)"--]] 
--[[Translation missing --]]
--[[ L["Personal Targeted"] = "Personal Targeted"--]] 
--[[Translation missing --]]
--[[ L["Personal Targeted Spells"] = "Personal Targeted Spells"--]] 
--[[Translation missing --]]
--[[ L["Pet Frame Settings"] = "Pet Frame Settings"--]] 
--[[Translation missing --]]
--[[ L["Pet Frames"] = "Pet Frames"--]] 
--[[Translation missing --]]
--[[ L["Pet frames are grouped together in a separate container."] = "Pet frames are grouped together in a separate container."--]] 
--[[Translation missing --]]
--[[ L["Pet frames are positioned relative to their owner's frame."] = "Pet frames are positioned relative to their owner's frame."--]] 
--[[Translation missing --]]
--[[ L["Pet Spacing"] = "Pet Spacing"--]] 
--[[Translation missing --]]
--[[ L["Phased"] = "Phased"--]] 
--[[Translation missing --]]
--[[ L["Phased Icon"] = "Phased Icon"--]] 
--[[Translation missing --]]
--[[ L["Picked setting: %s%s%s from tab %s%s%s"] = "Picked setting: %s%s%s from tab %s%s%s"--]] 
--[[Translation missing --]]
--[[ L["Pinned Frames"] = "Pinned Frames"--]] 
--[[Translation missing --]]
--[[ L["Pip Color"] = "Pip Color"--]] 
--[[Translation missing --]]
--[[ L["Pip Height"] = "Pip Height"--]] 
--[[Translation missing --]]
--[[ L["Pixel-Perfect Scaling"] = "Pixel-Perfect Scaling"--]] 
--[[Translation missing --]]
--[[ L["Place %s at %s"] = "Place %s at %s"--]] 
--[[Translation missing --]]
--[[ L["Placed"] = "Placed"--]] 
--[[Translation missing --]]
--[[ L["PLACED ON FRAME"] = "PLACED ON FRAME"--]] 
--[[Translation missing --]]
--[[ L["PLACEMENT"] = "PLACEMENT"--]] 
--[[Translation missing --]]
--[[ L["Player Range"] = "Player Range"--]] 
--[[Translation missing --]]
--[[ L["Players Grow From"] = "Players Grow From"--]] 
--[[Translation missing --]]
--[[ L["Players Per Column"] = "Players Per Column"--]] 
--[[Translation missing --]]
--[[ L["Players Per Row"] = "Players Per Row"--]] 
--[[Translation missing --]]
--[[ L["Please enter a profile name."] = "Please enter a profile name."--]] 
--[[Translation missing --]]
--[[ L["Please select an action!"] = "Please select an action!"--]] 
--[[Translation missing --]]
--[[ L["Poison"] = "Poison"--]] 
--[[Translation missing --]]
--[[ L["Position"] = "Position"--]] 
--[[Translation missing --]]
--[[ L["Position & anchors"] = "Position & anchors"--]] 
--[[Translation missing --]]
--[[ L["Position managed by: %s"] = "Position managed by: %s"--]] 
--[[Translation missing --]]
--[[ L["Position reset."] = "Position reset."--]] 
--[[Translation missing --]]
--[[ L["Power Bar Alpha"] = "Power Bar Alpha"--]] 
--[[Translation missing --]]
--[[ L["Power Word: Fortitude (Priest)"] = "Power Word: Fortitude (Priest)"--]] 
--[[Translation missing --]]
--[[ L["Pre-configure players before they join the group"] = "Pre-configure players before they join the group"--]] 
--[[Translation missing --]]
--[[ L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Press Ctrl+A to select all, then Ctrl+C to copy"] = "Press Ctrl+A to select all, then Ctrl+C to copy"--]] 
--[[Translation missing --]]
--[[ L["Press Ctrl+C to copy, then Escape to close"] = "Press Ctrl+C to copy, then Escape to close"--]] 
--[[Translation missing --]]
--[[ L["Press key/click/scroll..."] = "Press key/click/scroll..."--]] 
--[[Translation missing --]]
--[[ L["Preview"] = "Preview"--]] 
--[[Translation missing --]]
--[[ L["Preview Scale"] = "Preview Scale"--]] 
--[[Translation missing --]]
--[[ L["Preview Sound"] = "Preview Sound"--]] 
--[[Translation missing --]]
--[[ L["Preview:"] = "Preview:"--]] 
--[[Translation missing --]]
--[[ L["Priest"] = "Priest"--]] 
--[[Translation missing --]]
--[[ L["Priority"] = "Priority"--]] 
--[[Translation missing --]]
--[[ L["Priority:"] = "Priority:"--]] 
--[[Translation missing --]]
--[[ L["Private Aura Overlay Setup"] = "Private Aura Overlay Setup"--]] 
--[[Translation missing --]]
--[[ L["Profile \"%s\" has no overrides."] = "Profile \"%s\" has no overrides."--]] 
--[[Translation missing --]]
--[[ L["Profile '%s' already exists."] = "Profile '%s' already exists."--]] 
--[[Translation missing --]]
--[[ L["Profile Actions"] = "Profile Actions"--]] 
--[[Translation missing --]]
--[[ L["Profile imported successfully!"] = "Profile imported successfully!"--]] 
--[[Translation missing --]]
--[[ L["Profile matched to loadout"] = "Profile matched to loadout"--]] 
--[[Translation missing --]]
--[[ L["Profile Name"] = "Profile Name"--]] 
--[[Translation missing --]]
--[[ L["Profile not found"] = "Profile not found"--]] 
--[[Translation missing --]]
--[[ L["Profile Settings"] = "Profile Settings"--]] 
--[[Translation missing --]]
--[[ L["Profile:"] = "Profile:"--]] 
--[[Translation missing --]]
--[[ L["Profile: %s"] = "Profile: %s"--]] 
--[[Translation missing --]]
--[[ L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Profiles"] = "Profiles"--]] 
--[[Translation missing --]]
--[[ L["Pull Timer"] = "Pull Timer"--]] 
--[[Translation missing --]]
--[[ L["Pull Timer Duration"] = "Pull Timer Duration"--]] 
--[[Translation missing --]]
--[[ L["Pulsate"] = "Pulsate"--]] 
--[[Translation missing --]]
--[[ L["Pulsate Border"] = "Pulsate Border"--]] 
--[[Translation missing --]]
--[[ L["Pulse"] = "Pulse"--]] 
--[[Translation missing --]]
--[[ L["Pulse Animation"] = "Pulse Animation"--]] 
--[[Translation missing --]]
--[[ L["Question"] = "Question"--]] 
--[[Translation missing --]]
--[[ L["Question:"] = "Question:"--]] 
--[[Translation missing --]]
--[[ L["Quick Bind"] = "Quick Bind"--]] 
--[[Translation missing --]]
--[[ L["Quick Bind Mode"] = "Quick Bind Mode"--]] 
--[[Translation missing --]]
--[[ L["Quick Macro"] = "Quick Macro"--]] 
--[[Translation missing --]]
--[[ L["Quick Macro Builder"] = "Quick Macro Builder"--]] 
--[[Translation missing --]]
--[[ L["Quick Switch CC Profile"] = "Quick Switch CC Profile"--]] 
--[[Translation missing --]]
--[[ L["Quick Switch Profile"] = "Quick Switch Profile"--]] 
--[[Translation missing --]]
--[[ L["Rage"] = "Rage"--]] 
--[[Translation missing --]]
--[[ L["Raid"] = "Raid"--]] 
--[[Translation missing --]]
--[[ L["RAID"] = "RAID"--]] 
--[[Translation missing --]]
--[[ L["Raid Auto Layouts"] = "Raid Auto Layouts"--]] 
--[[Translation missing --]]
--[[ L["Raid Buffs"] = "Raid Buffs"--]] 
--[[Translation missing --]]
--[[ L["Raid Debuffs"] = "Raid Debuffs"--]] 
--[[Translation missing --]]
--[[ L["Raid frames centered."] = "Raid frames centered."--]] 
--[[Translation missing --]]
--[[ L["Raid Group Labels"] = "Raid Group Labels"--]] 
--[[Translation missing --]]
--[[ L["Raid In Combat"] = "Raid In Combat"--]] 
--[[Translation missing --]]
--[[ L["Raid Layout Mode"] = "Raid Layout Mode"--]] 
--[[Translation missing --]]
--[[ L["Raid position reset."] = "Raid position reset."--]] 
--[[Translation missing --]]
--[[ L["Raid Role (MT/MA)"] = "Raid Role (MT/MA)"--]] 
--[[Translation missing --]]
--[[ L["Raid Role Icon (MT/MA)"] = "Raid Role Icon (MT/MA)"--]] 
--[[Translation missing --]]
--[[ L["Raid Target Icon"] = "Raid Target Icon"--]] 
--[[Translation missing --]]
--[[ L["Raid to Party"] = "Raid to Party"--]] 
--[[Translation missing --]]
--[[ L["Raid: %s"] = "Raid: %s"--]] 
--[[Translation missing --]]
--[[ L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Raids"] = "Raids"--]] 
--[[Translation missing --]]
--[[ L["Raids, battlegrounds (1-40)"] = "Raids, battlegrounds (1-40)"--]] 
--[[Translation missing --]]
--[[ L["Range Check Interval"] = "Range Check Interval"--]] 
--[[Translation missing --]]
--[[ L["Range Check Spell"] = "Range Check Spell"--]] 
--[[Translation missing --]]
--[[ L["Ranged DPS"] = "Ranged DPS"--]] 
--[[Translation missing --]]
--[[ L["Ready Check"] = "Ready Check"--]] 
--[[Translation missing --]]
--[[ L["Ready Check Icon"] = "Ready Check Icon"--]] 
--[[Translation missing --]]
--[[ L["Ready to copy"] = "Ready to copy"--]] 
--[[Translation missing --]]
--[[ L["Recovered %d raid settings from interrupted auto layout editing session."] = "Recovered %d raid settings from interrupted auto layout editing session."--]] 
--[[Translation missing --]]
--[[ L["Refresh"] = "Refresh"--]] 
--[[Translation missing --]]
--[[ L["Reload UI"] = "Reload UI"--]] 
--[[Translation missing --]]
--[[ L["Remove all bindings from the current profile."] = "Remove all bindings from the current profile."--]] 
--[[Translation missing --]]
--[[ L["Remove Offline"] = "Remove Offline"--]] 
--[[Translation missing --]]
--[[ L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."] = "Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."--]] 
--[[Translation missing --]]
--[[ L["Removes your player frame from the DandersFrames party display."] = "Removes your player frame from the DandersFrames party display."--]] 
--[[Translation missing --]]
--[[ L["Rename"] = "Rename"--]] 
--[[Translation missing --]]
--[[ L["Replace"] = "Replace"--]] 
--[[Translation missing --]]
--[[ L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."] = "Replace Blizzard's color picker with the DandersFrames color picker for this addon."--]] 
--[[Translation missing --]]
--[[ L["Replace Buffs"] = "Replace Buffs"--]] 
--[[Translation missing --]]
--[[ L["Res + Mass"] = "Res + Mass"--]] 
--[[Translation missing --]]
--[[ L["Res + Mass + Combat"] = "Res + Mass + Combat"--]] 
--[[Translation missing --]]
--[[ L["Reset"] = "Reset"--]] 
--[[Translation missing --]]
--[[ L["Reset All Aura Configs"] = "Reset All Aura Configs"--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Reset All to Default"] = "Reset All to Default"--]] 
--[[Translation missing --]]
--[[ L["Reset Aura Designer to Global"] = "Reset Aura Designer to Global"--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Reset Position"] = "Reset Position"--]] 
--[[Translation missing --]]
--[[ L["Reset Profile to Defaults"] = "Reset Profile to Defaults"--]] 
--[[Translation missing --]]
--[[ L["Reset to Defaults"] = "Reset to Defaults"--]] 
--[[Translation missing --]]
--[[ L["Reset to Global"] = "Reset to Global"--]] 
--[[Translation missing --]]
--[[ L["Reset to Global Order"] = "Reset to Global Order"--]] 
--[[Translation missing --]]
--[[ L["Resource Bar"] = "Resource Bar"--]] 
--[[Translation missing --]]
--[[ L["Resource Bar Settings"] = "Resource Bar Settings"--]] 
--[[Translation missing --]]
--[[ L["Resource Colors"] = "Resource Colors"--]] 
--[[Translation missing --]]
--[[ L["Rested Indicator"] = "Rested Indicator"--]] 
--[[Translation missing --]]
--[[ L["Resurrection"] = "Resurrection"--]] 
--[[Translation missing --]]
--[[ L["Resurrection Icon"] = "Resurrection Icon"--]] 
--[[Translation missing --]]
--[[ L["Resurrection Icon Tooltips"] = "Resurrection Icon Tooltips"--]] 
--[[Translation missing --]]
--[[ L["Reverse Fill"] = "Reverse Fill"--]] 
--[[Translation missing --]]
--[[ L["Reverse Fill Direction"] = "Reverse Fill Direction"--]] 
--[[Translation missing --]]
--[[ L["Reverse Order"] = "Reverse Order"--]] 
--[[Translation missing --]]
--[[ L["Reverse Overlay Fill"] = "Reverse Overlay Fill"--]] 
--[[Translation missing --]]
--[[ L["Reverse Position"] = "Reverse Position"--]] 
--[[Translation missing --]]
--[[ L["Right"] = "Right"--]] 
--[[Translation missing --]]
--[[ L["Right Click"] = "Right Click"--]] 
--[[Translation missing --]]
--[[ L["Right Edge"] = "Right Edge"--]] 
--[[Translation missing --]]
--[[ L["Right of Health Bar"] = "Right of Health Bar"--]] 
--[[Translation missing --]]
--[[ L["Right of Owner"] = "Right of Owner"--]] 
--[[Translation missing --]]
--[[ L["Right of Party"] = "Right of Party"--]] 
--[[Translation missing --]]
--[[ L["Right of Raid"] = "Right of Raid"--]] 
--[[Translation missing --]]
--[[ L["Right to Left"] = "Right to Left"--]] 
--[[Translation missing --]]
--[[ L["Right-click"] = "Right-click"--]] 
--[[Translation missing --]]
--[[ L["Right-click: Edit/View"] = "Right-click: Edit/View"--]] 
--[[Translation missing --]]
--[[ L["Rogue"] = "Rogue"--]] 
--[[Translation missing --]]
--[[ L["Role Icon"] = "Role Icon"--]] 
--[[Translation missing --]]
--[[ L["Role Priority"] = "Role Priority"--]] 
--[[Translation missing --]]
--[[ L["Row Spacing"] = "Row Spacing"--]] 
--[[Translation missing --]]
--[[ L["Rows"] = "Rows"--]] 
--[[Translation missing --]]
--[[ L["Rows Grow From"] = "Rows Grow From"--]] 
--[[Translation missing --]]
--[[ L["Run"] = "Run"--]] 
--[[Translation missing --]]
--[[ L["Run Overlay Setup Wizard"] = "Run Overlay Setup Wizard"--]] 
--[[Translation missing --]]
--[[ L["Run Script"] = "Run Script"--]] 
--[[Translation missing --]]
--[[ L["Run Setup Wizard"] = "Run Setup Wizard"--]] 
--[[Translation missing --]]
--[[ L["Runic Power"] = "Runic Power"--]] 
--[[Translation missing --]]
--[[ L["Runtime"] = "Runtime"--]] 
--[[Translation missing --]]
--[[ L["Save"] = "Save"--]] 
--[[Translation missing --]]
--[[ L["Save & Close"] = "Save & Close"--]] 
--[[Translation missing --]]
--[[ L["Save Changes"] = "Save Changes"--]] 
--[[Translation missing --]]
--[[ L["Scale"] = "Scale"--]] 
--[[Translation missing --]]
--[[ L["Script Runner"] = "Script Runner"--]] 
--[[Translation missing --]]
--[[ L["Search fonts..."] = "Search fonts..."--]] 
--[[Translation missing --]]
--[[ L["Search sounds..."] = "Search sounds..."--]] 
--[[Translation missing --]]
--[[ L["Search spells..."] = "Search spells..."--]] 
--[[Translation missing --]]
--[[ L["Search textures..."] = "Search textures..."--]] 
--[[Translation missing --]]
--[[ L["Search..."] = "Search..."--]] 
--[[Translation missing --]]
--[[ L["Seconds"] = "Seconds"--]] 
--[[Translation missing --]]
--[[ L["See Also:"] = "See Also:"--]] 
--[[Translation missing --]]
--[[ L["Select a destination"] = "Select a destination"--]] 
--[[Translation missing --]]
--[[ L["Select a spell"] = "Select a spell"--]] 
--[[Translation missing --]]
--[[ L["Select a step to edit"] = "Select a step to edit"--]] 
--[[Translation missing --]]
--[[ L["Select All Text"] = "Select All Text"--]] 
--[[Translation missing --]]
--[[ L["Select any tab"] = "Select any tab"--]] 
--[[Translation missing --]]
--[[ L["Select Class"] = "Select Class"--]] 
--[[Translation missing --]]
--[[ L["Select indicator..."] = "Select indicator..."--]] 
--[[Translation missing --]]
--[[ L["Select or create a wizard"] = "Select or create a wizard"--]] 
--[[Translation missing --]]
--[[ L["Select trigger for %s"] = "Select trigger for %s"--]] 
--[[Translation missing --]]
--[[ L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."] = "Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."--]] 
--[[Translation missing --]]
--[[ L["Select..."] = "Select..."--]] 
--[[Translation missing --]]
--[[ L["Selected: %d"] = "Selected: %d"--]] 
--[[Translation missing --]]
--[[ L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[Selecting an option will disable the other addon(s)
and reload your UI.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Selection Highlight"] = "Selection Highlight"--]] 
--[[Translation missing --]]
--[[ L["Selection Settings"] = "Selection Settings"--]] 
--[[Translation missing --]]
--[[ L["Self Position"] = "Self Position"--]] 
--[[Translation missing --]]
--[[ L["Separate Melee & Ranged DPS"] = "Separate Melee & Ranged DPS"--]] 
--[[Translation missing --]]
--[[ L["Separate Pet Group"] = "Separate Pet Group"--]] 
--[[Translation missing --]]
--[[ L["Set a font and outline style, then click Apply to update ALL text elements."] = "Set a font and outline style, then click Apply to update ALL text elements."--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Settings"] = "Settings"--]] 
--[[Translation missing --]]
--[[ L["Settings to Apply"] = "Settings to Apply"--]] 
--[[Translation missing --]]
--[[ L["Setup Wizards"] = "Setup Wizards"--]] 
--[[Translation missing --]]
--[[ L["Shadow"] = "Shadow"--]] 
--[[Translation missing --]]
--[[ L["Shadow Color"] = "Shadow Color"--]] 
--[[Translation missing --]]
--[[ L["Shadow Settings"] = "Shadow Settings"--]] 
--[[Translation missing --]]
--[[ L["Shadow settings are controlled in General > Global Fonts."] = "Shadow settings are controlled in General > Global Fonts."--]] 
--[[Translation missing --]]
--[[ L["Shadow X Offset"] = "Shadow X Offset"--]] 
--[[Translation missing --]]
--[[ L["Shadow Y Offset"] = "Shadow Y Offset"--]] 
--[[Translation missing --]]
--[[ L["Shaman"] = "Shaman"--]] 
--[[Translation missing --]]
--[[ L["Shared"] = "Shared"--]] 
--[[Translation missing --]]
--[[ L["Shared Border"] = "Shared Border"--]] 
--[[Translation missing --]]
--[[ L["Shift+Left Click"] = "Shift+Left Click"--]] 
--[[Translation missing --]]
--[[ L["Shift+Right Click"] = "Shift+Right Click"--]] 
--[[Translation missing --]]
--[[ L["Show a pulsing yellow glow around the frame."] = "Show a pulsing yellow glow around the frame."--]] 
--[[Translation missing --]]
--[[ L["Show All Roles Out of Combat"] = "Show All Roles Out of Combat"--]] 
--[[Translation missing --]]
--[[ L["Show as Text"] = "Show as Text"--]] 
--[[Translation missing --]]
--[[ L["Show Background"] = "Show Background"--]] 
--[[Translation missing --]]
--[[ L["Show Border"] = "Show Border"--]] 
--[[Translation missing --]]
--[[ L["Show Buffs"] = "Show Buffs"--]] 
--[[Translation missing --]]
--[[ L["Show Cooldown Swipe"] = "Show Cooldown Swipe"--]] 
--[[Translation missing --]]
--[[ L["Show Debuffs"] = "Show Debuffs"--]] 
--[[Translation missing --]]
--[[ L["Show Dispel Icon"] = "Show Dispel Icon"--]] 
--[[Translation missing --]]
--[[ L["Show DPS"] = "Show DPS"--]] 
--[[Translation missing --]]
--[[ L["Show Duration"] = "Show Duration"--]] 
--[[Translation missing --]]
--[[ L["Show Duration Numbers"] = "Show Duration Numbers"--]] 
--[[Translation missing --]]
--[[ L["Show Duration Text"] = "Show Duration Text"--]] 
--[[Translation missing --]]
--[[ L["Show every buff with no filtering."] = "Show every buff with no filtering."--]] 
--[[Translation missing --]]
--[[ L["Show every debuff with no filtering."] = "Show every debuff with no filtering."--]] 
--[[Translation missing --]]
--[[ L["Show Expiring Border"] = "Show Expiring Border"--]] 
--[[Translation missing --]]
--[[ L["Show Expiring Tint"] = "Show Expiring Tint"--]] 
--[[Translation missing --]]
--[[ L["Show for Roles"] = "Show for Roles"--]] 
--[[Translation missing --]]
--[[ L["Show Frame Border"] = "Show Frame Border"--]] 
--[[Translation missing --]]
--[[ L["Show Gradient"] = "Show Gradient"--]] 
--[[Translation missing --]]
--[[ L["Show Group Label"] = "Show Group Label"--]] 
--[[Translation missing --]]
--[[ L["Show Healer"] = "Show Healer"--]] 
--[[Translation missing --]]
--[[ L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."] = "Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."--]] 
--[[Translation missing --]]
--[[ L["Show Health Percentage"] = "Show Health Percentage"--]] 
--[[Translation missing --]]
--[[ L["Show in content types:"] = "Show in content types:"--]] 
--[[Translation missing --]]
--[[ L["Show in Solo Mode"] = "Show in Solo Mode"--]] 
--[[Translation missing --]]
--[[ L["Show Interrupted Visual"] = "Show Interrupted Visual"--]] 
--[[Translation missing --]]
--[[ L["Show Label"] = "Show Label"--]] 
--[[Translation missing --]]
--[[ L["Show LFG Eye for Cross-Instance"] = "Show LFG Eye for Cross-Instance"--]] 
--[[Translation missing --]]
--[[ L["Show Main Assist"] = "Show Main Assist"--]] 
--[[Translation missing --]]
--[[ L["Show Main Tank"] = "Show Main Tank"--]] 
--[[Translation missing --]]
--[[ L["Show Minimap Button"] = "Show Minimap Button"--]] 
--[[Translation missing --]]
--[[ L["Show On Current Health Only"] = "Show On Current Health Only"--]] 
--[[Translation missing --]]
--[[ L["Show on Hover Only"] = "Show on Hover Only"--]] 
--[[Translation missing --]]
--[[ L["Show Overheal"] = "Show Overheal"--]] 
--[[Translation missing --]]
--[[ L["Show Overlay For"] = "Show Overlay For"--]] 
--[[Translation missing --]]
--[[ L["Show Overshield Glow"] = "Show Overshield Glow"--]] 
--[[Translation missing --]]
--[[ L["Show Party/Raid Side Menu"] = "Show Party/Raid Side Menu"--]] 
--[[Translation missing --]]
--[[ L["Show rested indicators when in a rested area (inn, city)."] = "Show rested indicators when in a rested area (inn, city)."--]] 
--[[Translation missing --]]
--[[ L["Show Shadow"] = "Show Shadow"--]] 
--[[Translation missing --]]
--[[ L["Show Stacks"] = "Show Stacks"--]] 
--[[Translation missing --]]
--[[ L["Show Tank"] = "Show Tank"--]] 
--[[Translation missing --]]
--[[ L["Show the animated ZZZ icon on the player frame."] = "Show the animated ZZZ icon on the player frame."--]] 
--[[Translation missing --]]
--[[ L["Show the DF color picker when any addon opens a color picker."] = "Show the DF color picker when any addon opens a color picker."--]] 
--[[Translation missing --]]
--[[ L["Show Timer"] = "Show Timer"--]] 
--[[Translation missing --]]
--[[ L["Show When Missing"] = "Show When Missing"--]] 
--[[Translation missing --]]
--[[ L["Show X Mark"] = "Show X Mark"--]] 
--[[Translation missing --]]
--[[ L["Show:"] = "Show:"--]] 
--[[Translation missing --]]
--[[ L["Shows a border ring around the entire frame when a boss debuff is active."] = "Shows a border ring around the entire frame when a boss debuff is active."--]] 
--[[Translation missing --]]
--[[ L["Shows a colored border/glow when a dispellable debuff is present."] = "Shows a colored border/glow when a dispellable debuff is present."--]] 
--[[Translation missing --]]
--[[ L["Shows a glow at max health when absorb exceeds the clamp limit."] = "Shows a glow at max health when absorb exceeds the clamp limit."--]] 
--[[Translation missing --]]
--[[ L["Shows an icon when an enemy is casting a spell targeting a party/raid member."] = "Shows an icon when an enemy is casting a spell targeting a party/raid member."--]] 
--[[Translation missing --]]
--[[ L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."] = "Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."--]] 
--[[Translation missing --]]
--[[ L["Shows effects that reduce incoming healing (like Necrotic stacks)."] = "Shows effects that reduce incoming healing (like Necrotic stacks)."--]] 
--[[Translation missing --]]
--[[ L["Shows icon when party members are missing raid buffs."] = "Shows icon when party members are missing raid buffs."--]] 
--[[Translation missing --]]
--[[ L["Shows incoming targeted spells on YOU in the center of your screen."] = "Shows incoming targeted spells on YOU in the center of your screen."--]] 
--[[Translation missing --]]
--[[ L["Shows the ping wheel & party management menu."] = "Shows the ping wheel & party management menu."--]] 
--[[Translation missing --]]
--[[ L["Single Select"] = "Single Select"--]] 
--[[Translation missing --]]
--[[ L["Size"] = "Size"--]] 
--[[Translation missing --]]
--[[ L["Size & Orientation"] = "Size & Orientation"--]] 
--[[Translation missing --]]
--[[ L["Size & Spacing"] = "Size & Spacing"--]] 
--[[Translation missing --]]
--[[ L["Skip for now"] = "Skip for now"--]] 
--[[Translation missing --]]
--[[ L["Skyfury (Shaman)"] = "Skyfury (Shaman)"--]] 
--[[Translation missing --]]
--[[ L["Smart Res:"] = "Smart Res:"--]] 
--[[Translation missing --]]
--[[ L["Smart Resurrection"] = "Smart Resurrection"--]] 
--[[Translation missing --]]
--[[ L["Smooth Bar Animation"] = "Smooth Bar Animation"--]] 
--[[Translation missing --]]
--[[ L["Snaps sizes and borders to exact pixels for crisp rendering."] = "Snaps sizes and borders to exact pixels for crisp rendering."--]] 
--[[Translation missing --]]
--[[ L["Solid (BLEND)"] = "Solid (BLEND)"--]] 
--[[Translation missing --]]
--[[ L["Solid Border"] = "Solid Border"--]] 
--[[Translation missing --]]
--[[ L["Solo Mode"] = "Solo Mode"--]] 
--[[Translation missing --]]
--[[ L["Solo mode %s"] = "Solo mode %s"--]] 
--[[Translation missing --]]
--[[ L["Solo Mode: Show your player frame when not in a group."] = "Solo Mode: Show your player frame when not in a group."--]] 
--[[Translation missing --]]
--[[ L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[Some bindings use spells that are not available
to your current class or specialization.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Sort by Class (within role)"] = "Sort by Class (within role)"--]] 
--[[Translation missing --]]
--[[ L["Sort Order"] = "Sort Order"--]] 
--[[Translation missing --]]
--[[ L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Sorted with Group"] = "Sorted with Group"--]] 
--[[Translation missing --]]
--[[ L["Sorting"] = "Sorting"--]] 
--[[Translation missing --]]
--[[ L["Sound"] = "Sound"--]] 
--[[Translation missing --]]
--[[ L["Sound Alert"] = "Sound Alert"--]] 
--[[Translation missing --]]
--[[ L["Sound Alerts"] = "Sound Alerts"--]] 
--[[Translation missing --]]
--[[ L["Sound file could not be played: %s"] = "Sound file could not be played: %s"--]] 
--[[Translation missing --]]
--[[ L["Source Mode"] = "Source Mode"--]] 
--[[Translation missing --]]
--[[ L["Spacing"] = "Spacing"--]] 
--[[Translation missing --]]
--[[ L["Spacing X"] = "Spacing X"--]] 
--[[Translation missing --]]
--[[ L["Spacing Y"] = "Spacing Y"--]] 
--[[Translation missing --]]
--[[ L["Spark"] = "Spark"--]] 
--[[Translation missing --]]
--[[ L["Spec Default"] = "Spec Default"--]] 
--[[Translation missing --]]
--[[ L["Spec:"] = "Spec:"--]] 
--[[Translation missing --]]
--[[ L["Specialization data not available."] = "Specialization data not available."--]] 
--[[Translation missing --]]
--[[ L["Spell:"] = "Spell:"--]] 
--[[Translation missing --]]
--[[ L["Spells"] = "Spells"--]] 
--[[Translation missing --]]
--[[ L["Spells flagged as important by Blizzard."] = "Spells flagged as important by Blizzard."--]] 
--[[Translation missing --]]
--[[ L["Square"] = "Square"--]] 
--[[Translation missing --]]
--[[ L["Stack Anchor"] = "Stack Anchor"--]] 
--[[Translation missing --]]
--[[ L["Stack Count"] = "Stack Count"--]] 
--[[Translation missing --]]
--[[ L["Stack Font"] = "Stack Font"--]] 
--[[Translation missing --]]
--[[ L["Stack Minimum"] = "Stack Minimum"--]] 
--[[Translation missing --]]
--[[ L["Stack Offset X"] = "Stack Offset X"--]] 
--[[Translation missing --]]
--[[ L["Stack Offset Y"] = "Stack Offset Y"--]] 
--[[Translation missing --]]
--[[ L["Stack Outline"] = "Stack Outline"--]] 
--[[Translation missing --]]
--[[ L["Stack Scale"] = "Stack Scale"--]] 
--[[Translation missing --]]
--[[ L["Stack Text"] = "Stack Text"--]] 
--[[Translation missing --]]
--[[ L["Stack Text Color"] = "Stack Text Color"--]] 
--[[Translation missing --]]
--[[ L["Standard Buffs are also visible on frames."] = "Standard Buffs are also visible on frames."--]] 
--[[Translation missing --]]
--[[ L["START"] = "START"--]] 
--[[Translation missing --]]
--[[ L["Start"] = "Start"--]] 
--[[Translation missing --]]
--[[ L["Start (Left/Top)"] = "Start (Left/Top)"--]] 
--[[Translation missing --]]
--[[ L["Start = Left/Top, End = Right/Bottom depending on direction."] = "Start = Left/Top, End = Right/Bottom depending on direction."--]] 
--[[Translation missing --]]
--[[ L["Start Delay (sec)"] = "Start Delay (sec)"--]] 
--[[Translation missing --]]
--[[ L["Start of Group"] = "Start of Group"--]] 
--[[Translation missing --]]
--[[ L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Status Icon Text Settings"] = "Status Icon Text Settings"--]] 
--[[Translation missing --]]
--[[ L["Status Text"] = "Status Text"--]] 
--[[Translation missing --]]
--[[ L["Status Text (Dead/Offline)"] = "Status Text (Dead/Offline)"--]] 
--[[Translation missing --]]
--[[ L["Status Text Alpha"] = "Status Text Alpha"--]] 
--[[Translation missing --]]
--[[ L["Step %d of %d"] = "Step %d of %d"--]] 
--[[Translation missing --]]
--[[ L["Step 1: Click here with desired key combo"] = "Step 1: Click here with desired key combo"--]] 
--[[Translation missing --]]
--[[ L["Step 2: Select Action"] = "Step 2: Select Action"--]] 
--[[Translation missing --]]
--[[ L["Step 3: Combat Condition (optional)"] = "Step 3: Combat Condition (optional)"--]] 
--[[Translation missing --]]
--[[ L["Step Editor"] = "Step Editor"--]] 
--[[Translation missing --]]
--[[ L["Step ID"] = "Step ID"--]] 
L["Steps"] = "Шаги"
L["Style"] = "Стиль"
--[[Translation missing --]]
--[[ L["Summary"] = "Summary"--]] 
--[[Translation missing --]]
--[[ L["Summary Step"] = "Summary Step"--]] 
--[[Translation missing --]]
--[[ L["Summon"] = "Summon"--]] 
--[[Translation missing --]]
--[[ L["Summon Icon"] = "Summon Icon"--]] 
--[[Translation missing --]]
--[[ L["Switched to profile: %s"] = "Switched to profile: %s"--]] 
--[[Translation missing --]]
--[[ L["Sync"] = "Sync"--]] 
--[[Translation missing --]]
--[[ L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Sync from WoW"] = "Sync from WoW"--]] 
--[[Translation missing --]]
--[[ L["Sync with %s"] = "Sync with %s"--]] 
--[[Translation missing --]]
--[[ L["Sync: %s"] = "Sync: %s"--]] 
--[[Translation missing --]]
--[[ L["Synced with %s"] = "Synced with %s"--]] 
--[[Translation missing --]]
--[[ L["Synced: %s"] = "Synced: %s"--]] 
L["Tank"] = "Танк"
--[[Translation missing --]]
--[[ L["Tanking (Red)"] = "Tanking (Red)"--]] 
L["Tanks"] = "Танки"
--[[Translation missing --]]
--[[ L["Target Type:"] = "Target Type:"--]] 
--[[Translation missing --]]
--[[ L["Target Unit"] = "Target Unit"--]] 
--[[Translation missing --]]
--[[ L["Targeted Spell Alpha"] = "Targeted Spell Alpha"--]] 
--[[Translation missing --]]
--[[ L["Targeted Spell Click-Through"] = "Targeted Spell Click-Through"--]] 
--[[Translation missing --]]
--[[ L["Targeted Spells"] = "Targeted Spells"--]] 
--[[Translation missing --]]
--[[ L["Targeted Spells (on frames)"] = "Targeted Spells (on frames)"--]] 
--[[Translation missing --]]
--[[ L["Targeting Fallback:"] = "Targeting Fallback:"--]] 
--[[Translation missing --]]
--[[ L["Targeting: %s"] = "Targeting: %s"--]] 
L["Test"] = "Тест"
L["Test Mode"] = "Тестовый режим"
L["Test mode disabled."] = "Тестовый режим деактивирован"
L["Test mode enabled."] = "Тестовый режим активирован."
L["Test mode ended — entering combat."] = "Тестовый режим завершен — вступил в бой."
L["Test Mode: %s"] = "Тестовый режим: %s"
L["Text"] = "Текст"
L["Text Color"] = "Цвет текста"
L["Text Colors:"] = "Цвет текста:"
L["Text Format"] = "Формат текста"
L["Text Scale"] = "Масштаб текста"
L["Texture"] = "Текстура"
L["Texture & Colors"] = "Текстура и Цвет"
--[[Translation missing --]]
--[[ L["The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."] = "The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."--]] 
--[[Translation missing --]]
--[[ L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."] = "These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."--]] 
--[[Translation missing --]]
--[[ L["Thick Outline"] = "Thick Outline"--]] 
--[[Translation missing --]]
--[[ L["Thickness"] = "Thickness"--]] 
--[[Translation missing --]]
--[[ L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = ""--]] 
L["this option"] = "эта опция"
--[[Translation missing --]]
--[[ L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["This setting differs from the global profile value. Click the reset button to revert."] = "This setting differs from the global profile value. Click the reset button to revert."--]] 
--[[Translation missing --]]
--[[ L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."] = "This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."--]] 
--[[Translation missing --]]
--[[ L["This step automatically shows a review of all the user's answers. It's always the last step."] = "This step automatically shows a review of all the user's answers. It's always the last step."--]] 
--[[Translation missing --]]
--[[ L["This warning will not appear again after confirming."] = "This warning will not appear again after confirming."--]] 
L["Threat Colors"] = "Цвет угрозы"
--[[Translation missing --]]
--[[ L["Threshold Mode"] = "Threshold Mode"--]] 
L["Time Remaining"] = "Оставшееся время"
--[[Translation missing --]]
--[[ L["Timing"] = "Timing"--]] 
L["Tint"] = "Оттенок"
L["Tint Color"] = "Цвет оттенка"
L["Tint Opacity"] = "Непрозрачность оттенка"
--[[Translation missing --]]
--[[ L[ [=[to customise
this profile's settings]=] ] = [=[to customise
this profile's settings]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[to customise
this profile's settings]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["To fix the ElvUI compatibility issue:"] = "To fix the ElvUI compatibility issue:"--]] 
--[[Translation missing --]]
--[[ L["To reposition: Unlock frames (/df unlock) and drag the mover."] = "To reposition: Unlock frames (/df unlock) and drag the mover."--]] 
--[[Translation missing --]]
--[[ L["Toggle Solo Mode"] = "Toggle Solo Mode"--]] 
--[[Translation missing --]]
--[[ L["Toggle Test Mode"] = "Toggle Test Mode"--]] 
L["Tooltips"] = "Подсказка"
L["Top"] = "Сверху"
--[[Translation missing --]]
--[[ L["Top Edge"] = "Top Edge"--]] 
L["Top Left"] = "Вверху слева"
L["Top Right"] = "Вверху справа"
L["Top to Bottom"] = "Сверху вниз"
L["Total:"] = "Всего:"
--[[Translation missing --]]
--[[ L["Track Highest Duration"] = "Track Highest Duration"--]] 
--[[Translation missing --]]
--[[ L["Track Lowest Duration"] = "Track Lowest Duration"--]] 
--[[Translation missing --]]
--[[ L["Trigger"] = "Trigger"--]] 
--[[Translation missing --]]
--[[ L["Trigger Mode"] = "Trigger Mode"--]] 
--[[Translation missing --]]
--[[ L["TRIGGERED BY"] = "TRIGGERED BY"--]] 
L["Truncate Mode"] = "Режим сокращения"
L["Truncation"] = "Сокращение"
L["Type"] = "Тип"
--[[Translation missing --]]
--[[ L["Type /dfarena again to disable"] = "Type /dfarena again to disable"--]] 
L["Type:"] = "Тип:"
L["UI Scale:"] = "Масштаб интерфейса"
--[[Translation missing --]]
--[[ L["Unit Frame"] = "Unit Frame"--]] 
--[[Translation missing --]]
--[[ L["Unit Frame Sorting"] = "Unit Frame Sorting"--]] 
--[[Translation missing --]]
--[[ L["Unit Selection"] = "Unit Selection"--]] 
--[[Translation missing --]]
--[[ L["Units at or above this health percent are faded."] = "Units at or above this health percent are faded."--]] 
--[[Translation missing --]]
--[[ L["Units Per Row"] = "Units Per Row"--]] 
L["Unknown"] = "Неизвестно"
L["Unknown error"] = "Неизвестная ошибка"
L["Unlock"] = "Разблокировать"
--[[Translation missing --]]
--[[ L["Unlock Frames"] = "Unlock Frames"--]] 
--[[Translation missing --]]
--[[ L["Unnamed"] = "Unnamed"--]] 
--[[Translation missing --]]
--[[ L["Up"] = "Up"--]] 
--[[Translation missing --]]
--[[ L["Use"] = "Use"--]] 
--[[Translation missing --]]
--[[ L["USE"] = "USE"--]] 
--[[Translation missing --]]
--[[ L["Use %s"] = "Use %s"--]] 
--[[Translation missing --]]
--[[ L["Use /df overrides for full details in chat"] = "Use /df overrides for full details in chat"--]] 
--[[Translation missing --]]
--[[ L["Use Class Color"] = "Use Class Color"--]] 
--[[Translation missing --]]
--[[ L["Use Current (%s)"] = "Use Current (%s)"--]] 
--[[Translation missing --]]
--[[ L["Use Current Value"] = "Use Current Value"--]] 
--[[Translation missing --]]
--[[ L["Use Custom Colors"] = "Use Custom Colors"--]] 
--[[Translation missing --]]
--[[ L["Use Custom Pip Color"] = "Use Custom Pip Color"--]] 
L["Use DandersFrames"] = "Использовать DandersFrames"
L["Use DF Color Picker"] = "Использовать выбор цвета DF"
--[[Translation missing --]]
--[[ L["Use DF Color Picker for All Addons"] = "Use DF Color Picker for All Addons"--]] 
--[[Translation missing --]]
--[[ L["Use FrameSort Addon"] = "Use FrameSort Addon"--]] 
--[[Translation missing --]]
--[[ L["Use Group-Based Layout"] = "Use Group-Based Layout"--]] 
L["Use recommended defaults"] = "Использовать настройки по умолчанию"
--[[Translation missing --]]
--[[ L["Use Seconds Instead of Percent"] = "Use Seconds Instead of Percent"--]] 
--[[Translation missing --]]
--[[ L["Uses a single border per frame. Highest priority wins."] = "Uses a single border per frame. Highest priority wins."--]] 
--[[Translation missing --]]
--[[ L["Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."] = "Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."--]] 
--[[Translation missing --]]
--[[ L["Uses party frame settings/position"] = "Uses party frame settings/position"--]] 
--[[Translation missing --]]
--[[ L["Using highest duration trigger"] = "Using highest duration trigger"--]] 
--[[Translation missing --]]
--[[ L["Using lowest duration trigger"] = "Using lowest duration trigger"--]] 
--[[Translation missing --]]
--[[ L["Using spec default"] = "Using spec default"--]] 
--[[Translation missing --]]
--[[ L["v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."] = "v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."--]] 
--[[Translation missing --]]
--[[ L["Valid range"] = "Valid range"--]] 
--[[Translation missing --]]
--[[ L["Value:"] = "Value:"--]] 
--[[Translation missing --]]
--[[ L["Vehicle"] = "Vehicle"--]] 
--[[Translation missing --]]
--[[ L["Vehicle Icon"] = "Vehicle Icon"--]] 
--[[Translation missing --]]
--[[ L["Vertical"] = "Vertical"--]] 
L["Vertical Spacing"] = "Отступ по вертикали"
--[[Translation missing --]]
--[[ L["View Imported Macro"] = "View Imported Macro"--]] 
L["Visibility"] = "Видимость"
L["Volume"] = "Громкость"
L["Warlock"] = "Чернокнижник"
L["Warnings + Errors"] = "Предупреждения + Ошибки"
L["Warrior"] = "Воин"
--[[Translation missing --]]
--[[ L["Weight"] = "Weight"--]] 
--[[Translation missing --]]
--[[ L["What should '%s' do with this setting?"] = "What should '%s' do with this setting?"--]] 
--[[Translation missing --]]
--[[ L["When \"%s\" selected:"] = "When \"%s\" selected:"--]] 
--[[Translation missing --]]
--[[ L["When auto-detect is OFF, select which raid buffs to monitor manually."] = "When auto-detect is OFF, select which raid buffs to monitor manually."--]] 
--[[Translation missing --]]
--[[ L["When disabled: Click spell to open Binding Editor."] = "When disabled: Click spell to open Binding Editor."--]] 
--[[Translation missing --]]
--[[ L["When enabled, a new profile will be automatically"] = "When enabled, a new profile will be automatically"--]] 
--[[Translation missing --]]
--[[ L["When enabled, all pips use a single custom color instead of the class-specific default."] = "When enabled, all pips use a single custom color instead of the class-specific default."--]] 
--[[Translation missing --]]
--[[ L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."] = "When enabled, all role icons are shown outside of combat. The filters below only apply during combat."--]] 
--[[Translation missing --]]
--[[ L["When enabled, click-casting bindings will be"] = "When enabled, click-casting bindings will be"--]] 
--[[Translation missing --]]
--[[ L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."] = "When enabled, Masque skins aura icons and borders. DF border settings will be disabled."--]] 
--[[Translation missing --]]
--[[ L["When enabled, shows incoming heals even if they would overheal."] = "When enabled, shows incoming heals even if they would overheal."--]] 
--[[Translation missing --]]
--[[ L["When enabled, the group you are in will always be displayed first."] = "When enabled, the group you are in will always be displayed first."--]] 
--[[Translation missing --]]
--[[ L["When enabled: Click spell, press key to bind instantly."] = "When enabled: Click spell, press key to bind instantly."--]] 
--[[Translation missing --]]
--[[ L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."] = "When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."--]] 
--[[Translation missing --]]
--[[ L["Which aura data source would you like to use?"] = "Which aura data source would you like to use?"--]] 
--[[Translation missing --]]
--[[ L["While editing, each setting shows its override status:"] = "While editing, each setting shows its override status:"--]] 
--[[Translation missing --]]
--[[ L["Whitelist buffs take priority for the expiring indicator."] = "Whitelist buffs take priority for the expiring indicator."--]] 
--[[Translation missing --]]
--[[ L["WHITELISTED"] = "WHITELISTED"--]] 
--[[Translation missing --]]
--[[ L["Whole Alpha Pulse"] = "Whole Alpha Pulse"--]] 
L["Width"] = "Ширина"
L["Width / Length"] = "Ширина / Длина"
--[[Translation missing --]]
--[[ L["Will auto-create on switch"] = "Will auto-create on switch"--]] 
--[[Translation missing --]]
--[[ L["Will replace existing Mythic layout"] = "Will replace existing Mythic layout"--]] 
--[[Translation missing --]]
--[[ L["Wizard"] = "Wizard"--]] 
--[[Translation missing --]]
--[[ L["Wizard '%s' saved!"] = "Wizard '%s' saved!"--]] 
--[[Translation missing --]]
--[[ L["Wizard Builder"] = "Wizard Builder"--]] 
--[[Translation missing --]]
--[[ L["Wizard Details"] = "Wizard Details"--]] 
--[[Translation missing --]]
--[[ L["Wizard Name:"] = "Wizard Name:"--]] 
--[[Translation missing --]]
--[[ L["Works when hovering frames. Action bars work when not hovering."] = "Works when hovering frames. Action bars work when not hovering."--]] 
--[[Translation missing --]]
--[[ L["World bosses, outdoor raids (1-40)"] = "World bosses, outdoor raids (1-40)"--]] 
--[[Translation missing --]]
--[[ L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=]--]] 
--[[Translation missing --]]
--[[ L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would you like to set up your aura filters?"] = "Would you like to set up your aura filters?"--]] 
--[[Translation missing --]]
--[[ L["X Color"] = "X Color"--]] 
--[[Translation missing --]]
--[[ L["X Mark"] = "X Mark"--]] 
--[[Translation missing --]]
--[[ L["X Size"] = "X Size"--]] 
--[[Translation missing --]]
--[[ L["Yellow=high, Orange=highest, Red=tanking."] = "Yellow=high, Orange=highest, Red=tanking."--]] 
L["Yes"] = "Да"
--[[Translation missing --]]
--[[ L["Yes, set it up"] = "Yes, set it up"--]] 
L["YOUR PROFILES"] = "Ваши профили"
L["Z to A"] = "От Я до А"

