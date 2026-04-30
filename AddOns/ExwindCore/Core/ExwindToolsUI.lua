-- =========================================================
-- ExwindTools UI v4.1 - 原生 Grid 引擎版
-- =========================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

local L = ExwindTools.L

-- 使用已存在的 EXUI（由 ExwindGUI.lua 和 ExwindGrid.lua 创建）
local EXUI = ExwindTools.UI or {}
ExwindTools.UI = EXUI
_G.ExwindToolsUI = EXUI


-- =========================================================
-- 视觉主题配置
-- =========================================================
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
-- [Fix] 优先提取当前游戏的通用字体（适配用户手动改字体的情况）
-- [Fix] 强制使用系统默认字体 (GameFontNormal)，不再依赖自定义或第三方字体
local defaultFontPath = GameFontNormal:GetFont()
-- [Fix] 恢复变量定义以兼容现有代码的 50+ 处引用 (功能上已全部指向系统默认字体)
local msyh = defaultFontPath
local msyhbd = defaultFontPath


local THEME = {
    -- [Style] 调整色调为深色一体化风格
    Background = { 0.04, 0.04, 0.05, 0.98 }, -- [Fixed] 极致深色背景
    Sidebar = { 0, 0, 0, 0 },                -- 侧边栏透明，融入背景
    Border = { 0.25, 0.25, 0.28, 1 },        -- [Style] 稍微提亮边框
    Primary = { 0.64, 0.19, 0.79 },          -- 主色调 (紫色)保持不变
    Success = { 0.13, 0.77, 0.37 },
    Danger = { 0.87, 0.26, 0.26 },
    TextMain = { 0.9, 0.9, 0.9, 1 },
    TextSub = { 0.6, 0.6, 0.65, 1 },
    TextDim = { 0.4, 0.4, 0.45, 1 },
    CardBg = { 0.18, 0.18, 0.22, 0.6 },
    CardBgHover = { 0.22, 0.22, 0.26, 0.8 },
}

local BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 14,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

local BACKDROP_SIMPLE = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = nil,
}

-- =========================================================
-- 全局状态
-- =========================================================
EXUI.MainFrame = nil    -- 原生 WoW Frame
EXUI.SidebarFrame = nil -- 左侧导航滚动子容器
EXUI.RightPanel = nil   -- 右侧内容容器
EXUI.CurrentPage = "Home"
EXUI.CurrentModule = nil
EXUI.ActivePageFrame = nil           -- 当前页面的 Frame
EXUI.PendingRightScrollRestore = nil -- 通用右侧滚动容器刷新后需要恢复的滚动位置

-- =========================================================
-- Toggle UI
-- =========================================================
function EXUI:Toggle()
    if not EXUI.MainFrame then
        EXUI:CreateMainFrame()
    end
    if EXUI.MainFrame:IsShown() then
        EXUI.MainFrame:Hide()
    else
        EXUI.MainFrame:Show()
        EXUI:RefreshContent()
        if ExwindTools.HandleChangelogPopupOnUIOpen then
            C_Timer.After(0.05, function()
                if EXUI.MainFrame and EXUI.MainFrame:IsShown() and ExwindTools.HandleChangelogPopupOnUIOpen then
                    ExwindTools:HandleChangelogPopupOnUIOpen()
                end
            end)
        end
    end
end

-- =========================================================
-- 创建主框架 (完全原生实现)
-- =========================================================
function EXUI:CreateMainFrame()
    -- 1. 创建主窗口
    local f = CreateFrame("Frame", "ExwindToolsMainFrame", UIParent, "BackdropTemplate")
    f:SetSize(1200, 720)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(false)

    -- 主题效果
    f:SetBackdrop(BACKDROP)
    f:SetBackdropColor(unpack(THEME.Background))
    f:SetBackdropBorderColor(unpack(THEME.Border))

    -- 拖拽逻辑
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- 装饰：标题区
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -15)
    title:SetText("|cffA330C9ExwindTools|r " .. L["设置中心"])
    f.Title = title

    --底层显示
    local status = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("BOTTOMLEFT", 20, 15)
    status:SetText(string.format(L["版本: %s | 引擎: GRID %s"], ExwindTools.VERSION or "Unknown",
        ExwindTools.GridEngineVersion or "Unknown"))
    f.Status = status

    -- 暴雪原生关闭按钮
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() f:Hide() end)
    f.CloseButton = closeBtn -- 存储引用供皮肤模块直接获取

    -- [Fix] 移除 UISpecialFrames 注册以避免 Blizzard_QuickJoin Taint 报错
    -- tinsert(UISpecialFrames, "ExwindToolsMainFrame") (此操作在某些情况下会导致安全表污染)
    -- 注册到 UISpecialFrames 以支持 ESC 键关闭
    tinsert(UISpecialFrames, "ExwindToolsMainFrame")
    EXUI.MainFrame = f

    -- 2. 创建子区域
    EXUI:CreateSidebar(f)
    EXUI:CreateRightPanel(f)

    -- 底部功能区
    local footer = CreateFrame("Frame", nil, f)
    footer:SetSize(850, 40)
    footer:SetPoint("BOTTOMRIGHT", -15, 10)

    local reloadBtn = EXUI:CreateSmallButton(footer, L["立即重载界面"], function()
        C_UI.Reload()
    end)
    reloadBtn:SetPoint("RIGHT", 0, -8)
    reloadBtn:SetSize(180, 26)

    -- [v4.7] 新增编辑模式快捷开关
    local editBtn = EXUI:CreateSmallButton(footer, ExwindTools.GlobalEditMode and L["关闭编辑模式"] or L["启用编辑模式"], function()
        ExwindTools:ToggleGlobalEditMode()
        -- [优化] 如果开启了编辑模式，自动关闭设置面板，方便用户调整布局
        if ExwindTools.GlobalEditMode and f:IsShown() then
            f:Hide()
        end
    end)
    editBtn:SetPoint("RIGHT", reloadBtn, "LEFT", -10, 0)
    editBtn:SetSize(180, 26)
    EXUI.EditModeToggleButton = editBtn

    local changelogBtn = EXUI:CreateSmallButton(footer, L["更新日志"], function()
        if ExwindTools.ShowChangelog then
            ExwindTools:ShowChangelog({ markShown = true })
        end
    end)
    changelogBtn:SetPoint("RIGHT", editBtn, "LEFT", -10, 0)
    changelogBtn:SetSize(150, 26)
    EXUI.ChangelogButton = changelogBtn

    f:Hide()
end

