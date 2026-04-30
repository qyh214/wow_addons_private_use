-- =============================================================
-- [[ 位移技能CD提示 (No Move Skill Alert) ]]
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExClass.NoMoveSkillAlert"

-- =============================================================
-- 声明式配置：只维护职业 / 专精 / 法术ID / 显示文本Key
-- =============================================================
local NO_MOVE_SKILL_CONFIGS = {
    MAGE = {
        header = "法师设置",
        color = "3fc7eb",
        mode = "KNOWN_FIRST",
        displayRows = {
            { specIDs = { 62, 63, 64 }, formatKey = "displayFormat", defaultFormat = "我没有闪 (%t)" },
        },
        candidates = {
            { spellID = 212653, formatKey = "displayFormat" }, -- 闪光术
            { spellID = 1953,   formatKey = "displayFormat" }, -- 闪现
        },
    },
    ROGUE = {
        header = "盗贼设置",
        color = "fff468",
        mode = "SPEC",
        displayRows = {
            { specIDs = { 259, 261 }, formatKey = "rogue_fmt_shadow" },
            { specIDs = { 260 },      formatKey = "rogue_fmt_phantom" },
        },
        specs = {
            [259] = { spellID = 36554, formatKey = "rogue_fmt_shadow", defaultFormat = "没有影步 (%t)" },
            [260] = { spellID = 195457, formatKey = "rogue_fmt_phantom", defaultFormat = "没有爪钩 (%t)" },
            [261] = { spellID = 36554, formatKey = "rogue_fmt_shadow", defaultFormat = "没有影步 (%t)" },
        },
        order = { 259, 260, 261 },
    },
    PALADIN = {
        header = "圣骑士设置",
        color = "f48cba",
        mode = "SPEC",
        displayRows = {
            { specIDs = { 65 }, enabledKey = "paladin_enable_holy",        formatKey = "paladin_fmt_holy" },
            { specIDs = { 66 }, enabledKey = "paladin_enable_protection",  formatKey = "paladin_fmt_protection" },
            { specIDs = { 70 }, enabledKey = "paladin_enable_retribution", formatKey = "paladin_fmt_retribution" },
        },
        specs = {
            [65] = {
                spellID = 190784,
                enabledKey = "paladin_enable_holy",
                formatKey = "paladin_fmt_holy",
                defaultFormat = "没有骑马 (%t)",
            },
            [66] = {
                spellID = 190784,
                enabledKey = "paladin_enable_protection",
                formatKey = "paladin_fmt_protection",
                fallbackFormatKey = "paladin_fmt_steed",
                defaultFormat = "没有骑马 (%t)",
            },
            [70] = {
                spellID = 190784,
                enabledKey = "paladin_enable_retribution",
                formatKey = "paladin_fmt_retribution",
                defaultFormat = "没有骑马 (%t)",
            },
        },
        order = { 65, 66, 70 },
    },
    DEMONHUNTER = {
        header = "恶魔猎手设置",
        color = "a330c9",
        mode = "SPEC",
        displayRows = {
            { specIDs = { 577 },  enabledKey = "dh_enable_havoc",     formatKey = "dh_fmt_havoc" },
            { specIDs = { 581 },  enabledKey = "dh_enable_vengeance", formatKey = "dh_fmt_vengeance" },
            { specIDs = { 1480 }, enabledKey = "dh_enable_devourer",  formatKey = "dh_fmt_devourer" },
        },
        specs = {
            [577] = {
                spellID = 195072,
                enabledKey = "dh_enable_havoc",
                formatKey = "dh_fmt_havoc",
                defaultFormat = "没有冲 (%t)",
            },
            [581] = {
                spellID = 189110,
                enabledKey = "dh_enable_vengeance",
                formatKey = "dh_fmt_vengeance",
                defaultFormat = "没有跳 (%t)",
            },
            [1480] = {
                spellID = 1234796,
                enabledKey = "dh_enable_devourer",
                formatKey = "dh_fmt_devourer",
                defaultFormat = "我没有闪 (%t)",
            },
        },
        order = { 577, 581, 1480 },
    },
    EVOKER = {
        header = "唤魔师设置",
        color = "33937f",
        mode = "SPEC",
        displayRows = {
            { specIDs = { 1467 }, enabledKey = "evoker_enable_devastation",  formatKey = "evoker_fmt_devastation" },
            { specIDs = { 1468 }, enabledKey = "evoker_enable_preservation", formatKey = "evoker_fmt_preservation" },
            { specIDs = { 1473 }, enabledKey = "evoker_enable_augmentation", formatKey = "evoker_fmt_augmentation" },
        },
        specs = {
            [1467] = {
                spellID = 358267,
                enabledKey = "evoker_enable_devastation",
                formatKey = "evoker_fmt_devastation",
                defaultFormat = "我没有闪 (%t)",
            },
            [1468] = {
                spellID = 358267,
                enabledKey = "evoker_enable_preservation",
                formatKey = "evoker_fmt_preservation",
                defaultFormat = "我没有闪 (%t)",
            },
            [1473] = {
                spellID = 358267,
                enabledKey = "evoker_enable_augmentation",
                formatKey = "evoker_fmt_augmentation",
                defaultFormat = "我没有闪 (%t)",
            },
        },
        order = { 1467, 1468, 1473 },
    },
}

