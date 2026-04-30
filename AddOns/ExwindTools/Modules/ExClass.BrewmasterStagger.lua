-- =============================================================
-- [[ 酒仙酒池监控 ]]
-- { Key = "ExClass.BrewmasterStagger", Name = "酒仙酒池监控", Desc = "显示酒仙武僧的酒池百分比，并支持自定义满条上限与阈值配色。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExClass.BrewmasterStagger"
local BREWMASTER_SPEC_ID = 268
local STAGGER_SPELL_ID = 115069
local WISE_ELIXIR_SPELL_ID = 455139
local COOLDOWN_MONITOR_SPELL_ID = 455180
local COOLDOWN_MONITOR_ICON_ID = 608949
local COOLDOWN_MONITOR_DURATION = 15

local UIParent = _G.UIParent
local CreateFrame = _G.CreateFrame
local UnitHealthMax = _G.UnitHealthMax
local UnitStagger = _G.UnitStagger
local GetTime = _G.GetTime
local C_Timer = _G.C_Timer
local CooldownFrame_Set = _G.CooldownFrame_Set
local math_floor = math.floor
local math_ceil = math.ceil
local math_max = math.max
local math_min = math.min

local LSM = LibStub("LibSharedMedia-3.0")
local LibCustomGlow = LibStub("LibCustomGlow-1.0", true)
local ExwindFactory = _G.ExwindFactory

local anchorFrame = nil
local activeBar = nil
local previewBar = nil
local cooldownIconFrame = nil
local cooldownIconEndTime = 0
local cooldownIconGlowActive = false
local isPreviewing = false
local isEditModeActive = false
local isEditModeVisible = true
local TogglePreview

local function RefreshEditOverlay()
    if not anchorFrame then return end

    if isEditModeActive and isEditModeVisible then
        ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY, anchorFrame)
    else
        ExwindTools:HideExwindToolsEditOverlay(anchorFrame)
    end
end

