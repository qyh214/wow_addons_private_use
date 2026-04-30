-- =========================================================
-- ExwindGUI.lua
-- 封装 LibSharedMedia (LSM) 的原生 Wow 工具组件
-- =========================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end

-- 确保 EXUI 命名空间存在（可能在 ExwindToolsUI.lua 之前加载）
local EXUI = ExwindTools.UI or {}
ExwindTools.UI = EXUI
_G.ExwindToolsUI = EXUI

local LSM = LibStub("LibSharedMedia-3.0")
local L = ExwindTools.L

-- [Core] 严格遵照指令：只许使用游戏默认字体路径，禁止任何硬编码引用
local defaultFontPath, defaultFontSize, defaultFontFlags = _G.GameFontHighlight:GetFont()


-- [Style] 统一的 Tooltip 风格背景定义
EXUI.TooltipBackdrop = {
    bgFile = "Interface\\Buttons\\WHITE8X8", -- 使用纯色背景以便通过代码控制颜色
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 20,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

-- [Helper] 防止 UI 污染的统一清理函数
local function CleanDropdownButton(button)
    if button.playBtn then button.playBtn:Hide() end
    if button.lsmFontPreview then button.lsmFontPreview:Hide() end
    if button.fontString then
        button.fontString:SetAlpha(1)
    end
end

-- =========================================================
-- [Core] 统一标签样式更新 (ExwindGrid 编辑器专用)
-- =========================================================
function EXUI:UpdateLabelStyle(widget, size, pos)
    if not widget then return end

    -- 1. 寻找 Label 对象 (不同组件存储位置不同，统统找出来)
    local label = widget.labelText or widget.label or widget.Title
    if not label or not label.SetFont then return end

    -- 保存引用以便后续再次访问
    widget._exLabel = label

    -- 2. [Fix v4.3.4] 恢复使用 SetFont 配合 CJK 探测后的 MAIN_FONT
    local fontSize = tonumber(size) or 16
    local fontPath = ExwindTools.MAIN_FONT

    label:SetFont(fontPath, fontSize, "OUTLINE")

    -- [v4.3.1] 级联更新子物料
    if widget.SetFont then
        if widget:GetObjectType() == "EditBox" then
            widget:SetFontObject("ChatFontNormal") -- 输入框专用
        else
            widget:SetFont(fontPath, fontSize, "OUTLINE")
        end
    end
    if widget.nameText then -- itemconfig 特供
        widget.nameText:SetFontObject("GameFontNormalLarge")
    end

    -- [Fix] 判定逻辑统一，支持池化后的名称 (GridCheckbox / GridSlider 等)
    local gType = widget._gridType and widget._gridType:lower() or ""

    -- 3. 特殊组件位置锁定 (对于 FontGroup/Header 等，只改字体，不移动位置)
    if gType:find("fontgroup") or gType:find("header") or gType:find("soundgroup")
        or gType:find("description") then
        return
    end

    -- 4. 判定 Checkbox/Slider 特殊逻辑

    -- 对于 Checkbox，由于它是 [Box] [Label] 结构，特殊处理
    if gType == "checkbox" or gType == "gridcheckbox" then
        label:ClearAllPoints()
        if pos == "left" then
            label:SetPoint("RIGHT", widget.checkbox, "LEFT", -5, 0)
            label:SetJustifyH("RIGHT")
        elseif pos == "top" then
            label:SetPoint("BOTTOMLEFT", widget.checkbox, "TOPLEFT", 0, 2)
            label:SetJustifyH("LEFT")
        else -- right (Default)
            label:SetPoint("LEFT", widget.checkbox, "RIGHT", 6, 0)
            label:SetJustifyH("LEFT")
        end
        return
    end

    -- [Fix] 对于 Slider，必需保持 Title 不覆盖 ValueText 的约束
    if gType == "slider" or gType == "gridslider" then
        label:ClearAllPoints()
        if pos == "left" then
            label:SetPoint("RIGHT", widget, "LEFT", -5, 0)
            label:SetJustifyH("RIGHT")
        else -- top (Default)
            label:SetPoint("BOTTOMLEFT", widget, "TOPLEFT", 0, 1)
            if widget.ValueText then
                label:SetPoint("RIGHT", widget.ValueText, "LEFT", -5, 0)
            end
            label:SetJustifyH("LEFT")
            label:SetWordWrap(false)
        end
        return
    end

    -- [Fix] 对于特定的组组件，不碰位置
    if gType == "fontgroup" or gType == "gridfontgroup" or gType == "header" or gType == "gridheader"
        or gType == "soundgroup" or gType == "subheader" or gType == "gridsubheader" or gType == "icongroup" or gType == "glow_settings"
        or gType == "description" or gType == "griddescription" then
        return
    end

    -- 通用处理 (Input, Dropdown, Button 等)
    if not pos then pos = "top" end
    label:ClearAllPoints()

    if pos == "left" then
        label:SetPoint("RIGHT", widget, "LEFT", -5, 0)
        label:SetJustifyH("RIGHT")
    elseif pos == "right" then
        label:SetPoint("LEFT", widget, "RIGHT", 5, 0)
        label:SetJustifyH("LEFT")
    else -- top
        label:SetPoint("BOTTOMLEFT", widget, "TOPLEFT", 0, 3)
        label:SetJustifyH("LEFT")
    end
end

-- =========================================================
-- 0. 通用单选下拉菜单 (Generic Dropdown) - [v4.3.1] 支持池化
-- items 格式: { "选项1", "选项2" } 或 { {"显示文字", "实际值"}, ... }
-- =========================================================
function EXUI:CreateDropdown(parent, width, label, items, currentValue, onSelect)
    local EXFactory = _G.ExwindFactory
    local dropdown

    if EXFactory then
        -- 从池获取
        dropdown = EXFactory:Acquire("GridDropdown", parent)
    else
        -- 兜底：传统创建
        dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dropdown.labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        dropdown.labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
        if dropdown.Text then
            dropdown.Text:ClearAllPoints()
            dropdown.Text:SetPoint("LEFT", 8, 0)
            dropdown.Text:SetPoint("RIGHT", dropdown.Arrow, "LEFT", -2, 0)
        end
        if dropdown.Arrow then
            dropdown.Arrow:ClearAllPoints()
            dropdown.Arrow:SetPoint("RIGHT", -2, 0)
        end
    end

    dropdown:SetWidth(width)
    if dropdown.EnableMouse then
        dropdown:EnableMouse(true)
    end
    dropdown.labelText:SetText(label or "")

    -- [v4.3.2 Fix] 将状态挂载到 Self，避免 SetupMenu 闭包捕获导致内存泄漏
    dropdown._currentValue = currentValue
    dropdown._onSelect = onSelect
    dropdown._items = items

    -- [Fix] 递归查找选定值的显示文本
    local function GetEntry(val, list)
        for _, item in ipairs(list or items) do
            if type(item) == "table" then
                if item.isMenu then
                    local found, v = GetEntry(val, item.menu)
                    if found ~= L["请选择..."] then return found, v end
                elseif item[2] == val or (tonumber(item[2]) and tonumber(item[2]) == tonumber(val)) then
                    return item[1], item[2]
                end
            else
                if item == val or (tonumber(item) and tonumber(item) == tonumber(val)) then return item, item end
            end
        end
        return L["请选择..."], nil
    end

    local initialText = GetEntry(currentValue)
    dropdown:SetText(initialText)

    -- [Fix] 使用 Self 引用构建菜单
    dropdown:SetupMenu(function(self, rootDescription)
        rootDescription:SetScrollMode(400)

        local function BuildMenu(rootDesc, list)
            if not list then return end -- [Fix] 防止复用初始化间隙导致的 nil 报错
            for _, item in ipairs(list) do
                if type(item) == "table" and item.isMenu then
                    local subMenu = rootDesc:CreateButton(item.text, function() end)
                    BuildMenu(subMenu, item.menu)
                else
                    local text, value
                    if type(item) == "table" then
                        text, value = item[1], item[2]
                    else
                        text, value = item, item
                    end

                    rootDesc:CreateRadio(text,
                        function()
                            -- [Fix] 必须在闭包内动态获取 self._currentValue，否则状态会死锁
                            return (self._currentValue == value) or (tostring(self._currentValue) == tostring(value))
                        end,
                        function()
                            self._currentValue = value
                            self:SetText(text)
                            if self._onSelect then self._onSelect(value, text) end
                        end
                    )
                end
            end
        end

        BuildMenu(rootDescription, self._items)
    end)

    return dropdown
end

-- =========================================================
-- 1. 字体下拉菜单 (LSM Font) - [v4.3.1] 支持池化
-- =========================================================
function EXUI:CreateLSMDropdown(parent, mediaType, width, label, currentValue, onSelect)
    -- [Fix] 兼容性处理
    if type(currentValue) == "function" and onSelect == nil then
        onSelect = currentValue
        currentValue = nil
    end

    local EXFactory = _G.ExwindFactory
    local dropdown

    if EXFactory then
        -- 复用 GridLSMDropdown 池
        dropdown = EXFactory:Acquire("GridLSMDropdown", parent)
    else
        -- 兜底
        dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dropdown.labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        dropdown.labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
    end

    dropdown:SetWidth(width)
    if dropdown.EnableMouse then
        dropdown:EnableMouse(true)
    end
    dropdown.labelText:SetText(label or "")

    -- [v4.3.2 Fix] 将状态挂载到 Self
    dropdown._selectedValue = currentValue or LSM:GetDefault(mediaType)
    dropdown._onSelect = onSelect
    dropdown._mediaType = mediaType

    dropdown:SetText(dropdown._selectedValue)

    dropdown:SetupMenu(function(self, rootDescription)
        if not self._mediaType then return end -- [Fix] 防止复用时 nil 报错
        rootDescription:CreateTitle(L["选择"] .. (self._mediaType == "font" and L["字体"] or self._mediaType))
        if rootDescription.SetScrollMode then rootDescription:SetScrollMode(400) end

        local list = LSM:HashTable(self._mediaType)
        local sortedKeys = LSM:List(self._mediaType)

        for _, key in ipairs(sortedKeys) do
            local path = list[key]
            -- 使用 self 属性而非闭包捕获
            local btn = rootDescription:CreateRadio(key, function() return self._selectedValue == key end, function()
                self._selectedValue = key
                self:SetText(key)
                if self._onSelect then self._onSelect(key, path) end
            end)

            if self._mediaType == "font" then
                btn:AddInitializer(function(button, description, menu)
                    CleanDropdownButton(button)

                    if not button.lsmFontPreview then
                        button.lsmFontPreview = CreateFrame("Frame", nil, button)
                        button.lsmFontPreview:SetAllPoints()

                        -- [Fix] 这里的 fs 需要创建并保存到 button.lsmFontPreview.fs
                        local fs = button.lsmFontPreview:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        fs:SetPoint("LEFT", 20, 0)
                        fs:SetPoint("RIGHT", -10, 0)
                        fs:SetJustifyH("LEFT")
                        button.lsmFontPreview.fs = fs

                        button:HookScript("OnHide", function() CleanDropdownButton(button) end)
                    end

                    button.lsmFontPreview:Show()
                    -- 隐藏原生文字
                    if button.fontString then button.fontString:SetAlpha(0) end

                    if path then
                        pcall(function()
                            button.lsmFontPreview.fs:SetFont(path, 14, "")
                            button.lsmFontPreview.fs:SetText(key)
                        end)
                    end
                end)
            end
        end
    end)
    return dropdown
end

-- =========================================================
-- 2. 材质下拉菜单 (LSM Texture/Border/Background/Statusbar) - [v4.3.1] 支持池化
-- =========================================================
function EXUI:CreateLSMTextureDropdown(parent, mediaType, width, label, currentValue, onSelect)
    -- [Fix] 兼容性处理
    if type(currentValue) == "function" and onSelect == nil then
        onSelect = currentValue
        currentValue = nil
    end

    local EXFactory = _G.ExwindFactory
    local dropdown

    if EXFactory then
        -- 复用 GridLSMDropdown 池
        dropdown = EXFactory:Acquire("GridLSMDropdown", parent)
    else
        -- 兜底
        dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dropdown.labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        dropdown.labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
    end

    dropdown:SetWidth(width)
    if dropdown.EnableMouse then
        dropdown:EnableMouse(true)
    end
    dropdown.labelText:SetText(label or "")

    local selectedValue = currentValue or LSM:GetDefault(mediaType)
    -- 如果所选 key 在 LSM 中不存在（如用户未安装 SharedMedia），fallback 到 "Solid"
    if selectedValue and not LSM:HashTable(mediaType)[selectedValue] then
        selectedValue = LSM:HashTable(mediaType)["Solid"] and "Solid" or LSM:GetDefault(mediaType)
    end
    dropdown:SetText(selectedValue or "None")

    dropdown:SetupMenu(function(dropdown, rootDescription)
        rootDescription:CreateTitle(L["选择材质"])
        if rootDescription.SetScrollMode then rootDescription:SetScrollMode(400) end

        local list = LSM:HashTable(mediaType)
        local sortedKeys = LSM:List(mediaType)

        for _, key in ipairs(sortedKeys) do
            local path = list[key]
            local shortKey = #key > 24 and (string.sub(key, 1, 23) .. "..") or key

            local displayText = shortKey
            if path then
                if mediaType == "statusbar" then
                    displayText = string.format("|T%s:14:100:0:0:64:64:5:59:5:59|t %s", path, shortKey)
                elseif mediaType == "background" then
                    displayText = string.format("|T%s:20:20:0:0:64:64:5:59:5:59|t %s", path, shortKey)
                elseif mediaType == "border" then
                    -- 边框材质通常需要完整显示，不应用内裁剪
                    displayText = string.format("|T%s:14:100|t %s", path, shortKey)
                else
                    displayText = string.format("|T%s:16:16:0:0:64:64:5:59:5:59|t %s", path, shortKey)
                end
            end

            local btn = rootDescription:CreateRadio(displayText,
                function() return selectedValue == key end,
                function()
                    selectedValue = key
                    dropdown:SetText(key)
                    if onSelect then onSelect(key, path) end
                end
            )

            btn:AddInitializer(function(button, description, menu)
                CleanDropdownButton(button)
            end)
        end
    end)

    return dropdown
end

-- =========================================================
-- 3. 音效下拉菜单 (LSM Sound with Groups)
-- =========================================================
function EXUI:CreateLSMSoundDropdown(parent, width, label, currentValue, onSelect)
    -- [Fix] 兼容性处理：如果第四个参数是函数，说明是 legacy 调用 (onSelect 放在了 currentValue 位置)
    if type(currentValue) == "function" and onSelect == nil then
        onSelect = currentValue
        currentValue = nil
    end

    local EXFactory = _G.ExwindFactory
    local dropdown
    if EXFactory then
        dropdown = EXFactory:Acquire("GridLSMDropdown", parent)
    else
        dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dropdown.labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        dropdown.labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
    end
    dropdown:SetWidth(width)
    if dropdown.EnableMouse then
        dropdown:EnableMouse(true)
    end

    -- [池化关键] 将状态挂到 self，避免每次 Render 生成新闭包链
    dropdown._selectedValue = type(currentValue) == "string" and currentValue or LSM:GetDefault("sound")
    dropdown._onSelect = onSelect
    dropdown.labelText:SetText(label or "")

    dropdown:SetText(dropdown._selectedValue or "None")

    dropdown:SetupMenu(function(self, rootDescription)
        rootDescription:CreateTitle(L["选择音效"])
        if rootDescription.SetScrollMode then rootDescription:SetScrollMode(400) end

        local list = LSM:HashTable("sound")
        local keys = LSM:List("sound")

        -- 分类逻辑
        local exKeys = {}
        local otherKeys = {}
        for _, key in ipairs(keys) do
            if key:find("^%(EX%)") then
                table.insert(exKeys, key)
            else
                table.insert(otherKeys, key)
            end
        end

        local function AddSoundToMenu(targetDescription, key, path)
            local shortKey = #key > 50 and (string.sub(key, 1, 49) .. ".") or key
            local btn = targetDescription:CreateRadio(shortKey,
                function() return self._selectedValue == key end,
                function()
                    self._selectedValue = key
                    self:SetText(key)
                    if self._onSelect then self._onSelect(key, path) end
                end
            )

            btn:AddInitializer(function(button, description, menu)
                CleanDropdownButton(button)
                local playBtn = MenuTemplates.AttachBasicButton(button, 16, 16)
                playBtn:SetPoint("RIGHT", -5, 0)
                local tex = playBtn:AttachTexture()
                tex:SetAllPoints()
                tex:SetTexture("Interface\\Common\\VoiceChat-Speaker")
                tex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
                tex:SetVertexColor(0.8, 0.8, 0.8)
                playBtn:SetScript("OnEnter", function(self) tex:SetVertexColor(1, 1, 1) end)
                playBtn:SetScript("OnLeave", function(self) tex:SetVertexColor(0.8, 0.8, 0.8) end)
                MenuTemplates.SetUtilityButtonClickHandler(playBtn, function()
                    if path then PlaySoundFile(path, "Master") end
                end)
            end)
        end

        if #exKeys > 0 then
            local submenu = rootDescription:CreateButton(L["EXWIND音效"])
            for _, key in ipairs(exKeys) do
                AddSoundToMenu(submenu, key, list[key])
            end
            rootDescription:CreateDivider()
        end

        for _, key in ipairs(otherKeys) do
            AddSoundToMenu(rootDescription, key, list[key])
        end
    end)

    return dropdown
end

-- =========================================================
-- 4. 多选下拉菜单 (Multi-Select)
-- =========================================================
function EXUI:CreateMultiSelectDropdown(parent, width, label, options, selections, onUpdate)
    local EXFactory = _G.ExwindFactory
    local dropdown

    if EXFactory then
        -- 复用 GridDropdown 池 (它本身就是 DropdownButton + Label)
        dropdown = EXFactory:Acquire("GridDropdown", parent)
    else
        -- 兜底
        dropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
        dropdown.labelText = dropdown:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        dropdown.labelText:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 0, 2)
    end

    dropdown:SetWidth(width)
    if dropdown.EnableMouse then
        dropdown:EnableMouse(true)
    end
    dropdown.labelText:SetText(label or "")

    -- [v4.3.2] 将状态挂载到 Self，防止闭包泄漏
    dropdown._options = options
    dropdown._selections = selections
    dropdown._onUpdate = onUpdate

    -- [Fix] 重命名为 RefreshSelectionDisplay 避免与 Blizzard 内部方法冲突导致栈溢出
    function dropdown:RefreshSelectionDisplay()
        local selectedKeys = {}
        for _, key in ipairs(self._options) do
            if self._selections[key] then table.insert(selectedKeys, key) end
        end
        local display = L["未选择"]
        if #selectedKeys > 0 then
            if #selectedKeys <= 2 then
                display = table.concat(selectedKeys, ", ")
            else
                display = string.format(L["已选 %d 项"], #selectedKeys)
            end
        end
        self:SetText(display)
        if self._onUpdate then self._onUpdate(self._selections) end
    end

    dropdown:RefreshSelectionDisplay()

    dropdown:SetupMenu(function(self, rootDescription)
        rootDescription:SetScrollMode(400)
        rootDescription:CreateTitle(label)

        if not self._options then return end

        for _, key in ipairs(self._options) do
            rootDescription:CreateCheckbox(key,
                function() return self._selections[key] == true end,
                function()
                    self._selections[key] = not self._selections[key]
                    self:RefreshSelectionDisplay()
                    return MenuResponse.Refresh
                end
            )
        end
        rootDescription:CreateDivider()
        rootDescription:CreateButton(L["清空全部"], function()
            for k in pairs(self._selections) do self._selections[k] = nil end
            self:RefreshSelectionDisplay()
            return MenuResponse.Refresh
        end)
    end)

    -- 兼容旧接口
    dropdown.dropdown = dropdown

    return dropdown
end

-- =========================================================
-- 5. 通用按钮 (Button) - [v4.3.1] 支持池化
-- =========================================================
function EXUI:CreateButton(parent, width, height, text, onClick)
    local EXFactory = _G.ExwindFactory
    local btn

    if EXFactory then
        -- 从池获取
        btn = EXFactory:Acquire("GridButton", parent)
        -- 清理旧的 OnClick
        btn:SetScript("OnClick", nil)
        btn:SetScript("PreClick", nil)
        btn:SetScript("PostClick", nil)
        btn:SetScript("OnMouseDown", nil)
        btn:SetScript("OnMouseUp", nil)
    else
        -- 兜底
        btn = CreateFrame("Button", nil, parent, "SharedButtonLargeTemplate")
    end

    btn:SetSize(width or 120, height or 32)
    if btn.EnableMouse then
        btn:EnableMouse(true)
    end
    if btn.Enable then
        btn:Enable()
    end
    if btn.RegisterForClicks then
        btn:RegisterForClicks("LeftButtonUp")
    end
    btn:SetText(text)

    if onClick then
        btn:SetScript("OnClick", onClick)
    end

    return btn
end

-- =========================================================
-- 5b. 图片按钮 (PicButton) - 支持 Normal/Pushed/Highlight 贴图
-- =========================================================
function EXUI:CreatePicButton(parent, width, height, normalTex, pushedTex, highlightTex, onClick, noCrop)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(width or 32, height or 32)

    local crop = (not noCrop) and { 0.08, 0.92, 0.08, 0.92 } or { 0, 1, 0, 1 }

    -- 1. 正常状态贴图
    if normalTex then
        local n = btn:CreateTexture(nil, "ARTWORK")
        n:SetTexture(normalTex)
        n:SetAllPoints()
        n:SetTexCoord(unpack(crop))
        btn:SetNormalTexture(n)
        btn.Normal = n
    end

    -- 2. 按下状态贴图
    if pushedTex then
        local p = btn:CreateTexture(nil, "ARTWORK")
        p:SetTexture(pushedTex)
        p:SetAllPoints()
        p:SetTexCoord(unpack(crop))
        btn:SetPushedTexture(p)
        btn.Pushed = p
    else
        -- ...
        -- 自动生成按下效果：稍微缩小并位移
        btn:SetPushedTextOffset(1, -1)
        if btn.Normal then
            -- 如果没有 Pushed 贴图，按下时给 Normal 加点暗色滤镜
            btn:GetPushedTexture():SetVertexColor(0.7, 0.7, 0.7)
        end
    end

    -- 3. 高亮(滑过)状态贴图
    if highlightTex then
        local h = btn:CreateTexture(nil, "HIGHLIGHT")
        h:SetTexture(highlightTex)
        h:SetAllPoints()
        h:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn:SetHighlightTexture(h)
    else
        -- 自动生成高亮效果：半透明白光
        local h = btn:CreateTexture(nil, "HIGHLIGHT")
        h:SetTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
        h:SetAllPoints()
        h:SetBlendMode("ADD")
        btn:SetHighlightTexture(h)
    end

    if onClick then btn:SetScript("OnClick", onClick) end
    return btn
end

-- =========================================================
-- 6. 通用勾选框 (CheckBox) - [v4.3.1] 支持池化
-- =========================================================
function EXUI:CreateCheckbox(parent, text, initialValue, onClick)
    local EXFactory = _G.ExwindFactory
    local container

    if EXFactory then
        -- 从池获取（池中已预创建 checkbox 和 label）
        container = EXFactory:Acquire("GridCheckbox", parent)
    else
        -- 兜底：传统创建
        container = CreateFrame("Frame", nil, parent)
        container:SetSize(200, 28)

        local cb = CreateFrame("CheckButton", nil, container, "MinimalCheckboxTemplate")
        cb:SetSize(28, 28)
        cb:SetPoint("LEFT", container, "LEFT", 0, 0)
        -- 移除旧版硬编码贴图，使用模板自带的现代 Atlas
        container.checkbox = cb

        local label = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        label:SetPoint("LEFT", cb, "RIGHT", 6, 0)
        container.label = label

        function container:SetChecked(v) self.checkbox:SetChecked(v) end

        function container:GetChecked() return self.checkbox:GetChecked() end
    end

    -- 设置当前值
    container:SetSize(200, 28)
    container.checkbox:SetChecked(initialValue)
    container.label:SetText(text or "")
    if container.EnableMouse then
        container:EnableMouse(false)
    end
    container:SetScript("OnEnter", nil)
    container:SetScript("OnLeave", nil)
    if container.checkbox.EnableMouse then
        container.checkbox:EnableMouse(true)
    end
    container.checkbox:SetScript("OnEnter", nil)
    container.checkbox:SetScript("OnLeave", nil)
    container.checkbox:SetScript("PreClick", nil)
    container.checkbox:SetScript("PostClick", nil)

    -- 设置回调
    container.checkbox:SetScript("OnClick", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        if onClick then onClick(self:GetChecked() == true) end
    end)

    return container
end

-- =========================================================
-- 7. 通用拖动条 (Slider) - [v4.3.13] 支持池化
-- =========================================================
function EXUI:CreateSlider(parent, width, label, minVal, maxVal, curVal, step, formatter, onValueChanged)
    local EXFactory = _G.ExwindFactory
    local slider

    if EXFactory then
        slider = EXFactory:Acquire("GridSlider", parent)
    else
        slider = CreateFrame("Slider", nil, parent, "MinimalSliderWithSteppersTemplate")
    end

    slider:SetWidth(width or 200)
    if slider.EnableMouse then
        slider:EnableMouse(true)
    end

    -- [池化关键] 将回调存到 slider 属性
    slider._onValueChanged = onValueChanged

    -- [v4.3.15 Fix] 智能格式化：如果启用了小数步长，自动显示相应的小数位
    local precision = 0
    if step and step < 1 then
        if step >= 0.1 then
            precision = 1
        elseif step >= 0.01 then
            precision = 2
        else
            precision = 3
        end
    end

    slider._formatter = (type(formatter) == "function") and formatter or function(v)
        if precision > 0 then
            return string.format("%." .. precision .. "f", v)
        else
            return math.floor(v + 0.5) -- 整数模式使用四舍五入
        end
    end

    -- 池化滑块可能已预创建 ValueText/Title；仅在缺失时补建，避免拖动时叠字残影
    if not slider.ValueText then
        slider.ValueText = slider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        slider.ValueText:SetFontObject("GameFontNormal")
        slider.ValueText:SetPoint("BOTTOMRIGHT", slider, "TOPRIGHT", -2, 1)
        slider.ValueText:SetJustifyH("RIGHT")
    end
    if not slider.Title then
        slider.Title = slider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        slider.Title:SetFontObject("GameFontNormal")
        slider.Title:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 1)
        slider.Title:SetJustifyH("LEFT")
        slider.Title:SetWordWrap(false)
    end
    slider.Title:ClearAllPoints()
    slider.Title:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 1)
    slider.Title:SetPoint("RIGHT", slider.ValueText, "LEFT", -5, 0)
    slider.labelText = slider.Title

    -- 首次注册回调（只注册一次）
    if not slider._sliderInit then
        -- [v4.3.13 Fix] 传入 slider 作为 owner
        -- CallbackRegistryMixin 的 TriggerEvent 会以 callback(owner, value) 形式调用
        -- 所以第一个参数 s 就是 slider 自身
        slider:RegisterCallback("OnValueChanged", function(s, value)
            if s._onValueChanged then s._onValueChanged(value) end
            if s.ValueText and s._formatter then
                s.ValueText:SetText(s._formatter(value))
            end
        end, slider)
        slider._sliderInit = true
    end

    -- 每次调用都更新：标题、数值显示、滑动条值
    if slider.Title then slider.Title:SetText(label or "") end
    if slider.ValueText then slider.ValueText:SetText(slider._formatter(curVal)) end

    if slider.Init then
        slider:Init(curVal, minVal, maxVal, (maxVal - minVal) / (step or 1))
    end

    return slider
