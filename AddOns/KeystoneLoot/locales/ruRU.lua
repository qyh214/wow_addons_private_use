local AddonName, KeystoneLoot = ...;

if (GetLocale() ~= "ruRU") then
    return;
end

local L = KeystoneLoot.L;

-- keystoneloot_frame.lua
L["%s (%s Season %d)"] = "%s (%s сезон %d)";

-- itemlevel_dropdown.lua
L["Veteran"] = "Ветеран";
L["Champion"] = "Защитник";
L["Hero"] = "Герой";

-- upgrade_tracks.lua
L["Myth"] = "Легенда";

-- catalyst_frame.lua
L["The Catalyst"] = "Катализатор";

-- settings_dropdown.lua
L["Minimap button"] = "Включить кнопку на миникарте";
L["Item level in keystone tooltip"] = "Показать уровень предметов во всплывающей подсказке ключа";
L["Favorite in item tooltip"] = "Избранное в подсказке предмета";
L["Loot reminder (dungeons)"] = "Включить напоминание о добыче";
L["Highlighting"] = "Подсветка";
L["No stats"] = "Характеристика отсутствует";
L["Export..."] = "Экспорт...";
L["Import..."] = "Импорт...";
L["Export favorites of %s"] = "Экспортировать избранное %s";
L["Import favorites for %s\nPaste import string here:"] = "Импортировать избранное для %s\nВставьте строку импорта сюда:";
L["Merge"] = "Объединить";
L["Overwrite"] = "Перезаписать";
L["%d |4favorite:favorites; imported%s."] = "Успешно импортировано %d |4предмет:предмета:предметов;%s.";
L[" (overwritten)"] = " (перезаписано)";
L["Import failed - %s"] = "Ошибка импорта - %s";
L["Some specs were skipped - import string belongs to a different class."] = "Некоторые специализации пропущены - строка импорта принадлежит другому классу.";
L["Manage characters"] = "Управление персонажами";
L["Hidden"] = "Скрытый";
L["Delete..."] = "Удалить...";
L["Delete all data for %s?"] = "Удалить все данные для %s?";
L["Cannot delete the currently logged in character."] = "Невозможно удалить персонажа, под которым выполнен вход.";
L["This character is hidden."] = "Этот персонаж скрыт.";
L["Wide mode"] = "Широкий режим";

-- favorites.lua
L["No favorites found"] = "Избранное не найдено";
L["Invalid import string."] = "Неверная строка импорта.";
L["No character selected."] = "Персонаж не выбран.";
L["No valid items found."] = "Допустимые предметы не найдены.";

-- icon_button.lua / favorites.lua
L["Set Favorite"] = "Добавить в избранное";
L["Nice to have"] = "Желательно";
L["Must have"] = "Обязательно";
L["Best in Slot"] = "БиС";

-- loot_reminder_frame.lua
L["Correct loot specialization set?"] = "Правильная установка специализации для добычи?";
L["+1 item dropping for all specs."] = "+1 предмет выпадает для всех специализаций.";
L["+%d items dropping for all specs."] = "+%d предметов выпадает для всех специализаций.";
L["%s has a smaller loot pool than %s"] = "%s имеет меньший набор добычи, чем %s";

-- minimap_button.lua
L["Left click: Open overview"] = "ЛКМ: Открыть окно KeystoneLoot";
