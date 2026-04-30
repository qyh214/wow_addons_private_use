-- [[ 传送喊话模块 ]]
-- { Key = "ExM+Info.TeleMsg", Name = "传送喊话", Desc = "在施放副本传送法术时自动在队伍频道喊话。", Category = 2 },

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local EXState = ExwindTools.State
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

-- 1. 识别 Key
local EXWIND_MODULE_KEY = "ExM+Info.TeleMsg"

-- 2. 载入检查
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EXDB = _G.EXDB
if not EXDB then return end

-- 3. 数据默认值
local EXWIND_DEFAULTS = {
    teleportShoutText = "[无广告]正在施放%link , 准备传送到\"%name\"",
    shoutTiming = "施法成功", -- 喊话时机: 施法开始 / 施法成功
}
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)
local DEFAULT_MSG = EXWIND_DEFAULTS.teleportShoutText

-- =========================================================
-- [v4.2] 注册与配置
-- =========================================================

-- Grid 布局
local function EX_RegisterLayout()
    -- 1. 预计算预览字符串（逻辑在外部执行，layout只拿结果）
    local fmt = EX_DB.teleportShoutText or DEFAULT_MSG
    local link = "|cff71d5ff|Hspell:444222|h[" .. L["传送: 萨隆矿坑"] .. "]|h|r"
    local name = L["萨隆矿坑"]
    local out = fmt:gsub("%%link", link):gsub("%%name", name)

    local _, classFilename = UnitClass("player")
    local color = C_ClassColor.GetClassColor(classFilename or "WARRIOR")
    local playerColored = "|c" ..
        ((color and color.GenerateHexColor) and color:GenerateHexColor() or "ffffff") .. UnitName("player") .. "|r"

    local previewText = "\n|cffffd100" .. L["预览:"] .. "|r\n|cffaaaaff[" .. L["队伍"] .. "] [" .. playerColored .. "]: " .. out .. "|r"

    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 49, h = 3, label = L["传送喊话 (Teleport Shout)"], labelSize = 25 },
        {
            key = "descInfo",
            type = "description",
            x = 2,
            y = 4,
            w = 49,
            h = 4,
            label = L["|cffffd100变量说明:|r\n  |cff00ff00%link|r  = 法术链接\n  |cff00ff00%name|r = 副本名称"],
            labelSize = 18
        },
        { key = "divider_1705", type = "divider", x = 2, y = 8, w = 49, h = 1 },
        {
            key = "shoutTiming",
            type = "dropdown",
            x = 2,
            y = 10,
            w = 20,
            h = 2,
            label = L["喊话时机"],
            items = "施法开始,施法成功"
        },
        { key = "teleportShoutText", type = "input", x = 2, y = 13, w = 49, h = 2, label = L["自定义喊话内容"] },
        {
            key = "previewLabel",
            type = "description",
            x = 2,
            y = 15,
            w = 49,
            h = 6,
            label = previewText,
            labelSize = 18
        },
        { key = "reset", type = "button", x = 2, y = 21, w = 15, h = 2, label = L["恢复默认喊话"] },
    }
    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

-- 3. 立即注册
EX_RegisterLayout()

-- =========================================================
-- 业务逻辑
-- =========================================================

-- 通用喊话处理（施法开始和施法成功共用）
local function HandleSpellCast(unit, spellID)
    if unit ~= "player" then return end
    local dungeonName = EXDB.SpellToDungeonName[spellID]
    -- 通天峰：联盟/部落法术 ID 兼容
    if not dungeonName and (spellID == 159898 or spellID == 1254557) then
        dungeonName = "通天峰"
    end
    if not dungeonName then return end
    dungeonName = L[dungeonName] or dungeonName

    local spellLink = C_Spell.GetSpellLink(spellID)
    if not spellLink then return end

    local msgFormat = EX_DB.teleportShoutText or DEFAULT_MSG
    local message = msgFormat:gsub("%%link", spellLink):gsub("%%name", dungeonName)
    SendChatMessage(message, "PARTY")
end

local function OnSpellStart(event, unit, _, spellID)
    HandleSpellCast(unit, spellID)
end

local function OnSpellSucceeded(event, unit, _, spellID)
    HandleSpellCast(unit, spellID)
end

-- 根据当前设置注册对应的事件，注销另一个
local function UpdateTelemsgEvent()
    local timing = EX_DB.shoutTiming or EXWIND_DEFAULTS.shoutTiming
    if timing == "施法开始" then
        ExwindTools:RegisterEvent("UNIT_SPELLCAST_START", EXWIND_MODULE_KEY, OnSpellStart)
        ExwindTools:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", EXWIND_MODULE_KEY)
    else
        -- 默认：施法成功
        ExwindTools:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", EXWIND_MODULE_KEY, OnSpellSucceeded)
        ExwindTools:UnregisterEvent("UNIT_SPELLCAST_START", EXWIND_MODULE_KEY)
    end
end

-- 4. 绑定逻辑
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(data)
    if data.key == "reset" then
        EX_DB.teleportShoutText = DEFAULT_MSG
        ExwindTools:UpdateState(EXWIND_MODULE_KEY .. ".DatabaseChanged", "reset")
    end
end)

-- 监听 DB 变更：刷新预览 + 重新注册事件
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function()
    -- 重新生成静态 Layout（更新预览文本）
    EX_RegisterLayout()
    -- 如果当前正是本模块的界面，刷新显示
    if ExwindTools.UI and ExwindTools.UI.CurrentModule == EXWIND_MODULE_KEY then
        ExwindTools.UI:RefreshContent()
    end
    -- 用户切换喊话时机时重新注册对应事件
    if not EXState.InInstance then
        UpdateTelemsgEvent()
    end
end)

-- 智能生命周期：在副本外时监听，进本后自动注销
ExwindTools:WatchState("InInstance", EXWIND_MODULE_KEY, function(inInstance)
    if inInstance then
        ExwindTools:UnregisterEvent("UNIT_SPELLCAST_START", EXWIND_MODULE_KEY)
        ExwindTools:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", EXWIND_MODULE_KEY)
    else
        UpdateTelemsgEvent()
    end
end)

-- 初始检查
if not EXState.InInstance then
    UpdateTelemsgEvent()
end

-- 报告模块加载完成
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
