-- [[ ExwindFramePool.lua ]]




local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

local EXFactory = {}
_G.ExwindFactory = EXFactory

-- 池子存储
EXFactory.Pools = {}

-- 活跃对象追踪表（供 DevMonitor 显示地址用）
-- 结构: { [poolType] = { [frame] = true } }
EXFactory.ActiveTracker = {}

-------------------------------------------------------
-- 辅助：标准重置函数 (Cleaner)
-------------------------------------------------------
local function StandardReset(pool, frame)
    frame:Hide()
    frame:ClearAllPoints()
    frame:SetParent(UIParent)
    frame:SetAlpha(1)
    frame:SetScale(1)

    -- 防止动作残留
    frame:SetScript("OnUpdate", nil)

    -- [0429] DropdownButton 的 OnEnter/OnLeave 是模板内置的纯视觉脚本（高亮/取消高亮），
    -- 不携带任何外部状态，清除后悬停高亮和点击动画会永久失效。
    -- 如有 BUG 直接删除此 if/else，恢复原始的无条件清除。
    local isDropdown = frame.IsObjectType and frame:IsObjectType("DropdownButton")
    if not isDropdown then
        frame:SetScript("OnEnter", nil)
        frame:SetScript("OnLeave", nil)
    end

    -- [Fix] 只有按钮才有 OnClick，先判断类型再操作
    if frame.IsObjectType and frame:IsObjectType("Button") then
        frame:SetScript("OnClick", nil)
        frame:SetScript("PreClick", nil)
        frame:SetScript("PostClick", nil)
        -- [0429] DropdownButton 的 OnMouseDown/OnMouseUp 同上，保留模板视觉脚本
        if not isDropdown then
            frame:SetScript("OnMouseDown", nil)
            frame:SetScript("OnMouseUp", nil)
        end
        if frame.Enable then
            frame:Enable()
        end
        if frame.RegisterForClicks then
            frame:RegisterForClicks("LeftButtonUp")
        end
    end

    -- 若是按钮，也清理文本
    if frame.SetText then
        frame:SetText("")
    end

    if frame.EnableMouse then
        frame:EnableMouse(false)
    end

    -- 若有文字子项，也进行重置
    if frame.cells then
        for _, fs in ipairs(frame.cells) do
            fs:SetText("")
            fs:SetTextColor(1, 1, 1, 1)
            fs:ClearAllPoints()
            fs:SetAlpha(1)
        end
    end

    if frame.icon then
        frame.icon:SetTexture(nil)
        frame.icon:SetDesaturated(false)
        frame.icon:SetAlpha(1)
    end

    if frame.name then frame.name:SetText("") end
    if frame.title then frame.title:SetText("") end
    if frame.value then frame.value:SetText("") end
    if frame.level then frame.level:SetText("") end
    if frame.score then frame.score:SetText("") end
    if frame.text and frame.text.SetText then frame.text:SetText("") end
    if frame.label and frame.label.SetText then frame.label:SetText("") end
    if frame.labelText and frame.labelText.SetText then frame.labelText:SetText("") end

    -- [GridCheckbox] 彻底清理子勾选框状态与脚本，避免池化残留导致“今天好明天坏”
    if frame.checkbox then
        if frame.checkbox.SetScript then
            frame.checkbox:SetScript("OnClick", nil)
            frame.checkbox:SetScript("OnEnter", nil)
            frame.checkbox:SetScript("OnLeave", nil)
            frame.checkbox:SetScript("PreClick", nil)
            frame.checkbox:SetScript("PostClick", nil)
            frame.checkbox:SetScript("OnShow", nil)
            frame.checkbox:SetScript("OnHide", nil)
        end
        if frame.checkbox.HookScript then
            -- HookScript 无法移除历史 hook，因此只依赖不再对 checkbox 使用 HookScript。
        end
        if frame.checkbox.SetChecked then
            frame.checkbox:SetChecked(false)
        end
        if frame.checkbox.Enable then
            frame.checkbox:Enable()
        end
        if frame.checkbox.EnableMouse then
            frame.checkbox:EnableMouse(true)
        end
        if frame.checkbox.ClearAllPoints then
            frame.checkbox:ClearAllPoints()
            frame.checkbox:SetPoint("LEFT", frame, "LEFT", 0, 0)
        end
    end

    if frame.label and frame.label.ClearAllPoints and frame.checkbox then
        frame.label:ClearAllPoints()
        frame.label:SetPoint("LEFT", frame.checkbox, "RIGHT", 6, 0)
    end

    -- [v4.3.2 Fix] 清理 Dropdown/LSMDropdown 存储的临时属性 防止 Config 表与闭包泄漏
    frame._currentValue = nil
    frame._onSelect = nil
    frame._items = nil
    frame._selectedValue = nil
    -- 注意：不清除 _mediaType，因为 SetupMenu 回调依赖它，会在 CreateLSMDropdown 中重新设置

    -- [v4.3.12] 清理 Slider 回调引用（保留 _sliderInit 以识别已初始化）
    frame._onValueChanged = nil
    frame._formatter = nil

    -- [v4.3.13] 清理 Multiselect 属性，防止职业切换时数据残留
    frame._options = nil
    frame._selections = nil
    frame._onUpdate = nil
