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
	GridLocale-deDE.lua
	German localization
	Contributors: Alakabaster, derwanderer, Firuzz, kaybe, kunda, Leialyn, ole510
----------------------------------------------------------------------]]

if GetLocale() ~= "deDE" then return end

local _, Grid = ...
local L = { }
Grid.L = L

------------------------------------------------------------------------
--	GridCore

L["Debugging"] = "Debuggen"
L["Debugging messages help developers or testers see what is happening inside Grid in real time. Regular users should leave debugging turned off except when troubleshooting a problem for a bug report."] = "Debugg Nachrichten helfen Entwicklern und Testern zu sehen was aktuell inerhalb von Grid passiert. Normale Bentzer sollten debugging Nachrichten ausgeschaltet lassen, entseiden sie wollen eine Bug oder ein Problem dokumentieren." -- Needs review
L["Enable debugging messages for the %s module."] = "Aktiviere Debugging Nachrichten für das %s Modul" -- Needs review
L["General"] = "Allgemein" -- Needs review
L["Module debugging menu."] = "Debug-Menü."
L["Open Grid's options in their own window, instead of the Interface Options window, when typing /grid or right-clicking on the minimap icon, DataBroker icon, or layout tab."] = "Die Optionen des Grid in einem alleinstehenden Fenster anzeigen, anstatt des standarden Intrerfaz-Optionen, nach dem Schreiben '/grid' oder dem Klicken auf dem Minimapsymbol, DataBroker-Symbol oder Grid-Reiter."
L["Output Frame"] = "Ausgabe  Fenster" -- Needs review
L["Right-Click for more options."] = "Rechtsklick für Optionen."
L["Show debugging messages in this frame."] = "Zeige debugg Nachrichten in diesem Fenster" -- Needs review
L["Show minimap icon"] = "Minikarten Button anzeigen"
L["Show the Grid icon on the minimap. Note that some DataBroker display addons may hide the icon regardless of this setting."] = "Das Grid-Icon an der Minimap anzeigen. Beachte: Einige DataBroker-Addons können das Icon dennoch verstecken, unabhängig von dieser Einstellung."
L["Standalone options"] = "Alleinstehenden Optionen"
L["Toggle debugging for %s."] = "Aktiviere das Debuggen für %s."

------------------------------------------------------------------------
--	GridFrame