local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 53, h = 2, label = L["酒仙酒池监控"], labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 53, h = 3, label = L["显示酒仙武僧当前酒池百分比（酒池值 / 最大生命 * 100），并提供独立的满条上限、阈值配色，以及明志灵药冷却监控。"] },

        { key = "subheader_general", type = "subheader", x = 1, y = 9, w = 53, h = 1, label = L["酒池基础设置"], labelSize = 20 },
        { key = "div_general", type = "divider", x = 1, y = 10, w = 53, h = 1, label = "--[[ Stagger Bar ]]" },
        { key = "enabled", type = "checkbox", x = 1, y = 12, w = 10, h = 2, label = L["启用酒池条"] },
        { key = "preview", type = "checkbox", x = 13, y = 12, w = 8, h = 2, label = L["预览"] },
        { key = "locked", type = "checkbox", x = 23, y = 12, w = 10, h = 2, label = L["锁定位置"] },
        { key = "btn_reset_pos", type = "button", x = 41, y = 12, w = 12, h = 2, label = L["重置位置"] },
        { key = "showText", type = "checkbox", x = 1, y = 16, w = 12, h = 2, label = L["显示文字"] },
        { key = "hideBar", type = "checkbox", x = 15, y = 16, w = 12, h = 2, label = L["隐藏条体"] },
        { key = "hideOnMounted", type = "checkbox", x = 29, y = 16, w = 18, h = 2, label = L["骑乘时隐藏"] },
        { key = "textColorFollowsBar", type = "checkbox", x = 1, y = 20, w = 18, h = 2, label = L["文字跟随条体颜色"] },
        { key = "textValueOnly", type = "checkbox", x = 21, y = 20, w = 14, h = 2, label = L["仅显示数值"] },
        { key = "textAlign", type = "dropdown", x = 37, y = 20, w = 16, h = 2, label = L["文字对齐"], items = "LEFT,CENTER,RIGHT" },
        { key = "posX", type = "slider", x = 1, y = 24, w = 16, h = 2, label = L["水平偏移"], min = -1000, max = 1000, step = 1 },
        { key = "posY", type = "slider", x = 19, y = 24, w = 16, h = 2, label = L["垂直偏移"], min = -1000, max = 1000, step = 1 },

        { key = "subheader_elixir_quick", type = "subheader", x = 1, y = 29, w = 53, h = 1, label = L["明志灵药快捷设置"], labelSize = 20 },
        { key = "div_elixir_quick", type = "divider", x = 1, y = 30, w = 53, h = 1, label = "--[[ Elixir Quick ]]" },
        { key = "cooldownIconEnabled", type = "checkbox", x = 1, y = 32, w = 18, h = 2, label = L["启用明志灵药冷却监控"] },
        { key = "wiseElixirHideOutOfCombat", type = "checkbox", x = 21, y = 32, w = 14, h = 2, label = L["脱战隐藏"] },

        { key = "subheader_value", type = "subheader", x = 1, y = 40, w = 53, h = 1, label = L["酒池数值与阈值"], labelSize = 20 },
        { key = "div_value", type = "divider", x = 1, y = 41, w = 53, h = 1, label = "--[[ Threshold ]]" },
        { key = "fullBarPercent", type = "slider", x = 1, y = 43, w = 18, h = 2, label = L["满条映射上限 (%)"], min = 50, max = 500, labelPos = "top" },
        { key = "desc_value_1", type = "description", x = 21, y = 43, w = 32, h = 3, label = L["条体填充上限和阈值颜色分开计算。未命中阈值时，使用下方条体外观中的主色。"] },
        { key = "warningEnabled", type = "checkbox", x = 1, y = 48, w = 8, h = 2, label = L["启用"] },
        { key = "warningThresholdValue", type = "input", x = 10, y = 48, w = 11, h = 2, label = L["阈值(%)"], labelPos = "top" },
        { key = "warningColor", type = "color", x = 23, y = 48, w = 12, h = 2, label = L["阶段一颜色"] },
        { key = "dangerEnabled", type = "checkbox", x = 1, y = 52, w = 8, h = 2, label = L["启用"] },
        { key = "dangerThresholdValue", type = "input", x = 10, y = 52, w = 11, h = 2, label = L["阈值(%)"], labelPos = "top" },
        { key = "dangerColor", type = "color", x = 23, y = 52, w = 12, h = 2, label = L["阶段二颜色"] },
        { key = "extraColor1Enabled", type = "checkbox", x = 1, y = 56, w = 8, h = 2, label = L["启用"] },
        { key = "extraColor1ThresholdValue", type = "input", x = 10, y = 56, w = 11, h = 2, label = L["阈值(%)"], labelPos = "top" },
        { key = "extraColor1", type = "color", x = 23, y = 56, w = 12, h = 2, label = L["阶段三颜色"] },
        { key = "extraColor2Enabled", type = "checkbox", x = 1, y = 60, w = 8, h = 2, label = L["启用"] },
        { key = "extraColor2ThresholdValue", type = "input", x = 10, y = 60, w = 11, h = 2, label = L["阈值(%)"], labelPos = "top" },
        { key = "extraColor2", type = "color", x = 23, y = 60, w = 12, h = 2, label = L["阶段四颜色"] },

        { key = "subheader_bar", type = "subheader", x = 1, y = 65, w = 53, h = 1, label = L["酒池条外观"], labelSize = 20 },
        { key = "div_bar", type = "divider", x = 1, y = 66, w = 53, h = 1, label = "--[[ Bar ]]" },
        { key = "timerGroup", type = "timerBarGroup", x = 1, y = 68, w = 53, h = 26, label = L["酒池条样式"], labelSize = 20 },

        { key = "font_text_header", type = "header", x = 1, y = 96, w = 53, h = 2, label = L["文字设置"], labelSize = 20 },
        { key = "font_text", type = "fontgroup", x = 1, y = 100, w = 53, h = 17, label = L["酒池文字样式"], labelSize = 20 },

        { key = "subheader_cd_icon", type = "subheader", x = 1, y = 119, w = 53, h = 1, label = L["明志灵药冷却监控"], labelSize = 20 },
        { key = "div_cd_icon", type = "divider", x = 1, y = 120, w = 53, h = 1, label = "--[[ Elixir of Determination ]]" },
        { key = "desc_cd_icon", type = "description", x = 1, y = 122, w = 53, h = 2, label = L["用于监控 Elixir of Determination 冷却。可单独预览图标、设置就绪表现，并调整整组图标外观。"] },
        { key = "cooldownIconReadyMode", type = "dropdown", x = 1, y = 125, w = 16, h = 2, label = L["就绪时表现"], items = { { L["灰白"], "灰白" }, { L["高亮"], "高亮" }, { L["正常"], "正常" } } },
        { key = "cooldownIconPreview", type = "checkbox", x = 20, y = 125, w = 12, h = 2, label = L["预览监控图标"] },
        { key = "cooldownIcon", type = "icongroup", x = 1, y = 129, w = 53, h = 17, label = L["明志灵药图标设置"] },
        { key = "cooldownGlow", type = "glow_settings", x = 1, y = 148, w = 53, h = 17, label = L["明志灵药就绪高亮"] },
    }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EX_DEFAULTS = {
    cooldownIcon = {
        height = 40,
        iconID = 608949,
        reverse = false,
        showIcon = true,
        width = 40,
        x = -109,
        y = -68,
    },
    cooldownIconEnabled = true,
    cooldownIconPreview = false,
    cooldownIconReadyMode = "高亮",
    dangerColorA = 1,
    dangerColorB = 0.11372549831867,
    dangerColorG = 0.054901964962482,
    dangerColorR = 1,
    dangerEnabled = true,
    dangerThresholdValue = "140",
    enabled = true,
    extraColor1A = 1,
    extraColor1B = 0.96470594406128,
    extraColor1Enabled = true,
    extraColor1G = 0.11372549831867,
    extraColor1R = 1,
    extraColor1ThresholdValue = "180",
    extraColor2A = 1,
    extraColor2B = 1,
    extraColor2Enabled = false,
    extraColor2G = 0.2,
    extraColor2R = 0.75,
    extraColor2ThresholdValue = "300",
    font_text = {
        a = 1,
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = false,
        shadowX = 1,
        shadowY = -1,
        size = 16,
        x = 0,
        y = 0,
    },
    fullBarPercent = 200,
    hideBar = false,
    hideOnMounted = false,
    locked = true,
    posX = -8,
    posY = -107,
    preview = false,
    showText = true,
    textAlign = "CENTER",
    textColorFollowsBar = false,
    textValueOnly = false,
    timerGroup = {
        barBgColor = {
            a = 0.55,
            b = 0,
            g = 0,
            r = 0,
        },
        barBgColorA = 0.55,
        barBgColorB = 0,
        barBgColorG = 0,
        barBgColorR = 0,
        barColor = {
            a = 1,
            b = 0.52,
            g = 1,
            r = 0.52,
        },
        barColorA = 1,
        barColorB = 0.52,
        barColorG = 1,
        barColorR = 0.52,
        borderColorA = 1,
        borderColorB = 0.070588238537312,
        borderColorG = 0.082352943718433,
        borderColorR = 0.070588238537312,
        borderPadding = 1,
        borderSize = 1,
        borderTexture = "1 Pixel",
        height = 35,
        iconOffsetX = -2,
        iconOffsetY = 0,
        iconSide = "LEFT",
        iconSize = 26,
        showBorder = true,
        showIcon = true,
        texture = "Melli",
        width = 240,
    },
    warningColorA = 1,
    warningColorB = 0,
    warningColorG = 1,
    warningColorR = 0.98823535442352,
    warningEnabled = true,
    warningThresholdValue = "70",
    wiseElixirHideOutOfCombat = false,
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)