end

-- =========================================================
-- 8. 通用分隔线 (Separator)
-- =========================================================
function EXUI:CreateSeparator(parent, width)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetSize(width or 200, 1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    -- 使用渐变效果，让线看起来更高级
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.3), CreateColor(1, 1, 1, 0.05))
    return line
end

-- =========================================================
-- 9. 分段标题 (Header with Line) - [v4.3.1] 支持池化
-- =========================================================
function EXUI:CreateHeader(parent, text, width)
    local EXFactory = _G.ExwindFactory
    local container

    if EXFactory then
        -- 从池获取（池中已预创建 Title 和 Line）
        container = EXFactory:Acquire("GridHeader", parent)
    else
        -- 兜底：传统创建
        container = CreateFrame("Frame", nil, parent)
        container:SetSize(width or 550, 40)

        local title = container:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        title:SetPoint("TOPLEFT", 0, -5)
        title:SetTextColor(1, 0.82, 0)
        container.Title = title

        local line = container:CreateTexture(nil, "ARTWORK")
        line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
        line:SetPoint("RIGHT", 0, 0)
        line:SetHeight(1)
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))
        container.Line = line
    end

    container:SetSize(width or 550, 40)
    container.Title:SetText(text or "")

    return container
end

-- =========================================================
-- 10. 复合字体设置组 (Font Setting Group)
-- 传入一个 db 表(需包含 .font, .size, .outline)，会自动创建一整套设置
-- =========================================================
-- =========================================================
-- 11. 颜色选择按钮 (Color Button)
-- =========================================================
function EXUI:CreateColorButton(parent, label, db, key, hasAlpha, onUpdate)
    local EXFactory = _G.ExwindFactory
    local btn

    if EXFactory then
        btn = EXFactory:Acquire("GridColorButton", parent)
    else
        btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        if not btn.swatch then
            btn.swatch = btn:CreateTexture(nil, "OVERLAY")
            btn.swatch:SetTexture("Interface\\Buttons\\WHITE8X8")
        end
        if not btn.labelText then
            local txt = btn:CreateFontString(nil, "OVERLAY")
            txt:SetFontObject("GameFontHighlight")
            btn.labelText = txt
        end
    end

    -- 1. 主容器
    btn:SetSize(225, 36)
    if btn.EnableMouse then
        btn:EnableMouse(true)
    end

    -- 2. 设置 Tooltip 风格的背景与边框
    btn:SetBackdrop(EXUI.TooltipBackdrop)
    btn:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
    btn:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    -- 3. 左侧预览色块
    local swatch = btn.swatch
    if swatch then
        swatch:ClearAllPoints()
        swatch:SetSize(16, 16)
        swatch:SetPoint("LEFT", btn, "LEFT", 10, 0)
        swatch:SetTexture("Interface\\Buttons\\WHITE8X8")
    end

    if not btn.swatchBorder then
        btn.swatchBorder = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        btn.swatchBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    end
    btn.swatchBorder:ClearAllPoints()
    btn.swatchBorder:SetPoint("TOPLEFT", swatch, -1, 1)
    btn.swatchBorder:SetPoint("BOTTOMRIGHT", swatch, 1, -1)
    btn.swatchBorder:SetBackdropBorderColor(0, 0, 0, 0.8)

    -- 4. 文本标签
    if not btn.labelText then
        btn.labelText = btn.label
    end
    if not btn.labelText then
        btn.labelText = btn:CreateFontString(nil, "OVERLAY")
        btn.labelText:SetFontObject("GameFontHighlight")
    end
    local text = btn.labelText
    text:SetFontObject("GameFontHighlight")
    text:ClearAllPoints()
    text:SetPoint("LEFT", swatch, "RIGHT", 10, 0)
    text:SetPoint("RIGHT", btn, "RIGHT", -8, 0)
    text:SetJustifyH("LEFT")
    text:SetText(label or "")

    -- [关键] 属性挂载，以便池化复用时更新
    btn._currentDb = db
    btn._currentKey = key
    btn._currentOnUpdate = onUpdate
    btn._hasAlpha = hasAlpha

    if not btn.UpdateColor then
        function btn:UpdateColor(nr, ng, nb, na)
            local r, g, b, a
            if type(nr) == "number" then
                r, g, b, a = nr, ng, nb, na
            else
                local d, k = self._currentDb, self._currentKey
                if not d then return end
                if not k or k == "" then
                    r, g, b, a = d.r or 1, d.g or 1, d.b or 1, d.a or 1
                else
                    r, g, b, a = d[k .. "R"] or 1, d[k .. "G"] or 1, d[k .. "B"] or 1, d[k .. "A"] or 1
                end
            end
            if self.swatch then
                self.swatch:SetVertexColor(r, g, b, a)
            end
            self:SetBackdropColor(r * 0.2, g * 0.2, b * 0.2, 0.75)
            self:SetBackdropBorderColor(r, g, b, 0.4)
        end
    end

    btn:UpdateColor()

    btn:SetScript("OnClick", function(self)
        local d, k = self._currentDb, self._currentKey
        if type(d) ~= "table" then return end

        local function GetDBColor()
            if not k or k == "" then
                return d.r or 1, d.g or 1, d.b or 1, d.a or 1
            else
                return d[k .. "R"] or 1, d[k .. "G"] or 1, d[k .. "B"] or 1, d[k .. "A"] or 1
            end
        end

        local function SetDBColor(r, g, b, a)
            if not k or k == "" then
                d.r, d.g, d.b, d.a = r, g, b, a
            else
                d[k .. "R"], d[k .. "G"], d[k .. "B"], d[k .. "A"] = r, g, b, a
            end
        end

        local currR, currG, currB, currA = GetDBColor()
        local info = {
            swatchFunc = function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = self._hasAlpha and ColorPickerFrame:GetColorAlpha() or 1
                SetDBColor(r, g, b, a)
                self:UpdateColor()
                if self._currentOnUpdate then self._currentOnUpdate(d) end
            end,
            opacityFunc = self._hasAlpha and function()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                local a = ColorPickerFrame:GetColorAlpha()
                SetDBColor(r, g, b, a)
                self:UpdateColor()
                if self._currentOnUpdate then self._currentOnUpdate(d) end
            end or nil,
            cancelFunc = function(prev)
                SetDBColor(prev.r, prev.g, prev.b, prev.a or prev.opacity or 1)
                self:UpdateColor()
                if self._currentOnUpdate then self._currentOnUpdate(d) end
            end,
            hasOpacity = self._hasAlpha,
            opacity = self._hasAlpha and currA or 1,
            r = currR,
            g = currG,
            b = currB,
        }
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)
    return btn
