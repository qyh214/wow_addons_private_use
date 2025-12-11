-- 指挥坞 GUI（简化版实现，文件名：gui.lua）
-- 说明：删除了 ChangelogTab/TabButton/最小化等不必要元素，仅保留
-- 左侧分类、中间功能列表、右侧预览等核心交互。

local ADDON_NAME, ADT = ...
if not ADT.IsToCVersionEqualOrNewerThan(110000) then return end

local L = ADT.L
local API = ADT.API
local CommandDock = ADT.CommandDock
local GetDBBool = ADT.GetDBBool

local Mixin = API.Mixin
local CreateFrame = CreateFrame
local DisableSharpening = API.DisableSharpening


-- 临时应急：将左侧分类栏改为独立弹窗（禁用滑出动效），定位与右侧面板同级，确保点击优先级。
-- 复原时将此常量改回 false 即可。
-- 关闭强制静态左窗（统一交由 LeftPanel.lua 构建并管理层级/命中）。
local USE_STATIC_LEFT_PANEL = (ADT.DockLeft and ADT.DockLeft.IsStatic and ADT.DockLeft.IsStatic()) or false

local Def = {
    BackgroundFile = "Interface/AddOns/AdvancedDecorationTools/Art/CommandDock/CommonFrameWithHeader.tga", -- [NEW] HD Background
    ButtonSize = 28,
    CategoryHeight = 22,
    WidgetGap = 14,
    PageHeight = 380,  -- 缩小高度：约10行文本+标题+边距
    CategoryGap = 10,  -- 缩小分类间距
    TabButtonHeight = 40,

    TextColorNormal = {215/255, 192/255, 163/255},
    -- 标题优雅淡金（深色背景下可读、不过分刺眼）
    TitleColorPaleGold = {0.95, 0.86, 0.55},
    TextColorHighlight = {1, 1, 1},
    TextColorNonInteractable = {148/255, 124/255, 102/255},
    TextColorDisabled = {0.5, 0.5, 0.5},
    TextColorReadable = {163/255, 157/255, 147/255},
    -- 右侧内容区域左侧统一内边距（从左侧容器右边框算起，需与左侧 Category 按钮到右边框的边距一致：Def.WidgetGap）
    -- 注意：实际读取请使用 GetRightPadding() 以保证与 Def.WidgetGap 一致。
    RightContentPaddingLeft = 14,
    -- 左侧分类：标题与数量的视觉间隔以及为数量预留的宽度
    CategoryLabelToCountGap = 8,
    CountTextWidthReserve = 22,
    -- 与 Entry 模板保持一致的左内边距（ADTSettingsPanelEntryTemplate 中文本的 x 偏移）
    EntryLabelLeftInset = 28,
    -- Header 左移微调（用于靠近渐变边缘，但不顶边）
    HeaderLeftNudge = 8,
    -- About(信息) 面板的纯文本行相对容器的额外左内边距（不使用图标位）
    AboutTextExtraLeft = 0,
    -- 高亮条边距与最小高度（配合 housing-basic-container）
    -- 语义：
    --   - HighlightTextPaddingLeft：高亮左边缘距离“文本起点”的预留像素，保证文本不贴框
    --   - HighlightRightInset：高亮右边缘距按钮右边缘的收缩像素，尽可能把右侧计数也框入
    HighlightTextPaddingLeft = 10,
    HighlightRightInset = 2,
    HighlightMinHeight = 18,
    -- 文本高亮左右统一内边距（用于静态左窗，以字符串宽度为准包裹）
    HighlightTextPadX = 6,
    -- 右侧视觉微调：因字体字形右侧外延/阴影，右边看起来会略宽；
    -- 这里提供 -2 的缺省补偿，让左右观感一致
    HighlightRightBias = -2,
    -- 右侧停靠相关：与屏幕右缘留白
    ScreenRightMargin = 0,
    -- 静态左窗与右侧面板左边框的对齐微调：0 表示严格相切，无重叠
    StaticRightAttachOffset = 0,
    LeftPanelPadTop = 14,
    LeftPanelPadBottom = 14,


    -- ================= Header/顶部区域可调参数（统一权威） =================
    HeaderHeight = 68,                 -- Header 高度
    HeaderTitleOffsetX = 22,           -- Header 标题 X 偏移
    HeaderTitleOffsetY = -10,          -- Header 标题 Y 偏移（负值为向下）
    -- 关闭按钮（UIPanelCloseButton）位置（锚到整体右上角，负值向内收）
    CloseBtnOffsetX = -1,
    CloseBtnOffsetY = -1,

    -- 放置清单按钮（PlacedDecorListButton）在 Header 内的位置/层级
    PlacedListBtnPoint = "LEFT",       -- 锚点（按钮自身）
    PlacedListBtnRelPoint = "LEFT",    -- 相对锚点（Header）
    PlacedListBtnOffsetX = 40,         -- X 偏移
    PlacedListBtnOffsetY = -1,          -- Y 偏移
    PlacedListBtnRaiseAboveBorder = 1, -- 提升到边框之上的 FrameLevel 偏移（0 表示不提升）

    -- ================= 中央滚动区域边距 =================
    -- 修复说明：内容区与背景的语义要分离。
    --  - ScrollViewInsetBottom：只给“内容”留出安全边距，避免项目压住底部装饰。
    --  - RightBGInsetBottom/CenterBGInsetBottom：背景应当铺满至边框内缘，取 0 贴边。
    ScrollViewInsetTop = 2,
    ScrollViewInsetBottom = 18,
    RightBGInsetRight = -2,            -- 右侧统一背景右侧 inset
    RightBGInsetBottom = 0,            -- 背景贴边，避免出现可见空隙
    CenterBGInsetBottom = 0,           -- 背景贴边，避免出现可见空隙

    -- ================= 列表空状态（Empty State）细节 =================
    -- 当分类为空时，第一行灰色提示与上方“标题分隔线”之间的额外间距（像素）
    EmptyStateTopGap = 6,

    -- ================= 左侧分类按钮细节 =================
    CategoryButtonLabelOffset = 9,     -- 文本左内边距（与数字角标对称）
    CategoryCountRightInset = 2,       -- 数字角标右内缩

    -- ================= 子面板动效（统一权威配置） =================
    -- 说明：尽量避免硬编码，所有与 SubPanel 展开/收起的动效参数集中在此，便于后续统一微调。
    SubPanelFX = {
        enabled = true,                -- 是否启用子面板开合动效
        originPoint = "TOP",           -- 缩放原点，使展开/收起从上缘发生
        showDuration = 0.18,           -- 展开时长（秒）
        hideDuration = 0.16,           -- 收起时长（秒）
        smoothingIn = "OUT",           -- 展开缓动：前快后慢
        smoothingOut = "IN",           -- 收起缓动：前慢后快
        scaleMin = 0.001,              -- 近似 0 的缩放下限，避免 0 引发奇异值
        scaleMax = 1.0,                -- 目标缩放
        fade = true,                   -- 同步透明度渐变
        fadeFrom = 0.0,                -- 展开起始透明度
        fadeTo = 1.0,                  -- 展开目标透明度
        emptyQuietSec = 0.12,          -- 判定“空内容→收起”所需的静默时间，防抖避免模式切换反复收放
    },
}

-- 单一权威：右侧内容起始的左内边距，强制与左侧 Category 的外边距一致
local function GetRightPadding()
    return Def.WidgetGap
end

-- 导出 DockUI 共享配置与统一边距函数，供子模块复用
ADT.DockUI = ADT.DockUI or {}
ADT.DockUI.Def = Def
ADT.DockUI.GetRightPadding = GetRightPadding

-- 面板显隐：仅控制 DockUI 的“右侧主体 + 左侧列表”，不影响 SubPanel
-- 目的：当用户关闭“默认开启设置面板”时，仍允许 SubPanel/清单弹窗独立显示。
do
    local function SetShownSafe(f, shown)
        if not f then return end
        if shown then f:Show() else f:Hide() end
    end

    -- 单一权威：外部仅调用这一个入口控制 Dock 主体是否可见
    function ADT.DockUI.SetMainPanelsVisible(shown)
        local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
        if not main then return end
        local vis = not not shown

        -- 左侧：静态左窗容器（按钮实际挂在 LeftSlideContainer）
        SetShownSafe(main.LeftSlideContainer, vis)
        SetShownSafe(main.LeftPanelContainer, vis)

        -- 右侧：Header/背景/中央滚动区/边框
        SetShownSafe(main.Header, vis)
        SetShownSafe(main.RightUnifiedBackground, vis)
        SetShownSafe(main.CenterBackground, vis)
        if main.ModuleTab then SetShownSafe(main.ModuleTab, vis) end
        if main.CentralSection then SetShownSafe(main.CentralSection, vis) end
        if main.BorderFrame then SetShownSafe(main.BorderFrame, vis) end

        -- 注意：SubPanel 由业务控制，保持不变（避免“跟随主体一起被隐藏”）。
        ADT.DockUI._mainPanelsVisible = vis
    end

    -- 查询当前 Dock 主体是否可见（独立于容器显示状态）
    function ADT.DockUI.AreMainPanelsVisible()
        return not not ADT.DockUI._mainPanelsVisible
    end

    -- 根据数据库设置应用默认显隐（进入编辑器或用户切换选项时调用）
    function ADT.DockUI.ApplyPanelsDefaultVisibility()
        local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
        if not main then return end
        -- EnableDockAutoOpenInEditor 为 false 表示不自动展示 Dock 主体
        local v = ADT and ADT.GetDBValue and ADT.GetDBValue('EnableDockAutoOpenInEditor')
        local shouldShowMainPanels = (v ~= false)
        ADT.DockUI.SetMainPanelsVisible(shouldShowMainPanels)
    end
end

-- 提前提供一个“请求子面板自适应高度”的稳定入口（占位包装器）。
-- 目的：解决 /reload 后 HoverHUD 先于 SubPanel 初始化时，
--       首次 RecalculateHeight 触发的请求被丢失的问题。
-- 真实实现仍在 SubPanel.lua 内部生成（单一权威），
-- 此处仅做一次性延迟转发，避免业务层出现空指针。
if not ADT.DockUI.RequestSubPanelAutoResize then
    ADT.DockUI.RequestSubPanelAutoResize = function()
        -- 优先直接找到 SubPanel 实例并调用其单一权威入口，避免任何重复实现。
        local main = ADT.CommandDock and ADT.CommandDock.SettingsPanel
        local sub = main and (main.SubPanel or (main.EnsureSubPanel and main:EnsureSubPanel()))
        local caller = sub and sub._ADT_RequestAutoResize
        if type(caller) == "function" then
            caller()
            return
        end
        -- 若 SubPanel 尚未完成构建，延后半帧重试一次（最多一次）。
        if not (ADT and ADT.DockUI) then return end
        if ADT.DockUI.__resizeRetryScheduled then return end
        ADT.DockUI.__resizeRetryScheduled = true
        C_Timer.After(0.05, function()
            if ADT and ADT.DockUI then ADT.DockUI.__resizeRetryScheduled = nil end
            local main2 = ADT.CommandDock and ADT.CommandDock.SettingsPanel
            local sub2 = main2 and (main2.SubPanel or (main2.EnsureSubPanel and main2:EnsureSubPanel()))
            local caller2 = sub2 and sub2._ADT_RequestAutoResize
            if type(caller2) == "function" then caller2() end
        end)
    end
end

-- 依据“实际分类文本宽度”动态计算左侧栏目标宽度（单一权威）
-- 说明：不再使用按语种的固定值；改为测量当前语言下所有分类标题的像素宽度，
--       再加上控件自身的左右留白，得到最小充分宽度。
local function ComputeSideSectionWidth()
    return (ADT.DockLeft and ADT.DockLeft.ComputeSideSectionWidth and ADT.DockLeft.ComputeSideSectionWidth()) or 180
end

-- 导出侧栏宽度计算（单一权威）
ADT.DockUI.ComputeSideSectionWidth = ComputeSideSectionWidth

