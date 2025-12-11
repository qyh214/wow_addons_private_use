-- Housing_Recent.lua：最近放置记录（ADT 独立实现）
-- 放置历史记录核心逻辑：捕获放置、存储历史、快速重新放置
local ADDON_NAME, ADT = ...
local L = ADT.L or {}

local History = CreateFrame("Frame")
ADT.History = History

-- 常量
local MAX_HISTORY = 10

-- 获取历史列表
function History:GetAll()
    local db = ADT.GetDBValue("PlacementHistory")
    if type(db) ~= "table" then
        db = {}
        ADT.SetDBValue("PlacementHistory", db)
    end
    return db
end

-- 添加记录到历史（FIFO，去重）
function History:Add(decorID, name, icon)
    if not decorID then return end
    local list = self:GetAll()
    
    -- 去重：如果已存在，先移除旧的
    for i = #list, 1, -1 do
        if list[i].decorID == decorID then
            table.remove(list, i)
        end
    end
    
    -- 插入到头部
    table.insert(list, 1, {
        decorID = decorID,
        name = name or ((ADT.L and ADT.L['Unknown Decor']) or '未知装饰'),
        icon = icon or 134400, -- 默认问号图标
    })
    
    -- 限制最大数量
    while #list > MAX_HISTORY do
        table.remove(list)
    end
    
    ADT.SetDBValue("PlacementHistory", list)
    
    -- 通知 UI 刷新
    if self.OnHistoryChanged then
        self:OnHistoryChanged()
    end
end

-- 清空历史
function History:Clear()
    ADT.SetDBValue("PlacementHistory", {})
    if self.OnHistoryChanged then
        self:OnHistoryChanged()
    end
end

-- 从历史：进入“悬停放置”状态（不立即落地）。
function History:StartPlacing(decorID)
    if not decorID then return false end
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
    if not entryInfo or not entryInfo.entryID then
        if ADT and ADT.Notify then ADT.Notify((ADT.L and ADT.L['Cannot Place Decor']) or '无法放置该装饰（可能已用完或未拥有）', 'error') end
        return false
    end
    -- 关键点：延后一小段时间再开始放置，避免与点击列表同一鼠标事件重叠，
    -- 导致客户端把这次点击当作“确认落地”。
    C_Timer.After(0.05, function()
        if C_HouseEditor and C_HouseEditor.IsHouseEditorActive and C_HouseEditor.IsHouseEditorActive() then
            C_HousingBasicMode.StartPlacingNewDecor(entryInfo.entryID)
        else
            if ADT and ADT.Notify then ADT.Notify(ADT.L["Enter editor then choose history"], 'info') end
        end
    end)
    return true
end

-- 从历史：快速落地（保留该能力，后续可能做成高级选项/快捷操作）。
function History:QuickPlaceAtCursor(decorID)
    if not decorID then return false end
    local entryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, decorID, true)
    if not entryInfo or not entryInfo.entryID then
        if ADT and ADT.Notify then ADT.Notify((ADT.L and ADT.L['Cannot Place Decor']) or '无法放置该装饰（可能已用完或未拥有）', 'error') end
        return false
    end
    -- 进入放置后，下一帧尝试直接确认（如果客户端支持）。
    C_HousingBasicMode.StartPlacingNewDecor(entryInfo.entryID)
    C_Timer.After(0, function()
        if C_HousingBasicMode.FinishPlacingNewDecor then
            pcall(C_HousingBasicMode.FinishPlacingNewDecor)
        end
    end)
    return true
end

-- 安全地从 entryID 表获取装饰信息并记录
local function SafeRecordPlacement(entryID)
    if not entryID then return end
    
    -- entryID 本身就是一个表，包含 recordID
    local recordID = entryID.recordID
    if not recordID then return end
    
    -- 优先用 recordID 反查完整信息；当库存为 0 时，entry 查询可能为空
    local info = C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, recordID, true)
                    or C_HousingCatalog.GetCatalogEntryInfo(entryID)
    if info then
        local iconPath = info.iconTexture or info.iconAtlas or 134400
        History:Add(recordID, info.name, iconPath)
    else
        History:Add(recordID, (string.format((ADT.L and ADT.L['Decor #%d']) or '装饰 #%d', recordID)), 134400)
    end
end

-- 仅记录“开始放置”的 entryID，真正写入历史延后到“放置成功”事件
local lastStartedEntryID = nil

hooksecurefunc(C_HousingBasicMode, "StartPlacingNewDecor", function(entryID)
    lastStartedEntryID = entryID
end)

History:SetScript("OnEvent", function(self, event, ...)
    if event == "HOUSING_DECOR_PLACE_SUCCESS" then
        if lastStartedEntryID then
            SafeRecordPlacement(lastStartedEntryID)
            lastStartedEntryID = nil
        end
    end
end)

History:RegisterEvent("HOUSING_DECOR_PLACE_SUCCESS")

-- 调试：打印历史
function History:DebugPrint()
    local list = self:GetAll()
    if ADT and ADT.DebugPrint then ADT.DebugPrint("放置历史 (" .. #list .. " 条):") end
    for i, item in ipairs(list) do
        if ADT and ADT.DebugPrint then ADT.DebugPrint(string.format("  %d. %s (ID: %d)", i, item.name, item.decorID)) end
    end
end

-- 初始化消息
if ADT and ADT.DebugPrint then ADT.DebugPrint("放置历史模块已加载。在 /adt 控制中心的‘最近放置’分类查看。") end
