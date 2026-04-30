-- =============================================================
-- [[ 队友打断监控 (CD条版) ]]
-- { Key = "ExM+.InterruptTracker", Name = "队友打断监控", Desc = "显示队友打断技能冷却状态（计时条样式）", Category = 2 },
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExM+.InterruptTracker"
local PartySpec = ExwindTools.PartySpec
local EXDB = _G.EXDB
local C_Spell = _G.C_Spell
local LSM = LibStub("LibSharedMedia-3.0")

-- 常用全局函数引用
local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local UnitNameFromGUID = _G.UnitNameFromGUID
local UnitClassFromGUID = _G.UnitClassFromGUID
local UnitExists = _G.UnitExists
local GetTime = _G.GetTime
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local C_Timer = _G.C_Timer
local wipe = _G.wipe
local date = _G.date
local GetLocale = _G.GetLocale
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local C_ClassColor = _G.C_ClassColor
local GetInstanceInfo = _G.GetInstanceInfo
local C_ChallengeMode = _G.C_ChallengeMode
local IsInRaid = _G.IsInRaid
local GetNumGroupMembers = _G.GetNumGroupMembers
local anchorFrame = nil
local isEditModeActive = false
local isEditModeVisible = true
local editModeRestore = nil
local editHandleFrame = nil

local function RefreshEditOverlay()
    if not editHandleFrame then return end

    if isEditModeActive and isEditModeVisible then
        ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY, editHandleFrame, { ownerFrame = anchorFrame })
    else
        ExwindTools:HideExwindToolsEditOverlay(editHandleFrame)
    end
end

-- 使用 EXDB.InterruptData
local SPEC_INTERRUPT_DB = EXDB.InterruptData

-- =============================================================
-- Grid 布局
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 53, h = 2, label = L["打断监控 (计时条)"], labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 53, h = 2, label = L["实时监控队友打断技能冷却状态（计时条样式）"] },
        { key = "div1", type = "divider", x = 1, y = 8, w = 53, h = 1, label = "--[[ Function ]]" },
        { key = "subheader_func", type = "subheader", x = 1, y = 7, w = 53, h = 1, label = L["通用设置"], labelSize = 20 },
        { key = "enabled", type = "checkbox", x = 1, y = 9, w = 6, h = 2, label = L["启用"] },
        { key = "locked", type = "checkbox", x = 10, y = 9, w = 8, h = 2, label = L["锁定位置"] },
        { key = "preview", type = "checkbox", x = 20, y = 9, w = 8, h = 2, label = L["预览模式"] },
        { key = "btn_reset_pos", type = "button", x = 30, y = 9, w = 14, h = 2, label = L["重置位置"] },
        { key = "posX", type = "slider", x = 19, y = 13, w = 14, h = 2, label = L["整体水平位置"], min = -1000, max = 1000 },
        { key = "posY", type = "slider", x = 36, y = 13, w = 14, h = 2, label = L["整体垂直位置"], min = -1000, max = 1000 },
        { key = "color_header", type = "header", x = 1, y = 29, w = 48, h = 2, label = L["计时条"], labelSize = 20 },
        { key = "spacing", type = "slider", x = 1, y = 34, w = 17, h = 2, label = L["垂直间距"], min = 0, max = 50 },
        { key = "growDirection", type = "dropdown", x = 21, y = 34, w = 15, h = 2, label = L["增长方向"], items = "向下,向上" },
        { key = "maxBars", type = "slider", x = 1, y = 37, w = 17, h = 2, label = L["最大显示数量"], min = 1, max = 15 },
        { key = "useClassColorBar", type = "checkbox", x = 21, y = 37, w = 15, h = 2, label = L["使用职业颜色"] },
        { key = "timerGroup", type = "timerBarGroup", x = 1, y = 40, w = 53, h = 26, label = L["计时条外观"], labelSize = 20 },
        { key = "font_name_header", type = "header", x = 1, y = 67, w = 53, h = 3, label = L["玩家名称"], labelSize = 20 },
        { key = "showPlayerName", type = "checkbox", x = 1, y = 72, w = 15, h = 2, label = L["显示玩家名字"] },
        { key = "nameAlign", type = "dropdown", x = 18, y = 72, w = 15, h = 2, label = L["名字对齐方式"], items = "LEFT,CENTER,RIGHT" },
        { key = "useClassColorName", type = "checkbox", x = 35, y = 72, w = 15, h = 2, label = L["使用职业颜色"] },
        { key = "font_name", type = "fontgroup", x = 1, y = 74, w = 53, h = 17, label = L["玩家名字文字设置"], labelSize = 20 },
        { key = "font_timer_header", type = "header", x = 1, y = 94, w = 53, h = 2, label = L["冷却时间设置"], labelSize = 20 },
        { key = "showTimer", type = "checkbox", x = 1, y = 98, w = 15, h = 2, label = L["显示剩余时间"] },
        { key = "showReadyText", type = "checkbox", x = 18, y = 98, w = 15, h = 2, label = L["冷却结束显示就绪"] },
        { key = "readyText", type = "input", x = 35, y = 98, w = 15, h = 2, label = L["就绪文字"] },
        { key = "font_timer", type = "fontgroup", x = 1, y = 100, w = 53, h = 18, label = L["时间文字设置"], labelSize = 20 },
        { key = "sort_header", type = "header", x = 1, y = 120, w = 53, h = 2, label = L["排序优先级"], labelSize = 20 },
        { key = "sort_desc", type = "description", x = 1, y = 123, w = 53, h = 2, label = L["CD就绪时按角色优先级排序，CD冷却中按剩余时间排序（时间短优先）"] },
        { key = "sortPriorityTank", type = "slider", x = 1, y = 126, w = 15, h = 2, label = L["坦克优先级"], min = 1, max = 3 },
        { key = "sortPriorityHealer", type = "slider", x = 19, y = 126, w = 15, h = 2, label = L["治疗优先级"], min = 1, max = 3 },
        { key = "sortPriorityDPS", type = "slider", x = 36, y = 126, w = 15, h = 2, label = L["DPS优先级"], min = 1, max = 3 },
        { key = "sortMeleeDPSFirst", type = "checkbox", x = 1, y = 129, w = 20, h = 2, label = L["近战DPS优先于远程DPS"] },
        { key = "attach_header", type = "header", x = 1, y = 16, w = 49, h = 2, label = L["依附小队框体"], labelSize = 20 },
        { key = "attach_desc", type = "description", x = 1, y = 19, w = 49, h = 1, label = L["启用后，打断条组将整体依附到小队框体的上方或下方"] },
        { key = "attachToRaidFrame", type = "checkbox", x = 1, y = 21, w = 15, h = 2, label = L["启用依附到小队框体"] },
        { key = "attachFrame", type = "dropdown", x = 36, y = 21, w = 14, h = 2, label = L["目标框架"], items = "无,DandersFrames,NDui,ElvUI,EQO小队框架,Grid2,暴雪原生框架" },
        { key = "attachPoint", type = "dropdown", x = 1, y = 25, w = 15, h = 2, label = L["依附到目标框架的"], items = "上方,下方" },
        { key = "attachOffsetX", type = "slider", x = 19, y = 25, w = 15, h = 2, label = L["水平偏移"], min = -150, max = 150 },
        { key = "attachOffsetY", type = "slider", x = 36, y = 25, w = 15, h = 2, label = L["垂直偏移"], min = -150, max = 150 },
        { key = "attachAutoWidth", type = "checkbox", x = 19, y = 21, w = 9, h = 2, label = L["自适应宽度"] },
    }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end