-- Dock 调试设施（按需启用，不默认刷屏）
do
    local strataIndex = {
        BACKGROUND = 0, LOW = 1, MEDIUM = 2, HIGH = 3, DIALOG = 4,
        FULLSCREEN = 5, FULLSCREEN_DIALOG = 6, TOOLTIP = 7,
    }
    local function SIdx(s) return strataIndex[tostring(s or "")] or -1 end

    local function FrameInfo(f)
        if not f then return "<nil>" end
        local n = f.GetName and f:GetName() or "<anon>"
        local s = f.GetFrameStrata and f:GetFrameStrata() or "?"
        local l = f.GetFrameLevel and f:GetFrameLevel() or -1
        local m = f.IsMouseEnabled and f:IsMouseEnabled() and 1 or 0
        local v = f.IsVisible and f:IsVisible() and 1 or 0
        return string.format("%s strata=%s(%d) level=%d mouse=%d vis=%d", n, tostring(s), SIdx(s), l, m, v)
    end

    local traceTicker, traceOn
    local function traceTick()
        if not (ADT and ADT.DebugPrint) then return end
        local focus = GetMouseFocus and GetMouseFocus() or nil
        local focusName = focus and (focus.GetName and focus:GetName()) or tostring(focus)
        local L = MainFrame and MainFrame.LeftSlideContainer
        local H = MainFrame and MainFrame.LeftSlideHandle
        local R = MainFrame and MainFrame.RightSection
        ADT.DebugPrint(string.format("[DockTrace] focus=%s", tostring(focusName)))
        if L then ADT.DebugPrint("[DockTrace] LeftSlide  "..FrameInfo(L)) end
        if H then ADT.DebugPrint("[DockTrace] LeftHandle "..FrameInfo(H)) end
        if R then ADT.DebugPrint("[DockTrace] RightSect  "..FrameInfo(R)) end
    end

    function ADT.DockUI.SetTrace(state)
        traceOn = not not state
        if traceOn and not traceTicker then
            traceTicker = C_Timer.NewTicker(0.25, traceTick)
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockTrace] 开启 (0.25s)") end
        elseif (not traceOn) and traceTicker then
            traceTicker:Cancel(); traceTicker = nil
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockTrace] 关闭") end
        end
    end

    function ADT.DockUI.Diag(reason)
        if ADT and ADT.DebugPrint then
            ADT.DebugPrint("[DockDiag] reason="..tostring(reason))
            traceTick()
        end
    end

    function ADT.DockUI.Stack()
        if not (ADT and ADT.DebugPrint) then return end
        if not GetMouseFoci then
            ADT.DebugPrint("[DockStack] GetMouseFoci 不可用（需要 11.0+）")
            return
        end
        local list = {GetMouseFoci()}
        ADT.DebugPrint("[DockStack] size="..tostring(#list))
        for i, f in ipairs(list) do
            local name = f and (f.GetName and f:GetName()) or tostring(f)
            local s = f and (f.GetFrameStrata and f:GetFrameStrata()) or "?"
            local l = f and (f.GetFrameLevel and f:GetFrameLevel()) or -1
            local m = f and (f.IsMouseEnabled and f:IsMouseEnabled()) and 1 or 0
            ADT.DebugPrint(string.format("[DockStack] %02d %s strata=%s lvl=%d mouse=%d", i, tostring(name), tostring(s), l, m))
        end
    end
    -- 便捷命令：/adtdockstack 打印鼠标命中栈
    SLASH_ADT_DOCKSTACK1 = "/adtdockstack"
    SlashCmdList["ADT_DOCKSTACK"] = function()
        if ADT and ADT.DockUI and ADT.DockUI.Stack then ADT.DockUI.Stack() end
    end

    -- 幽灵框体扫描：/adtghost
    -- 原理：遍历可见且可拦截鼠标的 Frame，找出覆盖“左侧分类栏区域”的对象并打印来源。
    local function RectOverlap(aL, aR, aT, aB, bL, bR, bT, bB)
        if not (aL and aR and aT and aB and bL and bR and bT and bB) then return false end
        if aL >= aR or bL >= bR or aB >= aT or bB >= bT then return false end
        return not (aR <= bL or aL >= bR or aT <= bB or aB >= bT)
    end
    local function ScanGhosts()
        local main = CommandDock and CommandDock.SettingsPanel
        if not (main and main.Header and main.LeftSection) then
            ADT.DebugPrint("[Ghost] 主面板未就绪")
            return
        end
        local zoneL, zoneR, zoneT, zoneB
        zoneL = main.LeftSection:GetLeft() or 0
        zoneR = main.LeftSection:GetRight() or 0
        zoneT = (main.Header and main.Header:GetBottom()) or (main:GetTop() or 0)
        zoneB = main:GetBottom() or 0
        ADT.DebugPrint(string.format("[Ghost] LeftZone L/R/T/B = %.1f/%.1f/%.1f/%.1f", zoneL, zoneR, zoneT, zoneB))
        local i, f = 0
        f = EnumerateFrames()
        local hits = 0
        while f do
            i = i + 1
            if f.IsShown and f:IsShown() and f.IsMouseEnabled and f:IsMouseEnabled() then
                local L = f.GetLeft and f:GetLeft()
                local R = f.GetRight and f:GetRight()
                local T = f.GetTop and f:GetTop()
                local B = f.GetBottom and f:GetBottom()
                if RectOverlap(L, R, T, B, zoneL, zoneR, zoneT, zoneB) then
                    hits = hits + 1
                    local name = (f.GetName and f:GetName()) or tostring(f)
                    local strata = (f.GetFrameStrata and f:GetFrameStrata()) or "?"
                    local lvl = (f.GetFrameLevel and f:GetFrameLevel()) or -1
                    ADT.DebugPrint(string.format("[Ghost] #%d %s strata=%s lvl=%d L/R/T/B=%.1f/%.1f/%.1f/%.1f",
                        hits, tostring(name), tostring(strata), lvl, L or -1, R or -1, T or -1, B or -1))
                end
            end
            f = EnumerateFrames(f)
        end
        if hits == 0 then ADT.DebugPrint("[Ghost] 未发现可拦截鼠标的重叠框体。") end
    end
    SLASH_ADT_GHOST1 = "/adtghost"
    SlashCmdList["ADT_GHOST"] = function()
        pcall(ScanGhosts)
    end

    -- 隔离模式：/adtdockisolate on|off
    -- 作用：暂时关闭右侧所有会吃鼠标的层（MouseBlocker/SubPanel 等），便于验证左侧是否恢复可点。
    local _isolated = false
    local function ApplyIsolation(state)
        _isolated = state and true or false
        local m = CommandDock and CommandDock.SettingsPanel
        if not m then return end
        -- 右侧鼠标阻挡层
        if m.MouseBlocker then
            m.MouseBlocker:SetShown(not _isolated)
            m.MouseBlocker:EnableMouse(not _isolated)
        end
        -- 子面板
        if m.SubPanel then
            -- 使用统一入口以避免动效抖动
            if m.SetSubPanelShown then
                m:SetSubPanelShown(not _isolated and m.SubPanel:IsShown())
            else
                m.SubPanel:SetShown(not _isolated and m.SubPanel:IsShown())
            end
            if m.SubPanel.BorderFrame then m.SubPanel.BorderFrame:EnableMouse(false) end
        end
        -- 统一背景仅为贴图，不吃鼠标；此处不处理
        ADT.DebugPrint("[Dock] Isolation="..tostring(_isolated))
    end
    SLASH_ADT_DOCKISOLATE1 = "/adtdockisolate"
    SlashCmdList["ADT_DOCKISOLATE"] = function(msg)
        msg = tostring(msg or ""):lower()
        if msg == "on" or msg == "1" or msg == "true" then
            ApplyIsolation(true)
        elseif msg == "off" or msg == "0" or msg == "false" then
            ApplyIsolation(false)
        else
            ADT.DebugPrint("用法：/adtdockisolate on|off")
        end
    end
end

local MainFrame = CreateFrame("Frame", nil, UIParent, "ADTSettingsPanelLayoutTemplate")
CommandDock.SettingsPanel = MainFrame
do
    local frameKeys = {"LeftSection", "RightSection", "CentralSection", "SideTab", "TabButtonContainer", "ModuleTab", "ChangelogTab", "TopTabOwner"}
    for _, key in ipairs(frameKeys) do
        MainFrame[key] = MainFrame.FrameContainer[key]
    end
    -- 顶部标签回退为左右布局：隐藏顶栏托管容器，避免遮挡
    if MainFrame.TopTabOwner then MainFrame.TopTabOwner:Hide() end

    -- 创建专用边框Frame（确保在所有子内容之上）
    local BorderFrame = CreateFrame("Frame", nil, MainFrame)
    BorderFrame:SetAllPoints(MainFrame)
    BorderFrame:SetFrameLevel(MainFrame:GetFrameLevel() + 100) -- 确保边框在最上层
    MainFrame.BorderFrame = BorderFrame
    BorderFrame:EnableMouse(false) -- 仅视觉，不拦截鼠标
    
    -- 使用 housing-wood-frame Atlas 九宫格边框
    local border = BorderFrame:CreateTexture(nil, "OVERLAY")
    -- 让右侧边框严格贴合自身容器，避免“向左溢出”覆盖左窗
    border:SetPoint("TOPLEFT", BorderFrame, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", BorderFrame, "BOTTOMRIGHT", 0, 0)
    border:SetAtlas("housing-wood-frame")
    border:SetTextureSliceMargins(16, 16, 16, 16)
    border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    BorderFrame.WoodFrame = border

    -- 使用标准暴雪关闭按钮（与 housing 边框协调）
    local CloseButton = CreateFrame("Button", nil, BorderFrame, "UIPanelCloseButton")
    MainFrame.CloseButton = CloseButton
    -- 锚到边框容器右上角，并向内收缩，避免跑到面板外侧
    CloseButton:ClearAllPoints()
    CloseButton:SetPoint("TOPRIGHT", BorderFrame, "TOPRIGHT", Def.CloseBtnOffsetX, Def.CloseBtnOffsetY)
    -- 防御：确保层级在木框之上，且不会吃掉左侧面板的鼠标
    CloseButton:SetFrameLevel((BorderFrame:GetFrameLevel() or 0) + 2)
    CloseButton:SetScript("OnClick", function()
        MainFrame:Hide()
        if ADT.UI and ADT.UI.PlaySoundCue then
            ADT.UI.PlaySoundCue('ui.checkbox.off')
        end
    end)
end
--
-- 将暴雪家宅编辑器中的“放置的装饰清单”按钮（PlacedDecorListButton）
-- 采纳到 ADT 的 Header 内（偏左位置）。
-- 单一权威：采纳/恢复逻辑仅在本文件维护，外部只需触发 DockUI.Attach/Restore。
--
ADT.DockUI = ADT.DockUI or {}
do
    -- 回归“只搬运官方按钮”的实现：不创建代理、不屏蔽官方逻辑。
    local OrigParent, OrigStrata
    local OrigPoint -- {p, rel, rp, x, y}
    local Attached = false

    local function GetPlacedListButton()
        local hf = _G.HouseEditorFrame
        local expert = hf and hf.ExpertDecorModeFrame
        local btn = expert and expert.PlacedDecorListButton
        return btn, expert
    end

    local function _IsExpertMode()
        local HEM = C_HouseEditor and C_HouseEditor.GetActiveHouseEditorMode and C_HouseEditor.GetActiveHouseEditorMode()
        return HEM == (Enum and Enum.HouseEditorMode and Enum.HouseEditorMode.ExpertDecor)
    end

    local function SaveOriginal(btn)
        if OrigParent then return end
        OrigParent = btn:GetParent()
        OrigStrata = btn:GetFrameStrata()
        if btn:GetNumPoints() > 0 then
            local p, rel, rp, x, y = btn:GetPoint(1)
            OrigPoint = { p = p, rel = rel, rp = rp, x = x, y = y }
        end
    end

    local function RestoreToOriginal()
        local btn = GetPlacedListButton()
        if not (btn and OrigParent) then return end
        btn:ClearAllPoints()
        btn:SetParent(OrigParent)
        if OrigPoint then
            btn:SetPoint(OrigPoint.p or "CENTER", OrigPoint.rel or OrigParent, OrigPoint.rp or OrigPoint.p, tonumber(OrigPoint.x) or 0, tonumber(OrigPoint.y) or 0)
        end
        if OrigStrata then btn:SetFrameStrata(OrigStrata) end
        Attached = false
    end

    local function AttachIntoHeader()
        if not (MainFrame and MainFrame.Header) then return end
        local btn = GetPlacedListButton()
        if not btn then return end
        SaveOriginal(btn)
        btn:ClearAllPoints()
        btn:SetParent(MainFrame.Header)
        btn:SetPoint(Def.PlacedListBtnPoint or "LEFT", MainFrame.Header, Def.PlacedListBtnRelPoint or (Def.PlacedListBtnPoint or "LEFT"), Def.PlacedListBtnOffsetX or 40, Def.PlacedListBtnOffsetY or 0)
        -- 提升层级避免被边框覆盖
        local strata = MainFrame:GetFrameStrata() or "FULLSCREEN_DIALOG"
        btn:SetFrameStrata(strata)
        if MainFrame.BorderFrame and Def.PlacedListBtnRaiseAboveBorder and Def.PlacedListBtnRaiseAboveBorder > 0 then
            btn:SetFrameLevel((MainFrame.BorderFrame:GetFrameLevel() or 0) + Def.PlacedListBtnRaiseAboveBorder)
        end
        btn:Show()
        Attached = true
    end

    -- 对外：只做“附着/恢复”，不更改官方逻辑
    function ADT.DockUI.AttachPlacedListButton() AttachIntoHeader() end
    function ADT.DockUI.RestorePlacedListButton() RestoreToOriginal() end

    -- 事件驱动：进入家宅编辑器时附着；退出时恢复
    local EL = CreateFrame("Frame")
    EL:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    EL:RegisterEvent("ADDON_LOADED")
    EL:RegisterEvent("PLAYER_LOGIN")
    EL:SetScript("OnEvent", function(_, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "Blizzard_HouseEditor" then
            AttachIntoHeader()
        elseif event == "PLAYER_LOGIN" then
            AttachIntoHeader()
        elseif event == "HOUSE_EDITOR_MODE_CHANGED" then
            if C_HouseEditor and C_HouseEditor.IsHouseEditorActive and C_HouseEditor.IsHouseEditorActive() and _IsExpertMode() then
                AttachIntoHeader()
            else
                RestoreToOriginal()
            end
        end
    end)
end
local SearchBox
local CategoryHighlight
local ActiveCategoryInfo = {}

-- 动态收敛左侧分类容器高度
--[[ 已迁移至 LeftPanel.lua
function MainFrame:UpdateLeftSectionHeight()
    local LeftSection = self.LeftSection
    if not LeftSection then return end
    local n = 0
    if self.primaryCategoryPool and self.primaryCategoryPool.EnumerateActive then
        for _ in self.primaryCategoryPool:EnumerateActive() do n = n + 1 end
    end
    local topPad = Def.WidgetGap or 14
    local catH = Def.CategoryHeight or Def.ButtonSize or 28
    local height = math.max(catH, topPad + n * catH + topPad)
    LeftSection:SetHeight(height)
end]]

-- 启用“上下布局 + 顶部标签”
local USE_TOP_TABS = false

-- 顶部标签系统初始化（基于 TabSystemOwner + TabSystemTopButtonTemplate）
function MainFrame:InitTopTabs()
    if not USE_TOP_TABS then return end
    if not (self.TopTabOwner and self.TopTabOwner.TabSystem) then return end

    self.TopTabOwner:SetTabSystem(self.TopTabOwner.TabSystem)

    self.__tabKeyFromID = {}
    self.__tabIDFromKey = {}

    local list = CommandDock:GetSortedModules() or {}
    for _, info in ipairs(list) do
        local tabID = self.TopTabOwner:AddNamedTab(info.categoryName)
        self.__tabKeyFromID[tabID] = info.key
        self.__tabIDFromKey[info.key] = tabID

        -- 捕获每次循环的局部值，避免闭包引用同一 upvalue
        local catKey = info.key
        local catType = info.categoryType

        -- 选中回调：按分类类型分派到现有渲染函数；若内容未初始化则缓存待应用
        self.TopTabOwner:SetTabCallback(tabID, function(isUserAction)
            if not (self.ModuleTab and self.ModuleTab.ScrollView) then
                self.__pendingTabKey = catKey
                return
            end
            if catType == 'decorList' then
                self:ShowDecorListCategory(catKey)
            elseif catType == 'about' then
                self:ShowAboutCategory(catKey)
            else
                self:ShowSettingsCategory(catKey)
            end
        end)
    end

    -- 记录待应用默认标签，等内容区创建后再选中
    self.__pendingTabKey = (ADT and ADT.GetDBValue and ADT.GetDBValue('LastCategoryKey')) or 'Housing'
end

-- 空壳下方拼接弹窗：实现迁移至独立模块 src/dock/SubPanel.lua

function MainFrame:ApplyInitialTabSelection()
    if not (USE_TOP_TABS and self.TopTabOwner and self.__tabIDFromKey) then return end
    if not (self.ModuleTab and self.ModuleTab.ScrollView) then return end
    local key = self.__pendingTabKey or 'Housing'
    local id = self.__tabIDFromKey[key] or 1
    self.TopTabOwner:SetTab(id)
    self.__pendingTabKey = nil
end


-- 取消通用“贴图换肤”函数，全面改用暴雪内置 Atlas/模板

local function SetTexCoord(obj, x1, x2, y1, y2)
    obj:SetTexCoord(x1/1024, x2/1024, y1/1024, y2/1024)
end

local function SetTextColor(obj, color)
    obj:SetTextColor(color[1], color[2], color[3])
end

local function CreateNewFeatureMark(button, smallDot)
    local newTag = button:CreateTexture(nil, "OVERLAY")
    newTag:SetTexture("Interface/AddOns/AdvancedDecorationTools/Art/CommandDock/NewFeatureTag", nil, nil, smallDot and "TRILINEAR" or "LINEAR")
    newTag:SetSize(16, 16)
    newTag:SetPoint("RIGHT", button, "LEFT", 0, 0)
    newTag:Hide()
    if smallDot then
        newTag:SetTexCoord(0.5, 1, 0, 1)
    else
        newTag:SetTexCoord(0, 0.5, 0, 1)
    end
    return newTag
end

local function CreateDivider(frame, width)
    local div = frame:CreateTexture(nil, "OVERLAY")
    div:SetSize(width, 8)
    div:SetAtlas("house-upgrade-header-divider-horz")
    return div
end


local MakeFadingObject
do
    local FadeMixin = {}

    local function FadeIn_OnUpdate(self, elapsed)
        self.alpha = self.alpha + self.fadeSpeed * elapsed
        if self.alpha >= self.fadeInAlpha then
            self:SetScript("OnUpdate", nil)
            self.alpha = self.fadeInAlpha
        end
        self:SetAlpha(self.alpha)
    end

    local function FadeOut_OnUpdate(self, elapsed)
        self.alpha = self.alpha - self.fadeSpeed * elapsed
        if self.alpha <= self.fadeOutAlpha then
            self:SetScript("OnUpdate", nil)
            self.alpha = self.fadeOutAlpha
            if self.hideAfterFadeOut then
                self:Hide()
            end
        end
        self:SetAlpha(self.alpha)
    end

    function FadeMixin:FadeIn(instant)
        if instant then
            self.alpha = 1
            self:SetScript("OnUpdate", nil)
        else
            self.alpha = self:GetAlpha()
            self:SetScript("OnUpdate", FadeIn_OnUpdate)
        end
        self:Show()
    end

    function FadeMixin:FadeOut()
        self.alpha = self:GetAlpha()
        self:SetScript("OnUpdate", FadeOut_OnUpdate)
    end

    function FadeMixin:SetFadeInAlpha(alpha)
        if alpha <= 0.099 then
            self.fadeInAlpha = 1
        else
            self.fadeInAlpha = alpha
        end
    end

    function FadeMixin:SetFadeOutAlpha(alpha)
        if alpha <= 0.01 then
            self.fadeOutAlpha = 0
            self.hideAfterFadeOut = true
        else
            self.fadeOutAlpha = alpha
            self.hideAfterFadeOut = false
        end
    end

    function FadeMixin:SetFadeSpeed(fadeSpeed)
        self.fadeSpeed = fadeSpeed
    end

    function MakeFadingObject(obj)
        Mixin(obj, FadeMixin)
        obj:SetFadeOutAlpha(0)
        obj:SetFadeInAlpha(1)
        obj:SetFadeSpeed(5)
        obj.alpha = 1
    end
end


-- ============================================================================
-- 自定义下拉菜单系统（使用 SettingsPanel.png 素材）
-- ============================================================================
local ADTDropdownMenu
do
    -- 将常量存储在菜单对象上，避免闭包问题
    local MENU_WIDTH = 160
    local ITEM_HEIGHT = 20   -- 下拉项更矮，视觉更精致
    local PADDING = 6
    
    -- 菜单项 Mixin
    local DropdownItemMixin = {}
    
    function DropdownItemMixin:OnEnter()
        self.Highlight:Show()
        SetTextColor(self.Text, Def.TextColorHighlight)
    end
    
    function DropdownItemMixin:OnLeave()
        self.Highlight:Hide()
        SetTextColor(self.Text, { 0.922, 0.871, 0.761 })
    end
    
    function DropdownItemMixin:OnClick()
        if self.onClickFunc then
            self.onClickFunc()
        end
        ADTDropdownMenu:Hide()
    end
    
    function DropdownItemMixin:SetSelected(selected)
        self.selected = selected
        if self.Check then
            self.Check:SetShown(selected)
        end
    end
    
    function DropdownItemMixin:SetText(text)
        self.Text:SetText(text)
    end
    
    -- 创建单个菜单项
    local function CreateDropdownItem(parent)
        local f = CreateFrame("Button", nil, parent)
        Mixin(f, DropdownItemMixin)
        f:SetSize(MENU_WIDTH - 2 * PADDING, ITEM_HEIGHT)
        
        -- 高亮背景
        f.Highlight = f:CreateTexture(nil, "BACKGROUND")
        f.Highlight:SetAllPoints(true)
        f.Highlight:SetColorTexture(1, 0.82, 0, 0.15)
        f.Highlight:Hide()
        
        -- 单选按钮：最小化复选框 + 黄色对勾（使用暴雪 Atlas）
        f.Radio = f:CreateTexture(nil, "ARTWORK")
        f.Radio:SetSize(14, 14)
        f.Radio:SetPoint("LEFT", f, "LEFT", 4, 0)
        f.Radio:SetAtlas("checkbox-minimal")
        DisableSharpening(f.Radio)
        f.Check = f:CreateTexture(nil, "OVERLAY")
        f.Check:SetPoint("CENTER", f.Radio, "CENTER", 0, 0)
        f.Check:SetSize(12, 12)
        f.Check:SetAtlas("common-icon-checkmark-yellow")
        f.Check:Hide()
        
        -- 文本
        f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.Text:SetPoint("LEFT", f.Radio, "RIGHT", 4, 0)
        f.Text:SetPoint("RIGHT", f, "RIGHT", -4, 0)
        f.Text:SetJustifyH("LEFT")
        SetTextColor(f.Text, { 0.922, 0.871, 0.761 })
        
        f:SetScript("OnEnter", f.OnEnter)
        f:SetScript("OnLeave", f.OnLeave)
        f:SetScript("OnClick", f.OnClick)
        
        return f
    end
    
    -- 创建下拉菜单主框架
    ADTDropdownMenu = CreateFrame("Frame", "ADTDropdownMenuFrame", UIParent)
    -- 重要：在编辑器模式下，SettingsPanel 会提升到 "TOOLTIP" 层级。
    -- 若下拉菜单仅为 FULLSCREEN_DIALOG，则会被面板遮挡，导致“看似没弹出”。
    -- 因此统一使用最高层级 TOOLTIP，确保始终在面板之上。
    ADTDropdownMenu:SetFrameStrata("TOOLTIP")
    ADTDropdownMenu:SetFrameLevel(100)
    ADTDropdownMenu:Hide()
    ADTDropdownMenu:EnableMouse(true)
    ADTDropdownMenu:SetClampedToScreen(true)
    
    -- 使用九宫格背景（SettingsPanel.png 左上角区域）
    -- 根据图片素材坐标设置九宫格背景
    local bg = ADTDropdownMenu:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    -- 使用暴雪通用面板背景
    bg:SetAtlas("housing-basic-panel-background")
    bg:SetVertexColor(1, 1, 1)
    ADTDropdownMenu.Background = bg
    
    -- 金色边框（使用九宫格）
    local borderSize = 3
    local borders = {}
    for i = 1, 4 do
        borders[i] = ADTDropdownMenu:CreateTexture(nil, "BORDER")
        borders[i]:SetColorTexture(0.6, 0.5, 0.3)
    end
    -- 上边框
    borders[1]:SetPoint("TOPLEFT", ADTDropdownMenu, "TOPLEFT", 0, 0)
    borders[1]:SetPoint("TOPRIGHT", ADTDropdownMenu, "TOPRIGHT", 0, 0)
    borders[1]:SetHeight(borderSize)
    -- 下边框
    borders[2]:SetPoint("BOTTOMLEFT", ADTDropdownMenu, "BOTTOMLEFT", 0, 0)
    borders[2]:SetPoint("BOTTOMRIGHT", ADTDropdownMenu, "BOTTOMRIGHT", 0, 0)
    borders[2]:SetHeight(borderSize)
    -- 左边框
    borders[3]:SetPoint("TOPLEFT", ADTDropdownMenu, "TOPLEFT", 0, 0)
    borders[3]:SetPoint("BOTTOMLEFT", ADTDropdownMenu, "BOTTOMLEFT", 0, 0)
    borders[3]:SetWidth(borderSize)
    -- 右边框
    borders[4]:SetPoint("TOPRIGHT", ADTDropdownMenu, "TOPRIGHT", 0, 0)
    borders[4]:SetPoint("BOTTOMRIGHT", ADTDropdownMenu, "BOTTOMRIGHT", 0, 0)
    borders[4]:SetWidth(borderSize)
    ADTDropdownMenu.Borders = borders
    
    ADTDropdownMenu.items = {}
    ADTDropdownMenu.itemPool = {}
    
    function ADTDropdownMenu:AcquireItem()
        local item = table.remove(self.itemPool)
        if not item then
            item = CreateDropdownItem(self)
        end
        item:Show()
        return item
    end
    
    function ADTDropdownMenu:ReleaseAllItems()
        for _, item in ipairs(self.items) do
            item:Hide()
            table.insert(self.itemPool, item)
        end
        wipe(self.items)
    end
    
    function ADTDropdownMenu:ShowMenu(owner, options, dbKey, toggleFunc)
        ADT.DebugPrint("[Dropdown] ShowMenu called, dbKey=" .. tostring(dbKey) .. ", options count=" .. tostring(#options))
        self:ReleaseAllItems()
        
        local numOptions = #options
        local menuHeight = numOptions * ITEM_HEIGHT + 2 * PADDING
        
        ADT.DebugPrint("[Dropdown] Setting size: " .. MENU_WIDTH .. "x" .. menuHeight)
        self:SetSize(MENU_WIDTH, menuHeight)
        
        -- 记录归属者，便于“点外面关闭”时排除自身与触发按钮
        self.owner = owner

        -- 定位到按钮下方
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -4)
        
        -- 创建菜单项
        local currentValue = ADT.GetDBValue(dbKey)
        ADT.DebugPrint("[Dropdown] Current value: " .. tostring(currentValue))
        for i, opt in ipairs(options) do
            local item = self:AcquireItem()
            item:SetText(opt.text)
            item:SetSelected(currentValue == opt.value)
            item:SetPoint("TOPLEFT", self, "TOPLEFT", PADDING, -PADDING - (i - 1) * ITEM_HEIGHT)
            
            item.onClickFunc = function()
                ADT.SetDBValue(dbKey, opt.value, true)
                if toggleFunc then
                    toggleFunc(opt.value)
                end
                if owner.UpdateDropdownLabel then
                    owner:UpdateDropdownLabel()
                end
                if MainFrame.UpdateSettingsEntries then
                    MainFrame:UpdateSettingsEntries()
                end
            end
            
            table.insert(self.items, item)
        end
        
        -- 再次确保层级足够高（在某些 UI 改动后防御性设置）
        self:SetFrameStrata("TOOLTIP")
        self:SetFrameLevel( max( (owner and owner:GetFrameLevel() or 0) + 10, 100) )

        ADT.DebugPrint("[Dropdown] Showing menu frame")
        self:Show()
        ADT.DebugPrint("[Dropdown] Menu frame IsShown: " .. tostring(self:IsShown()))

        -- 由于点击按钮时鼠标仍处于按下状态，会导致“立即关闭”。
        -- 这里等待一次鼠标松开，再开始侦测点击外部以关闭。
        self.waitRelease = true
        self:SetScript("OnUpdate", function()
            -- 首先等待一次任意键松开，避免首帧被立刻关闭
            if self.waitRelease then
                if not IsMouseButtonDown("LeftButton") and not IsMouseButtonDown("RightButton") then
                    self.waitRelease = false
                end
                return
            end

            -- 鼠标按下，且既不在菜单上也不在触发按钮上，则关闭
            if (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton"))
                and not self:IsMouseOver()
                and not (self.owner and self.owner:IsMouseOver()) then
                self:Hide()
            end
        end)
    end
    
    ADTDropdownMenu:SetScript("OnHide", function(self)
        self:ReleaseAllItems()
        self:SetScript("OnUpdate", nil)
        self.owner = nil
        self.waitRelease = nil
    end)

    -- 允许按 ESC 关闭下拉菜单（与 Settings 面板行为一致）
    if ADTDropdownMenu.GetName then
        local name = ADTDropdownMenu:GetName()
        if name and UISpecialFrames then
            -- 避免重复插入
            local found
            for i, v in ipairs(UISpecialFrames) do if v == name then found = true break end end
            if not found then table.insert(UISpecialFrames, name) end
        end
    end
end


--[[ LeftPanel/SearchBox：已迁移到 src/dock/LeftPanel.lua
local CreateSearchBox
do
    local StringTrim = API.StringTrim

    function CreateSearchBox(parent)
        -- 使用暴雪原生 SearchBoxTemplate，避免自定义贴图/切片
        local f = CreateFrame("EditBox", nil, parent, "SearchBoxTemplate")
        f:SetAutoFocus(false)
        f:SetSize(168, Def.ButtonSize)
        f.Instructions:SetText(SEARCH)

        -- 统一文字颜色
        f:SetTextColor(1, 1, 1)

        -- 文本变化回调（200ms 防抖）
        local t
        f:SetScript("OnTextChanged", function(self, userInput)
            if not userInput then return end
            t = 0
            self:SetScript("OnUpdate", function(self2, elapsed)
                t = t + elapsed
                if t > 0.2 then
                    self2:SetScript("OnUpdate", nil)
                    local text = StringTrim(self2:GetText())
                    MainFrame:RunSearch(text)
                end
            end)
        end)

        -- 清除按钮与 Esc 行为
        if f.ClearButton then
            f.ClearButton:SetScript("OnClick", function(btn)
                local self2 = btn:GetParent()
                self2:SetText("")
                MainFrame:RunSearch("")
                if ADT.UI and ADT.UI.PlaySoundCue then ADT.UI.PlaySoundCue('ui.checkbox.off') end
            end)
        end
        f:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        f:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

        return f
    end
end]]


--[[ LeftPanel/CategoryButton：已迁移到 src/dock/LeftPanel.lua
local CreateCategoryButton
do
    local CategoryButtonMixin = {}

    function CategoryButtonMixin:OnEnter()
        if ADT and ADT.DebugPrint then
            ADT.DebugPrint("[DockLeft] OnEnter key="..tostring(self.categoryKey)
                .." over="..tostring(self:IsMouseOver())
                .." btn="..(self.GetName and (self:GetName() or "") or ""))
        end
        MainFrame:HighlightButton(self)
        SetTextColor(self.Label, Def.TextColorHighlight)
    end

    function CategoryButtonMixin:OnLeave()
        if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockLeft] OnLeave key="..tostring(self.categoryKey)) end
        MainFrame:HighlightButton()
        SetTextColor(self.Label, Def.TextColorNormal)
    end

    function CategoryButtonMixin:SetCategory(key, text, anyNewFeature)
        if ADT and ADT.API and ADT.API.StringTrim then
            text = ADT.API.StringTrim(text or "")
        else
            text = tostring(text or ""):match("^%s*(.-)%s*$")
        end
        self.Label:SetText(text)
        self.cateogoryName = string.lower(text)
        self.categoryKey = key

        self.NewTag:ClearAllPoints()
        self.NewTag:SetPoint("CENTER", self, "LEFT", 0, 0)
        self.NewTag:SetShown(anyNewFeature)
    end

    function CategoryButtonMixin:ShowCount(count)
        -- 计数显示/隐藏，并根据当前按钮宽度重新计算 Label 的可用宽度，
        -- 保证左右内边距对称（无计数时不预留右侧空白）。
        local hasCount = count and count > 0
        if hasCount then
            self.Count:SetText(count)
            self.CountContainer:FadeIn()
        else
            self.CountContainer:FadeOut()
        end
        if self.UpdateLabelWidth then self:UpdateLabelWidth() end
    end

    function CategoryButtonMixin:OnClick()
        if ADT and ADT.DebugPrint then
            local f = GetMouseFocus and GetMouseFocus()
            local fname = f and (f.GetName and f:GetName()) or tostring(f)
            ADT.DebugPrint("[DockLeft] OnClick key="..tostring(self.categoryKey).." focus="..tostring(fname))
        end
        local cat = CommandDock:GetCategoryByKey(self.categoryKey)
        if cat and cat.categoryType == 'decorList' then
            -- 装饰列表分类：切换到装饰列表视图
            MainFrame:ShowDecorListCategory(self.categoryKey)
            if ADT.UI and ADT.UI.PlaySoundCue then ADT.UI.PlaySoundCue('ui.scroll.step') end
        elseif cat and cat.categoryType == 'about' then
            -- 信息分类：显示关于信息
            MainFrame:ShowAboutCategory(self.categoryKey)
            if ADT.UI and ADT.UI.PlaySoundCue then ADT.UI.PlaySoundCue('ui.scroll.step') end
        else
            -- 设置类分类：仅显示该分类的条目（不与其它分类混排）
            MainFrame:ShowSettingsCategory(self.categoryKey)
            if ADT.UI and ADT.UI.PlaySoundCue then ADT.UI.PlaySoundCue('ui.scroll.step') end
        end
        if ADT and ADT.SetDBValue then ADT.SetDBValue('LastCategoryKey', self.categoryKey) end
        MainFrame:HighlightButton(self)
    end

    function CategoryButtonMixin:OnMouseDown()
        self.Label:SetPoint("LEFT", self, "LEFT", self.labelOffset + 1, -1)
        if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockLeft] OnMouseDown key="..tostring(self.categoryKey)) end
    end

    function CategoryButtonMixin:OnMouseUp()
        self:ResetOffset()
        if ADT and ADT.DebugPrint then ADT.DebugPrint("[DockLeft] OnMouseUp key="..tostring(self.categoryKey)) end
    end

    function CategoryButtonMixin:ResetOffset()
        self.Label:SetPoint("LEFT", self, "LEFT", self.labelOffset, 0)
    end

    function CreateCategoryButton(parent)
        local f = CreateFrame("Button", nil, parent)
        Mixin(f, CategoryButtonMixin)
        f:SetSize(120, 26)
        f.labelOffset = Def.CategoryButtonLabelOffset or 9
        if f.RegisterForClicks then f:RegisterForClicks("LeftButtonUp", "RightButtonUp") end
        f.Label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.Label:SetJustifyH("LEFT")
        f.Label:SetPoint("LEFT", f, "LEFT", 9, 0)
        SetTextColor(f.Label, Def.TextColorNormal)

        local CountContainer = CreateFrame("Frame", nil, f)
        f.CountContainer = CountContainer
        -- 使用固定宽度，防止数字位数变化造成视觉跳动（单一权威：与 ComputeSideSectionWidth 里的预留一致）
        local countWidth = Def.CountTextWidthReserve or 22
        CountContainer:SetSize(countWidth, Def.ButtonSize)
        -- 右侧外边距与左侧 labelOffset 对称：9px
        CountContainer:SetPoint("RIGHT", f, "RIGHT", -f.labelOffset, 0)
        CountContainer:Hide()
        CountContainer:SetAlpha(0)
        -- 去掉数字背景框，仅淡入文字
        MakeFadingObject(CountContainer)
        CountContainer:SetFadeSpeed(8)

        f.Count = CountContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.Count:SetJustifyH("RIGHT")
        -- 数字右内边距 2px，避免贴边；与容器宽度分离以获得更稳定的视觉对齐
        f.Count:ClearAllPoints()
        f.Count:SetPoint("RIGHT", CountContainer, "RIGHT", - (Def.CategoryCountRightInset or 2), 0)
        SetTextColor(f.Count, Def.TextColorNonInteractable)

        f:SetScript("OnEnter", f.OnEnter)
        f:SetScript("OnLeave", f.OnLeave)
        f:SetScript("OnClick", f.OnClick)
        f:SetScript("OnMouseDown", f.OnMouseDown)
        f:SetScript("OnMouseUp", f.OnMouseUp)

        f.NewTag = CreateNewFeatureMark(f, true)

        -- 统一的 Label 宽度自适应：根据是否显示计数决定是否预留右侧空间
        function f:UpdateLabelWidth()
            local bw = tonumber(self:GetWidth()) or 0
            if bw <= 0 then return end
            local reserve = 0
            if self.CountContainer and self.CountContainer:IsShown() then
                reserve = (Def.CountTextWidthReserve + Def.CategoryLabelToCountGap)
            end
            self.Label:SetWidth(bw - 2 * self.labelOffset - reserve)
        end

        return f
    end
end]]


local OptionToggleMixin = {}
do
    function OptionToggleMixin:OnEnter()
        self.Texture:SetVertexColor(1, 1, 1)
        local tooltip = GameTooltip
        tooltip:SetOwner(self, "ANCHOR_RIGHT")
        tooltip:SetText(SETTINGS, 1, 1, 1, 1)
        tooltip:Show()

        if MainFrame and MainFrame.HighlightButton then
            local entry = self:GetParent()
            if entry then MainFrame:HighlightButton(entry) end
        end
    end

    function OptionToggleMixin:OnLeave()
        self:ResetVisual()
        GameTooltip:Hide()
        -- 不主动清除条目高亮，交由 Entry 的 OnLeave 负责，避免出现“移入右侧按钮高亮消失”的闪烁
    end

    function OptionToggleMixin:OnClick(button)
        if self.onClickFunc then
            self.onClickFunc(self, button)
        end
    end

    function OptionToggleMixin:SetOnClickFunc(onClickFunc, hasMovableWidget)
        self.onClickFunc = onClickFunc
        self.hasMovableWidget = hasMovableWidget
    end

    function OptionToggleMixin:ResetVisual()
        self.Texture:SetVertexColor(0.65, 0.65, 0.65)
    end

    function OptionToggleMixin:OnLoad()
        self:SetScript("OnEnter", self.OnEnter)
        self:SetScript("OnLeave", self.OnLeave)
        self:SetScript("OnClick", self.OnClick)
        self:ResetVisual()
    end
end


local CreateSettingsEntry
do
    local EntryButtonMixin = {}

    function EntryButtonMixin:SetData(moduleData)
        self.Label:SetText(moduleData.name)
        self.dbKey = moduleData.dbKey
        self.virtual = moduleData.virtual
        self.data = moduleData
        self.NewTag:SetShown((not self.isChangelogButton) and moduleData.isNewFeature)
        self.OptionToggle:SetOnClickFunc(moduleData.optionToggleFunc, self.data and self.data.hasMovableWidget)
        self.hasOptions = moduleData.optionToggleFunc ~= nil
        
        -- 下拉菜单类型：更新标签显示当前选中值
        if moduleData.type == 'dropdown' then
            self:UpdateDropdownLabel()
        end
        
        self:UpdateState()
        self:UpdateVisual()
    end

    function EntryButtonMixin:OnEnter()
        if ADT and ADT.DebugPrint then
            ADT.DebugPrint("[SettingsPanel] Entry OnEnter dbKey="..tostring(self.dbKey)
                .." over="..tostring(self:IsMouseOver()))
        end
        if MainFrame and MainFrame.HighlightButton then MainFrame:HighlightButton(self) end
        self:UpdateVisual()
        if not self.isChangelogButton then
            MainFrame:ShowFeaturePreview(self.data, self.parentDBKey)
        end
    end

    function EntryButtonMixin:OnLeave()
        if MainFrame and MainFrame.HighlightButton then MainFrame:HighlightButton(nil) end
        self:UpdateVisual()
    end

    function EntryButtonMixin:OnEnable()
        self:UpdateVisual()
    end

    function EntryButtonMixin:OnDisable()
        self:UpdateVisual()
    end

    function EntryButtonMixin:OnClick(button)
        if ADT and ADT.DebugPrint then
            ADT.DebugPrint("[SettingsPanel] OnClick dbKey=" .. tostring(self.dbKey)
                .." focus="..tostring(GetMouseFocus and (GetMouseFocus():GetName() or "<anon>") or "?"))
        end
        if self.dbKey and self.data then
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[SettingsPanel] data.type=" .. tostring(self.data.type)) end
            -- 下拉菜单类型：使用暴雪 12.0+ Menu API（最佳实践）
            if self.data.type == 'dropdown' then
                ADT.DebugPrint("[SettingsPanel] Using MenuUtil.CreateContextMenu")
                MenuUtil.CreateContextMenu(self, function(owner, root)
                    if self.data.dropdownBuilder then
                        self.data.dropdownBuilder(owner, root)
                    else
                        if not self.data.options then return end
                        local function IsSelected(value)
                            return ADT.GetDBValue(self.dbKey) == value
                        end
                        local function SetSelected(value)
                            ADT.SetDBValue(self.dbKey, value, true)
                            if self.data.toggleFunc then
                                self.data.toggleFunc(value)
                            end
                            self:UpdateDropdownLabel()
                            if MainFrame.UpdateSettingsEntries then
                                MainFrame:UpdateSettingsEntries()
                            end
                            return MenuResponse.Close
                        end
                        for _, opt in ipairs(self.data.options) do
                            if opt and opt.action == 'button' and opt.onClick then
                                root:CreateButton(opt.text, function()
                                    opt.onClick()
                                    return MenuResponse.Close
                                end)
                            else
                                root:CreateRadio(opt.text, IsSelected, SetSelected, opt.value)
                            end
                        end
                    end
                end)
                return  -- 不需要执行后续的 UpdateSettingsEntries
            -- 普通复选框类型
            else
                -- 通用复选框：无 toggleFunc 也能持久化并广播
                local newState = not GetDBBool(self.dbKey)
                ADT.SetDBValue(self.dbKey, newState, true)
                if self.data.toggleFunc then self.data.toggleFunc(newState) end
                if newState then if ADT.UI and ADT.UI.PlaySoundCue then ADT.UI.PlaySoundCue('ui.checkbox.on') end
                else if ADT.UI and ADT.UI.PlaySoundCue then ADT.UI.PlaySoundCue('ui.checkbox.off') end end
            end
        end

        MainFrame:UpdateSettingsEntries()
    end
    
    -- 更新下拉菜单的显示标签
    function EntryButtonMixin:UpdateDropdownLabel()
        if not self.data or self.data.type ~= 'dropdown' or not self.data.options then return end
        local currentValue = ADT.GetDBValue(self.dbKey)
        local displayText = self.data.name
        for _, opt in ipairs(self.data.options) do
            if opt.value == currentValue then
                displayText = self.data.name .. "：" .. opt.text
                break
            end
        end
        self.Label:SetText(displayText)
    end

    function EntryButtonMixin:UpdateState()
        if self.virtual then
            self:Enable()
            self.OptionToggle:SetShown(self.hasOptions)
            -- 虚拟条目：仅显示容器，不显示对勾
            if self.Box.SetAtlas then self.Box:SetAtlas("checkbox-minimal") end
            if self.Check then self.Check:Hide() end
            return
        end
        
        -- 只读项
        if self.data and self.data.type == 'readonly' then
            if self.Box then self.Box:Hide() end
            if self.Check then self.Check:Hide() end
            self.OptionToggle:Hide()
            self:Disable()
            SetTextColor(self.Label, Def.TextColorDisabled)
            return
        end

        -- 数值微调器：以 Name：value 形式显示，左键+step，右键-step
        if self.data and self.data.type == 'number' then
            if self.Box then self.Box:Hide() end
            if self.Check then self.Check:Hide() end
            self.OptionToggle:Hide()
            self:Enable()
            local v = tonumber(ADT.GetDBValue(self.dbKey)) or tonumber(self.data.default) or 0
            local fmt = self.data.format or "%s：%s"
            self.Label:SetText(string.format(fmt, self.data.name, tostring(v)))
            -- 覆写点击：左加右减
            self:SetScript("OnClick", function(_, btn)
                local minv = tonumber(self.data.min) or -math.huge
                local maxv = tonumber(self.data.max) or math.huge
                local step = tonumber(self.data.step) or 1
                local nv = v
                if btn == "RightButton" then nv = v - step else nv = v + step end
                if nv < minv then nv = minv elseif nv > maxv then nv = maxv end
                v = nv
                ADT.SetDBValue(self.dbKey, v, true)
                self.Label:SetText(string.format(fmt, self.data.name, tostring(v)))
            end)
            return
        end

        -- 下拉菜单类型：显示下拉箭头，使用柔和金色文字
        if self.data and self.data.type == 'dropdown' then
            -- 下拉项不显示左侧复选框/对勾，也不显示右侧更多按钮图标
            if self.Box then self.Box:Hide() end
            if self.Check then self.Check:Hide() end
            self.OptionToggle:Hide()
            self:Enable()
            -- 设置柔和金色文字（0.922, 0.871, 0.761）
            SetTextColor(self.Label, { 0.922, 0.871, 0.761 })
            self:UpdateDropdownLabel()
            return
        else
            self.Box:Show()  -- 确保复选框显示
        end

        local disabled
        if self.parentDBKey and not GetDBBool(self.parentDBKey) then
            disabled = true
        end

        if GetDBBool(self.dbKey) then
            if self.Box.SetAtlas then self.Box:SetAtlas("checkbox-minimal") end
            if self.Check then self.Check:Show() end
            self.OptionToggle:SetShown(self.hasOptions)
        else
            if self.Box.SetAtlas then self.Box:SetAtlas("checkbox-minimal") end
            if self.Check then self.Check:Hide() end
            self.OptionToggle:Hide()
        end

        if disabled then
            self:Disable()
        else
            self:Enable()
        end
    end

    -- 旧的“逐字符宽度高亮”实现已废弃，保留空实现以兼容旧调用。
    function EntryButtonMixin:EnsureTextHighlight() return nil end
    function EntryButtonMixin:HideTextHighlight() end
    function EntryButtonMixin:UpdateTextHighlight(_) end

    function EntryButtonMixin:UpdateVisual()
        -- 统一色彩策略：高亮不改变文字颜色；仅按可用/不可用切换。
        if self:IsEnabled() then
            SetTextColor(self.Label, Def.TextColorNormal)
        else
            SetTextColor(self.Label, Def.TextColorDisabled)
        end
    end

    -- 返回此条目在中央区域所需的“容器宽度”（不含 CentralSection 的左右留白）
    -- 依据模板：Label 左 28、右 28
    function EntryButtonMixin:GetDesiredWidth()
        local w = 0
        if self.Label and self.Label.GetStringWidth then
            w = math.ceil(self.Label:GetStringWidth() or 0)
        end
        return w + 56
    end

    function CreateSettingsEntry(parent)
        local f = CreateFrame("Button", nil, parent, "ADTSettingsPanelEntryTemplate")
        Mixin(f, EntryButtonMixin)
        if f.RegisterForClicks then f:RegisterForClicks("LeftButtonUp", "RightButtonUp") end
        f:SetMotionScriptsWhileDisabled(true)
        f:SetScript("OnEnter", f.OnEnter)
        f:SetScript("OnLeave", f.OnLeave)
        f:SetScript("OnEnable", f.OnEnable)
        f:SetScript("OnDisable", f.OnDisable)
        f:SetScript("OnClick", f.OnClick)
        SetTextColor(f.Label, Def.TextColorNormal)
        -- 禁止换行并限制为单行，避免右侧仍有空间时出现意外换行。
        if f.Label and f.Label.SetMaxLines then f.Label:SetMaxLines(1) end
        if f.Label and f.Label.SetWordWrap then f.Label:SetWordWrap(false) end

        -- 复选框属于“小尺寸图元”，若使用三线性过滤(TRILINEAR)，在缩放/生成mipmap时会从图集相邻切片取样，
        -- 即便我们做了 +1px inset，仍可能出现“橙色勾边缘发灰/发白”的串色伪影。
        -- 因此这里明确关闭三线性过滤，退回 LINEAR，以保证像素仅在当前切片内采样。
        f.Box.useTrilinearFilter = false
        if f.Box.SetAtlas then f.Box:SetAtlas("checkbox-minimal") end
        -- 对勾覆盖层（黄色对勾）
        local check = f:CreateTexture(nil, "OVERLAY")
        f.Check = check
        check:SetAtlas("common-icon-checkmark-yellow")
        check:SetSize(20, 20)
        check:SetPoint("CENTER", f.Box, "CENTER", 0, 0)
        check:Hide()

        f.NewTag = CreateNewFeatureMark(f)

        -- 暂不显示独立的“更多选项”按钮图标，保留点击行为
        Mixin(f.OptionToggle, OptionToggleMixin)
        f.OptionToggle:OnLoad()
        f.OptionToggle.Texture:Hide()

        return f
    end
end
-- 右侧/左侧通用：悬停容器（housing-basic-container）的单一权威实现
-- 统一“高亮容器”实现：单实例 Frame，父到目标按钮，贴 housing-basic-container，带淡入
ADT.DockUI = ADT.DockUI or {}
do
    local HL
    local function DockHLParams()
        local cfg = ADT and ADT.GetHousingCFG and ADT.GetHousingCFG()
        local d = (cfg and cfg.DockHighlight) or {}
        return {
            r = tonumber(d.color and d.color.r) or 0.96,
            g = tonumber(d.color and d.color.g) or 0.84,
            b = tonumber(d.color and d.color.b) or 0.32,
            a = tonumber(d.color and d.color.a) or 0.15,
            il = tonumber(d.insetLeft) or 0,
            ir = tonumber(d.insetRight) or 0,
            it = tonumber(d.insetTop) or 1,
            ib = tonumber(d.insetBottom) or 1,
            fadeEnabled = (d.fade and d.fade.enabled) ~= false,
            fadeInDuration = tonumber(d.fade and d.fade.inDuration) or 0.15,
        }
    end
    local function EnsureHL()
        if HL then return HL end
        local f = CreateFrame("Frame", nil, MainFrame, "ADTSettingsAnimSelectionTemplate")
        f:Hide()
        -- 采用模板自带三段贴片，颜色来自配置表
        local P = DockHLParams()
        if f.Left then f.Left:SetColorTexture(P.r, P.g, P.b, P.a) end
        if f.Center then f.Center:SetColorTexture(P.r, P.g, P.b, P.a) end
        if f.Right then f.Right:SetColorTexture(P.r, P.g, P.b, P.a) end
        f.BG = f.Center
        function f:SyncPieces()
            local h = math.max(1, tonumber(self:GetHeight()) or 28)
            if self.Left and self.Left.SetHeight then self.Left:SetHeight(h) end
            if self.Right and self.Right.SetHeight then self.Right:SetHeight(h) end
            -- Center 由 Left/Right 的锚点决定高度，无需单独设置
        end
        f:SetScript("OnSizeChanged", function(self) self:SyncPieces() end)
        -- 简单淡入
        f:SetAlpha(0)
        f._fadeTicker = nil
        function f:FadeIn()
            if self._fadeTicker then self._fadeTicker:Cancel() end
            local P = DockHLParams()
            if not P.fadeEnabled or (P.fadeInDuration or 0) <= 0 then
                self:SetAlpha(1); self:Show(); return
            end
            local step = 0.016
            local steps = math.max(1, math.floor(P.fadeInDuration / step + 0.5))
            local a = 0
            self:SetAlpha(0); self:Show()
            self._fadeTicker = C_Timer.NewTicker(step, function()
                a = a + (1/steps)
                if a >= 1 then a = 1; if self._fadeTicker then self._fadeTicker:Cancel(); self._fadeTicker = nil end end
                self:SetAlpha(a)
            end, steps)
        end
        function f:InstantHide()
            if self._fadeTicker then self._fadeTicker:Cancel(); self._fadeTicker = nil end
            self:SetAlpha(0); self:Hide(); self:ClearAllPoints()
        end
        HL = f
        return HL
    end

    -- 供 LeftPanel 与右侧条目统一调用
    function MainFrame:HighlightButton(button)
        local hl = EnsureHL()
        hl:InstantHide()
        if not button then return end
        -- 父到按钮，覆盖整条区域
        hl:SetParent(button)
        hl:SetFrameStrata(button:GetFrameStrata() or "FULLSCREEN_DIALOG")
        pcall(hl.SetFrameLevel, hl, math.max(1, (button:GetFrameLevel() or 1)))
        local P = DockHLParams()
        hl:SetPoint("TOPLEFT", button, "TOPLEFT", P.il, -P.it)
        hl:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -P.ir, P.ib)
        if hl.SyncPieces then hl:SyncPieces() end
        hl:FadeIn()
    end
end


local CreateSettingsHeader
do
    local HeaderMixin = {}

    function HeaderMixin:SetText(text)
        self.Label:SetText(text)
    end

    function HeaderMixin:SetLeftPadding(pixels)
        local x = tonumber(pixels) or 8
        if self.Label then
            self.Label:ClearAllPoints()
            self.Label:SetPoint("BOTTOMLEFT", self, "LEFT", x, 5)
        end
        if self.Divider then
            self.Divider:ClearAllPoints()
            self.Divider:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", x, 6)
            self.Divider:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 6)
        end
    end


    function CreateSettingsHeader(parent)
        local f = CreateFrame("Frame", nil, parent, "ADTSettingsPanelHeaderTemplate")
        Mixin(f, HeaderMixin)
        SetTextColor(f.Label, Def.TextColorNonInteractable)

        -- 使用 Housing 风格分割线，弃用旧的 SettingsPanel 贴片
        if f.Left then f.Left:Hide() end
        if f.Right then f.Right:Hide() end

        local divider = f:CreateTexture(nil, "ARTWORK")
        f.Divider = divider
        divider:SetAtlas("house-upgrade-header-divider-horz")
        divider:SetHeight(2)
        -- 具体锚点在 SetLeftPadding 中与内容对齐

        -- 统一左边距：标题与右侧内容共用同一左起点（不对齐到图标位）
        local defaultHeaderLeft = GetRightPadding()
        f:SetLeftPadding(defaultHeaderLeft)
        
        -- 供自动宽度评估
        function f:GetDesiredWidth()
            local w = 0
            if self.Label and self.Label.GetStringWidth then
                w = math.ceil(self.Label:GetStringWidth() or 0)
            end
            -- Header 左侧有 GetRightPadding() 的缩进，右侧也给同等余量
            return w + 2 * GetRightPadding()
        end
        return f
    end
end

-- 导出通用 Header 构造器（单一权威，供子模块调用）
ADT.DockUI.CreateSettingsHeader = CreateSettingsHeader


-- 装饰项按钮（用于临时板和历史记录列表）
local CreateDecorItemEntry
do
    local DecorItemMixin = {}

    -- 读取 DockDecorList 样式（分类：Clipboard/History），带通用 Common 兜底
    local function GetDecorListStyle(categoryKey)
        local cfg = ADT.GetHousingCFG and ADT.GetHousingCFG() or nil
        local dl  = cfg and cfg.DockDecorList or nil
        if not dl then
            return { countRightInset = 6, nameToCountGap = 8, countWidth = 32 }
        end
        local common = dl.Common or {}
        local style
        if categoryKey == 'Clipboard' then
            style = dl.Clipboard or {}
        elseif categoryKey == 'History' then
            style = dl.Recent or {}
        else
            style = {}
        end
        return {
            countRightInset = tonumber(style.countRightInset) or tonumber(common.countRightInset) or 6,
            nameToCountGap  = tonumber(style.nameToCountGap)  or tonumber(common.nameToCountGap)  or 8,
            countWidth      = tonumber(style.countWidth)      or tonumber(common.countWidth)      or 32,
        }
    end

    function DecorItemMixin:SetData(item, categoryInfo)
        self.decorID = item.decorID
        self.categoryInfo = categoryInfo
        self.itemData = item
        
        -- 设置图标
        self.Icon:SetTexture(item.icon or 134400)
        
        -- 获取库存数量
        local entryInfo = C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID 
            and C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, item.decorID, true)
        local available = 0
        local displayName = item.name or (string.format((ADT.L and ADT.L['Decor #%d']) or '装饰 #%d', tonumber(item.decorID) or 0))
        
        if entryInfo then
            available = (entryInfo.quantity or 0) + (entryInfo.remainingRedeemable or 0)
            if not item.name and entryInfo.name then
                displayName = entryInfo.name
            end
            if not item.icon and entryInfo.iconTexture then
                self.Icon:SetTexture(entryInfo.iconTexture)
            end
        end
        
        -- 临时板显示计数前缀
        if item.count and item.count > 1 then
            displayName = string.format("[x%d] %s", item.count, displayName)
        end
        
        self.Name:SetText(displayName)
        self.Count:SetText(tostring(available))
        self.available = available

        -- 分类化的锚点与间距：允许在 Housing_Config.lua 独立调节 Clipboard/Recent
        do
            local catKey = categoryInfo and categoryInfo.key or nil
            local sty = GetDecorListStyle(catKey)
            -- 右侧库存位置与宽度
            if self.Count and self.Count.ClearAllPoints then
                self.Count:ClearAllPoints()
                self.Count:SetPoint("RIGHT", self, "RIGHT", -sty.countRightInset, 0)
                if self.Count.SetWidth then self.Count:SetWidth(sty.countWidth) end
            end
            -- 名称右侧对齐到 Count 左侧，留 nameToCountGap
            if self.Name and self.Name.ClearAllPoints and self.Icon then
                self.Name:ClearAllPoints()
                self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 8, 0)
                self.Name:SetPoint("RIGHT", self.Count, "LEFT", -sty.nameToCountGap, 0)
            end
        end
        
        -- 禁用状态
        self.isDisabled = available <= 0
        self:UpdateVisual()
    end

    function DecorItemMixin:UpdateVisual()
        if self.isDisabled then
            self.Name:SetTextColor(0.5, 0.5, 0.5)
            if self.Icon.SetDesaturated then self.Icon:SetDesaturated(true) end
        else
            SetTextColor(self.Name, Def.TextColorNormal)
            if self.Icon.SetDesaturated then self.Icon:SetDesaturated(false) end
        end
    end

    -- 依据模板：图标(左 4 + 宽 28) + 名称左间距 8 = 40；右侧数量保留 40
    function DecorItemMixin:GetDesiredWidth()
        local w = 0
        if self.Name and self.Name.GetStringWidth then
            w = math.ceil(self.Name:GetStringWidth() or 0)
        end
        local catKey = self.categoryInfo and self.categoryInfo.key or nil
        local sty = GetDecorListStyle(catKey)
        -- 左侧固定：4(Icon左内) + 28(Icon) + 8(Icon-Name 间距) = 40
        local leftFixed = 40
        -- 右侧保留：库存区宽度 + 名称与库存间距 + 右侧内缩
        local rightFixed = sty.countWidth + sty.nameToCountGap + sty.countRightInset
        return w + leftFixed + rightFixed
    end

    function DecorItemMixin:OnEnter()
        if not self.isDisabled then
            self.Highlight:Show()
            SetTextColor(self.Name, Def.TextColorHighlight)
        end
        -- 右侧预览
        MainFrame:ShowDecorPreview(self.itemData, self.available)
        --（移除 Dock 列表悬停→世界高亮的逻辑，避免与“世界悬停高亮”需求混淆）
        -- Tooltip
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(self.Name:GetText() or "", 1, 1, 1)
        if self.available > 0 then
            GameTooltip:AddLine(string.format((ADT.L and ADT.L['Stock: %d']) or '库存：%d', self.available), 0, 1, 0)
        else
            GameTooltip:AddLine((ADT.L and ADT.L['Stock: 0 (Unavailable)']) or '库存：0（不可放置）', 1, 0.2, 0.2)
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine((ADT.L and ADT.L['Left Click: Place']) or '左键：开始放置', 0.8, 0.8, 0.8)
        if self.categoryInfo and self.categoryInfo.key == 'Clipboard' then
            GameTooltip:AddLine((ADT.L and ADT.L['Right Click: Remove from Clipboard']) or '右键：从临时板移除', 1, 0.4, 0.4)
        end
        GameTooltip:Show()
    end

    function DecorItemMixin:OnLeave()
        self.Highlight:Hide()
        self:UpdateVisual()
        --（不再在 Dock 列表离开时清理世界高亮）
        GameTooltip:Hide()
    end

    function DecorItemMixin:OnClick(button)
        if self.isDisabled and button ~= "RightButton" then return end
        if self.categoryInfo and self.categoryInfo.onItemClick then
            self.categoryInfo.onItemClick(self.decorID, button)
            -- 刷新列表
            C_Timer.After(0.1, function()
                if MainFrame.currentDecorCategory then
                    MainFrame:ShowDecorListCategory(MainFrame.currentDecorCategory)
                end
            end)
        end
    end

    function CreateDecorItemEntry(parent)
        local f = CreateFrame("Button", nil, parent, "ADTDecorItemEntryTemplate")
        Mixin(f, DecorItemMixin)
        f:SetSize(200, 36)
        f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        -- Icon border removed - user prefers clean icons without frames
        f:SetScript("OnEnter", f.OnEnter)
        f:SetScript("OnLeave", f.OnLeave)
        f:SetScript("OnClick", f.OnClick)
        SetTextColor(f.Name, Def.TextColorNormal)
        -- 名称仅单行显示，过长时自动省略号
        if f.Name and f.Name.SetMaxLines then f.Name:SetMaxLines(1) end
        if f.Name and f.Name.SetWordWrap then f.Name:SetWordWrap(false) end
        return f
    end
