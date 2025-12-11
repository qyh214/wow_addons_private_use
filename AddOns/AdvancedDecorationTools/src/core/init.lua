local ADDON_NAME, ADT = ...

-- 本地化表
ADT = ADT or {}
ADT.L = ADT.L or {}

-- 先行提供 API 表与 DeltaLerp（供核心滚动等模块使用，单一权威）
ADT.API = ADT.API or {}
local API = ADT.API

-- 帧率无关的线性缓动：将 a 按给定速率 amount 向 b 逼近（与参考手感保持一致）
function API.DeltaLerp(a, b, amount, dt)
    local t = (amount or 0.15) * (dt or 0) * 60
    if t < 0 then t = 0 elseif t > 1 then t = 1 end
    return (1 - t) * (a or 0) + t * (b or 0)
end

-- 默认配置（单一权威）
local DEFAULTS = {
    EnableDupe = true,
    -- 是否启用 Q/E 旋转 90°（仅在住宅编辑器内生效）
    EnableQERotate = true,
    -- 是否启用 T 重置默认属性（专家模式下重置当前子模式）
    EnableResetT = true,
    -- 是否启用 Ctrl+T 全部重置
    EnableResetAll = true,
    -- 是否启用 L 锁定/解锁 悬停装饰
    EnableLock = true,
    DuplicateKey = 3,
    -- 记住控制中心上次选中的分类（'Housing'/'Clipboard'/'History'/...）
    LastCategoryKey = nil,
    -- 悬停高亮（3D场景中高亮当前悬停的装饰物）
    EnableHoverHighlight = true,
    -- 放置历史记录
    PlacementHistory = {},
    -- 额外剪切板（持久化，可视化列表）
    ExtraClipboard = {},
    -- 调试开关（仅在开启时才向聊天框 print）
    DebugEnabled = false,
    -- UI 位置持久化：控制中心主面板
    SettingsPanelPos = nil,
    -- UI 尺寸持久化：控制中心主面板（w/h）
    SettingsPanelSize = nil,
    -- 语言选择（nil=跟随客户端）
    SelectedLanguage = nil,
    -- 自动旋转（批量放置增强）默认配置（顶层仅放“显式可见的用户选项”）
    EnableAutoRotateOnCtrlPlace = true,
    AutoRotateMode = "preset",         -- 可选："preset" | "learn" | "sequence"
    AutoRotatePresetDegrees = 90,       -- 预设角度（度）
    AutoRotateSequence = "0,90",       -- 序列（逗号分隔），仅在 mode=sequence 生效
    AutoRotateApplyScope = "onlyPaint", -- 仅在按住 CTRL 连续放置时启用："onlyPaint"；或对所有抓取入口启用："all"
    AutoRotateStepDegrees = 15,         -- 基本模式单次步进角度（估值，可在设置中调节）
    -- 注意：按 decorRecordID 的专属步进、序列索引、学习记录等运行期/半持久化数据
    -- 统一收敛到 ADT_DB.AutoRotate 子表中，避免出现重复字段。

    -- 访屋助手（VisitAssistant）配置（配置驱动，统一权威）
    VisitAutoRemoveFriend = true,     -- 通过好友曲线拿到 GUID 后，是否自动移除临时好友
    VisitFriendWaitSec = 8,           -- 等待好友列表刷新最大秒数
    -- 进入编辑模式时自动打开控制中心（Dock）
    EnableDockAutoOpenInEditor = true,
}

-- 统一设置事件总线（单一权威）：任何对 ADT_DB 的写操作都通过此处发出事件
ADT.Settings = ADT.Settings or {}
do
    local Bus = ADT.Settings
    Bus._listeners = Bus._listeners or {}

    function Bus.On(key, fn)
        if not key or type(fn) ~= 'function' then return end
        Bus._listeners[key] = Bus._listeners[key] or {}
        table.insert(Bus._listeners[key], fn)
    end

    function Bus.Emit(key, value)
        local arr = Bus._listeners and Bus._listeners[key]
        if not arr then return end
        for _, fn in ipairs(arr) do
            pcall(fn, value)
        end
    end

    -- 在 ADDON_LOADED 之后，可用于把“当前持久化值”广播给已注册监听者
    function Bus.ApplyAll()
        local db = _G.ADT_DB or {}
        for key, fns in pairs(Bus._listeners or {}) do
            local v = db[key]
            for _, fn in ipairs(fns) do pcall(fn, v) end
        end
    end