local EX_DEFAULTS = {
    enabled = true,
    font_name = {
        a = 1,
        align = "LEFT",
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowX = 1.6000003814697,
        shadowY = -0.69999885559082,
        size = 16,
        x = 2,
        y = 0,
    },
    font_timer = {
        a = 1,
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = false,
        shadowX = 1,
        shadowY = -1,
        size = 14,
        x = 0,
        y = 0,
    },
    growDirection = "向下",
    locked = true,
    maxBars = 5,
    nameAlign = "LEFT",
    pos = {
        "CENTER",
        "UIParent",
        "CENTER",
        0,
        -200,
    },
    posX = -592,
    posY = -52,
    preview = true,
    readyText = "准备",
    showPlayerName = true,
    showReadyText = false,
    showTimer = true,
    spacing = 1,
    timerGroup = {
        barBgColor = {
            a = 0.6,
            b = 0.1,
            g = 0.1,
            r = 0.1,
        },
        barBgColorA = 0.5,
        barBgColorB = 0,
        barBgColorG = 0,
        barBgColorR = 0,
        barColor = {
            a = 1,
            b = 0.5,
            g = 0.5,
            r = 0.5,
        },
        barColorA = 1,
        barColorB = 0.2,
        barColorG = 0.8,
        barColorR = 0.2,
        height = 24,
        iconOffsetX = -1,
        iconOffsetY = 0,
        iconSide = "LEFT",
        iconSize = 23,
        showIcon = true,
        texture = "Melli",
        width = 150,
    },
    useClassColorBar = true,
    useClassColorName = false,
    sortPriorityTank = 1, -- 坦克优先级最高
    sortPriorityHealer = 2, -- 治疗次之
    sortPriorityDPS = 3, -- DPS最低
    sortMeleeDPSFirst = false, -- 近战DPS不优先
    -- 依附小队框体
    attachToRaidFrame = false, -- 是否启用依附模式
    attachFrame = "无", -- 目标框架 (无/DandersFrames/NDui/ElvUI/EQO小队框架/Grid2)
    attachPoint = "上方", -- 依附位置: 上方/下方
    attachOffsetX = 0, -- 水平偏移
    attachOffsetY = 2, -- 垂直偏移
    attachAutoWidth = true, -- 自适应宽度 (匹配小队框体宽度)
    _attachFrameSetByUser = false, -- 内部标记：用户是否手动选择过目标框架
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)

-- =============================================================
-- 自动检测已加载的小队框体插件（仅在用户未手动设置时生效）
-- =============================================================
--- 延迟自动检测：在模块首次需要时调用（插件框架可能还未创建）
local attachFrameAutoDetectDone = false
local function AutoDetectAttachFrame()
    if attachFrameAutoDetectDone then return end
    attachFrameAutoDetectDone = true
    -- 用户已手动选择过，不覆盖
    if EX_DB._attachFrameSetByUser then return end
    -- 按优先级检测：DandersFrames > NDui > ElvUI > EQO小队框架 > Grid2 > 暴雪原生框架
    if _G.DandersFrames and _G.DandersFrames.Api then
        EX_DB.attachFrame = "DandersFrames"
    elseif _G.oUF_Party or (_G.NDui and C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("NDui")) then
        EX_DB.attachFrame = "NDui"
    elseif _G.ElvUI or (_G.ElvUF_PartyGroup1) then
        EX_DB.attachFrame = "ElvUI"
    elseif _G.EQOLUFPartyHeaderUnitButton1 or _G.EQOLUFPartyHeader then
        EX_DB.attachFrame = "EQO小队框架"
    elseif (_G.Grid2 and _G.Grid2.GetUnitFrames) or _G.Grid2LayoutFrame or _G.Grid2LayoutHeader1UnitButton1 then
        EX_DB.attachFrame = "Grid2"
    elseif _G.CompactPartyFrame then
        EX_DB.attachFrame = "暴雪原生框架"
    end
end

-- =============================================================
-- UI 框架系统
-- =============================================================
local activeBars = {}   -- [recordID] = { bar, guid, startTime, expireTime, duration, classFilename }
local usedBarsList = {} -- 有序列表，用于布局
local previewBars = {}  -- 预览模式条
local isPreviewing = false
local ExwindFactory = _G.ExwindFactory
local nextInterruptRecordID = 0
local INTERRUPT_RECORD_DURATION = 15
local INTERRUPT_RECORD_ICON = 132357
local interruptDebugEnabled = false
local isValidEnvironment = nil
local hasShownTemporaryNotice = false

local TEMP_NOTICE_EXPIRE = {
    year = 2026,
    month = 5,
    day = 5,
}

-- 前置声明局部函数，防止时序导致的 nil 错误
local UpdateLayout, ReLayout, RefreshAll, TogglePreview, CreateAnchor, CleanupExpiredRecords

local function IsSecretValue(value)
    return type(_G.issecretvalue) == "function" and _G.issecretvalue(value)
end

local function NormalizeSafeText(value)
    if value == nil or IsSecretValue(value) then
        return nil
    end
    local text = tostring(value)
    if text == "" then
        return nil
    end
    return text
end

local function DebugPrint(fmt, ...)
    if not interruptDebugEnabled then return end

    local msg = fmt
    if select("#", ...) > 0 then
        msg = string.format(fmt, ...)
    end

    print(string.format("|cff33ff99[ExInterruptDebug]|r %s", msg))
end

local function HideAllVisualsForEditMode()
    if anchorFrame then
        anchorFrame:Hide()
        anchorFrame:EnableMouse(false)
        if anchorFrame.bg then anchorFrame.bg:Hide() end
        if anchorFrame.label then anchorFrame.label:Hide() end
        ExwindTools:HideExwindToolsEditOverlay(anchorFrame)
    end

    for _, data in pairs(activeBars) do
        if data.bar then
            data.bar:Hide()
            data.bar:SetScript("OnUpdate", nil)
        end
    end

    for _, bar in ipairs(previewBars) do
        bar:Hide()
        bar:SetScript("OnUpdate", nil)
        ReleaseBar(bar)
    end
    wipe(previewBars)

    for _, bar in ipairs(usedBarsList) do
        if bar then
            bar:Hide()
            bar:SetScript("OnUpdate", nil)
        end
    end

    isPreviewing = false
end

local function PrintDebugSnapshot()
    local state = ExwindTools.State or {}
    local enemyNameplates = (_G.GetCVarBool and _G.GetCVarBool("nameplateShowEnemies")) and "开" or "关"
    DebugPrint("enabled=%s, preview=%s, env=%s, IsInParty=%s, InstanceType=%s, InMythicPlus=%s, 敌方姓名板=%s",
        tostring(EX_DB and EX_DB.enabled),
        tostring(isPreviewing),
        tostring(isValidEnvironment),
        tostring(state.IsInParty),
        tostring(state.InstanceType),
        tostring(state.InMythicPlus),
        enemyNameplates
    )
end

local function IsTemporaryNoticeExpired()
    if type(date) ~= "function" then return true end
    local now = date("*t")
    if not now then return true end

    if now.year ~= TEMP_NOTICE_EXPIRE.year then
        return now.year > TEMP_NOTICE_EXPIRE.year
    end
    if now.month ~= TEMP_NOTICE_EXPIRE.month then
        return now.month > TEMP_NOTICE_EXPIRE.month
    end
    return now.day > TEMP_NOTICE_EXPIRE.day
end

local function GetTemporaryNoticeMessage()
    local locale = GetLocale and GetLocale() or ""
    if locale == "zhCN" or locale == "zhTW" then
        return "|cffffcc00[EX公告]|r 由于12.0.5暴雪限制，打断监控已无法使用。目前透过一些方式先做一个试验性的平替版本。所有打断只能使用15秒倒数，无法根据职业去做改变（目前已有一些思路，后续会逐渐尝试）。此提示将在一周后移除。"
    end

    return "|cffffcc00[EX Notice]|r Due to Blizzard restrictions in 12.0.5, the interrupt tracker can no longer work as before. A temporary experimental replacement is currently in place. All interrupts now use a fixed 15-second countdown and cannot yet change based on class. Some possible approaches already exist, and we will continue testing improvements. This notice will be removed after one week."
end

local function ScheduleTemporaryNotice()
    if hasShownTemporaryNotice or IsTemporaryNoticeExpired() then return end
    hasShownTemporaryNotice = true

    C_Timer.After(5, function()
        if IsTemporaryNoticeExpired() then return end
        print(GetTemporaryNoticeMessage())
    end)
end

local function GetUnitSpecID(unit)
    local specID = 0
    if PartySpec then
        specID = PartySpec:GetSpec(unit)
    end

    if specID == 0 and unit == "player" then
        specID = GetSpecializationInfo(GetSpecialization() or 1)
    end

    return specID or 0
end

local function GetUnitInterruptSpellData(unit)
    local specID = GetUnitSpecID(unit)
    if specID == 0 then return nil, 0 end
    return SPEC_INTERRUPT_DB[specID], specID
end

-- =============================================================
-- 环境检测：只在队伍且5人副本内生效
-- =============================================================
--- 检测当前环境是否有效（队伍 + 5人副本）
local function CheckEnvironment()
    local state = ExwindTools.State
    local inParty = state.IsInParty or false
    local instanceType = state.InstanceType or "none"

    -- 必须在队伍中，且副本类型为 party (5人本)
    local shouldEnable = inParty and instanceType == "party"

    if shouldEnable ~= isValidEnvironment then
        isValidEnvironment = shouldEnable
        DebugPrint("环境切换: shouldEnable=%s, inParty=%s, instanceType=%s",
            tostring(shouldEnable), tostring(inParty), tostring(instanceType))

        if not shouldEnable then
            -- 环境无效，隐藏所有UI
            if anchorFrame then
                anchorFrame:Hide()
            end
            for guid, data in pairs(activeBars) do
                if data.bar then
                    data.bar:Hide()
                end
            end
        else
            -- 环境有效，恢复显示
            if EX_DB.enabled then
                UpdateLayout()
            end
        end
    end

    return shouldEnable
