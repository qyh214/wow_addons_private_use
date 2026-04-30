-- [[ 自动购买 ]]
-- { Key = "ExTools.AutoBuy", Name = "自动购买", Desc = "在商人处自动购买预设或自定义的物品（如钥石地图、消耗品等）。", Category = 4 },

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local EXState = ExwindTools.State
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

-- 1. 识别 Key
local EXWIND_MODULE_KEY = "ExTools.AutoBuy"

-- 2. 载入检查
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- 3. 数据默认值与 DB 初始化
local EXWIND_DEFAULTS = {
    enabled = true,
    Items = {},       -- 存储 ID -> {enabled, quantity}
    CustomItems = {}, -- 存储 ID -> {enabled, quantity}
}
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)

-- 静态配置数据
local PRESET_ITEMS = {
    { id = 151060, buy = 1, cat = "map", name = "" },
    { id = 201344, buy = 5, cat = "map" }, { id = 159691, buy = 5, cat = "map" },
    { id = 201333, buy = 5, cat = "map" }, { id = 253009, buy = 5, cat = "map" },
    { id = 253012, buy = 5, cat = "map" }, { id = 252951, buy = 5, cat = "map" },
    { id = 252658, buy = 5, cat = "map" }, { id = 253010, buy = 5, cat = "map" },
    { id = 166381, buy = 5, cat = "key" }, { id = 166380, buy = 5, cat = "key" },
    { id = 166379, buy = 5, cat = "key" }, { id = 166378, buy = 5, cat = "key" },
    { id = 166377, buy = 5, cat = "key" }, { id = 159694, buy = 5, cat = "key" },
    { id = 159695, buy = 5, cat = "key" }, { id = 159696, buy = 5, cat = "key" },
    { id = 159697, buy = 5, cat = "key" }, { id = 159698, buy = 5, cat = "key" },
    { id = 243734, buy = 100, cat = "food" }, { id = 243738, buy = 100, cat = "food" },
    { id = 241326, buy = 200, cat = "food" }, { id = 241324, buy = 200, cat = "food" },
}

-- =========================================================
-- [v4.2] 注册与配置
-- =========================================================



-- 2. Grid 布局 (核心)
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 47, h = 3, label = L["自动购买 (Auto Buy)"], labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 47, h = 2, label = L["当打开商人界面时，自动购买背包中缺少的物品 (自动补齐到设置数量)"] },
        { key = "sub_add", type = "subheader", x = 1, y = 6, w = 47, h = 1, label = L["手动添加 (输入物品ID)"], labelSize = 20 },
        { key = "addID", type = "input", x = 1, y = 9, w = 18, h = 2, label = L["输入 ID"] },
        { key = "addItem", type = "button", x = 20, y = 9, w = 8, h = 2, label = L["添加"] },
        { key = "sub_c", type = "subheader", x = 1, y = 12, w = 47, h = 2, label = L["自定义购买列表 (支持拖拽添加)"], labelSize = 20 },
    }


    -- 问号框（添加位）始终固定在自定义列表开头
    table.insert(layout, {
        key = "new_item_drop",
        type = "itemconfig",
        itemID = 0,
        x = 1,
        y = 14,
        w = 35,
        h = 3
    })

    local y = 17.5

    -- 渲染自定义列表
    local customList = {}
    for id, _ in pairs(EX_DB.CustomItems) do table.insert(customList, tonumber(id)) end
    table.sort(customList)

    for _, id in ipairs(customList) do
        table.insert(layout, {
            key = id,
            parentKey = "CustomItems",
            subKey = id,
            type = "itemconfig",
            itemID = id,
            x = 1,
            y = y,
            w = 35,
            h = 3,
            canDelete = true, -- 显式启用删除按钮（上报事件模式）
            labelSize = 18
        })
        y = y + 3.5
    end

    y = y + 1
    table.insert(layout, { key = "sub_p", type = "subheader", x = 1, y = y, w = 47, h = 1, label = L["预设项目 (仅支持开启/禁用)"] })
    y = y + 2

    local cats = { { k = "food", n = L["消耗品"] }, { k = "key", n = L["钥石设置"] }, { k = "map", n = L["副本地图"] } }
    for _, cat in ipairs(cats) do
        -- [Core] 如果是 Key 或 Map 分类且当前不是 Beta 环境，则隐藏
        local isBetaOnly = (cat.k == "key" or cat.k == "map")
        local shouldShow = (not isBetaOnly) or ExwindTools.IsBeta

        if shouldShow then
            table.insert(layout,
                {
                    key = "t_" .. cat.k,
                    type = "description",
                    x = 1,
                    y = y,
                    w = 47,
                    h = 1,
                    label = "|cffffd100" .. cat.n ..
                        "|r"
                })
            y = y + 1.5
            for _, it in ipairs(PRESET_ITEMS) do
                if it.cat == cat.k then
                    if not EX_DB.Items[it.id] then EX_DB.Items[it.id] = { enabled = true, quantity = it.buy } end
                    table.insert(layout, {
                        key = it.id,
                        parentKey = "Items",
                        subKey = it.id,
                        type = "itemconfig",
                        itemID = it.id,
                        x = 1,
                        y = y,
                        w = 35,
                        h = 3,
                        canDelete = false, -- 预设项目不可删除
                        labelSize = 18
                    })
                    y = y + 3.5
                end
            end
            y = y + 1
        end
    end

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

