local CraftScan = select(2, ...)
CraftScan.LOCAL_MX = {}

function CraftScan.LOCAL_MX:GetData()
    local LID = CraftScan.CONST.TEXT;
    return {
        ["CraftScan"]                             = "CraftScan",
        [LID.CRAFT_SCAN]                          = "CraftScan",
        [LID.CHAT_ORDERS]                         = "Órdenes de Chat",
        [LID.DISABLE_ADDONS]                      = "Desactivar Addons",
        [LID.RENABLE_ADDONS]                      = "Reactivar Addons",
        [LID.DISABLE_ADDONS_TOOLTIP]              =
        "Guarda tu lista de addons y luego desactívalos, permitiendo un cambio rápido a un alter. Este botón puede ser pulsado de nuevo para reactivar los addons en cualquier momento.",
        [LID.GREETING_I_CAN_CRAFT_ITEM]           = "Puedo fabricar {item}.",                      -- ItemLink
        [LID.GREETING_ALT_CAN_CRAFT_ITEM]         = "Mi alter, {crafter}, puede fabricar {item}.", -- Crafter Name, ItemLink
        [LID.GREETING_LINK_BACKUP]                = "eso",
        [LID.GREETING_I_HAVE_PROF]                = "Tengo {profession}.",                         -- Profession Name
        [LID.GREETING_ALT_HAS_PROF]               = "Mi alter, {crafter}, tiene {profession}.",    -- Crafter Name, Profession Name
        [LID.GREETING_ALT_SUFFIX]                 = "Avísame si envías una orden para que pueda cambiar de personaje.",
        [LID.MAIN_BUTTON_BINDING_NAME]            = "Alternar Página de Órdenes",
        [LID.GREET_BUTTON_BINDING_NAME]           = "Saludar al Cliente del Banner",
        [LID.DISMISS_BUTTON_BINDING_NAME]         = "Despedir al Cliente del Banner",
        [LID.TOGGLE_CHAT_TOOLTIP]                 = "Alternar órdenes de chat%s", -- Keybind
        [LID.SCANNER_CONFIG_SHOW]                 = "Mostrar CraftScan",
        [LID.SCANNER_CONFIG_HIDE]                 = "Ocultar CraftScan",
        [LID.CRAFT_SCAN_OPTIONS]                  = "Opciones de CraftScan",
        [LID.ITEM_SCAN_CHECK]                     = "Escanear chat para este ítem",
        [LID.HELP_PROFESSION_KEYWORDS]            =
        "Un mensaje debe contener uno de estos términos. Para coincidir con un mensaje como 'LF Lariat', 'lariat' debe estar listado aquí. Para generar un enlace de ítem para el Lazo Elemental en la respuesta, 'lariat' también debe incluirse en las palabras clave de configuración del ítem para el Lazo Elemental.",
        [LID.HELP_PROFESSION_EXCLUSIONS]          =
        "Un mensaje será ignorado si contiene uno de estos términos, incluso si de otra manera sería una coincidencia. Para evitar responder a 'LF JC Lariat' con 'Tengo Joyería' cuando no tienes la receta de Lazo, 'lariat' debe estar listado aquí.",
        [LID.HELP_SCAN_ALL]                       =
        "Habilitar escaneo para todas las recetas en la misma expansión que la receta seleccionada.",
        [LID.HELP_PRIMARY_EXPANSION]              =
        "Usa este saludo al responder a una solicitud genérica como 'LF Herrero'. Cuando se lance una nueva expansión, probablemente querrás un saludo que describa los ítems que puedes fabricar en lugar de indicar que tienes el máximo conocimiento de la expansión anterior.",
        [LID.HELP_EXPANSION_GREETING]             =
        "Siempre se genera una introducción inicial que indica que puedes fabricar el ítem. Este texto se agrega a ella. Se permiten nuevas líneas y se enviarán como una respuesta separada. Si el texto es demasiado largo, se dividirá en múltiples respuestas.",
        [LID.HELP_CATEGORY_KEYWORDS]              =
        "Si se ha coincidido con una profesión, verifica estas palabras clave específicas de la categoría para refinar el saludo. Por ejemplo, podrías poner 'tóxico' o 'viscoso' aquí para intentar detectar patrones de Peletería que requieren el Altar de la Decadencia.",
        [LID.HELP_CATEGORY_GREETING]              =
        "Cuando se detecta esta categoría en un mensaje, ya sea mediante una palabra clave o un enlace de ítem, este saludo adicional se agregará después del saludo de la profesión.",
        [LID.HELP_CATEGORY_OVERRIDE]              = "Omitir el saludo de la profesión y comenzar con el saludo de la categoría.",
        [LID.HELP_ITEM_KEYWORDS]                  =
        "Si se ha coincidido con una profesión, verifica estas palabras clave específicas del ítem para refinar el saludo. Cuando coincidan, la respuesta incluirá el enlace del ítem en lugar del saludo genérico de la profesión. Si 'lariat' es una palabra clave de profesión, pero no una palabra clave de ítem, la respuesta dirá 'Tengo Joyería.' Si 'lariat' es solo una palabra clave de ítem, 'LF Lariat' no coincidirá con una profesión y no se considerará una coincidencia. Si 'lariat' es tanto una palabra clave de profesión como de ítem, la respuesta a 'LF Lariat' será 'Puedo fabricar [Lazo Elemental].'",
        [LID.HELP_ITEM_GREETING]                  =
        "Cuando se detecta este ítem en un mensaje, ya sea mediante una palabra clave o el enlace del ítem, este saludo adicional se agregará después de los saludos de profesión y categoría.",
        [LID.HELP_ITEM_OVERRIDE]                  = "Omitir el saludo de la profesión y la categoría y comenzar con el saludo del ítem.",
        [LID.HELP_GLOBAL_KEYWORDS]                = "Un mensaje debe incluir uno de estos términos.",
        [LID.HELP_GLOBAL_EXCLUSIONS]              = "Un mensaje será ignorado si contiene uno de estos términos.",
        [LID.SCAN_ALL_RECIPES]                    = "Escanear todas las recetas",
        [LID.SCANNING_ENABLED]                    = "El escaneo está habilitado porque '%s' está marcado.", -- SCAN_ALL_RECIPES or ITEM_SCAN_CHECK
        [LID.SCANNING_DISABLED]                   = "El escaneo está deshabilitado.",
        [LID.PRIMARY_KEYWORDS]                    = "Palabras clave primarias",
        [LID.HELP_PRIMARY_KEYWORDS]               =
        "Todos los mensajes se filtran por estos términos, que son comunes a todas las profesiones. Un mensaje coincidente se procesa más para buscar contenido relacionado con la profesión.",
        [LID.HELP_CATEGORY_SECTION]               =
        "La categoría es la sección colapsable que contiene la receta en la lista a la izquierda. 'Favoritos' no es una categoría. Esto está destinado principalmente a cosas como las recetas tóxicas de Peletería que son más difíciles de fabricar. También podría ser útil al inicio de expansiones cuando solo puedes especializarte en una categoría.",
        [LID.HELP_EXPANSION_SECTION]              =
        "Los árboles de conocimiento difieren por expansión, por lo que el saludo también puede diferir.",
        [LID.HELP_PROFESSION_SECTION]             =
        "Desde el punto de vista del cliente, no hay diferencia entre expansiones. Estos términos se combinan con la selección de 'expansión primaria' para proporcionar un saludo genérico (por ejemplo, 'Tengo <profesión>.') cuando no podemos coincidir con algo más específico.",
        [LID.RECIPE_NOT_LEARNED]                  = "No has aprendido esta receta. El escaneo está deshabilitado.",
        [LID.PING_SOUND_LABEL]                    = "Sonido de alerta",
        [LID.PING_SOUND_TOOLTIP]                  = "El sonido que se reproduce cuando se detecta un cliente.",
        [LID.BANNER_SIDE_LABEL]                   = "Dirección del banner",
        [LID.BANNER_SIDE_TOOLTIP]                 = "El banner crecerá desde el botón en esta dirección.",
        Left                                      = "Izquierda",
        Right                                     = "Derecha",
        Minute                                    = "Minuto",
        Minutes                                   = "Minutos",
        Second                                    = "Segundo",
        Seconds                                   = "Segundos",
        Millisecond                               = "Milisegundo",
        Milliseconds                              = "Milisegundos",
        Version                                   = "Nuevo en",
        ["CraftScan Release Notes"]               = "Notas de la Versión de CraftScan",
        [LID.CUSTOMER_TIMEOUT_LABEL]              = "Tiempo de espera del cliente",
        [LID.CUSTOMER_TIMEOUT_TOOLTIP]            = "Despedir automáticamente a los clientes después de estos minutos.",
        [LID.BANNER_TIMEOUT_LABEL]                = "Tiempo de espera del banner",
        [LID.BANNER_TIMEOUT_TOOLTIP]              =
        "El banner de notificación del cliente permanecerá mostrado por esta duración después de que se detecte una coincidencia.",
        ["All crafters"]                          = "Todos los artesanos",
        ["Crafter Name"]                          = "Nombre del Artesano",
        ["Profession"]                            = "Profesión",
        ["Customer Name"]                         = "Nombre del Cliente",
        ["Replies"]                               = "Respuestas",
        ["Keywords"]                              = "Palabras clave",
        ["Profession greeting"]                   = "Saludo de la profesión",
        ["Category greeting"]                     = "Saludo de la categoría",
        ["Item greeting"]                         = "Saludo del ítem",
        ["Primary expansion"]                     = "Expansión primaria",
        ["Override greeting"]                     = "Sobrescribir saludo",
        ["Excluded keywords"]                     = "Palabras clave excluidas",
        [LID.EXCLUSION_INSTRUCTIONS]              = "No coincidir mensajes que contengan estos tokens separados por comas.",
        [LID.KEYWORD_INSTRUCTIONS]                = "Coincidir mensajes que contengan una de estas palabras clave separadas por comas.",
        [LID.GREETING_INSTRUCTIONS]               = "Un saludo para enviar a los clientes que buscan un oficio.",
        [LID.GLOBAL_INCLUSION_DEFAULT]            = "LF, LFC, WTB, recraft",
        [LID.GLOBAL_EXCLUSION_DEFAULT]            = "LFW, WTS, LF trabajo",
        [LID.DEFAULT_KEYWORDS_BLACKSMITHING]      = "BS, Herrero, Forjador de Armaduras, Forjador de Armas",
        [LID.DEFAULT_KEYWORDS_LEATHERWORKING]     = "LW, Peletería, Peletero",
        [LID.DEFAULT_KEYWORDS_ALCHEMY]            = "Alc, Alquimista, Piedra",
        [LID.DEFAULT_KEYWORDS_TAILORING]          = "Sastre",
        [LID.DEFAULT_KEYWORDS_ENGINEERING]        = "Ingeniero, Ing",
        [LID.DEFAULT_KEYWORDS_ENCHANTING]         = "Encantador, Cresta",
        [LID.DEFAULT_KEYWORDS_JEWELCRAFTING]      = "JC, Joyero",
        [LID.DEFAULT_KEYWORDS_INSCRIPTION]        = "Inscripción, Inscripcionista, Escriba",

        -- Release notes
        [LID.RN_WELCOME]                          = "¡Bienvenido a CraftScan!",
        [LID.RN_WELCOME + 1]                      =
        "Este addon escanea el chat en busca de mensajes que parezcan solicitudes de fabricación. Si la configuración indica que puedes fabricar el ítem solicitado, se activará una notificación y se almacenará la información del cliente para facilitar la comunicación.",

        [LID.RN_INITIAL_SETUP]                    = "Configuración Inicial",
        [LID.RN_INITIAL_SETUP + 1]                =
        "Para empezar, abre una profesión y haz clic en el nuevo botón 'Mostrar CraftScan' en la parte inferior.",
        [LID.RN_INITIAL_SETUP + 2]                =
        "Desplázate hasta el final de esta nueva ventana y trabaja hacia arriba. Las cosas que necesitas cambiar raramente están al final, pero esas son las configuraciones de las que preocuparse primero.",
        [LID.RN_INITIAL_SETUP + 3]                =
        "Haz clic en el ícono de ayuda en la esquina superior izquierda de la ventana si necesitas una explicación de cualquier entrada.",

        [LID.RN_INITIAL_TESTING]                  = "Pruebas Iniciales",
        [LID.RN_INITIAL_TESTING + 1]              =
        "Una vez configurado, escribe un mensaje en el chat /decir, como 'LF BS' para Herrería, asumiendo que has dejado las palabras clave 'LF' y 'BS'. Debería aparecer una notificación.",
        [LID.RN_INITIAL_TESTING + 2]              =
        "Haz clic en la notificación para enviar una respuesta inmediatamente, haz clic derecho para despedir al cliente, o haz clic en el botón circular de la profesión para abrir la ventana de órdenes.",
        [LID.RN_INITIAL_TESTING + 3]              =
        "Las notificaciones duplicadas se suprimen a menos que ya hayan sido descartadas, así que haz clic derecho en tu notificación de prueba para descartarla si quieres intentarlo de nuevo.",

        [LID.RN_MANAGING_CRAFTERS]                = "Gestionando Tus Artesanos",
        [LID.RN_MANAGING_CRAFTERS + 1]            =
        "El lado izquierdo de la ventana de órdenes lista a tus artesanos. Esta lista se llenará a medida que inicies sesión en tus varios personajes y configures sus profesiones. Puedes seleccionar qué personajes deben ser escaneados activamente en cualquier momento, así como si las notificaciones visuales y auditivas están habilitadas para cada uno de tus artesanos.",

        [LID.RN_MANAGING_CUSTOMERS]               = "Gestionando Clientes",
        [LID.RN_MANAGING_CUSTOMERS + 1]           =
        "El lado derecho de la ventana de órdenes se llenará con órdenes de fabricación detectadas en el chat. Haz clic izquierdo en una fila para enviar el saludo si no lo hiciste ya desde el banner emergente. Haz clic izquierdo de nuevo para abrir un susurro al cliente. Haz clic derecho para descartar la fila.",
        [LID.RN_MANAGING_CUSTOMERS + 2]           =
        "Las filas en esta tabla persistirán en todos los personajes, por lo que puedes cambiar a un alter y luego hacer clic en el cliente nuevamente para restaurar la comunicación. Las filas se agotan después de 10 minutos por defecto. Esta duración se puede configurar en la página principal de configuraciones (Esc -> Opciones -> AddOns -> CraftScan).",
        [LID.RN_MANAGING_CUSTOMERS + 3]           =
        "Esperemos que la mayor parte de la tabla sea autoexplicativa. La columna 'Respuestas' tiene 3 íconos. La X o marca de verificación izquierda es si has enviado un mensaje al cliente. La X o marca de verificación derecha es si el cliente ha respondido. La burbuja de chat es un botón que abrirá una ventana de susurro temporal con el cliente y la llenará con tu historial de chat.",

        [LID.RN_KEYBINDS]                         = "Atajos de Teclado",
        [LID.RN_KEYBINDS + 1]                     =
        "Hay atajos de teclado disponibles para abrir la página de órdenes, responder al último cliente y despedir al último cliente. Busca 'CraftScan' para encontrar todas las configuraciones disponibles.",

        [LID.RN_CLEANUP]                          = "Limpieza de Configuración",
        [LID.RN_CLEANUP + 1]                      =
        "Tus artesanos en el lado izquierdo de la página 'Órdenes de Chat' ahora tienen un menú contextual al hacer clic derecho. Usa este menú para mantener la lista limpia y eliminar personajes/profesiones obsoletos.",
        ["Disable"]                               = "Desactivar",
        [LID.DELETE_CONFIG_TOOLTIP_TEXT]          =
        "Elimina permanentemente cualquier dato %s guardado para %s.\n\nUn botón 'Habilitar CraftScan' estará presente en la página de la profesión para habilitarlo nuevamente con la configuración predeterminada.\n\nUsa esto si deseas continuar usando la profesión, pero sin la interacción de CraftScan (por ejemplo, cuando tienes Alquimia en todos los personajes secundarios para frascos largos).", -- profession-name, character-name
        [LID.DELETE_CONFIG_CONFIRM]               = "Escribe 'DELETE' para continuar:",
        [LID.SCANNER_CONFIG_DISABLED]             = "Habilitar CraftScan",

        ["Cleanup"]                               = "Limpiar",
        [LID.CLEANUP_CONFIG_TOOLTIP_TEXT]         =
        "Elimina permanentemente cualquier dato %s guardado para %s.\n\nLa profesión quedará en un estado como si nunca hubiera sido configurada. Simplemente abrir la profesión nuevamente restaurará una configuración predeterminada.\n\nUsa esto si deseas restablecer completamente una profesión, has eliminado el personaje o has abandonado la profesión.", -- profession-name, character-name
        [LID.CLEANUP_CONFIG_CONFIRM]              = "Escribe 'CLEANUP' para continuar:",

        ["Primary Crafter"]                       = "Artesano Principal",
        [LID.PRIMARY_CRAFTER_TOOLTIP]             =
        "Marca %s como tu artesano principal para %s. Este artesano tendrá prioridad sobre otros si hay varias coincidencias con la misma solicitud.",
        ["Chat History"]                          = "Historial de chat con %s", -- customer, left-click-help
        ["Greet Help"]                            = "|cffffd100Clic izquierdo: Saludar al cliente%s|r",
        ["Chat Help"]                             = "|cffffd100Clic izquierdo: Abrir susurro|r",
        ["Chat Override"]                         = "|cffffd100Clic medio: Abrir susurro%s|r",
        ["Dismiss"]                               = "|cffffd100Clic derecho: Descartar%s|r",
        ["Proposed Greeting"]                     = "Saludo propuesto:",
        [LID.CHAT_BUTTON_BINDING_NAME]            = "Susurro al Cliente de la Bandera",
        ["Customer Request"]                      = "Solicitud de %s",
        [LID.ADDON_WHITELIST_LABEL]               = "Lista blanca de addons",
        [LID.ADDON_WHITELIST_TOOLTIP]             =
        "Cuando presionas el botón para desactivar temporalmente todos los addons, mantén los addons seleccionados aquí activados. CraftScan siempre estará habilitado. Mantén solo lo que necesitas para fabricar eficientemente.",
        [LID.MULTI_SELECT_BUTTON_TEXT]            = "%d seleccionados", -- Count

        [LID.ACCOUNT_LINK_DESC]                   =
        "Comparte artesanos entre varias cuentas.\n\nAl iniciar sesión o después de un cambio de configuración, CraftScan propagará la información más reciente entre los artesanos configurados en cualquiera de las cuentas para asegurarse de que ambos lados de una cuenta vinculada estén siempre sincronizados.",
        [LID.ACCOUNT_LINK_PROMPT_CHARACTER]       = "Ingresa el nombre de un personaje en línea en tu otra cuenta:",
        [LID.ACCOUNT_LINK_PROMPT_NICKNAME]        = "Ingresa un apodo para la otra cuenta:",
        ["Link Account"]                          = "Vincular cuenta",
        ["Linked Accounts"]                       = "Cuentas vinculadas",
        ["Accept Linked Account"]                 = "Aceptar cuenta vinculada",
        ["Delete Linked Account"]                 = "Eliminar cuenta vinculada",
        ["OK"]                                    = "OK",
        [LID.VERSION_MISMATCH]                    =
        "|cFFFF0000Error: incompatibilidad de versión de CraftScan. Versión de la otra cuenta: %s. Tu versión: %s.|r",

        [LID.REMOTE_CRAFTER_TOOLTIP]              =
        "Este personaje pertenece a una cuenta vinculada. Solo puede desactivarse en la cuenta a la que pertenece. Puedes eliminar completamente este personaje a través de 'Limpieza', pero necesitarás hacerlo manualmente en todas las cuentas vinculadas, o será restaurado por una cuenta vinculada al iniciar sesión.",
        [LID.REMOTE_CRAFTER_SUMMARY]              = "Sincronizado con %s.",
        ["proxy_send_enabled"]                    = "Órdenes proxy",
        ["proxy_send_enabled_tooltip"]            = "Cuando se detecta un pedido de cliente, envíalo a cuentas vinculadas.",
        ["proxy_receive_enabled"]                 = "Recibir órdenes proxy",
        ["proxy_receive_enabled_tooltip"]         =
        "Cuando otra cuenta detecta y envía un pedido de cliente, esta cuenta lo recibirá. El botón CraftScan se mostrará para mostrar la alerta si es necesario.",
        [LID.LINK_ACTIVE]                         = "|cFF00FF00%s (visto por última vez %s)|r", -- Crafter, Time
        [LID.ACCOUNT_LINK_DELETE_INFO]            =
        "Elimina el enlace a '%s' y todos los personajes importados. Esta cuenta dejará de comunicarse con la otra parte. La otra parte seguirá intentando establecer conexiones hasta que el enlace también se elimine manualmente allí.\n\nArtesanos importados que se eliminarán:\n%s",
        [LID.ACCOUNT_LINK_ADD_CHAR]               =
        "Por defecto, el personaje que vinculaste inicialmente, cualquier artesano y cualquier personaje que haya iniciado sesión mientras esta cuenta estaba en línea son conocidos por CraftScan. Agrega personajes adicionales propiedad de la otra cuenta para que también puedan usarse. '/reload' para forzar la sincronización con el nuevo personaje si está en línea.",
        ["Backup characters"]                     = "Personajes adicionales",
        ["Unlink account"]                        = "Desvincular cuenta",
        ["Add"]                                   = "Agregar",
        ["Remove"]                                = "Eliminar",
        ["Rename account"]                        = "Renombrar cuenta",
        ["New name"]                              = "Nuevo nombre:",

        [LID.RN_LINKED_ACCOUNTS]                  = "Cuentas vinculadas",
        [LID.RN_LINKED_ACCOUNTS + 1]              =
        "Vincula varias cuentas de WoW para compartir información de fabricación y escanear desde cualquier cuenta.",
        [LID.RN_LINKED_ACCOUNTS + 2]              =
        "Opcionalmente, envía pedidos de clientes por proxy de una cuenta a las otras para que puedas estacionar una cuenta de prueba en la ciudad mientras tu personaje principal está fuera.",
        [LID.RN_LINKED_ACCOUNTS + 3]              =
        "Para empezar, haz clic en el botón 'Vincular cuenta' en la esquina inferior izquierda de la ventana de CraftScan y sigue las instrucciones.",
        [LID.RN_LINKED_ACCOUNTS + 4]              = "Demostración: https://www.youtube.com/watch?v=x1JLEph6t_c",

        ["Open Settings"]                         = "Abrir configuración",
        ["Customize Greeting"]                    = "Personalizar saludo",
        [LID.CUSTOM_GREETING_INFO]                =
        "CraftScan utiliza estas frases para crear el saludo inicial enviado a los clientes dependiendo de la situación. Sobrescribe algunas o todas a continuación para crear tu propio saludo.",
        ["Default"]                               = "Predeterminado",
        [LID.MISSING_PLACEHOLDERS]                = "Los siguientes marcadores de posición también son compatibles: %s.",
        [LID.EXTRA_PLACEHOLDERS]                  = "Error: %s no son marcadores de posición válidos.",
        [LID.LEGACY_PLACEHOLDERS]                 =
        "Advertencia: El uso de %s ya no está recomendado. Utilice marcadores de posición con nombre, como por ejemplo: {placeholder}",

        ["Pixels"]                                = "Píxeles",
        ["Show button height"]                    = "Mostrar altura del botón",
        ["Alert icon scale"]                      = "Escala del ícono de alerta",
        ["Total"]                                 = "Total",
        ["Repeat"]                                = "Repetir",
        ["Avg Per Day"]                           = "Promedio/Día",
        ["Peak Per Hour"]                         = "Pico/Hora",
        ["Median Per Customer"]                   = "Mediana/Cliente",
        ["Median Per Customer Filtered"]          = "Mediana/Cliente Filtrado",
        ["No analytics data"]                     = "No hay datos analíticos",
        ["Reset Analytics"]                       = "Restablecer análisis",
        ["Analytics Options"]                     = "Opciones de análisis",

        ["1 minute"]                              = "1 minuto",
        ["15 minutes "]                           = "15 minutos",
        ["1 hour"]                                = "1 hora",
        ["1 day"]                                 = "1 día",
        ["1 week "]                               = "1 semana",
        ["30 days"]                               = "30 días",
        ["180 days"]                              = "180 días",
        ["1 year"]                                = "1 año",
        ["Clear recent data"]                     = "Borrar datos recientes",
        ["Newer than"]                            = "Más reciente que",
        ["Clear old data"]                        = "Borrar datos antiguos",
        ["Older than"]                            = "Más antiguo que",
        ["1 Minute Bins"]                         = "Intervalos de 1 minuto",
        ["5 Minute Bins"]                         = "Intervalos de 5 minutos",
        ["10 Minute Bins"]                        = "Intervalos de 10 minutos",
        ["30 Minute Bins"]                        = "Intervalos de 30 minutos",
        ["1 Hour Bins"]                           = "Intervalos de 1 hora",
        ["6 Hour Bins"]                           = "Intervalos de 6 horas",
        ["12 Hour Bins"]                          = "Intervalos de 12 horas",
        ["24 Hour Bins"]                          = "Intervalos de 24 horas",
        ["1 Week Bins"]                           = "Intervalos de 1 semana",

        [LID.ANALYTICS_ITEM_TOOLTIP]              =
        "Los ítems se emparejan asegurando que un mensaje coincida con las palabras clave de inclusión y exclusión globales, y luego buscando el ícono de calidad en un enlace de ítem. No hay una lista global de ítems creados ni forma de determinar si un itemID es creado, así que esto es lo mejor que podemos hacer.",
        [LID.ANALYTICS_PROFESSION_TOOLTIP]        =
        "No hay una búsqueda inversa de un ítem al oficio que lo crea. Si uno de tus personajes puede crear el ítem, se asigna automáticamente el oficio. Cuando se abre un oficio, se asignan los ítems desconocidos pertenecientes a ese oficio. También puedes asignar manualmente el oficio.",
        [LID.ANALYTICS_TOTAL_TOOLTIP]             =
        "El número total de veces que se ha solicitado este ítem. Las solicitudes duplicadas del mismo cliente dentro de la misma hora no se incluyen.",
        [LID.ANALYTICS_REPEAT_TOOLTIP]            =
        "El número total de veces que este ítem ha sido solicitado por el mismo cliente múltiples veces dentro de la misma hora.\n\nSi este valor está cerca del total, probablemente falta suministro para este ítem.\n\nSe ignoran las solicitudes duplicadas dentro de los 15 segundos de la solicitud inicial.",
        [LID.ANALYTICS_AVERAGE_TOOLTIP]           = "El número promedio de solicitudes totales para este ítem por día.",
        [LID.ANALYTICS_PEAK_TOOLTIP]              = "El número máximo de solicitudes para este ítem por hora.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP]            =
        "El número mediano de veces que el mismo cliente ha solicitado el mismo ítem dentro de la misma hora.\n\nUn valor de 1 indica que al menos la mitad de todas las solicitudes están siendo satisfechas por alguien y la demanda de este ítem probablemente está cubierta.\n\nSi este valor es alto, probablemente sea un buen ítem para considerar fabricar.",
        [LID.ANALYTICS_MEDIAN_TOOLTIP_FILTERED]   =
        "El número mediano de veces que el mismo cliente ha solicitado el mismo ítem dentro de la misma hora, filtrado para solo aquellas solicitudes donde el solicitante preguntó múltiples veces.\n\nSi este valor no es 1 pero la mediana sin filtrar es 1, eso indica que hay momentos en que la demanda no se está satisfaciendo.",
        ["Request Count"]                         = "Contador de Solicitudes",
        [LID.ACCOUNT_LINK_ACCEPT_DST_INFO]        =
        "'%s' ha enviado una solicitud para vincular cuentas.\n\nSe solicitaron los siguientes permisos:\n\n%s\n\nNo aceptes permisos completos a menos que tú hayas enviado la solicitud.\n\nIngresa un apodo para la otra cuenta:",
        [LID.LINKED_ACCOUNT_REJECTED]             = "CraftScan: La solicitud de cuenta vinculada falló. Razón: %s",
        [LID.LINKED_ACCOUNT_USER_REJECTED]        = "La cuenta objetivo rechazó la solicitud.",

        [LID.LINKED_ACCOUNT_PERMISSION_FULL]      = "Control Total",
        [LID.LINKED_ACCOUNT_PERMISSION_ANALYTICS] = "Sincronización de Análisis",
        [LID.ACCOUNT_LINK_PERMISSIONS_DESC]       = "Solicita los siguientes permisos con la cuenta vinculada.",
        [LID.ACCOUNT_LINK_FULL_CONTROL_DESC]      =
        "Sincroniza todos los datos del personaje y admite todos los demás permisos también.",
        [LID.ACCOUNT_LINK_ANALYTICS_DESC]         =
        "Sincroniza solo datos analíticos entre las dos cuentas manualmente a través del menú de la cuenta. Cualquiera de las cuentas puede iniciar una sincronización bidireccional en cualquier momento. Nunca se hace automáticamente. Como no se importan personajes, solo sincronizarás con el personaje especificado aquí. Puedes agregar manualmente más alts de la cuenta vinculada desde el menú de la cuenta.",
        ["Sync Analytics"]                        = "Sincronizar Análisis",
        ["Sync Recent Analytics"]                 = "Sincronizar Análisis Recientes",
        [LID.ANALYTICS_PROF_MISMATCH]             =
        "|cFFFF0000CraftScan: Advertencia: Desajuste de profesión de análisis. Ítem: %s. Profesión local: %s. Profesión vinculada: %s.|r",
        [LID.RN_ANALYTICS]                        = "Análisis",
        [LID.RN_ANALYTICS + 1]                    =
        "CraftScan ahora escanea el chat en busca de cualquier ítem creado combinado con tus palabras clave globales (por ejemplo, LF, recraft, etc.), incluso si no puedes crear el ítem. El tiempo se registra y los ítems detectados se muestran debajo de los pedidos habituales encontrados en el chat.",
        [LID.RN_ANALYTICS + 2]                    =
        "El concepto de 'repeticiones' se utiliza para determinar si un ítem carece de suministro. CraftScan recuerda quién solicitó qué durante la última hora, y si vuelven a solicitar lo mismo, se registra como una repetición. Los encabezados de columna de la nueva cuadrícula tienen tooltips que explican su intención.",
        [LID.RN_ANALYTICS + 3]                    =
        "Con un personaje estacionado en el chat comercial el tiempo suficiente, esto debería construir una buena visión de qué ramas del árbol de profesión valen la pena la inversión.",
        [LID.RN_ANALYTICS + 4]                    =
        "Los análisis se pueden sincronizar entre múltiples cuentas. Puedes estacionar una cuenta de prueba en el comercio todo el día para recopilar datos y luego sincronizarlos con tu cuenta principal. También puedes crear un enlace de cuenta solo para análisis con un amigo, apoyando una sincronización bidireccional que fusiona tus análisis. Una vez que la colección sea grande, hay una opción para sincronizar solo los datos desde la última vez que se sincronizaron las cuentas.",
        [LID.RN_ALERT_ICON_ANCHOR]                = "Actualizaciones de Anclaje de Ícono de Alerta",
        [LID.RN_ALERT_ICON_ANCHOR + 1]            =
        "El ícono de alerta ahora se ocultará correctamente cuando la interfaz de usuario esté oculta. El cambio movió y escaló ligeramente el ícono en mi pantalla. Si el botón se ha movido fuera de tu pantalla debido a esto, hay una opción de reinicio si haces clic derecho en el botón 'Abrir Configuración' en la parte superior derecha de la página de pedidos del chat.",
        [LID.BUSY_RIGHT_NOW]                      = "Modo Ocupado",
        [LID.GREETING_BUSY]                       = "Estoy ocupado ahora, pero puedo fabricarlo más tarde si lo envías.",
        [LID.BUSY_HELP]                           =
        "|cFFFFFFFFCuando se selecciona, agrega la saludo ocupado en tu respuesta. Edita tu saludo ocupado con el botón de abajo.\n\nEsto está destinado a ser utilizado con una segunda cuenta que procura pedidos para que puedas capturar pedidos mientras estás afuera con tu cuenta principal.\n\nSaludo ocupado actual: |cFF00FF00%s|r|r",
        ["Custom Explanations"]                   = "Explicaciones Personalizadas",
        ["Create"]                                = "Crear",
        ["Modify"]                                = "Modificar",
        ["Delete"]                                = "Eliminar",
        [LID.EXPLANATION_LABEL_DESC]              =
        "Ingresa una etiqueta que verás al hacer clic derecho en el nombre del cliente en el chat.",
        [LID.EXPLANATION_DUPLICATE_LABEL]         = "Esta etiqueta ya está en uso.",
        [LID.EXPLANATION_TEXT_DESC]               =
        "Ingresa un mensaje para enviar al cliente cuando se haga clic en la etiqueta. Las nuevas líneas se envían como mensajes separados. Las líneas largas se dividen para ajustarse a la longitud máxima del mensaje.",
        ["Create an Explanation"]                 = "Crear una Explicación",
        ["Save"]                                  = "Guardar",
        ["Reset"]                                 = "Restablecer",
        [LID.MANUAL_MATCHING_TITLE]               = "Coincidencia Manual",
        [LID.MANUAL_MATCH]                        = "%s - %s", -- creador, profesión
        [LID.MANUAL_MATCHING_DESC]                =
        "Ignora palabras clave primarias y fuerza una coincidencia para este mensaje. CraftScan intentará encontrar el creador correcto basado en el mensaje, pero si no se encuentran coincidencias, se utilizará el saludo predeterminado para el creador especificado. La coincidencia se informa a través de los medios habituales, permitiéndote hacer clic en el banner o en la fila de la tabla para enviar el saludo.",

        [LID.RN_MANUAL_MATCH]                     = "Coincidencia Manual",
        [LID.RN_MANUAL_MATCH + 1]                 =
        "El menú contextual al hacer clic derecho en un nombre de jugador en el chat ahora incluye opciones de CraftScan.",
        [LID.RN_MANUAL_MATCH + 2]                 =
        "Este menú incluye todos tus creadores y profesiones. Hacer clic en uno de estos forzará otro paso en el mensaje para buscar una coincidencia sin considerar las 'Palabras Clave Primarias' (por ejemplo, LF, WTB, recraft, etc.), en caso de que el cliente esté utilizando terminología no estándar.",
        [LID.RN_MANUAL_MATCH + 3]                 =
        "Si el mensaje aún no coincide, se forzará una coincidencia con el saludo predeterminado para el creador y la profesión que seleccionaste.",
        [LID.RN_MANUAL_MATCH + 4]                 =
        "Este clic no enviará automáticamente un mensaje al cliente. Genera la coincidencia de la manera habitual, y luego puedes inspeccionar la respuesta generada y decidir si deseas enviarla o no.",
        [LID.RN_MANUAL_MATCH + 5]                 = "(Lo siento, no hay aprendizaje automático.)",
        [LID.RN_CUSTOM_EXPLANATIONS]              = "Explicaciones Personalizadas",
        [LID.RN_CUSTOM_EXPLANATIONS + 1]          =
        "La página 'Pedidos de Chat' ahora incluye un botón de 'Explicaciones Personalizadas'. Las explicaciones configuradas aquí también aparecen en el menú contextual del chat, y hacer clic en ellas enviará inmediatamente la explicación.",
        [LID.RN_CUSTOM_EXPLANATIONS + 2]          =
        "Las explicaciones se ordenan alfabéticamente, por lo que puedes numerarlas para forzar un orden deseado.",
        [LID.RN_BUSY_MODE]                        = "Modo Ocupado",
        [LID.RN_BUSY_MODE + 1]                    =
        "Esto ha estado presente durante algunas versiones, pero nunca se explicó. Hay una nueva casilla de verificación 'Modo Ocupado' en la página 'Pedidos de Chat'. Cuando se activa, agrega el saludo ocupado en tu respuesta. Edita tu saludo ocupado con el botón 'Personalizar Saludo'.",
        [LID.RN_BUSY_MODE + 2]                    =
        "Esto está destinado a ser utilizado con una segunda cuenta que proxy pedidos para que puedas recibir pedidos mientras estás fuera con tu cuenta principal, y el cliente sabrá que no puedes fabricarlo de inmediato.",
        ["Release Notes"]                         = "Notas de la Versión",
        ["Secondary Keywords"]                    = "Palabras clave secundarias",
        [LID.SECONDARY_KEYWORD_INSTRUCTIONS]      =
        "Por ejemplo: 'pvp, 610, algari' o '606, 610, 636' o '590', para diferenciar la misma palabra clave en varios objetos.",
        [LID.HELP_ITEM_SECONDARY_KEYWORDS]        =
        "Después de coincidir con una palabra clave anterior, busca palabras clave secundarias para refinar la coincidencia, permitiendo diferenciar las varias artesanías del mismo tipo de objeto.",
        [LID.RN_SECONDARY_KEYWORDS]               = "Palabras clave secundarias",
        [LID.RN_SECONDARY_KEYWORDS + 1]           =
        "Ahora los objetos admiten palabras clave secundarias para refinar una coincidencia. Cada tipo de objeto generalmente tiene una versión de Chispa, PVP y Azul. Las palabras clave secundarias pueden configurarse para diferenciarlas.",
        [LID.RN_SECONDARY_KEYWORDS + 2]           = "Ejemplo de palabras clave secundarias:",
        [LID.RN_SECONDARY_KEYWORDS + 3]           = "606, 619, 636",
        [LID.RN_SECONDARY_KEYWORDS + 4]           = "610, pvp, algari",
        [LID.RN_SECONDARY_KEYWORDS + 5]           = "590",
        ["Find Crafter"]                          = "Encontrar Artesano",
        ["No Crafters Found"]                     = "No se encontraron artesanos",
        [LID.FOUND_CRAFTER_NAME_ENTRY]            = "%s [%s]",
        [LID.GREET_FOUND_CRAFTER]                 = "|cffffd100Clic izquierdo: Solicitar fabricación|r",
        ["Crafter Greeting"]                      = "|cFFFFFFFFSaludo del artesano|r",
        [LID.BUSY_ICON]                           =
        "|cFFFFFFFFEl artesano ha indicado que está ocupado, pero puede fabricar el objeto más tarde.\n\nVerifica su saludo para más detalles.|r",
        ["Potential Crafters"]                    = "Artesanos potenciales",
        [LID.FOUND_VIA_CRAFT_SCAN]                =
        "Te encontré a través de CraftScan y vi tu saludo. ¿Puedes fabricar %s para mí ahora?",
        [LID.COMMISSION_INSTRUCTIONS]             =
        "Ej. '10000g', Predeterminado: 'Cualquiera'\nEste texto aparece en la tabla 'Encontrar artesano' del cliente.",
        ["Commission"]                            = "Comisión",
        ["Crafter [Currently Playing]"]           = "Artesano [Actualmente jugando]",
        ["Profession commission"]                 = "Comisión de profesión",
        [LID.DEFAULT_COMMISSION]                  = "Cualquiera",
        [LID.HELP_ITEM_COMMISSION]                =
        "CraftScan ofrece a los clientes un botón de 'Encontrar artesano' en órdenes personales. Tu nombre, saludo y esta comisión aparecerán en la tabla junto con otros artesanos. La longitud está limitada a 12 caracteres para ajustarse en la tabla del cliente.",
        ["Discoverable"]                          = "Visible para los clientes",
        [LID.DISCOVERABLE_SETTING]                =
        "Cuando está activado, cuando un cliente pulsa 'Encontrar artesano', tu nombre aparecerá en la tabla generada si puedes fabricar el objeto.",
        [LID.RN_CUSTOMER_SEARCH]                  = "Encontrar artesano",
        [LID.RN_CUSTOMER_SEARCH + 1]              =
        "La página para enviar una orden personal ahora tiene un botón de 'Encontrar artesano'. Este botón envía una solicitud a todos los usuarios de CraftScan para ver quién puede fabricar el objeto y presenta los resultados en una tabla con la comisión configurada del artesano.",
        [LID.RN_CUSTOMER_SEARCH + 2]              =
        "Cada profesión y objeto ahora tiene un cuadro de 'Comisión' para configurar lo que se mostrará en esta tabla, y el texto está limitado a 12 caracteres para caber en la tabla.",
        [LID.RN_CUSTOMER_SEARCH + 3]              =
        "Te has unido al canal 'CraftScan', pero no necesitas activarlo ni ver mensajes en el canal. Existe para permitir que CraftScan envíe solicitudes privadas como normalmente se hace en el chat de Comercio.",
        [LID.RN_CUSTOMER_SEARCH + 4]              =
        "Como artesano, ahora podrías recibir susurros no solicitados de clientes que ya saben lo que puedes fabricar.",
        [LID.RN_CUSTOMER_SEARCH + 5]              =
        "Este es un poco difícil de probar ya que las cuentas de prueba no tienen acceso a la tabla de fabricación. Si encuentras algún problema, puedes desactivar la función hasta que pueda solucionarlo.",
        [LID.RN_CUSTOMER_SEARCH + 6]              =
        "Puedes optar por no estar incluido en esta tabla a través de la nueva configuración de 'Visible' en el menú principal de configuración de Blizzard.",
        [LID.RN_CUSTOMER_SEARCH + 7]              =
        "Dado que los clientes podrían empezar a usar el addon, la función de Análisis se puede desactivar por completo, y ahora está desactivada por defecto. Si ya has recopilado datos, seguirá habilitada.",
        ["Permissive keyword matching"]           = "Coincidencia permisiva de palabras clave",
        [LID.PERMISSIVE_MATCH_SETTING]            =
        "Cuando está activada, CraftScan dejará de preocuparse por los espacios y otros delimitadores al buscar coincidencias de palabras clave. Por defecto, CraftScan solo coincidirá con una palabra clave si está claramente delimitada del texto circundante para evitar coincidencias incorrectas de palabras clave cortas incrustadas en otras palabras. Para los idiomas que no usan espacios para delimitar palabras clave, active esta opción.",
        ["Show chat orders tab"]                  = "Mostrar pestaña de órdenes del chat",
        [LID.SHOW_CHAT_ORDER_TAB]                 =
        "Muestra u oculta la pestaña 'Órdenes del Chat' en la ventana de profesiones. Si está oculta, puedes abrirla haciendo clic en el botón CraftScan donde aparecen las alertas.",
        [LID.IGNORE]                              = "Ignorar",
        [LID.IGNORE_TOOLTIP]                      =
        "Añade a este jugador a tu lista de ignorados en CraftScan. CraftScan ignorará todos los mensajes de este jugador. Este menú permite quitar al jugador de la lista.",
        [LID.UNIGNORE]                            = "Quitar de ignorados",
        [LID.UNIGNORE_TOOLTIP]                    =
        "Este jugador está en tu lista de ignorados de CraftScan. Esta opción lo quitará de la lista.",
        ["Collapse chat context menu"]            = "Colapsar menú contextual del chat",
        [LID.COLLAPSE_CHAT_CONTEXT_TOOLTIP]       =
        "Al hacer clic derecho en el nombre de un jugador en el chat, colapsa todas las opciones del menú contextual en un submenú único de CraftScan.",

        [LID.PROXY_ORDERS_TOOLTIP]                =
        "Envía los pedidos detectados por esta cuenta a cuentas vinculadas con permisos de 'Control Total'. La cuenta receptora mostrará la notificación habitual como si hubiera detectado el pedido.",
        [LID.RECEIVE_PROXY_ORDERS_TOOLTIP]        =
        "Recibe pedidos detectados y enviados por una cuenta vinculada con 'Control Total'. Cuando se recibe un pedido de la cuenta vinculada, aparecerá la notificación habitual en esta cuenta.",
        [LID.LOCAL_ALERTS_TOOLTIP]                =
        "Las notificaciones visuales y sonoras sobre este artesano y profesión solo se mostrarán cuando estés jugando con este personaje. Esto es solo un filtro y no activa ni desactiva las notificaciones en general. Las notificaciones siguen gestionándose mediante los iconos de misión y auriculares en el lado derecho de la lista de artesanos.",
        ["Local Notifications Only"]              = "Solo notificaciones locales",

    }
end