local CLASS_CONFIG_ORDER = { "MAGE", "ROGUE", "PALADIN", "DEMONHUNTER", "EVOKER" }

local function GetSpecInfoForConfig(specID)
    local spec = EXDB and EXDB.SpecByID and EXDB.SpecByID[specID]
    if spec then
        return spec.name or tostring(specID), spec.icon or 136116
    end

    if GetSpecializationInfoForSpecID then
        local name, _, _, icon = GetSpecializationInfoForSpecID(specID)
        return name or tostring(specID), icon or 136116
    end

    return tostring(specID), 136116
end

local function GetIconMarkup(icon, size)
    return string.format("|T%d:%d:%d:0:0:64:64:5:59:5:59|t", tonumber(icon) or 136116, size or 18, size or 18)
end

local function GetDisplayRowLabel(row)
    if row.specIDs then
        local parts = {}
        for _, specID in ipairs(row.specIDs) do
            local specName, specIcon = GetSpecInfoForConfig(specID)
            parts[#parts + 1] = GetIconMarkup(specIcon, 18) .. " " .. L[specName]
        end
        return table.concat(parts, "  ")
    end

    return GetIconMarkup(row.icon or 136116, 18) .. " " .. L[row.label or ""]
end

local function AppendSkillConfigLayout(layout, startY)
    local y = startY

    for _, classTag in ipairs(CLASS_CONFIG_ORDER) do
        local classConfig = NO_MOVE_SKILL_CONFIGS[classTag]
        if classConfig then
            layout[#layout + 1] = {
                key = "h_" .. classTag,
                type = "header",
                x = 1,
                y = y,
                w = 54,
                h = 2,
                label = "|cff" .. classConfig.color .. L[classConfig.header] .. "|r",
                labelSize = 20,
            }
            y = y + 4

            if classConfig.displayRows then
                for _, row in ipairs(classConfig.displayRows) do
                    layout[#layout + 1] = {
                        key = row.enabledKey or ("desc_" .. row.formatKey),
                        type = row.enabledKey and "checkbox" or "description",
                        x = 1,
                        y = y,
                        w = row.enabledKey and 6 or 24,
                        h = 2,
                        label = row.enabledKey and L["启用"] or GetDisplayRowLabel(row),
                    }
                    layout[#layout + 1] = {
                        key = "desc_" .. row.formatKey,
                        type = "description",
                        x = row.enabledKey and 8 or 1,
                        y = y,
                        w = row.enabledKey and 17 or 24,
                        h = 2,
                        label = GetDisplayRowLabel(row),
                    }
                    layout[#layout + 1] = {
                        key = row.formatKey,
                        type = "input",
                        x = 27,
                        y = y,
                        w = 26,
                        h = 2,
                        label = L["显示CD时的内容 (用 %t 代表时间)"],
                        labelPos = "top",
                    }
                    y = y + 4
                end
            elseif classConfig.order then
                local usedFormatKeys = {}
                for _, specID in ipairs(classConfig.order) do
                    local skill = classConfig.specs and classConfig.specs[specID]
                    if skill and not usedFormatKeys[skill.formatKey] then
                        usedFormatKeys[skill.formatKey] = true
                        local specName, specIcon = GetSpecInfoForConfig(specID)
                        layout[#layout + 1] = {
                            key = "desc_" .. skill.formatKey,
                            type = "description",
                            x = 1,
                            y = y,
                            w = 24,
                            h = 2,
                            label = GetIconMarkup(specIcon, 18) .. " " .. L[specName],
                        }
                        layout[#layout + 1] = {
                            key = skill.formatKey,
                            type = "input",
                            x = 27,
                            y = y,
                            w = 26,
                            h = 2,
                            label = L["显示CD时的内容 (用 %t 代表时间)"],
                            labelPos = "top",
                        }
                        y = y + 4
                    end
                end
            end
        end
    end
end

-- =============================================================
-- Grid 布局
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 54, h = 2, label = L["位移技能CD提示"], labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 54, h = 2, label = L["当位移技能CD时 在屏幕上显示文字提醒。"] },
        { key = "divider_top", type = "divider", x = 1, y = 20, w = 54, h = 1, label = "--[[ Function ]]" },
        { key = "enabled", type = "checkbox", x = 1, y = 8, w = 10, h = 2, label = L["启用"] },
        { key = "decimalThreshold", type = "slider", x = 1, y = 13, w = 18, h = 2, label = L["小数点阈值(秒)"], min = 0, max = 30 },
        { key = "desc_format", type = "description", x = 1, y = 16, w = 54, h = 1, label = L["|cff97a393示例: 我没有闪(%t) → 我没有闪(12) 或 我没有闪(3.2)|r"], labelSize = 12 },
        { key = "font_alert", type = "fontgroup", x = 1, y = 27, w = 53, h = 17, label = L["提示文字|cffff140d (位置在上面改)|r"], labelSize = 20 },
        { key = "sub_pos", type = "subheader", x = 1, y = 18, w = 54, h = 2, label = L["位置设置"], labelSize = 20 },
        { key = "posX", type = "slider", x = 1, y = 23, w = 15, h = 2, label = L["位置 X|cff0aff2a(在这里改)|r"], min = -800, max = 800 },
        { key = "posY", type = "slider", x = 18, y = 23, w = 15, h = 2, label = L["位置 Y|cff0aff2a(在这里改)|r"], min = -500, max = 500 },
        { key = "btn_reset_pos", type = "button", x = 37, y = 22, w = 13, h = 3, label = L["重置位置"] },
        { key = "divider_8703", type = "divider", x = 1, y = 6, w = 54, h = 1, label = L["新组件"] },
        { key = "header_skill_content", type = "header", x = 1, y = 46, w = 53, h = 2, label = L["显示内容"], labelSize = 20 },
    }

    AppendSkillConfigLayout(layout, 50)

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 默认设置
-- =============================================================
local EX_DEFAULTS            = {
    decimalThreshold           = 6,
    displayFormat              = "我没有闪 (%t)",
    enabled                    = true,
    font_alert                 = {
        a = 1,
        align = "CENTER",
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = false,
        shadowX = 2,
        shadowY = -2,
        size = 15,
    },
    posX                       = 15,
    posY                       = -5,
    -- 盗贼专属
    rogue_fmt_shadow           = "没有影步 (%t)",
    rogue_fmt_phantom          = "没有爪钩 (%t)",
    paladin_fmt_steed          = "没有骑马 (%t)",
    paladin_enable_holy        = true,
    paladin_enable_protection  = true,
    paladin_enable_retribution = true,
    paladin_fmt_holy           = "没有骑马 (%t)",
    paladin_fmt_protection     = "没有骑马 (%t)",
    paladin_fmt_retribution    = "没有骑马 (%t)",
    dh_enable_havoc            = false,
    dh_enable_vengeance        = false,
    dh_enable_devourer         = true,
    dh_fmt_havoc               = "没有冲 (%t)",
    dh_fmt_vengeance           = "没有跳 (%t)",
    dh_fmt_devourer            = "我没有闪 (%t)",
    evoker_enable_devastation  = true,
    evoker_enable_preservation = true,
    evoker_enable_augmentation = true,
    evoker_fmt_devastation     = "我没有闪 (%t)",
    evoker_fmt_preservation    = "我没有闪 (%t)",
    evoker_fmt_augmentation    = "我没有闪 (%t)",
}