local function GetColor(dbKey)
    local r = EX_DB[dbKey .. "R"]
    local g = EX_DB[dbKey .. "G"]
    local b = EX_DB[dbKey .. "B"]
    local a = EX_DB[dbKey .. "A"]
    if r == nil and EX_DB[dbKey] and type(EX_DB[dbKey]) == "table" then
        return EX_DB[dbKey].r, EX_DB[dbKey].g, EX_DB[dbKey].b, EX_DB[dbKey].a
    end
    return r or 1, g or 1, b or 1, a or 1
end

local function GetBarTexturePath(textureName)
    local tex = textureName and LSM and LSM:Fetch("statusbar", textureName)
    if tex then return tex end
    return "Interface\\Buttons\\WHITE8X8"
end

local function GetBarBaseColor()
    local group = EX_DB.timerGroup or {}
    return group.barColorR or 0.52, group.barColorG or 1.0, group.barColorB or 0.52, group.barColorA or 1.0
end

local function ShouldShowText()
    return EX_DB.showText or EX_DB.hideBar
end

local function ParsePercentInput(value)
    local n = tonumber(value)
    if not n then return nil end
    return math_max(0, n)
end

local function BuildColorRules()
    local rules = {}

    local function AddRule(enabledKey, valueKey, colorKey)
        if not EX_DB[enabledKey] then return end
        local threshold = ParsePercentInput(EX_DB[valueKey])
        if threshold == nil then return end
        rules[#rules + 1] = {
            threshold = threshold,
            colorKey = colorKey,
        }
    end

    AddRule("warningEnabled", "warningThresholdValue", "warningColor")
    AddRule("dangerEnabled", "dangerThresholdValue", "dangerColor")
    AddRule("extraColor1Enabled", "extraColor1ThresholdValue", "extraColor1")
    AddRule("extraColor2Enabled", "extraColor2ThresholdValue", "extraColor2")

    table.sort(rules, function(a, b)
        if a.threshold == b.threshold then
            return a.colorKey > b.colorKey
        end
        return a.threshold > b.threshold
    end)

    return rules
end

local function GetBarColorForPercent(percent)
    local rules = BuildColorRules()
    for i = 1, #rules do
        local rule = rules[i]
        if percent >= rule.threshold then
            return GetColor(rule.colorKey)
        end
    end
    return GetBarBaseColor()
end

local function GetHighestEnabledThreshold()
    local rules = BuildColorRules()
    if #rules > 0 then
        return rules[1].threshold
    end
    return nil
end

local function IsBrewmasterActive()
    local state = ExwindTools.State or {}
    return state.ClassID == 10 and state.SpecID == BREWMASTER_SPEC_ID
end

local function IsWiseElixirKnown()
    if not _G.C_SpellBook or not _G.C_SpellBook.IsSpellKnown then
        return false
    end

    local ok, known = pcall(_G.C_SpellBook.IsSpellKnown, WISE_ELIXIR_SPELL_ID)
    return ok and known == true
end

local function IsCooldownIconAllowed()
    if not EX_DB.cooldownIconEnabled then return false end
    if EX_DB.hideOnMounted and ExwindTools.State and ExwindTools.State.IsMounted then return false end
    if EX_DB.wiseElixirHideOutOfCombat and ExwindTools.State and not ExwindTools.State.InCombat then return false end
    return IsBrewmasterActive() and IsWiseElixirKnown()