-- =========================================================
-- 创建左侧导航栏
-- =========================================================
function EXUI:CreateSidebar(parent)
    local sidebar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    sidebar:SetSize(280, 630)
    sidebar:SetPoint("TOPLEFT", 15, -50)
    -- [Style] 去掉侧边栏背景色，改为透明
    sidebar:SetBackdrop(nil)
    -- sidebar:SetBackdropColor(unpack(THEME.Sidebar))

    -- [Style] 添加一条垂直分割线，区分侧边栏和内容区
    local vLine = sidebar:CreateTexture(nil, "ARTWORK")
    vLine:SetSize(1, 620)
    vLine:SetPoint("TOPRIGHT", 0, 0)
    vLine:SetColorTexture(1, 1, 1, 0.05)

    -- 为滚动条分配固定名称以启用材质隐藏逻辑
    local scrollFrame = CreateFrame("ScrollFrame", "ExwindSidebarScroll", sidebar, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

    -- 手动隐藏旧版金边材质
    if _G["ExwindSidebarScrollTop"] then _G["ExwindSidebarScrollTop"]:Hide() end
    if _G["ExwindSidebarScrollBottom"] then _G["ExwindSidebarScrollBottom"]:Hide() end

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(250, 1)
    scrollFrame:SetScrollChild(scrollChild)

    EXUI.SidebarFrame = scrollChild
    EXUI:BuildNavigationTree(scrollChild)
end

-- =========================================================
-- [v4.6] Sidebar Redesign (Modern Tree View)
-- =========================================================
-- 侧边栏折叠状态与对象池
EXUI.SidebarState = { Expanded = { true, true, true, true, true } }
EXUI.SidebarPool = { Headers = {}, Items = {} }

-- 对象池获取
function EXUI:GetSidebarObj(type, parent)
    local pool = EXUI.SidebarPool[type]
    for _, obj in ipairs(pool) do
        if not obj:IsShown() then
            obj:SetParent(parent)
            obj:Show()
            return obj
        end
    end
    -- 新建对象
    local obj
    if type == "Headers" then
        obj = EXUI:CreateCategoryHeaderBase(parent)
    elseif type == "Items" then
        obj = EXUI:CreateSidebarItemBase(parent)
    end
    table.insert(pool, obj)
    return obj
end

-- 创建分类标题头
function EXUI:CreateCategoryHeaderBase(parent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(240, 32) -- [Style] 增加高度，更像一个Bar

    -- [Style] 背景：水平渐变 (左深右浅)
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(1, 1, 1, 1)
    -- 使用 CreateColor 定义渐变色 (深灰色 -> 透明)
    btn.bg:SetGradient("HORIZONTAL", CreateColor(0.18, 0.18, 0.22, 0.7), CreateColor(0.05, 0.05, 0.08, 0))

    -- [Style] 左侧装饰条 (金色)
    btn.bar = btn:CreateTexture(nil, "ARTWORK")
    btn.bar:SetSize(3, 30)
    btn.bar:SetPoint("LEFT", 0, 0)
    btn.bar:SetColorTexture(1, 0.82, 0, 0.9)

    -- 折叠箭头
    btn.arrow = btn:CreateFontString(nil, "OVERLAY")
    btn.arrow:SetFontObject("GameFontHighlight") -- 稍微缩小
    btn.arrow:SetPoint("LEFT", 8, 0)
    btn.arrow:SetTextColor(0.8, 0.8, 0.8)

    -- 标题
    btn.label = btn:CreateFontString(nil, "OVERLAY")
    btn.label:SetFontObject("GameFontNormal")
    btn.label:SetPoint("LEFT", 22, 0)
    btn.label:SetTextColor(1, 0.82, 0) -- 金色标题

    -- 交互反馈
    btn:SetScript("OnEnter", function(self)
        -- 悬停时背景变亮
        self.bg:SetGradient("HORIZONTAL", CreateColor(0.25, 0.25, 0.3, 0.8), CreateColor(0.1, 0.1, 0.15, 0))
        self.arrow:SetTextColor(1, 1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        -- 恢复默认
        self.bg:SetGradient("HORIZONTAL", CreateColor(0.18, 0.18, 0.22, 0.7), CreateColor(0.05, 0.05, 0.08, 0))
        self.arrow:SetTextColor(0.8, 0.8, 0.8)
    end)

    return btn
end

-- 创建子项目按钮
function EXUI:CreateSidebarItemBase(parent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(240, 30) -- [Style] 高度稍微减小一点，更紧凑

    -- 高亮背景 (左侧亮条 + 渐变背景)
    btn.accent = btn:CreateTexture(nil, "ARTWORK")
    btn.accent:SetSize(4, 18)
    btn.accent:SetPoint("LEFT", 12, 0)
    btn.accent:SetColorTexture(0.2, 0.75, 1) -- [Color] 冰川蓝
    btn.accent:SetAlpha(0)

    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    btn.bg:SetColorTexture(0.2, 0.75, 1, 0.1) -- [Color] 冰川蓝背景淡色
    btn.bg:SetAlpha(0)

    btn.badge = btn:CreateTexture(nil, "OVERLAY")
    btn.badge:SetSize(64, 33)
    btn.badge:Hide()

    -- 文本
    btn.label = btn:CreateFontString(nil, "OVERLAY")
    btn.label:SetFontObject("GameFontHighlight")
    btn.label:SetPoint("LEFT", 28, 0)      -- 缩进适配层级
    btn.label:SetJustifyH("LEFT")
    btn.label:SetTextColor(0.8, 0.8, 0.85) -- [Style] 默认字体颜色提亮
    btn.label:SetWidth(200)
    btn.label:SetWordWrap(false)

    btn:SetBackdrop(BACKDROP_SIMPLE)
    btn:SetBackdropColor(0, 0, 0, 0)

    btn:SetScript("OnEnter", function(self)
        if self.isLoaded == false then return end -- [New] 未载入模块不显示悬停效果
        if not self.isActive then
            self:SetBackdropColor(1, 1, 1, 0.04)
            self.label:SetTextColor(1, 1, 1)
        end
    end)
    btn:SetScript("OnLeave", function(self)
        if self.isLoaded == false then return end
        if not self.isActive then
            self:SetBackdropColor(0, 0, 0, 0)
            self.label:SetTextColor(0.8, 0.8, 0.85, 1)
        end
    end)

    return btn
end

local function UpdateSidebarItemBadge(btn, meta)
    if not btn or not btn.badge or not btn.label then return end

    btn.badge:Hide()
    btn.label:ClearAllPoints()
    btn.label:SetPoint("LEFT", 28, 0)
    btn.label:SetWidth(200)

    if meta and meta.new then
        local faction = _G.UnitFactionGroup and _G.UnitFactionGroup("player")
        local atlas = faction == "Alliance" and "NewCharacter-Alliance" or "NewCharacter-Horde"
        btn.badge:SetAtlas(atlas, false)
        btn.badge:ClearAllPoints()
        btn.badge:SetPoint("RIGHT", btn.label, "LEFT", 25, 0)
        btn.label:SetWidth(160)
        btn.badge:Show()
    end
end

-- 构建导航树 (核心逻辑)
function EXUI:BuildNavigationTree(parent)
    -- 1. 回收旧对象到池中 (Hide)
    if EXUI.SidebarPool.Headers then for _, v in ipairs(EXUI.SidebarPool.Headers) do v:Hide() end end
    if EXUI.SidebarPool.Items then for _, v in ipairs(EXUI.SidebarPool.Items) do v:Hide() end end

    local yOffset = -5

    -- 2. 静态导航项 (首页/载入/诊断/配置管理)
    local staticItems = {
        { name = L["首页概览"], page = "Home" },
        { name = L["模块管理"], page = "LoadSettings" },
        { name = L["状态诊断"], page = "Diagnostic" },
        { name = L["配置管理"], page = "ProfileManager" }
    }

    local function CreateItem(name, page, key, meta)
        local btn = EXUI:GetSidebarObj("Items", parent)
        btn.page = page
        btn.moduleKey = key
        UpdateSidebarItemBadge(btn, meta)

        -- [New] 检测模块是否已载入
        local isModule = (key ~= nil)
        local isLoaded = not isModule
        if isModule and ExwindTools.DB and ExwindTools.DB.LoadByKey then
            isLoaded = ExwindTools.DB.LoadByKey[key]
        end
        btn.isLoaded = isLoaded

        if isModule and not isLoaded then
            btn.label:SetText("|cff888888" .. name .. " (" .. L["未载入"] .. ")|r")
        else
            btn.label:SetText(name)
        end

        btn:SetPoint("TOPLEFT", 5, yOffset)

        btn:SetScript("OnClick", function()
            -- [New] 未载入模块禁止点击切换
            if isModule and not isLoaded then return end

            -- [Fix] 增加延迟到 0.1s 以彻底断开执行栈，避免污染暴雪的 QuickJoinToast 更新
            C_Timer.After(0.1, function()
                EXUI.CurrentPage = page
                EXUI.CurrentModule = key
                EXUI:RefreshContent()
            end)
        end)

        yOffset = yOffset - 31 -- [Style] 间距微调
    end

    for _, info in ipairs(staticItems) do
        CreateItem(info.name, info.page, nil, nil)
    end

    yOffset = yOffset - 10

    -- 分割线
    if not EXUI.NavDivider then
        EXUI.NavDivider = parent:CreateTexture(nil, "ARTWORK")
        EXUI.NavDivider:SetSize(230, 1)
        EXUI.NavDivider:SetColorTexture(1, 1, 1, 0.08)
    end
    EXUI.NavDivider:SetPoint("TOP", 0, yOffset)
    yOffset = yOffset - 15

    -- 3. 动态分类树
    for cateId = 1, 5 do
        local cateName = ExwindTools.Cate[cateId]
        if cateName then
            local header = EXUI:GetSidebarObj("Headers", parent)
            local isExpanded = EXUI.SidebarState.Expanded[cateId]

            header.arrow:SetText(isExpanded and "▼" or "▶")
            header.label:SetText(cateName)
            header:SetPoint("TOPLEFT", 5, yOffset)

            header:SetScript("OnClick", function()
                -- [Fix] 延迟执行避免 Taint
                C_Timer.After(0.1, function()
                    EXUI.SidebarState.Expanded[cateId] = not EXUI.SidebarState.Expanded[cateId]
                    EXUI:BuildNavigationTree(parent) -- 递归重建
                end)
            end)

            yOffset = yOffset - 34 -- [Style] Header 高度加间距

            if isExpanded then
                for _, meta in ipairs(ExwindTools.ModuleList) do
                    if meta.Category == cateId and not meta.HideCfg then
                        CreateItem(meta.Name, "ModuleSettings", meta.Key, meta)
                    end
                end
                yOffset = yOffset - 8
            end
        end
    end

    parent:SetHeight(math.abs(yOffset) + 50)
    EXUI:UpdateNavButtonStates()
end

-- 更新侧边栏按钮选中状态
function EXUI:UpdateNavButtonStates()
    if not EXUI.SidebarFrame or not EXUI.SidebarPool.Items then return end

    for _, btn in ipairs(EXUI.SidebarPool.Items) do
        if btn:IsShown() and btn.page then
            local isActive = (btn.page == EXUI.CurrentPage and btn.moduleKey == EXUI.CurrentModule)
            btn.isActive = isActive
            if isActive then
                btn.accent:SetAlpha(1)
                btn.bg:SetAlpha(1)
                btn.label:SetTextColor(1, 1, 1, 1)
            else
                btn.accent:SetAlpha(0)
                btn.bg:SetAlpha(0)
                if btn.isLoaded == false then
                    btn.label:SetTextColor(0.5, 0.5, 0.5, 1)  -- [New] 未载入模块文字更暗
                else
                    btn.label:SetTextColor(0.8, 0.8, 0.85, 1) -- [Style] 默认字体提亮
                end
                btn:SetBackdropColor(0, 0, 0, 0)
            end
        end
    end
end

-- =========================================================
-- 创建右侧普通 Frame 容器 (用于首页和载入页面)
-- =========================================================
function EXUI:CreateRightPanel(parent)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(850, 630)
    panel:SetPoint("TOPLEFT", 335, -50)
    -- [Style] 去掉右侧内容区背景色，改为透明
    panel:SetBackdrop(nil)
    -- panel:SetBackdropColor(0.05, 0.05, 0.07, 0.5)

    -- [New] 通用滚动容器 (为所有普通页面提供滚动支持)
    local sf = CreateFrame("ScrollFrame", "ExwindCommonScroll", panel, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, -5)
    sf:SetPoint("BOTTOMRIGHT", -25, 5)

    -- 隐藏不需要的材质
    if _G["ExwindCommonScrollTop"] then _G["ExwindCommonScrollTop"]:Hide() end
    if _G["ExwindCommonScrollBottom"] then _G["ExwindCommonScrollBottom"]:Hide() end
    if _G["ExwindCommonScrollScrollBarScrollUpButton"] then _G["ExwindCommonScrollScrollBarScrollUpButton"]:Hide() end
    if _G["ExwindCommonScrollScrollBarScrollDownButton"] then _G["ExwindCommonScrollScrollBarScrollDownButton"]:Hide() end

    local sc = CreateFrame("Frame", nil, sf)
    sc:SetSize(750, 1)
    sf:SetScrollChild(sc)

    EXUI.RightPanel = panel
    EXUI.RightScrollFrame = sf
    EXUI.RightScrollChild = sc
end

-- =========================================================
-- 刷新逻辑
-- =========================================================
function EXUI:RefreshContent()
    local restoreRightScroll = EXUI.PendingRightScrollRestore
    EXUI.PendingRightScrollRestore = nil

    -- 设置切换标志
    EXUI.SwitchingModule = true

    -- 清理旧的页面内容
    if EXUI.ActivePageFrame then
        EXUI.ActivePageFrame:Hide()
        EXUI.ActivePageFrame:SetParent(nil)
        EXUI.ActivePageFrame = nil
    end

    -- 默认隐藏所有专用容器
    if EXUI.ModuleScrollFrame then EXUI.ModuleScrollFrame:Hide() end
    if EXUI.NoLayoutLabel then EXUI.NoLayoutLabel:Hide() end

    -- 清除切换标志
    EXUI.SwitchingModule = nil
    -- [Fix] 防御性检查：如果 UI 还没初始化完整（RightPanel 为空），不执行刷新
    if not EXUI.RightPanel then return end

    -- 根据页面类型决定显示哪个滚动容器
    if EXUI.CurrentPage == "ModuleSettings" then
        -- ModuleSettings 使用自己独立的滚动容器 (ModuleScrollFrame)
        if EXUI.RightScrollFrame then EXUI.RightScrollFrame:Hide() end
        EXUI:ShowModuleSettingsPage()
    else
        -- 其他页面使用通用滚动容器
        if EXUI.RightScrollFrame then
            EXUI.RightScrollFrame:Show()
            if restoreRightScroll == nil then
                EXUI.RightScrollFrame:SetVerticalScroll(0)
            end
        end
        -- 显示对应页面
        if EXUI.CurrentPage == "Home" then
            EXUI.RightPanel:Show()
            EXUI:ShowHomePage()
        elseif EXUI.CurrentPage == "LoadSettings" then
            EXUI.RightPanel:Show()
            EXUI:ShowLoadSettingsPage()
        elseif EXUI.CurrentPage == "Diagnostic" then
            EXUI.RightPanel:Show()
            EXUI:ShowDiagnosticPage()
        elseif EXUI.CurrentPage == "ProfileManager" then
            EXUI.RightPanel:Show()
            EXUI:ShowProfileManagerPage()
        end

        -- [v4.8 Fix] 模块管理页启用/禁用刷新时保留滚动位置，避免跳回顶部
        if restoreRightScroll ~= nil and EXUI.RightScrollFrame and EXUI.RightScrollFrame:IsShown() then
            EXUI.RightScrollFrame:SetVerticalScroll(restoreRightScroll)
        end
    end

    EXUI:UpdateNavButtonStates()
end

-- 刷新右侧内容时保留当前通用滚动容器的位置（用于模块管理卡片刷新等场景）
function EXUI:RefreshContentKeepRightScroll()
    if EXUI.CurrentPage ~= "ModuleSettings" and EXUI.RightScrollFrame and EXUI.RightScrollFrame:IsShown() then
        EXUI.PendingRightScrollRestore = EXUI.RightScrollFrame:GetVerticalScroll() or 0
    end
    EXUI:RefreshContent()
end

function EXUI:RefreshContentKeepModuleScroll()
    if EXUI.CurrentPage == "ModuleSettings" and EXUI.ModuleScrollFrame and EXUI.ModuleScrollFrame:IsShown() then
        EXUI.PendingModuleScrollRestore = EXUI.ModuleScrollFrame:GetVerticalScroll() or 0
    end
    EXUI:RefreshContent()
end

-- =========================================================
-- 页面缓存 (Page Pooling)
-- =========================================================
EXUI.PageCache = {}

function EXUI:GetCachedPage(key, parent)
    -- 注意：这里的 parent 应该是 ScrollChild
    if not EXUI.PageCache[key] then
        local page = CreateFrame("Frame", nil, parent)
        -- page 高度由内容撑开，不应 SetAllPoints
        page:SetWidth(parent:GetWidth())
        page:SetPoint("TOPLEFT", 0, 0)
        EXUI.PageCache[key] = page
        page:Show()
        return page, true -- isNew = true
    end
    local page = EXUI.PageCache[key]
    page:SetParent(parent)
    page:SetWidth(parent:GetWidth())
    page:ClearAllPoints()
    page:SetPoint("TOPLEFT", 0, 0)
    page:Show()
    return page, false -- isNew = false
end

-- =========================================================
-- 首页
-- =========================================================

-- 确认弹窗（仅注册一次）
StaticPopupDialogs["EXWIND_CONFIRM_RESET"] = {
    text = L["确定要重置 ExwindTools 的所有配置并重载吗？\n|cffff4444此操作不可逆！|r"],
    button1 = L["确定重置"],
    button2 = L["取消"],
    OnAccept = function()
        _G.ExwindToolsDB = nil
        C_UI.Reload()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["EXWIND_CONFIRM_RESET_MODULE"] = {
    text = "%s",
    button1 = L["确定重置"],
    button2 = L["取消"],
    OnAccept = function(self, data)
        local moduleKey = data and data.moduleKey
        if not moduleKey then return end

        local db = _G.ExwindToolsDB
        if db and db.ModuleDB then
            db.ModuleDB[moduleKey] = nil
        end

        C_UI.Reload()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function EXUI:ShowHomePage()
    local page, isNew = EXUI:GetCachedPage("Home", EXUI.RightScrollChild)
    EXUI.ActivePageFrame = page

    if not isNew then
        if page.RefreshLocaleControls then
            page:RefreshLocaleControls()
        end
        EXUI.RightScrollChild:SetHeight(980)
        return
    end

    local FONT = ExwindTools.MAIN_FONT
    local HOME = {
        bg = { 0.035, 0.040, 0.060, 0.94 },
        panel = { 0.055, 0.065, 0.090, 0.96 },
        panel2 = { 0.040, 0.048, 0.070, 0.96 },
        line = { 0.26, 0.30, 0.36, 0.78 },
        gold = { 1.00, 0.82, 0.35, 1 },
        cyan = { 0.36, 0.82, 1.00, 1 },
        green = { 0.48, 0.92, 0.72, 1 },
        red = { 1.00, 0.36, 0.32, 1 },
        text = { 0.88, 0.90, 0.94, 1 },
        muted = { 0.60, 0.66, 0.74, 1 },
    }
    local CYAN = "|cff00DDFF"
    local GOLD = "|cffFFD700"
    local GREY = "|cff888888"
    local SUPPORT_URL = "https://afdian.com/a/Exwind"
    -- 右侧通用滚动容器实际宽度约 750，这里留边距避免被裁切
    local W = math.min((page:GetWidth() or 750) - 30, 720)
    local PAGE_H = 980
    local COL_GAP = 14
    local COL_W = math.floor((W - COL_GAP) / 2)
    local INNER_W = COL_W - 42
    local localeItems = {
        { L["跟随客户端"], "AUTO" },
        { L["强制 zhCN"], "zhCN" },
        { L["强制 enUS"], "enUS" },
    }

    local function GetLocaleModeLabel(mode)
        if mode == "zhCN" then
            return L["强制 zhCN"]
        elseif mode == "enUS" then
            return L["强制 enUS"]
        end
        return L["跟随客户端"]
    end

    local function MakePanel(parent, w, h, point, rel, relPoint, x, y, bg, border)
        local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        frame:SetSize(w, h)
        frame:SetPoint(point, rel, relPoint, x, y)
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        frame:SetBackdropColor(unpack(bg or HOME.panel))
        frame:SetBackdropBorderColor(unpack(border or HOME.line))
        return frame
    end

    local function Accent(frame, color)
        local c = color or HOME.gold
        local line = frame:CreateTexture(nil, "ARTWORK")
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetVertexColor(c[1], c[2], c[3], 0.95)
        line:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
        line:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        line:SetHeight(2)
        return line
    end

    local function Font(fs, size, color, flags)
        fs:SetFont(FONT, size or 14, flags or "")
        local c = color or HOME.text
        fs:SetTextColor(c[1], c[2], c[3], c[4] or 1)
    end

    local function Text(parent, text, size, color, point, rel, relPoint, x, y, w, flags)
        local fs = parent:CreateFontString(nil, "OVERLAY")
        Font(fs, size, color, flags)
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        if w then fs:SetWidth(w) end
        fs:SetText(text or "")
        fs:SetPoint(point or "TOPLEFT", rel or parent, relPoint or point or "TOPLEFT", x or 0, y or 0)
        return fs
    end

    local function MakeCopyBox(parent, label, value, color, width, height, fontSize)
        local c = color or HOME.cyan
        local title
        if label and label ~= "" then
            title = Text(parent, label, 12, HOME.muted, "TOPLEFT", parent, "TOPLEFT", 0, 0)
        end
        local box = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
        box:SetSize(width or 360, height or 28)
        box:SetAutoFocus(false)
        box:SetMultiLine(false)
        box:SetTextInsets(10, 10, 0, 0)
        box:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        box:SetBackdropColor(c[1] * 0.10, c[2] * 0.10, c[3] * 0.10, 0.92)
        box:SetBackdropBorderColor(c[1], c[2], c[3], 0.78)
        Font(box, fontSize or 13, HOME.text, "")
        box:SetText(tostring(value or ""))
        box:SetCursorPosition(0)
        box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
        box:SetScript("OnMouseUp", function(self)
            self:SetFocus()
            self:HighlightText()
        end)
        return box, title
    end

    local function OpenCopyText(value)
        if ChatFrame_OpenChat then
            ChatFrame_OpenChat(tostring(value or ""))
        else
            print(tostring(value or ""))
        end
    end

    local function MakeButton(parent, label, value, color, w, h, fontSize)
        local c = color or HOME.cyan
        local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
        b:SetSize(w or 168, h or 28)
        b:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 1,
        })
        b:SetBackdropColor(c[1] * 0.16, c[2] * 0.16, c[3] * 0.16, 0.92)
        b:SetBackdropBorderColor(c[1], c[2], c[3], 0.78)
        b.text = b:CreateFontString(nil, "OVERLAY")
        b.text:SetPoint("CENTER")
        Font(b.text, fontSize or 13, HOME.text, "OUTLINE")
        b.text:SetText(label)
        b:SetScript("OnEnter", function(self)
            self:SetBackdropColor(c[1] * 0.24, c[2] * 0.24, c[3] * 0.24, 0.98)
            self:SetBackdropBorderColor(c[1], c[2], c[3], 1)
        end)
        b:SetScript("OnLeave", function(self)
            self:SetBackdropColor(c[1] * 0.16, c[2] * 0.16, c[3] * 0.16, 0.92)
            self:SetBackdropBorderColor(c[1], c[2], c[3], 0.78)
        end)
        b:SetScript("OnClick", function()
            OpenCopyText(value)
        end)
        return b
    end

    local function SectionTitle(parent, title, sub, color)
        local t = Text(parent, title, 18, color or HOME.gold, "TOPLEFT", parent, "TOPLEFT", 16, -14, nil, "OUTLINE")
        if sub and sub ~= "" then
            local s = Text(parent, sub, 12, HOME.muted, "TOPLEFT", t, "BOTTOMLEFT", 0, -5)
            s:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -16, 0)
            return t, s
        end
        return t
    end

    local function MakeOpenExBossButton(parent)
        local b = EXUI:CreateSmallButton(parent, L["打开 EXBoss"], function()
        local panel = _G.ExBoss and _G.ExBoss.UI and _G.ExBoss.UI.Panel
        if not panel then
            return
        end
        if panel.SetTab then
            panel:SetTab("boss")
        end
        if EXUI.MainFrame then
            EXUI.MainFrame:Hide()
        end
        if panel.Show then
            panel:Show()
        elseif panel.Toggle then
            panel:Toggle()
        end
        end)
        return b
    end

    local hero = MakePanel(page, W, 168, "TOP", page, "TOP", 0, -18, HOME.bg, HOME.line)
    Accent(hero, HOME.gold)
    local title = Text(hero, "ExwindTools", 32, HOME.gold, "TOPLEFT", hero, "TOPLEFT", 24, -20, nil, "OUTLINE")
    Text(hero, L["零依赖 · 事件驱动 · State 订阅 · Grid 配置"], 14, HOME.text, "TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    Text(hero, L["模块管理用于启用/禁用功能；各模块配置页使用 Grid 面板实时调整。"], 13, HOME.muted, "TOPLEFT", title, "BOTTOMLEFT", 0, -38, W - 220)
    Text(hero, L["作者"] .. ": EXWIND", 13, HOME.cyan, "TOPLEFT", title, "BOTTOMLEFT", 0, -72)
    Text(hero, "Version " .. (ExwindTools.VERSION or "Unknown"), 13, HOME.muted, "TOPRIGHT", hero, "TOPRIGHT", -24, -24)
    local openExBossBtn = MakeOpenExBossButton(hero)
    openExBossBtn:SetSize(132, 28)
    openExBossBtn:SetPoint("TOPRIGHT", hero, "TOPRIGHT", -24, -62)
    if openExBossBtn:GetFontString() then
        openExBossBtn:GetFontString():SetFont(FONT, 12, "OUTLINE")
    end

    local support = MakePanel(page, W, 190, "TOP", hero, "BOTTOM", 0, -16, { 0.095, 0.078, 0.030, 0.98 }, HOME.gold)
    Accent(support, HOME.gold)
    Text(support, L["赞助支持"], 28, HOME.gold, "TOPLEFT", support, "TOPLEFT", 22, -18, nil, "OUTLINE")
    Text(support, L["如果你觉得插件不错，可以小额赞助。"], 15, HOME.text, "TOPLEFT", support, "TOPLEFT", 22, -62, W - 44)
    Text(support, L["ExwindTools 和 EXBoss 是免费项目；赞助不会解锁额外功能，所有人使用同一版本。"], 12, HOME.muted, "TOPLEFT", support, "TOPLEFT", 22, -88, W - 44)
    local supportBox = MakeCopyBox(support, "", SUPPORT_URL, HOME.gold, W - 250, 38, 18)
    supportBox:SetPoint("BOTTOMLEFT", support, "BOTTOMLEFT", 22, 24)
    local supportBtn = MakeButton(support, L["复制赞助链接"], SUPPORT_URL, HOME.gold, 190, 38, 16)
    supportBtn:SetPoint("LEFT", supportBox, "RIGHT", 14, 0)
    Text(support, L["点击输入框可全选，按 Ctrl+C 复制链接。"], 11, HOME.muted, "BOTTOMLEFT", supportBox, "TOPLEFT", 0, 7)

    local cardRow = CreateFrame("Frame", nil, page)
    cardRow:SetSize(W, 410)
    cardRow:SetPoint("TOP", support, "BOTTOM", 0, -16)

    local infoPanel = MakePanel(cardRow, COL_W, 410, "TOPLEFT", cardRow, "TOPLEFT", 0, 0, HOME.panel, HOME.line)
    Accent(infoPanel, HOME.cyan)
    SectionTitle(infoPanel, L["信息与反馈"], L["遇到问题、配置建议或缺少选项都可以反馈。"], HOME.cyan)

    Text(infoPanel, L["网站"], 12, HOME.muted, "TOPLEFT", infoPanel, "TOPLEFT", 18, -78)
    local siteBox = MakeCopyBox(infoPanel, "", "exwind.net", HOME.cyan, INNER_W, 28, 13)
    siteBox:SetPoint("TOPLEFT", infoPanel, "TOPLEFT", 18, -100)

    Text(infoPanel, "BiliBili", 12, HOME.muted, "TOPLEFT", siteBox, "BOTTOMLEFT", 0, -22)
    Text(infoPanel, "EX-WIND " .. GREY .. "(" .. L["私信"] .. ")|r", 14, HOME.text, "TOPLEFT", siteBox, "BOTTOMLEFT", 0, -43)

    Text(infoPanel, L["NGA 链接"], 12, HOME.muted, "TOPLEFT", siteBox, "BOTTOMLEFT", 0, -78)
    local ngaBox = MakeCopyBox(infoPanel, "", "https://nga.178.com/read.php?tid=46217768", HOME.cyan, INNER_W, 28, 11)
    ngaBox:SetPoint("TOPLEFT", siteBox, "BOTTOMLEFT", 0, -100)
    Text(infoPanel, L["点击输入框可全选，按 Ctrl+C 复制链接"], 10, HOME.muted, "TOPLEFT", ngaBox, "BOTTOMLEFT", 0, -5)

    local actionPanel = MakePanel(cardRow, COL_W, 410, "TOPRIGHT", cardRow, "TOPRIGHT", 0, 0, HOME.panel, HOME.line)
    Accent(actionPanel, HOME.gold)
    SectionTitle(actionPanel, L["快捷操作"], L["这些操作会直接影响插件配置。"], HOME.gold)

    local localeDropdown = EXUI:CreateDropdown(
        actionPanel,
        188,
        L["界面语言"],
        localeItems,
        ExwindTools.GetLocaleMode and ExwindTools:GetLocaleMode() or "AUTO",
        function(value)
            if ExwindTools.SetLocaleMode then
                ExwindTools:SetLocaleMode(value)
            end
            if page.RefreshLocaleControls then
                page:RefreshLocaleControls()
            end
        end
    )
    localeDropdown:SetPoint("TOPLEFT", actionPanel, "TOPLEFT", 18, -82)

    local localeReloadBtn = EXUI:CreateSmallButton(actionPanel, L["立即重载界面"], function()
        C_UI.Reload()
    end)
    localeReloadBtn:SetSize(120, 26)
    localeReloadBtn:SetPoint("BOTTOMRIGHT", localeDropdown, "BOTTOMRIGHT", 122, 0)
    if localeReloadBtn:GetFontString() then
        localeReloadBtn:GetFontString():SetFont(FONT, 11, "OUTLINE")
    end

    local localeHint = Text(actionPanel, "", 11, HOME.muted, "TOPLEFT", localeDropdown, "BOTTOMLEFT", 0, -10, INNER_W)
    localeHint:SetWordWrap(true)
    local localeStatus = Text(actionPanel, "", 10, HOME.muted, "TOPLEFT", localeHint, "BOTTOMLEFT", 0, -6, INNER_W)
    localeStatus:SetWordWrap(true)

    page.LocaleDropdown = localeDropdown
    page.LocaleHint = localeHint
    page.LocaleStatus = localeStatus

    function page:RefreshLocaleControls()
        local localeMode = ExwindTools.GetLocaleMode and ExwindTools:GetLocaleMode() or "AUTO"
        local clientLocale = _G.ExwindLocale and _G.ExwindLocale.GetClientLocale and _G.ExwindLocale.GetClientLocale() or GetLocale()
        local effectiveLocale = ExwindTools.GetEffectiveLocale and ExwindTools:GetEffectiveLocale(localeMode) or clientLocale

        if self.LocaleDropdown then
            self.LocaleDropdown._currentValue = localeMode
            self.LocaleDropdown:SetText(GetLocaleModeLabel(localeMode))
        end

        if self.LocaleHint then
            self.LocaleHint:SetText(L["仅影响 Exwind 自身本地化文本；部分由游戏 API / 第三方库返回的内容不受影响。切换后建议立即重载界面。"])
        end

        if self.LocaleStatus then
            self.LocaleStatus:SetText(string.format(L["当前设置：%s | 客户端：%s | 当前生效：%s"], GetLocaleModeLabel(localeMode), clientLocale, effectiveLocale))
        end
    end
    page:RefreshLocaleControls()

    local minimapToggle = EXUI:CreateCheckbox(
        actionPanel,
        L["隐藏小地图按钮"],
        ExwindTools.IsMinimapButtonHidden and ExwindTools:IsMinimapButtonHidden() or false,
        function(checked)
            if ExwindTools.SetMinimapButtonHidden then
                ExwindTools:SetMinimapButtonHidden(checked)
            end
        end
    )
    minimapToggle:SetSize(170, 24)
    minimapToggle:SetPoint("TOPLEFT", localeStatus, "BOTTOMLEFT", 0, -18)
    minimapToggle.label:ClearAllPoints()
    minimapToggle.label:SetPoint("LEFT", minimapToggle.checkbox, "RIGHT", 4, 0)
    minimapToggle.label:SetTextColor(0.82, 0.82, 0.88, 1)

    local tipHeader = Text(actionPanel, L["使用建议"], 13, HOME.gold, "TOPLEFT", minimapToggle, "BOTTOMLEFT", 0, -20, nil, "OUTLINE")
    local tips = {
        L["模块管理页用于启用/禁用模块，变更后需 /reload 生效。"],
        L["进入模块设置页后可使用 Grid 面板调整样式、位置和功能开关。"],
        L["全局编辑模式命令: /ex edmode (用于拖动 HUD 位置)。"],
    }
    local lastTip = tipHeader
    for _, tip in ipairs(tips) do
        local fs = Text(actionPanel, "|cff9fb0c0•|r " .. tip, 12, HOME.text, "TOPLEFT", lastTip, "BOTTOMLEFT", 0, -8, INNER_W)
        lastTip = fs
    end

    local btnReset = CreateFrame("Button", nil, actionPanel, "BackdropTemplate")
    btnReset:SetSize(120, 24)
    btnReset:SetPoint("BOTTOMRIGHT", actionPanel, "BOTTOMRIGHT", -16, 16)
    btnReset:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    btnReset:SetBackdropColor(0.35, 0.06, 0.06, 0.9)
    btnReset:SetBackdropBorderColor(0.8, 0.2, 0.2, 0.9)

    local btnResetLabel = btnReset:CreateFontString(nil, "OVERLAY")
    btnResetLabel:SetFont(FONT, 11, "OUTLINE")
    btnResetLabel:SetPoint("CENTER")
    btnResetLabel:SetText("|cffFF6666" .. L["重置设置"] .. "|r")

    btnReset:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.5, 0.08, 0.08, 0.95)
        self:SetBackdropBorderColor(1, 0.3, 0.3, 1)
    end)
    btnReset:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.35, 0.06, 0.06, 0.9)
        self:SetBackdropBorderColor(0.8, 0.2, 0.2, 0.9)
    end)
    btnReset:SetScript("OnClick", function()
        StaticPopup_Show("EXWIND_CONFIRM_RESET")
    end)

    local resetHint = Text(actionPanel, GREY .. L["RESET_HINT"] .. "|r", 10, HOME.muted, "BOTTOMLEFT", actionPanel, "BOTTOMLEFT", 18, 20, INNER_W - 110)

    local footerPanel = MakePanel(page, W, 84, "TOP", cardRow, "BOTTOM", 0, -16, HOME.bg, HOME.line)
    Accent(footerPanel, HOME.cyan)
    local footerText = Text(footerPanel, L["作者: Exwind  |  网站: exwind.net\n问题反馈: BiliBili(EX-WIND) / NGA"], 15, HOME.muted, "CENTER", footerPanel, "CENTER", 0, 0, W - 36)
    footerText:SetJustifyH("CENTER")
    footerText:SetWordWrap(true)

    page:SetHeight(PAGE_H)
    EXUI.RightScrollChild:SetHeight(PAGE_H)