end

-------------------------------------------------------
-- API: 初始化某种类型的池子
-------------------------------------------------------
-- type: 池子类型 Key (如 "StandardRow")
-- frameType: 基础控件类型 (如 "Frame", "Button")
-- template: 继承的暴雪模板
-- customInit: 第一次创建时执行的初始化函数
function EXFactory:InitPool(type, frameType, template, customInit)
    if self.Pools[type] then return end

    local pool = CreateFramePool(frameType or "Frame", UIParent, template, StandardReset)
    pool.customInit = customInit
    self.Pools[type] = pool
end

-------------------------------------------------------
-- API: 借用 (Acquire)
-------------------------------------------------------
function EXFactory:Acquire(type, parent)
    local pool = self.Pools[type]
    if not pool then
        -- 如果没初始化 尝试建立一个默认的
        self:InitPool(type, "Frame")
        pool = self.Pools[type]
    end

    local frame, isNew = pool:Acquire()



    -- [v4.3.1] 标记此 Frame 来自池
    frame._fromPool = type

    -- 如果是第一次创建，执行它的初始化逻辑
    if isNew and pool.customInit then
        local ok, err = pcall(pool.customInit, frame)
        if not ok then
            print(string.format("|cffff0000[ExwindFactory] 初始化错误 [%s]: %s|r", tostring(type), tostring(err)))
        end
    end

    if parent then
        frame:SetParent(parent)
    end

    -- [v4.3.16 Fix] StandardReset 会统一关闭鼠标，按钮类在重新取回时必须恢复交互
    if frame.IsObjectType and frame:IsObjectType("Button") then
        if frame.Enable then
            frame:Enable()
        end
        if frame.EnableMouse then
            frame:EnableMouse(true)
        end
        if frame.RegisterForClicks then
            -- [0429] DropdownButton 需同时注册 Down 事件，否则 OnMouseDown 不触发，按下动画永久失效
            if frame.IsObjectType and frame:IsObjectType("DropdownButton") then
                frame:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
            else
                frame:RegisterForClicks("LeftButtonUp")
            end
        end
    end

    -- 追踪活跃对象（供 DevMonitor 地址显示）
    if not EXFactory.ActiveTracker[type] then
        EXFactory.ActiveTracker[type] = {}
    end
    EXFactory.ActiveTracker[type][frame] = true

    frame:Show()
    return frame, isNew
end

-------------------------------------------------------
-- API: 归还 (Release)
-------------------------------------------------------
function EXFactory:Release(type, frame)
    -- [v4.3.1] 只有真正来自池的 Frame 才能归还
    -- 检查 _fromPool 标记，避免暴雪池抛出 "doesn't belong to this pool" 错误
    if not frame._fromPool then
        -- 不是从池获取的，直接隐藏
        frame:Hide()
        frame:ClearAllPoints()
        frame:SetParent(nil)
        return
    end

    local poolType = frame._fromPool
    local pool = self.Pools[poolType]
    if pool then
        frame._fromPool = nil -- 清除标记
        -- 移除追踪记录
        if EXFactory.ActiveTracker[poolType] then
            EXFactory.ActiveTracker[poolType][frame] = nil
        end
        pool:Release(frame)
    else
        -- 池不存在，退化为隐藏
        frame:Hide()
        frame:ClearAllPoints()
        frame:SetParent(nil)
    end
end

-------------------------------------------------------
-- API: 调试 - 获取当前池子活跃对象数
-------------------------------------------------------
function EXFactory:GetActiveCount(type)
    local pool = self.Pools[type]
    return pool and pool:GetNumActive() or 0
end

-------------------------------------------------------
-- 预设：标准组件 (Standards)
-------------------------------------------------------

-- 0. 基础纯净框架
EXFactory:InitPool("SimpleFrame", "Frame", "BackdropTemplate", function(f)
end)

