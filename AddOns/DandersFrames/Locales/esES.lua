-- Populate DF_AllLocales["esES"] so Core.lua's ADDON_LOADED handler
-- can apply this locale's translations as an overlay if the user's
-- languageOverride selects it. No AceLocale interaction here — the
-- overlay step happens once the SavedVariable is actually populated,
-- which is only guaranteed at ADDON_LOADED time (not file-scope).
DF_AllLocales = DF_AllLocales or {}
DF_AllLocales.esES = {}
local L = DF_AllLocales.esES
L["    Show Frame Glow"] = "    Mostrar brillo del marco"
L["    Show ZZZ Icon"] = "    Mostrar icono ZZZ"
L["— click to edit"] = "- clic para editar"
L[" indicator"] = " indicador"
L[" indicators"] = " indicadores"
L["⚠ Note: Click-through icons will not show tooltips."] = "⚠ Nota: los iconos con clic a través no mostrarán descripciones emergentes"
L["\"%s\" will be overwritten."] = "\"%s\" será sobrescrito."
L["%d - %d players"] = "%d - %d jugadores"
L["%d binds"] = "%d atajos"
L["%d blacklisted"] = "%d en lista negra"
L["%d override"] = "%d sobrescritura"
L["%d overrides"] = "%d sobrescrituras"
L["%d players"] = "%d jugadores"
L["%d-%d players"] = "%d-%d jugadores"
L["%s (Copy)"] = "%s (Copia)"
L["%s (currently %s)"] = "%s (actualmente %s)"
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = [=[%s detectado.

¿Qué addon de lanzamiento por clic quieres usar?]=]
L[ [=[%s detected.

Which click-casting addon would you like to use?]=] ] = [=[%s detectado.

¿Qué addon de lanzamiento por clic quieres usar?]=]
L["%s settings reset to defaults."] = "La configuración de %s se ha restablecido a los valores predeterminados."
L["%sGlobal: 80%s %s— Setting matches global, no override stored%s"] = "%sGlobal: 80%s %s— El ajuste coincide con el valor global, no hay sobrescritura guardada%s"
L["%sModified%s %s— Setting differs from global. Click%s %sreset%s %sto revert.%s"] = "%sModificado%s %s— El ajuste difiere del valor global. Haz clic en%s %srestablecer%s %spara revertir.%s"
L["(none)"] = "(ninguno)"
L["(offline)"] = "(desconectado)"
L["(skipped)"] = "(omitido)"
L["[Linked]"] = "[Vinculado]"
L["[Override]"] = "[Sobrescrito]"
L["[Unassigned]"] = "[Sin asignar]"
L["+ Add"] = "+ Añadir"
L["+ Add aura"] = "+ Añadir aura"
L["+ Add Indicator"] = "+ Añadir indicador"
L["+ Add Layout"] = "+ Añadir diseño"
L["+ Add Option"] = "+ Añadir opción"
L["+ Add Step"] = "+ Añadir paso"
L["+ Add Trigger"] = "+ Añadir disparador"
L["+ Create Group"] = "+ Crear grupo"
L["+ New"] = "+ Nuevo"
L["+ New Wizard"] = "+ Nuevo asistente"
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = [=[• ¿Tienes problemas al visualizar algunos beneficios o perjuicios?
• Este asistente te ayudará a escoger las opciones correctas de auras]=]
L[ [=[• Having trouble seeing certain buffs or debuffs?
• This wizard helps you pick the right aura settings]=] ] = [=[• ¿Tienes problemas al visualizar algunos beneficios o perjuicios?
• Este asistente te ayudará a escoger las opciones correctas de auras]=]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• Texto del nombre
• Texto de salud
• Texto de estado (Muerto/Desconectado)
• Acumulación y duración de beneficios
• Acumulación y duración de perjuicios
• Texto del marco de mascota
• Duración de hechizo dirigido
• Duración del icono defensivo
• Texto del icono de estado (Resurrección, Invocación, etc.)
• Etiquetas de grupo (Banda)]=]
L[ [=[• Name Text
• Health Text
• Status Text (Dead/Offline)
• Buff Stack & Duration
• Debuff Stack & Duration
• Pet Frame Text
• Targeted Spell Duration
• Defensive Icon Duration
• Status Icon Text (Res, Summon, etc.)
• Group Labels (Raid)]=] ] = [=[• Texto del nombre
• Texto de salud
• Texto de estado (Muerto/Desconectado)
• Acumulación y duración de beneficios
• Acumulación y duración de perjuicios
• Texto del marco de mascota
• Duración de hechizo dirigido
• Duración del icono defensivo
• Texto del icono de estado (Resurrección, Invocación, etc.)
• Etiquetas de grupo (Banda)]=]
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• Los valores predeterminados recomendados funcionan bien para la mayoría de los jugadores
• Manual te permite ajustar con precisión todas las opciones de filtro]=]
L[ [=[• Recommended defaults work well for most players
• Manual lets you fine-tune every filter option]=] ] = [=[• Los valores predeterminados recomendados funcionan bien para la mayoría de los jugadores
• Manual te permite ajustar con precisión todas las opciones de filtro]=]
L["0=Auto, Higher=On top of more elements"] = "0=Automático, Mayor=Encima de más elementos"
L["1"] = "1"
L["1 = High"] = "1 = Alto"
L["1. Open ElvUI config with %s/ec%s"] = "1. Abre la configuración de ElvUI con %s/ec%s"
L["10 = Low"] = "10 = Bajo"
L["2. Go to %sUnitFrames%s (left sidebar)"] = "2. Ve a %sMarco de unidad%s (barra lateral izquierda)"
L["20 players (fixed)"] = "20 jugadores (fijo)"
L["3. Click %sGeneral%s at the top"] = "3. Haz clic en %sGeneral%s en la parte superior"
L["4. Scroll down to %sDisabled Blizzard Frames%s"] = "4. Desplázate hacia abajo hasta %sMarcos de Blizzard Desactivados%s"
L["5. Under %sGroup Units%s, uncheck %sParty%s and %sRaid%s"] = "5. Bajo %sUnidades de Grupo%s, desmarca %sGrupo%s y %sBanda%s"
L["6. Click the reload button when prompted"] = "6. Haz clic en el botón de recargar cuando se te indique."
L["A layout with this name already exists in %s"] = "Un diseño con este nombre ya existe en %s"
L["a placed indicator to remove it from the frame"] = "en un indicador colocado para eliminarlo del marco."
L["a placed indicator to reposition it on the frame"] = "un indicador colocado para reposicionarlo en el marco"
L["A profile with this name already exists"] = "Un perfil con este nombre ya existe"
L["A to Z"] = "A a la Z"
L["Abbreviate (K/M)"] = "Abreviar (K/M)"
L["Above Health Bar"] = "Encima de la barra de salud"
L["Above Owner"] = "Encima del dueño"
L["Above Party"] = "Encima del grupo"
L["Above Raid"] = "Encima de la banda"
L["Absorb Shield"] = "Escudo de absorción"
L["Absorbs"] = "Absorciones"
L["Actions"] = "Acciones"
L["Active"] = "Activo"
L["Active Bindings"] = "Atajos activos"
L["Active Bindings (%d)"] = "Atajos activos (%d)"
L["ACTIVE INDICATORS"] = "INDICADORES ACTIVOS"
L["Active:"] = "Activo:"
L["Actually, disable it"] = "En realidad, desactívalo"
L["Add"] = "Añadir"
L["Add #showtooltip"] = "Añadir #showtooltip"
L["Add /stopcasting"] = "Añadir /stopcasting"
L["Add Layout"] = "Añadir diseño"
L["Add New Binding"] = "Añadir atajo nuevo"
L["Add Offline Player"] = "Añadir jugador desconectado"
L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[Agrega jugadores desde
la lista o usa los botones
de adición rápida.]=]
L[ [=[Add players from the roster
or use quick add buttons]=] ] = [=[Agrega jugadores desde
la lista o usa los botones
de adición rápida.]=]
L["Additive (ADD)"] = "Aditivo (SUMAR)"
L["Advanced"] = "Avanzado"
L["Affected Elements"] = "Elementos afectados"
L["AFK"] = "AUS"
L["AFK Icon"] = "Icono de AUS"
L["Aggro Highlight"] = "Resaltar amenaza"
L["Aggro Settings"] = "Configuración de amenaza"
L["Alert if anyone is missing the buff"] = "Alerta si a alguien le falta un beneficio"
L["Alert only if nobody has the buff"] = "Alertar solo si nadie tiene el beneficio"
L["Alert When Expiring"] = "Alertar al expirar"
L["All"] = "Todos"
L["ALL (AND)"] = "TODOS (AND)"
L["All Buffs"] = "Todos los beneficios"
L["All Debuffs"] = "Todos los perjuicios"
L["All Dispellable"] = "Todos los disipables"
L["All players in a unified grid. Sorting applies raid-wide."] = "Todos los jugadores en una cuadrícula unificada. Ordenar aplica a toda la banda."
L["ALL triggers must be active"] = "TODOS los disparadores deben estar activos"
L["Alpha"] = "Opacidad"
L["Alphabetical"] = "Alfabéticamente"
L["Alphabetical (within class/role)"] = "Alfabéticamente (dentro de clase/rol)"
L["Always"] = "Siempre"
L["Always First"] = "Siempre primero"
L["Always Green"] = "Siempre verde"
L["Always Last"] = "Siempre último"
L["an indicator on the frame to expand its settings"] = "en un indicador en el marco para expandir sus configuraciones"
L["Anchor"] = "Anclaje"
L["Anchor Point"] = "Punto de ancla"
L["Anchor Position"] = "Posición del anclaje"
L["Anchor To"] = "Anclar a"
L["Animated Border"] = "Borde animado"
L["ANY (OR)"] = "CUALQUIERA (OR)"
L["Any Target"] = "Cualquier objetivo"
L["ANY trigger activates the effect"] = "CUALQUIER disparador activa este efecto"
L["Appearance"] = "Apariencia"
L["Apply"] = "Aplicar"
L["Apply to All"] = "Aplicar a todo"
L["Apply to Frames:"] = "Aplicar a los marcos:"
L["Arcane Intellect (Mage)"] = "Intelecto Arcano (Mago)"
L["are secret-tracked"] = "son rastreados en secreto"
L["Are you sure?"] = "¿Estás seguro?"
L["Arena"] = "Arena"
L["Arena header will show using raid1-5 unit IDs"] = "El encabezado de arena se mostrará usando los identificadores de unidad de banda 1 a 5"
L["Arena mode %sDISABLED%s"] = "Modo arena %sDESACTIVADO%s"
L["Arena mode %sENABLED%s for testing"] = "Modo arena %sACTIVADO%s para pruebas"
L["Arrange Groups In"] = "Organizar los grupos en"
L["Arrange In"] = "Organizar en"
L["Arrange Players In"] = "Organizar los jugadores en"
L["Attach the handle to the container, the first visible unit, or the last visible unit."] = "Fija el control de arrastre al contenedor, a la primera unidad visible o a la última unidad visible."
L["Attach To"] = "Fijar a"
L["Attached + Overflow"] = "Fijado + desbordamiento"
L["Attached to Health"] = "Fijado a la salud"
L["Attached to Owner"] = "Fijado al dueño"
L["Aura Blacklist"] = "Lista negra de auras"
L["Aura Data Source"] = "Origen de datos de auras"
L["Aura Designer"] = "Diseñador de auras"
L["Aura Designer Alpha"] = "Opacidad del diseñador de auras"
L["Aura Designer is active alongside Buffs."] = "El diseñador de auras está activado junto a los beneficios."
L["Aura Designer is disabled"] = "El diseñador de auras está desactivado"
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = [=[El diseñador de auras es compatible con las especializaciones de sanación y el evocador aumento.

Puedes seleccionar manualmente una especialización usando el menú desplegable de arriba para configurar los indicadores con antelación.]=]
L[ [=[Aura Designer supports healer specs and Augmentation Evoker.

You can manually select a spec using the dropdown above to configure indicators in advance.]=] ] = [=[El diseñador de auras es compatible con las especializaciones de sanación y el evocador aumento.

Puedes seleccionar manualmente una especialización usando el menú desplegable de arriba para configurar los indicadores con antelación.]=]
L["Aura Filter Setup"] = "Configuración de filtros de auras"
L["Aura Filters"] = "Filtros de auras"
L["Auras"] = "Auras"
L["Auras Alpha"] = "Opacidad de auras"
L["Auto (%s)"] = "Auto (%s)"
L["Auto (detect class)"] = "Auto (detectar clase)"
L["Auto (detect spec)"] = "Auto (detectar especialización)"
L["Auto (detect)"] = "Auto (detectar)"
L["Auto (Spec Default)"] = "Auto (especialización por defecto)"
L["Auto Layouts"] = "Diseños automáticos"
L["Auto Layouts is a Raid-only feature. Switch to Raid mode to configure automatic layout switching based on content type and group size."] = "La función de diseños automáticos solo está disponible en modo banda. Cambia al modo banda para configurar el cambio automático de diseño según el tipo de contenido y el tamaño del grupo."
L["Auto Layouts module not loaded."] = "El módulo de diseños automáticos no está cargado."
L["Auto-add DPS"] = "Agregar DPS automáticamente"
L["Auto-add Healers"] = "Agregar Sanadores automáticamente"
L["Auto-add Tanks"] = "Agregar Tanques automáticamente"
L["Auto-create disabled"] = "Creación autom. desactivada"
L["Auto-Create Profiles"] = "Creación automática de perfiles"
L["Auto-create profiles for loadouts"] = "Crear perfiles autom. para configuraciones"
L["Auto-detect (your class's buff)"] = "Detección automática (tu beneficio de clase)"
L["Auto-Fit Border to Frame Size"] = "Adaptar borde automáticamente al marco"
L["Automatically add players by role when they join your group."] = "Añadir automáticamente a los jugadores por su rol cuando se unan a tu grupo."
L["Automatically detects player-dispellable debuffs via the RAID_PLAYER_DISPELLABLE filter. Configure the overlay on the Dispel Overlay page."] = "Detecta automáticamente los perjuicios que el jugador puede disipar mediante el filtro RAID_PLAYER_DISPELLABLE. Configura la superposición en la página Superposición de disipación."
L["Auto-Populate"] = "Rellenar automáticamente"
L["Auto-profile \"%s\" activated (%s, %d players)"] = "Perfil automático \"%s\" activado (%s, %d jugadores)"
L["Auto-profile deactivated (profile deleted)"] = "Perfil automático desactivado (perfil eliminado)"
L["Auto-profile deactivated, using global settings"] = "Perfil automático desactivado; usando la configuración global."
L["Auto-Switch by Spec"] = "Cambio automático por especialización"
L["Auto-switched to profile: %s"] = "Cambiado automáticamente al perfil: %s"
L["Auto-switching disabled"] = "Cambio automático desactivado"
L["Available Profiles"] = "Perfiles disponibles"
L["A-Z"] = "A-Z"
L["Back"] = "Atrás"
L["Back to List"] = "Volver a la lista"
L["Background"] = "Fondo"
L["Background Alpha"] = "Opacidad del fondo"
L["Background Color"] = "Color de fondo"
L["Background Fill"] = "Relleno de fondo"
L["Background Mode"] = "Modo de fondo"
L["Background Only"] = "Solamente fondo"
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[Solamente fondo: muestra un fondo sólido normal.
Solamente la salud faltante: muestra la barra coloreada donde falta salud.
Ambos: muestra ambos.]=]
L[ [=[Background Only: Normal solid background
Missing Health Only: Shows colored bar where health is missing
Both: Shows both]=] ] = [=[Solamente fondo: muestra un fondo sólido normal.
Solamente la salud faltante: muestra la barra coloreada donde falta salud.
Ambos: muestra ambos.]=]
L["Background Texture"] = "Textura de fondo"
L["Bar"] = "Barra"
L["Bar Color"] = "Color de la barra"
L["Bar Texture"] = "Textura de la barra"
L["Bars"] = "Barras"
L["Battle Shout (Warrior)"] = "Grito de Batalla (Guerrero)"
L["Battlegrounds"] = "Campos de batalla"
L["Before You Enable"] = "Antes de activar"
L["Below Health Bar"] = "Debajo de la barra de salud"
L["Below Owner"] = "Debajo del dueño"
L["Below Party"] = "Debajo del grupo"
L["Below Raid"] = "Debajo de la banda"
L["Big Defensives"] = "Defensivos mayores"
L["Bind Action"] = "Asignar acción"
L["Bind Item"] = "Asignar objeto"
L["Bind Spell"] = "Asignar hechizo"
L["Binding Tooltips"] = "Descripciones emergentes de atajos"
L["Binding:"] = "Atajo:"
L["Bindings only cast their assigned spell"] = "Los atajos solamente lanzan su hechizo asignado"
L["BINDS"] = "ATAJOS"
L["Bleed / Enrage"] = "Sangrado / Enfurecimiento"
L["Blend %"] = "Porcentaje de mezcla"
L["Blend Mode"] = "Modo de mezcla"
L["Blessing of the Bronze (Evoker)"] = "Bendición de bronce (Evocador)"
L["Blizzard"] = "Blizzard"
L["Blizzard (Default)"] = "Blizzard (Predeterminado)"
L["Blizzard Click-Casting"] = "Lanzamiento por clic de Blizzard"
L["Blizzard Frame Settings"] = "Configuración de marco de Blizzard"
L["Blizzard Frames"] = "Marcos de Blizzard"
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[Blizzard:
• Refleja los beneficios y perjuicios de los marcos predeterminados de Blizzard
• Requiere que la configuración de banda de Blizzard esté correctamente configurada
• Puede tener un mayor impacto en el rendimiento en grupos grandes

API Directa:
• Te permite controlar qué se muestra en tus marcos
• Algunos filtros pueden omitir ciertos beneficios/perjuicios
• Otros pueden mostrar algunos no deseados
• Se puede ajustar con precisión para obtener los mejores resultados]=]
L[ [=[Blizzard:
• Mirrors the buffs/debuffs from default Blizzard frames
• Requires Blizzard raid settings to be configured correctly
• Slightly more performance heavy in large groups

Direct API:
• Gives you control over what shows on your frames
• Some filters may miss certain buffs/debuffs
• Others might show unwanted ones
• Can be fine-tuned for best results]=] ] = [=[Blizzard:
• Refleja los beneficios y perjuicios de los marcos predeterminados de Blizzard
• Requiere que la configuración de banda de Blizzard esté correctamente configurada
• Puede tener un mayor impacto en el rendimiento en grupos grandes

API Directa:
• Te permite controlar qué se muestra en tus marcos
• Algunos filtros pueden omitir ciertos beneficios/perjuicios
• Otros pueden mostrar algunos no deseados
• Se puede ajustar con precisión para obtener los mejores resultados]=]
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[El sistema de lanzamiento por clic integrado de Blizzard puede entrar en conflicto con la configuración de lanzamiento por clic de DandersFrames.

Recomendamos borrar los atajos de Blizzard en los marcos donde uses los de DandersFrames.]=]
L[ [=[Blizzard's built-in click-casting may conflict with
DandersFrames click-casting settings.

We recommend clearing Blizzard's bindings from
frames where you use DandersFrames bindings.]=] ] = [=[El sistema de lanzamiento por clic integrado de Blizzard puede entrar en conflicto con la configuración de lanzamiento por clic de DandersFrames.

Recomendamos borrar los atajos de Blizzard en los marcos donde uses los de DandersFrames.]=]
L["Border"] = "Borde"
L["Border Color"] = "Color del borde"
L["Border Inset"] = "Margen interno del borde"
L["Border Mode:"] = "Modo del borde:"
L["Border Opacity"] = "Opacidad del borde:"
L["Border Scale"] = "Escala del borde"
L["Border Size"] = "Tamaño del borde"
L["Border Thickness"] = "Grosor del borde"
L["Boss Debuffs"] = "Perjuicios de jefe"
L["Boss Debuffs (Private Auras) are special debuffs that Blizzard hides from addons."] = "Los perjuicios de jefe (auras privadas) son perjuicios especiales que Blizzard oculta a los addons."
L["Both"] = "Ambos"
L["Bottom"] = "Abajo"
L["Bottom Edge"] = "Borde inferior"
L["Bottom Left"] = "Abajo a la izquierda"
L["Bottom Right"] = "Abajo a la derecha"
L["Bottom to Top"] = "De abajo hacia arriba"
L["Bounce"] = "Rebotar"
L["Bound: %s"] = "Asignado: %s"
L["Branch"] = "Rama"
L["Branching Rules"] = "Reglas de ramificación"
L["BUFF BLACKLIST"] = "LISTA NEGRA DE BENEFICIOS"
L["Buff Filters"] = "Filtros de beneficios"
L["Buff Icon"] = "Icono de beneficio"
L["Buff Icons"] = "Iconos de beneficios"
L["Buff Icons Click-Through"] = "Clic a través de iconos de beneficios"
L["Buff Tooltips"] = "Descripciones emergentes de beneficios"
L["Buffs"] = "Beneficios"
L["Buffs are disabled. Aura Designer is managing your auras."] = "Los beneficios están desactivados. El diseñador de auras está gestionando tus auras."
L["Buffs flagged by Blizzard to show up on raid frames."] = "Beneficios marcados por Blizzard para mostrarse en los marcos de banda."
L["Buffs flagged to show on raid frames during combat, such as self-cast HoTs."] = "Beneficios marcados para mostrarse en los marcos de banda durante el combate, como sanaciones periódicas lanzadas por uno mismo."
L["Buffs that can be right-click cancelled."] = "Beneficios que se pueden cancelar al hacer clic derecho."
L["Buffs that cannot be cancelled by the player."] = "Beneficios que no pueden ser cancelados por el jugador."
L["Buffs to Check (Manual Mode)"] = "Beneficios a comprobar (modo manual)"
L["Building: "] = "Generando:"
L["Built-in Wizards"] = "Asistentes integrados"
L["By Health %"] = "Por el % de salud"
L["Cancel"] = "Cancelar"
L["Cancel Fade on Dispellable Debuff"] = "Cancelar atenuación por perjuicio disipable"
L["Cancelable"] = "Cancelables"
L["Cannot delete Default profile."] = "No se puede eliminar el perfil por defecto"
L["Cannot disable test mode while frames are unlocked. Lock frames first."] = "No se puede desactivar el modo de prueba mientras los marcos estén desbloqueados. Bloquea primero los marcos."
L["Cannot Edit"] = "No se puede editar"
L["Cannot enter test mode during combat."] = "No se puede acceder al modo de pruebas durante el combate."
L["Cannot toggle arena mode during combat"] = "No se puede activar o desactivar el modo de arena durante el combate."
L["Cannot toggle test mode during combat."] = "No se puede activar o desactivar el modo de pruebas durante el combate."
L["Cannot unlock - container doesn't exist!"] = "No se puede desbloquear - ¡el contenedor no existe!"
L["Cannot unlock - failed to create mover frame!"] = "No se puede desbloquear: error al crear el control de arrastre."
L["Cannot unlock frames during combat."] = "No se pueden desbloquear los marcos durante el combate."
L["Cannot use this action in combat."] = "No se puede usar esta acción en combate."
L["Cast on DOWN"] = "Lanzar al PULSAR"
L["Categories"] = "Categorías"
L["Category Filters"] = "Filtros de categoría"
L["CC effects like stuns, roots, and incapacitates."] = "Efectos de control de masas como aturdimientos, enraizamientos e incapacitaciones."
L["Center"] = "Centro"
L["Center (Horizontal)"] = "Centro (horizontal)"
L["Center (Vertical)"] = "Centro (vertical)"
L["Center of Group"] = "En el Centro del Grupo"
L["Character"] = "Personaje"
L["Character Import"] = "Importar personaje"
L["Choose how DandersFrames reads aura data for buffs, debuffs, defensives, and dispel detection."] = "Elige cómo DandersFrames lee los datos de auras para detectar beneficios, perjuicios, defensivos y detección de disipaciones."
L["Choose Icon"] = "Escoge icono"
L["Choose whether to enable the frame border overlay."] = "Elige si deseas activar la superposición de borde del marco."
L["Choose which groups to display."] = "Elige qué grupos mostrar."
L["Clamp Mode"] = "Modo de límite"
L["Class"] = "Clase"
L["Class Color"] = "Color de clase"
L["Class Color Alpha"] = "Opacidad del color de clase"
L["Class Colors"] = "Colores de clase"
L["Class Filter"] = "Filtro de clase"
L["Class Power"] = "Poder de clase"
L["Class Power Pips"] = "Indicadores de recurso de clase"
L["Class Priority"] = "Prioridad de clase"
L["Clear"] = "Limpiar"
L["Clear All"] = "Limpiar todo"
L["Clear All Bindings"] = "Limpiar todos los atajos"
L["Clear Blizzard Bindings"] = "Limpiar atajos de Blizzard"
L["Clear Log"] = "Borrar registro"
L["Click"] = "Clic"
L["Click %sEdit Settings%s on a profile to customise it. This takes you to the settings tabs with an editing banner at the top. While editing, any setting you change is stored as an override for that profile only."] = "Haz clic en %sEditar configuración%s en un perfil para personalizarlo. Esto te llevará a la configuración con un banner de edición en la parte superior. Al editar, cualquier ajuste que modifiques se guardará como una sobreescritura solo para ese perfil."
L["Click %sExit Editing%s when done. Your overrides are saved to the profile. If you change a setting back to match global, the override is automatically removed."] = "Haz clic en %sSalir de edición%s cuando hayas terminado. Tus modificaciones se guardarán en el perfil. Si cambias una configuración para que coincida con la global, la modificación se eliminará automáticamente."
L["Click a color swatch to open the color picker. These settings are shared across party and raid frames."] = "Haz clic en una muestra de color para abrir el selector de color. Estos ajustes se comparten entre los marcos de grupo y de banda."
L["Click a setting to link it to your wizard"] = "Haz clic en un ajuste para vincularlo a tu asistente."
L["Click item slot to bind"] = "Haz clic en la ranura de objeto para asignar atajo"
L["Click macro to bind"] = "Haz clic en la macro para asignar atajo"
L["Click or drag a spell onto the frame to place it"] = "Haz clic o arrastra el hechizo al marco para colocarlo."
L["Click spell to bind"] = "Haz clic en el hechizo para asignar atajo"
L["Click to bind..."] = "Clic para establecer..."
L["Click to cycle through steps"] = "Haz clic para recorrer los pasos"
L["Click to edit"] = "Haz clic para editar"
L["Click to edit range"] = "Haz clic para editar el rango."
L["Click to set branch target"] = "Haz clic para establecer objetivo de rama"
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = [=[Haz clic para sincronizar los ajustes de grupo y banda de %s.
Los cambios en un modo se aplicarán automáticamente al otro.]=]
L[ [=[Click to sync Party & Raid %s settings.
Changes in one mode will automatically apply to the other.]=] ] = [=[Haz clic para sincronizar los ajustes de grupo y banda de %s.
Los cambios en un modo se aplicarán automáticamente al otro.]=]
L["Click to toggle"] = "Haz clic para alternar"
L["Click-cast profile: %s"] = "Perfil de lanzamiento por clic: %s"
L["Click-Casting"] = "Lanzamiento por clic"
L["Click-Casting Addon Conflict"] = "Conflicto de addons de lanzamiento por clic"
L["Click-Through Icons"] = "Clic a través de iconos"
L["Clip Border to Frame"] = "Recortar borde al marco"
L["Close"] = "Cerrar"
L["Color"] = "Color"
L["Color and opacity of the empty/inactive pips."] = "Color y opacidad de los indicadores vacíos/inactivos."
L["Color Bar by Duration"] = "Colorear la barra por duración"
L["Color by Dispel Type"] = "Colorear por tipo de disipación"
L["Color by Time"] = "Colorear por tiempo"
L["Color by Time Remaining"] = "Colorear por tiempo restante"
L["Color Duration by Time"] = "Colorear duración por tiempo"
L["Color Mode"] = "Modo de color"
L["Color Name Text"] = "Color del texto del nombre"
L["Color Picker"] = "Selector de color"
L["Color shown when in combat to indicate the handle is locked."] = "Color que se muestra en combate para indicar que el control de arrastre está bloqueado."
L["Colors"] = "Colores"
L["Column Growth"] = "Crecimiento de columnas"
L["Column Spacing"] = "Espaciado de columnas"
L["Columns"] = "Columnas"
L["Columns Grow From"] = "Las columnas crecerán desde el"
L["Combat"] = "Combate"
L["Combat Color"] = "Color de combate"
L["Combat Limitation: All groups will not update with new players that join mid-combat."] = "Limitación de combate: Ningún grupo se actualizará con los nuevos jugadores que se unan en medio del combate."
L["Combat Limitation: Your group will not update with new players that join mid-combat."] = "Limitación de combate: Tu grupo no se actualizará con los nuevos jugadores que se unan en medio del combate."
L["Combat Mode"] = "Modo de combate"
L["Combat Only"] = "Solamente en combate"
L["Compatible (%d)"] = "Compatible (%d)"
L["Compatible Bindings"] = "Atajos compatibles"
L["Compatible Only"] = "Solamente compatible"
L["Confirm"] = "Confirmar"
L["Console"] = "Consola"
L["Container"] = "Contenedor"
L["Content type filters configured in Party tab."] = "Los filtros de tipo de contenido se configuran en la pestaña de grupo."
L["Content Types"] = "Tipos de contenido"
L["Content:"] = "Contenido:"
L["Controls Blizzard's debuff filtering (affects our display too)."] = "Controla el filtrado de perjuicios de Blizzard (también afecta a nuestra visualización)."
L["Controls how multiple defensive icons are arranged when using Direct aura mode."] = "Controla cómo se organizan múltiples iconos defensivos al usar el modo de aura directa."
L["Copied %d settings from %s to %s."] = "Copiados %d ajustes de %s a %s."
L["Copied settings from %s to %s."] = "Copiados ajustes de %s a %s."
L["Copies these settings from %s to %s."] = "Copia estos ajustes de %s a %s."
L["Copy"] = "Copiar"
L["Copy %s Settings"] = "Copiar ajustes de %s"
L["Copy %s settings to %s?"] = "¿Copiar ajustes de %s a %s?"
L["Copy all settings between Party and Raid modes."] = "Copia todos los ajustes entre los modos de grupo y banda"
L["COPY APPEARANCE FROM"] = "COPIAR APARIENCIA DESDE"
L["Copy Layout"] = "Copiar diseño"
L["Copy Settings"] = "Copiar ajustes"
L["Copy Settings to %s"] = "Copiar ajustes a %s"
L["Copy the string below to share this wizard:"] = "Copia la cadena de abajo para compartir este asistente:"
L["Copy this string to share your profile:"] = "Copia esta cadena para compartir tu perfil:"
L["Copy To"] = "Copiar a"
L["Copy to Clipboard"] = "Copiar al portapapeles"
L["Copy to Party"] = "Copiar a grupo"
L["Copy to Raid"] = "Copiar a banda"
L["Corners Only"] = "Solamente las esquinas"
L["Create"] = "Crear"
L["Create and manage setup wizards that guide users through configuring addon settings. Wizards can be shared with others via import/export strings."] = "Crea y gestiona asistentes que guían al usuario a través de la configuración del addon. Los asistentes pueden compartirse con otros mediante cadenas de importación/exportación."
L["Create Custom Macro"] = "Crear macro personalizada"
L["Create Empty"] = "Crear vacío"
L["Create Layout"] = "Crear diseño"
L["Create layouts below for different player ranges within each content type. Layouts only store settings that %sdiffer%s from your global settings — everything else is inherited automatically."] = "Crea diseños a continuación para diferentes rangos de jugadores dentro de cada tipo de contenido. Los diseños solo almacenan configuraciones que %sdifieren%s de tus configuraciones globales; todo lo demás se hereda automáticamente."
L["Create Macro"] = "Crear macro"
L["Create New Profile"] = "Crear perfil nuevo"
L["Create separate frame groups to pin specific players like tanks, healers, or key raid members. Drag players from your group roster to add them."] = "Crea grupos de marcos separados para fijar jugadores específicos como tanques, sanadores o miembros clave de la banda. Arrastra a los jugadores de tu lista de grupo para añadirlos."
L["Created new profile: %s"] = "Perfil nuevo creado: %s"
L["Crowd Control"] = "Control de masas"
L["Current / Max"] = "Actual / Máxima"
L["Current Health"] = "Salud actual"
L["Current Profile"] = "Perfil actual"
L["CURRENT STATUS"] = "ESTADO ACTUAL"
L["Currently: Percent. Click for Seconds."] = "Actualmente: Porcentaje. Haz clic para Segundos"
L["Currently: Seconds. Click for Percent."] = "Actualmente: Segundos. Haz clic para Porcentaje"
L["Curse"] = "Maldición"
L["Cursor"] = "Cursor"
L["Custom"] = "Personalizado"
L["Custom Border"] = "Borde personalizado"
L["Custom buff and frame effect indicators"] = "Indicadores personalizados de beneficios y efectos de marco"
L["Custom Color"] = "Color personalizado"
L["Custom Dead Background"] = "Fondo personalizado para muertos"
L["Custom Dispel Colors"] = "Colores personalizados de disipación"
L["Custom Health Color"] = "Color personalizado de salud"
L["Custom Macro"] = "Macro personalizada"
L["Custom Sound Path"] = "Ruta personalizada de sonido"
L["Custom Spell ID"] = "Identificador de hechizo personalizado"
L["Customise"] = "Personalizar"
L["Customize class colors used throughout DandersFrames. Changes apply to health bars, name text, borders, and all other class-colored elements."] = "Personaliza los colores de clase utilizados en DandersFrames. Los cambios se aplican a las barras de salud, el texto del nombre, los bordes y todos los demás elementos con color de clase."
L["Customize resource bar colors per power type. Shared across party and raid frames."] = "Personalizar colores de la barra de recursos por tipo de poder. Compartido entre los marcos de grupo y de banda"
L["Cut"] = "Cortar"
L["Cycle Next CC Profile"] = "Cambiar al siguiente perfil de lanzamiento por clic"
L["Cycle Next Profile"] = "Cambiar al siguiente perfil"
L["Damage"] = "Daño"
L["DandersFrames Auto-Profile Overrides:"] = "Sobrescrituras de perfil automático de DandersFrames:"
L["Darken Amount"] = "Intensidad de oscurecido"
L["Darken Behind Gradient"] = "Oscurecer detrás del degradado"
L["Darken Effect"] = "Efecto de oscurecido"
L["Dashed Border"] = "Borde a rayas"
L["Dead + In combat: Cast Battle Res (Rebirth, etc.)"] = "Muerto + en combate: lanzar resurrección en combate (Renacer, etc.)"
L["Dead + Out of combat: Cast Mass Res or normal Res"] = "Muerto + fuera de combate: lanzar Resurrección en masa o resurrección normal"
L["Dead Background Color"] = "Color de fondo para muertos"
L["Dead/Offline Fading"] = "Atenuar por muerte/desconexión"
L["Death Knight"] = "Caballero de la Muerte"
L["DEBUFF BLACKLIST"] = "LISTA NEGRA DE PERJUICIOS"
L["Debuff Filters"] = "Filtros de perjuicios"
L["Debuff Icon"] = "Icono de perjuicio"
L["Debuff Icons"] = "Iconos de perjuicios"
L["Debuff Icons Click-Through"] = "Clic a través de iconos de perjuicios"
L["Debuff Tooltips"] = "Descripciones emergentes de perjuicios"
L["Debuffs"] = "Perjuicios"
L["Debuffs relevant during combat in a raid context."] = "Perjuicios relevantes durante el combate en el contexto de una banda."
L["Debuffs relevant in a raid context."] = "Perjuicios relevantes en el contexto de una banda."
L["Debug"] = "Depuración"
L["Debug Console"] = "Consola de depuración"
L["Debug Log Export (Filtered)"] = "Exportar registro de depuración (Filtrado)"
L["Debug logging %s"] = "Registro de depuración %s"
L["Debug mode %s"] = "Modo de depuración %s"
L["Debug Mode (print to chat)"] = "Modo de depuración (imprimir al chat)"
L["Deduplication"] = "Eliminación de duplicados"
L["Default (Slot Order)"] = "Predeterminado (orden de ranuras)"
L["Default Frame Level"] = "Nivel de marco por defecto"
L["Default Frame Strata"] = "Nivel de capa de marco por defecto"
L["Default Icon Size"] = "Tamaño de icono por defecto"
L["Default Scale"] = "Escala por defecto"
L["Defensive buffs from other players, like Pain Suppression or Blessing of Sacrifice."] = "Beneficios defensivos de otros jugadores, como Supresión de dolor o Bendición de sacrificio."
L["Defensive Icon"] = "Icono defensivo"
L["Defensive Icon Alpha"] = "Opacidad del icono defensivo"
L["Defensive Icon Click-Through"] = "Clic a través de icono defensivo"
L["Defensive Icon Tooltips"] = "Descrip. emergentes de icono defensivo"
L["Defensives"] = "Defensivos"
L["Del"] = "Eliminar"
L["Delete"] = "Borrar"
L["Delete Current Profile"] = "Eliminar perfil actual"
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[¿Eliminar la macro importada '%s'?
Se eliminarán todos los atajos que usen esta macro.

(La macro original en WoW no se verá afectada).]=]
L[ [=[Delete imported macro '%s'?
Any bindings using this macro will be removed.

(The original WoW macro will not be affected)]=] ] = [=[¿Eliminar la macro importada '%s'?
Se eliminarán todos los atajos que usen esta macro.

(La macro original en WoW no se verá afectada).]=]
L["Delete Layout"] = "Borrar diseño"
L["Delete layout \"%s\"?"] = "¿Borrar diseño \"%s\"?"
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = [=[¿Eliminar la macro '%s'?
Se eliminarán todos los atajos que utilicen esta macro.]=]
L[ [=[Delete macro '%s'?
Any bindings using this macro will be removed.]=] ] = [=[¿Eliminar la macro '%s'?
Se eliminarán todos los atajos que utilicen esta macro.]=]
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = [=[¿Eliminar el perfil '%s'?

Esta acción no se puede deshacer. ]=]
L[ [=[Delete profile '%s'?

This cannot be undone.]=] ] = [=[¿Eliminar el perfil '%s'?

Esta acción no se puede deshacer.]=]
L["Delete Step"] = "Borrar paso"
L["Deleted profile: %s"] = "Perfil eliminado: %s"
L["Demon Hunter"] = "Cazador de Demonios"
L["Desaturate When Missing"] = "Quitar color si falta"
L["Description"] = "Descripción"
L["Description (optional)"] = "Descripción (opcional)"
L["Dialog"] = "Diálogo"
L["Direct API"] = "API Directa"
L["Direction"] = "Dirección"
L["Disable (set to false)"] = "Desactivar (establecer a falso)"
L["Disable Buffs"] = "Desactivar beneficios"
L["Disable in Combat"] = "Desactivar en combate"
L["Disable Overlay"] = "Desactivar superposición"
L["Disable While Mounted"] = "Desactivar en montura"
L["Disable while mounted/flying"] = "Desactivar en montura/vuelo"
L["Disabled"] = "Desactivado"
L["disabled"] = "desactivado"
L["Disease"] = "Enfermedad"
L["Dispel Detection"] = "Detección de disipación"
L["Dispel Overlay"] = "Superpos. disipación"
L["Dispel Overlay Alpha"] = "Opacidad de la superposición de disipación"
L["Dispel Type Colors"] = "Colores por tipo de disipación"
L["Dispel Type Icon"] = "Icono de tipo de disipación"
L["Dispellable By Me"] = "Disipables por mí"
L["Display"] = "Mostrar"
L["Display labels above or beside each raid group."] = "Muestra etiquetas encima o al lado de cada grupo de banda."
L["Display Mode"] = "Modo de visualización"
L["Displays class-specific resources (Holy Power, Chi, Combo Points, Soul Shards, Arcane Charges, Essence) as colored pips on your player frame."] = "Muestra los recursos específicos de clase (Poder Sagrado, Chi, Puntos de combo, Fragmentos de alma, Cargas arcanas, Esencia) como indicadores de color en el marco de jugador."
L["Done"] = "Hecho"
L["Don't show this warning again"] = "No mostrar esta advertencia de nuevo"
L["Down"] = "Abajo"
L["DPS"] = "DPS"
L["Drag"] = "Arrastrar"
L["Drag to reorder groups. Top = first."] = "Arrastra para reordenar los grupos. Arriba = primero."
L["Drag to reorder. Top = first."] = "Arrastra para reordenar. Arriba = primero."
L["Drop on an anchor point to move %s"] = "Suelta sobre un punto de anclaje para mover %s"
L["Drop on an anchor point to place %s"] = "Suelta sobre un punto de anclaje para colocar %s"
L["Druid"] = "Druida"
L["Dungeons"] = "Mazmorras"
L["Duplicate"] = "Duplicar"
L["Duplicate Current"] = "Duplicar el actual"
L["Duplicated profile '%s' to '%s'."] = "Perfil duplicado '%s' a '%s'."
L["Duration"] = "Duración"
L["Duration & stack display"] = "Duración y visualización de acumulaciones"
L["Duration Anchor"] = "Anclaje de duración"
L["Duration Color"] = "Color de la duración"
L["Duration Font"] = "Fuente de la duración"
L["Duration in seconds for the Pull Timer quick action."] = "Duración en segundos para la acción rápida del temporizador para iniciar combate"
L["Duration Offset X"] = "Desplazamiento X de la duración"
L["Duration Offset Y"] = "Desplazamiento Y de la duración"
L["Duration Outline"] = "Contorno de la duración"
L["Duration Position"] = "Posición de la duración"
L["Duration Scale"] = "Escala de la duración"
L["Duration Text"] = "Texto de la duración"
L["Duration Text Color"] = "Color del texto de la duración"
L["Echo to Chat"] = "Mostrar en el chat"
L["Edge Glow (All Sides)"] = "Brillo en los bordes (en todos los lados)"
L["Edit"] = "Editar"
L["Edit Binding"] = "Editar atajo"
L["Edit Copy"] = "Editar copia"
L["Edit Layout Range"] = "Editar rango de diseño"
L["Edit Macro"] = "Editar macro"
L["Edit Settings"] = "Editar config."
L["Edit Steps"] = "Editar pasos"
L["Editing"] = "Editando"
L["Editing:"] = "Editando:"
L["Editing: %s"] = "Editando: %s"
L["Effects"] = "Efectos"
L["Ellipsis (...)"] = "Elipsis (...)"
L["Enable"] = "Activar"
L["Enable (set to true)"] = "Activar (establecer a verdadero)"
L["Enable AFK Icon"] = "Activar icono de AUS"
L["Enable Aura Designer"] = "Activar diseñador de auras"
L["Enable Binding Tooltips"] = "Activar descripciones emergentes de atajos"
L["Enable Boss Debuffs"] = "Activar perjuicios de jefe"
L["Enable Buff Tooltips"] = "Activar descripciones emergentes de beneficios"
L["Enable Buffs"] = "Activar beneficios"
L["Enable Class Power Pips"] = "Activar indicadores de recurso de clase"
L["Enable Custom Sorting"] = "Activar orden personalizado"
L["Enable Dead Fade"] = "Activar atenuación por muerte"
L["Enable Debuff Tooltips"] = "Activar descripciones emergentes de perjuicios"
L["Enable Debug Logging"] = "Activar registro de depuración"
L["Enable Defensive Icon"] = "Activar icono defensivo"
L["Enable Defensive Icon Tooltips"] = "Activar descrip. emergentes de icono defensivo"
L["Enable Dispel Overlay"] = "Activar la superposición de disipación"
L["Enable Element-Specific Alpha"] = "Activar opacidad por cada elemento especifico"
L["Enable Expiring Indicators"] = "Activar indicadores de expiración"
L["Enable Frame Border Overlay"] = "Activar superposición de borde del marco"
L["Enable Frame Tooltips"] = "Activar marco de descripciones emergentes"
L["Enable Group Labels"] = "Activar etiquetas de grupo"
L["Enable Heal Prediction"] = "Activar predicción de sanación"
L["Enable Health Threshold Fade"] = "Activar atenuación por umbral de salud"
L["Enable Leader Icon"] = "Activar icono de líder"
L["Enable Missing Buff Icon"] = "Activar icono de beneficio faltante"
L["Enable Offscreen Nameplates"] = "Activar placas de nombre fuera de pantalla"
L["Enable Overlay"] = "Activar superposición"
L["Enable Permanent Mover"] = "Activar control de arrastre permanente"
L["Enable Personal Targeted Spells"] = "Activar hechizos dirigidos hacia ti"
L["Enable Pet Frames"] = "Activar marcos de mascota"
L["Enable Phased Icon"] = "Activar icono de faseado"
L["Enable Raid Auto-Switching Layouts"] = "Activar cambio automático de diseños de banda"
L["Enable Raid Role Icon"] = "Activar icono de rol en raid"
L["Enable Raid Target Icon"] = "Activar icono de objetivo de banda"
L["Enable Ready Check Icon"] = "Activar icono de comprobación de listos"
L["Enable Resource Bar"] = "Activar la barra de recursos"
L["Enable Resurrection Icon"] = "Activar icono de resurrección"
L["Enable Resurrection Icon Tooltips"] = "Activar d. emergentes de icono de resurrección"
L["Enable Sound Alert"] = "Activar alerta de sonido"
L["Enable Spec Auto-Switch"] = "Activar cambio automático por especialización"
L["Enable Status Text"] = "Activar texto de estado"
L["Enable Summon Icon"] = "Activar icono de invocar"
L["Enable Targeted Spells"] = "Activar hechizos dirigidos"
L["Enable the checkbox above to use"] = "Activa la casilla de verificación superior para utilizarlo"
L["Enable Vehicle Icon"] = "Activar icono de vehículo"
L["enabled"] = "activado"
L["Enabled"] = "Activado"
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[Activado: Jugadores organizados en grupos de banda (1-8).
Desactivado: Todos los jugadores en una única cuadrícula plana.]=]
L[ [=[Enabled: Players organized by raid groups (1-8).
Disabled: All players in one flat grid.]=] ] = [=[Activado: Jugadores organizados en grupos de banda (1-8).
Desactivado: Todos los jugadores en una única cuadrícula plana.]=]
L["End"] = "Final"
L["END"] = "FIN"
L["End (Right/Bottom)"] = "Final (Derecha/Abajo)"
L["End of Group"] = "Al final del grupo"
L["Energy"] = "Energía"
L["Enter a layout name"] = "Introduce un nombre de diseño"
L["Enter a profile name"] = "Introduce un nombre de perfil"
L["Enter a spell name above..."] = "Introduce el nombre del hechizo arriba..."
L["Enter any spell ID for range checking. Press Enter to apply. Leave empty to use dropdown selection."] = "Introduce cualquier identificador de hechizo para comprobar su alcance. Pulsa Intro para aplicar. Deja el espacio en blanco para usar la entrada seleccionada en el desplegable."
L["Enter name for copy of '%s':"] = "Introduce el nombre para la copia de '%s':"
L["Enter new name for '%s':"] = "Introduce un nuevo nombre para '%s':"
L["Enter new profile name:"] = "Introduce el nuevo nombre de perfil:"
L["Enter WoW texture paths (file extensions are stripped automatically). Leave empty to use DF Icons as fallback."] = "Introduce las rutas de las texturas de WoW (las extensiones de archivo se eliminan automáticamente). Déjalo en blanco para usar los iconos de DF como alternativa."
L["Errors Only"] = "Solamente errores"
L["Evoker"] = "Evocador"
L["Exit Editing"] = "Salir de edición"
L["Expire Alert"] = "Alerta de expiración"
L["Expiring"] = "Expiración"
L["Expiring Alpha"] = "Opacidad de expiración"
L["Expiring Alpha Override"] = "Aplicar opacidad al expirar"
L["Expiring Color"] = "Color de expiración"
L["Expiring Color Override"] = "Aplicar color al expirar"
L["Expiring Indicator"] = "Indicador de expiración"
L["Expiring indicator tracks the trigger with the least time remaining."] = "El indicador de expiración sigue el efecto con menor tiempo restante."
L["Expiring indicator tracks the trigger with the most time remaining."] = "El indicador de expiración sigue el efecto con mayor tiempo restante."
L["Expiring Threshold (%)"] = "Umbral de expiración (%)"
L["Expiring Threshold (seconds)"] = "Umbral de expiración (segundos)"
L["Export"] = "Exportar"
L["Export failed. Please try again or check for errors."] = "Error al exportar. Inténtalo de nuevo o comprueba si hay errores."
L["Export Settings"] = "Exportar configuración"
L["Export Wizard"] = "Asistente de exportación"
L["External"] = "Externos"
L["External Defensives"] = "Defensivos externos"
L["Fade frames or elements when a unit's health is above the set threshold (e.g. 100% or 80%)."] = "Atenúa los marcos o elementos cuando la salud de una unidad supere el umbral establecido (por ejemplo, 100% u 80%)."
L["Fading"] = "Atenuar"
L["Fill Color"] = "Color de relleno"
L["Fill Direction"] = "Dirección de relleno"
L["Fill Pulsate"] = "Relleno pulsante"
L["Finish"] = "Finalizar"
L["First question"] = "Primera pregunta"
L["First Unit"] = "Primera unidad"
L["Fixed at 20 players (Mythic)"] = "Fijado a 20 jugadores (Mítico)"
L["Flat Grid Settings"] = "Configuración de cuadrícula plana"
L["Floating Bar"] = "Barra flotante"
L["Floating Bar Anchor"] = "Anclaje de la barra flotante"
L["Floating Bar Position"] = "Posición de la barra flotante"
L["Focus"] = "Enfoque"
L["Font"] = "Fuente"
L["Font Outline"] = "Contorno de fuente"
L["Font Settings"] = "Configuración de fuente"
L["Font settings for icons displayed as text (Summon, Res, AFK, etc.)"] = "Configuración de fuentes para los iconos que se muestran como texto (Invocar, Resurrección, AUS, etc.)"
L["Font Size"] = "Tamaño de fuente"
L["For items/macros that need @cursor, @mouseover, etc. Consumes the keybind and prevents action bar use."] = "Para objetos/macros que requieren @cursor, @mouseover, etc. Consume el atajo y evita su uso en la barra de acción."
L["For nameplates & world units. %sDoes not work with action bar binds.%s"] = "Para placas de nombre y unidades del mundo. %sNo funciona con las combinaciones de teclas de la barra de acciones.%s"
L["Frame"] = "Marco"
L["Frame Alpha"] = "Opacidad del marco"
L["Frame Alpha (Above Threshold)"] = "Opacidad del marco (por encima del umbral)"
L["Frame Alpha (Out of Range)"] = "Opacidad del marco (Fuera de Rango)"
L["Frame Border Overlay"] = "Superposición de borde del marco"
L["Frame Display"] = "Visualización del marco"
L["Frame Growth"] = "Crecimiento del marco"
L["Frame Height"] = "Altura de marco"
L["Frame Level"] = "Nivel de marco"
L["Frame Level Offset"] = "Desplazamiento del nivel de marco"
L["Frame opacity when health is above the threshold."] = "Opacidad del marco cuando la salud está por encima del umbral."
L["Frame Padding"] = "Espaciado interno de marcos"
L["FRAME PREVIEW"] = "PREVISUALIZACIÓN DEL MARCO"
L["Frame Scale"] = "Escala del marco"
L["Frame Size"] = "Tamaño del marco"
L["Frame Spacing"] = "Espaciado entre marcos"
L["Frame Strata"] = "Nivel de capa de marco"
L["Frame Tooltips"] = "Marco de descripciones emergentes"
L["Frame Width"] = "Anchura de marco"
L["FRAME-LEVEL EFFECTS"] = "EFECTOS A NIVEL DE MARCO"
L["Frames centered on screen."] = "Marcos centrados en pantalla"
L["Frames Grow From"] = "Los marcos crecerán desde el"
L["Frames locked."] = "Marcos bloqueados."
L["Frames unlocked. Drag to move, right-click to lock."] = "Marcos desbloqueados. Arrastra para mover, haz clic derecho para bloquear."
L["Frames: %s"] = "Marcos: %s"
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[Se ha detectado el addon FrameSort. Actívalo para que FrameSort controle el orden de los marcos.

%sExperimental:%s Esta función es nueva y puede que no funcione a la perfección en todos los casos. Por favor, informa de cualquier problema.]=]
L[ [=[FrameSort addon detected. Enable to let FrameSort control frame ordering.

%sExperimental:%s This feature is new and may not work perfectly in all scenarios. Please report any issues.]=] ] = [=[Se ha detectado el addon FrameSort. Actívalo para que FrameSort controle el orden de los marcos.

%sExperimental:%s Esta función es nueva y puede que no funcione a la perfección en todos los casos. Por favor, informa de cualquier problema.]=]
L["FrameSort Integration"] = "Integración con FrameSort"
L["Friendly Only"] = "Solamente amistosos"
L["Full Frame"] = "Todo el marco"
L["Fully Combat Safe: Frames will update normally during combat."] = "Totalmente seguro en combate: Los marcos se actualizarán con normalidad durante el combate."
L["Fury"] = "Furia"
L["G1"] = "G1"
L["Game Default"] = "Predeterminado por el juego"
L["Gap Between Pips"] = "Espacio entre indicadores"
L["General"] = "General"
L["General Import"] = "Importación general"
L["Generate Export String"] = "Generar cadena de exportación"
L["Gets its own independent border overlay. Multiple custom borders can be visible at the same time."] = "Obtiene su propio borde independiente. Se pueden mostrar varios bordes personalizados al mismo tiempo."
L["Global"] = "Global"
L["Global Font Settings"] = "Configuración global de fuentes"
L["Global Fonts"] = "Fuentes globales"
L["Global Keybind:"] = "Atajo global:"
L["Glow"] = "Brillar"
L["Glow (ADD)"] = "Brillo (AÑADIR)"
L["Glow Alpha"] = "Opacidad del brillo"
L["Glow Color"] = "Color de brillo"
L["Glow Style"] = "Estilo de brillo"
L["Go Back"] = "Volver atrás"
L["Goes to: %s"] = "Va a: %s"
L["Gradient"] = "Degradado"
L["Gradient Color Alpha"] = "Opacidad del color de degradado"
L["Gradient Intensity"] = "Intensidad del degradado"
L["Gradient Opacity"] = "Opacidad del degradado"
L["Gradient Position"] = "Posición del degradado"
L["Gradient Size"] = "Tamaño del degradado"
L["Grid"] = "Cuadrícula"
L["Grid Layout"] = "Diseño de cuadrícula"
L["Group"] = "Grupo"
L["Group 1"] = "Grupo 1"
L["Group Display Order"] = "Orden de visualización del grupo"
L["Group Labels"] = "Etiquetas de grupo"
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[Las etiquetas de grupo no están disponibles en el diseño de cuadrícula plana.

Activa la opción "Usar diseño basado en grupos" en la configuración de marco para usar las etiquetas de grupo.]=]
L[ [=[Group labels are not available in Flat Grid layout.

Enable 'Use Group-Based Layout' in Frame settings
to use group labels.]=] ] = [=[Las etiquetas de grupo no están disponibles en el diseño de cuadrícula plana.

Activa la opción "Usar diseño basado en grupos" en la configuración de marco para usar las etiquetas de grupo.]=]
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[Las etiquetas de grupo solo están disponibles para marcos de banda.

Cambia al modo banda usando el botón en la parte superior del panel de configuración para configurar las etiquetas de grupo.]=]
L[ [=[Group labels are only available for raid frames.

Switch to Raid mode using the toggle at the top
of the settings panel to configure group labels.]=] ] = [=[Las etiquetas de grupo solo están disponibles para marcos de banda.

Cambia al modo banda usando el botón en la parte superior del panel de configuración para configurar las etiquetas de grupo.]=]
L["Group Layout Settings"] = "Configuración de diseño de grupos"
L["GROUP NAME"] = "NOMBRE DEL GRUPO"
L["Group Position"] = "Posición del grupo"
L["Group Roster"] = "Lista de grupo"
L["Group Settings"] = "Configuración de grupo"
L["Group Spacing"] = "Espaciado de grupo"
L["Group Visibility"] = "Visibilidad de grupo"
L["Group X Offset"] = "Desplazamiento X del grupo"
L["Group Y Offset"] = "Desplazamiento Y del grupo"
L["Groups Grow From"] = "Los grupos crecerán desde el"
L["Groups Per Column"] = "Grupos por columna"
L["Groups Per Row"] = "Grupos por fila"
L["Growth"] = "Crecimiento"
L["GROWTH"] = "CRECIMIENTO"
L["Growth Direction"] = "Dirección de crecimiento"
L["GUI reset to default size, scale, and position."] = "La interfaz gráfica de usuario se restableció a su tamaño, escala y posición predeterminados."
L["Guided setup for configuring which buffs and debuffs appear on your frames."] = "Configuración guiada para definir qué beneficios y perjuicios aparecen en tus marcos."
L["Guided setup for the frame border overlay that highlights boss debuffs."] = "Guía de configuración para la superposición de borde del marco que resalta los perjuicios de jefe."
L["Handle Color"] = "Color del control de arrastre"
L["Handle Height"] = "Altura del control de arrastre"
L["Handle is invisible until you hover over it. Fades in and out smoothly."] = "El control de arrastre es invisible hasta que pasas el cursor sobre él. Aparece y desaparece suavemente."
L["Handle Position"] = "Posición del control de arrastre"
L["Handle Width"] = "Ancho del control de arrastre"
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = [=[Tener varios addons de lanzamiento por clic activados puede causar conflictos y un comportamiento inesperado.

%s¡Utilízalo bajo tu propia responsabilidad!%s]=]
L[ [=[Having multiple click-casting addons enabled
may cause conflicts and unexpected behavior.

%sUse at your own risk!%s]=] ] = [=[Tener varios addons de lanzamiento por clic activados puede causar conflictos y un comportamiento inesperado.

%s¡Utilízalo bajo tu propia responsabilidad!%s]=]
L["Having trouble with buffs or debuffs? Run the setup wizard for guided help."] = "¿Tienes problemas con los beneficios y perjuicios? Ejecuta el asistente de configuración para obtener ayuda guiada."
L["Heal Absorb"] = "Absorción de sanación"
L["Heal Prediction"] = "Predicción sanación"
L["Heal Prediction Color"] = "Color de la predicción de sanación"
L["Healer"] = "Sanador"
L["Healers"] = "Sanadores"
L["Health"] = "Salud"
L["Health Bar"] = "Barra de salud"
L["Health Bar Alpha"] = "Opacidad de la barra de salud"
L["Health Bar Color"] = "Color de la barra de salud"
L["Health Bar Texture"] = "Textura de la barra de salud"
L["Health Deficit"] = "Déficit de salud"
L["Health Format"] = "Formato de la salud"
L["Health Gradient"] = "Degradado de salud"
L["Health Text"] = "Texto de salud"
L["Health Text Alpha"] = "Opacidad del texto de salud"
L["Health Text Anchor"] = "Anclaje del texto de salud"
L["Health Text Color"] = "Color del texto de salud"
L["Health Threshold (%)"] = "Umbral de salud (%)"
L["Health Threshold Fading"] = "Atenuar por umbral de salud"
L["Health X Offset"] = "Desplazamiento X de la salud"
L["Health Y Offset"] = "Desplazamiento Y de la salud"
L["Height"] = "Altura"
L["Height / Thickness"] = "Altura / Grosor"
L["Here's what we'll set up:"] = "Esto es lo que vamos a configurar:"
L["Hidden"] = "Oculto"
L["Hide % Symbol"] = "Ocultar el símbolo %"
L["Hide Above (seconds)"] = "Ocultar por encima (segundos)"
L["Hide Above Threshold"] = "Ocultar por encima del umbral"
L["Hide Blizzard Party Frames"] = "Ocultar los marcos de grupo de Blizzard"
L["Hide Blizzard Player Frame"] = "Ocultar el marco de jugador de Blizzard"
L["Hide Blizzard Raid Frames"] = "Ocultar marcos de banda de Blizzard"
L["Hide buffs from the buff bar when they are already displayed by the Defensive Bar or Aura Designer."] = "Oculta los beneficios de la barra de beneficios cuando ya se muestren en la barra defensiva o en el diseñador de auras."
L["Hide Cooldown Swipe"] = "Ocultar barrido de reutilización"
L["Hide duplicate buffs"] = "Ocultar beneficios duplicados"
L["Hide Duration Above Threshold"] = "Ocultar duración por encima del umbral"
L["Hide Icon (Text Only)"] = "Ocultar icono (solo texto)"
L["Hide in Combat"] = "Ocultar en combate"
L["Hide raid buffs from buff bar"] = "Ocultar beneficios de banda en la barra de beneficios"
L["Hide Self from Party Frames"] = "Ocultarte de los marcos de grupo"
L["Hide specific buffs and debuffs from your frames. Click a spell to toggle blacklisting. Blacklisted auras will not appear on buff bars or Aura Designer indicators."] = "Oculta beneficios y perjuicios específicos de tus marcos. Haz clic en un hechizo para activar o desactivar de la lista negra. Las auras incluidas en la lista negra no aparecerán en las barras de beneficios ni en los indicadores del diseñador de auras."
L["Hide Tooltip on Mouseover"] = "Ocultar descripciones emergentes al pasar el ratón"
L["Hides Blizzard frames but keeps them active for aura filtering."] = "Oculta los marcos de Blizzard pero los mantiene activos para el filtrado de auras."
L["Hides the default Blizzard player portrait and health bar."] = "Oculta el retrato de jugador y la barra de salud predeterminados de Blizzard."
L["Hides the handle during combat. If disabled, the handle changes color to indicate it is locked."] = "Oculta el control de arrastre durante el combate. Si está desactivado, cambia de color para indicar que está bloqueado."
L["High"] = "Alto"
L["High Health (100%)"] = "Salud alta (100%)"
L["High Threat (Yellow)"] = "Amenaza alta (Amarillo)"
L["Higher values render the bar above other elements. Frame border is at level 10."] = "Valores más altos dibujan la barra sobre otros elementos. El borde del marco está en el nivel 10."
L["Highest Threat (Orange)"] = "Amenaza máxima (Naranja)"
L["Highlight"] = "Resaltado"
L["Highlight Color"] = "Color de resaltado"
L["Highlight Dispellable"] = "Resaltar disipable"
L["Highlight for User"] = "Resaltar para el usuario"
L["Highlight for user to configure"] = "Resaltar para que el usuario configure"
L["Highlight Important Spells"] = "Resaltar hechizos importantes"
L["Highlight Settings"] = "Configuración de resaltado"
L["Highlight Settings (comma-separated dbKeys)"] = "Configuración de resaltado (dbKeys separadas por comas)"
L["Highlight Style"] = "Estilo de resaltado"
L["Highlighted Units"] = "Unidades resaltadas"
L["Highlights"] = "Resaltados"
L["Highlights: %s"] = "Resaltados: %s"
L["Horizontal"] = "Horizontal"
L["Horizontal anchors lay pips left-to-right. Left/Right anchors stack pips vertically along the frame side."] = "Los anclajes horizontales colocan los indicadores de izquierda a derecha. Los anclajes izquierdo/derecho los apilan verticalmente a lo largo del borde del marco."
L["Horizontal Spacing"] = "Espaciado horizontal"
L["Horizontal: Players stack vertically, groups grow left-to-right."] = "Horizontal: los jugadores se apilan verticalmente, los grupos crecen de izquierda a derecha."
L["Hostile Only"] = "Solamente hostiles"
L["Hover Highlight"] = "Resaltado al pasar el ratón"
L["Hover Settings"] = "Configuración al pasar el ratón"
L["How it works"] = "Cómo funciona"
L["How often to check range (seconds). Lower = more responsive but higher CPU. Default: 0.5s"] = "Frecuencia para comprobar el rango (segundos). Valores bajos = más respuesta pero mayor uso de procesador. Por defecto: 0,5s."
L["How would you like to configure the filters?"] = "¿Cómo te gustaría configurar los filtros?"
L["HP"] = "PS"
L["Hunter"] = "Cazador"
L["I understand, enable it"] = "Lo entiendo, actívalo"
L["I, II, III..."] = "I, II, III..."
L["Icon"] = "Icono"
L["Icon Height"] = "Altura del icono"
L["Icon Offset X"] = "Desplazamiento X del icono"
L["Icon Offset Y"] = "Desplazamiento Y del icono"
L["Icon Opacity"] = "Opacidad del icono"
L["Icon Position"] = "Posición del icono"
L["Icon Ratio"] = "Proporción del icono"
L["Icon Size"] = "Tamaño de icono"
L["Icon size, scale & border"] = "Tamaño de icono, escala y borde"
L["Icon Spacing"] = "Espaciado de iconos"
L["Icon Style"] = "Estilo de icono"
L["Icon Width"] = "Anchura del icono"
L["Icons"] = "Iconos"
L["Icons Alpha"] = "Opacidad de iconos"
L["Icons Per Row"] = "Iconos por fila"
L["Ignore"] = "Ignorar"
L["Ignore Full Health Fade"] = "Ignorar atenuación de salud completa"
L["Import"] = "Importar"
L["Import All"] = "Importar todas"
L["Import All (%d)"] = "Importar todas (%d)"
L["Import Buffs Tab Defaults"] = "Importar valores predeterminados de la pestaña de beneficios"
L["Import Click Casting Profile"] = "Importar perfil de lanzamiento por clic"
L["Import failed"] = "Error al importar"
L["Import from Buffs Tab"] = "Importar desde la pestaña de beneficios"
L["Import Selected"] = "Importar seleccionado"
L["Import Settings"] = "Importar configuración"
L["Import String"] = "Importar cadena"
L["Import Wizard"] = "Importar asistente"
L["Import WoW Macros"] = "Importar macros de WoW"
L["Import your existing Buffs tab settings as defaults for all auras. Compatible settings will be applied automatically."] = "Importa la configuración existente de la pestaña de beneficios como valores predeterminados para todas las auras. Los ajustes compatibles se aplicarán automáticamente."
L["Import/Export"] = "Importar/Exportar"
L["Important Spells"] = "Hechizos importantes"
L["Important Spells Only"] = "Solamente hechizos importantes"
L["Imported Profile"] = "Perfil importado"
L["Imported!"] = "Importado"
L["In Combat Only"] = "Solamente en combate"
L["In Direct mode, all active big and external defensives are shown per unit (not just one). Adjust max count and layout on the Defensive Icon page."] = "En el modo directo, se muestran todos los defensivos activos, tanto grandes como externos, por unidad (no solo uno). Ajusta el número máximo y la disposición en la página icono defensivo."
L["Incompatible Bindings"] = "Atajos incompatibles"
L["Indicators"] = "Indicadores"
L["INFERRED TRACKING"] = "SEGUIMIENTO DEDUCIDO"
L["Info (All)"] = "Información (Todo)"
L["Inherit (Frame)"] = "Heredar (Marco)"
L["Insanity"] = "Demencia"
L["Inset"] = "Margen interno"
L["Inside (Bottom)"] = "Interior (abajo)"
L["Inside (Top)"] = "Interior (arriba)"
L["Instanced / PvP"] = "Instanciado / JcJ"
L["Integration"] = "Integración"
L["Integration (advanced):"] = "Integración (avanzado):"
L["Integrations"] = "Integraciones"
L["Interrupt Settings"] = "Configuración de interrupciones"
L["Interrupted Visual"] = "Visual de interrupción"
L["is secret-tracked"] = "es rastreado en secreto"
L["Items"] = "Objetos"
L["Join a raid group (2-5 players works best)"] = "Únete a un grupo de banda (lo ideal es de 2 a 5 jugadores)."
L["Keep Buffs"] = "Mantener beneficios"
L["Keep when offline/left"] = "Mantener al desconectar/abandonar"
L["Label Color"] = "Color de la etiqueta"
L["Label Format"] = "Formato de la etiqueta"
L["Label Name"] = "Nombre de la etiqueta"
L["Label Position"] = "Posición de la etiqueta"
L["Label:"] = "Etiqueta:"
L["Last Unit"] = "Ultima unidad"
L["Layout"] = "Diseño"
L["Layout (Direct Mode)"] = "Diseño (Modo directo)"
L["Layout Direction"] = "Dirección del diseño"
L["Layout Group"] = "Grupo de diseño"
L["Layout Groups"] = "Grupos de diseño"
L["Layout Mode"] = "Modo de diseño"
L["Layout Name"] = "Nombre del diseño"
L["Layout:"] = "Diseño:"
L["Leader Icon"] = "Icono de líder"
L["Left"] = "Izquierda"
L["Left Click"] = "Clic izquierdo"
L["Left Edge"] = "Borde izquierdo"
L["Left of Health Bar"] = "A la izquierda de la barra de salud"
L["Left of Owner"] = "A la izquierda del dueño"
L["Left of Party"] = "A la izquierda del grupo"
L["Left of Raid"] = "A la izquierda de la banda"
L["Left to Right"] = "Izquierda a derecha"
L["Left-click to add/edit binding"] = "Haz clic izquierdo para añadir/editar atajo"
L["Left-click: Bind"] = "Clic izquierdo: Asignar atajo"
L["Let Masque Control Aura Borders"] = "Permitir que Masque controle los bordes de aura"
L["Let me configure it myself"] = "Déjame configurarlo a mi"
L["Line"] = "Linea"
L["Link: %s"] = "Enlace: %s"
L["Linked Settings"] = "Ajustes vinculados"
L["List"] = "Lista"
L["Loading..."] = "Cargando..."
L["LOADOUT ASSIGNMENTS"] = "ASIGNACIÓN DE CONFIGURACIONES"
L["Loadout expects: %s"] = "Configuración esperada: %s"
L["Lock"] = "Bloquear"
L["Lock Frames"] = "Bloquear marcos"
L["Lock Position"] = "Bloquear posición"
L["Log Viewer"] = "Visor de registros"
L["Loop Interval (sec)"] = "Intervalo de repetición (segundos)"
L["Low"] = "Bajo"
L["Low Health (0%)"] = "Salud baja (0%)"
L["Lunar Power"] = "Poder Astral"
L["Macro Options:"] = "Opciones de macro:"
L["Macro Text:"] = "Texto de macro:"
L["Macros"] = "Macros"
L["Mage"] = "Mago"
L["Magic"] = "Magia"
L["Major defensive cooldowns like Divine Shield, Ice Block, or Barkskin."] = "Habilidades defensivas importantes como Escudo divino, Bloque de hielo o Corteza."
L["Make icons click-through for external click-casting addons. Not needed for DF built-in click-casting."] = "Permite hacer clic a traves de los iconos para addons externos de lanzamiento por clic. No es necesario para el lanzamiento por clic integrado de DF."
L["Makes this binding work everywhere, consuming the keybind."] = "Permite que este atajo funcione en cualquier lugar, consumiendo / ocupando la tecla asignada."
L["Mana"] = "Maná"
L["Manage"] = "Gestionar"
L["Manage Profiles"] = "Gestionar perfiles"
L["Marching Ants"] = "Hormigas marchando"
L["Mark of the Wild (Druid)"] = "Marca de lo Salvaje (Druida)"
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = [=[El addon Masque no está instalado.

Masque te permite personalizar los iconos de beneficios/perjuicios con texturas personalizadas. Instala Masque desde CurseForge para activarlo.]=]
L[ [=[Masque addon is not installed.

Masque allows you to skin buff/debuff icons with custom textures. Install Masque from CurseForge to enable.]=] ] = [=[El addon Masque no está instalado.

Masque te permite personalizar los iconos de beneficios/perjuicios con texturas personalizadas. Instala Masque desde CurseForge para activarlo.]=]
L["Masque Integration"] = "Integración con Masque"
L["Match Frame Height"] = "Igualar altura del marco"
L["Match Frame Width"] = "Igualar anchura de marco"
L["Match Health Bar Width/Height"] = "Ajustar la anchura/altura a la barra de salud"
L["Match Owner Height"] = "Igualar altura del dueño"
L["Match Owner Width"] = "Igualar anchura del dueño"
L["Matched (not applied)"] = "Coincide (no aplicado)"
L["Max Buffs"] = "Beneficios máximos"
L["Max Debuffs"] = "Perjuicios máximos"
L["Max Health"] = "Salud máxima"
L["Max Icons"] = "Iconos máximos"
L["Max Length (0=off)"] = "Longitud máxima (0=desactivado)"
L["Max Log Entries"] = "Número máximo de entradas de registro"
L["Max Name Length"] = "Longitud máxima del nombre"
L["Max Slots"] = "Ranuras máximas"
L["Medium"] = "Medio"
L["Medium Health (50%)"] = "Salud media (50%)"
L["Melee DPS"] = "DPS cuerpo a cuerpo"
L["MEMBERS"] = "MIEMBROS"
L["Min Stacks to Show"] = "Acumulaciones mínimas para mostrar"
L["Minimum Log Level"] = "Nivel mínimo de registro"
L["Missing Buff Alpha"] = "Opacidad de beneficio faltante"
L["Missing Buffs"] = "Beneficios faltantes"
L["Missing Health"] = "Salud faltante"
L["Missing Health Alpha"] = "Opacidad de salud faltante"
L["Missing Health Color"] = "Color de salud faltante"
L["Missing Health Only"] = "Solamente la salud faltante"
L["Missing Health Texture"] = "Textura de salud faltante"
L["Mode"] = "Modo"
L["Modified"] = "Modificado"
L["Monk"] = "Monje"
L["Monochrome"] = "Monocromo"
L["Moves the glow to the opposite side (no HP side instead of max HP side)."] = "Mueve el brillo al lado opuesto (el lado sin puntos de salud en vez del lado con salud al máximo)."
L["Multi Select"] = "Selección múltiple"
L["My Group First"] = "Mi grupo primero"
L["My Wizards"] = "Mis asistentes"
L["Mythic"] = "Mítico"
L["Mythic has fixed range"] = "Mítico tiene un rango fijo"
L["Name"] = "Nombre"
L["Name Alpha"] = "Opacidad del nombre"
L["Name already exists"] = "El nombre ya existe"
L["Name Anchor"] = "Anclaje de nombre"
L["Name Color"] = "Color del nombre"
L["Name Text"] = "Texto del nombre"
L["Name Text Alpha"] = "Opacidad del texto del nombre"
L["Name Text Color"] = "Color del texto del nombre"
L["Name X Offset"] = "Desplazamiento X del nombre"
L["Name Y Offset"] = "Desplazamiento Y del nombre"
L["Name:"] = "Nombre:"
L["New"] = "Nueva"
L["New Binding"] = "Atajo nuevo"
L["New Feature: Frame Border Overlay"] = "Nueva característica: Superposición de borde del marco"
L["New Option"] = "Nueva opción"
L["New question"] = "Nueva pregunta"
L["Next"] = "Siguiente"
L["No"] = "No"
L["No %s effects configured."] = "No hay efectos configurados de %s."
L["No action selected"] = "No se ha seleccionado acción"
L["No auto-profile is currently active or being edited."] = "Actualmente no hay ningún perfil automático activo ni en proceso de edición."
L["no branch"] = "sin rama"
L["No built-in wizards available yet. Check back after updates!"] = "Aún no hay asistentes integrados disponibles. ¡Vuelve después de las actualizaciones!"
L["No changelog available."] = "No hay registro de cambios"
L["No custom wizards yet. Click 'New Wizard' to create one!"] = "Aún no hay asistentes personalizados. ¡Haz clic en ‘Nuevo asistente’ para crear uno!"
L["No data to export"] = "No hay datos para exportar"
L["No default profile set"] = "No se ha configurado ningún perfil predeterminado."
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = [=[No hay efectos configurados.
Haz clic en '+ Añadir indicador' para comenzar.]=]
L[ [=[No effects configured yet.
Click '+ Add Indicator' to get started.]=] ] = [=[No hay efectos configurados.
Haz clic en '+ Añadir indicador' para comenzar.]=]
L["No item equipped"] = "No hay objeto equipado"
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = [=[Aún no se han creado grupos de diseño.
Haz clic en '+ Crear grupo' para comenzar.]=]
L[ [=[No layout groups created yet.
Click '+ Create Group' to get started.]=] ] = [=[Aún no se han creado grupos de diseño.
Haz clic en '+ Crear grupo' para comenzar.]=]
L["No layout set. Using global settings."] = "No hay diseño establecido. Se está usando la configuración global."
L["No loadout detected"] = "No se detectó ninguna configuración"
L["No macros match the current filter."] = "No hay macros que coincidan con el filtro actual."
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = [=[Aún no hay macros.
Haz clic en '+ Nuevo' para crear una o en 'Importar' para importar desde WoW.]=]
L[ [=[No macros yet.
Click '+ New' to create one or 'Import' to import from WoW.]=] ] = [=[Aún no hay macros.
Haz clic en '+ Nuevo' para crear una o en 'Importar' para importar desde WoW.]=]
L["No members yet"] = "Aún no hay miembros."
L["No saved position to reset to."] = "No hay posición guardada a la que restablecer."
L["No sound file selected. Choose a sound from the dropdown or enter a custom path."] = "No se ha seleccionado ningún archivo de sonido. Elije un sonido del menú desplegable o introduce una ruta personalizada."
L["No spells available for this class"] = "No hay hechizos disponibles para esta clase"
L["No thanks"] = "No gracias"
L["No wizard selected. Go to 'My Wizards' tab to select or create a wizard first."] = "No hay asistente seleccionado. Ve a la pestaña ‘Mis asistentes’ para seleccionar o crear uno primero."
L["None"] = "Nada"
L["None (no clamping)"] = "Ninguno (sin límite)"
L["None / Physical"] = "Ninguno / Físico"
L["None active (using global settings)"] = "Ninguno activo (utilizando la configuración global)"
L["Normal (BLEND)"] = "Normal (MEZCLAR)"
L["Not Cancelable"] = "No cancelables"
L["Not in a raid group"] = "No estas en un grupo de banda"
L["Not Set"] = "No esta establecido"
L["Note: Cmd + Left Click unavailable on Mac"] = "Nota: La combinación Cmd + Clic izquierdo no está disponible en Mac."
L["Note: Font sizes are not changed. Adjust sizes in each element's page."] = "Nota: Los tamaños de fuente no se modifican. Ajusta los tamaños en la página de cada elemento."
L["Notice"] = "Aviso"
L["Off"] = "Desactivado"
L["Offset X"] = "Desplazamiento X"
L["Offset Y"] = "Desplazamiento Y"
L["OK"] = "Aceptar"
L["Only changed settings will be saved"] = "Solo se guardarán los ajustes modificados."
L["Only Dispellable Debuffs"] = "Solamente perjuicios disipables"
L["Only My Buffs"] = "Solamente mis beneficios"
L["Only show buffs that you cast. Applies to all buff filters."] = "Mostrar solo los beneficios que lanzas. Se aplica a todos los filtros de beneficios"
L["Only Show When Tanking"] = "Mostrar solo al estar tanqueando"
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = "Solo se puede editar el diseño activo mientras los diseños automáticos están en ejecución."
L[ [=[Only the active layout can be edited
while auto layouts are running.]=] ] = "Solo se puede editar el diseño activo mientras los diseños automáticos están en ejecución."
L["OOC"] = "No comb."
L["Open Aura Designer"] = "Abrir diseñador de auras"
L["Open Cast History"] = "Abrir historial de lanzamientos"
L["Open Settings"] = "Abrir configuración"
L["Open Settings Tab"] = "Abrir pestaña de configuración"
L["Open the Profiles tab to manage profiles"] = "Abre la pestaña de perfiles para gestionar perfiles"
L["Open Unit Menu"] = "Abre el menú de la unidad"
L["Open World"] = "Mundo abierto"
L["Opens tab: %s"] = "Abre la pestaña: %s"
L["Option A"] = "Opción A"
L["Option B"] = "Opción B"
L["Options"] = "Opciones"
L["Options:    [S] = Link Setting    [->] = Branch    [x] = Delete"] = "Opciones: [S] = Enlazar ajuste [->] = Rama [x] = Eliminar"
L["Or enter Icon ID:"] = "O introduce el identificador de icono:"
L["Orientation"] = "Orientación"
L["Other"] = "Otros"
L["Other (%d)"] = "Otros (%d)"
L["Other Frames"] = "Otros marcos"
L["Out of combat"] = "Fuera de combate"
L["Out of Combat Only"] = "Solamente fuera de combate"
L["Out of Range"] = "Fuera de rango"
L["Outline"] = "Contorno"
L["Overlaps with \"%s\""] = "Se superpone con \"%s\""
L["Overlaps with \"%s\" (%d-%d)"] = "Se superpone con \"%s\" (%d-%d)"
L["Overlay (on health bar)"] = "Superposición (en la barra de salud)"
L["Overridden by Auto Layout"] = "Sobrescrito por diseño automático"
L["Overridden in this layout"] = "Sobreescrito en este diseño"
L["Override Details"] = "Detalles de sobrescritura"
L["Owner's Class Color"] = "Color de la clase del dueño"
L["Paladin"] = "Paladín"
L["Parse String"] = "Analizar cadena"
L["Party"] = "Grupo"
L["PARTY"] = "GRUPO"
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[Los ajustes de %s de grupo y banda están sincronizados.
Haz clic para dejar de sincronizarlos.]=]
L[ [=[Party & Raid %s settings are synced.
Click to stop syncing.]=] ] = [=[Los ajustes de %s de grupo y banda están sincronizados.
Haz clic para dejar de sincronizarlos.]=]
L["Party to Raid"] = "Grupo a banda"
L["Party: %s"] = "Grupo: %s"
L["Paste a profile string to import:"] = "Pega una cadena de perfil para importar:"
L["Paste the wizard export string below:"] = "Pega la cadena de exportación del asistente a continuación:"
L["Pattern:"] = "Patrón:"
L["Per-aura overrides"] = "Sobrescrituras por aura"
L["Percent"] = "Por ciento"
L["Percentage"] = "Porcentaje"
L["Permanent Mover"] = "Control de arrastre permanente"
L["Per-setting reset is not available for Aura Designer"] = "No se puede restablecer ajustes individualmente en el diseñador de auras"
L["Persist (sec)"] = "Persistir (seg)"
L["Personal Targeted"] = "Dirigidos hacia ti"
L["Personal Targeted Spells"] = "Hechizos dirigidos hacia ti"
L["Pet Frame Settings"] = "Configuración del marco de mascotas"
L["Pet Frames"] = "Marcos de mascota"
L["Pet frames are grouped together in a separate container."] = "Los marcos de mascotas se agrupan en un contenedor aparte."
L["Pet frames are positioned relative to their owner's frame."] = "Los marcos de mascotas se posicionan en relación con el marco de su dueño."
L["Pet Spacing"] = "Espaciado de mascotas"
L["Phased"] = "Faseado"
L["Phased Icon"] = "Icono de faseado"
L["Picked setting: %s%s%s from tab %s%s%s"] = "Ajuste seleccionado: %s%s%s de la pestaña %s%s%s"
L["Pinned Frames"] = "Marcos fijados"
L["Pip Color"] = "Color de los indicadores"
L["Pip Height"] = "Altura de los indicadores"
L["Pixel-Perfect Scaling"] = "Escalado perfecto al píxel"
L["Place %s at %s"] = "Coloca %s en %s"
L["Placed"] = "Colocado"
L["PLACED ON FRAME"] = "COLOCADO EN EL MARCO"
L["PLACEMENT"] = "COLOCACIÓN"
L["Player Range"] = "Rango de jugadores"
L["Players Grow From"] = "Los jugadores crecerán desde el"
L["Players Per Column"] = "Jugadores por columna"
L["Players Per Row"] = "Jugadores por fila"
L["Please enter a profile name."] = "Por favor, introduce un nombre de perfil."
L["Please select an action!"] = "¡Por favor, selecciona una acción!"
L["Poison"] = "Veneno"
L["Position"] = "Posición"
L["Position & anchors"] = "Posición y anclajes"
L["Position managed by: %s"] = "Posición gestionada por: %s"
L["Position reset."] = "Posición restablecida."
L["Power Bar Alpha"] = "Opacidad de la barra de poder"
L["Power Word: Fortitude (Priest)"] = "Palabra de poder: entereza (Sacerdote)"
L["Pre-configure players before they join the group"] = "Preconfigura jugadores antes de que se unan al grupo."
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[Pulsa cualquier tecla, botón del ratón
o mueve la rueda de desplazamiento
(con modificadores si lo deseas)]=]
L[ [=[Press any key, mouse button, or scroll wheel
(with modifiers if desired)]=] ] = [=[Pulsa cualquier tecla, botón del ratón
o mueve la rueda de desplazamiento
(con modificadores si lo deseas)]=]
L["Press Ctrl+A to select all, then Ctrl+C to copy"] = "Pulsa Control+A para seleccionar todo y luego Control+C para copiar."
L["Press Ctrl+C to copy, then Escape to close"] = "Pulsa Control+C para copiar y luego Escape para cerrar."
L["Press key/click/scroll..."] = "Pulsa la tecla/haz clic/desplaza..."
L["Preview"] = "Previsualización"
L["Preview Scale"] = "Escala de previsualización"
L["Preview Sound"] = "Previsualizar sonido"
L["Preview:"] = "Previsualización:"
L["Priest"] = "Sacerdote"
L["Priority"] = "Prioridad"
L["Priority:"] = "Prioridad"
L["Private Aura Overlay Setup"] = "Configuración de superposición de aura privada"
L["Profile \"%s\" has no overrides."] = "El perfil '%s' no tiene sobreescrituras."
L["Profile '%s' already exists."] = "El perfil '%s' ya existe."
L["Profile Actions"] = "Acciones de perfil"
L["Profile imported successfully!"] = "¡Perfil importado correctamente!"
L["Profile matched to loadout"] = "Perfil coincide con el loadout"
L["Profile Name"] = "Nombre del perfil"
L["Profile not found"] = "Perfil no encontrado"
L["Profile Settings"] = "Configuración de perfil"
L["Profile:"] = "Perfil:"
L["Profile: %s"] = "Perfil: %s"
L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[Perfil: %s%s%s
%s%d compatible%s %s%d incompatible%s %s%d total%s]=]
L[ [=[Profile: %s%s%s
%s%d compatible%s   %s%d incompatible%s   %s%d total%s]=] ] = [=[Perfil: %s%s%s
%s%d compatible%s %s%d incompatible%s %s%d total%s]=]
L["Profiles"] = "Perfiles"
L["Pull Timer"] = "Temporizador para iniciar combate"
L["Pull Timer Duration"] = "Duración del temporizador para iniciar combate"
L["Pulsate"] = "Pulsante"
L["Pulsate Border"] = "Borde pulsante"
L["Pulse"] = "Pulso"
L["Pulse Animation"] = "Animación de pulso"
L["Question"] = "Pregunta"
L["Question:"] = "Pregunta:"
L["Quick Bind"] = "Atajo rápido"
L["Quick Bind Mode"] = "Modo de atajo rápido"
L["Quick Macro"] = "Macro rápida"
L["Quick Macro Builder"] = "Creador rápido de macros"
L["Quick Switch CC Profile"] = "Cambio rápido de perfil de lanzamiento por clic"
L["Quick Switch Profile"] = "Cambio rápido de perfil"
L["Rage"] = "Ira"
L["Raid"] = "Banda"
L["RAID"] = "BANDA"
L["Raid Auto Layouts"] = "Diseños automáticos de banda"
L["Raid Buffs"] = "Beneficios de banda"
L["Raid Debuffs"] = "Perjuicios de banda"
L["Raid frames centered."] = "Marcos de banda centrados."
L["Raid Group Labels"] = "Etiquetas de grupo de banda"
L["Raid In Combat"] = "Banda en combate"
L["Raid Layout Mode"] = "Modo de diseño de banda"
L["Raid position reset."] = "Restablecida posición de la banda"
L["Raid Role (MT/MA)"] = "Rol en banda (TP/AP)"
L["Raid Role Icon (MT/MA)"] = "Icono de rol en banda (TP/AP)"
L["Raid Target Icon"] = "Icono de objetivo de banda"
L["Raid to Party"] = "Banda a grupo"
L["Raid: %s"] = "Banda: %s"
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = "Banda: El diseño de grupo ordena dentro de cada grupo. El diseño de cuadrícula plana ordena a todos los jugadores juntos."
L[ [=[Raid: Group layout sorts within each group.
Flat grid layout sorts all players together.]=] ] = "Banda: El diseño de grupo ordena dentro de cada grupo. El diseño de cuadrícula plana ordena a todos los jugadores juntos."
L["Raids"] = "Bandas"
L["Raids, battlegrounds (1-40)"] = "Bandas, campos de batalla (1-40)"
L["Range Check Interval"] = "Intervalo de comprobación de rango"
L["Range Check Spell"] = "Hechizo de comprobación de rango"
L["Ranged DPS"] = "DPS a distancia"
L["Ready Check"] = "Comprobación de listos"
L["Ready Check Icon"] = "Icono de comprobación de listos"
L["Ready to copy"] = "Listo para copiar"
L["Recovered %d raid settings from interrupted auto layout editing session."] = "Se recuperaron %d ajustes de raid de la sesión de edición de diseño automático interrumpida"
L["Refresh"] = "Refrescar"
L["Reload UI"] = "Recargar interfaz"
L["Remove all bindings from the current profile."] = "Eliminar todos los atajos del perfil actual"
L["Remove Offline"] = "Eliminar descon."
L["Removes all Aura Designer overrides from this auto layout, restoring it to match your global profile."] = "Elimina todas las modificaciones del diseñador de auras de este diseño automático, restaurándolo para que coincida con tu perfil global."
L["Removes your player frame from the DandersFrames party display."] = "Elimina tu marco de jugador del marco de grupo de DanderFrames."
L["Rename"] = "Renombrar"
L["Replace"] = "Reemplazar"
L["Replace Blizzard's color picker with the DandersFrames color picker for this addon."] = "Reemplaza el selector de color de Blizzard por el selector de color de DandersFrames para este addon."
L["Replace Buffs"] = "Reemplazar beneficios"
L["Res + Mass"] = "Res + Masa"
L["Res + Mass + Combat"] = "Res + Masa + Combate"
L["Reset"] = "Restablecer"
L["Reset All Aura Configs"] = "Restablecer todas las configuraciones de auras"
L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[¿Deseas restablecer todos los ajustes del diseñador de auras en este diseño automático para que coincidan con tu perfil global?

Esta acción es irreversible.]=]
L[ [=[Reset all Aura Designer settings in this auto layout to match your global profile?

This cannot be undone.]=] ] = [=[¿Deseas restablecer todos los ajustes del diseñador de auras en este diseño automático para que coincidan con tu perfil global?

Esta acción es irreversible.]=]
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[¿Restablecer todos los atajos a los valores predeterminados?

Esto configurará:
• Clic izquierdo = Seleccionar objetivo
• Clic derecho = Abrir menú 

%sEsto no se puede deshacer.%s]=]
L[ [=[Reset all bindings to defaults?

This will set:
• Left Click = Target Unit
• Right Click = Open Menu

%sThis cannot be undone.%s]=] ] = [=[¿Restablecer todos los atajos a los valores predeterminados?

Esto configurará:
• Clic izquierdo = Seleccionar objetivo
• Clic derecho = Abrir menú 

%sEsto no se puede deshacer.%s]=]
L["Reset All to Default"] = "Restablecer todo a valores predeterminados"
L["Reset Aura Designer to Global"] = "Restablecer el diseñador de auras a la configuración global"
L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[¿Restablecer el perfil actual a los valores predeterminados?
Esto restablecerá tanto la configuración de grupo como la de banda.]=]
L[ [=[Reset current profile to defaults?
This will reset BOTH Party and Raid settings.]=] ] = [=[¿Restablecer el perfil actual a los valores predeterminados?
Esto restablecerá tanto la configuración de grupo como la de banda.]=]
L["Reset Position"] = "Restablecer posición"
L["Reset Profile to Defaults"] = "Restablecer perfil a valores predeterminados"
L["Reset to Defaults"] = "Restablecer valores predeterminados"
L["Reset to Global"] = "Restablecer a la global"
L["Reset to Global Order"] = "Restablecer al orden global"
L["Resource Bar"] = "Barra de recursos"
L["Resource Bar Settings"] = "Configuración de la barra de recursos"
L["Resource Colors"] = "Colores de recursos"
L["Rested Indicator"] = "Indicador de descanso"
L["Resurrection"] = "Resurrección"
L["Resurrection Icon"] = "Icono de resurrección"
L["Resurrection Icon Tooltips"] = "Desc. emergentes de icono de resurrección"
L["Reverse Fill"] = "Llenado inverso"
L["Reverse Fill Direction"] = "Dirección de llenado inverso"
L["Reverse Order"] = "Orden inverso"
L["Reverse Overlay Fill"] = "Relleno de superposición inverso"
L["Reverse Position"] = "Relleno invertido"
L["Right"] = "Derecha"
L["Right Click"] = "Clic derecho"
L["Right Edge"] = "Borde derecho"
L["Right of Health Bar"] = "A la derecha de la barra de salud"
L["Right of Owner"] = "A la derecha del dueño"
L["Right of Party"] = "A la derecha del grupo"
L["Right of Raid"] = "A la derecha de la banda"
L["Right to Left"] = "Derecha a izquierda"
L["Right-click"] = "Clic derecho"
L["Right-click: Edit/View"] = "Clic derecho: Editar/Ver"
L["Rogue"] = "Pícaro"
L["Role Icon"] = "Icono de rol"
L["Role Priority"] = "Prioridad de rol"
L["Row Spacing"] = "Espaciado de filas"
L["Rows"] = "Filas"
L["Rows Grow From"] = "Las filas crecerán desde el"
L["Run"] = "Ejecutar"
L["Run Overlay Setup Wizard"] = "Ejecutar asistente de config. de superposición"
L["Run Script"] = "Ejecutar script"
L["Run Setup Wizard"] = "Ejecutar asistente"
L["Runic Power"] = "Poder Rúnico"
L["Runtime"] = "Tiempo de ejecución"
L["Save"] = "Guardar"
L["Save & Close"] = "Guardar y cerrar"
L["Save Changes"] = "Guardar cambios"
L["Scale"] = "Escala"
L["Script Runner"] = "Ejecutor de scripts"
L["Search fonts..."] = "Buscar fuentes..."
L["Search sounds..."] = "Buscar sonidos..."
L["Search spells..."] = "Busca hechizos..."
L["Search textures..."] = "Buscar texturas..."
L["Search..."] = "Buscar..."
L["Seconds"] = "Segundos"
L["See Also:"] = "Ver también:"
L["Select a destination"] = "Selecciona un destino"
L["Select a spell"] = "Selecciona un hechizo"
L["Select a step to edit"] = "Selecciona un paso para editar"
L["Select All Text"] = "Seleccionar todo el texto"
L["Select any tab"] = "Selecciona cualquier pestaña"
L["Select Class"] = "Seleccionar clase"
L["Select indicator..."] = "Seleccionar indicador..."
L["Select or create a wizard"] = "Selecciona o crea un asistente"
L["Select trigger for %s"] = "Selecciona un disparador para %s"
L["Select which spell to use for range checking. Auto will use your spec's default healing/friendly spell."] = "Selecciona qué hechizo usar para comprobar el rango. La opción Automático usará el hechizo de sanación/amistoso predeterminado de tu especialización."
L["Select..."] = "Seleccionar..."
L["Selected: %d"] = "Seleccionado: %d"
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[Al seleccionar una opción, se desactivarán los
demás addons y se recargará la interfaz de usuario.]=]
L[ [=[Selecting an option will disable the other addon(s)
and reload your UI.]=] ] = [=[Al seleccionar una opción, se desactivarán los
demás addons y se recargará la interfaz de usuario.]=]
L["Selection Highlight"] = "Resaltado de selección"
L["Selection Settings"] = "Configuración de selección"
L["Self Position"] = "Posición propia"
L["Separate Melee & Ranged DPS"] = "DPS cuerpo a cuerpo y a distancia por separado"
L["Separate Pet Group"] = "Grupo de mascotas separado"
L["Set a font and outline style, then click Apply to update ALL text elements."] = "Establece un estilo de fuente y de contorno, y luego haz clic en Aplicar para actualizar TODOS los elementos de texto."
L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[Ajuste: %s 
Valor actual: %s 

Introduce el valor a establecer, o resaltarlo para el usuario]=]
L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[Ajuste: %s 
Valor actual: %s 

¿Que debería ocurrir cuando '%s' sea seleccionado?]=]
L[ [=[Setting: %s
Current value: %s

Enter the value to set, or highlight for the user.]=] ] = [=[Ajuste: %s 
Valor actual: %s 

Introduce el valor a establecer, o resaltarlo para el usuario]=]
L[ [=[Setting: %s
Current value: %s

What should happen when '%s' is selected?]=] ] = [=[Ajuste: %s 
Valor actual: %s 

¿Que debería ocurrir cuando '%s' sea seleccionado?]=]
L["Settings"] = "Configuraciones"
L["Settings to Apply"] = "Configuraciones a aplicar"
L["Setup Wizards"] = "Configurar asistentes"
L["Shadow"] = "Sombra"
L["Shadow Color"] = "Color de sombra"
L["Shadow Settings"] = "Configuración de sombras"
L["Shadow settings are controlled in General > Global Fonts."] = "La configuración de las sombras se controla en General > Fuentes globales."
L["Shadow X Offset"] = "Desplazamiento X de sombra"
L["Shadow Y Offset"] = "Desplazamiento Y de sombra"
L["Shaman"] = "Chamán"
L["Shared"] = "Compartido"
L["Shared Border"] = "Borde compartido"
L["Shift+Left Click"] = "Mayúsculas+Clic izquierdo"
L["Shift+Right Click"] = "Mayúsculas+Clic derecho"
L["Show a pulsing yellow glow around the frame."] = "Muestra un brillo amarillo pulsante alrededor del marco."
L["Show All Roles Out of Combat"] = "Mostrar todos los roles fuera de combate"
L["Show as Text"] = "Mostrar como texto"
L["Show Background"] = "Mostrar fondo"
L["Show Border"] = "Mostrar borde"
L["Show Buffs"] = "Mostrar beneficios"
L["Show Cooldown Swipe"] = "Mostrar barrido de reutilización"
L["Show Debuffs"] = "Mostrar perjuicios"
L["Show Dispel Icon"] = "Mostrar icono de disipación"
L["Show DPS"] = "Mostrar DPS"
L["Show Duration"] = "Mostrar duración"
L["Show Duration Numbers"] = "Mostrar números de duración"
L["Show Duration Text"] = "Mostrar texto de duración"
L["Show every buff with no filtering."] = "Mostrar todos los beneficios sin filtrar."
L["Show every debuff with no filtering."] = "Mostrar todos los perjuicios sin filtrar"
L["Show Expiring Border"] = "Mostrar borde de expiración"
L["Show Expiring Tint"] = "Mostrar tinte de expiración"
L["Show for Roles"] = "Mostrar para los roles"
L["Show Frame Border"] = "Mostrar borde del marco"
L["Show Gradient"] = "Mostrar degradado"
L["Show Group Label"] = "Mostrar etiqueta de grupo."
L["Show Healer"] = "Mostrar sanador"
L["Show health bars for player and party/raid member pets, anchored to their owner's frame. Pet frames hide when owner dies."] = "Muestra las barras de salud de las mascotas del jugador y de los miembros del grupo/banda, ancladas al marco de su dueño. Los marcos de las mascotas se ocultan cuando el dueño muere."
L["Show Health Percentage"] = "Mostrar porcentaje de salud"
L["Show in content types:"] = "Mostrar en los siguientes tipos de contenido:"
L["Show in Solo Mode"] = "Mostrar en modo individual"
L["Show Interrupted Visual"] = "Mostrar visual de interrupción"
L["Show Label"] = "Mostrar etiqueta"
L["Show LFG Eye for Cross-Instance"] = "Muestra el ojo del buscador de grupos para instancias conectadas"
L["Show Main Assist"] = "Mostrar asistente principal"
L["Show Main Tank"] = "Mostrar tanque principal"
L["Show Minimap Button"] = "Mostrar botón en el minimapa"
L["Show On Current Health Only"] = "Mostrar solamente en la salud actual"
L["Show on Hover Only"] = "Mostrar unicamente al pasar el ratón"
L["Show Overheal"] = "Mostrar exceso de sanación"
L["Show Overlay For"] = "Mostrar superposición para"
L["Show Overshield Glow"] = "Mostrar resplandor de sobreescudo"
L["Show Party/Raid Side Menu"] = "Mostrar menú lateral de grupo/banda"
L["Show rested indicators when in a rested area (inn, city)."] = "Mostrar indicadores de descanso cuando estas en una zona de descanso (posada, ciudad)."
L["Show Shadow"] = "Mostrar sombra"
L["Show Stacks"] = "Mostrar acumulaciones"
L["Show Tank"] = "Mostrar tanque"
L["Show the animated ZZZ icon on the player frame."] = "Muestra el icono animado ZZZ en el marco del jugador."
L["Show the DF color picker when any addon opens a color picker."] = "Mostrar el selector de color de DF cuando cualquier addon abra un selector de color."
L["Show Timer"] = "Mostrar temporizador"
L["Show When Missing"] = "Mostrar cuando falte"
L["Show X Mark"] = "Mostrar marca de la X"
L["Show:"] = "Mostrar:"
L["Shows a border ring around the entire frame when a boss debuff is active."] = "Muestra un anillo bordeando alrededor de todo el marco cuando un perjuicio de jefe está activo."
L["Shows a colored border/glow when a dispellable debuff is present."] = "Muestra un borde/brillo de color cuando hay un perjuicio disipable presente."
L["Shows a glow at max health when absorb exceeds the clamp limit."] = "Muestra un resplandor al máximo de salud cuando el escudo de absorción excede el límite máximo."
L["Shows an icon when an enemy is casting a spell targeting a party/raid member."] = "Muestra un icono cuando un enemigo lanza un hechizo dirigido a un miembro del grupo o de la banda."
L["Shows an icon when party members have a defensive cooldown active (Pain Suppression, Ironbark, etc.)."] = "Muestra un icono cuando los miembros del grupo tienen una habilidad defensiva activa (Supresión del dolor, Corteza de hierro, etc.)."
L["Shows effects that reduce incoming healing (like Necrotic stacks)."] = "Muestra efectos que reducen la curación recibida (como las acumulaciones de necrótica)."
L["Shows icon when party members are missing raid buffs."] = "Muestra un icono cuando a miembros del grupo les faltan beneficios de banda"
L["Shows incoming targeted spells on YOU in the center of your screen."] = "Muestra los hechizos dirigidos hacia TI en el centro de la pantalla."
L["Shows the ping wheel & party management menu."] = "Muestra la rueda de ping y el menú de gestión del grupo."
L["Single Select"] = "Selección individual"
L["Size"] = "Tamaño"
L["Size & Orientation"] = "Tamaño y orientación"
L["Size & Spacing"] = "Tamaño y espaciado"
L["Skip for now"] = "Omitir por ahora"
L["Skyfury (Shaman)"] = "Furia del cielo (Chamán)"
L["Smart Res:"] = "Res. inteligente:"
L["Smart Resurrection"] = "Resurrección inteligente"
L["Smooth Bar Animation"] = "Animación suave de la barra"
L["Snaps sizes and borders to exact pixels for crisp rendering."] = "Ajusta los tamaños y los bordes a los píxeles exactos para una representación nítida."
L["Solid (BLEND)"] = "Solido (MEZCLAR)"
L["Solid Border"] = "Borde solido"
L["Solo Mode"] = "Modo individual"
L["Solo mode %s"] = "Modo individual %s"
L["Solo Mode: Show your player frame when not in a group."] = "Modo individual: Muestra tu marco de jugador cuando no estas en un grupo."
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[Algunos atajos usan hechizos que no están 
disponibles para tu clase o especialización actual.]=]
L[ [=[Some bindings use spells that are not available
to your current class or specialization.]=] ] = [=[Algunos atajos usan hechizos que no están 
disponibles para tu clase o especialización actual.]=]
L["Sort by Class (within role)"] = "Ordenar por clase (dentro de cada rol)"
L["Sort Order"] = "Ordenar por"
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[Ordenar a los miembros del grupo por rol, clase y nombre.
Orden: Posición propia > Rol > Clase > Nombre]=]
L[ [=[Sort party members by role, class, and name.

Sort order: Self Position > Role > Class > Name]=] ] = [=[Ordenar a los miembros del grupo por rol, clase y nombre.
Orden: Posición propia > Rol > Clase > Nombre]=]
L["Sorted with Group"] = "Ordenado con el grupo"
L["Sorting"] = "Ordenar"
L["Sound"] = "Sonido"
L["Sound Alert"] = "Alerta de sonido"
L["Sound Alerts"] = "Alertas de sonido"
L["Sound file could not be played: %s"] = "No se pudo reproducir el archivo de sonido: %s"
L["Source Mode"] = "Modo fuente"
L["Spacing"] = "Espaciado"
L["Spacing X"] = "Espaciado X"
L["Spacing Y"] = "Espaciado Y"
L["Spark"] = "Chispa"
L["Spec Default"] = "Predeterminado de especialización"
L["Spec:"] = "Especialización:"
L["Specialization data not available."] = "Datos de especialización no disponibles."
L["Spell:"] = "Hechizo"
L["Spells"] = "Hechizos"
L["Spells flagged as important by Blizzard."] = "Hechizos marcados como importantes por Blizzard."
L["Square"] = "Cuadrado"
L["Stack Anchor"] = "Anclaje de acumulaciones"
L["Stack Count"] = "Contador de acumulaciones"
L["Stack Font"] = "Fuente de acumulaciones"
L["Stack Minimum"] = "Acumulaciones mínimas"
L["Stack Offset X"] = "Desplazamiento X de las acumulaciones"
L["Stack Offset Y"] = "Desplazamiento Y de las acumulaciones"
L["Stack Outline"] = "Contorno de acumulaciones"
L["Stack Scale"] = "Escala de acumulaciones"
L["Stack Text"] = "Texto de acumulaciones"
L["Stack Text Color"] = "Color del texto de acumulaciones"
L["Standard Buffs are also visible on frames."] = "Los beneficios estándar también están visibles en los marcos."
L["START"] = "INICIO"
L["Start"] = "Inicio"
L["Start (Left/Top)"] = "Inicio (Izquierda/Arriba)"
L["Start = Left/Top, End = Right/Bottom depending on direction."] = "Inicio = Izquierda/Arriba, Final = Derecha/Abajo dependiendo de la dirección"
L["Start Delay (sec)"] = "Retraso de inicio (segundos)"
L["Start of Group"] = "Al inicio del grupo"
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[Inicio: encima/izquierda de los grupos.
Centro: en el medio del grupo.
Fin: debajo/derecha de los grupos.]=]
L[ [=[Start: Above/left of groups.
Center: Middle of the group.
End: Below/right of groups.]=] ] = [=[Inicio: encima/izquierda de los grupos.
Centro: en el medio del grupo.
Fin: debajo/derecha de los grupos.]=]
L["Status Icon Text Settings"] = "Configuración del texto del icono de estado"
L["Status Text"] = "Texto de estado"
L["Status Text (Dead/Offline)"] = "Texto de estado (muerto/desconectado)"
L["Status Text Alpha"] = "Opacidad del texto de estado"
L["Step %d of %d"] = "Paso %d de %d"
L["Step 1: Click here with desired key combo"] = "Paso 1: Haz clic aquí con la combinación de teclas deseada"
L["Step 2: Select Action"] = "Paso 2: Selecciona la acción"
L["Step 3: Combat Condition (optional)"] = "Paso 3: Condición de combate (opcional)"
L["Step Editor"] = "Editor de pasos"
L["Step ID"] = "ID del paso"
L["Steps"] = "Pasos"
L["Style"] = "Estilo"
L["Summary"] = "Resumen"
L["Summary Step"] = "Resumen de paso"
L["Summon"] = "Invocar"
L["Summon Icon"] = "Icono de invocar"
L["Switched to profile: %s"] = "Perfil cambiado: %s"
L["Sync"] = "Sincronizar"
L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[¿Sincronizar los ajustes de %s?

Esto copiará los ajustes actuales de %s a %s y los mantendrá sincronizados.]=]
L[ [=[Sync %s settings?

This will copy current %s settings to %s and keep them in sync.]=] ] = [=[¿Sincronizar los ajustes de %s?

Esto copiará los ajustes actuales de %s a %s y los mantendrá sincronizados.]=]
L["Sync from WoW"] = "Sinc. desde WoW"
L["Sync with %s"] = "Sincr. con %s"
L["Sync: %s"] = "Sincronizar: %s"
L["Synced with %s"] = "Sincr. con %s"
L["Synced: %s"] = "Sincronizado: %s"
L["Tank"] = "Tanque"
L["Tanking (Red)"] = "Tanqueo (Rojo)"
L["Tanks"] = "Tanques"
L["Target Type:"] = "Tipo de Objetivo:"
L["Target Unit"] = "Seleccionar objetivo"
L["Targeted Spell Alpha"] = "Opacidad de hechizos dirigidos"
L["Targeted Spell Click-Through"] = "Clic a través de hechizos dirigidos"
L["Targeted Spells"] = "Hechizos dirigidos"
L["Targeted Spells (on frames)"] = "Hechizos dirigidos (en marcos)"
L["Targeting Fallback:"] = "Apuntado de último recurso:"
L["Targeting: %s"] = "Objetivo: %s"
L["Test"] = "Prueba"
L["Test Mode"] = "Modo de pruebas"
L["Test mode disabled."] = "Modo de pruebas desactivado."
L["Test mode enabled."] = "Modo de pruebas activado."
L["Test mode ended — entering combat."] = "Modo de pruebas finalizado — entrando en combate."
L["Test Mode: %s"] = "Modo de pruebas: %s"
L["Text"] = "Texto"
L["Text Color"] = "Color de texto"
L["Text Colors:"] = "Colores de texto"
L["Text Format"] = "Formato de texto"
L["Text Scale"] = "Escala de texto"
L["Texture"] = "Textura"
L["Texture & Colors"] = "Textura y Colores"
L["The first image shows the overlay border active on a frame. The second shows the standard boss debuff icon only."] = "La primera imagen muestra el borde superpuesto activo en un marco. La segunda muestra únicamente el icono estándar de perjuicio de jefe."
L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[La superposición de borde del marco es renderizada completamente por Blizzard y tiene algunas peculiaridades visuales que no se pueden corregir: 

%sBordes naranjas%s aparecerán para los perjuicios de jefe que %sno se pueden disipar%s. Solo los perjuicios disipables muestran el borde de color estándar.

El %stexto flotante del contador de acumulaciones%s puede aparecer en el marco, separado del icono.

La superposición no es una solución perfecta y puede verse mal en algunos encuentros. Actívala bajo tu propia responsabilidad.]=]
L[ [=[The frame border overlay is rendered entirely by Blizzard and has some visual quirks that cannot be fixed:

%sOrange borders%s will appear for boss debuffs that are %snot dispellable%s. Only dispellable debuffs show the standard coloured border.

Floating %sstack count text%s may appear on the frame, separate from the icon.

The overlay is not a perfect solution and may look rough in some encounters. Enable at your own risk.]=] ] = [=[La superposición de borde del marco es renderizada completamente por Blizzard y tiene algunas peculiaridades visuales que no se pueden corregir: 

%sBordes naranjas%s aparecerán para los perjuicios de jefe que %sno se pueden disipar%s. Solo los perjuicios disipables muestran el borde de color estándar.

El %stexto flotante del contador de acumulaciones%s puede aparecer en el marco, separado del icono.

La superposición no es una solución perfecta y puede verse mal en algunos encuentros. Actívala bajo tu propia responsabilidad.]=]
L["These settings apply when using 'Shadow' outline style. Use larger offsets for more dramatic shadows."] = "Estos ajustes se aplican al usar el estilo de contorno \"Sombra\". Utiliza desplazamientos mayores para obtener sombras más pronunciadas."
L["Thick Outline"] = "Contorno grueso"
L["Thickness"] = "Grosor"
L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[Esta característica añade un borde alrededor de todo el marco de la unidad cuando las auras privadas de perjuicio de jefe están activas.

Importante: El borde aparecerá para TODOS los perjuicios de jefe, no solo para los que se pueden disipar. Los perjuicios que no se pueden disipar muestran un borde sólido.

La apariencia del borde la controla Blizzard y no se puede personalizar; solo se puede ajustar el tamaño.

¿Te gustaría configurar esta función ahora?]=]
L[ [=[This feature adds a border around the entire unit frame when private aura boss debuffs are active.

Important: The border will appear for ALL boss debuffs, not just dispellable ones. Non-dispellable debuffs show a solid border.

The appearance of the border is controlled by Blizzard and cannot be customised — only the size can be adjusted.

Would you like to set up this feature now?]=] ] = [=[Esta característica añade un borde alrededor de todo el marco de la unidad cuando las auras privadas de perjuicio de jefe están activas.

Importante: El borde aparecerá para TODOS los perjuicios de jefe, no solo para los que se pueden disipar. Los perjuicios que no se pueden disipar muestran un borde sólido.

La apariencia del borde la controla Blizzard y no se puede personalizar; solo se puede ajustar el tamaño.

¿Te gustaría configurar esta función ahora?]=]
L["this option"] = "esta opción"
L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[Perfil creado para %s%s%s. 
Algunos atajos podrían no funcionar con %s%s%s]=]
L[ [=[This profile was created for %s%s%s.
Some bindings may not be compatible with %s%s%s.]=] ] = [=[Perfil creado para %s%s%s. 
Algunos atajos podrían no funcionar con %s%s%s]=]
L["This setting differs from the global profile value. Click the reset button to revert."] = "Este ajuste difiere del valor del perfil global. Haz clic en el botón de reinicio para restaurarlo."
L["This setting is being overridden by the active auto layout profile. To change it, edit the profile in the Auto Layouts tab."] = "Este ajuste está siendo sobrescrito por el perfil activo de diseño automático. Para cambiarlo, edita el perfil en la pestaña de diseños automáticos."
L["This step automatically shows a review of all the user's answers. It's always the last step."] = "Este paso muestra automáticamente un resumen de todas las respuestas del usuario. Siempre es el último paso."
L["This warning will not appear again after confirming."] = "Este aviso no volverá a mostrarse después de confirmarlo."
L["Threat Colors"] = "Colores de amenaza"
L["Threshold Mode"] = "Modo de umbral"
L["Time Remaining"] = "Tiempo restante"
L["Timing"] = "Temporización"
L["Tint"] = "Tinte"
L["Tint Color"] = "Color del tinte"
L["Tint Opacity"] = "Opacidad del tinte"
L[ [=[to customise
this profile's settings]=] ] = "para personalizar la configuración de este perfil"
L[ [=[to customise
this profile's settings]=] ] = "para personalizar la configuración de este perfil"
L["To fix the ElvUI compatibility issue:"] = "Para solucionar el problema de compatibilidad de ElvUI:"
L["To reposition: Unlock frames (/df unlock) and drag the mover."] = "Para reposicionarlo: Desbloquea los marcos (/df unlock) y arrastra el elemento"
L["Toggle Solo Mode"] = "Activar/desactivar el modo individual"
L["Toggle Test Mode"] = "Activar/desactivar el modo de prueba"
L["Tooltips"] = "Descrip. emergentes"
L["Top"] = "Arriba"
L["Top Edge"] = "Borde superior"
L["Top Left"] = "Arriba a la izquierda"
L["Top Right"] = "Arriba a la derecha"
L["Top to Bottom"] = "De arriba hacia abajo"
L["Total:"] = "Total:"
L["Track Highest Duration"] = "Rastrear duración más larga"
L["Track Lowest Duration"] = "Rastrear duración más corta"
L["Trigger"] = "Disparador"
L["Trigger Mode"] = "Modo de disparador"
L["TRIGGERED BY"] = "DISPARADO POR"
L["Truncate Mode"] = "Modo de truncado"
L["Truncation"] = "Truncamiento"
L["Type"] = "Tipo"
L["Type /dfarena again to disable"] = "Escribe /dfarena de nuevo para desactivar"
L["Type:"] = "Tipo:"
L["UI Scale:"] = "Escala de IU:"
L["Unit Frame"] = "Marco de unidad"
L["Unit Frame Sorting"] = "Ordenar marcos de unidades"
L["Unit Selection"] = "Selección de unidad"
L["Units at or above this health percent are faded."] = "Las unidades que alcancen o superen este porcentaje de salud se muestran atenuadas."
L["Units Per Row"] = "Unidades por fila"
L["Unknown"] = "Desconocido"
L["Unknown error"] = "Error desconocido"
L["Unlock"] = "Desbloq."
L["Unlock Frames"] = "Desbloquear marcos"
L["Unnamed"] = "Sin nombre"
L["Up"] = "Arriba"
L["Use"] = "Usar"
L["USE"] = "USO"
L["Use %s"] = "Utilizar %s"
L["Use /df overrides for full details in chat"] = "Usa /df overrides para obtener todos los detalles en el chat."
L["Use Class Color"] = "Utilizar color de clase"
L["Use Current (%s)"] = "Usar actual (%s)"
L["Use Current Value"] = "Usar valor actual"
L["Use Custom Colors"] = "Utilizar colores personalizados"
L["Use Custom Pip Color"] = "Usar color personalizado para los indicadores"
L["Use DandersFrames"] = "Utilizar DandersFrames"
L["Use DF Color Picker"] = "Utilizar el selector de color de DF"
L["Use DF Color Picker for All Addons"] = "Utilizar el selector de color de DF para todos los addons"
L["Use FrameSort Addon"] = "Utilizar addon FrameSort"
L["Use Group-Based Layout"] = "Usar diseño basado en grupos"
L["Use recommended defaults"] = "Usar valores predeterminados recomendados"
L["Use Seconds Instead of Percent"] = "Usar segundos en vez de porcentaje"
L["Uses a single border per frame. Highest priority wins."] = "Usa un solo borde por marco. Gana el de mayor prioridad."
L["Uses cast tracking to identify spells WoW marks as secret. Only tracks your own casts."] = "Usa el seguimiento de lanzamientos para identificar hechizos que WoW marca como secretos. Solo rastrea tus propios lanzamientos."
L["Uses party frame settings/position"] = "Usa los ajustes/posición del marco de grupo"
L["Using highest duration trigger"] = "Usando el disparador de mayor duración"
L["Using lowest duration trigger"] = "Usando el disparador de menor duración"
L["Using spec default"] = "Utilizando el predeterminado de especialización"
L["v%s loaded. Type %s/df%s for settings, %s/df resetgui%s if window is offscreen."] = "v%s cargado. Escribe %s/df%s para abrir la configuración, %s/df resetgui%s si la ventana está fuera de pantalla."
L["Valid range"] = "Rango válido"
L["Value:"] = "Valor:"
L["Vehicle"] = "Vehículo"
L["Vehicle Icon"] = "Icono de vehículo"
L["Vertical"] = "Vertical"
L["Vertical Spacing"] = "Espaciado vertical"
L["View Imported Macro"] = "Ver macro importada"
L["Visibility"] = "Visibilidad"
L["Volume"] = "Volumen"
L["Warlock"] = "Brujo"
L["Warnings + Errors"] = "Advertencias y errores"
L["Warrior"] = "Guerrero"
L["Weight"] = "Peso"
L["What should '%s' do with this setting?"] = "¿Que debería hacer '%s' con este ajuste?"
L["When \"%s\" selected:"] = "Cuando se selecciona “%s”:"
L["When auto-detect is OFF, select which raid buffs to monitor manually."] = "Cuando la detección automática esta DESACTIVADA, selecciona manualmente qué beneficios de banda quieres comprobar."
L["When disabled: Click spell to open Binding Editor."] = "Cuando está desactivado: haz clic en el hechizo para abrir el editor de asignación de atajos."
L["When enabled, a new profile will be automatically"] = "Cuando esta activado, un nuevo perfil será automaticamente"
L["When enabled, all pips use a single custom color instead of the class-specific default."] = "Cuando está activado, todos los indicadores usan un único color personalizado en lugar del color predeterminado de la clase."
L["When enabled, all role icons are shown outside of combat. The filters below only apply during combat."] = "Cuando está activado, todos los iconos de rol se muestran fuera de combate. Los filtros a continuación solo se aplican durante el combate."
L["When enabled, click-casting bindings will be"] = "Cuando está activado, los atajos de lanzamiento por clic serán"
L["When enabled, Masque skins aura icons and borders. DF border settings will be disabled."] = "Cuando está activado, Masque modifica los iconos y bordes de auras. La configuración de bordes de DF se desactivará."
L["When enabled, shows incoming heals even if they would overheal."] = "Cuando está activada, muestra las sanaciones entrantes incluso si sanan en exceso."
L["When enabled, the group you are in will always be displayed first."] = "Cuando está activado, el grupo en el que te encuentras siempre se mostrará primero."
L["When enabled: Click spell, press key to bind instantly."] = "Cuando está activado: haz clic en el hechizo y pulsa una tecla para vincularlo al instante."
L["When you enter matching content, the layout's overrides are applied on top of your global settings. If no layout matches, global settings are used as-is."] = "Al acceder a contenido coincidente, las modificaciones del diseño se aplican encima de la configuración global. Si ningún diseño coincide, se utiliza la configuración global tal cual."
L["Which aura data source would you like to use?"] = "¿Qué fuente de datos de auras te gustaría utilizar?"
L["While editing, each setting shows its override status:"] = "Durante la edición, cada configuración muestra su estado de sobreescritura:"
L["Whitelist buffs take priority for the expiring indicator."] = "Los beneficios de la lista blanca se priorizan en el indicador de expiración."
L["WHITELISTED"] = "EN LISTA BLANCA"
L["Whole Alpha Pulse"] = "Pulso de opacidad completo"
L["Width"] = "Anchura"
L["Width / Length"] = "Anchura / Largo"
L["Will auto-create on switch"] = "Crearán autom. al cambiar"
L["Will replace existing Mythic layout"] = "Reemplazará el diseño actual de Mítico"
L["Wizard"] = "Asistente"
L["Wizard '%s' saved!"] = "¡Asistente '%s' guardado!"
L["Wizard Builder"] = "Constructor de asistentes"
L["Wizard Details"] = "Detalles del asistente"
L["Wizard Name:"] = "Nombre del asistente:"
L["Works when hovering frames. Action bars work when not hovering."] = "Funciona al pasar el cursor sobre los marcos. Las barras de acción funcionan cuando no se pasa el cursor."
L["World bosses, outdoor raids (1-40)"] = "Jefes de mundo, bandas al aire libre (1-40)"
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = "¿Prefieres mantener los iconos de beneficio estándar junto con el diseñador de auras, o que los reemplace por completo?"
L[ [=[Would you like to keep standard buff icons alongside
Aura Designer, or let it fully replace them?]=] ] = "¿Prefieres mantener los iconos de beneficio estándar junto con el diseñador de auras, o que los reemplace por completo?"
L["Would you like to set up your aura filters?"] = "¿Quieres configurar tus filtros de auras?"
L["X Color"] = "Color de la X"
L["X Mark"] = "Marca X"
L["X Size"] = "Tamaño de la X"
L["Yellow=high, Orange=highest, Red=tanking."] = "Amarillo=alto, Naranja=máximo, Rojo=tanqueo."
L["Yes"] = "Sí"
L["Yes, set it up"] = "Sí, configúralo"
L["YOUR PROFILES"] = "TUS PERFILES"
L["Z to A"] = "Z a la A"