end

local function CopyDefaults(dst, src)
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

-- 允许值校验（防御：被其它版本写入异常值时恢复到安全态）
local function ValidateEnums(db)
    local mode = db.AutoRotateMode
    if mode ~= "preset" and mode ~= "learn" and mode ~= "sequence" then
        db.AutoRotateMode = "preset"
    end
end

-- 数据迁移与“单一权威”落盘
local function MigrateIfNeeded(db)
    if type(db) ~= "table" then return end
    -- 统一 AutoRotate 运行期子表
    db.AutoRotate = db.AutoRotate or {}
    local ar = db.AutoRotate
    ar.LastRotationByRID = ar.LastRotationByRID or {}
    ar.SeqIndexByRID    = ar.SeqIndexByRID    or {}
    ar.StepByRID        = ar.StepByRID        or {}

    -- 迁移：旧字段 AutoRotateStepByRID → AutoRotate.StepByRID（一次性）
    if type(db.AutoRotateStepByRID) == "table" then
        for k, v in pairs(db.AutoRotateStepByRID) do
            if ar.StepByRID[k] == nil then
                ar.StepByRID[k] = v
            end
        end
        db.AutoRotateStepByRID = nil
    end

    -- 未来可在此扩展更多迁移（保持一次性、幂等）
    -- 移除已废弃的独立弹窗位置字段
    db.HistoryPopupPos = nil
    db.ClipboardPopupPos = nil
end

local function GetDB()
    _G.ADT_DB = CopyDefaults(_G.ADT_DB, DEFAULTS)
    -- 一次性迁移
    MigrateIfNeeded(_G.ADT_DB)
    -- 历史兼容：旧版本默认是 Alt（2），改为 Ctrl+D（3）。
    -- 仅作迁移用途；HoverHUD 不再使用 Alt 触发。
    if _G.ADT_DB and _G.ADT_DB.DuplicateKey == 2 then
        _G.ADT_DB.DuplicateKey = 3
    end
    -- 值校验（防御外部污染）
    ValidateEnums(_G.ADT_DB)
    return _G.ADT_DB
end

function ADT.GetDBBool(key)
    local db = GetDB()
    return not not db[key]
end

function ADT.GetDBValue(key)
    local db = GetDB()
    return db[key]
end

function ADT.SetDBValue(key, value)
    local db = GetDB()
    db[key] = value
    if ADT.Settings and ADT.Settings.Emit then
        ADT.Settings.Emit(key, value)
    end
end

function ADT.FlipDBBool(key)
    ADT.SetDBValue(key, not ADT.GetDBBool(key))
end

-- Frame 位置保存/恢复（单一权威）
function ADT.SaveFramePosition(dbKey, frame)
    if not (dbKey and frame and frame.GetPoint) then return end
    local point, relTo, relPoint, xOfs, yOfs = frame:GetPoint(1)
    if not point then return end
    local relName = relTo and relTo:GetName() or "UIParent"
    ADT.SetDBValue(dbKey, { point = point, rel = relName, relPoint = relPoint or point, x = xOfs or 0, y = yOfs or 0 })
end

function ADT.RestoreFramePosition(dbKey, frame, fallback)
    if not (dbKey and frame and frame.SetPoint) then return end
    local pos = ADT.GetDBValue(dbKey)
    frame:ClearAllPoints()
    if type(pos) == "table" and pos.point then
        local rel = _G[pos.rel or "UIParent"] or UIParent
        frame:SetPoint(pos.point, rel, pos.relPoint or pos.point, pos.x or 0, pos.y or 0)
    else
        if type(fallback) == "function" then
            fallback(frame)
        else
            frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
    end
end

