-- =============================================================
-- [[ 微型选单 ]]
-- { Key = "ExTools.MicroMenu", Name = "微型选单", Desc = "顶端微型选单：中间显示时间，左右各有可配置的面板快捷图标。", Category = 1 },
-- =============================================================
local ondev = true
if ondev then
    return
end

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end

local EXWIND_MODULE_KEY = "ExTools.MicroMenu"

-- =============================================================
-- 动作定义表
-- 每个槽位有独立的「图标」和「动作」，两者完全解耦。
-- 注意：游戏菜单(ShowUIPanel/ToggleGameMenu)属于受保护函数，
--       从插件调用会触发 ForceTaint_Strong，故不列入。
-- =============================================================
local ACTION_LIST = {
    -- id         = 唯一键，存入 DB
    -- label      = 显示名称
    -- atlas      = 暴雪原版图标（用于「暴雪原版」主题的默认图案）
    -- action     = 执行函数（nil = 无动作 或 custom 命令）
    { id = "none", label = "（无）", atlas = nil },
    {
        id = "character",
        label = "角色",
        atlas = "UI-HUD-MicroMenu-Portrait-Shadow",
        action = function()
            ToggleCharacter(
                "PaperDollFrame")
        end
    },
    {
        id = "spellbook",
        label = "法术书/天赋",
        atlas = "UI-HUD-MicroMenu-SpecTalents-Up",
        action = function()
            TogglePlayerSpellsFrame()
        end
    },
    {
        id = "achievement",
        label = "成就",
        atlas = "UI-HUD-MicroMenu-Achievements-Up",
        action = function()
            ToggleAchievementFrame()
        end
    },
    { id = "questlog", label = "任务日志", atlas = "UI-HUD-MicroMenu-Questlog-Up", action = function() ToggleQuestLog() end },
    { id = "guild", label = "公会/社区", atlas = "UI-HUD-MicroMenu-GuildCommunities-Up", action = function() ToggleGuildFrame() end },
    { id = "lfg", label = "寻求组队", atlas = "UI-HUD-MicroMenu-Groupfinder-Up", action = function() ToggleLFDParentFrame() end },
    {
        id = "collections",
        label = "收藏",
        atlas = "UI-HUD-MicroMenu-Collections-Up",
        action = function()
            ToggleCollectionsJournal()
        end
    },
    { id = "ej", label = "冒险指南", atlas = "UI-HUD-MicroMenu-AdventureGuide-Up", action = function() ToggleEncounterJournal() end },
    {
        id = "professions",
        label = "专业技能",
        atlas = "UI-HUD-MicroMenu-Professions-Up",
        action = function()
            ToggleProfessionsBook()
        end
    },
    {
        id = "housing",
        label = "家园",
        atlas = "UI-HUD-MicroMenu-Housing-Up",
        action = function()
            HousingFramesUtil
                .ToggleHousingDashboard()
        end
    },
    -- 自定义命令：action=nil，执行时读取 _cmd 字段
    { id = "custom", label = "自定义命令", atlas = "UI-HUD-MicroMenu-GameMenu-Up", action = nil },
}

-- id -> 定义 映射
local ACTION_BY_ID = {}
for _, a in ipairs(ACTION_LIST) do
    ACTION_BY_ID[a.id] = a
end

