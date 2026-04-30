-- =============================================================
-- [[ 目标距离监控 ]]
-- { Key = "ExClass.RangeCheck", Name = "距离监视", Desc = "实时显示目标距离范围。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExClass.RangeCheck"

-- =============================================================
-- 第一部分：Grid 布局定义 (必须最先运行！)
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        -- 标题
        { key = "header", type = "header", x = 2, y = 1, w = 50, h = 3, label = L["距离监视"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 50, h = 2, label = L["实时显示目标距离范围，根据与目标的最小距离自动变色。"] },

        -- 基础设置
        { key = "sub_general", type = "subheader", x = 2, y = 6, w = 50, h = 2, label = L["基础设置"], labelSize = 20 },
        { key = "div_general", type = "divider", x = 2, y = 8, w = 50, h = 1 },
        { key = "enabled", type = "checkbox", x = 2, y = 10, w = 12, h = 2, label = L["启用"] },
        { key = "locked", type = "checkbox", x = 16, y = 10, w = 12, h = 2, label = L["锁定位置"] },
        { key = "showText", type = "checkbox", x = 30, y = 10, w = 14, h = 2, label = L["显示距离范围"] },

        -- 外观设置
        { key = "sub_appearance", type = "subheader", x = 2, y = 13, w = 50, h = 2, label = L["外观设置"], labelSize = 20 },
        { key = "div_appearance", type = "divider", x = 2, y = 15, w = 50, h = 1 },
        { key = "fontSize", type = "slider", x = 2, y = 17, w = 16, h = 2, label = L["字体大小"], min = 10, max = 48, step = 1, labelPos = "top" },
        { key = "frameScale", type = "slider", x = 20, y = 17, w = 16, h = 2, label = L["缩放"], min = 0.5, max = 3.0, step = 0.1, labelPos = "top" },
        { key = "hideThreshold", type = "slider", x = 38, y = 17, w = 16, h = 2, label = L["隐藏距离阈值"], min = 5, max = 100, step = 5, labelPos = "top" },
        { key = "desc_threshold", type = "description", x = 38, y = 20, w = 16, h = 2, label = L["目标超过此距离时隐藏(100=不隐藏)"] },

        -- 字体描边与阴影
        {
            key = "fontOutline",
            type = "dropdown",
            x = 2,
            y = 20,
            w = 16,
            h = 2,
            label = L["文字描边"],
            labelPos = "top",
            items = "无,细描边,粗描边,无锯齿"
        },
        { key = "fontShadow", type = "checkbox", x = 20, y = 20, w = 14, h = 2, label = L["启用阴影"] },
        { key = "fontShadowX", type = "slider", x = 2, y = 23, w = 16, h = 2, label = L["阴影 X 偏移"], min = -10, max = 10, step = 1, labelPos = "top" },
        { key = "fontShadowY", type = "slider", x = 20, y = 23, w = 16, h = 2, label = L["阴影 Y 偏移"], min = -10, max = 10, step = 1, labelPos = "top" },

        -- 自定义格式
        { key = "rangeFormat", type = "input", x = 2, y = 26, w = 16, h = 2, label = L["范围格式"], labelPos = "top", placeholder = "%d - %d" },
        { key = "minOnlyFormat", type = "input", x = 20, y = 26, w = 16, h = 2, label = L["仅最小值格式"], labelPos = "top", placeholder = "%d+" },
        { key = "desc_format", type = "description", x = 2, y = 29, w = 34, h = 2, label = L["范围格式需要两个 %d (最小/最大，如%d - %d)，仅最小值格式需要一个 %d+。留空使用默认格式。"] },

        -- 位置设置
        { key = "sub_position", type = "subheader", x = 2, y = 32, w = 50, h = 2, label = L["位置设置"], labelSize = 20 },
        { key = "div_position", type = "divider", x = 2, y = 34, w = 50, h = 1 },
        { key = "xOffset", type = "slider", x = 2, y = 36, w = 16, h = 2, label = L["X 轴偏移"], min = -1000, max = 1000, step = 1, labelPos = "top" },
        { key = "yOffset", type = "slider", x = 20, y = 36, w = 16, h = 2, label = L["Y 轴偏移"], min = -1000, max = 1000, step = 1, labelPos = "top" },
        { key = "btn_resetPos", type = "button", x = 38, y = 36, w = 14, h = 3, label = L["重置位置"] },

        -- 颜色设置
        { key = "sub_colors", type = "subheader", x = 2, y = 41, w = 50, h = 2, label = L["距离颜色设置"], labelSize = 20 },
        { key = "div_colors", type = "divider", x = 2, y = 43, w = 50, h = 1 },
        { key = "desc_colors", type = "description", x = 2, y = 45, w = 50, h = 2, label = L["根据与目标的距离自动切换文字颜色。每个颜色对应一个距离区间。"] },

        { key = "crColor", type = "color", x = 2, y = 48, w = 7, h = 2, label = L["< 5 码"] },
        { key = "srColor", type = "color", x = 9, y = 48, w = 7, h = 2, label = L[">= 5 码"] },
        { key = "s10Color", type = "color", x = 16, y = 48, w = 7, h = 2, label = L[">= 10 码"] },
        { key = "s15Color", type = "color", x = 23, y = 48, w = 7, h = 2, label = L[">= 15 码"] },
        { key = "mrColor", type = "color", x = 30, y = 48, w = 7, h = 2, label = L[">= 20 码"] },
        { key = "lrColor", type = "color", x = 37, y = 48, w = 7, h = 2, label = L[">= 30 码"] },
        { key = "oorColor", type = "color", x = 44, y = 48, w = 7, h = 2, label = L[">= 40 码"] },
    }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout() -- 立即执行注册

-- =============================================================
-- 第二部分：载入检查与环境过滤
-- =============================================================
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 第三部分：依赖与数据初始化
-- =============================================================

-- 获取 LibRangeCheck-3.0 (已在 ExwindCore/libs 中加载)
local LRC = LibStub("LibRangeCheck-3.0")
if not LRC then
    print(string.format("|cffff0000[%s]|r %s", L["距离监控"], L["LibRangeCheck-3.0 未找到，模块无法工作。"]))
    return
end

-- 默认配置
local EXWIND_DEFAULTS = {
    enabled = true,
    locked = true, -- 默认锁定，通过编辑模式解锁
    showText = true,
    fontSize = 18,
    frameScale = 1.0,
    hideThreshold = 60, -- 距离大于此值时隐藏 (100=不隐藏)

    -- 位置
    point = "CENTER",
    relativePoint = "CENTER",
    xOffset = 0,
    yOffset = -85,

    -- 字体描边与阴影
    fontOutline = "细描边", -- 文字描边: 无/细描边/粗描边/无锯齿
    fontShadow = true, -- 启用阴影
    fontShadowX = 1, -- 阴影 X 偏移
    fontShadowY = -1, -- 阴影 Y 偏移

    -- 自定义格式 (留空使用默认)
    rangeFormat = "",   -- 范围格式，默认 "%d - %d"
    minOnlyFormat = "", -- 仅最小值格式，默认 "%d+"

    -- 颜色设置 (Grid ColorPicker 自动拆分为 R/G/B 后缀)
    crColorR = 0.9,
    crColorG = 0.9,
    crColorB = 0.9, -- < 5 码 白色
    srColorR = 0.063,
    srColorG = 1.0,
    srColorB = 0.941, -- >= 5 码 青色 #10FFF0
    s10ColorR = 0.063,
    s10ColorG = 1.0,
    s10ColorB = 0.941, -- >= 10 码 青色 (默认同 >5 码)
    s15ColorR = 0.063,
    s15ColorG = 1.0,
    s15ColorB = 0.941, -- >= 15 码 青色 (默认同 >5 码)
    mrColorR = 0.039,
    mrColorG = 1.0,
    mrColorB = 0.0, -- >= 20 码 绿色 #0AFF00
    lrColorR = 1.0,
    lrColorG = 1.0,
    lrColorB = 0.0, -- >= 30 码 黄色 #FFFF00
    oorColorR = 1.0,
    oorColorG = 0.0,
    oorColorB = 0.0, -- >= 40 码 红色 #FF0000
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)
local isEditModeActive = false
local isEditModeVisible = true
local SAMPLE_RANGE_TEXT = "15 - 20"
local rangeFrame = nil
local rangeText = nil

local function RefreshEditOverlay()
    if not rangeFrame then return end

    if isEditModeActive and isEditModeVisible then
        ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY, rangeFrame)
    else
        ExwindTools:HideExwindToolsEditOverlay(rangeFrame)
    end
