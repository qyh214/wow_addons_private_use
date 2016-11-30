local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization

local LOCALE = GetLocale()

if LOCALE == "deDE" then
	-- The EU English game client also
	-- uses the US English locale code.

-- ###########################################################################################################
-- ##	Deutsche (German) translations provided by pas06, flow0284, Markurion and Branduril on Curseforge.	##
-- ##	Thank you pas06, flow0284, Markurion and Branduril!													##
-- ###########################################################################################################

-- ####################
-- ## Slash Commands ##
-- ####################

--	L["/dcstats"] = ""
	L["DejaCharacterStats Slash commands (/dcstats):"] = "DejaCharacterStats Slashbefehle (/dcstats):"
	L["  /dcstats config: Open the DejaCharacterStats addon config menu."] = "  /dcstats config: Öffnet das DejaCharacterStats Konfigurationsfenster." --configuration
	L["  /dcstats reset:  Resets DejaCharacterStats frames to default positions."] = "  /dcstats reset: Setzt DejaCharacterStats zurück."
	L["Resetting config to defaults"] = "Einstellungen zurücksetzen." --configuration
	L["DejaCharacterStats is currently using "] = "DejaCharacterStats benutzt zurzeit "
	L[" kbytes of memory"] = " Kilobyte Arbeitsspeicher" --kilobytes
--	L["DejaCharacterStats is currently using "] = ""
	L[" kbytes of memory after garbage collection"] = " Kilobyte Arbeitsspeicher nach der Speicherbereinigung" --kilobytes
--	L["config"] = "" --configuration
--	L["dumpconfig"] = "" --configuration
--	L["With defaults"] = ""
--	L["Direct table"] = ""
--	L["reset"] = ""
--	L["perf"] = "" --performance
	L["Reset to Default"] = "Standardeinstellungen"

-- ################################
-- ## Global Options Left Column ##
-- ################################

	L["Equipped/Available"] = "Ausgerüstet/Verfügbar"
	L['Displays Equipped/Available item levels unless equal.'] = "Zeigt die durchschnittliche Gegenstandsstufe von angelegten und verfügbaren Gegenständen an, wenn diese nicht gleich sind."

	L["Decimals"] = "Nachkommastellen"
	L['Displays "Enhancements" category stats to two decimal places.'] = 'Zeigt die Werte in der Kategorie "Verstärkungen" mit 2 Nachkommastellen an.'

	L["Ilvl Decimals"] = "Nachkommastellen Ilvl"
	L['Displays average item level to two decimal places.'] = "Zeigt die durchschnittliche Gegenstandsstufe mit zwei Nachkommastellen an."

	L['Durability '] = "Haltbarkeit "
	L['Displays the average Durability percentage for equipped items in the stat frame.'] = "Zeigt die durchschnittliche Haltbarkeit im Hemdplatz und in der Liste unter Haltbarkeit an."

	L['Repair Total '] = "Ges. Reparaturkosten "
	L['Displays the Repair Total before discounts for equipped items in the stat frame.'] = "Zeigt die gesamten Reparaturkosten ohne Bonus für die ausgerüsteten Gegenstände in der Charakterinfo an."

-- ################################

	L["Durability Bars"] = "Haltbarkeitsleisten"
	L["Displays a durability bar next to each item." ] = "Zeigt neben jedem Gegenstand eine Haltbarkeitsleiste an."

	L["Average Durability"] = "Durchschnittliche Haltbarkeit"
	L["Displays average item durability on the character shirt slot and durability frames."] = "Zeigt die durchschnittliche Haltbarkeit im Hemdslot und Haltbarkeitsframe."

	L["Item Durability"] = "Gegenstandshaltbarkeit"
	L["Displays each equipped item's durability."] = "Zeigt die Haltbarkeit von jedem ausgerüsteten Gegenstand an."

	L["Item Repair Cost"] = "Gegenstandsreparaturkosten"
	L["Displays each equipped item's repair cost."] = "Zeigt die Reparaturkosten von jedem ausgerüsteten Gegenstand an."

-- ################################

	L["Expand"] = "Erweitern"
	L['Displays the Expand button for the character stats frame.'] = "Zeigt die Erweiterungsschaltfläche für die Charakterwerte an." --## Needs review.
	L['Show Character Stats'] = "Zeigt die Charakterwerte"
	L['Hide Character Stats'] = "Versteckt die Charakterwerte"

	L["Scrollbar"] = "Scrollleiste"
	L['Displays the DCS scrollbar.'] = "Zeigt den DCS Scrollbalken."