end

local function StopCooldownIconGlow(frame)
    if not frame or not LibCustomGlow then return end

    if LibCustomGlow.ButtonGlow_Stop then LibCustomGlow.ButtonGlow_Stop(frame) end
    if LibCustomGlow.PixelGlow_Stop then LibCustomGlow.PixelGlow_Stop(frame, "CooldownReady") end
    if LibCustomGlow.AutoCastGlow_Stop then LibCustomGlow.AutoCastGlow_Stop(frame, "CooldownReady") end
    if LibCustomGlow.ProcGlow_Stop then LibCustomGlow.ProcGlow_Stop(frame, "CooldownReady") end
    cooldownIconGlowActive = false
end

local function StartCooldownIconGlow(frame)
    if not frame or not LibCustomGlow or not EX_DB.cooldownGlowEnabled then return end
    if cooldownIconGlowActive then return end

    local color = {
        EX_DB.cooldownGlowColorR or 1,
        EX_DB.cooldownGlowColorG or 0.82,
        EX_DB.cooldownGlowColorB or 0,
        EX_DB.cooldownGlowColorA or 1,
    }
    local style = EX_DB.cooldownGlowStyle or "Action Button Glow"
    local frequency = EX_DB.cooldownGlowFrequency or 0.25
    local lines = EX_DB.cooldownGlowLines or 8
    local scale = EX_DB.cooldownGlowScale or 1
    local offset = EX_DB.cooldownGlowOffset or 0
    local frameLevel = frame:GetFrameLevel() + 5

    if style == "Pixel Glow" and LibCustomGlow.PixelGlow_Start then
        LibCustomGlow.PixelGlow_Start(frame, color, lines, frequency, 8, scale, offset, offset, true, "CooldownReady", frameLevel)
    elseif style == "Autocast Shine" and LibCustomGlow.AutoCastGlow_Start then
        LibCustomGlow.AutoCastGlow_Start(frame, color, lines, frequency, scale, offset, offset, "CooldownReady", frameLevel)
    elseif style == "Proc Glow" and LibCustomGlow.ProcGlow_Start then
        LibCustomGlow.ProcGlow_Start(frame, {
            key = "CooldownReady",
            color = color,
            startAnim = true,
            xOffset = offset,
            yOffset = offset,
        })
    elseif LibCustomGlow.ButtonGlow_Start then
        LibCustomGlow.ButtonGlow_Start(frame, color, frequency, frameLevel)
    else
        return
    end

    cooldownIconGlowActive = true
end

local function SetCooldownWidget(cooldown, startTime, duration)
    if not cooldown then return end
    if CooldownFrame_Set then
        CooldownFrame_Set(cooldown, startTime, duration, duration > 0 and 1 or 0)
    elseif cooldown.SetCooldown then
        cooldown:SetCooldown(startTime, duration)
    end
end

local function CreateCooldownIconFrame()
    if cooldownIconFrame then return end

    local f = CreateFrame("Frame", "ExBrewmasterCooldownIcon", UIParent, "BackdropTemplate")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:SetFrameStrata("MEDIUM")

    f.Icon = f:CreateTexture(nil, "ARTWORK")
    f.Icon:SetAllPoints(true)
    f.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    f.Cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    f.Cooldown:SetAllPoints(true)

    f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.Text:SetPoint("CENTER", f, "CENTER")

    f.Handle = f:CreateTexture(nil, "BACKGROUND")
    f.Handle:SetColorTexture(0, 1, 0, 0.35)
    f.Handle:SetAllPoints(true)
    f.Handle:Hide()

    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, f)
    f:EnableMouse(false)

    f:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and (ExwindTools.GlobalEditMode or not EX_DB.locked or EX_DB.cooldownIconPreview) then
            self.isMoving = true
            self:StartMoving()
        elseif button == "RightButton" and ExwindTools.GlobalEditMode then
            ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
        end
    end)

    f:SetScript("OnMouseUp", function(self, button)
        if button ~= "LeftButton" or not self.isMoving then return end
        self.isMoving = false
        self:StopMovingOrSizing()

        local cx, cy = UIParent:GetCenter()
        local sx, sy = self:GetCenter()
        if sx and sy and cx and cy then
            local scale = self:GetScale()
            EX_DB.cooldownIcon = EX_DB.cooldownIcon or {}
            EX_DB.cooldownIcon.x = math_floor(sx * scale - cx)
            EX_DB.cooldownIcon.y = math_floor(sy * scale - cy)
            if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() then
                ExwindTools.UI:RefreshContent()
            end
        end
    end)

    cooldownIconFrame = f
end