end

-- =============================================================
-- 依附到小队框体：多插件支持 (DandersFrames / NDui / ElvUI / EQO小队框架 / Grid2 / 暴雪原生框架)
-- =============================================================
local DandersFramesApi = nil    -- 延迟获取，避免加载顺序问题
local hookedAttachFrames = {}   -- 已 hook OnSizeChanged 的框架（所有插件共用）
local lastAttachUnitWidth = nil -- 上次单位框架宽度（用于检测变化）

--- 获取 DandersFrames API 引用（懒加载）
local function GetDandersFramesApi()
    if DandersFramesApi then return DandersFramesApi end
    if _G.DandersFrames and _G.DandersFrames.Api then
        DandersFramesApi = _G.DandersFrames.Api
    end
    return DandersFramesApi
end

--- 检测指定插件是否已加载
--- @param addonName string "DandersFrames"|"NDui"|"ElvUI"|"EQO小队框架"|"Grid2"|"暴雪原生框架"
--- @return boolean
local function IsAddonAvailable(addonName)
    if addonName == "DandersFrames" then
        return GetDandersFramesApi() ~= nil
    elseif addonName == "NDui" then
        return _G["oUF_Party"] ~= nil
    elseif addonName == "ElvUI" then
        return _G["ElvUF_PartyGroup1"] ~= nil
    elseif addonName == "EQO小队框架" then
        return _G["EQOLUFPartyHeader"] ~= nil or _G["EQOLUFPartyHeaderUnitButton1"] ~= nil
    elseif addonName == "Grid2" then
        return _G["Grid2LayoutFrame"] ~= nil or (_G.Grid2 and _G.Grid2.GetUnitFrames ~= nil)
    elseif addonName == "暴雪原生框架" then
        return _G["CompactPartyFrame"] ~= nil
    end
    return false
end

