-- [[ 大米法术手册 (Spell Info) ]]
-- { Key = "ExM+Info.SpellInfo", Name = "大米法术手册", Desc = "全能的大秘境怪物与技能百科全书。支持 3D 模型预览及法术数值模拟。", Category = 2 },

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })
local EXState = ExwindTools.State

-- 1. 识别 Key
local EXWIND_MODULE_KEY = "ExM+Info.SpellInfo"

-- 2. 载入检查
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EXDB = _G.EXDB

-- =========================================================
-- [v4.2] 注册与配置
-- =========================================================

-- 1. Grid 布局
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 47, h = 2, label = L["大米法术手册 (Mythic Spell Guide)"], labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 47, h = 1, label = L["此模块提供了一个极度详细的地下城百科，涵盖所有层数下的怪物技能数值。"] },
        { key = "open", type = "button", x = 1, y = 6, w = 15, h = 2, label = L["立即打开手册"] },
        { key = "sub_sim", type = "subheader", x = 1, y = 9, w = 47, h = 1, label = L["数值模拟 (全局同步)"] },
        { key = "mythicLevel", type = "slider", x = 1, y = 12, w = 24, h = 2, label = L["模拟层数"], min = 0, max = 30, parentKey = "ExM+.MythicDamage" },
        { key = "info", type = "description", x = 1, y = 15, w = 47, h = 2, label = "|cff888888" .. L["注：模拟层数与“大秘境伤害计算”模块共享数据。"] .. "|r" },
    }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

-- 3. 立即注册
EX_RegisterLayout()


ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(data)
    if data.key == "open" then
        if SlashCmdList and SlashCmdList["EXSP"] then SlashCmdList["EXSP"]() end
    end
end)

-- =========================================================
-- 核心业务逻辑
-- =========================================================



--@@ 主标题文字
local EXWIND_MAIN_TITLE_TEXT = "Exwind 大米法术详细信息"
--@@ 调试模式开关
local EXWIND_DEBUG_MODE = false

EXSP = EXSP or {}
EXSP.Tabs = {}
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local EX_FACTORY = _G.ExwindFactory

-- 字体配置 (严格对接 ExwindTools 主指针)
local EXSP_DEFAULT_FONT = ExwindTools.MAIN_FONT or STANDARD_TEXT_FONT
local EXSP_FALLBACK_FONT = ExwindTools.MAIN_FONT

local function EXSP_BuildDungeonIconMap()
    local mapInfoByName = {}
    local mapIDs = C_ChallengeMode.GetMapTable()
    if not mapIDs then return mapInfoByName end

    for _, mapID in ipairs(mapIDs) do
        local mapName, _, _, icon = C_ChallengeMode.GetMapUIInfo(mapID)
        if mapName and mapName ~= "" then
            mapInfoByName[mapName] = {
                mapID = mapID,
                icon = icon,
            }
        end
    end

    return mapInfoByName
end

-------------------------------------------------------------------
-- 主逻辑
-------------------------------------------------------------------

