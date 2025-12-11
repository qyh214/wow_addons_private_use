-- Housing_AdvancedTools.lua：高级编辑工具（ADT 独立实现）
-- 目标：虚拟多选 + 同步移动/旋转/缩放（最小可用版本）
-- 思路：
-- 1) 维护“选集”（decorGUID 集合）与一个“锚点” decorGUID。
-- 2) 当玩家在专家模式下对锚点做精确微调时，hook 记录每一次增量（以及当前旋转轴状态）。
-- 3) 发生 Commit 时，把这段“增量脚本”重放到选集内其他对象：逐个选中 → 同步轴状态 → 依次触发相同的增量 → 提交。
-- 限制：住房 API 不提供绝对位置/角度/缩放的读写，因此采用“增量重放”的绕弯方式。

local ADDON_NAME, ADT = ...

-- 快速别名（保持单一权威，不做别名链式兜底）
local C_HousingDecor = C_HousingDecor
local C_HousingExpertMode = C_HousingExpertMode
local C_HousingBasicMode = C_HousingBasicMode
local C_HouseEditor = C_HouseEditor

local GetAllPlacedDecor = C_HousingDecor and C_HousingDecor.GetAllPlacedDecor
local GetHoveredDecorInfo_Expert = C_HousingExpertMode and C_HousingExpertMode.GetHoveredDecorInfo
local GetHoveredDecorInfo_Basic = C_HousingBasicMode and C_HousingBasicMode.GetHoveredDecorInfo
local GetSelectedDecorInfo_Expert = C_HousingExpertMode and C_HousingExpertMode.GetSelectedDecorInfo
local GetSelectedDecorInfo_Basic = C_HousingBasicMode and C_HousingBasicMode.GetSelectedDecorInfo

local SetSelectedByGUID = C_HousingDecor and C_HousingDecor.SetPlacedDecorEntrySelected
local CommitMovement_Expert = C_HousingExpertMode and C_HousingExpertMode.CommitDecorMovement

local SetIncActive = C_HousingExpertMode and C_HousingExpertMode.SetPrecisionIncrementingActive
local SetAxisActive = C_HousingExpertMode and C_HousingExpertMode.SetPrecisionIncrementRotationAxisActive

local IsEditorActive = C_HouseEditor and C_HouseEditor.IsHouseEditorActive

local HousingIncrementType = Enum and Enum.HousingIncrementType
local HousingPrecisionAxis = Enum and Enum.HousingPrecisionAxis

-- 模块对象
local M = CreateFrame("Frame")
ADT.AdvancedEdit = M

-- 状态：选集与锚点
M.selectionList = {}          -- 有序列表：{ guid1, guid2, ... }
M.selectionSet = {}           -- 快速查询：set[guid] = true
M.anchorGUID = nil            -- 当前锚点 guid

-- 录制缓冲
M.recordingEnabled = false    -- 是否启用本模块
M.isReplaying = false         -- 重放保护，避免递归
M.opBuffer = {}               -- { {op="inc", t=Enum.HousingIncrementType}, ... }
M.axisState = { X=false, Y=false, Z=false } -- 当前旋转轴状态

-- 工具：校验编辑器状态
local function InHouseEditor()
    return IsEditorActive and IsEditorActive() or false
end

local function EnsureAPIs()
    return SetSelectedByGUID and CommitMovement_Expert and SetIncActive and SetAxisActive
end

-- 工具：获取“悬停/选中”的 decorGUID（优先专家模式）
local function TryGetHoveredGUID()
    local info
    if GetHoveredDecorInfo_Expert then
        info = GetHoveredDecorInfo_Expert()
    end
    if (not info or not info.decorGUID) and GetHoveredDecorInfo_Basic then
        info = GetHoveredDecorInfo_Basic()
    end
    return info and info.decorGUID
end

local function TryGetSelectedGUID()
    local info
    if GetSelectedDecorInfo_Expert then
        info = GetSelectedDecorInfo_Expert()
    end
    if (not info or not info.decorGUID) and GetSelectedDecorInfo_Basic then
        info = GetSelectedDecorInfo_Basic()
    end
    return info and info.decorGUID
end

-- 选集操作
function M:ClearSelection()
    wipe(self.selectionList)
    wipe(self.selectionSet)
end

local function IndexOf(list, value)
    for i, v in ipairs(list) do
        if v == value then return i end
    end
end

function M:AddGUID(guid)
    if not guid then return end
    if not self.selectionSet[guid] then
        table.insert(self.selectionList, guid)
        self.selectionSet[guid] = true
        print("ADT: 已加入选集", guid)
    else
        print("ADT: 该对象已在选集", guid)
    end
end

function M:RemoveGUID(guid)
    if not guid then return end
    if self.selectionSet[guid] then
        self.selectionSet[guid] = nil
        local idx = IndexOf(self.selectionList, guid)
        if idx then table.remove(self.selectionList, idx) end
        print("ADT: 已移出选集", guid)
    end
end

function M:ToggleHovered()
    if not (self.recordingEnabled and InHouseEditor()) then return end
    local guid = TryGetHoveredGUID()
    if not guid then
        print("ADT: 未检测到悬停装饰")
        return
    end
    if self.selectionSet[guid] then
        self:RemoveGUID(guid)
    else
        self:AddGUID(guid)
    end
end

