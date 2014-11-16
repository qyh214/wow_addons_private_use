--[[--------------------------------------------------------------------
	Grid
	Compact party and raid unit frames.
	Copyright (c) 2006-2014 Kyle Smith (Pastamancer), Phanx
	All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info5747-Grid.html
	http://www.wowace.com/addons/grid/
	http://www.curse.com/addons/wow/grid
------------------------------------------------------------------------
	GridLocale-ptBR.lua
	Brazilian Portuguese localization
	Contributors: heltonaugusto, leocolpas
----------------------------------------------------------------------]]

if not GetLocale():match("^pt") then return end

local _, Grid = ...
local L = { }
Grid.L = L

------------------------------------------------------------------------
--	GridCore

L["Debugging"] = "Depurando"
-- L["Debugging messages help developers or testers see what is happening inside Grid in real time. Regular users should leave debugging turned off except when troubleshooting a problem for a bug report."] = ""
-- L["Enable debugging messages for the %s module."] = ""
-- L["General"] = ""
L["Module debugging menu."] = "Menu de depuração do modulo"
-- L["Open Grid's options in their own window, instead of the Interface Options window, when typing /grid or right-clicking on the minimap icon, DataBroker icon, or layout tab."] = ""
-- L["Output Frame"] = ""
L["Right-Click for more options."] = "Clique-direito para mais opções."
-- L["Show debugging messages in this frame."] = ""
L["Show minimap icon"] = "Mostrar ícone do minimapa"
-- L["Show the Grid icon on the minimap. Note that some DataBroker display addons may hide the icon regardless of this setting."] = ""
-- L["Standalone options"] = ""
L["Toggle debugging for %s."] = "Alternar depuração para %s"

------------------------------------------------------------------------
--	GridFrame