local function RefreshCooldownIconVisuals()
    if not cooldownIconFrame then return end

    local iconDB = EX_DB.cooldownIcon or {}
    local width = iconDB.width or 48
    local height = iconDB.height or 48
    local icon = iconDB.iconID or COOLDOWN_MONITOR_ICON_ID
    local shouldShowHandle = isEditModeActive or ExwindTools.GlobalEditMode or not EX_DB.locked or EX_DB.cooldownIconPreview

    cooldownIconFrame:SetSize(width, height)
    cooldownIconFrame:ClearAllPoints()
    cooldownIconFrame:SetPoint("CENTER", UIParent, "CENTER", iconDB.x or 0, iconDB.y or -150)
    cooldownIconFrame.Icon:SetTexture(icon)
    cooldownIconFrame.Icon:SetShown(iconDB.showIcon ~= false)
    cooldownIconFrame.Handle:SetShown(shouldShowHandle)
    cooldownIconFrame:EnableMouse(shouldShowHandle)
end

local function ApplyCooldownIconReadyState()
    if not cooldownIconFrame then return end

    cooldownIconFrame:SetScript("OnUpdate", nil)
    SetCooldownWidget(cooldownIconFrame.Cooldown, 0, 0)
    cooldownIconFrame.Text:SetText("")

    local mode = EX_DB.cooldownIconReadyMode or "高亮"
    cooldownIconFrame.Icon:SetDesaturated(mode == "灰白")

    if mode == "高亮" then
        StopCooldownIconGlow(cooldownIconFrame)
        StartCooldownIconGlow(cooldownIconFrame)
    else
        StopCooldownIconGlow(cooldownIconFrame)
    end
end

local function ApplyCooldownIconCountdownState()
    if not cooldownIconFrame then return end

    local now = GetTime()
    local remaining = cooldownIconEndTime - now
    if remaining <= 0 then
        cooldownIconEndTime = 0
        ApplyCooldownIconReadyState()
        return
    end

    StopCooldownIconGlow(cooldownIconFrame)
    cooldownIconFrame.Icon:SetDesaturated(false)
    SetCooldownWidget(cooldownIconFrame.Cooldown, cooldownIconEndTime - COOLDOWN_MONITOR_DURATION, COOLDOWN_MONITOR_DURATION)
    cooldownIconFrame.Text:SetText(tostring(math_ceil(remaining)))

    cooldownIconFrame:SetScript("OnUpdate", function(self)
        local left = cooldownIconEndTime - GetTime()
        if left <= 0 then
            cooldownIconEndTime = 0
            ApplyCooldownIconReadyState()
            return
        end
        self.Text:SetText(tostring(math_ceil(left)))
    end)
end

local function RefreshCooldownIconState()
    if isEditModeActive then
        CreateCooldownIconFrame()
        RefreshCooldownIconVisuals()
        if not cooldownIconFrame then return end

        if isEditModeVisible then
            cooldownIconFrame:Show()
            ApplyCooldownIconReadyState()
        else
            StopCooldownIconGlow(cooldownIconFrame)
            cooldownIconFrame:SetScript("OnUpdate", nil)
            cooldownIconFrame:Hide()
        end
        return
    end

    local iconDB = EX_DB.cooldownIcon or {}
    local shouldShow = iconDB.showIcon ~= false and (EX_DB.cooldownIconPreview or IsCooldownIconAllowed())
    if not shouldShow then
        if cooldownIconFrame then
            StopCooldownIconGlow(cooldownIconFrame)
            cooldownIconFrame:SetScript("OnUpdate", nil)
            cooldownIconFrame:Hide()
        end
        return
    end

    CreateCooldownIconFrame()
    RefreshCooldownIconVisuals()
    if not cooldownIconFrame then return end
    cooldownIconFrame:Show()

    local now = GetTime()
    if cooldownIconEndTime > now and not EX_DB.cooldownIconPreview then
        ApplyCooldownIconCountdownState()
        return
    end

    ApplyCooldownIconReadyState()
end

local function StartCooldownIconCountdown()
    if not IsCooldownIconAllowed() then return end

    local now = GetTime()
    if cooldownIconEndTime > now then return end

    cooldownIconEndTime = now + COOLDOWN_MONITOR_DURATION
    CreateCooldownIconFrame()
    RefreshCooldownIconVisuals()
    if not cooldownIconFrame then return end

    cooldownIconFrame:Show()
    ApplyCooldownIconCountdownState()
end

local function GetStaggerIcon()
    if _G.C_Spell and _G.C_Spell.GetSpellTexture then
        return _G.C_Spell.GetSpellTexture(STAGGER_SPELL_ID) or 608951
    end
    if _G.GetSpellTexture then
        return _G.GetSpellTexture(STAGGER_SPELL_ID) or 608951
    end
    return 608951
end

