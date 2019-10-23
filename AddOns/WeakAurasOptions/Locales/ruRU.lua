if not WeakAuras.IsCorrectVersion() then return end

if not(GetLocale() == "ruRU") then
  return
end

local L = WeakAuras.L

-- WeakAuras/Options
	--[[Translation missing --]]
	L[" by "] = " by "
	L["-- Do not remove this comment, it is part of this trigger: "] = "-- Не удаляйте этот комментарий, он является частью этого триггера: "
	--[[Translation missing --]]
	L[" to version "] = " to version "
	L["% of Progress"] = "% прогресса"
	L["%i auras selected"] = "%i |4индикация выбрана:индикации выбраны:индикаций выбрано;"
	L["%i Matches"] = "%i |4совпадение:совпадения:совпадений;"
	--[[Translation missing --]]
	L["%s - Option #%i has the key %s. Please choose a different option key."] = "%s - Option #%i has the key %s. Please choose a different option key."
	--[[Translation missing --]]
	L["%s %s, Lines: %d, Frequency: %0.2f, Length: %d, Thickness: %d"] = "%s %s, Lines: %d, Frequency: %0.2f, Length: %d, Thickness: %d"
	--[[Translation missing --]]
	L["%s %s, Particles: %d, Frequency: %0.2f, Scale: %0.2f"] = "%s %s, Particles: %d, Frequency: %0.2f, Scale: %0.2f"
	--[[Translation missing --]]
	L["%s Alpha: %d%%"] = "%s Alpha: %d%%"
	L["%s Color"] = "%s "
	--[[Translation missing --]]
	L["%s Default Alpha, Zoom, Icon Inset, Aspect Ratio"] = "%s Default Alpha, Zoom, Icon Inset, Aspect Ratio"
	--[[Translation missing --]]
	L["%s Inset: %d%%"] = "%s Inset: %d%%"
	--[[Translation missing --]]
	L["%s is not a valid SubEvent for COMBAT_LOG_EVENT_UNFILTERED"] = "%s is not a valid SubEvent for COMBAT_LOG_EVENT_UNFILTERED"
	--[[Translation missing --]]
	L["%s Keep Aspect Ratio"] = "%s Keep Aspect Ratio"
	L["%s total auras"] = "Всего %s |4индикация:индикации:индикаций;"
	--[[Translation missing --]]
	L["%s Zoom: %d%%"] = "%s Zoom: %d%%"
	--[[Translation missing --]]
	L["%s, Border"] = "%s, Border"
	--[[Translation missing --]]
	L["%s, Offset: %0.2f;%0.2f"] = "%s, Offset: %0.2f;%0.2f"
	--[[Translation missing --]]
	L["%s, offset: %0.2f;%0.2f"] = "%s, offset: %0.2f;%0.2f"
	--[[Translation missing --]]
	L["|c%02x%02x%02x%02xColor|r"] = "|c%02x%02x%02x%02xColor|r"
	--[[Translation missing --]]
	L["|cFFA9A9A9--Please Create an Entry--"] = "|cFFA9A9A9--Please Create an Entry--"
	--[[Translation missing --]]
	L["|cFFffcc00Anchors:|r Anchored |cFFFF0000%s|r to frame's |cFFFF0000%s|r"] = "|cFFffcc00Anchors:|r Anchored |cFFFF0000%s|r to frame's |cFFFF0000%s|r"
	--[[Translation missing --]]
	L["|cFFffcc00Anchors:|r Anchored |cFFFF0000%s|r to frame's |cFFFF0000%s|r with offset |cFFFF0000%s/%s|r"] = "|cFFffcc00Anchors:|r Anchored |cFFFF0000%s|r to frame's |cFFFF0000%s|r with offset |cFFFF0000%s/%s|r"
	--[[Translation missing --]]
	L["|cFFffcc00Anchors:|r Anchored to frame's |cFFFF0000%s|r"] = "|cFFffcc00Anchors:|r Anchored to frame's |cFFFF0000%s|r"
	--[[Translation missing --]]
	L["|cFFffcc00Anchors:|r Anchored to frame's |cFFFF0000%s|r with offset |cFFFF0000%s/%s|r"] = "|cFFffcc00Anchors:|r Anchored to frame's |cFFFF0000%s|r with offset |cFFFF0000%s/%s|r"
	--[[Translation missing --]]
	L["|cFFffcc00Extra Options:|r"] = "|cFFffcc00Extra Options:|r"
	--[[Translation missing --]]
	L["|cFFffcc00Font Flags:|r |cFFFF0000%s|r and shadow |c%sColor|r with offset |cFFFF0000%s/%s|r%s%s"] = "|cFFffcc00Font Flags:|r |cFFFF0000%s|r and shadow |c%sColor|r with offset |cFFFF0000%s/%s|r%s%s"
	L["1 Match"] = "1 cовпадение"
	L["A 20x20 pixels icon"] = "Иконка 20х20 пикселей"
	L["A 32x32 pixels icon"] = "Иконка 32х32 пикселей"
	L["A 40x40 pixels icon"] = "Иконка 40х40 пикселей"
	L["A 48x48 pixels icon"] = "Иконка 48х48 пикселей"
	L["A 64x64 pixels icon"] = "Иконка 64х64 пикселей"
	L["A group that dynamically controls the positioning of its children"] = "Группа, динамически изменяющая позиции своих индикаций"
	--[[Translation missing --]]
	L["A Unit ID (e.g., party1)."] = "A Unit ID (e.g., party1)."
	L["Actions"] = "Действия"
	--[[Translation missing --]]
	L["Add %s"] = "Add %s"
	L["Add a new display"] = "Добавить новую индикацию"
	L["Add Condition"] = "Добавить условие"
	--[[Translation missing --]]
	L["Add Entry"] = "Add Entry"
	--[[Translation missing --]]
	L["Add Extra Elements"] = "Add Extra Elements"
	--[[Translation missing --]]
	L["Add Option"] = "Add Option"
	L["Add Overlay"] = "Добавить наложение (дополнительный прогресс)"
	L["Add Property Change"] = "Добавить свойство"
	--[[Translation missing --]]
	L["Add Sub Option"] = "Add Sub Option"
	L["Add to group %s"] = "Добавить в группу %s"
	L["Add to new Dynamic Group"] = "Добавить в новую динамическую группу"
	L["Add to new Group"] = "Добавить в новую группу"
	L["Add Trigger"] = "Добавить триггер"
	L["Addon"] = "Аддон"
	L["Addons"] = "Аддоны"
	L["Advanced"] = "Комплексный подход"
	L["Align"] = "Выравнивание"
	--[[Translation missing --]]
	L["Alignment"] = "Alignment"
	L["All of"] = "И (все условия)"
	L["Allow Full Rotation"] = "Разрешить полное вращение"
	L["Alpha"] = "Прозрачность"
	L["Anchor"] = "Крепление"
	L["Anchor Point"] = "Точка крепления"
	L["Anchored To"] = "Прикрепить к"
	L["And "] = "И "
	--[[Translation missing --]]
	L["and aligned left"] = "and aligned left"
	--[[Translation missing --]]
	L["and aligned right"] = "and aligned right"
	--[[Translation missing --]]
	L["and rotated left"] = "and rotated left"
	--[[Translation missing --]]
	L["and rotated right"] = "and rotated right"
	L["and Trigger %s"] = "Триггер %s"
	L["Angle"] = "Угол"
	L["Animate"] = "Анимация"
	L["Animated Expand and Collapse"] = "Анимированное сворачивание и разворачивание"
	L["Animates progress changes"] = "Изменение прогресса отображается при помощи анимации"
	L["Animation relative duration description"] = [=[Длительность анимации относительно длительности индикации, выраженная в виде обыкновенной (1/2) или десятичной (0.5) дробей, процента (50%).

|cFFFF0000Замечание:|r если у индикации нет прогресса (аура без длительности, триггер события без времени и т. д.), то анимация не будет отображаться.

|cFF4444FFПримеры:|r
Если длительность анимации установлена в |cFF00CC0010%|r и триггер индикации - это бафф длительностью 20 секунд, то анимация будет отображаться в течение 2 секунд.
Если длительность анимации установлена в |cFF00CC0010%|r и триггер индикации - это бесконечная аура, то анимация отображаться не будет (хотя могла бы, если бы вы указали длительность в секундах).]=]
	L["Animation Sequence"] = "Цепочка анимаций"
	L["Animations"] = "Анимация"
	L["Any of"] = "ИЛИ (любое условие)"
	L["Apply Template"] = "Применить шаблон"
	--[[Translation missing --]]
	L["Arc Length"] = "Arc Length"
	L["Arcane Orb"] = "Чародейский шар"
	L["At a position a bit left of Left HUD position."] = "Немного левее позиции левого HUD"
	L["At a position a bit left of Right HUD position"] = "Немного правее позиции правого HUD"
	L["At the same position as Blizzard's spell alert"] = "В таком же положении, как предупреждение заклинаний Blizzard"
	L["Aura Name"] = "Название ауры"
	--[[Translation missing --]]
	L["Aura Name Pattern"] = "Aura Name Pattern"
	L["Aura Type"] = "Тип эффекта"
	L["Aura(s)"] = "Эффекты"
	--[[Translation missing --]]
	L["Author Options"] = "Author Options"
	L["Auto"] = "Авто"
	--[[Translation missing --]]
	L["Auto-Clone (Show All Matches)"] = "Auto-Clone (Show All Matches)"
	L["Auto-cloning enabled"] = "Автоклонирование включено"
	--[[Translation missing --]]
	L["Automatic"] = "Automatic"
	L["Automatic Icon"] = "Автоматическая иконка"
	L["Backdrop Color"] = "Цвет фона"
	L["Backdrop in Front"] = "Фон спереди"
	L["Backdrop Style"] = "Стиль фона"
	--[[Translation missing --]]
	L["Background"] = "Background"
	L["Background Color"] = "Цвет подложки"
	L["Background Offset"] = "Смещение подложки"
	L["Background Texture"] = "Текстура подложки"
	--[[Translation missing --]]
	L["Bar"] = "Bar"
	L["Bar Alpha"] = "Прозрачность полосы"
	L["Bar Color"] = "Цвет полосы"
	L["Bar Color Settings"] = "Настройки цвета полосы"
	--[[Translation missing --]]
	L["Bar Inner"] = "Bar Inner"
	L["Bar Texture"] = "Текстура полосы"
	L["Big Icon"] = "Большая иконка"
	L["Blend Mode"] = "Режим наложения"
	L["Blue Rune"] = "Синяя руна"
	L["Blue Sparkle Orb"] = "Синий искрящийся шар"
	L["Border"] = "Граница"
	--[[Translation missing --]]
	L["Border %s"] = "Border %s"
	--[[Translation missing --]]
	L["Border Anchor"] = "Border Anchor"
	L["Border Color"] = "Цвет границы"
	L["Border in Front"] = "Граница спереди"
	L["Border Inset"] = "Вставка границы"
	L["Border Offset"] = "Смещение границы"
	L["Border Settings"] = "Настройки границы"
	L["Border Size"] = "Размер границы"
	L["Border Style"] = "Стиль границы"
	--[[Translation missing --]]
	L["Bottom"] = "Bottom"
	--[[Translation missing --]]
	L["Bottom Left"] = "Bottom Left"
	--[[Translation missing --]]
	L["Bottom Right"] = "Bottom Right"
	L["Bracket Matching"] = "Закрывать скобки"
	L["Button Glow"] = "Подсветка кнопки"
	--[[Translation missing --]]
	L["Can be a Name or a Unit ID (e.g. party1). A name only works on friendly players in your group."] = "Can be a Name or a Unit ID (e.g. party1). A name only works on friendly players in your group."
	--[[Translation missing --]]
	L["Can be a UID (e.g., party1)."] = "Can be a UID (e.g., party1)."
	L["Cancel"] = "Отмена"
	--[[Translation missing --]]
	L["Center"] = "Center"
	L["Channel Number"] = "Номер канала"
	L["Chat Message"] = "Сообщение в чат"
	L["Check On..."] = "Проверять..."
	L["Children:"] = "Индикации:"
	L["Choose"] = "Выбрать"
	L["Choose Trigger"] = "Выберите триггер"
	L["Choose whether the displayed icon is automatic or defined manually"] = "Выберите, будет ли иконка задана автоматически или вручную"
	--[[Translation missing --]]
	L["Clip Overlays"] = "Clip Overlays"
	--[[Translation missing --]]
	L["Clipped by Progress"] = "Clipped by Progress"
	L["Clone option enabled dialog"] = [=[Вы активировали параметр, использующий |cFFFF0000Автоклонирование|r.

|cFFFF0000Автоклонирование|r заставляет индикацию автоматически дублироваться для отображения нескольких источников информации. Если вы не разместите ее в |cFF22AA22Динамической группе|r, то все клоны будут отображаться друг над другом в большой куче.

Вы хотите поместить эту индикацию в новую |cFF22AA22Динамическую группу|r?]=]
	L["Close"] = "Закрыть"
	L["Collapse"] = "Свернуть"
	L["Collapse all loaded displays"] = "Свернуть все загруженные индикации"
	L["Collapse all non-loaded displays"] = "Свернуть все не загруженные индикации"
	--[[Translation missing --]]
	L["Collapsible Group"] = "Collapsible Group"
	L["color"] = "цвет"
	L["Color"] = "Цвет"
	--[[Translation missing --]]
	L["Column Height"] = "Column Height"
	--[[Translation missing --]]
	L["Column Space"] = "Column Space"
	L["Combinations"] = "Логические операции"
	--[[Translation missing --]]
	L["Combine Matches Per Unit"] = "Combine Matches Per Unit"
	--[[Translation missing --]]
	L["Common Text"] = "Common Text"
	--[[Translation missing --]]
	L["Compare against the number of units affected."] = "Compare against the number of units affected."
	L["Compress"] = "Сжать"
	L["Condition %i"] = "Условие %i"
	L["Conditions"] = "Условия"
	--[[Translation missing --]]
	L["Configure what options appear on this panel."] = "Configure what options appear on this panel."
	L["Constant Factor"] = "Постоянный параметр"
	L["Control-click to select multiple displays"] = "Ctrl-клик для выбора нескольких индикаций"
	L["Controls the positioning and configuration of multiple displays at the same time"] = "Управляет позиционированием и настройкой нескольких индикаций одновременно"
	--[[Translation missing --]]
	L["Convert to New Aura Trigger"] = "Convert to New Aura Trigger"
	L["Convert to..."] = "Преобразовать в ..."
	--[[Translation missing --]]
	L["Cooldown Edge"] = "Cooldown Edge"
	--[[Translation missing --]]
	L["Cooldown Settings"] = "Cooldown Settings"
	--[[Translation missing --]]
	L["Cooldown Swipe"] = "Cooldown Swipe"
	--[[Translation missing --]]
	L["Copy"] = "Copy"
	L["Copy settings..."] = "Копировать настройки из ..."
	L["Copy to all auras"] = "Копировать во все индикации"
	L["Copy URL"] = "Копировать строку URL"
	L["Count"] = "Кол-во"
	--[[Translation missing --]]
	L["Counts the number of matches over all units."] = "Counts the number of matches over all units."
	L["Creating buttons: "] = "Создание кнопок:"
	L["Creating options: "] = "Создание настроек:"
	L["Crop X"] = "Обрезать по X"
	L["Crop Y"] = "Обрезать по Y"
	L["Custom"] = "Самостоятельно"
	--[[Translation missing --]]
	L["Custom Anchor"] = "Custom Anchor"
	L["Custom Code"] = "Свой код"
	--[[Translation missing --]]
	L["Custom Configuration"] = "Custom Configuration"
	--[[Translation missing --]]
	L["Custom Frames"] = "Custom Frames"
	L["Custom Function"] = "Своя функция"
	--[[Translation missing --]]
	L["Custom Grow"] = "Custom Grow"
	--[[Translation missing --]]
	L["Custom Options"] = "Custom Options"
	--[[Translation missing --]]
	L["Custom Sort"] = "Custom Sort"
	L["Custom Trigger"] = "Свой триггер"
	L["Custom trigger event tooltip"] = [=[Напишите события, которые будут вызывать проверку вашего триггера. Несколько событий должны быть разделены запятыми или пробелами.

|cFF4444FFПример:|r
UNIT_POWER  UNIT_AURA, PLAYER_TARGET_CHANGED]=]
	L["Custom trigger status tooltip"] = [=[Напишите события, которые будут вызывать проверку вашего триггера. Несколько событий должны быть разделены запятыми или пробелами.
Поскольку это триггер статуса, указанные события могут быть переданы WeakAuras без ожидаемых аргументов.

|cFF4444FFПример:|r
UNIT_POWER  UNIT_AURA, PLAYER_TARGET_CHANGED]=]
	L["Custom Untrigger"] = "Свой детриггер"
	L["Custom Variables"] = "Свои переменные"
	L["Debuff Type"] = "Тип дебаффа"
	L["Default"] = "По умолчанию"
	--[[Translation missing --]]
	L["Default Color"] = "Default Color"
	L["Delete"] = "Удалить"
	L["Delete all"] = "Удалить всё"
	L["Delete children and group"] = "Удалить индикации и группу"
	--[[Translation missing --]]
	L["Delete Entry"] = "Delete Entry"
	L["Delete Trigger"] = "Удалить триггер"
	L["Desaturate"] = "Обесцветить"
	--[[Translation missing --]]
	L["Description Text"] = "Description Text"
	--[[Translation missing --]]
	L["Determines how many entries can be in the table."] = "Determines how many entries can be in the table."
	L["Differences"] = "Различия"
	L["Disable Import"] = "Отключить импорт"
	L["Disabled"] = "Выключено"
	L["Discrete Rotation"] = "Дискретный поворот"
	L["Display"] = "Отображение"
	L["Display Icon"] = "Отображать иконку"
	--[[Translation missing --]]
	L["Display Name"] = "Display Name"
	L["Display Text"] = "Отображать текст"
	L["Displays a text, works best in combination with other displays"] = "Отображает текст, лучше всего работает в сочетании с другими индикациями"
	L["Distribute Horizontally"] = "Распределить по горизонтали"
	L["Distribute Vertically"] = "Распределить по вертикали"
	L["Do not group this display"] = "Не группировать эту индикацию"
	L["Done"] = "Выполнено"
	--[[Translation missing --]]
	L["Don't skip this Version"] = "Don't skip this Version"
	L["Down"] = "Переместить вниз"
	L["Drag to move"] = "Перетащите для перемещения"
	L["Duplicate"] = "Дублировать"
	L["Duplicate All"] = "Дублировать все"
	L["Duration (s)"] = "Длительность"
	L["Duration Info"] = "Информация о длительности"
	L["Dynamic Duration"] = "Динамическое значение"
	L["Dynamic Group"] = "Динамическая группа"
	--[[Translation missing --]]
	L["Dynamic Group Settings"] = "Dynamic Group Settings"
	L["Dynamic Information"] = "Динамическая информация"
	L["Dynamic information from first active trigger"] = "Динамическая информация из первого активного триггера"
	L["Dynamic information from Trigger %i"] = "Динамическая информация из Триггера %i"
	L["Dynamic text tooltip"] = [=[Несколько специальных кодов для отображения динамической информации в тексте:

|cFFFF0000%p|r - Прогресс - Оставшееся время таймера или текущее бестаймерное значение
|cFFFF0000%t|r - Всего - Максимальное время таймера или бестаймерное значение
|cFFFF0000%n|r - Название - Название эффекта, заклинания, предмета и т. д. или ID индикации
|cFFFF0000%i|r - Иконка - Иконка, связанная с индикацией
|cFFFF0000%s|r - Стаки - Количество стаков эффекта, предмета, зарядов заклинания и т. д.
|cFFFF0000%c|r - Свой код - Позволяет написать функцию на Lua, которая возвращает одно значение или их список. Для отображения единственного значения используйте |cFFFF0000%c|r, для n-го значения из списка - |cFFFF0000%cn|r]=]
	--[[Translation missing --]]
	L["Edge"] = "Edge"
	L["Enabled"] = "Включено"
	L["End Angle"] = "Конечный угол"
	--[[Translation missing --]]
	L["End of %s"] = "End of %s"
	--[[Translation missing --]]
	L["Enter a Spell ID"] = "Enter a Spell ID"
	L["Enter an aura name, partial aura name, or spell id"] = "Введите полное название эффекта, часть его названия или ID заклинания."
	--[[Translation missing --]]
	L["Enter an Aura Name, partial Aura Name, or Spell ID. A Spell ID will match any spells with the same name."] = "Enter an Aura Name, partial Aura Name, or Spell ID. A Spell ID will match any spells with the same name."
	--[[Translation missing --]]
	L["Enter Author Mode"] = "Enter Author Mode"
	--[[Translation missing --]]
	L["Enter User Mode"] = "Enter User Mode"
	--[[Translation missing --]]
	L["Enter user mode."] = "Enter user mode."
	--[[Translation missing --]]
	L["Entry %i"] = "Entry %i"
	--[[Translation missing --]]
	L["Entry limit"] = "Entry limit"
	L["Event"] = "Событие"
	L["Event Type"] = "Тип триггера"
	L["Event(s)"] = "Событие(я)"
	L["Everything"] = "Всех вкладок"
	--[[Translation missing --]]
	L["Exact Spell ID(s)"] = "Exact Spell ID(s)"
	L["Exact Spell Match"] = "Точное совпадение"
	L["Expand"] = "Развернуть"
	L["Expand all loaded displays"] = "Развернуть все загруженные индикации"
	L["Expand all non-loaded displays"] = "Развернуть все не загруженные индикации"
	L["Expansion is disabled because this group has no children"] = "Расширение отключено, так как эта группа не имеет индикаций"
	L["Export to Lua table..."] = "Экспорт в таблицу Lua ..."
	L["Export to string..."] = "Экспорт в строку ..."
	L["External"] = "Внешний ресурс"
	L["Fade"] = "Выцветание"
	L["Fade In"] = "Появление"
	L["Fade Out"] = "Исчезновение"
	L["False"] = "Ложь"
	--[[Translation missing --]]
	L["Fetch Affected/Unaffected Names"] = "Fetch Affected/Unaffected Names"
	L["Filter by Group Role"] = "Применить фильтр:"
	L["Finish"] = "Конечная"
	L["Fire Orb"] = "Огненный шар"
	L["Font"] = "Шрифт"
	L["Font Size"] = "Размер шрифта"
	--[[Translation missing --]]
	L["Foreground"] = "Foreground"
	L["Foreground Color"] = "Основной цвет"
	L["Foreground Texture"] = "Основная текстура"
	L["Frame"] = "Кадр"
	L["Frame Strata"] = "Слой кадра"
	--[[Translation missing --]]
	L["Frequency"] = "Frequency"
	L["From Template"] = "Из шаблона"
	--[[Translation missing --]]
	L["From version "] = "From version "
	L["Global Conditions"] = "Универсальные условия"
	L["Glow Action"] = "Действие"
	--[[Translation missing --]]
	L["Glow Color"] = "Glow Color"
	--[[Translation missing --]]
	L["Glow Settings"] = "Glow Settings"
	--[[Translation missing --]]
	L["Glow Type"] = "Glow Type"
	L["Green Rune"] = "Зеленая руна"
	--[[Translation missing --]]
	L["Grid direction"] = "Grid direction"
	L["Group"] = "Группа"
	L["Group (verb)"] = "Группировать"
	L["Group aura count description"] = [=[Количество участников группы (рейда), к которым должен быть применен один или более данных эффектов, чтобы триггер сработал.

Если указано целое число (5), то количество человек с этим эффектом будет сравниваться с введенным числом. Если указана обыкновенная (1/2) или десятичная (0.5) дроби, процент (50%%), то эта часть участников группы (рейда) и будет использована в сравнении.

|cFF4444FFПримеры:|r
|cFF00CC00> 0|r - сработает, когда кто-нибудь из группы попал под воздействие
|cFF00CC00= 100%%|r - сработает, когда вся группа попала под воздействие
|cFF00CC00!= 2|r - сработает, если число человек с этим эффектом не равно 2 (0 или 1 или >2)
|cFF00CC00<= 0.8|r - сработает, если менее 80%% группы под воздействием эффекта (4 из 5, 7 из 10 человек)
|cFF00CC00> 1/2|r - сработает, если больше половины группы по воздействием эффекта (5 из 5, 6 из 10 человек)
|cFF00CC00>= 0|r - всегда срабатывает, несмотря ни на что]=]
	--[[Translation missing --]]
	L["Group by Frame"] = "Group by Frame"
	--[[Translation missing --]]
	L["Group contains updates from Wago"] = "Group contains updates from Wago"
	--[[Translation missing --]]
	L["Group Icon"] = "Group Icon"
	--[[Translation missing --]]
	L["Group key"] = "Group key"
	L["Group Member Count"] = "Кол-во участников"
	L["Group Role"] = "Роль в группе"
	L["Group Scale"] = "Масштаб группы"
	--[[Translation missing --]]
	L["Group Settings"] = "Group Settings"
	--[[Translation missing --]]
	L["Group Type"] = "Group Type"
	L["Grow"] = "Направление роста"
	L["Hawk"] = "Ястреб"
	L["Height"] = "Высота"
	L["Hide"] = "Скрыть"
	--[[Translation missing --]]
	L["Hide Cooldown Text"] = "Hide Cooldown Text"
	--[[Translation missing --]]
	L["Hide Extra Options"] = "Hide Extra Options"
	L["Hide on"] = "Скрыть на"
	L["Hide this group's children"] = "Скрыть индикации этой группы"
	L["Hide When Not In Group"] = "Скрыть когда не в группе"
	L["Horizontal Align"] = "Выравнивание по горизонтали"
	L["Horizontal Bar"] = "Горизонтальная полоса"
	L["Huge Icon"] = "Огромная иконка"
	L["Hybrid Position"] = "Гибридная позиция"
	L["Hybrid Sort Mode"] = "Режим гибридной сортировки"
	L["Icon"] = "Иконка"
	L["Icon Info"] = "Информация об иконке"
	L["Icon Inset"] = "Вставка иконки"
	--[[Translation missing --]]
	L["Icon Position"] = "Icon Position"
	--[[Translation missing --]]
	L["Icon Settings"] = "Icon Settings"
	L["If"] = "Если"
	--[[Translation missing --]]
	L["If checked, then the user will see a multi line edit box. This is useful for inputting large amounts of text."] = "If checked, then the user will see a multi line edit box. This is useful for inputting large amounts of text."
	--[[Translation missing --]]
	L["If checked, then this option group can be temporarily collapsed by the user."] = "If checked, then this option group can be temporarily collapsed by the user."
	--[[Translation missing --]]
	L["If checked, then this option group will start collapsed."] = "If checked, then this option group will start collapsed."
	--[[Translation missing --]]
	L["If checked, then this separator will include text. Otherwise, it will be just a horizontal line."] = "If checked, then this separator will include text. Otherwise, it will be just a horizontal line."
	--[[Translation missing --]]
	L["If checked, then this space will span across multiple lines."] = "If checked, then this space will span across multiple lines."
	L["If this option is enabled, you are no longer able to import auras."] = "Если этот параметр включен, то вы больше не сможете импортировать индикации"
	L["If Trigger %s"] = "Если Триггер %s"
	--[[Translation missing --]]
	L["If unchecked, then a default color will be used (usually yellow)"] = "If unchecked, then a default color will be used (usually yellow)"
	--[[Translation missing --]]
	L["If unchecked, then this space will fill the entire line it is on in User Mode."] = "If unchecked, then this space will fill the entire line it is on in User Mode."
	--[[Translation missing --]]
	L["Ignore all Updates"] = "Ignore all Updates"
	--[[Translation missing --]]
	L["Ignore Self"] = "Ignore Self"
	L["Ignore self"] = "Исключить себя из числа участников"
	L["Ignored"] = "Игнорируется"
	L["Import"] = "Импорт"
	L["Import a display from an encoded string"] = "Импортировать индикацию из закодированной строки"
	--[[Translation missing --]]
	L["Inner"] = "Inner"
	L["Invalid Item Name/ID/Link"] = "Неверное название, ссылка или ID предмета"
	L["Invalid Spell ID"] = "Неверный ID заклинания"
	L["Invalid Spell Name/ID/Link"] = "Неверное название, ссылка или ID заклинания"
	L["Inverse"] = "Обратная"
	L["Inverse Slant"] = "В обратную сторону"
	--[[Translation missing --]]
	L["Is Stealable"] = "Is Stealable"
	L["Justify"] = "Выравнивание"
	L["Keep Aspect Ratio"] = "Сохранять пропорции"
	--[[Translation missing --]]
	L["Large Input"] = "Large Input"
	L["Leaf"] = "Лист"
	--[[Translation missing --]]
	L["Left"] = "Left"
	L["Left 2 HUD position"] = "Позиция 2-го левого HUD"
	L["Left HUD position"] = "Позиция левого HUD"
	--[[Translation missing --]]
	L["Legacy Aura Trigger"] = "Legacy Aura Trigger"
	--[[Translation missing --]]
	L["Length"] = "Length"
	--[[Translation missing --]]
	L["Limit"] = "Limit"
	--[[Translation missing --]]
	L["Lines & Particles"] = "Lines & Particles"
	L["Load"] = "Загрузка"
	L["Loaded"] = "Загружено"
	L["Loop"] = "Зациклить"
	L["Low Mana"] = "Мало маны"
	L["Main"] = "Основная"
	L["Manage displays defined by Addons"] = "Управление индикациями, определенными аддонами"
	--[[Translation missing --]]
	L["Match Count"] = "Match Count"
	--[[Translation missing --]]
	L["Max"] = "Max"
	--[[Translation missing --]]
	L["Max Length"] = "Max Length"
	L["Medium Icon"] = "Средняя иконка"
	L["Message"] = "Сообщение"
	L["Message Prefix"] = "Префикс сообщения"
	L["Message Suffix"] = "Суффикс сообщения"
	L["Message Type"] = "Тип сообщения"
	--[[Translation missing --]]
	L["Min"] = "Min"
	L["Mirror"] = "Отразить"
	L["Model"] = "Модель"
	--[[Translation missing --]]
	L["Model %s"] = "Model %s"
	--[[Translation missing --]]
	L["Model Settings"] = "Model Settings"
	--[[Translation missing --]]
	L["Move Above Group"] = "Move Above Group"
	--[[Translation missing --]]
	L["Move Below Group"] = "Move Below Group"
	L["Move Down"] = "Переместить вниз"
	--[[Translation missing --]]
	L["Move Entry Up"] = "Move Entry Up"
	--[[Translation missing --]]
	L["Move Into Above Group"] = "Move Into Above Group"
	--[[Translation missing --]]
	L["Move Into Below Group"] = "Move Into Below Group"
	L["Move this display down in its group's order"] = "Переместить индикацию вниз в порядке элементов группы"
	L["Move this display up in its group's order"] = "Переместить индикацию вверх в порядке элементов группы"
	L["Move Up"] = "Переместить вверх"
	L["Multiple Displays"] = "Несколько индикаций"
	L["Multiple Triggers"] = "Несколько триггеров"
	L["Multiselect ignored tooltip"] = [=[
|cFFFF0000Ничего|r - |cFF777777Одно|r - |cFF777777Несколько|r
Этот параметр не определяет, когда индикация должна быть загружена]=]
	L["Multiselect multiple tooltip"] = [=[
|cFF777777Ничего|r - |cFF777777Одно|r - |cFF00FF00Несколько|r
Можно выбрать любое количество соответствующих значений. Выполнение любого условия приведет к загрузке]=]
	L["Multiselect single tooltip"] = [=[
|cFF777777Ничего|r - |cFF00FF00Одно|r - |cFF777777Несколько|r
Можно выбрать только одно соответствующее значение]=]
	L["Name Info"] = "Информация о названии"
	--[[Translation missing --]]
	L["Name Pattern Match"] = "Name Pattern Match"
	--[[Translation missing --]]
	L["Name(s)"] = "Name(s)"
	--[[Translation missing --]]
	L["Nameplates"] = "Nameplates"
	L["Negator"] = "Не"
	L["Never"] = "Никогда"
	L["New"] = "Новая индикация"
	--[[Translation missing --]]
	L["New Value"] = "New Value"
	L["No"] = "Нет"
	L["No Children"] = "Нет индикаций"
	L["No tooltip text"] = "Без подсказки"
	L["None"] = "Нет"
	L["Not all children have the same value for this option"] = "Не все индикации имеют одинаковое значение для этого параметра"
	L["Not Loaded"] = "Не загружено"
	--[[Translation missing --]]
	L["Note: Automated Messages to SAY and YELL are blocked outside of Instances."] = "Note: Automated Messages to SAY and YELL are blocked outside of Instances."
	--[[Translation missing --]]
	L["Number of Entries"] = "Number of Entries"
	--[[Translation missing --]]
	L["Offer a guided way to create auras for your character"] = "Offer a guided way to create auras for your character"
	L["Okay"] = "Ок"
	L["On Hide"] = "При скрытии"
	L["On Init"] = "При инициализации"
	L["On Show"] = "При появлении"
	L["Only match auras cast by people other than the player"] = "Совпадение для эффектов других людей, но не игрока"
	--[[Translation missing --]]
	L["Only match auras cast by people other than the player or his pet"] = "Only match auras cast by people other than the player or his pet"
	L["Only match auras cast by the player"] = "Совпадение только для эффектов игрока"
	--[[Translation missing --]]
	L["Only match auras cast by the player or his pet"] = "Only match auras cast by the player or his pet"
	L["Operator"] = "Оператор"
	--[[Translation missing --]]
	L["Option #%i"] = "Option #%i"
	--[[Translation missing --]]
	L["Option %i"] = "Option %i"
	--[[Translation missing --]]
	L["Option key"] = "Option key"
	--[[Translation missing --]]
	L["Option Type"] = "Option Type"
	L["Options will open after combat ends."] = "Параметры откроются после окончания боя."
	L["or"] = "или"
	L["or Trigger %s"] = "Триггер %s"
	L["Orange Rune"] = "Оранжевая руна"
	L["Orientation"] = "Ориентация"
	--[[Translation missing --]]
	L["Outer"] = "Outer"
	L["Outline"] = "Контур"
	L["Overflow"] = "Переполнение"
	L["Overlay %s Info"] = "Информация о наложении %s"
	L["Overlays"] = "Настройка цвета наложений"
	L["Own Only"] = "Только своё"
	L["Paste Action Settings"] = "Вставить настройки действий"
	L["Paste Animations Settings"] = "Вставить настройки анимации"
	--[[Translation missing --]]
	L["Paste Author Options Settings"] = "Paste Author Options Settings"
	L["Paste Condition Settings"] = "Вставить настройки условий"
	--[[Translation missing --]]
	L["Paste Custom Configuration"] = "Paste Custom Configuration"
	L["Paste Display Settings"] = "Вставить настройки отображения"
	L["Paste Group Settings"] = "Вставить настройки группы"
	L["Paste Load Settings"] = "Вставить настройки загрузки"
	L["Paste Settings"] = "Вставить настройки"
	L["Paste text below"] = "Вставьте текст ниже"
	L["Paste Trigger Settings"] = "Вставить настройки триггера"
	L["Play Sound"] = "Проиграть звук"
	L["Portrait Zoom"] = "Увеличить портрет"
	L["Position Settings"] = "Настройки размера и расположения"
	--[[Translation missing --]]
	L["Preferred Match"] = "Preferred Match"
	L["Preset"] = "Предустановка"
	L["Processed %i chars"] = "Обработано %i |4символ:символа:символов;"
	L["Progress Bar"] = "Полоса прогресса"
	--[[Translation missing --]]
	L["Progress Bar Settings"] = "Progress Bar Settings"
	L["Progress Texture"] = "Текстура прогресса"
	--[[Translation missing --]]
	L["Progress Texture Settings"] = "Progress Texture Settings"
	L["Purple Rune"] = "Фиолетовая руна"
	L["Put this display in a group"] = "Переместить эту индикацию в группу"
	L["Radius"] = "Радиус"
	L["Re-center X"] = "Рецентрировать по X"
	L["Re-center Y"] = "Рецентрировать по Y"
	L["Regions of type \"%s\" are not supported."] = "Регионы типа \"%s\" не поддерживаются."
	L["Remaining Time"] = "Оставшееся время"
	L["Remaining Time Precision"] = "Точность оставшегося времени"
	L["Remove"] = "Удалить"
	L["Remove this display from its group"] = "Убрать индикацию из этой группы"
	L["Remove this property"] = "Удалить это свойство"
	L["Rename"] = "Переименовать"
	L["Repeat After"] = "Повторять после"
	L["Repeat every"] = "Повторять каждые"
	L["Required for Activation"] = "Необходимо для активации"
	--[[Translation missing --]]
	L["Reset all options to their default values."] = "Reset all options to their default values."
	--[[Translation missing --]]
	L["Reset to Defaults"] = "Reset to Defaults"
	--[[Translation missing --]]
	L["Right"] = "Right"
	L["Right 2 HUD position"] = "Позиция 2-го правого HUD"
	L["Right HUD position"] = "Позиция правого HUD"
	L["Right-click for more options"] = "Правый клик для дополнительных опций"
	L["Rotate"] = "Поворот"
	L["Rotate In"] = [=[Поворот в
(исходное положение)]=]
	L["Rotate Out"] = [=[Поворот из
(исходного положения)]=]
	L["Rotate Text"] = "Повернуть текст"
	L["Rotation"] = "Поворот"
	L["Rotation Mode"] = "Режим вращения"
	--[[Translation missing --]]
	L["Row Space"] = "Row Space"
	--[[Translation missing --]]
	L["Row Width"] = "Row Width"
	L["Same"] = "Похожие"
	L["Scale"] = "Масштаб"
	L["Search"] = "Поиск"
	L["Select the auras you always want to be listed first"] = "Выберите индикации для гибридной позиции"
	L["Send To"] = "Отправить"
	--[[Translation missing --]]
	L["Separator Text"] = "Separator Text"
	--[[Translation missing --]]
	L["Separator text"] = "Separator text"
	L["Set Parent to Anchor"] = "Назначить родителем"
	--[[Translation missing --]]
	L["Set Thumbnail Icon"] = "Set Thumbnail Icon"
	L["Set tooltip description"] = "Описание подсказки"
	L["Sets the anchored frame as the aura's parent, causing the aura to inherit attributes such as visiblility and scale."] = "Устанавливает данный кадр в качестве родителя для кадра индикации. При этом индикация наследует такие атрибуты, как видимость и масштаб"
	L["Settings"] = "Параметры"
	--[[Translation missing --]]
	L["Shadow Color"] = "Shadow Color"
	--[[Translation missing --]]
	L["Shadow X Offset"] = "Shadow X Offset"
	--[[Translation missing --]]
	L["Shadow Y Offset"] = "Shadow Y Offset"
	L["Shift-click to create chat link"] = "Shift-клик для создания ссылки чата"
	L["Show all matches (Auto-clone)"] = "Показать все совпадения (Автоклонирование)"
	--[[Translation missing --]]
	L["Show Border"] = "Show Border"
	--[[Translation missing --]]
	L["Show Cooldown"] = "Show Cooldown"
	--[[Translation missing --]]
	L["Show Extra Options"] = "Show Extra Options"
	--[[Translation missing --]]
	L["Show Glow"] = "Show Glow"
	--[[Translation missing --]]
	L["Show Icon"] = "Show Icon"
	--[[Translation missing --]]
	L["Show If Unit Does Not Exist"] = "Show If Unit Does Not Exist"
	L["Show If Unit Is Invalid"] = "Показать, если нет допустимой цели"
	--[[Translation missing --]]
	L["Show Matches for"] = "Show Matches for"
	--[[Translation missing --]]
	L["Show Matches for Units"] = "Show Matches for Units"
	--[[Translation missing --]]
	L["Show Model"] = "Show Model"
	L["Show model of unit "] = "Показать модель элемента"
	L["Show On"] = "Показать"
	--[[Translation missing --]]
	L["Show Spark"] = "Show Spark"
	--[[Translation missing --]]
	L["Show Text"] = "Show Text"
	L["Show this group's children"] = "Показать индикации этой группы"
	L["Shows a 3D model from the game files"] = "Показывает 3D модель из файлов игры"
	--[[Translation missing --]]
	L["Shows a border"] = "Shows a border"
	L["Shows a custom texture"] = "Показывает свою текстуру"
	--[[Translation missing --]]
	L["Shows a model"] = "Shows a model"
	L["Shows a progress bar with name, timer, and icon"] = "Показывает полосу прогресса с названием, таймером и иконкой"
	L["Shows a spell icon with an optional cooldown overlay"] = "Показывает иконку заклинания с наложением анимации восстановления (перезарядки)"
	L["Shows a texture that changes based on duration"] = "Показывает текстуру, меняющуюся в зависимости от длительности"
	L["Shows one or more lines of text, which can include dynamic information such as progress or stacks"] = "Показывает одну или несколько строк текста, которые могут включать в себя динамическую информацию такую как длительность или стаки"
	L["Simple"] = "Простой способ"
	L["Size"] = "Размер"
	--[[Translation missing --]]
	L["Skip this Version"] = "Skip this Version"
	L["Slant Amount"] = "Уровень наклона"
	L["Slant Mode"] = "Режим наклона"
	L["Slanted"] = "Наклонная текстура"
	L["Slide"] = "Перемещение"
	L["Slide In"] = "Приближение"
	L["Slide Out"] = "Отдаление"
	--[[Translation missing --]]
	L["Slider Step Size"] = "Slider Step Size"
	L["Small Icon"] = "Маленькая иконка"
	L["Smooth Progress"] = "Плавный прогресс"
	--[[Translation missing --]]
	L["Soft Max"] = "Soft Max"
	--[[Translation missing --]]
	L["Soft Min"] = "Soft Min"
	L["Sort"] = "Сортировка"
	L["Sound"] = "Звук"
	L["Sound Channel"] = "Звуковой канал"
	L["Sound File Path"] = "Путь к звуковому файлу"
	L["Sound Kit ID"] = "ID звукового набора (см. ru.wowhead.com/sounds)"
	L["Space"] = "Отступ"
	L["Space Horizontally"] = "Отступ по горизонтали"
	L["Space Vertically"] = "Отступ по вертикали"
	L["Spark"] = "Вспышка"
	L["Spark Settings"] = "Настройки вспышки"
	L["Spark Texture"] = "Текстура вспышки"
	L["Specific Unit"] = "Конкретная единица"
	L["Spell ID"] = "ID заклинания"
	L["Stack Count"] = "Кол-во cтаков"
	L["Stack Info"] = "Информация о стаках"
	L["Stagger"] = "Выступ (смещение уровня)"
	L["Star"] = "Звезда"
	L["Start"] = "Начальная"
	L["Start Angle"] = "Начальный угол"
	--[[Translation missing --]]
	L["Start Collapsed"] = "Start Collapsed"
	--[[Translation missing --]]
	L["Start of %s"] = "Start of %s"
	L["Status"] = "Статус"
	L["Stealable"] = "Можно украсть"
	--[[Translation missing --]]
	L["Step Size"] = "Step Size"
	--[[Translation missing --]]
	L["Stop ignoring Updates"] = "Stop ignoring Updates"
	L["Stop Sound"] = "Остановить звук"
	--[[Translation missing --]]
	L["Sub Elements"] = "Sub Elements"
	--[[Translation missing --]]
	L["Sub Option %i"] = "Sub Option %i"
	L["Temporary Group"] = "Временная группа"
	L["Text"] = "Текст"
	--[[Translation missing --]]
	L["Text %s"] = "Text %s"
	L["Text Color"] = "Цвет текста"
	--[[Translation missing --]]
	L["Text Settings"] = "Text Settings"
	L["Texture"] = "Текстура"
	L["Texture Info"] = "Информация о текстуре"
	--[[Translation missing --]]
	L["Texture Settings"] = "Texture Settings"
	L["Texture Wrap"] = "Режим обертки текстурой"
	L["The duration of the animation in seconds."] = "Длительность анимации в секундах."
	L["The duration of the animation in seconds. The finish animation does not start playing until after the display would normally be hidden."] = [=[Длительность анимации в секундах.
Конечная анимация не начнет отображаться, пока индикация не будет нормально скрыта  (должен сработать детриггер).]=]
	L["The type of trigger"] = "Тип триггера"
	L["Then "] = "Тогда "
	--[[Translation missing --]]
	L["Thickness"] = "Thickness"
	--[[Translation missing --]]
	L["This adds %tooltip, %tooltip1, %tooltip2, %tooltip3 as text replacements."] = "This adds %tooltip, %tooltip1, %tooltip2, %tooltip3 as text replacements."
	--[[Translation missing --]]
	L["This aura has legacy aura trigger(s). Convert them to the new system to benefit from enhanced performance and features"] = "This aura has legacy aura trigger(s). Convert them to the new system to benefit from enhanced performance and features"
	L["This display is currently loaded"] = "Эта индикация загружена"
	L["This display is not currently loaded"] = "Эта индикация не загружена"
	L["This region of type \"%s\" is not supported."] = "Регион типа \"%s\" не поддерживается."
	--[[Translation missing --]]
	L["This setting controls what widget is generated in user mode."] = "This setting controls what widget is generated in user mode."
	L["Time in"] = "Время"
	L["Tiny Icon"] = "Крошечная иконка"
	L["To Frame's"] = "Относительно кадра"
	L["to group's"] = "Относительно группы"
	L["To Personal Ressource Display's"] = "На индикаторе личного ресурса"
	L["To Screen's"] = "Относительно экрана"
	L["Toggle the visibility of all loaded displays"] = "Переключить видимость всех загруженных индикаций"
	L["Toggle the visibility of all non-loaded displays"] = "Переключить видимость всех не загруженных индикаций"
	L["Toggle the visibility of this display"] = "Переключить видимость этой индикации"
	L["Tooltip"] = "Подсказка"
	--[[Translation missing --]]
	L["Tooltip Content"] = "Tooltip Content"
	L["Tooltip on Mouseover"] = "Подсказка при наведении курсора"
	--[[Translation missing --]]
	L["Tooltip Pattern Match"] = "Tooltip Pattern Match"
	--[[Translation missing --]]
	L["Tooltip Text"] = "Tooltip Text"
	--[[Translation missing --]]
	L["Tooltip Value"] = "Tooltip Value"
	--[[Translation missing --]]
	L["Tooltip Value #"] = "Tooltip Value #"
	--[[Translation missing --]]
	L["Top"] = "Top"
	L["Top HUD position"] = "Верхняя позиция HUD"
	--[[Translation missing --]]
	L["Top Left"] = "Top Left"
	--[[Translation missing --]]
	L["Top Right"] = "Top Right"
	L["Total Time Precision"] = "Точность общего времени"
	L["Trigger"] = "Триггер"
	L["Trigger %d"] = "Триггер %d"
	L["Trigger %s"] = "Триггер %s"
	L["True"] = "Истина"
	L["Type"] = "Тип"
	L["Ungroup"] = "Разгруппировать"
	L["Unit"] = "Единица"
	--[[Translation missing --]]
	L["Unit %s is not a valid unit for RegisterUnitEvent"] = "Unit %s is not a valid unit for RegisterUnitEvent"
	--[[Translation missing --]]
	L["Unit Count"] = "Unit Count"
	--[[Translation missing --]]
	L["Unit Frames"] = "Unit Frames"
	L["Unlike the start or finish animations, the main animation will loop over and over until the display is hidden."] = "В отличие от начальной или конечной анимации, основная зациклена и будет повторяться пока индикация не пропадет."
	L["Up"] = "Переместить вверх"
	--[[Translation missing --]]
	L["Update "] = "Update "
	L["Update Custom Text On..."] = "Обновить свой текст на..."
	--[[Translation missing --]]
	L["Update in Group"] = "Update in Group"
	--[[Translation missing --]]
	L["Update this Aura"] = "Update this Aura"
	--[[Translation missing --]]
	L["Use Display Info Id"] = "Use Display Info Id"
	L["Use Full Scan (High CPU)"] = "Использовать Полное сканирование (загрузка ЦП)"
	L["Use nth value from tooltip:"] = "Использовать n-ое значение из подсказки:"
	L["Use SetTransform"] = "Использовать ф-ю SetTransform"
	L["Use tooltip \"size\" instead of stacks"] = "Использовать значение из подсказки вместо стаков"
	--[[Translation missing --]]
	L["Use Tooltip Information"] = "Use Tooltip Information"
	--[[Translation missing --]]
	L["Used in Auras:"] = "Used in Auras:"
	L["Used in auras:"] = "Использовано в индикациях:"
	--[[Translation missing --]]
	L["Value %i"] = "Value %i"
	--[[Translation missing --]]
	L["Values are in normalized rgba format."] = "Values are in normalized rgba format."
	--[[Translation missing --]]
	L["Values:"] = "Values:"
	L["Version: "] = "Версия: "
	L["Vertical Align"] = "Выравнивание по вертикали"
	L["Vertical Bar"] = "Вертикальная полоса"
	L["View"] = "Вид"
	--[[Translation missing --]]
	L["Wago Update"] = "Wago Update"
	--[[Translation missing --]]
	L["Whole Area"] = "Whole Area"
	L["Width"] = "Ширина"
	L["X Offset"] = "Смещение по X"
	L["X Rotation"] = "Поворот по X"
	L["X Scale"] = "Масштаб по X"
	--[[Translation missing --]]
	L["X-Offset"] = "X-Offset"
	L["Y Offset"] = "Смещение по Y"
	L["Y Rotation"] = "Поворот по Y"
	L["Y Scale"] = "Масштаб по Y"
	L["Yellow Rune"] = "Жёлтая руна"
	L["Yes"] = "Да"
	--[[Translation missing --]]
	L["Y-Offset"] = "Y-Offset"
	L["You are about to delete %d aura(s). |cFFFF0000This cannot be undone!|r Would you like to continue?"] = [=[Вы собираетесь удалить %d |4индикацию:индикации:индикаций;.
|cFFFF0000Это действие нельзя отменить!|r
Вы хотите продолжить?]=]
	L["Z Offset"] = "Смещение по Z"
	L["Z Rotation"] = "Поворот по Z"
	L["Zoom"] = "Масштабирование"
	L["Zoom In"] = "Увеличение"
	L["Zoom Out"] = "Уменьшение"