-- 法术标签
function EXSP_GetTagsForSpell(spellID)
    if not spellID then return {} end
    local tags = {}
    local function ex_hasValue(tab, val)
        if not tab then return false end
        for _, v in ipairs(tab) do if v == val then return true end end
        return false
    end
    -- MISC
    if ex_hasValue(EXSP.aoe_List, spellID) then table.insert(tags, "aoe") end
    if ex_hasValue(EXSP.los_List, spellID) then table.insert(tags, "los") end
    if ex_hasValue(EXSP.interrupt_List, spellID) then table.insert(tags, "interrupt") end
    if ex_hasValue(EXSP.noReflect_List, spellID) then table.insert(tags, "noReflect") end
    if ex_hasValue(EXSP.alwaysHit_List, spellID) then table.insert(tags, "alwaysHit") end
    if ex_hasValue(EXSP.noBlock_List, spellID) then table.insert(tags, "noBlock") end
    if ex_hasValue(EXSP.noDodge_List, spellID) then table.insert(tags, "noDodge") end
    if ex_hasValue(EXSP.noParry_List, spellID) then table.insert(tags, "noParry") end

    -- 驱散
    if ex_hasValue(EXSP.DispelBleed_List, spellID) then table.insert(tags, "DispelBleed") end
    if ex_hasValue(EXSP.DispelCurse_List, spellID) then table.insert(tags, "DispelCurse") end
    if ex_hasValue(EXSP.DispelDisease_List, spellID) then table.insert(tags, "DispelDisease") end
    if ex_hasValue(EXSP.DispelEnrage_List, spellID) then table.insert(tags, "DispelEnrage") end
    if ex_hasValue(EXSP.DispelMagic_List, spellID) then table.insert(tags, "DispelMagic") end
    if ex_hasValue(EXSP.DispelPoison_List, spellID) then table.insert(tags, "DispelPoison") end

    -- 控制
    if ex_hasValue(EXSP.MechanicAsleep_List, spellID) then table.insert(tags, "MechanicAsleep") end
    if ex_hasValue(EXSP.MechanicBleeding_List, spellID) then table.insert(tags, "MechanicBleeding") end
    if ex_hasValue(EXSP.MechanicDisoriented_List, spellID) then table.insert(tags, "MechanicDisoriented") end
    if ex_hasValue(EXSP.MechanicEnraged_List, spellID) then table.insert(tags, "MechanicEnraged") end
    if ex_hasValue(EXSP.MechanicFrozen_List, spellID) then table.insert(tags, "MechanicFrozen") end
    if ex_hasValue(EXSP.MechanicPolymorphed_List, spellID) then table.insert(tags, "MechanicPolymorphed") end
    if ex_hasValue(EXSP.MechanicRooted_List, spellID) then table.insert(tags, "MechanicRooted") end
    if ex_hasValue(EXSP.MechanicSnared_List, spellID) then table.insert(tags, "MechanicSnared") end
    if ex_hasValue(EXSP.MechanicSnared_List, spellID) then table.insert(tags, "MechanicSnared") end
    if ex_hasValue(EXSP.MechanicStunned_List, spellID) then table.insert(tags, "MechanicStunned") end
    if ex_hasValue(EXSP.MechanicFleeing_List, spellID) then table.insert(tags, "MechanicFleeing") end

    if EXWIND_DEBUG_MODE and #tags > 0 then
        print("|cff00ffff[EXSP 调试]|r 法术ID:", spellID, "匹配标签:", table.concat(tags, ","))
    end
    return tags
end

-- 模型交互
function EXSP_SetupModelInteractions(model)
    model:EnableMouse(true)
    model:EnableMouseWheel(true)
    model.ex_curRotation = 0
    model:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.ex_isDragging = true
            self.ex_startX = GetCursorPosition()
        end
    end)
    model:SetScript("OnMouseUp", function(self)
        self.ex_isDragging = false
    end)
    model:SetScript("OnUpdate", function(self)
        if self.ex_isDragging then
            local cx = GetCursorPosition()
            --@@ 这里修改模型旋转灵敏度 (0.015)
            local diff = (cx - (self.ex_startX or cx)) / self:GetEffectiveScale()
            self.ex_curRotation = self.ex_curRotation + (diff * 0.015)
            self:SetRotation(self.ex_curRotation)
            self.ex_startX = cx
        end
    end)
    model:SetScript("OnMouseWheel", function(self, delta)
        --@@ 这里修改滚轮缩放幅度 (0.15)
        local zoom = (self.ex_zoomLevel or 0) + delta * 0.15
        self.ex_zoomLevel = math.max(0, math.min(1.5, zoom))
        self:SetPortraitZoom(self.ex_zoomLevel)
    end)
end

-- 安全初始化模型
function EXSP_SafeModelInit(model)
    model:ClearModel()
    model:SetPosition(0, 0, 0)
    model:SetRotation(0)
    model.ex_curRotation = 0
    model.ex_zoomLevel = 0
    EXSP_SetupModelInteractions(model)
end

function EXSP_DoCache()
    if not EXSP.Database then return end
    for _, mobs in pairs(EXSP.Database) do
        for _, d in pairs(mobs) do
            for _, id in ipairs(d.spells) do
                C_Spell.RequestLoadSpellData(id)
            end
        end
    end
end

-------------------------------------------------------------------
-- 框架池 (已对接至 ExwindFactory)
-------------------------------------------------------------------