end

-- =========================================================
-- 10. 复合字体设置组 (完整封装版) - [v4.3.1] 支持池化
-- =========================================================
function EXUI:CreateFontGroup(parent, width, label, db, onUpdate)
    local EXFactory = _G.ExwindFactory
    local group
    local groupWidth = width or 750
    local groupHeight = 280

    local function getDb() return group and group._currentDb end
    local function getOnUpdate() return group and group._currentOnUpdate end

    if EXFactory then
        -- 从池获取
        group = EXFactory:Acquire("GridFontGroup", parent)
        group:SetSize(groupWidth, groupHeight)

        -- 复用时更新标题
        if group.labelText then
            group.labelText:SetText(label or "")
        end

        -- 复用时更新所有子组件的值和回调
        if group._initialized then
            group._currentDb = db
            group._currentOnUpdate = onUpdate

            -- [关键] 补充 sub-widgets 的属性同步，防止池化复用后脚本仍指向旧行数据

            -- 1. 更新颜色按钮
            if group.colorBtn and group.colorBtn.UpdateColor then
                group.colorBtn._currentDb = db
                group.colorBtn._currentOnUpdate = onUpdate
                group.colorBtn:UpdateColor()
            end

            -- 2. 更新滑块（Init 内部会触发绑定了 getDb() 的回调）
            if group.sizeSlider and group.sizeSlider.Init then
                group.sizeSlider._onValueChanged = function(v)
                    getDb().size = v; if getOnUpdate() then getOnUpdate()(getDb()) end
                end
                group.sizeSlider:Init(db.size or 14, 4, 100, 96)
            end
            if group.xSlider and group.xSlider.Init then
                group.xSlider._onValueChanged = function(v)
                    getDb().x = v; if getOnUpdate() then getOnUpdate()(getDb()) end
                end
                group.xSlider:Init(db.x or 0, -200, 200, 400)
            end
            if group.ySlider and group.ySlider.Init then
                group.ySlider._onValueChanged = function(v)
                    getDb().y = v; if getOnUpdate() then getOnUpdate()(getDb()) end
                end
                group.ySlider:Init(db.y or 0, -200, 200, 400)
            end
            if group.sxSlider and group.sxSlider.Init then
                group.sxSlider._onValueChanged = function(v)
                    getDb().shadowX = v; if getOnUpdate() then getOnUpdate()(getDb()) end
                end
                group.sxSlider:Init(db.shadowX or 1, -20, 20, 400)
            end
            if group.sySlider and group.sySlider.Init then
                group.sySlider._onValueChanged = function(v)
                    getDb().shadowY = v; if getOnUpdate() then getOnUpdate()(getDb()) end
                end
                group.sySlider:Init(db.shadowY or -1, -20, 20, 400)
            end

            -- 3. 更新复选框
            if group.shadowCheck then
                group.shadowCheck.checkbox:SetScript("OnClick", function(self)
                    getDb().shadow = self:GetChecked()
                    if getOnUpdate() then getOnUpdate()(getDb()) end
                end)
                group.shadowCheck.checkbox:SetChecked(db.shadow)
            end

            if group.fontDropdown then
                group.fontDropdown._mediaType = "font"
                -- [关键] 同时更新 _selectedValue 和显示文本
                group.fontDropdown._selectedValue = db.font or LSM:GetDefault("font")
                group.fontDropdown._onSelect = function(key)
                    getDb().font = key; if getOnUpdate() then getOnUpdate()(getDb()) end
                end
                group.fontDropdown:SetText(db.font or L["默认"])
            end

            if group.outlineDropdown then
                group.outlineDropdown._currentValue = db.outline or "OUTLINE"
                group.outlineDropdown._onSelect = function(val)
                    getDb().outline = val; if getOnUpdate() then getOnUpdate()(getDb()) end
                end
                local outlineText = ({ [""] = L["无"], ["OUTLINE"] = L["细"], ["THICKOUTLINE"] = L["粗"], ["MONOCHROME"] = L["无锯齿"] })
                    [db.outline or "OUTLINE"] or L["细"]
                group.outlineDropdown:SetText(outlineText)
            end

            return group
        end
    else
        -- 兜底：传统创建
        group = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    end

    group:SetSize(groupWidth, groupHeight)

    -- 盒子外观 (Tooltip 风格)
    group:SetBackdrop(EXUI.TooltipBackdrop)
    group:SetBackdropColor(0, 0, 0, 0.6)
    group:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    -- 标题区域
    local header = CreateFrame("Frame", nil, group)
    header:SetSize(groupWidth, 40)
    header:SetPoint("TOPLEFT")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", 15, 0)
    title:SetText(label or "")
    title:SetTextColor(1, 0.82, 0)
    group.labelText = title

    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT", 10, 5)
    line:SetPoint("BOTTOMRIGHT", -10, 5)
    line:SetHeight(1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))

    local content = CreateFrame("Frame", nil, group)
    content:SetSize(groupWidth, groupHeight - 40)
    content:SetPoint("TOPLEFT", 0, -40)
    group.content = content

    local col1, col2, col3 = 15, 275, 535
    local row1, row2, row3 = -25, -95, -165
    local itemW = 225

    -- 存储 db 和 onUpdate 引用（用于复用时更新回调）
    group._currentDb = db
    group._currentOnUpdate = onUpdate

    -- [第一行]
    local colorBtn = self:CreateColorButton(content, L["文字颜色"], db, "", true, function()
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    colorBtn:SetPoint("TOPLEFT", col1, row1)
    group.colorBtn = colorBtn

    local sizeSlider = self:CreateSlider(content, itemW, L["文字大小"], 4, 100, db.size or 14, 1, nil, function(v)
        getDb().size = v
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    sizeSlider:SetPoint("TOPLEFT", col2, row1)
    group.sizeSlider = sizeSlider

    local shadowCheck = self:CreateCheckbox(content, L["启用阴影"], db.shadow, function(checked)
        getDb().shadow = checked
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    shadowCheck:SetPoint("TOPLEFT", col3, row1 - 5)
    group.shadowCheck = shadowCheck

    -- [第二行]
    local fontDropdown = self:CreateLSMDropdown(content, "font", itemW, L["字体样式"], function(key)
        getDb().font = key
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    fontDropdown:SetPoint("TOPLEFT", col1, row2)
    -- [关键] 同步更新 _selectedValue，确保单选按钮状态正确
    if db.font then
        fontDropdown._selectedValue = db.font
        fontDropdown:SetText(db.font)
    end
    group.fontDropdown = fontDropdown

    local xSlider = self:CreateSlider(content, itemW, L["X 轴偏移"], -200, 200, db.x or 0, 1, nil, function(v)
        getDb().x = v
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    xSlider:SetPoint("TOPLEFT", col2, row2)
    group.xSlider = xSlider

    local sxSlider = self:CreateSlider(content, itemW, L["阴影 X 偏移"], -20, 20, db.shadowX or 1, 0.1, nil, function(v)
        getDb().shadowX = v
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    sxSlider:SetPoint("TOPLEFT", col3, row2)
    group.sxSlider = sxSlider

    -- [第三行]
    local outlineItems = { { L["无"], "" }, { L["细"], "OUTLINE" }, { L["粗"], "THICKOUTLINE" }, { L["无锯齿"], "MONOCHROME" } }
    local outlineDropdown = self:CreateDropdown(content, itemW, L["文字描边"], outlineItems, db.outline or "OUTLINE",
        function(val)
            getDb().outline = val
            local cb = getOnUpdate()
            if cb then cb(getDb()) end
        end)
    outlineDropdown:SetPoint("TOPLEFT", col1, row3)
    group.outlineDropdown = outlineDropdown

    local ySlider = self:CreateSlider(content, itemW, L["Y 轴偏移"], -200, 200, db.y or 0, 1, nil, function(v)
        getDb().y = v
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    ySlider:SetPoint("TOPLEFT", col2, row3)
    group.ySlider = ySlider

    local sySlider = self:CreateSlider(content, itemW, L["阴影 Y 偏移"], -20, 20, db.shadowY or -1, 0.1, nil, function(v)
        getDb().shadowY = v
        local cb = getOnUpdate()
        if cb then cb(getDb()) end
    end)
    sySlider:SetPoint("TOPLEFT", col3, row3)
    group.sySlider = sySlider

    -- 标记为已初始化
    group._initialized = true

    return group
end

-- =========================================================
-- 12. 音效设置复合组件 (Sound Settings Group)
-- =========================================================
function EXUI:CreateSoundGroup(parent, width, label, db, key, onUpdate)
    local LSM = LibStub("LibSharedMedia-3.0")
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local groupWidth = width or 750
    local groupHeight = 180

    container:SetSize(groupWidth, groupHeight)
    container:SetBackdrop(EXUI.TooltipBackdrop)
    container:SetBackdropColor(0, 0, 0, 0.6)
    container:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    local header = CreateFrame("Frame", nil, container)
    header:SetSize(groupWidth, 40)
    header:SetPoint("TOPLEFT")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", 15, 0)
    title:SetText(label or L["音效设置"])
    title:SetTextColor(0, 0.8, 1)
    container.labelText = title

    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT", 10, 5)
    line:SetPoint("BOTTOMRIGHT", -10, 5)
    line:SetHeight(1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))

    local content = CreateFrame("Frame", nil, container)
    content:SetSize(groupWidth, groupHeight - 40)
    content:SetPoint("TOPLEFT", 0, -40)

    local col1, col2 = 15, 385
    local row1, row2 = -25, -95
    local itemW = 350

    local sKey = key .. "Sound"
    local cKey = key .. "Channel"
    local useKey = key .. "UseCustom"
    local pathKey = key .. "CustomPath"

    -- 1. LSM 音效选择
    local soundDropdown = EXUI:CreateLSMSoundDropdown(content, itemW, L["选择音效 (LSM)"], db[sKey] or "None", function(val)
        db[sKey] = val
        if onUpdate then onUpdate() end
    end)
    soundDropdown:SetPoint("TOPLEFT", col1, row1 - 10)

    -- 2. 音频通道选择
    local channels = {
        { L["主音量 (Master)"], "Master" },
        { L["音效 (SFX)"], "SFX" },
        { L["环境 (Ambience)"], "Ambience" },
        { L["音乐 (Music)"], "Music" },
        { L["对话 (Dialog)"], "Dialog" },
    }
    local channelDropdown = EXUI:CreateDropdown(content, 180, L["音频通道"], channels, db[cKey] or "Master", function(val)
        db[cKey] = val
        if onUpdate then onUpdate() end
    end)
    channelDropdown:SetPoint("TOPLEFT", col2, row1 - 10)

    -- 3. 自定义音效开关与输入
    local cbCustom = EXUI:CreateCheckbox(content, L["使用自定义路径"], db[useKey], function(c)
        db[useKey] = c
        if onUpdate then onUpdate() end
    end)
    cbCustom:SetPoint("TOPLEFT", col1, row2 - 10)

    local inputCustom = EXUI:CreateEditBox(
        content,
        db[pathKey] or "",
        groupWidth - 200,
        32,
        "",
        {
            onEnter = function(v)
                db[pathKey] = v
                if onUpdate then onUpdate() end
            end,
            onEditFocusLost = function(v)
                db[pathKey] = v
                if onUpdate then onUpdate() end
            end,
            placeholder = L["示例: Interface\\AddOns\\MySound\\test.ogg"]
        }
    )
    inputCustom:SetPoint("LEFT", cbCustom, "RIGHT", 5, 0)

    return container
end

-- =========================================================
-- [v4.4] Encounter Voice Group (池化版音效设置组)
-- =========================================================
if _G.ExwindFactory and not _G.ExwindFactory.Pools["GridVoiceGroup"] then
    _G.ExwindFactory:InitPool("GridVoiceGroup", "Frame", "BackdropTemplate", function(f)
        f:SetSize(750, 220)
        f._gridType = "GridVoiceGroup"
    end)
    if _G.ExwindFactory.GridTypeMap then
        _G.ExwindFactory.GridTypeMap["voicegroup"] = "GridVoiceGroup"
        _G.ExwindFactory.GridTypeMap["encounter_voice_group"] = "GridVoiceGroup"
    end
end

function EXUI:CreateVoiceGroup(parent, width, labelText, db, key, onUpdate)
    local w = width or 750
    local h = 170

    local EXFactory = _G.ExwindFactory
    local container

    if EXFactory then
        container = EXFactory:Acquire("GridVoiceGroup", parent)
        container:SetSize(w, h)
    else
        container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        container:SetSize(w, h)
    end

    container:SetBackdrop(nil)

    if not container._initialized then
        container.header = CreateFrame("Frame", nil, container)
        container.header:SetSize(w, 1)
        container.header:SetPoint("TOPLEFT")
        container.header:Hide()

        container.title = container.header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
        container.title:SetPoint("LEFT", 15, 0)
        container.title:SetTextColor(0, 0.8, 1)

        local line = container.header:CreateTexture(nil, "ARTWORK")
        line:SetPoint("BOTTOMLEFT", 10, 5)
        line:SetPoint("BOTTOMRIGHT", -10, 5)
        line:SetHeight(1)
        line:SetTexture("Interface\\Buttons\\WHITE8X8")
        line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))

        container.content = CreateFrame("Frame", nil, container)
        container.content:SetSize(w, h)
        container.content:SetPoint("TOPLEFT", 0, 0)

        container.rows = {}

        local triggerNames = {
            [0] = L["文本警报"],
            [1] = L["施法开始"],
            [2] = L["提前五秒"]
        }

        local channels = {
            { "Master",   "Master" },
            { "SFX",      "SFX" },
            { "Ambience", "Ambience" },
            { "Music",    "Music" },
            { "Dialog",   "Dialog" },
        }

        local sources = {
            { L["语音包"], "pack" },
            { L["LSM音效"], "lsm" },
            { L["自定义路径"], "file" }
        }

        local packOptions = {}
        if _G.EXBV_LABELS and type(_G.EXBV_LABELS) == "table" then
            for _, label in ipairs(_G.EXBV_LABELS) do
                if type(label) == "string" and label ~= "" then
                    table.insert(packOptions, { label, label })
                end
            end
        end
        if #packOptions == 0 then
            table.insert(packOptions, { L["注意"], "注意" })
        end

        local rowY = -15
        for i = 0, 2 do
            local row = CreateFrame("Frame", nil, container.content)
            row:SetSize(w, 45)
            row:SetPoint("TOPLEFT", 0, rowY)
            rowY = rowY - 50

            local w_chk = 110
            local w_src = 120
            local w_chan = 110
            local w_vol = 140
            local w_dyn = math.max(160, w - w_chk - w_src - w_chan - w_vol - 60)

            local off_chk = -2
            local off_src = off_chk + w_chk
            local off_dyn = off_src + w_src + 15
            local off_chan = off_dyn + w_dyn + 15
            local off_vol = off_chan + w_chan + 15

            local chk = EXUI:CreateCheckbox(row, triggerNames[i], false, function(checked)
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.enabled = checked end
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)
            chk:SetPoint("LEFT", off_chk, 0)

            local srcDrop = EXUI:CreateDropdown(row, w_src, L["来源"], sources, "pack", function(val)
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.sourceType = val end
                row.UpdateDynamicArea(rDb)
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)
            srcDrop:SetPoint("LEFT", off_src, 0)

            local dynArea = CreateFrame("Frame", nil, row)
            dynArea:SetSize(w_dyn, 30)
            dynArea:SetPoint("LEFT", off_dyn, 0)

            local packDrop = EXUI:CreateDropdown(dynArea, w_dyn, "", packOptions, "注意", function(val)
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.label = val end
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)
            packDrop:SetPoint("LEFT", 0, 0)

            local lsmDrop = EXUI:CreateLSMSoundDropdown(dynArea, w_dyn, "sound", "None", function(val)
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.customLSM = val end
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)
            lsmDrop:SetPoint("LEFT", 0, 0)

            local fileInput = EXUI:CreateEditBox(dynArea, "", w_dyn, 30, "", {})
            fileInput:SetPoint("LEFT", 0, 0)
            fileInput:SetScript("OnEditFocusLost", function(self)
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.customPath = self:GetText() end
                if self:GetText() == "" then self.placeholder:Show() end
                self:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)
            fileInput:SetScript("OnEnterPressed", function(self)
                self:ClearFocus()
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.customPath = self:GetText() end
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)

            row.UpdateDynamicArea = function(t)
                local rDb = t or
                    (container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i])
                if not rDb then return end
                packDrop:Hide()
                lsmDrop:Hide()
                fileInput:Hide()
                if rDb.sourceType == "pack" then
                    packDrop:Show()
                elseif rDb.sourceType == "lsm" then
                    lsmDrop:Show()
                else
                    fileInput:Show()
                end
            end

            local chanDrop = EXUI:CreateDropdown(row, w_chan, L["频道"], channels, "Master", function(val)
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.channel = val end
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)
            chanDrop:SetPoint("LEFT", off_chan, 0)

            local volSlider = EXUI:CreateSlider(row, w_vol, L["音量"], 0, 1, 1, 0.1, nil, function(v)
                local rDb = container._currentDb and container._currentDb.triggers and container._currentDb.triggers[i]
                if rDb then rDb.volume = v end
                if container._currentOnUpdate then container._currentOnUpdate(container._currentDb) end
            end)
            volSlider:SetPoint("LEFT", off_vol, 0)

            row.chk = chk
            row.srcDrop = srcDrop
            row.packDrop = packDrop
            row.lsmDrop = lsmDrop
            row.fileInput = fileInput
            row.chanDrop = chanDrop
            row.volSlider = volSlider

            container.rows[i] = row
        end

        container._initialized = true
    end

    container.title:SetText(labelText or L["语音设置组"])

    if type(db) ~= "table" then return container end
    db.triggers = type(db.triggers) == "table" and db.triggers or {}

    container._currentDb = db
    container._currentOnUpdate = onUpdate

    for i = 0, 2 do
        local r = container.rows[i]
        local t = db.triggers[i]
        if type(t) ~= "table" then
            t = {}
            db.triggers[i] = t
        end

        if not t.sourceType then t.sourceType = "pack" end
        if not t.channel then t.channel = "Master" end
        if not t.volume then t.volume = 1 end

        -- Apply values to Checkbox
        r.chk:SetChecked(t.enabled == true)

        -- Apply values to Source Dropdown
        r.srcDrop._currentValue = t.sourceType
        r.srcDrop:SetText(t.sourceType == "pack" and L["语音包"] or (t.sourceType == "lsm" and L["LSM音效"] or L["自定义路径"]))

        -- Apply values to Pack Dropdown
        r.packDrop._currentValue = t.label or "注意"
        r.packDrop:SetText(t.label or "注意")

        -- Apply values to LSM Dropdown
        r.lsmDrop._selectedValue = t.customLSM or "None"
        r.lsmDrop:SetText(t.customLSM or "None")

        -- Apply values to File Input
        r.fileInput:SetText(t.customPath or "")
        r.fileInput.placeholder:SetText(L["路径..."])
        if t.customPath and t.customPath ~= "" then
            r.fileInput.placeholder:Hide()
        else
            r.fileInput.placeholder:Show()
        end

        -- Apply values to Channel Dropdown
        r.chanDrop._currentValue = t.channel
        r.chanDrop:SetText(t.channel)

        -- Apply values to Volume Slider
        if r.volSlider.Init then r.volSlider:Init(t.volume, 0, 1, 10) end
        if r.volSlider.ValueText then r.volSlider.ValueText:SetText(string.format("%.1f", t.volume)) end

        -- Finally refresh Dynamic Area Visibility
        if r.UpdateDynamicArea then r.UpdateDynamicArea(t) end
    end

    container:Show()
    return container
end

-- =========================================================
-- 13. 输入框与多行文本框 (EditBox)
-- Options: .bgColor, .borderColor, .textColor
-- =========================================================
function EXUI:CreateEditBox(parent, text, w, h, labelText, options)
    local isMultiLine = h > 40
    options = options or {}

    local EXFactory = _G.ExwindFactory

    -- [v4.3.2] 单行模式走池化通道
    if EXFactory and not isMultiLine then
        local container = EXFactory:Acquire("GridInput", parent)

        -- 清理旧回调
        container:SetScript("OnTextChanged", nil)
        container:SetScript("OnEditFocusLost", nil)
        container:SetScript("OnEnterPressed", nil)

        -- 兼容旧接口
        container.editBox = container

        -- 基础配置
        container:SetSize(w or 180, h or 28)
        if container.EnableMouse then
            container:EnableMouse(true)
        end
        container:SetAutoFocus(false)
        container:SetText(text or "")

        -- 标签设置
        if labelText then
            local label = container.label
            label:Show()
            label:SetText(labelText)
            label:ClearAllPoints()

            if options.labelPos == "left" then
                label:SetPoint("RIGHT", container, "LEFT", -5, 0)
                label:SetJustifyH("RIGHT")
            else
                label:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 3)
                label:SetJustifyH("LEFT")
            end

            -- 字体大小 (修正默认值)
            local font, _, flags = label:GetFont()
            local size = (options.labelSize and tonumber(options.labelSize)) or 14
            label:SetFont(font, size, flags)
        else
            container.label:Hide()
        end

        -- 占位符
        if not container.placeholder then
            container.placeholder = container:CreateFontString(nil, "OVERLAY", "GameFontDisable")
            container.placeholder:SetPoint("LEFT", 3, 0)
        end
        container.placeholder:SetText(options.placeholder or "")

        local function UpdatePlaceholder()
            if container:GetText() == "" then container.placeholder:Show() else container.placeholder:Hide() end
        end
        UpdatePlaceholder()

        -- 回调逻辑
        container:SetScript("OnTextChanged", function(self, userInput)
            UpdatePlaceholder()
            if options.onChanged then options.onChanged(self:GetText(), userInput) end
        end)

        container:SetScript("OnEditFocusGained", function(self)
            self:SetBackdropBorderColor(0.64, 0.19, 0.79, 1)
        end)

        container:SetScript("OnEditFocusLost", function(self)
            self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
            UpdatePlaceholder()
            if options.onEditFocusLost then options.onEditFocusLost(self:GetText()) end
        end)

        container:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
            if options.onEnter then options.onEnter(self:GetText()) end
        end)

        container:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

        return container
    end

    -- =========================================================
    -- 多行模式或无工厂模式 (Legacy Path)
    -- =========================================================

    -- 1. 主容器 (Tooltip 风格)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(w, h)
    container:SetBackdrop(EXUI.TooltipBackdrop)
    container:SetBackdropColor(0, 0, 0, 0.6)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)

    -- 简化的标签逻辑
    if labelText then
        local label = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        if options.labelPos == "left" then
            label:SetPoint("RIGHT", container, "LEFT", -5, 0)
            label:SetJustifyH("RIGHT")
        else
            label:SetPoint("BOTTOMLEFT", container, "TOPLEFT", 0, 3)
        end
        local font, _, flags = label:GetFont()
        local size = (options.labelSize and tonumber(options.labelSize)) or 14
        label:SetFont(font, size, flags)
        label:SetText(labelText)
        container.label = label
    end

    -- 多行模式特有逻辑: ScrollFrame
    local eb
    local sf = CreateFrame("ScrollFrame", nil, container)
    sf:SetPoint("TOPLEFT", 5, -5)
    sf:SetPoint("BOTTOMRIGHT", -5, 5)

    -- [Fix] 使用一个容器 Frame 作为 ScrollChild，EditBox 放在里面
    -- 这样可以更精确控制 EditBox 的行为，避免 ScrollFrame 对 EditBox 的奇异约束
    local scrollContent = CreateFrame("Frame", nil, sf)
    scrollContent:SetSize(w - 20, 2000) -- 给一个巨大的高度，确保能滚动
    sf:SetScrollChild(scrollContent)

    eb = CreateFrame("EditBox", nil, scrollContent)
    eb:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 0, 0)
    eb:SetPoint("TOPRIGHT", scrollContent, "TOPRIGHT", 0, 0)
    eb:SetHeight(2000) -- 让 EditBox 同样巨大
    eb:SetMultiLine(true)
    eb:SetTextInsets(4, 4, 4, 4)
    eb:SetJustifyH("LEFT")
    eb:SetJustifyV("TOP") -- 必须顶部对齐！

    -- 自动滚动逻辑
    eb:SetScript("OnCursorChanged", function(self, x, y, width, height)
        local vs = sf:GetVerticalScroll()
        local h = sf:GetHeight()
        -- y 是相对于 EditBox 顶部的负值
        local cursorY = -y

        if cursorY < vs then
            sf:SetVerticalScroll(cursorY)
        elseif (cursorY + height) > (vs + h) then
            sf:SetVerticalScroll(cursorY + height - h)
        end
    end)
    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local new = current - (delta * 20)
        self:SetVerticalScroll(math.max(0, math.min(new, self:GetVerticalScrollRange())))
    end)
    container.scrollFrame = sf

    -- [Fix] 增加点击区域屏蔽，确保点击容器任何地方都能聚焦 EditBox
    sf:SetScript("OnMouseDown", function() eb:SetFocus() end)

    -- [Fix] 解决多行输入框拦截滚轮的问题：将滚动事件透传给父级
    sf:SetScript("OnMouseWheel", function(self, delta)
        local parentScroll = EXUI.RightScrollFrame
        if parentScroll and parentScroll:IsShown() then
            local current = parentScroll:GetVerticalScroll()
            parentScroll:SetVerticalScroll(current - (delta * 25))
        end
    end)

    eb:SetAutoFocus(false)
    eb:SetText(text or "")
    eb:SetFontObject("GameFontHighlight")
    eb:SetTextInsets(8, 8, 8, 8) -- 增加边距，更有呼吸感

    -- [Fix] 更新高度以适应内容，确保滚动条逻辑生效
    eb:SetScript("OnTextChanged", function(self, userInput)
        -- 自动伸缩高度：取可视高度和内容高度的较大者
        local contentH = self:GetNumLetters() * 15 -- 粗略估算，或者直接保持固定大高度
        -- 更好的做法：不做自动伸缩，只依赖 ScrollFrame。但为了点击体验，保持 SetSize(..., h)
        if options.onChanged then options.onChanged(self:GetText(), userInput) end
    end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    eb:SetScript("OnEditFocusGained", function() container:SetBackdropBorderColor(0.64, 0.19, 0.79, 1) end)
    eb:SetScript("OnEditFocusLost", function(self)
        container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        if options.onEditFocusLost then options.onEditFocusLost(self:GetText()) end
    end)

    container.editBox = eb
    function container:GetText() return self.editBox:GetText() end

    function container:SetText(t) self.editBox:SetText(t or "") end

    return container
end

-- =========================================================
-- 14. 交互式预览画板 (Interactive Preview Canvas)
-- =========================================================
function EXUI:CreatePreviewCanvas(parent, width, height, elementsData, callbacks)
    local canvas = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    canvas:SetSize(width, height)

    -- 画板背景 (网格或深色背景)
    canvas:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    canvas:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    canvas:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    -- 网格参考线 (辅助对齐)
    local gridLine = canvas:CreateTexture(nil, "BACKGROUND")
    gridLine:SetAllPoints()
    gridLine:SetColorTexture(1, 1, 1, 0.05)

    local centerLineH = canvas:CreateTexture(nil, "ARTWORK")
    centerLineH:SetHeight(1)
    centerLineH:SetPoint("LEFT"); centerLineH:SetPoint("RIGHT")
    centerLineH:SetPoint("CENTER")
    centerLineH:SetColorTexture(1, 1, 1, 0.2)

    local centerLineV = canvas:CreateTexture(nil, "ARTWORK")
    centerLineV:SetWidth(1)
    centerLineV:SetPoint("TOP"); centerLineV:SetPoint("BOTTOM")
    centerLineV:SetPoint("CENTER")
    centerLineV:SetColorTexture(1, 1, 1, 0.2)

    canvas.elements = {}
    canvas.selectedKey = nil

    local onSelect = callbacks and callbacks.onSelect
    local onMove = callbacks and callbacks.onMove

    -- 内部方法：创建/更新子元素
    function canvas:UpdateElements(dataMap)
        -- 1. 隐藏所有旧元素
        for _, el in pairs(self.elements) do el:Hide() end

        -- 2. 遍历数据创建/显示元素
        for key, data in pairs(dataMap) do
            if data.enabled then
                local el = self.elements[key]
                if not el then
                    el = CreateFrame("Button", nil, self, "BackdropTemplate")
                    el:SetSize(100, 24) -- 默认基准大小
                    el:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8X8",
                        edgeFile = "Interface\\Buttons\\WHITE8X8",
                        edgeSize = 1,
                    })

                    el.text = el:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    el.text:SetPoint("CENTER")

                    -- 拖拽逻辑
                    el:SetMovable(true)
                    el:RegisterForDrag("LeftButton")
                    el:SetScript("OnDragStart", function(s)
                        if self.selectedKey ~= key then self:Select(key) end
                        s:StartMoving()
                    end)
                    el:SetScript("OnDragStop", function(s)
                        s:StopMovingOrSizing()
                        local cx, cy = self:GetCenter()
                        local ex, ey = s:GetCenter()

                        if not cx or not ex then return end

                        -- 计算相对坐标 (相对于 Canvas 中心)
                        local relX = ex - cx
                        local relY = ey - cy

                        -- 吸附逻辑 (简单取整)
                        relX = math.floor(relX + 0.5)
                        relY = math.floor(relY + 0.5)

                        s:ClearAllPoints()
                        s:SetPoint("CENTER", self, "CENTER", relX, relY)

                        if onMove then onMove(key, relX, relY) end
                    end)

                    -- 点击选择
                    el:SetScript("OnClick", function() self:Select(key) end)

                    self.elements[key] = el
                end

                -- 更新样式与位置
                el:Show()
                el.text:SetText(data.label or key)
                el:ClearAllPoints()
                el:SetPoint("CENTER", self, "CENTER", data.x or 0, data.y or 0)

                -- 根据是否选中设置外观
                if self.selectedKey == key then
                    el:SetBackdropColor(0, 0.5, 1, 0.6)
                    el:SetBackdropBorderColor(1, 1, 1, 1)
                else
                    el:SetBackdropColor(0.2, 0.2, 0.2, 0.6)
                    el:SetBackdropBorderColor(0, 0, 0, 0)
                end
            end
        end
    end

    function canvas:Select(key)
        self.selectedKey = key
        -- 刷新外观
        for k, el in pairs(self.elements) do
            if k == key then
                el:SetBackdropColor(0, 0.5, 1, 0.6)
                el:SetBackdropBorderColor(1, 1, 1, 1)
            else
                el:SetBackdropColor(0.2, 0.2, 0.2, 0.6)
                el:SetBackdropBorderColor(0, 0, 0, 0)
            end
        end
        if onSelect then onSelect(key) end
    end

    function canvas:ClearSelection()
        self:Select(nil)
    end

    if elementsData then
        canvas:UpdateElements(elementsData)
    end

    return canvas