local EX_DB                  = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)

-- =============================================================
-- [盗贼] 事件驱动引擎
-- 监听 UNIT_SPELLCAST_SUCCEEDED，按专精决定监控法术与计时器时长：
--   259(奇袭)/261(敏锐) → 36554(影步)  30秒
--   260(狂徒)           → 195457(幽灵步) 45秒
-- 连续施放只保留最新计时器（覆盖 rogueEndTime）
-- =============================================================
local ALERT_REFRESH_INTERVAL = 0.5

local rogueFrame             = CreateFrame("Frame")
local rogueEndTime           = nil                    -- 计时器到期的绝对时间，nil 表示未激活
local rogueDuration          = 30                     -- 当前专精对应的计时器时长（秒）
local rogueSkillConfig       = nil
local rogueRefresh           = ALERT_REFRESH_INTERVAL -- 刷新计数器（初始值触发第一帧立即刷新）
local mageFrame              = CreateFrame("Frame")
local mageSpellID            = nil
local mageFormatKey          = "displayFormat"
local mageRefresh            = ALERT_REFRESH_INTERVAL
local paladinFrame           = CreateFrame("Frame")
local paladinSkillConfig     = nil
local paladinRefresh         = ALERT_REFRESH_INTERVAL
-- OnUpdate / 事件注册在 alertFrame 创建后进行（见下方）