-- 初始化怪物按钮池
EX_FACTORY:InitPool("SpellInfo_MobButton", "Button", "BackdropTemplate", function(b)
    b:SetSize(275, 65)
    b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10, insets = { left = 2, right = 2, top = 2, bottom = 2 } })

    b.ex_selBar = b:CreateTexture(nil, "OVERLAY")
    b.ex_selBar:SetWidth(4)
    b.ex_selBar:SetPoint("TOPLEFT", 2, -2)
    b.ex_selBar:SetPoint("BOTTOMLEFT", 2, 2)
    b.ex_selBar:SetColorTexture(0, 0.7, 1, 1)

    b.portrait = b:CreateTexture(nil, "ARTWORK")
    b.portrait:SetSize(58, 58)
    b.portrait:SetPoint("LEFT", 4, 0)
    b.portrait:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    b.nameText = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.nameText:SetPoint("LEFT", b.portrait, "RIGHT", 12, 0)
end)

-- 初始化法术卡片池
EX_FACTORY:InitPool("SpellInfo_SpellFrame", "Frame", "BackdropTemplate", function(f)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(0, 0, 0, 0.8)
    f:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    f.ex_internalPool = {} -- 内部子控件池无需接入主框架，因为生命周期跟随卡片
end)

-------------------------------------------------------------------
-- UI 核心
-------------------------------------------------------------------