-- Frame 尺寸保存/恢复（单一权威，独立于位置）
function ADT.SaveFrameSize(dbKey, frame)
    if not (dbKey and frame and frame.GetWidth) then return end
    local w, h = math.floor(frame:GetWidth() + 0.5), math.floor(frame:GetHeight() + 0.5)
    if w and h and w > 0 and h > 0 then
        ADT.SetDBValue(dbKey, { w = w, h = h })
    end
end

function ADT.RestoreFrameSize(dbKey, frame)
    if not (dbKey and frame and frame.SetSize) then return end
    local sz = ADT.GetDBValue(dbKey)
    if type(sz) == "table" and (sz.w and sz.h) then
        frame:SetSize(sz.w, sz.h)
    end
end

-- 调试打印（仅在 DebugEnabled 时输出到聊天框）
function ADT.IsDebugEnabled()
    return ADT.GetDBBool("DebugEnabled")
end

function ADT.DebugPrint(msg)
    if ADT.IsDebugEnabled() then
        print("ADT:", msg)
    end
end

-- 顶部美观提示（暴雪风格），带简单节流
do
    local lastMsg, lastT = nil, 0
    local function canShow(msg)
        local now = GetTime and GetTime() or 0
        if msg == lastMsg and (now - lastT) < 0.6 then
            return false
        end
        lastMsg, lastT = msg, now
        return true
    end

    local function AcquireNoticeFrame()
        local parent = (HouseEditorFrame and HouseEditorFrame:IsShown()) and HouseEditorFrame or UIParent
        local strata = (parent == HouseEditorFrame) and "TOOLTIP" or "FULLSCREEN_DIALOG"
        if ADT.NoticeFrame and ADT.NoticeFrame.SetParent then
            local f = ADT.NoticeFrame
            f:SetParent(parent)
            f:ClearAllPoints()
            f:SetPoint("TOP", parent, "TOP", 0, -120)
            f:SetFrameStrata(strata)
            local base = (parent.GetFrameLevel and parent:GetFrameLevel()) or 0
            pcall(f.SetFrameLevel, f, base + 1000)
            f:SetToplevel(true)
            return f
        end
        local f = CreateFrame("ScrollingMessageFrame", "ADT_NoticeFrame", parent)
        f:SetSize(1024, 64)
        f:SetPoint("TOP", parent, "TOP", 0, -120)
        f:SetFrameStrata(strata)
        local base = (parent.GetFrameLevel and parent:GetFrameLevel()) or 0
        pcall(f.SetFrameLevel, f, base + 1000)
        f:SetToplevel(true)
        f:SetJustifyH("CENTER")
        if GameFontHighlightLarge then f:SetFontObject(GameFontHighlightLarge)
        elseif GameFontNormalLarge then f:SetFontObject(GameFontNormalLarge) end
        f:SetShadowOffset(1, -1)
        f:SetFading(true)
        f:SetFadeDuration(0.5)
        f:SetTimeVisible(2.0)
        f:SetMaxLines(3)
        f:EnableMouse(false)
        ADT.NoticeFrame = f
        return f
    end

    -- kind: 'success' | 'error' | 'info'
    function ADT.Notify(msg, kind)
        if not msg or msg == "" then return end
        if not canShow(msg) then return end

        local color
        if kind == 'error' then
            local c = ChatTypeInfo and ChatTypeInfo.ERROR_MESSAGE
            color = c and { r = c.r, g = c.g, b = c.b } or { r = 1.0, g = 0.25, b = 0.25 }
        else
            -- 暴雪黄色信息
            local c = _G.YELLOW_FONT_COLOR or (ChatTypeInfo and ChatTypeInfo.SYSTEM)
            local r, g, b = 1, 0.82, 0
            if c then
                if c.r then r = c.r; g = c.g; b = c.b
                elseif c.GetRGB then r, g, b = c:GetRGB() end
            end
            color = { r = r, g = g, b = b }
        end

        local frame = AcquireNoticeFrame()
        if frame and frame.AddMessage then
            frame:AddMessage(tostring(msg), color.r, color.g, color.b)
            return
        end
        -- 兜底：在调试模式才打印
        ADT.DebugPrint(msg)
    end
end