-- =============================================================
-- 运行时状态
-- =============================================================
local activeSpellID          = nil
local maxCharges             = 0
local currentCharges         = 0
local chargeCooldown         = 0
local rechargeStartTime      = 0
local isActive               = false
local GRACE_PERIOD           = 2



-- =============================================================
-- UI 框架
-- =============================================================
local alertFrame = CreateFrame("Frame", "ExNoMoveSkillAlertFrame", UIParent)
alertFrame:SetSize(300, 50)
alertFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
alertFrame:SetMovable(true)
alertFrame:SetClampedToScreen(true)
alertFrame:Hide()

local alertText = alertFrame:CreateFontString(nil, "OVERLAY")
alertText:SetPoint("CENTER")

-- [v12.1 Fix] 统一控制鼠标交互，非编辑模式下确保点击穿透
local function SetAlertFrameMouseInteractive(enabled)
    alertFrame:EnableMouse(enabled)
    if alertFrame.SetMouseClickEnabled then
        alertFrame:SetMouseClickEnabled(enabled)
    end
    if alertFrame.SetMouseMotionEnabled then
        alertFrame:SetMouseMotionEnabled(enabled)
    end
end

local function ApplyFontSettings()
    local db = EX_DB.font_alert
    local fontPath = ExwindTools.MAIN_FONT
    if db.font and db.font ~= "默认" then
        local LSM = LibStub("LibSharedMedia-3.0", true)
        if LSM then
            fontPath = LSM:Fetch("font", db.font) or fontPath
        end
    end
    alertText:SetFont(fontPath, db.size or 28, db.outline or "OUTLINE")
    alertText:SetTextColor(db.r or 1, db.g or 0.2, db.b or 0.2, db.a or 1)
    if db.shadow then
        alertText:SetShadowOffset(db.shadowX or 2, db.shadowY or -2)
        alertText:SetShadowColor(0, 0, 0, 1)
    else
        alertText:SetShadowOffset(0, 0)
    end
    alertText:SetJustifyH(db.align or "CENTER")
end
ApplyFontSettings()

local function UpdatePosition()
    alertFrame:ClearAllPoints()
    alertFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
end

local function GetCurrentSpecID()
    local specIndex = GetSpecialization and GetSpecialization()
    if not specIndex then return 0 end
    return GetSpecializationInfo(specIndex) or 0
end

local function ResolveSpecSkillConfig(classTag, specID)
    local classConfig = NO_MOVE_SKILL_CONFIGS[classTag]
    if not classConfig or not classConfig.specs then return nil end
    local skill = classConfig.specs[specID]
    if skill and skill.enabledKey and EX_DB[skill.enabledKey] == false then
        return nil
    end
    return skill
end

local function IsConfiguredSpell(classTag, spellID)
    local classConfig = NO_MOVE_SKILL_CONFIGS[classTag]
    if not classConfig or not classConfig.specs then return false end

    for _, skill in pairs(classConfig.specs) do
        if skill.spellID == spellID then
            return true
        end
    end

    return false
end