function EXSP.CreateMainFrame()
    EXSP.CurrentFont = EXSP_DEFAULT_FONT

    local f = CreateFrame("Frame", "EXSP_MainFrame", UIParent, "BackdropTemplate")
    -- 注册到 UISpecialFrames 以支持 ESC 键关闭
    tinsert(UISpecialFrames, "EXSP_MainFrame")
    --@@ 主框架大小 (1650,850)
    f:SetSize(1650, 850); f:SetPoint("CENTER"); f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(false)
    f:SetMovable(true); f:EnableMouse(true); f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving); f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f.ex_bgTexture = f:CreateTexture(nil, "BACKGROUND", nil, 1)
    f.ex_bgTexture:SetTexture("Interface\\AddOns\\ExwindTools\\DK.png")
    f.ex_bgTexture:SetAllPoints(); f.ex_bgTexture:SetAlpha(0.9)

    f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
    --@@ 黑色背景透明度 (0.95)
    f:SetBackdropColor(0, 0, 0, 0.95); f:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    f.Title = f:CreateFontString(nil, "OVERLAY")
    --@@ 主标题的字号 (25)
    f.Title:SetFont(EXSP.CurrentFont, 30, "OUTLINE")
    f.Title:SetPoint("TOP", 0, -12); f.Title:SetText(EXWIND_MAIN_TITLE_TEXT)



    -- 层数滑块 (集成 MythicDamage 逻辑)
    if _G.EXMD and ExwindTools.UI then
        local currentLevel = _G.EXMD.EX_DB.mythicLevel or 10

        -- 使用 ExwindUI 的封装 Slider
        local slider = ExwindTools.UI:CreateSlider(
            f, -- parent
            220, -- width
            "模拟层数", -- label
            0, 30, -- min, max
            currentLevel, -- value
            1, -- step
            function(v) return string.format("|cffffd100%d|r 层", v) end, -- formatter
            function(value) -- onValueChanged callback
                value = math.floor(value + 0.5)
                if value ~= _G.EXMD.EX_DB.mythicLevel then
                    _G.EXMD.EX_DB.mythicLevel = value

                    -- 刷新当前面板
                    if EXSP.CurrentDungeon and EXSP.CurrentMob then
                        EXSP_RefreshRightPanel(EXSP.CurrentDungeon, EXSP.CurrentMob)
                    end

                    -- 通知外部模块刷新 (双向绑定)
                    -- 注意：ExwindState 使用 UpdateState 来触发回调
                    ExwindTools:UpdateState("ExM+.MythicDamage.DatabaseChanged", { key = "mythicLevel", value = value })
                end
            end
        )

        -- 布局调整
        slider:SetPoint("TOPRIGHT", -55, -20)

        EXSP.LevelSlider = slider

        -- 双向绑定：监听外部变化
        ExwindTools:WatchState("ExM+.MythicDamage.DatabaseChanged", EXWIND_MODULE_KEY, function()
            local newLevel = _G.EXMD.EX_DB.mythicLevel or 10
            if EXSP.LevelSlider and EXSP.LevelSlider:GetValue() ~= newLevel then
                EXSP.LevelSlider:SetValue(newLevel)
            end
        end)
    end

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", 0, 0)

    -- 副本切换图标
    local dungeonIconMap = EXSP_BuildDungeonIconMap()
    for i, name in ipairs(EXSP.DungeonList) do
        local tab = CreateFrame("Button", nil, f)
        --@@ 副本图标尺寸 (60x60)
        tab:SetSize(60, 60); tab:SetPoint("TOPLEFT", 25 + (i - 1) * 75, -45)
        local tex = tab:CreateTexture(nil, "ARTWORK"); tex:SetAllPoints(); tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        local dungeonInfo = dungeonIconMap[name]
        local icon = dungeonInfo and dungeonInfo.icon
        tex:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark"); tab.icon = tex
        local sub = tab:CreateFontString(nil, "OVERLAY")
        --@@ 副本名称字号 (18)
        sub:SetFont(EXSP.CurrentFont, 18, "OUTLINE"); sub:SetPoint("TOP", tab, "BOTTOM", 0, -2); sub:SetText(EXSP
            .DungeonAbbr[name] or name); tab.text = sub
        tab:SetScript("OnClick",
            function()
                for _, t in ipairs(EXSP.Tabs) do t.icon:SetDesaturated(true) end
                tab.icon:SetDesaturated(false); EXSP_RefreshMobList(name)
            end)
        EXSP.Tabs[i] = tab
    end

    -- 搜索框
    local search = CreateFrame("EditBox", "EXSP_Search", f, "InputBoxTemplate")
    --@@ 搜索框的宽度 (275)
    search:SetSize(275, 30); search:SetPoint("TOPLEFT", 20, -140); search:SetAutoFocus(false)
    search:SetText(L["搜索怪物..."]); search:SetTextInsets(10, 10, 0, 0)
    search:SetScript("OnTextChanged",
        function(s) if EXSP.CurrentDungeon then EXSP_RefreshMobList(EXSP.CurrentDungeon, s:GetText()) end end)

    local mobSF = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate"); mobSF:SetSize(285, 600); mobSF
        :SetPoint("TOPLEFT", 20, -180)
    local mobChild = CreateFrame("Frame", nil, mobSF); mobChild:SetSize(270, 1); mobSF:SetScrollChild(mobChild)
    EXSP.MobScroll = mobSF
    --@@ 模组框的高宽 (500, 500) 定位(左上,345,-140)
    local model = CreateFrame("PlayerModel", "EXSP_MainModel", f); model:SetSize(555, 410); model:SetPoint("TOPLEFT", 345,
        -135)
    EXSP_SafeModelInit(model); EXSP.ModelFrame = model

    -- NPC 名称
    local infoPanel = CreateFrame("Frame", nil, f); infoPanel:SetSize(750, 200); infoPanel:SetPoint("TOP", model,
        "BOTTOM", 0, -15)
    EXSP.NPCInfoPanel = infoPanel
    infoPanel.Name = infoPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal"); infoPanel.Name:SetPoint("TOP", 0, 0)
    infoPanel.TopLine = infoPanel:CreateTexture(nil, "OVERLAY"); infoPanel.TopLine:SetHeight(2); infoPanel.TopLine
        :SetPoint("BOTTOM", infoPanel.Name, "TOP", 0, 8); infoPanel.TopLine:SetColorTexture(1, 0.82, 0, 0.4)
    infoPanel.BottomLine = infoPanel:CreateTexture(nil, "OVERLAY"); infoPanel.BottomLine:SetHeight(2); infoPanel
        .BottomLine:SetPoint("TOP", infoPanel.Name, "BOTTOM", 0, -8); infoPanel.BottomLine:SetColorTexture(1, 0.82, 0,
        0.4)

    infoPanel.CenterInfo = infoPanel:CreateFontString(nil, "OVERLAY"); infoPanel.CenterInfo:SetPoint("TOP",
        infoPanel.BottomLine, "BOTTOM", 0, -12); infoPanel.CenterInfo:SetJustifyH("CENTER")
    infoPanel.IDFootnote = infoPanel:CreateFontString(nil, "OVERLAY"); infoPanel.IDFootnote:SetPoint("TOP",
        infoPanel.CenterInfo, "BOTTOM", 0, -8); infoPanel.IDFootnote:SetJustifyH("CENTER")

    local spellSF = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate"); spellSF:SetSize(710, 640); spellSF
        :SetPoint("TOPLEFT", 915, -140)
    local spellChild = CreateFrame("Frame", nil, spellSF); spellChild:SetSize(700, 1); spellSF:SetScrollChild(spellChild)
    EXSP.SpellScroll = spellSF

    f:Hide(); EXSP.MainFrame = f

    -- 导出 Refresh 函数供外部调用
    EXSP.RefreshRightPanel = EXSP_RefreshRightPanel