L["Adjust the font outline."] = "Ajustar o contorno da fonte"
L["Adjust the font settings"] = "Ajustar as configurações da fonte"
L["Adjust the font size."] = "Ajustar o tamanho da fonte"
L["Adjust the height of each unit's frame."] = "Ajustar a altura do quadro de cada unidade."
L["Adjust the size of the border indicators."] = "Ajustar o tamanho dos indicadores de bordas."
L["Adjust the size of the center icon."] = "Ajustar o tamanho do ícone central"
L["Adjust the size of the center icon's border."] = "Ajustar o tamanho da borda do ícone central"
L["Adjust the size of the corner indicators."] = "Ajustar o tamanho dos indicadores de canto"
L["Adjust the texture of each unit's frame."] = "Ajustar a textura do quadro de cada unidade"
L["Adjust the width of each unit's frame."] = "Ajustar a largura do quadro de cada unidade"
L["Always"] = "Sempre"
L["Bar Options"] = "Opções das Barras"
L["Border"] = "Borda"
L["Border Size"] = "Tamanho da Borda"
L["Bottom Left Corner"] = "Canto inferior esquerdo"
L["Bottom Right Corner"] = "Canto inferior direito"
L["Center Icon"] = "Ícone central"
L["Center Text"] = "Texto central"
L["Center Text 2"] = "Texto central 2"
L["Center Text Length"] = "Tamanho do texto central"
L["Color the healing bar using the active status color instead of the health bar color."] = "Colore a barra de cura usando a cor do status de ativo ao invés da cor da barra de vida."
L["Corner Size"] = "Tamanho do canto"
L["Darken the text color to match the inverted bar."] = "Escurecer a cor do texto para coincidir com a cor da barra invertida."
L["Enable Mouseover Highlight"] = "Ativar destaque \"mouseover\""
-- L["Enable right-click menu"] = ""
L["Enable %s"] = "Habilitar %s"
L["Enable %s indicator"] = "Ativar indicador de %s"
L["Font"] = "Fonte"
L["Font Outline"] = "Contorno da fonte"
L["Font Shadow"] = "Sombra da fonte"
L["Font Size"] = "Tamanho da fonte"
L["Frame"] = "Quadro"
L["Frame Alpha"] = "Alpha do quadro"
L["Frame Height"] = "Altura do quadro"
L["Frame Texture"] = "Textura do quadro"
L["Frame Width"] = "Largura do quadro"
L["Healing Bar"] = "Barra de cura"
L["Healing Bar Opacity"] = "Opacidade da barra de cura"
L["Healing Bar Uses Status Color"] = "A barra de cura usa a cor do status"
L["Health Bar"] = "Barra de vida"
L["Health Bar Color"] = "Cor da barra de vida"
L["Horizontal"] = "Horizontal"
L["Icon Border Size"] = "Tamanho da borda do ícone"
L["Icon Cooldown Frame"] = "Quadro recarga do ícone"
L["Icon Options"] = "Opções do Ícone"
L["Icon Size"] = "Tamanho do ícone"
L["Icon Stack Text"] = "Texto de agrupamento do ícone"
L["Indicators"] = "Indicadores"
L["Invert Bar Color"] = "Inverter a cor da barra"
L["Invert Text Color"] = "Inverta a cor do texto"
L["Make the healing bar use the status color instead of the health bar color."] = "Use para a barra de cura a cor estado em vez de a cor da barra de saúde."
L["Never"] = "Nunca"
L["None"] = "Nenhum(a)"
L["Number of characters to show on Center Text indicator."] = "Número de caracteres que serão mostrados no indicador de texto central."
L["OOC"] = "FDC - Fora de Combate"
L["Options for assigning statuses to indicators."] = "Opções para definir status para os indicadores."
L["Options for GridFrame."] = "Opções para o QuadroGrid"
L["Options for %s indicator."] = "Opções para o indicador de %s"
L["Options related to bar indicators."] = "Opções relativas aos indicadores das barras"
L["Options related to icon indicators."] = "Opções relativas aos indicadores dos ícones"
L["Options related to text indicators."] = "Opções relacionadas aos indicadores de texto"
L["Orientation of Frame"] = "Orientação do quadro"
L["Orientation of Text"] = "Orientação do texto"
L["Set frame orientation."] = "Definir orientação do quadro"
L["Set frame text orientation."] = "Definir orientação do texto do quadro."
L["Sets the opacity of the healing bar."] = "Define a opacidade da barra de cura."
-- L["Show the standard unit menu when right-clicking on a frame."] = ""
L["Show Tooltip"] = "Mostrar dica de jogo"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "Mostrar dica da unidade. Escolha 'Sempre', 'Nunca', ou 'FDC - Fora de Combate'"
L["Statuses"] = "Status"
L["Swap foreground/background colors on bars."] = "Troca cor frontal / cor de fundo das barras"
L["Text Options"] = "Opções de texto"
L["Thick"] = "Grosso"
L["Thin"] = "Fino"
L["Throttle Updates"] = "Atualizações do acelerador"
L["Throttle updates on group changes. This option may cause delays in updating frames, so you should only enable it if you're experiencing temporary freezes or lockups when people join or leave your group."] = "Suprimir atualizações quando houver mudança no grupo. Essa opção pode causar lentidão na atualização dos quadros, então você deve habilitar apenas se estiver passando por congelamentos ou travamentos quando pessoas entram ou saem do grupo."
L["Toggle center icon's cooldown frame."] = "Altera o quadro de recarga do ícone central"
L["Toggle center icon's stack count text."] = "Altera o texto de contagem de empilhamento do icone central"
L["Toggle mouseover highlight."] = "Alterna realce \"mouseover\" "
L["Toggle status display."] = "Alterna indicador de status."
L["Toggle the font drop shadow effect."] = "Alterna o efeito de fonte com sombra caindo."
L["Toggle the %s indicator."] = "Alterna o indicador %s."
L["Top Left Corner"] = "Canto superior esquerdo"
L["Top Right Corner"] = "Canto superior direito"
L["Vertical"] = "Vertical"

------------------------------------------------------------------------
--	GridLayout

