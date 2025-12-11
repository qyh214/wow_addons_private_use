-- Housing_BlizzardGraft.lua
-- 目的：
-- 1) 把右上角“装饰计数  已用/上限（house-decor-budget-icon）”嵌入 DockUI 的 Header，替换原标题文字。
-- 2) 把右侧（或右下角）HouseEditor 的“操作说明/键位提示”面板（Instructions 容器）重挂到 DockUI 的下方面板中显示。
-- 3) 在进入家宅编辑器时，常驻显示“放置的装饰”列表（使用暴雪官方模板）。
-- 约束：
-- - 严格依赖 Housing 事件与 API（单一权威）：
--     计数：C_HousingDecor.GetSpentPlacementBudget() / GetMaxPlacementBudget()
--     事件：HOUSING_NUM_DECOR_PLACED_CHANGED, HOUSE_LEVEL_CHANGED
--   （参见：Referrence/API/12.0.0.64774/Blizzard_HouseEditor/Blizzard_HouseEditorTemplates.lua）
-- - 不复制暴雪“说明列表”的业务逻辑，直接重挂其容器（DRY）。

local ADDON_NAME, ADT = ...
if not ADT or not ADT.CommandDock then return end

local CommandDock = ADT.CommandDock
-- 前置声明：供早期函数安全引用（避免隐式全局）
local EL -- 事件承载帧将在文末初始化

local function Debug(msg)
    if ADT and ADT.DebugPrint then ADT.DebugPrint("[Graft] " .. tostring(msg)) end
end

-- 统一从配置脚本读取（唯一权威）
local CFG = assert(ADT and ADT.HousingInstrCFG, "ADT.HousingInstrCFG 缺失：请确认 Housing_Config.lua 先于本文件加载")

-- 取到 Dock 主框体与 Header
local function GetDock()
    local dock = CommandDock and CommandDock.SettingsPanel
    if not dock or not dock.Header then return nil end
    return dock
end

-- 统一右侧内边距：优先读取 DockUI 的单一权威；无则回退到 CFG 的默认
local function GetUnifiedRightPad()
    local pad
    if ADT and ADT.DockUI and ADT.DockUI.GetRightPadding then
        local ok, v = pcall(ADT.DockUI.GetRightPadding)
        if ok and type(v) == 'number' then pad = v end
    end
    return tonumber(pad) or (CFG.Row.rightPad or 6)
end

--
-- 一、Dock Header 的装饰计数控件
--
local BudgetWidget
local HeaderTitleBackup
-- 前向声明：避免在闭包中捕获到全局未定义的 IsHouseEditorShown
--（Lua 的词法作用域要求在首次使用前声明局部变量，否则将解析为全局）
local IsHouseEditorShown
local GetActiveModeFrame -- 前向声明，供早期函数引用
local GetCustomizePanes   -- 前向声明：供 AnchorDyePopout 提前调用

-- 更新：按需微调“放置的装饰”官方面板（仅布局/交互禁用），不改其数据与刷新逻辑。

-- 让预算控件在自身容器内居中：计算“图标 + 间距 + 文本”的组合宽度，
-- 将图标的 LEFT 锚点向右偏移一半剩余空间。
local function LayoutBudgetWidget()
    if not BudgetWidget or not BudgetWidget.Icon or not BudgetWidget.Text then return end
    local gap = 6
    local iconW = BudgetWidget.Icon:GetWidth() or 0
    local textW = 0
    if BudgetWidget.Text.GetStringWidth then
        textW = math.ceil(BudgetWidget.Text:GetStringWidth() or 0)
    end
    local groupW = iconW + gap + textW
    local availW = BudgetWidget:GetWidth() or groupW
    local left = math.floor(math.max(0, (availW - groupW) * 0.5))

    BudgetWidget.Icon:ClearAllPoints()
    BudgetWidget.Icon:SetPoint("LEFT", BudgetWidget, "LEFT", left, 0)
    BudgetWidget.Text:ClearAllPoints()
    BudgetWidget.Text:SetPoint("LEFT", BudgetWidget.Icon, "RIGHT", gap, 0)
end

-- 计算并设置“从 Header 顶边”向下的像素，使 BudgetWidget 的垂直中心与 Header 垂直中心重合。
local function RepositionBudgetVertically()
    if not BudgetWidget then return end
    local header = BudgetWidget:GetParent()
    if not header or not header.GetHeight then return end
    local h = header:GetHeight() or 68
    local selfH = BudgetWidget:GetHeight() or 36
    local offset = math.floor((h - selfH) * 0.5 + 0.5)
    BudgetWidget:ClearAllPoints()
    BudgetWidget:SetPoint("TOP", header, "TOP", 0, -offset)
end

local function UpdateBudgetText()
    if not BudgetWidget or not BudgetWidget.Text then return end
    local used = C_HousingDecor and C_HousingDecor.GetSpentPlacementBudget and C_HousingDecor.GetSpentPlacementBudget() or 0
    local maxv = C_HousingDecor and C_HousingDecor.GetMaxPlacementBudget and C_HousingDecor.GetMaxPlacementBudget() or 0
    if used and maxv then
        if _G.HOUSING_DECOR_PLACED_COUNT_FMT then
            BudgetWidget.Text:SetText(string.format(_G.HOUSING_DECOR_PLACED_COUNT_FMT, used, maxv))
        else
            BudgetWidget.Text:SetText(used .. "/" .. maxv)
        end
    end
    -- 同步布局至居中
    LayoutBudgetWidget()
    RepositionBudgetVertically()
    -- Tooltip 文本与暴雪一致：室内/室外有不同描述
    if BudgetWidget then
        local base = _G.HOUSING_DECOR_BUDGET_TOOLTIP
        if _G.C_Housing and C_Housing.IsInsideHouse and _G.HOUSING_DECOR_BUDGET_TOOLTIP_INDOOR then
            base = (C_Housing.IsInsideHouse() and _G.HOUSING_DECOR_BUDGET_TOOLTIP_INDOOR) or _G.HOUSING_DECOR_BUDGET_TOOLTIP_OUTDOOR or base
        end
        if base then
            BudgetWidget.tooltipText = string.format(base, used or 0, maxv or 0)
        end
    end
end

local function EnsureBudgetWidget()
    local dock = GetDock()
    if not dock then return end

    -- 创建一次即可
    if BudgetWidget then return end

    local Header = dock.Header
    -- 备份标题，以便离开编辑器时恢复
    if dock.HeaderTitle and not HeaderTitleBackup then
        HeaderTitleBackup = dock.HeaderTitle:GetText()
    end

    BudgetWidget = CreateFrame("Frame", nil, Header)
    -- 初始化锚点，后续用 RepositionBudgetVertically() 精确垂直居中
    BudgetWidget:ClearAllPoints()
    BudgetWidget:SetPoint("CENTER", Header, "CENTER", 0, 0)
    BudgetWidget:SetHeight(36)
    BudgetWidget:SetWidth(240)
    -- 初次创建时保持透明，等锚点与文本准备好后再显现（防止视觉“飞入”）
    if BudgetWidget.SetAlpha then BudgetWidget:SetAlpha(0) end
    BudgetWidget:SetScript("OnEnter", function(self)
        if not self.tooltipText then return end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText)
        GameTooltip:Show()
    end)
    BudgetWidget:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local icon = BudgetWidget:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("LEFT", BudgetWidget, "LEFT", 0, 0)
    icon:SetAtlas("house-decor-budget-icon")
    icon:SetSize(34, 34) -- 放大 ~20%
    BudgetWidget.Icon = icon

    local text = BudgetWidget:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    text:SetText("0/0")
    BudgetWidget.Text = text
    -- 放大字体 ~20%
    pcall(function()
        local path, size, flags = text:GetFont()
        if path and size then text:SetFont(path, math.floor(size * 1.2 + 0.5), flags) end
    end)

    -- 初始布局：确保内容在容器内居中
    LayoutBudgetWidget(); RepositionBudgetVertically()

    -- 用 FrameUtil 注册事件，保持与暴雪模板一致
    BudgetWidget.updateEvents = {"HOUSING_NUM_DECOR_PLACED_CHANGED", "HOUSE_LEVEL_CHANGED"}
    BudgetWidget:SetScript("OnEvent", function() UpdateBudgetText() end)
    BudgetWidget:SetScript("OnShow", function(self)
        if FrameUtil and FrameUtil.RegisterFrameForEvents then
            FrameUtil.RegisterFrameForEvents(self, self.updateEvents)
        else
            for _, e in ipairs(self.updateEvents) do self:RegisterEvent(e) end
        end
        UpdateBudgetText()
        RepositionBudgetVertically()
        LayoutBudgetWidget()
    end)

    -- Header 尺寸变化时（如语言或 UI 缩放变动），保持垂直居中
    if Header and Header.HookScript then
        Header:HookScript("OnSizeChanged", function()
            if BudgetWidget and BudgetWidget:IsShown() then
                RepositionBudgetVertically(); LayoutBudgetWidget()
            end
        end)
    end
    BudgetWidget:SetScript("OnHide", function(self)
        if FrameUtil and FrameUtil.UnregisterFrameForEvents then
            FrameUtil.UnregisterFrameForEvents(self, self.updateEvents)
        else
            for _, e in ipairs(self.updateEvents) do self:UnregisterEvent(e) end
        end
    end)

end

