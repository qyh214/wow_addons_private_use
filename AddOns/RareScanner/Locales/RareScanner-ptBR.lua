-- Locale
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local AL = AceLocale:NewLocale("RareScanner", "ptBR", false);

if AL then
	AL["ALARM_MESSAGE"] = "Um PNJ raro acaba de aparecer. Olhe seu mapa!"
	AL["ALARM_SOUND"] = "Som de alerta para PNJs raros"
	AL["ALARM_SOUND_DESC"] = "Som produzido quando se detecta um PNJ raro na proximidade"
	AL["ALARM_TREASURES_SOUND"] = "Som de alerta para eventos/tesouros"
	AL["ALARM_TREASURES_SOUND_DESC"] = "Som produzido quando se detecta um tesouro/baú ou evento no seu minimapa"
	AL["AUTO_HIDE_BUTTON"] = "Esconder botão e miniatura automaticamente"
	AL["AUTO_HIDE_BUTTON_DESC"] = "Esconder botão e miniatura automaticamente, depois de passado o tempo selecionado (em segundos). Se marcar zero segundos, estes não se esconderão automaticamente"
	AL["CLASS_HALLS"] = "Salões de Ordem"
	AL["CLEAR_FILTERS_SEARCH"] = "Limpar"
	AL["CLEAR_FILTERS_SEARCH_DESC"] = "Retorna a forma a seu estado original"
	AL["CLICK_TARGET"] = "Clique para selecionar o PNJ"
	AL["CMD_HELP1"] = "Lista de comandos"
	AL["CMD_HELP2"] = "- Escreva \"/rarescanner show\" para mostrar todos os ícones no mapa"
	AL["CMD_HELP3"] = "- Escreva \"/rarescanner hide\" para ocultar todos os ícones no mapa"
	AL["CMD_HELP4"] = "- Escreva \"/rarescanner toggle\" para alternar entre os ícones no mapa"
	AL["CMD_HELP5"] = "- Escreva \"/rarescanner toggle rares\" ou \"/rarescanner tr\" para mostrar/ocultar ícones dos PNJs no mapa"
	AL["CMD_HELP6"] = "- Escreva \"/rarescanner toggle events\" ou \"/rarescanner te\" para mostrar/ocultar ícones de eventos no mapa"
	--[[Translation missing --]]
	AL["CMD_HELP7"] = "- Type \"/rarescanner toggle treasures\" or \"/rarescanner tt\" to show/hide icons of treasures on the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE"] = "Hiding RareScanner icons in the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE_EVENTS"] = "Hiding RareScanner event icons in the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE_RARES"] = "Hiding RareScanner rare icons in the world map"
	--[[Translation missing --]]
	AL["CMD_HIDE_TREASURES"] = "Hiding RareScanner treasure icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW"] = "Showing RareScanner icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW_EVENTS"] = "Showing RareScanner event icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW_RARES"] = "Showing RareScanner rare icons in the world map"
	--[[Translation missing --]]
	AL["CMD_SHOW_TREASURES"] = "Showing RareScanner treasure icons in the world map"
	AL["CONTAINER"] = "Recipiente"
	AL["DATABASE_HARD_RESET"] = "Com a mais recente expansão e com a última versão do RareScanner, grandes mudanças ocorreram na base de dados. Esta foi reiniciada para evitar inconsistências. Pedimos desculpa pelo incómodo."
	AL["DISABLE_SEARCHING_RARE_TOOLTIP"] = "Desativa alertas para este PNJ raro"
	AL["DISABLE_SOUND"] = "Desativa alertas de som"
	AL["DISABLE_SOUND_DESC"] = "Quando esteja activo, não serão produzidos sons de alerta"
	AL["DISABLED_SEARCHING_RARE"] = "Desativados os alertas para este PNJ raro:"
	AL["DISPLAY"] = "Mostrar"
	AL["DISPLAY_BUTTON"] = "Mostrar botão e miniatura"
	AL["DISPLAY_BUTTON_CONTAINERS"] = "Alterna mostrando o botão para tesouro/baú"
	AL["DISPLAY_BUTTON_CONTAINERS_DESC"] = "Alterna mostrando o botão de tesouro/baú. Não afeta o som de alarme nem os alertas de chat"
	AL["DISPLAY_BUTTON_DESC"] = "Quando desativado, deixa de mostrar o botão e a miniatura. Não afeta o som de alarme nem as mensagens de chat"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON_SCALE"] = "Scale of the button and miniature"
	--[[Translation missing --]]
	AL["DISPLAY_BUTTON_SCALE_DESC"] = "This will adjust the scale of the button and miniature, being the value of 0.85 the original size"
	--[[Translation missing --]]
	AL["DISPLAY_CONTAINER_ICONS"] = "Toggle showing container icons on the world map"
	--[[Translation missing --]]
	AL["DISPLAY_CONTAINER_ICONS_DESC"] = "When disabled, icons of containers/treasures won't be shown on the world map."
	--[[Translation missing --]]
	AL["DISPLAY_EVENT_ICONS"] = "Toggle showing event icons on the world map"
	--[[Translation missing --]]
	AL["DISPLAY_EVENT_ICONS_DESC"] = "When disabled, icons of events won't be shown on the world map."
	AL["DISPLAY_LOG_WINDOW"] = "Mostra a janela de log"
	AL["DISPLAY_LOG_WINDOW_DESC"] = "Quando desativado, a janela de registos (janela de log) não aparecerá novamente. "
	AL["DISPLAY_LOOT_ON_MAP"] = "Mostra o loot nas dicas de contexto (tooltips) do mapa"
	AL["DISPLAY_LOOT_ON_MAP_DESC"] = "Alterna mostrando o loot de PNJ/recipientes nas dicas de contexto (tooltips) que aparecem quando você move o mouse sobre os ícones"
	AL["DISPLAY_LOOT_PANEL"] = "Mostrar barra de saque (loot)"
	AL["DISPLAY_LOOT_PANEL_DESC"] = "Quando ativado, mostrará uma barra com o saque (loot) soltado pelo PNJ encontrado"
	AL["DISPLAY_MAP_NOT_DISCOVERED_ICONS"] = "Mostrar ícones não descobertos no mapa. "
	AL["DISPLAY_MAP_NOT_DISCOVERED_ICONS_DESC"] = "Quando desativado, os ícones de PNJs raros não descobertos (os ícones vermelhos e laranja), recipientes ou eventos não aparecerão no mapa mundo"
	AL["DISPLAY_MAP_OLD_NOT_DISCOVERED_ICONS"] = "Mostra, no mapa, ícones não descobertos de expansões antigas. "
	AL["DISPLAY_MAP_OLD_NOT_DISCOVERED_ICONS_DESC"] = "Quando desativado, os ícones de PNJs raros não descobertos (os ícones vermelhos e laranja), recipientes ou eventos não aparecerão no mapa mundo em áreas que pertençam a expansões antigas. "
	AL["DISPLAY_MINIATURE"] = "Mostrar a miniatura"
	AL["DISPLAY_MINIATURE_DESC"] = "Quando desativado, a miniatura não aparecerá novamente. "
	--[[Translation missing --]]
	AL["DISPLAY_NPC_ICONS"] = "Toggle showing rare NPC icons on the world map"
	--[[Translation missing --]]
	AL["DISPLAY_NPC_ICONS_DESC"] = "When disabled, icons of rare NPCs won't be shown on the world map."
	AL["DISPLAY_OPTIONS"] = "Mostrar opções"
	AL["DUNGEONS_SCENARIOS"] = "Masmorras/Cenários"
	--[[Translation missing --]]
	AL["ENABLE_MARKER"] = "Toggle target marker"
	--[[Translation missing --]]
	AL["ENABLE_MARKER_DESC"] = "When this is activated it will show a marker on top of the target when you click the main button"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_CHAT"] = "Toggle searching for rare NPCs through chat messages"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_CHAT_DESC"] = "When this is activated you will be warned visually and with a sound everytime a rare NPC yells or a chat message related with a rare NPCs is detected."
	AL["ENABLE_SCAN_CONTAINERS"] = "Ativa a busca de tesouros ou baús"
	AL["ENABLE_SCAN_CONTAINERS_DESC"] = "Quando ativado, aparecerá um aviso visual e sonoro cada vez que um tesouro ou baú apareça no seu minimapa."
	AL["ENABLE_SCAN_EVENTS"] = "Ativar a busca de eventos"
	AL["ENABLE_SCAN_EVENTS_DESC"] = "Quando ativado, aparecerá um aviso visual e sonoro cada vez que um evento apareça no seu minimapa "
	AL["ENABLE_SCAN_GARRISON_CHEST"] = "Ativa a busca de tesouros de sua guarnição"
	AL["ENABLE_SCAN_GARRISON_CHEST_DESC"] = "Quando ativado, será avisado com som e visualmente cada vez que um cofre de sua guarnição apareça no minimapa."
	AL["ENABLE_SCAN_IN_INSTANCE"] = "Ativar escaneio em instâncias"
	AL["ENABLE_SCAN_IN_INSTANCE_DESC"] = "Quando ativado, o addon funcionará como de costume enquanto estiver numa instância (masmorra, raide, etc)"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_ON_TAXI"] = "Toggle scanning while using a transportation"
	--[[Translation missing --]]
	AL["ENABLE_SCAN_ON_TAXI_DESC"] = "When this is activated the addon will work as usual while you are using a transportation (flight, boat, etc.)"
	AL["ENABLE_SCAN_RARES"] = "Ativa a busca de PNJs raros"
	AL["ENABLE_SCAN_RARES_DESC"] = "Quando ativado, aparecerá um aviso visual e sonoro cada vez que um NPC raro apareça no minimapa"
	AL["ENABLE_SEARCHING_RARE_TOOLTIP"] = "Habilita alertas de busca para este PNJ raro"
	--[[Translation missing --]]
	AL["ENABLE_TOMTOM_SUPPORT"] = "Toggle Tomtom's support"
	--[[Translation missing --]]
	AL["ENABLE_TOMTOM_SUPPORT_DESC"] = "When this is activated it will add a Tomtom's waypoint at the entitie's found coordinates"
	AL["ENABLED_SEARCHING_RARE"] = "Habilitou a busca deste PNJ raro: "
	AL["EVENT"] = "Evento"
	AL["FILTER"] = "Filtros de PNJ"
	AL["FILTER_CONTINENT"] = "Continente/Categoria"
	AL["FILTER_CONTINENT_DESC"] = "Nome de continente ou categoria"
	--[[Translation missing --]]
	AL["FILTER_NPCS_ONLY_MAP"] = "Enable filters only in the world map"
	--[[Translation missing --]]
	AL["FILTER_NPCS_ONLY_MAP_DESC"] = "When enabled you will still get alerts from filtered NPCs but they won't show up in your world map. When disabled you won't get alerts from filtered NPCs at all."
	AL["FILTER_RARE_LIST"] = "Filtros de busca para PNJs raros"
	AL["FILTER_RARE_LIST_DESC"] = "Ativar a busca deste PNJ raro. Quando desativado, não será avisado ao encontrar este PNJ. "
	AL["FILTER_ZONE"] = "Zona"
	AL["FILTER_ZONE_DESC"] = "Zona dentro do continente ou categoria "
	AL["FILTER_ZONES_LIST"] = "Lista de zonas"
	AL["FILTER_ZONES_LIST_DESC"] = "Ativa alertas para esta zona. Quando desativado, não será avisado ao encontrar um tesouro, evento ou PNJ raro nesta zona."
	--[[Translation missing --]]
	AL["FILTER_ZONES_ONLY_MAP"] = "Enable filters only in the world map"
	--[[Translation missing --]]
	AL["FILTER_ZONES_ONLY_MAP_DESC"] = "When enabled you will still get alerts from NPCs that belong to filtered zones but they won't show up in your world map. When disabled you won't get alerts from NPCs that belong to filtered zones at all."
	AL["FILTERS"] = "Filtro para PNJs raros"
	AL["FILTERS_SEARCH"] = "Buscar"
	AL["FILTERS_SEARCH_DESC"] = "Escreva o nome do PNJ para filtrar na lista de baixo"
	AL["GENERAL_OPTIONS"] = "Opções gerais"
	AL["JUST_SPAWNED"] = "%s acabou de aparecer. Olhe seu mapa!"
	AL["LEFT_BUTTON"] = "Botão esquerdo"
	AL["LOG_WINDOW_AUTOHIDE"] = "Oculta automaticamente botões de PNJ logueados"
	AL["LOG_WINDOW_AUTOHIDE_DESC"] = "Esconde cada botão de PNJ após o tempo selecionado (em minutos). Se você selecionar zero minutos, os botões permanecerão até que feche a janela de log, ou até que atinja o número máximo de botões (nesse caso, o mais antigo será substituído)."
	AL["LOG_WINDOW_OPTIONS"] = "Opções de janela de log"
	AL["LOOT_CATEGORY_FILTERED"] = "Filtro ativo para a categoria/subcategoria: %s/%s. Você pode desativar este filtro clicando novamente no ícone de loot (saque) ou através do menu do addon RareScanner"
	AL["LOOT_CATEGORY_FILTERS"] = "Filtros de Categoria"
	AL["LOOT_CATEGORY_FILTERS_DESC"] = "Filtra o saque (loot) mostrado pela categoria"
	AL["LOOT_CATEGORY_NOT_FILTERED"] = "Filtro desativado para a categoria/subcategoria: %s/%s"
	AL["LOOT_DISPLAY_OPTIONS"] = "Mostrar opções"
	AL["LOOT_DISPLAY_OPTIONS_DESC"] = "Mostrar opções para a barra de loot"
	AL["LOOT_FILTER_COLLECTED"] = "Filtrar pets coleccionadas, montarias e brinquedos. "
	AL["LOOT_FILTER_COLLECTED_DESC"] = "Quando ativado, apenas montarias, mascotes e brinquedos que ainda não tenha colecionado serão mostrados na barra de loot (saque). Este filtro não afeta outros tipos de itens looteáveis (saqueáveis). "
	--[[Translation missing --]]
	AL["LOOT_FILTER_COMPLETED_QUEST"] = "Filter quest items that don't begin a new quest"
	--[[Translation missing --]]
	AL["LOOT_FILTER_COMPLETED_QUEST_DESC"] = "When activated, any item that is a requirement for a quest, or that begins an already completed quest, won't show up on the loot bar."
	AL["LOOT_FILTER_NOT_EQUIPABLE"] = "Filtrar itens não-equipáveis"
	AL["LOOT_FILTER_NOT_EQUIPABLE_DESC"] = "Quando desativado, armas e armaduras que seu personagem não possa usar não aparecerão na barra de loot (saque). Este filtro não afeta outros tipos de itens looteáveis (saqueáveis). "
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_MATCHING_CLASS"] = "Filter items that require a different class than yours"
	--[[Translation missing --]]
	AL["LOOT_FILTER_NOT_MATCHING_CLASS_DESC"] = "When activated, any item that requires a specific class to be used that doesn't match yours, won't show up on the loot bar."
	AL["LOOT_FILTER_NOT_TRANSMOG"] = "Mostrar apenas armadura e armas de transmog"
	AL["LOOT_FILTER_NOT_TRANSMOG_DESC"] = "Quando ativado, apenas armas e armaduras que ainda não tenha colecionado serão mostrados na barra de loot (saque). Este filtro não afeta outros tipos de itens looteáveis (saqueáveis). "
	AL["LOOT_FILTER_SUBCATEGORY_DESC"] = "Mostra este tipo de loot na barra de loot (saque). Quando desativado, você não verá nenhum item que corresponda a essa categoria no loot mostrado quando você encontrar um PNJ raro."
	AL["LOOT_FILTER_SUBCATEGORY_LIST"] = "Subcategorias"
	AL["LOOT_ITEMS_PER_ROW"] = "Números de itens mostrados, por barra"
	AL["LOOT_ITEMS_PER_ROW_DESC"] = "Define o número de itens a serem exibidos, por linha, na barra de loot (saque). Se o número for menor que o máximo, várias linhas serão exibidas."
	AL["LOOT_MAIN_CATEGORY"] = "Categoria principal"
	AL["LOOT_MAX_ITEMS"] = "Número de itens mostrados"
	AL["LOOT_MAX_ITEMS_DESC"] = "Determina o número máximo de itens mostrados na barra de loot. "
	AL["LOOT_MIN_QUALITY"] = "Qualidade mínima do saque"
	AL["LOOT_MIN_QUALITY_DESC"] = "Define a qualidade mínima do saque mostrado no painel de saque"
	AL["LOOT_OPTIONS"] = "Opções de loot "
	AL["LOOT_OTHER_FILTERS"] = "Outros filtros"
	AL["LOOT_OTHER_FILTERS_DESC"] = "Outros filtros"
	AL["LOOT_PANEL_OPTIONS"] = "Opções painel de saque (loot)"
	AL["LOOT_SUBCATEGORY_FILTERS"] = "Filtros de subcategorias "
	AL["LOOT_TOGGLE_FILTER"] = "Clique para ativar filtro"
	AL["LOOT_TOOLTIP_POSITION"] = "Posição do tooltip (dica de contexto) do saque (loot)"
	AL["LOOT_TOOLTIP_POSITION_DESC"] = "Define a posição na qual se mostra o tooltip (dica de contexto/janela flutuante) com a descrição do saque ao passar o mouse por cima dos ícones, em relação ao botão"
	AL["MAIN_BUTTON_OPTIONS"] = "Opções do botão principal"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_CONTAINER_FILTER"] = "Show containers that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_EVENT_FILTER"] = "Show events that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_DISABLE_LAST_SEEN_FILTER"] = "Show rare NPCs that you saw a long time ago but that can respawn"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_CONTAINERS"] = "Show container icons on map"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_EVENTS"] = "Show event icons on map"
	AL["MAP_MENU_SHOW_NOT_DISCOVERED"] = "Entidades não descobertas"
	AL["MAP_MENU_SHOW_NOT_DISCOVERED_OLD"] = "Entidades não descobertas (expansões antigas)"
	--[[Translation missing --]]
	AL["MAP_MENU_SHOW_RARE_NPCS"] = "Show rare NPC icons on map"
	AL["MAP_NEVER"] = "Nunca"
	AL["MAP_OPTIONS"] = "Opções de mapa"
	--[[Translation missing --]]
	AL["MAP_SCALE_ICONS"] = "Scale of the icons"
	--[[Translation missing --]]
	AL["MAP_SCALE_ICONS_DESC"] = "This will adjust the scale of the icons, being the value of 1 the original size."
	AL["MAP_SHOW_ICON_AFTER_COLLECTED"] = "Continua mostrando ícones de contêiner após looteados (saqueados)"
	AL["MAP_SHOW_ICON_AFTER_COLLECTED_DESC"] = "Quando desativado, o ícone desaparecerá depois de lootear (saquear) o contêiner.  "
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COMPLETED"] = "Keep showing event icons after completion"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_COMPLETED_DESC"] = "When disabled the icon will disappear after you complete the event."
	AL["MAP_SHOW_ICON_AFTER_DEAD"] = "Continuar mostrando ícones de PNJ depois da morte"
	AL["MAP_SHOW_ICON_AFTER_DEAD_DESC"] = "Quando desativado, o ícone desaparecerá depois de matar o PNJ. O ícone reaparecerá assim que encontre o PNJ novamente. Esta opção apenas funcionará com PNJs que continuem sendo raros  mesmo depois de mortos. "
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_RESETEABLE"] = "Keep showing NPC icons after death (only in resetable zones)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_AFTER_DEAD_RESETEABLE_DESC"] = "When disabled the icon will disappear after you kill the NPC. The icon will reappear as soon as you find the NPC again. This option only works with NPCs that keep being rares after killing them in zones that reset with world quests."
	AL["MAP_SHOW_ICON_CONTAINER_MAX_SEEN_TIME"] = "Temporizador para ocultar ícones de contêiner (em minutos)"
	AL["MAP_SHOW_ICON_CONTAINER_MAX_SEEN_TIME_DESC"] = "Determina o número máximo de minutos desde que viu por última vez o recipiente. Depois disso, o ícone não aparecerá no mapa mundo até que encontre esse mesmo recipiente outra vez. Se selecionar zero minutos, os ícones aparecerão independentemente de quanto tempo tenha passado desde que você viu esse recipiente. Este filtro não afeta recipientes que sejam parte de uma Conquista."
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_EVENT_MAX_SEEN_TIME"] = "Timer to hide event icons (in minutes)"
	--[[Translation missing --]]
	AL["MAP_SHOW_ICON_EVENT_MAX_SEEN_TIME_DESC"] = "Sets the maximum number of minutes since you have seen the event. After that time, the icon won't be shown on the world map until you find the event again. If you select zero minutes the icons will be shown regardless of how long since you have seen the event."
	AL["MAP_SHOW_ICON_MAX_SEEN_TIME"] = "Temporizador para esconder ícones de PNJ raros (em horas) "
	AL["MAP_SHOW_ICON_MAX_SEEN_TIME_DESC"] = "Determina o número máximo de horas desde que viu por última vez o PNJ. Depois desse tempo, o ícone não aparecerá no mapa mundo até que encontre esse mesmo PNJ outra vez. Se selecionar zero horas, os ícones aparecerão independentemente de quanto tempo tenha passado desde que você viu esse PNJ raro."
	AL["MAP_TOOLTIP_ACHIEVEMENT"] = "Este é um objetivo da conquista %s"
	--[[Translation missing --]]
	AL["MAP_TOOLTIP_ALREADY_COMPLETED"] = "This event is already completed. Restart on: %s"
	AL["MAP_TOOLTIP_ALREADY_KILLED"] = "Este PNJ foi assassinado. Reinício em: %s"
	AL["MAP_TOOLTIP_ALREADY_OPENED"] = "Este recipiente já está aberto. Reinício em: %s"
	AL["MAP_TOOLTIP_CONTAINER_LOOTED"] = "Shift-Clique-esquerdo para determinar como looteado (saqueado). "
	AL["MAP_TOOLTIP_DAYS"] = "dias"
	AL["MAP_TOOLTIP_EVENT_DONE"] = "Shift-clique-esquerdo para determinar como completado"
	AL["MAP_TOOLTIP_IGNORE_ICON"] = "Shift-Clique-esquerdo para esconder este ícone indefinidamente, se não era suposto aparecer aqui.  "
	AL["MAP_TOOLTIP_KILLED"] = "Shift-Clique-esquerdo para determinar como morto"
	AL["MAP_TOOLTIP_NOT_FOUND"] = "Ainda não tinha visto este PNJ e ninguém o tinha partilhado com você"
	AL["MAP_TOOLTIP_SEEN"] = "Visto anteriormente: %s"
	--[[Translation missing --]]
	AL["MARKER"] = "Target marker"
	--[[Translation missing --]]
	AL["MARKER_DESC"] = "Choose the marker to add on top of the target when you click the main button."
	AL["MESSAGE_OPTIONS"] = "Opções de mensagens "
	AL["MIDDLE_BUTTON"] = "Clique no botão do meio (scroll)"
	--[[Translation missing --]]
	AL["NAVIGATION_ENABLE"] = "Toggle navigation"
	--[[Translation missing --]]
	AL["NAVIGATION_ENABLE_DESC"] = "When enabled the navigation arrows will show up beside the main button to allow you access to newer or older entities found"
	--[[Translation missing --]]
	AL["NAVIGATION_LOCK_ENTITY"] = "Block display of new entities if one is already shown"
	--[[Translation missing --]]
	AL["NAVIGATION_LOCK_ENTITY_DESC"] = "When enabled, if the main button is displaying an entity in your screen, it won't update to a newer one automatically. An arrow will appear allowing you to access the new entity whenever you are ready"
	--[[Translation missing --]]
	AL["NAVIGATION_OPTIONS"] = "Navigation options"
	--[[Translation missing --]]
	AL["NAVIGATION_SHOW_NEXT"] = "Show next entity found"
	--[[Translation missing --]]
	AL["NAVIGATION_SHOW_PREVIOUS"] = "Show previous entity found"
	AL["NOT_TARGETEABLE"] = "Não é selecionável"
	AL["NOTE_130350"] = "Você tem que montar este raro e levá-lo até ao recipiente que você encontrará seguindo o caminho à direita desta posição."
	AL["NOTE_131453"] = "Você tem que montar [Guardião da Nascente] e trazê-lo a esta posição. O cavalo é um raro amigável que você encontrará seguindo o caminho à esquerda deste recipiente."
	--[[Translation missing --]]
	AL["NOTE_135497"] = "Only available while doing the daily quest [Aid from Nordrassil] obtained from Mylune. While you are on this quest you will find mushrooms under the trees. Clicking on them might spawn this NPC."
	--[[Translation missing --]]
	AL["NOTE_149847"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_150342"] = "Only available during the event [Drill Rig DR-TR35]."
	--[[Translation missing --]]
	AL["NOTE_150394"] = "In order to kill him you have to bring him to the coordinates 63.38, where there is a device with blue lightning. Once the NPC is touched by lightning, it will explode and you will be able to loot him."
	--[[Translation missing --]]
	AL["NOTE_151124"] = "You have to loot a [Smashed Transport Relay] from the enemies that appear during the event [Drill Rig DR-JD99] (coordinates 59.67) and then use it on the machine that is found on the platform."
	--[[Translation missing --]]
	AL["NOTE_151159"] = "He is available only when [Oglethorpe Obnoticus] is in Mechagon (coordinates 72.37). He wanders around Mechagon, so check in every street. Killing him makes [OOX-Avenger/MG] to spawn."
	--[[Translation missing --]]
	AL["NOTE_151202"] = "In order to summon him you have to connect the [Wires] on the shore, with the [Pylons] inside the water."
	--[[Translation missing --]]
	AL["NOTE_151296"] = "First check if [Oglethorpe Obnoticus] is in Mechagon (coordinates 72.37). If he is there, then you have to find and kill [OOX-Fleetfoot/MG] (it is a chicken robot wandering around Mechagon). Once you find him and kill him, come back to this icon's coordinates."
	--[[Translation missing --]]
	AL["NOTE_151308"] = "Only available during [Drill Rig] events."
	--[[Translation missing --]]
	AL["NOTE_151569"] = "You require a [Hundred-Fathom Lure] to summon it."
	--[[Translation missing --]]
	AL["NOTE_151627"] = "You need to use a [Exothermic Evaporator Coil] on the machine that is found on the platform."
	--[[Translation missing --]]
	AL["NOTE_151933"] = "In order to kill him you have to use [Beastbot Powerpack] (you can get the schema at the coordinates 60.41)."
	--[[Translation missing --]]
	AL["NOTE_152007"] = "It is wandering in this area, so the coordinates might not be very accurate."
	--[[Translation missing --]]
	AL["NOTE_152113"] = "Only available during the event [Drill Rig DR-CC88]."
	--[[Translation missing --]]
	AL["NOTE_152569"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_152570"] = "When you aproach to him, he will tell you a colour that he hates. Once you know what colour it is, you have to go to the coordinates 63.41 where you will be painted that colour. When you will come back to his position, he will attack you."
	--[[Translation missing --]]
	AL["NOTE_153000"] = "Only available while the daily quest [Bugs, Lots of 'Em!] is active."
	--[[Translation missing --]]
	AL["NOTE_153200"] = "Only available during the event [Drill Rig DR-JD41]."
	--[[Translation missing --]]
	AL["NOTE_153205"] = "Only available during the event [Drill Rig DR-JD99]."
	--[[Translation missing --]]
	AL["NOTE_153206"] = "Only available during the event [Drill Rig DR-TR28]."
	--[[Translation missing --]]
	AL["NOTE_153228"] = "It shows up after killing a LOT of [Upgraded Sentry] that wander around the area."
	--[[Translation missing --]]
	AL["NOTE_154225"] = "He is available only on the interface that you can access using [Personal Time Displacer] that you can create with resources collected in Mechagon. Important: He won't spawn while Chromie's daily quest is available."
	--[[Translation missing --]]
	AL["NOTE_154332"] = "It is in a cave. The entrance is located at the coordinates 57,38."
	--[[Translation missing --]]
	AL["NOTE_154333"] = "It is in a cave. The entrance is located at the coordinates 57,38."
	--[[Translation missing --]]
	AL["NOTE_154342"] = "He is available only on the interface that you can access using [Personal Time Displacer] that you can create with resources collected in Mechagon."
	--[[Translation missing --]]
	AL["NOTE_154559"] = "It is in a cave. The entrance is located at the coordinates 70,58."
	--[[Translation missing --]]
	AL["NOTE_154604"] = "It is in a cave. The entrance is located at the coordinates 36,20."
	--[[Translation missing --]]
	AL["NOTE_154701"] = "Only available during the event [Drill Rig DR-CC61]."
	--[[Translation missing --]]
	AL["NOTE_154739"] = "Only available during the event [Drill Rig DR-CC73]."
	--[[Translation missing --]]
	AL["NOTE_155531"] = "You have to use the orb above him (Essence of the Sun) to get [Aura of the Sun] and be able to attack him."
	--[[Translation missing --]]
	AL["NOTE_156709"] = "You have to kill Faceless Despoiler (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_157162"] = "Inside the temple. The entrance is located at the coordinates 22,24."
	--[[Translation missing --]]
	AL["NOTE_158531"] = "You have to kill Voidwarped Neferset (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_158632"] = "You have to kill Burbling Fleshbeast (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_158706"] = "You have to kill Oozing Putrefaction (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_159087"] = "You have to kill N'Zoth Bonestripper (normal NPC) to force this one to spawn."
	--[[Translation missing --]]
	AL["NOTE_160968"] = "Inside the temple. The entrance is located at the coordinates 22,24."
	--[[Translation missing --]]
	AL["NOTE_162171"] = "It is in a cave. The entrance is located at the coordinates 45,58."
	--[[Translation missing --]]
	AL["NOTE_162352"] = "It is in a cave. The entrance is underwater at the coordinates 52,40."
	AL["NOTE_280951"] = "Siga a ferrovia até encontrar um carrinho. Monte-o para descobrir o tesouro."
	AL["NOTE_287239"] = "Apenas disponível para a Horda. Você tem de completar a campanha de Vol'dun para poder ter acesso ao templo. "
	--[[Translation missing --]]
	AL["NOTE_289647"] = "The treasure is in a cave. The entrance is at the coordinates 65.11, between some trees almost on top of the mountain."
	AL["NOTE_292673"] = "1 de 5 pergaminhos. Leia todos eles para descobrir o tesouro [Segredo das Profundezas]. Está no porão. Esconda este ícone manualmente depois de o ter lido."
	AL["NOTE_292674"] = "2 de 5 pergaminhos. Leia todos eles para descobrir o tesouro [Segredo das Profundezas]. Está debaixo do chão de madeira, no canto, ao lado de um aglomerado de velas. Esconda este ícone manualmente depois de o ter lido."
	AL["NOTE_292675"] = "3 de 5 pergaminhos. Leia todos eles para descobrir o tesouro [Segredo das Profundezas]. Está no porão. Esconda este ícone manualmente depois de o ter lido. "
	AL["NOTE_292676"] = "4 de 5 pergaminhos. Leia todos eles para descobrir o tesouro [Segredo das Profundezas]. Está no último andar. Esconda este ícone manualmente depois de o ter lido. "
	AL["NOTE_292677"] = "5 de 5 pergaminhos. Leia todos eles para descobrir o tesouro [Segredo das Profundezas]. Está numa cave subterrânea. A entrada está debaixo de água nas coordenadas 72.40 (piscina de água no mosteiro). Esconda este ícone manualmente depois de o ter lido. "
	AL["NOTE_292686"] = "Depois de ler os 5 pergaminhos, use o [Ominous Altar] para obter [Segredo das Profundezas]. Aviso: usar o altar o teletransportará para o meio do mar. Esconda o ícone manualmente assim que o use. "
	AL["NOTE_293349"] = "É dentro do galpão, em cima de uma prateleira."
	AL["NOTE_293350"] = "Este tesouro está escondido numa caverna subterrânea. Vá para as coordenadas 61.38, coloque a câmara olhando desde cima, depois salte para trás através da pequena fissura no chão e aterrisse na borda. "
	AL["NOTE_293852"] = "Não poderá ver isto até que coleccione [Mapa do Tesouro Encharcado] dos piratas no Freehold. "
	AL["NOTE_293880"] = "Não poderá ver isto até que coleccione [Mapa do Tesouro Esmaecido] dos piratas no Freehold. "
	AL["NOTE_293881"] = "Não poderá ver isto até que coleccione [Mapa do Tesouro Amarelado] dos piratas no Freehold. "
	AL["NOTE_293884"] = "Não poderá ver isto até que coleccione [Mapa do Tesouro Chamuscado] dos piratas no Freehold. "
	AL["NOTE_297828"] = "O corvo que sobrevoa os domínios contém a chave. Mate-o. "
	AL["NOTE_297891"] = "Você tem que desativar as runas nesta ordem: Esquerda, Baixo, Cima, Direita. "
	AL["NOTE_297892"] = "Você tem que desativar as runas nesta ordem: Esquerda , Direita, Baixo, Cima. "
	AL["NOTE_297893"] = "Você tem que desativar as runas nesta ordem: Direita, Cima, Esquerda, Baixo"
	--[[Translation missing --]]
	AL["NOTE_326395"] = "You have to enable the [Arcane device] that is found on top of a table beside the chest in order to start the minigame. To pass the game you have to separate the three triangles. Click on the orbs to switch their positions."
	--[[Translation missing --]]
	AL["NOTE_326396"] = "You have to enable the [Arcane device] that is found on the ground beside the chest in order to start the minigame. To pass the game you have to separate the two rectangles. Click on the orbs to switch their positions."
	--[[Translation missing --]]
	AL["NOTE_326397"] = "You have to enable the [Arcane device] that is found on the ground beside the chest in order to start the minigame. To pass the game you have to line up three red runes."
	--[[Translation missing --]]
	AL["NOTE_326398"] = "You have to enable the [Arcane device] that is found on top of a table beside the chest in order to start the minigame. To pass the game you have to line up four cyan runes."
	--[[Translation missing --]]
	AL["NOTE_326399"] = "It's in a cave underwater. You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_326400"] = "It is in a cave. You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_326403"] = "It is inside the building. You have to access it from the back."
	--[[Translation missing --]]
	AL["NOTE_326405"] = "It is between some ruins in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326406"] = "It is on top of a mountain in the highest level of the map. It's hard to get there on foot, but it's possible from the south side."
	--[[Translation missing --]]
	AL["NOTE_326407"] = "It is on top of a mountain in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326408"] = "It is in a cave underwater. The entrance is in the lake to the south (coordinates 57,39)."
	--[[Translation missing --]]
	AL["NOTE_326410"] = "It is in a cave in the lower level of the map."
	--[[Translation missing --]]
	AL["NOTE_326411"] = "It is between some stones in the highest level of the map."
	--[[Translation missing --]]
	AL["NOTE_326413"] = "It is in a cave in the lower level of the map."
	--[[Translation missing --]]
	AL["NOTE_326415"] = "It requires flying or you can use a [Goblin Glider Kit] from the tall mountain beside. The chest is on top of the coral bridge."
	--[[Translation missing --]]
	AL["NOTE_326416"] = "It is in the highest level of the map, inside a tower in ruins."
	--[[Translation missing --]]
	AL["NOTE_329783"] = "It is on the roof (access at coordinates 83.33). You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	--[[Translation missing --]]
	AL["NOTE_332220"] = "You have to complete a minigame where you have to shoot the fire balls before they touch the circles on the ground. Everytime a ball touches the ground or you use the spell without hitting a ball, the energy will decrease, and if it reaches zero then you will have to start again."
	AL["PROFILES"] = "Perfis"
	AL["RAIDS"] = "Raides"
	--[[Translation missing --]]
	AL["RESET_POSITION"] = "Reset position"
	--[[Translation missing --]]
	AL["RESET_POSITION_DESC"] = "Restores the original position of the main button."
	AL["SHOW_CHAT_ALERT"] = "Mostrar alertas de chat"
	AL["SHOW_CHAT_ALERT_DESC"] = "Mostra no chat uma mensagem privada, cada vez que se detecte um cofre, tesouro ou NPC."
	--[[Translation missing --]]
	AL["SHOW_RAID_WARNING"] = "Toggle showing raid warnings"
	--[[Translation missing --]]
	AL["SHOW_RAID_WARNING_DESC"] = "Shows a raid warning on your screen every time a treasure, chest or NPC is found"
	AL["SOUND"] = "Áudio"
	AL["SOUND_OPTIONS"] = "Opções de áudio"
	--[[Translation missing --]]
	AL["SOUND_VOLUME"] = "Volume"
	--[[Translation missing --]]
	AL["SOUND_VOLUME_DESC"] = "Sets the sound volume level"
	--[[Translation missing --]]
	AL["SYNCRONIZATION_COMPLETED"] = "Syncronization completed"
	--[[Translation missing --]]
	AL["SYNCRONIZE"] = "Sync database"
	--[[Translation missing --]]
	AL["SYNCRONIZE_DESC"] = "This will analize which rare NPCs and treasures that are part of an achievement you have killed/collected already, and they will disappear from your map. There is no way to know the state of non-achievement rare NPCs and treasures, so they will remain in your map as they are currently shown."
	AL["TEST"] = "Iniciar teste"
	AL["TEST_DESC"] = "Pulse o botão para mostrar um exemplo de alerta. Pode arrastar o botão até outra posição onde se mostrarão alertas futuros."
	AL["TOC_NOTES"] = "Scanner do minimapa. Avisa com uma mensagem, uma miniatura e produz um sinal sonoro cada vez que um NPC raro, tesouro ou evento aparece no seu minimapa."
	AL["TOGGLE_FILTERS"] = "Ativa/desativa filtros"
	AL["TOGGLE_FILTERS_DESC"] = "Ativa/desativa todos os filtros simultaneamente"
	AL["TOOLTIP_BOTTOM"] = "Lado inferior"
	AL["TOOLTIP_CURSOR"] = "Siga o cursor"
	AL["TOOLTIP_LEFT"] = "Lado esquerdo"
	AL["TOOLTIP_RIGHT"] = "Lado direito"
	AL["TOOLTIP_TOP"] = "Lado superior"
	AL["UNKNOWN"] = "Desconhecido"
	AL["UNKNOWN_TARGET"] = "Objetivo desconhecido"
	AL["ZONES_FILTER"] = "Filtros de zonas"
	AL["ZONES_FILTERS_SEARCH_DESC"] = "Escreva o nome da zona para filtrar na lista de baixo"

	-- CONTINENT names
	AL["ZONES_CONTINENT_LIST"] = {
		[9999] = "Salões de Ordem"; --Class Halls
		[9998] = "Ilha de Negraluna"; --Darkmoon Island
		[9997] = "Dungeons/Scenarios"; --Dungeons/Scenarios
		[9996] = "Raids"; --Raids
		[9995] = "Desconhecido"; --Unknown
	}
end