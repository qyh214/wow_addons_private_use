-- ♡ Translation // Larsj02, dabear78

---@class addon
local addon = select(2, ...)
local L = addon.C.AddonInfo.Locales

--------------------------------

L.deDE = {}
local NS = L.deDE; L.deDE = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "deDE" then
		return
	end

	--------------------------------
	-- GENERAL
	--------------------------------

	do

	end

	--------------------------------
	-- WAYPOINT SYSTEM
	--------------------------------

	do
		-- PINPOINT
		L["WaypointSystem - Pinpoint - Quest - Complete"] = "Bereit zur Abgabe"
	end

	--------------------------------
	-- SLASH COMMAND
	--------------------------------

	do
		L["SlashCommand - /way - Map ID - Prefix"] = "Aktuelle Karten-ID: "
		L["SlashCommand - /way - Map ID - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (X) - Prefix"] = "X: "
		L["SlashCommand - /way - Position - Axis (X) - Suffix"] = ""
		L["SlashCommand - /way - Position - Axis (Y) - Prefix"] = ", Y: "
		L["SlashCommand - /way - Position - Axis (Y) - Suffix"] = ""
	end

	--------------------------------
	-- CONFIG
	--------------------------------

	do
		L["Config - General"] = "Allgemein"
		L["Config - General - Title"] = "Allgemein"
		L["Config - General - Title - Subtext"] = "Allgemeine Einstellungen anpassen."
		L["Config - General - Preferences"] = "Präferenzen"
		L["Config - General - Preferences - Meter"] = "Meter statt Yard verwenden"
		L["Config - General - Preferences - Meter - Description"] = "Ändert die Maßeinheit auf das metrische System."
		L["Config - General - Preferences - Font"] = "Schriftart"
		L["Config - General - Preferences - Font - Description"] = "Die im Addon verwendete Schriftart."
		L["Config - General - Reset"] = "Zurücksetzen"
		L["Config - General - Reset - Button"] = "Auf Standard zurücksetzen"
		L["Config - General - Reset - Confirm"] = "Möchtest du wirklich alle Einstellungen zurücksetzen?"
		L["Config - General - Reset - Confirm - Yes"] = "Bestätigen"
		L["Config - General - Reset - Confirm - No"] = "Abbrechen"

		L["Config - WaypointSystem"] = "Wegpunkt"
		L["Config - WaypointSystem - Title"] = "Wegpunkt"
		L["Config - WaypointSystem - Title - Subtext"] = "Verwalte das Verhalten des Weltmarkers und der Zielmarkierung."
		L["Config - WaypointSystem - Type"] = "Aktivieren"
		L["Config - WaypointSystem - Type - Both"] = "Alle"
		L["Config - WaypointSystem - Type - Waypoint"] = "Wegpunkt"
		L["Config - WaypointSystem - Type - Pinpoint"] = "Zielmarkierung"
		L["Config - WaypointSystem - General"] = "Allgemein"
		L["Config - WaypointSystem - General - RightClickToClear"] = "Right-Click To Clear"
		L["Config - WaypointSystem - General - RightClickToClear - Description"] = "Allows you to clear the Waypoint/Pinpoint/Navigator by right-clicking it."
		L["Config - WaypointSystem - General - Transition Distance"] = "Zielmarkierungs-Distanz"
		L["Config - WaypointSystem - General - Transition Distance - Description"] = "Distanz, bevor die Zielmarkierung angezeigt wird."
		L["Config - WaypointSystem - General - Hide Distance"] = "Minimale Distanz"
		L["Config - WaypointSystem - General - Hide Distance - Description"] = "Distanz, bevor ausgeblendet wird."
		L["Config - WaypointSystem - Waypoint"] = "Wegpunkt"
		L["Config - WaypointSystem - Waypoint - Footer - Type"] = "Zusätzliche Infos"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Both"] = "Alle"
		L["Config - WaypointSystem - Waypoint - Footer - Type - Distance"] = "Entfernung"
		L["Config - WaypointSystem - Waypoint - Footer - Type - ETA"] = "Ankunftszeit"
		L["Config - WaypointSystem - Waypoint - Footer - Type - None"] = "Keine"
		L["Config - WaypointSystem - Pinpoint"] = "Zielmarkierung"
		L["Config - WaypointSystem - Pinpoint - Info"] = "Info anzeigen"
		L["Config - WaypointSystem - Pinpoint - Info - Extended"] = "Erweiterte Info verwenden"
		L["Config - WaypointSystem - Pinpoint - Info - Extended - Description"] = "Wie Name und Beschreibung."
		L["Config - WaypointSystem - Navigator"] = "Navigator"
		L["Config - WaypointSystem - Navigator - Enable"] = "Anzeigen"
		L["Config - WaypointSystem - Navigator - Enable - Description"] = "Wenn der Wegpunkt oder die Zielmarkierung außerhalb des Bildschirms ist, zeigt der Navigator die Richtung an."

		L["Config - Appearance"] = "Aussehen"
		L["Config - Appearance - Title"] = "Aussehen"
		L["Config - Appearance - Title - Subtext"] = "Das Aussehen des Interfaces anpassen."
		L["Config - Appearance - Waypoint"] = "Wegpunkt"
		L["Config - Appearance - Waypoint - Scale"] = "Größe"
		L["Config - Appearance - Waypoint - Scale - Description"] = "Die Größe ändert sich je nach Entfernung. Diese Option legt die Gesamtgröße fest."
		L["Config - Appearance - Waypoint - Scale - Min"] = "Minimum %"
		L["Config - Appearance - Waypoint - Scale - Min - Description"] = "Größe kann reduziert werden auf."
		L["Config - Appearance - Waypoint - Scale - Max"] = "Maximum %"
		L["Config - Appearance - Waypoint - Scale - Max - Description"] = "Größe kann vergrößert werden auf."
		L["Config - Appearance - Waypoint - Beam"] = "Strahl anzeigen"
		L["Config - Appearance - Waypoint - Beam - Alpha"] = "Transparenz"
		L["Config - Appearance - Waypoint - Footer"] = "Info-Text anzeigen"
		L["Config - Appearance - Waypoint - Footer - Scale"] = "Größe"
		L["Config - Appearance - Waypoint - Footer - Alpha"] = "Transparenz"
		L["Config - Appearance - Pinpoint"] = "Zielmarkierung"
		L["Config - Appearance - Pinpoint - Scale"] = "Größe"
		L["Config - Appearance - Navigator"] = "Navigator"
		L["Config - Appearance - Navigator - Scale"] = "Größe"
		L["Config - Appearance - Navigator - Alpha"] = "Transparenz"
		L['Config - Appearance - Navigator - Distance'] = "Distance"
		L["Config - Appearance - Visual"] = "Visuell"
		L["Config - Appearance - Visual - UseCustomColor"] = "Benutzerdefinierte Farbe verwenden"
		L["Config - Appearance - Visual - UseCustomColor - Color"] = "Farbe"
		L["Config - Appearance - Visual - UseCustomColor - TintIcon"] = "Icon einfärben"
		L["Config - Appearance - Visual - UseCustomColor - Reset"] = "Zurücksetzen"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Default"] = "Normale Quest"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Repeatable"] = "Wiederholbare Quest"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Complete - Important"] = "Wichtige Quest"
		L["Config - Appearance - Visual - UseCustomColor - Quest - Incomplete"] = "Unvollständige Quest"
		L["Config - Appearance - Visual - UseCustomColor - Neutral"] = "Allgemeiner Wegpunkt"

		L["Config - Audio"] = "Audio"
		L["Config - Audio - Title"] = "Audio"
		L["Config - Audio - Title - Subtext"] = "Konfiguration für die Audioeffekte der Wegpunkt-Benutzeroberfläche."
		L["Config - Audio - General"] = "Allgemein"
		L["Config - Audio - General - EnableGlobalAudio"] = "Audio aktivieren"
		L["Config - Audio - Customize"] = "Anpassen"
		L["Config - Audio - Customize - UseCustomAudio"] = "Benutzerdefiniertes Audio verwenden"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID"] = "Sound-ID"
		L["Config - Audio - Customize - UseCustomAudio - Sound ID - Placeholder"] = "Benutzerdefinierte ID"
		L["Config - Audio - Customize - UseCustomAudio - Preview"] = "Vorschau"
		L["Config - Audio - Customize - UseCustomAudio - Reset"] = "Zurücksetzen"
		L["Config - Audio - Customize - UseCustomAudio - WaypointShow"] = "Wegpunkt anzeigen"
		L["Config - Audio - Customize - UseCustomAudio - PinpointShow"] = "Zielmarkierung anzeigen"

		L["Config - About"] = "Über"
		L["Config - About - Contributors"] = "Mitwirkende"
		L["Config - About - Developer"] = "Entwickler"
		L["Config - About - Developer - AdaptiveX"] = "AdaptiveX"
	end

	--------------------------------
	-- CONTRIBUTORS
	--------------------------------

	do
		L["Contributors - ZamestoTV"] = "ZamestoTV"
		L["Contributors - ZamestoTV - Description"] = "Übersetzer — Russisch"
		L["Contributors - huchang47"] = "huchang47"
		L["Contributors - huchang47 - Description"] = "Übersetzer — Chinesisch (Vereinfacht)"
		L["Contributors - BlueNightSky"] = "BlueNightSky"
		L["Contributors - BlueNightSky - Description"] = "Übersetzer — Chinesisch (Traditionell)"
		L["Contributors - Crazyyoungs"] = "Crazyyoungs"
		L["Contributors - Crazyyoungs - Description"] = "Übersetzer — Koreanisch"
		L["Contributors - Klep"] = "Klep"
		L["Contributors - Klep - Description"] = "Übersetzer — Französisch"
		L["Contributors - Kroffy"] = "Kroffy"
		L["Contributors - Kroffy - Description"] = "Übersetzer — Französisch"
		L["Contributors - cathtail"] = "cathtail"
		L["Contributors - cathtail - Description"] = "Translator - Brazilian Portuguese"
		L["Contributors - Larsj02"] = "Larsj02"
		L["Contributors - Larsj02 - Description"] = "Übersetzer — Deutsch"
		L["Contributors - dabear78"] = "dabear78"
		L["Contributors - dabear78 - Description"] = "Übersetzer — Deutsch"
		L["Contributors - y45853160"] = "y45853160"
		L["Contributors - y45853160 - Description"] = "Code — Beta-Bugfix"
		L["Contributors - lemieszek"] = "lemieszek"
		L["Contributors - lemieszek - Description"] = "Code — Beta-Bugfix"
		L["Contributors - BadBoyBarny"] = "BadBoyBarny"
		L["Contributors - BadBoyBarny - Description"] = "Code — Bug Fix"
		L["Contributors - SyverGiswold"] = "SyverGiswold"
		L["Contributors - SyverGiswold - Description"] = "Code - Feature"
	end
end

NS:Load()
