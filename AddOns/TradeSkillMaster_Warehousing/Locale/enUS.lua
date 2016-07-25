-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Warehousing Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/tradeskillmaster_warehousing/localization/

local isDebug = false
--[===[@debug@
isDebug = true
--@end-debug@]===]
local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Warehousing", "enUS", true, isDebug)
if not L then return end

L["Canceled"] = true
L["Deposit Reagents"] = true
L["Displays realtime move data."] = true
L["Empty Bags"] = true
L["Enable Restock"] = true
L["Enable this to set the quantity to keep back in your bags"] = true
L["Enable this to set the quantity to keep back in your bank / guildbank"] = true
L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"] = true
L["Enable this to set the restock quantity"] = true
L["Enable this to set the stack size multiple to be moved"] = true
L["General"] = true
L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."] = true
L["Invalid criteria entered."] = true
L["Keep in Bags Quantity"] = true
L["Keep in Bank/GuildBank Quantity"] = true
L["Lists the groups with warehousing operations. Left click to select/deselect the group, Right click to expand/collapse the group."] = true
L["Move Data has been turned off"] = true
L["Move Data has been turned on"] = true
L["Move Group to Bags"] = true
L["Move Group to Bank"] = true
L["Move Quantity"] = true
L["Move Quantity Settings"] = true
L["Nothing to Move"] = true
L["Nothing to Restock"] = true
L["Preparing to Move"] = true
L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."] = true
L["Restock Bags"] = true
L["Restocking"] = true
L["Restock Quantity"] = true
L["Restock Settings"] = true
L["Restore Bags"] = true
L["Set Keep in Bags Quantity"] = true
L["Set Keep in Bank Quantity"] = true
L["Set Move Quantity"] = true
L["Set Stack Size for bags"] = true
L["'%s' has a Warehousing operation of '%s' which no longer exists."] = true
L["Stack Size Multiple"] = true
L["There are no visible banks."] = true
L["These will toggle between the module specific tabs."] = true
L["This button will deposit all reagents to your reagent bank (if unlocked)."] = true
L["This button will de-select all groups."] = true
L["This button will empty the contents of your bags and move them all to the bank. It will remember what you moved so that you can use the restore button to put them back"] = true
L["This button will move all items in the selected groups using the operation restock settings from the bank to your bags."] = true
L["This button will move items in the selected groups from the bank to your bags."] = true
L["This button will move items in the selected groups from your bags to the bank."] = true
L["This button will restore the items to your bags from the last time you clicked empty bags."] = true
L["This button will select all groups."] = true
L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."] = true
L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."] = true
L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."] = true
L["Warehousing will ensure this number remain in your bank / guildbank when restocking items to your bags."] = true
L["Warehousing will move all of the items in this group."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."] = true
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = true
L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."] = true
L["Warehousing will move this number of each item"] = true
L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"] = true
L["Warehousing will restock your bags up to this number of items"] = true