end

-------------------------------------------------------------------
-- 刷新逻辑
-------------------------------------------------------------------

function EXSP_RefreshMobList(dungeonName, filter)
    EXSP.CurrentDungeon = dungeonName
    local container = EXSP.MobScroll:GetScrollChild()

    -- 使用 ExwindFactory 回收
    local children = { container:GetChildren() }
    for _, child in ipairs(children) do
        -- 仅回收该模块池子创建的按钮
        if child.poolType == "SpellInfo_MobButton" then
            EX_FACTORY:Release("SpellInfo_MobButton", child)
        else
            child:Hide()
        end
    end
    local mobs = EXSP.Database[dungeonName] or {}
    local sorted = {}
    for n in pairs(mobs) do table.insert(sorted, n) end
    table.sort(sorted)
    local firstBtn, idx = nil, 0
    filter = (filter and filter ~= "" and filter ~= L["搜索怪物..."]) and filter:lower() or nil
    for _, name in ipairs(sorted) do
        local data = mobs[name]
        if not filter or name:lower():find(filter) then
            -- 使用 ExwindFactory 获取
            local b = EX_FACTORY:Acquire("SpellInfo_MobButton", container)
            b.poolType = "SpellInfo_MobButton" -- 标记来源，方便回收
            b:SetPoint("TOPLEFT", 5, -(idx * 70) - 5)
            if EXSP.CurrentMob == name then
                b:SetBackdropColor(0.1, 0.4, 0.8, 0.3); b:SetBackdropBorderColor(0, 0.8, 1, 1); b.ex_selBar:Show()
            else
                b:SetBackdropColor(0.04, 0.04, 0.04, 0.8); b:SetBackdropBorderColor(0.4, 0.4, 0.4, 1); b.ex_selBar:Hide()
            end
            if data.displayID then
                SetPortraitTextureFromCreatureDisplayID(b.portrait, data.displayID); b.portrait:SetTexCoord(0.15, 0.85,
                    0.15, 0.85)
            end
            --@@ 左侧怪物名字体大小 (19)
            b.nameText:SetFont(EXSP.CurrentFont, 19, "OUTLINE"); b.nameText:SetText(name)
            b:SetScript("OnClick",
                function()
                    EXSP.CurrentMob = name; EXSP_RefreshRightPanel(dungeonName, name); EXSP_RefreshMobList(dungeonName,
                        filter)
                end)
            if not firstBtn then firstBtn = b end
            idx = idx + 1
        end
    end
    if firstBtn and not filter and not EXSP.CurrentMob then firstBtn:Click() end
end

function EXSP_RefreshRightPanel(dungeonName, mobName)
    -- [Fix] 支持作为 Method 调用 (EXSP:RefreshRightPanel) 以及无参调用
    if type(dungeonName) == "table" then dungeonName = nil end

    dungeonName = dungeonName or EXSP.CurrentDungeon
    mobName = mobName or EXSP.CurrentMob

    if not dungeonName or not mobName then return end

    local dungeonData = EXSP.Database[dungeonName]
    if not dungeonData then return end

    local data = dungeonData[mobName]
    local info = EXSP.NPCInfoPanel
    local font = EXSP_DEFAULT_FONT
    if not data then return end
    if EXSP.ModelFrame.lastID ~= data.displayID then
        EXSP.ModelFrame:SetDisplayInfo(data.displayID); EXSP.ModelFrame.lastID = data.displayID
    end

    --@@ 中间NPC名称字体大小 (52)
    info.Name:SetFont(font, 52, "OUTLINE"); info.Name:SetTextColor(1, 0.82, 0); info.Name:SetText(mobName)
    --@@ NPC名上下装饰线的宽度偏移 (10)
    local nameWidth = info.Name:GetStringWidth(); info.TopLine:SetWidth(-1); info.BottomLine:SetWidth(nameWidth + 100)

    -- NPC 详情信息
    local lvColor, lvSuffix = "|cff00ff00", ""
    if data.level == 91 then
        lvColor = "|cff0070dd"; lvSuffix = "(精英)"
    elseif data.level == 92 then
        lvColor = "|cffa335ee"; lvSuffix = "(首领)"
    end
    --@@ NPC名中间(生物类型+等级)字体大小 (24)
    info.CenterInfo:SetFont(font, 24, "OUTLINE")
    info.CenterInfo:SetText(string.format("|cffffffff%s|r    %sLV.%d%s|r", data.type or L["未知生物"], lvColor, data.level or 90,
        lvSuffix))
    --@@ NPC ID 字体大小 (18)
    info.IDFootnote:SetFont(font, 18, "OUTLINE"); info.IDFootnote:SetText("|cff888888NPCID:" ..
        (data.npcID or 0) .. "|r")

    local container = EXSP.SpellScroll:GetScrollChild()
    local children = { container:GetChildren() }
    for _, child in ipairs(children) do
        if child.poolType == "SpellInfo_SpellFrame" then
            EX_FACTORY:Release("SpellInfo_SpellFrame", child)
        else
            child:Hide()
        end
    end
    local last = nil
    if data.spells then
        for _, id in ipairs(data.spells) do
            local f = EXSP_UpdateSpellItem(container, id, data)
            --@@ 右侧法术技能之间的垂直间距 (8)
            if last then f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -8) else f:SetPoint("TOPLEFT", 0, 0) end
            last = f
        end
    end
