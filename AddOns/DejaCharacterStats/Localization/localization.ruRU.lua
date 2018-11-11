local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

--local LOCALE = GetLocale()

if namespace.locale == "ruRU" then
	-- The EU English game client also
	-- uses the US English locale code.

-- ####################################################################################################################
-- ##	русский (Russian) translations provided by Nappsel, Wishko, berufegoru, Hubbotu, and n1mrorox on Curseforge. ##
-- ####################################################################################################################

L["  /dcstats config: Opens the DejaCharacterStats addon config menu."] = "/dcstats config: Открывает настройки дополнения DejaCharacterStats."
L["  /dcstats reset:  Resets DejaCharacterStats options to default."] = "/dcstats reset: Вернуть настройки DejaCharacterStats по умолчанию."
L["%s of %s increases %s by %.2f%%"] = "%s %s увеличивает %s на %.2f%%"
L["About DCS"] = "О DCS"
L["All Stats"] = "Все"
L["Attack"] = "Атакующие"
L["Average Durability"] = "Средняя прочность"
L["Average equipped item durability percentage."] = "Средняя прочность экипированных предметов в процентах."
L["Average Item Level:"] = "Средний уровень предметов:"
L["Avoidance Rating"] = "Рейтинг Уклонения"
L["Blizzard's Hide At Zero"] = "Blizzard скрытие при нуле"
L["Character Stats:"] = "Характеристики персонажа:"
L["Class Colors"] = "Цвета классов"
L["Class Crest Background"] = "Фон с гербом класса"
L["Critical Strike Rating"] = "Показатель крит. удара"
L["DCS's Hide At Zero"] = "DCS скрытие при нуле"
L["Decimals"] = "Десятичные числа"
L["Defense"] = "Защитные"
L["Dejablue's improved character stats panel view."] = "Улучшенное представление характеристик персонажа."
L["DejaCharacterStats Slash commands (/dcstats):"] = "DejaCharacterStats Slash команды (/dcstats):"
L["Displays a durability bar next to each item."] = "Отображает индикатор прочности рядом с каждым предметом."
L["Displays average item durability on the character shirt slot and durability frames."] = "Отображает среднюю прочность предметов в слоте рубашки персонажа и окне прочности."
L["Displays average item level to one decimal place."] = "Отображать средний уровень предметов используя одно число после точки."
L["Displays average item level to two decimal places."] = "Отображать средний уровень предметов используя два числа после точки."
L["Displays average item level with class colors."] = "Отображать средний уровень предметов цветом класса."
L["Displays each equipped item's durability."] = "Отображает прочность каждого экипированного предмета."
L["Displays each equipped item's repair cost."] = "Отображает стоимость ремонта каждого экипированного предмета."
L["Displays 'Enhancements' category stats to two decimal places."] = "Отображает характеристики 'Усиления' используя десятичные числа."
L["Displays Equipped/Available item levels unless equal."] = "Отображает уровень Надетых/Доступных предметов, если значения не равны."
L["Displays the class crest background."] = "Отображать фон с гербом класса."
L["Displays the DCS scrollbar."] = "Отображать полосу прокрутки DCS."
L["Displays the Expand button for the character stats frame."] = "Отображает кнопку скрывающую окно характеристик персонажа."
L["Displays the item level of each equipped item."] = "Отображать уровень каждого надетого предмета."
L["Dodge Rating"] = "Показатель уклонения"
L["Durability"] = "Прочность"
L["Durability Bars"] = "Индикатор прочности"
L["Equipped/Available"] = "Надето/Доступно"
L["Expand"] = "Раскрыть"
L["General"] = "Основные"
L["General global cooldown refresh time."] = "Общее время глобальной перезарядки."
L["Global Cooldown"] = "Общее время восст."
L["Haste Rating"] = "Показатель скорости"
L["Hide Character Stats"] = "Скрыть характеристики персонажа"
--[[Translation missing --]]
--[[ L["Hide low level mastery"] = ""--]] 
L["Hides 'Enhancements' stats if their displayed value would be zero. Checking 'Decimals' changes the displayed value."] = "Скрыть характеристики 'Усиления' если их отображаемое значение равно нулю. Выбор 'Десятичных чисел' изменяет отображаемое значение."
L["Hides 'Enhancements' stats only if their numerical value is exactly zero. For example, if stat value is 0.001%, then it would be displayed as 0%."] = "Скрыть характеристики 'Усилений' только если их значение равно нулю. Например, если значение характеристики равно 0.001%, то оно будет отображаться как 0%."
--[[Translation missing --]]
--[[ L["Hides Mastery stat until the character starts to have benefit from it. Hiding Mastery with Select-A-Stat™ in the character panel has priority over this setting."] = ""--]] 
L["Item Durability"] = "Прочность предмета"
L["Item Level"] = "Уровень предмета"
L["Item Repair Cost"] = "Стоимость ремонта предмета"
L["Item Slots:"] = "Ячейки снаряжения:"
L["Leech Rating"] = "Показатель самоисцеления"
L["Lock DCS"] = "Заблокировать DCS"
L["Main Hand"] = "Правая рука"
L["Mastery Rating"] = "Показатель искусности"
L["Miscellaneous:"] = "Разное:"
L["Movement Speed"] = "Скорость движения"
L["Off Hand"] = "Левая рука"
L["Offense"] = "Атакующие"
L["One Decimal Place"] = "Один десятичный знак"
L["Parry Rating"] = "Показатель парирования"
L["Ratings"] = "Рейтинги"
L["Relevant Stats"] = "Актуальная статистика"
L["Repair Total"] = "Стоимость ремонта"
L["Requires Level "] = "Требуется уровень "
L["Reset Stats"] = "Сбросить"
L["Reset to Default"] = "Сбросить настройки"
L["Resets order of stats."] = "Сбросить порядок характеристик."
L["Scrollbar"] = "Скроллбар"
L["Show all stats."] = "Показать все характеристики"
L["Show Character Stats"] = "Показать характеристики персонажа"
L["Show only stats relevant to your class spec."] = "Показывать характеристики только для вашей специализации."
L["Total equipped item repair cost before discounts."] = "Общая стоимость ремонта без учёта скидок."
L["Two Decimal Places"] = "Два десятичных знака"
L["Unlock DCS"] = "Разблокировать DCS"
L["Versatility Rating"] = "Показатель универсальности"
L["weapon auto attack (white) DPS."] = "Автоматическая атака оружием. 'Белый' урон."
L["Weapon DPS"] = "Урон оружия"

return end
