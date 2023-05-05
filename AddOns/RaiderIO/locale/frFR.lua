-- Generated from CurseForge on Thu May  4 19:43:24 UTC 2023
local ns = select(2, ...) ---@type ns @The addon namespace.

if ns:IsSameLocale("frFR") then
	local L = ns.L or ns:NewLocale()

	L.LOCALE_NAME = "frFR"

L["ALLOW_IN_LFD"] = "Autoriser pour la Recherche de Donjon"
L["ALLOW_IN_LFD_DESC"] = "Ajoute une option pour copier l'url du profil Raider.IO dans le menu du bouton droit d'un groupe ou d'un candidat"
L["ALLOW_ON_PLAYER_UNITS"] = "Autoriser pour les cadres d'unité"
L["ALLOW_ON_PLAYER_UNITS_DESC"] = "Ajoute une option pour copier l'url du profil Raider.IO dans le menu bouton droit d'un cadre d'unité."
L["API_DEPRECATED"] = [=[|cffFF0000Attention!|r L'Addon |cffFFFFFF%s|r appelle une fonction obsolète de RaiderIO.%s. Cette fonction sera supprimées dans les versions futures. Veuillez encourager l'auteur de %s 
à mettre à jour son addon. Pile d'exécution: %s ]=]
L["API_DEPRECATED_UNKNOWN_ADDON"] = "<AddOn Inconnu>"
L["API_DEPRECATED_UNKNOWN_FILE"] = "<Fichier d'AddOn Inconnu>"
L["API_DEPRECATED_WITH"] = "|cffFF0000Attention!|r L'Addon |cffFFFFFF%s|r appelle une fonction obsolète de RaiderIO.%s. Cette fonction sera supprimée dans de futures versions. Veuillez encourager l'auteur de %s à se mettre à jour vers la nouvelle API de RaiderIO.%s à la place. Pile d'exécution: %s "
L["API_INVALID_DATABASE"] = [=[|cffFF0000Attention!|r Une base de données RaiderIO invalide à été détectée |cffffffff%s|r. Veuillez 
 rafraîchir toutes les régions et factions du client RaiderIO, ou réinstallez l'Addon manuellement. ]=]
L["AUTO_COMBATLOG"] = "Activer Automatiquement le Journal de Combat dans les Raids et Donjons"
L["AUTO_COMBATLOG_DESC"] = "Active ou Désactive Automatiquement le Journalisation de Combat quand vous entrez et sortez des Raids et Donjons pris en charge."
L["BEST_FOR_DUNGEON"] = "Meilleure clé pour le donjon"
L["BEST_RUN"] = "Meilleure clé"
L["BEST_SCORE"] = "Meilleur Score M+ (%s)"
L["CANCEL"] = "Annuler"
L["CHANGES_REQUIRES_UI_RELOAD"] = [=[Vos changements ont été sauvegardé, mais il faut recharger l'interface pour qu'elles prennent effets.

Voulez-vous faire cela maintenant ?]=]
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_MPLUS"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_MPLUS_WITH_SCORE"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_PVP"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_RAID_DEFAULT"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_RAID_HEROIC"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_RAID_MYTHIC"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_RAID_NORMAL"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_GUILD_SOCIAL"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_TEAM_MPLUS_DEFAULT"] = ""--]] 
--[[Translation missing --]]
--[[ L["CHARACTER_LF_TEAM_MPLUS_WITH_SCORE"] = ""--]] 
L["CHECKBOX_DISPLAY_WEEKLY"] = "Hebdomadaire"
L["CHOOSE_HEADLINE_HEADER"] = "Titre de l'infobulle Mythique+"
L["CONFIG_WHERE_TO_SHOW_TOOLTIPS"] = "Où afficher la progression Mythique+ et de Raid"
L["CONFIRM"] = "Confirmer"
L["COPY_RAIDERIO_PROFILE_URL"] = "Copier le profil Raider.IO"
--[[Translation missing --]]
--[[ L["COPY_RAIDERIO_RECRUITMENT_URL"] = ""--]] 
L["COPY_RAIDERIO_URL"] = "Copier l'url Raider.IO"
L["CURRENT_MAINS_SCORE"] = "Score M+ du personnage principal"
L["CURRENT_SCORE"] = "Score Actuel M+"
--[[Translation missing --]]
--[[ L["DB_MODULES"] = ""--]] 
--[[Translation missing --]]
--[[ L["DB_MODULES_HEADER_MYTHIC_PLUS"] = ""--]] 
--[[Translation missing --]]
--[[ L["DB_MODULES_HEADER_RAIDING"] = ""--]] 
--[[Translation missing --]]
--[[ L["DB_MODULES_HEADER_RECRUITMENT"] = ""--]] 
L["DISABLE_DEBUG_MODE_RELOAD"] = [=[
Vous désactivez le mode de débogage.

Cliquez sur Confirmer pour recharger votre interface.]=]
--[[Translation missing --]]
--[[ L["DISABLE_RWF_MODE_BUTTON"] = ""--]] 
--[[Translation missing --]]
--[[ L["DISABLE_RWF_MODE_BUTTON_TOOLTIP"] = ""--]] 
--[[Translation missing --]]
--[[ L["DISABLE_RWF_MODE_RELOAD"] = ""--]] 
L["DPS"] = "DPS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_AA"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_AV"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_COS"] = ""--]] 
L["DUNGEON_SHORT_NAME_DOS"] = "DOS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_GD"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_GMBT"] = ""--]] 
L["DUNGEON_SHORT_NAME_HOA"] = "HOA"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_HOV"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_ID"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_LOWR"] = ""--]] 
L["DUNGEON_SHORT_NAME_MISTS"] = "MISTS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_NO"] = ""--]] 
L["DUNGEON_SHORT_NAME_NW"] = "NW"
L["DUNGEON_SHORT_NAME_PF"] = "PF"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_RLP"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_SBG"] = ""--]] 
L["DUNGEON_SHORT_NAME_SD"] = "SD"
L["DUNGEON_SHORT_NAME_SOA"] = "SOA"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_STRT"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_TJS"] = ""--]] 
L["DUNGEON_SHORT_NAME_TOP"] = "TOP"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_UPPR"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_VOTW"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_WORK"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_YARD"] = ""--]] 
L["ENABLE_AUTO_FRAME_POSITION"] = "Positionner le cadre de profil RaiderIO automatiquement "
L["ENABLE_AUTO_FRAME_POSITION_DESC"] = "Activer cette option gardera l'info-bulle de profil M+ à côté du cadre de recherche de donjon ou de l'info-bulle du joueur. "
L["ENABLE_DEBUG_MODE_RELOAD"] = [=[Vous activez le mode de débogage. Ceci est destiné uniquement à des fins de test et de développement, et entraînera une utilisation supplémentaire de la mémoire.

 Cliquez sur Confirmer pour recharger votre interface.]=]