-- alertFrame 已创建，注册盗贼事件驱动逻辑
-- OnUpdate：每 0.5 秒调一次 GetSpellCooldown 读取真实剩余 CD
-- timeUntilEndOfStartRecovery 是 secret number
-- string.format("%d", secret) → secret string；前缀/后缀是普通字符串，.. 拼接 secret string 合法；SetText 接受 secret string
rogueFrame:SetScript("OnUpdate", function(_, elapsed)
    if not rogueEndTime then return end
    if not EX_DB.enabled then
        rogueEndTime = nil
        alertFrame:Hide()
        return
    end
    -- 普通数字判断计时器是否到期
    local wallRemaining = rogueEndTime - GetTime()
    if wallRemaining <= 0 then
        rogueEndTime = nil
        alertFrame:Hide()
        return
    end
    rogueRefresh = rogueRefresh + elapsed
    if rogueRefresh < ALERT_REFRESH_INTERVAL then return end
    rogueRefresh = 0
    -- 按专精选对应法术读实际 CD
    local skill = rogueSkillConfig or ResolveSpecSkillConfig("ROGUE", GetCurrentSpecID())
    if not skill then
        alertFrame:Hide()
        return
    end
    local spellID = skill.spellID
    local info = C_Spell.GetSpellCooldown(spellID)
    if not info or info.isOnGCD ~= false then
        alertFrame:Hide()
        return
    end
    -- 按专精选对应格式字符串；前缀/后缀用 match 拆出（普通字符串操作），再用 .. 夹住 secret string
    local fmt = EX_DB[skill.formatKey] or skill.defaultFormat or ""
    local prefix, suffix = fmt:match("^(.-)%%t(.*)$")
    if prefix then
        alertText:SetText(prefix .. string.format("%d", info.timeUntilEndOfStartRecovery) .. suffix)
    else
        alertText:SetText(string.format("%d", info.timeUntilEndOfStartRecovery))
    end
    alertFrame:Show()
end)
rogueFrame:Hide()

-- 监听施法成功事件：按专精决定监控法术和计时器时长，连续施放只保留最新
local rogueEventFrame = CreateFrame("Frame")
rogueEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
rogueEventFrame:SetScript("OnEvent", function(_, _, unitTarget, _, spellID)
    if unitTarget ~= "player" then return end
    if not IsConfiguredSpell("ROGUE", spellID) then return end
    if not EX_DB.enabled then return end
    -- 按专精决定计时器时长：260(狂徒)=45秒，259/261=30秒
    local specID = GetCurrentSpecID()
    rogueSkillConfig = ResolveSpecSkillConfig("ROGUE", specID)
    if not rogueSkillConfig or rogueSkillConfig.spellID ~= spellID then return end
    if specID == 260 then
        rogueDuration = 45
    else
        rogueDuration = 30
    end
    -- 无论是否已有计时器，始终以最新施放重置（连续施放只保留最新）
    rogueEndTime = GetTime() + rogueDuration
    rogueRefresh = ALERT_REFRESH_INTERVAL -- 立即触发第一次刷新
    rogueFrame:Show()
end)

-- =============================================================
-- [法师] 直读 API 引擎
-- 不再手动推算充能/CD，统一通过 C_Spell 读取真实数据
-- =============================================================
local function IsSpellKnownSafe(spellID)
    if C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(spellID) then
        return true
    end
    if IsPlayerSpell and IsPlayerSpell(spellID) then
        return true
    end
    return false
end

local function ResolveKnownFirstSkillConfig(classTag)
    local classConfig = NO_MOVE_SKILL_CONFIGS[classTag]
    if not classConfig or not classConfig.candidates then return nil end

    for _, skill in ipairs(classConfig.candidates) do
        if IsSpellKnownSafe(skill.spellID) then
            return skill
        end
    end
end

local function HideMageDirectAlert()
    alertFrame:Hide()
end

local function UpdateMageDirectAlert()
    if not EX_DB.enabled or not mageSpellID then
        HideMageDirectAlert()
        return
    end

    local info = C_Spell.GetSpellCooldown(mageSpellID)
    if not info or info.isOnGCD ~= false then
        HideMageDirectAlert()
        return
    end

    local fmt = EX_DB.displayFormat or "我没有闪 (%t)"
    if mageFormatKey then
        local classConfig = NO_MOVE_SKILL_CONFIGS.MAGE
        local fallback = classConfig and classConfig.displayRows and classConfig.displayRows[1]
        fmt = EX_DB[mageFormatKey] or (fallback and fallback.defaultFormat) or fmt
    end
    local prefix, suffix = fmt:match("^(.-)%%t(.*)$")
    if prefix then
        alertText:SetText(prefix .. string.format("%d", info.timeUntilEndOfStartRecovery) .. suffix)
    else
        alertText:SetText(string.format("%d", info.timeUntilEndOfStartRecovery))
    end
    alertFrame:Show()
end

mageFrame:SetScript("OnUpdate", function(_, elapsed)
    if not mageSpellID then return end
    if not EX_DB.enabled then
        HideMageDirectAlert()
        return
    end

    mageRefresh = mageRefresh + elapsed
    if mageRefresh < ALERT_REFRESH_INTERVAL then return end
    mageRefresh = 0
    UpdateMageDirectAlert()
end)
mageFrame:Hide()