-- 1. 标准列表行 (StandardRow): 带有背景和 5 个文字单元格
EXFactory:InitPool("StandardRow", "Frame", nil, function(f)
    f:SetSize(720, 25)
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)
    f.cells = {}
    for i = 1, 5 do
        local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        table.insert(f.cells, fs)
    end
end)

-- 2. 标准图标块 (StandardIcon): 带边框的图标
EXFactory:InitPool("StandardIcon", "Frame", nil, function(f)
    f:SetSize(32, 32)
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetAllPoints()
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.border = f:CreateTexture(nil, "OVERLAY")
    f.border:SetAllPoints()
    f.border:SetTexture("Interface\\Buttons\\UI-EmptySlot-White")
    f.border:SetVertexColor(0.3, 0.3, 0.3, 0.8)
end)

-- 3. 标准按钮 (StandardButton)
EXFactory:InitPool("StandardButton", "Button", "UIPanelButtonTemplate", function(f)
    f:SetSize(80, 22)
end)

-- 4. 图标文字卡片 (IconTextCard)
EXFactory:InitPool("IconTextCard", "Frame", "BackdropTemplate", function(f)
    f:SetSize(130, 65)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(1, 1, 1, 0.05)
    f:SetBackdropBorderColor(1, 1, 1, 0.25)
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(45, 45)
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.icon:SetPoint("LEFT", 0, -5)
    f.title = f:CreateFontString(nil, "OVERLAY")
    f.title:SetPoint("TOP", 3, -6)
    f.value = f:CreateFontString(nil, "OVERLAY")
    f.value:SetPoint("TOP", 2, -27)
end)

-- 5. 大秘境统计行 (StatRow)
EXFactory:InitPool("StatRow", "Frame", "BackdropTemplate", function(f)
    f:SetSize(800, 45)
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetAllPoints()
    f.icon = f:CreateTexture(nil, "OVERLAY")
    f.icon:SetSize(40, 40)
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.icon:SetPoint("LEFT", 10, 0)
    f.name = f:CreateFontString(nil, "OVERLAY")
    f.name:SetPoint("LEFT", 57, 0)
    f.cells = {}
    for i = 1, 10 do
        local fs = f:CreateFontString(nil, "OVERLAY")
        table.insert(f.cells, fs)
    end
end)

-- 6. 大秘境历史记录行 (RunRow): 图标 + 名字 + 装等
EXFactory:InitPool("RunRow", "Frame", "BackdropTemplate", function(f)
    f:SetSize(300, 40)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(1, 1, 1, 0.03)
    f:SetBackdropBorderColor(1, 1, 1, 0.25)
    f.icon = f:CreateTexture(nil, "OVERLAY")
    f.icon:SetSize(30, 30)
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    f.icon:SetPoint("LEFT", 6, 0)
    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetPoint("LEFT", 40, 0)
    f.ilvl = f:CreateFontString(nil, "OVERLAY")
    f.ilvl:SetPoint("RIGHT", -8, 0)
end)

-- 7. 大秘境图标覆盖层 (MythicIconOverlay)
EXFactory:InitPool("MythicIconOverlay", "Frame", nil, function(f)
    f:SetSize(100, 100)
    f.name = f:CreateFontString(nil, "OVERLAY")
    f.level = f:CreateFontString(nil, "OVERLAY")
    f.score = f:CreateFontString(nil, "OVERLAY")
end)

-------------------------------------------------------
-- [v4.3.1] Grid 引擎专用组件池
-- 用于设置面板的 UI 组件池化复用
-------------------------------------------------------

-- Grid 组件重置函数
local function ResetGridWidget(pool, frame)
    StandardReset(pool, frame)
    -- 清理 Grid 特有属性
    frame._gridType = nil
    frame._gridKey = nil
    frame._moduleKey = nil
    -- 清理所有事件脚本
    if frame.SetScript then
        frame:SetScript("OnValueChanged", nil)
        frame:SetScript("OnTextChanged", nil)
        frame:SetScript("OnEditFocusLost", nil)
        frame:SetScript("OnEnterPressed", nil)
    end
end