L["Adjust the font outline."] = "Den Schriftumriss anpassen."
L["Adjust the font settings"] = "Die Schriftart anpassen"
L["Adjust the font size."] = "Die Schriftgröße anpassen."
L["Adjust the height of each unit's frame."] = "Die Höhe von jedem Einheitenfenster anpassen."
L["Adjust the size of the border indicators."] = "Die Randbreite der Indikatoren anpassen."
L["Adjust the size of the center icon."] = "Die Größe des Symbols im Zentrum anpassen."
L["Adjust the size of the center icon's border."] = "Die Randbreite des Symbols im Zentrum anpassen."
L["Adjust the size of the corner indicators."] = "Die Größe der Eckenindikatoren anpassen."
L["Adjust the texture of each unit's frame."] = "Die Textur von jedem Einheitenfenster anpassen."
L["Adjust the width of each unit's frame."] = "Die Breite von jedem Einheitenfenster anpassen."
L["Always"] = "Immer"
L["Bar Options"] = "Leistenoptionen"
L["Border"] = "Rand"
L["Border Size"] = "Randbreite"
L["Bottom Left Corner"] = "Untere linke Ecke"
L["Bottom Right Corner"] = "Untere rechte Ecke"
L["Center Icon"] = "Symbol im Zentrum"
L["Center Text"] = "Text im Zentrum 1"
L["Center Text 2"] = "Text im Zentrum 2"
L["Center Text Length"] = "Länge des mittleren Textes"
L["Color the healing bar using the active status color instead of the health bar color."] = "Färbt die Heilleiste mit der Farbe des aktiven Status, anstelle der Heilleistenfarbe"
L["Corner Size"] = "Eckengröße"
L["Darken the text color to match the inverted bar."] = "Text abdunkeln, um die invertierte Leiste entsprechen."
L["Enable Mouseover Highlight"] = "Rahmen Hervorhebung"
L["Enable right-click menu"] = "Rechtsklick-Menü einschalten"
L["Enable %s"] = "Aktiviert %s"
L["Enable %s indicator"] = "Indikator: %s"
L["Font"] = "Schriftart"
L["Font Outline"] = "Schriftumriss"
L["Font Shadow"] = "Schriftschatten"
L["Font Size"] = "Schriftgröße"
L["Frame"] = "Rahmen"
L["Frame Alpha"] = "Rahmentransparenz"
L["Frame Height"] = "Rahmenhöhe"
L["Frame Texture"] = "Rahmentextur"
L["Frame Width"] = "Rahmenbreite"
L["Healing Bar"] = "Heilleiste"
L["Healing Bar Opacity"] = "Heilleistendeckkraft"
L["Healing Bar Uses Status Color"] = "Heilleiste benutzt Statusfarbe"
L["Health Bar"] = "Gesundheitsleiste"
L["Health Bar Color"] = "Gesundheitsleistenfarbe"
L["Horizontal"] = "Horizontal"
L["Icon Border Size"] = "Symbolrandbreite"
L["Icon Cooldown Frame"] = "Symbol Cooldown-Rahmen"
L["Icon Options"] = "Symboloptionen"
L["Icon Size"] = "Symbolgröße"
L["Icon Stack Text"] = "Symbol Stack-Text"
L["Indicators"] = "Indikatoren"
L["Invert Bar Color"] = "Invertiere die Leistenfarbe"
L["Invert Text Color"] = "Invertiere Textfarbe"
L["Make the healing bar use the status color instead of the health bar color."] = "Die Heilungsleiste verwendet die Statusfarbe statt der Lebensbalkenfarbe"
L["Never"] = "Nie"
L["None"] = "Kein Umriss"
L["Number of characters to show on Center Text indicator."] = "Anzahl der Buchstaben der Indikatoren 'Text im Zentrum 1/2'."
L["OOC"] = "Außerhalb des Kampfes"
L["Options for assigning statuses to indicators."] = "Optionen für die Status-Indikatorzuordnung."
L["Options for GridFrame."] = "Optionen für den Grid-Rahmen."
L["Options for %s indicator."] = "Optionen für den Indikator: %s."
L["Options related to bar indicators."] = "Optionen für Leistenindikatoren."
L["Options related to icon indicators."] = "Optionen für Symbolindikatoren."
L["Options related to text indicators."] = "Optionen für Textindikatoren."
L["Orientation of Frame"] = "Ausrichtung der Statusleiste"
L["Orientation of Text"] = "Ausrichtung des Texts"
L["Set frame orientation."] = "Ausrichtung der Statusleiste festlegen."
L["Set frame text orientation."] = "Textausrichtung festlegen."
L["Sets the opacity of the healing bar."] = "Verändert die Deckkraft der Heilleiste."
L["Show the standard unit menu when right-clicking on a frame."] = "Zeige das standartdmäßige Einheitenmenü bei Rechtsklick auf einen Rahmen."
L["Show Tooltip"] = "Zeige Tooltip"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "Einheiten-Tooltip anzeigen. Wähle 'Außerhalb des Kampfes', 'Immer' oder 'Nie'."
L["Statuses"] = "Status"
L["Swap foreground/background colors on bars."] = "Tausche die Vordergrund-/Hintergrundfarbe der Leisten."
L["Text Options"] = "Textoptionen"
L["Thick"] = "Dick"
L["Thin"] = "Dünn"
L["Throttle Updates"] = "Aktualisierung drosseln"
L["Throttle updates on group changes. This option may cause delays in updating frames, so you should only enable it if you're experiencing temporary freezes or lockups when people join or leave your group."] = [=[Drosselt die Aktualisiersrate bei Gruppenänderungen auf 0,1 Sekunden (Standard: sofort).
ACHTUNG:
Diese Option kann Verzögerungen bei der Rahmenaktualisierung verursachen. Deshalb sollte man diese Option nur aktivieren, wenn man temporäre Lags oder 'Hänger' hat, wenn Spieler der Gruppe beitreten oder sie verlassen.]=]
L["Toggle center icon's cooldown frame."] = "Cooldown-Rahmen für Symbol im Zentrum ein-/ausblenden."
L["Toggle center icon's stack count text."] = "Stack-Text für Symbol im Zentrum ein-/ausblenden."
L["Toggle mouseover highlight."] = "Rahmen Hervorhebung (Mouseover Highlight) ein-/ausschalten."
L["Toggle status display."] = "Aktiviert die Anzeige dieses Status."
L["Toggle the font drop shadow effect."] = "Schriftschatten ein-/ausschalten."
L["Toggle the %s indicator."] = "Aktiviert den Indikator: %s."
L["Top Left Corner"] = "Obere linke Ecke"
L["Top Right Corner"] = "Obere rechte Ecke"
L["Vertical"] = "Vertikal"

