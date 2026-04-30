local AddonName, KeystoneLoot = ...;

if (GetLocale() ~= "frFR") then
    return;
end

local L = KeystoneLoot.L;

-- keystoneloot_frame.lua
L["%s (%s Season %d)"] = "%s (%s Saison %d)";

-- itemlevel_dropdown.lua
L["Veteran"] = "Vétéran";
L["Champion"] = "Champion";
L["Hero"] = "Héros";

-- upgrade_tracks.lua
L["Myth"] = "Mythe";

-- catalyst_frame.lua
L["The Catalyst"] = "Le catalyseur";

-- settings_dropdown.lua
L["Minimap button"] = "Bouton de la mini-carte";
L["Item level in keystone tooltip"] = "Niveau d'objet dans l'infobulle de la clé";
L["Favorite in item tooltip"] = "Favori dans l'infobulle de l'objet";
L["Loot reminder (dungeons)"] = "Rappel de butin (donjons)";
L["Highlighting"] = "Surlignage";
L["No stats"] = "Aucune statistique";
L["Export..."] = "Exporter...";
L["Import..."] = "Importer...";
L["Export favorites of %s"] = "Exporter les favoris de %s";
L["Import favorites for %s\nPaste import string here:"] = "Importer les favoris de %s\nCollez la chaîne d'importation ici :";
L["Merge"] = "Fusionner";
L["Overwrite"] = "Écraser";
L["%d |4favorite:favorites; imported%s."] = "%d |4favori:favoris; importé%s.";
L[" (overwritten)"] = " (écrasé)";
L["Import failed - %s"] = "Échec de l'importation - %s";
L["Some specs were skipped - import string belongs to a different class."] = "Certaines spécialisations ont été ignorées - la chaîne d'importation appartient à une autre classe.";
L["Manage characters"] = "Gérer les personnages";
L["Hidden"] = "Masqué";
L["Delete..."] = "Supprimer...";
L["Delete all data for %s?"] = "Supprimer toutes les données de %s ?";
L["Cannot delete the currently logged in character."] = "Impossible de supprimer le personnage actuellement connecté.";
L["This character is hidden."] = "Ce personnage est masqué.";
L["Wide mode"] = "Mode large";

-- favorites.lua
L["No favorites found"] = "Aucun favori trouvé";
L["Invalid import string."] = "Chaîne d'importation non valide.";
L["No character selected."] = "Aucun personnage sélectionné.";
L["No valid items found."] = "Aucun objet valide trouvé.";

-- icon_button.lua / favorites.lua
L["Set Favorite"] = "Définir le favori";
L["Nice to have"] = "Serait utile";
L["Must have"] = "Indispensable";

-- loot_reminder_frame.lua
L["Correct loot specialization set?"] = "Spécialisation de butin correcte définie ?";
L["+1 item dropping for all specs."] = "+1 objet qui tombe pour toutes les spécialisations.";
L["+%d items dropping for all specs."] = "+%d objets qui tombent pour toutes les spécialisations.";
L["%s has a smaller loot pool than %s"] = "%s a un pool de butin plus petit que %s";

-- minimap_button.lua
L["Left click: Open overview"] = "Clic gauche : Ouvrir l'aperçu";
