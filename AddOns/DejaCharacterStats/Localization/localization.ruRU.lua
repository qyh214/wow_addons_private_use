local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local LOCALE = GetLocale()

if LOCALE == "ruRU" then
	-- The EU English game client also
	-- uses the US English locale code.

-- ###################################################################################################################
-- ##	русский (Russian) translations provided by Nappsel and Wishko on Curseforge. Thank you Nappsel and Wishko!	##													##
-- ###################################################################################################################

-- ################################
-- ## Slash Commands ##
-- ################################

--	L["/dcstats"] = ""
	L["DejaCharacterStats Slash commands (/dcstats):"] = "DejaCharacterStats Slash команды (/dcstats):"
	L["  /dcstats config: Open the DejaCharacterStats addon config menu."] = "  /dcstats config: Открывает настройки дополнения DejaCharacterStats." --configuration
	L["  /dcstats reset:  Resets DejaCharacterStats frames to default positions."] = "  /dcstats reset: Сбрасывает рамки DejaCharacterStats на позиции по умолчанию."
	L["Resetting config to defaults"] = "Сброс до конфигурации по умолчанию." --configuration
	L["DejaCharacterStats is currently using "] = "DejaCharacterStats теперь использует "
	L[" kbytes of memory"] = " кбайт памяти" --kilobytes
--	L["DejaCharacterStats is currently using "] = "DejaCharacterStats уже используется"
	L[" kbytes of memory after garbage collection"] = " кбайт памяти после сборки мусора" --kilobytes
--	L["config"] = "" --configuration
--	L["dumpconfig"] = "" --configuration
	L["With defaults"] = "С конфигурацией по умолчанию"
	L["Direct table"] = "Прямая таблица"
--	L["reset"] = ""
--	L["perf"] = "" --performance
	L["Reset to Default"] = "Сбросить до настроек по умолчанию"

-- ################################
-- ## Global Options Left Column ##
-- ################################

	L["Equipped/Available"] = "Надето/Доступно"
	L['Displays Equipped/Available item levels unless equal.'] = "Отображает уровень Надетых/Доступных предметов, если значения не равны."

	L["Decimals"] = "Десятичные числа"
	L['Displays "Enhancements" category stats to two decimal places.'] = 'Отображает "расширенные" характеристики персонажа используя два знака после запятой.'

	L["Ilvl Decimals"] = "Десятичные числа для ilvl"
	L['Displays average item level to two decimal places.'] = "Отображает средний уровень предметов используя два знака после запятой."

	L['Durability '] = "Прочность "
	L['Displays the average Durability percentage for equipped items in the stat frame.'] = "Показывать средний процент Прочности для экипированных предметов в окне характеристик."

	L['Repair Total '] = "Стоимость ремонта "
	L['Displays the Repair Total before discounts for equipped items in the stat frame.'] = "Отображает стоимость ремонта без учёта скидок на экипированные предметы в окне характеристик персонажа."

-- ################################

	L["Durability Bars"] = "Индикатор прочности"
	L["Displays a durability bar next to each item." ] = "Отображает индикатор прочности рядом с каждым предметом."

	L["Average Durability"] = "Средняя прочность"
	L["Displays average item durability on the character shirt slot and durability frames."] = "Отображает среднюю прочность предметов в слоте рубашки персонажа и окне прочности."

	L["Item Durability"] = "Прочность предмета"
	L["Displays each equipped item's durability."] = "Отображает прочность каждого экипированного предмета."

	L["Item Repair Cost"] = "Стоимость ремонта предмета"
	L["Displays each equipped item's repair cost."] = "Отображает стоимость ремонта каждого экипированного предмета."

-- ################################

	L["Expand"] = "Раскрыть"
	L['Displays the Expand button for the character stats frame.'] = "Отображает кнопку Раскрыть в окне характеристик персонажа."
	L['Show Character Stats'] = "Показать характеристики персонажа"
	L['Hide Character Stats'] = "Скрыть характеристики персонажа"

	L["Scrollbar"] = "Скроллбар"
	L['Displays the DCS scrollbar.'] = "Отображать DCS полосу прокрутки."

