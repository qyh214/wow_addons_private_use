local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI", "ptBR")
if not L then return end

-- Translation by: ubios

L["ENH_LOGIN_MSG"] = "Você está a usar |cff1784d1ElvUI Enhanced Again|r |cffff8000|r versão %s%s|r."
L["ENH_LOGIN_MSG_WRATH"] = "You are using |cff1784d1ElvUI Enhanced Again|r |cffff8000(Wrath Classic)|r version %s%s|r."
L["Your version of ElvUI is to old (required v11.52 or higher). Please, download the latest version from tukui.org."] = "A sua versão do ElvUI é muita antiga (requerida v6.51 ou superior). Por favor, descarregue a versão mais recente em tukui.org."

-- Equipment
L["Equipment"] = "Equipamento"
L["EQUIPMENT_DESC"] = "Ajuste os parâmetros para a mudança de equipamento quando muda de especialização ou entra num campo de batalha."
L["No Change"] = "Sem mudança"

L["Specialization"] = "Especialização"
L["Enable/Disable the specialization switch."] = "Activar/desactivar a mudança com a especialização."

L["Primary Talent"] = "Talento primário"
L["Choose the equipment set to use for your primary specialization."] = "Escolha o conjunto de equipamento para usar com a especialização primária."

L["Secondary Talent"] = "Talento secundário"
L["Choose the equipment set to use for your secondary specialization."] = "Escolha o conjunto de equipamento para usar com a especialização secundária."

L["Battleground"] = "Campo de batalha"
L['Enable/Disable the battleground switch.'] = "Activar/desactivar a mudança em Campo de batalha."

L["Equipment Set"] = "Conjunto de Equipamento"
L["Choose the equipment set to use when you enter a battleground or arena."] = "Escolha o conjunto de equipamento para usar quando entra num Campo de batalha."

L["You have equipped equipment set: "] = "Você tem equipado o conjunto: "

L["DURABILITY_DESC"] = "Ajuste as opções para a informação de durabilidade no ecrã de informação do personagem."
L['Enable/Disable the display of durability information on the character screen.'] = "Activar/desactivar a informação de durabilidade no ecrã de informação do personagem."
L["Damaged Only"] = "Só Danificados"
L["Only show durabitlity information for items that are damaged."] = "Só mostrar informação de durabilidade para itens danificados."

L["ITEMLEVEL_DESC"] = "Adjust the settings for the item level information on the character screen."
L["Enable/Disable the display of item levels on the character screen."] = true

L["Miscellaneous"] = true
L['Equipment Set Overlay'] = true
L['Show the associated equipment sets for the items in your bags (or bank).'] = true

-- Movers
L["Mover Transparency"] = true
L["Changes the transparency of all the movers."] = true

-- Automatic Role Assignment
L['Automatic Role Assignment'] = true
L['Enables the automatic role assignment based on specialization for party / raid members (only work when you are group leader or group assist).'] = true

-- Auto Hide Role Icons in combat
L['Hide Role Icon in combat'] = true
L['All role icons (Damage/Healer/Tank) on the unit frames are hidden when you go into combat.'] = true

-- GPS module
L['GPS'] = "GPS"
L['Show the direction and distance to the selected party or raid member.'] = "Mostrar a direcção e distância para o membro do grupo ou raide seleccionado."

-- Attack Icon
L['Attack Icon'] = true
L['Show attack icon for units that are not tapped by you or your group, but still give kill credit when attacked.'] = true

-- Class Icon
L['Show class icon for units.'] = true

-- Minimap Location
L['Above Minimap'] = true
L['Location Digits'] = true
L['Number of digits for map location.'] = true

-- Minimap Combat Hide
L["Hide minimap while in combat."] = true
L["FadeIn Delay"] = true
L["The time to wait before fading the minimap back in after combat hide. (0 = Disabled)"] = true

-- Minimap Buttons
L['Skin Buttons'] = "Customizar Botões"
L['Skins the minimap buttons in Elv UI style.'] = "Customiza os botões do minimapa no estilo do Elv UI."
L['Skin Style'] = "Estilo de Customização"
L['Change settings for how the minimap buttons are skinned.'] = "Mudar definições de como os botões do minimapa são customizados."
L['The size of the minimap buttons.'] = "O tamanho dos botões do minimapa."