local function BuildStaggerInfo(percentOverride)
    local currentPercent
    local displayValue
    local maxValue

    if type(percentOverride) == "number" then
        currentPercent = percentOverride
        local fullBarPercent = math_max(1, EX_DB.fullBarPercent or 100)
        displayValue = math_min(currentPercent, fullBarPercent)
        maxValue = fullBarPercent
    else
        local maxHealth = UnitHealthMax("player") or 0
        local fullBarPercent = math_max(1, EX_DB.fullBarPercent or 100)
        local staggerValue = UnitStagger("player") or 0
        currentPercent = maxHealth > 0 and (staggerValue / maxHealth) * 100 or 0
        displayValue = staggerValue
        maxValue = maxHealth * (fullBarPercent / 100)
    end

    return {
        currentPercent = currentPercent,
        displayValue = displayValue,
        maxValue = maxValue,
        icon = GetStaggerIcon(),
    }
end

local function InitBarStructure(bar)
    bar:SetClampedToScreen(true)
    bar:SetMinMaxValues(0, 100)
    bar:SetValue(0)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bar.bg = bg

    bar.TextFrame = CreateFrame("Frame", nil, bar)
    bar.TextFrame:SetAllPoints(true)
    bar.TextFrame:SetFrameLevel(bar:GetFrameLevel() + 4)
    bar.Text = bar.TextFrame:CreateFontString(nil, "OVERLAY")
    bar.Icon = bar:CreateTexture(nil, "OVERLAY")
end

if ExwindFactory then
    ExwindFactory:InitPool("ExBrewmasterStaggerBar", "StatusBar", "BackdropTemplate", InitBarStructure)
end

local function AcquireBar()
    if not ExwindFactory then return nil end
    local bar = ExwindFactory:Acquire("ExBrewmasterStaggerBar", anchorFrame)
    bar._isPreview = nil
    bar:SetAlpha(1)
    return bar
end

local function ReleaseBar(bar)
    if not ExwindFactory or not bar then return end
    bar:SetScript("OnUpdate", nil)
    bar:SetAlpha(1)
    ExwindFactory:Release("ExBrewmasterStaggerBar", bar)
end

local function UpdateBarVisuals(bar)
    if not bar then return end

    local group = EX_DB.timerGroup or {}
    local staticDB = ExwindTools.DB_Static
    local width = group.width or 220
    local height = group.height or 26
    local tex = GetBarTexturePath(group.texture or "Melli")
    local hideBar = EX_DB.hideBar and true or false

    bar:SetSize(width, height)
    bar:SetStatusBarTexture(tex)
    bar.bg:SetTexture(tex)
    if hideBar then
        bar.bg:Hide()
    else
        bar.bg:SetVertexColor(
            group.barBgColorR or 0,
            group.barBgColorG or 0,
            group.barBgColorB or 0,
            group.barBgColorA or 0.55
        )
        bar.bg:Show()
    end

    local edgeTex = (not hideBar) and group.showBorder and group.borderTexture and group.borderTexture ~= "None"
        and LSM and LSM:Fetch("border", group.borderTexture) or nil
    if edgeTex then
        if not bar.BorderFrame then
            bar.BorderFrame = CreateFrame("Frame", nil, bar, "BackdropTemplate")
            bar.BorderFrame:SetFrameLevel(bar:GetFrameLevel() + 2)
        end
        local edgeSize = group.borderSize or 12
        local pad = group.borderPadding or 0
        bar.BorderFrame:ClearAllPoints()
        bar.BorderFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -pad, pad)
        bar.BorderFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", pad, -pad)
        bar.BorderFrame:SetBackdrop({
            edgeFile = edgeTex,
            edgeSize = edgeSize,
        })
        bar.BorderFrame:SetBackdropBorderColor(
            group.borderColorR or 1,
            group.borderColorG or 1,
            group.borderColorB or 1,
            group.borderColorA or 1
        )
        bar.BorderFrame:Show()
    elseif bar.BorderFrame then
        bar.BorderFrame:Hide()
    end

    if bar.Text then
        if bar.TextFrame then
            bar.TextFrame:SetFrameLevel(bar:GetFrameLevel() + 4)
            bar.TextFrame:SetAllPoints(true)
        end
        staticDB:ApplyFont(bar.Text, EX_DB.font_text)
        bar.Text:ClearAllPoints()
        bar.Text:SetPoint(EX_DB.textAlign or "CENTER", bar.TextFrame or bar, EX_DB.textAlign or "CENTER", EX_DB.font_text.x or 0, EX_DB.font_text.y or 0)
        bar.Text:SetJustifyH(EX_DB.textAlign or "CENTER")
        bar.Text:SetShown(ShouldShowText())
    end

    if bar.Icon then
        bar.Icon:Hide()
    end
end

local function ApplyBarState(bar, info)
    if not bar or not info then return end

    bar:SetMinMaxValues(0, info.maxValue)
    bar:SetValue(info.displayValue)

    local r, g, b, a = GetBarColorForPercent(info.currentPercent)
    if EX_DB.hideBar then
        bar:SetStatusBarColor(r, g, b, 0)
    else
        bar:SetStatusBarColor(r, g, b, a or 1)
    end

    if bar.Text then
        if EX_DB.textColorFollowsBar then
            bar.Text:SetTextColor(r, g, b, a or 1)
        else
            local font = EX_DB.font_text or {}
            bar.Text:SetTextColor(font.r or 1, font.g or 1, font.b or 1, font.a or 1)
        end

        if ShouldShowText() then
            if EX_DB.textValueOnly then
                bar.Text:SetText(string.format("%.0f", info.currentPercent))
            else
                bar.Text:SetText(string.format("%.0f%%", info.currentPercent))
            end
            bar.Text:Show()
        else
            bar.Text:SetText("")
            bar.Text:Hide()
        end
    end