local function ShowBudgetInHeader()
    local dock = GetDock()
    if not dock then return end
    EnsureBudgetWidget()
    if dock.HeaderTitle then
        dock.HeaderTitle:Hide()
    end
    if BudgetWidget then
        if BudgetWidget.SetAlpha then BudgetWidget:SetAlpha(0) end
        BudgetWidget:ClearAllPoints()
        BudgetWidget:SetPoint("CENTER", dock.Header, "CENTER", 0, 0)
        LayoutBudgetWidget(); RepositionBudgetVertically(); UpdateBudgetText()
        BudgetWidget:Show()
        C_Timer.After(0, function()
            if BudgetWidget and BudgetWidget:IsShown() and BudgetWidget.SetAlpha then
                BudgetWidget:SetAlpha(1)
            end
        end)
    end
    Debug("Header 计数已显示到 Dock")
    -- 维护计数刷新与可见性
    if not BudgetWidget._ticker then
        BudgetWidget._ticker = C_Timer.NewTicker(1.0, function(t)
            if not IsHouseEditorShown() then t:Cancel(); BudgetWidget._ticker=nil; return end
            UpdateBudgetText()
            if dock.HeaderTitle and dock.HeaderTitle:IsShown() then
                dock.HeaderTitle:Hide()
            end
            if BudgetWidget and not BudgetWidget:IsShown() then
                BudgetWidget:Show()
            end
        end)
    end
end

local function RestoreHeaderTitle()
    local dock = GetDock()
    if not dock then return end
    if BudgetWidget then
        BudgetWidget:Hide()
        if BudgetWidget._ticker then BudgetWidget._ticker:Cancel(); BudgetWidget._ticker=nil end
    end
    if dock.HeaderTitle and HeaderTitleBackup then
        dock.HeaderTitle:SetText(HeaderTitleBackup)
        dock.HeaderTitle:Show()
    end
end

-- 立刻隐藏官方右上角 DecorCount，避免与我们 Header 计数“先出现后消失”的跳动观感
local function HideOfficialDecorCountNow()
    local active = GetActiveModeFrame()
    local dc = active and active.DecorCount
    if not dc then return end
    -- 先把 alpha 置 0，再调用 Hide，避免任何一帧的闪现
    if dc.SetAlpha then dc:SetAlpha(0) end
    if dc.Hide then dc:Hide() end
    dc._ADTForceHidden = true
    if not dc._ADT_HideHooked then
        dc._ADT_HideHooked = true
        hooksecurefunc(dc, "Show", function(self)
            if self._ADTForceHidden then
                if self.SetAlpha then self:SetAlpha(0) end
                self:Hide()
            end
        end)
    end
end

--
-- 二、重挂 HouseEditor 的 Instructions 面板至 Dock 下方面板
--
local AdoptState = {
    originalParent = nil,
    restored = true,
    instr = nil,
    mirror = nil,
    selectRow = nil,
}

-- 统一：说明区自适应高度计算与重排队列（文件级本地函数，供各处调用）
local function _ADT_ComputeInstrNaturalHeight(instr)
    if not instr then return 0 end
    local h = (instr.GetHeight and instr:GetHeight()) or 0
    if not h or h <= 1 then
        local topMost, bottomMost
        for _, child in ipairs({instr:GetChildren()}) do
            if child and (not child.IsShown or child:IsShown()) then
                local ct = child.GetTop and child:GetTop()
                local cb = child.GetBottom and child:GetBottom()
                if ct and cb then
                    topMost = topMost and math.max(topMost, ct) or ct
                    bottomMost = bottomMost and math.min(bottomMost, cb) or cb
                end
            end
        end
        if topMost and bottomMost then
            h = math.max(0, topMost - bottomMost)
        end
    end
    return h or 0
end

-- 高度自适应改由 SubPanel 统一测量与驱动；此处仅发出“请求自适配”。
local function _ADT_QueueResize()
    if not IsHouseEditorShown() then return end
    if ADT and ADT.DockUI and ADT.DockUI.RequestSubPanelAutoResize then
        ADT.DockUI.RequestSubPanelAutoResize()
    end
end

--
-- 说明面板排版：字体缩放（让暴雪信息文字更“秀气”，适配下方面板宽度）
--

local function _ADT_SetFontPx(fs, px)
    if not (fs and fs.GetFont and fs.SetFont) then return end
    local path, size, flags = fs:GetFont()
    if not size or size <= 0 then return end
    if not fs._ADTOrigFont then
        fs._ADTOrigFont = {path=path, size=size, flags=flags}
    end
    local target = math.max(CFG.Typography.minFontSize, math.floor(px or size))
    if target ~= size then fs:SetFont(path, target, flags) end
end

-- 前置声明，避免调用顺序问题
local _ADT_AlignControl
local _ADT_AnchorRowColumns
local _ADT_UpdateLeftTextAnchors
local function _ADT_SetRowFixedWidth(row)
    if not row then return end
    local width
    do
        local dock = GetDock()
        local sub = dock and (dock.SubPanel or (dock.EnsureSubPanel and dock:EnsureSubPanel()))
        local content = sub and sub.Content
        width = content and content:GetWidth()
        if not width or width <= 1 then
            -- 兜底：在 Dock/SubPanel 尚未完成布局的首帧，回退到父容器的当前宽度，
            -- 避免行宽为 0 导致左列被压缩成“ … ”且出现越界。
            local p = row:GetParent()
            width = (p and p.GetWidth and p:GetWidth()) or width
        end
    end
    if width and width > 1 then
        if row.SetFixedWidth then
            row:SetFixedWidth(width)
        elseif row.SetWidth then
            row:SetWidth(width)
        end
    end
end

local function _ADT_ApplyTypographyToRow(row)
    if not row then return end
    -- 行最小高度与左右列间距 + 行内上下内边距
    -- 行高需要能容纳“按键气泡”的高度；因此取 Row.minHeight 与 Control.height 的较大者。
    local minRowH = math.max(tonumber(CFG.Row.minHeight or 0) or 0, tonumber(CFG.Control and CFG.Control.height or 0) or 0)
    row.minimumHeight = minRowH
    row.spacing = CFG.Row.hSpacing
    row.topPadding = CFG.Row.vPadEach
    row.bottomPadding = CFG.Row.vPadEach
    -- 关键：行在 VerticalLayout 容器中的水平对齐方式改为“贴左”，
    -- 避免模板默认的 center 导致整行相对内容区水平居中，从而看起来没有左对齐弹窗。
    row.align = "left"
    -- 关键：让整行占满父容器宽度（VerticalLayoutFrame 会据此把行宽设为可用宽度）
    row.expand = true
    -- 改为右向左布局：让“按键气泡”天然贴右并受 rightPadding 约束，从而形成与左侧一致的右留白
    row.childLayoutDirection = "rightToLeft"
    -- 左右边距统一：与 DockUI.GetRightPadding 保持一致，保证与 Header Divider 左/右缩进相同
    local uniPad = GetUnifiedRightPad()
    -- 左边距允许用 CFG.Row.leftPad 显式覆盖（单一权威）；未设置则与右侧统一留白保持一致
    row.leftPadding  = (CFG.Row.leftPad ~= nil) and CFG.Row.leftPad or uniPad
    row.rightPadding = uniPad
    -- 行宽固定为 SubPanel.Content 宽度，确保 RIGHT 锚点等价于“内容区右缘”
    _ADT_SetRowFixedWidth(row)

    local fs = row.InstructionText
    if fs then
        -- 右向左布局下，将文本放在第二列，靠左展开
        fs.layoutIndex = 2
        _ADT_SetFontPx(fs, CFG.Typography.instructionFontPx)
        if fs.SetJustifyV then fs:SetJustifyV("MIDDLE") end
        if fs.SetJustifyH then fs:SetJustifyH("LEFT") end
    end
    local ctext = row.Control and row.Control.Text
    if ctext then
        _ADT_SetFontPx(ctext, CFG.Typography.controlFontPx)
        if ctext.SetJustifyV then ctext:SetJustifyV("MIDDLE") end
    end
    -- 控件高度与背景高度
    if row.Control then
        -- 右向左布局下，按键气泡放在第一列，靠右
        if row.Control then row.Control.layoutIndex = 1 end
        _ADT_AlignControl(row)
    end
    -- 统一锚点：左列贴左、右列贴右；
    -- 但允许特例（如 HoverHUD 的 InfoLine）保留 HorizontalLayout 的定位，
    -- 以避免在首帧没有可用宽度时出现“文本被压缩为 …”。
    _ADT_AnchorRowColumns(row)
    -- 行宽固定为内容区宽度，确保右对齐时贴到 SubPanel 右缘
    _ADT_SetRowFixedWidth(row)
end

-- 前置声明，避免在定义之前被调用
local _ADT_FitControlText

local function _ADT_ApplyTypography(instr)
    if not instr then return end
    -- 统一容器级“行间距”（不同行之间）
    instr.spacing = CFG.Row.vSpacing

    -- 递归应用到说明面板中的所有“行”样式。
    -- 原先只处理到第一层子节点，导致 ADT 自建的说明行（作为容器的子孙
    -- 节点，例如 HoverHUD 里的 SubFrame/附加行）未被缩放与对齐，从而与
    -- 暴雪说明的字号与按钮尺寸不一致。这里改为深度遍历，遇到具备
    -- InstructionText/Control 的帧即视作一行应用统一样式。
    local function applyDeep(frame)
        if not frame then return end
        _ADT_ApplyTypographyToRow(frame)
        _ADT_FitControlText(frame)
        -- 关键：对子元素（行/模板）应用排版后，立即触发布局计算，
        -- 以便 VerticalLayout 能拿到正确高度进行堆叠，避免“看不见/高度为0”。
        pcall(function()
            if frame.MarkDirty then frame:MarkDirty() end
            if frame.Layout then frame:Layout() end
            if frame.UpdateLayout then frame:UpdateLayout() end
        end)
        for _, ch in ipairs({frame:GetChildren()}) do
            applyDeep(ch)
        end
    end
    for _, child in ipairs({instr:GetChildren()}) do
        applyDeep(child)
    end
end