------------------------------------------------------------------------
--	GridLayout

L["10 Player Raid Layout"] = "10 Spieler Schlachtzug Layout"
L["25 Player Raid Layout"] = "25 Spieler Schlachtzug Layout"
L["40 Player Raid Layout"] = "40 Spieler Raid Layout" -- Needs review
L["Adjust background color and alpha."] = "Anpassen der Hintergrundfarbe und Transparenz."
L["Adjust border color and alpha."] = "Anpassen der Rahmenfarbe und Transparenz."
L["Adjust frame padding."] = "Zwischenabstand anpassen."
L["Adjust frame spacing."] = "Abstand anpassen."
L["Adjust Grid scale."] = "Skalierung anpassen."
L["Adjust the extra spacing inside the layout frame, around the unit frames."] = "Der Abstand innerhalb des Layoutfensters, rund um den Einheitfenstern, anpassen."
L["Adjust the spacing between individual unit frames."] = "Der Abstand zwischen den individuellen Einheitfenstern anpassen."
L["Advanced"] = "Erweitert"
L["Advanced options."] = "Erweiterte Einstellungen."
L["Allows mouse click through the Grid Frame."] = "Erlaubt Mausklicks durch den Grid-Rahmen."
L["Alt-Click to permanantly hide this tab."] = "Alt-Klick um diesen Reiter immer zu verstecken."
L["Arena Layout"] = "Arena Layout"
L["Background color"] = "Hintergrund"
L["Background Texture"] = "Hintergrund Textur" -- Needs review
L["Battleground Layout"] = "Schlachtfeld Layout"
L["Beast"] = "Wildtier"
L["Border color"] = "Rand"
L["Border Inset"] = "Einsätze des Rands"
L["Border Size"] = "Größe des Rands"
L["Border Texture"] = "Randtextur"
L["Bottom"] = "Unten"
L["Bottom Left"] = "Untenlinks"
L["Bottom Right"] = "Untenrechts"
L["By Creature Type"] = "Nach Kreaturtyp"
L["By Owner Class"] = "Nach Besitzerklasse"
L["Center"] = "Zentriert"
L["Choose the layout border texture."] = "Layout Randtextur auswählen."
L["Clamped to screen"] = "Im Bildschirm lassen"
L["Class colors"] = "Klassenfarben"
L["Click through the Grid Frame"] = "Durch Grid-Rahmen klicken"
L["Color for %s."] = "Farbe für %s."
L["Color of pet unit creature types."] = "Farbe für die verschiedenen Kreaturtypen."
L["Color of player unit classes."] = "Farbe für Spielerklassen."
L["Color of unknown units or pets."] = "Farbe für unbekannte Einheiten oder Begleiter."
L["Color options for class and pets."] = "Legt fest, wie Klassen und Begleiter eingefärbt werden."
L["Colors"] = "Farben"
L["Creature type colors"] = "Kreaturtypfarben"
L["Demon"] = "Dämon"
L["Dragonkin"] = "Drachkin"
L["Drag this tab to move Grid."] = "Reiter klicken und bewegen, um Grid zu verschieben."
L["Elemental"] = "Elementar"
L["Fallback colors"] = "Ersatzfarben"
L["Flexible Raid Layout"] = "Flexible Schlachtzug"
L["Frame lock"] = "Grid sperren"
L["Frame Spacing"] = "Zwischenabstand"
L["Group Anchor"] = "Ankerpunkt der Gruppe"
L["Horizontal groups"] = "Horizontal gruppieren"
L["Humanoid"] = "Humanoid"
L["Layout"] = "Layout"
L["Layout Anchor"] = "Ankerpunkt des Layouts"
L["Layout Background"] = "Hintergrund des Layouts"
L["Layout Padding"] = "Layoutsabstand"
L["Layouts"] = "Layouts" -- Needs review
L["Left"] = "Links"
L["Lock Grid to hide this tab."] = "'Grid sperren' um diesen Reiter zu verstecken."
L["Locks/unlocks the grid for movement."] = "Sperrt Grid oder entsperrt Grid, um den Rahmen zu verschieben."
L["Not specified"] = "Nicht spezifiziert"
L["Options for GridLayout."] = "Optionen für das Layout von Grid."
L["Padding"] = "Zwischenabstand"
L["Party Layout"] = "Gruppen Layout"
L["Pet color"] = "Begleiterfarbe"
L["Pet coloring"] = "Begleiterfärbung"
L["Reset Position"] = "Position zurücksetzen"
L["Resets the layout frame's position and anchor."] = "Setzt den Ankerpunkt und die Position des Layoutrahmens zurück."
L["Right"] = "Rechts"
L["Scale"] = "Skalierung"
L["Select which layout to use when in a 10 player raid."] = "Wähle welches Schlachtzug Layout für 10 Spieler benutzt werden soll."
L["Select which layout to use when in a 25 player raid."] = "Wähle welches Schlachtzug Layout für 25 Spieler benutzt werden soll."
L["Select which layout to use when in a 40 player raid."] = "Wähle das Layout für einen 40 Spieler Raid aus" -- Needs review
L["Select which layout to use when in a battleground."] = "Wähle welches Schlachtfeld Layout benutzt werden soll."
L["Select which layout to use when in a flexible raid."] = "Wähle welches Layout benutzt wird, wenn Ihr in einem flexiblen Schlachtzug seid."
L["Select which layout to use when in an arena."] = "Wähle welches Arena Layout benutzt werden soll."
L["Select which layout to use when in a party."] = "Wähle welches Gruppen Layout benutzt werden soll."
L["Select which layout to use when not in a party."] = "Wähle welches Layout benutzt werden soll, wenn Du in keiner Gruppe bist."
L["Sets where Grid is anchored relative to the screen."] = "Setzt den Ankerpunkt von Grid relativ zum Bildschirm."
L["Sets where groups are anchored relative to the layout frame."] = "Setzt den Ankerpunkt der Gruppe relativ zum Layoutrahmen."
L["Set the coloring strategy of pet units."] = "Legt fest, wie die Begleiter eingefärbt werden."
L["Set the color of pet units."] = "Legt die Begleiterfarbe fest."
L["Show a tab for dragging when Grid is unlocked."] = "Reiter immer anzeigen. (Egal ob Grid gesperrt oder entsperrt ist.)"
L["Show Frame"] = "Zeige Rahmen"
L["Show tab"] = "Reiter anzeigen"
L["Solo Layout"] = "Solo Layout"
L["Spacing"] = "Abstand"
L["Switch between horizontal/vertical groups."] = "Wechselt zwischen horizontaler/vertikaler Gruppierung."
L["The color of unknown pets."] = "Farbe für unbekannte Begleiter."
L["The color of unknown units."] = "Farbe für unbekannte Einheiten."
L["Toggle whether to permit movement out of screen."] = "Legt fest ob der Grid-Rahmen im Bildschirm bleiben soll."
L["Top"] = "Oben"
L["Top Left"] = "Obenlinks"
L["Top Right"] = "Obenrechts"
L["Undead"] = "Untoter"
L["Unknown Pet"] = "Unbekannter Begleiter"
L["Unknown Unit"] = "Unbekannte Einheit"
-- L["Use the 40 Player Raid layout when in a raid group outside of a raid instance, instead of choosing a layout based on the current Raid Difficulty setting."] = ""
L["Using Fallback color"] = "Nach Ersatzfarbe"
-- L["World Raid as 40 Player"] = ""