L["10 Player Raid Layout"] = "Layout de Raide 10 Jogadores"
L["25 Player Raid Layout"] = "Layout de Raide 25 jogadores"
-- L["40 Player Raid Layout"] = ""
L["Adjust background color and alpha."] = "Ajustar cor de fundo e alpha."
L["Adjust border color and alpha."] = "Ajustar cor e alpha da borda."
L["Adjust frame padding."] = "Ajusta o \"Padding\" do quadro"
L["Adjust frame spacing."] = "Ajustar espaçamento de quadro"
L["Adjust Grid scale."] = "Ajustar escala do grid"
-- L["Adjust the extra spacing inside the layout frame, around the unit frames."] = ""
-- L["Adjust the spacing between individual unit frames."] = ""
L["Advanced"] = "Avançado"
L["Advanced options."] = "Opções avançadas."
L["Allows mouse click through the Grid Frame."] = "Permite clicks do mouse através do quadro do Grid."
L["Alt-Click to permanantly hide this tab."] = "Alt-Click para ocultar essa aba permanentemente."
L["Arena Layout"] = "Leiaute de Arena"
L["Background color"] = "Cor de fundo"
-- L["Background Texture"] = ""
L["Battleground Layout"] = "Leiaute de campo de batalha"
L["Beast"] = "Fera"
L["Border color"] = "Cor da borda"
-- L["Border Inset"] = ""
-- L["Border Size"] = ""
L["Border Texture"] = "Textura da Borda"
L["Bottom"] = "Fundo"
L["Bottom Left"] = "Fundo esquerdo"
L["Bottom Right"] = "Fundo direito"
L["By Creature Type"] = "Por tipo de criatura"
L["By Owner Class"] = "Por classe do dono"
L["Center"] = "Centro"
L["Choose the layout border texture."] = "Escolha a textura da borda do leiaute."
L["Clamped to screen"] = "Preso na tela"
L["Class colors"] = "Cores das classes"
L["Click through the Grid Frame"] = "Clicar através do quadro do Grid"
L["Color for %s."] = "Cor para %s."
L["Color of pet unit creature types."] = "Cor dos tipos de criatura de unidades de ajudantes."
L["Color of player unit classes."] = "Cor das classes de unidades de jogadores"
L["Color of unknown units or pets."] = "Cor de ajudantes ou unidades desconhecidas."
L["Color options for class and pets."] = "Opções de cor para ajudantes e classes."
L["Colors"] = "Cores"
L["Creature type colors"] = "Cores de tipos de criaturas"
L["Demon"] = "Demônio"
L["Dragonkin"] = "Draconiano"
L["Drag this tab to move Grid."] = "Arraste essa aba para mover o Grid."
L["Elemental"] = "Elemental"
L["Fallback colors"] = "Cores para Fallback"
-- L["Flexible Raid Layout"] = ""
L["Frame lock"] = "Travar quadro"
-- L["Frame Spacing"] = ""
L["Group Anchor"] = "Âncora do grupo"
L["Horizontal groups"] = "Grupos horizontais"
L["Humanoid"] = "Humanoide"
L["Layout"] = "Leiaute"
L["Layout Anchor"] = "Âncora do Leiaute"
-- L["Layout Background"] = ""
-- L["Layout Padding"] = ""
-- L["Layouts"] = ""
L["Left"] = "Esquerda"
L["Lock Grid to hide this tab."] = "Trave o Grid para ocultar essa aba."
L["Locks/unlocks the grid for movement."] = "Trava/Destrava o Grid para movimento."
L["Not specified"] = "Não especificado"
L["Options for GridLayout."] = "Opções para LeiauteGrid."
L["Padding"] = "\"Padding\""
L["Party Layout"] = "Leiaute de grupo"
L["Pet color"] = "Cor do ajudante"
L["Pet coloring"] = "Coloração do ajudante"
L["Reset Position"] = "Resetar posição"
L["Resets the layout frame's position and anchor."] = "Reseta a posição e âncora do quadro de leiaute."
L["Right"] = "Direita"
L["Scale"] = "Escala"
L["Select which layout to use when in a 10 player raid."] = "Seleciona qual leiaute usar quando estiver em uma raide de 10 jogadores."
L["Select which layout to use when in a 25 player raid."] = "Seleciona qual leiaute usar quando estiver em uma raide de 25 jogadores."
-- L["Select which layout to use when in a 40 player raid."] = ""
L["Select which layout to use when in a battleground."] = "Seleciona qual leiaute usar quando estiver em um campo de batalha."
-- L["Select which layout to use when in a flexible raid."] = ""
L["Select which layout to use when in an arena."] = "Seleciona qual layout usar quando estiver em arena."
L["Select which layout to use when in a party."] = "Seleciona qual layout usar quando estiver em grupo."
L["Select which layout to use when not in a party."] = "Seleciona qual layout usar quando não estiver em grupo."
L["Sets where Grid is anchored relative to the screen."] = "Define onde o Grid estará ancorado em relação a tela."
L["Sets where groups are anchored relative to the layout frame."] = "Define onde os grupos estão ancorados em relação ao quadro de leiaute."
L["Set the coloring strategy of pet units."] = "Define a estratégia de coloração das unidades de ajudantes."
L["Set the color of pet units."] = "Define a cor das unidades de ajudantes."
L["Show a tab for dragging when Grid is unlocked."] = "Mostre a aba quando o Grid estiver destravado."
L["Show Frame"] = "Mostrar quadro"
L["Show tab"] = "Mostrar aba"
L["Solo Layout"] = "Leiaute Solo"
L["Spacing"] = "Espaçamento"
L["Switch between horizontal/vertical groups."] = "Alternar entre grupos horizontais/verticais."
L["The color of unknown pets."] = "A cor de ajudantes desconhecidos."
L["The color of unknown units."] = "A cor de unidades desconhecidas."
L["Toggle whether to permit movement out of screen."] = "Alterna quando é permitido movimento para fora da tela."
L["Top"] = "Topo"
L["Top Left"] = "Topo esquerto"
L["Top Right"] = "Topo direito"
L["Undead"] = "Morto-vivo"
L["Unknown Pet"] = "Ajudante desconhecido"
L["Unknown Unit"] = "Unidade desconhecida"
-- L["Use the 40 Player Raid layout when in a raid group outside of a raid instance, instead of choosing a layout based on the current Raid Difficulty setting."] = ""
L["Using Fallback color"] = "Usando cor de recuo"
-- L["World Raid as 40 Player"] = ""

