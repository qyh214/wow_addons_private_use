-- ------------------------------------------------------------------------------ --
--                           TradeSkillMaster_Accounting                          --
--           http://www.curse.com/addons/wow/tradeskillmaster_accounting          --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- TradeSkillMaster_Accounting Locale - ruRU
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_Accounting/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_Accounting", "ruRU")
if not L then return end

L["Accounting has not yet collected enough information for this tab. This is likely due to not having recorded enough data points or not seeing any significant fluctuations (over 1k gold) in your gold on hand."] = "Модуль Accounting не смог собрать достаточное количество информации для отображения. Причиной может стать недостаточное количество информации или недостаток золота (более 1000) в наличии." -- Needs review
L["Activity Type"] = "Вид активности"
L["All"] = "Все"
L["Amount"] = "Кол-во" -- Needs review
L["Aucs"] = "Аукционы"
L["Average Prices:"] = "Средняя цена:"
L["Avg Buy"] = "Средняя покупка" -- Needs review
L["Avg Buy Price"] = "Средн. цена выкупа"
L["Avg Resale Profit"] = "Средняя прибыль" -- Needs review
L["Avg Sale"] = "Средняя продажа" -- Needs review
L["Avg Sell Price"] = "Средн. цена продажи"
L["Back to Previous Page"] = "Назад к пред. странице"
L["Balance"] = "Баланс"
L[ [=[Below is a graph of the your character's gold on hand over time.

The x-axis is time and goes from %s to %s
The y-axis is thousands of gold.]=] ] = [=[Ниже расположен график количества золота, которым располагают ваши персонажи.

Ось x представляет временной промежуток от %s до %s
Ось у представляет количество золота (в тысячах)]=] -- Needs review
L["Bought"] = "Куплено"
L["Buyer/Seller"] = "Покупатель/продавец"
L["Cancelled"] = "Отменено"
L["Cancelled Since Last Sale:"] = "Отменено с последней продажи:"
-- L["|cffff0000IMPORTANT:|r When TSM_Accounting last saved data for this realm, it was too big for WoW to handle, so old data was automatically trimmed in order to avoid corruption of the saved variables. The last %s of %s data has been preserved."] = ""
L["Character/Guild to Graph"] = "График персонажа/гильдии" -- Needs review
L["Character to Graph"] = "Персонаж" -- Needs review
L["Clear Old Data"] = "Очистить старые данные"
L["Click for a detailed report on this item."] = "Нажмите для вывода подробного отчета об этом товаре."
L["Click this button to permanently remove data older than the number of days selected in the dropdown."] = "Нажмите эту кнопку для безвозвратного удаления данных, которые старше чем выбранное число дней."
L["Data older than this many days will be deleted when you click on the button to the right."] = "Данные, которые старше чем выбранное число дней, будут удалены при нажатии кнопки справа."
L["Days:"] = "Дни:"
L["DD/MM/YY HH:MM"] = "ДД/ММ/ГГ ЧЧ:ММ"
L["Display Grey Items in Sales"] = "Отображать продажу серых вещей"
L["Display Money Transfers"] = "Учитывать передачу золота" -- Needs review
-- L["Don't Prompt to Record Trades"] = ""
L["Earned Per Day:"] = "Заработано за день" -- Needs review
L["Expenses"] = "Расходы"
L["Expired"] = "Не продано"
L["Expired Since Last Sale:"] = "Прошло время с последней продажи:"
L["Failed Auctions"] = "Несостоявшиеся аукционы"
L["Failed Since Last Sale"] = "Не удалось продать" -- Needs review
L["Failed Since Last Sale (Expired/Cancelled):"] = "Несостоявшиеся с последней продажи (Истекло время/Отмененные):"
L["General Options"] = "Общие настройки"
L["Gold Earned:"] = "Получено золота:" -- Needs review
L["Gold Spent:"] = "Потрачено золота:"
L["Group"] = "Группа"
L["_ Hr _ Min ago"] = "_ ч _ мин назад"
L["If checked, Money Transfers will be included in income / expense and summary. Accounting will still track these if disabled but will not show them."] = "Если выбрано, то передача золота будет считаться получением/тратой. Данные будут учитываться в любом случае, но не будут отображаться." -- Needs review
L["If checked, poor quality items will be shown in sales data. They will still be included in gold earned totals on the summary tab regardless of this setting"] = "Показывать предметы низкого качества в данных о продажах. Они всё равно будут включены итоговое количество полученного золота в сводке."
L["If checked, the average purchase price that shows in the tooltip will be the average price for the most recent X you have purchased, where X is the number you have in your bags / bank / guild vault. Otherwise, a simple average of all purchases will be used."] = "Если выбрано, то средняя цена покупки отображаемая в подсказке будет представлять собой цену покупки последних Х товаров, где Х - количество предметов, которыми вы располагаете в сумках/банке/хранилище гильдии. Иными словами - средняя цена всех покупок." -- Needs review
L["If checked, the number of cancelled auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of cancelled auctions will be shown."] = "Показывать число отмененных аукционов с последней продажи как неудачные. Если продаж небыло, то отмененные аукционы показаны не будут."
L["If checked, the number of expired auctions since the last sale will show as up as failed auctions in an item's tooltip. if no sales then the total number of expired auctions will be shown."] = "Показывать число просроченных аукционов с последней продажи как неудачные. Если продаж небыло, то просроченные аукционы показаны не будут."
L[ [=[If checked, the number you have purchased and the average purchase price will show up in an item's tooltip.

Note: Vendor purchases will not be shown.]=] ] = [=[Если выбрано, то в подсказке будет отображаться количество купленных товаров и их средняя цена.

Важно: покупки у торговца не учитываются.]=] -- Needs review
L[ [=[If checked, the number you have sold and the average sale price will show up in an item's tooltip.

Note: Vendor sales will not be shown.]=] ] = [=[Если выбрано, то в подсказке будет отображаться количество проданных товаров и их средняя цена.

Важно: продажи торговцу не учитываются.]=] -- Needs review
L["If checked, the sale rate will be shown in item tooltips. sale rate is calculated as total sold / (total sold + total expired + total cancelled)."] = "Показывать цену продажи во всплывающей подсказке. Цена расчитывается: всего продано / (всего продано + всего истекших + всего отменено)."
L["If checked, whenever you buy or sell any quantity of a single item via trade, Accounting will display a popup asking if you want it to record that transaction."] = "Показывать всплывающее окно с подтверждением о покупке/продаже предметов."
L["If checked, you won't get a popup confirmation about whether or not to track trades."] = "Не получать окно с подтверждением об отслеживании сделки."
L["Item Name"] = "Название товара"
L["Items"] = "Товары"
L["Items/Resale Price Format"] = "Формат цены товаров/перепродажи"
L["Last %d Days"] = "За %d дней" -- Needs review
L["Last Purchased:"] = "Последняя покупка:"
L["Last Sold:"] = "Последняя продажа:"
L["Market Value"] = "Рыночная стоимость" -- Needs review
L["Market Value Source"] = "Откуда брать рыночную стоимость" -- Needs review
L["Max Buy Price"] = "Макс. цена покупки" -- Needs review
L["Max Sell Price"] = "Макс. цена продажи" -- Needs review
L["Min Buy Price"] = "Мин. цена покупки" -- Needs review
L["Min Sell Price"] = "Мин. цена продажи" -- Needs review
L["MM/DD/YY HH:MM"] = "ММ/ДД/ГГ ЧЧ:ММ"
L["none"] = "без фильтра"
L["None"] = "Всё"
L["Other Income"] = "Другие доходы"
L["Other Player"] = "Другой игрок" -- Needs review
L["Per Item"] = "За штуку" -- Needs review
L["Player"] = "Персонаж"
L["Player Gold"] = "Золото персонажа"
L["Profit:"] = "Получено:"
L["Profit Per Day:"] = "Получено в день:"
L["Purchase Data"] = "Данные покупки"
L["Purchased (Min/Avg/Max Price):"] = "Куплено (мин/сред/макс цена):" -- Needs review
L["Purchased (Total Price):"] = "Куплено (общая цена):"
L["Purchases"] = "Покупки"
L["Quantity"] = "Кол-во" -- Needs review
L["Quantity Bought:"] = "Число покупок:"
L["Quantity Sold:"] = "Число продаж:"
L["Rarity"] = "Качество"
L["Removed a total of %s old records and %s items with no remaining records."] = "Всего удалено %s старых записей и %s товаров без оставшихся записей."
L["Removed record."] = "Запись удалена." -- Needs review
L["Remove Old Data (No Confirmation)"] = "Удалить старые данные (БЕЗ подтверждения)"
L["Resale"] = "Перепродажа"
L["Revenue"] = "Доход"
L["%s ago"] = "%s назад"
L["Sale Data"] = "Данные продажи"
L["Sale Rate:"] = "Рейтинг продаж:"
L["Sales"] = "Продажи"
L["Search"] = "Поиск"
L["Select how you would like prices to be shown in the \"Items\" and \"Resale\" tabs; either average price per item or total value."] = "Выберите какую цену отображать во вкладках \"Товары\" и \"Перепродажа\": среднюю цену за товар или общую стоимость."
L["Select what format Accounting should use to display times in applicable screens."] = "Выберите формат отображения времени."
L["Select where you want Accounting to get market value info from to show in applicable screens."] = "Выберите, откуда брать информацию о рыночной стоимости." -- Needs review
L["Shift-Right-Click to delete this record."] = "Shift-ПКМ чтобы удалить запись." -- Needs review
L["Show cancelled auctions since last sale in item tooltips"] = "Показывать отменённые аукционы после последней продажи в подсказке." -- Needs review
L["Show expired auctions since last sale in item tooltips"] = "Показывать просроченные аукционы после последней продажи в подсказке." -- Needs review
L["Show purchase info in item tooltips"] = "Информация о покупках товара в подсказке"
L["Show sale info in item tooltips"] = "Информация о продажах товара в подсказке"
L["Show Sale Rate in item tooltips"] = "Показать рейтинг продаж во всплывающей подсказке"
L["Sold"] = "Продано"
L["Sold (Min/Avg/Max Price):"] = "Продано (мин/сред/макс цена):" -- Needs review
L["Sold (Total Price):"] = "Продано (общая цена):"
L["Source"] = "Источник"
L["Spent Per Day:"] = "Потрачено в день:"
L["Stack"] = "Количество"
L["Summary"] = "Итого"
L["Sum of All Characters/Guilds"] = "Общее количество по всем персонажам/гильдиям" -- Needs review
L["There is no purchase data for this item."] = "Нет данных о покупке этого товара."
L["There is no sale data for this item."] = "Нет данных о продаже этого товара."
L["Time"] = "Время"
L["Time Format"] = "Формат времени"
L["Timeframe (Days)"] = "Временной промежуток (в днях)" -- Needs review
L["Timeframe Filter"] = "Фильтр сроков"
L["Today"] = "Сегодня"
L["Top Buyers:"] = "Лучшие покупатели:" -- Needs review
L["Top Expense by Gold / Quantity:"] = "Наивысшая трата по Золоту/Кол-ву" -- Needs review
L["Top Income by Gold / Quantity:"] = "Наивысшая прибыль по Золоту/Кол-ву" -- Needs review
L["Top Item by Gold / Quantity:"] = "Наивысшая предмет по Золоту/Кол-ву" -- Needs review
L["Top Sellers:"] = "Лучшие продавцы:" -- Needs review
L["Total:"] = "Всего:"
L["Total Buy"] = "Всего куплено" -- Needs review
L["Total Buy Price"] = "Общая цена покупки"
L["Total Price"] = "Общая цена"
L["Total Sale"] = "Всего продано" -- Needs review
L["Total Sale Price"] = "Общая цена продажи"
L["Total Spent:"] = "Всего потрачено:"
L["Total Value"] = "Общая стоимость"
L["Track Sales/Purchases via Trade"] = "Отслеживать Продажи/Покупки через Обмен" -- Needs review
L["TSM_Accounting detected that you just traded %s %s in return for %s. Would you like Accounting to store a record of this trade?"] = "TSM_Accounting обнаружил, что вы торгуете %s %s в обмен на %s. Хотите сохранить запись этой операции?"
L["Type"] = "Тип"
-- L["Use Smart Average for Purchase Price"] = ""
L["Yesterday"] = "Вчера"
L[ [=[You can use the options below to clear old data. It is recommened to occasionally clear your old data to keep Accounting running smoothly. Select the minimum number of days old to be removed in the dropdown, then click the button.

NOTE: There is no confirmation.]=] ] = [=[Используйте настройки ниже для очистки устаревших данных. Рекомендуется время от времени очищать старые данные, чтобы модуль Accounting работал правильно. Выберите минимальное число дней, данные старше которого будут удалены в списке, затем нажмите кнопку.

ВНИМАНИЕ: действие без подтверждения.]=]
L["YY/MM/DD HH:MM"] = "ГГ/ММ/ДД ЧЧ:ММ"
 