local L = LibStub("AceLocale-3.0"):NewLocale("Titan","ptBR")
if not L then return end

L["TITAN_PANEL"] = "Painel Titan";
local TITAN_PANEL = "Painel Titan";
L["TITAN_DEBUG"] = "<Titan>";
L["TITAN_PRINT"] = "Titan";
     
L["TITAN_NA"] = "N/A";
L["TITAN_SECONDS"] = "segundos";
L["TITAN_MINUTES"] = "minutos";
L["TITAN_HOURS"] = "horas";
L["TITAN_DAYS"] = "dias";
L["TITAN_SECONDS_ABBR"] = "s";
L["TITAN_MINUTES_ABBR"] = "min";
L["TITAN_HOURS_ABBR"] = "h";
L["TITAN_DAYS_ABBR"] = "d";
L["TITAN_MILLISECOND"] = "ms";
L["TITAN_KILOBYTES_PER_SECOND"] = "kB/s";
L["TITAN_KILOBITS_PER_SECOND"] = "kbps"
L["TITAN_MEGABYTE"] = "MB";
L["TITAN_NONE"] = "Nenhum";
L["TITAN_USE_COMMA"] = "Use comma";
L["TITAN_USE_PERIOD"] = "Use period";

L["TITAN_PANEL_ERROR_PROF_DELCURRENT"] = "Você não pode apagar seu perfil atual.";
local TITAN_PANEL_WARNING = GREEN_FONT_COLOR_CODE.."Atenção : "..FONT_COLOR_CODE_CLOSE
local TITAN_PANEL_RELOAD_TEXT = "If you wish to continue with this operation, push 'Accept' (your UI will reload), otherwise push 'Cancel' or the 'Escape' key."
L["TITAN_PANEL_RESET_WARNING"] = TITAN_PANEL_WARNING
	.."This setting will reset your bar(s) and "..TITAN_PANEL.." settings to default values and will recreate your current profile. "
	..TITAN_PANEL_RELOAD_TEXT
L["TITAN_PANEL_RELOAD"] = TITAN_PANEL_WARNING
	.."This will reload "..TITAN_PANEL..". "
	..TITAN_PANEL_RELOAD_TEXT
L["TITAN_PANEL_ATTEMPTS"] = TITAN_PANEL.." Tentativas"
L["TITAN_PANEL_ATTEMPTS_SHORT"] = "Tentativas"
L["TITAN_PANEL_ATTEMPTS_DESC"] = "The plugins below requested to be registered with "..TITAN_PANEL..".\n"
	.. "Please send any issues to the plugin author."
L["TITAN_PANEL_ATTEMPTS_TYPE"] = "Tipo"
L["TITAN_PANEL_ATTEMPTS_CATEGORY"] = "Categoria"
L["TITAN_PANEL_ATTEMPTS_BUTTON"] = "Nome do botão"
L["TITAN_PANEL_EXTRAS"] = "Extras do " .. TITAN_PANEL
L["TITAN_PANEL_EXTRAS_SHORT"] = "Extras"
L["TITAN_PANEL_EXTRAS_DESC"] = "These are plugins with configuration data that are not currently loaded.\n"
	.. "These are safe to delete."
L["TITAN_PANEL_EXTRAS_DELETE_BUTTON"] = "Apagar dados de configuração"
L["TITAN_PANEL_EXTRAS_DELETE_MSG"] = "configuration entry for has been removed."
L["TITAN_PANEL_CHARS"] = "Personagens"
L["TITAN_PANEL_CHARS_DESC"] = "These are characters with configuration data."
L["TITAN_PANEL_REGISTER_START"] = "Registrando plugins do " .. TITAN_PANEL;
L["TITAN_PANEL_REGISTER_END"] = "Processo de registro feito."