--- 收集 EQO 小队单位框架
--- @param includeHidden boolean|nil true=包含隐藏框架
--- @return table
local function CollectEQOPartyUnitFrames(includeHidden)
    local frames = {}
    for i = 1, 5 do
        local frame = _G["EQOLUFPartyHeaderUnitButton" .. i]
        if frame and (includeHidden or frame:IsVisible()) then
            frames[#frames + 1] = frame
        end
    end
    return frames
end

--- 收集 Grid2 小队单位框架
--- 优先使用 Grid2 API；若不可用则回退到命名规则：
--- Grid2LayoutHeaderNUnitButtonM
--- @param includeHidden boolean|nil true=包含隐藏框架
--- @return table
local function CollectGrid2PartyUnitFrames(includeHidden)
    local frames, seen = {}, {}
    local function Push(frame)
        if not frame or seen[frame] then return end
        if includeHidden or frame:IsVisible() then
            seen[frame] = true
            frames[#frames + 1] = frame
        end
    end

    local grid2 = _G.Grid2
    if grid2 and grid2.GetUnitFrames then
        local testUnits = { "player", "party1", "party2", "party3", "party4" }
        for _, unit in ipairs(testUnits) do
            local unitFrames = grid2:GetUnitFrames(unit)
            if type(unitFrames) == "table" then
                for frame in pairs(unitFrames) do
                    Push(frame)
                end
            end
        end
    end

    if #frames == 0 then
        for headerIndex = 1, 8 do
            for unitIndex = 1, 5 do
                Push(_G["Grid2LayoutHeader" .. headerIndex .. "UnitButton" .. unitIndex])
            end
        end
    end

    return frames
end

--- 判断依附模式是否可用（检查插件+队伍人数≤5）
local function IsAttachModeAvailable()
    if not EX_DB.attachToRaidFrame then return false end
    local frameName = EX_DB.attachFrame
    if not frameName or frameName == "无" then return false end

    -- 超过5人（团队）不启用依附模式
    if IsInRaid and IsInRaid() then return false end

    return IsAddonAvailable(frameName)
end

--- 获取小队框架 Header（根据选择的插件）
--- @return Frame|nil 队伍 Header 框架
local function GetAttachTargetFrame()
    local frameName = EX_DB.attachFrame
    if frameName == "DandersFrames" then
        return _G["DandersPartyHeader"]
    elseif frameName == "NDui" then
        return _G["oUF_Party"]
    elseif frameName == "ElvUI" then
        return _G["ElvUF_PartyGroup1"]
    elseif frameName == "EQO小队框架" then
        return _G["EQOLUFPartyHeader"] or _G["EQOLUFPartyHeaderUnitButton1"]
    elseif frameName == "Grid2" then
        local unitFrames = CollectGrid2PartyUnitFrames(false)
        if unitFrames[1] and unitFrames[1].GetParent then
            return unitFrames[1]:GetParent()
        end
        return _G["Grid2LayoutFrame"]
    elseif frameName == "暴雪原生框架" then
        return _G["CompactPartyFrame"]
    end
    return nil
end

--- 获取指定插件小队框架中第一个可见单位框架
--- @return Frame|nil 第一个可见的单位框架
local function GetFirstVisibleUnitFrame()
    local frameName = EX_DB.attachFrame
    if frameName == "DandersFrames" then
        local api = GetDandersFramesApi()
        if not api or not api.GetFrameForUnit then return nil end
        local testUnits = { "player", "party1", "party2", "party3", "party4" }
        for _, unit in ipairs(testUnits) do
            local frame = api.GetFrameForUnit(unit, "party")
            if frame and frame:IsVisible() then
                return frame
            end
        end
    elseif frameName == "NDui" then
        local header = _G["oUF_Party"]
        if not header then return nil end
        for i = 1, 5 do
            local child = header:GetAttribute("child" .. i)
            if child and child:IsVisible() then
                return child
            end
        end
    elseif frameName == "ElvUI" then
        local header = _G["ElvUF_PartyGroup1"]
        if not header then return nil end
        for i = 1, 5 do
            local child = header:GetAttribute("child" .. i)
            if child and child:IsVisible() then
                return child
            end
        end
    elseif frameName == "EQO小队框架" then
        local frames = CollectEQOPartyUnitFrames(false)
        return frames[1]
    elseif frameName == "Grid2" then
        local frames = CollectGrid2PartyUnitFrames(false)
        return frames[1]
    elseif frameName == "暴雪原生框架" then
        for i = 1, 5 do
            local child = _G["CompactPartyFrameMember" .. i]
            if child and child:IsVisible() then
                return child
            end
        end
    end
    return nil
end

--- 获取队伍框架中第一个可见单位框架的宽度（用于自适应宽度）
--- @return number|nil 单位框架宽度
local function GetAttachFrameUnitWidth()
    local frame = GetFirstVisibleUnitFrame()
    if not frame then return nil end
    local width = frame:GetWidth()
    -- DandersFrames 的单位框架宽度包含边框（默认1px每侧），需要扣除
    if EX_DB.attachFrame == "DandersFrames" then
        local dfObj = _G.DandersFrames
        local dfDB = dfObj and dfObj.GetDB and dfObj:GetDB()
        if dfDB and dfDB.showFrameBorder then
            width = width - 2 * (dfDB.borderSize or 1)
        end
    end
    return width
end

--- 获取视觉上最底部的可见队伍子框架（用于依附下方时定位）
--- oUF 框架（NDui/ElvUI）会按角色排序，child 索引顺序 ≠ 视觉位置，
--- 因此必须比较实际屏幕坐标来找到最底部的子框架。
--- @return Frame|nil 视觉最底部的可见子框架
local function GetLastVisiblePartyChild()
    local frameName = EX_DB.attachFrame
    local children = {}

    if frameName == "暴雪原生框架" then
        for i = 1, 5 do
            local child = _G["CompactPartyFrameMember" .. i]
            if child and child:IsVisible() then
                children[#children + 1] = child
            end
        end
    elseif frameName == "DandersFrames" then
        local header = _G["DandersPartyHeader"]
        if header then
            for i = 1, 5 do
                local child = header:GetAttribute("child" .. i)
                if child and child:IsVisible() then
                    children[#children + 1] = child
                end
            end
        end
    elseif frameName == "NDui" then
        local header = _G["oUF_Party"]
        if header then
            for i = 1, 5 do
                local child = header:GetAttribute("child" .. i)
                if child and child:IsVisible() then
                    children[#children + 1] = child
                end
            end
        end
    elseif frameName == "ElvUI" then
        local header = _G["ElvUF_PartyGroup1"]
        if header then
            for i = 1, 5 do
                local child = header:GetAttribute("child" .. i)
                if child and child:IsVisible() then
                    children[#children + 1] = child
                end
            end
        end
    elseif frameName == "EQO小队框架" then
        children = CollectEQOPartyUnitFrames(false)
    elseif frameName == "Grid2" then
        children = CollectGrid2PartyUnitFrames(false)
    end

    if #children == 0 then return nil end
    if #children == 1 then return children[1] end

    -- 找到视觉上最底部的子框架（屏幕 Y 坐标最低 = bottom 值最小）
    local bottomMost = children[1]
    local bottomMostY = select(2, bottomMost:GetCenter()) or 0
    for i = 2, #children do
        local cy = select(2, children[i]:GetCenter()) or 0
        if cy < bottomMostY then
            bottomMostY = cy
            bottomMost = children[i]
        end
    end
    return bottomMost
end

--- Hook 单位框架的 OnSizeChanged，实时响应宽度变化
--- 懒加载：仅在依附模式+自适应宽度启用时才 hook
local function HookAttachFramesSizeChanged()
    local frameName = EX_DB.attachFrame
    if not frameName or frameName == "无" then return end

    -- 收集需要 hook 的框架列表
    local frameList = {}
    if frameName == "DandersFrames" then
        local api = GetDandersFramesApi()
        if api and api.GetFrameForUnit then
            local testUnits = { "player", "party1", "party2", "party3", "party4" }
            for _, unit in ipairs(testUnits) do
                local frame = api.GetFrameForUnit(unit, "party")
                if frame then table.insert(frameList, frame) end
            end
        end
    elseif frameName == "NDui" then
        local header = _G["oUF_Party"]
        if header then
            for i = 1, 5 do
                local child = header:GetAttribute("child" .. i)
                if child then table.insert(frameList, child) end
            end
        end
    elseif frameName == "ElvUI" then
        local header = _G["ElvUF_PartyGroup1"]
        if header then
            for i = 1, 5 do
                local child = header:GetAttribute("child" .. i)
                if child then table.insert(frameList, child) end
            end
        end
    elseif frameName == "EQO小队框架" then
        frameList = CollectEQOPartyUnitFrames(true)
    elseif frameName == "Grid2" then
        frameList = CollectGrid2PartyUnitFrames(true)
    elseif frameName == "暴雪原生框架" then
        for i = 1, 5 do
            local child = _G["CompactPartyFrameMember" .. i]
            if child then table.insert(frameList, child) end
        end
    end

    -- Hook 每个框架的 OnSizeChanged
    for _, frame in ipairs(frameList) do
        if not hookedAttachFrames[frame] then
            hookedAttachFrames[frame] = true
            frame:HookScript("OnSizeChanged", function(self, w, h)
                if not IsAttachModeAvailable() or not EX_DB.attachAutoWidth then return end
                local roundedW = math.floor(w + 0.5)
                if lastAttachUnitWidth and lastAttachUnitWidth == roundedW then return end
                lastAttachUnitWidth = roundedW
                C_Timer.After(0, function()
                    if ReLayout then ReLayout() end
                end)
            end)
        end
    end
end

-- 创建锚点
CreateAnchor = function()
    if anchorFrame then return end
    anchorFrame = CreateFrame("Frame", "ExInterruptTrackerAnchor", UIParent)
    anchorFrame:SetSize(200, 20)
    anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
    anchorFrame:SetMovable(true)
    anchorFrame:SetClampedToScreen(true)
    anchorFrame:RegisterForDrag("LeftButton")

    anchorFrame.bg = anchorFrame:CreateTexture(nil, "BACKGROUND")
    anchorFrame.bg:SetAllPoints()
    anchorFrame.bg:SetColorTexture(0, 0.5, 0, 0.5)

    anchorFrame.label = anchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorFrame.label:SetPoint("CENTER")
    anchorFrame.label:SetText(L["打断监控 锚点"])
    anchorFrame.bg:Hide()
    anchorFrame.label:Hide()

    editHandleFrame = CreateFrame("Frame", nil, anchorFrame)
    editHandleFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
    editHandleFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT", 0, 0)
    editHandleFrame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMLEFT", 0, 0)
    editHandleFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 0, 0)

    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, anchorFrame)

    anchorFrame:SetScript("OnDragStart", function(self)
        if not EX_DB.locked then
            self:StartMoving()
        end
    end)

    anchorFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local cx, cy = UIParent:GetCenter()
        local sx, sy = self:GetCenter()
        if sx and cx then
            EX_DB.posX = math.floor(sx - cx)
            EX_DB.posY = math.floor(sy - cy)

            -- [v2.0 Fix] 不再刷新整个面板，避免滚动到顶端
            -- Grid引擎会自动同步slider值，无需手动RefreshContent
        end
    end)
end

-- 初始化计时条结构
local function InitCastBarStructure(bar)
    bar:SetClampedToScreen(true)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bar.bg = bg

    bar.Text = bar:CreateFontString(nil, "OVERLAY")
    bar.TargetNameText = bar:CreateFontString(nil, "OVERLAY")
    bar.TimerText = bar:CreateFontString(nil, "OVERLAY")
    bar.Icon = bar:CreateTexture(nil, "OVERLAY")
end

-- 初始化框架池
if ExwindFactory then
    ExwindFactory:InitPool("ExInterruptBar", "StatusBar", "BackdropTemplate", InitCastBarStructure)
end

-- 获取计时条
local function AcquireBar()
    if not ExwindFactory then return end
    local bar = ExwindFactory:Acquire("ExInterruptBar", anchorFrame)
    bar._isPreview = nil
    return bar
end

-- 释放计时条
local function ReleaseBar(bar)
    if not ExwindFactory or not bar then return end
    bar:SetScript("OnUpdate", nil)
    ExwindFactory:Release("ExInterruptBar", bar)
end

-- 应用计时条视觉
local function UpdateBarVisuals(bar)
    local db = EX_DB
    local group = db.timerGroup or {}

    -- 设置尺寸
    bar:SetSize(group.width or 200, group.height or 20)

    -- 设置材质 (fallback: LSM 找不到时用 Solid)
    local tex = LSM:Fetch("statusbar", group.texture or "Melli")
    if not tex then tex = LSM:Fetch("statusbar", "Solid") or "Interface\\Buttons\\WHITE8X8" end
    if bar.bg then
        bar.bg:SetTexture(tex)
        bar.bg:SetVertexColor(
            group.barBgColorR or 0,
            group.barBgColorG or 0,
            group.barBgColorB or 0,
            group.barBgColorA or 0.5
        )
    end
    bar:SetStatusBarTexture(tex)

    -- 如果不使用职业颜色，使用默认颜色
    if not db.useClassColorBar then
        bar:SetStatusBarColor(
            group.barColorR or 0.2,
            group.barColorG or 0.8,
            group.barColorB or 0.2,
            group.barColorA or 1
        )
    else
        -- 使用职业颜色 (StatusBar)
        local class
        if bar._isPreview then
            class = bar._previewClass
        elseif bar._classFilename then
            class = bar._classFilename
        elseif bar.unit then
            _, class = UnitClass(bar.unit)
        end
        if class then
            local okColor, color = pcall(C_ClassColor.GetClassColor, class)
            if okColor and color then
                bar:SetStatusBarColor(color.r, color.g, color.b, 1)
            end
        end
    end

    -- [Feature] 应用边框相关样式 (确保边框渲染于状态条前台)
    local edgeTex = group.showBorder and group.borderTexture and group.borderTexture ~= "None" and
        LSM:Fetch("border", group.borderTexture) or nil
    if edgeTex then
        if not bar.BorderFrame then
            bar.BorderFrame = CreateFrame("Frame", nil, bar, "BackdropTemplate")
            bar.BorderFrame:SetFrameLevel(bar:GetFrameLevel() + 2)
        end
        local edgeSize = group.borderSize or 12
        local pad = group.borderPadding or 0
        bar.BorderFrame:ClearAllPoints()
        bar.BorderFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -pad, pad)
        bar.BorderFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", pad, -pad)
        bar.BorderFrame:SetBackdrop({
            edgeFile = edgeTex,
            edgeSize = edgeSize,
        })
        local br, bg, bb, ba = group.borderColorR or 1, group.borderColorG or 1, group.borderColorB or 1,
            group.borderColorA or 1
        bar.BorderFrame:SetBackdropBorderColor(br, bg, bb, ba)
        bar.BorderFrame:Show()
    else
        if bar.BorderFrame then
            bar.BorderFrame:Hide()
        end
    end

    -- 应用字体组
    local StaticDB = ExwindTools.DB_Static

    -- 玩家名称 (原来的 Text)
    if bar.Text then
        StaticDB:ApplyFont(bar.Text, db.font_name)
        bar.Text:ClearAllPoints()
        bar.Text:SetPoint(db.nameAlign, bar, db.nameAlign, db.font_name.x, db.font_name.y)
        bar.Text:SetJustifyH(db.nameAlign)
        bar.Text:SetShown(db.showPlayerName)

        -- 职业颜色 (Text)
        if db.useClassColorName then
            local class
            if bar._isPreview then
                class = bar._previewClass
            elseif bar._classFilename then
                class = bar._classFilename
            elseif bar.unit then
                _, class = UnitClass(bar.unit)
            end
            if class then
                local okColor, color = pcall(C_ClassColor.GetClassColor, class)
                if okColor and color then
                    bar.Text:SetTextColor(color.r, color.g, color.b, 1)
                end
            end
        end
    end

    -- 冷却时间 (固定在最右边)
    if bar.TimerText then
        StaticDB:ApplyFont(bar.TimerText, db.font_timer)
        bar.TimerText:ClearAllPoints()
        bar.TimerText:SetPoint("RIGHT", bar, "RIGHT", db.font_timer.x, db.font_timer.y)
        bar.TimerText:SetJustifyH("RIGHT")
        bar.TimerText:SetShown(db.showTimer)
    end

    -- 隐藏原来的目标名字（不再使用）
    if bar.TargetNameText then
        bar.TargetNameText:Hide()
    end

    -- 图标
    if bar.Icon then
        bar.Icon:SetSize(group.iconSize or 20, group.iconSize or 20)
        bar.Icon:ClearAllPoints()
        local side = group.iconSide or "LEFT"
        if side == "LEFT" then
            bar.Icon:SetPoint("RIGHT", bar, "LEFT", group.iconOffsetX or 0, group.iconOffsetY or 0)
        else
            bar.Icon:SetPoint("LEFT", bar, "RIGHT", group.iconOffsetX or 0, group.iconOffsetY or 0)
        end
        bar.Icon:SetShown(group.showIcon)
        bar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
end

-- 获取专精的角色优先级
local function GetSpecPriority(unit)
    if not unit or not UnitExists(unit) then return 999 end

    local specID = GetUnitSpecID(unit)
    if not specID or specID == 0 then return 999 end

    local specData = SPEC_INTERRUPT_DB[specID]
    if not specData then return 999 end

    local role = specData.role or "DAMAGER"
    local db = EX_DB

    -- 基础优先级（根据角色）
    local basePriority =
        role == "TANK" and (db.sortPriorityTank or 1) or
        role == "HEALER" and (db.sortPriorityHealer or 2) or
        (db.sortPriorityDPS or 3)

    -- 近战DPS微调（如果开启）
    if role == "DAMAGER" and db.sortMeleeDPSFirst then
        -- 判断是否近战专精（根据EXDB.InterruptData中的专精ID）
        local meleeSpecs = {
            -- 战士: 71武器, 72狂暴
            [71] = true,
            [72] = true,
            -- 圣骑士: 70神圣, 66防护, 70惩戒
            [70] = true,
            -- 猎人: 无近战
            -- 盗贼: 全近战
            [259] = true,
            [260] = true,
            [261] = true,
            -- 牧师: 无近战
            -- 萨满: 263增强
            [263] = true,
            -- 法师: 无近战
            -- 术士: 无近战
            -- 武僧: 268酿酒, 269踏风
            [268] = true,
            [269] = true,
            -- 德鲁伊: 103野性
            [103] = true,
            -- 恶魔猎手: 全近战
            [577] = true,
            [581] = true,
            -- 死亡骑士: 全近战
            [250] = true,
            [251] = true,
            [252] = true,
        }

        if meleeSpecs[specID] then
            basePriority = basePriority - 0.5 -- 近战优先级提升0.5
        end
    end

    return basePriority
end

-- 排序函数：最新打断记录优先，剩余显示时间越长越靠前
local function SortBars()
    if isPreviewing then return end

    -- 将 activeBars 转换为可排序的列表
    local sortList = {}
    for recordID, data in pairs(activeBars) do
        if not data.attachFrame then
            table.insert(sortList, { recordID = recordID, data = data })
        end
    end

    -- 排序规则
    table.sort(sortList, function(a, b)
        if a.data.startTime ~= b.data.startTime then
            return a.data.startTime > b.data.startTime
        end

        if a.data.expireTime ~= b.data.expireTime then
            return a.data.expireTime > b.data.expireTime
        end

        return a.recordID > b.recordID
    end)

    -- 更新 usedBarsList
    wipe(usedBarsList)
    for _, item in ipairs(sortList) do
        table.insert(usedBarsList, item.data.bar)
    end
end

-- 重新布局所有条（统一逻辑：条始终堆叠在 anchorFrame 上，依附模式只改变 anchorFrame 的位置）
ReLayout = function()
    if not anchorFrame then return end

    -- 先排序
    if not isPreviewing then
        SortBars()
    end

    local group = EX_DB.timerGroup or {}
    local height = group.height or 20
    local spacing = EX_DB.spacing or 2
    local list = isPreviewing and previewBars or usedBarsList
    local growUp = (EX_DB.growDirection == "向上")
    local maxLimit = EX_DB.maxBars or 5
    local barWidth = group.width or 200
    local totalHeight = height

    local attachMode = IsAttachModeAvailable()
    local iconCenterShift = 0 -- 依附模式下图标导致的水平居中偏移

    -- 依附模式下的自适应宽度：匹配队伍框架中单位框架的宽度
    -- 目标：图标 + 打断条宽度 = 小队框体宽度，且整体居中对齐
    if attachMode and EX_DB.attachAutoWidth then
        local unitWidth = GetAttachFrameUnitWidth()
        if unitWidth then
            if group.showIcon then
                local iconSize = group.iconSize or 20
                local iconOffX = group.iconOffsetX or 0
                local side = group.iconSide or "LEFT"
                -- 图标实际占用宽度 = 图标尺寸 + 图标与条之间的间距
                -- LEFT: Icon.RIGHT = bar.LEFT + iconOffsetX → 占用 = iconSize - iconOffsetX
                -- RIGHT: Icon.LEFT = bar.RIGHT + iconOffsetX → 占用 = iconSize + iconOffsetX
                local iconOccupied
                if side == "LEFT" then
                    iconOccupied = iconSize - iconOffX
                else
                    iconOccupied = iconSize + iconOffX
                end
                if iconOccupied < 0 then iconOccupied = 0 end

                barWidth = unitWidth - iconOccupied
                if barWidth < 20 then barWidth = 20 end -- 最小宽度保护

                -- 计算居中偏移：图标在一侧，需要平移锚点使 (图标+条) 整体居中于目标框架
                -- LEFT: 图标在左侧，视觉中心偏右 iconOccupied/2 → 锚点右移 iconOccupied/2
                -- RIGHT: 图标在右侧，视觉中心偏左 iconOccupied/2 → 锚点左移 iconOccupied/2
                if side == "LEFT" then
                    iconCenterShift = iconOccupied / 2
                else
                    iconCenterShift = -iconOccupied / 2
                end
            else
                barWidth = unitWidth
            end
        end
        -- 懒加载：hook 框架的 OnSizeChanged，实时响应宽度变化
        HookAttachFramesSizeChanged()
    end

    -- 锚点框架固定为一条高度，仅作为定位参考点
    anchorFrame:SetSize(barWidth, height)

    -- ====== 统一条堆叠逻辑（独立/依附模式共用） ======
    local visibleCount = 0
    for i, bar in ipairs(list) do
        if i <= maxLimit then
            visibleCount = visibleCount + 1
            bar:SetParent(anchorFrame)
            bar:Show()
            bar:EnableMouse(false)
            bar:ClearAllPoints()

            -- 依附模式下自适应宽度：覆盖条的宽度
            if attachMode and EX_DB.attachAutoWidth then
                bar:SetWidth(barWidth)
            end

            if growUp then
                -- 向上增长：第1条在锚点 BOTTOM，后续依次向上叠加
                bar:SetPoint("BOTTOM", anchorFrame, "BOTTOM", 0, (i - 1) * (height + spacing))
            else
                -- 向下增长：第1条在锚点 TOP，后续依次向下叠加
                bar:SetPoint("TOP", anchorFrame, "TOP", 0, -(i - 1) * (height + spacing))
            end
        else
            bar:Hide()
        end
    end

    totalHeight = math.max(height, visibleCount > 0 and (visibleCount * height + (visibleCount - 1) * spacing) or height)

    if not attachMode and anchorFrame.bg then
        anchorFrame.bg:ClearAllPoints()
        anchorFrame.bg:SetSize(barWidth, totalHeight)
        anchorFrame.label:ClearAllPoints()
        anchorFrame.label:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)

        if growUp then
            anchorFrame.bg:SetPoint("BOTTOM", anchorFrame, "BOTTOM")
            anchorFrame:SetHitRectInsets(0, 0, -(totalHeight - height), 0)
        else
            anchorFrame.bg:SetPoint("TOP", anchorFrame, "TOP")
            anchorFrame:SetHitRectInsets(0, 0, 0, -(totalHeight - height))
        end
    else
        anchorFrame:SetHitRectInsets(0, 0, 0, 0)
    end

    if editHandleFrame then
        editHandleFrame:ClearAllPoints()
        editHandleFrame:SetSize(barWidth, totalHeight)
        if growUp then
            editHandleFrame:SetPoint("BOTTOM", anchorFrame, "BOTTOM")
        else
            editHandleFrame:SetPoint("TOP", anchorFrame, "TOP")
        end
    end

    -- ====== 依附模式：将锚点定位到目标框架 ======
    if attachMode then
        local attachAbove = (EX_DB.attachPoint ~= "下方")
        local offsetX = (EX_DB.attachOffsetX or 0) + iconCenterShift -- 加上图标居中补偿
        local offsetY = EX_DB.attachOffsetY or 2

        -- 计算条组总高度（用于计算偏移）
        local totalExtent = visibleCount > 0
            and (visibleCount * height + (visibleCount - 1) * spacing)
            or height

        if attachAbove then
            -- 依附到上方：底部的条紧贴框架顶部
            local target = GetAttachTargetFrame()
            if target then
                anchorFrame:ClearAllPoints()
                if growUp then
                    -- 向上增长: bar1 在 BOTTOM（最下方），直接锚定
                    anchorFrame:SetPoint("BOTTOM", target, "TOP", offsetX, offsetY)
                else
                    -- 向下增长: bar1 在 TOP（最上方），需要向上偏移整个组高度
                    -- barN.BOTTOM = anchor.TOP - totalExtent
                    -- 需要 barN.BOTTOM = target.TOP + offsetY
                    -- → anchor.BOTTOM = target.TOP + offsetY + totalExtent - height
                    anchorFrame:SetPoint("BOTTOM", target, "TOP", offsetX, offsetY + totalExtent - height)
                end
                anchorFrame:Show()
                anchorFrame:EnableMouse(false)
                anchorFrame.bg:Hide()
                anchorFrame.label:Hide()
            end
        else
            -- 依附到下方：顶部的条紧贴框架底部
            local lastChild = GetLastVisiblePartyChild()
            local target = lastChild or GetAttachTargetFrame()
            if target then
                local anchorPoint = lastChild and "BOTTOM" or "TOP"
                anchorFrame:ClearAllPoints()
                if growUp then
                    -- 向上增长: barN 在顶部，需要向下偏移整个组高度
                    -- offsetY 统一为正值=往上：此处用正号，使偏移越大条组越往上
                    anchorFrame:SetPoint("TOP", target, anchorPoint, offsetX, offsetY - totalExtent + height)
                else
                    -- 向下增长: bar1 在 TOP（最上方），直接锚定
                    -- offsetY 统一为正值=往上：此处用正号
                    anchorFrame:SetPoint("TOP", target, anchorPoint, offsetX, offsetY)
                end
                anchorFrame:Show()
                anchorFrame:EnableMouse(false)
                anchorFrame.bg:Hide()
                anchorFrame.label:Hide()
            end
        end
    end
end

-- 刷新所有条
RefreshAll = function()
    if isPreviewing then
        TogglePreview(false)
        TogglePreview(true)
    else
        for guid, data in pairs(activeBars) do
            if data.bar then
                UpdateBarVisuals(data.bar)
            end
        end
    end
    ReLayout()

    -- 独立模式下维护锚点状态，依附模式下锚点位置由 ReLayout 管理
    if not IsAttachModeAvailable() and anchorFrame then
        anchorFrame:ClearAllPoints()
        anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX or 0, EX_DB.posY or 0)

        if EX_DB.locked then
            anchorFrame:EnableMouse(false)
            anchorFrame.bg:Hide()
            anchorFrame.label:Hide()
        else
            anchorFrame:EnableMouse(true)
            anchorFrame.bg:Show()
            anchorFrame.label:Show()
        end
    end