end

-- =========================================================
-- 15. 分段控制器 (Segmented Control / Tabs)
-- items: { {label, value}, ... }
-- =========================================================
function EXUI:CreateSegmentedControl(parent, width, items, currentValue, onChange)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local height = 32
    container:SetSize(width, height)

    -- 胶囊背景
    container:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    container:SetBackdropColor(0.1, 0.1, 0.1, 1)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    container.buttons = {}

    local numItems = #items
    local btnWidth = (width - 4) / numItems

    for i, item in ipairs(items) do
        local label, value = item[1], item[2]

        local btn = CreateFrame("Button", nil, container, "BackdropTemplate")
        btn:SetSize(btnWidth, height - 4)
        btn:SetPoint("LEFT", container, "LEFT", 2 + (i - 1) * btnWidth, 0)

        -- 选中态背景
        btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
        btn:SetBackdropColor(0, 0, 0, 0) -- 默认透明

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("CENTER")
        text:SetText(label)
        btn.text = text

        btn:SetScript("OnClick", function()
            if currentValue == value then return end
            currentValue = value
            container:Refresh()
            if onChange then onChange(value) end
        end)

        btn.value = value
        container.buttons[i] = btn
    end

    -- 分割线
    for i = 1, numItems - 1 do
        local line = container:CreateTexture(nil, "OVERLAY")
        line:SetSize(1, height - 8)
        line:SetPoint("LEFT", container, "LEFT", 2 + i * btnWidth, 0)
        line:SetColorTexture(0.3, 0.3, 0.3, 1)
    end

    function container:Refresh()
        for _, btn in ipairs(self.buttons) do
            if btn.value == currentValue then
                -- 选中样式: 高亮背景 + 亮白文字
                btn:SetBackdropColor(0.2, 0.4, 0.8, 0.9)
                btn.text:SetTextColor(1, 1, 1)
            else
                -- 未选样式: 透明背景 + 灰色文字
                btn:SetBackdropColor(0, 0, 0, 0)
                btn.text:SetTextColor(0.6, 0.6, 0.6)
            end
        end
    end

    container:Refresh()

    return container