end

-- =============================================================
-- 第四部分：业务逻辑
-- =============================================================

-- 主框体
rangeFrame = CreateFrame("Frame", "ExwindRangeCheckFrame", UIParent)
rangeFrame:SetSize(120, 40)
rangeFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
rangeFrame:SetMovable(true)
rangeFrame:SetClampedToScreen(true)
rangeFrame:Hide()

-- 距离文本
rangeText = rangeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
rangeText:SetPoint("CENTER")
rangeText:SetText("")
rangeFrame.text = rangeText

-- ===================== 位置保存/恢复 =====================

local function SavePosition()
    if not rangeFrame then return end
    local point, _, relativePoint, xOfs, yOfs = rangeFrame:GetPoint()
    if point and relativePoint then
        EX_DB.point = point
        EX_DB.relativePoint = relativePoint
        EX_DB.xOffset = xOfs or 0
        EX_DB.yOffset = yOfs or 0
    end
end

local function RestorePosition()
    if not rangeFrame then return end

    rangeFrame:SetScale(EX_DB.frameScale or 1.0)
    rangeFrame:ClearAllPoints()
    rangeFrame:SetPoint(
        EX_DB.point or "CENTER",
        UIParent,
        EX_DB.relativePoint or "CENTER",
        EX_DB.xOffset or 0,
        EX_DB.yOffset or -85
    )