local function HidePaladinDirectAlert()
    alertFrame:Hide()
end

local function UpdatePaladinDirectAlert()
    if not EX_DB.enabled or not paladinSkillConfig then
        HidePaladinDirectAlert()
        return
    end

    local info = C_Spell.GetSpellCooldown(paladinSkillConfig.spellID)
    if not info or info.isOnGCD ~= false then
        HidePaladinDirectAlert()
        return
    end

    local fmt = EX_DB[paladinSkillConfig.formatKey]
        or (paladinSkillConfig.fallbackFormatKey and EX_DB[paladinSkillConfig.fallbackFormatKey])
        or paladinSkillConfig.defaultFormat
        or "我没有马 (%t)"
    local prefix, suffix = fmt:match("^(.-)%%t(.*)$")
    if prefix then
        alertText:SetText(prefix .. string.format("%d", info.timeUntilEndOfStartRecovery) .. suffix)
    else
        alertText:SetText(string.format("%d", info.timeUntilEndOfStartRecovery))
    end
    alertFrame:Show()
end

paladinFrame:SetScript("OnUpdate", function(_, elapsed)
    if not paladinSkillConfig then return end
    if not EX_DB.enabled then
        HidePaladinDirectAlert()
        return
    end

    paladinRefresh = paladinRefresh + elapsed
    if paladinRefresh < ALERT_REFRESH_INTERVAL then return end
    paladinRefresh = 0
    UpdatePaladinDirectAlert()
end)
paladinFrame:Hide()

-- =============================================================
-- 充能追踪引擎
-- =============================================================
local engineFrame = CreateFrame("Frame")
engineFrame:Hide()

local lastDisplayed = nil

engineFrame:SetScript("OnUpdate", function(self)
    if not isActive or not EX_DB.enabled then
        alertFrame:Hide()
        self:Hide()
        return
    end

    if currentCharges < maxCharges and rechargeStartTime > 0 then
        if GetTime() - rechargeStartTime >= chargeCooldown then
            currentCharges = currentCharges + 1
            if currentCharges < maxCharges then
                rechargeStartTime = rechargeStartTime + chargeCooldown
            else
                rechargeStartTime = 0
                self:Hide()
            end
        end
    end

    if currentCharges == 0 and rechargeStartTime > 0 then
        local remaining = chargeCooldown - (GetTime() - rechargeStartTime)
        if remaining > 0 then
            local threshold = EX_DB.decimalThreshold or 6
            local timeStr
            if remaining <= threshold then
                local displayVal = math.floor(remaining * 10)
                if displayVal ~= lastDisplayed then
                    lastDisplayed = displayVal
                    timeStr = string.format("%.1f", remaining)
                end
            else
                local displayVal = math.floor(remaining)
                if displayVal ~= lastDisplayed then
                    lastDisplayed = displayVal
                    timeStr = string.format("%d", displayVal)
                end
            end
            if timeStr then
                local fmt = EX_DB.displayFormat or "我没有闪(%t)"
                alertText:SetText(fmt:gsub("%%t", timeStr))
            end
            alertFrame:Show()
        else
            alertFrame:Hide()
            lastDisplayed = nil
        end
    else
        if alertFrame:IsShown() then
            alertFrame:Hide()
            lastDisplayed = nil
        end
    end
end)

