-- German localisation file for deDE
local L = ElvUI[1].Libs.ACL:NewLocale("ElvUI", "deDE")
if not L then return end

-- Translation by: Kaltzifar

-- Init
L["ENH_LOGIN_MSG"] = "Sie verwenden |cff1784d1ElvUI Enhanced Again|r |cffff8000(Shadowlands)|r Version %s%s|r."
L["ENH_LOGIN_MSG_WRATH"] = "You are using |cff1784d1ElvUI Enhanced Again|r |cffff8000(Wrath Classic)|r version %s%s|r."
L["MSG_EEL_ELV_OUTDATED"] = "Ihre Version von ElvUI ist älter als für die Verwendung mit |cff1784d1ElvUI Enhanced Lite|r |cffff8000(Shadowlands)|r empfohlen. Ihre Version ist |cff1784d1%.2f|r (empfohlen ist |cff1784d1%.2f|r. Bitte aktualisieren Sie Ihre ElvUI."

-- Equipment
L["Equipment"] = "Ausrüstung"
L["EQUIPMENT_DESC"] = "Passen Sie die Einstellungen für das Ändern Ihrer Ausrüstung an, wenn Sie Ihre Talentspezialisierung ändern oder ein Schlachtfeld betreten."
L["No Change"] = "Keine Änderung"

L["Specialization"] = "Talentspezialisierung"
L["Enable/Disable the specialization switch."] = "Automatische Änderung der Ausrüstung beim Talentwechsel aktivieren / deaktivieren."

L["Primary Talent"] = "Primäre Talentspezialisierung"
L["Choose the equipment set to use for your primary specialization."] = "Wählen Sie das Ausrüstungsset für Ihre primäre Talentspezialisierung."

L["Secondary Talent"] = "Sekundäre Talentspezialisierung"
L["Choose the equipment set to use for your secondary specialization."] = "Wählen Sie das Ausrüstungsset für Ihre sekundäre Talentspezialisierung."

L["Battleground"] = "Schlachtfeld"
L['Enable/Disable the battleground switch.'] = "Automatische Änderung der Ausrüstung beim Betreten eines Schlachtfelds aktivieren / deaktivieren."

L["Equipment Set"] = "Ausrüstungsset"
L["Choose the equipment set to use when you enter a battleground or arena."] = "Wählen Sie Ihr Ausrüstungsset für Schlachtfelder oder die Arena."

L["You have equipped equipment set: "] = "Sie haben das folgende Ausrüstungsset angelegt: "

L["DURABILITY_DESC"] = "Passen Sie die Einstellungen für die Haltbarkeit im Charakterfenster an."
L["Enable/Disable the display of durability information on the character screen."] = "Anzeige der Haltbarkeit im Charakterfenster."
L["Damaged Only"] = "Nur Beschädigte"
L["Only show durabitlity information for items that are damaged."] = "Nur die Haltbarkeit für beschädigte Ausrüstungsteile anzeigen."

L["ITEMLEVEL_DESC"] = "Passen Sie die Einstellungen für die Anzeige von Gegenstandsstufen im Charakterfenster an."
L["Enable/Disable the display of item levels on the character screen."] = "Anzeige von Gegenstandsstufen im Charakterfenster aktivieren / deaktivieren."

L["Miscellaneous"] = "Verschiedenes"
L['Equipment Set Overlay'] = 'Ausrüstungssettext'
L['Show the associated equipment sets for the items in your bags (or bank).'] = 'Zeige auf Gegenständen im Rucksack (oder der Bank) die zugehörigen Ausrüstungssets als Text an.'

-- Movers
L["Mover Transparency"] = "Transparenz Ankerpunkte"
L["Changes the transparency of all the movers."] = "Konfiguriere die Einstellungen der Transparenz der Ankerpukte"

-- Automatic Role Assignment
L['Automatic Role Assignment'] = 'Automatische Rollenzuweisung'
L['Enables the automatic role assignment based on specialization for party / raid members (only work when you are group leader or group assist).'] = 'Aktiviert die automatische Rollenzuweisung basierend auf der Talentspezialisierung der Gruppen- oder Schlachtzugsmitglieder. Funktioniert nur, wenn Sie Gruppenleiter oder -assistent sind.'

