-- ------------------------------------------------------------------------------ --
--                          TradeSkillMaster_Warehousing                          --
--          http://www.curse.com/addons/wow/tradeskillmaster_warehousing          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Warehousing Locale - zhCN
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Warehousing/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Warehousing", "zhCN")
if not L then return end
L["Canceled"] = "已取消"
-- L["Deposit Reagents"] = ""
L["Displays realtime move data."] = "显示移动实时信息。"
L["Empty Bags"] = "清空背包"
L["Enable Restock"] = "开启补货"
L["Enable this to set the quantity to keep back in your bags"] = "激活后设置物品的背包最小保有量"
L["Enable this to set the quantity to keep back in your bank / guildbank"] = "激活后设置物品的银行/公会银行最小保有量"
L["Enable this to set the quantity to move, if disabled Warehousing will move all of the item"] = "激活后设置物品的移动数量，如果不激活将以最大数量移动物品。"
L["Enable this to set the restock quantity"] = "激活后设置补货数量"
-- L["Enable this to set the stack size multiple to be moved"] = ""
L["General"] = "常规"
L["Gets items from the bank or guild bank matching the itemstring, itemID or partial text entered."] = "根据物品链接, 物品ID或输入的部分文本从银行/公会银行提取物品"
L["Invalid criteria entered."] = "无效的标准输入。"
L["Keep in Bags Quantity"] = "背包保有数量"
L["Keep in Bank/GuildBank Quantity"] = "银行/公会银行保有数量"
-- L["Lists the groups with warehousing operations. Left click to select/deselect the group, Right click to expand/collapse the group."] = ""
L["Move Data has been turned off"] = "移动数据已经关闭"
L["Move Data has been turned on"] = "移动数据已经开启"
L["Move Group to Bags"] = "将队列移动至背包" -- Needs review
L["Move Group to Bank"] = "将队列移动至银行" -- Needs review
L["Move Quantity"] = "移动数量"
L["Move Quantity Settings"] = "移动数量设置"
L["Nothing to Move"] = "没有物品用以移动"
L["Nothing to Restock"] = "没有物品用以补货"
L["Preparing to Move"] = "准备移动中"
L["Puts items matching the itemstring, itemID or partial text entered into the bank or guild bank."] = "根据物品链接, 物品ID或输入的部分文本向银行/公会银行存放物品。"
L["Restock Bags"] = "背包补货"
L["Restocking"] = "补货中"
L["Restock Quantity"] = "补货数量"
L["Restock Settings"] = "补货设置"
L["Restore Bags"] = "背包补货"
L["Set Keep in Bags Quantity"] = "设置物品的背包保有量"
L["Set Keep in Bank Quantity"] = "设置物品的银行保有量"
L["Set Move Quantity"] = "设置移动数量"
-- L["Set Stack Size for bags"] = ""
L["'%s' has a Warehousing operation of '%s' which no longer exists."] = "'%s'具有一个已经不存在的Warehousing操作'%s'"
-- L["Stack Size Multiple"] = ""
L["There are no visible banks."] = "没有打开的银行"
-- L["These will toggle between the module specific tabs."] = ""
-- L["This button will deposit all reagents to your reagent bank (if unlocked)."] = ""
-- L["This button will de-select all groups."] = ""
-- L["This button will empty the contents of your bags and move them all to the bank. It will remember what you moved so that you can use the restore button to put them back"] = ""
-- L["This button will move all items in the selected groups using the operation restock settings from the bank to your bags."] = ""
-- L["This button will move items in the selected groups from the bank to your bags."] = ""
-- L["This button will move items in the selected groups from your bags to the bank."] = ""
-- L["This button will restore the items to your bags from the last time you clicked empty bags."] = ""
-- L["This button will select all groups."] = ""
L["Warehousing operations contain settings for moving the items in a group. Type the name of the new operation into the box below and hit 'enter' to create a new Warehousing operation."] = "Warehousing操作包括移动分组物品的设置. 在下边的文本框中输入新操作的名称并回车可以创建一个新Warehousing操作。"
L["Warehousing will ensure this number remain in your bags when moving items to the bank / guildbank."] = "当移动物品到你的银行/公会银行中时,Warehousing会确保此数量的物品保留在你的背包中。"
L["Warehousing will ensure this number remain in your bank / guildbank when moving items to your bags."] = "当移动物品到你的背包中时,Warehousing会确保此数量的物品保留在你的银行/公会银行中。"
-- L["Warehousing will ensure this number remain in your bank / guildbank when restocking items to your bags."] = ""
L["Warehousing will move all of the items in this group."] = "Warehousing会移动这个分组内的所有物品"
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank."] = "Warehousing会移动这个分组的所有物品, 当从背包→银行/公会银行时每种物品保留%d件。"
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "Warehousing会移动这个分组的所有物品, 当从背包→银行/公会银行时每种物品保留%d件, 当从银行/公会银行→背包时每种物品保留%d件。"
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组的所有物品, 当从背包→银行/公会银行时每种物品保留%d件, 当从银行/公会银行→背包时每种物品保留%d件。补货会在背包里保留%d件物品。"
L["Warehousing will move all of the items in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组的所有物品, 当从背包→银行/公会银行时每种物品保留%d。补货会在背包里保留%d件物品。"
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags."] = "Warehousing会移动这个分组的所有物品, 当从银行/公会银行→背包时每种物品保留%d件。"
L["Warehousing will move all of the items in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组的所有物品, 当从银行/公会银行→背包时每种物品保留%d件. 补货会在背包里保留%d件物品。"
L["Warehousing will move all of the items in this group. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组的所有物品. 补货会在背包里保留%d件物品."
L["Warehousing will move a max of %d of each item in this group."] = "Warehousing会移动这个分组中每种物品最多%d件。"
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank."] = "Warehousing会移动这个分组中每种物品最多%d件, 当从背包→银行/公会银行时每种物品保留%d件。"
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags."] = "Warehousing会移动这个分组中每种物品最多%d件, 当从背包→银行/公会银行时每种物品保留%d件, 当从银行/公会银行→背包时每种物品保留%d件。"
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank, %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组中每种物品最多%d件, 当从背包→银行/公会银行时每种物品保留%d件, 当从银行/公会银行→背包时每种物品保留%d件. 补货会保留%d件物品在你的背包里。"
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bags > bank/gbank. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组中每种物品最多%d件, 当从背包→银行/公会银行时每种物品保留%d件. 补货会保留%d件物品在你的背包里。"
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags."] = "Warehousing会移动这个分组中每种物品最多%d件, 当从银行/公会银行→背包时每种物品保留%d件。"
L["Warehousing will move a max of %d of each item in this group keeping %d of each item back when bank/gbank > bags. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组中每种物品最多%d件, 当从银行/公会银行→背包时每种物品保留%d件。补货会保留%d件物品在背包里。"
L["Warehousing will move a max of %d of each item in this group. Restock will maintain %d items in your bags."] = "Warehousing会移动这个分组中每种物品最多%d件。补货会保留%d件物品在背包里。"
L["Warehousing will move this number of each item"] = "Warehousing会移动此数量的物品"
-- L["Warehousing will only move items in multiples of the stack size set when moving to your bags, this is useful for milling/prospecting etc to ensure you don't move items you can't process"] = ""
L["Warehousing will restock your bags up to this number of items"] = "Warehousing会向你的背包中补充这个数量的物品"