end

-- =========================================================
-- Async Handler (单例，确保能取消之前的任务)
-- =========================================================
EXUI.AsyncHandler = LibStub("LibAsync"):GetHandler({
    type = "everyFrame",
    maxTime = 20, -- 增加一点每帧处理时间
    errorHandler = geterrorhandler()
})

-- =========================================================
-- 插件载入页面
-- =========================================================
function EXUI:ShowLoadSettingsPage()
    -- [Fix] 挂载到 ScrollChild
    local page, isNew = EXUI:GetCachedPage("LoadSettings", EXUI.RightScrollChild)
    EXUI.ActivePageFrame = page

    if isNew then
        local pageTitle = page:CreateFontString(nil, "OVERLAY")
        pageTitle:SetFontObject("GameFontNormalLarge")
        pageTitle:SetPoint("TOPLEFT", 20, -15)
        pageTitle:SetText(L["模块载入管理"])

        local hint = page:CreateFontString(nil, "OVERLAY")
        hint:SetFontObject("GameFontHighlight")
        hint:SetPoint("TOPLEFT", 20, -45)
        hint:SetText("|cffff8800" .. L["点击卡片切换启用/禁用，点击 Settings 打开设置。禁用会立即停用；启用未初始化模块仍需 /reload。"] .. "|r")

        local btnEnableAll = EXUI:CreateSmallButton(page, L["全部启用"], function()
            for _, meta in ipairs(ExwindTools.ModuleList) do
                ExwindTools:SetModuleEnabled(meta.Key, true)
            end
            if page.cardsContainer then
                EXUI:RefreshModuleCardStates(page.cardsContainer)
            else
                EXUI:RefreshContentKeepRightScroll()
            end
        end)
        btnEnableAll:SetPoint("TOPRIGHT", -150, -12)

        local btnDisableAll = EXUI:CreateSmallButton(page, L["全部禁用"], function()
            for _, meta in ipairs(ExwindTools.ModuleList) do
                ExwindTools:SetModuleEnabled(meta.Key, false)
            end
            if page.cardsContainer then
                EXUI:RefreshModuleCardStates(page.cardsContainer)
            else
                EXUI:RefreshContentKeepRightScroll()
            end
        end)
        btnDisableAll:SetPoint("TOPRIGHT", -20, -12)

        -- [Fix] 不再创建内部 ScrollFrame，直接使用 page 作为容器
        -- 用于挂载卡片的容器 (其实就是 page 本身)
        page.cardsContainer = CreateFrame("Frame", nil, page)
        page.cardsContainer:SetPoint("TOPLEFT", 15, -75)
        page.cardsContainer:SetPoint("BOTTOMRIGHT", -15, 0)
        page.cardsContainer:SetSize(720, 1) -- 初始高度
    end

    -- 刷新卡片列表
    if page.cardsContainer then
        EXUI.AsyncHandler:CancelAsync("ExwindTools_GenCards")
        for _, child in ipairs({ page.cardsContainer:GetChildren() }) do
            child:Hide()
            child:SetParent(nil)
        end
        -- 生成卡片并自适应高度
        EXUI:GenerateModuleCards(page.cardsContainer, function(contentHeight)
            page:SetHeight(contentHeight + 100)
            EXUI.RightScrollChild:SetHeight(page:GetHeight())
        end)
    end