end


-- 子面板的实现已迁移至 src/dock/SubPanel.lua


--[[ LeftPanel/SelectionHighlight：已迁移到 src/dock/LeftPanel.lua
local CreateSelectionHighlight
do
    local SelectionHighlightMixin = {}

    function SelectionHighlightMixin:FadeIn()
        self.isFading = true
        self:SetAlpha(0)
        self.t = 0
        self.alpha = 0
        self:SetScript("OnUpdate", self.OnUpdate)
        self:Show()
    end

    function SelectionHighlightMixin:OnUpdate(elapsed)
        self.t = self.t + elapsed

        if self.isFading then
            self.alpha = self.alpha + 5 * elapsed
            if self.alpha > 1 then
                self.alpha = 1
                self.isFading = nil
                self:SetScript("OnUpdate", nil)
            end
            self:SetAlpha(self.alpha)
        end
    end

    function SelectionHighlightMixin:OnHide()
        self:Hide()
        self:ClearAllPoints()
    end

    function CreateSelectionHighlight(parent)
        local f = CreateFrame("Frame", nil, parent, "ADTSettingsAnimSelectionTemplate")
        Mixin(f, SelectionHighlightMixin)

        -- 统一改用纯色矩形，保证左右对称
        if f.Left then f.Left:Hide() end
        if f.Center then f.Center:Hide() end
        if f.Right then f.Right:Hide() end

        local bg = f:CreateTexture(nil, "ARTWORK")
        f.Background = bg
        bg:SetAllPoints(true)
        bg:SetColorTexture(0, 0, 0, 0.30)

        f.d = 0.6
        f:Hide()
        f:SetScript("OnHide", f.OnHide)

        return f
    end
end]]


