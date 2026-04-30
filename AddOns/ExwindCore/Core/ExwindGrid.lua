-- =========================================================
-- ExwindGrid.lua - 可视化网格布局引擎 (v4.2 增强版)
-- =========================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then
    error("[ExwindGrid] 错误: ExwindTools.lua 必须在 ExwindGrid.lua 之前加载!")
end

-- 确保 EXUI 命名空间存在（可能在 ExwindToolsUI.lua 之前加载）
local EXUI = ExwindTools.UI or {}
ExwindTools.UI = EXUI

local Grid = {
    Cols = 50,
    CellSize = 0,
    Padding = 2,
    ActiveLayout = {},
    Widgets = {},
    IsLiveEditing = false,
    ContainerCols = setmetatable({}, { __mode = "k" }),
    ContainerStates = setmetatable({}, { __mode = "k" }),
    _effectiveCols = 50,
}

-- 挂载到多个位置方便访问
ExwindTools.Grid = Grid
EXUI.Grid = Grid
_G.ExwindGrid = Grid

local function NormalizeCols(cols)
    local n = tonumber(cols)
    if not n then return nil end
    n = math.floor(n)
    if n < 10 then n = 10 end
    if n > 200 then n = 200 end
    return n
end

local function GetContainerState(self, container)
    if not container then return nil end
    local state = self.ContainerStates[container]
    if not state then
        state = {
            widgets = {},
            widgetMap = {},
            layout = nil,
            config = nil,
            moduleKey = nil,
        }
        self.ContainerStates[container] = state
    end
    return state
end

local function ActivateContainerState(self, container, state)
    if not container or not state then return end
    self._activeContainer = container
    self.Widgets = state.widgets
    self.WidgetMap = state.widgetMap
    self.ActiveLayout = state.layout or {}
    self.LastConfig = state.config
    self.ModuleKey = state.moduleKey
end

function Grid:SetContainerCols(container, cols)
    if not container then return false end
    local n = NormalizeCols(cols)
    if not n then
        self.ContainerCols[container] = nil
        return false
    end
    self.ContainerCols[container] = n
    return true
end

function Grid:ClearContainerCols(container)
    if not container then return end
    self.ContainerCols[container] = nil
end

function Grid:GetContainerCols(container)
    if not container then return nil end
    return self.ContainerCols[container]
end

function Grid:UpdateMetrics(containerWidth, container)
    local cols = self:GetContainerCols(container) or self.Cols
    self._effectiveCols = cols
    self.CellSize = (containerWidth - 20) / cols
end

function Grid:GetPixelRect(x, y, w, h)
    local px = (x - 1) * self.CellSize + 10
    local py = -(y - 1) * self.CellSize - 10
    local pw = w * self.CellSize - self.Padding
    local ph = (h or 2) * self.CellSize - self.Padding
    return px, py, pw, ph
end

function Grid:GetGridPos(lx, ly)
    local gx = math.floor((lx - 5) / self.CellSize) + 1
    local gy = math.floor((math.abs(ly) - 5) / self.CellSize) + 1
    local cols = self._effectiveCols or self.Cols
    return math.max(1, math.min(gx, cols)), math.max(1, gy)
end

function Grid:IsAreaEmpty(x, y, w, h, excludeKey, layout)
    -- [v2.0] 支持传入指定的 layout 子集（用于 TableGroup 内部排版检测）
    -- 但由于 v2.0 采用绝对坐标，其实还是应该检测全局
    -- 只是为了编辑器逻辑，可能需要调整
    local targetLayout = layout or self.ActiveLayout

    -- 递归检查函数
    local function checkRecursive(items)
        for _, item in ipairs(items) do
            if item.key ~= excludeKey then
                -- 核心：所有组件在运行时都使用绝对坐标 (item.x, item.y)
                -- 所以直接比较坐标即可，无需关心层级
                if not (x + w <= item.x or x >= item.x + item.w or
                        y + (h or 2) <= item.y or y >= item.y + (item.h or 2)) then
                    return false
                end

                -- 如果是 TableGroup，递归检查其子元素
                if item.children then
                    if not checkRecursive(item.children) then return false end
                end
            end
        end
        return true
    end

    if layout then
        -- 如果指定了子集，只检查子集（通常用于局部重排）
        return checkRecursive(layout)
    else
        -- 默认检查全局所有元素
        return checkRecursive(self.ActiveLayout)
    end
end

-- [Core] 提前声明 Helper，供 ValidateContext 调用
local function GetConfigPath(config, path)
    if not config or not path then return config end
    local keys = { strsplit(".", path) }
    local curr = config
    for i = 1, #keys do
        local k = tonumber(keys[i]) or keys[i]
        if type(curr) ~= "table" then return nil end
        curr = curr[k]
    end
    return curr
end

-- [v2.0 New] 数据有效性验证
function Grid:ValidateContext(config, contextPath)
    if not contextPath or contextPath == "" then return true end
    local data = GetConfigPath(config, contextPath)
    return (data ~= nil)
end

-- [v2.0 New] 递归渲染核心
function Grid:RenderItems(container, items, contextPath, config, moduleKey)
    for _, item in ipairs(items) do
        -- 1. 计算当前组件的绝对数据路径 (Scoped Context)
        local currentPath = contextPath
        if item.parentKey then
            if currentPath then
                currentPath = currentPath .. "." .. item.parentKey
            else
                currentPath = item.parentKey
            end
        end

        -- 2. 数据有效性熔断保护
        -- 如果当前路径无效（例如 rows.5 已被删除），则跳过渲染或回退
        if currentPath and not self:ValidateContext(config, currentPath) then

        else
            if item.type == "TableGroup" then
                -- [逻辑容器模式]
                -- Header/Label 渲染 (如果有)
                if item.label then
                    -- TableGroup 自身作为一个 Label/Header 组件存在
                    self:CreateWidget(container, item, config, moduleKey, currentPath)
                end

                -- 递归渲染子元素
                -- 关键：container 保持不变 (MainFrame)，传递新的 ContextPath
                if item.children then
                    self:RenderItems(container, item.children, currentPath, config, moduleKey)
                end
            else
                -- [普通组件]
                -- 使用计算好的 Absolute Path 进行数据绑定
                -- 传递 currentPath 给 CreateWidget，它将用作 fullKey
                self:CreateWidget(container, item, config, moduleKey, currentPath)
            end
        end
    end
end

function Grid:Render(container, layoutData, config, moduleKey, onFinished)
    if not container or not layoutData then return end

    if type(config) == "string" then
        moduleKey = config
        config = ExwindTools:GetModuleDB(moduleKey)
    end

    local state = GetContainerState(self, container)
    state.layout = layoutData
    state.config = config
    state.moduleKey = moduleKey
    ActivateContainerState(self, container, state)

    self:UpdateMetrics(container:GetWidth(), container)

    -- [v4.3.1] 仅归还当前容器的旧组件，避免不同面板互相清场
    local EXFactory = _G.ExwindFactory
    for k, w in pairs(self.Widgets) do
        if EXFactory and w._gridType then
            EXFactory:ReleaseGridWidget(w)
        else
            -- 兜底：旧逻辑
            w:Hide()
            w:SetParent(nil)
        end
    end
    table.wipe(self.Widgets)

    -- [v4.3 Fix] 清理当前容器的反向索引，防止旧引用残留
    table.wipe(self.WidgetMap)

    -- [v2.0] 启动递归渲染
    self:RenderItems(container, layoutData, nil, config, moduleKey)

    -- 计算最大高度 (需要递归遍历所有元素)
    local maxH = 1
    local function findMaxH(items)
        for _, ele in ipairs(items) do
            if ele.y then
                maxH = math.max(maxH, ele.y + (ele.h or 2))
            end
            if ele.children then findMaxH(ele.children) end
        end
    end
    findMaxH(layoutData)

    container:SetHeight(maxH * self.CellSize + 80)

    if onFinished then onFinished() end