-- 下拉选项字符串（带 atlas 图标预览）
local ACTION_ITEMS_STR = (function()
    local t = {}
    for _, a in ipairs(ACTION_LIST) do
        if a.atlas then
            t[#t + 1] = CreateAtlasMarkup(a.atlas, 16, 16) .. " " .. a.label
        else
            t[#t + 1] = a.label
        end
    end
    return table.concat(t, ",")
end)()

-- label（含markup）-> id 映射（用于从 DB 值还原 id）
local ACTION_LABEL_TO_ID = {}
for _, a in ipairs(ACTION_LIST) do
    if a.atlas then
        ACTION_LABEL_TO_ID[CreateAtlasMarkup(a.atlas, 16, 16) .. " " .. a.label] = a.id
    end
    ACTION_LABEL_TO_ID[a.label] = a.id
    ACTION_LABEL_TO_ID[a.id]    = a.id
end

-- =============================================================
-- 图标主题系统
-- =============================================================

-- 图标语义顺序（与 ACTION_LIST 的 id 对应，用于图标选择器列顺序）
local ICON_SEMANTIC_IDS = {
    "character", "spellbook", "achievement", "questlog",
    "guild", "lfg", "collections", "ej",
    "professions", "housing", "custom",
}

local ADDON_PATH        = "Interface\\AddOns\\ExwindTools\\Textures\\Icons\\"

-- 主题注册表
local ICON_THEMES       = {
    {
        id   = "blizzard",
        name = "暴雪原版",
        type = "blizzard",
    },
    {
        id   = "cyberpunk",
        name = "赛博朋克",
        type = "custom",
        path = ADDON_PATH .. "cyberpunk\\",
    },
}

local THEME_BY_ID       = {}
local THEME_NAME_LIST   = {}
for _, t in ipairs(ICON_THEMES) do
    THEME_BY_ID[t.id]                     = t
    THEME_NAME_LIST[#THEME_NAME_LIST + 1] = t.name
end
local THEME_ITEMS_STR = table.concat(THEME_NAME_LIST, ",")

local THEME_NAME_TO_ID = {}
for _, t in ipairs(ICON_THEMES) do
    THEME_NAME_TO_ID[t.name] = t.id
    THEME_NAME_TO_ID[t.id]   = t.id
end

-- =============================================================
-- 常量
-- =============================================================
local MAX_SLOTS = 10

-- =============================================================
-- 工具：自定义命令执行（解析斜杠命令）
-- =============================================================
local function RunCustomCmd(cmd)
    if not cmd or cmd == "" then return end
    cmd = cmd:match("^%s*(.-)%s*$")
    if cmd == "" then return end
    local slash, args = cmd:match("^(/[^%s]+)%s*(.*)")
    if slash then
        slash = slash:upper()
        for k, v in pairs(_G.SlashCmdList) do
            local i = 1
            while true do
                local registered = _G["SLASH_" .. k .. i]
                if not registered then break end
                if registered:upper() == slash then
                    v(args or "")
                    return
                end
                i = i + 1
            end
        end
    end
    local editBox = ChatEdit_ChooseBoxForSend and ChatEdit_ChooseBoxForSend()
    if editBox then
        editBox:SetText(cmd)
        ChatEdit_SendText(editBox, 0)
    end
end

-- =============================================================
-- 默认配置
-- 每槽位三个字段：
--   _action = 动作 id（点击执行什么）
--   _icon   = 图案 id（显示什么图标，""=跟随主题默认）
--   _cmd    = 自定义命令（仅 action=custom 时生效）
-- =============================================================
local EX_DEFAULTS = {
    enabled = true,
    locked = true,
    iconSize = 28,
    barScale = 1.0,
    showBackground = true,
    bgAlpha = 0.6,
    timeFormat = "24小时制",
    showSeconds = false,
    posX = 0,
    posY = 0,
    posAnchor = "TOP",

    timeFontSize = 0,
    timeOffsetX = 0,
    timeOffsetY = 0,

    iconTheme = "blizzard",

    leftCount = 5,
    rightCount = 5,

    -- 左侧槽位默认值（_tip 留空=不显示 Tooltip）
    left1_action = "character",
    left1_icon = "",
    left1_cmd = "",
    left1_tip = "",
    left2_action = "questlog",
    left2_icon = "",
    left2_cmd = "",
    left2_tip = "",
    left3_action = "achievement",
    left3_icon = "",
    left3_cmd = "",
    left3_tip = "",
    left4_action = "lfg",
    left4_icon = "",
    left4_cmd = "",
    left4_tip = "",
    left5_action = "guild",
    left5_icon = "",
    left5_cmd = "",
    left5_tip = "",
    left6_action = "none",
    left6_icon = "",
    left6_cmd = "",
    left6_tip = "",
    left7_action = "none",
    left7_icon = "",
    left7_cmd = "",
    left7_tip = "",
    left8_action = "none",
    left8_icon = "",
    left8_cmd = "",
    left8_tip = "",
    left9_action = "none",
    left9_icon = "",
    left9_cmd = "",
    left9_tip = "",
    left10_action = "none",
    left10_icon = "",
    left10_cmd = "",
    left10_tip = "",

    -- 右侧槽位默认值
    right1_action = "spellbook",
    right1_icon = "",
    right1_cmd = "",
    right1_tip = "",
    right2_action = "professions",
    right2_icon = "",
    right2_cmd = "",
    right2_tip = "",
    right3_action = "collections",
    right3_icon = "",
    right3_cmd = "",
    right3_tip = "",
    right4_action = "ej",
    right4_icon = "",
    right4_cmd = "",
    right4_tip = "",
    right5_action = "housing",
    right5_icon = "",
    right5_cmd = "",
    right5_tip = "",
    right6_action = "none",
    right6_icon = "",
    right6_cmd = "",
    right6_tip = "",
    right7_action = "none",
    right7_icon = "",
    right7_cmd = "",
    right7_tip = "",
    right8_action = "none",
    right8_icon = "",
    right8_cmd = "",
    right8_tip = "",
    right9_action = "none",
    right9_icon = "",
    right9_cmd = "",
    right9_tip = "",
    right10_action = "none",
    right10_icon = "",
    right10_cmd = "",
    right10_tip = "",
}

-- =============================================================
-- Grid 布局定义
-- 每槽位三行控件：
--   行1：[图标选择按钮(8列)] [动作下拉(30列)] [空]
--   行2：[命令输入框(全宽)]  ← 仅 action=custom 时有意义，始终显示
-- =============================================================
local function EX_RegisterLayout()
    local function SlotRows(side, startY)
        local rows = {}
        local y = startY
        for i = 1, MAX_SLOTS do
            local actionKey = side .. i .. "_action"
            local iconKey   = side .. i .. "_iconbtn"
            local cmdKey    = side .. i .. "_cmd"
            local tipKey    = side .. i .. "_tip"

            -- 一行：[图案button 5列] [动作下拉 19列] [命令输入 12列] [Tooltip输入 12列]
            local label     = (side == "left" and "左" or "右") .. i
            rows[#rows + 1] = {
                key = iconKey,
                type = "button",
                x = 1,
                y = y,
                w = 5,
                h = 2,
                label = label,
            }
            rows[#rows + 1] = {
                key = actionKey,
                type = "dropdown",
                x = 7,
                y = y,
                w = 19,
                h = 2,
                label = "动作",
                items = ACTION_ITEMS_STR,
            }
            rows[#rows + 1] = {
                key = cmdKey,
                type = "input",
                x = 27,
                y = y,
                w = 12,
                h = 2,
                label = "自定义命令",
                placeholder = "/目标 boss1",
            }
            rows[#rows + 1] = {
                key = tipKey,
                type = "input",
                x = 40,
                y = y,
                w = 11,
                h = 2,
                label = "提示文字",
                placeholder = "留空不显示",
            }
            y               = y + 3
        end
        return rows, y
    end

    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 50, h = 2, label = "微型选单" },
        {
            key = "desc",
            type = "description",
            x = 1,
            y = 3,
            w = 50,
            h = 2,
            label = "顶端微型选单：中间时钟，左右各有可配置图标。图案与动作完全独立设置。"
        },

        { key = "div_basic", type = "divider", x = 1, y = 6, w = 50, h = 1 },
        { key = "sh_basic", type = "subheader", x = 1, y = 7, w = 50, h = 1, label = "基础设置" },

        { key = "enabled", type = "checkbox", x = 1, y = 9, w = 8, h = 2, label = "启用" },
        { key = "locked", type = "checkbox", x = 10, y = 9, w = 8, h = 2, label = "锁定位置" },
        { key = "showBackground", type = "checkbox", x = 19, y = 9, w = 8, h = 2, label = "显示背景" },

        { key = "iconSize", type = "slider", x = 1, y = 12, w = 16, h = 2, label = "图标大小", min = 16, max = 64, step = 1 },
        { key = "barScale", type = "slider", x = 19, y = 12, w = 16, h = 2, label = "整体缩放", min = 0.5, max = 2.0, step = 0.05 },
        { key = "bgAlpha", type = "slider", x = 36, y = 12, w = 14, h = 2, label = "背景透明度", min = 0, max = 1, step = 0.05 },

        { key = "div_theme", type = "divider", x = 1, y = 15, w = 50, h = 1 },
        { key = "sh_theme", type = "subheader", x = 1, y = 16, w = 50, h = 1, label = "图标风格" },
        { key = "iconTheme", type = "dropdown", x = 1, y = 18, w = 25, h = 2, label = "整体风格", items = THEME_ITEMS_STR },

        { key = "div_time", type = "divider", x = 1, y = 21, w = 50, h = 1 },
        { key = "sh_time", type = "subheader", x = 1, y = 22, w = 50, h = 1, label = "时间文字" },
        { key = "timeFormat", type = "dropdown", x = 1, y = 24, w = 16, h = 2, label = "时间格式", items = "24小时制,12小时制" },
        { key = "showSeconds", type = "checkbox", x = 19, y = 24, w = 8, h = 2, label = "显示秒数" },
        { key = "timeFontSize", type = "slider", x = 28, y = 24, w = 12, h = 2, label = "字体大小（0=自动）", min = 0, max = 36, step = 1 },
        { key = "timeOffsetX", type = "slider", x = 1, y = 27, w = 16, h = 2, label = "时间 X 偏移", min = -200, max = 200, step = 1 },
        { key = "timeOffsetY", type = "slider", x = 19, y = 27, w = 16, h = 2, label = "时间 Y 偏移", min = -50, max = 50, step = 1 },

        { key = "div_pos", type = "divider", x = 1, y = 30, w = 50, h = 1 },
        { key = "sh_pos", type = "subheader", x = 1, y = 31, w = 50, h = 1, label = "位置" },
        { key = "posAnchor", type = "dropdown", x = 1, y = 33, w = 20, h = 2, label = "锚点", items = "TOP,TOPLEFT,TOPRIGHT,CENTER,BOTTOM" },
        { key = "posX", type = "slider", x = 22, y = 33, w = 14, h = 2, label = "X 偏移", min = -1000, max = 1000, step = 1 },
        { key = "posY", type = "slider", x = 37, y = 33, w = 13, h = 2, label = "Y 偏移", min = -600, max = 600, step = 1 },
        { key = "btn_reset_pos", type = "button", x = 1, y = 36, w = 12, h = 2, label = "重置位置" },
    }

    -- 左侧槽位
    layout[#layout + 1] = { key = "div_left", type = "divider", x = 1, y = 39, w = 50, h = 1 }
    layout[#layout + 1] = { key = "sh_left", type = "subheader", x = 1, y = 40, w = 50, h = 1, label = "左侧图标槽位" }
    layout[#layout + 1] = {
        key = "leftCount",
        type = "slider",
        x = 1,
        y = 42,
        w = 16,
        h = 2,
        label = "左侧图标数量",
        min = 0,
        max =
            MAX_SLOTS,
        step = 1
    }

    local leftRows, leftEndY = SlotRows("left", 45)
    for _, row in ipairs(leftRows) do layout[#layout + 1] = row end

    -- 右侧槽位
    layout[#layout + 1] = { key = "div_right", type = "divider", x = 1, y = leftEndY, w = 50, h = 1 }
    layout[#layout + 1] = {
        key = "sh_right",
        type = "subheader",
        x = 1,
        y = leftEndY + 1,
        w = 50,
        h = 1,
        label =
        "右侧图标槽位"
    }
    layout[#layout + 1] = {
        key = "rightCount",
        type = "slider",
        x = 1,
        y = leftEndY + 3,
        w = 16,
        h = 2,
        label = "右侧图标数量",
        min = 0,
        max =
            MAX_SLOTS,
        step = 1
    }

    local rightRows, _ = SlotRows("right", leftEndY + 6)
    for _, row in ipairs(rightRows) do layout[#layout + 1] = row end

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

-- =============================================================
-- 载入检查
-- =============================================================
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)
local isEditModeActive = false
local isEditModeVisible = true
local editModeRestoreLocked = nil

-- =============================================================
-- 工具函数
-- =============================================================

-- 从 DB 值（可能是 label含markup / 纯label / id）还原 action id
local function GetActionIdFromDB(key)
    local val = EX_DB[key]
    if not val or val == "" then return "none" end
    return ACTION_LABEL_TO_ID[val] or "none"
end

-- 获取当前主题
local function GetCurrentTheme()
    local themeVal = EX_DB.iconTheme or "blizzard"
    return THEME_BY_ID[THEME_NAME_TO_ID[themeVal] or themeVal] or THEME_BY_ID["blizzard"]
end

-- 解析槽位图案覆盖，返回 (themeId, iconId)
-- _icon 格式：""=跟随主题, "themeId:iconId"=独立覆盖
local function GetSlotIconInfo(side, i, actionId)
    local override = EX_DB[side .. i .. "_icon"]
    if override and override ~= "" then
        -- 格式："cyberpunk:achievement"
        local themeId, iconId = override:match("^(.+):(.+)$")
        if themeId and iconId then
            return themeId, iconId
        end
    end
    -- 跟随全局主题，图案语义=动作id
    local theme = GetCurrentTheme()
    return theme.id, actionId
end

-- 将图标应用到纹理对象
local function ApplyIconToTex(tex, themeId, iconId)
    local theme = THEME_BY_ID[themeId] or THEME_BY_ID["blizzard"]
    if theme.type == "blizzard" then
        local actionDef = ACTION_BY_ID[iconId]
        if actionDef and actionDef.atlas then
            tex:SetAtlas(actionDef.atlas, false)
        else
            tex:SetColorTexture(0.3, 0.3, 0.3, 0.5)
        end
        tex:SetTexCoord(0, 1, 0, 1)
    else
        tex:SetTexture(theme.path .. iconId .. ".tga")
        tex:SetTexCoord(0, 1, 0, 1)
    end
    tex:SetAlpha(1.0)
end

-- 获取当前时间字符串
local function GetTimeString()
    local d                 = date("*t")
    local hour, minute, sec = d.hour, d.min, d.sec
    local format24          = EX_DB.timeFormat ~= "12小时制"
    if format24 then
        if EX_DB.showSeconds then
            return string.format("%02d:%02d:%02d", hour, minute, sec)
        else
            return string.format("%02d:%02d", hour, minute)
        end
    else
        local ampm = hour >= 12 and "PM" or "AM"
        local h12  = hour % 12
        if h12 == 0 then h12 = 12 end
        if EX_DB.showSeconds then
            return string.format("%d:%02d:%02d %s", h12, minute, sec, ampm)
        else
            return string.format("%d:%02d %s", h12, minute, ampm)
        end
    end
end

-- =============================================================
-- 图标选择器浮窗
-- =============================================================
local IconPicker       = {}
IconPicker.frame       = nil
IconPicker.targetSide  = nil
IconPicker.targetIndex = nil

local PICKER_CELL_SIZE = 40
local PICKER_PADDING   = 12

local function IconPicker_Close()
    if IconPicker.frame then IconPicker.frame:Hide() end
end

local function IconPicker_Refresh()
    local f = IconPicker.frame
    if not f then return end

    if f.cells then
        for _, cell in ipairs(f.cells) do
            cell:Hide(); cell:SetParent(nil)
        end
    end
    f.cells          = {}

    local themeCount = #ICON_THEMES
    local iconCount  = #ICON_SEMANTIC_IDS
    local totalW     = PICKER_PADDING * 2 + iconCount * PICKER_CELL_SIZE + (iconCount - 1) * 2
    local totalH     = PICKER_PADDING * 2 + 24 + themeCount * (PICKER_CELL_SIZE + 2) + 16 + 28
    f:SetSize(totalW, totalH)

    -- 标题
    if not f.titleText then
        f.titleText = f:CreateFontString(nil, "OVERLAY")
        f.titleText:SetFont(ExwindTools.MAIN_FONT, 13, "OUTLINE")
        f.titleText:SetTextColor(1, 1, 1, 1)
        f.titleText:SetPoint("TOPLEFT", f, "TOPLEFT", PICKER_PADDING, -PICKER_PADDING)
    end
    local sideLabel = IconPicker.targetSide == "left" and L["左"] or L["右"]
    f.titleText:SetText(L["选择图案"] .. "  [" .. sideLabel .. IconPicker.targetIndex .. "]")

    -- 列标题
    local colHeaderY = -PICKER_PADDING - 18
    for ci, iconId in ipairs(ICON_SEMANTIC_IDS) do
        local hdrKey = "colHdr" .. ci
        if not f[hdrKey] then
            local lbl = f:CreateFontString(nil, "OVERLAY")
            lbl:SetFont(ExwindTools.MAIN_FONT, 8, "OUTLINE")
            lbl:SetTextColor(0.7, 0.7, 0.7, 1)
            f[hdrKey] = lbl
        end
        local lbl = f[hdrKey]
        lbl:ClearAllPoints()
        lbl:SetPoint("TOPLEFT", f, "TOPLEFT",
            PICKER_PADDING + (ci - 1) * (PICKER_CELL_SIZE + 2), colHeaderY)
        lbl:SetWidth(PICKER_CELL_SIZE)
        lbl:SetJustifyH("CENTER")
        local actionDef = ACTION_BY_ID[iconId]
        lbl:SetText(actionDef and actionDef.label or iconId)
        lbl:Show()
    end

    -- 格子：每行=一套主题，每列=一个图案
    local currentKey  = IconPicker.targetSide .. IconPicker.targetIndex .. "_icon"
    local currentIcon = EX_DB[currentKey] or ""

    for ri, theme in ipairs(ICON_THEMES) do
        for ci, iconId in ipairs(ICON_SEMANTIC_IDS) do
            local cellX = PICKER_PADDING + (ci - 1) * (PICKER_CELL_SIZE + 2)
            local cellY = -(PICKER_PADDING + 24 + (ri - 1) * (PICKER_CELL_SIZE + 2))

            local cell = CreateFrame("Button", nil, f)
            cell:SetSize(PICKER_CELL_SIZE, PICKER_CELL_SIZE)
            cell:SetPoint("TOPLEFT", f, "TOPLEFT", cellX, cellY)
            cell:EnableMouse(true)
            cell:RegisterForClicks("AnyUp")

            local bg = cell:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
            cell.bg = bg

            -- 当前选中高亮边框
            if currentIcon == iconId then
                local border = cell:CreateTexture(nil, "OVERLAY")
                border:SetAllPoints()
                border:SetColorTexture(1, 0.8, 0, 0.4)
            end

            local iconTex = cell:CreateTexture(nil, "ARTWORK")
            iconTex:SetAllPoints()
            ApplyIconToTex(iconTex, theme.id, iconId)

            cell:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.3, 0.6, 1.0, 0.4)
                local actionDef = ACTION_BY_ID[iconId]
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(theme.name .. " · " .. (actionDef and actionDef.label or iconId), 1, 1, 1)
                GameTooltip:Show()
            end)
            cell:SetScript("OnLeave", function(self)
                self.bg:SetColorTexture(0.15, 0.15, 0.15, 0.9)
                GameTooltip:Hide()
            end)

            -- 存储格式："themeId:iconId"，例如 "cyberpunk:achievement"
            local capturedThemeId = theme.id
            local capturedIconId  = iconId
            cell:SetScript("OnClick", function()
                local key = IconPicker.targetSide .. IconPicker.targetIndex .. "_icon"
                EX_DB[key] = capturedThemeId .. ":" .. capturedIconId
                -- 用时间戳保证 UpdateState 一定触发（避免相同值跳过）
                ExwindTools:UpdateState(EXWIND_MODULE_KEY .. ".IconPickerApplied", GetTime())
                IconPicker_Close()
            end)

            f.cells[#f.cells + 1] = cell
        end
    end

    -- 「跟随动作」按钮（清除图案覆盖）
    if not f.resetBtn then
        f.resetBtn = CreateFrame("Button", nil, f)
        f.resetBtn:SetSize(110, 22)
        local btnTex = f.resetBtn:CreateTexture(nil, "BACKGROUND")
        btnTex:SetAllPoints()
        btnTex:SetColorTexture(0.2, 0.2, 0.2, 0.9)
        local btnLbl = f.resetBtn:CreateFontString(nil, "OVERLAY")
        btnLbl:SetFont(ExwindTools.MAIN_FONT, 11, "OUTLINE")
        btnLbl:SetTextColor(0.8, 0.8, 0.8, 1)
        btnLbl:SetText(L["↺ 跟随整体风格"])
        btnLbl:SetAllPoints()
        f.resetBtn:SetScript("OnClick", function()
            local key = IconPicker.targetSide .. IconPicker.targetIndex .. "_icon"
            EX_DB[key] = ""
            ExwindTools:UpdateState(EXWIND_MODULE_KEY .. ".IconPickerApplied", GetTime())
            IconPicker_Close()
        end)
        f.resetBtn:SetScript("OnEnter", function(_) btnTex:SetColorTexture(0.3, 0.3, 0.3, 0.9) end)
        f.resetBtn:SetScript("OnLeave", function(_) btnTex:SetColorTexture(0.2, 0.2, 0.2, 0.9) end)
    end
    local resetY = -(PICKER_PADDING + 24 + #ICON_THEMES * (PICKER_CELL_SIZE + 2) + 8)
    f.resetBtn:ClearAllPoints()
    f.resetBtn:SetPoint("BOTTOMLEFT", f, "TOPLEFT", PICKER_PADDING, resetY)

    -- 关闭按钮
    if not f.closeBtn then
        f.closeBtn = CreateFrame("Button", nil, f)
        f.closeBtn:SetSize(22, 22)
        local closeTex = f.closeBtn:CreateTexture(nil, "BACKGROUND")
        closeTex:SetAllPoints()
        closeTex:SetColorTexture(0.6, 0.1, 0.1, 0.9)
        local closeLbl = f.closeBtn:CreateFontString(nil, "OVERLAY")
        closeLbl:SetFont(ExwindTools.MAIN_FONT, 13, "OUTLINE")
        closeLbl:SetTextColor(1, 1, 1, 1)
        closeLbl:SetText("✕")
        closeLbl:SetAllPoints()
        f.closeBtn:SetScript("OnClick", IconPicker_Close)
        f.closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    end

    f:Show()
end

local function IconPicker_Open(side, index)
    if not IconPicker.frame then
        local f = CreateFrame("Frame", "ExMicroMenuIconPicker", UIParent, "BackdropTemplate")
        f:SetFrameStrata("TOOLTIP")
        f:SetFrameLevel(100)
        f:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        f:SetBackdropColor(0.05, 0.05, 0.08, 0.97)
        f:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function(self) self:StartMoving() end)
        f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        f:SetScript("OnKeyDown", function(_, key)
            if key == "ESCAPE" then IconPicker_Close() end
        end)
        f:SetPropagateKeyboardInput(true)
        f:Hide()
        IconPicker.frame = f
    end

    IconPicker.targetSide  = side
    IconPicker.targetIndex = index
    IconPicker.frame:ClearAllPoints()
    IconPicker.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    IconPicker_Refresh()
end

-- =============================================================
-- HUD 框架
-- =============================================================
local mainFrame    = nil
local leftBtns     = {}
local rightBtns    = {}
local timeText     = nil
local ticker       = nil
local editBgFrames = {}

-- 将当前主题+图案覆盖应用到按钮纹理
local function ApplyButtonIcon(btn, side, slotIndex, actionId)
    local themeId, iconId = GetSlotIconInfo(side, slotIndex, actionId)
    if iconId == "none" or not iconId or iconId == "" then
        btn.normalTex:SetColorTexture(0.3, 0.3, 0.3, 0.5)
        btn.normalTex:SetTexCoord(0, 1, 0, 1)
        btn.normalTex:SetAlpha(0.4)
        return
    end
    ApplyIconToTex(btn.normalTex, themeId, iconId)
end

-- 创建单个图标按钮
local function CreateIconButton(parent, actionId, side, slotIndex)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(EX_DB.iconSize, EX_DB.iconSize)
    btn:EnableMouse(true)
    btn:RegisterForClicks("AnyUp")

    local normalTex = btn:CreateTexture(nil, "ARTWORK")
    normalTex:SetAllPoints()
    btn.normalTex = normalTex
    ApplyButtonIcon(btn, side, slotIndex, actionId)

    -- 悬停放大 + Tooltip
    btn:SetScript("OnEnter", function(self)
        local w, h = self:GetSize()
        local ex, ey = w * 0.15, h * 0.15
        self.normalTex:ClearAllPoints()
        self.normalTex:SetPoint("TOPLEFT", self, "TOPLEFT", -ex, ey)
        self.normalTex:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ex, -ey)
        -- 自定义提示文字优先（留空则不显示任何 Tooltip）
        local tip = EX_DB[self._side .. self._slotIndex .. "_tip"] or ""
        if tip ~= "" then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:SetText(tip, 1, 1, 1)
            GameTooltip:Show()
            return
        end
        -- 无自定义文字且动作为空/无 → 不显示
        local def = ACTION_BY_ID[self._actionId]
        if not def or def.id == "none" then return end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        -- 第一行：动作名称
        GameTooltip:SetText(def.label, 1, 1, 1)
        -- 第二行：图案信息（主题·图案）
        local iconThemeId, iconId = GetSlotIconInfo(self._side, self._slotIndex, self._actionId)
        local iconTheme           = THEME_BY_ID[iconThemeId]
        local iconAction          = ACTION_BY_ID[iconId]
        local iconDesc            = (iconTheme and iconTheme.name or iconThemeId)
            .. " · " .. (iconAction and iconAction.label or iconId)
        GameTooltip:AddLine("|cffaaaaaa" .. L["图案："] .. iconDesc .. "|r", 1, 1, 1)
        -- 第三行：自定义命令
        if def.id == "custom" then
            local cmd = EX_DB[self._side .. self._slotIndex .. "_cmd"] or ""
            if cmd ~= "" then GameTooltip:AddLine("|cffffd700" .. cmd .. "|r", 1, 1, 1) end
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        self.normalTex:ClearAllPoints()
        self.normalTex:SetAllPoints()
        GameTooltip:Hide()
    end)

    -- 点击：执行动作
    btn:SetScript("OnClick", function(self)
        local def = ACTION_BY_ID[self._actionId]
        if not def then return end
        if def.id == "custom" then
            local cmd = EX_DB[self._side .. self._slotIndex .. "_cmd"] or ""
            RunCustomCmd(cmd)
        elseif def.action then
            local ok, err = pcall(def.action)
            if not ok then EXDebug("MicroMenu 按钮执行失败: %s", tostring(err)) end
        end
    end)

    btn._actionId  = actionId
    btn._side      = side
    btn._slotIndex = slotIndex
    return btn
end

-- 更新按钮绑定（不重建）
local function UpdateButtonAction(btn, actionId, side, slotIndex)
    btn._actionId  = actionId
    btn._side      = side
    btn._slotIndex = slotIndex
    ApplyButtonIcon(btn, side, slotIndex, actionId)
end

-- 创建/重建整个 HUD
local function BuildHUD()
    if mainFrame then
        mainFrame:Hide()
        mainFrame:SetParent(nil)
        mainFrame    = nil
        leftBtns     = {}
        rightBtns    = {}
        timeText     = nil
        editBgFrames = {}
    end
    if not EX_DB.enabled then return end

    local iconSize   = EX_DB.iconSize
    local iconGap    = 4
    local padding    = 8
    local leftCount  = math.min(EX_DB.leftCount or 5, MAX_SLOTS)
    local rightCount = math.min(EX_DB.rightCount or 5, MAX_SLOTS)
    local barHeight  = iconSize + padding * 2

    mainFrame        = CreateFrame("Frame", "ExMicroMenuFrame", UIParent)
    mainFrame:SetFrameStrata("MEDIUM")
    mainFrame:SetFrameLevel(10)
    mainFrame:SetScale(EX_DB.barScale)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(not EX_DB.locked)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetSize(100, barHeight)

    local timeBg = mainFrame:CreateTexture(nil, "BACKGROUND")
    timeBg:SetAllPoints()
    timeBg:SetColorTexture(0, 0, 0, EX_DB.showBackground and EX_DB.bgAlpha or 0)

    local mainEditBg = mainFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    mainEditBg:SetAllPoints()
    mainEditBg:SetColorTexture(0, 1, 0, 0.45)
    mainEditBg:Hide()
    table.insert(editBgFrames, mainEditBg)

    mainFrame._editDragLabel = mainFrame:CreateFontString(nil, "OVERLAY", nil, 8)
    mainFrame._editDragLabel:SetFont(ExwindTools.MAIN_FONT, 11, "OUTLINE")
    mainFrame._editDragLabel:SetTextColor(0, 1, 0, 1)
    mainFrame._editDragLabel:SetText(L["点这里拖动"])
    mainFrame._editDragLabel:SetPoint("CENTER", mainFrame, "CENTER", 0, 0)
    mainFrame._editDragLabel:Hide()

    timeText = mainFrame:CreateFontString(nil, "OVERLAY")
    local tfs = (EX_DB.timeFontSize and EX_DB.timeFontSize > 0) and EX_DB.timeFontSize or math.floor(iconSize * 0.75)
    timeText:SetFont(ExwindTools.MAIN_FONT, tfs, "OUTLINE")
    timeText:SetTextColor(1, 1, 1, 1)
    timeText:SetPoint("CENTER", mainFrame, "CENTER", EX_DB.timeOffsetX or 0, EX_DB.timeOffsetY or 0)
    timeText:SetText(GetTimeString())

    mainFrame:SetScript("OnDragStart", function(self)
        if not EX_DB.locked then self:StartMoving() end
    end)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        EX_DB.posX              = math.floor(x or 0)
        EX_DB.posY              = math.floor(y or 0)
        EX_DB.posAnchor         = point or "TOP"
    end)

    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, mainFrame)

    -- 左侧框架
    if leftCount > 0 then
        local leftWidth = padding + leftCount * iconSize + (leftCount - 1) * iconGap + padding
        local leftFrame = CreateFrame("Frame", nil, mainFrame)
        leftFrame:SetFrameStrata("MEDIUM"); leftFrame:SetFrameLevel(10)
        leftFrame:SetSize(leftWidth, barHeight)
        leftFrame:SetPoint("RIGHT", mainFrame, "LEFT", 0, 0)

        local leftBg = leftFrame:CreateTexture(nil, "BACKGROUND")
        leftBg:SetAllPoints()
        leftBg:SetColorTexture(0, 0, 0, EX_DB.showBackground and EX_DB.bgAlpha or 0)

        local leftEditBg = leftFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        leftEditBg:SetAllPoints()
        leftEditBg:SetColorTexture(0, 1, 0, 0.45)
        leftEditBg:Hide()
        table.insert(editBgFrames, leftEditBg)

        local curX = leftWidth - padding
        for i = 1, leftCount do
            local actionId = GetActionIdFromDB("left" .. i .. "_action")
            local btn      = CreateIconButton(leftFrame, actionId, "left", i)
            btn:SetPoint("RIGHT", leftFrame, "LEFT", curX, 0)
            curX        = curX - iconSize - iconGap
            leftBtns[i] = btn
        end
    end

    -- 右侧框架
    if rightCount > 0 then
        local rightWidth = padding + rightCount * iconSize + (rightCount - 1) * iconGap + padding
        local rightFrame = CreateFrame("Frame", nil, mainFrame)
        rightFrame:SetFrameStrata("MEDIUM"); rightFrame:SetFrameLevel(10)
        rightFrame:SetSize(rightWidth, barHeight)
        rightFrame:SetPoint("LEFT", mainFrame, "RIGHT", 0, 0)

        local rightBg = rightFrame:CreateTexture(nil, "BACKGROUND")
        rightBg:SetAllPoints()
        rightBg:SetColorTexture(0, 0, 0, EX_DB.showBackground and EX_DB.bgAlpha or 0)

        local rightEditBg = rightFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        rightEditBg:SetAllPoints()
        rightEditBg:SetColorTexture(0, 1, 0, 0.45)
        rightEditBg:Hide()
        table.insert(editBgFrames, rightEditBg)

        local curX = padding
        for i = 1, rightCount do
            local actionId = GetActionIdFromDB("right" .. i .. "_action")
            local btn      = CreateIconButton(rightFrame, actionId, "right", i)
            btn:SetPoint("LEFT", rightFrame, "LEFT", curX, 0)
            curX         = curX + iconSize + iconGap
            rightBtns[i] = btn
        end
    end

    mainFrame:ClearAllPoints()
    local anchor = EX_DB.posAnchor or "TOP"
    mainFrame:SetPoint(anchor, UIParent, anchor, EX_DB.posX or 0, EX_DB.posY or 0)
    mainFrame:Show()
end

-- 屏蔽/恢复内建微型选单
local blizzMicroMenuOrigPoint = nil
local function SetBlizzardMicroMenuVisible(visible)
    local container = _G["MicroMenuContainer"]
    if not container then return end
    if visible then
        container:ClearAllPoints()
        if blizzMicroMenuOrigPoint then
            container:SetPoint(unpack(blizzMicroMenuOrigPoint))
        else
            container:SetPoint("TOP", UIParent, "TOP", 0, 0)
        end
    else
        if not blizzMicroMenuOrigPoint then
            local point, relativeTo, relativePoint, x, y = container:GetPoint()
            if point then
                blizzMicroMenuOrigPoint = { point, relativeTo, relativePoint, x, y }
            end
        end
        container:ClearAllPoints()
        container:SetPoint("TOP", UIParent, "BOTTOM", 0, -9999)
    end
end

local function TickTime()
    if timeText and timeText:IsShown() then
        timeText:SetText(GetTimeString())
    end
end

local function StartTicker()
    if ticker then
        ticker:Cancel(); ticker = nil
    end
    ticker = C_Timer.NewTicker(1, TickTime)
end

local function RefreshAll()
    local ok, err = pcall(BuildHUD)
    if not ok then
        EXDebug("MicroMenu BuildHUD 出错: %s", tostring(err))
    end
    if ExwindTools.GlobalEditMode then
        for _, bg in ipairs(editBgFrames) do bg:Show() end
        if mainFrame and mainFrame._editDragLabel then mainFrame._editDragLabel:Show() end
    end
    if EX_DB.enabled then
        StartTicker()
        SetBlizzardMicroMenuVisible(false)
    else
        if ticker then
            ticker:Cancel(); ticker = nil
        end
        SetBlizzardMicroMenuVisible(true)
    end
end

local function RefreshPanels()
    local leftCount  = math.min(EX_DB.leftCount or 5, MAX_SLOTS)
    local rightCount = math.min(EX_DB.rightCount or 5, MAX_SLOTS)
    for i = 1, leftCount do
        if leftBtns[i] then
            UpdateButtonAction(leftBtns[i], GetActionIdFromDB("left" .. i .. "_action"), "left", i)
        end
    end
    for i = 1, rightCount do
        if rightBtns[i] then
            UpdateButtonAction(rightBtns[i], GetActionIdFromDB("right" .. i .. "_action"), "right", i)
        end
    end
end

-- 把设置面板里的图案选择按钮更新为当前图案预览
-- 通过 ExwindTools.Grid.Widgets 拿到按钮对象，叠加图标纹理并隐藏文字
local function RefreshIconBtnTextures()
    local widgets = ExwindTools.Grid and ExwindTools.Grid.Widgets
    if not widgets then return end

    local function ApplyToWidget(side, i)
        local key = side .. i .. "_iconbtn"
        local btn = widgets[key]
        if not btn then return end

        local actionId        = GetActionIdFromDB(side .. i .. "_action")
        local themeId, iconId = GetSlotIconInfo(side, i, actionId)

        -- 首次：清除模板原生纹理，变成干净画布，再创建图案纹理
        if not btn._iconPreviewTex then
            -- 隐藏 SharedButtonLargeTemplate 的所有原生纹理层
            btn:SetNormalTexture("")
            btn:SetPushedTexture("")
            btn:SetHighlightTexture("")
            btn:SetDisabledTexture("")
            -- 去掉文字
            local fs = btn:GetFontString()
            if fs then fs:SetAlpha(0) end
            -- 创建图案纹理（ARTWORK 层，不受模板干扰）
            btn._iconPreviewTex = btn:CreateTexture(nil, "ARTWORK")
            btn._iconPreviewTex:SetAllPoints(btn)
        end

        local tex = btn._iconPreviewTex
        if iconId == "none" or not iconId or iconId == "" then
            tex:SetColorTexture(0.3, 0.3, 0.3, 0.5)
            tex:SetTexCoord(0, 1, 0, 1)
            tex:SetAlpha(0.5)
        else
            ApplyIconToTex(tex, themeId, iconId)
        end
        tex:Show()
    end

    for i = 1, MAX_SLOTS do
        ApplyToWidget("left", i)
        ApplyToWidget("right", i)
    end
end

-- =============================================================
-- 事件与状态订阅
-- =============================================================
ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    C_Timer.After(0.5, RefreshAll)
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end
    if isEditModeActive and info.key == "locked" then
        return
    end

    local rebuildKeys = {
        enabled = true,
        iconSize = true,
        barScale = true,
        leftCount = true,
        rightCount = true,
        showBackground = true,
        bgAlpha = true,
        posAnchor = true,
        posX = true,
        posY = true,
        showSeconds = true,
        timeFormat = true,
        timeFontSize = true,
        timeOffsetX = true,
        timeOffsetY = true,
    }
    if rebuildKeys[info.key] then
        RefreshAll(); return
    end

    -- 整体主题或单槽图案/动作变更 → 刷新图标
    if info.key == "iconTheme"
        or string.find(info.key, "_action$")
        or string.find(info.key, "_icon$") then
        RefreshPanels()
        RefreshIconBtnTextures()
        return
    end

    if info.key == "locked" then
        if mainFrame then mainFrame:EnableMouse(not EX_DB.locked) end
    end
end)

