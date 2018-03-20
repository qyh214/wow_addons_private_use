-- Translate RCLootCouncil to your language at:
-- http://wow.curseforge.com/addons/rclootcouncil/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("RCLootCouncil", "esES")
if not L then return end

L[" is not active in this raid."] = "no está activo en esta banda."
L[" you are now the Master Looter and RCLootCouncil is now handling looting."] = "A partir de ahora eres el Maestro Despojador y RCLootCouncil maneja el reparto."
L["&p was awarded with &i for &r!"] = "&p fue premiado con &i por &r!"
L["2 Piece"] = "2ª Pieza"
L["2nd Tier Piece"] = "Segundo bonus de tier"
L["4 Piece"] = "4ª pieza"
L["4th Tier Piece"] = "4 bonus de tier"
L["A format to copy/paste to another player."] = "Establece un formato para copiar/pegar a otro jugador."
L["A new session has begun, type '/rc open' to open the voting frame."] = "Una nueva sesion ha comenzado, escriba '/rc open' para abrir ventana de votación"
L["A tab delimited output for Excel. Might work with other spreadsheets."] = "Un tabulador delimita una salida de Excel. Es posible que funcione con otra hoja de cálculo."
L["Abort"] = "Cancelar"
L["Accept Whispers"] = "Aceptar Susurros"
L["accept_whispers_desc"] = "Permite a los jugadores susurrar su(s) objeto(s) actual (s) para que puedan tenerse en cuenta en la votación."
L["Active"] = "Activar"
L["active_desc"] = "Desactive la opcion para desactivar RCLootCouncil. Esto es útil si estas en un grupo de banda, pero no participas en el reparto de botín. Nota: Esto se restablece cada cierre de sesión."
L["Add Item"] = "Añadir un objeto"
L["Add Note"] = "Añadir una nota"
L["Add ranks"] = "Agregar Rangos"
L["Add rolls"] = "Agregar Especializacion"
--Translation missing 
-- L["Add Rolls"] = ""
L["add_ranks_desc"] = "Seleccionar una rango mínimo para poder usar el lootcouncil:"
L["add_ranks_desc2"] = [=[Seleccione el rango de mayor categoría para añadir a todos los miembros en ese y por encima del mismo al consejo.

Clic en los rangos de la izquierda para añadir jugadores individualmente al consejo.

Clic en la ventana 'Consejo actual' para ver su selección.]=]
--Translation missing 
-- L["add_rolls_desc"] = ""
L["All items"] = "Todos los objetos"
L["All items has been awarded and  the loot session concluded"] = "Todos los objetos han sido repartidos y la sesion del reparto ha finalizado"
--Translation missing 
-- L["All items usable by the candidate"] = ""
--Translation missing 
-- L["All unawarded items"] = ""
L["Alt click Looting"] = "Pulsar ALT para Repartir"
L["alt_click_looting_desc"] = "Activar el clic de ALT para repartir el loot, es decir, se inicia una sesión de reparto del loot manteniendo pulsada la tecla Alt (izquierdo) y haciendo clic en un objeto."
L["Alternatively, flag the loot as award later."] = "Alternativamente, marcar el loot para premiar más tarde."
L["Always use RCLootCouncil when I'm Master Looter"] = "Utilizar siempre RCLootCouncil cuando soy el Maestro Despojador"
L["Always use when leader"] = "Utilizar siempre cuando sea el lider"
--Translation missing 
-- L["always_show_tooltip_howto"] = ""
L["Announce Awards"] = "Anunciar premios"
L["Announce Considerations"] = "Anunciar consideraciones"
--Translation missing 
-- L["announce_&i_desc"] = ""
--Translation missing 
-- L["announce_&l_desc"] = ""
--Translation missing 
-- L["announce_&n_desc"] = ""
--Translation missing 
-- L["announce_&p_desc"] = ""
--Translation missing 
-- L["announce_&r_desc"] = ""
--Translation missing 
-- L["announce_&s_desc"] = ""
--Translation missing 
-- L["announce_&t_desc"] = ""
L["announce_awards_desc"] = "Activar los anuncios de los premios en el chat"
L["announce_awards_desc2"] = "Elija que canal(s) deseas para anunciar junto con el texto. Usar &p para el nombre del jugador que consigue el botín, &i para el objeto adjudicado y &r para la razón."
L["announce_considerations_desc"] = "Activar los anuncios de los objetos bajo consideración cada vez que se inicia una sesión."
L["announce_considerations_desc2"] = [=[Selecciona el canal que deseas para anunciar y el mensaje.
Su mensaje sirve de cabecera para la lista de objetos.]=]
L["announce_item_string_desc"] = "Introduzca el texto que se anunciara por cada objeto. Las siguientes sustitutos de palabras están disponibles."
L["Announcements"] = "Anuncios"
L["Anonymous Voting"] = "Votación Anónima"
L["anonymous_voting_desc"] = "Habilitar la votación anónima, es decir, nadie puede ver quien vota por quien"
L["Append realm names"] = "Adjuntar nombres del reino"
L["Are you sure you want to abort?"] = "¿Estás seguro que deseas cancelar?"
L["Are you sure you want to give #item to #player?"] = "¿Estás seguro que quieres darle %s a %s?"
--Translation missing 
-- L["Are you sure you want to reannounce all unawarded items to %s?"] = ""
--Translation missing 
-- L["Are you sure you want to request rolls for all unawarded items from %s?"] = ""
L["Armor Token"] = "Ficha de armadura"
L["Ask me every time I become Master Looter"] = "Preguntarme cada vez que me convierta en Maestro Despojador"
L["Ask me when leader"] = "Preguntarme cuando sea el lider"
L["Auto Award"] = "Recompensa automática"
L["Auto Award to"] = "Recompensar automáticamente a"
L["Auto awarded 'item'"] = "Auto entregar %s"
L["Auto Close"] = "Cerrar automaticamente"
L["Auto Enable"] = "Habilitar automaticamente"
L["Auto extracted from whisper"] = "Auto extraer desde un susurro"
L["Auto Open"] = "Abrir automaticamente"
L["Auto Pass"] = "Auto pasar"
L["Auto pass BoE"] = "Auto entregar BoE"
L["Auto Pass Trinkets"] = "Auto pasar abalorios."
L["Auto Start"] = "Inicio automatico"
L["auto_award_desc"] = "Activa Recompensa Automatica."
L["auto_award_to_desc"] = "El jugador a recompensar automaticamente. Una lista seleccionable de miembros de la raid aparece si se está en un grupo de raid."
L["auto_close_desc"] = "marca la casilla para cerrar la ventana de votación cuando el Maestro despojador termine la sesión"
L["auto_enable_desc"] = "Compruebe siempre dejar RCLootCouncil marcado botin. Desmarcando hara que el addon pregunte si desea utilizar cada vez que entra en una banda o convertirse en maestro saqueador."
L["auto_loot_desc"] = "Permite autorepartir  todos los articulos que se ligan al equipar"
L["auto_open_desc"] = "Compruebe en abre automaticamente el marco de la votacion cuando este disponible. El marco de la votacion de lo contrario se puede abrir con /rc open. Nota: Esto requiere el permiso del maestro despojador."
L["auto_pass_boe_desc"] = "Desmarcar No Permite autorepartir los articulos que se ligan al equipar"
L["auto_pass_desc"] = "Marque para activar autopasar de articulos que su clase no puede usar."
--Translation missing 
-- L["auto_pass_trinket_desc"] = ""
L["auto_start_desc"] = "Permite el Auto iniciar, es decir, iniciar una sesion con todos los articulos elegibles. La desactivacion mostrara una lista de elementos editable antes de iniciar una sesion."
--Translation missing 
-- L["Autoloot all BoE"] = ""
L["Autoloot BoE"] = "Botin automatico BoE"
L["autoloot_BoE_desc"] = "Activa auto reparto de botin del mundo ( BoE )"
--Translation missing 
-- L["autoloot_others_BoE_desc"] = ""
L["autoloot_others_item_combat"] = "%s ha conseguido %s. Este objetos sera añadido al cuadro de sesion una vez el combate termine."
L["Autopass"] = "Pasar Automaticamente"
L["Autopassed on 'item'"] = "Auto pasar de %s"
L["Autostart isn't supported when testing"] = "Inicio automatico no se admite cuando se prueba"
L["award"] = "premio"
L["Award"] = "Premio"
L["Award Announcement"] = "Anunciar premio"
L["Award for ..."] = "Premio para ..."
L["Award later"] = "Recompensar mas tarde"
L["Award later isn't supported when testing."] = "Recompensar mas tarde no esta disponible mientras esta en prueba"
L["Award later?"] = "Premiar despues"
L["Award Reasons"] = "Motivos de la Recompensa"
L["award_reasons_desc"] = [=[Motivos de recompensa que no pueden ser elegidos en un sorteo.
Se usa al cambiar una respuesta con el menu del clic derecho y con Recompensa Automatica.]=]
--Translation missing 
-- L["Awarded"] = ""
--Translation missing 
-- L["Awarded item cannot be awarded later."] = ""
L["Awards"] = "Recompensas"
L["Background"] = "Fondo"
L["Background Color"] = "Color de fondo"
L["Banking"] = "Banco"
L["BBCode export, tailored for SMF."] = "Exportar en BBCode, hecho para SMF."
L["Border"] = "Borde"
L["Border Color"] = "Color del borde"
L["Button"] = "Boton"
L["Buttons and Responses"] = "Boton de respuesta"
L["buttons_and_responses_desc"] = [=[Configurar los botones de respuesta para mostrar en pantalla el botin de banda
El orden que mostrara determina el orden,para ordenar la estructura de votacion, y se muestra de izquierda a derecha en el marco de botin - utilizar el control deslizante para elegir el numero de botones que desee (max %d).
Se agrega el boton de "Pasar" mas a la derecha de forma automatica
]=]
L["Candidate didn't respond on time"] = "El candidato no ha respondido a tiempo"
L["Candidate has disabled RCLootCouncil"] = "Candidato ha deshabilitado RCLootCouncil"
L["Candidate is not in the instance"] = "El candidato no se encuentra en la instancia"
L["Candidate is selecting response, please wait"] = "El candidato esta eligiendo su respuesta, por favor, espere."
L["Candidate removed"] = "Candidato eliminado."
L["Candidates that can't use the item"] = "El candidato que no pueden usar el objeto."
L["Cannot autoaward:"] = "No puede premiar automaticamente"
L["Cannot give 'item' to 'player' due to Blizzard limitations. Gave it to you for distribution."] = "No se puede dar a %s de %s debido a las limitaciones de Blizzard.recoger para distribuir"
--Translation missing 
-- L["Change Award"] = ""
L["Change Response"] = "Cambiar respuesta"
L["Changing loot threshold to enable Auto Awarding"] = "Cambiando el modo de saqueo, para habilitar Recompensa Automatica"
L["Changing LootMethod to Master Looting"] = "Cambiando Metodo de Saqueo a Maestro Despojador"
L["channel_desc"] = "El canal para enviar el mensaje."
L["chat tVersion string"] = "|cFF87CEFARCLootCouncil |cFFFFFFFFversion |cFFFFA500 %s - %s"
L["chat version String"] = "|cFF87CEFARCLootCouncil |cFFFFFFFFversion |cFFFFA500 %s"
L["chat_commands_add"] = "Añade un objeto al cuadro de sesion"
L["chat_commands_award"] = "Empieza una sesion con los objetos conseguidos en tu inventario."
L["chat_commands_config"] = "Abre las opciones de interfaz"
--Translation missing 
-- L["chat_commands_council"] = ""
L["chat_commands_history"] = "Abre el cuadro de historial (alt. 'h' o 'his')"
L["chat_commands_open"] = "Abre el cuadro de votacion"
--Translation missing 
-- L["chat_commands_reset"] = ""
--Translation missing 
-- L["chat_commands_sync"] = ""
--Translation missing 
-- L["chat_commands_test"] = ""
--Translation missing 
-- L["chat_commands_version"] = ""
--Translation missing 
-- L["chat_commands_whisper"] = ""
--Translation missing 
-- L["chat_commands_winners"] = ""
L["Check this to loot the items and distribute them later."] = "Marque esta para recojer los articulos y distribuirlos despues."
L["Check to append the realmname of a player from another realm"] = "marca la casilla para ajunta el nombre del reino al que el jugador pertenece"
L["Check to have all frames minimize when entering combat"] = "Compruebe que todas las ventanas se minimizan al entrar en combate"
L["Choose timeout length in seconds"] = "Elige el tiempo de espera en segundos"
L["Choose when to use RCLootCouncil"] = "Elejir cuando usar RCLootCouncil"
L["Clear Loot History"] = "Limpiar Historial de botin"
L["Clear Selection"] = "Borrar selección"
L["clear_loot_history_desc"] = "Eliminar historial de botin"
L["Click to add note to send to the council."] = "Haga clic para agregar nota para enviar al consejo."
L["Click to change your note."] = "Click para cambiar la nota"
L["Click to expand/collapse more info"] = "Hacer clic para abrir / cerrar mas info"
L["Click to switch to 'item'"] = "Haga clic para cambiar a %s"
L["config"] = "Configurar"
--Translation missing 
-- L["confirm_award_later_text"] = ""
L["confirm_usage_text"] = [=[|cFF87CEFA RCLootCouncil |r

¿Te gustaría usar RCLootCouncil con este grupo?]=]
--Translation missing 
-- L["Conqueror Token"] = ""
L["Could not Auto Award i because the Loot Threshold is too high!"] = "No se pudo Autopremiar %s debido a que el limite de botin es demasiado alto!"
L["Could not find 'player' in the group."] = "No se pudo encontrar a %s en el grupo"
L["Couldn't find any councilmembers in the group"] = "No se pudo encontrar ningún miembro del concilio en el grupo"
L["council"] = "Consejo"
L["Council"] = "Consejo"
L["Current Council"] = "Consejo actual"
L["current_council_desc"] = "Haga clic para eliminar ciertas personas del consejo"
L["Customize appearance"] = "Personalizar apariencia"
L["customize_appearance_desc"] = "Aquí podrás personalizar completamente la apariencia de RCLootCouncil. Usa la función de guardado mas arriba para cambiar de apariencia rapidamente."
--Translation missing 
-- L["Data Received"] = ""
L["Date"] = "Fecha"
L["days and x months"] = "%s y %d meses"
L["days, x months, y years"] = "%s, %d meses y %d años"
L["Delete Skin"] = "Borrar apariencia"
L["delete_skin_desc"] = "Borrar la apariencia seleccionada (que no sea por defecto) de la lista."
L["Deselect responses to filter them"] = "Anule la seleccion de respuestas para filtrarlas"
L["Diff"] = "Diferente"
L["disenchant_desc"] = "Seleccionar para usar esta razon en la adjudicacion de un elemento a traves del boton 'Desencantar'"
L["Done syncing"] = "Sincronización completa"
L["Double click to delete this entry."] = "Doble click para borrar esta entrada."
L["Dropped by:"] = "Despojado de"
L["Edit Entry"] = "Editar entrada"
L["Enable Loot History"] = "Activar historial de botin"
L["Enable Relic Buttons"] = "Activar los botones de reliquias"
L["Enable Tier Buttons"] = "Activar los botones del tier"
L["Enable Timeout"] = "Habilitar tiempo de espera"
L["enable_loot_history_desc"] = "Activado el historial. RCLootCouncil no registrara nada si esta deshabilitado."
L["enable_relicbuttons_desc"] = "Marca para activar un conjunto de botones separados cuando se tiren por las reliquias"
L["enable_tierbuttons_desc"] = "Marca para activar un conjunto de botones separados cuando se tiren por las piezas de tier"
L["enable_timeout_desc"] = "Marca la casilla para habilitar tiempo maximo en la ventana de Loot"
L["Enter your note:"] = "Escribe tu nota"
L["EQdkp-Plus XML output, tailored for Enjin import."] = "Exportar para EQdkp-Plus XML, hecho para importar en Enjin."
L["Everyone have voted"] = "Todos han votado"
L["Export"] = "Exportar"
L["Following items were registered in the award later list:"] = "Los siguientes objetos no están registrados en la lista de recompensar mas tarde"
L["Following winners was registered:"] = "El seguimiento de los ganadores fue regristrado"
L["Frame options"] = "Cuadro de opciones"
L["Free"] = "Gratis"
L["g1"] = true
L["g2"] = true
--Translation missing 
-- L["Gave the item to you for distribution."] = ""
L["General options"] = "opciones generales"
L["Group Council Members"] = "Grupo de mienbros del consejo"
L["group_council_members_desc"] = "Utilice esta opcion para agregar los miembros del consejo de otro reino o de otra hermandad"
L["group_council_members_head"] = "Agregar al consejo los miembros de su actual grupo"
L["Guild Council Members"] = "Mienbos de hermandad en el consejo"
L["Hide Votes"] = "Ocultar Votos"
L["hide_votes_desc"] = "Oculta el numero de votos hasta que se haya votado."
L["How to sync"] = "Como sincronizar"
--Translation missing 
-- L["huge_export_desc"] = ""
L["Ignore List"] = "Ignorar lista"
L["Ignore Options"] = "Ignorar Opciones"
L["ignore_input_desc"] = "Introduzca la ID de un objeto para añadirlo a lista de ignorados, RCLootCouncil nunca incluira el objeto a un reparto de botin"
L["ignore_input_usage"] = "Esta funcion solo acepta ItemIDs (numero identificador del objeto)"
L["ignore_list_desc"] = "Articulo esta siendo ignorado por RCLootCouncil.Haga clic en un elemento para eliminarlo."
L["ignore_options_desc"] = "Control de los objetos que RCLootCouncil debe ignorar. Si se agrega un objeto que no se almacena en cache, es necesario cambiar a otra ventana y regresar a la misma para que lo vea en la lista."
L["import_desc"] = "Pega los datos aqui. Solo se mostraran los primeros 2500 caracteres para evitar que el juego se congele"
L["Item"] = "Objeto"
--Translation missing 
-- L["'Item' is added to the award later list."] = ""
--Translation missing 
-- L["Item quality is below the loot threshold"] = ""
L["Item received and added from 'player'"] = "Articulo recibido y agregado desde %s."
--Translation missing 
-- L["Item was awarded to"] = ""
L["Item(s) replaced:"] = "Objeto/s sustituidos:"
--Translation missing 
-- L["item_in_bags_low_trade_time_remaining_reminder"] = ""
--Translation missing 
-- L["Items stored in the loot master's bag for award later cannot be awarded later."] = ""
L["Items under consideration:"] = "Objetos en consideracion:"
L["Latest item(s) won"] = "Ultimo(s) objeto(s) repartidos"
L["leaderUsage_desc"] = "Usar la misma configuración cuando se entra en una instancia como líder?"
L["Length"] = "Duración"
L["Log"] = "Registro"
L["log_desc"] = "Permite incluir botin en el historial"
L["Loot announced, waiting for answer"] = "Botin anunciado, esperando respuesta"
L["Loot Everything"] = "Todo el botin"
L["Loot History"] = "Hitorial de botin"
L["Loot won:"] = "objetos ganados:"
L["loot_everything_desc"] = "Activar auto botin de no equipo ( monturas,mascotas,etc)"
L["loot_history_desc"] = [=[RCLootCouncil registra automaticamente informacion relevante de sesiones.
Los datos se almacena en "... / SavedVariables/RCLootCouncil.lua".

Nota: Los NO Maestros despojadores pueden guardar solo datos que el el Maestro despojador a mostrado]=]
L["Looting options"] = "Opciones de botin"
L["Lower Quality Limit"] = "Limite Inferior de Calidad"
L["lower_quality_limit_desc"] = [=[Seleccionar la calidad mas baja de los objetos a repartir automaticamente (calidad seleccionada incluida).
Nota: Esto sobreescribe el umbral normal de saqueo.]=]
L["Mainspec/Need"] = "Especializacion principal / Necesidad"
L["Master Looter"] = "Maestro de botin"
L["master_looter_desc"] = "Nota: Estos ajustes solo se utilizaran cuando eres el maestro despojador."
L["Message"] = "Mensaje"
L["Message for each item"] = "Mensaje para cada objeto"
L["message_desc"] = "El mensaje a enviar al canal seleccionado."
L["Minimize in combat"] = "Minimizar en combate"
L["Minor Upgrade"] = "Mejora Menor"
L["ML sees voting"] = "MS ve la votacion"
L["ml_sees_voting_desc"] = "Permitir al Maestro Despojador ver quien vota por quien."
--Translation missing 
-- L["module_tVersion_outdated_msg"] = ""
--Translation missing 
-- L["module_version_outdated_msg"] = ""
L["Modules"] = "Modulos"
L["More Info"] = "Más información"
L["more_info_desc"] = "Selecciona de cuántas de tus respuestas quieres ver los últimos objetos repartidos. Por ejemplo, seleccionando 2 (con las opciones por defecto) mostrará los últimos objetos de Especialización Principal y Especialización secundaria, junto con hace cuánto se repartieron."
L["Multi Vote"] = "Multi Voto"
L["multi_vote_desc"] = "Habilita votacion multiple, es decir, los votantes pueden votar a varios candidatos."
L["'n days' ago"] = "hace %s dias"
L["Never use RCLootCouncil"] = "No usar RCLootCouncil"
--Translation missing 
-- L["new_ml_bagged_items_reminder"] = ""
L["No (dis)enchanters found"] = "No (dis) encantadores encontrados"
L["No entries in the Loot History"] = "no hay entradas en el historial"
--Translation missing 
-- L["No entry in the award later list is removed."] = ""
L["No items to award later registered"] = "No hay elementos para adjudicar mas tarde registrados"
--Translation missing 
-- L["No recipients available"] = ""
L["No session running"] = "Ninguna sesion iniciada"
L["No winners registered"] = "No hay ganadores registrados"
L["Not announced"] = "No anunciado"
L["Not cached, please reopen."] = "Nada en cache,por favor vuelva a abrir."
L["Not Found"] = "No encontrado"
L["Not in your guild"] = "No esta en tu hermandad"
L["Not installed"] = "No instalado"
L["Notes"] = "Notas"
L["notes_desc"] = "Posibilita a los candidatos enviar una nota al consejo junto con su tirada."
L["Now handles looting"] = "Maneja el loot desde ahora"
L["Number of buttons"] = "Numero de botones"
--Translation missing 
-- L["Number of raids received loot from:"] = ""
L["Number of reasons"] = "Numero de Motivos"
L["Number of responses"] = "Cantidad de respuestas"
L["number_of_buttons_desc"] = "Desplazar para cambiar el numero de botones."
L["number_of_reasons_desc"] = "Arrastrar para cambiar el número de motivos."
L["Observe"] = "observar"
L["observe_desc"] = "Si se activa, los miembros del consejo no podran ver el marco de la votacion como un miembro normal consejo. No se les permite votar"
L["Offline or RCLootCouncil not installed"] = "Desconectado o RCLootCouncil no instalado"
L["Offspec/Greed"] = "Especializacion secundaria / Codicia"
L["Only use in raids"] = "Sólo usar en bandas"
L["onlyUseInRaids_desc"] = "Marcar para automáticamente desactivar RCLootCouncil en grupos que no sean de banda."
L["open"] = "Abrir"
L["Open the Loot History"] = "Abrir Hitorial de botin"
L["open_the_loot_history_desc"] = "Pulsar para abrir historial de botin"
L["Opens the synchronizer"] = "Abrir el sincronizador"
L["Other piece"] = "Otra pieza"
L["'player' can't receive 'type'"] = "%s no puede recibir %s - version anterior"
--Translation missing 
-- L["'player' declined your sync request"] = ""
L["'player' has asked you to reroll"] = "%s te ha pedido que vuelvas a tirar dados"
L["'player' has ended the session"] = "%s Ha terminado la sesion"
--Translation missing 
-- L["'player' has rolled 'roll' for: 'item'"] = ""
--Translation missing 
-- L["'player' hasn't opened the sync window"] = ""
L["Player is not in the group"] = "El jugador no esta en el grupo"
L["Player is not in this instance or his inventory is full"] = "El jugador no esta en la estancia o su inventario esta lleno"
--Translation missing 
-- L["Player is not in this instance or is ineligible for this item"] = ""
L["Player is offline"] = "El jugador esta desconectado"
L["Please wait a few seconds until all data has been synchronized."] = "Por favor espera unos segundos antes de que todos los datos sean sincronizados"
--Translation missing 
-- L["Please wait before trying to sync again."] = ""
--Translation missing 
-- L["Print Responses"] = ""
--Translation missing 
-- L["print_response_desc"] = ""
--Translation missing 
-- L["Protector Token"] = ""
L["Raw lua output. Doesn't work well with date selection."] = "Exportar en lua bruto. No funciona bien junto a selección por fecha."
--Translation missing 
-- L["RCLootCouncil - Synchronizer"] = ""
L["RCLootCouncil Loot Frame"] = "Ventana de botin RCLootCouncil"
L["RCLootCouncil Loot History"] = "Historial de RCLootCouncil"
L["RCLootCouncil Session Setup"] = "Configuracion de sesion RCLootCouncil "
L["RCLootCouncil Version Checker"] = "Comprobar version RCLootCouncil"
L["RCLootCouncil Voting Frame"] = "Ventara de votacion RCLootCouncil"
--Translation missing 
-- L["rclootcouncil_trade_add_item_confirm"] = ""
L["Reannounce ..."] = "Volver anunciar"
--Translation missing 
-- L["Reannounced 'item' to 'target'"] = ""
L["Reason"] = "Motivo"
L["reason_desc"] = "El motivo de la recompensa a añadir al Historial de Saqueo al repartir automaticamente."
--Translation missing 
-- L["Relic Buttons and Responses"] = ""
--Translation missing 
-- L["relic_buttons_desc"] = ""
L["Remove All"] = "Eliminar todo"
L["Remove from consideration"] = "Eliminar consideracion"
L["remove_all_desc"] = "Eliminar todos los miembros del consejo"
--Translation missing 
-- L["Requested rolls for 'item' from 'target'"] = ""
L["Reset Skin"] = "Reiniciar apariencia"
L["Reset skins"] = "Reiniciar apariencia"
L["reset_announce_to_default_desc"] = "Restablecer todas las opciones de aviso por defecto"
L["reset_buttons_to_default_desc"] = "Restablece todos los botones,los colores y las respuestas a los valores predeterminados"
L["reset_skin_desc"] = "Reinicia todos los colores y fondos de la apariencia actual"
L["reset_skins_desc"] = "Reinicia a la apariencia por defecto."
L["reset_to_default_desc"] = "Reinicia los motivos de la recompensa a por defecto."
L["Response"] = "Responder"
L["Response color"] = "Color de respuesta"
--Translation missing 
-- L["Response isn't available. Please upgrade RCLootCouncil."] = ""
--Translation missing 
-- L["Response options"] = ""
--Translation missing 
-- L["Response to 'item'"] = ""
--Translation missing 
-- L["Response to 'item' acknowledged as 'response'"] = ""
L["response_color_desc"] = "Establecer un color para la respuesta."
--Translation missing 
-- L["Responses"] = ""
L["Responses from Chat"] = "Chat de respuestas"
L["responses_from_chat_desc"] = [=[En caso de que alguien no ha instalado el addon (Boton 1 se utiliza si no se especifica la palabra clave).
Ejemplo:. "/ W ML_NAME [PUNTO] Codicia" seria por defecto y aparecera como usted tira codicia en un objeto 
A continuación puede elegir las palabras clave para los botones individuales, separados por el punto o espacio. Solo se aceptan numeros y palabras.
Los jugadores pueden recibir la lista de palabras clave de mensajería 'rchelp' al Maestro Despojadorr una vez que el complemento se activa (es decir,dentro en una banda).]=]
L["Save Skin"] = "Guardar apariencia"
L["save_skin_desc"] = "Introduce el nombre de la apariencia y presiona Ok para guardarla. Ten en cuenta que puedes sobreescribir cualquier apariencia que no sea por defecto."
L["Self Vote"] = "Voto Propio"
L["self_vote_desc"] = "Permite a los votantes votar por si mismos"
L["Send History"] = "Enviar historia"
L["send_history_desc"] = "Enviar datos a todo el mundo de la banda,sin importar si inicia sesion usted mismo. RCLootCouncil solo enviara datos si usted es el Maestro despojador"
--Translation missing 
-- L["Sending 'type' to 'player'..."] = ""
L["Sent whisper help to 'player'"] = "Susurro ayuda enviada a %s"
L["session_error"] = "Algo salio mal - por favor reinicie la sesion"
--Translation missing 
-- L["session_help_from_bag"] = ""
--Translation missing 
-- L["session_help_not_direct"] = ""
L["Set the text for button i's response."] = "Ajuste el texto para el boton %d respuesta"
L["Set the text on button 'number'"] = "Ajuste el texto en el boton %i"
L["Set the whisper keys for button i."] = "Asigna el boton para susurros a la tecla %d"
--Translation missing 
-- L["Show Spec Icon"] = ""
--Translation missing 
-- L["show_spec_icon_desc"] = ""
L["Silent Auto Pass"] = "Silenciar Auto pasar"
L["silent_auto_pass_desc"] = "Comprobar para ocultar mensajes de Auto pasar"
L["Simple BBCode output."] = "Exportar en BBCode simple."
L["Skins"] = "Apariencias"
L["skins_description"] = "Selecciona una de las apariencias por defecto o crea la tuya. Esto es puramente estético. Abre el comprobador de versión para ver los resultados rápidamente ('/rc version')."
--Translation missing 
-- L["Socket"] = ""
L["Something went wrong :'("] = "Algo salio mal :("
--Translation missing 
-- L["Something went wrong during syncing, please try again."] = ""
--Translation missing 
-- L["Sort Items"] = ""
--Translation missing 
-- L["sort_items_desc"] = ""
L["Standard .csv output."] = "Exportar en .csv estándar."
L["Status texts"] = "Textos de estado"
--Translation missing 
-- L["Store in bag and award later"] = ""
--Translation missing 
-- L["Successfully imported 'number' entries."] = ""
--Translation missing 
-- L["Successfully received 'type' from 'player'"] = ""
--Translation missing 
-- L["Sync"] = ""
--Translation missing 
-- L["sync_detailed_description"] = ""
L["test"] = "Prueba"
L["Test"] = "Prueba"
L["test_desc"] = "Haga clic para emular articulos de botin como Maestro Despojador y para cualquier persona en su banda"
L["Text color"] = "Color de texto"
L["Text for reason #i"] = "Texto de la razon #"
L["text_color_desc"] = "Color del texto cuando se muestra"
--Translation missing 
-- L["The award later list has been cleared."] = ""
--Translation missing 
-- L["The award later list is empty."] = ""
L["The following council members have voted"] = "Los siguientes miembros del concilio han votado"
--Translation missing 
-- L["The following entries are removed from the award later list:"] = ""
--Translation missing 
-- L["The following items are removed from the award later list and traded to 'player'"] = ""
--Translation missing 
-- L["The item can only be looted by you but it is not bind on pick up"] = ""
--Translation missing 
-- L["The item will be awarded later"] = ""
L["The item would now be awarded to 'player'"] = "El objeto ahora se otorga a %s"
L["The loot is already on the list"] = "El botin ya esta en la lista"
--Translation missing 
-- L["The loot master"] = ""
L["The Master Looter doesn't allow multiple votes."] = "El Maestro de Botin no permite multiples votos"
L["The Master Looter doesn't allow votes for yourself."] = "El Mastro de botin no permite votar por si mismo."
L["The session has ended."] = "La sesion ha terminado."
L["This item"] = "Este articulo"
L["This item has been awarded"] = "Este artículo ha sido premiado"
L["Tier 19"] = true
L["Tier 20"] = true
--Translation missing 
-- L["Tier 21"] = ""
--Translation missing 
-- L["Tier Buttons and Responses"] = ""
--Translation missing 
-- L["Tier Piece that doesn't complete a set"] = ""
--Translation missing 
-- L["Tier Tokens ..."] = ""
L["Tier tokens received from here:"] = "Fichas de conjunto recibidas de aquí:"
--Translation missing 
-- L["tier_buttons_desc"] = ""
L["tier_token_heroic"] = "Heroico"
L["tier_token_mythic"] = "Mítico"
L["tier_token_normal"] = "Normal"
L["Time"] = "Tiempo"
L["Timeout"] = "Se acabó el tiempo"
--Translation missing 
-- L["Timeout when giving 'item' to 'player'"] = ""
--Translation missing 
-- L["To target"] = ""
L["Tokens received"] = "Fichas de conjunto recibidas"
L["Total awards"] = "Total de objetos repartidos"
L["Total items received:"] = "objetos recibidos en total:"
L["Total items won:"] = "Total de objetos ganados:"
L["tVersion_outdated_msg"] = "La version de prueba mas reciente de RCLootCouncil es: %s"
--Translation missing 
-- L["Unable to give 'item' to 'player'"] = ""
L["Unable to give 'item' to 'player' - (player offline, left group or instance?)"] = "No entregar a %s de %s - ( Jugador desconectado, Fuera del grupo o banda )"
L["Unable to give out loot without the loot window open."] = "Incapaz de dar a conocer el botin sin abrir ventana de botin"
--Translation missing 
-- L["Unawarded"] = ""
L["Unguilded"] = "Sin Hermandad"
L["Unknown date"] = "Fecha desconocida"
L["Unknown/Chest"] = "Desconocido "
L["Unvote"] = true
--Translation missing 
-- L["Upgrade to existing tier/random upgrade"] = ""
L["Upper Quality Limit"] = "Limite Superior de Calidad"
L["upper_quality_limit_desc"] = [=[Seleccionar la calidad mas alta de los objetos a repartir automaticamente (calidad seleccionada incluida)
Nota: Esto sobrescribe el umbral normal de saqueo.]=]
L["Usage"] = "Uso"
L["Usage Options"] = "Opciones de uso"
--Translation missing 
-- L["Vanquisher Token"] = ""
L["version"] = "Version"
L["Version"] = true
L["Version Check"] = "Comprobar version"
L["version_check_desc"] = "Abrir comprobador de version"
L["version_outdated_msg"] = "Su version de %s no esta actualizada. La versión mas reciente es %s, por favor, actualice RCLootCouncil."
L["Vote"] = "Voto"
L["Voters"] = "Votantes"
L["Votes"] = "Votos"
L["Voting options"] = "Opciones de votacion"
L["Waiting for response"] = "Esperando una respuesta"
L["whisper_guide"] = "[RCLootCouncil]: respuestas de sesiones [item1] [item2]. Enlace su articulo (s) que el articulo # (sesion) reemplazaria, (respuesta) es de las siguientes palabras clave:"
L["whisper_guide2"] = "[RCLootCouncil]: Usted recibira un mensaje de confirmacion si se han añadido correctamente."
L["whisper_help"] = [=[Raiders pueden utilizar el sistema susurro en caso de que alguien no ha instalado el addon.
Susurrando 'rchelp' al Maestro Despojador mostrandote la lista de palabras clave, que puede ser editado en los "Botones y Respuestas 'optiontab.
Se recomienda para el ML para encender 'anuncian Consideraciones' ya que se requiere el numero de cada elemento a utilizar el sistema de susurro.
NOTA: La gente todavia debe obtener el complemento instalado, de lo contrario toda la información jugador no estara disponible.]=]
L["whisperKey_greed"] = "codicia, offspec, la, 2"
L["whisperKey_minor"] = "Actualizacion menor, menor .3"
L["whisperKey_need"] = "necesidad, mainspec, ms, 1"
L["Windows reset"] = "Restaurar ventana"
L["winners"] = "ganadores"
L["x days"] = "%d dias"
L["x out of x have voted"] = "%d de %d han votado"
L["You are not allowed to see the Voting Frame right now."] = "No se le permite ver el Marco de votacion en este momento."
L["You can only auto award items with a quality lower than 'quality' to yourself due to Blizaard restrictions"] = "Solo puede adjudicar premios automaticamente con una calidad inferior %s debido a restricciones de Blizaard"
L["You cannot initiate a test while in a group without being the MasterLooter."] = "No puede iniciar una prueba de grupo si no es maestro despojador"
L["You cannot start an empty session."] = "No puedes iniciar una sesión vacía."
L["You cannot use the menu when the session has ended."] = "No puede utilizar el menu cuando el reparto ha terminado."
L["You cannot use this command without being the Master Looter"] = "No puede utilizar este comando sin ser el maestro despojador"
L["You can't start a loot session while in combat."] = "No puede iniciar reparto de botin en combate"
L["You can't start a session before all items are loaded!"] = "¡No puedes comenzar una sesion hasta que todos los objetos estén cargados!"
--Translation missing 
-- L["You haven't selected an award reason to use for disenchanting!"] = ""
L["You haven't set a council! You can edit your council by typing '/rc council'"] = "No ha establecido un consejo! Puede editar su consejo escribiendo '/rc council'"
--Translation missing 
-- L["You must select a target"] = ""
L["Your note:"] = "Tu nota:"
L["You're already running a session."] = "Usted ya esta ejecutando una sesion."