end

local function ReLayout()
    if not anchorFrame then return end

    local group = EX_DB.timerGroup or {}
    local width = group.width or 220
    local height = group.height or 26
    anchorFrame:SetSize(width, height)

    local bar = isPreviewing and previewBar or activeBar
    if bar then
        bar:ClearAllPoints()
        bar:SetPoint("CENTER", anchorFrame, "CENTER")
    end
end

local function RefreshAnchorState()
    if not anchorFrame then return end

    anchorFrame:ClearAllPoints()
    anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX or 0, EX_DB.posY or 0)

    local shouldShowHandle = (isEditModeActive and isEditModeVisible) or ((not isEditModeActive) and (isPreviewing or (not EX_DB.locked)))
    anchorFrame:EnableMouse(shouldShowHandle)
    RefreshEditOverlay()
end

local function CreateAnchor()
    if anchorFrame then return end

    anchorFrame = CreateFrame("Frame", "ExBrewmasterStaggerAnchor", UIParent)
    anchorFrame:SetSize(220, 26)
    anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX or 0, EX_DB.posY or 0)
    anchorFrame:SetMovable(true)
    anchorFrame:SetClampedToScreen(true)

    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, anchorFrame)

    anchorFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and ((isEditModeActive and isEditModeVisible) or isPreviewing or not EX_DB.locked) then
            self.isMoving = true
            self:StartMoving()
        elseif button == "RightButton" and ExwindTools.GlobalEditMode then
            ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
        end
    end)

    anchorFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then
            self.isMoving = false
            self:StopMovingOrSizing()
            local cx, cy = UIParent:GetCenter()
            local sx, sy = self:GetCenter()
            if sx and sy and cx and cy then
                local scale = self:GetScale()
                EX_DB.posX = math_floor(sx * scale - cx)
                EX_DB.posY = math_floor(sy * scale - cy)
                if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() then
                    ExwindTools.UI:RefreshContent()
                end
            end
        end
    end)
end

local function EnsureActiveBar()
    if activeBar then return activeBar end
    activeBar = AcquireBar()
    if activeBar then
        UpdateBarVisuals(activeBar)
        activeBar:ClearAllPoints()
        activeBar:SetPoint("CENTER", anchorFrame, "CENTER")
    end
    return activeBar
end

local function ClearActiveBar()
    if not activeBar then return end
    ReleaseBar(activeBar)
    activeBar = nil
end

local function GetPreviewPercent()
    local fullBarPercent = math_max(1, EX_DB.fullBarPercent or 100)
    local previewPercent = fullBarPercent * 0.55
    local highestThreshold = GetHighestEnabledThreshold()

    if highestThreshold then
        previewPercent = math_max(previewPercent, highestThreshold + 10)
    end

    return math_min(previewPercent, fullBarPercent)
end

local function UpdateLiveBar()
    if isPreviewing then return end

    if isEditModeActive and not isEditModeVisible then
        ClearActiveBar()
        if anchorFrame then anchorFrame:Hide() end
        return
    end

    if (not EX_DB.enabled and not isEditModeActive) or not IsBrewmasterActive()
        or (EX_DB.hideOnMounted and ExwindTools.State and ExwindTools.State.IsMounted) then
        ClearActiveBar()
        if anchorFrame then anchorFrame:Hide() end
        return
    end

    CreateAnchor()
    if not anchorFrame then return end
    anchorFrame:Show()

    local bar = EnsureActiveBar()
    if not bar then return end

    ApplyBarState(bar, BuildStaggerInfo())
    bar:Show()
end

local function RefreshAll()
    if not EX_DB.enabled and not isPreviewing and not (isEditModeActive and isEditModeVisible) then
        ClearActiveBar()
        if anchorFrame then anchorFrame:Hide() end
        RefreshCooldownIconState()
        return
    end

    CreateAnchor()
    if not anchorFrame then return end

    if activeBar then
        UpdateBarVisuals(activeBar)
    end
    if previewBar then
        UpdateBarVisuals(previewBar)
    end

    RefreshAnchorState()
    ReLayout()

    if isEditModeActive and not isEditModeVisible then
        ClearActiveBar()
        anchorFrame:Hide()
    elseif isPreviewing then
        anchorFrame:Show()
    else
        UpdateLiveBar()
    end

    RefreshCooldownIconState()
end