-- 8. GridCheckbox - 复选框容器 (与 EXUI:CreateCheckbox 结构一致)
EXFactory:InitPool("GridCheckbox", "Frame", nil, function(f)
    f:SetSize(200, 28)

    -- 创建 CheckButton (使用暴雪现代版模板)
    local cb = CreateFrame("CheckButton", nil, f, "MinimalCheckboxTemplate")
    cb:SetSize(28, 28)
    cb:SetPoint("LEFT", f, "LEFT", 0, 0)
    -- 模板已自带现代 Atlas 贴图 (checkbox-minimal, checkmark-minimal)，无需手动 SetTexture
    f.checkbox = cb

    -- 创建 Label
    local label = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("LEFT", cb, "RIGHT", 6, 0)
    f.label = label

    -- 兼容方法
    function f:SetChecked(v) self.checkbox:SetChecked(v) end

    function f:GetChecked() return self.checkbox:GetChecked() end

    f._gridType = "GridCheckbox"
end)

-- 9. GridButton - 按钮
-- 9. GridButton - 通用按钮
EXFactory:InitPool("GridButton", "Button", "SharedButtonLargeTemplate", function(f)
    f:SetSize(120, 32)
    f._gridType = "GridButton"
end)

-- 10. GridSlider - 滑块 (与 EXUI:CreateSlider 结构一致)
EXFactory:InitPool("GridSlider", "Slider", "MinimalSliderWithSteppersTemplate", function(f)
    f:SetSize(180, 20)

    -- 顶部数值显示 (靠右)
    f.ValueText = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    f.ValueText:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", -2, 1)
    f.ValueText:SetJustifyH("RIGHT")

    -- 顶部标题 (靠左)
    f.Title = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    f.Title:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 1)
    f.Title:SetPoint("RIGHT", f.ValueText, "LEFT", -5, 0)
    f.Title:SetJustifyH("LEFT")
    f.Title:SetWordWrap(false)

    f.labelText = f.Title -- 兼容
    f._gridType = "GridSlider"
end)

-- 11. GridDropdown - 下拉菜单 (与 EXUI:CreateDropdown 结构一致)
EXFactory:InitPool("GridDropdown", "DropdownButton", "WowStyle1DropdownTemplate", function(f)
    f:SetSize(180, 30)
    f.labelText = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    f.labelText:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 2)
    f._gridType = "GridDropdown"

    -- [Fix] Text 的原始锚点 TOPLEFT y=-8 在 Grid 压缩高度下会导致文字偏上
    -- 修正 Text 为垂直居中；Arrow 保留暴雪原始 y=-3 偏移（与背景纹理视觉中心对齐）
    if f.Text then
        f.Text:ClearAllPoints()
        f.Text:SetPoint("LEFT", 8, 0)
        f.Text:SetPoint("RIGHT", f.Arrow, "LEFT", -2, 0)
    end
    if f.Arrow then
        f.Arrow:ClearAllPoints()
        f.Arrow:SetPoint("RIGHT", -2, -3)
    end
end)

-- 12. GridInput - 输入框
EXFactory:InitPool("GridInput", "EditBox", "BackdropTemplate", function(f)
    f:SetSize(180, 28)
    f:SetAutoFocus(false)
    f:SetFontObject(GameFontHighlight)

    -- 使用全插件统一的 Tooltip 风格
    local EXUI = _G.ExwindTools.UI
    if EXUI and EXUI.TooltipBackdrop then
        f:SetBackdrop(EXUI.TooltipBackdrop)
    else
        f:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 14,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
    end
    f:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    f:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.6)

    f:SetTextInsets(10, 10, 0, 0)
    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.label:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 2)
    f._gridType = "GridInput"
end)

-- 13. GridHeader - 标题 (与 EXUI:CreateHeader 结构一致)
EXFactory:InitPool("GridHeader", "Frame", nil, function(f)
    f:SetSize(550, 40)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 0, -5)
    title:SetTextColor(1, 0.82, 0)
    f.Title = title
    f.text = title -- 兼容旧引用

    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    line:SetPoint("RIGHT", 0, 0)
    line:SetHeight(1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))
    f.Line = line

    f._gridType = "GridHeader"
end)

-- 14. GridSubheader - 子标题
EXFactory:InitPool("GridSubheader", "Frame", nil, function(f)
    f:SetSize(400, 24)
    f.text = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    f.text:SetAllPoints()
    f.text:SetJustifyH("LEFT")
    f._gridType = "GridSubheader"
end)

-- 15. GridDivider - 分割线
EXFactory:InitPool("GridDivider", "Frame", nil, function(f)
    -- [Fix] 彻底透明化容器背景
    if f.SetBackdrop then f:SetBackdrop(nil) end
    f:SetSize(400, 20) -- 设定物理占位高度，但视觉线只有1px

    -- 使用 Line API 绘制分隔线，支持物理像素对齐
    local line = f:CreateLine(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.4)
    line:SetStartPoint("LEFT", f, 0, 0)
    line:SetEndPoint("RIGHT", f, 0, 0)

    -- 实时粗细对齐
    local scale = line:GetEffectiveScale() or 1
    if _G.PixelUtil and _G.PixelUtil.GetNearestPixelSize then
        line:SetThickness(_G.PixelUtil.GetNearestPixelSize(1.1, scale, 1.1))
    else
        line:SetThickness(1.1)
    end

    f.line = line
    f._gridType = "GridDivider"
end)