-- 对外小型工具：允许其它模块显式请求对某一“行/容器”应用一次样式
-- 注意：仍以本文件的 CFG 为唯一权威，避免出现两套尺寸计算。
ADT.ApplyHousingInstructionStyle = function(target)
    if not target then return end
    -- 容器级：也同步容器的行间距，确保 ADT 自建的 VerticalLayout 容器
    -- 与官方 Instructions 使用同一 spacing（单一权威）。
    pcall(function()
        if target.spacing ~= nil then
            target.spacing = CFG.Row.vSpacing
        end
        -- 对布局容器，优先走 Layout/MarkDirty，保证立刻生效；
        if target.MarkDirty then target:MarkDirty() end
        if target.Layout then target:Layout() end
        if target.UpdateLayout then target:UpdateLayout() end
    end)

    -- 行：直接应用；容器：对其所有后代应用
    local function applyDeep(frame)
        if not frame then return end
        _ADT_ApplyTypographyToRow(frame)
        _ADT_FitControlText(frame)
        for _, ch in ipairs({frame:GetChildren()}) do
            applyDeep(ch)
        end
    end
    applyDeep(target)
end

-- 将右侧“按键文本气泡”根据实际可用宽度进一步收缩，避免超出子面板宽度
function _ADT_FitControlText(row)
    -- 说明：原实现依赖 AdoptState.instr 存在来触发“键帽收缩/贴右”。
    -- 但 HoverHUD 在被 Reparent 到 Dock.SubPanel 期间可能先一步创建并请求样式，
    -- 此时 AdoptState.instr 还未就绪，导致本函数短路返回，从而出现“悬停行键帽不贴右/未缩放”的现象。
    -- 修复：仅要求行本身与控件存在，统一以 Dock.SubPanel.Content 的宽度作为可用宽度来源，
    -- 与暴雪说明行保持完全一致的度量口径；不再把 AdoptState.instr 作为前置条件。
    if not (row and row.Control and row.Control.Text) then return end
    local sub = GetDock() and (GetDock().SubPanel or (GetDock().EnsureSubPanel and GetDock():EnsureSubPanel()))
    local content = sub and sub.Content
    local contentW = content and content:GetWidth()
    if not contentW or contentW <= 0 then return end

    local spacing = row.spacing or CFG.Row.hSpacing or 10
    -- 统一权威：左右内边距都使用 row.leftPadding/rightPadding（由 _ADT_ApplyTypographyToRow 设置）
    -- 若行上未设置，则回退到 DockUI 的统一右边距。
    local rightPad = (row.rightPadding ~= nil) and row.rightPadding or GetUnifiedRightPad()
    local rightBias = CFG.Control.rightEdgeBias or 0
    -- 使用文本实际宽度（不裁剪）来评估右侧可用空间
    -- 注意：使用“实际显示宽度”而非 Unbounded 宽度。
    -- Unbounded 会按完整字符串长度估算，远大于可分配宽度，
    -- 在我们自建 HoverHUD 行（存在统一 keycap 宽度）时会把右侧可用空间压缩过度，
    -- 导致键帽文本被 _ADT_FitControlText 过度缩小。
    local leftW = 0
    if row.InstructionText then
        -- 优先读取“实际显示宽度”；若尚未排版（初次 /reload 可能为 0），
        -- 则退化为字符串自然宽度，避免把右侧可用空间误算得过大导致键帽溢出。
        leftW = (row.InstructionText.GetWidth and row.InstructionText:GetWidth()) or 0
        if not leftW or leftW <= 2 then
            leftW = (row.InstructionText.GetStringWidth and row.InstructionText:GetStringWidth()) or 0
        end
        leftW = math.ceil(leftW or 0)
    end
    -- 可用宽度 = 内容区宽度 - 左内边距 - 左列已占宽 - 列间距 - 统一右边距
    -- 左边距同样走单一权威：以行的 leftPadding 为准
    local leftPad = (row.leftPadding ~= nil) and row.leftPadding or GetUnifiedRightPad()
    local maxRight = math.max(20, contentW - leftPad - leftW - spacing - rightPad - rightBias)
    local text = row.Control.Text
    if not (text and text:IsShown()) then return end

    -- 计算当前文本宽度（按现字号）
    local strW = math.ceil(text:GetStringWidth() or 0)
    local pad = CFG.Control.textPad
    local need = strW + pad
    if need <= maxRight then
        -- 已经适配，无需再缩放
        row._ADT_lastScale = 1.0
        local finalW = math.min(need, maxRight)
        if row.Control.Background then row.Control.Background:SetWidth(finalW) end
        row.Control:SetWidth(finalW); row.Control:SetHeight(CFG.Control.height)
        -- 始终把文本锚到背景 RIGHT，保证靠右生长
        local half = math.floor((pad or 0) * 0.5 + 0.5)
        text:ClearAllPoints()
        text:SetPoint("RIGHT", row.Control.Background, "RIGHT", -half, 0)
        if text.SetJustifyH then text:SetJustifyH("RIGHT") end
        -- 右侧尺寸稳定后，重新设置左侧文本的右锚，保证不与键帽重叠
        if _ADT_UpdateLeftTextAnchors then _ADT_UpdateLeftTextAnchors(row) end
        return
    end

    -- 按可用宽度收缩字号（但不小于 CFG.Control.minScale）
    local path, size, flags = text:GetFont()
    if not size or size <= 0 then return end
    local curScale = row._ADT_lastScale or 1.0
    local targetScale = math.max(CFG.Control.minScale, (maxRight - pad) / math.max(1, strW))
    -- 仅在需要变更时才设置字体，避免无谓重排
    if targetScale < curScale - 0.01 then
        local newSize = math.max(CFG.Typography.minFontSize, math.floor(size * targetScale + 0.5))
        text:SetFont(path, newSize, flags)
        local newW = math.ceil(text:GetStringWidth() or 0) + pad
        local finalW = math.min(newW, maxRight)
        if row.Control.Background then row.Control.Background:SetWidth(finalW) end
        row.Control:SetWidth(finalW); row.Control:SetHeight(CFG.Control.height)
        local half = math.floor((pad or 0) * 0.5 + 0.5)
        text:ClearAllPoints()
        text:SetPoint("RIGHT", row.Control.Background, "RIGHT", -half, 0)
        if text.SetJustifyH then text:SetJustifyH("RIGHT") end
        row._ADT_lastScale = targetScale
        if _ADT_UpdateLeftTextAnchors then _ADT_UpdateLeftTextAnchors(row) end
    else
        -- 仍需同步背景宽度，避免因先前缩放造成错位
        local w = math.ceil(text:GetStringWidth() or 0) + pad
        local finalW = math.min(w, maxRight)
        if row.Control.Background then row.Control.Background:SetWidth(finalW) end
        row.Control:SetWidth(finalW); row.Control:SetHeight(CFG.Control.height)
        local half = math.floor((pad or 0) * 0.5 + 0.5)
        text:ClearAllPoints()
        text:SetPoint("RIGHT", row.Control.Background, "RIGHT", -half, 0)
        if text.SetJustifyH then text:SetJustifyH("RIGHT") end
        if _ADT_UpdateLeftTextAnchors then _ADT_UpdateLeftTextAnchors(row) end
    end
end

-- 垂直对齐右侧按键气泡，使其与左侧文本行对齐（顶部对齐，避免显得下垂）
function _ADT_AlignControl(row)
    if not (row and row.Control) then return end
    local ctrl = row.Control
    -- 让 Control 容器高度与行最小高度一致，以获得稳定的纵向定位
    -- 改为遵循配置的“气泡高度”（Control.height）。行本身的最小高度已在
    -- _ADT_ApplyTypographyToRow 中与 Control.height 取最大，保证不压扁气泡。
    ctrl:SetHeight((CFG.Control and CFG.Control.height) or CFG.Row.minHeight)
    ctrl.align = "center"
    if row.InstructionText then row.InstructionText.align = "center" end

    -- 位置交由 HorizontalLayoutFrame 布局，不再手动 SetPoint；仅调整背景尺寸
    local bg = ctrl.Background
    if bg then
        bg:SetHeight(CFG.Control.bgHeight)
        bg:ClearAllPoints()
        bg:SetPoint("RIGHT", ctrl, "RIGHT", 0, 0)
    end
    if ctrl.SetClampedToScreen then ctrl:SetClampedToScreen(true) end
end

-- 左文左对齐 + 右键帽右对齐：文本占据“左边缘 → 键帽左边缘”的剩余宽度
function _ADT_AnchorRowColumns(row)
    -- 目标：保证左列信息文字“真正贴左”，并与右侧按键气泡保持固定间距。
    -- 背景：切换为 rightToLeft 子布局后，HorizontalLayout 会按“未约束文本宽度”的自然宽度
    -- 放置左列文本，可能把文本起点推到父容器之外（表现为左列跑到面板外）。
    -- 做法：让左列脱离 HorizontalLayout 的水平定位，用锚点限定左右边界。
    if not row then return end
    local fs, ctrl = row.InstructionText, row.Control
    if not fs then return end

    -- 左列统一左对齐/垂直居中
    if fs.SetJustifyH then fs:SetJustifyH("LEFT") end
    if fs.SetJustifyV then fs:SetJustifyV("MIDDLE") end

    -- 行级权威：左内边距与列间距
    local leftPad = (row.leftPadding ~= nil) and row.leftPadding or GetUnifiedRightPad()
    local spacing = (row.spacing ~= nil) and row.spacing or (CFG.Row.hSpacing or 8)
    local xNudge  = CFG.Row.textLeftNudge or 0
    local yNudge  = CFG.Row.textYOffset or 0

    -- 锚点解耦（仅信息文字）。保持在布局之外，由我们按照“从左向右生长”的方式限定左右边界。
    fs.ignoreInLayout = true
    _ADT_UpdateLeftTextAnchors(row)

    -- 单行展示，过长自动截断（不换行）。注意此处宽度已由左右锚点保证为“行内剩余宽度”，
    -- 不需要再用 SetWidth 干预，避免被 HorizontalLayout 尚未完成时序影响。
    if fs.SetWordWrap then fs:SetWordWrap(false) end
    if fs.SetMaxLines then fs:SetMaxLines(1) end
end

