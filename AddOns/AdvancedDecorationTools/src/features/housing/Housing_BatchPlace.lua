-- Housing_BatchPlace.lua
-- 仅包含“按住 Ctrl 批量放置”核心逻辑

local ADDON_NAME, ADT = ...
local L = ADT.L

local PaintMode = CreateFrame("Frame")
ADT.PaintMode = PaintMode

-- Global APIs
local C_HousingBasicMode = C_HousingBasicMode
local C_HousingCatalog = C_HousingCatalog

-- State
-- 使用 recordID 作为“单一权威”，避免直接复用 entryID（结构表在某些情况下可能失效）
PaintMode.lastPlacedRecordID = nil

-- Paint Mode Logic: If Ctrl is held when placing, continue placing same item
function PaintMode:OnDecorPlaced(decorGUID, size, isNew, isPreview)
    -- 读取开关：仅当用户在“通用”里勾选了“按住CTRL以批量放置”时才启用
    local enabled = ADT and ADT.GetDBValue and ADT.GetDBValue('EnableBatchPlace')
    -- 优先从事件参数反查 decorID，避免依赖 StartPlacing 钩子
    local eventRID = nil
    if decorGUID and C_HousingDecor and C_HousingDecor.GetDecorInstanceInfoForGUID then
        local info = C_HousingDecor.GetDecorInstanceInfoForGUID(decorGUID)
        eventRID = info and info.decorID or nil
    end
    if ADT and ADT.DebugPrint then ADT.DebugPrint("[PaintMode] PLACE_SUCCESS: enabled="..tostring(enabled)..", ctrl="..tostring(IsControlKeyDown())..", lastRID="..tostring(self.lastPlacedRecordID)..", eventRID="..tostring(eventRID)..", isNew="..tostring(isNew)..", isPreview="..tostring(isPreview)) end
    if not enabled then return end

    if not IsControlKeyDown() then return end
    local rid = eventRID or self.lastPlacedRecordID
    if not rid then if ADT and ADT.DebugPrint then ADT.DebugPrint("[PaintMode] skip: no recordID (both event and last are nil)") end return end

    -- 通过 Housing 核心的统一入口按 recordID 重新开始放置，更稳妥
    C_Timer.After(0.05, function()
        if ADT and ADT.Housing and ADT.Housing.StartPlacingByRecordID then
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[PaintMode] ReStart by recordID="..tostring(rid)) end
            ADT.Housing:StartPlacingByRecordID(rid)
        end
    end)
end

-- Hook StartPlacing to capture EntryID
local function ExtractRecordIDFromEntry(entryID)
    if type(entryID) == "table" and entryID.recordID then
        return entryID.recordID
    end
    -- 有些路径传入的是 HousingCatalogEntryID（非表），需要反查
    if C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfo then
        local info = C_HousingCatalog.GetCatalogEntryInfo(entryID)
        if info and info.recordID then
            return info.recordID
        end
    end
    return nil
end

hooksecurefunc(C_HousingBasicMode, "StartPlacingNewDecor", function(entryID)
    local rid = ExtractRecordIDFromEntry(entryID)
    PaintMode.lastPlacedRecordID = rid
    if ADT and ADT.DebugPrint then ADT.DebugPrint("[PaintMode] Capture StartPlacing(New): recordID="..tostring(rid)) end
end)

-- 兼容从商城/预览列表进入放置的路径
if C_HousingBasicMode and C_HousingBasicMode.StartPlacingPreviewDecor then
    hooksecurefunc(C_HousingBasicMode, "StartPlacingPreviewDecor", function(decorRecordID)
        PaintMode.lastPlacedRecordID = decorRecordID
        if ADT and ADT.DebugPrint then ADT.DebugPrint("[PaintMode] Capture StartPlacing(Preview): recordID="..tostring(decorRecordID)) end
    end)
end

PaintMode:SetScript("OnEvent", function(self, event, ...)
    if event == "HOUSING_DECOR_PLACE_SUCCESS" then
        self:OnDecorPlaced(...)
    end
end)

PaintMode:RegisterEvent("HOUSING_DECOR_PLACE_SUCCESS")