end

-- =========================================================
-- 16. 物品配置组件 (Item Config Widget)
-- 包含：Checkbox + Icon + ItemName + Input(Count) + DeleteBtn
-- 支持：物品拖拽（OnReceiveDrag）
-- =========================================================
function EXUI:CreateItemConfig(parent, width, height, itemID, db, onChange, onDelete)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local w = width or 320
    local h = height or 40
    container:SetSize(w, h)

    -- 背景
    container:SetBackdrop(EXUI.TooltipBackdrop)
    container:SetBackdropColor(0, 0, 0, 0.4)
    container:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)

    -- 1. 复选框 (启用/禁用)
    local cb = CreateFrame("CheckButton", nil, container, "MinimalCheckboxTemplate")
    cb:SetSize(24, 24)
    cb:SetPoint("LEFT", 5, 0)
    cb:SetChecked(db.enabled)
    cb:SetScript("OnClick", function(self)
        db.enabled = self:GetChecked()
        if onChange then onChange(db) end
    end)
    container.checkbox = cb

    -- 2. 物品图标
    local iconBtn = CreateFrame("Button", nil, container)
    iconBtn:SetSize(h - 10, h - 10)
    iconBtn:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    local icon = iconBtn:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    container.icon = icon

    -- 3. 物品名称
    local name = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    name:SetPoint("LEFT", iconBtn, "RIGHT", 8, 0)
    name:SetWidth(w - 140)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    container.nameText = name

    -- Tooltip 逻辑封装
    local function ShowTooltip(self)
        if itemID and itemID > 0 then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetItemByID(itemID)
            GameTooltip:Show()
        end
    end
    local function HideTooltip() GameTooltip:Hide() end

    -- 物品加载逻辑
    local function UpdateItem(id)
        if not id or id == 0 then
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            name:SetText(L["可将消耗品拖进来添加"])
            name:SetTextColor(0.5, 0.5, 0.5)
            return
        end
        local itemName, _, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(id)
        if itemName then
            icon:SetTexture(texture)
            name:SetText(itemName)
            local r, g, b = GetItemQualityColor(quality or 1)
            name:SetTextColor(r, g, b)
        else
            C_Item.RequestLoadItemDataByID(id)
            icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            name:SetText(L["数据加载中..."])
            C_Timer.After(0.5, function() UpdateItem(id) end)
        end
    end

    -- 事件上报逻辑
    local function HandleNewItemID(newID)
        local moduleKey = container.moduleKey
        local elementKey = container.elementKey
        if moduleKey and elementKey then
            ExwindTools:UpdateState(moduleKey .. ".ItemConfigUpdate", { key = elementKey, itemID = newID })
        end
        if onChange then onChange(db, newID) end
    end

    -- 绑定交互到容器：扩大 Tooltip 和拖放范围
    container:EnableMouse(true)
    container:SetScript("OnEnter", ShowTooltip)
    container:SetScript("OnLeave", HideTooltip)

    container:SetScript("OnReceiveDrag", function()
        local infoType, info1 = GetCursorInfo()
        local id
        if infoType == "item" then
            id = tonumber(info1)
        elseif infoType == "merchant" then
            id = GetMerchantItemID(info1)
        end

        if id then
            ClearCursor()
            UpdateItem(id)
            HandleNewItemID(id)
        end
    end)

    -- 同时也让图标按钮支持这些交互（因为层级在上）
    iconBtn:SetScript("OnEnter", ShowTooltip)
    iconBtn:SetScript("OnLeave", HideTooltip)
    iconBtn:RegisterForClicks("LeftButtonUp")
    iconBtn:SetScript("OnClick", function()
        local infoType, info1 = GetCursorInfo()
        local id
        if infoType == "item" then
            id = tonumber(info1)
        elseif infoType == "merchant" then
            id = GetMerchantItemID(info1)
        end

        if id then
            ClearCursor()
            UpdateItem(id)
            HandleNewItemID(id)
        end
    end)

    -- 4. 输入框
    local editBox = CreateFrame("EditBox", nil, container, "BackdropTemplate")
    editBox:SetSize(40, 24)
    editBox:SetPoint("RIGHT", -35, 0)
    editBox:SetBackdrop(EXUI.TooltipBackdrop)
    editBox:SetBackdropColor(0, 0, 0, 0.8)
    editBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    editBox:SetFontObject("GameFontHighlightSmall")
    editBox:SetJustifyH("CENTER")
    editBox:SetAutoFocus(false)
    editBox:SetNumeric(true)
    editBox:SetText(tostring(db.quantity or 1))
    editBox:SetScript("OnEnterPressed", function(self)
        db.quantity = tonumber(self:GetText()) or 1
        self:ClearFocus()
        if onChange then onChange(db) end
    end)
    editBox:SetScript("OnEditFocusLost", function(self)
        db.quantity = tonumber(self:GetText()) or 1
        if onChange then onChange(db) end
    end)
    container.editBox = editBox

    local qtyLabel = container:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    qtyLabel:SetPoint("RIGHT", editBox, "LEFT", -5, 0)
    qtyLabel:SetText(L["数量"])

    -- 5. 修改后的删除按钮
    local delBtn = CreateFrame("Button", nil, container)
    delBtn:SetSize(20, 20)
    delBtn:SetPoint("RIGHT", -5, 0)
    delBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    delBtn:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Highlight")
    delBtn:SetScript("OnClick", function()
        local moduleKey = container.moduleKey
        local elementKey = container.elementKey
        if moduleKey and elementKey then
            ExwindTools:UpdateState(moduleKey .. ".ItemConfigDelete", { key = elementKey })
        end
        if onDelete and type(onDelete) == "function" then onDelete() end
    end)
    container.delBtn = delBtn
    -- 支持布尔值标记或函数回调
    if not onDelete then delBtn:Hide() end

    UpdateItem(itemID)
    return container