do  -- Left Section
    -- 高亮逻辑由 LeftPanel 注入到 MainFrame；此处不再实现

    -- 运行时根据语言调整左侧栏宽度，并联动更新相关控件尺寸
    function MainFrame:_ApplySideWidth(sideWidth)
        sideWidth = API.Round(sideWidth)
        local LeftSection = self.LeftSection
        if not LeftSection then return end

        LeftSection:SetWidth(sideWidth)

        -- 同步左侧滑出容器宽度与收起位置
        if self.LeftSlideContainer then
            self.LeftSlideContainer:SetWidth(sideWidth)
        end
        if self.LeftSlideDriver and self.GetLeftClosedOffset then
            local closed = self.GetLeftClosedOffset()
            if math.abs(self.LeftSlideDriver.target) > 0.5 then
                self.LeftSlideDriver.target = closed
                if math.abs(self.LeftSlideDriver.x - closed) < 1 then
                    self.LeftSlideDriver.x = closed
                    if self.LeftSlideDriver.onUpdate then self.LeftSlideDriver.onUpdate(closed) end
                end
            end
        end

        -- 分类按钮宽度与高亮条宽度
        local btnWidth = sideWidth - 2*Def.WidgetGap
        if CategoryHighlight and CategoryHighlight.SetSize then
            CategoryHighlight:SetSize(btnWidth, Def.ButtonSize)
        end
        if self.primaryCategoryPool and self.primaryCategoryPool.EnumerateActive then
            for _, button in self.primaryCategoryPool:EnumerateActive() do
                if button and button.SetSize then
                    button:SetSize(btnWidth, Def.ButtonSize)
                end
                if button and button.UpdateLabelWidth then button:UpdateLabelWidth() end
            end
        end

        -- 右侧预览图尺寸与滚动区联动（中央区随锚点自动伸缩，但滚动条需手动刷新）
        local previewSize = math.max(64, sideWidth - 2*Def.ButtonSize)
        if self.FeaturePreview and self.FeaturePreview.SetSize then
            self.FeaturePreview:SetSize(previewSize, previewSize)
        end

        if self.CentralSection and self.ModuleTab and self.ModuleTab.ScrollView then
            local CentralSection = self.CentralSection
            -- 修正：条目左侧统一使用 offsetX = GetRightPadding() 进行缩进，
            -- 因此条目真实可用宽度应为 CentralSection 宽度减去该缩进，
            -- 否则右侧库存数字会越出 DeckUI 的右边框。
            local newWidth = API.Round((CentralSection:GetWidth() or 0) - GetRightPadding())
            if newWidth > 0 then
                self.centerButtonWidth = newWidth
                local ScrollView = self.ModuleTab.ScrollView
                ScrollView:CallObjectMethod("Entry", "SetWidth", newWidth)
                ScrollView:CallObjectMethod("Header", "SetWidth", newWidth)
                ScrollView:CallObjectMethod("DecorItem", "SetWidth", newWidth)
                ScrollView:OnSizeChanged(true)
                if self.ModuleTab.ScrollBar and self.ModuleTab.ScrollBar.UpdateThumbRange then
                    self.ModuleTab.ScrollBar:UpdateThumbRange()
                end
            end
        end
    end

    function MainFrame:AnimateSideWidthTo(targetWidth)
        local from = self.LeftSection and self.LeftSection:GetWidth() or targetWidth
        if not from or math.abs(from - targetWidth) < 1 then
            self:_ApplySideWidth(targetWidth)
            return
        end
        local t, d = 0, 0.25
        local ease = ADT.EasingFunctions and ADT.EasingFunctions.outQuint
        self:SetScript("OnUpdate", function(_, elapsed)
            t = t + (elapsed or 0)
            if t >= d then
                self:SetScript("OnUpdate", nil)
                self:_ApplySideWidth(targetWidth)
                return
            end
            local cur
            if ease then
                cur = ease(t, from, targetWidth - from, d)
            else
                cur = API.Lerp(from, targetWidth, t/d)
            end
            self:_ApplySideWidth(cur)
        end)
    end

    function MainFrame:RefreshLanguageLayout(animated)
        local target = ComputeSideSectionWidth()
        if animated then
            self:AnimateSideWidthTo(target)
        else
            self:_ApplySideWidth(target)
        end
        -- 语言切换后，文本宽度变化需要重新计算容器宽
        if self.UpdateAutoWidth then self:UpdateAutoWidth() end
    end

    -- 中央“设置项”行高亮：已下沉到 EntryButtonMixin（每个条目自管），避免跨层级 frame level 混乱。