local function ApplyEditModePresentation()
    if not isEditModeActive then
        if anchorFrame then
            ExwindTools:HideExwindToolsEditOverlay(anchorFrame)
        end
        if EX_DB.preview then
            TogglePreview(true)
        else
            TogglePreview(false)
            RefreshModuleState()
        end
        RefreshAll()
        return
    end

    CreateAnchor()
    if not anchorFrame then
        return
    end

    if isEditModeVisible then
        TogglePreview(true)
        anchorFrame:Show()
    else
        if previewBar then
            ReleaseBar(previewBar)
            previewBar = nil
        end
        isPreviewing = false
        ClearActiveBar()
        anchorFrame:Hide()
    end

    RefreshAll()
    RefreshEditOverlay()
end

function TogglePreview(enable)
    isPreviewing = enable and true or false
    CreateAnchor()
    if not anchorFrame then return end

    if isPreviewing then
        if activeBar then activeBar:Hide() end

        if previewBar then
            ReleaseBar(previewBar)
            previewBar = nil
        end

        previewBar = AcquireBar()
        if previewBar then
            previewBar._isPreview = true
            UpdateBarVisuals(previewBar)
            ApplyBarState(previewBar, BuildStaggerInfo(GetPreviewPercent()))
            previewBar:Show()
        end
        anchorFrame:Show()
    else
        if previewBar then
            ReleaseBar(previewBar)
            previewBar = nil
        end
        if activeBar then activeBar:Show() end
        UpdateLiveBar()
    end

    RefreshAll()
end

local function RefreshModuleState()
    if isEditModeActive and not isEditModeVisible then
        TogglePreview(false)
        ClearActiveBar()
        if anchorFrame then anchorFrame:Hide() end
        RefreshCooldownIconState()
        return
    end

    if isPreviewing then
        RefreshAll()
        return
    end

    if not EX_DB.enabled then
        TogglePreview(false)
        ClearActiveBar()
        if anchorFrame then anchorFrame:Hide() end
        RefreshCooldownIconState()
        return
    end

    RefreshAll()
end

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    if info.key == "preview" then
        if isEditModeActive then
            ApplyEditModePresentation()
        else
            TogglePreview(EX_DB.preview)
        end
        return
    end

    if info.key == "enabled" then
        if isEditModeActive then
            ApplyEditModePresentation()
            return
        end

        if EX_DB.enabled then
            RefreshModuleState()
        else
            TogglePreview(false)
            ClearActiveBar()
            if anchorFrame then anchorFrame:Hide() end
            RefreshCooldownIconState()
        end
        return
    end

    RefreshAll()
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    if info.key == "btn_reset_pos" then
        EX_DB.posX = 0
        EX_DB.posY = -180
        if anchorFrame then
            anchorFrame:ClearAllPoints()
            anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
        end
        RefreshAll()
    end
end)

ExwindTools:WatchState("SpecID", EXWIND_MODULE_KEY, function()
    RefreshModuleState()
end)

ExwindTools:WatchState("ClassID", EXWIND_MODULE_KEY, function()
    RefreshModuleState()
end)

ExwindTools:WatchState("IsMounted", EXWIND_MODULE_KEY, function()
    RefreshModuleState()
end)

ExwindTools:WatchState("InCombat", EXWIND_MODULE_KEY, function()
    RefreshModuleState()
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    EX_DB.preview = false
    EX_DB.cooldownIconPreview = false
    C_Timer.After(1, function()
        CreateAnchor()
        TogglePreview(false)
        RefreshModuleState()
    end)
end)

ExwindTools:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", EXWIND_MODULE_KEY, function(_, unit)
    if unit == "player" then
        RefreshModuleState()
    end
end)

ExwindTools:RegisterEvent("TRAIT_CONFIG_UPDATED", EXWIND_MODULE_KEY, function()
    RefreshModuleState()
end)

ExwindTools:RegisterEvent("UNIT_MAXHEALTH", EXWIND_MODULE_KEY, function(_, unit)
    if unit == "player" and EX_DB.enabled and not isPreviewing then
        UpdateLiveBar()
    end
end)

ExwindTools:RegisterEvent("UNIT_HEALTH", EXWIND_MODULE_KEY, function(_, unit)
    if unit == "player" and EX_DB.enabled and not isPreviewing then
        UpdateLiveBar()
    end
end)

ExwindTools:RegisterEvent("UNIT_AURA", EXWIND_MODULE_KEY, function(_, unit)
    if unit == "player" and EX_DB.enabled and not isPreviewing then
        UpdateLiveBar()
    end
end)

ExwindTools:RegisterEvent("SPELL_UPDATE_COOLDOWN", EXWIND_MODULE_KEY, function(_, spellID)
    if tonumber(spellID) == COOLDOWN_MONITOR_SPELL_ID then
        StartCooldownIconCountdown()
    end
end)

ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
        isEditModeActive = true
        CreateAnchor()
        CreateCooldownIconFrame()
    end,
    ExitEditMode = function()
        isEditModeActive = false
        isEditModeVisible = true
        ApplyEditModePresentation()
    end,
    SetEditVisible = function(_, visible)
        isEditModeVisible = (visible == true)
        ApplyEditModePresentation()
    end,
})

ExwindTools:ReportReady(EXWIND_MODULE_KEY)