-- =============================================================
-- 天赋扫描
-- =============================================================
local function RefreshActiveSkillData()
    local _, className = UnitClass("player")

    -- 盗贼走独立轮询引擎，不走充能追踪
    if className == "ROGUE" then
        mageSpellID = nil
        mageFormatKey = "displayFormat"
        mageFrame:Hide()
        paladinSkillConfig = nil
        paladinFrame:Hide()
        isActive = false
        engineFrame:Hide()
        if EX_DB.enabled then
            rogueSkillConfig = ResolveSpecSkillConfig("ROGUE", GetCurrentSpecID())
            rogueFrame:Show()
        else
            rogueFrame:Hide()
            rogueSkillConfig = nil
            rogueEndTime = nil
            alertFrame:Hide()
        end
        return
    end

    if className == "MAGE" then
        rogueFrame:Hide()
        rogueSkillConfig = nil
        rogueEndTime = nil
        paladinSkillConfig = nil
        paladinFrame:Hide()
        -- [v12.2 Adjust] 法师停用旧手动推算逻辑，改为直读 API
        isActive = false
        engineFrame:Hide()
        local mageSkill = ResolveKnownFirstSkillConfig("MAGE")
        mageSpellID = mageSkill and mageSkill.spellID or nil
        mageFormatKey = mageSkill and mageSkill.formatKey or "displayFormat"
        if EX_DB.enabled and mageSpellID then
            mageRefresh = ALERT_REFRESH_INTERVAL
            mageFrame:Show()
            UpdateMageDirectAlert()
        else
            mageFrame:Hide()
            alertFrame:Hide()
        end
        return
    end

    if className == "PALADIN" or className == "DEMONHUNTER" or className == "EVOKER" then
        rogueFrame:Hide()
        rogueSkillConfig = nil
        rogueEndTime = nil
        mageSpellID = nil
        mageFormatKey = "displayFormat"
        mageFrame:Hide()
        isActive = false
        engineFrame:Hide()
        paladinSkillConfig = ResolveSpecSkillConfig(className, GetCurrentSpecID())
        if EX_DB.enabled and paladinSkillConfig then
            paladinRefresh = ALERT_REFRESH_INTERVAL
            paladinFrame:Show()
            UpdatePaladinDirectAlert()
        else
            paladinSkillConfig = nil
            paladinFrame:Hide()
            alertFrame:Hide()
        end
        return
    end

    rogueFrame:Hide()
    rogueSkillConfig = nil
    rogueEndTime = nil
    mageSpellID = nil
    mageFormatKey = "displayFormat"
    mageFrame:Hide()
    paladinSkillConfig = nil
    paladinFrame:Hide()
    isActive = false
    alertFrame:Hide()
    engineFrame:Hide()
end

-- =============================================================
-- 施法成功处理
-- =============================================================
local function OnSpellCastSucceeded(spellID)
    if not isActive or not EX_DB.enabled then return end
    if spellID ~= activeSpellID then return end



    if currentCharges > 0 then
        currentCharges = currentCharges - 1
        if rechargeStartTime == 0 then
            rechargeStartTime = GetTime()
        end
        engineFrame:Show()
    elseif rechargeStartTime > 0 then
        local remaining = chargeCooldown - (GetTime() - rechargeStartTime)

        if remaining > 0 and remaining < GRACE_PERIOD then
            currentCharges = 0
            rechargeStartTime = GetTime()
            engineFrame:Show()
        else

        end
    else
        rechargeStartTime = GetTime()
        engineFrame:Show()
    end
end

-- [v12.2 Adjust] 法师旧覆盖事件恢复充能逻辑停用（改为直读 API）
--[[
local function OnCooldownViewerSpellOverrideUpdated(baseSpellID, overrideSpellID)
end
]]

-- =============================================================
-- 事件注册
-- =============================================================
ExwindTools:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", EXWIND_MODULE_KEY, function(_, unit, _, spellID)
    if unit ~= "player" then return end
    OnSpellCastSucceeded(spellID)
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    C_Timer.After(1, RefreshActiveSkillData)
end)

ExwindTools:RegisterEvent("PLAYER_TALENT_UPDATE", EXWIND_MODULE_KEY, function()
    C_Timer.After(0.5, RefreshActiveSkillData)
end)

ExwindTools:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", EXWIND_MODULE_KEY, function(_, unit)
    if unit == "player" then
        C_Timer.After(0.5, RefreshActiveSkillData)
    end
end)

ExwindTools:RegisterEvent("TRAIT_CONFIG_UPDATED", EXWIND_MODULE_KEY, function()
    C_Timer.After(0.5, RefreshActiveSkillData)
end)

-- [v12.2 Adjust] 法师改为直读 API，停用旧覆盖事件逻辑
-- ExwindTools:RegisterEvent("COOLDOWN_VIEWER_SPELL_OVERRIDE_UPDATED", EXWIND_MODULE_KEY, ...)

-- =============================================================
-- Grid 监听
-- =============================================================
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end
    if info.key == "enabled" then
        if not EX_DB.enabled then
            alertFrame:Hide()
            engineFrame:Hide()
            rogueFrame:Hide()
            rogueEndTime = nil
            mageSpellID = nil
            mageFrame:Hide()
            paladinSkillConfig = nil
            paladinFrame:Hide()
        else
            -- 重新触发刷新，让当前职业分支按需启动
            RefreshActiveSkillData()
        end
    elseif info.key == "posX" or info.key == "posY" then
        UpdatePosition()
    elseif info.key == "displayFormat" then
        if alertFrame:IsShown() and alertFrame:IsMouseEnabled() then
            local fmt = EX_DB.displayFormat or "我没有闪(%t)"
            alertText:SetText(fmt:gsub("%%t", "12"))
        end
    else
        ApplyFontSettings()
    end
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if info and info.key == "btn_reset_pos" then
        EX_DB.posX = 0
        EX_DB.posY = 150
        UpdatePosition()
    end