end

-- 模块管理卡片：根据启用状态刷新视觉（避免整页刷新导致闪烁）
function EXUI:ApplyModuleCardState(card, isEnabled)
    if not card then return end

    card:SetBackdropBorderColor(isEnabled and THEME.Success[1] or 0.3,
        isEnabled and THEME.Success[2] or 0.3,
        isEnabled and THEME.Success[3] or 0.35, 0.8)

    if card.Thumbnail then
        card.Thumbnail:SetDesaturated(not isEnabled)
        card.Thumbnail:SetAlpha(isEnabled and 1 or 0.5)
    end

    if card.EnableBtn then
        card.EnableBtn:SetBackdropColor(isEnabled and THEME.Success[1] or THEME.Danger[1],
            isEnabled and THEME.Success[2] or THEME.Danger[2],
            isEnabled and THEME.Success[3] or THEME.Danger[3])
    end

    if card.EnableBtnText then
        card.EnableBtnText:SetText(isEnabled and L["禁 用"] or L["启 用"])
    end
end

function EXUI:RefreshModuleCardStates(container)
    if not container then return end
    for _, child in ipairs({ container:GetChildren() }) do
        if child._moduleKey then
            local isEnabled = ExwindTools.DB.LoadByKey[child._moduleKey] ~= false
            EXUI:ApplyModuleCardState(child, isEnabled)
        end
    end