-- 图标选择器应用后刷新
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".IconPickerApplied", EXWIND_MODULE_KEY, function()
    RefreshPanels()
    RefreshIconBtnTextures()
end)

-- 设置面板渲染完成后，将图案选择按钮更新为当前图案预览
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".PanelRendered", EXWIND_MODULE_KEY, function()
    RefreshIconBtnTextures()
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    if info.key == "btn_reset_pos" then
        EX_DB.posX = 0; EX_DB.posY = 0; EX_DB.posAnchor = "TOP"
        if mainFrame then
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint("TOP", UIParent, "TOP", 0, 0)
        end
        return
    end

    -- 图标按钮 → 打开选择器浮窗
    local btnSide, btnIdx = info.key:match("^(left)(%d+)_iconbtn$")
    if not btnSide then btnSide, btnIdx = info.key:match("^(right)(%d+)_iconbtn$") end
    if btnSide and btnIdx then
        IconPicker_Open(btnSide, tonumber(btnIdx))
    end
end)

local function ApplyEditModePresentation()
    if not mainFrame then return end

    if isEditModeActive then
        if isEditModeVisible then
            mainFrame:Show()
            mainFrame:EnableMouse(true)
            for _, bg in ipairs(editBgFrames) do bg:Show() end
            if mainFrame._editDragLabel then mainFrame._editDragLabel:Show() end
        else
            mainFrame:EnableMouse(false)
            for _, bg in ipairs(editBgFrames) do bg:Hide() end
            if mainFrame._editDragLabel then mainFrame._editDragLabel:Hide() end
            mainFrame:Hide()
        end
    else
        if editModeRestoreLocked ~= nil then
            EX_DB.locked = editModeRestoreLocked
            editModeRestoreLocked = nil
        end
        mainFrame:EnableMouse(not EX_DB.locked)
        for _, bg in ipairs(editBgFrames) do bg:Hide() end
        if mainFrame._editDragLabel then mainFrame._editDragLabel:Hide() end
        if EX_DB.enabled then
            mainFrame:Show()
        else
            mainFrame:Hide()
        end
    end
end

ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
        if editModeRestoreLocked == nil then
            editModeRestoreLocked = EX_DB.locked
        end
        isEditModeActive = true
        isEditModeVisible = true
        ApplyEditModePresentation()
    end,
    ExitEditMode = function()
        isEditModeActive = false
        isEditModeVisible = true
        ApplyEditModePresentation()
    end,
    SetEditVisible = function(_, visible)
        isEditModeVisible = (visible ~= false)
        ApplyEditModePresentation()
    end,
})

-- =============================================================
-- 模块就绪报告
-- =============================================================
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