end


do  -- Right Section (已移除，保留函数但添加空检查)
    function MainFrame:ShowFeaturePreview(moduleData, parentDBKey)
        -- 仅更新预览贴图；已移除说明文字
        if not self.FeaturePreview then return end
        if not moduleData then return end
        local desc = moduleData.description
        local additonalDesc = moduleData.descriptionFunc and moduleData.descriptionFunc() or nil
        if additonalDesc then
            if desc then
                desc = desc.."\n\n"..additonalDesc
            else
                desc = additonalDesc
            end
        end
        self.FeaturePreview:SetTexture("Interface/AddOns/AdvancedDecorationTools/Art/CommandDock/Preview_"..(parentDBKey or moduleData.dbKey))
    end

    -- 显示装饰项预览（右侧预览区已移除，函数保留但不执行任何操作）
    function MainFrame:ShowDecorPreview(itemData, available)
        -- 仅更新预览贴图
        if not self.FeaturePreview then return end
        if not itemData then return end
        -- 设置预览图标
        local icon = itemData.icon or 134400
        local entryInfo = C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID
            and C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, itemData.decorID, true)
        if entryInfo and entryInfo.iconTexture then
            icon = entryInfo.iconTexture
        end
        self.FeaturePreview:SetTexture(icon)
    end
end


do  -- Search
    function MainFrame:RunSearch(text)
        if text and text ~= "" then
            self.listGetter = function()
                return CommandDock:GetSearchResult(text)
            end
            self:RefreshFeatureList()
            for _, button in self.primaryCategoryPool:EnumerateActive() do
                if ActiveCategoryInfo[button.categoryKey] then
                    button:FadeIn()
                    button:ShowCount(ActiveCategoryInfo[button.categoryKey].numModules)
                else
                    button:FadeOut()
                    button:ShowCount(false)
                end
            end
        else
            -- 注意：不能直接赋值为 CommandDock.GetSortedModules（那样会丢失冒号调用的 self）
            -- 绑定为闭包，确保以冒号语义调用，避免 self 为 nil。
            self.listGetter = function()
                return CommandDock:GetSortedModules()
            end
            self:RefreshFeatureList()
            for _, button in self.primaryCategoryPool:EnumerateActive() do
                button:FadeIn()
                button:ShowCount(false)
            end
        end
    end
end