-- 仅修改“信息文字”的左右锚点，使其：
-- - 左起对齐到内容区左缘 + 统一左留白；
-- - 右侧为 内容区右缘 − (统一右留白 + 键帽宽度 + 列间距)，保证不与键帽重叠；
-- 任何时候都不设置宽度，由左右锚点推导，确保“左起向右生长”。
_ADT_UpdateLeftTextAnchors = function(row)
    if not row or not row.InstructionText then return end
    local fs, ctrl = row.InstructionText, row.Control
    -- 垂直坐标必须参考本行(row)，否则所有行会贴到同一Y导致“挤成一团”。
    local anchor = row

    local leftPad  = (row.leftPadding  ~= nil) and row.leftPadding  or GetUnifiedRightPad()
    local rightPad = (row.rightPadding ~= nil) and row.rightPadding or GetUnifiedRightPad()
    local spacing  = (row.spacing ~= nil) and row.spacing or (CFG.Row.hSpacing or 8)
    local xNudge   = CFG.Row.textLeftNudge or 0
    local yNudge   = CFG.Row.textYOffset or 0

    local reserveRight = rightPad
    if ctrl and ctrl.IsShown and ctrl:IsShown() then
        local w = (ctrl.GetWidth and ctrl:GetWidth()) or 0
        if w and w > 0 then reserveRight = reserveRight + spacing + w end
    end

    fs:ClearAllPoints()
    if fs.SetJustifyH then fs:SetJustifyH("LEFT") end
    if fs.SetJustifyV then fs:SetJustifyV("MIDDLE") end
    if fs.SetWordWrap then fs:SetWordWrap(false) end
    if fs.SetMaxLines then fs:SetMaxLines(1) end
    fs:SetPoint("LEFT",  anchor, "LEFT",  leftPad + xNudge, yNudge)
    fs:SetPoint("RIGHT", anchor, "RIGHT", -reserveRight, yNudge)
end

local function _ADT_RestoreTypography(instr)
    if not instr then return end
    for _, child in ipairs({instr:GetChildren()}) do
        local fs = child.InstructionText
        if fs and fs._ADTOrigFont then
            fs:SetFont(fs._ADTOrigFont.path, fs._ADTOrigFont.size, fs._ADTOrigFont.flags)
            fs._ADTOrigFont = nil
        end
        local ctext = child.Control and child.Control.Text
        if ctext and ctext._ADTOrigFont then
            ctext:SetFont(ctext._ADTOrigFont.path, ctext._ADTOrigFont.size, ctext._ADTOrigFont.flags)
            ctext._ADTOrigFont = nil
        end
        if child.UpdateControl then pcall(child.UpdateControl, child) end
        if child.UpdateInstruction then pcall(child.UpdateInstruction, child) end
        if child.MarkDirty then child:MarkDirty() end
    end
    if instr.UpdateLayout then instr:UpdateLayout() end
end

GetActiveModeFrame = function()
    if _G.HouseEditorFrame_GetFrame then
        local f = _G.HouseEditorFrame_GetFrame()
        if f and f.GetActiveModeFrame then
            return f:GetActiveModeFrame()
        end
    end
    return nil
end

--
-- 三、“放置的装饰”面板：跟随 Dock.SubPanel 贴合定位 + 禁止拖拽与关闭
--
local function GetPlacedDecorListFrame()
    local hf = _G.HouseEditorFrame
    local expert = hf and hf.ExpertDecorModeFrame
    local list = expert and expert.PlacedDecorList
    return list
end

-- 通用：将任意框体贴合到 Dock.SubPanel 下方（若无 SubPanel 则贴 Dock 下边），并做等宽与高度保护
local function AnchorFrameBelowDock(frame, cfg)
    if not frame or not frame.GetHeight then return end

    local dock = GetDock()
    if not dock then return end

    local anchor = dock.SubPanel or (dock.EnsureSubPanel and dock:EnsureSubPanel()) or dock
    if anchor and anchor.IsShown and not anchor:IsShown() then
        anchor = dock
    end

    local dxL = assert(cfg and cfg.anchorLeftCompensation)
    local dxR = assert(cfg and cfg.anchorRightCompensation)
    local dy  = assert(cfg and cfg.verticalGap)

    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT",  anchor, "BOTTOMLEFT", dxL, -dy)
    frame:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", dxR, -dy)

    -- 层级：与 Dock 一致并略高，避免被遮挡
    pcall(function()
        local targetStrata = dock:GetFrameStrata() or "DIALOG"
        frame:SetFrameStrata(targetStrata)
        frame:SetFrameLevel((dock:GetFrameLevel() or 10) + 10)
    end)

    -- 绝不越出屏幕底部
    frame:SetClampedToScreen(true)
    local uiBottom = UIParent and (UIParent.GetBottom and UIParent:GetBottom()) or 0
    local topY = (anchor and anchor.GetBottom and anchor:GetBottom()) or (dock and dock:GetBottom()) or 0
    local available = math.max(120, (topY - dy - uiBottom) - 8) -- 8px 安全边距
    local curH = frame:GetHeight() or 300
    if curH > available + 0.5 then frame:SetHeight(available) end
end

-- 将“放置的装饰”官方弹窗与 ADT 子面板自然衔接
local function AnchorPlacedList()
    local list = GetPlacedDecorListFrame()
    if not list then return end
    AnchorFrameBelowDock(list, CFG.PlacedList)
    -- 禁止拖动/用户放置，保持跟随
    pcall(function()
        list:SetMovable(false)
        list:SetUserPlaced(false)
        list:RegisterForDrag() -- 清空
        list:SetScript("OnDragStart", nil)
        list:SetScript("OnDragStop", nil)
    end)
end

local function EnsurePlacedListHooks()
    local list = GetPlacedDecorListFrame()
    if not list or list._ADT_Anchored then return end

    -- 一次性：禁用拖拽与关闭按钮（防止 StartMoving 报错 & 用户误关）
    local function LockInteractions()
        pcall(function()
            list:SetMovable(false)
            list:SetUserPlaced(false)
        end)
        if list.DragBar then
            list.DragBar:EnableMouse(false)
            list.DragBar:SetScript("OnMouseDown", nil)
            list.DragBar:SetScript("OnMouseUp", nil)
            list.DragBar.isMovingTarget = false
        end
        if list.CloseButton then
            list.CloseButton:Hide()
            list.CloseButton:EnableMouse(false)
            list.CloseButton:SetScript("OnClick", nil)
        end
    end
    LockInteractions()

    -- 动态自适应：显示期间开启一个轻量轮询（~5Hz），
    -- 防止暴雪内部在我们校准之后再次改变尺寸导致越界。
    local function StartWatcher()
        if list._ADT_resizerTicker then return end
        list._ADT_resizerTicker = C_Timer.NewTicker(0.2, function()
            if not list:IsShown() then return end
            AnchorPlacedList()
        end)
    end
    local function StopWatcher()
        if list._ADT_resizerTicker then list._ADT_resizerTicker:Cancel(); list._ADT_resizerTicker = nil end
    end

    -- 首次显示：立即校准 + 启动 watcher
    list:HookScript("OnShow", function()
        LockInteractions()
        C_Timer.After(0, AnchorPlacedList)
        C_Timer.After(0.05, AnchorPlacedList)
        StartWatcher()
    end)
    list:HookScript("OnSizeChanged", function() C_Timer.After(0, AnchorPlacedList) end)
    list:HookScript("OnHide", function() StopWatcher() end)

    -- 主面板/子面板大小变化时也刷新一次（多源冗余保证）
    local dock = GetDock()
    if dock then
        if dock.HookScript then
            dock:HookScript("OnSizeChanged", function() C_Timer.After(0, AnchorPlacedList) end)
        end
        if dock.SubPanel and dock.SubPanel.HookScript then
            dock.SubPanel:HookScript("OnSizeChanged", function() C_Timer.After(0, AnchorPlacedList) end)
            dock.SubPanel:HookScript("OnShow",       function() C_Timer.After(0, AnchorPlacedList) end)
        end
    end
    list._ADT_Anchored = true
end

--
-- 四、染色弹窗（DyeSelectionPopout）：贴合 Dock.SubPanel 下方
--
local function GetDyePopoutFrame()
    return _G.DyeSelectionPopout
end

-- 统一：从某个“屏幕上的 Y 基准（通常是目标框体的顶/底）”向下可用高度，
-- 将 frame 的高度压缩到不超过该可用空间。
local function _ADT_ClampHeightFromTop(frame, topY)
    if not (frame and topY) then return end
    frame:SetClampedToScreen(true)
    local uiBottom = UIParent and (UIParent.GetBottom and UIParent:GetBottom()) or 0
    local safePad = (CFG and CFG.DyePopout and CFG.DyePopout.safetyBottomPad) or 8
    local available = math.max(120, (topY - uiBottom) - safePad)
    local curH = frame:GetHeight() or 300
    if curH > available + 0.5 then frame:SetHeight(available) end
end

local function AnchorDyePopout()
    local pop = GetDyePopoutFrame()
    if not pop then return end

    -- 优先：贴在“当前显示的自定义面板”的左侧；无法获取时退化到 Dock 下沿策略
    local paneDecor, paneRoom = GetCustomizePanes()
    local pane = (paneDecor and paneDecor:IsShown()) and paneDecor
              or (paneRoom and paneRoom:IsShown()) and paneRoom
              or nil

    if pane then
        -- 顶部对齐 + 左侧相切
        local dx = -((CFG and CFG.DyePopout and CFG.DyePopout.horizontalGap) or 0) -- 以“相切”为 0，正值向内留白
        local dy = (CFG and CFG.DyePopout and CFG.DyePopout.verticalTopNudge) or 0
        pop:ClearAllPoints()
        pop:SetPoint("TOPRIGHT", pane, "TOPLEFT", dx, dy)

        -- 置于自定义面板之上，避免被遮挡
        pcall(function()
            local strata = pane:GetFrameStrata() or "DIALOG"
            pop:SetFrameStrata(strata)
            pop:SetFrameLevel((pane:GetFrameLevel() or 10) + 20)
        end)

        -- 自顶向下压缩，避免越出屏幕底部
        local topY = pane.GetTop and pane:GetTop()
        if topY then _ADT_ClampHeightFromTop(pop, topY) end
        return
    end

    -- 回落（无自定义面板显示时）：仍采用 Dock.SubPanel 下沿定位
    AnchorFrameBelowDock(pop, CFG.PlacedList)