end

-- =========================================================
-- 12. Glow 设置复合组件 (Glow Settings Group)
-- =========================================================
function EXUI:CreateGlowSettings(parent, width, label, db, key, onUpdate)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local groupWidth = width or 750
    local groupHeight = 280

    container:SetSize(groupWidth, groupHeight)

    -- 盒子外观
    container:SetBackdrop(EXUI.TooltipBackdrop)
    container:SetBackdropColor(0, 0, 0, 0.6)
    container:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    -- 标题区域
    local header = CreateFrame("Frame", nil, container)
    header:SetSize(groupWidth, 40)
    header:SetPoint("TOPLEFT")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", 15, 0)
    title:SetText(label or L["发光样式"])
    title:SetTextColor(1, 0.82, 0)
    container.labelText = title

    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT", 10, 5)
    line:SetPoint("BOTTOMRIGHT", -10, 5)
    line:SetHeight(1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))

    -- 内容容器
    local content = CreateFrame("Frame", nil, container)
    content:SetSize(groupWidth, groupHeight - 40)
    content:SetPoint("TOPLEFT", 0, -40)

    -- 布局坐标
    local col1, col2, col3 = 15, 275, 535
    local row1, row2, row3 = -25, -95, -165
    local itemW = 225

    local enableKey = key .. "Enabled"
    if db[enableKey] == nil then db[enableKey] = true end

    local cb = EXUI:CreateCheckbox(content, L["启用发光"], db[enableKey], function(checked)
        db[enableKey] = checked
        if onUpdate then onUpdate() end
    end)
    -- 注意：CreateCheckbox 返回一个容器，不是简单的 Button
    cb:SetPoint("TOPLEFT", col1, row1 - 5)


    -- 1. 样式选择 (Style Dropdown)
    local styleKey = key .. "Style"
    local styles = {
        { L["标准 (Classic)"], "Action Button Glow" },
        { L["像素 (Pixel)"], "Pixel Glow" },
        { L["自动施法 (AutoCast)"], "Autocast Shine" },
        { L["新版触发 (Proc)"], "Proc Glow" },
    }

    local styleDropdown = EXUI:CreateDropdown(content, itemW, L["样式类型"], styles, db[styleKey] or "Action Button Glow",
        function(val)
            db[styleKey] = val
            container:RefreshLayout()
            if onUpdate then onUpdate() end
        end)
    styleDropdown:SetPoint("TOPLEFT", col2, row1 - 10)

    -- 2. 颜色选择
    local colorBtn = EXUI:CreateColorButton(content, L["发光颜色"], db, key .. "Color", true, function()
        if onUpdate then onUpdate() end
    end)
    -- Color button matches generic button height
    colorBtn:SetPoint("TOPLEFT", col3, row1 - 10)

    -- 3. Sliders
    local sliders = {}
    local function CreateGlowSlider(sLabel, sKey, min, max, step, def)
        local itemKey = key .. sKey
        local s = EXUI:CreateSlider(content, itemW, sLabel, min, max, db[itemKey] or def, step, nil, function(v)
            db[itemKey] = v
            if onUpdate then onUpdate() end
        end)
        return s
    end

    sliders.Frequency = CreateGlowSlider(L["频率 (Frequency)"], "Frequency", 0.1, 5, 0.1, 0.25)
    sliders.Lines = CreateGlowSlider(L["线条 (Lines)"], "Lines", 1, 30, 1, 8)
    sliders.Scale = CreateGlowSlider(L["大小/粗细 (Scale)"], "Scale", 0.5, 3, 0.1, 1)
    sliders.Offset = CreateGlowSlider(L["边距 (Offset)"], "Offset", -50, 50, 1, 0)
    if db[key .. "Offset"] == nil then db[key .. "Offset"] = 0 end

    container.Sliders = sliders

    function container:RefreshLayout()
        local style = db[styleKey] or "Action Button Glow"

        if style == "Proc Glow" then colorBtn:Hide() else colorBtn:Show() end

        for _, s in pairs(sliders) do s:Hide() end

        -- Row 2 placement
        if style == "Action Button Glow" then
            sliders.Frequency:Show(); sliders.Frequency.Title:SetText(L["闪烁速度"]); sliders.Frequency:SetPoint("TOPLEFT", col1,
                row2)
        elseif style == "Pixel Glow" then
            sliders.Frequency:Show(); sliders.Frequency.Title:SetText(L["流动速度"]); sliders.Frequency:SetPoint("TOPLEFT", col1,
                row2)
            sliders.Lines:Show(); sliders.Lines.Title:SetText(L["线条数量"]); sliders.Lines:SetPoint("TOPLEFT", col2, row2)
            sliders.Scale:Show(); sliders.Scale.Title:SetText(L["线条粗细"]); sliders.Scale:SetPoint("TOPLEFT", col3, row2)
        elseif style == "Autocast Shine" then
            sliders.Frequency:Show(); sliders.Frequency.Title:SetText(L["闪烁速度"]); sliders.Frequency:SetPoint("TOPLEFT", col1,
                row2)
            sliders.Lines:Show(); sliders.Lines.Title:SetText(L["粒子数量"]); sliders.Lines:SetPoint("TOPLEFT", col2, row2)
            sliders.Scale:Show(); sliders.Scale.Title:SetText(L["粒子大小"]); sliders.Scale:SetPoint("TOPLEFT", col3, row2)
        end

        -- Row 3 placement (Offset)
        if style ~= "Proc Glow" then
            sliders.Offset:Show(); sliders.Offset:SetPoint("TOPLEFT", col1, row3)
        end
    end

    container:RefreshLayout()
    return container
