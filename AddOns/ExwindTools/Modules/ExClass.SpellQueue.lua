-- =============================================================
-- [[ 全职业延迟容限 ]]
-- { Key = "ExTools.SpellQueue", Name = "全职业延迟容限", Desc = "根据当前专精自动调整输入延迟容限(SpellQueueWindow)。", Category = 5 },
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })
local EXState = ExwindTools.State

-- =============================================================
-- 第一部分：模块标识与载入检查
-- =============================================================
local EXWIND_MODULE_KEY = "ExTools.SpellQueue"

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 第二部分：依赖与数据初始化
-- =============================================================
local EXDB = _G.EXDB
if not EXDB then return end

local EXWIND_DEFAULTS = {
    enabled = false,
    aiMode = false,
    globalFixed = 400,
    globalOffset = 0,
    specs = {},   -- 固定模式：每个专精的固定延迟值
    specsAI = {}, -- AI 模式：每个专精的偏移值
}
local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)


local function GetCurrentInfo()
    local s = EXState
    local curV = GetCVar("SpellQueueWindow") or "400"
    local cHex = "ffffff"
    if s.ClassID and EXDB.Classes[s.ClassID] then cHex = EXDB.Classes[s.ClassID].colorHex end
    local sIcon = (s.SpecID and EXDB.SpecByID[s.SpecID]) and EXDB.SpecByID[s.SpecID].icon or 0
    local iStr = sIcon > 0 and string.format("|T%d:14:14:0:0|t ", sIcon) or ""
    return string.format(L["当前: %s|cff%s%s - %s|r | 系统值: |cffffd100%sms|r"], iStr, cHex, s.ClassName or L["未知"],
        s.SpecName or L["未知"], curV)
end

local function MakeSpecLabel(icon, colorHex, specName)
    return string.format("|T%d:14:14:0:0|t |cff%s%s|r", icon, colorHex, L[specName])
end