end

-- 预览模式（5个最近打断记录）
TogglePreview = function(enable)
    isPreviewing = enable

    if enable then
        -- [v5.0 新增] 预览模式下创建锚点（不受环境限制）
        if not anchorFrame then
            CreateAnchor()
        end

        -- [v3.1 Fix] 预览模式自动启用拖动（仅独立模式）
        if not IsAttachModeAvailable() and anchorFrame then
            anchorFrame:Show()
            anchorFrame:EnableMouse(true)
            anchorFrame.bg:Show()
            anchorFrame.label:Show()
        end

        -- 清理真实条
        for guid, data in pairs(activeBars) do
            if data.bar then
                data.bar:Hide()
            end
        end
        wipe(activeBars)
        wipe(usedBarsList)
        wipe(previewBars)

        -- 获取玩家职业
        local playerName = UnitName("player")
        local _, playerClass = UnitClass("player")
        local playerColor = C_ClassColor.GetClassColor(playerClass)

        -- 预设4个不同职业（用于其他4个条）
        local previewClasses = {
            { name = "战士", class = "WARRIOR" },
            { name = "法师", class = "MAGE" },
            { name = "猎人", class = "HUNTER" },
            { name = "圣骑士", class = "PALADIN" },
        }

        -- 创建5个预览条
        for i = 1, 5 do
            local bar = AcquireBar()
            bar._isPreview = true
            UpdateBarVisuals(bar)

            -- 设置模拟法术图标
            local previewSpells = { 1766, 2139, 106839, 183752, 187707 }
            local spellInfo = C_Spell.GetSpellInfo(previewSpells[i] or 1766)
            if spellInfo then
                bar.Icon:SetTexture(spellInfo.iconID)
            else
                bar.Icon:SetTexture(136197)
            end

            -- 设置玩家名称和职业颜色
            if bar.Text and EX_DB.showPlayerName then
                local displayName, classColor
                if i == 1 then
                    -- 第1个条显示真实玩家
                    displayName = playerName
                    classColor = playerColor
                else
                    -- 其他条显示模拟职业
                    local classData = previewClasses[i - 1]
                    displayName = classData.name
                    classColor = C_ClassColor.GetClassColor(classData.class)
                end

                bar._previewClass = (i == 1) and playerClass or previewClasses[i - 1].class
                bar.Text:SetText(displayName)
                bar.Text:Show()
            end

            -- 视觉应用 (UpdateBarVisuals 内部现在会处理职业颜色)
            UpdateBarVisuals(bar)

            -- 预览为最近 15 秒内的打断记录
            bar:SetMinMaxValues(0, INTERRUPT_RECORD_DURATION)
            do
                local remaining = math.max(1, INTERRUPT_RECORD_DURATION - (i - 1) * 3)
                bar:SetValue(remaining)
                if bar.TimerText and EX_DB.showTimer then
                    bar.TimerText:SetText(string.format("%d", remaining))
                end
            end

            table.insert(previewBars, bar)
        end
    else
        -- 退出预览
        for _, bar in ipairs(previewBars) do
            bar:Hide()
            bar:SetScript("OnUpdate", nil)
            ReleaseBar(bar)
        end
        wipe(previewBars)

        -- [v3.1 Fix] 退出预览时恢复锁定状态
        if anchorFrame then
            if EX_DB.locked then
                anchorFrame:EnableMouse(false)
                anchorFrame.bg:Hide()
                anchorFrame.label:Hide()
            else
                anchorFrame:EnableMouse(true)
                anchorFrame.bg:Show()
            end
        end
        -- [v5.1 Fix] 退出预览后立即执行一次 UpdateLayout 以恢复真实数据，解决关闭编辑模式后条条不显示的问题
        UpdateLayout()
    end

    ReLayout()