-- ################################
-- ## Character Options Right Column ##
-- ################################

	L["Show All Stats"] = "Alle Werte anzeigen"
	L['Checked displays all stats. Unchecked displays relevant stats. Use Shift-scroll to snap to the top or bottom.'] = "Wenn ausgewählt, werden alle Werte gezeigt. Ansonsten nur die relevanten. Halte die Umschalttaste und scrolle, um direkt an den Anfang oder ans Ende zu springen."

--	L["Select-A-Stat™"]  = "Select-A-Stat™ Checkbox Name" -- Try to use something snappy and silly like a Fallout or 1950's appliance feature.
	L['Select which stats to display. Use Shift-scroll to snap to the top or bottom.'] = "Wähle die anzuzeigenden Werte aus. Halte die Umschalttaste und scrolle, um direkt an den Anfang oder ans Ende zu springen."

-- ################################
-- ## Stats ##
-- ################################

	L["Durability"] = "Haltbarkeit" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Durability %s"] = "Haltbarkeit %s" -- ## --> %s MUST be included <-- ## 
	L["Average equipped item durability percentage."] = "Prozentuale Haltbarkeit der angelegten Gegenstände."

	L["Repair Total"] = "Ges. Reparaturkosten" -- Be sure to include the colon ":" or it will conflict wih the options checkbox.
	L["Repair Total %s"] = "Gesamte Reparaturkosten %s" -- ## --> %s MUST be included <-- ## 
	L["Total equipped item repair cost before discounts."] = "Reparaturkosten für angelegte Gegenstände ohne Abzug von Rabatt." -- ## Needs review

-- ## Attributes ##

	L["Health"] = "Gesundheit"
	L["Power"] = "Energiequelle"
	L["Druid Mana"] = "Druide Mana"
	L["Armor"] = "Rüstung"
	L["Strength"] = "Stärke"
	L["Agility"] = "Beweglichkeit"
	L["Intellect"] = "Intelligenz"
	L["Stamina"] = "Ausdauer"
	L["Damage"] = "Schaden"
	L["Attack Power"] = "Angriffskraft"
	L["Attack Speed"] = "Angriffstempo"
	L["Spell Power"] = "Zaubermacht"
	L["Mana Regen"] = "Manaregeneration"
	L["Energy Regen"] = "Energieregeneration"
	L["Rune Regen"] = "Runentempo"
	L["Focus Regen"] = "Fokusregeneration"
	L["Movement Speed"] = "Lauftempo"
	L["Bewegungsgeschwindigkeit"] = "Lauftempo"
	L["Durability"] = "Haltbarkeit"
	L["Repair Total"] = "Ges. Reparaturkosten"

-- ## Enhancements ##

	L["Critical Strike"] = "Kritische Treffer"
	L["Haste"] = "Tempo"
	L["Versatility"] = "Vielseitigkeit"
	L["Mastery"] = "Meisterschaft"
	L["Leech"] = "Lebensraub"
	L["Avoidance"] = "Vermeidung"
	L["Dodge"] = "Ausweichen"
	L["Parry"] = "Parieren"
	L["Block"] = "Blocken"
	
-- ## Patch 7.1.0 r2 additions ##
	L["Global Cooldown"] = "Globale Abklingzeit"
	L["Global Cooldown %.2fs"] = "Globale Abklingzeit %.2fs"
--	L["General global cooldown for casters. Individual spells, set bonuses, talents, etc. not considered. Not suitable for melee. Improvements coming Soon(TM)."] = ""
	L["Unlock DCS"] = "DCS freischalten"
	L["Lock DCS"] = "DCS sperren"
	L["Item Level 1 Decimal Place"] = "Gegenstandsstufe mit 1 Nachkommastelle"
	L["Displays average item level to one decimal place."] = "Zeigt die durchschnittliche Gegenstandsstufe mit einer Nachkommastelle an."
	L["Item Level 2 Decimal Places"] = "Gegenstandsstufe mit 2 Nachkommastellen"
	L["Displays average item level to two decimal places."] = "Zeigt die durchschnittliche Gegenstandsstufe mit zwei Nachkommastellen an."
	L["Main Hand"] = "Waffenhand"
	L["/Off Hand"] = "/Schildhand"
	L[" weapon auto attack (white) DPS."] = ' Schaden pro Sekunde der automatischen (weißen) Waffenangriffe.'
	L["Weapon DPS"] = "Waffen-SPS"
	L["Weapon DPS %s"] = "Waffen-SPS %s"
--	L["Class Crest Background"] = ""
--	L["Displays the class crest background."] = ""

return end
