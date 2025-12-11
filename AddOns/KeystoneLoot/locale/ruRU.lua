if (GetLocale() ~= 'ruRU') then
    return;
end

local AddonName, KeystoneLoot = ...;
local Translate = KeystoneLoot.Translate;


Translate['Left click: Open overview'] = 'ЛКМ: Открыть окно KeystoneLoot';
Translate['Right click: Open settings'] = 'ПКМ: Открыть настройки';
Translate['Enable Minimap Button'] = 'Включить кнопку миникарты';
Translate['Enable Loot Reminder'] = 'Включить напоминание о добыче';
Translate['Favorites Show All Specializations'] = 'Избранное для всех специализаций';
Translate['%s (%s Season %d)'] = '%s (%s сезон %d)';
Translate['Veteran'] = 'Ветеран';
Translate['Champion'] = 'Защитник';
Translate['Hero'] = 'Герой';
Translate['Myth'] = 'Легенда';
Translate['The Catalyst'] = 'Катализатор';
Translate['Рассвет Бесконечности: падение Галакронда'] = 'Падение Галакронда';
Translate['Рассвет Бесконечности: подъем Дорнозму'] = 'Подъем Дорнозму';
Translate['Correct loot specialization set?'] = 'Правильная установка специализации для добычи?';
Translate['Show Item Level In Keystone Tooltip'] = 'Показать уровень предмета во всплывающей подсказке ключа';
Translate['Highlighting'] = 'Подсветка';
Translate['No Stats'] = 'Статистика отсутствует';
Translate['The favorites are ready to share:'] = 'Избранное готово к передаче:';
Translate['Paste an import string to import favorites:'] = 'Вставьте строку импорта, чтобы импортировать избранное:';
Translate['Overwrite'] = 'Перезаписать';
Translate['Successfully imported %d |4item:items;.'] = 'Успешно импортировано %d |4предмет:предмета:предметов;.';
Translate['Invalid import string.'] = 'Неверная строка импорта';
