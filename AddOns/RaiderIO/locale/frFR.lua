-- Generated from CurseForge on Fri Mar 14 07:54:39 UTC 2025
local ns = select(2, ...) ---@class ns @The addon namespace.

if ns:IsSameLocale("frFR") then

	local L = ns.L or ns:NewLocale()
	ns.L = L

	L.LOCALE_NAME = "frFR"

L["ALLOW_IN_LFD"] = "Autoriser pour la Recherche de groupe"
L["ALLOW_IN_LFD_CLASSIC"] = "Autoriser pour la Recherche de groupe"
L["ALLOW_IN_LFD_CLASSIC_DESC"] = "Clic droit sur les groupes ou les joueurs dans l'outil de Recherche de groupe pour copier l'URL du profil Raider.IO."
L["ALLOW_IN_LFD_DESC"] = "Clic droit sur les groupes ou les joueurs dans l'outil de Recherche de groupe pour copier l'URL du profil Raider.IO."
L["ALLOW_ON_PLAYER_UNITS"] = "Autoriser pour les cadres d'unité"
L["ALLOW_ON_PLAYER_UNITS_DESC"] = "Ajoute une option pour copier l'url du profil Raider.IO dans le menu bouton droit d'un cadre d'unité."
L["API_DEPRECATED"] = [=[|cffFF0000Attention!|r L'addon |cffFFFFFF%s|r appelle une fonction obsolète de Raider.IO.%s. Cette fonction sera supprimées dans les versions futures. Veuillez encourager l'auteur de %s 
à mettre à jour son addon. Pile d'exécution: %s]=]
L["API_DEPRECATED_UNKNOWN_ADDON"] = "<Addon inconnu>"
L["API_DEPRECATED_UNKNOWN_FILE"] = "<Fichier d'addon inconnu>"
L["API_DEPRECATED_WITH"] = "|cffFF0000Attention !|r L'addon |cffFFFFFF%s|r appelle une fonction obsolète de Raider.IO.%s. Cette fonction sera supprimée dans de futures versions. Veuillez encourager l'auteur de %s à se mettre à jour vers la nouvelle API de Raider.IO.%s à la place. Pile d'exécution: %s"
L["API_INVALID_DATABASE"] = "|cffFF0000Attention !|r Détection d'une base de données Raider.IO non valide dans |cffFFFFFF%s|r. Veuillez actualiser toutes les régions et factions dans le client Raider.IO ou réinstaller l'addon manuellement."
L["AUTO_COMBATLOG"] = "Activer automatiquement le Journal de combat"
L["AUTO_COMBATLOG_DESC"] = "Activez / désactivez automatiquement le Journal de combat lorsque vous entrez et sortez de raids et de donjons pris en charge."
L["AUTO_COMBATLOG_DISABLED_DESC"] = "Le Journal de combat est désactivé sur un personnage Cours du temps."
L["BEST_FOR_DUNGEON"] = "Meilleure clé pour le donjon"
L["BEST_RUN"] = "Meilleure clé"
L["BEST_SCORE"] = "Meilleur Score M+ (%s)"
L["BINDING_CATEGORY_RAIDERIO"] = "Raider.IO"
L["BINDING_HEADER_RAIDERIO_REPLAYUI"] = "Interface de rediffusion"
--[[Translation missing --]]
--[[ L["BINDING_NAME_RAIDERIO_REPLAYUI_TIMING_BOSS"] = ""--]] 
--[[Translation missing --]]
--[[ L["BINDING_NAME_RAIDERIO_REPLAYUI_TIMING_DUNGEON"] = ""--]] 
L["BINDING_NAME_RAIDERIO_REPLAYUI_TOGGLE"] = "Afficher / masquer l'interface de rediffusion"
L["CANCEL"] = "Annuler"
L["CHANGES_REQUIRES_UI_RELOAD"] = "Vos modifications ont été enregistrées, mais vous devez recharger votre interface pour qu'elles prennent effet. Souhaitez-vous le faire maintenant ?"
L["CHARACTER_LF_GUILD_MPLUS"] = "Cherche une guilde Mythique +"
L["CHARACTER_LF_GUILD_MPLUS_WITH_SCORE"] = "Cherche une guilde Mythique +"
L["CHARACTER_LF_GUILD_PVP"] = "Cherche une guilde JcJ"
L["CHARACTER_LF_GUILD_RAID_DEFAULT"] = "Cherche une guilde pour les raids"
L["CHARACTER_LF_GUILD_RAID_HEROIC"] = "Cherche une guilde pour les raids héroïques"
L["CHARACTER_LF_GUILD_RAID_MYTHIC"] = "Cherche une guilde pour les raids mythiques"
L["CHARACTER_LF_GUILD_RAID_NORMAL"] = "Cherche une guilde pour les raids « normal »"
L["CHARACTER_LF_GUILD_SOCIAL"] = "Cherche une guilde pour discuter"
L["CHARACTER_LF_TEAM_MPLUS_DEFAULT"] = "Cherche une équipe Mythique +"
L["CHARACTER_LF_TEAM_MPLUS_WITH_SCORE"] = "Recherche de %d+ équipe(s) Mythique+"
L["CHECKBOX_DISPLAY_WEEKLY"] = "Hebdomadaire"
L["CHOOSE_HEADLINE_HEADER"] = "Titre de l'info-bulle Mythique+"
L["CONFIG_WHERE_TO_SHOW_TOOLTIPS"] = "Où afficher la progression Mythique+ et de Raid"
L["CONFIRM"] = "Confirmer"
L["COPY_RAIDERIO_PROFILE_URL"] = "Copier le profil Raider.IO"
L["COPY_RAIDERIO_RECRUITMENT_URL"] = "Copier l'URL de recrutement"
L["COPY_RAIDERIO_URL"] = "Copier l'URL de Raider.IO"
L["CURRENT_MAINS_SCORE"] = "Score M+ du personnage principal"
L["CURRENT_SCORE"] = "Score M+ Actuel"
L["DB_MODULES"] = "Modules de base de données"
L["DB_MODULES_HEADER_MYTHIC_PLUS"] = "Mythique+"
L["DB_MODULES_HEADER_RAIDING"] = "Raids"
L["DB_MODULES_HEADER_RECRUITMENT"] = "Recrutement"
L["DISABLE_DEBUG_MODE_RELOAD"] = "Vous désactivez le mode débogage. En cliquant sur Confirmer, vous rechargerez votre interface."
L["DISABLE_RWF_MODE_BUTTON"] = "Désactiver"
L["DISABLE_RWF_MODE_BUTTON_TOOLTIP"] = "Cliquez pour désactiver le mode « Course au World First ». Cela entraînera le rechargement de votre interface."
L["DISABLE_RWF_MODE_RELOAD"] = "Vous désactivez le mode « Course au World First ». En cliquant sur Confirmer, vous rechargerez votre interface."
L["DPS"] = "DPS"
L["DUNGEON_SHORT_NAME_AA"] = "AA"
L["DUNGEON_SHORT_NAME_AD"] = "AD"
L["DUNGEON_SHORT_NAME_ARAK"] = "AraK"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_ARC"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_AV"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_BH"] = ""--]] 
L["DUNGEON_SHORT_NAME_BREW"] = "HdB"
L["DUNGEON_SHORT_NAME_BRH"] = "BdF"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_COEN"] = ""--]] 
L["DUNGEON_SHORT_NAME_COS"] = "CoS"
L["DUNGEON_SHORT_NAME_COT"] = "CdF"
L["DUNGEON_SHORT_NAME_DAWN"] = "LBA"
L["DUNGEON_SHORT_NAME_DFC"] = "FdFN"
L["DUNGEON_SHORT_NAME_DHT"] = "FS"
L["DUNGEON_SHORT_NAME_DOS"] = "AC"
L["DUNGEON_SHORT_NAME_EB"] = "LFé"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_EOA"] = ""--]] 
L["DUNGEON_SHORT_NAME_FALL"] = "AdIRdG"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_FH"] = ""--]] 
L["DUNGEON_SHORT_NAME_FLOOD"] = "OVo"
L["DUNGEON_SHORT_NAME_GB"] = "GB"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_GD"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_GMBT"] = ""--]] 
L["DUNGEON_SHORT_NAME_HOA"] = "SdE"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_HOI"] = ""--]] 
L["DUNGEON_SHORT_NAME_HOV"] = "SdI"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_ID"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_KR"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_LOWR"] = ""--]] 
L["DUNGEON_SHORT_NAME_MISTS"] = "Brumes"
L["DUNGEON_SHORT_NAME_ML"] = "LF"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_MOS"] = ""--]] 
L["DUNGEON_SHORT_NAME_NELT"] = "NELT"
L["DUNGEON_SHORT_NAME_NL"] = "RdN"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_NO"] = ""--]] 
L["DUNGEON_SHORT_NAME_NW"] = "SN"
L["DUNGEON_SHORT_NAME_PF"] = "MP"
L["DUNGEON_SHORT_NAME_PSF"] = "PdlFs"
L["DUNGEON_SHORT_NAME_RISE"] = "AdIcdM"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_RLP"] = ""--]] 
L["DUNGEON_SHORT_NAME_ROOK"] = "Colonie"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_SBG"] = ""--]] 
L["DUNGEON_SHORT_NAME_SD"] = "PS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_SEAT"] = ""--]] 
L["DUNGEON_SHORT_NAME_SIEGE"] = "SIEGE"
L["DUNGEON_SHORT_NAME_SOA"] = "FdA"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_SOTS"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_STRT"] = ""--]] 
L["DUNGEON_SHORT_NAME_SV"] = "CAVE"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_TD"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_TJS"] = ""--]] 
L["DUNGEON_SHORT_NAME_TOP"] = "TdlS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_TOS"] = ""--]] 
L["DUNGEON_SHORT_NAME_TOTT"] = "TdM"
L["DUNGEON_SHORT_NAME_ULD"] = "ULD"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_UNDR"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_UPPR"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_VOTW"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_VP"] = ""--]] 
L["DUNGEON_SHORT_NAME_WM"] = "MM"
L["DUNGEON_SHORT_NAME_WORK"] = "Mécagone"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_YARD"] = ""--]] 
L["ENABLE_AUTO_FRAME_POSITION"] = "Positionner automatiquement le cadre de profil Raider.IO"
L["ENABLE_AUTO_FRAME_POSITION_DESC"] = "L'activation de cette option conservera l'info-bulle du profil M+ à côté du cadre de Recherche de groupe ou de l'info-bulle du joueur."
L["ENABLE_DEBUG_MODE_RELOAD"] = "Vous activez le mode débogage. Ceci est destiné uniquement à des fins de test et de développement et entraînera une utilisation supplémentaire de la mémoire. En cliquant sur Confirmer, vous rechargerez votre interface."
L["ENABLE_LOCK_PROFILE_FRAME"] = "Verrouiller le cadre de profil Raider.IO"
L["ENABLE_LOCK_PROFILE_FRAME_DESC"] = "Empêche le déplacement du cadre de profil M+. Cela n'a aucun effet si le cadre de profil M+ est configuré pour être positionné automatiquement."
L["ENABLE_NO_SCORE_COLORS"] = "Désactiver les couleurs de score"
L["ENABLE_NO_SCORE_COLORS_DESC"] = "Tous les scores seront affichés en blanc."
L["ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS"] = "Autoriser les améliorations du client Raider.IO"
L["ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS_DESC"] = "L'activation de cette option vous permettra d'afficher les données détaillées du profil Raider.IO téléchargées à partir du client Raider.IO pour vos personnages revendiqués."
L["ENABLE_REPLAY"] = "Afficher le système de rediffusion Mythique+"
L["ENABLE_REPLAY_DESC"] = "L’activer vous permettra de courir contre des sessions Mythique+ enregistrées."
L["ENABLE_RWF_MODE_BUTTON"] = "Activer"
L["ENABLE_RWF_MODE_BUTTON_TOOLTIP"] = "Cliquez pour activer le mode « Course au World First ». Cela entraînera le rechargement de votre interface."
L["ENABLE_RWF_MODE_RELOAD"] = "Vous activez le mode « Course au World First ». Ceci est destiné à être utilisé avec lors de la « Course au World First » en mode mythique et ne doit être utilisé à cette fin qu'avec le client Raider.IO pour le téléchargement de données. En cliquant sur Confirmer, vous rechargerez votre interface."
L["ENABLE_SIMPLE_SCORE_COLORS"] = "Utiliser des couleurs simples pour le score Mythique+"
L["ENABLE_SIMPLE_SCORE_COLORS_DESC"] = "Affiche uniquement les scores avec des couleurs standard (rare, épique, etc.). Cela peut permettre aux personnes daltoniennes de distinguer plus facilement les niveaux de score."
L["ENTER_REALM_AND_CHARACTER"] = "Entrez le serveur et le nom du personnage :"
L["EXPORTJSON_COPY_TEXT"] = "Copiez ce qui suit et collez-le n'importe où sur |cff00C8FFhttps://raider.io|r pour rechercher tous les joueurs."
L["GENERAL_TOOLTIP_OPTIONS"] = "Options générales des info-bulles"
L["GUILD_BEST_SEASON"] = "Guilde: Top Saison"
L["GUILD_BEST_TITLE"] = "Enregistrements Raider.IO"
L["GUILD_BEST_WEEKLY"] = "Guilde : Top Semaine"
L["GUILD_LF_MPLUS_DEFAULT"] = "Recruter des joueurs Mythique +"
L["GUILD_LF_MPLUS_WITH_SCORE"] = "Recrutement de %d+ joueur(s) pour Mythique+"
L["GUILD_LF_PVP"] = "Recruter des joueurs JcJ"
L["GUILD_LF_RAID_DEFAULT"] = "Recrutement de joueur"
L["GUILD_LF_RAID_HEROIC"] = "Recrutement de joueur pour raid héroïque"
L["GUILD_LF_RAID_MYTHIC"] = "Recrutement de joueur pour raid mythique"
L["GUILD_LF_RAID_NORMAL"] = "Recrutement de joueur pour raid normal"
L["GUILD_LF_SOCIAL"] = "Recrutement de joueur"
L["HEALER"] = "Soigneur"
L["HIDE_OWN_PROFILE"] = "Masquer l’info-bulle du profil personnel Raider.IO"
L["HIDE_OWN_PROFILE_DESC"] = "Une fois défini, cela n'affichera pas votre propre info-bulle de profil Raider.IO, mais pourra afficher celle des autres joueurs s'ils en ont une."
L["INVERSE_PROFILE_MODIFIER"] = "Inverser le modificateur de l'info bulle"
L["INVERSE_PROFILE_MODIFIER_DESC"] = "Activer cette option va inverser le comportement de l'info-bulle lorsque l'on utilise les touches (shift/ctrl/alt)."
--[[Translation missing --]]
--[[ L["LOCALE_NAME"] = ""--]] 
L["LOCKING_PROFILE_FRAME"] = "Raider.IO : Verrouillage du cadre de profil M+."
L["MAINS_BEST_SCORE_BEST_SEASON"] = "Meilleur score M+ du personnage principal (%s)"
L["MAINS_RAID_PROGRESS"] = "Progression du personnage principal "
L["MAINS_SCORE"] = "Score du personnage principal"
L["MINIMAP_SHORTCUT_BROKER_ENABLE"] = "Activer le bouton du compartiment supplémentaire"
L["MINIMAP_SHORTCUT_BROKER_ENABLE_DESC"] = "Activez pour afficher l’icône dans le menu du compartiment complémentaire. Cela le rendra également disponible dans tout autre addon prenant en charge le système de courtage."
L["MINIMAP_SHORTCUT_ENABLE"] = "Activer le bouton"
L["MINIMAP_SHORTCUT_ENABLE_DESC"] = "Activez pour afficher l'icône autour de la mini-carte. Cela le rendra également disponible dans tout autre addon prenant en charge le système de courtage."
L["MINIMAP_SHORTCUT_HEADER"] = "Mini-carte"
L["MINIMAP_SHORTCUT_HELP"] = "|A:newplayertutorial-icon-mouse-leftbutton:16:12|a Recherche |A:newplayertutorial-icon-mouse-rightbutton:16:12|a Paramètres"
L["MINIMAP_SHORTCUT_HELP_LEFT_CLICK"] = "Clic gauche"
L["MINIMAP_SHORTCUT_HELP_RIGHT_CLICK"] = "Clic droit"
L["MINIMAP_SHORTCUT_HELP_SEARCH"] = "Recherche"
L["MINIMAP_SHORTCUT_HELP_SETTINGS"] = "Paramètres"
L["MINIMAP_SHORTCUT_LOCK"] = "Verrouiller le bouton"
L["MINIMAP_SHORTCUT_MINIMAP_ENABLE"] = "Activer le bouton de la mini-carte"
L["MINIMAP_SHORTCUT_MINIMAP_ENABLE_DESC"] = "Activez pour afficher le bouton autour de la mini-carte."
L["MINIMAP_SHORTCUT_MINIMAP_LOCK"] = "Verrouiller le bouton sur la mini-carte"
L["MODULE_AMERICAS"] = "Amérique"
L["MODULE_EUROPE"] = "Europe"
L["MODULE_KOREA"] = "Corée"
L["MODULE_TAIWAN"] = "Taïwan"
L["MY_PROFILE_TITLE"] = "Profil Raider.IO"
L["MYTHIC_PLUS_DB_MODULES"] = "Modules de base de données Mythique+"
L["MYTHIC_PLUS_SCORES"] = "Scores Mythique+ "
L["NO_GUILD_RECORD"] = "Aucun enregistrement de guilde"
L["OPEN_CONFIG"] = "Ouvrir la configuration"
L["OUT_OF_SYNC_DATABASE_S"] = "|cffFFFFFF%s|r a des données de faction Horde/Alliance qui ne sont pas synchronisées. Veuillez mettre à jour les paramètres de votre client Raider.IO pour synchroniser les deux factions."
L["OUTDATED_DATABASE"] = "Dernière mise à jour des scores il y a %d jours"
L["OUTDATED_DATABASE_HOURS"] = "Dernière mise à jour des scores il y a %d heures"
L["OUTDATED_DOWNLOAD_LINK"] = "Télécharger : |cffFFBD0A%s|r"
L["OUTDATED_EXPIRED_ALERT"] = "|cffFFFFFF%s|r utilise des données expirées. Veuillez mettre à jour maintenant pour afficher les données les plus précises : |cffFFFFFF%s|r"
L["OUTDATED_EXPIRED_TITLE"] = "Les données Raider.IO ont expiré"
L["OUTDATED_EXPIRES_IN_DAYS"] = "Les données Raider.IO expirent dans %d jours"
L["OUTDATED_EXPIRES_IN_HOURS"] = "Les données Raider.IO expirent dans %d heures"
L["OUTDATED_EXPIRES_IN_MINUTES"] = "Les données Raider.IO expirent dans %d minutes"
L["OUTDATED_PROFILE_TOOLTIP_MESSAGE"] = "Veuillez mettre à jour votre addon maintenant pour afficher des données les plus précises. Les joueurs travaillent dur pour améliorer leur progression, et afficher des données très anciennes ne leur rend pas service. Vous pouvez utiliser le client Raider.IO pour synchroniser automatiquement vos données."
L["PREVIOUS_SCORE"] = "Score M+ Précédent (%s)"
L["PROFILE_BEST_RUNS"] = "Meilleures clés par donjon"
L["PROFILE_TOOLTIP_ANCHOR_TOOLTIP"] = "Verrouillez le cadre de profil Raider.IO ou activez le positionnement automatique afin de masquer cette ancre."
L["PROVIDER_NOT_LOADED"] = "|cffFF0000Attention :|r |cffFFFFFF%s|r Aucune donnée trouvée pour votre faction actuelle . Veuillez vérifier vos paramètres |cffFFFFFF/raiderio|r et activer les données d'info-bulle pour |cffFFFFFF%s|r."
L["PVP_DATA_HEADER"] = "Profil JcJ Raider.IO"
L["RAID_AATDH"] = "Éveillé Amirdrassil, l’Espoir du Rêve"
L["RAID_AATSC"] = "Éveillé Aberrus, le creuset de l’Ombre"
L["RAID_AVOTI"] = "Éveillé Caveau des Incarnations"
L["RAID_BOSS_AATDH_1"] = "Racine-Noueuse"
L["RAID_BOSS_AATDH_2"] = "Igira la Cruelle"
L["RAID_BOSS_AATDH_3"] = "Volcoross"
L["RAID_BOSS_AATDH_4"] = "Conseil des rêves"
L["RAID_BOSS_AATDH_5"] = "Larodar, gardien de la flamme"
L["RAID_BOSS_AATDH_6"] = "Nymue, la trame du cercle"
L["RAID_BOSS_AATDH_7"] = "Fumeron"
L["RAID_BOSS_AATDH_8"] = "Tindral Vifsage, prophète de flamme"
L["RAID_BOSS_AATDH_9"] = "Fyrakka le Flamboyant"
L["RAID_BOSS_AATSC_1"] = "Kazzara, née des enfers"
L["RAID_BOSS_AATSC_2"] = "Chambre d’amalgamation"
L["RAID_BOSS_AATSC_3"] = "Les expériences oubliées"
L["RAID_BOSS_AATSC_4"] = "Assaut des Zaqalis"
L["RAID_BOSS_AATSC_5"] = "Rashok, l’Ancien"
L["RAID_BOSS_AATSC_6"] = "Zskarn, l’Intendant vigilant"
L["RAID_BOSS_AATSC_7"] = "Magmorax"
L["RAID_BOSS_AATSC_8"] = "Écho de Neltharion"
L["RAID_BOSS_AATSC_9"] = "Squammandant Sarkareth"
L["RAID_BOSS_ATDH_1"] = "Racine-Noueuse"
L["RAID_BOSS_ATDH_2"] = "Igira la Cruelle"
L["RAID_BOSS_ATDH_3"] = "Volcoross"
L["RAID_BOSS_ATDH_4"] = "Conseil des rêves"
L["RAID_BOSS_ATDH_5"] = "Larodar, gardien de la flamme"
L["RAID_BOSS_ATDH_6"] = "Nymue, la trame du cercle"
L["RAID_BOSS_ATDH_7"] = "Fumeron"
L["RAID_BOSS_ATDH_8"] = "Tindral Vifsage, prophète de flamme"
L["RAID_BOSS_ATDH_9"] = "Fyrakka le Flamboyant"
L["RAID_BOSS_ATSC_1"] = "Kazzara, née des enfers"
L["RAID_BOSS_ATSC_2"] = "Chambre d’amalgamation"
L["RAID_BOSS_ATSC_3"] = "Les expériences oubliées"
L["RAID_BOSS_ATSC_4"] = "Assaut des Zaqalis"
L["RAID_BOSS_ATSC_5"] = "Rashok, l’Ancien"
L["RAID_BOSS_ATSC_6"] = "Zskarn, l’Intendant vigilant"
L["RAID_BOSS_ATSC_7"] = "Magmorax"
L["RAID_BOSS_ATSC_8"] = "Écho de Neltharion"
L["RAID_BOSS_ATSC_9"] = "Squammandant Sarkareth"
L["RAID_BOSS_AVOTI_1"] = "Éranog"
L["RAID_BOSS_AVOTI_2"] = "Terros"
L["RAID_BOSS_AVOTI_3"] = "Le Conseil primordial"
L["RAID_BOSS_AVOTI_4"] = "Sennarth, la Glaciale"
L["RAID_BOSS_AVOTI_5"] = "Dathéa, transcendée"
L["RAID_BOSS_AVOTI_6"] = "Kurog Totem-Sinistre"
L["RAID_BOSS_AVOTI_7"] = "Garde-couvée Diurna"
L["RAID_BOSS_AVOTI_8"] = "Raszageth la Mange-tempêtes"
L["RAID_BOSS_BOT_1"] = "Halfus Brise-Wyrm"
L["RAID_BOSS_BOT_2"] = "Theralion et Valiona"
L["RAID_BOSS_BOT_3"] = "Conseil d’ascendants"
L["RAID_BOSS_BOT_4"] = "Cho’gall"
L["RAID_BOSS_BOT_5"] = "Sinestra"
L["RAID_BOSS_BRD_1"] = "Seigneur Roccor"
L["RAID_BOSS_BRD_2"] = "Bael’Gar"
L["RAID_BOSS_BRD_3"] = "Seigneur Incendius"
L["RAID_BOSS_BRD_4"] = "Seigneur golem Argelmach"
L["RAID_BOSS_BRD_5"] = "Les sept"
L["RAID_BOSS_BRD_6"] = "Général Forgehargne"
L["RAID_BOSS_BRD_7"] = "Ambassadeur Cinglefouet"
L["RAID_BOSS_BRD_8"] = "Empereur Dagran Thaurissan"
L["RAID_BOSS_BWD_1"] = "Système de défense Omnitron"
L["RAID_BOSS_BWD_2"] = "Magmagueule"
L["RAID_BOSS_BWD_3"] = "Atramédès"
L["RAID_BOSS_BWD_4"] = "Chimaeron"
L["RAID_BOSS_BWD_5"] = "Maloriak"
L["RAID_BOSS_BWD_6"] = "Fin de Nefarian"
L["RAID_BOSS_CN_1"] = "Hurlaile"
L["RAID_BOSS_CN_10"] = "Sire Denathrius"
L["RAID_BOSS_CN_2"] = "Altimor le Veneur"
L["RAID_BOSS_CN_3"] = "Destructeur affamé"
L["RAID_BOSS_CN_4"] = "Artificier Xy'mox"
L["RAID_BOSS_CN_5"] = "Salut du roi-soleil"
L["RAID_BOSS_CN_6"] = "Dame Inerva Sombreveine"
L["RAID_BOSS_CN_7"] = "Le Conseil du Sang"
L["RAID_BOSS_CN_8"] = "Fangepoing"
L["RAID_BOSS_CN_9"] = "Généraux de la Légion de Pierre"
L["RAID_BOSS_DS_1"] = "Morchok"
L["RAID_BOSS_DS_2"] = "Seigneur de guerre Zon’ozz"
L["RAID_BOSS_DS_3"] = "Yor’sahj l’Insomniaque"
L["RAID_BOSS_DS_4"] = "Hagara la Lieuse des tempêtes"
L["RAID_BOSS_DS_5"] = "Ultraxion"
L["RAID_BOSS_DS_6"] = "Maître de guerre Corne-Noire"
L["RAID_BOSS_DS_7"] = "Échine d'Aile de mort"
L["RAID_BOSS_DS_8"] = "Folie d'Aile de mort"
L["RAID_BOSS_FCN_1"] = "Hurlaile"
L["RAID_BOSS_FCN_10"] = "Sire Denathrius"
L["RAID_BOSS_FCN_2"] = "Altimor le Veneur"
L["RAID_BOSS_FCN_3"] = "Salut du roi-soleil"
L["RAID_BOSS_FCN_4"] = "Artificier Xy’mox"
L["RAID_BOSS_FCN_5"] = "Destructeur affamé"
L["RAID_BOSS_FCN_6"] = "Dame Inerva Sombreveine"
L["RAID_BOSS_FCN_7"] = "Le conseil du Sang"
L["RAID_BOSS_FCN_8"] = "Fangepoing"
L["RAID_BOSS_FCN_9"] = "Généraux de la Légion de pierre"
--[[Translation missing --]]
--[[ L["RAID_BOSS_FL_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FL_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FL_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FL_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FL_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FL_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_FL_7"] = ""--]] 
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
--[[ L["RAID_BOSS_ICC_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_10"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_11"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_12"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ICC_9"] = ""--]] 
L["RAID_BOSS_LOU_1"] = "Vexie et les Écrouabouilles"
L["RAID_BOSS_LOU_2"] = "Chaudron du carnage"
L["RAID_BOSS_LOU_3"] = "Rik Rebond"
L["RAID_BOSS_LOU_4"] = "Stix Jettetout"
L["RAID_BOSS_LOU_5"] = "Pignonneur Crosseplatine"
L["RAID_BOSS_LOU_6"] = "Le Bandit manchot"
L["RAID_BOSS_LOU_7"] = "Verr’Minh, chefs de la sécurité"
L["RAID_BOSS_LOU_8"] = "Roi du chrome Gallywix"
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_NP_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_RS_1"] = ""--]] 
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
L["RAID_BOSS_SOD_1"] = "Le Naphtrémens"
L["RAID_BOSS_SOD_10"] = "Sylvanas Coursevent"
L["RAID_BOSS_SOD_2"] = "L’œil du Geôlier"
L["RAID_BOSS_SOD_3"] = "Les Neuf"
L["RAID_BOSS_SOD_4"] = "Vestige de Ner’zhul"
L["RAID_BOSS_SOD_5"] = "Étripeur d’âme Dormazain"
L["RAID_BOSS_SOD_6"] = "Mal-ferrant Raznal"
L["RAID_BOSS_SOD_7"] = "Gardien des Fondateurs"
L["RAID_BOSS_SOD_8"] = "Scribe du destin Roh-Kalo"
L["RAID_BOSS_SOD_9"] = "Kel’Thuzad"
L["RAID_BOSS_TOTFW_1"] = "Conclave du Vent"
L["RAID_BOSS_TOTFW_2"] = "Al’Akir"
L["RAID_BOSS_VOTI_1"] = "Eranog"
L["RAID_BOSS_VOTI_2"] = "Terros"
L["RAID_BOSS_VOTI_3"] = "Le Conseil primordial"
L["RAID_BOSS_VOTI_4"] = "Sennarth, la Glaciale"
L["RAID_BOSS_VOTI_5"] = "Dathéa, transcendée"
L["RAID_BOSS_VOTI_6"] = "Kurog Totem-Sinistre"
L["RAID_BOSS_VOTI_7"] = "Garde-couvée Diurna"
L["RAID_BOSS_VOTI_8"] = "Raszageth la Mange-tempêtes"
L["RAID_BOT"] = "Le bastion du Crépuscule"
L["RAID_BRD"] = "Profondeurs de Rochenoire"
L["RAID_BWD"] = "Descente de l’Aile noire"
L["RAID_DIFFICULTY_NAME_HEROIC"] = "Héroïque"
L["RAID_DIFFICULTY_NAME_HEROIC10"] = "Héroïque 10"
L["RAID_DIFFICULTY_NAME_HEROIC25"] = "Héroïque 25"
L["RAID_DIFFICULTY_NAME_MYTHIC"] = "Mythique"
L["RAID_DIFFICULTY_NAME_NORMAL"] = "Normal"
L["RAID_DIFFICULTY_NAME_NORMAL10"] = "Normal 10"
L["RAID_DIFFICULTY_NAME_NORMAL25"] = "Normal 25"
L["RAID_DIFFICULTY_SUFFIX_HEROIC"] = "H"
L["RAID_DIFFICULTY_SUFFIX_HEROIC10"] = "H10"
L["RAID_DIFFICULTY_SUFFIX_HEROIC25"] = "H25"
L["RAID_DIFFICULTY_SUFFIX_MYTHIC"] = "M"
L["RAID_DIFFICULTY_SUFFIX_NORMAL"] = "N"
L["RAID_DIFFICULTY_SUFFIX_NORMAL10"] = "N10"
L["RAID_DIFFICULTY_SUFFIX_NORMAL25"] = "N25"
L["RAID_DS"] = "L’Âme des dragons"
L["RAID_ENCOUNTERS_DEFEATED_TITLE"] = "Rencontres de Raid vaincues"
L["RAID_FL"] = "Terres de Feu"
L["RAID_ICC"] = "Citadelle de la Couronne de glace"
L["RAID_LOU"] = "Libération de Terremine"
L["RAID_NP"] = "Palais des Nérub’ar"
L["RAID_RS"] = "Le sanctum Rubis"
L["RAID_TOTFW"] = "Trône des quatre vents"
L["RAIDERIO_AVERAGE_PLAYER_SCORE"] = "Moy. de score Raider.IO sur des +%s"
L["RAIDERIO_BEST_RUN"] = "Meilleur donjon M+ Raider.IO"
L["RAIDERIO_CLIENT_CUSTOMIZATION"] = "Personnalisation du client Raider.IO"
L["RAIDERIO_LIVE_TRACKING"] = "Suivi en direct de Raider.IO"
L["RAIDERIO_MP_BASE_SCORE"] = "Score MM+ Raider.IO de base "
L["RAIDERIO_MP_BEST_SCORE"] = "Score M+ Raider.IO (%s)"
L["RAIDERIO_MP_SCORE"] = "Score Raider.IO M+"
L["RAIDERIO_MYTHIC_OPTIONS"] = "Options de l'addon Raider.IO"
L["RAIDING_DATA_HEADER"] = "Progression de Raid Raider.IO"
L["RAIDING_DB_MODULES"] = "Modules de base de données de raid"
L["RECENT_RUNS_WITH_YOU"] = "Mes clés récentes"
L["RECRUITMENT_DB_MODULES"] = "Modules de base de données de recrutement"
L["RELOAD_LATER"] = "Je rechargerai l'interface plus tard"
L["RELOAD_NOW"] = "Recharger l'interface maintenant"
L["RELOAD_RWF_MODE_BUTTON"] = "Sauvegarder"
L["RELOAD_RWF_MODE_BUTTON_TOOLTIP"] = "Cliquez pour enregistrer le journal dans un fichier de stockage. Cela entraînera le rechargement de votre interface."
L["REPLAY_AUTO_SELECTION"] = "Type de rediffusion préféré"
L["REPLAY_AUTO_SELECTION_DESC"] = "Choisissez le type de rediffusion que vous souhaitez sélectionner automatiquement."
L["REPLAY_AUTO_SELECTION_GUILD_BEST"] = "Meilleur guilde"
L["REPLAY_AUTO_SELECTION_MOST_RECENT"] = "Plus récent"
L["REPLAY_AUTO_SELECTION_PERSONAL_BEST"] = "Record personnel"
L["REPLAY_AUTO_SELECTION_STARRED"] = "Favoris"
L["REPLAY_AUTO_SELECTION_TEAM_BEST"] = "Meilleur équipe"
L["REPLAY_BACKGROUND_COLOR"] = "Couleur d’arrière-plan de la rediffusion"
L["REPLAY_BACKGROUND_COLOR_DESC"] = "Spécifiez la couleur d'arrière-plan utilisée dans la fenêtre de rediffusion."
L["REPLAY_DISABLE_CONFIRM"] = "Si vous désactivez le |cffFFBD0Asystème de rediffusion Mythique+|r, vous pouvez le réactiver dans le panneau Paramètres sous la catégorie |cffFFBD0APersonnalisation du client Raider.IO|r."
L["REPLAY_FRAME_ALPHA"] = "Opacité du cadre de rediffusion"
L["REPLAY_FRAME_ALPHA_DESC"] = "Spécifiez l'opacité du cadre de rediffusion."
L["REPLAY_MENU_COPY_URL"] = "Copier l'URL de rediffusion"
L["REPLAY_MENU_DISABLE"] = "Désactiver"
--[[Translation missing --]]
--[[ L["REPLAY_MENU_DOCK"] = ""--]] 
L["REPLAY_MENU_LOCK"] = "Verrouiller"
L["REPLAY_MENU_POSITION"] = "Position"
L["REPLAY_MENU_REPLAY"] = "Rejouer"
L["REPLAY_MENU_STYLE"] = "Style"
L["REPLAY_MENU_TIMING"] = "Durée"
--[[Translation missing --]]
--[[ L["REPLAY_MENU_UNDOCK"] = ""--]] 
L["REPLAY_MENU_UNLOCK"] = "Déverrouiller"
L["REPLAY_REPLAY_CHANGING"] = "Changer votre rediffusion réinitialisera les données en direct."
L["REPLAY_SETTINGS_TOOLTIP"] = "Paramètres"
L["REPLAY_STYLE_TITLE_MDI"] = "MDI"
L["REPLAY_STYLE_TITLE_MODERN"] = "Standard"
L["REPLAY_STYLE_TITLE_MODERN_COMPACT"] = "Compact"
L["REPLAY_STYLE_TITLE_MODERN_SPLITS"] = "Uniquement les boss"
L["REPLAY_SUMMARY_LOGGED"] = "|cffFFFFFF%s|r a enregistré votre achèvement de ce |cffFFFFFF+%s|r dans |cffFFFFFF%s|r."
L["REPLAY_TIMING_TITLE_BOSS"] = "Durée du boss"
L["REPLAY_TIMING_TITLE_DUNGEON"] = "Durée du donjon"
L["RESET_BUTTON"] = "Réinitialiser"
L["RESET_CONFIRM_BUTTON"] = "Réinitialiser et recharger"
L["RESET_CONFIRM_TEXT"] = "Êtes-vous sûr de vouloir réinitialiser Raider.IO aux paramètres par défaut ?"
L["RWF_MINIBUTTON_TOOLTIP"] = "Clic gauche à chaque fois qu’il y a du butin en attente. Cela entraînera le rechargement de votre interface. Clic droit pour ouvrir le cadre « Course au World First »."
L["RWF_SUBTITLE_LOGGING_FILTERED_LOOT"] = "(enregistrement des éléments pertinents)"
L["RWF_SUBTITLE_LOGGING_LOOT"] = "(enregistrement du butin)"
L["RWF_TITLE"] = "|cffFFFFFFRaider.IO|r « Course au World First »"
L["SEARCH_NAME_LABEL"] = "Pseudo"
L["SEARCH_REALM_LABEL"] = "Serveur"
L["SEARCH_REGION_LABEL"] = "Region"
L["SEASON_LABEL_1"] = "S1"
L["SEASON_LABEL_2"] = "S2"
L["SEASON_LABEL_3"] = "S3"
L["SEASON_LABEL_4"] = "S4"
L["SHOW_AVERAGE_PLAYER_SCORE_INFO"] = "Afficher le score moyen des joueurs pour une clé dans les temps"
L["SHOW_AVERAGE_PLAYER_SCORE_INFO_DESC"] = "Afficher la moyenne des scores Raider.IO des joueurs ayant fini une clé dans les temps. Cela est visible sur l'infobulle de la clé ainsi que des joueurs dans la recherche de groupe."
L["SHOW_BEST_MAINS_SCORE"] = "Afficher le score Mythique+ de la meilleure saison du personnage principal"
L["SHOW_BEST_MAINS_SCORE_DESC"] = "Affiche le score Mythique+ de la meilleure saison du personnage principal d'un joueur et la progression du raid dans l'info-bulle. Les joueurs doivent s'être inscrits sur Raider.IO et avoir déclaré un personnage comme personnage principal."
L["SHOW_BEST_RUN"] = "Afficher la meilleure clé Mythique+ dans le titre"
L["SHOW_BEST_RUN_DESC"] = "Affiche la meilleure clé Mythique+ du joueur de la saison en cours sous forme de titre de l'info-bulle."
L["SHOW_BEST_SEASON"] = "Afficher le meilleur score Mythique+ de la saison dans le titre"
L["SHOW_BEST_SEASON_DESC"] = "Affiche le meilleur score de la saison Mythique+ du joueur sous forme de titre dans l'info-bulle. Si le score provient d'une saison précédente, la saison sera indiquée dans le titre de l'info-bulle."
L["SHOW_CHESTS_AS_MEDALS"] = "Afficher les icônes de médaille Mythique+"
L["SHOW_CHESTS_AS_MEDALS_DESC"] = "Affiche les clés réussies sous forme d'icônes au lieu des signes plus (+)."
L["SHOW_CLIENT_GUILD_BEST"] = "Afficher les meilleurs records dans l'outil de Recherche de groupe pour les donjons mythiques"
L["SHOW_CLIENT_GUILD_BEST_DESC"] = "L'activation de cette option affichera les 5 meilleures session de votre guilde (saison ou semaine) dans l'onglet des donjons mythiques de la fenêtre de Recherche de groupe."
L["SHOW_CURRENT_SEASON"] = "Afficher le score Mythique+ de la saison actuelle dans le titre"
L["SHOW_CURRENT_SEASON_DESC"] = "Affiche le score actuel du joueur de la saison Mythique+ sous forme de titre de l'info-bulle."
L["SHOW_IN_FRIENDS"] = "Afficher dans la liste d'amis"
L["SHOW_IN_FRIENDS_DESC"] = "Afficher le score Mythique+ lorsqu'on survole un ami."
L["SHOW_IN_LFD"] = "Afficher dans la recherche de donjons"
L["SHOW_IN_LFD_CLASSIC"] = "Afficher dans les info-bulles de l'outil de Recherche de groupe"
L["SHOW_IN_LFD_DESC"] = "Afficher le score Mythique+ lorsqu'on survole un groupe ou un candidat."
L["SHOW_IN_SLASH_WHO_RESULTS"] = "Afficher les résultats de la commande « /who »"
L["SHOW_IN_SLASH_WHO_RESULTS_DESC"] = "Affichez le score Mythique+ lorsque vous tapez « /who » d'un joueur un en particulier."
L["SHOW_IN_WHO_UI"] = "Afficher dans la fenêtre \"Qui\""
L["SHOW_IN_WHO_UI_DESC"] = "Affichez la progression lorsque vous passez la souris dans la boîte de dialogue de la fenêtre « Qui »."
L["SHOW_KEYSTONE_INFO"] = "Affiche les informations de la clé"
L["SHOW_KEYSTONE_INFO_DESC"] = "Ajoute des informations sur l'info-bulle de la clé. Propose un score Mythique+ pour le groupe."
L["SHOW_LEADER_PROFILE"] = "Autoriser le modificateur d'info-bulle du profil Raider.IO"
L["SHOW_LEADER_PROFILE_DESC"] = "Maintenez enfoncé un modificateur (maj / ctrl / alt) pour basculer l'info-bulle de profil entre le profil personnel / leader."
L["SHOW_MAINS_SCORE"] = "Afficher le score du personnage principal"
L["SHOW_MAINS_SCORE_DESC"] = "Afficher le score du personnage principal du joueur pour la saison actuelle. Ces joueurs doivent avoir un compte sur Raider.IO où il a définit un personnage comme son personnage principal."
L["SHOW_ON_GUILD_ROSTER"] = "Afficher dans l'onglet guilde"
L["SHOW_ON_GUILD_ROSTER_DESC"] = "Afficher le score Mythique+ lorsqu'on survole un joueur dans la liste des membres de la guilde."
L["SHOW_ON_PLAYER_UNITS"] = "Afficher sur les cadres d'unité"
L["SHOW_ON_PLAYER_UNITS_DESC"] = "Afficher le score Mythique+ lorsqu'on survole le cadre d'un joueur. "
L["SHOW_RAID_ENCOUNTERS_IN_PROFILE"] = "Afficher les rencontres de raid dans l'info-bulle du joueur"
L["SHOW_RAID_ENCOUNTERS_IN_PROFILE_DESC"] = "Une fois défini, cela affichera la progression de raid dans les info-bulles du profil Raider.IO."
L["SHOW_RAIDERIO_BESTRUN_FIRST"] = "(Expérimental) Prioriser l'affichage de la meilleure clé de Raider.IO"
L["SHOW_RAIDERIO_BESTRUN_FIRST_DESC"] = "Il s'agit d'une fonctionnalité expérimentale. Au lieu d'afficher le score Raider.IO comme première ligne, affichez la meilleure clé du joueur."
L["SHOW_RAIDERIO_PROFILE"] = "Afficher le Profil Raider.IO dans la recherche de donjon"
L["SHOW_RAIDERIO_PROFILE_DESC"] = "Afficher le Profil Raider.IO en Info-Bulle dans la recherche de donjon"
L["SHOW_RAIDERIO_PROFILE_OPTION"] = "Afficher le profil Raider.IO"
L["SHOW_ROLE_ICONS"] = "Afficher les icônes de rôle dans les info-bulles"
L["SHOW_ROLE_ICONS_DESC"] = "Une fois activée, cette option affichera les meilleurs rôles Mythique+ du joueur dans les infos-bulles."
L["SHOW_SCORE_IN_COMBAT"] = "Afficher le score en combat"
L["SHOW_SCORE_IN_COMBAT_DESC"] = "Désactivez-le pour minimiser l'impact sur les performances lorsque vous survolez les joueurs pendant le combat."
L["SHOW_SCORE_WITH_MODIFIER"] = "Afficher les informations de l'info-bulle de Raider.IO avec un modificateur"
L["SHOW_SCORE_WITH_MODIFIER_DESC"] = "Désactivez l'affichage des données lors du survol des joueurs, sauf si une touche de modification est maintenue enfoncée."
L["SHOW_WARBAND_SCORE"] = "Afficher le score et la progression M+ de votre Bataillon dans les info-bulles"
L["SHOW_WARBAND_SCORE_DESC"] = "Affiche le score Mythique+ de votre Bataillon pour la saison en cours ainsi que la progression du raid dans l'info-bulle. Les joueurs doivent s'être inscrits sur Raider.IO et avoir synchronisé leur compte Battle.net pour que la progression de Bataillon fonctionne."
L["TANK"] = "Tank"
L["TEAM_LF_MPLUS_DEFAULT"] = "Recrutement de joueurs Mythique+"
L["TEAM_LF_MPLUS_WITH_SCORE"] = "Recrutement de %d joueurs Mythique+"
L["TIMED_10_RUNS"] = "10-14+ dans les temps"
L["TIMED_15_RUNS"] = "15+ dans les temps"
L["TIMED_20_RUNS"] = "20+ dans les temps"
L["TIMED_5_RUNS"] = "5-9+ dans les temps"
L["TIMED_RUNS_MINIMUM"] = "%d+ dans les temps"
L["TIMED_RUNS_RANGE"] = "+%d-%d dans les temps"
L["TOOLTIP_PROFILE"] = "Personnalisation de l'info-bulle du profil Raider.IO"
L["UNKNOWN_SERVER_FOUND"] = "|cffFFFFFF%s|r a rencontré un nouveau serveur. Veuillez noter ces informations |cffFF9999{|r |cffFFFFFF%s|r |cffFF9999,|r |cffFFFFFF%s|r |cffFF9999}|r et les signaler aux développeurs. Merci!"
L["UNLOCKING_PROFILE_FRAME"] = "Raider.IO : Déverrouillage du cadre de profil M+."
L["USE_ENGLISH_ABBREVIATION"] = "Forcer les abréviations anglaises pour les donjons"
L["USE_ENGLISH_ABBREVIATION_DESC"] = "Une fois défini, cela remplacera les abréviations utilisées pour les instances par les versions anglaises, plutôt que par votre langue actuelle."
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS"] = "Autoriser le client Raider.IO à contrôler le Journal de combat"
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS_DESC"] = "Autorisez le client Raider.IO (le cas échéant) à contrôler automatiquement vos paramètres du Journal de combat."
L["WARBAND_BEST_SCORE_BEST_SEASON"] = "Meilleur score M+ de votre Bataillon (%s)"
L["WARBAND_SCORE"] = "Score M+ de votre Bataillon"
L["WARNING_DEBUG_MODE_ENABLE"] = "|cffFFFFFF%s|r Le mode débogage est activé. Vous pouvez le désactiver en tapant |cffFFFFFF/raiderio debug|r."
L["WARNING_LOCK_POSITION_FRAME_AUTO"] = "Raider.IO : vous devez d'abord désactiver le positionnement automatique pour le profil Raider.IO."
L["WARNING_RWF_MODE_ENABLE"] = "|cffFFFFFF%s|r Le mode « Course au World First » est activé. Vous pouvez le désactiver en tapant |cffFFFFFF/raiderio rwf|r."
L["WIPE_RWF_MODE_BUTTON"] = "Wipe"
L["WIPE_RWF_MODE_BUTTON_TOOLTIP"] = "Cliquez pour effacer le journal du fichier de stockage. Cela entraînera le rechargement de votre interface."

end