end

local function EnsureDyePopoutHooks()
    local pop = GetDyePopoutFrame()
    if not pop or pop._ADT_Anchored then return end

    -- 首次显示：先瞬时透明 + 立即贴合，再下一帧复位透明度，避免“先在原位闪现一帧再飞过去”
    pop:HookScript("OnShow", function(self)
        local prevA = (self.GetAlpha and self:GetAlpha()) or 1
        if self.SetAlpha then self:SetAlpha(0) end
        AnchorDyePopout()
        C_Timer.After(0, function()
            AnchorDyePopout()
            if self.SetAlpha then self:SetAlpha(prevA) end
        end)
    end)
    pop:HookScript("OnSizeChanged", function() C_Timer.After(0, AnchorDyePopout) end)

    -- Dock 或 SubPanel 变化时也刷新
    local dock = GetDock()
    if dock then
        if dock.HookScript then
            dock:HookScript("OnSizeChanged", function() C_Timer.After(0, function() if pop:IsShown() then AnchorDyePopout() end end) end)
        end
        if dock.SubPanel and dock.SubPanel.HookScript then
            dock.SubPanel:HookScript("OnSizeChanged", function() C_Timer.After(0, function() if pop:IsShown() then AnchorDyePopout() end end) end)
            dock.SubPanel:HookScript("OnShow",       function() C_Timer.After(0, function() if pop:IsShown() then AnchorDyePopout() end end) end)
        end
    end

    pop._ADT_Anchored = true
end

--
-- 五、定制面板（DecorCustomizationsPane/RoomComponentCustomizationsPane）：同样贴合 Dock.SubPanel 下方
--
GetCustomizePanes = function()
    local hf = _G.HouseEditorFrame
    local customize = hf and hf.CustomizeModeFrame
    local decorPane = customize and customize.DecorCustomizationsPane
    local roomPane  = customize and customize.RoomComponentCustomizationsPane
    return decorPane, roomPane
end

-- 基于 Dock 宽度，计算“定制面板”的内容固定宽度（fixedWidth），避免依赖面板自身宽度
-- 说明：首次打开时 RoomComponentPane 在 :Show() 前就会执行 :Layout()，
-- 若此时仍是模板默认 fixedWidth=340，会造成首帧内容未对齐；
-- 这里直接以 Dock.SubPanel 的实际宽度作为权威来源计算 fixedWidth，
-- 消除与锚点/显示顺序相关的竞态。
local function _ADT_SyncPaneFixedWidthToDock(p)
    if not (p and p.SetFixedWidth) then return end
    local lp = tonumber(p.leftPadding) or 0
    local rp = tonumber(p.rightPadding) or 0
    local function apply(targetContentW)
        if not targetContentW or targetContentW <= 0 then return end
        local cw = math.max(1, targetContentW)
        if math.abs((p.fixedWidth or 0) - cw) > 0.5 then
            p:SetFixedWidth(cw)
            -- 关键修复：SetRoomComponentInfo 在 :Show() 之前会先调用 :Layout()，
            -- 这里必须在同步 fixedWidth 后主动触发布局，
            -- 而 VerticalLayoutFrame 使用的是 :Layout()（无 UpdateLayout）。
            if p.Layout then pcall(p.Layout, p) end
        end
    end
    -- 优先在“已锚定后”的时序直接以面板自身宽度为准（最稳妥）。
    local ownW = p.GetWidth and p:GetWidth()
    if ownW and ownW > 0 then
        return apply(ownW - lp - rp)
    end
    -- 早于 Show/布局时（如 SetRoomComponentInfo 早触发），退化到 Dock.SubPanel 的宽度估算。
    local dock = GetDock(); if not dock then return end
    local anchor = dock.SubPanel or (dock.EnsureSubPanel and dock:EnsureSubPanel()) or dock
    if not (anchor and anchor.GetWidth) then return end
    local dxL = assert(CFG and CFG.PlacedList and CFG.PlacedList.anchorLeftCompensation)
    local dxR = assert(CFG and CFG.PlacedList and CFG.PlacedList.anchorRightCompensation)
    local anchorW = anchor:GetWidth() or 0
    if anchorW <= 0 then return end
    apply(anchorW + (dxR or 0) - (dxL or 0) - lp - rp)
end

-- 轻量“跟随观察器”：面板可见期间短时监听宽度变化，确保与 SubPanel 动态缩放完全同步。
local function _ADT_EnsurePaneResizeWatcher(p)
    if not p or p._ADT_watcherTicker then return end
    local checks = 0
    p._ADT_watcherTicker = C_Timer.NewTicker(0.05, function(t)
        if not p:IsShown() then t:Cancel(); p._ADT_watcherTicker=nil; return end
        _ADT_SyncPaneFixedWidthToDock(p)
        checks = checks + 1
        -- 1. 在打开后一段时间内（~1s）持续跟随
        -- 2. 若外部仍在缩放，事件钩子也会触发；这里仅作为兜底补偿。
        if checks >= 20 then t:Cancel(); p._ADT_watcherTicker=nil end
    end)
end

local function AnchorCustomizePane()
    local paneDecor, paneRoom = GetCustomizePanes()
    if paneDecor and paneDecor:IsShown() then
        AnchorFrameBelowDock(paneDecor, CFG.PlacedList)
        -- 统一以 Dock 宽度为权威同步 fixedWidth，避免首帧不对齐
        _ADT_SyncPaneFixedWidthToDock(paneDecor)
        Debug("已贴合 DecorCustomizationsPane 到 SubPanel 下方")
    end
    if paneRoom and paneRoom:IsShown() then
        AnchorFrameBelowDock(paneRoom, CFG.PlacedList)
        _ADT_SyncPaneFixedWidthToDock(paneRoom)
        Debug("已贴合 RoomComponentCustomizationsPane 到 SubPanel 下方")
    end
end

local function LockPaneDragging(p)
    if not p then return end
    pcall(function()
        p:SetMovable(false)
        p:SetUserPlaced(false)
        p:RegisterForDrag() -- 清空
        p:SetScript("OnDragStart", nil)
        p:SetScript("OnDragStop", nil)
    end)
end

local function EnsureCustomizePaneHooks()
    local paneDecor, paneRoom = GetCustomizePanes()
    if not (paneDecor or paneRoom) then return end

    for _, p in ipairs({paneDecor, paneRoom}) do
        if p and not p._ADT_Anchored then
            LockPaneDragging(p)
            -- 首次显示：透明→立即贴合→同步 fixedWidth→下一帧复位透明度，避免初次“飞入/未对齐”
            p:HookScript("OnShow", function(self)
                local prevA = (self.GetAlpha and self:GetAlpha()) or 1
                if self.SetAlpha then self:SetAlpha(0) end
                AnchorCustomizePane()
                _ADT_SyncPaneFixedWidthToDock(self)
                _ADT_EnsurePaneResizeWatcher(self)
                C_Timer.After(0, function()
                    AnchorCustomizePane()
                    _ADT_SyncPaneFixedWidthToDock(self)
                    if self.SetAlpha then self:SetAlpha(prevA) end
                end)
            end)
            p:HookScript("OnHide", function(self)
                if self._ADT_watcherTicker then self._ADT_watcherTicker:Cancel(); self._ADT_watcherTicker=nil end
            end)
            p:HookScript("OnSizeChanged", function() C_Timer.After(0, AnchorCustomizePane) end)
            p._ADT_Anchored = true
        end
    end

    local dock = GetDock()
    if dock then
        local function queueSync()
            C_Timer.After(0, function()
                AnchorCustomizePane()
                local d, r = GetCustomizePanes()
                if d and d:IsShown() then _ADT_SyncPaneFixedWidthToDock(d) end
                if r and r:IsShown() then _ADT_SyncPaneFixedWidthToDock(r) end
                if d and d:IsShown() then _ADT_EnsurePaneResizeWatcher(d) end
                if r and r:IsShown() then _ADT_EnsurePaneResizeWatcher(r) end
            end)
        end
        if dock.HookScript then
            dock:HookScript("OnSizeChanged", queueSync)
        end
        if dock.SubPanel and dock.SubPanel.HookScript then
            dock.SubPanel:HookScript("OnSizeChanged", queueSync)
            dock.SubPanel:HookScript("OnShow",       queueSync)
        end
        -- 关键：SubPanel 的 Content 区域宽度会随 DockUI 的统一左右留白动态调整；
        -- 仅监听 SubPanel 尺寸不足以捕捉“仅留白变化”的场景，这里补挂 Content 的 OnSizeChanged。
        local content = dock.SubPanel and dock.SubPanel.Content
        if content and content.HookScript then
            content:HookScript("OnSizeChanged", queueSync)
        end
    end

    -- 当进入“自定义模式”时，确保再次贴合
    if _G.HouseEditorCustomizeModeMixin then
        hooksecurefunc(HouseEditorCustomizeModeMixin, "OnShow", function()
            EnsureCustomizePaneHooks(); C_Timer.After(0, AnchorCustomizePane)
        end)
        hooksecurefunc(HouseEditorCustomizeModeMixin, "ShowSelectedDecorInfo", function()
            EnsureCustomizePaneHooks(); C_Timer.After(0, AnchorCustomizePane)
        end)
        hooksecurefunc(HouseEditorCustomizeModeMixin, "ShowSelectedRoomComponentInfo", function()
            EnsureCustomizePaneHooks(); C_Timer.After(0, AnchorCustomizePane)
        end)
    end
end