-- Auto Hide Role Icons in combat
L['Hide Role Icon in combat'] = 'Verstecke Rollensymbol im Kampf'
L['All role icons (Damage/Healer/Tank) on the unit frames are hidden when you go into combat.'] = 'Alle Rollensymbole (Schaden/Heiler/Tank) auf den Einheitenfenstern werden versteckt, wenn der Charakter sich im Kampf befindet.'

-- GPS module
L['Show the direction and distance to the selected party or raid member.'] = "Zeige die Richtung und Entfernung zum ausgewählten Gruppen- oder Schlachtzugsmitglied an."

-- Attack Icon
L['Attack Icon'] = 'Angriffssymbol'
L['Show attack icon for units that are not tapped by you or your group, but still give kill credit when attacked.'] = 'Zeige Angriffssymbol für Gegner, die noch nicht von Ihnen markiert, aber trotzdem Belohnungen gewähren, wenn sie von Ihnen angegriffen werden'

-- Class Icon
L['Show class icon for units.'] = 'Zeige Klassensymbole für Einheiten'

-- Minimap Location
L['Above Minimap'] = "Oberhalb der Minimap"
L['Location Digits'] = "Koordinaten Nachkommastellen"
L['Number of digits for map location.'] = "Anzahl der Nachkommastellen der Koordinaten."

-- Minimap Combat Hide
L["Hide minimap while in combat."] = "Ausblenden der Minimap während des Kampfes."
L["FadeIn Delay"] = "Einblendungsverzögerung"
L["The time to wait before fading the minimap back in after combat hide. (0 = Disabled)"] = "Die Zeit vor dem wieder Einblenden der Minimap nach dem Kampf. (0 = deaktiviert)"

-- Minimap Buttons
L['Skin Buttons'] = "Skin Buttons"
L['Skins the minimap buttons in Elv UI style.'] = 'Skinne die Minimap-Buttons im ElvUI-Stil.'
L['Skin Style'] = "Skin Stil"
L['Change settings for how the minimap buttons are skinned.'] = "Ändern der Einstellungen, wie die Minimap-Buttons geskinnt werden."
L['The size of the minimap buttons.'] = "Die Größe der Minimap-Buttons."

L['No Anchor Bar'] = "Keine Ankerleiste"
L['Horizontal Anchor Bar'] = "Horizontale Ankerleiste"
L['Vertical Anchor Bar'] = "Vertikale Ankerleiste"

L['Layout Direction'] = true
L['Normal is right to left or top to bottom, or select reversed to switch directions.'] = true
L['Normal'] = true
L['Reversed'] = true

-- PvP Autorelease
L['PvP Autorelease'] = "Automatische Freigabe im PvP"
L['Automatically release body when killed inside a battleground.'] = "Gibt automatisch Ihren Geist frei, wenn Sie auf dem Schlachtfeld getötet wurden."

-- Track Reputation
L['Track Reputation'] = "Ruf beobachten"
L['Automatically change your watched faction on the reputation bar to the faction you got reputation points for.'] = "Ändere automatisch die beobachtete Fraktion auf der Erfahrungsleiste zu der Fraktion für die Sie grade Rufpunkte erhalten haben."

-- Select Quest Reward
L['Select Quest Reward'] = 'Wähle Questbelohnung'
L['Automatically select the quest reward with the highest vendor sell value.'] = 'Wählt automatisch die Questbelohnung mit dem höchsten Wiederverkaufswert beim Händler'

-- Item Level Datatext
L['Item Level'] = 'Gegenstandsstufe'

-- Range Datatext
L['Target Range'] = 'Zielabstand'
L['Distance'] = 'Entfernung'

-- Extra Datatexts
L['Actionbar1DataPanel'] = 'Aktionsleiste 1'
L['Actionbar3DataPanel'] = 'Aktionsleiste 3'
L['Actionbar5DataPanel'] = 'Aktionsleiste 5'

-- Farmer
L["Sunsong Ranch"] = 'Gehöft Sonnensang'
L["The Halfhill Market"] = 'Der Halbhügelmarkt'
L["Tilled Soil"] = 'Gepflügtes Erdreich'
L['Right-click to drop the item.'] = 'Mit der rechten Maustaste klicken, um den Gegenstand abzulegen.'

