-- Locale
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("RareScanner", "frFR", false);

if AL then
	AL["ALARM_MESSAGE"] = "Un PNJ rare vient d'apparaître, vérifiez votre carte!"
	AL["ALARM_SOUND"] = "Son d'avertissement pour les PNJ rares"
	AL["ALARM_SOUND_DESC"] = "Son joué lorsqu'un PNJ rare apparaît dans votre minicarte"
	AL["ALARM_TREASURES_SOUND"] = "Son d'avertissement pour les événements / trésors"
	AL["ALARM_TREASURES_SOUND_DESC"] = "Son joué lorsqu'un trésor / coffre ou événement apparaît dans votre mini-carte"
	AL["AUTO_HIDE_BUTTON"] = "Bouton de masquage automatique et miniature"
	AL["AUTO_HIDE_BUTTON_DESC"] = "Masque automatiquement le bouton et la miniature après le temps sélectionné (en secondes). Si vous sélectionnez zéro seconde, le bouton et la miniature ne seront pas masqués automatiquement"
	AL["CLASS_HALLS"] = "Salles de classe"
	AL["CLEAR_FILTERS_SEARCH_DESC"] = "Réinitialise le formulaire à l'état initial"
	AL["CLICK_TARGET"] = "Cliquez pour cibler le PNJ"
	AL["CMD_HELP1"] = "Liste des commandes"
	AL["CMD_HIDE"] = "Masquage des icônes RareScanner sur la carte du monde"
	AL["CMD_HIDE_EVENTS"] = "Masquage des icônes d'événements RareScanner sur la carte du monde"
	AL["CMD_HIDE_RARES"] = "Masquage des icônes rares de RareScanner sur la carte du monde"
	AL["CMD_HIDE_TREASURES"] = "Masquage des icônes du trésor RareScanner sur la carte du monde"
	AL["CMD_SHOW"] = "Affichage des icônes RareScanner sur la carte du monde"
	AL["CMD_SHOW_EVENTS"] = "Affichage des icônes d'événements RareScanner sur la carte du monde"
	AL["CMD_SHOW_RARES"] = "Affichage des icônes rares de RareScanner sur la carte du monde"
	AL["CMD_SHOW_TREASURES"] = "Affichage des icônes du trésor RareScanner sur la carte du monde"
	AL["CONTAINER"] = "Récipient"
	AL["DATABASE_HARD_RESET"] = "Depuis l'expansion la plus récente et avec la dernière version de RareScanner, de grands changements se sont produits dans la base de données, ce qui a nécessité une réinitialisation de la base de données afin d'éviter les incohérences. Désolé pour le dérangement."
	AL["DISABLE_SEARCHING_RARE_TOOLTIP"] = "Désactiver les alertes pour ce PNJ rare"
	AL["DISABLE_SOUND"] = "Désactiver les alertes audio"
	AL["DISABLE_SOUND_DESC"] = "Lorsque cette option est activée, vous ne recevrez pas d'alertes audio"
	AL["DISABLED_SEARCHING_RARE"] = "Alertes désactivées pour ce PNJ rare:"
	AL["DISPLAY"] = "Afficher"
	AL["DISPLAY_BUTTON_DESC"] = "Lorsqu'il est désactivé, le bouton et la miniature ne seront plus affichés. Cela n'affecte pas le son de l'alarme et les alertes de chat"
	AL["TEST_DESC"] = "Appuyez sur le bouton pour afficher un exemple d'alerte. Vous pouvez faire glisser et déposer le panneau vers une autre position où il sera désormais affiché."
	AL["TOC_NOTES"] = "Scanner mini-carte. Vous avertit visuellement avec un bouton et une miniature et émet un son à chaque fois qu'un PNJ, un trésor / coffre ou un événement rare apparaît dans votre mini-carte"
	AL["TOGGLE_FILTERS"] = "Basculer les filtres"
	AL["TOGGLE_FILTERS_DESC"] = "Basculer tous les filtres à la fois"
	AL["TOOLTIP_BOTTOM"] = "Côté inférieur"
	AL["TOOLTIP_CURSOR"] = "Suivre le curseur"
	AL["TOOLTIP_LEFT"] = "Côté gauche"
	AL["TOOLTIP_RIGHT"] = "Côté droit"
	AL["TOOLTIP_TOP"] = "Face supérieure"
	AL["UNKNOWN"] = "Inconnue"
	AL["UNKNOWN_TARGET"] = "Cible inconnue"
	AL["ZONES_FILTERS_SEARCH_DESC"] = "Tapez le nom de la zone pour filtrer la liste ci-dessous"

	-- CONTINENT names
	AL["ZONES_CONTINENT_LIST"] = {
		[9999] = "Class Halls"; --Class Halls
		[9998] = "Île de Sombrelune"; --Darkmoon Island
		[9997] = "Dungeons/Scenarios"; --Dungeons/Scenarios
		[9996] = "Raids"; --Raids
		[9995] = "Unknown"; --Unknown
	}
end