------------------------------------------------------------------------
--	GridLayoutLayouts

L["By Class 10"] = "Por classe 10"
L["By Class 10 w/Pets"] = "Por classe 10 c/ajudantes"
L["By Class 25"] = "Por classe 25"
L["By Class 25 w/Pets"] = "Por classe 25 c/ajudantes"
-- L["By Class 40"] = ""
-- L["By Class 40 w/Pets"] = ""
L["By Group 10"] = "Por grupo 10"
L["By Group 10 w/Pets"] = "Por grupo 10 c/ajudantes"
L["By Group 15"] = "Por grupo 15"
L["By Group 15 w/Pets"] = "Por grupo 15 c/ajudantes"
L["By Group 25"] = "Por grupo 25"
L["By Group 25 w/Pets"] = "Por grupo 25 c/ajudantes"
L["By Group 25 w/Tanks"] = "Por grupo 25 c/tanques"
L["By Group 40"] = "Por grupo 40"
L["By Group 40 w/Pets"] = "Por grupo 40 c/ajudantes"
L["By Group 5"] = "Por grupo 5"
L["By Group 5 w/Pets"] = "Por grupo 5 c/ajudantes"
L["None"] = "Nenhum"

------------------------------------------------------------------------
--	GridLDB

L["Click to toggle the frame lock."] = "Clique para alternar o travamento do quadro."

------------------------------------------------------------------------
--	GridRoster


------------------------------------------------------------------------
--	GridStatus

L["Color"] = "Cor"
L["Color for %s"] = "Cor para %s"
L["Enable"] = "Habilitar"
-- L["Opacity"] = ""
L["Options for %s."] = "Opções para %s."
L["Priority"] = "Prioridade"
L["Priority for %s"] = "Prioridade para %s"
L["Range filter"] = "Filtro de alcance"
L["Reset class colors"] = "Resetar cores de classes"
L["Reset class colors to defaults."] = "Resetar cores das classes para o padrão."
L["Show status only if the unit is in range."] = "Mostrar status somente se a unidade estiver no alcance."
L["Status"] = "Status"
L["Status: %s"] = "Status: %s"
L["Text"] = "Texto"
L["Text to display on text indicators"] = "Texto que será mostrado nos indicadores de texto"

------------------------------------------------------------------------
--	GridStatusAggro

