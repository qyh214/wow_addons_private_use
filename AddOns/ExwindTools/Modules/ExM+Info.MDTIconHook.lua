-- [[ MDT 法术图标替换 ]]
-- { Key = "ExM+Info.MDTIconHook", Name = "MDT 法术图标替换", Desc = "将 MDT 地图中怪物头像替换为法术图标，并支持自动团队标记。", Category = 2 },

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExM+Info.MDTIconHook"
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EXWIND_DEFAULTS = {
    enabled = true,
    useSpellIconMode = false,


    interruptMarkerIcon = "1", -- 默认骷髅
    eliteMarkerIcon = "8",     -- 默认星星

    customNPCIcons = {},
    blacklistNPCs = {},
    customIconsText = "", -- 缓存文本
    blacklistText = "",   -- 缓存文本
}
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)
EX_DB.customNPCIcons = EX_DB.customNPCIcons or {}
EX_DB.blacklistNPCs = EX_DB.blacklistNPCs or {}

local RAID_MARKER_DROPDOWN_ITEMS = {
    { L["无"], "0" },
    { L["星星 (1)"], "1" },
    { L["圆圈 (2)"], "2" },
    { L["菱形 (3)"], "3" },
    { L["三角 (4)"], "4" },
    { L["月亮 (5)"], "5" },
    { L["方块 (6)"], "6" },
    { L["叉叉 (7)"], "7" },
    { L["骷髅 (8)"], "8" },
}

local MDT_HOOK_INSTALLED = false
local MDT_BUTTONS_CREATED = false
local MDT_BUTTON_RETRY_PENDING = false
local MDT_PANEL_FRAME_HOOKED = false
local ELITE_LEVEL_BASE_CACHE = {}

local function RefreshMDTMap(silent)
    local MDT = _G.MDT
    local frame = MDT and MDT.main_frame
    if MDT and MDT.UpdateMap and frame and frame.sidePanel and frame.sidePanel.DifficultySlider then
        MDT:UpdateMap()
        if not silent then
            print("|cff00ff00[ExwindTools]|r " .. L["MDT 已刷新。"])
        end
    end
end

local function RefreshMDTMapDeferred(silent)
    local MDT = _G.MDT
    local frame = MDT and MDT.main_frame
    if MDT and MDT.Async and frame and frame.sidePanel and frame.sidePanel.DifficultySlider then
        MDT:Async(function()
            RefreshMDTMap(silent)
        end, "ExwindTools_MDTIconHook_RefreshMap", true)
        return
    end

    C_Timer.After(0, function()
        RefreshMDTMap(silent)
    end)
end

local function NormalizeMarkerIndex(value)
    local n = tonumber(value)
    if not n or n < 1 or n > 8 then
        return nil
    end
    return n
end

local function HasInterruptibleSpell(data)
    if not data or not data.spells then return false end
    for _, spellInfo in pairs(data.spells) do
        if type(spellInfo) == "table" and spellInfo.interruptible then
            return true
        end
    end
    return false
end

local function GetManualAssignment(enemyIdx, cloneIdx)
    local MDT = _G.MDT
    if not MDT or not MDT.GetCurrentPreset then return nil end
    local preset = MDT:GetCurrentPreset()
    local assignments = preset and preset.value and preset.value.enemyAssignments
    return assignments and assignments[enemyIdx] and assignments[enemyIdx][cloneIdx] or nil
end

local function GetCurrentDungeonEnemyTable()
    local MDT = _G.MDT
    if not MDT or not MDT.dungeonEnemies or not MDT.GetDB then return nil, nil end
    local db = MDT:GetDB()
    local dungeonIdx = db and db.currentDungeonIdx
    if not dungeonIdx then return nil, nil end
    return MDT.dungeonEnemies[dungeonIdx], dungeonIdx
end