end

-- 更新打断条布局 (增量更新,保留冷却状态)
UpdateLayout = function()
    -- [v5.0 新增] 环境检测：只在队伍且5人副本内生效
    if not CheckEnvironment() then
        return
    end

    -- 首次调用时自动检测可用的小队框体插件
    AutoDetectAttachFrame()

    if not EX_DB.enabled then
        if anchorFrame then
            anchorFrame:Hide()
        end
        return
    end

    if not anchorFrame then
        CreateAnchor()
    end

    -- 依附模式下隐藏锚点，独立模式下显示
    if IsAttachModeAvailable() then
        anchorFrame:Hide()
    else
        anchorFrame:Show()
    end

    -- [Fix] 预览时不该直接退出，而是应该继续执行
    if isPreviewing then
        ReLayout()
        return
    end

    CleanupExpiredRecords()
    ReLayout()
    RefreshAll()
end

-- =============================================================
-- 核心逻辑：打断检测
-- =============================================================

local function UpdateRecordTimerText(bar, remaining)
    if not bar or not bar.TimerText or not EX_DB.showTimer then return end

    local displayVal
    if remaining > 6 then
        displayVal = math.floor(remaining)
        if displayVal ~= bar._lastDisplayed then
            bar._lastDisplayed = displayVal
            bar.TimerText:SetText(string.format("%d", displayVal))
        end
    else
        displayVal = math.floor(remaining * 10)
        if displayVal ~= bar._lastDisplayed then
            bar._lastDisplayed = displayVal
            bar.TimerText:SetText(string.format("%.1f", remaining))
        end
    end