end

-- =========================================================
-- 17. 图标设置组 (Icon Settings Group)
-- =========================================================
function EXUI:CreateIconGroup(parent, width, label, db, key, onUpdate)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local groupWidth = width or 750
    local groupHeight = 280

    -- [关键修复] 获取嵌套子表，如果不存在则初始化
    if key and not db[key] then db[key] = {} end
    local iconDb = key and db[key] or db

    container:SetSize(groupWidth, groupHeight)

    -- 盒子外观
    container:SetBackdrop(EXUI.TooltipBackdrop)
    container:SetBackdropColor(0, 0, 0, 0.6)
    container:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    -- 标题区域
    local header = CreateFrame("Frame", nil, container)
    header:SetSize(groupWidth, 40)
    header:SetPoint("TOPLEFT")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", 15, 0)
    title:SetText(label or L["图标设置"])
    title:SetTextColor(1, 0.82, 0)
    container.labelText = title

    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT", 10, 5)
    line:SetPoint("BOTTOMRIGHT", -10, 5)
    line:SetHeight(1)
    line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))

    -- 内容容器
    local content = CreateFrame("Frame", nil, container)
    content:SetSize(groupWidth, groupHeight - 40)
    content:SetPoint("TOPLEFT", 0, -40)

    -- 布局坐标
    local col1, col2, col3 = 15, 275, 535
    local row1, row2, row3 = -25, -95, -165
    local itemW = 225

    -- Row 1: IconID Input, Show Checkbox, Reverse Checkbox

    -- 1. 显示图标 (Checkbox) -> Col 1
    local cbShow = EXUI:CreateCheckbox(content, L["显示图标"], iconDb.showIcon, function(c)
        iconDb.showIcon = c
        if onUpdate then onUpdate() end
    end)
    cbShow:SetPoint("TOPLEFT", col1, row1 - 5)

    -- 2. 图标ID (IconID Input) -> Col 2
    local inputIcon = EXUI:CreateEditBox(
        content,
        tostring(iconDb.iconID or ""),
        itemW,
        32,
        L["图标ID (可选)"],
        {
            onEnter = function(v)
                iconDb.iconID = tonumber(v) or nil
                if onUpdate then onUpdate() end
            end,
            onEditFocusLost = function(v)
                iconDb.iconID = tonumber(v) or nil
                if onUpdate then onUpdate() end
            end,
            labelPos = "top"
        }
    )
    inputIcon:SetPoint("TOPLEFT", col2, row1 - 10)

    -- 3. 倒数反转 (Checkbox) -> Col 3
    local cbRev = EXUI:CreateCheckbox(content, L["倒数反转"], iconDb.reverse, function(c)
        iconDb.reverse = c
        if onUpdate then onUpdate() end
    end)
    cbRev:SetPoint("TOPLEFT", col3, row1 - 5)

    -- Row 2: Width, Height

    -- 4. 宽度 (Slider) -> Col 1
    local sWidth = EXUI:CreateSlider(content, itemW, L["宽度 (Width)"], 10, 300, iconDb.width or 64, 1, nil, function(v)
        iconDb.width = v
        if onUpdate then onUpdate() end
    end)
    sWidth:SetPoint("TOPLEFT", col1, row2)

    -- 5. 高度 (Slider) -> Col 2
    local sHeight = EXUI:CreateSlider(content, itemW, L["高度 (Height)"], 10, 300, iconDb.height or 64, 1, nil, function(v)
        iconDb.height = v
        if onUpdate then onUpdate() end
    end)
    sHeight:SetPoint("TOPLEFT", col2, row2)

    -- Row 3: X, Y Offset
    -- 6. X 偏移 (Slider) -> Col 1
    local sPosX = EXUI:CreateSlider(content, itemW, L["水平偏移 (X)"], -1000, 1000, iconDb.x or 0, 1, nil, function(v)
        iconDb.x = v
        if onUpdate then onUpdate() end
    end)
    sPosX:SetPoint("TOPLEFT", col1, row3)

    -- 7. Y 偏移 (Slider) -> Col 2
    local sPosY = EXUI:CreateSlider(content, itemW, L["垂直偏移 (Y)"], -1000, 1000, iconDb.y or 0, 1, nil, function(v)
        iconDb.y = v
        if onUpdate then onUpdate() end
    end)
    sPosY:SetPoint("TOPLEFT", col2, row3)

    return container
end

