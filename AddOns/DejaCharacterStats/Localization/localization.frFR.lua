local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local LOCALE = GetLocale()

if LOCALE == "frFR" then
	-- The EU English game client also
	-- uses the US English locale code.

-- #######################################################################################
-- ##	Français (French) translations provided by Darkcraft92 and Ymvej on Curseforge.	##
-- ##	Thank you Darkcraft92 and Ymvej!												##
-- #######################################################################################

-- #######################
-- ##	Slash Commands 	##
-- #######################

--	L["/dcstats"] = ""
--	L["DejaCharacterStats Slash commands (/dcstats):"] = ""
--	L["  /dcstats config: Open the DejaCharacterStats addon config menu."] = "" --configuration
--	L["  /dcstats reset:  Resets DejaCharacterStats frames to default positions."] = ""
--	L["Resetting config to defaults"] = "" --configuration
--	L["DejaCharacterStats is currently using "] = ""
--	L[" kbytes of memory"] = "" --kilobytes
--	L["DejaCharacterStats is currently using "] = ""
--	L[" kbytes of memory after garbage collection"] = "" --kilobytes
--	L["config"] = "" --configuration
--	L["dumpconfig"] = "" --configuration
	L["With defaults"] = "Avec valeurs par défaut"
--	L["Direct table"] = ""
--	L["reset"] = ""
--	L["perf"] = "" --performance
	L["Reset to Default"] = "Réinitialiser par défaut"

-- ################################
-- ## Global Options Left Column ##
-- ################################

	L["Equipped/Available"] = "Équipé/Disponible"
	L['Displays Equipped/Available item levels unless equal.'] = "Afficher niveau d'objet Equipé/Disponible, sauf s'ils sont égaux."

	L["Decimals"] = "Décimales"
	L['Displays "Enhancements" category stats to two decimal places.'] = 'Afficher les statistiques de la catégorie "Améliorations" avec deux décimales.'

	L["Ilvl Decimals"] = "Decimales pour le niveau d'objet"
	L['Displays average item level to two decimal places.'] = "Afficher le niveau d'objet moyen avec deux décimales."

	L['Durability '] = "Durabilité "
	L['Displays the average Durability percentage for equipped items in the stat frame.'] = "Afficher le pourcentage de durabilité moyen pour les objets équipés dans le tableau de statistique."

	L['Repair Total '] = "Réparation Totale"
	L['Displays the Repair Total before discounts for equipped items in the stat frame.'] = "Afficher le coût total de réparation avant les réductions pour les objets équipés dans le tableau de statistiques."

-- ################################

--	L["Durability Bars"] = "Durability Bars Checkbox Name"
--	L["Displays a durability bar next to each item." ] = "Durability Bars Checkbox Mouseover Description"

--	L["Average Durability"] = "Average Dura Checkbox Name"
--	L["Displays average item durability on the character shirt slot and durability frames."] = "Average Durability Checkbox Mouseover Description"

--	L["Item Durability"] = "Item Durability Checkbox Name"
--	L["Displays each equipped item's durability."] = "Item Durability Checkbox Mouseover Description"

--	L["Item Repair Cost"] = "Item Repair Cost Checkbox Name"
--	L["Displays each equipped item's repair cost."] = "Item Repair Cost Checkbox Mouseover Description"

-- ################################

--	L["Expand"] = "Expand Checkbox Name"
--	L['Displays the Expand button for the character stats frame.'] = "Expand Checkbox Mouseover Description"
--	L['Show Character Stats'] = "Expand paperdoll frame button mouseover text when stats frame is hidden"
--	L['Hide Character Stats'] = "Expand paperdoll frame button mouseover text when stats frame is shown"

--	L["Scrollbar"] = "Scrollbar Checkbox Name"
--	L['Displays the DCS scrollbar.'] = "Scrollbar Checkbox Mouseover Description"

-- #######################################
-- ##	Character Options Right Column	##
-- #######################################

--	L["Show All Stats"] = "All Stats Checkbox Name"
--	L['Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom.'] = "All Stats Checkbox Mouseover Description"

--	L["Select-A-Stat™"]  = "Select-A-Stat™ Checkbox Name" -- Try to use something snappy and silly like a Fallout or 1950's appliance feature.
--	L['Select which stats to display. Use Shift-scroll to snap to the top or bottom.'] = "Select-A-Stat™ Checkbox Mouseover Description"

-- ###############################
-- ##			Stats			##
-- ###############################

	L["Durability"] = "Durabilité" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Durability %s"] = "Durabilité %s" -- ## --> %s MUST be included <-- ## 
--	L["Average equipped item durability percentage."] = "Durability stat mouseover tooltip yellow description."

--	L["Repair Total"] = "Repair Tot Stat Name" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
--	L["Repair Total %s"] = "Repair Total stat tooltip white mouseover title. You must use %%s to show %s. " -- ## --> %s MUST be included <-- ## 
--	L["Total equipped item repair cost before discounts."] = "Repair Total stat mouseover tooltip yellow description."

-- ## Attributes ##

	L["Health"] = "Vie"
	L["Power"] = "Pouvoir"
	L["Druid Mana"] = "Druide d'mana"
	L["Armor"] = "Armure"
	L["Strength"] = "Force"
	L["Agility"] = "Agilité"
	L["Intellect"] = "Intelligence"
	L["Stamina"] = "Endurance"
	L["Damage"] = "Dégâts"
	L["Attack Power"] = "Puissance d'attaque"
	L["Attack Speed"] = "Vitesse d'attaque"
	L["Spell Power"] = "Puissance des sorts"
	L["Mana Regen"] = "Régén. mana"
	L["Energy Regen"] = "Régén. énergie"
	L["Rune Regen"] = "Vitesse des runes"
	L["Focus Regen"] = "Régén. focalisation"
	L["Movement Speed"] = "Vitesse (déplacement)"
	L["Durability"] = "Durabilité"
	L["Repair Total"] = "Réparation Totale"

-- ## Enhancements ##

	L["Critical Strike"] = "Coup critique"
	L["Haste"] = "Hâte"
	L["Versatility"] = "Polyvalence"
	L["Mastery"] = "Maîtrise"
	L["Leech"] = "Ponction"
	L["Avoidance"] = "Évitement"
	L["Dodge"] = "Esquive"
	L["Parry"] = "Parade"
	L["Block"] = "Blocage"

return end