end

-- ===================== 锁定状态 =====================

local function UpdateLockState()
    if not rangeFrame then return end

    if isEditModeActive then
        rangeFrame:EnableMouse(isEditModeVisible == true)
        RefreshEditOverlay()
        return
    end

    local locked = EX_DB.locked
    if locked then
        rangeFrame:EnableMouse(false)
    else
        rangeFrame:EnableMouse(true)
    end

    RefreshEditOverlay()
end

-- ===================== 距离颜色逻辑 =====================

--- 根据最小距离获取对应的颜色 (R, G, B)
local function GetRangeColor(minRange)
    if not minRange then
        return EX_DB.crColorR or 0.9, EX_DB.crColorG or 0.9, EX_DB.crColorB or 0.9
    end

    if minRange >= 40 then
        return EX_DB.oorColorR or 1, EX_DB.oorColorG or 0, EX_DB.oorColorB or 0
    end

    if minRange >= 30 then
        return EX_DB.lrColorR or 1, EX_DB.lrColorG or 1, EX_DB.lrColorB or 0
    end

    if minRange >= 20 then
        return EX_DB.mrColorR or 0.039, EX_DB.mrColorG or 1, EX_DB.mrColorB or 0
    end

    if minRange >= 15 then
        return EX_DB.s15ColorR or 0.063, EX_DB.s15ColorG or 1, EX_DB.s15ColorB or 0.941
    end

    if minRange >= 10 then
        return EX_DB.s10ColorR or 0.063, EX_DB.s10ColorG or 1, EX_DB.s10ColorB or 0.941
    end

    if minRange >= 5 then
        return EX_DB.srColorR or 0.063, EX_DB.srColorG or 1, EX_DB.srColorB or 0.941
    end

    -- <= 5 码
    return EX_DB.crColorR or 0.9, EX_DB.crColorG or 0.9, EX_DB.crColorB or 0.9
end

-- ===================== 格式化距离文本 =====================

local function FormatRangeText(minRange, maxRange)
    if not minRange then
        return ""
    elseif not maxRange then
        local fmt = EX_DB.minOnlyFormat
        if not fmt or fmt == "" then fmt = "%d+" end
        return string.format(fmt, minRange)
    else
        local fmt = EX_DB.rangeFormat
        if not fmt or fmt == "" then fmt = "%d - %d" end
        return string.format(fmt, minRange, maxRange)
    end
end

-- ===================== 距离更新 =====================

local function UpdateRange()
    if isEditModeActive then
        if not isEditModeVisible then
            rangeText:SetText("")
            return
        end
        rangeText:SetText(SAMPLE_RANGE_TEXT)
        rangeText:SetTextColor(EX_DB.s15ColorR or 0.063, EX_DB.s15ColorG or 1, EX_DB.s15ColorB or 0.941)
        return
    end

    if not EX_DB.enabled or not EX_DB.showText then
        rangeText:SetText("")
        return
    end

    if not UnitExists("target") then
        rangeText:SetText("")
        return
    end

    local minRange, maxRange = LRC:GetRange("target")

    -- 检查是否超过隐藏阈值 (100=不隐藏)
    local hideThreshold = EX_DB.hideThreshold or 60
    if hideThreshold < 100 and minRange and minRange > hideThreshold then
        rangeText:SetText("")
        return
    end

    local r, g, b = GetRangeColor(minRange)
    rangeText:SetText(FormatRangeText(minRange, maxRange))
    rangeText:SetTextColor(r, g, b)
end

-- ===================== 应用字体样式 (大小/描边/阴影) =====================

-- 下拉选项文字 → SetFont 的描边参数
local OUTLINE_MAP = {
    ["无"] = "",
    ["细描边"] = "OUTLINE",
    ["粗描边"] = "THICKOUTLINE",
    ["无锯齿"] = "MONOCHROME",
}