-- 16. GridDescription - 描述文本
EXFactory:InitPool("GridDescription", "Frame", nil, function(f)
    f:SetSize(400, 40)
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.text:SetPoint("TOPLEFT")
    f.text:SetJustifyH("LEFT")
    f.text:SetJustifyV("TOP")
    f._gridType = "GridDescription"
end)

-- 17. GridColorButton - 颜色选择按钮
EXFactory:InitPool("GridColorButton", "Button", "BackdropTemplate", function(f)
    f:SetSize(28, 28)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 2
    })
    f:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    f.swatch = f:CreateTexture(nil, "ARTWORK")
    f.swatch:SetPoint("TOPLEFT", 3, -3)
    f.swatch:SetPoint("BOTTOMRIGHT", -3, 3)
    f.swatch:SetColorTexture(1, 1, 1, 1)
    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.label:SetPoint("LEFT", f, "RIGHT", 6, 0)
    f._gridType = "GridColorButton"
end)

-- 18. GridMultiselect - 多选框容器
EXFactory:InitPool("GridMultiselect", "Frame", "BackdropTemplate", function(f)
    f:SetSize(200, 80)
    f.label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.label:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 2)
    f.checkboxes = {} -- 子复选框将动态创建
    f._gridType = "GridMultiselect"
end)

-- 19. GridTableGroup - 表格组容器（用于 parentKey 数据绑定）
EXFactory:InitPool("GridTableGroup", "Frame", nil, function(f)
    f:SetSize(1, 1) -- 不可见容器
    f._gridType = "GridTableGroup"
end)

-- 20. GridFontGroup - 字体设置组（只创建外层容器，子组件由 CreateFontGroup 动态创建）
-- 注意：这个池用于整体复用 FontGroup，但首次创建时仍需初始化子组件
EXFactory:InitPool("GridFontGroup", "Frame", "BackdropTemplate", function(f)
    f:SetSize(750, 280)
    f._gridType = "GridFontGroup"
    -- 子组件由 EXUI:CreateFontGroup 内部创建（它们使用各自的池）
end)

-- 21. GridLSMDropdown - LSM 材质选择器
EXFactory:InitPool("GridLSMDropdown", "DropdownButton", "WowStyle1DropdownTemplate", function(f)
    f:SetSize(180, 30)
    f.labelText = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    f.labelText:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 2)
    f._gridType = "GridLSMDropdown"
end)

-------------------------------------------------------
-- [v4.3.1] Grid 池类型映射表
-------------------------------------------------------
EXFactory.GridTypeMap = {
    checkbox = "GridCheckbox",
    button = "GridButton",
    slider = "GridSlider",
    dropdown = "GridDropdown",
    input = "GridInput",
    header = "GridHeader",
    subheader = "GridSubheader",
    divider = "GridDivider",
    description = "GridDescription",
    color = "GridColorButton",
    colorbutton = "GridColorButton",
    multiselect = "GridMultiselect",
    TableGroup = "GridTableGroup",
    fontgroup = "GridFontGroup",
    lsm_font = "GridLSMDropdown",
    lsm_texture = "GridLSMDropdown",
    lsm_background = "GridLSMDropdown",
    lsm_border = "GridLSMDropdown",
    lsm_sound = "GridLSMDropdown",
    lsm_statusbar = "GridLSMDropdown",
}

-------------------------------------------------------
-- [v4.3.1] Grid 专用：获取组件
-------------------------------------------------------
function EXFactory:AcquireGridWidget(gridType, parent)
    local poolType = self.GridTypeMap[gridType]
    if not poolType then
        -- 未知类型，返回简单 Frame
        poolType = "SimpleFrame"
    end
    local frame, isNew = self:Acquire(poolType, parent)
    frame._gridType = poolType
    return frame, isNew
end

-------------------------------------------------------
-- [v4.3.1] Grid 专用：归还组件
-------------------------------------------------------
function EXFactory:ReleaseGridWidget(frame)
    if frame and frame._gridType then
        self:Release(frame._gridType, frame)
    else
        -- 兜底：隐藏
        if frame then
            frame:Hide()
            frame:SetParent(nil)
        end
    end
end