local function GetEliteLevelBase()
    local enemies, dungeonIdx = GetCurrentDungeonEnemyTable()
    if not enemies or not dungeonIdx then return nil end

    local cached = ELITE_LEVEL_BASE_CACHE[dungeonIdx]
    if cached ~= nil then
        return cached or nil
    end

    local minLevel, maxLevel
    for _, enemy in pairs(enemies) do
        if enemy and not enemy.isBoss then
            local level = tonumber(enemy.level)
            if level then
                if not minLevel or level < minLevel then minLevel = level end
                if not maxLevel or level > maxLevel then maxLevel = level end
            end
        end
    end

    if not minLevel or not maxLevel or maxLevel <= minLevel then
        ELITE_LEVEL_BASE_CACHE[dungeonIdx] = false
        return nil
    end

    ELITE_LEVEL_BASE_CACHE[dungeonIdx] = minLevel
    return minLevel
end

local function IsEliteEnemy(data)
    if not data or data.isBoss then return false end
    local level = tonumber(data.level)
    if not level then return false end
    local baseLevel = GetEliteLevelBase()
    return baseLevel and level > baseLevel or false
end

local function ApplyCustomSettings()
    wipe(EX_DB.customNPCIcons)
    local rawMap = EX_DB.customIconsText or ""
    for line in rawMap:gmatch("[^\r\n]+") do
        local n, s = line:match("(%d+)%s*=%s*(%d+)")
        if n and s then
            EX_DB.customNPCIcons[tonumber(n)] = tonumber(s)
        end
    end

    wipe(EX_DB.blacklistNPCs)
    local rawBlack = EX_DB.blacklistText or ""
    for id in rawBlack:gmatch("(%d+)") do
        EX_DB.blacklistNPCs[tonumber(id)] = true
    end

    RefreshMDTMap(false)
end

local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 3, y = 1, w = 50, h = 2, label = L["MDT 法术图标替换 (MDT Icon Hook)"], labelSize = 25 },
        { key = "desc", type = "description", x = 3, y = 4, w = 50, h = 2, label = L["支持法术图标替换 + 一次性真团队标记（按钮写入 MDT 路线）"] },
        { key = "enabled", type = "checkbox", x = 3, y = 8, w = 10, h = 2, label = L["开启功能"] },
        { key = "divider_top", type = "divider", x = 3, y = 6, w = 50, h = 1, label = L["新组件"] },

        { key = "sub_c", type = "subheader", x = 3, y = 11, w = 21, h = 2, label = L["自定义图标 (NPCID = SpellID) 用回车换行分隔"] },
        { key = "customIconsText", type = "input", x = 3, y = 13, w = 24, h = 17, label = "" },
        { key = "sub_b", type = "subheader", x = 28, y = 11, w = 23, h = 2, label = L["黑名单 NPC (ID 用逗号分隔)"] },
        { key = "blacklistText", type = "input", x = 28, y = 13, w = 23, h = 17, label = "" },
        { key = "apply", type = "button", x = 3, y = 31, w = 48, h = 3, label = L["保存并刷新(文本配置要点这个才生效)"] },

        { key = "divider_marker", type = "divider", x = 3, y = 35, w = 50, h = 1, label = L["真团队标记（一次性写入）"] },
        { key = "marker_desc", type = "description", x = 3, y = 36, w = 49, h = 2, label = "|cff97a393" .. L["左侧/MDT按钮点击后写入当前路线；不会自动重写，也不负责清除。"] .. "|r" },

        { key = "interruptMarkerIcon", type = "dropdown", x = 3, y = 39, w = 16, h = 2, label = L["打断标记"], items = RAID_MARKER_DROPDOWN_ITEMS },
        { key = "btn_apply_interrupt_markers", type = "button", x = 22, y = 38, w = 29, h = 3, label = L["给所有打断怪上真标记"] },

        { key = "eliteMarkerIcon", type = "dropdown", x = 3, y = 42, w = 16, h = 2, label = L["精英标记"], items = RAID_MARKER_DROPDOWN_ITEMS },
        { key = "btn_apply_elite_markers", type = "button", x = 22, y = 41, w = 29, h = 3, label = L["给所有精英怪上真标记"] },
    }

    for _, item in ipairs(layout) do
        if item.key == "apply" then
            item.func = ApplyCustomSettings
            break
        end
    end

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