-- 3. 立即注册
EX_RegisterLayout()

-- =========================================================
-- 逻辑绑定：通过事件处理添加与删除
-- =========================================================

-- 1. 处理按钮点击 (添加物品)
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(data)
    if data.key == "addItem" then
        local idStr = EX_DB.addID
        local id = tonumber(idStr)
        if id and id > 0 then
            EX_DB.CustomItems[id] = { enabled = true, quantity = 5 }
            EX_DB.addID = "" -- 清空
            EX_RegisterLayout()
            ExwindTools.UI:RefreshContent()
        end
    end
end)

-- 2. 处理 ItemConfig 组件上报的删除事件
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ItemConfigDelete", EXWIND_MODULE_KEY, function(data)
    local id = tonumber(data.key)
    if id and EX_DB.CustomItems[id] then
        EX_DB.CustomItems[id] = nil
        EX_RegisterLayout()
        ExwindTools.UI:RefreshContent()
    end
end)

-- 3. 处理 ItemConfig 组件上报的拖拽更新事件（用于新项目添加）
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ItemConfigUpdate", EXWIND_MODULE_KEY, function(data)
    if data.key == "new_item_drop" then
        local newItemID = tonumber(data.itemID)
        if newItemID and newItemID > 0 then
            EX_DB.CustomItems[newItemID] = { enabled = true, quantity = 5 }
            EX_RegisterLayout()
            ExwindTools.UI:RefreshContent()
        end
    end
end)

local function GetCount(id)
    local c = 0
    local maxBagIndex = 4
    if Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag then
        maxBagIndex = Enum.BagIndex.ReagentBag
    else
        maxBagIndex = 5
    end

    for b = 0, maxBagIndex do
        for s = 1, C_Container.GetContainerNumSlots(b) do
            local inf = C_Container.GetContainerItemInfo(b, s)
            if inf and inf.itemID == id then c = c + inf.stackCount end
        end
    end
    return c
end

local function DoBuy(id, target)
    local have = GetCount(id)
    local need = target - have
    if need <= 0 then return end

    local num = GetMerchantNumItems()
    for i = 1, num do
        if GetMerchantItemID(i) == id then
            local _, _, _, _, _, _, _, stack = C_Item.GetItemInfo(id)
            stack = stack or 1
            while need > 0 do
                local buy = math.min(stack, need)
                BuyMerchantItem(i, buy)
                need = need - buy
            end
            return
        end
    end
end

ExwindTools:RegisterEvent("MERCHANT_SHOW", EXWIND_MODULE_KEY, function()
    -- 预设
    for id, data in pairs(EX_DB.Items) do
        if data.enabled then DoBuy(tonumber(id), tonumber(data.quantity) or 5) end
    end
    -- 自定义
    for id, data in pairs(EX_DB.CustomItems) do
        if data.enabled then DoBuy(tonumber(id), tonumber(data.quantity) or 5) end
    end
end)

-- 报告模块加载完成
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