-- 获取当前重复热键名
function ADT.GetDuplicateKeyName()
    -- 为兼容旧字段名，仍保留此函数，但仅返回用于 UI 显示的“按键文本”。
    -- 注意：索引 1/2 为历史兼容值，不影响 HoverHUD 的行为（固定为 Ctrl+D 覆盖绑定）。
    local index = ADT.GetDBValue("DuplicateKey") or 3
    if index == 3 then
        return (CTRL_KEY_TEXT and (CTRL_KEY_TEXT.."+D")) or "CTRL+D"
    end
end

-- Settings API：在暴雪设置中嵌入我们的独立 GUI（嵌入式注册方式）
local function RegisterSettingsCategory()
    local BlizzardPanel = CreateFrame("Frame", "ADTSettingsContainer", UIParent)
    BlizzardPanel:Hide()

    local category = Settings.RegisterCanvasLayoutCategory(BlizzardPanel, "AdvancedDecorationTools")
    Settings.RegisterAddOnCategory(category)

    BlizzardPanel:SetScript("OnShow", function(self)
        local Main = ADT and ADT.CommandDock and ADT.CommandDock.SettingsPanel
        if Main and Main.ShowUI then
            Main:Hide()
            Main:SetParent(self)
            Main:ClearAllPoints()
            Main:SetPoint("TOPLEFT", self, "TOPLEFT", -10, 6)
            Main:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
            Main:ShowUI("blizzard")
        end
    end)

    BlizzardPanel:SetScript("OnHide", function(self)
        local Main = ADT and ADT.CommandDock and ADT.CommandDock.SettingsPanel
        if Main then Main:Hide() end
    end)

    ADT.SettingsCategory = category
end

-- 初始化
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addonName)
    if addonName == ADDON_NAME then
        GetDB() -- 初始化 SavedVariables
        -- 在 SavedVariables 就位后，依据用户设置重新应用语言（确保持久化生效）
        if ADT.ApplyLocale and ADT.GetActiveLocale then
            ADT.ApplyLocale(ADT.GetActiveLocale())
            -- 关键修复：/reload 后分类/条目仍保留中文
            -- 原因：i18n 在早期以客户端语言初始化，随后 UI 在首次构建时
            -- 读取到了当时的 L 表并缓存到 CommandDock._sorted 中；
            -- 尽管此处再次 ApplyLocale 到用户选择的语言，但未重建 _sorted，
            -- 导致“通用/临时板/最近放置”等早期生成的分类仍使用旧文案。
            -- 解决：语言应用后立刻触发一次模块重建，确保一切显示文本都以
            -- 当前语言重新生成（符合“单一权威+DRY”）。
            if ADT.CommandDock and ADT.CommandDock.RebuildModules then
                ADT.CommandDock:RebuildModules()
            end
        end
        RegisterSettingsCategory()
        if ADT.Housing and ADT.Housing.LoadSettings then
            ADT.Housing:LoadSettings()
        end
        -- 关键：/reload 后确保自动旋转模块按持久化配置加载
        if ADT.AutoRotate and ADT.AutoRotate.LoadSettings then
            ADT.AutoRotate:LoadSettings()
        end
        -- 广播当前所有设置值，驱动已注册的 on-change 监听者（例如模块自身加载刷新）
        if ADT.Settings and ADT.Settings.ApplyAll then
            ADT.Settings.ApplyAll()
        end
        -- 若控制中心已构建，刷新一次分类与条目（避免语言切换后残留旧文案）
        if ADT.CommandDock and ADT.CommandDock.SettingsPanel then
            local Main = ADT.CommandDock.SettingsPanel
            -- 仅当 UI 已构建完毕（存在对象池与滚动容器）时刷新；否则等待真正打开面板时再刷新。
            local canRefresh = Main.ModuleTab and Main.ModuleTab.ScrollView
            if canRefresh then
                -- 重建完模块后刷新 UI 内容与布局
                if Main.RefreshCategoryList then Main:RefreshCategoryList() end
                if Main.RefreshFeatureList then Main:RefreshFeatureList() end
                if Main.RefreshLanguageLayout then Main:RefreshLanguageLayout(true) end
            end
        end
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