local function ApplyTrueMarkersByRule(ruleType)
    local MDT = _G.MDT
    if not MDT or not MDT.GetCurrentPreset or not MDT.GetDB then
        print("|cffff8800[ExwindTools]|r " .. L["未检测到 MDT，无法写入真标记。"])
        return false
    end

    local preset = MDT:GetCurrentPreset()
    local db = MDT:GetDB()
    local dungeonIdx = db and db.currentDungeonIdx
    if not preset or not preset.value or not dungeonIdx then
        print("|cffff8800[ExwindTools]|r " .. L["未检测到 MDT 当前路线，无法写入真标记。"])
        return false
    end

    local enemies = MDT.dungeonEnemies and MDT.dungeonEnemies[dungeonIdx]
    if not enemies then
        print("|cffff8800[ExwindTools]|r " .. L["当前副本没有 MDT 敌人数据。"])
        return false
    end

    local markerIndex
    local matchFunc
    local ruleName
    if ruleType == "interrupt" then
        markerIndex = NormalizeMarkerIndex(EX_DB.interruptMarkerIcon)
        matchFunc = HasInterruptibleSpell
        ruleName = L["打断怪"]
    elseif ruleType == "elite" then
        markerIndex = NormalizeMarkerIndex(EX_DB.eliteMarkerIcon)
        matchFunc = IsEliteEnemy
        ruleName = L["精英怪"]
    else
        return false
    end

    if not markerIndex then
        print("|cffff8800[ExwindTools]|r " .. L["请先选择有效的团队标记。"])
        return false
    end

    preset.value.enemyAssignments = preset.value.enemyAssignments or {}
    local assignments = preset.value.enemyAssignments

    local appliedCount, skippedManualCount = 0, 0
    for enemyIdx, data in pairs(enemies) do
        if data and matchFunc(data) then
            for cloneIdx, _ in pairs(data.clones or {}) do
                local current = assignments[enemyIdx] and assignments[enemyIdx][cloneIdx] or nil
                if current == nil then
                    assignments[enemyIdx] = assignments[enemyIdx] or {}
                    assignments[enemyIdx][cloneIdx] = markerIndex
                    appliedCount = appliedCount + 1
                else
                    skippedManualCount = skippedManualCount + 1
                end
            end
        end
    end

    RefreshMDTMap(true)
    print(string.format("|cff00ff00[ExwindTools]|r " .. L["已给%s写入 MDT 真标记: 新增%d, 跳过已有标记%d"],
        ruleName, appliedCount, skippedManualCount))
    return true
end

local function ClearAllTrueMarkers()
    local MDT = _G.MDT
    if not MDT or not MDT.GetCurrentPreset then return false end
    local preset = MDT:GetCurrentPreset()
    if not preset or not preset.value then return false end

    preset.value.enemyAssignments = {}
    RefreshMDTMap(true)
    print("|cff00ff00[ExwindTools]|r " .. L["已清除当前 MDT 路线的所有标记。"])
    return true
end

local function InitializeMDTVisuals()
    if MDT_HOOK_INSTALLED then return true end

    local Mixin = _G.MDTDungeonEnemyMixin
    if not Mixin or not Mixin.SetUp then
        return false
    end

    MDT_HOOK_INSTALLED = true

    hooksecurefunc(Mixin, "SetUp", function(self, data, clone)
        if not EX_DB.enabled or not data then return end

        -- 功能1：头像替换为法术图标（原有逻辑）
        if EX_DB.useSpellIconMode and not data.isBoss and not data.iconTexture and not EX_DB.blacklistNPCs[data.id] then
            local targetID = EX_DB.customNPCIcons[data.id] or data.SPELLICON or (data.spells and next(data.spells))
            if targetID then
                local tex = C_Spell.GetSpellTexture(targetID)
                if tex and self.texture_Portrait then
                    self.texture_Portrait:SetTexture(tex)
                    self.texture_Portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                end
            end
        end
    end)

    return true
end

local function UpdateMDTButtonsVisual()
    local toggleBtn = _G.ExMDT_Btn_ToggleIcon
    if toggleBtn and toggleBtn.Text then
        if EX_DB.useSpellIconMode then
            toggleBtn.Text:SetTextColor(0.2, 1, 0.2)   -- 绿色代表开启
        else
            toggleBtn.Text:SetTextColor(0.6, 0.6, 0.6) -- 灰色代表关闭
        end
    end