-- slash command help
L["TITAN_PANEL_SLASH_RESET_0"] = LIGHTYELLOW_FONT_COLOR_CODE.."Usage: |cffffffff/titan {reset | reset tipfont/tipalpha/panelscale/spacing}";
L["TITAN_PANEL_SLASH_RESET_1"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."reset: |cffffffffResets "..TITAN_PANEL.." to default values/position.";
L["TITAN_PANEL_SLASH_RESET_2"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."reset tipfont: |cffffffffResets "..TITAN_PANEL.." tooltip font scale to default.";
L["TITAN_PANEL_SLASH_RESET_3"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."reset tipalpha: |cffffffffResets "..TITAN_PANEL.." tooltip transparency to default.";
L["TITAN_PANEL_SLASH_RESET_4"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."reset panelscale: |cffffffffResets "..TITAN_PANEL.." scale to default.";
L["TITAN_PANEL_SLASH_RESET_5"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."reset spacing: |cffffffffResets "..TITAN_PANEL.." button spacing to default.";
L["TITAN_PANEL_SLASH_GUI_0"] = LIGHTYELLOW_FONT_COLOR_CODE.."Usage: |cffffffff/titan {gui control/trans/skin}";
L["TITAN_PANEL_SLASH_GUI_1"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."gui control: |cffffffffOpens the "..TITAN_PANEL.." control GUI.";
L["TITAN_PANEL_SLASH_GUI_2"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."gui trans: |cffffffffOpens the Transparency control GUI.";
L["TITAN_PANEL_SLASH_GUI_3"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."gui skin: |cffffffffOpens the Skin control GUI.";
L["TITAN_PANEL_SLASH_PROFILE_0"] = LIGHTYELLOW_FONT_COLOR_CODE.."Usage: |cffffffff/titan {profile use <profile>}";
L["TITAN_PANEL_SLASH_PROFILE_1"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."profile use <name> <server>: |cffffffffSets the profile to the requested saved profile.";
L["TITAN_PANEL_SLASH_PROFILE_2"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."<name>: |cffffffffcan be either the character name or the custom profile name."
L["TITAN_PANEL_SLASH_PROFILE_3"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."<server>: |cffffffffcan be either the server name or 'TitanCustomProfile'."
L["TITAN_PANEL_SLASH_HELP_0"] = LIGHTYELLOW_FONT_COLOR_CODE.."Usage: |cffffffff/titan {help | help <topic>}";
L["TITAN_PANEL_SLASH_HELP_1"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."<topic>: reset/gui/profile/help ";
L["TITAN_PANEL_SLASH_ALL_0"] = LIGHTYELLOW_FONT_COLOR_CODE.."Usage: |cffffffff/titan <topic>";
L["TITAN_PANEL_SLASH_ALL_1"] = " - "..LIGHTYELLOW_FONT_COLOR_CODE.."<topic>: |cffffffffreset/gui/profile/help ";
    
-- slash command responses
L["TITAN_PANEL_SLASH_RESP1"] = LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PANEL.." tooltip font scale has been reset.";
L["TITAN_PANEL_SLASH_RESP2"] = LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PANEL.." tooltip transparency has been reset.";
L["TITAN_PANEL_SLASH_RESP3"] = LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PANEL.." scale has been reset.";
L["TITAN_PANEL_SLASH_RESP4"] = LIGHTYELLOW_FONT_COLOR_CODE..TITAN_PANEL.." button spacing has been reset.";
     
-- general panel locale
L["TITAN_PANEL_VERSION_INFO"] = "|cffffd700 pelo Time de Desenvolvimento do |cffff8c00"..TITAN_PANEL;
L["TITAN_PANEL_MENU_TITLE"] = TITAN_PANEL;
L["TITAN_PANEL_MENU_HIDE"] = "Ocultar ";
L["TITAN_PANEL_MENU_IN_COMBAT_LOCKDOWN"] = "(Em Combate)";
L["TITAN_PANEL_MENU_RELOADUI"] = "(Recarregar IU)";
L["TITAN_PANEL_MENU_SHOW_COLORED_TEXT"] = "Exibir Texto Colorido";
L["TITAN_PANEL_MENU_SHOW_ICON"] = "Exibir Ícone";
L["TITAN_PANEL_MENU_SHOW_LABEL_TEXT"] = "Exibir Texto de Rótulo";
L["TITAN_PANEL_MENU_AUTOHIDE"] = "Ocultar Automaticamente";
L["TITAN_PANEL_MENU_CENTER_TEXT"] = "Centralizar Texto";
L["TITAN_PANEL_MENU_DISPLAY_BAR"] = "Exibir Barra";
L["TITAN_PANEL_MENU_DISABLE_PUSH"] = "Desativar Ajuste de Tela";
L["TITAN_PANEL_MENU_DISABLE_MINIMAP_PUSH"] = "Desativar Ajuste de Mini-mapa";
L["TITAN_PANEL_MENU_DISABLE_LOGS"] = "Ajuste Automático de Log";
L["TITAN_PANEL_MENU_DISABLE_BAGS"] = "Ajuste Automático de Mochila";
L["TITAN_PANEL_MENU_DISABLE_TICKET"] = "Automatic Ticket Frame Adjust";
L["TITAN_PANEL_MENU_PROFILES"] = "Perfis";
L["TITAN_PANEL_MENU_PROFILE"] = "Perfil ";
L["TITAN_PANEL_MENU_PROFILE_CUSTOM"] = "Personalizado";
L["TITAN_PANEL_MENU_PROFILE_DELETED"] = " foi apagado.";
L["TITAN_PANEL_MENU_PROFILE_SERVERS"] = "Reino";
L["TITAN_PANEL_MENU_PROFILE_CHARS"] = "Personagem";
L["TITAN_PANEL_MENU_PROFILE_RELOADUI"] = "Sua UI será recarregada quando o botão 'Ok' for apertado, permitindo que seu perfil personalizado seja salvo.";
L["TITAN_PANEL_MENU_PROFILE_SAVE_CUSTOM_TITLE"] = "Digite um nome para seu perfil personalizado:\n(máximo 20 caracteres, espaços não são permitidos, maíusculas e minúsculas)";
L["TITAN_PANEL_MENU_PROFILE_SAVE_PENDING"] = "Current settings are to be saved under profile name: ";
L["TITAN_PANEL_MENU_PROFILE_ALREADY_EXISTS"] = "The profile name entered already exists. Are you sure you want to overwrite it ? Push 'Accept' if yes, otherwise push 'Cancel' or the 'Escape' key.";
L["TITAN_PANEL_MENU_MANAGE_SETTINGS"] = "Gerenciar";
L["TITAN_PANEL_MENU_LOAD_SETTINGS"] = "Carregar";
L["TITAN_PANEL_MENU_DELETE_SETTINGS"] = "Apagar";
L["TITAN_PANEL_MENU_SAVE_SETTINGS"] = "Salvar";
L["TITAN_PANEL_MENU_CONFIGURATION"] = "Configuração";
L["TITAN_PANEL_OPTIONS"] = "Opções";
L["TITAN_PANEL_MENU_TOP"] = "Superior"
L["TITAN_PANEL_MENU_TOP2"] = "Superior 2"
L["TITAN_PANEL_MENU_BOTTOM"] = "Inferior"
L["TITAN_PANEL_MENU_BOTTOM2"] = "Interior 2"
L["TITAN_PANEL_MENU_OPTIONS"] = TITAN_PANEL .." Tooltips e Quandros";
L["TITAN_PANEL_MENU_OPTIONS_SHORT"] = "Tooltips e Quadros";
L["TITAN_PANEL_MENU_TOP_BARS"] = "Barras Superiores"
L["TITAN_PANEL_MENU_BOTTOM_BARS"] = "Barras Inferiores"
L["TITAN_PANEL_MENU_OPTIONS_BARS"] = "Barras"
L["TITAN_PANEL_MENU_OPTIONS_MAIN_BARS"] = "Barras Superiores do " .. TITAN_PANEL;
L["TITAN_PANEL_MENU_OPTIONS_AUX_BARS"] = "Barras Inferiores do " .. TITAN_PANEL;
L["TITAN_PANEL_MENU_OPTIONS_TOOLTIPS"] = "Tooltips";
L["TITAN_PANEL_MENU_OPTIONS_FRAMES"] = "Quadros";
L["TITAN_PANEL_MENU_PLUGINS"] = "Plugins";
L["TITAN_PANEL_MENU_LOCK_BUTTONS"] = "Trancar Botões";
L["TITAN_PANEL_MENU_VERSION_SHOWN"] = "Exibir Versões dos Plugins";
L["TITAN_PANEL_MENU_LDB_SIDE"] = "Right-Side Plugin";
L["TITAN_PANEL_MENU_LDB_FORCE_LAUNCHER"] = "Force LDB Launchers to Right-Side";
L["TITAN_PANEL_MENU_CATEGORIES"] = {"Incorporados","Geral","Combate","Informação","Interface","Profissão"}
L["TITAN_PANEL_MENU_TOOLTIPS_SHOWN"] = "Exibir Tooltips";
L["TITAN_PANEL_MENU_TOOLTIPS_SHOWN_IN_COMBAT"] = "Ocultar Tooltips em Combate";
L["TITAN_PANEL_MENU_RESET"] = "Resetar o " .. TITAN_PANEL .. " para os Padrões";
L["TITAN_PANEL_MENU_TEXTURE_SETTINGS"] = "Skins";     
L["TITAN_PANEL_MENU_LSM_FONTS"] = "Painel de Fontes"
L["TITAN_PANEL_MENU_ENABLED"] = "Ativado";
L["TITAN_PANEL_MENU_DISABLED"] = "Desativado";
L["TITAN_PANEL_SHIFT_LEFT"] = "Mover a Esquerda";
L["TITAN_PANEL_SHIFT_RIGHT"] = "Mover a Direita";
L["TITAN_PANEL_MENU_SHOW_PLUGIN_TEXT"] = "Exibir Texto do Plugin";
L["TITAN_PANEL_MENU_BAR_ALWAYS"] = "Sempre Ativado";
L["TITAN_PANEL_MENU_POSITION"] = "Posição";
L["TITAN_PANEL_MENU_BAR"] = "Barra";
L["TITAN_PANEL_MENU_DISPLAY_ON_BAR"] = "Choose which bar the plugin is displayed";
L["TITAN_PANEL_MENU_SHOW"] = "Exibir Plugin";
L["TITAN_PANEL_MENU_PLUGIN_RESET"] = "Atualizar Plugins";
L["TITAN_PANEL_MENU_PLUGIN_RESET_DESC"] = "Refresh Plugin Text and Position";
    
-- localization strings for AceConfigDialog-3.0     
L["TITAN_PANEL_CONFIG_MAIN_LABEL"] = "Information display bar addon. Allows users to add data feed or launcher plugins on a control panel placed on the top and/or  of the screen.";			 
L["TITAN_TRANS_MENU_TEXT"] = "Transparência do " .. TITAN_PANEL;
L["TITAN_TRANS_MENU_TEXT_SHORT"] = "Transparência";
L["TITAN_TRANS_MENU_DESC"] = "Adjust transparency for the "..TITAN_PANEL.." bars and tooltip.";
L["TITAN_TRANS_MAIN_CONTROL_TITLE"] = "Barra Principal";
L["TITAN_TRANS_AUX_CONTROL_TITLE"] = "Barra Auxiliar";
L["TITAN_TRANS_CONTROL_TITLE_TOOLTIP"] = "Tooltip";
L["TITAN_TRANS_TOOLTIP_DESC"] = "Sets transparency for the tooltip of the various plugins.";
L["TITAN_UISCALE_MENU_TEXT"] = "Escala e Fonte do " .. TITAN_PANEL;
L["TITAN_UISCALE_MENU_TEXT_SHORT"] = "Escala e Fonte";
L["TITAN_UISCALE_CONTROL_TITLE_UI"] = "Escala da IU";
L["TITAN_UISCALE_CONTROL_TITLE_PANEL"] = "Escala do " .. TITAN_PANEL;
L["TITAN_UISCALE_CONTROL_TITLE_BUTTON"] = "Espaçamento de Botões";
L["TITAN_UISCALE_CONTROL_TITLE_ICON"] = "Espaçamento de Ícones";
L["TITAN_UISCALE_CONTROL_TOOLTIP_TOOLTIPFONT"] = "Tooltip Font Scale";
L["TITAN_UISCALE_TOOLTIP_DISABLE_TEXT"] = "Disable Tooltip Font Scale";
L["TITAN_UISCALE_MENU_DESC"] = "Controls various aspects of the UI and "..TITAN_PANEL..".";
L["TITAN_UISCALE_SLIDER_DESC"] = "Sets the scale of your entire UI.";
L["TITAN_UISCALE_PANEL_SLIDER_DESC"] = "Sets the scale for the various "..TITAN_PANEL.." buttons and icons.";
L["TITAN_UISCALE_BUTTON_SLIDER_DESC"] = "Adjusts the space between left-side plugins.";
L["TITAN_UISCALE_ICON_SLIDER_DESC"] = "Adjusts the space between right-side plugins.";
L["TITAN_UISCALE_TOOLTIP_SLIDER_DESC"] = "Adjusts the scale for the tooltip of the various plugins.";
L["TITAN_UISCALE_DISABLE_TOOLTIP_DESC"] = "Disables "..TITAN_PANEL.." Tooltip Font Scale Control.";

L["TITAN_SKINS_TITLE"] = "Skins " .. TITAN_PANEL;
L["TITAN_SKINS_OPTIONS_CUSTOM"] = "Skins - Personalizado";
L["TITAN_SKINS_TITLE_CUSTOM"] = "Skins Personalizadas do " .. TITAN_PANEL;
L["TITAN_SKINS_MAIN_DESC"] = "All custom skins are assumed to be in: \n"
			.."..\\AddOns\\Titan\\Artwork\\Custom\\<Skin Folder>\\ ".."\n"
			.."\n"..TITAN_PANEL.." and custom skins are stored under the Custom folder."
L["TITAN_SKINS_LIST_TITLE"] = "Skin List";
L["TITAN_SKINS_SET_DESC"] = "Select a skin for the "..TITAN_PANEL.." bars.";
L["TITAN_SKINS_SET_HEADER"] = "Set "..TITAN_PANEL.." Skin";
L["TITAN_SKINS_RESET_HEADER"] = "Reset "..TITAN_PANEL.." Skins";
L["TITAN_SKINS_NEW_HEADER"] = "Add New Skin";
L["TITAN_SKINS_NAME_TITLE"] = "Skin Name"
L["TITAN_SKINS_NAME_DESC"] = "Enter a name for your new skin. It will be used in the skin dropdown lists.";
L["TITAN_SKINS_PATH_TITLE"] = "<Skin Folder>"
L["TITAN_SKINS_PATH_DESC"] = "<Skin Folder> under the "..TITAN_PANEL.." install. See the example above." 
L["TITAN_SKINS_ADD_HEADER"] = "Add Skin";
L["TITAN_SKINS_ADD_DESC"] = "Adds a new skin to the list of available skins for "..TITAN_PANEL..".";
L["TITAN_SKINS_REMOVE_HEADER"] = "Remove Skin";
L["TITAN_SKINS_REMOVE_DESC"] = "Select a custom skin to remove."
L["TITAN_SKINS_REMOVE_BUTTON"] = "Remove";
L["TITAN_SKINS_REMOVE_BUTTON_DESC"] = "Removes the selected custom skin.";
L["TITAN_SKINS_REMOVE_NOTES"] = "You are responsible for removing any unwanted custom skins "
	.."from the "..TITAN_PANEL.." install folder. Addons can not add or remove files."
L["TITAN_SKINS_RESET_DEFAULTS_TITLE"] = "Reset to Defaults";
L["TITAN_SKINS_RESET_DEFAULTS_DESC"] = "Resets the skin list to the default "..TITAN_PANEL.." skins.";
L["TITAN_PANEL_MENU_LSM_FONTS_DESC"] = "Select the font type for the various plugins on the "..TITAN_PANEL.." Bars.";
L["TITAN_PANEL_MENU_FONT_SIZE"] = "Font Size";
L["TITAN_PANEL_MENU_FONT_SIZE_DESC"] = "Sets the size for the "..TITAN_PANEL.." font.";
L["TITAN_PANEL_MENU_FRAME_STRATA"] = ""..TITAN_PANEL.." Frame Strata";
L["TITAN_PANEL_MENU_FRAME_STRATA_DESC"] = "Adjusts the frame strata for the "..TITAN_PANEL.." Bar(s).";
-- /end localization strings for AceConfigDialog-3.0

L["TITAN_PANEL_MENU_ADV"] = "Avançado";
L["TITAN_PANEL_MENU_ADV_DESC"] = "Change Timers only if you experience issues with frames not adjusting.".."\n";
L["TITAN_PANEL_MENU_ADV_PEW"] = "Entering World";
L["TITAN_PANEL_MENU_ADV_PEW_DESC"] = "Change value (usually increase) if frames do not adjust when entering / leaving world or an instance.";
L["TITAN_PANEL_MENU_ADV_VEHICLE"] = "Vehicle";
L["TITAN_PANEL_MENU_ADV_VEHICLE_DESC"] = "Change value (usually increase) if frames do not adjust when entering / leaving vehicle.";
    
L["TITAN_AUTOHIDE_TOOLTIP"] = "Toggles " .. TITAN_PANEL .. " auto-Ocultar on/off feature";
     
L["TITAN_BAG_FORMAT"] = "%d/%d";
L["TITAN_BAG_BUTTON_LABEL"] = "Bolsas: ";
L["TITAN_BAG_TOOLTIP"] = "Informações de Bolsas";
L["TITAN_BAG_TOOLTIP_HINTS"] = "Dica: Clique para abrir todas as bolsas.";
L["TITAN_BAG_MENU_TEXT"] = "Bolsa";
L["TITAN_BAG_USED_SLOTS"] = "Espaços Usados";
L["TITAN_BAG_FREE_SLOTS"] = "Espaços Vazios";
L["TITAN_BAG_BACKPACK"] = "Mochila";
L["TITAN_BAG_MENU_SHOW_USED_SLOTS"] = "Exibir Espaços Usados";
L["TITAN_BAG_MENU_SHOW_AVAILABLE_SLOTS"] = "Exibir Espaços Disponíveis";
L["TITAN_BAG_MENU_SHOW_DETAILED"] = "Exibir Tooltip Detalhada";
L["TITAN_BAG_MENU_IGNORE_SLOTS"] = "Ignorar Contêineres";
L["TITAN_BAG_MENU_IGNORE_PROF_BAGS_SLOTS"] = "Ignorar Bolsas de Profissão";
L["TITAN_BAG_PROF_BAG_NAMES"] = {
-- Enchanting
"Saco de Magitrama Encantado", "Bolsa de Runatrama Encantada", "Algibeira do Encantador", "Grande Bolsa de Encantamentos", "Bolsa de Fogo Místico", 
"Bolsa Misteriosa", "Bolsa Sobrenatural", "Bolsa Tarde Encantadora - Exclusividade \"Lepos'Tiche\"",
-- Engineering
"Caixa de Ferramentas Pesada", "Caixa de Ferramentas de Ferrovil", "Caixa de Ferramentas de Titânico", "Caixa de Ferramentas de Elemêntio", "Bolsa de Alta Tecnologia - Linha \"Lepos'Tiche - Maddy\"",
-- Herbalism
"Bolsa de Herborismo", "Bolsa de Herborismo Cenariana", "Algibeira de Cenarius", "Sacola Botânica de Mika", "Bolsa Esmeralda", "Bolsa de Expedição Hyjal",
"Bolsa de Carga de Ervas - Linha \"Lepos'Tiche Esverdeada\"",
-- Inscription
"Algibeira do Escriba", "Pacote de Bolsos Infinitos", "Mochila Escolar - Linha \"Lepos'Tiche - Xandera\"", "Algibeira do Escriba Real",
-- Jewelcrafting
"Bolsa de Gemas", "Saco de Joias", "Amarra Cravejada de Gemas - Exclusividade \"Lepos'Tiche\"", "Bolsa de Gemas de Seda Luxuosa",
-- Leatherworking
"Algibeira do Coureiro", "Bolsa de Muitos Pelegos", "Mala de Viagem do Coureador", "Bolsa de Couro \"Lepos'Tiche - Miya\"",
-- Mining
"Saco de Mineração", "Bolsa de Mineração Reforçada", "Bolsa de Mineração de Mamute", "Bolsa de Metal Precioso \"Lepos'Tiche - Christina\"", "Bolsa de Mineração Triplamente Reforçada",
-- Fishing
"Caixa de Pesca do Mestre Anzol",
-- Cooking
"Portable Refrigerator",
};

L["TITAN_CLOCK_TOOLTIP"] = "Relógio";     
L["TITAN_CLOCK_TOOLTIP_VALUE"] = "Server Offset Hour Value: ";
L["TITAN_CLOCK_TOOLTIP_LOCAL_TIME"] = "Horário Local: ";
L["TITAN_CLOCK_TOOLTIP_SERVER_TIME"] = "Horário do Servidor: ";
L["TITAN_CLOCK_TOOLTIP_SERVER_ADJUSTED_TIME"] = "Horário Ajustado do Servidor: ";
L["TITAN_CLOCK_TOOLTIP_HINT1"] = "Hint: Left-click to adjust the offset hour"
L["TITAN_CLOCK_TOOLTIP_HINT2"] = "(server time only) and the 12/24H time format.";
L["TITAN_CLOCK_TOOLTIP_HINT3"] = "Shift Left-Click to toggle the Calendar on/off.";
L["TITAN_CLOCK_CONTROL_TOOLTIP"] = "Server Hour Offset: ";
L["TITAN_CLOCK_CONTROL_TITLE"] = "Offset";
L["TITAN_CLOCK_CONTROL_HIGH"] = "+12";
L["TITAN_CLOCK_CONTROL_LOW"] = "-12";
L["TITAN_CLOCK_CHECKBUTTON"] = "24H";
L["TITAN_CLOCK_CHECKBUTTON_TOOLTIP"] = "Altera a exbição do horário entre os formatos AM/PM ou 24 horas.";
L["TITAN_CLOCK_MENU_TEXT"] = "Relógio";
L["TITAN_CLOCK_MENU_LOCAL_TIME"] = "Exibir Horário Local (L)";
L["TITAN_CLOCK_MENU_SERVER_TIME"] = "Exibir Horário do Servidor (S)";
L["TITAN_CLOCK_MENU_SERVER_ADJUSTED_TIME"] = "Exibir Horário Ajustado do Servidor (A)";
L["TITAN_CLOCK_MENU_DISPLAY_ON_RIGHT_SIDE"] = "Exibir no Lado Direito";
L["TITAN_CLOCK_MENU_HIDE_GAMETIME"] = "Ocultar Botão de Hora/Calendário";
L["TITAN_CLOCK_MENU_HIDE_MAPTIME"] = "Ocultar Botão de Hora";
L["TITAN_CLOCK_MENU_HIDE_CALENDAR"] = "Ocultar Botão do Calendário";
     
     
L["TITAN_COORDS_FORMAT"] = "(%.d, %.d)";
L["TITAN_COORDS_FORMAT2"] = "(%.1f, %.1f)";
L["TITAN_COORDS_FORMAT3"] = "(%.2f, %.2f)";
L["TITAN_COORDS_FORMAT_LABEL"] = "(xx , yy)";
L["TITAN_COORDS_FORMAT2_LABEL"] = "(xx.x , yy.y)";
L["TITAN_COORDS_FORMAT3_LABEL"] = "(xx.xx , yy.yy)";
L["TITAN_COORDS_FORMAT_COORD_LABEL"] = "Formato das Coordenadas";
L["TITAN_COORDS_BUTTON_LABEL"] = "Loc: ";
L["TITAN_COORDS_TOOLTIP"] = "Informações de Localização";
L["TITAN_COORDS_TOOLTIP_HINTS_1"] = "Dica: Shift + Clique para adicionar informações"
L["TITAN_COORDS_TOOLTIP_HINTS_2"] = "de sua localização para o chat message.";
L["TITAN_COORDS_TOOLTIP_ZONE"] = "Zona: ";
L["TITAN_COORDS_TOOLTIP_SUBZONE"] = "Sub Zona: ";
L["TITAN_COORDS_TOOLTIP_PVPINFO"] = "Informação JvJ: ";
L["TITAN_COORDS_TOOLTIP_HOMELOCATION"] = "Localização da Casa";
L["TITAN_COORDS_TOOLTIP_INN"] = "Estalagem: ";
L["TITAN_COORDS_MENU_TEXT"] = "Localização";
L["TITAN_COORDS_MENU_SHOW_ZONE_ON_PANEL_TEXT"] = "Exibir Zone Text";
L["TITAN_COORDS_MENU_SHOW_COORDS_ON_MAP_TEXT"] = "Exibir Coordinates on World Map";
L["TITAN_COORDS_MAP_CURSOR_COORDS_TEXT"] = "Cursor: %s";
L["TITAN_COORDS_MAP_PLAYER_COORDS_TEXT"] = "Jogador: %s";
L["TITAN_COORDS_NO_COORDS"] = "Sem Coordenadas";
L["TITAN_COORDS_MENU_SHOW_LOC_ON_MINIMAP_TEXT"] = "Exibir Location Name Above Minimap";
L["TITAN_COORDS_MENU_UPDATE_WORLD_MAP"] = "Update World Map When Zone Changes";
     
L["TITAN_FPS_FORMAT"] = "%.1f";
L["TITAN_FPS_BUTTON_LABEL"] = "QPS: ";
L["TITAN_FPS_MENU_TEXT"] = "QPS";
L["TITAN_FPS_TOOLTIP_CURRENT_FPS"] = "QPS Atual: ";
L["TITAN_FPS_TOOLTIP_AVG_FPS"] = "QPS Médio: ";
L["TITAN_FPS_TOOLTIP_MIN_FPS"] = "QPS Mínimo: ";
L["TITAN_FPS_TOOLTIP_MAX_FPS"] = "QPS Máximo: ";
L["TITAN_FPS_TOOLTIP"] = "Quadros por Segundo";
     
L["TITAN_LATENCY_FORMAT"] = "%d".."ms";
L["TITAN_LATENCY_BANDWIDTH_FORMAT"] = "%.3f ".."KB/s";
L["TITAN_LATENCY_BUTTON_LABEL"] = "Latência: ";
L["TITAN_LATENCY_TOOLTIP"] = "Status da Rede";
L["TITAN_LATENCY_TOOLTIP_LATENCY_HOME"] = "Latência do Reino (local): ";
L["TITAN_LATENCY_TOOLTIP_LATENCY_WORLD"] = "Latência do Jogo (global): ";
L["TITAN_LATENCY_TOOLTIP_BANDWIDTH_IN"] = "Banda de Entrada: ";
L["TITAN_LATENCY_TOOLTIP_BANDWIDTH_OUT"] = "Banda de Saída: ";
L["TITAN_LATENCY_MENU_TEXT"] = "Latência";
     
L["TITAN_LOOTTYPE_BUTTON_LABEL"] = "Saque: ";
L["TITAN_LOOTTYPE_FREE_FOR_ALL"] = "\"Cada Um Por Si\"";
L["TITAN_LOOTTYPE_ROUND_ROBIN"] = "\"Rodízio\"";
L["TITAN_LOOTTYPE_MASTER_LOOTER"] = "Mestre Saqueador";
L["TITAN_LOOTTYPE_GROUP_LOOT"] = "Saque em Grupo";
L["TITAN_LOOTTYPE_NEED_BEFORE_GREED"] = "Necessidade sobre Ganância";
L["TITAN_LOOTTYPE_PERSONAL"] = "Personal";
L["TITAN_LOOTTYPE_TOOLTIP"] = "Informação de Tipo de Saque";
L["TITAN_LOOTTYPE_MENU_TEXT"] = "Tipo de Saque";
L["TITAN_LOOTTYPE_RANDOM_ROLL_LABEL"] = "Jogada Aleatória";
L["TITAN_LOOTTYPE_TOOLTIP_HINT1"] = "Dica: Clique para uma jogada aleatória.";
L["TITAN_LOOTTYPE_TOOLTIP_HINT2"] = "Selecione o tipo de jogada com o menu acessível com o botão direito do mouse.";
L["TITAN_LOOTTYPE_DUNGEONDIFF_LABEL"] = "Dificuldade da Masmorra";
L["TITAN_LOOTTYPE_DUNGEONDIFF_LABEL2"] = "Dificuldade da Raide";
L["TITAN_LOOTTYPE_SHOWDUNGEONDIFF_LABEL"] = "Exibir Dificuldade da Masmorra/Raide";
L["TITAN_LOOTTYPE_SETDUNGEONDIFF_LABEL"] = "Configurar Dificuldade da Masmorra";
L["TITAN_LOOTTYPE_SETRAIDDIFF_LABEL"] = "Configurar Dificuldade da Raide";
L["TITAN_LOOTTYPE_AUTODIFF_LABEL"] = "Automático (Baseado no Grupo)";
     
L["TITAN_MEMORY_FORMAT"] = "%.3f".."MB";
L["TITAN_MEMORY_FORMAT_KB"] = "%d".."KB";
L["TITAN_MEMORY_RATE_FORMAT"] = "%.3f".."KB/s";
L["TITAN_MEMORY_BUTTON_LABEL"] = "Memória: ";
L["TITAN_MEMORY_TOOLTIP"] = "Uso da Memória";
L["TITAN_MEMORY_TOOLTIP_CURRENT_MEMORY"] = "Atual: ";
L["TITAN_MEMORY_TOOLTIP_INITIAL_MEMORY"] = "Inicial: ";
L["TITAN_MEMORY_TOOLTIP_INCREASING_RATE"] = "Taxa de Aumento: ";
L["TITAN_MEMORY_KBMB_LABEL"] = "KB/MB";     
     
L["TITAN_MONEY_FORMAT"] = "%d".."o"..", %02d".."p"..", %02d".."c";
     
L["TITAN_PERFORMANCE_TOOLTIP"] = "Informações de Performance";
L["TITAN_PERFORMANCE_MENU_TEXT"] = "Performance";
L["TITAN_PERFORMANCE_ADDONS"] = "Addon Usage";
L["TITAN_PERFORMANCE_ADDON_MEM_USAGE_LABEL"] = "Uso de Memória de Addons";
L["TITAN_PERFORMANCE_ADDON_MEM_FORMAT_LABEL"] = "Addon Memory Format";
L["TITAN_PERFORMANCE_ADDON_CPU_USAGE_LABEL"] = "Uso de CPU por Addons";
L["TITAN_PERFORMANCE_ADDON_NAME_LABEL"] = "Nome:";
L["TITAN_PERFORMANCE_ADDON_USAGE_LABEL"] = "Uso";
L["TITAN_PERFORMANCE_ADDON_RATE_LABEL"] = "Aumento";
L["TITAN_PERFORMANCE_ADDON_TOTAL_MEM_USAGE_LABEL"] = "Total de Memória de Addon:";
L["TITAN_PERFORMANCE_ADDON_TOTAL_CPU_USAGE_LABEL"] = "Tempo de CPU Total:";
L["TITAN_PERFORMANCE_MENU_SHOW_FPS"] = "Exibir QPS";
L["TITAN_PERFORMANCE_MENU_SHOW_LATENCY"] = "Exibir Latência do Reino";
L["TITAN_PERFORMANCE_MENU_SHOW_LATENCY_WORLD"] = "Exibir Latência do Jogo";
L["TITAN_PERFORMANCE_MENU_SHOW_MEMORY"] = "Exibir Memória";
L["TITAN_PERFORMANCE_MENU_SHOW_ADDONS"] = "Exibir Addon Memory Usage";
L["TITAN_PERFORMANCE_MENU_SHOW_ADDON_RATE"] = "Exibir Addon Usage Rate";
L["TITAN_PERFORMANCE_MENU_CPUPROF_LABEL"] = "CPU Profiling Mode";
L["TITAN_PERFORMANCE_MENU_CPUPROF_LABEL_ON"] = "Enable CPU Profiling Mode ";
L["TITAN_PERFORMANCE_MENU_CPUPROF_LABEL_OFF"] = "Disable CPU Profiling Mode ";
L["TITAN_PERFORMANCE_CONTROL_TOOLTIP"] = "Addons Monitorados: ";
L["TITAN_PERFORMANCE_CONTROL_TITLE"] = "Addons Monitorados";
L["TITAN_PERFORMANCE_CONTROL_HIGH"] = "40";
L["TITAN_PERFORMANCE_CONTROL_LOW"] = "1";
L["TITAN_PERFORMANCE_TOOLTIP_HINT"] = "Dica: Clique para forçar a coleção de lixo.";

L["TITAN_XP_FORMAT"] = "%s";
L["TITAN_XP_PERCENT_FORMAT"] = "(%.1f%%)";
L["TITAN_XP_BUTTON_LABEL_XPHR_LEVEL"] = "EXP/hr This Level: ";
L["TITAN_XP_BUTTON_LABEL_XPHR_SESSION"] = "EXP/hr This Session: ";
L["TITAN_XP_BUTTON_LABEL_TOLEVEL_TIME_LEVEL"] = "Time To Level: ";
L["TITAN_XP_LEVEL_COMPLETE"] = "Level Complete: ";
L["TITAN_XP_TOTAL_RESTED"] = "Rested: ";
L["TITAN_XP_XPTOLEVELUP"] = "EXP To Level: ";
L["TITAN_XP_TOOLTIP"] = "EXP Info";
L["TITAN_XP_TOOLTIP_TOTAL_TIME"] = "Total Time Played: ";
L["TITAN_XP_TOOLTIP_LEVEL_TIME"] = "Time Played This Level: ";
L["TITAN_XP_TOOLTIP_SESSION_TIME"] = "Time Played This Session: ";
L["TITAN_XP_TOOLTIP_TOTAL_XP"] = "Total XP Required This Level: ";
L["TITAN_XP_TOOLTIP_LEVEL_XP"] = "XP Gained This Level: ";
L["TITAN_XP_TOOLTIP_TOLEVEL_XP"] = "XP Needed To Level: ";
L["TITAN_XP_TOOLTIP_SESSION_XP"] = "XP Gained This Session: ";
L["TITAN_XP_TOOLTIP_XPHR_LEVEL"] = "XP/HR This Level: ";
L["TITAN_XP_TOOLTIP_XPHR_SESSION"] = "XP/HR This Session: ";     
L["TITAN_XP_TOOLTIP_TOLEVEL_LEVEL"] = "Time To Level (Level Rate): ";
L["TITAN_XP_TOOLTIP_TOLEVEL_SESSION"] = "Time To Level (Session Rate): ";
L["TITAN_XP_MENU_TEXT"] = "EXP";
L["TITAN_XP_MENU_SHOW_XPHR_THIS_LEVEL"] = "Exibir XP/HR This Level";
L["TITAN_XP_MENU_SHOW_XPHR_THIS_SESSION"] = "Exibir XP/HR This Session";
L["TITAN_XP_MENU_SHOW_RESTED_TOLEVELUP"] = "Exibir Multi-Info View";
L["TITAN_XP_MENU_SIMPLE_BUTTON_TITLE"] = "Button";
L["TITAN_XP_MENU_SIMPLE_BUTTON_RESTED"] = "Exibir Rested XP";
L["TITAN_XP_MENU_SIMPLE_BUTTON_TOLEVELUP"] = "Exibir XP To Level";
L["TITAN_XP_MENU_SIMPLE_BUTTON_KILLS"] = "Exibir Estimated Kills To Level";
L["TITAN_XP_MENU_RESET_SESSION"] = "Resetar Sessão";
L["TITAN_XP_MENU_REFRESH_PLAYED"] = "Refresh Timers";
L["TITAN_XP_UPDATE_PENDING"] = "Atualizando...";
L["TITAN_XP_KILLS_LABEL"] = "Kills To Level (at %s XP gained last): ";
L["TITAN_XP_KILLS_LABEL_SHORT"] = "Est. Kills: ";
L["TITAN_XP_BUTTON_LABEL_SESSION_TIME"] = "Session Time: ";
L["TITAN_XP_MENU_SHOW_SESSION_TIME"] = "Exibir Session Time";
L["TITAN_XP_GAIN_PATTERN"] = "(.*) dies, you gain (%d+) experience.";
L["TITAN_XP_XPGAINS_LABEL_SHORT"] = "Est. Gains: ";
L["TITAN_XP_XPGAINS_LABEL"] = "XP Gains To Level (at %s XP gained last): ";
L["TITAN_XP_MENU_SIMPLE_BUTTON_XPGAIN"] = "Exibir Estimated XP Gains To Level";

     --Titan Repair
L["REPAIR_LOCALE"] = {
          menu = "Conserto",
          tooltip = "Informações de Conserto",
          button = "Durabilidade: ",
          normal = "Custo de Conserto (Normal): ",
          friendly = "Custo de Conserto (Respeitado): ",
          honored = "Custo de Conserto (Honrado): ",
          revered = "Custo de Conserto (Reverenciado): ",
          exalted = "Custo de Conserto (Exaltado): ",
          buttonNormal = "Exibir Normal",
          buttonFriendly = "Exibir Respeitado (5%)",
          buttonHonored = "Exibir Honrado (10%)",
          buttonRevered = "Exibir Reverenciado (15%)",
          buttonExalted = "Exibir Exaltado (20%)",
          percentage = "Exibir como Porcentagem",
          itemnames = "Exibir Nome dos Itens",
          mostdamaged = "Exibir o Mais Danificado",
          Exibirdurabilityframe = "Exibir Quadro de Durabilidade",
          undamaged = "Exibir Itens Não Danificados",
          discount = "Desconto",
          nothing = "Nada Danificado",
          confirmation = "Do you want to repair all items ?",
          badmerchant = "This merchant cannot repair. Displaying normal repair costs instead.",
          popup = "Exibir Popup de Conserto",
          showinventory = "Calculate Inventory Damage",
          WholeScanInProgress = "Atualizando...",
          AutoReplabel = "Auto Conserto",
          AutoRepitemlabel = "Auto Consertar Todos os Itens",
          ShowRepairCost = "Exibir Custo de Conserto",
          ignoreThrown = "Ignore Thrown",
          ShowItems = "Exibir Itens",
          ShowDiscounts = "Exibir Descontos",
          ShowCosts = "Exibir Custos",
          Items = "Itens",
          Discounts = "Descontos",
          Costs = "Custos",
          CostTotal = "Custo Total",
          CostBag = "Custo dos Itens na Bolsa",
          CostEquip = "Custo dos Itens Equipados",
          TooltipOptions = "Tooltip",
    };
     
     L["TITAN_REPAIR"] = "Titan Consertos"
     L["TITAN_REPAIR_GBANK_TOTAL"] = "Guild Bank Funds :"
     L["TITAN_REPAIR_GBANK_WITHDRAW"] = "Guild Bank Withdrawal Allowed :"
     L["TITAN_REPAIR_GBANK_USEFUNDS"] = "Use Guild Bank Funds"
     L["TITAN_REPAIR_GBANK_NOMONEY"] = "Guild Bank can't afford the repair cost, or you can't withdraw that much."
     L["TITAN_REPAIR_GBANK_NORIGHTS"] = "You are either not in a guild or you don't have permission to use the guild bank to repair your items."
     L["TITAN_REPAIR_CANNOT_AFFORD"] = "You cannot afford to repair, at this time."
     L["TITAN_REPAIR_REPORT_COST_MENU"] = "Report Repair Cost to Chat"
     L["TITAN_REPAIR_REPORT_COST_CHAT"] = "Custo de conserto foi "
     
-- L["TITAN_PLUGINS_MENU_TITLE"] = "Plugins do " .. TITAN_PANEL;

L["TITAN_GOLD_TOOLTIPTEXT"] = "Total Gold on";
L["TITAN_GOLD_ITEMNAME"] = "Titan Gold";
L["TITAN_GOLD_CLEAR_DATA_TEXT"] = "Limpar Banco de Dados";
L["TITAN_GOLD_RESET_SESS_TEXT"] = "Resetar Sessão Atual";
L["TITAN_GOLD_DB_CLEARED"] = "Titan Gold - Database Cleared.";
L["TITAN_GOLD_SESSION_RESET"] = "Titan Ouro - Sessão resetada.";
L["TITAN_GOLD_MENU_TEXT"] = "Ouro";
L["TITAN_GOLD_TOOLTIP"] = "Informações de Ouro";
L["TITAN_GOLD_TOGGLE_PLAYER_TEXT"] = "Display Player Gold";
L["TITAN_GOLD_TOGGLE_ALL_TEXT"] = "Display Server Gold";
L["TITAN_GOLD_SESS_EARNED"] = "Ganho nesta Sessão";
L["TITAN_GOLD_PERHOUR_EARNED"] = "Ganho por Hora";
L["TITAN_GOLD_SESS_LOST"] = "Perda Nesta Sessão";
L["TITAN_GOLD_PERHOUR_LOST"] = "Perda por Hora";
L["TITAN_GOLD_STATS_TITLE"] = "Estatísticas da Sessão";
L["TITAN_GOLD_TTL_GOLD"] = "Ouro Total";
L["TITAN_GOLD_START_GOLD"] = "Ouro Inicial";
L["TITAN_GOLD_TOGGLE_SORT_GOLD"] = "Ordernar Tabela por Ouro";
L["TITAN_GOLD_TOGGLE_SORT_NAME"] = "Ordenar Ouro por Nome";
L["TITAN_GOLD_TOGGLE_GPH_SHOW"] = "Exibir Ouro por Hora";
L["TITAN_GOLD_TOGGLE_GPH_HIDE"] = "Ocultar Gold Per Hour";
L["TITAN_GOLD_GOLD"] = "o";
L["TITAN_GOLD_SILVER"] = "p";
L["TITAN_GOLD_COPPER"] = "c";
L["TITAN_GOLD_STATUS_PLAYER_SHOW"] = "Visível";
L["TITAN_GOLD_STATUS_PLAYER_HIDE"] = "Escondido";
L["TITAN_GOLD_DELETE_PLAYER"] = "Apagar Personagem";
L["TITAN_GOLD_SHOW_PLAYER"] = "Exibir Personagem";
L["TITAN_GOLD_FACTION_PLAYER_ALLY"] = "Aliança";
L["TITAN_GOLD_FACTION_PLAYER_HORDE"] = "Horda";
L["TITAN_GOLD_CLEAR_DATA_WARNING"] = GREEN_FONT_COLOR_CODE .. "Atenção: "
.. FONT_COLOR_CODE_CLOSE .. "This setting will wipe your Titan Gold database. "
.. "If you wish to continue with this operation, push 'Accept', otherwise push 'Cancel' or the 'Escape' key.";
L["TITAN_GOLD_COIN_NONE"] = "Exibir Nenhum Rótulo";
L["TITAN_GOLD_COIN_LABELS"] = "Exibir Rótulo de Texto";
L["TITAN_GOLD_COIN_ICONS"] = "Exibir Rótulo de Ícones";
L["TITAN_GOLD_ONLY"] = "Exibir Somente Ouro";
L["TITAN_GOLD_COLORS"] = "Exibir Gold Colors";

L["TITAN_VOLUME_TOOLTIP"] = "Informação de Volume";
L["TITAN_VOLUME_MASTER_TOOLTIP_VALUE"] = "Master Sound Volume: ";
L["TITAN_VOLUME_SOUND_TOOLTIP_VALUE"] = "Effects Sound Volume: ";
L["TITAN_VOLUME_AMBIENCE_TOOLTIP_VALUE"] = "Ambience Sound Volume: ";
L["TITAN_VOLUME_DIALOG_TOOLTIP_VALUE"] = "Dialog Sound Volume: ";
L["TITAN_VOLUME_MUSIC_TOOLTIP_VALUE"] = "Music Sound Volume: ";
L["TITAN_VOLUME_MICROPHONE_TOOLTIP_VALUE"] = "Microphone Sound Volume: ";
L["TITAN_VOLUME_SPEAKER_TOOLTIP_VALUE"] = "Speaker Sound Volume: ";
L["TITAN_VOLUME_TOOLTIP_HINT1"] = "Hint: Clique para ajustar o"
L["TITAN_VOLUME_TOOLTIP_HINT2"] = "volume do som.";
L["TITAN_VOLUME_CONTROL_TOOLTIP"] = "Volume Control: ";
L["TITAN_VOLUME_CONTROL_TITLE"] = "Volume Control";
L["TITAN_VOLUME_MASTER_CONTROL_TITLE"] = "Geral";
L["TITAN_VOLUME_SOUND_CONTROL_TITLE"] = "Efeitos";
L["TITAN_VOLUME_AMBIENCE_CONTROL_TITLE"] = "Ambiente";
L["TITAN_VOLUME_DIALOG_CONTROL_TITLE"] = "Dialog";
L["TITAN_VOLUME_MUSIC_CONTROL_TITLE"] = "Música";
L["TITAN_VOLUME_MICROPHONE_CONTROL_TITLE"] = "Microfone";
L["TITAN_VOLUME_SPEAKER_CONTROL_TITLE"] = "Auto-falante";
L["TITAN_VOLUME_CONTROL_HIGH"] = "Alto";
L["TITAN_VOLUME_CONTROL_LOW"] = "Baixo";
L["TITAN_VOLUME_MENU_TEXT"] = "Controle do Volume";
L["TITAN_VOLUME_MENU_AUDIO_OPTIONS_LABEL"] = "Exibir Opções de Som/Voz";
L["TITAN_VOLUME_MENU_OVERRIDE_BLIZZ_SETTINGS"] = "Ignorar Configurações de Volume da Blizzard";
