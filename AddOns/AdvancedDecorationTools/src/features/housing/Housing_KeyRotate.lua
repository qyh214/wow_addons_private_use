-- Housing_KeyRotate.lua
-- 功能：为“基本模式”提供精确旋转热键（±90°），支持在预览/拖拽选中时一键旋转。
-- 设计：
-- - DRY：步进→度数换算完全复用 AutoRotate 的单一权威（GetStepForRID）。
-- - 主路径：Basic 模式调用 C_HousingBasicMode.RotateDecor(±1) 多次，次数=ceil(90/步进度)。
-- - 保护：需处于住宅编辑器，且当前有选中目标；否则提示。

local ADDON_NAME, ADT = ...
ADT = ADT or {}

local M = {}
ADT.RotateHotkey = M

-- 快速别名
local C_HouseEditor = C_HouseEditor
local C_HousingBasicMode = C_HousingBasicMode

-- 读取选中对象的 recordID（统一从 ADT.Housing 提供的单一权威接口获取）
local function GetSelectedRecordID()
    if not (ADT and ADT.Housing and ADT.Housing.GetSelectedDecorRecordIDAndName) then return nil end
    local rid = ADT.Housing:GetSelectedDecorRecordIDAndName()
    if type(rid) == 'number' then return rid end
    return nil
end

-- 获取当前对象的“旋转步进度”（度），优先使用 AutoRotate 的单一权威
local function GetStepDegrees(rid)
    if ADT and ADT.AutoRotate and ADT.AutoRotate.GetStepForRID then
        return tonumber(ADT.AutoRotate:GetStepForRID(rid)) or 15
    end
    -- 理论上不会走到这里；保底 15° 仅用于极端加载顺序异常
    return 15
end

-- 条件：处于编辑器 + 有选中（拖拽/预览或已选中）
local function IsReady()
    if not (C_HouseEditor and C_HouseEditor.IsHouseEditorActive and C_HouseEditor.IsHouseEditorActive()) then return false end
    if C_HousingBasicMode and C_HousingBasicMode.IsDecorSelected and C_HousingBasicMode.IsDecorSelected() then return true end
    -- 兼容：预览期同样允许旋转
    if C_HousingBasicMode and C_HousingBasicMode.IsPlacingNewDecor and C_HousingBasicMode.IsPlacingNewDecor() then return true end
    -- 若 Basic 不报告选中，也可能在 Expert/Customize 里选中；此时 Basic 旋转可能无效，因此直接返回 false
    return false
end

-- 主实现：按给定角度（正=顺时针，负=逆时针）旋转选中对象
function M:RotateSelectedByDegrees(deg)
    if type(deg) ~= 'number' or deg == 0 then return end
    if not IsReady() then
        if ADT and ADT.Notify then ADT.Notify(ADT.L and (ADT.L["Please select a decor to rotate"] or "请先抓起/选中一个装饰") or "请先抓起/选中一个装饰", 'info') end
        return
    end

    local rid = GetSelectedRecordID()
    local step = GetStepDegrees(rid)
    local sign = (deg >= 0) and 1 or -1
    local steps = math.floor((math.abs(deg) + (step/2)) / step)
    if steps <= 0 then steps = 1 end

    -- 为稳妥，逐步异步执行，避免同帧多次调用被忽略
    local token = math.random(1, 1e9)
    M._token = token
    local remaining = steps

    local function tick()
        if M._token ~= token then return end -- 外部抢占保护
        -- 再次确认仍在可旋转态
        if not IsReady() then
            C_Timer.After(0.05, tick)
            return
        end
        local ok = pcall(C_HousingBasicMode.RotateDecor, sign)
        remaining = remaining - 1
        if remaining > 0 then
            C_Timer.After(0.01, tick)
        end
    end

    tick()
end

-- 便捷别名（若后续需要直接调用）
function M:RotateLeft90()  self:RotateSelectedByDegrees(-90) end
function M:RotateRight90() self:RotateSelectedByDegrees(90)  end

