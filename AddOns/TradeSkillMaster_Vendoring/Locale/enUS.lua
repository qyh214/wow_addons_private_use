-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Vendoring                           --
--           http://www.curse.com/addons/wow/tradeskillmaster_vendoring           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Vendoring Locale - enUS
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/tradeskillmaster_vendoring/localization/

local isDebug = false
--[===[@debug@
isDebug = true
--@end-debug@]===]
local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Vendoring", "enUS", true, isDebug)
if not L then return end

L["AH"] = true
L["Alts"] = true
L["Alts AH"] = true
L[" and "] = true
L["Automatically Sell Vendor trash"] = true
L["Batch Size"] = true
L["BOEs"] = true
L["Buy"] = true
L["Buyback"] = true
L["Buy Selected Groups"] = true
L["Buy Settings"] = true
L["Cancel"] = true
L["Chat Message Options"] = true
L["Clear Filters"] = true
L["Click on this row to remove this item from the permanent ignore list."] = true
L["Click this button to automatically buy for groups which you have selected."] = true
L["Click this button to automatically sell for groups which you have selected."] = true
L["Collected: %s"] = true
L["Cost"] = true
L["Could not vendor due to not having free bag space available to split a stack of items."] = true
L["Default Vendoring Page"] = true
L["Destroy Value"] = true
L["Display Total Money Received"] = true
L["Do not sell an item if its destroy value meets or exceeds this amount"] = true
L["Do not sell an item if its market value meets or exceeds this amount"] = true
L["Enable Buying"] = true
L["Enable Selling"] = true
L["Filters >>"] = true
L["Formula for an item's destroy value"] = true
L["Formula for an item's market value"] = true
L["General"] = true
L["General Settings"] = true
L["Here you can select groups with TSM_Vendoring operations to be automatically bought or sold."] = true
L["Hide Grouped Items"] = true
L["Hide Soulbound Items"] = true
L["Hold shift to repair with guild bank"] = true
L["If checked, soulbound items will be sold"] = true
L["If checked, the total amount of gold received will be shown at the end of automatically selling."] = true
L["If checked, the Vendoring tab of merchant windows will be the default tab."] = true
L["If checked, this operation will be considered when clicking 'Buy Groups'"] = true
L["If checked, this operation will be considered when clicking 'Sell Groups'"] = true
L["If checked, vendoring will automatically sell any grey items in your inventory when you visit a merchant."] = true
L["Ignored Item"] = true
L["Ignore List"] = true
L["Ignoring all %s permanently. You can undo this in the Vendoring options."] = true
L["Ignoring all %s this session (until your UI is reloaded)."] = true
L["Item"] = true
L["Keeping %d."] = true
L["Keep Quantity"] = true
L["Mail"] = true
L["Make Vendoring Default Merchant Tab"] = true
L["Market Value"] = true
L["Max"] = true
L["Max Destroy Value"] = true
L["Max Destroy Value ('0c' to disable)"] = true
L["Max Market Value"] = true
L["Max Market Value ('0c' to disable)"] = true
L["Min Expires"] = true
L["Number of items to sell at a time when QuickSelling"] = true
L["Okay"] = true
L["Only sell an item after it has expired this many times"] = true
L["Potential"] = true
L["Quantity to keep in your bags"] = true
L["Quick Sell"] = true
L["Quick Sell Settings"] = true
L["Removed %s from the permanent ignore list."] = true
L["Repair"] = true
L["Restocking to %d."] = true
L["Restock Quantity"] = true
L["Sell after expired auctions"] = true
L["Sell All"] = true
L["Selling after %d expired auctions"] = true
L["Selling always"] = true
L["Selling if "] = true
L["Selling soulbound items."] = true
L["Sell Only:"] = true
L["Sell Selected Groups"] = true
L["Sell Settings"] = true
L["Sell soulbound items"] = true
L["%sLeft-Click|r to ignore an item for this session. Hold %sshift|r to ignore permanently. You can remove items from permanent ignore in the Vendoring options."] = true
L["Sources to Include in Restock"] = true
L["Specifies the default page that will show when you select the TSM_Vendoring tab."] = true
L["%s%sdestroy value is below %s"] = true
L["%s%smarket value is below %s"] = true
L["%s%smarket value is below %s and destroy value is below %s"] = true
L["Stack"] = true
L["These buttons change what is shown in the merchant frame. You can view what the merchant is selling, buyback any items you have sold, automatically buy and sell items in groups, and quickly sell items."] = true
L[ [=[The 'Sell All' button will sell all items listed above. The 'Trash' button will sell grey items.  The 'BOEs' button will sell bind-on-equip items listed above.

Make sure you review the list before selling the first time.]=] ] = true
L["This is where the items in your inventory are listed. Items that appear here have evaluated to be worth less than your thresholds determined in the options."] = true
L[ [=[This is where the items the merchant has for sale are listed.

Items with a red number are things that you already know or cannot use.

Just like the default UI, you may right click to buy a single item, or shift-left click to buy multiples.]=] ] = true
L["This is where you can buyback items from the merchant.  Right click on an item to buy it back."] = true
L["Trash"] = true
L["TSM Groups"] = true
L["Vendor"] = true
L["Vendoring operations contain settings for easy vendoring of items."] = true
L["Vendoring Settings"] = true
L["Vendoring will take into account items from these sources when calculating how much to restock"] = true
L["When buying, restock to this amount"] = true
