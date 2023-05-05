-- Generated from CurseForge on Thu May  4 19:43:22 UTC 2023
local ns = select(2, ...) ---@type ns @The addon namespace.

if ns:IsSameLocale("esES") then
	local L = ns.L or ns:NewLocale()

	L.LOCALE_NAME = "esES"

L["ALLOW_IN_LFD"] = "Permitir en buscador de mazmorras"
L["ALLOW_IN_LFD_DESC"] = "Click derecho en los grupos o aplicantes en el buscador de mazmorras para copiar la URL de su perfil de Raider.IO"
L["ALLOW_ON_PLAYER_UNITS"] = "Permitir en marcos de jugador"
L["ALLOW_ON_PLAYER_UNITS_DESC"] = [=[Click derecho en el marco de un jugador para copiar la URL de su perfil de Raider.IO
]=]
L["API_DEPRECATED"] = "|cffFF0000¡Atención!|r El addon |cffFFFFFF%s|r está usando una función RaiderIO obsoleta.%s. Esta función será eliminada en futuras versiones. Por favor, anima al autor de %s a actualizar su addon. Pila de llamadas: %s"
L["API_DEPRECATED_UNKNOWN_ADDON"] = [=[<AddOn desconocido>
]=]
L["API_DEPRECATED_UNKNOWN_FILE"] = [=[<Archivo de AddOn desconocido>
]=]
L["API_DEPRECATED_WITH"] = [=[|cffFF0000Warning!|r El addon |cffFFFFFF%s|r está llamando a una función obsoleta RaiderIO.%s. Esta función se eliminará en futuras versiones. Anime al autor de% s a actualizar a la nueva API RaiderIO.%s en su lugar. Pila de llamadas: %s
]=]
L["API_INVALID_DATABASE"] = [=[|cffFF0000Warning!|r Se detectó una base de datos Raider.IO no válida en |cffffffff%s|r. Actualice todas las regiones y facciones en el cliente Raider.IO, o reinstale el addon manualmente.
]=]
L["AUTO_COMBATLOG"] = "Habilitar automáticamente el registro de combate en Bandas y Mazmorras"
L["AUTO_COMBATLOG_DESC"] = "Activa o desactiva el registro de combate automáticamente al entrar y salir de las mazmorras y bandas admitidas."
L["BEST_FOR_DUNGEON"] = "Mejor en esta mazmorra"
L["BEST_RUN"] = "Mejor mazmorra"
L["BEST_SCORE"] = "Mejor puntuacion M + (% s)"
L["CANCEL"] = "Cancelar"
L["CHANGES_REQUIRES_UI_RELOAD"] = "Los cambios se han guardado, pero debes recargar la interfaz para que surtan efecto. ¿Quieres recargar ahora?"
L["CHARACTER_LF_GUILD_MPLUS"] = "Buscando Guild Mythic+"
L["CHARACTER_LF_GUILD_MPLUS_WITH_SCORE"] = "Buscando Guild Mythic+"
L["CHARACTER_LF_GUILD_PVP"] = "Buscando Guild PVP"
L["CHARACTER_LF_GUILD_RAID_DEFAULT"] = "Buscando Guild Raid"
L["CHARACTER_LF_GUILD_RAID_HEROIC"] = "Buscando Guild Raid HC"
L["CHARACTER_LF_GUILD_RAID_MYTHIC"] = "Buscando Guild Raid Mítico"
L["CHARACTER_LF_GUILD_RAID_NORMAL"] = "Buscando Guild Raid Normal"
L["CHARACTER_LF_GUILD_SOCIAL"] = "Buscando Guild Social"
L["CHARACTER_LF_TEAM_MPLUS_DEFAULT"] = "Buscando Equipo Mythic+"
L["CHARACTER_LF_TEAM_MPLUS_WITH_SCORE"] = "Buscando %d+ Equipo Mythic+"
L["CHECKBOX_DISPLAY_WEEKLY"] = [=[Mostrar semanal
]=]
L["CHOOSE_HEADLINE_HEADER"] = "Título del tooltip de míticas+"
L["CONFIG_WHERE_TO_SHOW_TOOLTIPS"] = "Dónde mostrar el progreso de míticas+ y bandas"
L["CONFIRM"] = "Confirmar"
L["COPY_RAIDERIO_PROFILE_URL"] = "Copiar URL de Raider.IO"
L["COPY_RAIDERIO_RECRUITMENT_URL"] = "Copiar URL de Recutramiento"
L["COPY_RAIDERIO_URL"] = "Copiar la URL de Raider.IO"
L["CURRENT_MAINS_SCORE"] = "Puntuación actual de M+ del Main"
L["CURRENT_SCORE"] = [=[Actual puntuación M+
]=]
--[[Translation missing --]]
--[[ L["DB_MODULES"] = ""--]] 
--[[Translation missing --]]
--[[ L["DB_MODULES_HEADER_MYTHIC_PLUS"] = ""--]] 
--[[Translation missing --]]
--[[ L["DB_MODULES_HEADER_RAIDING"] = ""--]] 
--[[Translation missing --]]
--[[ L["DB_MODULES_HEADER_RECRUITMENT"] = ""--]] 
L["DISABLE_DEBUG_MODE_RELOAD"] = "Estás desactivando el modo Debug. Al hacer clic en Confirmar se cargará de nuevo su interfaz."
L["DISABLE_RWF_MODE_BUTTON"] = "Desactivar"
L["DISABLE_RWF_MODE_BUTTON_TOOLTIP"] = "Haz clic para desactivar el modo Race World First. Esto hará que su interfaz se vuelva a cargar."
L["DISABLE_RWF_MODE_RELOAD"] = "Estás desactivando el modo Race World First. Al hacer clic en Confirmar, volverá a cargar su interfaz."
L["DPS"] = "DPS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_AA"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_AV"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_COS"] = ""--]] 
L["DUNGEON_SHORT_NAME_DOS"] = "El Otro Lado - DOS"
L["DUNGEON_SHORT_NAME_GD"] = "Terminal Malavía - GD"
L["DUNGEON_SHORT_NAME_GMBT"] = "Tazavesh: Gambito - GMBT"
L["DUNGEON_SHORT_NAME_HOA"] = "Salas de la Expiación - HOA"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_HOV"] = ""--]] 
L["DUNGEON_SHORT_NAME_ID"] = "Puerto de Hierro - ID"
L["DUNGEON_SHORT_NAME_LOWR"] = "Karazhan: Inferior - LOWR"
L["DUNGEON_SHORT_NAME_MISTS"] = "Nieblas de Tirna Scithe - MISTS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_NO"] = ""--]] 
L["DUNGEON_SHORT_NAME_NW"] = "Estela Necrótica - NW"
L["DUNGEON_SHORT_NAME_PF"] = "Bajapeste - PF"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_RLP"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_SBG"] = ""--]] 
L["DUNGEON_SHORT_NAME_SD"] = "Cavernas Sanguinas - SD"
L["DUNGEON_SHORT_NAME_SOA"] = "Agujas de Ascensión - SOA"
L["DUNGEON_SHORT_NAME_STRT"] = "Tazavesh: Calles - STRT"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_TJS"] = ""--]] 
L["DUNGEON_SHORT_NAME_TOP"] = "Teatro del Dolor - TOP"
L["DUNGEON_SHORT_NAME_UPPR"] = "Karazhan: Superior - UPPR"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_VOTW"] = ""--]] 
L["DUNGEON_SHORT_NAME_WORK"] = "Mechagon: Taller - WORK"
L["DUNGEON_SHORT_NAME_YARD"] = "Mechagon: Desguace - YARD"
L["ENABLE_AUTO_FRAME_POSITION"] = "Posicionar automáticamente el marco de perfil de RaiderIO"
L["ENABLE_AUTO_FRAME_POSITION_DESC"] = "Fija la ventana emergente de perfil de M+ junto al marco del buscador de grupos o la ventana emergente de jugador."
L["ENABLE_DEBUG_MODE_RELOAD"] = "Estás activando el modo depuración. Esto es solo para fines de pruebas y desarrollo, y puede incurrir en un aumento del uso de memoria. Haz clic en confirmar para recargar la interfaz."
L["ENABLE_LOCK_PROFILE_FRAME"] = "Bloquear el marco de perfil de RaiderIO"
L["ENABLE_LOCK_PROFILE_FRAME_DESC"] = "Evita que se pueda desplazar el marco de perfil de M+. No tiene efecto si el marco de perfil de M+ está configurado para posicionarse automáticamente."
L["ENABLE_NO_SCORE_COLORS"] = "Desactivar colores de puntuación"
L["ENABLE_NO_SCORE_COLORS_DESC"] = "Desactiva los colores de las puntuaciones. Todas las puntuaciones se mostrarán de color blanco."
L["ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS"] = "Habilitar mejoras del cliente de RaiderIO"
L["ENABLE_RAIDERIO_CLIENT_ENHANCEMENTS_DESC"] = "Permite ver información detallada del cliente de RaiderIO de tus personajes confirmados."
L["ENABLE_RWF_MODE_BUTTON"] = "Habilitar"
L["ENABLE_RWF_MODE_BUTTON_TOOLTIP"] = "Haz clic para habilitar el modo Race World First. Esto hará que su interfaz se vuelva a cargar."
--[[Translation missing --]]
--[[ L["ENABLE_RWF_MODE_RELOAD"] = ""--]] 
L["ENABLE_SIMPLE_SCORE_COLORS"] = "Usar colores de puntuación simples"
L["ENABLE_SIMPLE_SCORE_COLORS_DESC"] = "Muestra las puntuaciones usando solo los colores estándar de calidad de objeto. Facilita la distinción de puntuaciones para personas con defectos de visión cromática."
L["EXPORTJSON_COPY_TEXT"] = "Copia este texto y pégalo en |cff00C8FFhttps://raider.io|r para ver información de todos los jugadores."
L["GENERAL_TOOLTIP_OPTIONS"] = "Opciones generales del tooltip"
L["GUILD_BEST_SEASON"] = "Hermandad: mejor de la temporada"
L["GUILD_BEST_TITLE"] = "Récords de hermandad"
L["GUILD_BEST_WEEKLY"] = "Mejores de la semana"
L["GUILD_LF_MPLUS_DEFAULT"] = "Reclutamiento de jugadoras míticas+"
L["GUILD_LF_MPLUS_WITH_SCORE"] = "Reclutamiento %d+ jugadoras míticas+"
L["GUILD_LF_PVP"] = "Reclutar jugadores PvP"
L["GUILD_LF_RAID_DEFAULT"] = "Reclutar Raiders"
L["GUILD_LF_RAID_HEROIC"] = "Reclutar Raiders HC"
L["GUILD_LF_RAID_MYTHIC"] = "Reclutar Raiders Mítico"
L["GUILD_LF_RAID_NORMAL"] = "Reclutar Raiders Normal"
L["GUILD_LF_SOCIAL"] = "Reclutar jugadores Sociales"
L["HEALER"] = "Sanador"
L["HIDE_OWN_PROFILE"] = "Ocultar ventana emergente de perfil personal de RaiderIO"
L["HIDE_OWN_PROFILE_DESC"] = "Oculta la ventana emergente de tu perfil personal de RaiderIO. No afecta a las ventanas emergentes de otros jugadores."
L["INVERSE_PROFILE_MODIFIER"] = "Invertir modificador de marco de perfil"
L["INVERSE_PROFILE_MODIFIER_DESC"] = "Invierte el comportamiento del modificador del marco de perfil (mayús/ctrl/alt) para que muestre por defecto el perfil del líder del grupo."
L["LOCKING_PROFILE_FRAME"] = "RaiderIO: bloqueando el marco de perfil de M+."
L["MAINS_BEST_SCORE_BEST_SEASON"] = "Mejor puntuación en M+ con el main (%s)"
L["MAINS_RAID_PROGRESS"] = "Progreso de personaje principal"
L["MAINS_SCORE"] = "Puntuación de personaje principal"
L["MODULE_AMERICAS"] = "América"
L["MODULE_EUROPE"] = "Europa"
L["MODULE_KOREA"] = "Corea"
L["MODULE_TAIWAN"] = "Taiwan"
L["MY_PROFILE_TITLE"] = "Perfil personal de M+"
L["MYTHIC_PLUS_DB_MODULES"] = "Mythic+ Database Modulos"
L["MYTHIC_PLUS_SCORES"] = "Puntuaciones de M+"
L["NO_GUILD_RECORD"] = "No hay récords de hermandad"
L["OPEN_CONFIG"] = "Abrir configuración"
L["OUT_OF_SYNC_DATABASE_S"] = "|cffFFFFFF%s|r tiene datos de facción sin sincronizar. Por favor, actualiza tu configuración del cliente de RaiderIO para sincronizar ambas facciones."
L["OUTDATED_DATABASE"] = "Estas puntuaciones son de hace %d día(s)"
L["OUTDATED_DATABASE_HOURS"] = "Estas puntuaciones son de hace %d hora(s)"
L["OUTDATED_DOWNLOAD_LINK"] = "Descargar: |cffffbd0a%s|r"
L["OUTDATED_EXPIRED_ALERT"] = "|cffFFFFFF%s|r está utilizando datos caducados. Actualice ahora para ver los datos más precisos: |cffFFFFFF%s|r"
L["OUTDATED_EXPIRED_TITLE"] = "Raider.IO Los datos han expirado"
L["OUTDATED_EXPIRES_IN_DAYS"] = "Raider.IO Los Datos caducan en %d días"
L["OUTDATED_EXPIRES_IN_HOURS"] = "Raider.IO Los Datos caducan en %d horas"
L["OUTDATED_EXPIRES_IN_MINUTES"] = "Raider.IO Los Datos caducan en %d minutos"
L["OUTDATED_PROFILE_TOOLTIP_MESSAGE"] = "Actualice su complemento ahora para ver los datos más precisos. Los jugadores trabajan duro para mejorar su progreso y mostrar datos muy antiguos es un flaco favor para ellos. Puede utilizar Raider.IO Client para mantener sus datos sincronizados automáticamente."
L["PREVIOUS_SCORE"] = "Puntuación M+ anterior (%s)"
L["PROFILE_BEST_RUNS"] = "Mejor de cada mazmorra"
--[[Translation missing --]]
--[[ L["PROFILE_TOOLTIP_ANCHOR_TOOLTIP"] = ""--]] 
L["PROVIDER_NOT_LOADED"] = "|cffFF0000Advertencia:|r |cffFFFFFF%s|r no puede encontrar datos para tu facción actual. Compruebe la configuración de |cffFFFFFF/raiderio|r y habilite los datos de información sobre herramientas para |cffFFFFFF%s|r."
L["RAID_BOSS_CN_1"] = "Alachilla"
L["RAID_BOSS_CN_10"] = "Sire Denathrius"
L["RAID_BOSS_CN_2"] = "Altimor el Cazador"
L["RAID_BOSS_CN_3"] = "Destructor hambriento"
L["RAID_BOSS_CN_4"] = "Artificiero Xy'Mox"
L["RAID_BOSS_CN_5"] = "Salvación del Rey del Sol"
L["RAID_BOSS_CN_6"] = "Lady Inerva Venaoscura"
L["RAID_BOSS_CN_7"] = "El Consejo de Sangre"
L["RAID_BOSS_CN_8"] = "Puñolodo"
L["RAID_BOSS_CN_9"] = "Generales de la Legión Pétrea"
L["RAID_BOSS_FCN_1"] = "Alachilla"
L["RAID_BOSS_FCN_10"] = "Sire Denathrius"
L["RAID_BOSS_FCN_2"] = "Altimor el Cazador"
L["RAID_BOSS_FCN_3"] = "Destructor Hambriento"
L["RAID_BOSS_FCN_4"] = "Artificiero Xy'Mox"
L["RAID_BOSS_FCN_5"] = "Salvación del Rey del Sol"
L["RAID_BOSS_FCN_6"] = "Lady Inerva Venaoscura"
L["RAID_BOSS_FCN_7"] = "El Consejo de Sangre"
L["RAID_BOSS_FCN_8"] = "Puñolodo"
L["RAID_BOSS_FCN_9"] = "Generales de la Legión Pétrea"
L["RAID_BOSS_FSFO_1"] = "Guardián Vigilante"
L["RAID_BOSS_FSFO_10"] = "Rygelon"
L["RAID_BOSS_FSFO_11"] = "El Carcelero"
L["RAID_BOSS_FSFO_2"] = "Skolex"
L["RAID_BOSS_FSFO_3"] = "Artificiero Xy'Mox"
L["RAID_BOSS_FSFO_4"] = "Dausegne"
L["RAID_BOSS_FSFO_5"] = "Panteón de Prototipos"
L["RAID_BOSS_FSFO_6"] = "Lihuvim"
L["RAID_BOSS_FSFO_7"] = "Halondrus"
L["RAID_BOSS_FSFO_8"] = "Anduin Wrynn"
L["RAID_BOSS_FSFO_9"] = "Señores del Terror"
L["RAID_BOSS_FSOD_1"] = "El Tarragrue"
L["RAID_BOSS_FSOD_10"] = "Sylvanas Brisaveloz"
L["RAID_BOSS_FSOD_2"] = "Mirada del Carcelero"
L["RAID_BOSS_FSOD_3"] = "Las Nueve"
L["RAID_BOSS_FSOD_4"] = "Remanente de Ner'zhul"
L["RAID_BOSS_FSOD_5"] = "Desgarrador de almas Dormazain"
L["RAID_BOSS_FSOD_6"] = "Forjapenas Raznal"
L["RAID_BOSS_FSOD_7"] = "Guardián de los Primeros"
L["RAID_BOSS_FSOD_8"] = "Escriba del destino Roh-Kalo"
L["RAID_BOSS_FSOD_9"] = "Kel'Thuzad"
L["RAID_BOSS_SFO_1"] = "Guardián vigilante"
L["RAID_BOSS_SFO_10"] = "Rygelon"
L["RAID_BOSS_SFO_11"] = "El Carcelero"
L["RAID_BOSS_SFO_2"] = "Skolex"
L["RAID_BOSS_SFO_3"] = "Artificiero Xy'Mox"
L["RAID_BOSS_SFO_4"] = "Dausegne"
L["RAID_BOSS_SFO_5"] = "Panteón de prototipos"
L["RAID_BOSS_SFO_6"] = "Lihuvim"
L["RAID_BOSS_SFO_7"] = "Halondrus"
L["RAID_BOSS_SFO_8"] = "Anduin Wrynn"
L["RAID_BOSS_SFO_9"] = "Señores del Terror"
L["RAID_BOSS_SOD_1"] = "El Tarragrue"
L["RAID_BOSS_SOD_10"] = "Sylvanas Brisaveloz"
L["RAID_BOSS_SOD_2"] = "Mirada del Carcelero"
L["RAID_BOSS_SOD_3"] = "Las Nueve"
L["RAID_BOSS_SOD_4"] = "Remanente de Ner'zhul"
L["RAID_BOSS_SOD_5"] = "Desgarrador de almas Dormazain"
L["RAID_BOSS_SOD_6"] = "Forjapenas Raznal"
L["RAID_BOSS_SOD_7"] = "Guardián de los Primeros"
L["RAID_BOSS_SOD_8"] = "Escriba del destino Roh-Kalo"
L["RAID_BOSS_SOD_9"] = "Kel'Thuzad"
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
L["RAID_DIFFICULTY_NAME_HEROIC"] = "Heroico"
L["RAID_DIFFICULTY_NAME_MYTHIC"] = "Mítico"
L["RAID_DIFFICULTY_NAME_NORMAL"] = "Normal"
L["RAID_DIFFICULTY_SUFFIX_HEROIC"] = "H"
L["RAID_DIFFICULTY_SUFFIX_MYTHIC"] = "M"
L["RAID_DIFFICULTY_SUFFIX_NORMAL"] = "N"
L["RAID_ENCOUNTERS_DEFEATED_TITLE"] = "Encuentros de banda derrotados"
L["RAIDERIO_AVERAGE_PLAYER_SCORE"] = "Puntuación media de +%s en tiempo"
L["RAIDERIO_BEST_RUN"] = "Raider.IO Mejor resultado en M+"
L["RAIDERIO_CLIENT_CUSTOMIZATION"] = "Personalización del cliente de RaiderIO"
L["RAIDERIO_LIVE_TRACKING"] = "Raider.IO seguimiento en vivo"
L["RAIDERIO_MP_BASE_SCORE"] = "Puntuación de M+ base"
L["RAIDERIO_MP_BEST_SCORE"] = "Raider.IO Puntuación M+ (%s)"
L["RAIDERIO_MP_SCORE"] = "Puntuación de M+"
L["RAIDERIO_MYTHIC_OPTIONS"] = "Opciones de Raider.IO Mythic Plus"
L["RAIDING_DATA_HEADER"] = "Progreso de banda de Raider.IO"
L["RAIDING_DB_MODULES"] = "Raiding Database Modulos"
--[[Translation missing --]]
--[[ L["RECRUITMENT_DB_MODULES"] = ""--]] 
L["RELOAD_LATER"] = "La reiniciaré más tarde"
L["RELOAD_NOW"] = "Reiniciarla ahora"
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
L["SEARCH_NAME_LABEL"] = "Nombre"
L["SEARCH_REALM_LABEL"] = "Reino"
L["SEARCH_REGION_LABEL"] = "Región"
L["SEASON_LABEL_1"] = "T1"
L["SEASON_LABEL_2"] = "T2"
L["SEASON_LABEL_3"] = "T3"
L["SEASON_LABEL_4"] = "T4"
L["SHOW_AVERAGE_PLAYER_SCORE_INFO"] = "Mostrar puntuación media de M+ en tiempo"
L["SHOW_AVERAGE_PLAYER_SCORE_INFO_DESC"] = "Muestra la puntuación media de M+ en tiempo de los miembros de un grupo. Aparece en las descripciones emergentes de piedras angulares y jugadores en el buscador de grupos."
L["SHOW_BEST_MAINS_SCORE"] = "Mostrar puntuación de M+ del personaje principal de la mejor temporada"
L["SHOW_BEST_MAINS_SCORE_DESC"] = "Muestra la puntuación conseguida con el personaje principal en la mejor temporada de míticas+ y bandas en el tooltip. Los jugadores deben haberse registrado en Raider.IO y haber declarado un personaje como personaje principal."
L["SHOW_BEST_RUN"] = "Mostrar la mejor mítica+ realizada en el título"
L["SHOW_BEST_RUN_DESC"] = "Muestra la mejor mítica+ realizada por el jugador en la temporada actual como título del tooltip."
L["SHOW_BEST_SEASON"] = "Mostrar la mejor puntuación de la temporada de Míticas+ como título"
L["SHOW_BEST_SEASON_DESC"] = "Muestra la mejor puntuación de la temporada de Míticas+ del jugador como título del tooltip. Si la puntuación es de una temporada anterior, la temporada se indicará en el título del tooltip."
--[[Translation missing --]]
--[[ L["SHOW_CHESTS_AS_MEDALS"] = ""--]] 
--[[Translation missing --]]
--[[ L["SHOW_CHESTS_AS_MEDALS_DESC"] = ""--]] 
L["SHOW_CLIENT_GUILD_BEST"] = "Mostrar mejores puntuaciones de mazmorra en el buscador de grupos"
L["SHOW_CLIENT_GUILD_BEST_DESC"] = "Muestra las cinco mejores puntuaciones de tu hermandad (tanto de temporada como semanales) en la pestaña 'Piedra angular mítica' de la ventana del buscador de grupos."
L["SHOW_CURRENT_SEASON"] = "Mostrar la puntuación actual de la temporada de Míticas+ como título"
L["SHOW_CURRENT_SEASON_DESC"] = "Muestra la puntuación actual de la temporada de Míticas+ del jugador como título del tooltip."
L["SHOW_IN_FRIENDS"] = "Mostrar en la lista de amigos"
L["SHOW_IN_FRIENDS_DESC"] = "Muestra la puntuación de M+ de tus amigos cuando pasas el ratón por encima."
L["SHOW_IN_LFD"] = "Mostrar en el buscador de grupos"
L["SHOW_IN_LFD_DESC"] = "Muestra la puntuación de M+ cuando pasas el ratón por encima de grupos ya creados del buscador o jugadores que soliciten unirse a tu grupo."
L["SHOW_IN_SLASH_WHO_RESULTS"] = "Mostrar en resultados de /who"
L["SHOW_IN_SLASH_WHO_RESULTS_DESC"] = "Muestra la puntuación de M+ cuando usas \"/who\" con un jugador específico."
L["SHOW_IN_WHO_UI"] = "Mostrar en la interfaz de ¿Quién?"
L["SHOW_IN_WHO_UI_DESC"] = "Muestra la puntuación de M+ cuando pasas el ratón por encima de los resultados de la ventana ¿Quién?"
L["SHOW_KEYSTONE_INFO"] = "Mostrar información de piedras angulares"
L["SHOW_KEYSTONE_INFO_DESC"] = "Muestra la puntuación base de cada piedra angular en su descripción emergente. También muestra la mejor M+ de esa mazmorra de cada jugador en tu grupo."
L["SHOW_LEADER_PROFILE"] = "Habilitar modificador del marco de perfil"
L["SHOW_LEADER_PROFILE_DESC"] = "Permite mantener pulsado un modificador (mayús/ctrl/alt) para alternar el marco de perfil entre el personal y el del líder del grupo."
L["SHOW_MAINS_SCORE"] = "Mostrar puntuación de personaje principal"
L["SHOW_MAINS_SCORE_DESC"] = "Muestra la puntuación en la temporada actual del personaje principal del jugador inspeccionado. El jugador en cuestión debe estar registrado en Raider.IO y haber seleccionado su personaje principal."
L["SHOW_ON_GUILD_ROSTER"] = "Mostrar en lista de hermandad"
L["SHOW_ON_GUILD_ROSTER_DESC"] = "Muestra la puntuación de M+ de los miembros de tu hermandad cuando pasas el ratón por encima de ellos en la lista de hermandad."
L["SHOW_ON_PLAYER_UNITS"] = "Mostrar en marcos de jugador"
L["SHOW_ON_PLAYER_UNITS_DESC"] = "Muestra la puntuación de M+ de los jugadores en su ventana emergente cuando pasas el ratón sobre ellos."
L["SHOW_RAID_ENCOUNTERS_IN_PROFILE"] = "Mostrar encuentros de banda en la ventana emergente de perfil"
L["SHOW_RAID_ENCOUNTERS_IN_PROFILE_DESC"] = "Muestra el progreso de banda en la ventana emergente de perfil de RaiderIO."
L["SHOW_RAIDERIO_BESTRUN_FIRST"] = "(Experimental) Priorizar mostrar la mejor carrera de Raider.IO "
L["SHOW_RAIDERIO_BESTRUN_FIRST_DESC"] = "Esta es una característica experimental. En lugar de mostrar la puntuación de Raider.IO como la primera línea, muestra la mejor carrera del jugador."
L["SHOW_RAIDERIO_PROFILE"] = "Mostrar marco de perfil en el buscador de grupos"
L["SHOW_RAIDERIO_PROFILE_DESC"] = "Muestra el marco de perfil de Raider.IO en el buscador de grupos."
L["SHOW_ROLE_ICONS"] = "Mostrar iconos de rol en el tooltip"
L["SHOW_ROLE_ICONS_DESC"] = "Cuando está activado, se muestran los mejores roles del jugador en míticas+ en el tooltip."
L["SHOW_SCORE_IN_COMBAT"] = "Mostrar puntuación en combate"
L["SHOW_SCORE_IN_COMBAT_DESC"] = "Desactiva esta opción para mejorar el rendimiento al pasar el ratón por encima de jugadores cuando estás en combate."
L["SHOW_SCORE_WITH_MODIFIER"] = "Mostrar Raider.IO en la información sobre herramientas con modificador"
L["SHOW_SCORE_WITH_MODIFIER_DESC"] = "Desactiva la visualización de datos al colocar el cursor sobre un jugadores a menos que se mantenga presionada una tecla modificada."
L["TANK"] = "Tanque"
--[[Translation missing --]]
--[[ L["TEAM_LF_MPLUS_DEFAULT"] = ""--]] 
--[[Translation missing --]]
--[[ L["TEAM_LF_MPLUS_WITH_SCORE"] = ""--]] 
L["TIMED_10_RUNS"] = "+10-14 en tiempo"
L["TIMED_15_RUNS"] = "+15 en tiempo"
L["TIMED_20_RUNS"] = "+20 en tiempo"
L["TIMED_5_RUNS"] = "+5-9 en tiempo"
L["TOOLTIP_PROFILE"] = "Personalización del marco de perfil"
L["UNKNOWN_SERVER_FOUND"] = "|cffFFFFFF%s|r ha encontrado un nuevo servidor. Por favor, apunta esta información |cffFF9999{|r |cffFFFFFF%s|r |cffFF9999,|r |cffFFFFFF%s|r |cffFF9999}|r y envíasela a los desarrolladores. ¡Gracias!"
L["UNLOCKING_PROFILE_FRAME"] = "RaiderIO: desbloqueando el marco de perfil de M+."
L["USE_ENGLISH_ABBREVIATION"] = "Forzar abreviaturas en inglés para mazmorras"
L["USE_ENGLISH_ABBREVIATION_DESC"] = "Cuando está activado, se sustituyen las abreviaturas usadas para referirse a las mazmorras por sus versiones en inglés, en vez de usar las de tu idioma actual."
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS"] = "Permitir que el cliente Raider.IO controle el registro de combate"
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS_DESC"] = "Permita que el Cliente Raider.IO (cuando esté presente) controle la configuración del Registro de combate automáticamente."
L["WARNING_DEBUG_MODE_ENABLE"] = "|cffFFFFFF%s|r El modo depuración está activado. Puedes desactivarlo escribiendo |cffFFFFFF/raiderio debug|r."
L["WARNING_LOCK_POSITION_FRAME_AUTO"] = "RaiderIO: primero debes deshabilitar el posicionamiento automático del marco de perfil de RaiderIO."
--[[Translation missing --]]
--[[ L["WARNING_RWF_MODE_ENABLE"] = ""--]] 
L["WIPE_RWF_MODE_BUTTON"] = "Wipe"
--[[Translation missing --]]
--[[ L["WIPE_RWF_MODE_BUTTON_TOOLTIP"] = ""--]] 

	ns.L = L
end