L['Farmer'] = 'Landwirt'
L["FARMER_DESC"] = 'Einstellungen für alle Werkzeuge, die Sie effizienter auf Gehöft Sonnensang arbeiten lassen.'
L['Farmer Bars'] = 'Landwirt Aktionsleisten'
L['Farmer Portal Bar'] = 'Landwirt Portalleiste'
L['Farmer Seed Bar'] = 'Landwirt Saatleiste'
L['Farmer Tools Bar'] = 'Landwirt Werkzeugleiste'
L['Enable/Disable the farmer bars.'] = 'Aktivieren / Deaktivieren der Landwirtleisten'
L['Only active buttons'] = 'Nur aktive Buttons'
L['Only show the buttons for the seeds, portals, tools you have in your bags.'] = 'Nur Buttons für Saat, Portale und Werkzeuge anzeigen, wenn diese in Ihrem Rucksack vorhanden sind.'
L['Drop Tools'] = 'Werkzeuge ablegen'
L['Automatically drop tools from your bags when leaving the farming area.'] = 'Beim Verlassen der Farm automatisch die Werkzeuge zerstören.'
L['Seed Bar Direction'] = 'Richtung Saatleiste'
L['The direction of the seed bar buttons (Horizontal or Vertical).'] = 'Die Ausbreitungsrichtung der Saatleiste (horizontal oder vertikal)'

-- Nameplates
L["Threat Text"] = "Bedrohungstext"
L["Display threat level as text on targeted, boss or mouseover nameplate."] = " Bedrohung als Text auf der Namensplakette des Ziels anzeigen."
L["Target Count"] = "Zähler für Angreifende"
L["Display the number of party / raid members targetting the nameplate unit."] = "Anzahl der Gruppenmitglieder die den Gegner der Namensplakette angreifen."

-- HealGlow
L['Heal Glow'] = 'Heilungsleuchten'
L['Direct AoE heals will let the unit frames of the affected party / raid members glow for the defined time period.'] = 'Direkte AoE-Heilungen lassen die Einheitenfenster von Gruppen- oder Schlachtzugsmitgliedern für eine festgelegte Zeit leuchten.'
L["Glow Duration"] = 'Richtung des Leuchtens'
L["The amount of time the unit frames of party / raid members will glow when affected by a direct AoE heal."] = "Die Zeitdauer die Einheitenfenster von Gruppen- oder Schlachtzugsmitgliedern leuchten, wenn diese durch direkte AoE-Heilungen betroffen sind."
L["Glow Color"] = 'Farbe des Leuchtens'

-- Raid Marker Bar
L['Raid Marker Bar'] = "Leiste Schlachtzugsymbole"
L['Display a quick action bar for raid targets and world markers.'] = "Aktionsleiste für Schlachtzugsymbole und Weltmarkierungen anzeigen."
L['Modifier Key'] = "Modifizierungstaste"
L['Set the modifier key for placing world markers.'] = "Modifizierungstaste für die Platzierung von Weltmarkierungen einstellen."
L['Shift Key'] = "Shift Taste"
L['Ctrl Key'] = "Steuerungstaste"
L['Alt Key'] = "Alt Taste"
L["Raid Markers"] = "Schlachtzugsymbole"
L["Click to clear the mark."] = "Klicken um die Weltmarkierung zu entfernen."
L["Click to mark the target."] = "Klicken um das Ziel zu markieren."
L["%sClick to remove all worldmarkers."] = "Drücken Sie die %staste um alle Weltmarkierungen zu entfernen."
L["%sClick to place a worldmarker."] = "Drücken Sie die %staste um eine Weltmarkierung zu platzieren."

-- WatchFrame
L['WatchFrame'] = "Questlog"
L['WATCHFRAME_DESC'] = 'Passen Sie die Einstellungen für die Sichtbarkeit des Questlogs ganz an ihre persönlichen Bedürfnisse an.'
L['Hidden'] = 'Versteckt'
L['Collapsed'] = 'Eingeklappt'
L['Settings'] = 'Einstellungen'
L['City (Resting)'] = 'Stadt (erholend)'
L['PvP'] = 'PvP'
L['Arena'] = 'Arena'
L['Party'] = 'Gruppe'
L['Raid'] = 'Schlachtzug'

-- Tooltips
L['Progression Info'] = 'Schlachtzugfortschritt'
L['Display the players raid progression in the tooltip, this may not immediately update when mousing over a unit.'] = 'Zeigt den Schlachtzugfortschritt eines Charakters im Tooltip an. Es kann einen kurzen Moement dauern, bis diese Information agezeigt / aktualisiert wird.'