------------------------------------------------------------------------
--	GridLayoutLayouts

L["By Class 10"] = "10er nach Klasse"
L["By Class 10 w/Pets"] = "10er nach Klasse mit Begleitern"
L["By Class 25"] = "25er nach Klasse"
L["By Class 25 w/Pets"] = "25er nach Klasse mit Begleitern"
-- L["By Class 40"] = ""
-- L["By Class 40 w/Pets"] = ""
L["By Group 10"] = "10er"
L["By Group 10 w/Pets"] = "10er mit Begleitern"
L["By Group 15"] = "15er"
L["By Group 15 w/Pets"] = "15er mit Begleitern"
L["By Group 25"] = "25er"
L["By Group 25 w/Pets"] = "25er mit Begleitern"
L["By Group 25 w/Tanks"] = "25er mit Tanks"
L["By Group 40"] = "40er"
L["By Group 40 w/Pets"] = "40er mit Begleitern"
L["By Group 5"] = " 5er"
L["By Group 5 w/Pets"] = " 5er mit Begleitern"
L["None"] = "Ausblenden"

------------------------------------------------------------------------
--	GridLDB

L["Click to toggle the frame lock."] = "Linksklick um Grid zu entsperren."

------------------------------------------------------------------------
--	GridRoster


------------------------------------------------------------------------
--	GridStatus

