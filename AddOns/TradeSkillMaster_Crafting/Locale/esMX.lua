-- ------------------------------------------------------------------------------------- --
-- 					TradeSkillMaster_Crafting - AddOn by Sapu94							 	  	  --
--   http://wow.curse.com/downloads/wow-addons/details/tradeskillmaster_crafting.aspx    --
--																													  --
--		This addon is licensed under the CC BY-NC-ND 3.0 license as described at the		  --
--				following url: http://creativecommons.org/licenses/by-nc-nd/3.0/			 	  --
-- 	Please contact the author via email at sapu94@gmail.com with any questions or		  --
--		concerns regarding this license.																	  --
-- ------------------------------------------------------------------------------------- --

-- TradeSkillMaster_Crafting Locale - esMX
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Crafting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Crafting", "esMX")
if not L then return end

-- L["AH"] = ""
-- L["All"] = ""
-- L["A loop was detected in the mat cost of %s. Please correct this in your settings. This is typically caused by having 'crafting' in the custom price of two mats which can be crafted into each other."] = ""
-- L["Always Buy from AH"] = ""
-- L["A minimum profit of 0g is not allowed."] = ""
-- L["Are you sure you want to reset all material prices to the default value?"] = ""
-- L["Are you sure you want to reset the 'Default Craft Value Method' back to the default value?"] = ""
-- L["Are you sure you want to reset the 'Default Material Cost Method' back to the default value?"] = ""
-- L["Ask Later"] = ""
-- L["Auction House"] = ""
-- L["Bags"] = ""
--[==[ L[ [=[Below is a list of crafts that have been smartly added. You can configure what crafts are listed here in the "Cooldowns" tab of the "Crafting" page within the main TSM window. Quest items can be removed through the TSM crafting options.

Simply click on the row in the table below to craft it.]=] ] = "" ]==]
-- L["Buy From AH"] = ""
-- L["Buy From Vendor"] = ""
-- L["Buy Items"] = ""
-- L["Buy Vendor Items"] = ""
-- L["Can Craft At Least One, Profit, Craftable Quantity"] = ""
-- L[" (CD)"] = ""
-- L["|cffff0000[Filtered]|r "] = ""
-- L["Changes the scale of the profession frame."] = ""
--[==[ L[ [=[Changes the scale of the profession frame. 

Open the profession window to enable.]=] ] = "" ]==]
-- L["Characters"] = ""
-- L["Characters (Bags/Bank/AH/Mail) to Ignore:"] = ""
-- L["Clear Filters"] = ""
L["Clear Queue"] = "Limpiar cola."
-- L["Click here to restock the selected groups based on their Crafting operations."] = ""
-- L["Clicking this button will gather the required materials when you are at a valid source, the text of the button will change according to source."] = ""
-- L["Click this button to stop gathering and close the window."] = ""
-- L["Conversions"] = ""
-- L["Convert"] = ""
-- L["Cooldowns"] = ""
-- L["Cost"] = ""
-- L["Could not get link for profession."] = ""
-- L["Craftable"] = ""
-- L["Craftable Quantity, Profit"] = ""
-- L["Crafter"] = ""
-- L["Crafting can automatically prompt you to craft your cooldowns when you open the profession with the necessary materials on-hand or automatically add them to your queue if you don't have the necessary materials on-hand. Click on rows below to toggle this smart behavior on/off for your cooldowns."] = ""
-- L["Crafting can automatically prompt you to craft your quest required items when you open the profession with the necessary materials on-hand or automatically add them to your queue if you don't have the necessary materials on-hand."] = ""
-- L["Crafting Cost"] = ""
-- L["Crafting failed to scan your profession. Please close and re-open it to to allow Crafting to scan and provide pricing info for this profession."] = ""
-- L["Crafting Material Cost"] = ""
-- L["Crafting operations contain settings for restocking the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Crafting operation."] = ""
-- L["Crafting will not queue any items affected by this operation with a profit below this value. As an example, a min profit of 'max(10g, 10% crafting)' would ensure a profit of at least 10g or 10% of the craft cost, whichever is highest."] = ""
-- L["Craft Name"] = ""
L["Craft Next"] = "Crear siguiente"
-- L["Craft Queue"] = ""
L["Crafts"] = "Creaciones"
-- L["Craft Value Method"] = ""
-- L["Created profession group for %s."] = ""
-- L["Create Profession Groups"] = ""
-- L["Current Source"] = ""
-- L["Custom Price"] = ""
-- L["Custom Price for this item."] = ""
-- L["Custom Price per Item"] = ""
-- L["Default Craft Value Method"] = ""
-- L["Default Material Cost Method"] = ""
-- L["Default Price"] = ""
-- L["Default Price Settings"] = ""
-- L["Disable Crafting AH Search"] = ""
-- L["Disable DE Search"] = ""
-- L["Enable Smart Crafting for Quests"] = ""
-- L["Enchant Vellum"] = ""
--[==[ L[ [=[Estimated Cost: %s
Estimated Profit: %s]=] ] = "" ]==]
-- L["Even Stacks Only"] = ""
-- L["Exclude Crafts with a Cooldown from Craft Cost"] = ""
-- L["Filters >>"] = ""
-- L["Finished Gathering"] = ""
-- L["First select a crafter"] = ""
-- L["From "] = ""
-- L["Gather"] = ""
L["Gathering"] = "Recolección"
-- L["Gathering Crafting Mats"] = ""
-- L["Gather Items"] = ""
L["General"] = "General"
-- L["General Settings"] = ""
-- L["Guilds (Guild Banks) to Ignore:"] = ""
-- L["Have Mats"] = ""
-- L["Here, you can select which of your TSM groups you would like to restock based on their Crafting operations."] = ""
-- L["Here you can view and adjust how Crafting is calculating the price for this material."] = ""
-- L["Hide Queue"] = ""
-- L["Hold the left mouse button down and drag this handle to resize the window."] = ""
-- L["If checked, if there is more than one way to craft the item then the craft cost will exclude any craft with a daily cooldown when calculating the lowest craft cost."] = ""
-- L["If checked, only crafts which you can craft with items in your bags (ignoring vendor items) will be shown below."] = ""
-- L["If checked, the crafting cost of items will be shown in the tooltip for the item."] = ""
-- L["If checked, the material cost of items will be shown in the tooltip for the item."] = ""
-- L["If checked, the mats needed to craft an item and their prices will be shown in item tooltips."] = ""
-- L["If enabled, buying from AH will always be suggested even if you have enough via other sources. If disabled only short items will be searched for at the AH"] = ""
-- L["If enabled the crafting search at the Auction House will ignore Disenchantable Items."] = ""
-- L["If enabled the crafting search will only search for multiples of 5."] = ""
-- L["Ignore Alts"] = ""
-- L["Ignore Intermediate Crafting"] = ""
-- L["Ink Trader"] = ""
-- L["Intermediate Craft"] = ""
-- L["Intermediate Crafting"] = ""
L["Inventory Settings"] = "Configuración de Inventario"
-- L["Item Name"] = ""
L["Items will only be added to the queue if the number being added is greater than this number. This is useful if you don't want to bother with crafting singles for example."] = "Los objetos se agregaran a la cola solo si el número agregado es mayor que este número. Esto es utíl si no quieres molestarte en crear objetos en singular por ejemplo. " -- Needs review
-- L["Item Value"] = ""
-- L["Left-Click|r to add this craft to the queue."] = ""
-- L["Left click will set max quantity as quantity required"] = ""
-- L["Link"] = ""
-- L["List Mats in Tooltip"] = ""
-- L["Mail From "] = ""
-- L["Mailing Craft Mats to %s"] = ""
-- L["Mail Items"] = ""
-- L["Mail To "] = ""
-- L["Mat Cost"] = ""
-- L["Material Cost Options"] = ""
-- L["Material Name"] = ""
L["Materials"] = "Materiales"
-- L["Materials:"] = ""
-- L["Mat Price"] = ""
L["Max Restock Quantity"] = "Cantidad de Reposición maxima"
-- L["Minimum Profit"] = ""
L["Min Restock Quantity"] = "Cantidad de Reposición mínima"
L["Name"] = "Nombre"
L["Need"] = "Necesidad"
-- L["No Auctions found for %s"] = ""
-- L["No item specified. Usage: /tsm restock_help [ITEM_LINK]"] = ""
-- L["<None>"] = ""
-- L["None Found"] = ""
-- L["No Thanks"] = ""
-- L["Nothing to Gather"] = ""
-- L["Nothing To Gather"] = ""
-- L["Nothing to Mail"] = ""
-- L["Num Owned"] = ""
-- L["Once a crafter and profession(s) are selected, Click this button to start gathering."] = ""
-- L["Once a crafter is selected, you can use this dropdown to select the profession(s) you want to gather for."] = ""
-- L["Opens the Crafting window to the first profession."] = ""
-- L["Operation"] = ""
-- L["Override Default Craft Value Method"] = ""
-- L["Override global options for the session"] = ""
L["Percent to subtract from buyout when calculating profits (5% will compensate for AH cut)."] = "Porcentaje a extraer del precio "
-- L["Perform a manual AH search for this item"] = ""
-- L["Player"] = ""
-- L["Please switch to the Shopping Tab at the AH to perform the gathering search."] = ""
-- L["Please switch to the Shopping Tab to perform the gathering search."] = ""
-- L["Price:"] = ""
L["Price Settings"] = "Configuración de precios"
-- L["Price Source Filter"] = ""
-- L["Profession"] = ""
-- L["Profession Filter"] = ""
-- L["Profession Frame Scale"] = ""
-- L["Professions"] = ""
-- L["Professions Used In"] = ""
L["Profit"] = "Ganancia"
-- L["Profit, Craftable Quantity"] = ""
L["Profit Deduction"] = "Deducción de ganancia"
-- L["Profit (Total Profit):"] = ""
-- L["Prospect"] = ""
-- L["Queue"] = ""
-- L["Queue Increment"] = ""
-- L["Queue Sorting Method"] = ""
-- L["Ready"] = ""
-- L["Reset All Custom Prices to Default"] = ""
-- L["Reset all Custom Prices to Default Price Source."] = ""
-- L["Reset Craft Value Method to Default"] = ""
-- L["Reset Material Cost Method to Default"] = ""
-- L["Resets the material price for this item to the defualt value."] = ""
-- L["Reset the Craft Value Method to the default TSM value."] = ""
-- L["Reset the Material Cost Method to the default TSM value."] = ""
-- L["Reset to Default"] = ""
-- L["Restock help for %s:"] = ""
-- L["Restocking to a max of %d (min of %d) with a min profit."] = ""
-- L["Restocking to a max of %d (min of %d) with no min profit."] = ""
-- L["Restock Quantity Settings"] = ""
-- L["Restock Selected Groups"] = ""
-- L["Restock Settings"] = ""
-- L["Retrieve From "] = ""
-- L["Right-Click|r to subtract this craft from the queue."] = ""
-- L["Right click will search with no max quantity"] = ""
-- L["Search"] = ""
-- L["Selection"] = ""
-- L["Select one of your characters' professions to browse."] = ""
-- L["Select profession(s) and click start"] = ""
-- L["Set Minimum Profit"] = ""
-- L["Shift-Left-Click|r to queue all you can craft."] = ""
-- L["Shift-Right-Click|r to remove all from queue."] = ""
-- L["Show Crafting Cost in Tooltip"] = ""
-- L["Show Material Cost in Tooltip"] = ""
-- L["Show Queue"] = ""
-- L["'%s' is an invalid operation! Min restock of %d is higher than max restock of %d."] = ""
-- L["Skip Smart Crafts and Continue to Profession"] = ""
-- L["Smart"] = ""
-- L["Smart Crafts"] = ""
-- L["Sources"] = ""
-- L["%s (%s profit)"] = ""
-- L["Start Gathering"] = ""
L["Status"] = "Estado."
-- L["Stop Gathering"] = ""
-- L["Tells you why a specific item is not being restocked and added to the queue."] = ""
-- L["The 'Craft Value Method' (%s) did not return a value for this item. If it is based on some price database (AuctionDB, TSM_WoWuction, TUJ, etc), then ensure that you have scanned for or downloaded the data as appropriate."] = ""
-- L["The min profit (%s) did not evalulate to a valid value for this item."] = ""
-- L["The number which would be queued (%d) is less than the min restock quantity (%d)."] = ""
-- L["The operation applied to this item is invalid! Min restock of %d is higher than max restock of %d."] = ""
-- L["The profit of this item (%s) is below the min profit (%s)."] = ""
-- L["The queue will be sorted based on this option, from left to right."] = ""
-- L["There is a crafting cost and crafted item value, but TSM_Crafting wasn't able to calculate a profit. This shouldn't happen!"] = ""
-- L["There is no TSM_Crafting operation applied to this item's TSM group (%s)."] = ""
-- L["This area of the profession tab works similarly to the default profession UI, but with some added features. These include the ability to easily add crafts to your queue, listing profit next to crafts, and displaying inventory information."] = ""
-- L["This button will automatically create some simple TSM groups based on the current profession."] = ""
-- L["This button will switch to the default profession UI. You can switch back by clicking a 'TSM' button at the top of the default profession UI."] = ""
-- L["This button will switch to the default profession UI. You can switch back by clicking the 'TSM' button at the top of the default profession UI."] = ""
-- L["This displays the available sources for each item that is required, click a source to select or deselect that source. On opening the window, materials needed to be gathered from the crafter or have a single source are auto-selected"] = ""
-- L["This displays the tasks that you need to perform to gather the required materials from the selected sources."] = ""
-- L["This is the default method Crafting will use for determining material cost."] = ""
-- L["This is the default method Crafting will use for determining the value of crafted items."] = ""
-- L["This item does not have a crafting cost. Check that all of its mats have mat prices. If the mat prices are based on some price database (AuctionDB, TSM_WoWuction, TUJ, etc), then ensure that you have scanned for or downloaded the data as appropriate."] = ""
-- L["This item is not in a TSM group."] = ""
-- L["This item will be added to the queue when you restock its group. If this isn't happening, make a post on the TSM forums with a screenshot of the item's tooltip, operation settings, and your general TSM_Crafting options."] = ""
-- L["This slider sets the quantity to add/remove from the queue when left/right clicking on a row below."] = ""
-- L["Toggle to ignore gathering from Alts."] = ""
-- L["Toggle to ignore gathering from Alts and only gather from the crafter."] = ""
-- L["Toggle to ignore intermediate crafting."] = ""
-- L["Toggle to suggest trading inks at the vendor."] = ""
-- L["Toggle to switch between Crafting and Normal searches at the Auction House."] = ""
-- L["Toggle to switch between Crafting and Normal searches at the Auction House. A Crafting search will look for any disenchantable / prospectable / millable / craftable items that will provide the target item wheras a normal search will look just for the target item"] = ""
L["Total"] = "Total"
-- L["Trade Inks at the vendor"] = ""
-- L["Transform"] = ""
-- L["Transform Next"] = ""
-- L["TSM Groups"] = ""
-- L["Vendor"] = ""
-- L["Vendor Trade"] = ""
-- L["Visit Bank"] = ""
-- L["Visit Guild Vault"] = ""
-- L["Visit Mailbox"] = ""
-- L["Warning: The min restock quantity must be lower than the max restock quantity."] = ""
-- L["When you click on the \"Restock Queue\" button enough of each craft will be queued so that you have this maximum number on hand. For example, if you have 2 of item X on hand and you set this to 4, 2 more will be added to the craft queue."] = ""
-- L["Would you like to automatically create some TradeSkillMaster groups for this profession?"] = ""
-- L["You already have at least your max restock quantity of this item. You have %d and the max restock quantity is %d"] = ""
-- L["You can change the current tab of the profession frame, start gathering materials for your queue, and show the queue using these buttons."] = ""
-- L["You can click on one of the rows of the scrolling table below to view or adjust how the price of a material is calculated."] = ""
-- L["You can left/right click on a row to add/remove a craft from the crafting queue."] = ""
-- L["You can set the global default gathering options here, some of these can be overriden per gathering session."] = ""
-- L["You can use this dropdown to switch between crafters."] = ""
-- L["You can use this dropdown to switch between the current character's professions."] = ""
-- L["You don't know how to craft this item."] = ""
-- L["Your craft value method for '%s' was invalid so it has been returned to the default. Details: %s"] = ""
-- L["Your default craft value method was invalid so it has been returned to the default. Details: %s"] = ""