local function EX_RegisterLayout()
    --GRID引擎数据
    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 49, h = 2, label = L["全职业延迟容限 (SpellQueueWindow)"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 30, h = 2, label = L["AI模式：容限 = 延迟 + 偏移。固定模式：容限 = 设定值。"] },
        { key = "live_status", type = "description", x = 2, y = 5, w = 49, h = 2, label = GetCurrentInfo() },
        { key = "ctrl_header", type = "subheader", x = 2, y = 7, w = 49, h = 2, label = L["核心控制"], labelPos = "top" },
        { key = "enabled", type = "checkbox", x = 4, y = 11, w = 8, h = 2, label = L["开启功能"] },
        { key = "aiMode", type = "checkbox", x = 14, y = 11, w = 8, h = 2, label = "|cff00ffff" .. L["启用 AI 智能模式"] .. "|r" },
        { key = "globalFixed", type = "input", x = 26, y = 11, w = 15, h = 2, label = L["全局默认延迟值 (固定)"], labelSize = 17 },
        { key = "h_板甲职业", type = "subheader", x = 2, y = 15, w = 49, h = 1, label = L["板甲职业"] },
        { key = "250", type = "input", x = 9, y = 18, w = 9, h = 2, label = MakeSpecLabel(135770, "C41E3A", "鲜血"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "251", type = "input", x = 25, y = 18, w = 9, h = 2, label = MakeSpecLabel(135773, "C41E3A", "冰霜"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "252", type = "input", x = 42, y = 18, w = 9, h = 2, label = MakeSpecLabel(135775, "C41E3A", "邪恶"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "71", type = "input", x = 25, y = 20, w = 9, h = 2, label = MakeSpecLabel(132355, "C79C6E", "武器"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "72", type = "input", x = 42, y = 20, w = 9, h = 2, label = MakeSpecLabel(132347, "C79C6E", "狂怒"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "73", type = "input", x = 9, y = 20, w = 9, h = 2, label = MakeSpecLabel(132341, "C79C6E", "防护"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "65", type = "input", x = 42, y = 22, w = 9, h = 2, label = MakeSpecLabel(135920, "F48CBA", "神圣"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "66", type = "input", x = 9, y = 22, w = 9, h = 2, label = MakeSpecLabel(236264, "F48CBA", "防护"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "70", type = "input", x = 25, y = 22, w = 9, h = 2, label = MakeSpecLabel(135873, "F48CBA", "惩戒"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "h_锁甲职业", type = "subheader", x = 2, y = 27, w = 49, h = 1, label = L["锁甲职业"] },
        { key = "253", type = "input", x = 42, y = 32, w = 9, h = 2, label = MakeSpecLabel(461112, "ABD473", "野兽控制"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "254", type = "input", x = 25, y = 32, w = 9, h = 2, label = MakeSpecLabel(236179, "ABD473", "射击"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "255", type = "input", x = 9, y = 32, w = 9, h = 2, label = MakeSpecLabel(461113, "ABD473", "生存"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "262", type = "input", x = 9, y = 30, w = 9, h = 2, label = MakeSpecLabel(136048, "0070DD", "元素"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "263", type = "input", x = 25, y = 30, w = 9, h = 2, label = MakeSpecLabel(237581, "0070DD", "增强"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "264", type = "input", x = 42, y = 30, w = 9, h = 2, label = MakeSpecLabel(136052, "0070DD", "恢复"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "1467", type = "input", x = 9, y = 34, w = 9, h = 2, label = MakeSpecLabel(4511811, "33937F", "湮灭"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "1468", type = "input", x = 42, y = 34, w = 9, h = 2, label = MakeSpecLabel(4511812, "33937F", "恩护"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "1473", type = "input", x = 25, y = 34, w = 9, h = 2, label = MakeSpecLabel(5198700, "33937F", "增辉"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "h_皮甲职业", type = "subheader", x = 2, y = 39, w = 49, h = 1, label = L["皮甲职业"] },
        { key = "577", type = "input", x = 25, y = 42, w = 9, h = 2, label = MakeSpecLabel(1247264, "A330C9", "浩劫"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "581", type = "input", x = 9, y = 42, w = 9, h = 2, label = MakeSpecLabel(1247265, "A330C9", "复仇"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "1480", type = "input", x = 42, y = 42, w = 9, h = 2, label = MakeSpecLabel(7455385, "A330C9", "噬灭"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "259", type = "input", x = 25, y = 44, w = 9, h = 2, label = MakeSpecLabel(236270, "FFF468", "奇袭"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "260", type = "input", x = 9, y = 44, w = 9, h = 2, label = MakeSpecLabel(236286, "FFF468", "狂徒"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "261", type = "input", x = 42, y = 44, w = 9, h = 2, label = MakeSpecLabel(132320, "FFF468", "敏锐"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "268", type = "input", x = 9, y = 46, w = 9, h = 2, label = MakeSpecLabel(608951, "00FF98", "酒仙"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "269", type = "input", x = 25, y = 46, w = 9, h = 2, label = MakeSpecLabel(608953, "00FF98", "踏风"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "270", type = "input", x = 42, y = 46, w = 9, h = 2, label = MakeSpecLabel(608952, "00FF98", "织雾"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "102", type = "input", x = 33, y = 48, w = 6, h = 2, label = MakeSpecLabel(136096, "FF7C0A", "平衡"), parentKey = "specs", labelPos = "left" },
        { key = "103", type = "input", x = 21, y = 48, w = 6, h = 2, label = MakeSpecLabel(132115, "FF7C0A", "野性"), parentKey = "specs", labelPos = "left" },
        { key = "104", type = "input", x = 9, y = 48, w = 6, h = 2, label = MakeSpecLabel(132276, "FF7C0A", "守护"), parentKey = "specs", labelPos = "left" },
        { key = "105", type = "input", x = 45, y = 48, w = 6, h = 2, label = MakeSpecLabel(136041, "FF7C0A", "恢复"), parentKey = "specs", labelPos = "left" },
        { key = "h_布甲职业", type = "subheader", x = 2, y = 53, w = 49, h = 1, label = L["布甲职业"] },
        { key = 62, type = "input", x = 42, y = 56, w = 9, h = 2, label = MakeSpecLabel(135932, "3FC7EB", "奥术"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = 63, type = "input", x = 25, y = 56, w = 9, h = 2, label = MakeSpecLabel(135810, "3FC7EB", "火焰"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = 64, type = "input", x = 9, y = 56, w = 9, h = 2, label = MakeSpecLabel(135846, "3FC7EB", "冰霜"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = 265, type = "input", x = 25, y = 58, w = 9, h = 2, label = MakeSpecLabel(136145, "8788EE", "痛苦"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "266", type = "input", x = 42, y = 58, w = 9, h = 2, label = MakeSpecLabel(136172, "8788EE", "恶魔学识"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = 267, type = "input", x = 9, y = 58, w = 9, h = 2, label = MakeSpecLabel(136186, "8788EE", "毁灭"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = 256, type = "input", x = 9, y = 60, w = 9, h = 2, label = MakeSpecLabel(135940, "FFFFFF", "戒律"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = 257, type = "input", x = 25, y = 60, w = 9, h = 2, label = MakeSpecLabel(237542, "FFFFFF", "神圣"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = 258, type = "input", x = 42, y = 60, w = 9, h = 2, label = MakeSpecLabel(136207, "FFFFFF", "暗影"), parentKey = "specs", labelPos = "left", labelSize = 18 },
        { key = "divider_9437", type = "divider", x = 2, y = 9, w = 49, h = 1, label = L["新组件"] },
        { key = "divider_4513", type = "divider", x = 2, y = 16, w = 49, h = 1, label = L["新组件"] },
        { key = "divider_6806", type = "divider", x = 2, y = 28, w = 49, h = 1, label = L["新组件"] },
        { key = "divider_8842", type = "divider", x = 2, y = 40, w = 49, h = 1, label = L["新组件"] },
        { key = "divider_5635", type = "divider", x = 2, y = 54, w = 49, h = 1, label = L["新组件"] },
    }






    -- 3. 逻辑适配区 (只在注册前，刷新受 AI 模式影响的内容)
    -- 注意：这里使用 lua 本地逻辑更新 parentKey，不改变 layout 的静态结构
    local targetStorage = EX_DB.aiMode and "specsAI" or "specs"
    local suffix = EX_DB.aiMode and " |cff00ffff(AI)|r" or ""

    for i = 1, #layout do
        local item = layout[i]

        -- 全局默认值切换 (双向修复)
        -- 无论当前 layout 里写的是 globalFixed 还是 globalOffset，都根据 aiMode 强制修正
        if item.key == "globalFixed" or item.key == "globalOffset" then
            if EX_DB.aiMode then
                item.key = "globalOffset"
                item.baseLabel = item.baseLabel or item.label
                item.label = L["全局延迟偏移 |cff00ffff(AI)|r"]
            else
                item.key = "globalFixed"
                item.baseLabel = item.baseLabel or item.label
                item.label = L["全局默认延迟值 (固定)"]
            end
        end

        -- 处理所有专精对应的输入框
        if item.parentKey == "specs" or item.parentKey == "specsAI" then
            item.parentKey = targetStorage
            -- 动态追加 AI 标识
            if EX_DB.aiMode then
                item.baseLabel = item.baseLabel or item.label
                if item.label and not item.label:find("AI") then
                    item.label = suffix .. item.label
                end
            else
                -- 还原 Label (如果有 baseLabel)
                if item.baseLabel then item.label = item.baseLabel end
            end
        end
    end

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end

local function ApplySpellQueue()
    if not EX_DB.enabled then return end

    local state = EXState
    local specID = state.SpecID
    if not specID or specID == 0 then return end

    local storage = EX_DB.aiMode and EX_DB.specsAI or EX_DB.specs
    -- 读取分离后的全局变量
    local defaultVal = EX_DB.aiMode and EX_DB.globalOffset or EX_DB.globalFixed
    local val = storage[specID] or defaultVal or 400

    local finalVal = tonumber(val) or 400

    if EX_DB.aiMode then
        local _, _, _, lagWorld = GetNetStats()
        lagWorld = lagWorld or 0
        if lagWorld < 300 then
            finalVal = lagWorld + finalVal
        end
    end

    finalVal = math.max(0, math.min(400, finalVal))
    SetCVar("SpellQueueWindow", finalVal)
end

-- =============================================================
-- 第四部分：事件与状态订阅
-- =============================================================
-- 监听数据库变动 (用户在 UI 中修改设置)
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(changeInfo)
    local key = type(changeInfo) == "table" and changeInfo.key or changeInfo
    if key == "aiMode" then
        if EX_DB.aiMode then
            print("|cff00ffff[Exwind]|r " .. L["进入 AI 自动模式 (容限 = 延迟 + 偏移)"])
        else
            print("|cff00ff00[Exwind]|r " .. L["进入 手动固定模式 (容限 = 固定值)"])
        end
    end
    ApplySpellQueue()

    -- 定向更新状态文本，防止滚动条重置
    if ExwindTools.Grid and ExwindTools.Grid.Widgets then
        local w = ExwindTools.Grid.Widgets["live_status"]
        if w and w.text then w.text:SetText(GetCurrentInfo()) end
    end

    -- 仅当切换 AI 模式时（结构改变）才进行全量刷新
    if key == "aiMode" then
        EX_RegisterLayout()
        if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() and ExwindTools.UI.CurrentModule == EXWIND_MODULE_KEY then
            ExwindTools.UI:RefreshContent()
        end
    end
end)

-- 监听天赋/职业变动 (核心框架广播)
local function OnIdentityChanged()
    EX_RegisterLayout() -- 重新生成布局以更新当前状态文字
    ApplySpellQueue()

    -- 如果主 UI 正在显示当前模块，则强制刷新以更新界面文字
    if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() and ExwindTools.UI.CurrentModule == EXWIND_MODULE_KEY then
        ExwindTools.UI:RefreshContent()
    end
end

ExwindTools:WatchState("SpecID", EXWIND_MODULE_KEY, OnIdentityChanged)
ExwindTools:WatchState("ClassName", EXWIND_MODULE_KEY, OnIdentityChanged)
ExwindTools:WatchState("SpecName", EXWIND_MODULE_KEY, OnIdentityChanged)

-- =============================================================
-- 第五部分：初始化与模块报告
-- =============================================================
C_Timer.After(2, ApplySpellQueue)

ExwindTools:ReportReady(EXWIND_MODULE_KEY)

-- =============================================================
-- 第六部分：首次注册
-- =============================================================
EX_RegisterLayout()