function M:SetAnchorByHovered()
    if not (self.recordingEnabled and InHouseEditor()) then return end
    local guid = TryGetHoveredGUID()
    if not guid then
        print("ADT: 未检测到悬停装饰，无法设为锚点")
        return
    end
    self.anchorGUID = guid
    print("ADT: 锚点已设为悬停对象", guid)
end

function M:SetAnchorBySelected()
    if not (self.recordingEnabled and InHouseEditor()) then return end
    local guid = TryGetSelectedGUID()
    if not guid then
        print("ADT: 当前未选中装饰，无法设为锚点")
        return
    end
    self.anchorGUID = guid
    print("ADT: 锚点已设为当前选中", guid)
end

-- 录制：hook 专家模式的增量与轴状态
local function OnSetAxis(axis, active)
    local self = M
    if not (self.recordingEnabled and not self.isReplaying) then return end
    -- 仅在锚点被选中时记录
    if TryGetSelectedGUID() ~= self.anchorGUID then return end
    if axis == HousingPrecisionAxis.X then
        self.axisState.X = not not active
    elseif axis == HousingPrecisionAxis.Y then
        self.axisState.Y = not not active
    elseif axis == HousingPrecisionAxis.Z then
        self.axisState.Z = not not active
    end
end

local function OnSetInc(incrementType, active)
    local self = M
    if not (self.recordingEnabled and not self.isReplaying) then return end
    -- 只记录“按下”（active=true）事件，避免重复
    if not active then return end
    if TryGetSelectedGUID() ~= self.anchorGUID then return end
    table.insert(self.opBuffer, { op = "inc", t = incrementType })
end

-- 重放到非锚点对象
function M:ReplayOpsTo(guid)
    if not guid or guid == self.anchorGUID then return end
    -- 逐个选中对象
    pcall(SetSelectedByGUID, guid, true)

    -- 同步旋转轴可见状态
    for axisName, flag in pairs(self.axisState) do
        local axisEnum = (axisName == "X" and HousingPrecisionAxis.X)
            or (axisName == "Y" and HousingPrecisionAxis.Y)
            or (axisName == "Z" and HousingPrecisionAxis.Z)
        if axisEnum then
            pcall(SetAxisActive, axisEnum, flag)
        end
    end

    -- 依次触发所有增量（true→false）
    for i = 1, #self.opBuffer do
        local op = self.opBuffer[i]
        if op.op == "inc" and op.t then
            pcall(SetIncActive, op.t, true)
            pcall(SetIncActive, op.t, false)
        end
    end

    -- 提交
    pcall(CommitMovement_Expert)
end

-- 提交时机：由专家模式 Commit 触发把缓冲重放到其他对象
local function OnCommit()
    local self = M
    if not (self.recordingEnabled and not self.isReplaying) then return end
    -- 仅在锚点被选中时触发同步
    if TryGetSelectedGUID() ~= self.anchorGUID then return end
    if #self.opBuffer == 0 then return end

    self.isReplaying = true
    -- 记录原先的选中对象，稍后还原
    local prevSelected = TryGetSelectedGUID()

    -- 对选集内除锚点之外的所有 guid 重放
    for _, guid in ipairs(self.selectionList) do
        if guid ~= self.anchorGUID then
            self:ReplayOpsTo(guid)
        end
    end

    -- 还原选中为锚点
    if self.anchorGUID then
        pcall(SetSelectedByGUID, self.anchorGUID, true)
    elseif prevSelected then
        pcall(SetSelectedByGUID, prevSelected, true)
    end

    -- 清空本次缓冲
    wipe(self.opBuffer)
    self.isReplaying = false
    print("ADT: 批量同步完成（对象数：" .. tostring(#self.selectionList - (self.anchorGUID and 1 or 0)) .. ")")
end

-- 对外开关
function M:SetEnabled(state)
    local want = not not state
    if want == self.recordingEnabled then return end
    self.recordingEnabled = want
    if want then
        print("ADT: 虚拟多选已开启（设置锚点后，对锚点的精确微调将被录制并批量同步）")
    else
        print("ADT: 虚拟多选已关闭")
        wipe(self.opBuffer)
    end
end

function M:ToggleEnabled()
    self:SetEnabled(not self.recordingEnabled)
end

-- 安装 hook（一次性）
do
    if SetAxisActive then
        hooksecurefunc(C_HousingExpertMode, "SetPrecisionIncrementRotationAxisActive", OnSetAxis)
    end
    if SetIncActive then
        hooksecurefunc(C_HousingExpertMode, "SetPrecisionIncrementingActive", OnSetInc)
    end
    if CommitMovement_Expert then
        hooksecurefunc(C_HousingExpertMode, "CommitDecorMovement", OnCommit)
    end
end

-- Slash 命令（便于测试）
SLASH_ADTAE1 = "/adtae"
SlashCmdList["ADTAE"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "on" then M:SetEnabled(true) return end
    if msg == "off" then M:SetEnabled(false) return end
    if msg == "clear" then M:ClearSelection() print("ADT: 选集已清空") return end
    if msg == "anchorh" then M:SetAnchorByHovered() return end
    if msg == "anchors" then M:SetAnchorBySelected() return end
    if msg == "toggleh" then M:ToggleHovered() return end
    print("/adtae on|off|clear|anchorh|anchors|toggleh")
end