do  -- Central
    function MainFrame:RefreshFeatureList()
        local top, bottom
        local n = 0
        local fromOffsetY = Def.ButtonSize
        local offsetY = fromOffsetY
        local content = {}

        local buttonHeight = Def.ButtonSize
        local categoryGap = Def.CategoryGap
        local buttonGap = 0
        local subOptionOffset = Def.ButtonSize
        -- 右侧内容整体左内边距（不移动各小节 Header）
        local offsetX = GetRightPadding()

        ActiveCategoryInfo = {}
        self.firstModuleData = nil

        local sortedModule = self.listGetter and self.listGetter() or CommandDock:GetSortedModules()

        for index, categoryInfo in ipairs(sortedModule) do
            -- 跳过装饰列表分类和信息分类（它们有自己的渲染方式）
            if categoryInfo.categoryType == 'decorList' or categoryInfo.categoryType == 'about' then
                -- 不渲染这些分类的内容，仅在 ActiveCategoryInfo 中标记
                ActiveCategoryInfo[categoryInfo.key] = {
                    scrollOffset = 0,
                    numModules = 0,
                }
            else
                n = n + 1
                top = offsetY
                bottom = offsetY + buttonHeight + buttonGap

                ActiveCategoryInfo[categoryInfo.key] = {
                    scrollOffset = top - fromOffsetY,
                    numModules = categoryInfo.numModules,
                }

                content[n] = {
                    dataIndex = n,
                    templateKey = "Header",
                    setupFunc = function(obj)
                        obj:SetText(categoryInfo.categoryName)
                        -- 使用 Housing 分割线
                        if obj.Left then obj.Left:Hide() end
                        if obj.Right then obj.Right:Hide() end
                        if obj.Divider then obj.Divider:Show() end
                        obj.Label:SetJustifyH("LEFT")
                    end,
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    top = top,
                    bottom = bottom,
                    -- Header 与右侧内容共用同一左起点
                    offsetX = GetRightPadding(),
                }
                offsetY = bottom

                if n == 1 then
                    self.firstModuleData = categoryInfo.modules[1]
                end

            for _, data in ipairs(categoryInfo.modules) do
                n = n + 1
                top = offsetY
                bottom = offsetY + buttonHeight + buttonGap
                content[n] = {
                    dataIndex = n,
                    templateKey = "Entry",
                    setupFunc = function(obj)
                        obj.parentDBKey = nil
                        obj:SetData(data)
                    end,
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    top = top,
                    bottom = bottom,
                    offsetX = offsetX,
                }
                offsetY = bottom

                if data.subOptions then
                    for _, v in ipairs(data.subOptions) do
                        n = n + 1
                        top = offsetY
                        bottom = offsetY + buttonHeight + buttonGap
                        content[n] = {
                            dataIndex = n,
                            templateKey = "Entry",
                            setupFunc = function(obj)
                                obj.parentDBKey = data.dbKey
                                obj:SetData(v)
                            end,
                            point = "TOPLEFT",
                            relativePoint = "TOPLEFT",
                            top = top,
                            bottom = bottom,
                            offsetX = offsetX + 0.5*subOptionOffset,
                        }
                        offsetY = bottom
                    end
                end
            end
            offsetY = offsetY + categoryGap
            end -- end of else (非装饰列表分类)
        end

        local retainPosition = true
        self.ModuleTab.ScrollView:SetContent(content, retainPosition)

        if self.firstModuleData then
            self:ShowFeaturePreview(self.firstModuleData)
        end
        if self.UpdateAutoWidth then self:UpdateAutoWidth() end
    end

    -- 仅显示一个“设置类”分类（不与其它分类混排）
    function MainFrame:ShowSettingsCategory(categoryKey)
        if not (self.ModuleTab and self.ModuleTab.ScrollView) then
            self.__pendingTabKey = categoryKey
            return
        end
        local cat = CommandDock:GetCategoryByKey(categoryKey)
        if not cat or cat.categoryType ~= 'settings' then return end

        -- 安全兜底：如果目标分类没有任何条目（例如 AutoRotate 仍未注入具体选项），
        -- 自动回退到第一个“包含条目”的设置类分类（通常是 Housing/通用），
        -- 避免出现“右侧只有说明、中央列表为空”的错觉。
        if (not cat.modules) or (#cat.modules == 0) then
            for _, info in ipairs(CommandDock:GetSortedModules()) do
                if info.categoryType == 'settings' and info.modules and #info.modules > 0 then
                    if ADT and ADT.DebugPrint then ADT.DebugPrint("[SettingsPanel] Empty category "..tostring(categoryKey)..", fallback -> "..tostring(info.key)) end
                    categoryKey = info.key
                    cat = info
                    break
                end
            end
        end

        self.currentSettingsCategory = categoryKey
        self.currentDecorCategory = nil
        self.currentAboutCategory = nil
        if ADT and ADT.SetDBValue then ADT.SetDBValue('LastCategoryKey', categoryKey) end

        local content = {}
        local n = 0
        local buttonHeight = Def.ButtonSize
        local fromOffsetY = Def.ButtonSize
        local offsetY = fromOffsetY
        local buttonGap = 0
        local subOptionOffset = Def.ButtonSize
        local offsetX = GetRightPadding()

        -- 分类标题
        n = n + 1
        content[n] = {
            dataIndex = n,
            templateKey = "Header",
            setupFunc = function(obj)
                obj:SetText(cat.categoryName)
                if obj.Left then obj.Left:Hide() end
                if obj.Right then obj.Right:Hide() end
                if obj.Divider then obj.Divider:Show() end
                obj.Label:SetJustifyH("LEFT")
            end,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT",
            top = offsetY,
            bottom = offsetY + buttonHeight,
            offsetX = GetRightPadding(),
        }
        offsetY = offsetY + buttonHeight

        -- 分类内条目
        for _, data in ipairs(cat.modules) do
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[SettingsPanel] item: "..tostring(data.name).." dbKey="..tostring(data.dbKey)) end
            n = n + 1
            local top = offsetY
            local bottom = offsetY + buttonHeight + buttonGap
            content[n] = {
                dataIndex = n,
                templateKey = "Entry",
                setupFunc = function(obj)
                    obj.parentDBKey = nil
                    obj:SetData(data)
                end,
                point = "TOPLEFT",
                relativePoint = "TOPLEFT",
                top = top,
                bottom = bottom,
                offsetX = offsetX,
            }
            offsetY = bottom

            if data.subOptions then
                for _, v in ipairs(data.subOptions) do
                    n = n + 1
                    top = offsetY
                    bottom = offsetY + buttonHeight + buttonGap
                    content[n] = {
                        dataIndex = n,
                        templateKey = "Entry",
                        setupFunc = function(obj)
                            obj.parentDBKey = data.dbKey
                            obj:SetData(v)
                        end,
                        point = "TOPLEFT",
                        relativePoint = "TOPLEFT",
                        top = top,
                        bottom = bottom,
                        offsetX = offsetX + 0.5*subOptionOffset,
                    }
                    offsetY = bottom
                end
            end
        end

        self.firstModuleData = cat.modules[1]
        self.ModuleTab.ScrollView:SetContent(content, false)
        if (ADT.DockLeft and ADT.DockLeft.IsStatic and ADT.DockLeft.IsStatic()) and self.UpdateStaticLeftPlacement then C_Timer.After(0, function() self:UpdateStaticLeftPlacement() end) end
        if ADT and ADT.DebugPrint then ADT.DebugPrint("[SettingsPanel] ShowSettingsCategory("..tostring(categoryKey)..") items="..tostring(#content)) end
        if self.firstModuleData then
            self:ShowFeaturePreview(self.firstModuleData)
        end
        if self.UpdateAutoWidth then self:UpdateAutoWidth() end
        if (ADT.DockLeft and ADT.DockLeft.IsStatic and ADT.DockLeft.IsStatic()) and self.UpdateStaticLeftPlacement then C_Timer.After(0, function() self:UpdateStaticLeftPlacement() end) end
    end

    function MainFrame:RefreshCategoryList()
        if not self.primaryCategoryPool then return end
        self.primaryCategoryPool:ReleaseAll()
        for index, categoryInfo in ipairs(CommandDock:GetSortedModules()) do
            local categoryButton = self.primaryCategoryPool:Acquire()
            categoryButton:SetCategory(categoryInfo.key, categoryInfo.categoryName, categoryInfo.anyNewFeature)
            categoryButton:SetPoint("TOPLEFT", self.LeftSlideContainer, self.primaryCategoryPool.offsetX, self.primaryCategoryPool.leftListFromY - (index - 1) * (Def.CategoryHeight or Def.ButtonSize))
            -- 根据需求取消临时板/最近放置的数量角标显示，避免不必要的数据遍历
            if ADT and ADT.DebugPrint and ADT.IsDebugEnabled and ADT.IsDebugEnabled() then
                local lx, ly = categoryButton:GetLeft(), categoryButton:GetTop()
                ADT.DebugPrint(string.format("[DockLeft] acquire #%d key=%s x=%.1f y=%.1f", index, tostring(categoryInfo.key), lx or -1, ly or -1))
            end
        end
        -- 动态收敛左侧容器高度：根据分类数量计算
        self:UpdateLeftSectionHeight()
        -- 静态模式下，同步一次弹窗高度与位置
        if (ADT.DockLeft and ADT.DockLeft.IsStatic and ADT.DockLeft.IsStatic()) and self.UpdateStaticLeftPlacement then self:UpdateStaticLeftPlacement() end
        -- 保持现有宽度；语言切换时由 RefreshLanguageLayout(true) 统一处理动画与宽度
    end

    function MainFrame:UpdateSettingsEntries()
        self.ModuleTab.ScrollView:CallObjectMethod("Entry", "UpdateState")
    end

    -- 显示装饰列表分类（临时板或最近放置）
    function MainFrame:ShowDecorListCategory(categoryKey)
        if not (self.ModuleTab and self.ModuleTab.ScrollView) then
            self.__pendingTabKey = categoryKey
            return
        end
        local cat = CommandDock:GetCategoryByKey(categoryKey)
        if not cat or cat.categoryType ~= 'decorList' then return end
        
        self.currentDecorCategory = categoryKey
        self.currentSettingsCategory = nil
        if ADT and ADT.SetDBValue then ADT.SetDBValue('LastCategoryKey', categoryKey) end
        
        local list = cat.getListData and cat.getListData() or {}
        local content = {}
        local n = 0
        local buttonHeight = 36 -- 装饰项按钮高度
        local fromOffsetY = Def.ButtonSize
        local offsetY = fromOffsetY
        local buttonGap = 2
        -- 右侧内容左内边距（Header 同步此起点）
        local offsetX = GetRightPadding()
        
        -- 添加标题（左对齐锚点）
        n = n + 1
        content[n] = {
            dataIndex = n,
            templateKey = "Header",
            setupFunc = function(obj)
                obj:SetText(cat.categoryName)
                -- 标题使用 Housing 分割线
                if obj.Left then obj.Left:Hide() end
                if obj.Right then obj.Right:Hide() end
                if obj.Divider then obj.Divider:Show() end
                obj.Label:SetJustifyH("LEFT")
            end,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT",
            top = offsetY,
            bottom = offsetY + Def.ButtonSize,
            offsetX = GetRightPadding(),
        }
        offsetY = offsetY + Def.ButtonSize
        
        -- 添加装饰项或空列表提示
        if #list == 0 then
            -- 空列表：用普通 Header 显示一行提示
            n = n + 1
            local emptyTop = offsetY + (Def.EmptyStateTopGap or 0)
            local emptyBottom = emptyTop + Def.ButtonSize
            content[n] = {
                dataIndex = n,
                templateKey = "Header",
                setupFunc = function(obj)
                    -- 注意：emptyText 可能包含换行符，这里只取第一行
                    local text = cat.emptyText or (ADT.L and ADT.L['List Is Empty']) or "列表为空"
                    local firstLine = text:match("^([^\n]*)")
                    obj:SetText(firstLine or text)
                    SetTextColor(obj.Label, Def.TextColorDisabled)
                    -- 仅保留页面主标题的分隔纹理；空列表提示不显示分隔线
                    if obj.Left then obj.Left:Hide() end
                    if obj.Right then obj.Right:Hide() end
                    if obj.Divider then obj.Divider:Hide() end
                    obj.Label:SetJustifyH("LEFT")
                end,
                point = "TOPLEFT",
                relativePoint = "TOPLEFT",
                top = emptyTop,
                bottom = emptyBottom,
                offsetX = offsetX,
            }
            -- 如果有第二行提示，继续添加
            if cat.emptyText and cat.emptyText:find("\n") then
                local secondLine = cat.emptyText:match("\n(.*)$")
                if secondLine and secondLine ~= "" then
                    n = n + 1
                    offsetY = emptyBottom
                    content[n] = {
                        dataIndex = n,
                        templateKey = "Header",
                        setupFunc = function(obj)
                            obj:SetText(secondLine)
                            SetTextColor(obj.Label, Def.TextColorDisabled)
                            -- 空列表第二行同样不显示分隔线
                            if obj.Left then obj.Left:Hide() end
                            if obj.Right then obj.Right:Hide() end
                            if obj.Divider then obj.Divider:Hide() end
                            obj.Label:SetJustifyH("LEFT")
                        end,
                        point = "TOPLEFT",
                        relativePoint = "TOPLEFT",
                        top = offsetY,
                        bottom = offsetY + Def.ButtonSize,
                        offsetX = offsetX,
                    }
                end
            end
        else
            -- 有装饰项：渲染列表
            for i, item in ipairs(list) do
                n = n + 1
                local top = offsetY
                local bottom = offsetY + buttonHeight + buttonGap
                local capCat = cat -- 捕获当前分类信息
                local capItem = item -- 捕获当前项
                content[n] = {
                    dataIndex = n,
                    templateKey = "DecorItem",
                    setupFunc = function(obj)
                        obj:SetData(capItem, capCat)
                    end,
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    top = top,
                    bottom = bottom,
                    offsetX = offsetX,
                }
                offsetY = bottom
            end
        end
        
        self.ModuleTab.ScrollView:SetContent(content, false)
        
        -- 显示第一个装饰项的预览
        if #list > 0 then
            local firstItem = list[1]
            local entryInfo = C_HousingCatalog and C_HousingCatalog.GetCatalogEntryInfoByRecordID
                and C_HousingCatalog.GetCatalogEntryInfoByRecordID(1, firstItem.decorID, true)
            local available = 0
            if entryInfo then
                available = (entryInfo.quantity or 0) + (entryInfo.remainingRedeemable or 0)
            end
            self:ShowDecorPreview(firstItem, available)
        else
            -- 空列表时显示提示（已无右侧预览/说明）
            if self.FeaturePreview then self.FeaturePreview:SetTexture(134400) end
            if self.FeatureDescription then self.FeatureDescription:SetText(cat.emptyText or (ADT.L and ADT.L['List Is Empty']) or "列表为空") end
        end
        if self.UpdateAutoWidth then self:UpdateAutoWidth() end
    end

    -- 返回设置列表视图
    function MainFrame:ShowSettingsView()
        self.currentDecorCategory = nil
        self.currentAboutCategory = nil
        self:RefreshFeatureList()
    end

    -- 显示信息分类（关于插件）
    function MainFrame:ShowAboutCategory(categoryKey)
        if not (self.ModuleTab and self.ModuleTab.ScrollView) then
            self.__pendingTabKey = categoryKey
            return
        end
        local cat = CommandDock:GetCategoryByKey(categoryKey)
        if not cat or cat.categoryType ~= 'about' then return end
        
        self.currentDecorCategory = nil
        self.currentAboutCategory = categoryKey
        self.currentSettingsCategory = nil
        if ADT and ADT.SetDBValue then ADT.SetDBValue('LastCategoryKey', categoryKey) end
        
        local content = {}
        local n = 0
        local buttonHeight = Def.ButtonSize
        local fromOffsetY = Def.ButtonSize
        local offsetY = fromOffsetY
        -- 右侧内容左内边距（Header 同步此起点）
        local offsetX = GetRightPadding()
        
        -- 添加标题（保留分隔线，左对齐锚点）
        n = n + 1
        content[n] = {
            dataIndex = n,
            templateKey = "Header",
            setupFunc = function(obj)
                obj:SetText(cat.categoryName)
                -- 确保标题的分割线可见（Housing 风格）
                if obj.Left then obj.Left:Hide() end
                if obj.Right then obj.Right:Hide() end
                if obj.Divider then obj.Divider:Show() end
                obj.Label:SetJustifyH("LEFT") -- 标题左对齐
            end,
            point = "TOPLEFT",
            relativePoint = "TOPLEFT",
            top = offsetY,
            bottom = offsetY + Def.ButtonSize,
            offsetX = GetRightPadding(),
        }
        offsetY = offsetY + Def.ButtonSize * 2
        
        -- 添加信息文本（隐藏分隔线，更靠左对齐；信息面板不占用 Entry 的“图标位”）
        if cat.getInfoText then
            local infoText = cat.getInfoText()
            -- 按换行符拆分
            for line in infoText:gmatch("[^\n]+") do
                n = n + 1
                content[n] = {
                    dataIndex = n,
                    templateKey = "Header",
                    setupFunc = function(obj)
                        obj:SetText(line)
                        obj.Label:SetJustifyH("LEFT") -- 信息行更靠左
                        -- 隐藏分割线纹理
                        if obj.Left then obj.Left:Hide() end
                        if obj.Right then obj.Right:Hide() end
                        if obj.Divider then obj.Divider:Hide() end
                        -- 单独设置信息行的左边距：不使用 Entry 的 28px 图标缩进
                        if obj.SetLeftPadding then obj:SetLeftPadding(GetRightPadding() + (Def.AboutTextExtraLeft or 0)) end
                    end,
                    point = "TOPLEFT",
                    relativePoint = "TOPLEFT",
                    top = offsetY,
                    bottom = offsetY + buttonHeight,
                    offsetX = offsetX,
                }
                offsetY = offsetY + buttonHeight
            end
        end
        
        self.ModuleTab.ScrollView:SetContent(content, false)
        if self.UpdateAutoWidth then self:UpdateAutoWidth() end
    end
end


local function CreateUI()
    local pageHeight = Def.PageHeight
    
    -- 紧凑布局：左侧宽度按“分类文本宽度”动态计算
    local sideSectionWidth = ComputeSideSectionWidth()
    MainFrame.sideSectionWidth = sideSectionWidth
    -- 右侧仅保留预览，默认更窄；后续在 UpdateAutoWidth 中会按可用空间动态压缩/放宽
    local rightSectionWidth = math.min(sideSectionWidth, 160)
    MainFrame.rightSectionWidth = rightSectionWidth
    local centralSectionWidth = 340  -- 中间：图标 + 长装饰名称(如"小型锯齿奥格瑞玛栅栏") + 数量

    -- 总宽度 = 左侧 + 中间 + 右侧（之前漏算右侧导致中间极窄）
    MainFrame:SetSize(sideSectionWidth + centralSectionWidth + rightSectionWidth, pageHeight)
    -- 固定停靠：由我们统一控制定位与尺寸，不再恢复历史尺寸
    MainFrame:SetToplevel(true)
    
    -- 禁止玩家拖动移动（固定右侧停靠）
    MainFrame:SetMovable(false)
    -- 修复：主框体不吃鼠标，避免其“透明区域”向左越界拦截 LeftPanel 点击。
    -- 世界交互的屏蔽改由局部 MouseBlocker 负责（仅覆盖右侧可见区域）。
    MainFrame:EnableMouse(false)
    if MainFrame.SetPropagateMouseClicks then MainFrame:SetPropagateMouseClicks(false) end
    if MainFrame.SetPropagateMouseMotion then MainFrame:SetPropagateMouseMotion(false) end
    MainFrame:RegisterForDrag() -- 清空注册（保持无拖拽）
    MainFrame:SetScript("OnDragStart", nil)
    MainFrame:SetScript("OnDragStop", nil)
    MainFrame:SetClampedToScreen(true)

    -- 顶部大 Header（对标 HouseEditor Storage 视觉）
    do
        local headerHeight = Def.HeaderHeight or 68
        local Header = CreateFrame("Frame", nil, MainFrame)
        MainFrame.Header = Header
        -- Header 仅覆盖右侧区域（不延伸到左侧分类区），并且左边始终贴合 LeftSection 的右缘
        Header:SetPoint("TOPLEFT", MainFrame.LeftSection or MainFrame, MainFrame.LeftSection and "TOPRIGHT" or "TOPLEFT", 0, 0)
        Header:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, 0)
        Header:SetHeight(headerHeight)

        local bg = Header:CreateTexture(nil, "ARTWORK")
        MainFrame.HeaderBackground = bg
        bg:SetAtlas("house-chest-header-bg")
        -- 直接铺满 Header 区域（Header 高度 68），并放在 ARTWORK 层级，以确保不被右侧黑底覆盖
        bg:SetAllPoints(Header)

        local title = Header:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        MainFrame.HeaderTitle = title
        title:SetPoint("LEFT", Header, "LEFT", Def.HeaderTitleOffsetX or 22, Def.HeaderTitleOffsetY or -10)
        title:SetJustifyH("LEFT")
        title:SetText((ADT.L and ADT.L['Addon Full Name']) or '高级装修工具')

        -- 向下顺延主体区域：将左右分栏的顶部锚到 Header 底部
        if MainFrame.LeftSection then
            MainFrame.LeftSection:ClearAllPoints()
            -- 左侧分类容器顶对 Header 底部，高度稍后按内容动态设置
            MainFrame.LeftSection:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, -headerHeight)
        end

        if MainFrame.RightSection then
            -- 右侧面板已废弃：保持隐藏且不参与布局
            MainFrame.RightSection:Hide()
            MainFrame.RightSection:ClearAllPoints()
            MainFrame.RightSection:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, 0)
            MainFrame.RightSection:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0)
            MainFrame.RightSection:SetWidth(0)
        end

        -- 根因治理：移除“右侧鼠标阻挡层”。
        -- 统一原则：Dock 主框体自身禁鼠；所有可交互行为仅来自其子控件。
        -- 因此不再创建 MouseBlocker，避免任何越界遮挡 LeftPanel 的风险。
        if MainFrame.MouseBlocker then
            MainFrame.MouseBlocker:Hide()
            MainFrame.MouseBlocker:SetScript("OnMouseDown", nil)
            MainFrame.MouseBlocker:SetScript("OnMouseUp", nil)
            MainFrame.MouseBlocker:EnableMouse(false)
            MainFrame.MouseBlocker = nil
        end
    end

    -- 禁止缩放：移除右下角抓手，并锁定最小尺寸约束仅用于内部自适应
    do
        -- 计算最小尺寸：高度至少能显示两行条目；
        -- 宽度：左侧固定列宽 + 右侧至少能显示“艾尔..”
        local meter = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        meter:SetText("艾尔..")
        local textMin = math.ceil(meter:GetStringWidth())
        meter:SetText("")
        meter:Hide()

        local iconW, gapW, countW, padW = 28, 8, 40, 16
        local rightMin = iconW + gapW + textMin + countW + padW
        local minH = 160
        local minW = sideSectionWidth + rightMin

        MainFrame:SetResizable(false)
        if MainFrame.SetResizeBounds then MainFrame:SetResizeBounds(minW, minH) end
        -- 隐藏并禁用原抓手
        if MainFrame.ResizeGrip then MainFrame.ResizeGrip:Hide() end
    end

    -- 固定停靠函数：右侧对齐，顶部与左侧 StoragePanel 对齐
    function MainFrame:ApplyDockPlacement()
        local parent = UIParent
        if HouseEditorFrame and HouseEditorFrame:IsShown() then
            parent = HouseEditorFrame
        end

        local topY = parent:GetTop() or 0
        local targetTop = topY
        if HouseEditorFrame and HouseEditorFrame.StoragePanel and HouseEditorFrame.StoragePanel:GetTop() then
            targetTop = HouseEditorFrame.StoragePanel:GetTop()
        end
        local yOffset = (targetTop or topY) - topY

        self:ClearAllPoints()
        self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -Def.ScreenRightMargin, yOffset)
        -- 静态左窗需要跟随重新贴边
        if USE_STATIC_LEFT_PANEL and self.UpdateStaticLeftPlacement then
            C_Timer.After(0, function() if self:IsShown() then self:UpdateStaticLeftPlacement() end end)
        end
    end

    -- 自动宽度：根据当前可见内容的字符串宽度，动态放宽中央区域
    function MainFrame:UpdateAutoWidth()
        local sidew = tonumber(self.LeftSection and self.LeftSection:GetWidth()) or tonumber(self.sideSectionWidth) or ComputeSideSectionWidth() or 180
        -- 取消外层左右额外留白；模板已提供 Label 左28/右28 的内部留白。
        local margin = 0

        local maxNeeded = 0
        local sv = self.ModuleTab and self.ModuleTab.ScrollView
        if sv and sv._templates then
            local function accumulate(poolKey, getter)
                local pool = sv._templates[poolKey]
                if not pool then return end
                for _, obj in pool:EnumerateActive() do
                    local w
                    if getter then w = getter(obj) end
                    if not w and obj.GetDesiredWidth then w = obj:GetDesiredWidth() end
                    if not w then
                        -- 兜底：尝试常见字段
                        local fs = (obj.Label or obj.Name)
                        if fs and fs.GetStringWidth then w = (fs:GetStringWidth() or 0) end
                    end
                    if type(w) == 'number' then maxNeeded = math.max(maxNeeded, math.ceil(w)) end
                end
            end
            accumulate("Entry")
            accumulate("DecorItem")
            accumulate("Header")
        end

        -- 合并 SubPanel 的宽度需求（由 SubPanel 自行测量并上报）
        local subNeed = 0
        do
            local sub = self.SubPanel or (self.EnsureSubPanel and self:EnsureSubPanel())
            if sub and sub.GetDesiredCenterWidth then
                subNeed = tonumber(sub:GetDesiredCenterWidth()) or 0
            end
        end

        -- 至少保证一个合理的最小值（配置驱动）
        local minCenter = 240
        if ADT and ADT.GetHousingCFG then
            local C = ADT.GetHousingCFG()
            if C and C.Layout and type(C.Layout.dockMinCenterWidth) == 'number' then
                minCenter = math.max(0, math.floor(C.Layout.dockMinCenterWidth))
            end
        end
        local wantedCenter = math.max(minCenter, maxNeeded, subNeed)
        -- 视口最大宽度限制（避免超出屏幕）
        local parent = self:GetParent() or UIParent
        local viewport = (parent.GetWidth and parent:GetWidth() or 1600) - Def.ScreenRightMargin - 4
        local maxTotal = viewport
        if ADT and ADT.GetHousingCFG then
            local C = ADT.GetHousingCFG()
            local r = C and C.Layout and C.Layout.dockMaxTotalWidthRatio
            if type(r) == 'number' and r > 0 and r <= 1 then
                maxTotal = math.floor(viewport * r)
            end
        end
        -- 无右侧栏：总宽 = 左栏 + 中央需求 + 边距
        local targetTotal = sidew + wantedCenter
        if targetTotal > maxTotal then targetTotal = maxTotal end
        targetTotal = math.floor(targetTotal + 0.5)
        local currentTotal = math.floor((self:GetWidth() or 0) + 0.5)
        if targetTotal ~= currentTotal then
            self:SetWidth(targetTotal)
        end
        self.sideSectionWidth = sidew

        -- 同步中央区域内各条目实际宽度
        -- 之前仅改变了 MainFrame 的总宽，而 ScrollView 内的对象仍保留创建时的旧宽，
        -- 会导致 Label 的锚点虽到右侧，但父按钮过窄，从而出现“启用 C...”之类的省略号。
        -- 这里在调整完总宽后，按 CentralSection 的最新可用宽度批量更新各模板对象尺寸。
        local CentralSection = self.CentralSection
        if CentralSection and self.ModuleTab and self.ModuleTab.ScrollView then
            local newWidth = tonumber(CentralSection:GetWidth()) or 0
            newWidth = math.floor(newWidth + 0.5)
            -- 按左侧统一缩进扣除可用宽度
            newWidth = newWidth - GetRightPadding()
            if newWidth > 0 then
                self.centerButtonWidth = newWidth
                local ScrollView = self.ModuleTab.ScrollView
                if ScrollView.CallObjectMethod then
                    ScrollView:CallObjectMethod("Entry", "SetWidth", newWidth)
                    ScrollView:CallObjectMethod("Header", "SetWidth", newWidth)
                    ScrollView:CallObjectMethod("DecorItem", "SetWidth", newWidth)
                end
                -- 触发一次强制重渲染，确保可见对象立即使用新宽度
                if ScrollView.OnSizeChanged then ScrollView:OnSizeChanged(true) end
            end
        end

        -- 更新锚点确保紧贴右缘
        self:ApplyDockPlacement()
    end
    
    -- 重要：FrameContainer 仅用于布局与滚轮，不应拦截鼠标点击/悬停。
    -- 否则会导致左侧滑出列表无法收到 OnEnter/OnClick。
    MainFrame.FrameContainer:EnableMouse(false)
    MainFrame.FrameContainer:EnableMouseMotion(false)
    MainFrame.FrameContainer:EnableMouseWheel(true)
    MainFrame.FrameContainer:SetScript("OnMouseWheel", function(self, delta) end)
    -- 模板中带的 TabButtonContainer 默认可交互；我们未使用，显式关闭避免遮挡左窗
    if MainFrame.TabButtonContainer then
        MainFrame.TabButtonContainer:Hide()
        MainFrame.TabButtonContainer:EnableMouse(false)
        MainFrame.TabButtonContainer:EnableMouseMotion(false)
    end



    local baseFrameLevel = MainFrame:GetFrameLevel()

    local LeftSection = MainFrame.LeftSection
    local CentralSection = MainFrame.CentralSection
    local RightSection = MainFrame.RightSection
    local Tab1 = MainFrame.ModuleTab

    -- 顶部标签布局：左侧容器仅用于占位/锚点，不承担交互
    LeftSection:SetWidth(sideSectionWidth)
    if LeftSection.EnableMouse then LeftSection:EnableMouse(false) end
    if LeftSection.EnableMouseMotion then LeftSection:EnableMouseMotion(false) end
    
    -- 移除整个右侧区域：不再占据任何宽度，也不创建任何子内容
    RightSection:Hide()
    RightSection:SetWidth(0)
    RightSection:ClearAllPoints()
    RightSection:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", 0, 0)
    RightSection:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0)

    -- CentralSection：顶部必须“紧贴 Header 底部”作为锚点，
    -- 不能再与 LeftSection 顶部对齐（那样会把内容顶到 Header 区域内部）。
    CentralSection:ClearAllPoints()
    CentralSection:SetPoint("TOPLEFT", MainFrame.Header or MainFrame, "BOTTOMLEFT", 0, 0)
    CentralSection:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0)
    if CentralSection.EnableMouse then CentralSection:EnableMouse(false) end
    if CentralSection.EnableMouseMotion then CentralSection:EnableMouseMotion(false) end


    -- LeftSection：改为调用 LeftPanel 模块统一构建（唯一权威，移除旧内联实现）
    do
        local DockLeft = ADT.DockLeft
        if DockLeft and DockLeft.Build then
            DockLeft.Build(MainFrame, sideSectionWidth)
        end
    end

    -- 右侧木质边框范围（仅包裹右侧区域，避免覆盖左窗）
    do
        local bf = MainFrame.BorderFrame
        if bf and MainFrame.Header then
            bf:ClearAllPoints()
            bf:SetPoint("TOPLEFT", MainFrame.Header, "TOPLEFT", 0, 0)
            bf:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0)
        end
    end

    -- 右侧整栏已移除；下面创建中央区域与其背景
    do  -- CentralSection（设置列表所在区域）
        -- 右侧统一背景：从 Header 左缘一路覆盖到面板右下，保证 Header 区域下方也有底纹
        if MainFrame.RightUnifiedBackground then MainFrame.RightUnifiedBackground:Hide() end
        local RBG = MainFrame:CreateTexture(nil, "BACKGROUND")
        MainFrame.RightUnifiedBackground = RBG
        RBG:SetAtlas("housing-basic-panel-background")
        RBG:ClearAllPoints()
        RBG:SetPoint("TOPLEFT", MainFrame.Header or MainFrame, "TOPLEFT", 0, 0)
        RBG:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", Def.RightBGInsetRight or -2, Def.RightBGInsetBottom or 2)
        -- 再创建中央区域独立背景，层级同为 BACKGROUND，不影响点击
        --（保留以强化中央区的对比度；两者叠加仍在 BACKGROUND 图层）
        
        -- 中央区域独立背景
        if MainFrame.CenterBackground then MainFrame.CenterBackground:Hide() end
        local CenterBG = MainFrame:CreateTexture(nil, "BACKGROUND")
        MainFrame.CenterBackground = CenterBG
        CenterBG:SetAtlas("housing-basic-panel-background")
        CenterBG:SetPoint("TOPLEFT", CentralSection, "TOPLEFT", 0, 0)
        CenterBG:SetPoint("BOTTOMRIGHT", CentralSection, "BOTTOMRIGHT", 0, Def.CenterBGInsetBottom or 2)

        -- 暂不显示自研滚动条，后续将切换为暴雪 ScrollBox 体系
        MainFrame.ModuleTab.ScrollBar = nil

        local ScrollView = API.CreateListView(Tab1)
        MainFrame.ModuleTab.ScrollView = ScrollView
        -- 列表视图顶端 = CentralSection 顶端（亦即 Header 底部）
        -- 给一段向内间距（Def.ScrollViewInsetTop），避免文字紧贴分隔线。
        ScrollView:SetPoint("TOPLEFT", CentralSection, "TOPLEFT", 0, - (Def.ScrollViewInsetTop or 6))
        ScrollView:SetPoint("BOTTOMRIGHT", CentralSection, "BOTTOMRIGHT", 0, (Def.ScrollViewInsetBottom or 2))
        ScrollView:SetStepSize(Def.ButtonSize * 2)
        ScrollView:OnSizeChanged()
        ScrollView:EnableMouseBlocker(true)
        ScrollView:SetBottomOvershoot(Def.CategoryGap)
        -- 不显示滚动条
        ScrollView:SetAlwaysShowScrollBar(false)
        ScrollView:SetShowNoContentAlert(true)
        ScrollView:SetNoContentAlertText(CATALOG_SHOP_NO_SEARCH_RESULTS or "")


        -- 初始右侧可用宽度，随着窗口缩放动态更新
        local function ComputeCenterWidth()
            local w = tonumber(CentralSection:GetWidth()) or 0
            if w <= 0 then
                local total = tonumber(MainFrame:GetWidth()) or 0
                local leftw = tonumber(MainFrame.sideSectionWidth) or 0
                local rightw = tonumber(MainFrame.rightSectionWidth) or leftw
                w = math.max(0, total - leftw - rightw)
            end
            -- 不在此处扣除外层 margin，避免与模板自身内边距叠加导致有效文本宽度过窄。
            w = API.Round(w)
            if w < 120 then w = 120 end
            return w
        end
        -- 梳理：所有列表项在渲染时都会以 GetRightPadding() 作为左侧缩进，
        -- 因而条目真实宽度 = 容器宽度 - 该缩进。统一在此处扣除，确保对齐一致。
        MainFrame.centerButtonWidth = ComputeCenterWidth() - GetRightPadding()
        Def.centerButtonWidth = MainFrame.centerButtonWidth


        local function EntryButton_Create()
            local obj = CreateSettingsEntry(ScrollView)
            obj:SetSize(MainFrame.centerButtonWidth or Def.centerButtonWidth, Def.ButtonSize)
            if obj.HideTextHighlight then obj:HideTextHighlight() end
            return obj
        end

        ScrollView:AddTemplate("Entry", EntryButton_Create)


        local function Header_Create()
            local obj = CreateSettingsHeader(ScrollView)
            obj:SetSize(MainFrame.centerButtonWidth or Def.centerButtonWidth, Def.ButtonSize)
            return obj
        end

        ScrollView:AddTemplate("Header", Header_Create)


        -- 装饰项模板（用于临时板和最近放置列表）
        local function DecorItem_Create()
            local obj = CreateDecorItemEntry(ScrollView)
            obj:SetSize(MainFrame.centerButtonWidth or Def.centerButtonWidth, 36)
            return obj
        end

        ScrollView:AddTemplate("DecorItem", DecorItem_Create)
    end


    -- 取消自定义边框相关占位与调用，改由顶部 UIPanelCloseButton 控制关闭

    -- 中央内容区创建完毕，应用待选标签
    MainFrame:ApplyInitialTabSelection()


    -- 打开时恢复到上次选中的分类/视图
    function MainFrame:HighlightCategoryByKey(key)
        if not key or not self.primaryCategoryPool then return end
        for _, button in self.primaryCategoryPool:EnumerateActive() do
            if button and button.categoryKey == key then
                self:HighlightButton(button)
                break
            end
        end
    end

    Tab1:SetScript("OnShow", function()
        if MainFrame.ApplyDockPlacement then MainFrame:ApplyDockPlacement() end
        local key = (ADT and ADT.GetDBValue and ADT.GetDBValue('LastCategoryKey')) or MainFrame.currentDecorCategory or MainFrame.currentAboutCategory or MainFrame.currentSettingsCategory
        -- 首次无记录时，显式记录并使用 "Housing" 作为默认分类
        if (not ADT.GetDBValue('LastCategoryKey')) then
            if ADT and ADT.SetDBValue then ADT.SetDBValue('LastCategoryKey', 'Housing') end
            key = 'Housing'
        end
        -- 显式首选“通用”（Housing）作为回退；若无则再选第一个设置类
        if not key then
            local housing = CommandDock:GetCategoryByKey('Housing')
            if housing and housing.categoryType == 'settings' then
                key = 'Housing'
            end
        end
        if ADT and ADT.DebugPrint then
            local cw = MainFrame.CentralSection and MainFrame.CentralSection:GetWidth() or 0
            local ch = MainFrame.CentralSection and MainFrame.CentralSection:GetHeight() or 0
            ADT.DebugPrint(string.format("[SettingsPanel] OnShow: key=%s, center=%.1fx%.1f", tostring(key), cw, ch))
        end
        if USE_TOP_TABS and MainFrame.TopTabOwner and MainFrame.__tabIDFromKey then
            local id = MainFrame.__tabIDFromKey[key] or MainFrame.__tabIDFromKey['Housing'] or 1
            MainFrame.TopTabOwner:SetTab(id)
            return
        end

        -- 旧布局回退逻辑
        local cat = key and CommandDock:GetCategoryByKey(key) or nil
        if cat and cat.categoryType == 'decorList' then
            MainFrame:ShowDecorListCategory(key)
            MainFrame:HighlightCategoryByKey(key)
        elseif cat and cat.categoryType == 'about' then
            MainFrame:ShowAboutCategory(key)
            MainFrame:HighlightCategoryByKey(key)
        elseif cat and cat.categoryType == 'settings' then
            MainFrame:ShowSettingsCategory(key)
            MainFrame:HighlightCategoryByKey(key)
        else
            -- 默认回退到第一个“设置类”分类（若存在 Housing 优先）
            local all = CommandDock:GetSortedModules()
            local firstSettings
            -- Housing 优先
            for _, info in ipairs(all) do
                if info.key == 'Housing' and info.categoryType ~= 'decorList' and info.categoryType ~= 'about' then
                    firstSettings = 'Housing'; break
                end
            end
            -- 通用不存在时，取第一个设置类
            for _, info in ipairs(all) do
                if info.categoryType ~= 'decorList' and info.categoryType ~= 'about' then
                    firstSettings = firstSettings or info.key; break
                end
            end
            if firstSettings then
                MainFrame:ShowSettingsCategory(firstSettings)
                MainFrame:HighlightCategoryByKey(firstSettings)
            else
                MainFrame:RefreshFeatureList()
            end
        end
        if MainFrame.UpdateAutoWidth then MainFrame:UpdateAutoWidth() end
        if (ADT.DockLeft and ADT.DockLeft.IsStatic and ADT.DockLeft.IsStatic()) and MainFrame.UpdateStaticLeftPlacement then C_Timer.After(0, function() if MainFrame:IsShown() then MainFrame:UpdateStaticLeftPlacement() end end) end
    end)

    -- 单一 OnSizeChanged：当窗口缩放时，仅调整右侧内容宽度
    MainFrame:SetScript("OnSizeChanged", function(self)
        local CentralSection = self.CentralSection
        if not CentralSection or not self.ModuleTab or not self.ModuleTab.ScrollView then return end
        local total = tonumber(self:GetWidth()) or 0
        local leftw = tonumber(self.sideSectionWidth) or 0
        local w = tonumber(CentralSection:GetWidth()) or (total - leftw)
        -- 修正：列表项左侧存在统一缩进 offsetX = GetRightPadding()，
        -- 条目实际可用宽度应扣除该缩进，避免右侧对齐越界。
        local newWidth = API.Round((w or 0)) - GetRightPadding()
        if newWidth < 120 then newWidth = 120 end
        if newWidth <= 0 then return end

        -- 同步左侧滑出容器宽度与收起偏移
        if self.LeftSlideContainer and self.LeftSection then
            local lw = tonumber(self.LeftSection:GetWidth()) or 0
            if lw > 0 then self.LeftSlideContainer:SetWidth(lw) end
            if self.LeftSlideDriver and self.GetLeftClosedOffset then
                local closed = self.GetLeftClosedOffset()
                if math.abs(self.LeftSlideDriver.target) > 0.5 then
                    self.LeftSlideDriver.target = closed
                    if math.abs(self.LeftSlideDriver.x - closed) < 1 then
                        self.LeftSlideDriver.x = closed
                        if self.LeftSlideDriver.onUpdate then self.LeftSlideDriver.onUpdate(closed) end
                    end
                end
            end
        end
        if self.centerButtonWidth ~= newWidth then
            self.centerButtonWidth = newWidth
            local ScrollView = self.ModuleTab.ScrollView
            ScrollView:CallObjectMethod("Entry", "SetWidth", newWidth)
            ScrollView:CallObjectMethod("Header", "SetWidth", newWidth)
            ScrollView:CallObjectMethod("DecorItem", "SetWidth", newWidth)
            ScrollView:OnSizeChanged(true)
            if self.ModuleTab.ScrollBar and self.ModuleTab.ScrollBar.UpdateThumbRange then
                self.ModuleTab.ScrollBar:UpdateThumbRange()
            end
        end
    end)

    -- 初次创建后立即固定停靠并做一次自适应宽度
    if MainFrame.ApplyDockPlacement then MainFrame:ApplyDockPlacement() end
    if MainFrame.UpdateAutoWidth then MainFrame:UpdateAutoWidth() end

    -- 监听分辨率/缩放/编辑器模式变化，保持右侧贴边
    local AnchorWatcher = CreateFrame("Frame", nil, MainFrame)
    AnchorWatcher:RegisterEvent("DISPLAY_SIZE_CHANGED")
    AnchorWatcher:RegisterEvent("UI_SCALE_CHANGED")
    AnchorWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    AnchorWatcher:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    AnchorWatcher:SetScript("OnEvent", function()
        C_Timer.After(0, function()
            if MainFrame and MainFrame.ApplyDockPlacement then MainFrame:ApplyDockPlacement() end
            if MainFrame and MainFrame.UpdateAutoWidth then MainFrame:UpdateAutoWidth() end
        end)
    end)

    -- 注册数据变化回调，实时刷新 GUI
    -- Clipboard 数据变化时刷新
    if ADT.Clipboard then
        local origOnChanged = ADT.Clipboard.OnChanged
        ADT.Clipboard.OnChanged = function(self)
            if origOnChanged then origOnChanged(self) end
            -- 如果当前显示的是临时板分类，则刷新列表
            if MainFrame:IsShown() and MainFrame.currentDecorCategory == 'Clipboard' then
                MainFrame:ShowDecorListCategory('Clipboard')
            end
            -- 刷新分类列表的数量角标
            MainFrame:RefreshCategoryList()
        end
    end

    -- History 数据变化时刷新
    if ADT.History then
        local origOnHistoryChanged = ADT.History.OnHistoryChanged
        ADT.History.OnHistoryChanged = function(self)
            if origOnHistoryChanged then origOnHistoryChanged(self) end
            -- 如果当前显示的是最近放置分类，则刷新列表
            if MainFrame:IsShown() and MainFrame.currentDecorCategory == 'History' then
                MainFrame:ShowDecorListCategory('History')
            end
            -- 刷新分类列表的数量角标
            MainFrame:RefreshCategoryList()
        end
    end