local function ApplyFontSize()
    local fontPath   = ExwindTools.MAIN_FONT or select(1, GameFontNormalLarge:GetFont())
    local fontSize   = EX_DB.fontSize or EXWIND_DEFAULTS.fontSize
    local outlineKey = EX_DB.fontOutline or EXWIND_DEFAULTS.fontOutline
    local outline    = OUTLINE_MAP[outlineKey] or "OUTLINE"
    rangeText:SetFont(fontPath, fontSize, outline)

    -- 阴影
    if EX_DB.fontShadow then
        rangeText:SetShadowColor(0, 0, 0, 1)
        rangeText:SetShadowOffset(
            EX_DB.fontShadowX or EXWIND_DEFAULTS.fontShadowX,
            EX_DB.fontShadowY or EXWIND_DEFAULTS.fontShadowY
        )
    else
        rangeText:SetShadowOffset(0, 0)
    end
end

-- ===================== 可见性控制 =====================

local function UpdateVisibility()
    if isEditModeActive then
        if isEditModeVisible then
            rangeFrame:Show()
            rangeFrame:SetAlpha(1)
        else
            rangeFrame:Hide()
        end
        return
    end

    if not EX_DB.enabled then
        rangeFrame:Hide()
        return
    end

    if EX_DB.showText then
        rangeFrame:Show()
    else
        rangeFrame:Hide()
    end
end

-- ===================== 全量刷新 =====================

local function RefreshAll()
    RestorePosition()
    ApplyFontSize()
    UpdateLockState()
    UpdateVisibility()
    UpdateRange()
end

local function ApplyEditModePresentation()
    if not isEditModeActive then
        RefreshAll()
        return
    end

    RestorePosition()
    ApplyFontSize()
    UpdateLockState()
    UpdateVisibility()
    UpdateRange()
    RefreshEditOverlay()
end

-- ===================== 拖动交互 =====================

rangeFrame:SetScript("OnMouseDown", function(self, button)
    local locked = EX_DB.locked
    if isEditModeActive then
        locked = not (isEditModeVisible == true)
    end
    if locked then return end
    if button == "LeftButton" then
        self.moving = true
        self:StartMoving()
    elseif button == "RightButton" and ExwindTools.GlobalEditMode then
        ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
    end
end)

rangeFrame:SetScript("OnMouseUp", function(self)
    if self.moving then
        self.moving = false
        self:StopMovingOrSizing()
        SavePosition()
    end
end)

-- ===================== OnUpdate 轮询距离 =====================

local UPDATE_INTERVAL = 0.3
local timeSinceLastUpdate = 0

rangeFrame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= UPDATE_INTERVAL then
        UpdateRange()
        timeSinceLastUpdate = 0
    end
end)

-- =============================================================
-- 第五部分：事件与状态订阅
-- =============================================================

-- 注册编辑模式回调
local function RegisterEditMode()
    ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
        EnterEditMode = function()
            isEditModeActive = true
            isEditModeVisible = true
            ApplyEditModePresentation()
        end,
        ExitEditMode = function()
            isEditModeActive = false
            isEditModeVisible = true
            RefreshAll()
        end,
        SetEditVisible = function(_, visible)
            isEditModeVisible = (visible ~= false)
            ApplyEditModePresentation()
        end,
    })
end
RegisterEditMode()

-- 注册 HUD (右键跳转到设置)
ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, rangeFrame)

-- 目标切换时立即刷新
ExwindTools:RegisterEvent("PLAYER_TARGET_CHANGED", EXWIND_MODULE_KEY, function()
    UpdateRange()
end)

-- 监听数据库变动 (用户在 Grid 面板修改设置)
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if isEditModeActive then
        ApplyEditModePresentation()
        return
    end
    RefreshAll()
end)

-- 监听重置位置按钮
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end
    if info.key == "btn_resetPos" then
        EX_DB.point = "CENTER"
        EX_DB.relativePoint = "CENTER"
        EX_DB.xOffset = EXWIND_DEFAULTS.xOffset
        EX_DB.yOffset = EXWIND_DEFAULTS.yOffset
        RestorePosition()
        print(string.format("|cff00ff00[%s]|r %s", L["距离监控"], L["位置已重置"]))
    end
end)

-- =============================================================
-- 第六部分：初始化与模块报告
-- =============================================================

-- 延迟初始化
C_Timer.After(1, function()
    RefreshAll()
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    RefreshAll()
end)

-- 报告模块加载完成
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