end

local function ApplyElvUISkin(frame)
    if not frame then return false end
    local Skin = ExwindTools.ElvUISkin
    if not Skin or not Skin:IsElvUILoaded() then return false end

    Skin:SkinFrame(frame, "Transparent")
    local E = _G.ElvUI and _G.ElvUI[1]
    local S = E and E:GetModule("Skins", true)
    if S and S.CreateShadowModule then
        _G.pcall(S.CreateShadowModule, S, frame)
    end
    if frame.CloseButton then Skin:SkinCloseButton(frame.CloseButton) end
    return true
end

local function UpdateMDTActionPanelPosition()
    local panel = _G.ExMDT_ActionPanel
    local MDT = _G.MDT
    local mainFrame = MDT and MDT.main_frame
    if not panel or not mainFrame then return end

    panel:ClearAllPoints()
    panel:SetPoint("TOP", mainFrame, "BOTTOM", 0, -10)
end

local function UpdateMDTActionPanelVisibility()
    local panel = _G.ExMDT_ActionPanel
    local MDT = _G.MDT
    local mainFrame = MDT and MDT.main_frame
    if not panel then return end

    if EX_DB.enabled and mainFrame and mainFrame:IsShown() then
        UpdateMDTActionPanelPosition()
        panel:Show()
    else
        panel:Hide()
    end
end

local function HookMDTMainFrame()
    if MDT_PANEL_FRAME_HOOKED then return end

    local MDT = _G.MDT
    local mainFrame = MDT and MDT.main_frame
    if not mainFrame then return end

    MDT_PANEL_FRAME_HOOKED = true
    mainFrame:HookScript("OnShow", function()
        C_Timer.After(0.05, UpdateMDTActionPanelVisibility)
    end)
    mainFrame:HookScript("OnHide", function()
        UpdateMDTActionPanelVisibility()
    end)
    mainFrame:HookScript("OnSizeChanged", function()
        UpdateMDTActionPanelPosition()
    end)
end