end

-- (GetConfigPath moved to top)

local function GetConfigValue(config, ele)
    if not config then return nil end

    local curr = config
    if ele.parentKey then
        curr = GetConfigPath(config, ele.parentKey)
    end

    if not curr or type(curr) ~= "table" then return nil end

    -- [Core] setKey 优先级最高，用于分离 GridKey 和 DBKey
    if ele.setKey then
        local sk = tonumber(ele.setKey) or ele.setKey
        return curr[sk]
    end

    -- [v4.3.2 Fix] subKey 优先级高于 ele.key
    -- 用法: parentKey="current", subKey="iconSize" → 读取 config.current.iconSize
    -- ele.key (如 "current_iconSize") 仅用于 Grid 组件标识，不参与数据路径
    if ele.subKey then
        local sk = tonumber(ele.subKey) or ele.subKey
        return curr[sk]
    end

    local key = ele.key
    local numKey = tonumber(key)
    local finalKey = numKey or key

    return curr[finalKey]
end

-- [v4.3.1] 递归查找布局项
local function FindLayoutItem(items, key)
    for _, item in ipairs(items) do
        if item.key == key then return item end
        if item.children then
            local found = FindLayoutItem(item.children, key)
            if found then return found end
        end
    end
    return nil
end

local function BindTooltip(target, ele, enableMouse)
    if not target or not target.SetScript then
        return
    end
    if ele.tooltip or ele.spellID then
        if enableMouse and target.EnableMouse then
            target:EnableMouse(true)
        end
        target:SetScript("OnEnter", function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if ele.spellID then
                _G.GameTooltip:SetSpellByID(ele.spellID)
            elseif ele.tooltip then
                _G.GameTooltip:SetText(ele.tooltip, 1, 1, 1, 1, true)
            end
            _G.GameTooltip:Show()
        end)
        target:SetScript("OnLeave", function()
            _G.GameTooltip:Hide()
        end)
    else
        if enableMouse and target.EnableMouse then
            target:EnableMouse(false)
        end
        target:SetScript("OnEnter", nil)
        target:SetScript("OnLeave", nil)
    end
end