end

-- 渲染法术
function EXSP_UpdateSpellItem(parent, spellID, mobData)
    -- 使用 ExwindFactory 获取
    local f = EX_FACTORY:Acquire("SpellInfo_SpellFrame", parent)
    f.poolType = "SpellInfo_SpellFrame"
    --@@ 法术卡片的总宽度 (690)
    f:SetWidth(690)
    if not f.ex_internalPool then f.ex_internalPool = {} end
    for _, obj in ipairs(f.ex_internalPool) do
        obj:Hide(); obj:ClearAllPoints()
    end

    local font = EXSP_DEFAULT_FONT
    local function AcquireObject(type)
        for _, obj in ipairs(f.ex_internalPool) do
            if not obj:IsShown() and obj:GetObjectType() == type then
                if type == "FontString" then
                    obj:SetWidth(0); obj:SetSpacing(0); obj:SetTextColor(1, 1, 1);
                    obj:SetFont(font, 22, "OUTLINE")
                end
                obj:Show(); return obj
            end
        end
        local obj = (type == "FontString") and f:CreateFontString(nil, "OVERLAY") or f:CreateTexture(nil, "ARTWORK")
        if type == "FontString" then obj:SetFont(font, 22, "OUTLINE") end
        obj:Show(); table.insert(f.ex_internalPool, obj); return obj
    end

    if not C_Spell.IsSpellDataCached(spellID) then
        C_Spell.RequestLoadSpellData(spellID)
        local t = AcquireObject("FontString"); t:SetPoint("CENTER"); t:SetText(L["缓存中..."]); f:SetHeight(30); return f
    end

    local tags = EXSP_GetTagsForSpell(spellID)
    local inlineTags, footerTags = {}, {}
    for _, tk in ipairs(tags) do
        local d = EXSP.TagDefs[tk]
        if d then if d.category >= 2 then table.insert(inlineTags, d) else table.insert(footerTags, d) end end
    end
    table.sort(inlineTags, function(a, b) return a.category < b.category end)

    local tip = C_TooltipInfo.GetSpellByID(spellID)

    --@@ 右侧法术图标大小 (42x42)
    local lastL, totalH, iSize = nil, 10, 42
    local icon = AcquireObject("Texture"); icon:SetSize(iSize, iSize); icon:SetPoint("TOPLEFT", 8, -8);
    icon:SetTexture(C_Spell.GetSpellInfo(spellID).iconID)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]

    for i, line in ipairs(tip.lines) do
        local fs = AcquireObject("FontString")
        --@@ 法术描述 标题 (20) 描述文本 (16) 的字体大小
        fs:SetFont(font, i == 1 and 20 or 16, "OUTLINE")
        --@@ 法术描述自动换行高度 (5)
        fs:SetSpacing(5)
        if line.leftColor then fs:SetTextColor(line.leftColor.r, line.leftColor.g, line.leftColor.b) end

        if i == 1 then
            fs:SetText(string.format("%s  |cff888888(%d)|r", line.leftText or "", spellID))
            fs:SetPoint("TOPLEFT", iSize + 18, -10)
            local inlineAnchor = fs
            for _, d in ipairs(inlineTags) do
                --@@ 法术描述category2.3的图案大小 (25)
                local itex = AcquireObject("Texture"); itex:SetSize(25, 25); itex:SetPoint("LEFT", inlineAnchor, "RIGHT",
                    15, 0); itex:SetTexture(d.icon)
                itex:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
                --@@ 法术描述category2.3的文字大小 (20)
                local ilbl = AcquireObject("FontString"); ilbl:SetWidth(0); ilbl:SetFont(font, 20, "OUTLINE"); ilbl
                    :SetPoint("LEFT", itex, "RIGHT", 5, 0); ilbl:SetText(d.name)
                inlineAnchor = ilbl
            end
        else
            --@@ 法术描述的最大宽度 (600)
            fs:SetWidth(600); fs:SetJustifyH("LEFT"); fs:SetWordWrap(true)
            --@@ 法术描述 上下间距 (-5)
            -- 处理伤害数字
            local displayText = line.leftText
            if _G.EXMD then
                displayText = _G.EXMD.ProcessDamageText(line.leftText, _G.EXMD.GetCurrentMultiplier(mobData))
            end
            fs:SetText(displayText); fs:SetPoint("TOPLEFT", lastL, "BOTTOMLEFT", 0, -5)
        end
        totalH = totalH + (fs:GetStringHeight() > 0 and fs:GetStringHeight() or 16) + 5
        lastL = fs
    end

    -- 渲染底部 (Category 1)
    if #footerTags > 0 then
        local l = AcquireObject("Texture"); l:SetSize(660, 1); l:SetPoint("TOPLEFT", 15, -totalH - 5); l:SetColorTexture(
            1, 1, 1, 0.1)
        totalH = totalH + 15; local prev = nil
        for _, d in ipairs(footerTags) do
            --@@ 法术MISC图标大小 (25,25)
            local ic = AcquireObject("Texture"); ic:SetSize(25, 25)
            if prev then ic:SetPoint("LEFT", prev, "RIGHT", 15, 0) else ic:SetPoint("TOPLEFT", 15, -totalH) end
            ic:SetTexture(d.icon)
            ic:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- [标准内裁剪]
            --@@ 法术MISC字体大小 (22)
            local lb = AcquireObject("FontString"); lb:SetWidth(0); lb:SetFont(font, 17, "OUTLINE"); lb:SetPoint("LEFT",
                ic, "RIGHT", 4, 0); lb:SetText(d.name); prev = lb
        end
        totalH = totalH + 28
    end
    f:SetHeight(math.max(iSize + 16, totalH + 12)); return f