-- 首开不居中根因：SetRoomComponentInfo() 会在 Show 之前立即调用 :Layout()，
-- 此时 fixedWidth 仍为模板默认值（340）。在其执行后再同步 fixedWidth 并重排一次即可。
if _G.RoomComponentPaneMixin and not _G.RoomComponentPaneMixin._ADT_FixedWidthHooked then
    _G.RoomComponentPaneMixin._ADT_FixedWidthHooked = true
    hooksecurefunc(RoomComponentPaneMixin, "SetRoomComponentInfo", function(self)
        if not self then return end
        -- 在布局前强制以 Dock 宽度同步 fixedWidth，消除首开竞态
        _ADT_SyncPaneFixedWidthToDock(self)
        -- 再下一帧复核一次，覆盖 Dock/SubPanel 在本帧内发生的尺寸变化
        C_Timer.After(0, function() _ADT_SyncPaneFixedWidthToDock(self); _ADT_EnsurePaneResizeWatcher(self) end)
    end)
end

-- 额外：染色面板在部分客户端语言/缩放下也可能出现首帧错位，做同样的 fixedWidth 同步保护（若其支持）
if _G.HousingDyePaneMixin and not _G.HousingDyePaneMixin._ADT_FixedWidthHooked then
    _G.HousingDyePaneMixin._ADT_FixedWidthHooked = true
    hooksecurefunc(HousingDyePaneMixin, "SetDecorInfo", function(self)
        if not self then return end
        _ADT_SyncPaneFixedWidthToDock(self)
        C_Timer.After(0, function() _ADT_SyncPaneFixedWidthToDock(self); _ADT_EnsurePaneResizeWatcher(self) end)
    end)
end

-- 说明：12.0 后不再强制打开“放置的装饰”清单，
-- 但文件中仍有延迟调用点引用 ShowPlacedListIfExpertActive。
-- 为避免 C_Timer.After 传入 nil 回调导致报错，这里提供温和实现：
-- 仅在清单已由官方逻辑显示时进行一次锚点处理，不改变其显示状态。
local function ShowPlacedListIfExpertActive()
    local list = GetPlacedDecorListFrame()
    if not list then return end
    if not IsHouseEditorShown() then return end
    if list.IsShown and list:IsShown() then
        -- 仅在已显示时尝试贴合定位；若 AnchorPlacedList 仍为占位实现，则无副作用。
        AnchorPlacedList()
    end
end

-- 判断是否处于“专家编辑模式”
-- 绑定到前向声明的同名局部变量，而不是重新声明新的 local
function IsHouseEditorShown()
    if _G.HouseEditorFrame_IsShown then
        return _G.HouseEditorFrame_IsShown()
    end
    local f = _G.HouseEditorFrame
    return f and f:IsShown()
end