L["Color"] = "Farbe"
L["Color for %s"] = "Farbe für %s"
L["Enable"] = "Aktivieren"
L["Opacity"] = "Deckkraft" -- Needs review
L["Options for %s."] = "Optionen für %s."
L["Priority"] = "Priorität"
L["Priority for %s"] = "Priorität für %s"
L["Range filter"] = "Entfernungsfilter"
L["Reset class colors"] = "Klassenfarben zurücksetzen"
L["Reset class colors to defaults."] = "Klassenfarben auf Standard zurücksetzen."
L["Show status only if the unit is in range."] = "Zeigen Sie den Status nur, wenn die Einheit in Reichweite befindet."
L["Status"] = "Status"
L["Status: %s"] = "Status: %s"
L["Text"] = "Text"
L["Text to display on text indicators"] = "Text, der in einem Textindikator angezeigt wird"

------------------------------------------------------------------------
--	GridStatusAggro

L["Aggro"] = "Aggro"
L["Aggro alert"] = "Aggro-Alarm"
L["Aggro color"] = "Aggro Farbe"
L["Color for Aggro."] = "Farbe für 'Aggro'."
L["Color for High Threat."] = "Farbe für 'Hohe Bedrohung'."
L["Color for Tanking."] = "Farbe für 'Tanken'."
L["High"] = "Hoch"
L["High Threat color"] = "Farbe bei hoher Bedrohung"
L["Show detailed threat levels instead of simple aggro status."] = "Zeigt mehrere Bedrohungsstufen."
L["Tank"] = "Tank"
L["Tanking color"] = "Tanken Farbe"
L["Threat"] = "Bedrohung"

------------------------------------------------------------------------
--	GridStatusAuras

