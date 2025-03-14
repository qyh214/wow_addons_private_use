---@class BigFootSync
local BigFootSync = select(2, ...)
BigFootSync.tradingPost = {}

---@class TradingPost
local TP = BigFootSync.tradingPost

if BigFootSync.isRetail then
    local GetCurrencyAmount = C_PerksProgram.GetCurrencyAmount
    function TP.UpdateTradingPostCurrency(t)
        t["amount"] = GetCurrencyAmount()
    end

    local GetVendorItemInfo = C_PerksProgram.GetVendorItemInfo
    local GetAvailableVendorItemIDs = C_PerksProgram.GetAvailableVendorItemIDs
    local knownItems = {}
    function TP.UpdateTradingPostKnownItems()
        for _, id in pairs(GetAvailableVendorItemIDs()) do
            local known = GetVendorItemInfo(id).purchased
            if known then
                knownItems[id] = true
            else
                knownItems[id] = nil
            end
        end
    end

    function TP.SaveTradingPostKnownItems(t)
        local result = ""
        for id in pairs(knownItems) do
            if result ~= "" then
                result = result .. ","
            end
            result = result .. id
        end
        t["knownItems"] = result
    end
else
    function TP.UpdateTradingPostCurrency(t) end
    function TP.UpdateTradingPostKnownItems(t) end
    function TP.SaveTradingPostKnownItems(t) end
end