-- =========================================================
-- 18. 计时条设置组 (Timer Bar Settings Group)
-- [User Request] 封装包含尺寸/材质/颜色/图标的完整设置组
-- =========================================================
function EXUI:CreateTimerBarGroup(parent, width, label, db, key, onUpdate)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local groupWidth = width or 750
    local groupHeight = 440

    container:SetSize(groupWidth, groupHeight)
    container:SetBackdrop(EXUI.TooltipBackdrop)
    container:SetBackdropColor(0, 0, 0, 0.6)
    container:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    -- Header
    local header = CreateFrame("Frame", nil, container)
    header:SetSize(groupWidth, 40); header:SetPoint("TOPLEFT")
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", 15, 0); title:SetText(label or L["计时条设置"]); title:SetTextColor(1, 0.82, 0)
    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT", 10, 5); line:SetPoint("BOTTOMRIGHT", -10, 5)
    line:SetHeight(1); line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))

    local content = CreateFrame("Frame", nil, container)
    content:SetSize(groupWidth, groupHeight - 40); content:SetPoint("TOPLEFT", 0, -40)

    local col1, col2, col3 = 15, 275, 535
    local row1, row2 = -25, -75
    local div1 = -120
    local row3, row4 = -140, -190
    local div2 = -235
    local row5, row6 = -255, -305
    local itemW = 220

    local function AddDivider(y, text)
        local d = content:CreateTexture(nil, "ARTWORK")
        d:SetPoint("TOPLEFT", 10, y)
        d:SetPoint("TOPRIGHT", -10, y)
        d:SetHeight(1)
        d:SetTexture("Interface\\Buttons\\WHITE8X8")
        d:SetColorTexture(1, 1, 1, 0.1)
        if text then
            local t = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            t:SetPoint("BOTTOMLEFT", d, "TOPLEFT", 5, 2)
            t:SetText(text)
        end
    end

    -- Helper for Slider
    local function AddSlider(lbl, k, min, max, step, c, r, def)
        local val = db[k]
        if val == nil then val = def or min end
        local s = EXUI:CreateSlider(content, itemW, lbl, min, max, val, step, nil, function(v)
            db[k] = v; if onUpdate then onUpdate() end
        end)
        s:SetPoint("TOPLEFT", c, r)
    end

    -- Row 1: Width, Height
    AddSlider(L["宽度"], "width", 50, 500, 1, col1, row1, 200)
    AddSlider(L["高度"], "height", 10, 100, 1, col2, row1, 20)

    -- Row 2: Texture, FG, BG
    -- 如果 db.texture 在 LSM 里不存在（如未安装 SharedMedia），修正为 "Solid" 并立即通知模块
    if db.texture and not LSM:HashTable("statusbar")[db.texture] then
        db.texture = LSM:HashTable("statusbar")["Solid"] and "Solid" or LSM:GetDefault("statusbar")
        if onUpdate then onUpdate() end
    end
    local texDrop = EXUI:CreateLSMTextureDropdown(content, "statusbar", itemW, L["材质"], db.texture, function(k)
        db.texture = k; if onUpdate then onUpdate() end
    end)
    texDrop:SetPoint("TOPLEFT", col1, row2)

    local fgBtn = EXUI:CreateColorButton(content, L["前景色"], db, "barColor", true, onUpdate)
    fgBtn:SetPoint("TOPLEFT", col2, row2)

    local bgBtn = EXUI:CreateColorButton(content, L["背景色"], db, "barBgColor", true, onUpdate)
    bgBtn:SetPoint("TOPLEFT", col3, row2)

    AddDivider(div1, L["边框设置"])

    -- Row 3: Border settings
    local cbShowBorder = EXUI:CreateCheckbox(content, L["启用边框"], db.showBorder, function(v)
        db.showBorder = v; if onUpdate then onUpdate() end
    end)
    cbShowBorder:SetPoint("TOPLEFT", col1, row3)

    local borderDrop = EXUI:CreateLSMTextureDropdown(content, "border", itemW, L["边框材质"], db.borderTexture or "None",
        function(k)
            db.borderTexture = k; if onUpdate then onUpdate() end
        end)
    borderDrop:SetPoint("TOPLEFT", col2, row3)

    local borderBtn = EXUI:CreateColorButton(content, L["边框颜色"], db, "borderColor", true, onUpdate)
    borderBtn:SetPoint("TOPLEFT", col3, row3)

    -- Row 4: Border Size and Padding
    AddSlider(L["边框粗细"], "borderSize", 1, 32, 1, col1, row4, 12)
    AddSlider(L["边框间距 (Padding)"], "borderPadding", -16, 16, 1, col2, row4, 0)

    AddDivider(div2, L["图标设置"])

    -- Row 5: Icon Show, Side, Size
    local cbShow = EXUI:CreateCheckbox(content, L["显示图标"], db.showIcon, function(v)
        db.showIcon = v; if onUpdate then onUpdate() end
    end)
    cbShow:SetPoint("TOPLEFT", col1, row5)

    local sideOpts = { { L["左侧 (Left)"], "LEFT" }, { L["右侧 (Right)"], "RIGHT" } }
    local sideDrop = EXUI:CreateDropdown(content, itemW, L["图标位置"], sideOpts, db.iconSide or "LEFT", function(v)
        db.iconSide = v; if onUpdate then onUpdate() end
    end)
    sideDrop:SetPoint("TOPLEFT", col2, row5)
    if sideDrop.Label then sideDrop.Label:SetJustifyH("CENTER") end

    AddSlider(L["图标大小"], "iconSize", 8, 100, 1, col3, row5, 30)

    -- Row 6: Offset X, Y
    AddSlider(L["图标 X偏移"], "iconOffsetX", -100, 100, 1, col1, row6, 0)
    AddSlider(L["图标 Y偏移"], "iconOffsetY", -100, 100, 1, col2, row6, 0)

    return container
end

function EXUI:CreateTimerBarGroupV2(parent, width, label, db, key, onUpdate)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    local groupWidth = width or 750
    local groupHeight = 600

    container:SetSize(groupWidth, groupHeight)
    container:SetBackdrop(EXUI.TooltipBackdrop)
    container:SetBackdropColor(0, 0, 0, 0.6)
    container:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.8)

    local header = CreateFrame("Frame", nil, container)
    header:SetSize(groupWidth, 40); header:SetPoint("TOPLEFT")
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    title:SetPoint("LEFT", 15, 0); title:SetText(label or L["计时条设置"]); title:SetTextColor(1, 0.82, 0)
    local line = header:CreateTexture(nil, "ARTWORK")
    line:SetPoint("BOTTOMLEFT", 10, 5); line:SetPoint("BOTTOMRIGHT", -10, 5)
    line:SetHeight(1); line:SetTexture("Interface\\Buttons\\WHITE8X8")
    line:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.5), CreateColor(1, 1, 1, 0.05))

    local content = CreateFrame("Frame", nil, container)
    content:SetSize(groupWidth, groupHeight - 40); content:SetPoint("TOPLEFT", 0, -40)

    local col1, col2, col3 = 15, 275, 535
    local row1, row2 = -25, -75
    local div1 = -120
    local row3, row4 = -150, -200
    local div2 = -270
    local row5, row6 = -300, -350
    local div3 = -410
    local row7, row8 = -440, -490
    local itemW = 220

    local function AddDivider(y, text)
        local d = content:CreateTexture(nil, "ARTWORK")
        d:SetPoint("TOPLEFT", 10, y)
        d:SetPoint("TOPRIGHT", -10, y)
        d:SetHeight(1)
        d:SetTexture("Interface\\Buttons\\WHITE8X8")
        d:SetColorTexture(1, 1, 1, 0.1)
        if text then
            local t = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            t:SetPoint("BOTTOMLEFT", d, "TOPLEFT", 5, 8)
            t:SetText(text)
            t:SetTextColor(1, 1, 1, 1)
        end
    end

    local function AddSlider(lbl, k, min, max, step, c, r, def)
        local val = db[k]
        if val == nil then val = def or min end
        local s = EXUI:CreateSlider(content, itemW, lbl, min, max, val, step, nil, function(v)
            db[k] = v; if onUpdate then onUpdate() end
        end)
        s:SetPoint("TOPLEFT", c, r)
    end

    AddSlider(L["宽度"], "width", 50, 500, 1, col1, row1, 200)
    AddSlider(L["高度"], "height", 10, 100, 1, col2, row1, 20)

    if db.texture and not LSM:HashTable("statusbar")[db.texture] then
        db.texture = LSM:HashTable("statusbar")["Solid"] and "Solid" or LSM:GetDefault("statusbar")
        if onUpdate then onUpdate() end
    end
    local texDrop = EXUI:CreateLSMTextureDropdown(content, "statusbar", itemW, L["材质"], db.texture, function(k)
        db.texture = k; if onUpdate then onUpdate() end
    end)
    texDrop:SetPoint("TOPLEFT", col1, row2)

    local fgBtn = EXUI:CreateColorButton(content, L["前景色"], db, "barColor", true, onUpdate)
    fgBtn:SetPoint("TOPLEFT", col2, row2)

    local bgBtn = EXUI:CreateColorButton(content, L["背景色"], db, "barBgColor", true, onUpdate)
    bgBtn:SetPoint("TOPLEFT", col3, row2)

    AddDivider(div1, L["边框设置"])

    local cbShowBorder = EXUI:CreateCheckbox(content, L["启用边框"], db.showBorder, function(v)
        db.showBorder = v; if onUpdate then onUpdate() end
    end)
    cbShowBorder:SetPoint("TOPLEFT", col1, row3)

    local borderDrop = EXUI:CreateLSMTextureDropdown(content, "border", itemW, L["边框材质"], db.borderTexture or "None",
        function(k)
            db.borderTexture = k; if onUpdate then onUpdate() end
        end)
    borderDrop:SetPoint("TOPLEFT", col2, row3)

    local borderBtn = EXUI:CreateColorButton(content, L["边框颜色"], db, "borderColor", true, onUpdate)
    borderBtn:SetPoint("TOPLEFT", col3, row3)

    AddSlider(L["边框粗细"], "borderSize", 1, 32, 1, col1, row4, 12)
    AddSlider(L["边框间距 (Padding)"], "borderPadding", -16, 16, 1, col2, row4, 0)

    AddDivider(div2, L["图标设置"])

    local cbShow = EXUI:CreateCheckbox(content, L["显示图标"], db.showIcon, function(v)
        db.showIcon = v; if onUpdate then onUpdate() end
    end)
    cbShow:SetPoint("TOPLEFT", col1, row5)

    local sideOpts = { { L["左侧 (Left)"], "LEFT" }, { L["右侧 (Right)"], "RIGHT" } }
    local sideDrop = EXUI:CreateDropdown(content, itemW, L["图标位置"], sideOpts, db.iconSide or "LEFT", function(v)
        db.iconSide = v; if onUpdate then onUpdate() end
    end)
    sideDrop:SetPoint("TOPLEFT", col2, row5)
    if sideDrop.Label then sideDrop.Label:SetJustifyH("CENTER") end

    AddSlider(L["图标大小"], "iconSize", 8, 100, 1, col3, row5, 30)
    AddSlider(L["图标 X偏移"], "iconOffsetX", -100, 100, 1, col1, row6, 0)
    AddSlider(L["图标 Y偏移"], "iconOffsetY", -100, 100, 1, col2, row6, 0)

    AddDivider(div3, L["图标边框设置"])

    local cbShowIconBorder = EXUI:CreateCheckbox(content, L["启用图标边框"], db.showIconBorder, function(v)
        db.showIconBorder = v; if onUpdate then onUpdate() end
    end)
    cbShowIconBorder:SetPoint("TOPLEFT", col1, row7)

    local iconBorderDrop = EXUI:CreateLSMTextureDropdown(content, "border", itemW, L["图标边框材质"], db.iconBorderTexture or "None",
        function(k)
            db.iconBorderTexture = k; if onUpdate then onUpdate() end
        end)
    iconBorderDrop:SetPoint("TOPLEFT", col2, row7)

    local iconBorderBtn = EXUI:CreateColorButton(content, L["图标边框颜色"], db, "iconBorderColor", true, onUpdate)
    iconBorderBtn:SetPoint("TOPLEFT", col3, row7)

    AddSlider(L["图标边框粗细"], "iconBorderSize", 1, 32, 1, col1, row8, 1)
    AddSlider(L["图标边框间距 (Padding)"], "iconBorderPadding", -16, 16, 1, col2, row8, 0)

    return container
end