L["Add Buff"] = "Neuen Buff hinzufügen"
L["Add Debuff"] = "Neuen Debuff hinzufügen"
L["Auras"] = "Auren"
L["<buff name>"] = "<Buffname>"
L["Buff: %s"] = "Buff: %s"
L["Change what information is shown by the status color."] = "Ändere welche Information für die Statusfarbe angezeigt wird."
L["Change what information is shown by the status color and text."] = "Ändere welche Informationen für die Statusfarbe und den Statustext angezeigt werden."
L["Change what information is shown by the status text."] = "Ändere welche Information für den Statustext angezeigt wird."
L["Class Filter"] = "Klassenfilter"
L["Color"] = "Farbe"
L["Color to use when the %s is above the high count threshold values."] = "Farbe, welche genutzt wird wenn %s über dem hohem Schwellenwert liegt."
L["Color to use when the %s is between the low and high count threshold values."] = "Farbe, welche genutzt wird wenn %s zwischen dem niedrigen und der hohem Schwellenwert liegt."
L["Color when %s is below the low threshold value."] = "Farbe, welche genutzt wird wenn %s unter dem niedrigen Schwellenwert liegt"
L["Create a new buff status."] = "Fügt einen neuen Buff-Status hinzu."
L["Create a new debuff status."] = "Fügt einen neuen Debuff-Status hinzu."
L["Curse"] = "Fluch"
L["<debuff name>"] = "<Debuffname>"
L["(De)buff name"] = "(De)buff Name"
L["Debuff: %s"] = "Debuff: %s"
L["Debuff type: %s"] = "Debufftyp: %s"
L["Disease"] = "Krankheit"
L["Display status only if the buff is not active."] = "Zeigt den Status nur an, wenn der Buff nicht aktiv ist."
L["Display status only if the buff was cast by you."] = "Zeigt den Status nur an, wenn Du ihn gezaubert hast."
L["Ghost"] = "Geistererscheinung"
L["High color"] = "Farbe für \"Hoch\""
L["High threshold"] = "Hoher Schwellwert"
L["Low color"] = "Farbe für \"Niedrig\""
L["Low threshold"] = "Niedriger Schwellwert"
L["Magic"] = "Magie"
L["Middle color"] = "Farbe für \"Mittig\""
L["Pet"] = "Begleiter"
L["Poison"] = "Gift"
L["Present or missing"] = "Vorhanden oder fehlend"
L["Refresh interval"] = "Aktualisierungsintervall"
L["Remove an existing buff or debuff status."] = "Löscht einen vorhandenen Buff oder Debuff."
L["Remove Aura"] = "Debuff/Buff löschen"
L["Remove %s from the menu"] = "Entfernt %s vom Menü"
L["%s colors"] = "%s farben"
L["%s colors and threshold values."] = "%s Farben und Schwellenwerte"
L["Show advanced options"] = "Zeige erweiterte Optionen" -- Needs review
L[ [=[Show advanced options for buff and debuff statuses.

Beginning users may wish to leave this disabled until you are more familiar with Grid, to avoid being overwhelmed by complicated options menus.]=] ] = [=[Zeige erweiterte Einstellungen für Buff und Debuff Status

Beginner sollten diese Option deaktiviert lassen solange sie noch keie Erfahrung mit Grid gemacht haben, um zu vielen und/oder komplizierten Menüleisten aus dem Weg zu gehen.]=] -- Needs review
L["Show duration"] = "Dauer anzeigen"
L["Show if mine"] = "Zeigen wenn es meiner ist"
L["Show if missing"] = "Zeigen wenn es fehlt"
L["Show on pets and vehicles."] = "Auf Begleitern und Fahrzeugen anzeigen"
L["Show on %s players."] = "Zeigt den Status für die Klasse: %s."
L["Show status for the selected classes."] = "Zeigt den Status für die ausgwählte Klasse."
L["Show the time left to tenths of a second, instead of only whole seconds."] = "Zeige die verbleibende Zeit in Zehntelsekunden, anstelle von ganzen Sekunden "
L["Show the time remaining, for use with the center icon cooldown."] = "Zeigt die Dauer im Cooldown-Rahmen (Symbol im Zentrum)."
L["Show time left to tenths"] = "Zeige verbleibende Zeit in Zehntelsekunden"
L["%s is high when it is at or above this value."] = "%s ist hoch wenn der Wert gleich oder höher ist."
L["%s is low when it is at or below this value."] = "%s ist niedrig wenn der Wert gleich oder höher ist."
L["Stack count"] = "Stapel Zählen"
L["Status Information"] = "Statusinformation"
L["Text"] = "Text"
L["Time in seconds between each refresh of the status time left."] = "Zeit in Sekunden zwischen jeder Aktualisierung des Status Zeit verbleiben."
L["Time left"] = "Verbleibende Zeit"

------------------------------------------------------------------------
--	GridStatusHeals

L["Heals"] = "Heilungen"
L["Ignore heals cast by you."] = "Ignoriert Heilungen die von Dir gezaubert werden."
L["Ignore Self"] = "Sich selbst ignorieren"
L["Incoming heals"] = "Eingehende Heilungen"
L["Minimum Value"] = "Mindestwert"
L["Only show incoming heals greater than this amount."] = "Nur eingehende Heilungen anzeigen, die grösser als dieser Wert sind."

------------------------------------------------------------------------
--	GridStatusHealth

