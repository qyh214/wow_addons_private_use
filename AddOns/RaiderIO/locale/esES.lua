-- Generated from CurseForge on Fri Mar 14 07:54:38 UTC 2025
local ns = select(2, ...) ---@class ns @The addon namespace.

if ns:IsSameLocale("esES") then

	local L = ns.L or ns:NewLocale()
	ns.L = L

	L.LOCALE_NAME = "esES"

L["ALLOW_IN_LFD"] = "Permitir en buscador de mazmorras"
L["ALLOW_IN_LFD_CLASSIC"] = "Permitir en Buscador de grupos"
L["ALLOW_IN_LFD_CLASSIC_DESC"] = "Haga clic con el botón derecho del ratón en los grupos o candidatos del Buscador de grupos para copiar la URL del perfil de Raider.IO."
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
L["AUTO_COMBATLOG"] = "Habilitar automáticamente los registros de combate en Bandas y Mazmorras"
L["AUTO_COMBATLOG_DESC"] = "Activa o desactiva los registros de combate automáticamente al entrar y salir de las mazmorras y bandas admitidas."
L["AUTO_COMBATLOG_DISABLED_DESC"] = "El registro de combate está desactivado en Timerunner."
L["BEST_FOR_DUNGEON"] = "Mejor tiempo en esta mazmorra"
L["BEST_RUN"] = "Mejor tiempo"
L["BEST_SCORE"] = "Mejor puntuacion M + (% s)"
L["BINDING_CATEGORY_RAIDERIO"] = "Raider.IO"
L["BINDING_HEADER_RAIDERIO_REPLAYUI"] = "Replay UI"
L["BINDING_NAME_RAIDERIO_REPLAYUI_TIMING_BOSS"] = "Ajustar el tiempo a la hora del boss"
L["BINDING_NAME_RAIDERIO_REPLAYUI_TIMING_DUNGEON"] = "Ajusta el tiempo a la hora de la mazmorra"
L["BINDING_NAME_RAIDERIO_REPLAYUI_TOGGLE"] = "Alternar Replay UI"
L["CANCEL"] = "Cancelar"
L["CHANGES_REQUIRES_UI_RELOAD"] = "Los cambios se han guardado, pero debes recargar la interfaz para que surtan efecto. ¿Quieres recargar ahora?"
L["CHARACTER_LF_GUILD_MPLUS"] = "Buscando Hermandad Mythic+"
L["CHARACTER_LF_GUILD_MPLUS_WITH_SCORE"] = "Buscando Hermandad para Mythic+"
L["CHARACTER_LF_GUILD_PVP"] = "Buscando Hermandad PVP"
L["CHARACTER_LF_GUILD_RAID_DEFAULT"] = "Buscando Hermandad Raid"
L["CHARACTER_LF_GUILD_RAID_HEROIC"] = "Buscando Hermandad Raid HC"
L["CHARACTER_LF_GUILD_RAID_MYTHIC"] = "Buscando Hermandad Raid Mítico"
L["CHARACTER_LF_GUILD_RAID_NORMAL"] = "Buscando Hermandad Raid Normal"
L["CHARACTER_LF_GUILD_SOCIAL"] = "Buscando Hermandad Social"
L["CHARACTER_LF_TEAM_MPLUS_DEFAULT"] = "Buscando Grupo Mythic+"
L["CHARACTER_LF_TEAM_MPLUS_WITH_SCORE"] = "Buscando %d+ Grupo Mythic+"
L["CHECKBOX_DISPLAY_WEEKLY"] = [=[Mostrar semanal
]=]
L["CHOOSE_HEADLINE_HEADER"] = "Título Míticas+ en barra de información "
L["CONFIG_WHERE_TO_SHOW_TOOLTIPS"] = "Dónde mostrar el progreso de míticas+ y bandas"
L["CONFIRM"] = "Confirmar"
L["COPY_RAIDERIO_PROFILE_URL"] = "Copiar URL de Raider.IO"
L["COPY_RAIDERIO_RECRUITMENT_URL"] = "Copiar URL de Recutramiento"
L["COPY_RAIDERIO_URL"] = "Copiar la URL de Raider.IO"
L["CURRENT_MAINS_SCORE"] = "Puntuación actual de M+ del Main"
L["CURRENT_SCORE"] = [=[Actual puntuación M+
]=]
L["DB_MODULES"] = "Módulos de base de datos"
L["DB_MODULES_HEADER_MYTHIC_PLUS"] = "Míticas+"
L["DB_MODULES_HEADER_RAIDING"] = "Incursión"
L["DB_MODULES_HEADER_RECRUITMENT"] = "Reclutamiento"
L["DISABLE_DEBUG_MODE_RELOAD"] = "Estás desactivando el modo Debug. Al hacer clic en Confirmar se recargará de nuevo tu interfaz."
L["DISABLE_RWF_MODE_BUTTON"] = "Desactivar"
L["DISABLE_RWF_MODE_BUTTON_TOOLTIP"] = "Haz clic para desactivar el modo Race World First. Esto hará que su interfaz se vuelva a cargar."
L["DISABLE_RWF_MODE_RELOAD"] = "Estás desactivando el modo Race World First. Al hacer clic en Confirmar, volverá a cargar su interfaz."
L["DPS"] = "DPS"
L["DUNGEON_SHORT_NAME_AA"] = "Academia Algeth'ar - AA"
L["DUNGEON_SHORT_NAME_AD"] = "Atal'Dazar - AD"
L["DUNGEON_SHORT_NAME_ARAK"] = "Ara-Kara - ARAK"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_ARC"] = ""--]] 
L["DUNGEON_SHORT_NAME_AV"] = "Cámara Azur - AV"
L["DUNGEON_SHORT_NAME_BH"] = "Hondonada Frondacuero - BH"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_BREW"] = ""--]] 
L["DUNGEON_SHORT_NAME_BRH"] = "Torreón Grajo Negro - BRH"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_COEN"] = ""--]] 
L["DUNGEON_SHORT_NAME_COS"] = "Corte de las Estrellas - COS"
L["DUNGEON_SHORT_NAME_COT"] = "Ciudad Tejida - COT"
L["DUNGEON_SHORT_NAME_DAWN"] = "El Rompealbas - DAWN"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_DFC"] = ""--]] 
L["DUNGEON_SHORT_NAME_DHT"] = "Arboleda Corazón Oscuro - DHT"
L["DUNGEON_SHORT_NAME_DOS"] = "El Otro Lado - DOS"
L["DUNGEON_SHORT_NAME_EB"] = "El Vergel Eterno - EB"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_EOA"] = ""--]] 
L["DUNGEON_SHORT_NAME_FALL"] = [=[Amanecer: Caída de Galakrond - FALL
]=]
L["DUNGEON_SHORT_NAME_FH"] = "Fuerte Libre - FH"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_FLOOD"] = ""--]] 
L["DUNGEON_SHORT_NAME_GB"] = "Grim Batol - GB"
L["DUNGEON_SHORT_NAME_GD"] = "Terminal Malavía - GD"
L["DUNGEON_SHORT_NAME_GMBT"] = "Tazavesh: Gambito - GMBT"
L["DUNGEON_SHORT_NAME_HOA"] = "Salas de la Expiación - HOA"
L["DUNGEON_SHORT_NAME_HOI"] = "Salas de Infusión - HOI"
L["DUNGEON_SHORT_NAME_HOV"] = "Cámaras del Valor - HOV"
L["DUNGEON_SHORT_NAME_ID"] = "Puerto de Hierro - ID"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_KR"] = ""--]] 
L["DUNGEON_SHORT_NAME_LOWR"] = "Karazhan: Inferior - LOWR"
L["DUNGEON_SHORT_NAME_MISTS"] = "Nieblas de Tirna Scithe - MISTS"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_ML"] = ""--]] 
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_MOS"] = ""--]] 
L["DUNGEON_SHORT_NAME_NELT"] = "Neltharus - NELT"
L["DUNGEON_SHORT_NAME_NL"] = "Guarida de Neltharion - NL"
L["DUNGEON_SHORT_NAME_NO"] = "Ofensiva Nokhud - NO"
L["DUNGEON_SHORT_NAME_NW"] = "Estela Necrótica - NW "
L["DUNGEON_SHORT_NAME_PF"] = "Bajapeste - PF"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_PSF"] = ""--]] 
L["DUNGEON_SHORT_NAME_RISE"] = [=[Amanecer: Ascenso de Murozond - RISE
]=]
L["DUNGEON_SHORT_NAME_RLP"] = "Estanques de Vida Rubí - RLP"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_ROOK"] = ""--]] 
L["DUNGEON_SHORT_NAME_SBG"] = "Cementerio de Sombraluna - SBG"
L["DUNGEON_SHORT_NAME_SD"] = "Cavernas Sanguinas - SD"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_SEAT"] = ""--]] 
L["DUNGEON_SHORT_NAME_SIEGE"] = "Asedio de Boralus - SIEGE"
L["DUNGEON_SHORT_NAME_SOA"] = "Agujas de Ascensión - SOA"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_SOTS"] = ""--]] 
L["DUNGEON_SHORT_NAME_STRT"] = "Tazavesh: Calles - STRT"
L["DUNGEON_SHORT_NAME_SV"] = "La Petrocámara - SV"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_TD"] = ""--]] 
L["DUNGEON_SHORT_NAME_TJS"] = "Templo del Dragón de Jade - TJS"
L["DUNGEON_SHORT_NAME_TOP"] = "Teatro del Dolor - TOP"
--[[Translation missing --]]
--[[ L["DUNGEON_SHORT_NAME_TOS"] = ""--]] 
L["DUNGEON_SHORT_NAME_TOTT"] = "Trono de las Mareas - TOTT"
L["DUNGEON_SHORT_NAME_ULD"] = "Uldaman - ULD"
L["DUNGEON_SHORT_NAME_UNDR"] = "Catacumbas Putrefactas - UNDR"
L["DUNGEON_SHORT_NAME_UPPR"] = "Karazhan: Superior - UPPR"
L["DUNGEON_SHORT_NAME_VOTW"] = "Cámara de las Celadoras - VOTW"
L["DUNGEON_SHORT_NAME_VP"] = "Cumbre del Vórtice - VP"
L["DUNGEON_SHORT_NAME_WM"] = "Mansión Crestavía - WM"
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
L["ENABLE_REPLAY"] = "Mostrar el sistema de repetición Miticas+"
L["ENABLE_REPLAY_DESC"] = "Si activas esta opción, podrás competir contra Míticas+ ya registradas."
L["ENABLE_RWF_MODE_BUTTON"] = "Habilitar"
L["ENABLE_RWF_MODE_BUTTON_TOOLTIP"] = "Haz clic para habilitar el modo Race World First. Esto hará que su interfaz se vuelva a cargar."
L["ENABLE_RWF_MODE_RELOAD"] = "Estás habilitando el modo Race World First. Esto está pensado para ser usado en Mythic World First, y sólo debe ser usado para este propósito junto con el Cliente Raider.IO para la carga de datos. Al hacer clic en Confirmar se recargará la interfaz."
L["ENABLE_SIMPLE_SCORE_COLORS"] = "Usar colores de puntuación simples"
L["ENABLE_SIMPLE_SCORE_COLORS_DESC"] = "Muestra las puntuaciones usando solo los colores estándar de calidad de objeto. Facilita la distinción de puntuaciones para personas con defectos de visión cromática."
L["ENTER_REALM_AND_CHARACTER"] = "Introduzca el reino y el nombre del personaje:"
L["EXPORTJSON_COPY_TEXT"] = "Copia este texto y pégalo en |cff00C8FFhttps://raider.io|r para ver información de todos los jugadores."
L["GENERAL_TOOLTIP_OPTIONS"] = "Opciones generales del tooltip"
L["GUILD_BEST_SEASON"] = "Hermandad: mejor de la temporada"
L["GUILD_BEST_TITLE"] = "Récords de hermandad"
L["GUILD_BEST_WEEKLY"] = "Mejores de la semana"
L["GUILD_LF_MPLUS_DEFAULT"] = "Reclutamiento para Míticas+"
L["GUILD_LF_MPLUS_WITH_SCORE"] = "Reclutamiento %d+ jugadoras míticas+"
L["GUILD_LF_PVP"] = "Reclutar jugadores PvP"
L["GUILD_LF_RAID_DEFAULT"] = "Reclutar Raiders"
L["GUILD_LF_RAID_HEROIC"] = "Reclutamiento para Raid Heroica"
L["GUILD_LF_RAID_MYTHIC"] = "Reclutar Raiders Mítico"
L["GUILD_LF_RAID_NORMAL"] = "Reclutar Raiders Normal"
L["GUILD_LF_SOCIAL"] = "Reclutar jugadores Sociales"
L["HEALER"] = "Sanador"
L["HIDE_OWN_PROFILE"] = "Ocultar ventana emergente de perfil personal de RaiderIO"
L["HIDE_OWN_PROFILE_DESC"] = "Oculta la ventana emergente de tu perfil personal de RaiderIO. No afecta a las ventanas emergentes de otros jugadores."
L["INVERSE_PROFILE_MODIFIER"] = "Invertir modificador de marco de perfil"
L["INVERSE_PROFILE_MODIFIER_DESC"] = "Invierte el comportamiento del modificador del marco de perfil (mayús/ctrl/alt) para que muestre por defecto el perfil del líder del grupo."
L["LOCALE_NAME"] = "esES"
L["LOCKING_PROFILE_FRAME"] = "RaiderIO: bloqueando el marco de perfil de M+."
L["MAINS_BEST_SCORE_BEST_SEASON"] = "Mejor Puntuación M+ pj principal (%s)"
L["MAINS_RAID_PROGRESS"] = "Progreso de personaje principal"
L["MAINS_SCORE"] = "Puntuación de personaje principal"
L["MINIMAP_SHORTCUT_BROKER_ENABLE"] = "Mostrar icono del addon en el compartimento"
L["MINIMAP_SHORTCUT_BROKER_ENABLE_DESC"] = "Activa la visualización del icono en la lista desplegable de los addons. Esto también hace que esté disponible en todos los demás complementos compatibles de gestión de iconos."
L["MINIMAP_SHORTCUT_ENABLE"] = "Activar el botón"
L["MINIMAP_SHORTCUT_ENABLE_DESC"] = "Habilitar para mostrar el icono alrededor del minimapa. Esto también hará que esté disponible en cualquier otro addon que gestiones los iconos en el minimapa."
L["MINIMAP_SHORTCUT_HEADER"] = "Minimapa"
L["MINIMAP_SHORTCUT_HELP"] = "|A:newplayertutorial-icon-mouse-leftbutton:16:12|a Búsqueda |A:newplayertutorial-icon-mouse-rightbutton:16:12|a Configuración"
L["MINIMAP_SHORTCUT_HELP_LEFT_CLICK"] = "Clic izquierdo"
L["MINIMAP_SHORTCUT_HELP_RIGHT_CLICK"] = "Clic derecho"
L["MINIMAP_SHORTCUT_HELP_SEARCH"] = "Búsqueda"
L["MINIMAP_SHORTCUT_HELP_SETTINGS"] = "Configuración"
L["MINIMAP_SHORTCUT_LOCK"] = "Bloquear Botón"
L["MINIMAP_SHORTCUT_MINIMAP_ENABLE"] = "Habilitar el botón del minimapa"
L["MINIMAP_SHORTCUT_MINIMAP_ENABLE_DESC"] = "Habilitar para mostrar el icono alrededor del minimapa."
L["MINIMAP_SHORTCUT_MINIMAP_LOCK"] = "Bloquear botón del minimapa"
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
L["OUTDATED_DATABASE_HOURS"] = "Las puntuaciones tienen %d horas"
L["OUTDATED_DOWNLOAD_LINK"] = "Descargar: |cffffbd0a%s|r"
L["OUTDATED_EXPIRED_ALERT"] = "|cffFFFFFF%s|r está usando datos caducados. Por favor actualiza ahora para ver los datos más precisos: |cffFFFFFF%s|r"
L["OUTDATED_EXPIRED_TITLE"] = "Datos de Raider.IO han caducado"
L["OUTDATED_EXPIRES_IN_DAYS"] = "Los datos de Raider.IO caducan en %d días"
L["OUTDATED_EXPIRES_IN_HOURS"] = "Los datos de Raider.IO caducan en %d horas"
L["OUTDATED_EXPIRES_IN_MINUTES"] = "Los datos de Raider.IO caducan en %d minutos"
L["OUTDATED_PROFILE_TOOLTIP_MESSAGE"] = "Por favor, actualiza tu addon ahora para ver los datos más precisos. Los jugadores trabajan duro para mejorar su progreso, y mostrar datos antiguos es un perjuicio para ellos. Puedes usar el Cliente de Raider.IO para mantener tus datos sincronizados automáticamente."
L["PREVIOUS_SCORE"] = "Puntuación M+ anterior (%s)"
L["PROFILE_BEST_RUNS"] = "Mejor de cada mazmorra"
L["PROFILE_TOOLTIP_ANCHOR_TOOLTIP"] = "Bloquear el marco del Perfil Raider.IO o activar el Posicionamiento Automático para ocultar este anclaje."
L["PROVIDER_NOT_LOADED"] = "|cffFF0000Advertencia:|r |cffFFFFFF%s|r no puede encontrar datos para tu facción actual. Por favor, revisa tus configuraciones de |cffFFFFFF/raiderio|r y habilita los datos de la descripción emergente para |cffFFFFFF%s|r."
L["PVP_DATA_HEADER"] = "Perfil PvP de Raider.IO"
L["RAID_AATDH"] = "Despierta: Amirdrassil, la Esperanza del Sueño"
L["RAID_AATSC"] = "Despierta: Aberrus, el Crisol Ensombrecido"
L["RAID_AVOTI"] = "Despierta: Cámara de las Encarnaciones"
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATDH_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AATSC_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATDH_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_ATSC_9"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_AVOTI_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BOT_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BOT_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BOT_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BOT_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BOT_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BRD_8"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BWD_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BWD_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BWD_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BWD_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BWD_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_BWD_6"] = ""--]] 
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
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_DS_8"] = ""--]] 
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
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_1"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_2"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_3"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_4"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_5"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_6"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_7"] = ""--]] 
--[[Translation missing --]]
--[[ L["RAID_BOSS_LOU_8"] = ""--]] 
L["RAID_BOSS_NP_1"] = "Ulgrax"
L["RAID_BOSS_NP_2"] = "Bloodbound Horror"
L["RAID_BOSS_NP_3"] = "Sikran"
L["RAID_BOSS_NP_4"] = "Rasha'nan"
L["RAID_BOSS_NP_5"] = "Ovi'nax"
L["RAID_BOSS_NP_6"] = "Nexus-Princess"
L["RAID_BOSS_NP_7"] = "Silken Court"
L["RAID_BOSS_NP_8"] = "Queen Ansurek"
L["RAID_BOSS_RS_1"] = "Halion"
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
L["RAID_BOSS_TOTFW_1"] = "El Cónclave del Viento"
L["RAID_BOSS_TOTFW_2"] = "Al'Akir"
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
L["RAID_BOT"] = "Bastión del Crepúsculo - BOT"
L["RAID_BRD"] = "Profundidades de Roca Negra - BRD"
L["RAID_BWD"] = "Descenso de Alanegra - BWD"
L["RAID_DIFFICULTY_NAME_HEROIC"] = "Heroico"
L["RAID_DIFFICULTY_NAME_HEROIC10"] = "Heroico 10"
L["RAID_DIFFICULTY_NAME_HEROIC25"] = "Heroico 25"
L["RAID_DIFFICULTY_NAME_MYTHIC"] = "Mítico"
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
--[[Translation missing --]]
--[[ L["RAID_DS"] = ""--]] 
L["RAID_ENCOUNTERS_DEFEATED_TITLE"] = "Encuentros de banda derrotados"
L["RAID_FL"] = "Tierras de Fuego - FL"
L["RAID_ICC"] = "Ciudadela de la Corona de Hielo - ICC"
--[[Translation missing --]]
--[[ L["RAID_LOU"] = ""--]] 
L["RAID_NP"] = "Palacio Nerub'ar"
L["RAID_RS"] = "El Sagrario Rubí - RS"
L["RAID_TOTFW"] = "Trono de los Cuatro Vientos - TOTFW"
L["RAIDERIO_AVERAGE_PLAYER_SCORE"] = "Puntuación media de +%s en tiempo"
L["RAIDERIO_BEST_RUN"] = "Mejor resultado M+ de Raider.IO"
L["RAIDERIO_CLIENT_CUSTOMIZATION"] = "Personalización del cliente de RaiderIO"
L["RAIDERIO_LIVE_TRACKING"] = "Seguimiento en vivo de Raider.IO"
L["RAIDERIO_MP_BASE_SCORE"] = "Puntuación de M+ base"
L["RAIDERIO_MP_BEST_SCORE"] = "Puntuación M+ de Raider.IO (%s)"
L["RAIDERIO_MP_SCORE"] = "Puntuación de M+"
L["RAIDERIO_MYTHIC_OPTIONS"] = "Opciones de Raider.IO Mythic Plus"
L["RAIDING_DATA_HEADER"] = "Progreso de banda de Raider.IO"
L["RAIDING_DB_MODULES"] = "Raiding Database Modulos"
--[[Translation missing --]]
--[[ L["RECENT_RUNS_WITH_YOU"] = ""--]] 
L["RECRUITMENT_DB_MODULES"] = "Módulos de bases de datos de reclutamiento"
L["RELOAD_LATER"] = "La reiniciaré más tarde"
L["RELOAD_NOW"] = "Reiniciarla ahora"
L["RELOAD_RWF_MODE_BUTTON"] = "Guardar"
L["RELOAD_RWF_MODE_BUTTON_TOOLTIP"] = "Haga clic para guardar el registro en la carpeta de almacenamiento. Esto hará que se recargue la interfaz."
L["REPLAY_AUTO_SELECTION"] = "Tipo de repetición preferido"
L["REPLAY_AUTO_SELECTION_DESC"] = "Elija el tipo de repetición que desea que se seleccione automáticamente."
L["REPLAY_AUTO_SELECTION_GUILD_BEST"] = "Mejor de Guild"
L["REPLAY_AUTO_SELECTION_MOST_RECENT"] = "Más recientes"
L["REPLAY_AUTO_SELECTION_PERSONAL_BEST"] = "Marca personal"
L["REPLAY_AUTO_SELECTION_STARRED"] = "Favoritos"
L["REPLAY_AUTO_SELECTION_TEAM_BEST"] = "Mejor equipo"
L["REPLAY_BACKGROUND_COLOR"] = "Color de fondo de la repetición"
L["REPLAY_BACKGROUND_COLOR_DESC"] = "Especifique el color de fondo utilizado en la ventana de repetición."
L["REPLAY_DISABLE_CONFIRM"] = "Si desactivas el |cffFFBD0AMythic+ Replay System|r puedes volver a activarlo a través del panel de Configuración en la categoría |cffFFBD0ARaider.IO Client Customization|r."
L["REPLAY_FRAME_ALPHA"] = "Opacidad de la ventana de repetición"
L["REPLAY_FRAME_ALPHA_DESC"] = "Opacidad del marco de la repetición."
L["REPLAY_MENU_COPY_URL"] = "Copiar URL de repetición"
L["REPLAY_MENU_DISABLE"] = "Desactivar"
L["REPLAY_MENU_DOCK"] = "Ajuste"
L["REPLAY_MENU_LOCK"] = "Bloquear"
L["REPLAY_MENU_POSITION"] = "Posición"
L["REPLAY_MENU_REPLAY"] = "Repetición"
L["REPLAY_MENU_STYLE"] = "Estilo"
L["REPLAY_MENU_TIMING"] = "Tiempo"
L["REPLAY_MENU_UNDOCK"] = "Separar"
L["REPLAY_MENU_UNLOCK"] = "Desbloquear"
L["REPLAY_REPLAY_CHANGING"] = "Al cambiar la repetición, se restablecerán los datos en vivo."
L["REPLAY_SETTINGS_TOOLTIP"] = "Configuración"
L["REPLAY_STYLE_TITLE_MDI"] = "MDI"
L["REPLAY_STYLE_TITLE_MODERN"] = "Estándar"
L["REPLAY_STYLE_TITLE_MODERN_COMPACT"] = "Compacto"
L["REPLAY_STYLE_TITLE_MODERN_SPLITS"] = "Sólo jefes"
L["REPLAY_SUMMARY_LOGGED"] = "|cffFFFFFF%s|r registrado su finalización de |cffFFFFFF+%s|r en |cffFFFF%s|r."
L["REPLAY_TIMING_TITLE_BOSS"] = "Tiempo de Jefe"
L["REPLAY_TIMING_TITLE_DUNGEON"] = "Tiempo de mazmorra"
L["RESET_BUTTON"] = "Restablecer valores"
L["RESET_CONFIRM_BUTTON"] = "Reiniciar y recargar"
L["RESET_CONFIRM_TEXT"] = "¿Estás seguro de que quieres restablecer Raider.IO a la configuración predeterminada?"
L["RWF_MINIBUTTON_TOOLTIP"] = "Clic izquierdo siempre que haya botín pendiente. Esto hará que tu Interfaz se Recargue. Clic derecho para abrir la ventaneada del Race World First."
L["RWF_SUBTITLE_LOGGING_FILTERED_LOOT"] = "(registro de objetos relevantes)"
L["RWF_SUBTITLE_LOGGING_LOOT"] = "(registro de botín)"
L["RWF_TITLE"] = "|cffFFFFFFRaider.IO|r Race World First"
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
L["SHOW_BEST_SEASON"] = "Mostrar la mejor puntuación de la temporada de M+ en la descripción"
L["SHOW_BEST_SEASON_DESC"] = "Muestra la mejor puntuación de la temporada de Míticas+ del jugador en la descripción emergente al pasar el ratón por encima de un jugador. Si la puntuación es de una temporada anterior, la temporada se indicará en la descripción."
L["SHOW_CHESTS_AS_MEDALS"] = "Mostrar iconos de medallas de míticas"
L["SHOW_CHESTS_AS_MEDALS_DESC"] = "Muestra las medallas de piedras angulares ganadas como iconos en lugar de signos más (+)."
L["SHOW_CLIENT_GUILD_BEST"] = "Mostrar mejores puntuaciones de mazmorra en el buscador de grupos"
L["SHOW_CLIENT_GUILD_BEST_DESC"] = "Muestra las cinco mejores puntuaciones de tu hermandad (tanto de temporada como semanales) en la pestaña 'Piedra angular mítica' de la ventana del buscador de grupos."
L["SHOW_CURRENT_SEASON"] = "Mostrar la puntuación de la temporada actual de M+ en la descripción"
L["SHOW_CURRENT_SEASON_DESC"] = "Muestra la puntuación actual de la temporada de Míticas+ del jugador como información en la ventana de descripción emergente al pasar el ratón por un jugador."
L["SHOW_IN_FRIENDS"] = "Mostrar en la lista de amigos"
L["SHOW_IN_FRIENDS_DESC"] = "Muestra la puntuación de M+ de tus amigos cuando pasas el ratón por encima."
L["SHOW_IN_LFD"] = "Mostrar en el buscador de grupos"
L["SHOW_IN_LFD_CLASSIC"] = "Mostrar en el buscador de grupos"
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
L["SHOW_RAIDERIO_BESTRUN_FIRST"] = "(Experimental) Priorizar Mostrar la Mejor piedra de Raider.IO"
L["SHOW_RAIDERIO_BESTRUN_FIRST_DESC"] = "Esta es una característica experimental. En lugar de mostrar la puntuación de Raider.IO como primera línea, muestra la mejor piedra completada por el jugador."
L["SHOW_RAIDERIO_PROFILE"] = "Mostrar marco de perfil en el buscador de grupos"
L["SHOW_RAIDERIO_PROFILE_DESC"] = "Muestra el marco de perfil de Raider.IO en el buscador de grupos."
L["SHOW_RAIDERIO_PROFILE_OPTION"] = "Mostrar perfil de Raider.IO"
L["SHOW_ROLE_ICONS"] = "Mostrar iconos de rol en el tooltip"
L["SHOW_ROLE_ICONS_DESC"] = "Cuando está activado, se muestran los mejores roles del jugador en míticas+ en el tooltip."
L["SHOW_SCORE_IN_COMBAT"] = "Mostrar puntuación en combate"
L["SHOW_SCORE_IN_COMBAT_DESC"] = "Desactiva esta opción para mejorar el rendimiento al pasar el ratón por encima de jugadores cuando estás en combate."
L["SHOW_SCORE_WITH_MODIFIER"] = "Mostrar información de Raider.IO en la descripción emergente con modificador"
L["SHOW_SCORE_WITH_MODIFIER_DESC"] = "Desactiva la visualización de datos al colocar el ratón sobre un jugador, a menos que se mantenga presionada una tecla previamente seleccionada."
L["SHOW_WARBAND_SCORE"] = "Mostrar puntuación y progreso M+ de la Banda guerrera en la descripción"
L["SHOW_WARBAND_SCORE_DESC"] = "Muestra la puntuación de Mítica+ de la banda de guerra del jugador en la temporada actual y el progreso de la banda en la descripción emergente. Los jugadores deben haberse registrado en Raider.IO y haber sincronizado su BNET para que el progreso de la banda de guerra funcione."
L["TANK"] = "Tanque"
L["TEAM_LF_MPLUS_DEFAULT"] = "Reclutar jugadores para Míticas+"
L["TEAM_LF_MPLUS_WITH_SCORE"] = "Reclutando %d+ jugadores M+"
L["TIMED_10_RUNS"] = "+10-14 en tiempo"
L["TIMED_15_RUNS"] = "+15 en tiempo"
L["TIMED_20_RUNS"] = "+20 en tiempo"
L["TIMED_5_RUNS"] = "+5-9 en tiempo"
L["TIMED_RUNS_MINIMUM"] = "En tiempo %d+ completadas"
L["TIMED_RUNS_RANGE"] = "Completadas en tiempo +%d-%d "
L["TOOLTIP_PROFILE"] = "Personalización del marco de perfil"
L["UNKNOWN_SERVER_FOUND"] = "|cffFFFFFF%s|r ha encontrado un nuevo servidor. Por favor, apunta esta información |cffFF9999{|r |cffFFFFFF%s|r |cffFF9999,|r |cffFFFFFF%s|r |cffFF9999}|r y envíasela a los desarrolladores. ¡Gracias!"
L["UNLOCKING_PROFILE_FRAME"] = "RaiderIO: desbloqueando el marco de perfil de M+."
L["USE_ENGLISH_ABBREVIATION"] = "Forzar abreviaturas en inglés para mazmorras"
L["USE_ENGLISH_ABBREVIATION_DESC"] = "Cuando está activado, se sustituyen las abreviaturas usadas para referirse a las mazmorras por sus versiones en inglés, en vez de usar las de tu idioma actual."
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS"] = "Permitir que el cliente de Raider.IO controle el registro de combate"
L["USE_RAIDERIO_CLIENT_LIVE_TRACKING_SETTINGS_DESC"] = "Permitir que el cliente de Raider.IO (cuando esté presente) controle automáticamente la configuración de registro de combate."
L["WARBAND_BEST_SCORE_BEST_SEASON"] = "Mejor puntuación M+ Banda de guerra (%s)"
L["WARBAND_SCORE"] = "Puntuación M+ Banda de guerra"
L["WARNING_DEBUG_MODE_ENABLE"] = "|cffFFFFFF%s|r El modo depuración está activado. Puedes desactivarlo escribiendo |cffFFFFFF/raiderio debug|r."
L["WARNING_LOCK_POSITION_FRAME_AUTO"] = "RaiderIO: primero debes deshabilitar el posicionamiento automático del marco de perfil de RaiderIO."
L["WARNING_RWF_MODE_ENABLE"] = "|cffFFFFFF%s|r Race World First.-Está activado. Puedes desactivarlo introduciendo |cffFFFFFF/raiderio rwf|r."
L["WIPE_RWF_MODE_BUTTON"] = "Wipe"
L["WIPE_RWF_MODE_BUTTON_TOOLTIP"] = "Haga clic para borrar el Registro del almacenamiento. Esto hará que la interfaz se recargue."

end