end

-- 订阅“进入编辑器自动打开 Dock”设置，实时应用默认显隐
if ADT and ADT.Settings and ADT.Settings.On then
    ADT.Settings.On('EnableDockAutoOpenInEditor', function()
        if ADT and ADT.DockUI and ADT.DockUI.ApplyPanelsDefaultVisibility then
            ADT.DockUI.ApplyPanelsDefaultVisibility()
        end
    end)
end

function MainFrame:UpdateLayout()
    local frameWidth = math.floor(self:GetWidth() + 0.5)
    if frameWidth == self.frameWidth then
        return
    end
    self.frameWidth = frameWidth

    self.ModuleTab.ScrollView:OnSizeChanged()
    if self.ModuleTab.ScrollBar and self.ModuleTab.ScrollBar.OnSizeChanged then
        self.ModuleTab.ScrollBar:OnSizeChanged()
    end
end


function MainFrame:ShowUI(mode)
    if CreateUI then
        CreateUI()
        CreateUI = nil

        CommandDock:UpdateCurrentSortMethod()
        if self.primaryCategoryPool then
            self:RefreshCategoryList()
        end
    end

    mode = mode or "standalone"
    self.mode = mode
    -- 关闭按钮由 UIPanelCloseButton 提供，无需额外控制
    self:UpdateLayout()
    -- 固定停靠：不再恢复历史位置，统一由 ApplyDockPlacement 控制
    -- 仅确保创建，不默认展示；需要时由业务侧显式打开
    self:EnsureSubPanel()
    self:SetSubPanelShown(false)
    self:Show()