L["Aggro"] = "Agro"
L["Aggro alert"] = "Alerta de Agro"
L["Aggro color"] = "Cor de aggro"
L["Color for Aggro."] = "Cor para agro"
L["Color for High Threat."] = "Cor de ameaça alta"
L["Color for Tanking."] = "Cor para tancar."
L["High"] = "Alto"
L["High Threat color"] = "Cor de ameaça alta"
L["Show detailed threat levels instead of simple aggro status."] = "Mostra níveis de ameaça mais detalhadamente."
L["Tank"] = "Tanque"
L["Tanking color"] = "Cor tancando"
L["Threat"] = "Ameaça"

------------------------------------------------------------------------
--	GridStatusAuras

L["Add Buff"] = "Adicionar buff"
L["Add Debuff"] = "Adicionar debuff"
L["Auras"] = "Auras"
L["<buff name>"] = "<nome do buff>"
L["Buff: %s"] = "Buff: %s"
L["Change what information is shown by the status color."] = "Muda qual informação é mostrada pela cor do status."
L["Change what information is shown by the status color and text."] = "Muda qual informação é mostrada pela cor e texto do status."
L["Change what information is shown by the status text."] = "Muda qual informação é mostrada pelo texto de status."
L["Class Filter"] = "Filtro de classe"
L["Color"] = "Cor"
L["Color to use when the %s is above the high count threshold values."] = "Cor para usar quando %s estiver acima do limite de contagem alto."
L["Color to use when the %s is between the low and high count threshold values."] = "Cor para usar quando %s estiver entre os limites baixo e alto."
L["Color when %s is below the low threshold value."] = "Cor para usar quando %s estiver menor que o limite baixo."
L["Create a new buff status."] = "Criar um novo status do buff"
L["Create a new debuff status."] = "Criar um novo status do debuff"
L["Curse"] = "Maldição"
L["<debuff name>"] = "<nome da penalidade>"
L["(De)buff name"] = "Nome do (De)buff"
L["Debuff: %s"] = "Debuff: %s"
L["Debuff type: %s"] = "Tipo de Debuff: %s"
L["Disease"] = "Doença"
L["Display status only if the buff is not active."] = "Mostra o status apenas se o buff não estiver ativo."
L["Display status only if the buff was cast by you."] = "Mostra o status apenas se o buff foi executado por você."
L["Ghost"] = "Fantasma"
L["High color"] = "Cor para Alto"
L["High threshold"] = "Limite alto"
L["Low color"] = "Cor para baixo"
L["Low threshold"] = "Limite baixo"
L["Magic"] = "Mágica"
L["Middle color"] = "Cor para médio"
L["Pet"] = "Ajudante"
L["Poison"] = "Veneno"
L["Present or missing"] = "Presente ou faltando"
L["Refresh interval"] = "Intervalo de renovação"
L["Remove an existing buff or debuff status."] = "Exclui um buff ou debuff existente do módulo de status"
L["Remove Aura"] = "Excluir (de)buff"
L["Remove %s from the menu"] = "Remove %s do menu"
L["%s colors"] = "%s cores"
L["%s colors and threshold values."] = "Cores de %s e valores limite."
-- L["Show advanced options"] = ""
--[==[ L[ [=[Show advanced options for buff and debuff statuses.

Beginning users may wish to leave this disabled until you are more familiar with Grid, to avoid being overwhelmed by complicated options menus.]=] ] = "" ]==]
L["Show duration"] = "Mostrar duração"
L["Show if mine"] = "Mostrar se for meu"
L["Show if missing"] = "Mostrar se estiver faltando"
L["Show on pets and vehicles."] = "Mostra em ajudantes e veículos"
L["Show on %s players."] = "Mostrar em %s jogadores."
L["Show status for the selected classes."] = "Mostra os status para as classes selecionadas."
L["Show the time left to tenths of a second, instead of only whole seconds."] = "Mostra o tempo restante em décimos de segundo, ao invés de apenas em segundos."
L["Show the time remaining, for use with the center icon cooldown."] = "Mostra o tempo restante, para uso no ícone central de recarga."
L["Show time left to tenths"] = "Mostra o tempo restante em décimos"
L["%s is high when it is at or above this value."] = "%s é alta quando está acima ou neste valor."
L["%s is low when it is at or below this value."] = "%s é baixa quando estiver abaixo ou neste valor."
L["Stack count"] = "Contador de agrupamento"
L["Status Information"] = "Informação de status"
L["Text"] = "Texto"
L["Time in seconds between each refresh of the status time left."] = "Tempo em segundos entre cada renovação do tempo restante do status."
L["Time left"] = "Tempo restante"