-- ################################
-- ## Character Options Right Column ##
-- ################################

	L["Show All Stats"] = "Показать все характеристики"
	L['Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom.'] = "Если отмечено, то показываются все характеристики. Если нет, то отображаются только соответствующие персонажу характеристики. Используйте Shift+Колёсико, чтобы быстро перемещаться к верхней или нижней части."

	L["Select-A-Stat™"]  = "Выбор-A-Xарактеристика™" -- Try to use something snappy and silly like a Fallout or 1950's appliance feature.
	L['Select which stats to display. Use Shift-scroll to snap to the top or bottom.'] = "Выберите какие характеристики должны отображаться. Используйте Shift+Колёсико, чтобы быстро перемещаться к верхней или нижней части."

-- ################################
-- ## Stats ##
-- ################################

	L["Durability"] = "Прочность" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Durability %s"] = "Прочность %s" -- ## --> %s MUST be included <-- ## 
	L["Average equipped item durability percentage."] = "Средняя прочность экипированных предметов в процентах."

	L["Repair Total"] = "Pемонт" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Repair Total %s"] = "Стоимость ремонта %s" -- ## --> %s MUST be included <-- ## 
	L["Total equipped item repair cost before discounts."] = "Общая стоимость ремонта без учёта скидок."

-- ## Attributes ##

	L["Health"] = "Здоровье"
	L["Power"] = "Мощность"
	L["Druid Mana"] = "Друид мана"
	L["Armor"] = "Броня"
	L["Strength"] = "Сила"
	L["Agility"] = "Ловкость"
	L["Intellect"] = "Интеллект"
	L["Stamina"] = "Выносливость"
	L["Damage"] = "Урон"
	L["Attack Power"] = "Сила атаки"
	L["Attack Speed"] = "Скорость атаки"
	L["Spell Power"] = "Сила заклинаний"
	L["Mana Regen"] = "Восполнение маны"
	L["Energy Regen"] = "Восст. энергии"
	L["Rune Regen"] = "Восст. рун"
	L["Focus Regen"] = "Восст. концентрации"
	L["Movement Speed"] = "Скорость движения"
	L["Durability"] = "Прочность"
	--L["Repair Total"] = "Стоимость ремонта"

-- ## Enhancements ##

	L["Critical Strike"] = "Критический удар"
	L["Haste"] = "Скорость"
	L["Versatility"] = "Универсальность"
	L["Mastery"] = "Искусность"
	L["Leech"] = "Самоисцеление"
	L["Avoidance"] = "Избегание"
	L["Dodge"] = "Уклонение"
	L["Parry"] = "Парирование"
	L["Block"] = "Блок"

-- ## Patch 7.1.0 r2 additions ##
	L["Global Cooldown"] = "Общее время восст."
	L["Global Cooldown %.2fs"] = "Общее время восст. %.2fs"
	L["General global cooldown for casters. Individual spells, set bonuses, talents, etc. not considered. Not suitable for melee. Improvements coming Soon(TM)."] = "Общее время восстановления(GCD) для кастеров. Индивидуальные заклинания, бонусы комплектов, таланты и т.д., не рассматриваются. Не подходит для ближнего боя. Улучшения в ближайшее время(TM)."
	L["Unlock DCS"] = "Разблокировать DCS"
	L["Lock DCS"] = "Заблокировать DCS"
	L["Item Level 1 Decimal Place"] = "Уровень предметов с десятичными"
	L["Displays average item level to one decimal place."] = "Отображать средний уровень предметов используя один знак после запятой."
	L["Item Level 2 Decimal Places"] = "Уровень предметов с сотыми"
	L["Displays average item level to two decimal places."] = "Отображать средний уровень предметов используя два знака после запятой."
	L["Main Hand"] = "Правая рука"
	L["/Off Hand"] = "/Левая рука"
	L[" weapon auto attack (white) DPS."] = ' Автоматическая атака оружием. "Белый" урон.'
	L["Weapon DPS"] = "Урон оружия"
	L["Weapon DPS %s"] = "Урон оружия %s"
--	L["Class Crest Background"] = ""
--	L["Displays the class crest background."] = ""

-- ## Patch 7.1.0 r5 additions ##
--	L["General global cooldown refresh time."] = ""

return end
