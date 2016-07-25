-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Accounting Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Accounting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Accounting", "deDE")
if not L then return end

-- L["Accounting has not yet collected enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."] = ""
L["Activity Type"] = "Art der Aktivität"
L["All"] = "Alle"
-- L["Amount"] = ""
L["Aucs"] = "Aukt."
L["Average Prices:"] = "Durchschnittliche Preise:"
-- L["Avg Buy"] = ""
L["Avg Buy Price"] = "Durchschn. Einkaufspreis"
L["Avg Resale Profit"] = "Durchschn. Wiederverkaufsgewinn"
-- L["Avg Sale"] = ""
L["Avg Sell Price"] = "Durchschn. Verkaufspreis"
L["Back to Previous Page"] = "Zurück zur vorherigen Seite"
L["Balance"] = "Bilanz"
--[==[ L[ [=[Below is a graph of the your character's gold on hand over time.

The x-axis is time and goes from %s to %s
The y-axis is thousands of gold.]=] ] = "" ]==]
L["Bought"] = "Gekauft"
L["Buyer/Seller"] = "Käufer/Verkäufer"
L["Cancelled"] = "Abgebrochen"
L["Cancelled Since Last Sale:"] = "Abgebrochen seit letztem Verkauf:"
-- L["|cffff0000IMPORTANT:|r When TSM_Accounting last saved data for this realm, it was too big for WoW to handle, so old data was automatically trimmed in order to avoid corruption of the saved variables. The last %s of %s data has been preserved."] = ""
-- L["Character/Guild to Graph"] = ""
-- L["Character to Graph"] = ""
L["Clear Old Data"] = "Lösche alte Daten"
L["Click for a detailed report on this item."] = "Klickt auf diesen Gegenstand für einen detaillierten Bericht."
L["Click this button to permanently remove data older than the number of days selected in the dropdown."] = "Klickt auf diesen Button, um Daten permanent zu löschen, die älter sind als die ausgewählte Anzahl der Tage im Dropdown."
L["Data older than this many days will be deleted when you click on the button to the right."] = "Daten, die älter sind als diese Anzahl von Tagen, werden gelöscht, wenn Ihr auf den Button auf der rechten Seite klickt."
L["Days:"] = "Tage:"
L["DD/MM/YY HH:MM"] = "TT/MM/JJ SS:MM"
L["Display Grey Items in Sales"] = "Zeige graue Gegenstände bei den Verkäufen an"
-- L["Display Money Transfers"] = ""
-- L["Don't Prompt to Record Trades"] = ""
L["Earned Per Day:"] = "Einkommen pro Tag:"
L["Expenses"] = "Ausgaben"
L["Expired"] = "Abgelaufen"
L["Expired Since Last Sale:"] = "Abgelaufen seit letztem Verkauf:"
L["Failed Auctions"] = "Fehlgeschl. Auktionen"
-- L["Failed Since Last Sale"] = ""
L["Failed Since Last Sale (Expired/Cancelled):"] = "Fehlgeschlagen seit letztem Verkauf (Abgelaufen/Abgebrochen):"
L["General Options"] = "Allgemeine Optionen"
L["Gold Earned:"] = "Gold eingenommen:"
L["Gold Spent:"] = "Gold ausgegeben:"
L["Group"] = "Gruppe"
L["_ Hr _ Min ago"] = "vor _ St _ Min"
-- L["If checked, Money Transfers will be included in income / expense and summary. Accounting will still track these if disabled but will not show them."] = ""
L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"] = "Falls aktiviert, werden Gegenstände schlechter Qualität in Verkaufsdaten gezeigt. Sie werden weiterhin in die Goldbilanzen der Zusammenfassung einbezogen, unabhängig von dieser Einstellung."
-- L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / guild vault. Otherwise, a simple average of all purchases will be used."] = ""
L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."] = "Wenn aktiviert, wird die Anzahl abgebrochener Auktionen seit dem letzten Verkauf im Tooltip eines Gegenstands als fehlgeschlagene Auktionen angezeigt. Falls es keine Verkäufe gab, wird die Gesamtanzahl abgebrochener Auktionen gezeigt."
L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."] = "Wenn aktiviert, wird die Anzahl abgelaufener Auktionen seit dem letzten Verkauf im Tooltip eines Gegenstands als fehlgeschlagene Auktionen angezeigt. Falls es keine Verkäufe gab, wird die Gesamtanzahl abgelaufener Auktionen gezeigt."
--[==[ L[ [=[If checked, the number you have purchased and the average purchase price will show up in an item's tooltip.

Note: Vendor purchases will not be shown.]=] ] = "" ]==]
--[==[ L[ [=[If checked, the number you have sold and the average sale price will show up in an item's tooltip.

Note: Vendor sales will not be shown.]=] ] = "" ]==]
L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."] = "Wenn aktiviert, wird die Verkaufsrate im Tooltip eines Gegenstands angezeigt. Die Verkaufsrate berechnet sich aus: Gesamtverkäufe / (Gesamtverkäufe + Gesamtabläufe + Gesamtabbrüche)"
L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."] = "Wenn aktiviert, wird jedesmal, wenn Ihr eine beliebige Menge eines einzelnen Gegenstandes via Handel kauft oder verkauft, Accounting eine Abfrage einblenden, ob Ihr diese Transaktion aufzeichnen wollt."
L["If checked, you won't get a popup confirmation about whether or not to track trades."] = "Wenn aktiviert, werdet Ihr keine Bestätigungsabfrage bekommen, ob Ihr einen Handel aufzeichnen wollt."
L["Item Name"] = "Gegenstandsname"
L["Items"] = "Gegenstände"
L["Items/Resale Price Format"] = "Gegenstände/Wiederverkauf Preisformat" -- Needs review
-- L["Last %d Days"] = ""
L["Last Purchased:"] = "Zuletzt eingekauft:"
L["Last Sold:"] = "Zuletzt verkauft:"
L["Market Value"] = "Marktwert"
L["Market Value Source"] = "Quelle des Marktwertes"
-- L["Max Buy Price"] = ""
-- L["Max Sell Price"] = ""
-- L["Min Buy Price"] = ""
-- L["Min Sell Price"] = ""
L["MM/DD/YY HH:MM"] = "MM/TT/JJ SS:MM"
L["none"] = "keine"
L["None"] = "Keine"
L["Other Income"] = "Sonstiges Einkommen"
-- L["Other Player"] = ""
-- L["Per Item"] = ""
L["Player"] = "Spieler"
L["Player Gold"] = "Spielergold"
L["Profit:"] = "Gewinn:"
L["Profit Per Day:"] = "Gewinn pro Tag:"
L["Purchase Data"] = "Einkaufsdaten"
-- L["Purchased (Min/Avg/Max Price):"] = ""
L["Purchased (Total Price):"] = "Einkäufe (Gesamtpreis):"
L["Purchases"] = "Einkäufe"
L["Quantity"] = "Anzahl"
L["Quantity Bought:"] = "Anzahl gekaufter:"
L["Quantity Sold:"] = "Anzahl verkaufter:"
L["Rarity"] = "Seltenheit"
L["Removed a total of %s old records and %s items with no remaining records."] = "%s alte Daten und %s Gegenstände ohne Aufzeichnungen entfernt."
-- L["Removed record."] = ""
L["Remove Old Data (No Confirmation)"] = "Alte Daten entfernen (ohne Abfrage)"
L["Resale"] = "Wiederverkauf"
L["Revenue"] = "Einkommen"
L["%s ago"] = "vor %s"
L["Sale Data"] = "Verkaufsdaten"
L["Sale Rate:"] = "Verkaufsrate:"
L["Sales"] = "Verkäufe"
L["Search"] = "Suchen"
L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."] = "Wählt aus, wie Ihr die Preise in den Tabs \"Gegenstände\" und \"Wiederverkauf\" anzeigen wollt; entweder Durchschnittspreis pro Gegenstand oder Gesamtpreis."
L["Select what format Accounting should use to display times in applicable screens."] = "Wählt aus, welches Format benutzt werden soll, um Zeiten in den Fenstern anzuzeigen."
L["Select where you want Accounting to get market value info from to show in applicable screens."] = "Wählt aus, woher Accounting die Marktwertinformationen beziehen soll, um sie in den Fenstern anzuzeigen."
-- L["Shift-Right-Click to delete this record."] = ""
-- L["Show cancelled auctions since last sale in item tooltips"] = ""
-- L["Show expired auctions since last sale in item tooltips"] = ""
L["Show purchase info in item tooltips"] = "Zeige Einkaufsinformationen im Tooltip eines Gegenstands an"
L["Show sale info in item tooltips"] = "Zeige Verkaufsinformationen im Tooltip eines Gegenstands an"
L["Show Sale Rate in item tooltips"] = "Zeige Verkaufsrate im Tooltip eines Gegenstands an"
L["Sold"] = "Verkauft"
-- L["Sold (Min/Avg/Max Price):"] = ""
L["Sold (Total Price):"] = "Verkäufe (Gesamtpreis):"
L["Source"] = "Quelle"
L["Spent Per Day:"] = "Ausgegeben pro Tag:"
L["Stack"] = "Stapel"
L["Summary"] = "Zusammenfassung"
-- L["Sum of All Characters/Guilds"] = ""
L["There is no purchase data for this item."] = "Keine Einkaufsstatistik für diesen Gegenstand vorhanden."
L["There is no sale data for this item."] = "Keine Verkaufsstatistik für diesen Gegenstand vorhanden."
L["Time"] = "Zeit"
L["Time Format"] = "Zeitformat"
-- L["Timeframe (Days)"] = ""
L["Timeframe Filter"] = "Zeitfenster-Filter"
L["Today"] = "Heute"
L["Top Buyers:"] = "Beste Käufer:"
-- L["Top Expense by Gold / Quantity:"] = ""
-- L["Top Income by Gold / Quantity:"] = ""
-- L["Top Item by Gold / Quantity:"] = ""
L["Top Sellers:"] = "Beste Verkäufer:"
L["Total:"] = "Gesamt:"
-- L["Total Buy"] = ""
L["Total Buy Price"] = "Gesamtkaufpreis"
L["Total Price"] = "Gesamtpreis"
-- L["Total Sale"] = ""
L["Total Sale Price"] = "Gesamtverkaufspreis"
L["Total Spent:"] = "Insgesamt ausgegeben:"
L["Total Value"] = "Gesamtwert"
-- L["Track Sales/Purchases via Trade"] = ""
L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"] = "TSM_Accounting hat entdeckt, dass Ihr %s %s im Austausch gegen %s gehandelt hast. Soll Accounting diesen Handel protokollieren?"
L["Type"] = "Typ"
-- L["Use Smart Average for Purchase Price"] = ""
L["Yesterday"] = "Gestern"
L[ [=[You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.

NOTE: There is no confirmation.]=] ] = [=[Ihr könnt die folgenden Optionen nutzen, um alte Daten zu löschen. Damit Accounting weiterhin reibungslos läuft, solltet Ihr regelmäßig Eure alten Daten löschen. Wählt die Anzahl der Tage im Dropdown, für die Daten behalten werden sollen, und drückt den Button.

HINWEIS: Es erfolgt keine Bestätigungsabfrage.]=]
L["YY/MM/DD HH:MM"] = "JJ/MM/TT SS:MM"
 