local function AdoptInstructionsIntoDock()
    local dock = GetDock()
    if not dock or not dock.EnsureSubPanel then return end

    local active = GetActiveModeFrame()
    local instr = active and active.Instructions
    if not instr then
        -- 兜底：尝试从所有可能的模式容器里找一个正在显示的 Instructions
        local hf = _G.HouseEditorFrame
        if hf then
            for _, key in ipairs({"ExpertDecorModeFrame","BasicDecorModeFrame","LayoutModeFrame","CustomizeModeFrame","CleanupModeFrame","ExteriorCustomizationModeFrame"}) do
                local frm = hf[key]
                if frm and frm:IsShown() and frm.Instructions then
                    active = frm
                    instr = frm.Instructions
                    break
                end
            end
        end
    end
    if not instr then
        -- 修复：在“模式切换（尤其是专家→基础）且存在选中/悬停目标”时，
        -- 暴雪的 Instructions 容器常在数帧后才创建/切换完成，旧逻辑会立即隐藏 SubPanel，
        -- 造成右侧下方面板整块消失且不一定能再被重新展示。
        -- 新策略（KISS + 单一权威）：
        -- - 不再立刻隐藏 SubPanel；先把 HoverHUD 重挂到 SubPanel.Content 以保持有“正文”，
        -- - 由统一自适应高度与判空逻辑决定是否可见；
        -- - 同时启动一次短周期轮询，直到成功采纳官方 Instructions 为止。
        local sub = dock:EnsureSubPanel()
        dock:SetSubPanelShown(true)
        if ADT and ADT.Housing and ADT.Housing.ReparentHoverHUD and sub and sub.Content then
            pcall(ADT.Housing.ReparentHoverHUD, ADT.Housing, sub.Content)
        end
        if ADT and ADT.DockUI and ADT.DockUI.RequestSubPanelAutoResize then
            ADT.DockUI.RequestSubPanelAutoResize()
        end
        -- 轮询采纳：与 HouseEditor.StateUpdated 的实现保持一致，但也覆盖“模式切换”场景
        if not (EL and EL._adoptTicker) then
            local attempts = 0
            EL = EL or CreateFrame("Frame")
            EL._adoptTicker = C_Timer.NewTicker(0.25, function(t)
                attempts = attempts + 1
                if not IsHouseEditorShown() then t:Cancel(); EL._adoptTicker=nil; return end
                -- 再尝试一次采纳；成功后终止轮询
                AdoptInstructionsIntoDock()
                if AdoptState.instr then t:Cancel(); EL._adoptTicker=nil; Debug("轮询采纳成功(模式切换)") return end
                if attempts >= 20 then t:Cancel(); EL._adoptTicker=nil; Debug("轮询超时，未能采纳 Instructions") end
            end)
        end
        return
    end

    -- 保存原始父级，便于恢复
    if AdoptState.restored then
        AdoptState.originalParent = instr:GetParent()
        AdoptState.restored = false
    end

    local sub = dock:EnsureSubPanel()
    dock:SetSubPanelShown(true)
    -- KISS：不再在此处清空 Header 文本。
    -- 标题的唯一权威由 HoverHUD 悬停/选中逻辑写入与维持；
    -- 这里仅负责采纳官方 Instructions 到 SubPanel，不改 Header 内容。

    -- 优先方案：直接重挂，但不再把容器“贴到底”。
    -- 改动说明：
    -- - 让暴雪的说明面板从 Header 之下开始，避免遮挡“操作说明”标题；
    -- - 只限定宽度与顶部锚点，让 VerticalLayoutFrame 自行计算“自然高度”，供后续自适应使用。
    instr:ClearAllPoints()
    instr:SetParent(sub.Content)
    -- 顺延排版：若我们自建的 HoverHUD 可用，则让官方说明排在其下方；
    -- 否则退回到“排在 Header 下方”。
    do
        local df = ADT and ADT.Housing and ADT.Housing.GetDisplayFrame and ADT.Housing:GetDisplayFrame()
        local gap = CFG.Layout.headerToInstrGap
        if df and df.GetHeight then
            instr:SetPoint("TOPLEFT",  df, "BOTTOMLEFT",  0, -gap)
            instr:SetPoint("TOPRIGHT", df, "BOTTOMRIGHT", 0, -gap)
            -- 当 HUD 尺寸变化时，要求重新排版与自适应高度
            if df.HookScript and not df._ADT_HookedForInstrFollow then
                df._ADT_HookedForInstrFollow = true
                df:HookScript("OnSizeChanged", function()
                    if instr and instr.MarkDirty then instr:MarkDirty() end
                    if instr and instr.UpdateLayout then instr:UpdateLayout() end
                    _ADT_QueueResize()
                end)
            end
        else
            instr:SetPoint("TOPLEFT",  sub.Header,  "BOTTOMLEFT",  0, -gap)
            instr:SetPoint("TOPRIGHT", sub.Header,  "BOTTOMRIGHT", 0, -gap)
        end
    end
    -- 去除容器额外左右内边距，并固定为内容区宽度，便于子行按“左贴左、右贴右”扩展
    instr.leftPadding, instr.rightPadding = 0, 0
    instr:SetFixedWidth(sub.Content:GetWidth())
    if sub.Content.HookScript then
        sub.Content:HookScript("OnSizeChanged", function(_, w)
            if instr and instr.SetFixedWidth and w then instr:SetFixedWidth(w) end
        end)
    end
    -- 关键修复：首帧进入高级/专家模式时，暴雪容器会先按默认样式（居中/非展开）完成一次排版，
    -- 再触发我们的 hook（hooksecurefunc 是“事后”调用），导致第一帧看起来“整体偏右”。
    -- 处理：在首次重挂到 Dock 后，先对现有子项应用一次 ADT 样式（左对齐/展开/锚点解耦），
    -- 再主动触发 Layout，确保第一帧就按我们的样式排版；随后仍保留官方 UpdateAllVisuals。
    pcall(function() _ADT_ApplyTypography(instr) end)
    if instr.MarkDirty then instr:MarkDirty() end
    if instr.UpdateLayout then instr:UpdateLayout() end
    -- 再跑一次官方刷新，保证数据与显示完整，然后用 0 帧延迟再套一次样式兜底（覆盖官方可能改写的行属性）。
    if instr.UpdateAllVisuals then instr:UpdateAllVisuals() end
    if instr.UpdateLayout then instr:UpdateLayout() end
    C_Timer.After(0, function()
        if not instr or not instr.GetChildren then return end
        pcall(function() _ADT_ApplyTypography(instr) end)
        if instr.MarkDirty then instr:MarkDirty() end
        if instr.UpdateLayout then instr:UpdateLayout() end
    end)
    -- 任何由暴雪内部引起的尺寸变化（文本换行、行显隐）都会触发：
    if instr.HookScript then
        instr:HookScript("OnSizeChanged", function()
            -- 强制行宽与内容宽度保持一致（包括 HoverHUD 行），然后再计算高度。
            if instr and instr.GetChildren then
                for _, ch in ipairs({instr:GetChildren()}) do _ADT_SetRowFixedWidth(ch) end
            end
            _ADT_QueueResize()
        end)
        instr:HookScript("OnShow", function()
            C_Timer.After(0, _ADT_QueueResize)
            C_Timer.After(0.05, _ADT_QueueResize)
        end)
    end

    -- 定制化：隐藏“选择装饰/放置装饰”整行 + 去掉所有鼠标图标（保留键位按钮）
    local function _ADT_ShouldHideRowByText(text)
        if not text then return false end
        if _G.HOUSING_DECOR_SELECT_INSTRUCTION and (text == _G.HOUSING_DECOR_SELECT_INSTRUCTION or string.find(text, _G.HOUSING_DECOR_SELECT_INSTRUCTION, 1, true)) then
            return true
        end
        if _G.HOUSING_BASIC_DECOR_PLACE_INSTRUCTION and (text == _G.HOUSING_BASIC_DECOR_PLACE_INSTRUCTION or string.find(text, _G.HOUSING_BASIC_DECOR_PLACE_INSTRUCTION, 1, true)) then
            return true
        end
        return false
    end
    local function stripLine(line)
        if not line or not line.InstructionText or not line.Control then return end
        local text = line.InstructionText:GetText()
        if _ADT_ShouldHideRowByText(text) then
            line._ADTForceHideRow = true
            if text == _G.HOUSING_DECOR_SELECT_INSTRUCTION then AdoptState.selectRow = line end
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[Graft] Hide row by text: " .. tostring(text)) end
            line:Hide()
            return
        end
        -- 仅隐藏“鼠标图标”本体，不影响左侧文字（如装饰名等）
        local atlas = line.Control.Icon and line.Control.Icon.GetAtlas and line.Control.Icon:GetAtlas()
        if atlas and atlas:find("housing%-hotkey%-icon%-") then
            line._ADTForceHideControl = true
            if ADT and ADT.DebugPrint then ADT.DebugPrint("[Graft] Hide mouse icon control, atlas=" .. tostring(atlas) .. ", text=" .. tostring(text)) end
            if line.Control.Icon then line.Control.Icon:Hide() end
            if line.Control.Background then line.Control.Background:Hide() end
            line.Control:Hide()
        end
    end

    local children = {instr:GetChildren()}
    for _, ch in ipairs(children) do stripLine(ch) end
    -- 经过“隐藏特定行/清除鼠标图标”后，官方容器会再次排版。
    -- 为避免再次回到默认居中，这里确保在排版前先套用 ADT 样式，并强制一次 Layout。
    pcall(function() _ADT_ApplyTypography(instr) end)
    if instr.MarkDirty then instr:MarkDirty() end
    if instr.UpdateLayout then instr:UpdateLayout() end
    -- 以及再延迟一帧做一次兜底，解决个别路径上文本换行/键帽宽度变更造成的次帧漂移。
    C_Timer.After(0, function()
        if not instr or not instr.GetChildren then return end
        pcall(function() _ADT_ApplyTypography(instr) end)
        if instr.MarkDirty then instr:MarkDirty() end
        if instr.UpdateLayout then instr:UpdateLayout() end
    end)
    _ADT_QueueResize()

    -- 如果官方暴露了直接 key，进一步保险
    if instr.SelectInstruction then
        instr.SelectInstruction._ADTForceHideRow = true
        AdoptState.selectRow = instr.SelectInstruction
        if instr.SelectInstruction.HookScript then
            instr.SelectInstruction:HookScript("OnShow", function(self) self:Hide() end)
        end
        instr.SelectInstruction:Hide()
    end
    if instr.PlaceInstruction then
        instr.PlaceInstruction._ADTForceHideRow = true
        if instr.PlaceInstruction.HookScript then
            instr.PlaceInstruction:HookScript("OnShow", function(self) self:Hide() end)
        end
        instr.PlaceInstruction:Hide()
    end
    AdoptState.instr = instr
    -- 同步：把我们的 HoverHUD 重挂到 Dock 下方面板的内容容器中（不再依赖 Instructions 容器高度/裁剪）
    if ADT and ADT.Housing and ADT.Housing.ReparentHoverHUD then
        local dock = GetDock()
        local sub = dock and (dock.SubPanel or (dock.EnsureSubPanel and dock:EnsureSubPanel()))
        local parent = sub and sub.Content or instr
        pcall(ADT.Housing.ReparentHoverHUD, ADT.Housing, parent)
    end

    -- 改为跟随父容器缩放，避免与 Dock 子面板产生坐标系不一致导致右侧越界
    if instr.SetIgnoreParentScale then instr:SetIgnoreParentScale(false) end
    instr:Show()
    -- 防御：/reload 首帧偶发被父层级或其它淡入逻辑带着低 Alpha，
    -- 这里强制把暴雪 Instructions 容器复位为完全不透明，避免“整体发灰”。
    if instr.SetAlpha then instr:SetAlpha(1) end
    -- 尺寸变化：仅排队重新计算高度，避免递归
    if instr.HookScript then
        instr:HookScript("OnSizeChanged", function()
            if AdoptState and AdoptState.instr then
                -- 尝试将容器（如 HoverHUD 的 VerticalLayout）也拉伸至内容区宽度，避免初始宽度偏小导致右侧错位
                for _, ch in ipairs({instr:GetChildren()}) do _ADT_SetRowFixedWidth(ch) end
                _ADT_QueueResize()
            end
        end)
        instr:HookScript("OnShow", function()
            if self and self.SetAlpha then pcall(self.SetAlpha, self, 1) end
            if AdoptState and AdoptState.instr then _ADT_ApplyTypography(AdoptState.instr); _ADT_QueueResize() end
        end)
    end

    -- 初次排队计算；说明内容在不同模式会异步刷新，多给一帧稳定时间
    _ADT_ApplyTypography(instr)
    _ADT_QueueResize()
    -- 触发一次判空自动隐藏（如果说明被我们全部隐藏，或 HoverHUD 也不可见）
    -- 显隐权威回归暴雪 Instructions：OnShow/OnHide → 我们的 SubPanel 同步淡入/淡出
    if not instr._ADT_SubPanelVisibilityHooked then
        instr._ADT_SubPanelVisibilityHooked = true
        instr:HookScript("OnShow", function()
            if ADT and ADT.DockUI and ADT.DockUI.FadeInSubPanel then ADT.DockUI.FadeInSubPanel() end
        end)
        instr:HookScript("OnHide", function()
            if ADT and ADT.DockUI and ADT.DockUI.FadeOutSubPanel then ADT.DockUI.FadeOutSubPanel(0.5) end
        end)
    end
    -- 初始状态同步（避免 /reload 首帧残留或空壳）
    if instr:IsShown() then
        if ADT and ADT.DockUI and ADT.DockUI.FadeInSubPanel then ADT.DockUI.FadeInSubPanel() end
    else
        if ADT and ADT.DockUI and ADT.DockUI.InstantHideSubPanel then ADT.DockUI.InstantHideSubPanel() end
    end
    -- 针对登录后立刻切到“专家模式”时偶发未缩放：
    -- 某些行会在后续一两帧由暴雪代码异步刷新（UpdateAllVisuals/UpdateLayout），
    -- 我们这里做一次短暂的“后抖动重应用”，确保样式最终一致。
    if not AdoptState._styleTicker then
        local count = 0
        AdoptState._styleTicker = C_Timer.NewTicker(0.05, function(t)
            if not IsHouseEditorShown() then t:Cancel(); AdoptState._styleTicker=nil; return end
            if AdoptState and AdoptState.instr then _ADT_ApplyTypography(AdoptState.instr); _ADT_QueueResize() end
            count = count + 1
            if count >= 6 then t:Cancel(); AdoptState._styleTicker=nil end
        end)
    end

    -- 同时隐藏右上角官方 DecorCount（我们已在 Header 重绘计数）
    if active and active.DecorCount and active.DecorCount:IsShown() then
        active.DecorCount:Hide()
    end
    -- 确保头部计数常驻
    ShowBudgetInHeader()
    Debug("已重挂 Instructions 到 Dock 下方面板（不再镜像/不再隐藏官方容器）")
end

local function RestoreInstructions()
    if not AdoptState.instr or not AdoptState.originalParent then return end
    local instr = AdoptState.instr
    instr:ClearAllPoints()
    instr:SetParent(AdoptState.originalParent)
    -- 恢复字体尺寸，避免影响官方原位显示
    _ADT_RestoreTypography(instr)
    instr:Show()
    -- 使用其模板默认锚点，不强行恢复具体点位
    AdoptState.instr = nil
    AdoptState.originalParent = nil
    AdoptState.restored = true

    local dock = GetDock()
    if dock and dock.SetSubPanelShown then
        dock:SetSubPanelShown(false)
    end
    -- 不再使用镜像
    if AdoptState.mirror then AdoptState.mirror:Hide() end
    -- 恢复右上角官方 DecorCount
    local active = GetActiveModeFrame()
    if active and active.DecorCount then
        active.DecorCount:Show()
    end
    Debug("已恢复官方 Instructions/计数到原位置")
end

--
-- 三、统一入口：HouseEditor 打开/关闭与模式变化时同步
--
EL = CreateFrame("Frame")