local function SetConfigValue(config, ele, val, moduleKey, fullKey)
    if not config then return end

    -- [Core] setKey 优先级最高 (Force Global/Local Override)
    if ele.setKey then
        local sk = tonumber(ele.setKey) or ele.setKey
        config[sk] = val
        ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
            { key = ele.setKey, gridKey = ele.key, value = val, ts = GetTime() })
        return
    end

    -- 解析路径并赋值
    local finalPath = fullKey
    if finalPath then
        local parts = { strsplit(".", finalPath) }
        local ptr = config
        for i = 1, #parts - 1 do
            local k = tonumber(parts[i]) or parts[i]
            if not ptr[k] then ptr[k] = {} end
            ptr = ptr[k]
        end
        local lastKey = tonumber(parts[#parts]) or parts[#parts]
        ptr[lastKey] = val
    else
        local fk = tonumber(ele.key) or ele.key
        config[fk] = val
    end

    -- 通知更新
    ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
        { key = ele.key, fullPath = fullKey, value = val, ts = GetTime() })
end

function Grid:CreateWidget(container, ele, config, moduleKey, contextPath)
    -- [v4.3.2] 构造当前组件的完整数据路径
    -- 关键: 当有 subKey 时，使用 subKey 作为数据键 (ele.key 仅用于 Grid 组件标识)
    local fullPath
    local dataKey = ele.subKey or ele.key -- subKey 优先级高于 key

    if contextPath then
        fullPath = contextPath .. "." .. dataKey
    else
        if ele.parentKey then
            fullPath = ele.parentKey .. "." .. dataKey
        else
            fullPath = tostring(dataKey)
        end
    end

    local px, py, pw, ph = self:GetPixelRect(ele.x, ele.y, ele.w, ele.h)
    local widget

    -- [v4.3.2] 获取值：setKey 最高优先，然后使用构造好的 fullPath
    local curVal
    if ele.setKey then
        curVal = config[ele.setKey]
    else
        curVal = GetConfigPath(config, fullPath)
    end

    -- 闭包 Helper
    local function Setter(v)
        SetConfigValue(config, ele, v, moduleKey, fullPath)
    end

    -- ... (Create Logic) ...
    if ele.type == "header" then
        local text = ele.label
        if type(text) == "function" then text = text() end
        widget = EXUI:CreateHeader(container, text or "", pw)
    elseif ele.type == "subheader" then
        local text = ele.label
        if type(text) == "function" then text = text() end

        -- [v4.3.1] 从池获取
        local EXFactory = _G.ExwindFactory
        if EXFactory then
            widget = EXFactory:Acquire("GridSubheader", container)
        else
            widget = CreateFrame("Frame", nil, container)
            widget.text = widget:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            widget.text:SetAllPoints()
            widget.text:SetJustifyH("LEFT")
        end
        widget.text:SetText(text or "")
        widget.labelText = widget.text -- 兼容
    elseif ele.type == "divider" then
        -- [v4.3.1] 从池获取
        local EXFactory = _G.ExwindFactory
        if EXFactory then
            widget = EXFactory:Acquire("GridDivider", container)
        else
            widget = CreateFrame("Frame", nil, container)
            local l = EXUI:CreateSeparator(widget, pw)
            l:SetPoint("CENTER")
            widget.line = l
        end
        -- 移除错误的 SetBackdrop 调用，该组件应保持完全透明
    elseif ele.type == "button" then
        widget = EXUI:CreateButton(container, pw, ph, ele.label, function()
            if ele.func then ele.func() end
            if ele.key and moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".ButtonClicked",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "picbutton" then
        local nTex, pTex = ele.iconNormal, ele.iconPushed
        if ele.atlas then
            nTex = ele.atlas .. "_Normal"; pTex = ele.atlas .. "_Pushed"
        end
        widget = EXUI:CreatePicButton(container, pw, ph, nTex, pTex, ele.iconHighlight, function()
            if ele.key and moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".ButtonClicked",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "checkbox" then
        widget = EXUI:CreateCheckbox(container, ele.label, curVal == true, function(v)
            Setter(v == true)
        end)
    elseif ele.type == "slider" then
        widget = EXUI:CreateSlider(container, pw, ele.label, ele.min or 0, ele.max or 100, curVal or 0, ele.step or 1,
            nil, Setter)
    elseif ele.type == "input" then
        widget = EXUI:CreateEditBox(container, curVal or "", pw, ph, ele.label, {
            onChanged = nil,
            onEnter = Setter,
            onEditFocusLost = Setter,
            labelPos = ele.labelPos,
            labelSize = ele.labelSize
        })
    elseif ele.type == "color" then
        local subConfig = config
        if contextPath then
            subConfig = GetConfigPath(config, contextPath) or config
        end
        widget = EXUI:CreateColorButton(container, ele.label, subConfig, ele.key, true, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "label" or ele.type == "description" then
        local text = ele.label
        if type(text) == "function" then text = text() end

        -- [v4.3.1] 从池获取
        local EXFactory = _G.ExwindFactory
        if EXFactory then
            widget = EXFactory:Acquire("GridDescription", container)
        else
            widget = CreateFrame("Frame", nil, container)
            local fs = widget:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fs:SetAllPoints()
            fs:SetJustifyH("LEFT")
            widget.text = fs
        end

        widget.text:SetText(text or "")
        if ele.type == "description" then
            widget.text:SetTextColor(1, 1, 1, 1)
        end
        widget.labelText = widget.text -- 兼容

        -- [v4.3.13] 支持 tooltip
        BindTooltip(widget, ele, true)
    elseif ele.type == "dropdown" then
        local rawItems = ele.items
        local itemsList = {}

        if type(rawItems) == "string" and rawItems:sub(1, 5) == "func:" then
            local funcPath = rawItems:match("func:(.+%(%))") or rawItems:sub(6)
            funcPath = funcPath:gsub("%(%)", "")
            local func = _G
            for part in string.gmatch(funcPath, "([^%.]+)") do
                if func then func = func[part] else break end
            end
            local dynamicData = (type(func) == "function" and func()) or "Run_Time_Generated"
            if type(dynamicData) == "table" then
                itemsList = dynamicData
            else
                for s in string.gmatch(dynamicData, "([^,]+)") do table.insert(itemsList, s) end
            end
        else
            if type(rawItems) == "table" then
                itemsList = rawItems
            elseif type(rawItems) == "string" then
                for s in string.gmatch(rawItems, "([^,]+)") do table.insert(itemsList, s) end
            end
        end

        widget = EXUI:CreateDropdown(container, pw, ele.label, itemsList, curVal, Setter)
    elseif ele.type == "multiselect" then
        local itemsList = {}
        -- (Complex items logic omitted for brevity, use existing)
        local rawItems = ele.items
        if type(rawItems) == "string" and rawItems:sub(1, 5) == "func:" then
            local funcPath = rawItems:match("func:(.+%(%))") or rawItems:sub(6)
            funcPath = funcPath:gsub("%(%)", "") -- clean ()
            local func = _G
            for part in string.gmatch(funcPath, "([^%.]+)") do
                if func then func = func[part] else break end
            end
            local dynamicStr = (type(func) == "function" and func()) or "Run_Time_Generated"
            for s in string.gmatch(dynamicStr, "([^,]+)") do table.insert(itemsList, s) end
        else
            if type(rawItems) == "table" then
                itemsList = rawItems
            elseif type(rawItems) == "string" then
                for s in string.gmatch(rawItems, "([^,]+)") do table.insert(itemsList, s) end
            end
        end

        if not curVal then
            SetConfigValue(config, ele, {}, moduleKey, fullPath); curVal = GetConfigPath(config, fullPath)
        end
        -- Multiselect 的回调比较特殊，它不需要传值，而是当内部状态变更时触发 StateUpdate
        widget = EXUI:CreateMultiSelectDropdown(container, pw, ele.label, itemsList, curVal, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "itemconfig" then
        local itemID = tonumber(ele.itemID) or (curVal and curVal.id) or 0
        local widgetSize = ele.labelSize or ele.size or 18
        widget = EXUI:CreateItemConfig(container, pw, ph, itemID, curVal or { enabled = true, quantity = 1 },
            function(newDB, newItemID)
                if newItemID and ele.onDragUpdate then
                    ele.onDragUpdate(newItemID)
                else
                    Setter(newDB)
                end
            end,
            ele.canDelete
        )
        widget.moduleKey = moduleKey
        widget.elementKey = ele.key
        if widget.nameText then
            widget.nameText:SetFontObject("GameFontNormalLarge")
        end
        if widget.editBox then
            widget.editBox:SetFontObject("ChatFontNormal")
        end
    elseif ele.type == "lsm_font" then
        widget = EXUI:CreateLSMDropdown(container, "font", pw, ele.label, curVal, Setter)
    elseif ele.type == "lsm_sound" then
        widget = EXUI:CreateLSMSoundDropdown(container, pw, ele.label, curVal, Setter)
    elseif ele.type == "lsm_texture" then
        widget = EXUI:CreateLSMTextureDropdown(container, "statusbar", pw, ele.label, curVal, Setter)
    elseif ele.type == "lsm_border" then
        widget = EXUI:CreateLSMTextureDropdown(container, "border", pw, ele.label, curVal, Setter)
    elseif ele.type == "lsm_background" then
        widget = EXUI:CreateLSMTextureDropdown(container, "background", pw, ele.label, curVal, Setter)
    elseif ele.type == "fontgroup" then
        if not curVal then
            local defaultFontTable = { font = "Friz Quadrata TT", size = 14, r = 1, g = 1, b = 1, a = 1, outline = "", shadow = false, x = 0, y = 0 }
            Setter(defaultFontTable)
            curVal = defaultFontTable
        end
        widget = EXUI:CreateFontGroup(container, pw, ele.label, curVal, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "glow_settings" then
        local subConfig = config
        if contextPath then
            subConfig = GetConfigPath(config, contextPath) or config
        end
        widget = EXUI:CreateGlowSettings(container, pw, ele.label, subConfig, ele.key, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "icongroup" then
        local subConfig = config
        if contextPath then
            subConfig = GetConfigPath(config, contextPath) or config
        end
        widget = EXUI:CreateIconGroup(container, pw, ele.label, subConfig, ele.key, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "soundgroup" then
        local subConfig = config
        if contextPath then
            subConfig = GetConfigPath(config, contextPath) or config
        end
        widget = EXUI:CreateSoundGroup(container, pw, ele.label, subConfig, ele.key, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "timerBarGroup" or ele.type == "timerbargroup" then
        if not curVal then
            local defaultTimerTable = {
                width = 240,
                height = 24,
                texture = "Clean",
                barColorR = 1,
                barColorG = 0.7,
                barColorB = 0,
                barColorA = 1,
                barBgColorR = 0,
                barBgColorG = 0,
                barBgColorB = 0,
                barBgColorA = 0.5,
                showIcon = true,
                iconSide = "LEFT",
                iconSize = 24,
                iconOffsetX = -5,
                iconOffsetY = 0,
            }
            Setter(defaultTimerTable)
            curVal = defaultTimerTable
        end
        widget = EXUI:CreateTimerBarGroup(container, pw, ele.label, curVal, nil, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "timerBarGroupV2" or ele.type == "timerbargroupv2" then
        if not curVal then
            local defaultTimerTable = {
                width = 240,
                height = 24,
                texture = "Clean",
                barColorR = 1,
                barColorG = 0.7,
                barColorB = 0,
                barColorA = 1,
                barBgColorR = 0,
                barBgColorG = 0,
                barBgColorB = 0,
                barBgColorA = 0.5,
                showIcon = true,
                iconSide = "LEFT",
                iconSize = 24,
                iconOffsetX = -5,
                iconOffsetY = 0,
                showIconBorder = true,
                iconBorderTexture = "Square Full White",
                iconBorderColorR = 0,
                iconBorderColorG = 0,
                iconBorderColorB = 0,
                iconBorderColorA = 1,
                iconBorderSize = 1,
                iconBorderPadding = 0,
            }
            Setter(defaultTimerTable)
            curVal = defaultTimerTable
        end
        widget = EXUI:CreateTimerBarGroupV2(container, pw, ele.label, curVal, nil, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    elseif ele.type == "voicegroup" or ele.type == "encounter_voice_group" then
        local subConfig = config
        if contextPath then
            subConfig = GetConfigPath(config, contextPath) or config
        end
        widget = EXUI:CreateVoiceGroup(container, pw, ele.label, subConfig, ele.key, function()
            if moduleKey then
                ExwindTools:UpdateState(moduleKey .. ".DatabaseChanged",
                    { key = ele.key, fullPath = fullPath, ts = GetTime() })
            end
        end)
    end

    if widget then
        widget:SetParent(container)
        widget:ClearAllPoints()
        widget:SetPoint("TOPLEFT", container, "TOPLEFT", px, py)

        widget:SetSize(pw, ph)

        if ele.type == "checkbox" then
            if widget.EnableMouse then
                widget:EnableMouse(false)
            end
            widget:SetScript("OnEnter", nil)
            widget:SetScript("OnLeave", nil)
            if widget.checkbox then
                if widget.checkbox.EnableMouse then
                    widget.checkbox:EnableMouse(true)
                end
                widget.checkbox:SetScript("OnEnter", nil)
                widget.checkbox:SetScript("OnLeave", nil)
                widget.checkbox:SetScript("PreClick", nil)
                widget.checkbox:SetScript("PostClick", nil)
            end
        end

        widget:Show()
        -- [v4.3.1] 映射到池类型
        local EXFactory = _G.ExwindFactory
        if EXFactory and EXFactory.GridTypeMap then
            widget._gridType = EXFactory.GridTypeMap[ele.type] or ele.type
        else
            widget._gridType = ele.type
        end
        self.Widgets[ele.key] = widget

        -- [v2.0] 反向索引注册
        -- 这里我们不再在 Widgets 表里只存 key，而是存下所有 meta 信息
        -- 核心：编辑器交互（拖拽）需要读取这些信息
        if not self.WidgetMap then self.WidgetMap = {} end
        -- [v4.3 Fix] 移除 parentContainer 引用，避免循环引用导致内存泄漏
        -- 所有 widget 都同一个 container 下，无需单独存储
        self.WidgetMap[widget] = {
            item = ele,     -- 引用 Layout Item
            path = fullPath -- 完整数据路径
        }

        EXUI:UpdateLabelStyle(widget, ele.labelSize, ele.labelPos)

        if self.IsLiveEditing then self:WrapWidgetForEdit(widget, ele.key, container) end
    end

    return widget
end

function Grid:ToggleLiveEdit(container)
    if container then
        local state = GetContainerState(self, container)
        ActivateContainerState(self, container, state)
    end
    self.IsLiveEditing = not self.IsLiveEditing
    self.LiveContainer = container

    if self.IsLiveEditing then
        if container then
            self._activeContainer = container
            self:UpdateMetrics(container:GetWidth(), container)
        end
        self:DrawEditorGrid(container)
        self:DrawRowGuides(container) -- [新增] 绘制行号尺

        for k, w in pairs(self.Widgets) do self:WrapWidgetForEdit(w, k, container) end
        self:ShowToolbar(); self:ShowPalette(); self:CreatePropertyPanel()

        print("|cff00ffff[ExwindGrid]|r 编辑模式已激活。请在左侧点击行号进行管理。")
    else
        if self.GridLines then for _, l in ipairs(self.GridLines) do l:Hide() end end
        if self.RowGuides then for _, b in ipairs(self.RowGuides) do b:Hide() end end -- [新增] 隐藏行号

        -- 恢复容器状态
        if container then
            container:EnableMouse(false)
            -- 清理脚本以防万一
            if container.SetScript then
            end
        end

        for _, w in pairs(self.Widgets) do if w.dragOverlay then w.dragOverlay:Hide() end end
        if self.LiveToolbar then self.LiveToolbar:Hide() end
        if self.Palette then self.Palette:Hide() end
        if self.PropPanel then self.PropPanel:Hide() end
    end
end

function Grid:ShiftRows(startY, delta)
    for _, item in ipairs(self.ActiveLayout) do
        if item.y >= startY then
            item.y = item.y + delta
        end
    end
    -- 修正可能的负数 y
    for _, item in ipairs(self.ActiveLayout) do
        if item.y < 1 then item.y = 1 end
    end
    self:Render(self.LiveContainer, self.ActiveLayout, self.LastConfig, self.ModuleKey)
end

function Grid:ShowRowContextMenu(row, x, y)
    if not self.ContextMenu then
        local cm = CreateFrame("Frame", "ExwindGridContextMenu", UIParent, "BackdropTemplate")
        cm:SetSize(140, 75)
        cm:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        cm:SetBackdropColor(0.05, 0.05, 0.1, 0.95)

        -- 保持高层级，确保在任何 Frame 之上
        cm:SetFrameStrata("TOOLTIP")
        cm:SetFrameLevel(9500)

        local function CreateMenuBtn(text, parent, yOff)
            local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
            btn:SetSize(125, 26)
            btn:SetPoint("TOP", 0, yOff)
            btn:SetText(text)
            return btn
        end

        cm.InsertBtn = CreateMenuBtn("插入行", cm, -10)
        cm.InsertBtn:SetScript("OnClick", function()
            local targetRow = Grid.ContextMenu.targetRow
            Grid:ShiftRows(targetRow, 1)
            Grid.ContextMenu:Hide()
            if Grid.MenuCloser then Grid.MenuCloser:Hide() end
        end)

        cm.DeleteBtn = CreateMenuBtn("删除行", cm, -38)
        cm.DeleteBtn:SetScript("OnClick", function()
            local targetRow = Grid.ContextMenu.targetRow
            Grid:ShiftRows(targetRow + 1, -1)
            Grid.ContextMenu:Hide()
            if Grid.MenuCloser then Grid.MenuCloser:Hide() end
        end)

        self.ContextMenu = cm
    end

    self.ContextMenu.targetRow = row
    self.ContextMenu:ClearAllPoints()
    self.ContextMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    self.ContextMenu:Show()

    if not self.MenuCloser then
        self.MenuCloser = CreateFrame("Button", nil, UIParent)
        self.MenuCloser:SetAllPoints()
        self.MenuCloser:SetFrameStrata("FULLSCREEN_DIALOG")
        self.MenuCloser:SetFrameLevel(9000)
        self.MenuCloser:SetScript("OnClick", function(f)
            f:Hide()
            Grid.ContextMenu:Hide()
        end)
    end
    self.MenuCloser:SetFrameLevel(9000)
    self.ContextMenu:SetFrameLevel(9500)

    self.MenuCloser:Show()
end

function Grid:WrapWidgetForEdit(widget, key, container)
    local drag = widget.dragOverlay or CreateFrame("Button", nil, widget, "BackdropTemplate")
    drag:SetAllPoints(); drag:SetFrameLevel(widget:GetFrameLevel() + 20); drag:EnableMouse(true)
    drag:RegisterForClicks("LeftButtonUp", "RightButtonUp"); drag:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" }); drag
        :SetBackdropColor(0, 0.5, 1, 0.15); drag:Show(); widget.dragOverlay = drag
    if widget.SetMovable then widget:SetMovable(true) end
    drag:SetScript("OnMouseDown",
        function(f, b)
            if b == "LeftButton" then
                widget:StartMoving(); widget.isDragging = true
            end
        end)
    drag:SetScript("OnMouseUp", function(f, b)
        if b == "RightButton" then
            Grid:ShowPropertyPanelFor(key); return
        end
        if widget.isDragging then
            widget:StopMovingOrSizing(); widget.isDragging = false
            local lx, ly = widget:GetLeft() - container:GetLeft(), widget:GetTop() - container:GetTop()
            local nx, ny = Grid:GetGridPos(lx + 2, ly - 2)

            -- [v2.0 Fix] 使用反向索引查找 LayoutItem，不再遍历 ActiveLayout
            -- 这样即便是 TableGroup 深层子元素也能被正确更新位置
            if Grid.WidgetMap and Grid.WidgetMap[widget] then
                local meta = Grid.WidgetMap[widget]
                local item = meta.item

                -- 检测碰撞
                -- 严格来说 IsAreaEmpty 应该检测全局防止重叠
                if Grid:IsAreaEmpty(nx, ny, item.w, item.h, item.key) then -- 这里暂时检测全局
                    item.x, item.y = nx, ny
                end

                -- 刷新
                Grid:Render(container, Grid.ActiveLayout, Grid.LastConfig, Grid.ModuleKey)
            end
        end
    end)

    -- [Resizer] 右下角调整大小手柄
    if not drag.resizer then
        local r = CreateFrame("Button", nil, drag)
        r:SetSize(12, 12)
        r:SetPoint("BOTTOMRIGHT", 0, 0)
        local t = r:CreateTexture(nil, "OVERLAY")
        t:SetAllPoints(); t:SetColorTexture(1, 1, 0, 0.5)
        r:SetScript("OnMouseDown", function()
            drag.isResizing = true
            r:SetScript("OnUpdate", function()
                local mx, my = GetCursorPosition()
                local s = widget:GetEffectiveScale()
                mx, my = mx / s, my / s
                local wx, wy = widget:GetLeft(), widget:GetTop()
                local newW = (mx - wx) + 5
                local newH = (wy - my) + 5

                -- [Fix] 实时调整小部件尺寸，提供视觉反馈
                widget:SetSize(math.max(10, newW), math.max(10, newH))

                -- 可选：显示 Tooltip 提示当前 Grid 网格大小
                local gw = math.max(1, math.floor(newW / Grid.CellSize + 0.5))
                local gh = math.max(1, math.floor(newH / Grid.CellSize + 0.5))
                GameTooltip:SetOwner(r, "ANCHOR_RIGHT")
                GameTooltip:SetText(string.format("W: %d  H: %d", gw, gh))
                GameTooltip:Show()
            end)
        end)
        drag.resizer = r
        r:SetScript("OnMouseUp", function()
            if drag.isResizing then
                drag.isResizing = false
                r:SetScript("OnUpdate", nil)
                GameTooltip:Hide()

                local mx, my = GetCursorPosition()
                local s = widget:GetEffectiveScale()
                mx, my = mx / s, my / s
                local wx, wy = widget:GetLeft(), widget:GetTop()

                -- Calculate new Width/Height in Grid Units
                local gw = math.max(1, math.floor(((mx - wx) + 10) / Grid.CellSize))
                local gh = math.max(1, math.floor(((wy - my) + 10) / Grid.CellSize))

                -- Update using Reverse Index
                if Grid.WidgetMap and Grid.WidgetMap[widget] then
                    local meta = Grid.WidgetMap[widget]
                    local item = meta.item
                    if Grid:IsAreaEmpty(item.x, item.y, gw, gh, item.key) then
                        item.w, item.h = gw, gh
                    end
                    Grid:Render(container, Grid.ActiveLayout, Grid.LastConfig, Grid.ModuleKey)
                end
            end
        end)
    end
    drag.resizer:Show()
end

-- [新增] 绘制左侧行号 Excel 风格
function Grid:DrawRowGuides(container)
    if not self.RowGuides then self.RowGuides = {} end
    -- 先隐藏旧的
    for _, b in ipairs(self.RowGuides) do b:Hide() end

    local rowsToDraw = 100 -- 默认画 100 行，如果内容更多可以扩展

    for i = 1, rowsToDraw do
        local btn = self.RowGuides[i]
        if not btn then
            -- 使用 Button 模板，天生支持 OnClick，无报错风险
            btn = CreateFrame("Button", nil, container, "BackdropTemplate")
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = "Interface\\Buttons\\WHITE8X8",
                edgeSize = 1,
            })
            btn:SetBackdropColor(0.2, 0.2, 0.2, 0.8) -- 深灰色背景
            btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.3)
            btn:RegisterForClicks("RightButtonUp")   -- 只响右键即可，或者左键也没事

            -- 行号文字
            btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            btn.text:SetPoint("CENTER", 0, 0)

            self.RowGuides[i] = btn
        end

        -- 更新以适应当前的 Parent (container)
        btn:SetParent(container)
        btn:SetSize(20, self.CellSize) --稍微变窄一点，减少遮挡
        -- 位置：x = 0 (Canvas左侧内部), y = 对应行的 grid y
        -- Grid y算: -(y-1)*CellSize - 10
        local py = -(i - 1) * self.CellSize - 10
        btn:SetPoint("TOPLEFT", container, "TOPLEFT", 0, py)

        btn.text:SetText(i)

        -- 交互逻辑
        btn:SetScript("OnClick", function(self, button)
            if button == "RightButton" then
                -- 呼出菜单
                local mx, my = GetCursorPosition()
                local s = self:GetEffectiveScale()
                mx, my = mx / s, my / s
                Grid:ShowRowContextMenu(i, mx, my)
            end
        end)

        -- 鼠标悬停变色效果
        btn:SetScript("OnEnter", function(self) self:SetBackdropColor(0, 0.6, 1, 0.8) end)
        btn:SetScript("OnLeave", function(self) self:SetBackdropColor(0.2, 0.2, 0.2, 0.8) end)

        btn:Show()
    end
end

-- [v4.3.2] 统一物理像素线宽计算 (参考暴雪源码)
local function SetupLineThickness(line, pixelWidth)
    local scale = line:GetEffectiveScale()
    if _G.PixelUtil and _G.PixelUtil.GetNearestPixelSize then
        line:SetThickness(_G.PixelUtil.GetNearestPixelSize(pixelWidth, scale, pixelWidth))
    else
        line:SetThickness(pixelWidth)
    end
end

function Grid:DrawEditorGrid(canvas)
    if not self.GridLines then self.GridLines = {} end
    -- 清理旧的（由于 Line 和 Texture 是不同对象，需要彻底重置）
    for _, l in ipairs(self.GridLines) do
        if l.Hide then l:Hide() end
    end

    local idx = 1
    local linePixelWidth = 1.2 -- 稍微加粗，确保可见
    local gridAlpha = 0.15     -- 提高透明度，确保在深色背景下可见

    -- 绘制垂直线
    for i = 0, self.Cols do
        local l = self.GridLines[idx]
        if not l or (l.GetObjectType and l:GetObjectType() ~= "Line") then
            l = canvas:CreateLine(nil, "BACKGROUND")
            self.GridLines[idx] = l
        end

        l:SetColorTexture(1, 1, 1, gridAlpha)
        -- [Fix] 显式传入 canvas 作为锚点目标，防止坐标偏移
        l:SetStartPoint("TOPLEFT", canvas, 10 + i * self.CellSize, 0)
        l:SetEndPoint("BOTTOMLEFT", canvas, 10 + i * self.CellSize, -3000)
        SetupLineThickness(l, linePixelWidth)
        l:Show()
        idx = idx + 1
    end

    -- 绘制水平线
    for i = 0, 150 do
        local l = self.GridLines[idx]
        if not l or (l.GetObjectType and l:GetObjectType() ~= "Line") then
            l = canvas:CreateLine(nil, "BACKGROUND")
            self.GridLines[idx] = l
        end

        l:SetColorTexture(1, 1, 1, gridAlpha)
        -- [Fix] 显式传入 canvas 作为锚点目标
        l:SetStartPoint("TOPLEFT", canvas, 0, -10 - i * self.CellSize)
        l:SetEndPoint("TOPRIGHT", canvas, 0, -10 - i * self.CellSize)
        SetupLineThickness(l, linePixelWidth)
        l:Show()
        idx = idx + 1
    end
end

function Grid:ShowToolbar()
    if self.LiveToolbar then
        self.LiveToolbar:Show(); return
    end
    local tb = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    tb:SetSize(500, 44)
    tb:SetPoint("TOP", 0, -10)
    tb:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
    tb:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    tb:SetFrameStrata("HIGH")

    local b1 = CreateFrame("Button", nil, tb, "UIPanelButtonTemplate")
    b1:SetSize(100, 28); b1:SetPoint("LEFT", 10, 0); b1:SetText("导出布局")
    b1:SetScript("OnClick", function() Grid:ExportLayoutOnly() end)

    local b1b = CreateFrame("Button", nil, tb, "UIPanelButtonTemplate")
    b1b:SetSize(100, 28); b1b:SetPoint("LEFT", 115, 0); b1b:SetText("导出默认值")
    b1b:SetScript("OnClick", function() Grid:ExportDefaultsOnly() end)

    local b2 = CreateFrame("Button", nil, tb, "UIPanelButtonTemplate")
    b2:SetSize(100, 28); b2:SetPoint("LEFT", 220, 0); b2:SetText("保存退出")
    b2:SetScript("OnClick", function() Grid:ToggleLiveEdit(Grid.LiveContainer) end)

    local b3 = CreateFrame("Button", nil, tb, "UIPanelButtonTemplate")
    b3:SetSize(100, 28); b3:SetPoint("LEFT", 325, 0); b3:SetText("组件库")
    b3:SetScript("OnClick",
        function() if Grid.Palette:IsShown() then Grid.Palette:Hide() else Grid.Palette:Show() end end)

    self.LiveToolbar = tb
end

function Grid:ShowPalette()
    if self.Palette then
        self.Palette:Show(); return
    end
    local p = CreateFrame("Frame", nil, UIParent, "BackdropTemplate"); p:SetSize(160, 500); p:SetPoint("RIGHT", -20, 0); p
        :SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 }); p
        :SetBackdropColor(0.1, 0.1, 0.1, 0.95); p:SetFrameStrata("HIGH"); p:EnableMouse(true); p:SetMovable(true); p
        :RegisterForDrag("LeftButton"); p:SetScript("OnDragStart", p.StartMoving); p:SetScript("OnDragStop",
        p.StopMovingOrSizing)
    local types = {
        { t = "checkbox", n = "勾选框" }, { t = "button", n = "按钮" }, { t = "slider", n = "滑动条" }, { t = "input", n = "输入框" },
        { t = "header", n = "大标题" }, { t = "subheader", n = "中标题" }, { t = "divider", n = "分隔线" },
        { t = "label", n = "文本" }, { t = "description", n = "描述" }, { t = "color", n = "颜色" },
        { t = "dropdown", n = "单选下拉" }, { t = "multiselect", n = "多选下拉" },
        { t = "lsm_font", n = "LSM字体" }, { t = "lsm_sound", n = "LSM音效" },
        { t = "lsm_texture", n = "LSM材质" }, { t = "lsm_border", n = "LSM边框" }, { t = "lsm_background", n = "LSM背景" },
        { t = "fontgroup", n = "字体组" }
    }
    local y = -15
    for _, i in ipairs(types) do
        local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate"); b:SetSize(140, 24); b:SetPoint("TOP", 0, y); b
            :SetText(i.n); b:SetScript("OnClick", function() Grid:AddNewWidget(i.t, Grid.LiveContainer) end)
        y = y - 28
    end
    self.Palette = p
end

function Grid:AddNewWidget(t, c)
    local k = t .. "_" .. math.random(1000, 9999); local w, h = 12, 2
    if t == "checkbox" then
        w, h = 2, 2
    elseif t:find("header") or t == "divider" then
        w, h = 47, 1
    elseif t == "fontgroup" then
        w, h =
            47, 10
    end
    local e = { key = k, type = t, x = 1, y = 1, w = w, h = h, label = "新组件" }
    if t == "slider" then
        e.min = 0; e.max = 100
    elseif t:find("dropdown") or t == "multiselect" then
        e.items = "A,B,C"
    end
    for i = 1, 200 do
        if Grid:IsAreaEmpty(1, i, w, h) then
            e.y = i; table.insert(Grid.ActiveLayout, e); break
        end
    end
    Grid:Render(c, Grid.ActiveLayout, Grid.LastConfig, Grid.ModuleKey)
end

function Grid:CreatePropertyPanel()
    if self.PropPanel then return end
    local p = CreateFrame("Frame", nil, UIParent, "BackdropTemplate"); p:SetSize(320, 680); p:SetPoint("LEFT", 20, 0); p
        :SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 }); p
        :SetBackdropColor(0.05, 0.05, 0.1, 0.98); p:SetFrameStrata("DIALOG"); p:EnableMouse(true); p:SetMovable(true); p
        :RegisterForDrag("LeftButton"); p:SetScript("OnDragStart", p.StartMoving); p:SetScript("OnDragStop",
        p.StopMovingOrSizing)
    local function CI(l, y)
        local f = CreateFrame("Frame", nil, p); f:SetSize(280, 50); f:SetPoint("TOPLEFT", 20, y)
        local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); fs:SetPoint("TOPLEFT", 0, 0); fs
            :SetText(l)
        local eb = EXUI:CreateEditBox(f, "", 280, 26); eb:SetPoint("TOPLEFT", 0, -18); f.eb = eb; f.fs = fs; return f
    end

    -- [UI Polish] 压缩纵向间距 (从 60px -> 50px)，让底部内容上移
    p.k = CI("唯一 Key (Grid ID):", -40)
    p.sk = CI("DB Key (setKey, 可选):", -90)
    p.l = CI("显示标签:", -140)
    p.w = CI("宽度 (1-50):", -190); p.h = CI("高度:", -240)
    p.i = CI("选项列表 (逗号分隔):", -290)
    p.min = CI("Slider 最小值:", -340); p.max = CI("Slider 最大值:", -390)

    -- [New] 标签位置与大小 (现在整体上移了约 100px)
    p.lpos = CI("Label Pos (left / top...):", -440)
    p.lsize = CI("Label Size (10-30):", -490)

    -- [Core] 切换为实时交互模式：隐藏输入框
    p.lpos.eb:Hide(); p.lsize.eb:Hide()

    -- [New] 标签大小滑块 (实时生效)
    p.lsize.slider = EXUI:CreateSlider(p.lsize, 260, nil, 10, 32, 16, 1, nil, function(v)
        local e = Grid.Cur
        if e then
            e.labelSize = v
            p.lsize.fs:SetText("Label Size: " .. v)
            if Grid.Widgets[e.key] then
                -- [Real-time] 立即更新样式
                EXUI:UpdateLabelStyle(Grid.Widgets[e.key], e.labelSize, e.labelPos)
            end
        end
    end)
    p.lsize.slider:SetPoint("TOPLEFT", 0, -20) -- 稍微靠左对齐

    -- 标签位置切换按钮 (实时生效)
    local function CreatePosBtn(txt, val, x)
        local b = CreateFrame("Button", nil, p.lpos, "UIPanelButtonTemplate")
        b:SetSize(60, 22)
        -- 紧贴 label 下方布局
        b:SetPoint("TOPLEFT", x, -18)
        b:SetText(txt)
        b:SetScript("OnClick", function()
            local e = Grid.Cur
            if e then
                e.labelPos = val
                -- [Real-time] 立即更新样式
                if Grid.Widgets[e.key] then
                    EXUI:UpdateLabelStyle(Grid.Widgets[e.key], e.labelSize, e.labelPos)
                end
            end
        end)
        return b
    end
    p.lpos.b1 = CreatePosBtn("Left", "left", 0)
    p.lpos.b2 = CreatePosBtn("Top", "top", 70)
    p.lpos.b3 = CreatePosBtn("Right", "right", 140)
    p.lpos.b4 = CreatePosBtn("Default", nil, 210); p.lpos.b4:SetWidth(60)

    local s = CreateFrame("Button", nil, p, "UIPanelButtonTemplate"); s:SetSize(130, 32); s:SetPoint("BOTTOMLEFT", 20, 20); s
        :SetText("保存设置"); s:SetScript("OnClick", function()
        local e = Grid.Cur; if e then
            e.key = p.k.eb:GetText();
            -- [New] 保存 setKey
            local sk = p.sk.eb:GetText()
            e.setKey = (sk ~= "" and sk) or nil

            -- [修复] 将 UI 中的转义管道还原为普通管道存储
            e.label = p.l.eb:GetText():gsub("||", "|");
            e.w = tonumber(p.w.eb:GetText()) or e.w;
            e.h = tonumber(p.h.eb:GetText()) or e.h;
            if e.type == "slider" then
                e.min = tonumber(p.min.eb:GetText());
                e.max = tonumber(p.max.eb:GetText())
                -- [Revert] 移除 Step 保存逻辑
            end
            if p.i:IsShown() then
                local rawItems = p.i.eb:GetText():gsub("||", "|")
                if type(e.items) == "table" then
                    -- 表型下拉项用于结构化选项；属性面板当前仅做展示，不在这里降级成字符串
                else
                    e.items = rawItems
                end
            end

            -- [Core] Label 属性已由实时控件更新到 'e' 中，此处**不要**从隐藏的 EditBox 覆盖它们
        end
        p:Hide(); Grid:Render(Grid.LiveContainer, Grid.ActiveLayout, Grid.LastConfig, Grid.ModuleKey)
    end)


    local d = CreateFrame("Button", nil, p, "UIPanelButtonTemplate"); d:SetSize(130, 32); d:SetPoint("BOTTOMRIGHT", -20,
        20); d:SetText("|cffff0000删除组件|r"); d:SetScript("OnClick", function()
        for i, e in ipairs(Grid.ActiveLayout) do
            if e.key == Grid.Cur.key then
                table.remove(Grid.ActiveLayout, i); break
            end
        end
        p:Hide(); Grid:Render(Grid.LiveContainer, Grid.ActiveLayout, Grid.LastConfig, Grid.ModuleKey)
    end)
    self.PropPanel = p
end

function Grid:ShowPropertyPanelFor(key)
    if not self.IsLiveEditing then return end

    -- [v4.3.1] 递归查找，支持 TableGroup 内部组件
    local item = FindLayoutItem(self.ActiveLayout, key)
    if not item then
        print("[ExwindGrid] 错误: 未找到组件配置: " .. key); return
    end

    local panel = self.PropPanel
    if not panel then
        self:CreatePropertyPanel(); panel = self.PropPanel
    end
    Grid.Cur = item

    -- [修复] 使用双管道转义，防止 UI 引擎在 EditBox 内直接渲染图标代码
    panel.k.eb:SetText(item.key or "")
    panel.sk.eb:SetText(item.setKey or item.subKey or "")
    panel.l.eb:SetText((item.label or ""):gsub("|", "||"))
    panel.w.eb:SetText(tostring(item.w or 10))
    panel.h.eb:SetText(tostring(item.h or 2))

    panel.i:Hide(); panel.min:Hide(); panel.max:Hide()
    if item.type:find("dropdown") or item.type == "multiselect" then
        panel.i:Show()
        local itemsText = ""
        if type(item.items) == "string" then
            itemsText = item.items
        elseif type(item.items) == "table" then
            local parts = {}
            for _, entry in ipairs(item.items) do
                if type(entry) == "table" then
                    local label = tostring(entry[1] or "")
                    local value = tostring(entry[2] or entry[1] or "")
                    if value ~= "" and value ~= label then
                        parts[#parts + 1] = label .. "=" .. value
                    else
                        parts[#parts + 1] = label
                    end
                else
                    parts[#parts + 1] = tostring(entry)
                end
            end
            itemsText = table.concat(parts, ", ")
        end
        panel.i.eb:SetText(itemsText:gsub("|", "||"))
    end
    if item.type == "slider" then
        panel.min:Show(); panel.max:Show()
        panel.min.eb:SetText(tostring(item.min or 0))
        panel.max.eb:SetText(tostring(item.max or 100))
    end

    -- [New] 回填实时控件的状态
    if panel.lsize and panel.lsize.slider then
        panel.lsize.slider:SetValue(item.labelSize or 16)
        panel.lsize.fs:SetText("Label Size: " .. (item.labelSize or 16))
    end
    -- LabelPos 按钮不需要回填状态，点击即生效

    panel:Raise()
    panel:Show()
end

function Grid:ExportLayout()
    local layoutStr = "local layout = {\n"
    local defaults = {}

    local replacements = self.ExportReplacements or {}

    -- Helper: 格式化值
    local function formatVal(val, keyName)
        if type(val) == "string" and replacements[val] then
            return ", " .. keyName .. " = " .. replacements[val]
        else
            return ", " .. keyName .. " = " .. string.format("%q", val)
        end
    end

    -- 递归导出核心
    local function recursiveExport(items, indent, contextPath)
        local str = ""
        local pad = string.rep("    ", indent)

        for _, e in ipairs(items) do
            -- 1. 确定当前组件的数据上下文
            local itemScope = contextPath
            if e.parentKey then
                itemScope = itemScope and (itemScope .. "." .. e.parentKey) or e.parentKey
            end
            local fullPath = itemScope and (itemScope .. "." .. e.key) or tostring(e.key)

            -- 2. 导出属性字符串构造
            local ex = ""
            if e.min then ex = ex .. ", min = " .. e.min end; if e.max then ex = ex .. ", max = " .. e.max end

            if e.items and e.items ~= "" then
                if replacements[e.items] then
                    ex = ex .. ", items = " .. replacements[e.items]
                elseif type(e.items) == "string" and e.items:sub(1, 5) == "func:" then
                    ex = ex .. ", items = " .. string.format("%q", e.items)
                elseif type(e.items) == "table" then
                    local function serializeTable(t)
                        local s = "{"
                        for k, v in ipairs(t) do
                            if type(v) == "table" then
                                s = s .. serializeTable(v)
                            else
                                s = s .. string.format("%q", v)
                            end
                            if k < #t then s = s .. ", " end
                        end
                        return s .. "}"
                    end
                    ex = ex .. ", items = " .. serializeTable(e.items)
                else
                    ex = ex .. ", items = " .. string.format("%q", e.items)
                end
            end

            if e.parentKey then ex = ex .. formatVal(e.parentKey, "parentKey") end
            if e.setKey then ex = ex .. formatVal(e.setKey, "setKey") end
            if e.subKey then ex = ex .. formatVal(e.subKey, "subKey") end
            if e.labelPos then ex = ex .. ", labelPos = " .. string.format("%q", e.labelPos) end
            if e.labelSize and e.labelSize ~= 16 then ex = ex .. ", labelSize = " .. e.labelSize end

            local labelStr = ""
            local exportLabel = e.baseLabel or e.label
            if type(exportLabel) == "string" then
                labelStr = string.format(", label = %q", exportLabel)
            elseif type(exportLabel) == "number" then
                labelStr = string.format(", label = %q", tostring(exportLabel))
            else
                labelStr = ", label = \"--[[ Function ]]\""
            end

            local keyExport = (type(e.key) == "number") and tostring(e.key) or string.format("%q", tostring(e.key))

            -- 3. 收集默认值（核心更新：全量收集与颜色处理）
            local function AddToDefaults(path, val)
                if val == nil then return end
                local pathKeys = { strsplit(".", tostring(path)) }
                local ptr = defaults
                for i = 1, #pathKeys - 1 do
                    local k = tonumber(pathKeys[i]) or pathKeys[i]
                    if not ptr[k] then ptr[k] = {} end
                    ptr = ptr[k]
                end
                local lastK = tonumber(pathKeys[#pathKeys]) or pathKeys[#pathKeys]
                ptr[lastK] = val
            end

            local keyStr = tostring(e.key)
            if keyStr and not keyStr:find("^header") and not keyStr:find("^divider") and e.type ~= "TableGroup" then
                -- 颜色组件特殊处理：导出后缀格式 (xxxR, xxxG, xxxB, xxxA)
                if e.type == "color" then
                    local colorConfig = contextPath and GetConfigPath(self.LastConfig, contextPath) or self.LastConfig
                    if colorConfig then
                        local colorKey = tostring(e.key)
                        local basePath = contextPath and (contextPath .. ".") or ""
                        AddToDefaults(basePath .. colorKey .. "R", colorConfig[colorKey .. "R"] or 1)
                        AddToDefaults(basePath .. colorKey .. "G", colorConfig[colorKey .. "G"] or 1)
                        AddToDefaults(basePath .. colorKey .. "B", colorConfig[colorKey .. "B"] or 1)
                        AddToDefaults(basePath .. colorKey .. "A", colorConfig[colorKey .. "A"] or 1)
                    end
                else
                    AddToDefaults(e.setKey or fullPath,
                        (e.setKey and self.LastConfig[e.setKey]) or GetConfigPath(self.LastConfig, fullPath))
                end
            end

            -- 4. 处理递归与动态列表补全
            if e.type == "TableGroup" then
                if e.children and #e.children > 0 then
                    -- 动态索引探测：如果当前是 rows.1，则扫描 rows.2, 3... 补全 defaults 表
                    local prefix, idx = tostring(e.parentKey):match("^(.-)%.(%d+)$")
                    if prefix and idx then
                        local collection = GetConfigPath(self.LastConfig, prefix)
                        if type(collection) == "table" then
                            for i in pairs(collection) do recursiveExport(e.children, indent + 1, prefix .. "." .. i) end
                        end
                    end
                    str = str ..
                        string.format(
                            "%s{ key = %s, type = %q, x = %d, y = %d, w = %d, h = %d%s%s, children = {\n%s%s} },\n",
                            pad, keyExport, e.type, e.x, e.y, e.w, e.h, labelStr, ex,
                            recursiveExport(e.children, indent + 1, itemScope), pad)
                end
            else
                str = str ..
                    string.format("%s{ key = %s, type = %q, x = %d, y = %d, w = %d, h = %d%s%s },\n", pad, keyExport,
                        e.type,
                        e.x, e.y, e.w, e.h, labelStr, ex)
            end
        end
        return str
    end

    layoutStr = layoutStr .. recursiveExport(self.ActiveLayout, 1, nil)
    layoutStr = layoutStr .. "}\n"

    -- 自动补充顶层必要字段（如 pos）
    if self.LastConfig and self.LastConfig.pos and not defaults.pos then
        defaults.pos = self.LastConfig.pos
    end

    return layoutStr, defaults
end

-- 序列化表为 Lua 代码字符串
local function serializeTable(t, indent)
    local s = "{\n"

    -- 检测是否是连续数组
    local isArray = true
    local maxIndex = 0
    for k, _ in pairs(t) do
        if type(k) == "number" and k > 0 and math.floor(k) == k then
            if k > maxIndex then maxIndex = k end
        else
            isArray = false
            break
        end
    end
    if isArray and maxIndex > 0 then
        for i = 1, maxIndex do
            if t[i] == nil then
                isArray = false; break
            end
        end
    end

    if isArray and maxIndex > 0 then
        -- 连续数组：使用隐式索引
        for i = 1, maxIndex do
            local v = t[i]
            s = s .. string.rep("    ", indent)
            if type(v) == "table" then
                s = s .. serializeTable(v, indent + 1) .. ",\n"
            elseif type(v) == "string" then
                s = s .. string.format("%q", v) .. ",\n"
            else
                s = s .. tostring(v) .. ",\n"
            end
        end
    else
        -- 非连续表：使用显式键
        local keys = {}
        for k in pairs(t) do table.insert(keys, k) end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)

        for _, k in ipairs(keys) do
            local v = t[k]
            local keyStr
            if type(k) == "number" then
                keyStr = "[" .. k .. "]"
            elseif type(k) == "string" and k:match("^[%a_][%w_]*$") then
                keyStr = k
            else
                keyStr = "[" .. string.format("%q", k) .. "]"
            end
            s = s .. string.rep("    ", indent) .. keyStr .. " = "
            if type(v) == "table" then
                s = s .. serializeTable(v, indent + 1) .. ",\n"
            elseif type(v) == "string" then
                s = s .. string.format("%q", v) .. ",\n"
            else
                s = s .. tostring(v) .. ",\n"
            end
        end
    end
    return s .. string.rep("    ", indent - 1) .. "}"
end

-- 仅导出布局
function Grid:ExportLayoutOnly()
    local layoutStr, _ = self:ExportLayout()

    StaticPopupDialogs["EX_EXPORT_LAYOUT"] = {
        text = "复制布局代码 (粘贴到模块结尾):",
        button1 = "好的",
        hasEditBox = 1,
        OnShow = function(s)
            s.EditBox:SetText(layoutStr:gsub("|", "||"));
            s.EditBox:HighlightText()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
    StaticPopup_Show("EX_EXPORT_LAYOUT")
end

-- 仅导出默认值
function Grid:ExportDefaultsOnly()
    local _, defaults = self:ExportLayout()

    local defaultsStr = "local EX_DEFAULTS = " .. serializeTable(defaults, 1)

    StaticPopupDialogs["EX_EXPORT_DEFAULTS"] = {
        text = "复制默认值代码 (粘贴到模块开头):",
        button1 = "好的",
        hasEditBox = 1,
        OnShow = function(s)
            s.EditBox:SetText(defaultsStr:gsub("|", "||"));
            s.EditBox:HighlightText()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true
    }
    StaticPopup_Show("EX_EXPORT_DEFAULTS")
end

-- [v4.3.4 Fix] Revert to simple lines
function Grid:DrawEditorGrid(container)
    if not self.GridLines then self.GridLines = {} end
    -- Show/Create Lines
    local w, h = container:GetSize()
    local step = self.CellSize or 20

    local lineIdx = 1

    -- Horizontal
    for y = 0, h, step do
        local line = self.GridLines[lineIdx]
        if not line then
            line = container:CreateLine()
            line:SetThickness(1)
            line:SetColorTexture(1, 1, 1, 0.1)
            table.insert(self.GridLines, line)
        end
        line:Show()
        line:SetStartPoint("TOPLEFT", 0, -y)
        line:SetEndPoint("TOPRIGHT", 0, -y)
        lineIdx = lineIdx + 1
    end

    -- Vertical
    for x = 0, w, step do
        local line = self.GridLines[lineIdx]
        if not line then
            line = container:CreateLine()
            line:SetThickness(1)
            line:SetColorTexture(1, 1, 1, 0.1)
            table.insert(self.GridLines, line)
        end
        line:Show()
        line:SetStartPoint("TOPLEFT", x, 0)
        line:SetEndPoint("BOTTOMLEFT", x, 0)
        lineIdx = lineIdx + 1
    end

    -- Hide unused
    for i = lineIdx, #self.GridLines do self.GridLines[i]:Hide() end
end

-- [v4.3.4 Fix] Revert to simple lines
function Grid:DrawEditorGrid(container)
    if not self.GridLines then self.GridLines = {} end
    -- Show/Create Lines
    local w, h = container:GetSize()
    local step = self.CellSize or 20

    local lineIdx = 1

    -- Horizontal
    for y = 0, h, step do
        local line = self.GridLines[lineIdx]
        if not line then
            line = container:CreateLine()
            line:SetThickness(1)
            line:SetColorTexture(1, 1, 1, 0.1)
            table.insert(self.GridLines, line)
        end
        line:Show()
        line:SetStartPoint("TOPLEFT", 0, -y)
        line:SetEndPoint("TOPRIGHT", 0, -y)
        lineIdx = lineIdx + 1
    end

    -- Vertical
    for x = 0, w, step do
        local line = self.GridLines[lineIdx]
        if not line then
            line = container:CreateLine()
            line:SetThickness(1)
            line:SetColorTexture(1, 1, 1, 0.1)
            table.insert(self.GridLines, line)
        end
        line:Show()
        line:SetStartPoint("TOPLEFT", x, 0)
        line:SetEndPoint("BOTTOMLEFT", x, 0)
        lineIdx = lineIdx + 1
    end

    -- Hide unused
    for i = lineIdx, #self.GridLines do self.GridLines[i]:Hide() end
end

function ExwindTools:ToggleDevMode()
    if not self.UI or not self.UI.ActivePageFrame then
        return
    end
    self.Grid:ToggleLiveEdit(self.UI.ActivePageFrame)
end