end

-- [Update] 修改 GenerateModuleCards 以支持高度回调
function EXUI:GenerateModuleCards(parent, onComplete)
    local cardWidth = 250
    local cardHeight = 200
    local cardsPerRow = 3
    local cardSpacing = 10
    local xOffset = 5
    local yOffset = -5

    EXUI.AsyncHandler:Async(function()
        local totalRows = math.ceil(#ExwindTools.ModuleList / cardsPerRow)
        local totalHeight = totalRows * (cardHeight + cardSpacing) + 20
        parent:SetHeight(totalHeight)
        if onComplete then onComplete(totalHeight) end

        for i, meta in ipairs(ExwindTools.ModuleList) do
            if i % 3 == 0 then coroutine.yield() end
            if not parent:IsVisible() then return end

            local isEnabled = ExwindTools.DB.LoadByKey[meta.Key] ~= false
            -- ... (Layout check logic if needed)
            local hasSettings = not meta.HideCfg and ExwindTools.RegisteredLayouts[meta.Key] ~= nil

            local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
            card._moduleKey = meta.Key
            card:SetSize(cardWidth, cardHeight)
            card:SetBackdrop(BACKDROP)
            card:SetBackdropColor(unpack(THEME.CardBg))

            local row = math.floor((i - 1) / cardsPerRow)
            local col = (i - 1) % cardsPerRow
            card:SetPoint("TOPLEFT", xOffset + col * (cardWidth + cardSpacing),
                yOffset - row * (cardHeight + cardSpacing))

            local thumbnail = card:CreateTexture(nil, "ARTWORK")
            card.Thumbnail = thumbnail
            thumbnail:SetSize(cardWidth - 20, 90)
            thumbnail:SetPoint("TOP", 0, -10)
            thumbnail:SetTexture("Interface\\AddOns\\ExwindTools\\Textures\\LOGO\\EXTools.jpg")

            local nameText = card:CreateFontString(nil, "OVERLAY")
            nameText:SetFontObject("GameFontNormalLarge")
            nameText:SetPoint("TOPLEFT", 10, -105)
            nameText:SetText(meta.Name or meta.Key)
            nameText:SetTextColor(unpack(THEME.TextMain))
            nameText:SetWidth(cardWidth - 20)
            nameText:SetJustifyH("LEFT")

            local descText = card:CreateFontString(nil, "OVERLAY")
            descText:SetFontObject("GameFontHighlight")
            descText:SetPoint("TOPLEFT", 10, -122)
            descText:SetText(meta.Desc or "")
            descText:SetTextColor(unpack(THEME.TextSub))
            descText:SetWidth(cardWidth - 20)
            descText:SetJustifyH("LEFT")
            descText:SetWordWrap(true)
            descText:SetMaxLines(2)

            if hasSettings then
                local settingsBtn = CreateFrame("Button", nil, card, "BackdropTemplate")
                settingsBtn:SetSize(70, 22)
                settingsBtn:SetPoint("BOTTOMLEFT", 10, 8)
                settingsBtn:SetBackdrop(BACKDROP_SIMPLE)
                settingsBtn:SetBackdropColor(unpack(THEME.Primary))
                local settingsBtnText = settingsBtn:CreateFontString(nil, "OVERLAY")
                settingsBtnText:SetFontObject("GameFontNormal")
                settingsBtnText:SetPoint("CENTER")
                settingsBtnText:SetText(L["设 置"])
                settingsBtnText:SetTextColor(1, 1, 1, 1)
                settingsBtn:SetScript("OnClick", function()
                    EXUI.CurrentPage = "ModuleSettings"
                    EXUI.CurrentModule = meta.Key
                    EXUI:RefreshContent()
                end)
            end

            local enableBtn = CreateFrame("Button", nil, card, "BackdropTemplate")
            card.EnableBtn = enableBtn
            enableBtn:SetSize(70, 22)
            enableBtn:SetPoint("BOTTOMRIGHT", -10, 8)
            enableBtn:SetBackdrop(BACKDROP_SIMPLE)

            local enableBtnText = enableBtn:CreateFontString(nil, "OVERLAY")
            card.EnableBtnText = enableBtnText
            enableBtnText:SetFontObject("GameFontNormal")
            enableBtnText:SetPoint("CENTER")
            enableBtnText:SetTextColor(1, 1, 1, 1)

            EXUI:ApplyModuleCardState(card, isEnabled)

            enableBtn:SetScript("OnClick", function(self)
                local currentEnabled = ExwindTools.DB.LoadByKey[meta.Key] ~= false
                local newEnabled = not currentEnabled
                ExwindTools:SetModuleEnabled(meta.Key, newEnabled)
                EXUI:ApplyModuleCardState(card, newEnabled)
            end)
        end
    end, "ExwindTools_GenCards")
end

-- =========================================================
-- 模块设置页面 (ExwindGrid Layout)
-- 使用原生 Grid 布局引擎渲染
-- =========================================================
function EXUI:ShowModuleSettingsPage()
    if not EXUI.CurrentModule then return end

    local moduleMeta = nil
    for _, meta in ipairs(ExwindTools.ModuleList) do
        if meta.Key == EXUI.CurrentModule then
            moduleMeta = meta
            break
        end
    end
    if not moduleMeta then return end

    EXUI.SwitchingModule = true

    -- 核心逻辑：只支持原生 Grid 布局
    local layoutData = ExwindTools.RegisteredLayouts[EXUI.CurrentModule]
    if layoutData and _G.ExwindGrid then
        EXUI.RightPanel:Show()
        -- [Fix] 这里的 MainFrame 就是原生 Frame 了，不再需要 .frame
        EXUI.RightPanel:SetFrameLevel(EXUI.MainFrame:GetFrameLevel() + 10)

        if not EXUI.ModuleScrollFrame then
            -- 使用稳健模板并分配名称
            EXUI.ModuleScrollFrame = CreateFrame("ScrollFrame", "ExwindModuleGridScroll", EXUI.RightPanel,
                "UIPanelScrollFrameTemplate")
            EXUI.ModuleScrollFrame:SetPoint("TOPLEFT", 0, -5)
            EXUI.ModuleScrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

            if _G["ExwindModuleGridScrollTop"] then _G["ExwindModuleGridScrollTop"]:Hide() end
            if _G["ExwindModuleGridScrollBottom"] then _G["ExwindModuleGridScrollBottom"]:Hide() end

            local child = CreateFrame("Frame", nil, EXUI.ModuleScrollFrame)
            child:SetSize(750, 1)
            EXUI.ModuleScrollFrame:SetScrollChild(child)
            EXUI.ModuleScrollChild = child
        end
        EXUI.ModuleScrollFrame:Show()
        if EXUI.PendingModuleScrollRestore ~= nil then
            EXUI.ModuleScrollFrame:SetVerticalScroll(EXUI.PendingModuleScrollRestore)
        else
            EXUI.ModuleScrollFrame:SetVerticalScroll(0)
        end

        -- 获取或创建 Grid 容器页面 (挂载到 ScrollChild 上)
        local page, isNew = EXUI:GetCachedPage("ModuleGrid_" .. EXUI.CurrentModule, EXUI.ModuleScrollChild)
        EXUI.ActivePageFrame = page

        -- 清理页面旧内容 (防止切模块残留)
        for _, child in ipairs({ page:GetChildren() }) do
            if not child._isPersistent then
                child:Hide()
                child:SetParent(nil)
            end
        end

        -- 渲染布局前先隐藏提示标签
        if EXUI.NoLayoutLabel then EXUI.NoLayoutLabel:Hide() end

        -- 渲染布局
        local config = ExwindTools:GetModuleDB(EXUI.CurrentModule)
        local currentModuleKey = EXUI.CurrentModule
        _G.ExwindGrid:Render(page, layoutData, config, currentModuleKey, function()
            -- Render 完成后通知当前模块面板已刷新（各模块可订阅此事件更新动态内容）
            ExwindTools:UpdateState(currentModuleKey .. ".PanelRendered", GetTime())
        end)
        if EXUI.PendingModuleScrollRestore ~= nil then
            EXUI.ModuleScrollFrame:SetVerticalScroll(EXUI.PendingModuleScrollRestore)
            EXUI.PendingModuleScrollRestore = nil
        end

        local resetBtn = EXUI:CreateSmallButton(page, L["重置当前模块设置"], function()
            local moduleName = (moduleMeta and moduleMeta.Name) or EXUI.CurrentModule or L["当前模块"]
            local message = string.format(L["你将重置%s模块设置，并重载。是否确定？"], moduleName)
            StaticPopup_Show("EXWIND_CONFIRM_RESET_MODULE", message, nil, { moduleKey = EXUI.CurrentModule })
        end)
        resetBtn:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", -20, 16)
        resetBtn:SetFrameLevel(page:GetFrameLevel() + 50)
        page:SetHeight((page:GetHeight() or 1) + 52)

        -- [New v4.2] 如果处于开发者模式，在右上角显示“编辑”按钮
        if ExwindTools.State.DevMode then
            local editBtn = EXUI:CreateSmallButton(page, "|cff00ff00编辑布局|r", function()
                _G.ExwindGrid:ToggleLiveEdit(page, EXUI.CurrentModule)
            end)
            editBtn:SetPoint("TOPRIGHT", page, "TOPRIGHT", -20, -5)
            editBtn:SetFrameLevel(page:GetFrameLevel() + 50)
            editBtn._isPersistent = true -- 防止在编辑过程中被 Grid:Render 清理
        end
    else
        -- 模块未注册 Grid 布局，显示提示
        EXUI.RightPanel:Show()
        EXUI.RightPanel:SetFrameLevel(EXUI.MainFrame:GetFrameLevel() + 10)

        if not EXUI.NoLayoutLabel then
            local lbl = EXUI.RightPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
            lbl:SetPoint("CENTER", EXUI.RightPanel, "CENTER", 0, 0)
            EXUI.NoLayoutLabel = lbl
        end
        EXUI.NoLayoutLabel:SetText("|cffff8800[" ..
            moduleMeta.Name .. "]|r\n\n 此模块尚未注册 Grid 布局\n\n 请截图通知插件开发者\n\n请在模块文件末尾添加 EX_RegisterLayout() 函数。")
        EXUI.NoLayoutLabel:Show()
    end


    -- 清除切换标志
    EXUI.SwitchingModule = nil
end

-- =========================================================
-- 辅助函数
-- =========================================================
function EXUI:CreateActionButton(parent, text, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(180, 40)
    btn:SetBackdrop(BACKDROP)
    btn:SetBackdropColor(unpack(THEME.Primary))
    btn:SetBackdropBorderColor(0.5, 0.5, 0.55, 0.8)

    local btnText = btn:CreateFontString(nil, "OVERLAY")
    btnText:SetFontObject("GameFontNormal")
    btnText:SetPoint("CENTER")
    btnText:SetText(text)
    btnText:SetTextColor(1, 1, 1, 1)

    btn:SetScript("OnClick", onClick)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(THEME.Primary[1] * 1.3, THEME.Primary[2] * 1.3, THEME.Primary[3] * 1.3, 1)
        self:SetBackdropBorderColor(0.8, 0.5, 1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        -- 回复到 Exwind 经典紫色
        self:SetBackdropColor(unpack(THEME.Primary))
        self:SetBackdropBorderColor(0.5, 0.5, 0.55, 0.8)
    end)

    return btn
end

function EXUI:CreateSmallButton(parent, text, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(120, 28)
    btn:SetBackdrop(BACKDROP_SIMPLE)
    btn:SetBackdropColor(0.2, 0.2, 0.25, 0.9)

    local btnText = btn:CreateFontString(nil, "OVERLAY")
    btnText:SetFontObject("GameFontNormal")
    btnText:SetPoint("CENTER")
    btnText:SetText(text)
    btnText:SetTextColor(unpack(THEME.TextMain))

    btn:SetScript("OnClick", onClick)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.3, 0.3, 0.35, 0.95)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.2, 0.2, 0.25, 0.9)
    end)

    return btn
