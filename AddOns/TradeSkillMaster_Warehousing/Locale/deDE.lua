-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Warehousing Locale - deDE
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Warehousing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Warehousing", "deDE")
if not L then return end

L["Canceled"] = "Abgebrochen" -- Needs review
-- L["Deposit Reagents"] = ""
L["Displays realtime move data."] = "Zeigt Verschiebungsdaten in Echtzeit an." -- Needs review
L["Empty Bags"] = "Taschen leeren"
L["Enable Restock"] = "Aktiviere Auffüllen" -- Needs review
L["Enable this to set the quantity to keep back in your bags"] = "Aktiviert dies, um eine Menge setzen zu können, die in Euren Taschen behalten werden soll." -- Needs review
L["Enable this to set the quantity to keep back in your bank / guildbank"] = "Aktiviert dies, um eine Menge setzen zu können, die in Eurer Bank / Gildenbank behalten werden soll." -- Needs review
L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"] = "Aktiviert dies, um eine Menge setzen zu können, die verschoben werden soll. Ist es deaktiviert, wird Warehousing alles von dem Gegenstand verschieben." -- Needs review
L["Enable this to set the restock quantity"] = "Aktiviert dies, um die Auffüllmenge zu setzen." -- Needs review
-- L["Enable this to set the stack size multiple to be moved"] = ""
L["General"] = "Allgemein" -- Needs review
L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."] = "Nimmt Gegenstände aus der Bank oder Gildenbank, die mit itemString, itemID oder mit dem eingegebenen Teil des Textes übereinstimmen." -- Needs review
L["Invalid criteria entered."] = "Ungültige Kriterien eingetragen." -- Needs review
L["Keep in Bags Quantity"] = "In den Taschen zu behaltende Menge" -- Needs review
L["Keep in Bank/GuildBank Quantity"] = "In der Bank/Gildenbank zu behaltende Menge" -- Needs review
-- L["Lists the groups with warehousing operations. Left click to select/deselect the group, Right click to expand/collapse the group."] = ""
L["Move Data has been turned off"] = "Verschiebungsdaten wurden ausgeschalten" -- Needs review
L["Move Data has been turned on"] = "Verschiebungsdaten wurden eingeschalten" -- Needs review
L["Move Group to Bags"] = "Gruppe in Taschen verschieben"
L["Move Group to Bank"] = "Gruppe in die Bank verschieben"
L["Move Quantity"] = "Zu Verschiebende Menge" -- Needs review
L["Move Quantity Settings"] = "Einstellungen zum Verschieben der Menge" -- Needs review
L["Nothing to Move"] = "Nichts zu verschieben" -- Needs review
L["Nothing to Restock"] = "Nichts aufzufüllen" -- Needs review
L["Preparing to Move"] = "Bereite zum Verschieben vor" -- Needs review
L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."] = "Setzt Gegenstände in die Bank oder Gildenbank, die mit itemString, itemID oder mit dem eingegebenen Teil des Textes übereinstimmen." -- Needs review
L["Restock Bags"] = "Taschen auffüllen" -- Needs review
L["Restocking"] = "Auffüllen" -- Needs review
L["Restock Quantity"] = "Auffüllmenge" -- Needs review
L["Restock Settings"] = "Auffüll-Einstellungen" -- Needs review
L["Restore Bags"] = "Taschen wiederherstellen"
L["Set Keep in Bags Quantity"] = "Setze behaltende Taschenmenge"
L["Set Keep in Bank Quantity"] = "Setze behaltende Bankmenge"
L["Set Move Quantity"] = "Setze zu verschiebende Menge"
-- L["Set Stack Size for bags"] = ""
L["'%s' has a Warehousing operation of '%s' which no longer exists."] = "'%s' hat eine Warehousing-Operation von '%s', die nicht mehr existiert." -- Needs review
-- L["Stack Size Multiple"] = ""
L["There are no visible banks."] = "Es gibt keine sichtbaren Bänke." -- Needs review
-- L["These will toggle between the module specific tabs."] = ""
-- L["This button will deposit all reagents to your reagent bank (if unlocked)."] = ""
-- L["This button will de-select all groups."] = ""
-- L["This button will empty the contents of your bags and move them all to the bank. It will remember what you moved so that you can use the restore button to put them back"] = ""
-- L["This button will move all items in the selected groups using the operation restock settings from the bank to your bags."] = ""
-- L["This button will move items in the selected groups from the bank to your bags."] = ""
-- L["This button will move items in the selected groups from your bags to the bank."] = ""
-- L["This button will restore the items to your bags from the last time you clicked empty bags."] = ""
-- L["This button will select all groups."] = ""
L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."] = "Warehousing-Operationen enthalten Einstellungen, um die Gegenstände in eine Gruppe zu verschieben. Schreibt den Namen der neuen Operation in das Eingabefeld unten und drückt ENTER, um eine neue Warehousing-Operation zu erstellen." -- Needs review
L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."] = "Warehousing wird sichergehen, dass diese Anzahl in Euren Taschen bleibt, wenn Gegenstände in die Bank / Gildenbank verschoben werden." -- Needs review
L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."] = "Warehousing wird sichergehen, dass diese Anzahl in Eurer Bank / Gildenbank bleibt, wenn Gegenstände in Euren Taschen verschoben werden." -- Needs review
-- L["Warehousing will ensure this number remain in your bank / guildbank when restocking items to your bags."] = ""
L["Warehousing will move all of the items in this group."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."] = "Warehousing wird alles von den Gegenständen in diese Gruppe verschieben. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind, und %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Taschen größer als Bank/GBank sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind." -- Needs review
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben, und behält %d von jedem Gegenstand, wenn Bank/GBank größer als Taschen sind. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."] = "Warehousing wird maximal %d von jedem Gegenstand in diese Gruppe verschieben. Das Auffüllen wird %d Gegenstände in Euren Taschen aufrechterhalten." -- Needs review
L["Warehousing will move this number of each item"] = "Warehousing wird diese Anzahl von jedem Gegenstand verschieben." -- Needs review
-- L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"] = ""
L["Warehousing will restock your bags up to this number of items"] = "Warehousing wird Eure Taschen bis zu dieser Anzahl von Gegenständen auffüllen." -- Needs review