------------------------------------------------------------------------
--	GridStatusHeals

L["Heals"] = "Cura"
L["Ignore heals cast by you."] = "Ignora curas executadas por você."
L["Ignore Self"] = "Ignorar a si mesmo"
L["Incoming heals"] = "Curas vindo"
L["Minimum Value"] = "Valor minimo"
L["Only show incoming heals greater than this amount."] = "Apenas mostre cura vindo maior que essa quantidade."

------------------------------------------------------------------------
--	GridStatusHealth

L["Color deficit based on class."] = "Deficit de cor baseado na classe."
L["Color health based on class."] = "Colore a vida baseado na classe."
L["DEAD"] = "MORTO"
L["Death warning"] = "Alerta de morte"
L["FD"] = "FM"
L["Feign Death warning"] = "Alerta de fingindo morte"
L["Health"] = "Vida"
L["Health deficit"] = "Déficit de vida"
L["Health threshold"] = "Início da vida"
L["Low HP"] = "Vida baixa"
L["Low HP threshold"] = "Início de baixa vida"
L["Low HP warning"] = "Alerta de vida baixa"
L["Offline"] = "Desconectado"
L["Offline warning"] = "Alerta de desconexão"
L["Only show deficit above % damage."] = "Apenas mostre deficit além de % dano."
L["Set the HP % for the low HP warning."] = "Define a % de vida para o aviso de baixa vida"
L["Show dead as full health"] = "Mostrar morto com vida cheia"
L["Treat dead units as being full health."] = "Trata unidades mortas como tendo vida completa."
L["Unit health"] = "Vida da unidade"
L["Use class color"] = "Use a cor da classe"

------------------------------------------------------------------------
--	GridStatusMana

L["Low Mana"] = "Mana baixa"
L["Low Mana warning"] = "Alerta de mana baixa"
L["Mana"] = "Mana"
L["Mana threshold"] = "Início da mana"
L["Set the percentage for the low mana warning."] = "Define a porcentagem para aviso de mana baixa."

------------------------------------------------------------------------
--	GridStatusName

L["Color by class"] = "Colorir por classe"
L["Unit Name"] = "Nome da unidade"

------------------------------------------------------------------------
--	GridStatusRange

L["Out of Range"] = "Fora de alcance"
L["Range"] = "Alcance"
L["Range check frequency"] = "Frequência de checagem do alcance"
L["Seconds between range checks"] = "Segundos entre checagens de alcance"

------------------------------------------------------------------------
--	GridStatusReadyCheck

L["?"] = "?"
L["AFK"] = "LDT"
L["AFK color"] = "Cor do LDT"
L["Color for AFK."] = "Cor para LDT"
L["Color for Not Ready."] = "Cor para não pronto."
L["Color for Ready."] = "Cor para pronto."
L["Color for Waiting."] = "Cor para esperando."
L["Delay"] = "Atraso"
L["Not Ready color"] = "Cor para não pronto"
L["R"] = "P"
L["Ready Check"] = "Checar prontos"
L["Ready color"] = "Cor para pronto"
L["Set the delay until ready check results are cleared."] = "Define o atraso até que os resultados do \"checar prontos\" sejam apagados."
L["Waiting color"] = "Cor de esperando"
L["X"] = "X"

------------------------------------------------------------------------
--	GridStatusResurrect

-- L["Casting color"] = ""
-- L["Pending color"] = ""
-- L["RES"] = ""
-- L["Resurrection"] = ""
-- L["Show the status until the resurrection is accepted or expires, instead of only while it is being cast."] = ""
-- L["Show until used"] = ""
-- L["Use this color for resurrections that are currently being cast."] = ""
-- L["Use this color for resurrections that have finished casting and are waiting to be accepted."] = ""

------------------------------------------------------------------------
--	GridStatusTarget

L["Target"] = "Alvo"
L["Your Target"] = "Seu alvo"

------------------------------------------------------------------------
--	GridStatusVehicle

L["Driving"] = "Dirigindo"
L["In Vehicle"] = "Em veículo"

------------------------------------------------------------------------
--	GridStatusVoiceComm

L["Talking"] = "Falando"
L["Voice Chat"] = "Chat por voz"