end

-- =========================================================
-- 状态总控页面
-- =========================================================
-- =========================================================
-- 状态总控页面
-- =========================================================
function EXUI:ShowDiagnosticPage()
    -- [Fix] 挂载到 ScrollChild，防止被 ScrollFrame 遮挡
    local page, isNew = EXUI:GetCachedPage("Diagnostic", EXUI.RightScrollChild)
    EXUI.ActivePageFrame = page

    -- 每次都需要刷新数据，所以清理旧内容
    for _, child in pairs({ page:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, region in pairs({ page:GetRegions() }) do
        region:Hide()
    end

    local env = ExwindTools:GetEnvironmentInfo()
    local db = _G.ExwindToolsDB
    local yOffset = -15
    local localTime = date("%Y-%m-%d %H:%M:%S")

    -- ========== 标题 ==========
    local pageTitle = page:CreateFontString(nil, "OVERLAY")
    pageTitle:SetFont(ExwindTools.MAIN_FONT, 25, "OUTLINE")
    pageTitle:SetPoint("TOPLEFT", 20, yOffset)
    pageTitle:SetText("|cffA330C9" .. L["状态总控"] .. "|r")
    yOffset = yOffset - 35

    -- ========== 环境信息区块 ==========
    local envHeader = page:CreateFontString(nil, "OVERLAY")
    envHeader:SetFont(ExwindTools.MAIN_FONT, 20, "OUTLINE")
    envHeader:SetPoint("TOPLEFT", 20, yOffset)
    envHeader:SetText(L["【环境信息】"])
    envHeader:SetTextColor(0.4, 0.8, 1)
    yOffset        = yOffset - 22

    local YES      = "|cff00ff00" .. L["是"] .. "|r"
    local NO       = "|cffaaaaaa" .. L["否"] .. "|r"
    local envLines = {
        string.format(L["插件版本: |cff00ff00%s|r  |  WTF版本: |cff00ff00%d|r"], env.addonVersion, env.dbVersion),
        string.format(L["游戏版本: |cffffd100%s|r (Build: %s)"], env.gameVersion, env.gameBuild),
        string.format(L["系统: |cffffd100%s (%s)|r  |  区域: |cffffd100%s|r  |  语言: |cffffd100%s|r"], env.platform, env.arch,
            env.region, env.locale),
        string.format(L["PTR: %s  |  BETA: %s  |  ElvUI: %s"],
            env.isPTR == "是" and YES or NO,
            env.isBeta == "是" and YES or NO,
            env.isElvUI == "是" and YES or NO),
        string.format(L["时间: |cffffd100%s|r"], localTime),
    }
    for _, line in ipairs(envLines) do
        local text = page:CreateFontString(nil, "OVERLAY")
        text:SetFontObject("GameFontHighlightLarge")
        text:SetPoint("TOPLEFT", 30, yOffset)
        text:SetText(line)
        yOffset = yOffset - 18
    end
    yOffset = yOffset - 10

    -- ========== 当前状态区块 ==========
    local stateHeader = page:CreateFontString(nil, "OVERLAY")
    stateHeader:SetFont(ExwindTools.MAIN_FONT, 20, "OUTLINE")
    stateHeader:SetPoint("TOPLEFT", 20, yOffset)
    stateHeader:SetText(L["【当前状态】"])
    stateHeader:SetTextColor(0.4, 0.8, 1)
    yOffset = yOffset - 22

    local state = ExwindTools.State
    local mapID = tonumber(state.MapID) or 0
    local mapGroup = tonumber(state.MapGroup) or 0
    local instanceID = tonumber(state.InstanceID) or 0
    if mapGroup <= 0 then mapGroup = mapID end
    local encounterID = tonumber(state.EncounterID) or 0
    local level = tonumber(state.Level) or 0
    local stateLines = {
        string.format(L["职业: |cff00ff00%s|r  |  专精: |cff00ff00%s|r  |  等级: |cffffd100%d|r"], state.ClassName, state
            .SpecName, level),
        string.format(L["副本: %s  |  类型: |cffffd100%s|r  |  战斗: %s"],
            state.InInstance and YES or NO,
            state.InstanceType,
            state.InCombat and "|cffff0000" .. L["是"] .. "|r" or NO),
        string.format(L["地图ID: |cffffd100%d|r  |  地图组: |cffffd100%d|r  |  副本ID: |cffffd100%d|r"], mapID, mapGroup,
            instanceID),
        string.format(L["首领战: %s  |  首领战ID: |cffffd100%d|r"],
            state.IsBossEncounter and YES or NO,
            encounterID),
        string.format(L["队伍: %s  |  团队: %s"],
            state.IsInParty and YES or NO,
            state.IsInRaid and YES or NO),
    }
    for _, line in ipairs(stateLines) do
        local text = page:CreateFontString(nil, "OVERLAY")
        text:SetFontObject("GameFontHighlightSmall")
        text:SetPoint("TOPLEFT", 30, yOffset)
        text:SetText(line)
        yOffset = yOffset - 18
    end
    yOffset = yOffset - 10

    -- ========== 依赖库区块 ==========
    local libHeader = page:CreateFontString(nil, "OVERLAY")
    libHeader:SetFontObject("GameFontNormalLarge")
    libHeader:SetPoint("TOPLEFT", 20, yOffset)
    libHeader:SetText(L["【依赖库】"])
    libHeader:SetTextColor(0.4, 0.8, 1)
    yOffset = yOffset - 22

    local libText = page:CreateFontString(nil, "OVERLAY")
    libText:SetFontObject("GameFontHighlightLarge")
    libText:SetPoint("TOPLEFT", 30, yOffset)
    local libParts = {}
    for name, loaded in pairs(ExwindTools.LibStatus) do
        local status = loaded and "|cff00ff00[OK]|r" or "|cffff0000[X]|r"
        table.insert(libParts, string.format("%s %s", status, name))
    end
    libText:SetText(table.concat(libParts, "  |  "))
    yOffset = yOffset - 25

    -- ========== 事件注册统计 ==========
    local eventHeader = page:CreateFontString(nil, "OVERLAY")
    eventHeader:SetFontObject("GameFontNormal")
    eventHeader:SetPoint("TOPLEFT", 20, yOffset)
    eventHeader:SetText(L["【事件注册】"])
    eventHeader:SetTextColor(0.4, 0.8, 1)
    yOffset = yOffset - 22

    local eventCount = 0
    local eventList = {}
    for event, handlers in pairs(ExwindTools.EventHandlers or {}) do
        local handlerCount = 0
        for _ in pairs(handlers) do handlerCount = handlerCount + 1 end
        eventCount = eventCount + 1
        table.insert(eventList, string.format("|cffffd100%s|r(%d)", event, handlerCount))
    end

    local eventText = page:CreateFontString(nil, "OVERLAY")
    eventText:SetFontObject("GameFontHighlight")
    eventText:SetPoint("TOPLEFT", 30, yOffset)
    if eventCount == 0 then
        eventText:SetText("|cffaaaaaa" .. L["无事件注册"] .. "|r")
    else
        eventText:SetText(string.format(L["共 |cff00ff00%d|r 个事件: %s"], eventCount, table.concat(eventList, ", ")))
    end
    eventText:SetWidth(800)
    yOffset = yOffset - 25

    -- [Fix] 动态偏移，防止事件列表过长导致重叠
    -- 先设置事件列表，再计算它的物理高度作为模块状态的起点
    local textHeight = eventText:GetStringHeight()
    yOffset = yOffset - textHeight - 20

    -- ========== 模块状态区块 ==========
    local modHeader = page:CreateFontString(nil, "OVERLAY")
    modHeader:SetFontObject("GameFontNormal")
    modHeader:SetPoint("TOPLEFT", 20, yOffset)
    modHeader:SetText(L["【模块状态】"])
    modHeader:SetTextColor(0.4, 0.8, 1)
    yOffset = yOffset - 22

    local colWidth = 280
    local col = 0
    local rowY = yOffset

    for _, meta in ipairs(ExwindTools.ModuleList) do
        local key = meta.Key
        local enabled = db.LoadByKey[key]
        local ready = ExwindTools.ModuleStatus[key] == "ready"

        local statusIcon, statusColor
        if not enabled then
            statusIcon = "|cff888888[" .. L["关"] .. "]|r"
            statusColor = { 0.6, 0.6, 0.6 }
        elseif ready then
            statusIcon = "|cff00ff00[OK]|r"
            statusColor = { 0.13, 0.77, 0.37 }
        else
            statusIcon = "|cffff0000[!!]|r"
            statusColor = { 0.87, 0.26, 0.26 }
        end

        local modText = page:CreateFontString(nil, "OVERLAY")
        modText:SetFontObject("GameFontHighlight")
        modText:SetPoint("TOPLEFT", 30 + col * colWidth, rowY)
        modText:SetText(string.format("%s %s", statusIcon, meta.Name))
        modText:SetTextColor(unpack(statusColor))

        col = col + 1
        if col >= 3 then
            col = 0
            rowY = rowY - 18
        end
    end
    if col > 0 then rowY = rowY - 18 end
    yOffset = rowY - 15

    -- [Fix] 设置高度以撑开滚动条
    page:SetHeight(math.abs(yOffset) + 50)
    EXUI.RightScrollChild:SetHeight(page:GetHeight())
end

-- =========================================================
-- 配置管理页面 (导出/导入)
-- =========================================================
function EXUI:ShowProfileManagerPage()
    local page, isNew = EXUI:GetCachedPage("ProfileManager", EXUI.RightScrollChild)
    EXUI.ActivePageFrame = page

    -- 状态存储
    if not EXUI.ProfileState then
        EXUI.ProfileState = {
            exportSelected = {},   -- 导出时选中的模块
            importSelected = {},   -- 导入时选中的模块
            parsedData = nil,      -- 解析后的导入数据
            mergeMode = "replace", -- 导入模式
        }
    end
    local state = EXUI.ProfileState

    if not isNew then
        EXUI.RightScrollChild:SetHeight(1200)
        return
    end

    local yOffset = -20
    local Export = ExwindTools.Export

    -- ===== 标题 =====
    local title = page:CreateFontString(nil, "OVERLAY")
    title:SetFont(ExwindTools.MAIN_FONT, 25, "OUTLINE")
    title:SetPoint("TOPLEFT", 20, yOffset)
    title:SetText("|cffA330C9" .. L["配置管理"] .. "|r")
    yOffset = yOffset - 40

    -- ===== 导出区域 =====
    local exportSection = CreateFrame("Frame", nil, page, "BackdropTemplate")
    exportSection:SetSize(780, 400)
    exportSection:SetPoint("TOPLEFT", 20, yOffset)
    exportSection:SetBackdrop(BACKDROP)
    exportSection:SetBackdropColor(0.08, 0.08, 0.1, 0.9)
    exportSection:SetBackdropBorderColor(unpack(THEME.Border))

    local exportTitle = exportSection:CreateFontString(nil, "OVERLAY")
    exportTitle:SetFont(ExwindTools.MAIN_FONT, 20, "OUTLINE")
    exportTitle:SetPoint("TOPLEFT", 15, -15)
    exportTitle:SetText("|cff00ff80 " .. L["导出配置"] .. "|r")

    -- 配置名称输入
    local nameInput = EXUI:CreateEditBox(exportSection, L["我的配置"], 300, 30, L["配置名称:"], { labelPos = "left" })
    nameInput:SetPoint("TOPLEFT", 100, -50)

    -- 导出者名称输入
    local authorInput = EXUI:CreateEditBox(exportSection, "", 200, 30, L["导出者:"],
        { labelPos = "left", placeholder = L["留空则使用当前名"] })
    authorInput:SetPoint("LEFT", nameInput, "RIGHT", 80, 0)

    -- 备注说明输入
    local noteInput = EXUI:CreateEditBox(exportSection, "", 600, 70, L["备注说明:"], { labelPos = "left" })
    noteInput:SetPoint("TOPLEFT", 100, -100)

    -- 模块选择区域 (向下顺延偏移，防止重叠)
    local moduleLabel = exportSection:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    moduleLabel:SetPoint("TOPLEFT", 15, -190)
    moduleLabel:SetText(L["选择导出模块:"])

    -- 全选/全不选按钮
    local selectAllBtn = EXUI:CreateSmallButton(exportSection, L["全选"], function()
        local modules = Export:GetExportableModules()
        for _, m in ipairs(modules) do state.exportSelected[m.key] = true end
        EXUI:RefreshExportCheckboxes()
    end)
    selectAllBtn:SetSize(60, 22); selectAllBtn:SetPoint("LEFT", moduleLabel, "RIGHT", 15, 0)

    local selectNoneBtn = EXUI:CreateSmallButton(exportSection, L["全不选"], function()
        wipe(state.exportSelected); EXUI:RefreshExportCheckboxes()
    end)
    selectNoneBtn:SetSize(70, 22); selectNoneBtn:SetPoint("LEFT", selectAllBtn, "RIGHT", 5, 0)

    -- 模块列表容器 (调整位位移)
    local exportList = CreateFrame("Frame", nil, exportSection)
    exportList:SetSize(740, 1)
    exportList:SetPoint("TOPLEFT", 15, -220)
    EXUI.ExportListFrame = exportList

    -- 导出按钮 (回归 Exwind 经典紫)
    local exportBtn = EXUI:CreateActionButton(exportSection, L["生成导出字符串"], function()
        local profileName = nameInput:GetText() or L["未命名"]
        local authorName = authorInput:GetText() or ""
        local note = noteInput:GetText() or ""
        local result, err = Export:ExportModules(state.exportSelected, profileName, authorName, note)
        if result then
            EXUI:ShowExportResultPopup(result, profileName)
        else
            print("|cffff0000[ExwindTools]|r " .. L["导出失败: "] .. (err or L["未知错误"]))
        end
    end)
    exportBtn:SetSize(200, 38)
    exportBtn:SetBackdropColor(unpack(THEME.Primary))
    exportBtn:SetBackdropBorderColor(0.5, 0.5, 0.55, 0.8)
    exportBtn:SetPoint("BOTTOMRIGHT", exportSection, "BOTTOMRIGHT", -15, 15)
    EXUI.ExportGenBtn = exportBtn

    yOffset = yOffset - 420

    -- ===== 导入区域 =====
    local importSection = CreateFrame("Frame", nil, page, "BackdropTemplate")
    importSection:SetSize(780, 480)
    -- 初始位置设低一点，等待动态计算覆盖
    importSection:SetPoint("TOPLEFT", 20, -1000)
    EXUI.ImportSection = importSection
    importSection:SetBackdropColor(0.08, 0.08, 0.1, 0.9)
    importSection:SetBackdropBorderColor(unpack(THEME.Border))

    local importTitle = importSection:CreateFontString(nil, "OVERLAY")
    importTitle:SetFont(ExwindTools.MAIN_FONT, 20, "OUTLINE")
    importTitle:SetPoint("TOPLEFT", 15, -15)
    importTitle:SetText("|cff00aaff " .. L["导入配置"] .. "|r")

    -- 导入字符串输入 (统一使用标准 EditBox，移除所有滚动层包装)
    local importInput = EXUI:CreateEditBox(importSection, "", 750, 100, L["粘贴导入字符串:"], { labelPos = "top" })
    importInput:SetPoint("TOPLEFT", 15, -60)
    EXUI.ImportStringField = importInput

    -- 解析预览按钮
    local parseBtn = EXUI:CreateSmallButton(importSection, L["解析预览"], function()
        local importDataInput = EXUI.ImportStringField:GetText()
        local data, err = Export:ParseImportString(importDataInput)
        if data then
            state.parsedData = data
            local summary = Export:GetImportSummary(data)
            wipe(state.importSelected)
            for _, m in ipairs(summary.modules) do state.importSelected[m.key] = true end
            EXUI:RefreshImportPreview(summary)
            print("|cff00ff00[ExwindTools]|r " .. string.format(L["解析成功！包含 %d 个模块配置"], summary.moduleCount))
        else
            state.parsedData = nil
            EXUI:RefreshImportPreview(nil)
            print("|cffff0000[ExwindTools]|r " .. L["解析失败: "] .. (err or L["未知错误"]))
        end
    end)
    parseBtn:SetSize(120, 26)
    parseBtn:SetPoint("TOPLEFT", EXUI.ImportStringField, "BOTTOMLEFT", 0, -10)

    -- 预览信息区 (结构完全对齐导出区)
    local previewFrame = CreateFrame("Frame", nil, importSection)
    previewFrame:SetSize(740, 1)
    previewFrame:SetPoint("TOPLEFT", 15, -195)
    EXUI.ImportPreviewFrame = previewFrame

    -- [Style] 模拟导出页的数据字段 (只读模式)
    local pName = EXUI:CreateEditBox(previewFrame, "", 300, 30, "|cffffd100" .. L["配置名称:"] .. "|r", { labelPos = "left" })
    pName:SetPoint("TOPLEFT", 85, 0)
    pName.editBox:Disable(); pName:SetBackdropColor(0.05, 0.05, 0.05, 1)
    EXUI.ImportPreviewName = pName

    local pAuthor = EXUI:CreateEditBox(previewFrame, "", 200, 30, "|cffffd100" .. L["作者:"] .. "|r", { labelPos = "left" })
    pAuthor:SetPoint("LEFT", pName, "RIGHT", 75, 0)
    pAuthor.editBox:Disable(); pAuthor:SetBackdropColor(0.05, 0.05, 0.05, 1)
    EXUI.ImportPreviewAuthor = pAuthor

    local pNote = EXUI:CreateEditBox(previewFrame, "", 600, 60, "|cffffd100" .. L["备注说明:"] .. "|r", { labelPos = "left" })
    pNote:SetPoint("TOPLEFT", 85, -45)
    pNote.editBox:Disable(); pNote:SetBackdropColor(0.05, 0.05, 0.05, 1)
    EXUI.ImportPreviewNote = pNote

    -- [Standard] 模块选择标题 (下移防止重叠)
    local importModLabel = previewFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    importModLabel:SetPoint("TOPLEFT", 0, -125)
    importModLabel:SetText(L["选择导入模块:"])
    EXUI.ImportPreviewLabel = importModLabel

    -- 导入模块选择列表 (直挂预览框架)
    local importList = CreateFrame("Frame", nil, previewFrame)
    importList:SetSize(740, 1)
    importList:SetPoint("TOPLEFT", 0, -155)
    EXUI.ImportListFrame = importList

    -- 应用导入按钮
    local applyBtn = EXUI:CreateActionButton(importSection, L["应用导入"], function()
        if not state.parsedData then
            print("|cffff0000[ExwindTools]|r " .. L["请先解析导入字符串"])
            return
        end
        -- 默认使用覆盖模式
        local count = Export:ApplyImport(state.parsedData, state.importSelected, "replace")
        if count > 0 then
            StaticPopup_Show("EXWIND_IMPORT_SUCCESS", count)
        else
            print("|cffff8800[ExwindTools]|r " .. L["未导入任何模块 (可能未选中或数据为空)"])
        end
    end)
    applyBtn:SetSize(160, 38)
    applyBtn:SetPoint("BOTTOMRIGHT", importSection, "BOTTOMRIGHT", -15, 15)

    yOffset = yOffset - 500

    -- 初始化导出模块列表
    EXUI:RefreshExportCheckboxes()

    -- 设置页面高度
    page:SetHeight(math.abs(yOffset) + 50)
    EXUI.RightScrollChild:SetHeight(page:GetHeight())
end

-- =========================================================
-- 刷新导出模块复选框
-- =========================================================
function EXUI:RefreshExportCheckboxes()
    local Export = ExwindTools.Export
    local state = EXUI.ProfileState
    local parent = EXUI.ExportListFrame
    if not parent then return end

    -- 清理旧内容
    for _, child in ipairs({ parent:GetChildren() }) do
        if not child._isPersistent then
            child:Hide(); child:SetParent(nil)
        end
    end

    local modules = Export:GetExportableModules()
    local yOff = 0
    local col = 0
    local rowHeight = 32 -- 提高行高，适配大勾选框

    for i, m in ipairs(modules) do
        -- 使用自研勾选框组件 (取代 UICheckButtonTemplate)
        local cb = EXUI:CreateCheckbox(parent, m.name, state.exportSelected[m.key] or false, function(checked)
            state.exportSelected[m.key] = checked
        end)
        cb:SetSize(220, 26)
        cb:SetPoint("TOPLEFT", (col * 240), yOff)

        -- 对齐文本
        cb.label:ClearAllPoints()
        cb.label:SetPoint("LEFT", cb.checkbox, "RIGHT", 5, 0)
        cb.label:SetJustifyH("LEFT")
        cb.label:SetTextColor(0.9, 0.9, 0.9)

        col = col + 1
        if col >= 3 then
            col = 0
            yOff = yOff - rowHeight
        end
    end

    -- 动态布局计算
    local listHeight = math.abs(yOff) + 40
    parent:SetHeight(listHeight)

    local exportSection = parent:GetParent()
    -- 基础偏移(180) + 备注框高度(70) + 列表高度 + 底部按钮区域(80)
    local sectionHeight = 250 + listHeight + 80
    exportSection:SetHeight(sectionHeight)

    -- [CRITICAL] 重新排布导入区域的锚点，确保永远不重叠
    if EXUI.ImportSection then
        EXUI.ImportSection:ClearAllPoints()
        EXUI.ImportSection:SetPoint("TOPLEFT", 20, -(100 + sectionHeight + 50))
    end

    -- 更新页面总高度
    local page = exportSection:GetParent()
    if page then
        page:SetHeight(sectionHeight + (EXUI.ImportSection and EXUI.ImportSection:GetHeight() or 500) + 200)
    end
end

-- =========================================================
-- 刷新导入预览
-- =========================================================
function EXUI:RefreshImportPreview(summary)
    local state = EXUI.ProfileState
    local parent = EXUI.ImportListFrame
    if not parent then return end

    -- 清理旧内容
    for _, child in ipairs({ parent:GetChildren() }) do
        child:Hide(); child:SetParent(nil)
    end

    if not summary then
        EXUI.ImportPreviewName:SetText("")
        EXUI.ImportPreviewAuthor:SetText("")
        EXUI.ImportPreviewNote:SetText("")
        EXUI.ImportPreviewLabel:SetText("|cff888888" .. L["等待解析..."] .. "|r")
        return
    end

    -- [Standard] 填充数据到标准化只读字段
    EXUI.ImportPreviewName:SetText(summary.profileName or L["未命名"])
    EXUI.ImportPreviewAuthor:SetText(summary.author or L["未知"])
    EXUI.ImportPreviewNote:SetText(summary.note or L["无备注说明"])
    EXUI.ImportPreviewLabel:SetText("|cff00ff80" ..
        L["解析成功预览:"] .. "|r " .. string.format("|cffaaaaaa(" .. L["版本: %s"] .. ")|r", summary.addonVersion))

    -- 创建模块勾选列表
    local yOff = 0
    local col = 0
    local rowHeight = 32

    for i, m in ipairs(summary.modules) do
        local labelText = m.name
        if not m.exists then
            labelText = "|cffff6666" .. labelText .. " (" .. L["未安装"] .. ")|r"
        else
            labelText = "|cff90ee90" .. labelText .. "|r"
        end

        local cb = EXUI:CreateCheckbox(parent, labelText, state.importSelected[m.key] or false, function(checked)
            state.importSelected[m.key] = checked
        end)
        cb:SetSize(220, 26)
        cb:SetPoint("TOPLEFT", (col * 240), yOff)

        -- 对齐文本
        cb.label:ClearAllPoints()
        cb.label:SetPoint("LEFT", cb.checkbox, "RIGHT", 5, 0)
        cb.label:SetJustifyH("LEFT")

        col = col + 1
        if col >= 3 then
            col = 0; yOff = yOff - rowHeight
        end
    end

    -- 动态布局：调整整个区块高度
    local listHeight = math.abs(yOff) + 60
    parent:SetHeight(listHeight)

    local importSection = parent:GetParent():GetParent()
    if importSection then
        importSection:SetHeight(260 + listHeight + 80)
    end

    local page = importSection:GetParent()
    if page then page:SetHeight(math.abs(page:GetTop() - importSection:GetBottom()) + 200) end
end

-- =========================================================
-- 导出结果弹窗
-- =========================================================
function EXUI:ShowExportResultPopup(exportString, profileName)
    -- 创建或复用弹窗
    if not EXUI.ExportPopup then
        local popup = CreateFrame("Frame", "ExwindExportPopup", UIParent, "BackdropTemplate")
        popup:SetSize(600, 350)
        popup:SetPoint("CENTER")
        popup:SetFrameStrata("FULLSCREEN_DIALOG")
        popup:SetBackdrop(BACKDROP)
        popup:SetBackdropColor(0.06, 0.06, 0.08, 0.98)
        popup:SetBackdropBorderColor(unpack(THEME.Border))
        popup:EnableMouse(true)
        popup:SetMovable(true)
        popup:RegisterForDrag("LeftButton")
        popup:SetScript("OnDragStart", popup.StartMoving)
        popup:SetScript("OnDragStop", popup.StopMovingOrSizing)

        local title = popup:CreateFontString(nil, "OVERLAY")
        title:SetFont(ExwindTools.MAIN_FONT, 25, "OUTLINE")
        title:SetPoint("TOP", 0, -15)
        title:SetText("|cff00ff80" .. L["导出成功"] .. "|r")
        popup.Title = title

        local closeBtn = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", -5, -5)
        closeBtn:SetScript("OnClick", function() popup:Hide() end)

        local hint = popup:CreateFontString(nil, "OVERLAY")
        hint:SetFontObject("GameFontHighlight")
        hint:SetPoint("TOP", title, "BOTTOM", 0, -10)
        hint:SetText(L["导出弹窗提示"])
        hint:SetTextColor(0.8, 0.8, 0.8)
        popup.Hint = hint

        -- 复制成功提示层
        local copyHint = CreateFrame("Frame", nil, popup, "BackdropTemplate")
        copyHint:SetSize(200, 60)
        copyHint:SetPoint("CENTER", popup, "CENTER", 0, 0)
        copyHint:SetFrameLevel(popup:GetFrameLevel() + 10)
        copyHint:SetBackdrop(BACKDROP)
        copyHint:SetBackdropColor(0.1, 0.3, 0.1, 0.95)
        copyHint:SetBackdropBorderColor(0.3, 0.8, 0.3, 1)
        copyHint:Hide()

        local copyHintText = copyHint:CreateFontString(nil, "OVERLAY")
        copyHintText:SetFontObject("GameFontNormalLarge")
        copyHintText:SetPoint("CENTER")
        copyHintText:SetText("|cff00ff00✓ " .. L["已复制到剪贴板"] .. "|r")
        popup.CopyHint = copyHint

        local editFrame = CreateFrame("Frame", nil, popup, "BackdropTemplate")
        editFrame:SetSize(560, 200)
        editFrame:SetPoint("TOP", hint, "BOTTOM", 0, -10)
        editFrame:SetBackdrop(BACKDROP_SIMPLE)
        editFrame:SetBackdropColor(0.1, 0.1, 0.12, 1)

        local scrollFrame = CreateFrame("ScrollFrame", nil, editFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 5, -5)
        scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetSize(530, 190)
        editBox:SetFontObject("ChatFontNormal")
        editBox:SetTextColor(0.7, 0.9, 0.7)
        editBox:SetAutoFocus(false)
        editBox:SetMultiLine(true)
        editBox:SetMaxLetters(999999)
        scrollFrame:SetScrollChild(editBox)
        popup.EditBox = editBox

        -- Ctrl 键追踪
        popup.lastCtrlDown = 0
        popup:SetScript("OnUpdate", function(self)
            if IsControlKeyDown() then
                self.lastCtrlDown = GetTime()
            end
        end)

        -- 监听 Ctrl+C
        editBox:SetScript("OnKeyUp", function(self, key)
            local wasCtrlDown = IsControlKeyDown() or (GetTime() - popup.lastCtrlDown < 0.5)
            if wasCtrlDown and key == "C" then
                self:ClearFocus()
                -- 显示复制成功提示
                popup.CopyHint:Show()
                popup.CopyHint:SetAlpha(1)
                C_Timer.After(0.6, function()
                    popup:Hide()
                    popup.CopyHint:Hide()
                end)
            end
        end)

        local selectBtn = EXUI:CreateSmallButton(popup, L["全选复制"], function()
            editBox:SetFocus()
            editBox:HighlightText()
        end)
        selectBtn:SetSize(100, 28)
        selectBtn:SetPoint("BOTTOM", popup, "BOTTOM", -60, 15)

        local closeBtn2 = EXUI:CreateSmallButton(popup, L["关闭"], function()
            popup:Hide()
        end)
        closeBtn2:SetSize(80, 28)
        closeBtn2:SetPoint("BOTTOM", popup, "BOTTOM", 60, 15)

        EXUI.ExportPopup = popup
    end

    local popup = EXUI.ExportPopup
    popup.EditBox:SetText(exportString)
    popup.Title:SetText("|cff00ff80" .. L["导出成功"] .. "|r - " .. profileName)
    popup.CopyHint:Hide()
    popup:Show()
    popup.EditBox:SetFocus()
    popup.EditBox:HighlightText()
end

-- =========================================================
-- 监听核心状态变动以实时刷新 UI
-- =========================================================
local function OnIdentityStateChanged()
    -- 如果 UI 正在显示，则根据当前页面决定是否刷新
    if EXUI.MainFrame and EXUI.MainFrame:IsShown() then
        if EXUI.CurrentPage == "Diagnostic" then
            -- 即使是 Diagnostic 页面，我们也通过 RefreshContent 统一路由
            EXUI:RefreshContent()
        end
        -- 注意：ModuleSettings 的刷新由各模块内部的 WatchState 触发，此处不重复 RefreshContent
        -- 避免在 ModuleSettings 页面造成双重刷新导致输入框失去焦点
    end
end

-- 注册状态监听
ExwindTools:WatchState("ClassID", "ExUI_Identity", OnIdentityStateChanged)
ExwindTools:WatchState("ClassName", "ExUI_Identity", OnIdentityStateChanged)
ExwindTools:WatchState("SpecID", "ExUI_Identity", OnIdentityStateChanged)
ExwindTools:WatchState("SpecName", "ExUI_Identity", OnIdentityStateChanged)

-- 绑定 Grid 引擎到 EXUI (Grid 在此之前加载)
if ExwindTools.Grid then
    EXUI.Grid = ExwindTools.Grid
end