end

local function RemoveInterruptRecord(recordID, skipReLayout)
    local data = activeBars[recordID]
    if not data then return end

    if data.bar then
        data.bar._lastDisplayed = nil
        data.bar:SetScript("OnUpdate", nil)
        ReleaseBar(data.bar)
    end

    activeBars[recordID] = nil

    if not skipReLayout then
        ReLayout()
    end
end

CleanupExpiredRecords = function()
    local now = GetTime()
    local hasExpired = false

    for recordID, data in pairs(activeBars) do
        if not data.expireTime or data.expireTime <= now then
            RemoveInterruptRecord(recordID, true)
            hasExpired = true
        end
    end

    if hasExpired then
        ReLayout()
    end
end

local function AddInterruptRecord(interruptedBy)
    if not interruptedBy then
        DebugPrint("AddInterruptRecord 失败: interruptedBy 为空")
        return false, "missing_interruptedBy"
    end

    local okName, unitName, unitServer = pcall(UnitNameFromGUID, interruptedBy)
    if not okName or not unitName then
        DebugPrint("AddInterruptRecord 失败: UnitNameFromGUID 无法解析, ok=%s, secret=%s",
            tostring(okName), tostring(IsSecretValue(interruptedBy)))
        return false, "name_unresolved"
    end

    local safeUnitName = NormalizeSafeText(unitName)
    if not safeUnitName then
        DebugPrint("AddInterruptRecord 失败: unitName 为 secret 或空值")
        return false, "name_secret"
    end

    local displayName = safeUnitName
    local safeUnitServer = NormalizeSafeText(unitServer)
    if safeUnitServer then
        displayName = string.format("%s-%s", safeUnitName, safeUnitServer)
    end

    local classFilename = nil
    if UnitClassFromGUID then
        local okClass, _className, classFile = pcall(UnitClassFromGUID, interruptedBy)
        if okClass and classFile then
            classFilename = classFile
        else
            DebugPrint("UnitClassFromGUID 未提供可用职业 token, ok=%s", tostring(okClass))
        end
    end

    local iconTexture = INTERRUPT_RECORD_ICON

    local bar = AcquireBar()
    if not bar then return end

    nextInterruptRecordID = nextInterruptRecordID + 1
    local recordID = nextInterruptRecordID
    local startTime = GetTime()
    local expireTime = startTime + INTERRUPT_RECORD_DURATION

    bar.unit = nil
    bar._classFilename = classFilename
    bar._isPreview = nil
    bar._lastDisplayed = nil

    if bar.Icon then
        bar.Icon:SetTexture(iconTexture)
    end

    -- 先应用字体和控件样式，再写入文本，避免池化 FontString 尚未设置字体时报错。
    UpdateBarVisuals(bar)

    if bar.Text then
        local okText, errText = pcall(bar.Text.SetText, bar.Text, displayName)
        if not okText then
            DebugPrint("bar.Text:SetText 失败: %s", tostring(errText))
            return false, "text_set_failed"
        end
        bar.Text:SetShown(EX_DB.showPlayerName)
    end

    bar:SetMinMaxValues(0, INTERRUPT_RECORD_DURATION)
    bar:SetValue(INTERRUPT_RECORD_DURATION)
    UpdateRecordTimerText(bar, INTERRUPT_RECORD_DURATION)

    activeBars[recordID] = {
        bar = bar,
        guid = interruptedBy,
        unit = nil,
        startTime = startTime,
        expireTime = expireTime,
        duration = INTERRUPT_RECORD_DURATION,
        classFilename = classFilename,
    }

    bar:SetScript("OnUpdate", function(self)
        local data = activeBars[recordID]
        if not data or data.bar ~= self then
            self:SetScript("OnUpdate", nil)
            return
        end

        local remaining = data.expireTime - GetTime()
        if remaining > 0 then
            self:SetValue(remaining)
            UpdateRecordTimerText(self, remaining)
        else
            RemoveInterruptRecord(recordID)
        end
    end)

    ReLayout()
    DebugPrint("AddInterruptRecord 成功: name=%s, class=%s, activeRecords=%d",
        displayName, tostring(classFilename), nextInterruptRecordID)
    return true, "ok"
end

-- =============================================================
-- 大秘境打断统计系统
-- =============================================================
local interruptStats = {} -- { [guid] = count }
local isInMythicPlus = false
local C_DamageMeter = _G.C_DamageMeter
local IsInGroup = _G.IsInGroup
local GetNumSubgroupMembers = _G.GetNumSubgroupMembers

-- 重置打断统计表
local function ResetInterruptStats()
    wipe(interruptStats)
end

-- 记录一次打断
local function RecordInterrupt(guid)
    if not isInMythicPlus then return end
    if not guid then return end
    if IsSecretValue(guid) then
        DebugPrint("自定义统计跳过: interruptedBy 是 secret GUID，不能作为 table key")
        return
    end

    interruptStats[guid] = (interruptStats[guid] or 0) + 1
end

-- 打印自定义统计（模块内部记录）
local function PrintCustomInterruptStats()
    if not next(interruptStats) then
        return
    end

    -- 按次数排序
    local sortedStats = {}
    for guid, count in pairs(interruptStats) do
        table.insert(sortedStats, { guid = guid, count = count })
    end

    table.sort(sortedStats, function(a, b) return a.count > b.count end)

    -- 打印结果
    for _, data in ipairs(sortedStats) do
        local nameEX, serverEX = UnitNameFromGUID(data.guid)
        local safeNameEX = NormalizeSafeText(nameEX)
        local safeServerEX = NormalizeSafeText(serverEX)
        if safeNameEX then
            if safeServerEX then
                print(string.format("|cffffffff%s-%s|r: |cff00ff00%d|r 次", safeNameEX, safeServerEX, data.count))
            else
                print(string.format("|cffffffff%s|r: |cff00ff00%d|r 次", safeNameEX, data.count))
            end
        else
            print(string.format("|cffaaaaaa%s|r: |cff00ff00%d|r 次", data.guid, data.count))
        end
    end
end

-- 打印内建伤害统计的打断次数
local function PrintBlizzardInterruptStats()
    local sessionTypeEX = 0 -- Overall
    local meterTypeEX = 5   -- Interrupts

    if not C_DamageMeter then
        print("|cffff0000[内建统计]|r C_DamageMeter 不可用")
        return
    end

    local totalBySourceEX = {}

    local unitsEX = { "player" }
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            table.insert(unitsEX, "raid" .. i)
        end
    elseif IsInGroup() then
        for i = 1, GetNumSubgroupMembers() do
            table.insert(unitsEX, "party" .. i)
        end
    end

    for _, unitEX in ipairs(unitsEX) do
        local guidEX = UnitGUID(unitEX)
        if guidEX then
            local sessionSourceEX = C_DamageMeter.GetCombatSessionSourceFromType(sessionTypeEX, meterTypeEX, guidEX)

            if sessionSourceEX and sessionSourceEX.combatSpells then
                local totalEX = 0

                for _, spellEX in ipairs(sessionSourceEX.combatSpells) do
                    totalEX = totalEX + (spellEX.totalAmount or 0)
                end

                totalBySourceEX[guidEX] = totalEX
            end
        end
    end

    print("|cff00ffff===== 内建统计：打断次数 =====|r")

    if not next(totalBySourceEX) then
        print("|cffaaaaaa(暂无数据)|r")
        return
    end

    -- 按次数排序
    local sortedStats = {}
    for guid, count in pairs(totalBySourceEX) do
        table.insert(sortedStats, { guid = guid, count = count })
    end

    table.sort(sortedStats, function(a, b) return a.count > b.count end)

    for _, data in ipairs(sortedStats) do
        local nameEX, serverEX = UnitNameFromGUID(data.guid)
        local safeNameEX = NormalizeSafeText(nameEX)
        local safeServerEX = NormalizeSafeText(serverEX)
        if safeNameEX then
            if safeServerEX then
                print(string.format("|cffffffff%s-%s|r: |cff00ff00%d|r 次", safeNameEX, safeServerEX, data.count))
            else
                print(string.format("|cffffffff%s|r: |cff00ff00%d|r 次", safeNameEX, data.count))
            end
        else
            print(string.format("|cffaaaaaa%s|r: |cff00ff00%d|r 次", data.guid, data.count))
        end
    end