local function TrySetupHooks()
    if not _G.HouseEditorFrameMixin or EL._hooksInstalled then return end
    -- 钩住显示/隐藏与模式切换
    pcall(function()
        hooksecurefunc(HouseEditorFrameMixin, "OnShow", function()
            -- 直接隐藏官方按钮并在 Header 放置代理按钮（避免任何重挂跳动）
            pcall(function() if ADT and ADT.DockUI and ADT.DockUI.AttachPlacedListButton then ADT.DockUI.AttachPlacedListButton() end end)
            EnsurePlacedListHooks(); AnchorPlacedList();
            EnsureDyePopoutHooks(); AnchorDyePopout();
            EnsureCustomizePaneHooks(); AnchorCustomizePane();
            HideOfficialDecorCountNow();
            ShowBudgetInHeader();
            C_Timer.After(0, AdoptInstructionsIntoDock)
            C_Timer.After(0.1, AdoptInstructionsIntoDock)
            C_Timer.After(0.05, ShowPlacedListIfExpertActive)
        end)
        hooksecurefunc(HouseEditorFrameMixin, "OnHide", function()
            RestoreHeaderTitle(); RestoreInstructions();
        end)
        hooksecurefunc(HouseEditorFrameMixin, "OnActiveModeChanged", function()
            pcall(function() if ADT and ADT.DockUI and ADT.DockUI.AttachPlacedListButton then ADT.DockUI.AttachPlacedListButton() end end)
            EnsurePlacedListHooks(); AnchorPlacedList(); EnsureDyePopoutHooks(); AnchorDyePopout(); EnsureCustomizePaneHooks(); AnchorCustomizePane(); HideOfficialDecorCountNow();
            C_Timer.After(0, AdoptInstructionsIntoDock)
            C_Timer.After(0.1, AdoptInstructionsIntoDock)
            C_Timer.After(0.05, ShowPlacedListIfExpertActive)
        end)
        -- 专家模式 Frame 本体 OnShow：这是最稳的时点，直接确保展示与贴合
        -- 不再 hook 专家模式以强制打开清单（保持官方原样）
        -- 进入专家模式时自动显示官方“放置的装饰”清单（并在 OnShow 时贴合到 Dock.SubPanel 下缘）
        -- 对行控件进行二次清理：若设置了 _ADTForceHideControl 或检测到“选择装饰”文本，则强制隐藏
        if _G.HouseEditorInstructionMixin then
            hooksecurefunc(HouseEditorInstructionMixin, "UpdateControl", function(self)
                -- 1) 彻底隐藏“选择装饰”行
                local t = self.InstructionText and self.InstructionText.GetText and self.InstructionText:GetText()
                if (self == AdoptState.selectRow) or _ADT_ShouldHideRowByText(t) or self._ADTForceHideRow then
                    if ADT and ADT.DebugPrint then ADT.DebugPrint("[Graft] UpdateControl hide row: " .. tostring(t)) end
                    self:Hide(); return
                end

                -- 2) 去掉所有“鼠标图标”（例如左键/滚轮等）：
                --    - 保留左侧文字（可能是说明或装饰名）
                --    - 隐藏右侧图标，不展示空白背景气泡
                local icon = self.Control and self.Control.Icon
                local atlas = icon and icon.GetAtlas and icon:GetAtlas()
                if type(atlas) == "string" and atlas:find("housing%-hotkey%-icon%-") then
                    -- 保险：移除配置以免后续刷新又把图标带回来
                    if self.iconAtlas ~= nil then self.iconAtlas = nil end
                    if self.keybindName ~= nil then self.keybindName = nil end
                    if self.controlText ~= nil then self.controlText = nil end
                    if self.Control.Background then self.Control.Background:Hide() end
                    if icon then icon:Hide() end
                    if self.Control then self.Control:Hide() end
                    if self.SetControlWidth then pcall(self.SetControlWidth, self, 0) end
                    if self.MarkDirty then self:MarkDirty() end
                    _ADT_QueueResize();
                    if ADT and ADT.DebugPrint then ADT.DebugPrint("[Graft] UpdateControl hide mouse icon: atlas=" .. tostring(atlas) .. ", text=" .. tostring(t)) end
                    return
                end

                if self._ADTForceHideControl and self.Control then
                    if self.Control.Background then self.Control.Background:Hide() end
                    if self.Control.Icon then self.Control.Icon:Hide() end
                    self.Control:Hide()
                end
                _ADT_ApplyTypographyToRow(self); _ADT_AlignControl(self); _ADT_FitControlText(self); _ADT_QueueResize()
            end)
            -- 同步在 UpdateInstruction 阶段也做一次兜底（某些路径只更新文本，会绕过 UpdateControl）
            hooksecurefunc(HouseEditorInstructionMixin, "UpdateInstruction", function(self)
                local t = self.InstructionText and self.InstructionText.GetText and self.InstructionText:GetText()
                if _ADT_ShouldHideRowByText(t) or self._ADTForceHideRow then
                    if ADT and ADT.DebugPrint then ADT.DebugPrint("[Graft] UpdateInstruction hide row: " .. tostring(t)) end
                    self:Hide(); _ADT_QueueResize(); return
                end
                _ADT_ApplyTypographyToRow(self); _ADT_AlignControl(self); _ADT_FitControlText(self); _ADT_QueueResize()
            end)
        end
        -- 同步钩住“容器级”的刷新：任何官方对 Instructions 的 UpdateAllVisuals/UpdateLayout
        -- 结束后再次套用我们的样式，避免时序竞态导致的漏网。
        if _G.HouseEditorInstructionsContainerMixin then
            hooksecurefunc(HouseEditorInstructionsContainerMixin, "UpdateAllVisuals", function(self)
                _ADT_ApplyTypography(self); _ADT_QueueResize()
            end)
            hooksecurefunc(HouseEditorInstructionsContainerMixin, "UpdateLayout", function(self)
                -- UpdateLayout 完成后，右侧键帽宽度可能变化；对全树再次套用统一样式，确保孙级（HoverHUD）也一致。
                if self then
                    _ADT_ApplyTypography(self)
                    for _, ch in ipairs({self:GetChildren()}) do _ADT_SetRowFixedWidth(ch); _ADT_AlignControl(ch); _ADT_AnchorRowColumns(ch); _ADT_FitControlText(ch) end
                end
                _ADT_QueueResize()
            end)
        end
        EL._hooksInstalled = true
        Debug("已安装 HouseEditorFrameMixin 钩子")
    end)
end

-- 注册 EventRegistry 回调（额外冗余，优先触发）
if EventRegistry and EventRegistry.RegisterCallback then
    EventRegistry:RegisterCallback("HouseEditor.StateUpdated", function(_, isActive)
        TrySetupHooks()
        if isActive then
            -- 就位清单与按钮后再显示
            EnsurePlacedListHooks(); AnchorPlacedList(); EnsureDyePopoutHooks(); AnchorDyePopout(); EnsureCustomizePaneHooks(); AnchorCustomizePane(); HideOfficialDecorCountNow();
            pcall(function() if ADT and ADT.DockUI and ADT.DockUI.AttachPlacedListButton then ADT.DockUI.AttachPlacedListButton() end end)
            ShowBudgetInHeader();
            C_Timer.After(0, AdoptInstructionsIntoDock)
            C_Timer.After(0.1, AdoptInstructionsIntoDock)
            C_Timer.After(0.05, ShowPlacedListIfExpertActive)
            -- 启动轮询直到成功采用
            if not EL._adoptTicker then
                local attempts = 0
                EL._adoptTicker = C_Timer.NewTicker(0.25, function(t)
                    attempts = attempts + 1
                    if not IsHouseEditorShown() then t:Cancel(); EL._adoptTicker=nil; return end
                    AdoptInstructionsIntoDock()
                    if AdoptState.instr then t:Cancel(); EL._adoptTicker=nil; Debug("轮询采纳成功") return end
                    if attempts >= 20 then t:Cancel(); EL._adoptTicker=nil; Debug("轮询超时，未能采纳 Instructions") end
                end)
            end
        else
            RestoreHeaderTitle();
            RestoreInstructions()
        end
    end, EL)
end

-- 事件：模式变化/加载/登录
EL:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED")
-- 选中目标变化：行数/内容会改变，需要触发一次自适应高度
EL:RegisterEvent("HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED")
EL:RegisterEvent("HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED")
EL:RegisterEvent("ADDON_LOADED")
EL:RegisterEvent("PLAYER_LOGIN")
EL:SetScript("OnEvent", function(_, event, arg1)
    if event == "HOUSE_EDITOR_MODE_CHANGED" then
        EnsurePlacedListHooks(); AnchorPlacedList(); EnsureDyePopoutHooks(); AnchorDyePopout(); EnsureCustomizePaneHooks(); AnchorCustomizePane(); HideOfficialDecorCountNow();
        C_Timer.After(0, AdoptInstructionsIntoDock)
        C_Timer.After(0.1, AdoptInstructionsIntoDock)
        C_Timer.After(0.05, ShowPlacedListIfExpertActive)
        C_Timer.After(0.05, _ADT_QueueResize)
        C_Timer.After(0.15, _ADT_QueueResize)
    elseif event == "HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED" or event == "HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED" then
        -- 选中/取消选中都会改动说明行，分多帧排版
        C_Timer.After(0, _ADT_QueueResize)
        C_Timer.After(0.03, _ADT_QueueResize)
        C_Timer.After(0.1, _ADT_QueueResize)
    elseif event == "ADDON_LOADED" and (arg1 == "Blizzard_HouseEditor" or arg1 == ADDON_NAME) then
        TrySetupHooks()
        if IsHouseEditorShown() then
            EnsurePlacedListHooks(); AnchorPlacedList(); EnsureDyePopoutHooks(); AnchorDyePopout(); EnsureCustomizePaneHooks(); AnchorCustomizePane(); HideOfficialDecorCountNow(); ShowBudgetInHeader(); C_Timer.After(0, AdoptInstructionsIntoDock); C_Timer.After(0.05, ShowPlacedListIfExpertActive)
        end
    elseif event == "PLAYER_LOGIN" then
        TrySetupHooks()
        C_Timer.After(0.5, function()
            if IsHouseEditorShown() then
                EnsurePlacedListHooks(); AnchorPlacedList(); EnsureDyePopoutHooks(); AnchorDyePopout(); EnsureCustomizePaneHooks(); AnchorCustomizePane(); HideOfficialDecorCountNow(); ShowBudgetInHeader(); C_Timer.After(0, AdoptInstructionsIntoDock); C_Timer.After(0.05, ShowPlacedListIfExpertActive)
            end
        end)
    end
end)

-- 容错：如果当前就处于家宅编辑器，延迟一次尝试
C_Timer.After(1.0, function()
    TrySetupHooks()
    if IsHouseEditorShown() then
        EnsurePlacedListHooks(); AnchorPlacedList(); EnsureDyePopoutHooks(); AnchorDyePopout(); EnsureCustomizePaneHooks(); AnchorCustomizePane(); HideOfficialDecorCountNow(); ShowBudgetInHeader(); C_Timer.After(0, AdoptInstructionsIntoDock); C_Timer.After(0.05, ShowPlacedListIfExpertActive)
    end
end)