L["Color deficit based on class."] = "Färbt das Defizit nach Klassenfarbe."
L["Color health based on class."] = "Färbt den Gesundheitsbalken in Klassenfarbe."
L["DEAD"] = "TOT"
L["Death warning"] = "Todeswarnung"
L["FD"] = "TG"
L["Feign Death warning"] = "Warnung wenn totgestellt"
L["Health"] = "Gesundheit"
L["Health deficit"] = "Gesundheitsdefizit"
L["Health threshold"] = "Gesundheitsgrenzwert"
L["Low HP"] = "Wenig HP"
L["Low HP threshold"] = "Wenig HP Grenzwert"
L["Low HP warning"] = "Wenig HP Warnung"
L["Offline"] = "Offline"
L["Offline warning"] = "Offlinewarnung"
L["Only show deficit above % damage."] = "Zeigt Defizit bei mehr als % Schaden."
L["Set the HP % for the low HP warning."] = "Setzt den % Grenzwert für die Wenig HP Warnung."
L["Show dead as full health"] = "Zeige Tote mit voller Gesundheit an"
L["Treat dead units as being full health."] = "Behandle Tote als hätten sie volle Gesundheit."
L["Unit health"] = "Gesundheit"
L["Use class color"] = "Benutze Klassenfarbe"

------------------------------------------------------------------------
--	GridStatusMana

L["Low Mana"] = "Wenig Mana"
L["Low Mana warning"] = "Wenig Mana Warnung"
L["Mana"] = "Mana"
L["Mana threshold"] = "Mana Grenzwert"
L["Set the percentage for the low mana warning."] = "Setzt den % Grenzwert für die Wenig Mana Warnung."

------------------------------------------------------------------------
--	GridStatusName

L["Color by class"] = "Nach Klasse einfärben"
L["Unit Name"] = "Namen"

------------------------------------------------------------------------
--	GridStatusRange

L["Out of Range"] = "Außer Reichweite"
L["Range"] = "Entfernung"
L["Range check frequency"] = "Häufigkeit der Reichweitenmessung"
L["Seconds between range checks"] = "Sekunden zwischen den Reichweitenmessungen"

------------------------------------------------------------------------
--	GridStatusReadyCheck

L["?"] = "?"
L["AFK"] = "AFK"
L["AFK color"] = "AFK Farbe"
L["Color for AFK."] = "Farbe für 'AFK'."
L["Color for Not Ready."] = "Farbe für 'Nicht bereit'."
L["Color for Ready."] = "Farbe für 'Bereit'."
L["Color for Waiting."] = "Farbe für 'Warten'."
L["Delay"] = "Verzögerung"
L["Not Ready color"] = "Nicht bereit Farbe"
L["R"] = "OK"
L["Ready Check"] = "Bereitschaftscheck"
L["Ready color"] = "Bereit Farbe"
L["Set the delay until ready check results are cleared."] = "Zeit, bis die Bereitschaftscheck-Ergebnisse gelöscht werden."
L["Waiting color"] = "Warten Farbe"
L["X"] = "X"

------------------------------------------------------------------------
--	GridStatusResurrect

L["Casting color"] = "Farbe: Wirken"
L["Pending color"] = "Farbe: Abwarten"
L["RES"] = "REZ"
L["Resurrection"] = "Wiederbelebung"
L["Show the status until the resurrection is accepted or expires, instead of only while it is being cast."] = "Zeigen den Status bis die Wiederbelebung akzeptiert wurde oder abgelaufen ist, anstatt es nur währen des zauberns zu tun."
L["Show until used"] = "Zeige bis benutzt"
L["Use this color for resurrections that are currently being cast."] = "Nutze diese Farbe für die Wiederbelebungen, die zur Zeit gezaubert werden."
L["Use this color for resurrections that have finished casting and are waiting to be accepted."] = "Nutze diese Farbe für Wiederbelebungen die fertige gezaubert wurden und darauf warten angenommen zuwerden."

------------------------------------------------------------------------
--	GridStatusTarget

L["Target"] = "Ziel"
L["Your Target"] = "Dein Ziel"

------------------------------------------------------------------------
--	GridStatusVehicle

L["Driving"] = "Fährt"
L["In Vehicle"] = "In Fahrzeug"

------------------------------------------------------------------------
--	GridStatusVoiceComm

L["Talking"] = "Redet"
L["Voice Chat"] = "Sprachchat"