end)

-- =============================================================
-- 拖动 / 编辑模式
-- =============================================================
local function SetDragMode(enabled)
    if enabled then
        ApplyFontSettings()
        local fmt = EX_DB.displayFormat or "我没有闪(%t)"
        alertText:SetText(fmt:gsub("%%t", "12"))
        alertFrame:Show()
        SetAlertFrameMouseInteractive(true)
        alertFrame:RegisterForDrag("LeftButton")

        if not alertFrame.editBG then
            local bg = CreateFrame("Frame", nil, alertFrame, "BackdropTemplate")
            bg:SetPoint("TOPLEFT", alertFrame, "TOPLEFT", -10, 10)
            bg:SetPoint("BOTTOMRIGHT", alertFrame, "BOTTOMRIGHT", 10, -10)
            bg:SetBackdrop({
                bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                edgeFile = [[Interface\Buttons\WHITE8X8]],
                edgeSize = 1,
                insets = { left = 1, right = 1, top = 1, bottom = 1 },
            })
            bg:SetBackdropColor(0, 0.4, 0, 0.35)
            bg:SetBackdropBorderColor(0, 0.8, 0, 0.8)
            bg:SetFrameLevel(alertFrame:GetFrameLevel())
            alertFrame.editBG = bg
        end
        alertFrame.editBG:Show()

        if not alertFrame.editLabel then
            local label = alertFrame:CreateFontString(nil, "OVERLAY")
            label:SetFont(ExwindTools.MAIN_FONT, 11, "OUTLINE")
            label:SetPoint("BOTTOM", alertFrame, "TOP", 0, 6)
            label:SetTextColor(0, 1, 0, 0.9)
            alertFrame.editLabel = label
        end
        alertFrame.editLabel:SetText(L["位移技能CD提示"])
        alertFrame.editLabel:Show()

        alertFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        alertFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local cx, cy = self:GetCenter()
            local sx, sy = UIParent:GetCenter()
            if cx and sx then
                EX_DB.posX = math.floor(cx - sx + 0.5)
                EX_DB.posY = math.floor(cy - sy + 0.5)
            end
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
            ExwindTools:UpdateState(EXWIND_MODULE_KEY .. ".DatabaseChanged", { key = "posX", ts = GetTime() })
        end)
        alertFrame:SetScript("OnMouseDown", function(_, button)
            if button == "RightButton" and ExwindTools.GlobalEditMode then
                ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
            end
        end)

        if not alertFrame.DragHint then
            alertFrame.DragHint = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            alertFrame.DragHint:SetPoint("TOP", alertFrame, "BOTTOM", 0, -8)
        end
        alertFrame.DragHint:SetText("|cff00ff00" .. L["拖动调整位置"] .. "|r\n|cffaaaaaa" .. L["右键打开设置"] .. "|r")
        alertFrame.DragHint:Show()
    else
        SetAlertFrameMouseInteractive(false)
        alertFrame:SetScript("OnDragStart", nil)
        alertFrame:SetScript("OnDragStop", nil)
        alertFrame:SetScript("OnMouseDown", nil)
        if alertFrame.editBG then alertFrame.editBG:Hide() end
        if alertFrame.editLabel then alertFrame.editLabel:Hide() end
        if alertFrame.DragHint then alertFrame.DragHint:Hide() end
        if currentCharges > 0 or not isActive or not EX_DB.enabled then
            alertFrame:Hide()
        end
    end
end

local isEditModeActive = false
local isEditModeVisible = true

local function ApplyEditModePresentation()
    if isEditModeActive then
        rogueFrame:Hide()
        mageFrame:Hide()
        paladinFrame:Hide()
        engineFrame:Hide()
        SetDragMode(isEditModeVisible)
    else
        SetDragMode(false)
    end
end

ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
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

ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, alertFrame)
-- RegisterHUD 内部会强制 EnableMouse(true)，注册后立即关闭以恢复点击穿透
SetAlertFrameMouseInteractive(false)
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
