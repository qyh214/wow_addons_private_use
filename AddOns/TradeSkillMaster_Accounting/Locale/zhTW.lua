-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Accounting Locale - zhTW
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Accounting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Accounting", "zhTW")
if not L then return end

-- L["Accounting has not yet collected enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."] = ""
L["Activity Type"] = "動作" -- Needs review
L["All"] = "所有"
-- L["Amount"] = ""
L["Aucs"] = "拍賣疊數" -- Needs review
L["Average Prices:"] = "平均價格："
-- L["Avg Buy"] = ""
L["Avg Buy Price"] = "平均買入價格" -- Needs review
L["Avg Resale Profit"] = "平均倒賣利潤" -- Needs review
-- L["Avg Sale"] = ""
L["Avg Sell Price"] = "平均出售價格" -- Needs review
L["Back to Previous Page"] = "返回上一頁"
L["Balance"] = "賬戶結平" -- Needs review
--[==[ L[ [=[Below is a graph of the your character's gold on hand over time.

The x-axis is time and goes from %s to %s
The y-axis is thousands of gold.]=] ] = "" ]==]
L["Bought"] = "購買"
L["Buyer/Seller"] = "買家/賣家" -- Needs review
L["Cancelled"] = "已撤銷" -- Needs review
L["Cancelled Since Last Sale:"] = "上次售出后撤銷數量：" -- Needs review
-- L["|cffff0000IMPORTANT:|r When TSM_Accounting last saved data for this realm, it was too big for WoW to handle, so old data was automatically trimmed in order to avoid corruption of the saved variables. The last %s of %s data has been preserved."] = ""
-- L["Character/Guild to Graph"] = ""
-- L["Character to Graph"] = ""
L["Clear Old Data"] = "清除舊數據" -- Needs review
L["Click for a detailed report on this item."] = "點擊獲取該物品的詳細報告。" -- Needs review
L["Click this button to permanently remove data older than the number of days selected in the dropdown."] = "點擊該按紐將永久清除在下拉選單中選擇的天數之前的舊數據。" -- Needs review
L["Data older than this many days will be deleted when you click on the button to the right."] = "當你點擊右邊按紐時比該設定的天數更舊的數據將被刪除。" -- Needs review
L["Days:"] = "天數："
L["DD/MM/YY HH:MM"] = "日/月/年 時:分"
L["Display Grey Items in Sales"] = "在售出頁面顯示灰色物品" -- Needs review
-- L["Display Money Transfers"] = ""
-- L["Don't Prompt to Record Trades"] = ""
L["Earned Per Day:"] = "每日收入：" -- Needs review
L["Expenses"] = "開銷" -- Needs review
L["Expired"] = "已過期" -- Needs review
L["Expired Since Last Sale:"] = "上次售出后過期數量：" -- Needs review
L["Failed Auctions"] = "拍賣失敗" -- Needs review
-- L["Failed Since Last Sale"] = ""
L["Failed Since Last Sale (Expired/Cancelled):"] = "此次失敗（過期/撤銷）距上次售出：" -- Needs review
L["General Options"] = "一般設定"
L["Gold Earned:"] = "金幣收入：" -- Needs review
L["Gold Spent:"] = "金幣支出：" -- Needs review
L["Group"] = "分組" -- Needs review
L["_ Hr _ Min ago"] = "_ 小時 _ 分鐘之前"
-- L["If checked, Money Transfers will be included in income / expense and summary. Accounting will still track these if disabled but will not show them."] = ""
L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"] = "若勾選，低品質物品將顯示在售出數據中。不管是否勾選該設定，摘要中顯示的金幣收入總數都將包括低品質物品。" -- Needs review
-- L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / guild vault. Otherwise, a simple average of all purchases will be used."] = ""
L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."] = "若勾選，自上次售出之后撤銷的拍賣品數量將作為拍賣失敗數量顯示在滑鼠提示中。如果未曾售出，將顯示撤銷總數。" -- Needs review
L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."] = "若勾選，自上次售出之后過期的拍賣品數量將作為拍賣失敗數量顯示在滑鼠提示中。如果未曾售出，將顯示過期總數。" -- Needs review
--[==[ L[ [=[If checked, the number you have purchased and the average purchase price will show up in an item's tooltip.

Note: Vendor purchases will not be shown.]=] ] = "" ]==]
--[==[ L[ [=[If checked, the number you have sold and the average sale price will show up in an item's tooltip.

Note: Vendor sales will not be shown.]=] ] = "" ]==]
L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."] = "若勾選，售出率將顯示在物品的滑鼠提示中。售出率 = 總售出數量 / (總售出數量 + 總過期數量 + 總撤銷數量)。" -- Needs review
L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."] = "若勾選，無論你通過交易購買或售出任意數量的某物品，Accounting都將彈出一個對話框詢問你是否記錄該筆交易。" -- Needs review
L["If checked, you won't get a popup confirmation about whether or not to track trades."] = "若勾選，你將不會收到詢問你是否記錄交易的對話框。" -- Needs review
L["Item Name"] = "物品名稱"
L["Items"] = "物品"
L["Items/Resale Price Format"] = "物品/轉售價錢格式"
-- L["Last %d Days"] = ""
L["Last Purchased:"] = "最后購買：" -- Needs review
L["Last Sold:"] = "最後賣出："
L["Market Value"] = "市場價格"
L["Market Value Source"] = "市場價格來源"
-- L["Max Buy Price"] = ""
-- L["Max Sell Price"] = ""
-- L["Min Buy Price"] = ""
-- L["Min Sell Price"] = ""
L["MM/DD/YY HH:MM"] = "月/日/年 時:分"
L["none"] = "無"
L["None"] = "無" -- Needs review
L["Other Income"] = "其他收入" -- Needs review
-- L["Other Player"] = ""
-- L["Per Item"] = ""
L["Player"] = "玩家"
L["Player Gold"] = "玩家金幣" -- Needs review
L["Profit:"] = "利潤：" -- Needs review
L["Profit Per Day:"] = "每日利潤：" -- Needs review
L["Purchase Data"] = "購買數據"
-- L["Purchased (Min/Avg/Max Price):"] = ""
L["Purchased (Total Price):"] = "購入（合計價格）：" -- Needs review
L["Purchases"] = "購入"
L["Quantity"] = "數量"
L["Quantity Bought:"] = "購入數量：" -- Needs review
L["Quantity Sold:"] = "售出數量：" -- Needs review
L["Rarity"] = "稀有度" -- Needs review
L["Removed a total of %s old records and %s items with no remaining records."] = "共移除%s舊紀錄，%s物品沒有剩餘紀錄了。" -- Needs review
-- L["Removed record."] = ""
L["Remove Old Data (No Confirmation)"] = "移除舊數據（無確認）" -- Needs review
L["Resale"] = "倒賣" -- Needs review
L["Revenue"] = "收入" -- Needs review
L["%s ago"] = "%s 之前"
L["Sale Data"] = "售賣數據" -- Needs review
L["Sale Rate:"] = "售出率：" -- Needs review
L["Sales"] = "售出" -- Needs review
L["Search"] = "搜尋"
L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."] = "選擇你想在“物品”和“倒賣”標籤中如何顯示價格。可選每物品的平均價格或總價值。" -- Needs review
L["Select what format Accounting should use to display times in applicable screens."] = "選擇Accounting將使用何種格式在適當的介面中顯示物品。" -- Needs review
L["Select where you want Accounting to get market value info from to show in applicable screens."] = "選擇你想讓Accounting從何處取得市場價格訊息以顯示在適當介面。" -- Needs review
-- L["Shift-Right-Click to delete this record."] = ""
-- L["Show cancelled auctions since last sale in item tooltips"] = ""
-- L["Show expired auctions since last sale in item tooltips"] = ""
L["Show purchase info in item tooltips"] = "在物品的滑鼠提示顯示已購入訊息。" -- Needs review
L["Show sale info in item tooltips"] = "在物品的滑鼠提示顯示已售出訊息。" -- Needs review
L["Show Sale Rate in item tooltips"] = "在滑鼠提示中顯示售出率" -- Needs review
L["Sold"] = "賣出"
-- L["Sold (Min/Avg/Max Price):"] = ""
L["Sold (Total Price):"] = "售出（合計價格）：" -- Needs review
L["Source"] = "來源" -- Needs review
L["Spent Per Day:"] = "每日支出：" -- Needs review
L["Stack"] = "堆疊"
L["Summary"] = "摘要"
-- L["Sum of All Characters/Guilds"] = ""
L["There is no purchase data for this item."] = "沒有該物品的購入數據。" -- Needs review
L["There is no sale data for this item."] = "沒有該物品的售出數據。" -- Needs review
L["Time"] = "時間"
L["Time Format"] = "時間格式"
-- L["Timeframe (Days)"] = ""
L["Timeframe Filter"] = "時間過濾" -- Needs review
L["Today"] = "今天" -- Needs review
L["Top Buyers:"] = "最高買家：" -- Needs review
-- L["Top Expense by Gold / Quantity:"] = ""
-- L["Top Income by Gold / Quantity:"] = ""
-- L["Top Item by Gold / Quantity:"] = ""
L["Top Sellers:"] = "最高賣家：" -- Needs review
L["Total:"] = "全部："
-- L["Total Buy"] = ""
L["Total Buy Price"] = "總購買價"
L["Total Price"] = "總價"
-- L["Total Sale"] = ""
L["Total Sale Price"] = "總售價"
L["Total Spent:"] = "總花費："
L["Total Value"] = "總價值"
-- L["Track Sales/Purchases via Trade"] = ""
L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"] = "TSM_Accounting檢測到你剛剛和%s交易了%s，獲得%s。你想讓Accounting記錄這筆交易嗎？" -- Needs review
L["Type"] = "類型" -- Needs review
-- L["Use Smart Average for Purchase Price"] = ""
L["Yesterday"] = "昨天" -- Needs review
L[ [=[You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.

NOTE: There is no confirmation.]=] ] = [=[你可以使用下面的設定清除舊數據。建議你隔一段時間就清理一下舊數據以保持Accounting的流暢運行。在下拉選單中選擇一個清理數據的天數，然後點擊按紐。

注意：該操作不會彈出確認。]=] -- Needs review
L["YY/MM/DD HH:MM"] = "年/月/日 時:分"
 