end

function MainFrame:HandleEscape()
    self:Hide()
    return false
end

-- ESC 关闭功能（按 ESC 关闭面板）
do
    local CloseDummy = CreateFrame("Frame", "ADTSettingsPanelSpecialFrame", UIParent)
    CloseDummy:Hide()
    table.insert(UISpecialFrames, CloseDummy:GetName())

    CloseDummy:SetScript("OnHide", function()
        if MainFrame:HandleEscape() then
            CloseDummy:Show()
        end
    end)

    MainFrame:HookScript("OnShow", function()
        if MainFrame.mode == "standalone" then
            CloseDummy:Show()
        end
    end)

    MainFrame:HookScript("OnHide", function()
        CloseDummy:Hide()
    end)

    -- 注意：OnSizeChanged 已在 CreateUI 中注册，此处不再重复绑定。
end

-- 编辑模式自动打开 GUI（替代独立弹窗）
do
    local EditorWatcher = CreateFrame("Frame")
    local wasEditorActive = false
    
    local function UpdateEditorState()
        local isActive = C_HouseEditor and C_HouseEditor.IsHouseEditorActive and C_HouseEditor.IsHouseEditorActive()
        
        if isActive then
            if not wasEditorActive then
                -- 进入编辑模式：无论是否默认开启，都先创建并显示 Dock 容器，
                -- 再按用户设置隐藏/显示“主体面板”。这样 SubPanel/清单仍可独立工作。
                MainFrame:ShowUI("editor")
                -- 若默认开启，则聚焦到“通用”分类；否则仅保持容器存在
                local v = ADT and ADT.GetDBValue and ADT.GetDBValue('EnableDockAutoOpenInEditor')
                local shouldAutoOpen = (v ~= false)
                if shouldAutoOpen then
                    C_Timer.After(0, function()
                        MainFrame:ShowSettingsCategory('Housing')
                        if ADT and ADT.SetDBValue then ADT.SetDBValue('LastCategoryKey', 'Housing') end
                    end)
                end
                -- 应用默认显隐（只影响 Dock 主体，不影响 SubPanel）
                C_Timer.After(0, function()
                    if ADT and ADT.DockUI and ADT.DockUI.ApplyPanelsDefaultVisibility then
                        ADT.DockUI.ApplyPanelsDefaultVisibility()
                    end
                end)
            end
            -- 调整层级确保在编辑器之上
            if HouseEditorFrame then
                -- 调整：主面板不再提升到 "TOOLTIP"，避免与 LeftPanel（同样在 TOOLTIP）互抢层级。
                -- 使用 "FULLSCREEN_DIALOG" 足以压过编辑器普通层，又能确保 LeftPanel 始终在其之上。
                MainFrame:SetParent(HouseEditorFrame)
                MainFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            end
        else
            -- 退出编辑模式：隐藏 GUI
            MainFrame:SetParent(UIParent)
            MainFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            MainFrame:Hide()
        end
        
        wasEditorActive = isActive
    end
    
    EditorWatcher:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
    EditorWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
    EditorWatcher:SetScript("OnEvent", function(_, event)
        if event == "HOUSE_EDITOR_MODE_CHANGED" then
            -- 离开编辑模式时，立刻隐藏以避免可见闪烁；进入时再做轻微延迟以等待编辑器完成布局
            local isActive = C_HouseEditor and C_HouseEditor.IsHouseEditorActive and C_HouseEditor.IsHouseEditorActive()
            if not isActive then
                -- 立即隐藏，不等待
                if MainFrame then
                    MainFrame:SetParent(UIParent)
                    MainFrame:SetFrameStrata("FULLSCREEN_DIALOG")
                    MainFrame:Hide()
                end
                wasEditorActive = false
                return
            end
        end
        -- 进入或其它情况：短延迟以确保编辑器框架已就位
        C_Timer.After(0.05, UpdateEditorState)
    end)
end