L['No Anchor Bar'] = "Sem Ancora de Barra"
L['Horizontal Anchor Bar'] = "Ancora de Barra Horizontal"
L['Vertical Anchor Bar'] = "Ancora de Barra Vertical"

L['Layout Direction'] = true
L['Normal is right to left or top to bottom, or select reversed to switch directions.'] = true
L['Normal'] = true
L['Reversed'] = true

-- PvP Autorelease
L['PvP Autorelease'] = "Auto-libertar em JxJ"
L['Automatically release body when killed inside a battleground.'] = "Automaticamente libertar o corpo quando morto num campo de batalha."

-- Track Reputation
L['Track Reputation'] = "Controlar Reputação"
L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'] = "Mudar automaticamente a facção controlada para a facção na qual acabou de ganhar pontos de reputação." 

-- Select Quest Reward
L['Select Quest Reward'] = true
L['Automatically select the quest reward with the highest vendor sell value.'] = true

-- Item Level Datatext
L['Item Level'] = true

-- Range Datatext
L['Target Range'] = true
L['Distance'] = true

-- Extra Datatexts
L['Actionbar1DataPanel'] = 'Actionbar 1'
L['Actionbar3DataPanel'] = 'Actionbar 3'
L['Actionbar5DataPanel'] = 'Actionbar 5'

-- Farmer
L["Sunsong Ranch"] = "Fazenda Sol Cantante"
L["The Halfhill Market"] = "Mercado da Meia Colina"
L["Tilled Soil"] = "Terra Arada"
L['Right-click to drop the item.'] = true

L['Farmer'] = true
L["FARMER_DESC"] = "Adjust the settings for the tools that help you farm more efficiently on Sunsong Ranch."
L['Farmer Bars'] = true
L['Farmer Portal Bar'] = true
L['Farmer Seed Bar'] = true
L['Farmer Tools Bar'] = true
L['Enable/Disable the farmer bars.'] = true
L['Only active buttons'] = true
L['Only show the buttons for the seeds, portals, tools you have in your bags.'] = true
L['Drop Tools'] = true
L['Automatically drop tools from your bags when leaving the farming area.'] = true
L['Seed Bar Direction'] = true
L['The direction of the seed bar buttons (Horizontal or Vertical).'] = true

-- Nameplates
L["Threat Text"] = true
L["Display threat level as text on targeted, boss or mouseover nameplate."] = true
L["Target Count"] = true
L["Display the number of party / raid members targetting the nameplate unit."] = true

-- HealGlow
L['Heal Glow'] = true
L['Direct AoE heals will let the unit frames of the affected party / raid members glow for the defined time period.'] = true
L["Glow Duration"] = true
L["The amount of time the unit frames of party / raid members will glow when affected by a direct AoE heal."] = true
L["Glow Color"] = true

-- Raid Marker Bar
L['Raid Marker Bar'] = true
L['Display a quick action bar for raid targets and world markers.'] = true
L['Modifier Key'] = true
L['Set the modifier key for placing world markers.'] = true
L['Shift Key'] = true
L['Ctrl Key'] = true
L['Alt Key'] = true
L["Raid Markers"] = true
L["Click to clear the mark."] = true
L["Click to mark the target."] = true
L["%sClick to remove all worldmarkers."] = true
L["%sClick to place a worldmarker."] = true

-- WatchFrame
L['WatchFrame'] = true
L['WATCHFRAME_DESC'] = "Adjust the settings for the visibility of the watchframe (questlog) to your personal preference."
L['Hidden'] = true
L['Collapsed'] = true
L['Settings'] = true
L['City (Resting)'] = true
L['PvP'] = true
L['Arena'] = true
L['Party'] = true
L['Raid'] = true

-- Tooltips
L['Progression Info'] = true
L['Display the players raid progression in the tooltip, this may not immediately update when mousing over a unit.'] = true
