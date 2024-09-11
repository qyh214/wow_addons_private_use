if (GetLocale() ~= 'esES' and GetLocale() ~= 'esMX') then
    return;
end

local AddonName, KeystoneLoot = ...;
local Translate = KeystoneLoot.Translate;


Translate['Left click: Open overview'] = 'Clic izquierdo: Abrir vista general';
Translate['Right click: Open settings'] = 'Clic derecho: Abrir configuraciones';
Translate['Enable Minimap Button'] = 'Activar botón del minimapa';
Translate['Enable Loot Reminder'] = 'Activar Recordatorio de Botín';
--Translate['Favorites Show All Specializations'] = '';
Translate['%s (%s Season %d)'] = '%s (%s temporada %d)';
Translate['Veteran'] = 'Veterano';
Translate['Champion'] = 'Campeón';
Translate['Hero'] = 'Héroe';
Translate['Myth'] = 'Mito';
Translate['Revival Catalyst'] = 'Catalizador de reanimación';
Translate['El Alba del Infinito: Caída de Galakrond'] = 'Caída de Galakrond';
Translate['El Alba del Infinito: El Ascenso de Murozond'] = 'Ascenso de Murozond';
Translate['Correct loot specialization set?'] = '¿Establecer especialización de botín correcta?';
--Translate['Show Item Level In Keystone Tooltip'] = '';
Translate['Highlighting'] = 'Resaltar';
--Translate['No Stats'] = '';