L["ENABLE_LOCK_PROFILE_FRAME"] = "Verrouiller le cadre de profil RaiderIO"
L["ENABLE_LOCK_PROFILE_FRAME_DESC"] = "Empêche le déplacement du cadre de profil M+. Cela n'a aucun effet si le cadre de profil M+ est configuré pour être positionné automatiquement. "
L["ENABLE_NO_SCORE_COLORS"] = "Désactiver les couleurs de score"
L["ENABLE_NO_SCORE_COLORS_DESC"] = "Tous les scores seront affichés en blanc."
L["ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS"] = "Autoriser les améliorations du client RaiderIO "
L["ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS_DESC"] = "Activer cette option vous permettra d’afficher les données détaillées du profil RaiderIO téléchargées à partir du client RaiderIO pour les personnages réclamés. "
--[[Translation missing --]]
--[[ L["ENABLE_RWF_MODE_BUTTON"] = ""--]] 
--[[Translation missing --]]
--[[ L["ENABLE_RWF_MODE_BUTTON_TOOLTIP"] = ""--]] 
--[[Translation missing --]]
--[[ L["ENABLE_RWF_MODE_RELOAD"] = ""--]] 
L["ENABLE_SIMPLE_SCORE_COLORS"] = "Utiliser des couleurs simples pour le score"
L["ENABLE_SIMPLE_SCORE_COLORS_DESC"] = "Utiliser les couleurs de raretés (rare, épique, etc ...) pour les scores. Cela peut aider pour distinguer les tiers de score."
L["EXPORTJSON_COPY_TEXT"] = "Copiez le texte suivant et collez-le n'importe où sur | cff00C8FFhttps://raider.io|r pour rechercher tous les joueurs. "
L["GENERAL_TOOLTIP_OPTIONS"] = "Options générales de l'infobulle"
L["GUILD_BEST_SEASON"] = "Guilde: Top Saison"
L["GUILD_BEST_TITLE"] = "Record Raider.IO"
L["GUILD_BEST_WEEKLY"] = "Guilde : Top Semaine"
--[[Translation missing --]]
--[[ L["GUILD_LF_MPLUS_DEFAULT"] = ""--]] 
--[[Translation missing --]]
--[[ L["GUILD_LF_MPLUS_WITH_SCORE"] = ""--]] 
--[[Translation missing --]]
--[[ L["GUILD_LF_PVP"] = ""--]] 
--[[Translation missing --]]
--[[ L["GUILD_LF_RAID_DEFAULT"] = ""--]] 
--[[Translation missing --]]
--[[ L["GUILD_LF_RAID_HEROIC"] = ""--]] 
--[[Translation missing --]]
--[[ L["GUILD_LF_RAID_MYTHIC"] = ""--]] 
--[[Translation missing --]]
--[[ L["GUILD_LF_RAID_NORMAL"] = ""--]] 
--[[Translation missing --]]
--[[ L["GUILD_LF_SOCIAL"] = ""--]] 
L["HEALER"] = "Heal"
L["HIDE_OWN_PROFILE"] = "Masquer l'infobulle du profil RaiderIO personnel "
L["HIDE_OWN_PROFILE_DESC"] = "Lorsque cette option est activée, cette option n’affichera pas votre propre info-bulle de profil RaiderIO, mais peut afficher celles des autres joueurs s’ils en ont une. "
L["INVERSE_PROFILE_MODIFIER"] = "Inverser le modificateur de l'info bulle"
L["INVERSE_PROFILE_MODIFIER_DESC"] = "Activer cette option va inverser le comportement de l'info-bulle lorsque l'on utilise les touches (shift/ctrl/alt)."
L["LOCKING_PROFILE_FRAME"] = "RaiderIO: Verrouiller le cadre de profil M+. "
L["MAINS_BEST_SCORE_BEST_SEASON"] = "Meilleur score M+ du personnage principal (%s)"
L["MAINS_RAID_PROGRESS"] = "Progression du personnage principal "
L["MAINS_SCORE"] = "Score du personnage principal"
L["MODULE_AMERICAS"] = "Amérique"
L["MODULE_EUROPE"] = "Europe"
L["MODULE_KOREA"] = "Corée"
L["MODULE_TAIWAN"] = "Taïwan"
L["MY_PROFILE_TITLE"] = "Mon Profil Mythic+"
--[[Translation missing --]]
--[[ L["MYTHIC_PLUS_DB_MODULES"] = ""--]] 
L["MYTHIC_PLUS_SCORES"] = "Scores Mythique+ "
L["NO_GUILD_RECORD"] = "Aucun donjon de guilde"
L["OPEN_CONFIG"] = "Ouvrir la configuration"
L["OUT_OF_SYNC_DATABASE_S"] = "|cffFFFFFF%s|r a des données de dates différentes entre les factions. Pour résoudre ça, merci de mettre à jour vos paramètres sur le client RaiderIO pour mettre à jour les deux factions."
L["OUTDATED_DATABASE"] = "Dernière mise à jour des scores il y a %d jours"
L["OUTDATED_DATABASE_HOURS"] = "Dernière mise à jour des scores il y a %d heures"
L["OUTDATED_DOWNLOAD_LINK"] = "Télécharger : %s"
L["OUTDATED_EXPIRED_ALERT"] = "|cffFFFFFF%s|r utilise des données périmées. Veuillez mettre à jour maintenant pour avoir des données les plus précises : |cffFFFFFF%s|r"
L["OUTDATED_EXPIRED_TITLE"] = "Les données de Raider.IO ont expiré"
L["OUTDATED_EXPIRES_IN_DAYS"] = "Les données de Raider.IO expirent dans %d jours"
L["OUTDATED_EXPIRES_IN_HOURS"] = "Les données de Raider.IO expirent dans %d heures"
L["OUTDATED_EXPIRES_IN_MINUTES"] = "Les données de Raider.IO Expirent dans %d Minutes"
L["OUTDATED_PROFILE_TOOLTIP_MESSAGE"] = "Veuillez mettre à jour maintenant votre addon pour avoir des données les plus précises. Les joueurs travaillent dur pour améliorer leurs progression, et l'affichage de données très anciennes ne leur rend pas service. Vous pouvez utiliser le client Raider.IO pour synchroniser automatiquement vos données."
L["PREVIOUS_SCORE"] = "Score M+ Précédent (%s)"
L["PROFILE_BEST_RUNS"] = "Meilleurs Donjons"
--[[Translation missing --]]
--[[ L["PROFILE_TOOLTIP_ANCHOR_TOOLTIP"] = ""--]] 
L["PROVIDER_NOT_LOADED"] = "|cffFF0000Attention:|r |cffFFFFFF%s|r Aucune donnée trouvée pour votre faction actuelle . Veuillez vérifier vos paramètres |cffFFFFFF/raiderio|r et activer les données d'info-bulle pour |cffFFFFFF%s|r."
L["RAID_BOSS_CN_1"] = "Hurlaile"
L["RAID_BOSS_CN_10"] = "Sire Denathrius"
L["RAID_BOSS_CN_2"] = "Altimor le Veneur"
L["RAID_BOSS_CN_3"] = "Destructeur affamé"
L["RAID_BOSS_CN_4"] = "Artificier Xy'mox"
L["RAID_BOSS_CN_5"] = "Salut du roi-soleil"
L["RAID_BOSS_CN_6"] = "Dame Inerva Sombreveine"
L["RAID_BOSS_CN_7"] = "Le Conseil du Sang "
L["RAID_BOSS_CN_8"] = "Fangepoing"
L["RAID_BOSS_CN_9"] = "Généraux de la Légion de Pierre"
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_10"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FCN_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_10"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_11"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSFO_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_10"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FSOD_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_10"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_11"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SFO_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_10"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_SOD_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_VOTI_8"] = ""--]] 
L["RAID_DIFFICULTY_NAME_HEROIC"] = "Héroïque"
L["RAID_DIFFICULTY_NAME_MYTHIC"] = "Mythique"
L["RAID_DIFFICULTY_NAME_NORMAL"] = "Normal"
L["RAID_DIFFICULTY_SUFFIX_HEROIC"] = "H"
L["RAID_DIFFICULTY_SUFFIX_MYTHIC"] = "M"
L["RAID_DIFFICULTY_SUFFIX_NORMAL"] = "N"
L["RAID_ENCOUNTERS_DEFEATED_TITLE"] = "Rencontres de Raid vaincues"
L["RAIDERIO_AVERAGE_PLAYER_SCORE"] = "Moy. de score Raider.IO sur des +%s"
L["RAIDERIO_BEST_RUN"] = "Meilleur donjon M+ Raider.IO"
L["RAIDERIO_CLIENT_CUSTOMIZATION"] = "Modification avec le Client RaiderIO"
L["RAIDERIO_LIVE_TRACKING"] = "Raider.IO Suivi en Direct"
L["RAIDERIO_MP_BASE_SCORE"] = "Score MM+ Raider.IO de base "
L["RAIDERIO_MP_BEST_SCORE"] = "Score M+ Raider.IO (%s)"
L["RAIDERIO_MP_SCORE"] = "Score Raider.IO M+"
L["RAIDERIO_MYTHIC_OPTIONS"] = "Options de l'addon Raider.IO"
L["RAIDING_DATA_HEADER"] = "Progression de Raid Raider.io"
--[[Translation missing --]]
--[[ L["RAIDING_DB_MODULES"] = ""--]] 
--[[Translation missing --]]
--[[ L["RECRUITMENT_DB_MODULES"] = ""--]] 
L["RELOAD_LATER"] = "Je rechargerai l'interface plus tard"
L["RELOAD_NOW"] = "Recharger l'interface maintenant"
--[[Translation missing --]]
--[[ L["RELOAD_RWF_MODE_BUTTON"] = ""--]] 
--[[Translation missing --]]
--[[ L["RELOAD_RWF_MODE_BUTTON_TOOLTIP"] = ""--]] 
--[[Translation missing --]]
--[[ L["RWF_MINIBUTTON_TOOLTIP"] = ""--]] 
--[[Translation missing --]]
--[[ L["RWF_SUBTITLE_LOGGING_FILTERED_LOOT"] = ""--]] 
--[[Translation missing --]]
--[[ L["RWF_SUBTITLE_LOGGING_LOOT"] = ""--]] 
--[[Translation missing --]]
--[[ L["RWF_TITLE"] = ""--]] 
--[[Translation missing --]]
--[[ L["SEARCH_NAME_LABEL"] = ""--]] 
--[[Translation missing --]]
--[[ L["SEARCH_REALM_LABEL"] = ""--]] 
--[[Translation missing --]]
--[[ L["SEARCH_REGION_LABEL"] = ""--]] 
L["SEASON_LABEL_1"] = "S1-P"
L["SEASON_LABEL_2"] = "S2"
L["SEASON_LABEL_3"] = "S3"
L["SEASON_LABEL_4"] = "S4"
L["SHOW_AVERAGE_PLAYER_SCORE_INFO"] = "Afficher le score moyen des joueurs pour une clé dans les temps"
L["SHOW_AVERAGE_PLAYER_SCORE_INFO_DESC"] = "Afficher la moyenne des scores Raider.IO des joueurs ayant fini une clé dans les temps. Cela est visible sur l'infobulle de la clé ainsi que des joueurs dans la recherche de groupe."
L["SHOW_BEST_MAINS_SCORE"] = "Afficher le score Mythique+ de la meilleure saison du personnage principal"
L["SHOW_BEST_MAINS_SCORE_DESC"] = "Affiche le score Mythique+ de la meilleure saison du personnage principal d'un joueur et la progression du raid sur l'info-bulle. Les joueurs doivent s'être inscrits sur Raider.IO et avoir déclaré un personnage principal."
L["SHOW_BEST_RUN"] = "Afficher le meilleur Mythique+ comme titre"
L["SHOW_BEST_RUN_DESC"] = "Afficher le meilleur Donjon M+ du joueur de la saison actuelle comme titre dans l'infobulle."
L["SHOW_BEST_SEASON"] = [=[
Afficher le meilleur score mythique+ de la saison en titre]=]
L["SHOW_BEST_SEASON_DESC"] = [=[
Affiche le meilleur score de la saison Mythique+ du joueur dans le titre de l'info-bulle. Si le score provient d'une saison précédente, la saison sera indiquée dans le titre de l'info-bulle.]=]
--[[Translation missing --]]
--[[ L["SHOW_CHESTS_AS_MEDALS"] = ""--]] 
--[[Translation missing --]]
--[[ L["SHOW_CHESTS_AS_MEDALS_DESC"] = ""--]] 
L["SHOW_CLIENT_GUILD_BEST"] = "Afficher les meilleurs records dans la recherche de groupes de Donjons Mythiques"
L["SHOW_CLIENT_GUILD_BEST_DESC"] = "Si vous activez cette option, le Top 5 de votre guilde (par saison ou semaine) sera affiché dans l'onglet Donjons Mythiques de la fenêtre Recherche de groupe."
L["SHOW_CURRENT_SEASON"] = "Afficher le score Mythique+ de la saison actuelle en titre"
L["SHOW_CURRENT_SEASON_DESC"] = "Affiche le score du joueur pour la saison Mythique+ actuelle comme titre de l'info-bulle."
L["SHOW_IN_FRIENDS"] = "Afficher dans la liste d'amis"
L["SHOW_IN_FRIENDS_DESC"] = "Afficher le score Mythique+ lorsqu'on survole un ami."
L["SHOW_IN_LFD"] = "Afficher dans la recherche de donjons"
L["SHOW_IN_LFD_DESC"] = "Afficher le score Mythique+ lorsqu'on survole un groupe ou un candidat."
L["SHOW_IN_SLASH_WHO_RESULTS"] = "Afficher dans les résultats du /qui"
L["SHOW_IN_SLASH_WHO_RESULTS_DESC"] = "Afficher le score Mythique+ lorsque l'on /qui quelqu'un de spécifique."
L["SHOW_IN_WHO_UI"] = "Afficher dans la fenêtre \"Qui\""
L["SHOW_IN_WHO_UI_DESC"] = "Afficher le score Mythique+ lorsqu'on survole les résultats de la fenêtre \"Qui\"."
L["SHOW_KEYSTONE_INFO"] = "Affiche les informations de la clé"
L["SHOW_KEYSTONE_INFO_DESC"] = "Ajoute des informations sur l'info-bulle de la clé. Propose un score Mythique+ pour le groupe."
L["SHOW_LEADER_PROFILE"] = "Activer l'utilisation des touches (shift/ctrl/alt)"
L["SHOW_LEADER_PROFILE_DESC"] = "Utiliser un des touches (shift/ctrl/alt), permet de changer entre la vue de son profil et celui du chef de groupe."
L["SHOW_MAINS_SCORE"] = "Afficher le score du personnage principal"
L["SHOW_MAINS_SCORE_DESC"] = "Afficher le score du personnage principal du joueur pour la saison actuelle. Ces joueurs doivent avoir un compte sur Raider.IO où il a définit un personnage comme son personnage principal."
L["SHOW_ON_GUILD_ROSTER"] = "Afficher dans l'onglet guilde"
L["SHOW_ON_GUILD_ROSTER_DESC"] = "Afficher le score Mythique+ lorsqu'on survole un joueur dans la liste des membres de la guilde."
L["SHOW_ON_PLAYER_UNITS"] = "Afficher sur les cadres d'unité"
L["SHOW_ON_PLAYER_UNITS_DESC"] = "Afficher le score Mythique+ lorsqu'on survole le cadre d'un joueur. "
L["SHOW_RAID_ENCOUNTERS_IN_PROFILE"] = "Affiche la progression du Raid dans l'infobulle du joueur"
L["SHOW_RAID_ENCOUNTERS_IN_PROFILE_DESC"] = "Si activé, affiche la progression de Raid du joueur dans l'infobulle Raider.IO"
L["SHOW_RAIDERIO_BESTRUN_FIRST"] = "(Expérimental) Prioriser l'affichage Raider.IO du meilleur donjon"
L["SHOW_RAIDERIO_BESTRUN_FIRST_DESC"] = "Ceci est une fonctionnalité expérimentale. Au lieu d'afficher le score Raider.IO comme première ligne, affiche le meilleur donjon du joueur."
L["SHOW_RAIDERIO_PROFILE"] = "Afficher le Profil Raider.IO dans la recherche de donjon"
L["SHOW_RAIDERIO_PROFILE_DESC"] = "Afficher le Profil Raider.IO en Info-Bulle dans la recherche de donjon"
L["SHOW_ROLE_ICONS"] = "Afficher les icônes de rôles dans les info-bulles"
L["SHOW_ROLE_ICONS_DESC"] = "Lorsque cette option est activée, les principaux rôles du joueur en Mythique+ seront affichés dans les info-bulles."
L["SHOW_SCORE_IN_COMBAT"] = "Afficher le score en combat"
L["SHOW_SCORE_IN_COMBAT_DESC"] = "Le désactiver pour diminuer l'impact sur les performances lorsque l'on survole un joueur en combat."
L["SHOW_SCORE_WITH_MODIFIER"] = "Montre l'Info-bulle Raider.IO avec modificateur"
L["SHOW_SCORE_WITH_MODIFIER_DESC"] = "Désactive l'Affichage des Données lors du survol des joueurs, sauf si une touche de modification est maintenue."
L["TANK"] = "Tank"
--[[Translation missing --]]
--[[ L["TEAM_LF_MPLUS_DEFAULT"] = ""--]] 
--[[Translation missing --]]
--[[ L["TEAM_LF_MPLUS_WITH_SCORE"] = ""--]] 
L["TIMED_10_RUNS"] = "10-14+ dans les temps"
L["TIMED_15_RUNS"] = "15+ dans les temps"
L["TIMED_20_RUNS"] = "20+ dans les temps"
L["TIMED_5_RUNS"] = "5-9+ dans les temps"
L["TOOLTIP_PROFILE"] = "Modification du Profil"
L["UNKNOWN_SERVER_FOUND"] = "|cffFFFFFF%s|r a rencontré une erreur. S'il vous plait, écrivez ces informations |cffFF9999{|r |cffFFFFFF%s|r |cffFF9999,|r |cffFFFFFF%s|r |cffFF9999}|r et reporter le aux développers. Merci !"
L["UNLOCKING_PROFILE_FRAME"] = "RaiderIO: Déverrouiller le cadre de profil M+."
L["USE_ENGLISH_ABBREVIATION"] = "Forcer les abréviations anglaises pour les Donjons"
L["USE_ENGLISH_ABBREVIATION_DESC"] = "Lorsque cette option est activée, les abréviations utilisées pour les Donjons seront les versions anglaises et non celles de votre langue actuelle."
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS"] = "Autorise le client Raider.IO à contrôler le Journal de Combat"
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS_DESC"] = "Autorise le client Raider.IO (si présent) à contrôler automatiquement vos paramètres de Journal de Combat."
L["WARNING_DEBUG_MODE_ENABLE"] = "|cffFFFFFF%s|r Le mode de débogage est activé. Vous pouvez le désactiver en tapant |cffFFFFFF/raiderio debug|r."
L["WARNING_LOCK_POSITION_FRAME_AUTO"] = "RaiderIO: Vous devez d'abord désactiver le positionnement automatique pour le profil RaiderIO."
--[[Translation missing --]]
--[[ L["WARNING_RWF_MODE_ENABLE"] = ""--]] 
--[[Translation missing --]]
--[[ L["WIPE_RWF_MODE_BUTTON"] = ""--]] 
--[[Translation missing --]]
--[[ L["WIPE_RWF_MODE_BUTTON_TOOLTIP"] = ""--]] 

	ns.L = L
end