local function CreateMDTTextButton(name, parent, width, labelText, onClick)
    local btn = CreateFrame("Button", name, parent)
    btn:SetSize(width, 22)
    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    txt:SetPoint("CENTER")
    txt:SetText(labelText)
    btn.Text = txt

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, button)
        if button == "RightButton" and ExwindTools.OpenConfig then
            ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
        else
            onClick(self, button)
        end
    end)
    btn:SetScript("OnEnter", function(self)
        if txt:GetTextColor() ~= 0.2 then
            txt:SetTextColor(1, 1, 1)
        end
        if not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(labelText .. " (" .. L["右键打开设置"] .. ")", 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        UpdateMDTButtonsVisual()
        if GameTooltip then GameTooltip:Hide() end
    end)

    return btn
end

local function CreateMDTButtons()
    local MDT = _G.MDT
    if not MDT or not MDT.main_frame then
        if not MDT_BUTTON_RETRY_PENDING then
            MDT_BUTTON_RETRY_PENDING = true
            C_Timer.After(1, function()
                MDT_BUTTON_RETRY_PENDING = false
                CreateMDTButtons()
            end)
        end
        return false
    end

    if not _G.ExMDT_ActionPanel then
        local panel
        local Skin = ExwindTools.ElvUISkin
        local isElv = Skin and Skin:IsElvUILoaded()

        if isElv then
            panel = CreateFrame("Frame", "ExMDT_ActionPanel", UIParent)
            panel:SetSize(300, 94)

            local title = panel:CreateFontString(nil, "OVERLAY")
            title:SetFont(ExwindTools.MAIN_FONT, 15, "OUTLINE")
            title:SetPoint("TOP", 0, -8)
            title:SetTextColor(1, 0.82, 0)
            panel.TitleText = title

            local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
            close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)
            panel.CloseButton = close

            ApplyElvUISkin(panel)
        else
            panel = CreateFrame("Frame", "ExMDT_ActionPanel", UIParent, "DefaultPanelTemplate")
            panel:SetSize(300, 94)
        end

        panel:SetFrameStrata("MEDIUM")
        panel:SetToplevel(true)
        if panel.TitleText then
            panel.TitleText:SetText(L["MDT 快捷操作"])
        end

        if panel.CloseButton then
            panel.CloseButton:HookScript("OnClick", function()
                panel:Hide()
            end)
        end

        if _G.UISpecialFrames then
            local exists = false
            for _, frameName in ipairs(_G.UISpecialFrames) do
                if frameName == "ExMDT_ActionPanel" then
                    exists = true
                    break
                end
            end
            if not exists then
                table.insert(_G.UISpecialFrames, "ExMDT_ActionPanel")
            end
        end

        local content = CreateFrame("Frame", nil, panel)
        content:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -28)
        content:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 8)
        panel.Content = content

        local btnWidth = 132
        local btnHeight = 22

        local btnToggle = CreateMDTTextButton("ExMDT_Btn_ToggleIcon", content, btnWidth, L["替换图标"], function()
            EX_DB.useSpellIconMode = not EX_DB.useSpellIconMode
            RefreshMDTMap(true)
            UpdateMDTButtonsVisual()
        end)
        btnToggle:SetSize(btnWidth, btnHeight)
        btnToggle:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)

        local btnInt = CreateMDTTextButton("ExMDT_Btn_Int", content, btnWidth, L["标记打断"], function()
            ApplyTrueMarkersByRule("interrupt")
        end)
        btnInt:SetSize(btnWidth, btnHeight)
        btnInt:SetPoint("LEFT", btnToggle, "RIGHT", 8, 0)

        local btnElite = CreateMDTTextButton("ExMDT_Btn_Elite", content, btnWidth, L["标记精英"], function()
            ApplyTrueMarkersByRule("elite")
        end)
        btnElite:SetSize(btnWidth, btnHeight)
        btnElite:SetPoint("TOPLEFT", btnToggle, "BOTTOMLEFT", 0, -10)

        local btnClear = CreateMDTTextButton("ExMDT_Btn_Clear", content, btnWidth, L["清除标记"], function()
            ClearAllTrueMarkers()
        end)
        btnClear:SetSize(btnWidth, btnHeight)
        btnClear:SetPoint("LEFT", btnElite, "RIGHT", 8, 0)

        panel:Hide()
    end

    HookMDTMainFrame()
    UpdateMDTActionPanelPosition()
    MDT_BUTTONS_CREATED = true
    UpdateMDTButtonsVisual()
    UpdateMDTActionPanelVisibility()
    return true
end

local function TryBootstrapMDT()
    InitializeMDTVisuals()
    CreateMDTButtons()
    ELITE_LEVEL_BASE_CACHE = {}
end

TryBootstrapMDT()
C_Timer.After(0.1, TryBootstrapMDT)

ExwindTools:RegisterEvent("ADDON_LOADED", EXWIND_MODULE_KEY .. "_MDT", function(_, addonName)
    if addonName == "MythicDungeonTools" then
        C_Timer.After(0.2, function()
            ELITE_LEVEL_BASE_CACHE = {}
            TryBootstrapMDT()
        end)
    end
end)

-- Grid 配置变化后，刷新 MDT 地图与按钮外观
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    local key = info.key
    if key == "enabled"
        or key == "useSpellIconMode"
        or key == "interruptMarkerIcon"
        or key == "eliteMarkerIcon" then
        ELITE_LEVEL_BASE_CACHE = {}
        UpdateMDTButtonsVisual()
        UpdateMDTActionPanelVisibility()
        -- 一次性真标记方案：改配置不自动写入，避免干扰玩家在 MDT 里的手动操作
        if key == "enabled" or key == "useSpellIconMode" then
            RefreshMDTMapDeferred(true)
        end
    end
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end
    if info.key == "btn_apply_interrupt_markers" then
        ApplyTrueMarkersByRule("interrupt")
    elseif info.key == "btn_apply_elite_markers" then
        ApplyTrueMarkersByRule("elite")
    end
    UpdateMDTButtonsVisual()
end)

ExwindTools:ReportReady(EXWIND_MODULE_KEY)