end

-- 打印完整统计报告
local function PrintInterruptReport()
    print(" ")
    print("|cffff00ff================================================|r")
    print("|cffff00ff          打断统计报告                         |r")
    print("|cffff00ff================================================|r")
    print(" ")

    -- 打印模块统计
    PrintCustomInterruptStats()
    print(" ")

    -- 打印内建统计
    PrintBlizzardInterruptStats()
    print(" ")
    print("|cffff00ff================================================|r")
end

ExwindTools:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", EXWIND_MODULE_KEY, function(_, unit, castGUID, spellID, interruptedBy, castBarID)
    DebugPrint("收到 UNIT_SPELLCAST_INTERRUPTED: unit=%s, spellID=%s, castBarID=%s, hasInterruptedBy=%s, secretInterruptedBy=%s",
        tostring(unit), tostring(spellID), tostring(castBarID), tostring(interruptedBy ~= nil), tostring(IsSecretValue(interruptedBy)))

    if not EX_DB.enabled then
        DebugPrint("事件忽略: 模块未启用")
        return
    end
    if isPreviewing then
        DebugPrint("事件忽略: 当前处于预览模式")
        return
    end
    if not isValidEnvironment then
        DebugPrint("事件忽略: isValidEnvironment=false")
        PrintDebugSnapshot()
        return
    end
    if not unit or not string.find(unit, "nameplate") then
        DebugPrint("事件忽略: unit 不是 nameplate, unit=%s", tostring(unit))
        return
    end
    if not interruptedBy then
        DebugPrint("事件忽略: interruptedBy 为空")
        return
    end

    RecordInterrupt(interruptedBy)
    local okAdd, reason = AddInterruptRecord(interruptedBy)
    DebugPrint("事件处理结束: AddInterruptRecord=%s, reason=%s", tostring(okAdd), tostring(reason))
end)

-- =============================================================
-- 事件处理
-- =============================================================
ExwindTools:RegisterEvent("EX_PARTY_SPEC_UPDATED", EXWIND_MODULE_KEY, function()
    if not isPreviewing then
        UpdateLayout()
    end
end)

ExwindTools:RegisterEvent("GROUP_ROSTER_UPDATE", EXWIND_MODULE_KEY, function()
    if not isPreviewing then
        UpdateLayout()
    end
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    EX_DB.preview = false
    C_Timer.After(1, function()
        CreateAnchor()
        UpdateLayout()
    end)
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end
    if isEditModeActive and (info.key == "preview" or info.key == "locked") then
        return
    end

    if info.key == "preview" then
        TogglePreview(EX_DB.preview)
    elseif info.key == "enabled" then
        if EX_DB.enabled then
            CreateAnchor()
            UpdateLayout()
        else
            if anchorFrame then
                anchorFrame:Hide()
            end
        end
    elseif info.key == "attachToRaidFrame" or info.key == "attachFrame" or info.key == "attachPoint"
        or info.key == "attachAutoWidth" then
        -- 用户手动选择了目标框架时，标记为手动设置（不再自动检测覆盖）
        if info.key == "attachFrame" then
            EX_DB._attachFrameSetByUser = true
        end
        -- 依附模式切换：需要完全重建布局
        -- 先清理所有现有条，重新创建
        for guid, data in pairs(activeBars) do
            if data.bar then
                data.bar:SetParent(anchorFrame or UIParent)
                ReleaseBar(data.bar)
            end
        end
        wipe(activeBars)
        wipe(usedBarsList)
        if isPreviewing then
            TogglePreview(false)
            TogglePreview(true)
        else
            UpdateLayout()
        end
    else
        if isPreviewing then
            TogglePreview(false)
            TogglePreview(true)
        else
            RefreshAll()
        end
    end
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if info.key == "btn_reset_pos" then
        EX_DB.posX = 0
        EX_DB.posY = -200
        if anchorFrame then
            anchorFrame:ClearAllPoints()
            anchorFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
        end
        RefreshAll()
    end
end)

-- =============================================================
-- 全局编辑模式支持
-- =============================================================
-- [v3.1 新增] 注册全局编辑模式回调
local function ApplyEditModePresentation()
    if isEditModeActive then
        if isEditModeVisible then
            EX_DB.locked = false
            EX_DB.preview = true
            TogglePreview(true)
            RefreshAll()
            if anchorFrame and anchorFrame.bg then anchorFrame.bg:Hide() end
            if anchorFrame and anchorFrame.label then anchorFrame.label:Hide() end
            RefreshEditOverlay()
        else
            EX_DB.locked = true
            EX_DB.preview = false
            HideAllVisualsForEditMode()
        end
    else
        if editModeRestore then
            EX_DB.locked = editModeRestore.locked
            EX_DB.preview = editModeRestore.preview
            editModeRestore = nil
        end
        HideAllVisualsForEditMode()
        if EX_DB.preview then
            TogglePreview(true)
        else
            UpdateLayout()
            RefreshAll()
        end
        RefreshEditOverlay()
    end
end

ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
        if not editModeRestore then
            editModeRestore = {
                locked = EX_DB.locked,
                preview = EX_DB.preview,
            }
        end
        isEditModeActive = true
        isEditModeVisible = true
        ApplyEditModePresentation()
    end,
    ExitEditMode = function()
        isEditModeActive = false
        isEditModeVisible = true
        ApplyEditModePresentation()
    end,
    SetEditVisible = function(_, visible)
        isEditModeVisible = (visible ~= false)
        ApplyEditModePresentation()
    end,
})

-- =============================================================
-- 大秘境事件监听
-- =============================================================

-- 监听大秘境开始事件
ExwindTools:RegisterEvent("CHALLENGE_MODE_START", EXWIND_MODULE_KEY, function()
    isInMythicPlus = true
    ResetInterruptStats()
end)

-- 监听大秘境完成事件
ExwindTools:RegisterEvent("CHALLENGE_MODE_COMPLETED", EXWIND_MODULE_KEY, function()
    if isInMythicPlus then
        -- print("|cff00ff00[打断统计]|r 大秘境已完成，数据已保存")
    end
end)

-- 监听大秘境重置事件
ExwindTools:RegisterEvent("CHALLENGE_MODE_RESET", EXWIND_MODULE_KEY, function()
    if isInMythicPlus then
        -- print("|cffff8800[打断统计]|r 大秘境已重置")
    end
    isInMythicPlus = false
end)

-- 监听进入世界（重载也会触发）
ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY .. "_EnterWorld", function()
    ScheduleTemporaryNotice()

    -- 检测是否在大秘境中
    local _, instanceType = GetInstanceInfo()
    local isMythicPlusInstance = (instanceType == "party" and C_ChallengeMode and C_ChallengeMode.GetActiveKeystoneInfo())

    -- 只做统计用的标志位更新
    if isMythicPlusInstance then
        isInMythicPlus = true
    else
        isInMythicPlus = false
    end

    -- 检测环境并更新UI
    CheckEnvironment()
end)

-- =============================================================
-- State 监听：环境变化时自动启用/禁用
-- =============================================================
-- 监听队伍状态变化
ExwindTools:WatchState("IsInParty", EXWIND_MODULE_KEY .. "_PartyWatch", function()
    CheckEnvironment()
end)

-- 监听副本类型变化
ExwindTools:WatchState("InstanceType", EXWIND_MODULE_KEY .. "_InstanceWatch", function()
    CheckEnvironment()
end)

-- =============================================================
-- 斜杠命令注册
-- =============================================================

-- 注册 /extest 命令
_G.SLASH_EXTEST1 = "/extest"
_G.SlashCmdList["EXTEST"] = function()
    PrintInterruptReport()
end

_G.SLASH_EXINTDEBUG1 = "/exintdebug"
_G.SlashCmdList["EXINTDEBUG"] = function(msg)
    local cmd = string.lower(tostring(msg or ""))
    if cmd == "on" then
        interruptDebugEnabled = true
    elseif cmd == "off" then
        interruptDebugEnabled = false
    else
        interruptDebugEnabled = not interruptDebugEnabled
    end

    print(string.format("|cff33ff99[ExInterruptDebug]|r 调试已%s", interruptDebugEnabled and "开启" or "关闭"))
    if interruptDebugEnabled then
        PrintDebugSnapshot()
    end
end

ExwindTools:ReportReady(EXWIND_MODULE_KEY)
