local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local LOCALE = GetLocale()

if LOCALE == "ptBR" then
	-- The EU English game client also
	-- uses the US English locale code.

-- ###############################################################################################
-- ##	Português (Portuguese) translations provided by Othra on Curseforge. Thank you Othra!	##
-- ###############################################################################################

-- #######################
-- ##	Slash Commands	##
-- #######################

--	L["/dcstats"] = ""
	L["DejaCharacterStats Slash commands (/dcstats):"] = "DejaCharacterStats Comandos de consola (/dcstats):"
	L["  /dcstats config: Open the DejaCharacterStats addon config menu."] = "  /dcstats config: Abrir o menu de configuração do DejaCharacterStats." --configuration
	L["  /dcstats reset:  Resets DejaCharacterStats frames to default positions."] = "  /dcstats reset: Reposiciona a janela DejaCharacterStats para a posição original."
	L["Resetting config to defaults"] = "Reiniciar a configuração para default." --configuration
	L["DejaCharacterStats is currently using "] = "DejaCharacterStats está de momento a utilizar "
	L[" kbytes of memory"] = " kbytes de memória." --kilobytes
--	L["DejaCharacterStats is currently using "] = ""
	L[" kbytes of memory after garbage collection"] = " kbytes de memória após recolecção de lixo." --kilobytes
--	L["config"] = "" --configuration
--	L["dumpconfig"] = "" --configuration
	L["With defaults"] = "Com valores default"
	L["Direct table"] = "Conteúdo Directo"
--	L["reset"] = ""
--	L["perf"] = "" --performance
	L["Reset to Default"] = "Reiniciar para Predefinido"

-- ################################
-- ## Global Options Left Column ##
-- ################################

	L["Equipped/Available"] = "Equipado/Disponível"
	L['Displays Equipped/Available item levels unless equal.'] = "Apresentar Nível do Item Equipado/Apresentado excepto igual."

	L["Decimals"] = "Decimais"
	L['Displays "Enhancements" category stats to two decimal places.'] = 'Apresentar categoria "Aperfeiçoamentos" com atributos em duas decimais.'

	L["Ilvl Decimals"] = "Decimais de Nível de Item"
	L['Displays average item level to two decimal places.'] = "Apresentar Nível de Item médio em duas decimais."

	L['Durability '] = "Durabilidade "
	L['Displays the average Durability percentage for equipped items in the stat frame.'] = "Apresentar percentagem de Durabilidade média para items equipados na janela de atributos."

	L['Repair Total '] = "Total de Reparos "
	L['Displays the Repair Total before discounts for equipped items in the stat frame.'] = "Apresentar o Total de Reparos sem descontos para items equipados na janela de atributos."

-- ################################

	L["Durability Bars"] = "Barras de Durabilidade"
	L["Displays a durability bar next to each item." ] = "Apresentar uma barra de durabilidade próximo de cada item."

	L["Average Durability"] = "Durabilidade Média"
	L["Displays average item durability on the character shirt slot and durability frames."] = "Apresentar durabilidade média de items no slot da camisa e na janela de durabilidade."

	L["Item Durability"] = "Durabilidade de Item"
	L["Displays each equipped item's durability."] = "Apresentar durabilidade de cada item equipado."

	L["Item Repair Cost"] = "Custo de Reparação de Item"
	L["Displays each equipped item's repair cost."] = "Apresentar custo de reparação para cada item equipado."

-- ################################

	L["Expand"] = "Expandir"
	L['Displays the Expand button for the character stats frame.'] = "Apresentar o botão Expandir para a janela de atributos do personagem."
	L['Show Character Stats'] = "Mostrar Atributos de Personagem"
	L['Hide Character Stats'] = "Esconder Atributos de Personagem"

	L["Scrollbar"] = "Barra de Rolagem"
	L['Displays the DCS scrollbar.'] = "Apresentar a barra de rolagem para o DCS."

-- ################################
-- ## Character Options Right Column ##
-- ################################

	L["Show All Stats"] = "Mostrar todos os atributos."
	L['Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom.'] = "Verificado significa todos os atributos. Não Verificado apresenta atributos relevantes. Use Shift-rolagem para saltar para o topo ou fundo."

	L["Select-A-Stat™"]  = "Escolher-Um-Atributo™" -- Try to use something snappy and silly like a Fallout or 1950's appliance feature.
	L['Select which stats to display. Use Shift-scroll to snap to the top or bottom.'] = "Escolha quais os atributos a mostrar. Use Shift-rolagem para saltar para o topo ou fundo."

-- ################################
-- ## Stats ##
-- ################################

	L["Durability"] = "Durabilidade" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Durability %s"] = "Durabilidade %s" -- ## --> %s MUST be included <-- ## 
	L["Average equipped item durability percentage."] = "Percentagem média de durabilidade de item equipado."

	L["Repair Total"] = "Total de Reparos" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Repair Total %s"] = "Total de Reparos %s" -- ## --> %s MUST be included <-- ## 
	L["Total equipped item repair cost before discounts."] = "Custo de reparo sem descontos de facção."

-- ## Attributes ##

	L["Health"] = "Vida"
	L["Power"] = "Poder"
	L["Druid Mana"] = "Mana de Druida"
	L["Armor"] = "Armadura"
	L["Strength"] = "Força"
	L["Agility"] = "Agilidade"
	L["Intellect"] = "Intelecto"
	L["Stamina"] = "Vigor"
	L["Damage"] = "Dano"
	L["Attack Power"] = "Poder de Ataque"
	L["Attack Speed"] = "Velocidade de Ataque"
	L["Spell Power"] = "Poder Mágico"
	L["Mana Regen"] = "Regen. de Mana"
	L["Energy Regen"] = "Regen. de Energia"
	L["Rune Regen"] = "Velocidade Rúnica"
	L["Focus Regen"] = "Regen. de Foco"
	L["Movement Speed"] = "Velocidade de Movimento"
	L["Durability"] = "Durabilidade"
	L["Repair Total"] = "Reparação Total"

-- ## Enhancements ##

	L["Critical Strike"] = "Acerto Crítico"
	L["Haste"] = "Aceleração"
	L["Versatility"] = "Versatilidade"
	L["Mastery"] = "Maestría"
	L["Leech"] = "Sorver"
	L["Avoidance"] = "Evasiva"
	L["Dodge"] = "Esquiva"
	L["Parry"] = "Aparo"
	L["Block"] = "Bloqueio"

return end
