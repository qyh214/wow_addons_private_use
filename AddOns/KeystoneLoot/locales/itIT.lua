local AddonName, KeystoneLoot = ...;

if (GetLocale() ~= "itIT") then
    return;
end

local L = KeystoneLoot.L;

-- keystoneloot_frame.lua
L["%s (%s Season %d)"] = "%s (%s Stagione %d)";

-- itemlevel_dropdown.lua
L["Veteran"] = "Veterano";
L["Champion"] = "Campione";
L["Hero"] = "Eroe";

-- upgrade_tracks.lua
L["Myth"] = "Mito";

-- catalyst_frame.lua
L["The Catalyst"] = "Catalizzatore";

-- settings_dropdown.lua
L["Minimap button"] = "Pulsante minimappa";
L["Item level in keystone tooltip"] = "Livello oggetto nel tooltip della chiave";
L["Favorite in item tooltip"] = "Preferito nel tooltip dell'oggetto";
L["Loot reminder (dungeons)"] = "Promemoria bottino (sotterranei)";
L["Highlighting"] = "Evidenzia";
L["No stats"] = "Nessuna statistica";
L["Export..."] = "Esporta...";
L["Import..."] = "Importa...";
L["Export favorites of %s"] = "Esporta preferiti di %s";
L["Import favorites for %s\nPaste import string here:"] = "Importa preferiti di %s\nIncolla qui la stringa di importazione:";
L["Merge"] = "Unisci";
L["Overwrite"] = "Sovrascrivi";
L["%d |4favorite:favorites; imported%s."] = "%d |4preferito:preferiti; importato%s.";
L[" (overwritten)"] = " (sovrascritto)";
L["Import failed - %s"] = "Importazione fallita - %s";
L["Some specs were skipped - import string belongs to a different class."] = "Alcune specializzazioni sono state saltate - la stringa di importazione appartiene a una classe diversa.";
L["Manage characters"] = "Gestisci personaggi";
L["Hidden"] = "Nascosto";
L["Delete..."] = "Elimina...";
L["Delete all data for %s?"] = "Eliminare tutti i dati per %s?";
L["Cannot delete the currently logged in character."] = "Impossibile eliminare il personaggio attualmente connesso.";
L["This character is hidden."] = "Questo personaggio è nascosto.";
L["Wide mode"] = "Modalità estesa";

-- favorites.lua
L["No favorites found"] = "Nessun preferito trovato";
L["Invalid import string."] = "Stringa di importazione non valida.";
L["No character selected."] = "Nessun personaggio selezionato.";
L["No valid items found."] = "Nessun oggetto valido trovato.";

-- icon_button.lua / favorites.lua
L["Set Favorite"] = "Imposta preferito";
L["Nice to have"] = "Utile averlo";
L["Must have"] = "Indispensabile";

-- loot_reminder_frame.lua
L["Correct loot specialization set?"] = "Specializzazione bottino corretta?";
L["+1 item dropping for all specs."] = "+1 oggetto che cade per tutte le specializzazioni.";
L["+%d items dropping for all specs."] = "+%d oggetti che cadono per tutte le specializzazioni.";
L["%s has a smaller loot pool than %s"] = "%s ha un pool di bottino più piccolo di %s";

-- minimap_button.lua
L["Left click: Open overview"] = "Clic sinistro: Apri panoramica";
