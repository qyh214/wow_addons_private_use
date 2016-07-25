-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_AuctionDB                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_auctiondb           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_AuctionDB Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_AuctionDB/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "deDE")
if not L then return end

L["A full auction house scan will scan every item on the auction house but is far slower than a GetAll scan. Expect this scan to take several minutes or longer."] = "Ein vollständiger Scan wird jeden einzelnen Gegenstand im Auktionshaus scannen, allerdings ist er weitaus langsamer als der GetAll-Scan. Dieser Scan kann mehrere Minuten dauern."
L["A full scan is a slow, manual scan of the entire auction house."] = "Ein vollständiger Scan ist langsam, manuelles scannen des gesammten Autktionshauses." -- Needs review
L["A 'GetAll' scan is an extremely fast way to manually scan the entire AH, but may run into bugs on Blizzard's end such as disconnection issues. It also has a 15 minute cooldown."] = "Der \"GetAll\" Scan ist ein sehr schneller Weg um das gesammte AH zu scannen, es kann jedoch zu einem Verbindungsabbruch seitens Blizzard´s führen. Der Cooldown beträgt 15 Minuten." -- Needs review
L["A GetAll scan is the fastest in-game method for scanning every item on the auction house. However, there are many possible bugs on Blizzard's end with it including the chance for it to disconnect you from the game. Also, it has a 15 minute cooldown."] = "Ein GetAll-Scan ist die schnellste Methode im Spiel zum Scannen von AH-Gegenständen. Allerdings können dabei einige Bugs seitens Blizzard auftreten, einschließlich der Chance eines Disconnects. Außerdem hat er eine Abklingzeit von 15 Minuten."
L["AuctionDB - Global Historical Price (via TSM App)"] = "AuctionDB - Globaler historischer Preis (via TSM App)" -- Needs review
L["AuctionDB - Global Market Value Average (via TSM App)"] = "AuctionDB - Globaler Marktpreisdurchschnitt (via TSM App)" -- Needs review
L["AuctionDB - Global Minimum Buyout Average (via TSM App)"] = "AuctionDB - Globaler Mindestverkaufsdurchschnitt (via TSM App)" -- Needs review
L["AuctionDB - Global Sale Average (via TSM App)"] = "AuctionDB - Globaler Verkaufsdurchschnitt (via TSM App)" -- Needs review
L["AuctionDB - Historical Price (via TSM App)"] = "AuctionDB - Historischer Preis (via TSM App)" -- Needs review
L["AuctionDB - Market Value"] = "AuctionDB - Marktwert"
L["AuctionDB - Minimum Buyout"] = "AuctionDB - Mindestpreis"
-- L["AuctionDB - Region Historical Price (via TSM App)"] = ""
-- L["AuctionDB - Region Market Value Average (via TSM App)"] = ""
-- L["AuctionDB - Region Minimum Buyout Average (via TSM App)"] = ""
-- L["AuctionDB - Region Sale Average (via TSM App)"] = ""
L["Can't run a GetAll scan right now."] = "Momentan kann ein GetAll-Scan nicht durchgeführt werden."
-- L["|cffff0000WARNING:|r TSM_AuctionDB doesn't currently have any pricing data for your realm. Either download the TSM Desktop Application from |cff99ffffhttp://tradeskillmaster.com|r to automatically update TSM_AuctionDB's data, or run a manual scan in-game."] = ""
L["%d auctions"] = "%d Auktionen"
L["Display global historical price (via TSM Application) in the tooltip."] = "Zeige globalen historischen Preis avg (via TSM Application) im Tooltip." -- Needs review
L["Display global market value avg (via TSM Application) in the tooltip."] = "Zeige globalen Marktwert avg (via TSM Application) im Tooltip." -- Needs review
L["Display global min buyout avg (via TSM Application) in the tooltip."] = "Zeige globalen Mindestverkaufspreis avg (via TSM Application) im Tooltip." -- Needs review
L["Display global sale avg (via TSM Application) in the tooltip."] = "Zeige globalen Verkaufspreis avg (via TSM Application) im Tooltip." -- Needs review
L["Display historical price (via TSM Application) in the tooltip."] = "Zeige historischen Preis (via TSM Application) im Tooltip." -- Needs review
L["Display market value in tooltip."] = "Zeige Marktwert im Tooltip."
L["Display min buyout in tooltip."] = "Zeige Mindesverkaufspreis im Tooltip." -- Needs review
-- L["Display region average daily sold quantity (via TSM Application) in the tooltip."] = ""
-- L["Display region historical price (via TSM Application) in the tooltip."] = ""
-- L["Display region market value avg (via TSM Application) in the tooltip."] = ""
-- L["Display region min buyout avg (via TSM Application) in the tooltip."] = ""
-- L["Display region sale avg (via TSM Application) in the tooltip."] = ""
-- L["Display region sale rate (via TSM Application) in the tooltip."] = ""
L["Done Scanning"] = "Scannen beendet"
L["Download the FREE TSM desktop application which will automatically update your TSM_AuctionDB prices using Blizzard's online APIs (and does MUCH more). Visit %s for more info and never scan the AH again! This is the best way to update your AuctionDB prices."] = "Ladet die KOSTENLOSE TSM-Desktopsoftware herunter, die Eure TSM_AuctionDB-Preise mithilfe der Online-APIs von Blizzard aktualisiert (und noch VIELES mehr). Besucht %s, um weitere Informationen zu erhalten und das AH nie wieder scannen zu müssen! Das ist die beste Methode, um Eure AuctionDB-Preise aktuell zu halten."
L["General Options"] = "Allgemeine Optionen"
L["Global Historical Price:"] = "Globaler historischer Preis:" -- Needs review
L["Global Historical Price x%s:"] = "Globaler historischer Preis x%s:" -- Needs review
L["Global Market Value Avg:"] = "Globaler Marktwer Avg:" -- Needs review
L["Global Market Value Avg x%s:"] = "Globaler Marktwert Avg x%s:" -- Needs review
L["Global Min Buyout Avg:"] = "Globaler Mindestverkaufspreis Avg:" -- Needs review
L["Global Min Buyout Avg x%s:"] = "Globaler Mindestverkaufspreis Avg x%s:" -- Needs review
-- L["Global Sale Avg:"] = ""
-- L["Global Sale Avg x%s:"] = ""
-- L["Historical Price:"] = ""
-- L["Historical Price x%s:"] = ""
-- L["If checked, AuctionDB will add a tab to the AH to allow for in-game scans. If you are using the TSM app exclusively for your scans, you may want to hide it by unchecking this option. This option requires a reload to take effect."] = ""
-- L["If checked, the global historical price of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the global market value average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the global minimum buyout average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the global sale average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the historical price of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
L["If checked, the lowest buyout value seen in the last scan of the item will be displayed."] = "Wenn aktiviert, wird der niedrigste Sofortkaufpreis, der im letzten Scan des Gegenstands gefunden wurde, angezeigt."
L["If checked, the market value of the item will be displayed"] = "Wenn aktiviert, wird der Marktwert des Gegenstands angezeigt."
-- L["If checked, the region average daily sold quantity of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the region historical price of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the region market value average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the region minimum buyout average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the region sale average of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If checked, the region sale rate of the item will be displayed. This is provided exclusively via the TradeSkillMaster Application."] = ""
-- L["If you have created TSM groups, they will be listed here for selection."] = ""
L["Last updated from in-game scan %s ago."] = "Zuletzt aktualisiert vor %s via Ingame-Scan."
L["Last updated from the TSM Application %s ago."] = "Zuletzt aktualisiert vor %s via TSM-Anwendung."
-- L["Last Update Time"] = ""
L["Market Value:"] = "Marktwert:"
L["Market Value x%s:"] = "Marktwert x%s:"
L["Min Buyout:"] = "Mindest-Sofortkauf:" -- Needs review
L["Min Buyout x%s:"] = "Min. Sofortkauf x%s:"
L["No scans found."] = "Keine Scans gefunden."
L["Not Ready"] = "Nicht bereit"
L["Not Scanned"] = "Nicht gescannt"
-- L["Preparing Filters..."] = ""
L["Processing data..."] = "Verarbeite Daten..."
L["Ready"] = "Bereit"
-- L["Region Avg Daily Sold:"] = ""
-- L["Region Avg Daily Sold x%s:"] = ""
-- L["Region Historical Price:"] = ""
-- L["Region Historical Price x%s:"] = ""
-- L["Region Market Value Avg:"] = ""
-- L["Region Market Value Avg x%s:"] = ""
-- L["Region Min Buyout Avg:"] = ""
-- L["Region Min Buyout Avg x%s:"] = ""
-- L["Region Sale Avg:"] = ""
-- L["Region Sale Avg x%s:"] = ""
-- L["Region Sale Rate:"] = ""
-- L["Region Sale Rate x%s:"] = ""
L["Run Full Scan"] = "Vollständigen Scan starten"
L["Run GetAll Scan"] = "GetAll-Scan starten"
L["Running query..."] = "Abfrage läuft..."
L["%s ago"] = "Vor %s"
-- L["Scanning %d / %d (Page %d / %d)"] = ""
L["Scanning page %s/%s"] = "Scanne Seite %s/%s"
-- L["Scanning page %s/%s - Approximately %s remaining"] = ""
-- L["Scanning results..."] = ""
L["Scanning the auction house in game is no longer necessary!"] = "Das Auktionshaus muss im Spiel nicht mehr gescannt werden!"
-- L["Scan Selected Groups"] = ""
-- L["Show AuctionDB AH Tab (Requires Reload)"] = ""
-- L["The scan did not run successfully due to issues on Blizzard's end. Using the TSM desktop application for your scans is recommended."] = ""
L["This button will scan just the items in the groups you have selected."] = "Dieser Button wird nur die Gegenstände in den ausgewählten Gruppen durchsuchen." -- Needs review
-- L["This will do a slow auction house scan of every item in the selected groups and update their AuctionDB prices. This may take several minutes."] = ""
-- L["You must select at least one group before starting the group scan."] = ""
 