end

-------------------------------------------------------------------
-- 事件监听 (已迁移至 ExwindTools 框架)
-------------------------------------------------------------------
ExwindTools:RegisterEvent("SPELL_TEXT_UPDATE", EXWIND_MODULE_KEY, function()
    if EXSP.MainFrame and EXSP.MainFrame:IsShown() and EXSP.CurrentMob then
        EXSP_RefreshRightPanel(EXSP.CurrentDungeon, EXSP.CurrentMob)
    end
end)

ExwindTools:RegisterEvent("SPELL_DATA_LOAD_RESULT", EXWIND_MODULE_KEY, function(_, spellID, success)
    if success and EXSP.MainFrame and EXSP.MainFrame:IsShown() and EXSP.CurrentMob then
        -- 判定当前选中的怪物的技能列表是否包含这个刚加载好的 spellID
        local data = EXSP.Database[EXSP.CurrentDungeon] and EXSP.Database[EXSP.CurrentDungeon][EXSP.CurrentMob]
        if data and data.spells then
            for _, id in ipairs(data.spells) do
                if id == spellID then
                    EXSP_RefreshRightPanel(EXSP.CurrentDungeon, EXSP.CurrentMob)
                    break
                end
            end
        end
    end
end)

SLASH_EXSP1 = "/EXSP"
SLASH_EXSP2 = "/EXSPELL"
SlashCmdList["EXSP"] = function()
    if not EXSP.MainFrame then EXSP.CreateMainFrame() end
    if EXSP.MainFrame:IsShown() then
        EXSP.MainFrame:Hide()
    else
        EXSP.MainFrame:Show(); if not EXSP.CurrentDungeon and EXSP.Tabs[1] then EXSP.Tabs[1]:Click() end
    end
end

-- 报告模块加载完成
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
