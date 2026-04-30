-- =============================================================
-- [[ 焦点施法监控 ]]
-- { Key = "ExClass.FocusCast", Name = "焦点施法提示", Desc = "监控焦点施法，支持施法条显示与提示音效。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExClass.FocusCast"
local LSM = LibStub("LibSharedMedia-3.0")
local ExwindFactory = _G.ExwindFactory

local activeBar = nil
local previewBar = nil
local anchorFrame = nil
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

-- ------------------------------------------------------------
-- 1. Grid 布局定义
-- ------------------------------------------------------------
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 53, h = 2, label = L["焦点施法提示"], labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 53, h = 2, label = L["仅监控焦点单位施法，支持施法条和音效独立开关。"] },
        { key = "div1", type = "divider", x = 1, y = 8, w = 53, h = 1, label = "--[[ Function ]]" },
        { key = "subheader_general", type = "subheader", x = 1, y = 7, w = 53, h = 1, label = L["通用设置"], labelSize = 20 },
        { key = "enabled", type = "checkbox", x = 1, y = 9, w = 8, h = 2, label = L["启用"] },
        { key = "showBar", type = "checkbox", x = 11, y = 9, w = 10, h = 2, label = L["显示施法条"] },
        { key = "playSound", type = "checkbox", x = 1, y = 22, w = 10, h = 2, label = L["播放提示音"] },
        { key = "muteSoundOnInterruptCD", type = "checkbox", x = 13, y = 22, w = 18, h = 2, label = L["打断CD时不播放音效"] },
        { key = "locked", type = "checkbox", x = 23, y = 9, w = 8, h = 2, label = L["锁定位置"] },
        { key = "preview", type = "checkbox", x = 34, y = 9, w = 8, h = 2, label = L["预览"] },
        { key = "btn_reset_pos", type = "button", x = 36, y = 16, w = 16, h = 2, label = L["重置位置"] },
        { key = "posX", type = "slider", x = 1, y = 16, w = 15, h = 2, label = L["位置 X"], min = -1000, max = 1000 },
        { key = "posY", type = "slider", x = 19, y = 16, w = 15, h = 2, label = L["位置 Y"], min = -1000, max = 1000 },
        { key = "subheader_sound", type = "subheader", x = 1, y = 19, w = 53, h = 1, label = L["音效设置"], labelSize = 20 },
        { key = "sound", type = "lsm_sound", x = 1, y = 26, w = 15, h = 2, label = L["选择音效"], labelPos = "top" },
        { key = "soundChannel", type = "dropdown", x = 19, y = 26, w = 14, h = 2, label = L["输出频道"], items = { { L["主音量"], "Master" }, { L["效果"], "SFX" }, { L["环境"], "Ambience" }, { L["音乐"], "Music" }, { L["对话"], "Dialog" } }, labelPos = "top" },
        { key = "btn_test_sound", type = "button", x = 36, y = 26, w = 16, h = 2, label = L["测试音效"] },
        { key = "subheader_bar", type = "subheader", x = 1, y = 36, w = 53, h = 2, label = L["施法条设置"], labelSize = 20 },
        { key = "showInterruptMarkerLine", type = "checkbox", x = 1, y = 39, w = 20, h = 2, label = L["显示打断技能CD转好的线条"] },
        { key = "interruptMarkerColor", type = "color", x = 23, y = 39, w = 12, h = 2, label = L["线条颜色"], labelPos = "top" },
        { key = "interruptMarkerWidth", type = "slider", x = 37, y = 39, w = 16, h = 2, label = L["线条粗细"], min = 1, max = 8 },
        { key = "hideOnInterruptCD", type = "checkbox", x = 1, y = 41, w = 15, h = 2, label = L["打断CD时隐藏可断条"] },
        { key = "showInterruptCDThreshold", type = "slider", x = 32, y = 41, w = 23, h = 2, label = L["打断CD剩余几秒时显示(左边颜色)"], min = 0, max = 10 },
        { key = "nonInterruptColor", type = "color", x = 1, y = 45, w = 15, h = 2, label = L["无法打断颜色"], labelPos = "top" },
        { key = "interruptCDColor", type = "color", x = 19, y = 41, w = 12, h = 2, label = L["打断CD时颜色"], labelPos = "top" },
        { key = "textAlign", type = "dropdown", x = 8, y = 78, w = 15, h = 2, label = L["法术对齐"], items = "LEFT,CENTER,RIGHT", labelPos = "left", labelSize = 18 },
        { key = "showTarget", type = "checkbox", x = 1, y = 103, w = 8, h = 2, label = L["显示目标"], labelSize = 18 },
        { key = "targetAlign", type = "dropdown", x = 21, y = 103, w = 15, h = 2, label = L["目标对齐"], items = "LEFT,CENTER,RIGHT", labelPos = "left", labelSize = 18 },
        { key = "showTimer", type = "checkbox", x = 1, y = 128, w = 10, h = 2, label = L["显示时间"], labelSize = 18 },
        { key = "timerAlign", type = "dropdown", x = 21, y = 128, w = 15, h = 2, label = L["时间对齐"], items = "LEFT,CENTER,RIGHT", labelPos = "left", labelSize = 18 },
        { key = "hideWhenNotInterruptible", type = "checkbox", x = 1, y = 12, w = 19, h = 2, label = L["|cffff080a隐藏不能打断的条 (隐藏钢条)|r"], labelSize = 18 },
        { key = "timerGroup", type = "timerBarGroup", x = 1, y = 47, w = 53, h = 27, label = L["计时条外观"], labelSize = 20 },
        { key = "font_spell_header", type = "header", x = 1, y = 75, w = 53, h = 2, label = L["法术文字设置"], labelSize = 20 },
        { key = "font_spell", type = "fontgroup", x = 1, y = 81, w = 53, h = 17, label = L["法术名称"], labelSize = 20 },
        { key = "font_target_header", type = "header", x = 1, y = 100, w = 53, h = 2, label = L["目标文字设置"], labelSize = 20 },
        { key = "font_target", type = "fontgroup", x = 1, y = 106, w = 53, h = 17, label = L["施法目标"], labelSize = 20 },
        { key = "font_timer_header", type = "header", x = 1, y = 125, w = 53, h = 2, label = L["时间文字设置"], labelSize = 20 },
        { key = "font_timer", type = "fontgroup", x = 1, y = 131, w = 53, h = 17, label = L["剩余时间"], labelSize = 20 },
        { key = "divider_7144", type = "divider", x = 1, y = 20, w = 53, h = 1, label = L["新组件"] },
        { key = "divider_5422", type = "divider", x = 1, y = 38, w = 53, h = 1, label = L["新组件"] },
        { key = "customSoundPath", type = "input", x = 1, y = 31, w = 53, h = 2, label = L["使用自定义路径 (如留空则默认使用上面选单的音效)"] },
        { key = "description_5178", type = "description", x = 1, y = 33, w = 53, h = 2, label = L["|cffafafaf输入路径: (举例) Interface\\AddOns\\Exwind\\sound\\注意打断.mp3|r"], labelSize = 14 },
        { key = "description_6169", type = "description", x = 24, y = 43, w = 31, h = 2, label = L["举例:打断CD剩余2秒时会显示左边颜色的条 打断CD好的瞬间会变色"], labelSize = 14 },
    }






    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EX_DEFAULTS = {
    enabled = false,
    font_spell = {
        a = 1,
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = false,
        shadowX = 1,
        shadowY = -1,
        size = 24,
        x = 4,
        y = 0,
    },
    font_target = {
        a = 1,
        b = 0.40392160415649,
        font = "默认",
        g = 0.80000007152557,
        outline = "OUTLINE",
        r = 0.27058824896812,
        shadow = false,
        shadowX = 1,
        shadowY = -1,
        size = 20,
        x = 48,
        y = 0,
    },
    font_timer = {
        a = 1,
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = false,
        shadowX = 1,
        shadowY = -1,
        size = 24,
        x = 0,
        y = 0,
    },
    hideOnInterruptCD = false,
    showInterruptCDThreshold = 2,
    hideWhenNotInterruptible = true,
    locked = false,
    nonInterruptColorA = 1,
    nonInterruptColorB = 0.16862745583057,
    nonInterruptColorG = 0.1294117718935,
    nonInterruptColorR = 1,
    interruptCDColorA = 0.6,
    interruptCDColorB = 0.5,
    interruptCDColorG = 0.5,
    interruptCDColorR = 0.5,
    interruptMarkerColorA = 1,
    interruptMarkerColorB = 0.25,
    interruptMarkerColorG = 0.95,
    interruptMarkerColorR = 1,
    interruptMarkerWidth = 2,
    playSound = false,
    showInterruptMarkerLine = true,
    muteSoundOnInterruptCD = true,
    posX = 23,
    posY = 272,
    preview = true,
    showBar = true,
    showTarget = true,
    showTimer = true,
    sound = "None",
    soundChannel = "Master",
    customSoundPath = "",
    targetAlign = "CENTER",
    textAlign = "LEFT",
    timerAlign = "RIGHT",
    timerGroup = {
        barBgColor = {
            a = 0.5,
            b = 0,
            g = 0,
            r = 0,
        },
        barBgColorA = 0.5,
        barBgColorB = 0,
        barBgColorG = 0,
        barBgColorR = 0,
        barColor = {
            a = 1,
            b = 1,
            g = 0.90980398654938,
            r = 0.29019609093666,
        },
        barColorA = 1,
        barColorB = 1,
        barColorG = 0.90980398654938,
        barColorR = 0.29019609093666,
        height = 50,
        iconOffsetX = -1,
        iconOffsetY = 0,
        iconSide = "LEFT",
        iconSize = 50,
        showIcon = true,
        texture = "Melli",
        width = 350,
    },
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)
if EX_DB.customSoundPath == nil and type(EX_DB.input_1127) == "string" then
    EX_DB.customSoundPath = EX_DB.input_1127
end

local function GetColor(dbKey)
    local r, g, b, a = EX_DB[dbKey .. "R"], EX_DB[dbKey .. "G"], EX_DB[dbKey .. "B"], EX_DB[dbKey .. "A"]
    if r == nil and EX_DB[dbKey] and type(EX_DB[dbKey]) == "table" then
        return EX_DB[dbKey].r, EX_DB[dbKey].g, EX_DB[dbKey].b, EX_DB[dbKey].a
    end
    return r or 1, g or 1, b or 1, a or 1
end

local function GetInterruptDynamicState()
    if _G.ExwindTools.State.InterruptReady then return "READY" end
    local remaining = 0
    local startTime = _G.ExwindTools.State.InterruptStartTime or 0
    local duration = _G.ExwindTools.State.InterruptDuration or 0
    if duration > 0 then remaining = (startTime + duration) - GetTime() end
    if remaining <= 0 then return "READY" end

    local threshold = EX_DB.showInterruptCDThreshold or 0
    if remaining <= threshold then
        return "ALMOST_READY"
    end

    if EX_DB.hideOnInterruptCD then
        return "HIDDEN"
    else
        return "ON_CD"
    end
end

local function ApplyDynamicInterrupt(bar, state)
    if not bar then return end
    if state == "HIDDEN" then
        bar:SetAlpha(0)
    else
        bar:SetAlpha(1)
        local sbTex = bar:GetStatusBarTexture()
        if sbTex and bar._isNotInt ~= nil then
            local nrR, nrG, nrB, nrA = GetColor("nonInterruptColor")
            local intColor = CreateColor(nrR, nrG, nrB, nrA)
            local normColor
            if state == "READY" then
                local group = EX_DB.timerGroup or {}
                normColor = CreateColor(group.barColorR or 1, group.barColorG or 0.7, group.barColorB or 0,
                    group.barColorA or 1)
            else
                local cdR, cdG, cdB, cdA = GetColor("interruptCDColor")
                normColor = CreateColor(cdR, cdG, cdB, cdA)
            end
            sbTex:SetVertexColorFromBoolean(bar._isNotInt, intColor, normColor)
        end
    end
    bar._lastIntState = state
end

local function PlayConfiguredSound(forcePlay)
    if not forcePlay and not EX_DB.playSound then return end
    local soundChannel = EX_DB.soundChannel or "Master"
    local customPath = EX_DB.customSoundPath
    if type(customPath) == "string" then
        customPath = customPath:gsub("^%s+", ""):gsub("%s+$", "")
        if customPath ~= "" then
            PlaySoundFile(customPath, soundChannel)
            return
        end
    end

    if not LSM then return end
    if not EX_DB.sound or EX_DB.sound == "None" then return end

    local soundFile = LSM:Fetch("sound", EX_DB.sound)
    if soundFile then
        PlaySoundFile(soundFile, soundChannel)
    end
end

local function InitCastBarStructure(bar)
    bar:SetClampedToScreen(true)
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bar.bg = bg

    bar.Text = bar:CreateFontString(nil, "OVERLAY")
    bar.TargetNameText = bar:CreateFontString(nil, "OVERLAY")
    bar.TimerText = bar:CreateFontString(nil, "OVERLAY")
    bar.Cooldown = CreateFrame("Cooldown", nil, bar, "CooldownFrameTemplate")
    bar.Icon = bar:CreateTexture(nil, "OVERLAY")

    bar.InterruptMarkerBar = CreateFrame("StatusBar", nil, bar)
    bar.InterruptMarkerBar:SetAllPoints(true)
    bar.InterruptMarkerBar:SetClipsChildren(true)
    bar.InterruptMarkerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    bar.InterruptMarkerBar:GetStatusBarTexture():SetAlpha(0)
    bar.InterruptMarkerBar:SetAlpha(0)

    bar.InterruptMarkerLine = bar.InterruptMarkerBar:CreateTexture(nil, "OVERLAY")
    bar.InterruptMarkerLine:SetTexture("Interface\\Buttons\\WHITE8x8")
    bar.InterruptMarkerLine:SetWidth(2)
    bar.InterruptMarkerLine:Hide()

end

if ExwindFactory then
    ExwindFactory:InitPool("ExFocusCastBar", "StatusBar", "BackdropTemplate", InitCastBarStructure)
end

local function AcquireBar()
    if not ExwindFactory then return nil end
    local bar = ExwindFactory:Acquire("ExFocusCastBar", anchorFrame)
    bar._isPreview = nil
    bar._isNotInt = nil
    bar._interruptMarkerInitialized = nil
    bar:SetAlpha(1)
    return bar
end

local function ReleaseBar(bar)
    if not ExwindFactory or not bar then return end
    bar:SetScript("OnUpdate", nil)
    if bar.Cooldown then
        bar.Cooldown:Clear()
    end
    bar:SetAlpha(1)
    ExwindFactory:Release("ExFocusCastBar", bar)
end

local function GetFocusCastInfo()
    if not UnitExists("focus") then return nil end

    local objCast = UnitCastingDuration("focus")
    local objChannel = UnitChannelDuration("focus")
    local activeObj = objCast or objChannel
    local isChanneling = (objChannel ~= nil)
    if not activeObj then return nil end

    local name, texture, notInterruptible, startTimeMS, endTimeMS, spellID
    if isChanneling then
        name, _, texture, startTimeMS, endTimeMS, _, notInterruptible, spellID = UnitChannelInfo("focus")
    else
        name, _, texture, startTimeMS, endTimeMS, _, _, notInterruptible, spellID = UnitCastingInfo("focus")
    end
    if not name then return nil end
    if notInterruptible == nil then notInterruptible = false end

    local finalTargetName = nil
    local targetClass = nil
    local shouldDisplayTarget = nil
    if EX_DB.showTarget then
        finalTargetName = UnitSpellTargetName("focus")
        targetClass = UnitSpellTargetClass("focus")
        if UnitShouldDisplaySpellTargetName then
            shouldDisplayTarget = UnitShouldDisplaySpellTargetName("focus")
        end
    end

    return {
        name = name,
        texture = texture,
        activeObj = activeObj,
        isChanneling = isChanneling,
        notInterruptible = notInterruptible,
        targetName = finalTargetName,
        targetClass = targetClass,
        shouldDisplayTarget = shouldDisplayTarget,
    }
end

local function GetInterruptCooldownDurationObject()
    local state = ExwindTools.State or {}
    local specID = state.SpecID or 0
    if specID == 0 then
        local specIndex = GetSpecialization()
        if specIndex then
            specID = GetSpecializationInfo(specIndex) or 0
        end
    end

    local interruptData = EXDB and EXDB.InterruptData and EXDB.InterruptData[specID]
    local interruptSpellID = interruptData and interruptData.id or 0
    if interruptSpellID == 0 then return nil end
    if not _G.C_Spell or not _G.C_Spell.GetSpellCooldownDuration then return nil end

    return _G.C_Spell.GetSpellCooldownDuration(interruptSpellID)
end

local function HideInterruptMarker(bar)
    if not bar or not bar.InterruptMarkerBar or not bar.InterruptMarkerLine then return end
    bar.InterruptMarkerBar:SetAlpha(0)
    bar.InterruptMarkerLine:Hide()
end

local function UpdateInterruptMarker(bar, castInfo)
    if not bar or not bar.InterruptMarkerBar or not bar.InterruptMarkerLine then return end
    if not EX_DB.showInterruptMarkerLine then
        HideInterruptMarker(bar)
        return
    end
    if not castInfo then
        HideInterruptMarker(bar)
        return
    end

    local interruptCDObject = GetInterruptCooldownDurationObject()
    if not interruptCDObject then
        HideInterruptMarker(bar)
        return
    end

    local castDO = castInfo.activeObj
    if not castDO then
        HideInterruptMarker(bar)
        return
    end

    local lineR, lineG, lineB, lineA = GetColor("interruptMarkerColor")
    local pointOnStatusbar = castInfo.isChanneling and "LEFT" or "RIGHT"
    local pointOfLine = castInfo.isChanneling and "RIGHT" or "LEFT"

    bar.InterruptMarkerBar:SetFillStyle(castInfo.isChanneling and Enum.StatusBarFillStyle.Reverse or Enum.StatusBarFillStyle.Standard)
    bar.InterruptMarkerBar:SetMinMaxValues(0, castDO:GetTotalDuration())
    bar.InterruptMarkerBar:SetValue(interruptCDObject:GetRemainingDuration())

    local lineWidth = EX_DB.interruptMarkerWidth or 2
    bar.InterruptMarkerLine:SetWidth(lineWidth)
    bar.InterruptMarkerLine:SetVertexColor(lineR, lineG, lineB, lineA or 1)
    bar.InterruptMarkerLine:SetHeight(bar:GetHeight())
    bar.InterruptMarkerLine:ClearAllPoints()
    bar.InterruptMarkerLine:SetPoint(pointOfLine, bar.InterruptMarkerBar:GetStatusBarTexture(), pointOnStatusbar)

    bar.InterruptMarkerBar:SetAlpha(1)
    bar.InterruptMarkerLine:SetAlpha(1)
    if bar.InterruptMarkerBar.SetAlphaFromBoolean then
        bar.InterruptMarkerBar:SetAlphaFromBoolean(castInfo.notInterruptible, 0, 1)
        bar.InterruptMarkerBar:SetAlphaFromBoolean(interruptCDObject:IsZero(), 0, bar.InterruptMarkerBar:GetAlpha())
    else
        bar.InterruptMarkerBar:SetAlpha(1)
    end
    if bar.InterruptMarkerLine.SetAlphaFromBoolean then
        bar.InterruptMarkerLine:SetAlphaFromBoolean(castInfo.notInterruptible, 0, 1)
        bar.InterruptMarkerLine:SetAlphaFromBoolean(interruptCDObject:IsZero(), 0, bar.InterruptMarkerLine:GetAlpha())
    end
    bar.InterruptMarkerLine:Show()
end

local function RefreshInterruptMarkerVisibility(bar, castInfo)
    if not bar or not bar.InterruptMarkerBar or not bar.InterruptMarkerLine then return end
    if not castInfo then
        HideInterruptMarker(bar)
        return
    end
    if bar.InterruptMarkerBar.SetAlphaFromBoolean then
        bar.InterruptMarkerBar:SetAlphaFromBoolean(castInfo.notInterruptible, 0, bar.InterruptMarkerBar:GetAlpha())
    end
    if bar.InterruptMarkerLine.SetAlphaFromBoolean then
        bar.InterruptMarkerLine:SetAlphaFromBoolean(castInfo.notInterruptible, 0, bar.InterruptMarkerLine:GetAlpha())
    end
end

local function UpdateBarVisuals(bar)
    if not bar then return end

    local db = EX_DB
    local group = db.timerGroup or {}
    local StaticDB = ExwindTools.DB_Static

    bar:SetSize(group.width or 220, group.height or 20)
    local texName = group.texture or "Melli"
    local tex = LSM and LSM:Fetch("statusbar", texName)
    if not tex then tex = "Interface\\Buttons\\WHITE8X8" end

    if tex then
        if bar.bg then
            bar.bg:SetTexture(tex)
            bar.bg:SetVertexColor(
                group.barBgColorR or 0,
                group.barBgColorG or 0,
                group.barBgColorB or 0,
                group.barBgColorA or 0.5
            )
        end
        bar:SetStatusBarTexture(tex)
    end

    -- [Feature] 应用边框相关样式 (确保边框渲染于状态条前台)
    local edgeTex = group.showBorder and group.borderTexture and group.borderTexture ~= "None" and
        LSM:Fetch("border", group.borderTexture) or nil
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
        local br, bg, bb, ba = group.borderColorR or 1, group.borderColorG or 1, group.borderColorB or 1,
            group.borderColorA or 1
        bar.BorderFrame:SetBackdropBorderColor(br, bg, bb, ba)
        bar.BorderFrame:Show()
    else
        if bar.BorderFrame then
            bar.BorderFrame:Hide()
        end
    end

    if bar.Text then
        StaticDB:ApplyFont(bar.Text, db.font_spell)
        bar.Text:ClearAllPoints()
        bar.Text:SetPoint(db.textAlign, bar, db.textAlign, db.font_spell.x, db.font_spell.y)
        bar.Text:SetJustifyH(db.textAlign)
    end

    if bar.TargetNameText then
        StaticDB:ApplyFont(bar.TargetNameText, db.font_target)
        bar.TargetNameText:ClearAllPoints()
        bar.TargetNameText:SetPoint(db.targetAlign, bar, db.targetAlign, db.font_target.x, db.font_target.y)
        bar.TargetNameText:SetJustifyH(db.targetAlign)
        bar.TargetNameText:SetShown(db.showTarget)
    end

    if bar.TimerText then
        StaticDB:ApplyFont(bar.TimerText, db.font_timer)
        bar.TimerText:ClearAllPoints()
        bar.TimerText:SetPoint(db.timerAlign, bar, db.timerAlign, db.font_timer.x, db.font_timer.y)
        bar.TimerText:SetJustifyH(db.timerAlign)
        bar.TimerText:SetShown((db.showTimer and bar._isPreview) or false)
    end

    if bar.Cooldown then
        bar.Cooldown:ClearAllPoints()
        bar.Cooldown:SetAllPoints(bar)
        bar.Cooldown:SetReverse(true)
        bar.Cooldown:SetDrawSwipe(false)
        bar.Cooldown:SetDrawEdge(false)
        bar.Cooldown:SetDrawBling(false)
        if bar.Cooldown.SetMinimumCountdownDuration then
            bar.Cooldown:SetMinimumCountdownDuration(0)
        end
        if bar.Cooldown.SetCountdownMillisecondsThreshold then
            bar.Cooldown:SetCountdownMillisecondsThreshold(10)
        end
        if bar.Cooldown.SetCountdownAbbrevThreshold then
            bar.Cooldown:SetCountdownAbbrevThreshold(60)
        end
        bar.Cooldown:SetHideCountdownNumbers(not db.showTimer or bar._isPreview)

        local countdown = bar.Cooldown.GetCountdownFontString and bar.Cooldown:GetCountdownFontString() or nil
        if countdown then
            StaticDB:ApplyFont(countdown, db.font_timer)
            countdown:ClearAllPoints()
            countdown:SetPoint(db.timerAlign, bar, db.timerAlign, db.font_timer.x, db.font_timer.y)
            countdown:SetJustifyH(db.timerAlign)
        end
    end

    if bar.Icon then
        bar.Icon:SetSize(group.iconSize or 20, group.iconSize or 20)
        bar.Icon:ClearAllPoints()
        local side = group.iconSide or "LEFT"
        if side == "LEFT" then
            bar.Icon:SetPoint("RIGHT", bar, "LEFT", group.iconOffsetX or 0, group.iconOffsetY or 0)
        else
            bar.Icon:SetPoint("LEFT", bar, "RIGHT", group.iconOffsetX or 0, group.iconOffsetY or 0)
        end
        bar.Icon:SetShown(group.showIcon)
        bar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    if bar.InterruptMarkerBar then
        bar.InterruptMarkerBar:SetFrameLevel(bar:GetFrameLevel() + 3)
    end

    -- 3. 增强：动态响应 颜色与透明度混合
    -- 核心修复：12.0 中 _isNotInt 可能是 secret value，绝不能使用 `== true`, `== false` 或 `not` 在 Lua 中进行分支。
    -- 我们仅负责生成颜色，然后将 raw _isNotInt 交还给引擎的 SetVertexColorFromBoolean
    if bar._isNotInt ~= nil then
        local state = GetInterruptDynamicState()
        ApplyDynamicInterrupt(bar, state)
        -- 使用安全 C 函数处理透明度隐藏逻辑 (hideWhenNotInterruptible)
        if EX_DB.hideWhenNotInterruptible and bar.SetAlphaFromBoolean then
            -- 如果它不可打断(_isNotInt == true)，则设置为完全透明(0)
            -- 如果它可打断(_isNotInt == false)，保持在上一步(ApplyDynamicInterrupt)设置的原有透明度(通常是1)
            bar:SetAlphaFromBoolean(bar._isNotInt, 0, bar:GetAlpha())
        end
    else
        bar:SetAlpha(1)
    end
end

local function ReLayout()
    if not anchorFrame then return end
    local group = EX_DB.timerGroup or {}
    local width = group.width or 220
    local height = group.height or 20

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

    anchorFrame = CreateFrame("Frame", "ExFocusCastAnchor", UIParent)
    anchorFrame:SetSize(220, 20)
    anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
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
            if sx and cx then
                local scale = self:GetScale()
                EX_DB.posX = math.floor(sx * scale - cx)
                EX_DB.posY = math.floor(sy * scale - cy)
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
    return activeBar
end

local function ClearActiveBar()
    if not activeBar then return end
    ReleaseBar(activeBar)
    activeBar = nil
end

local function ApplyFocusCastToBar(bar, castInfo)
    if not bar or not castInfo then return end

    bar._isPreview = nil
    bar._isNotInt = castInfo.notInterruptible
    UpdateBarVisuals(bar)

    bar.Text:SetText(castInfo.name or "")
    bar.Icon:SetTexture(castInfo.texture)

    if EX_DB.showTarget then
        bar.TargetNameText:SetText(castInfo.targetName or "")
        local tc = castInfo.targetClass
        local c = nil
        local tcIsSecret = issecretvalue and issecretvalue(tc)
        if tcIsSecret or tc then
            c = C_ClassColor.GetClassColor(tc)
        end
        if c then
            bar.TargetNameText:SetTextColor(c.r, c.g, c.b, 1)
        else
            bar.TargetNameText:SetTextColor(1, 1, 1, 1)
        end
        if castInfo.shouldDisplayTarget ~= nil then
            bar.TargetNameText:SetShown(castInfo.shouldDisplayTarget)
        else
            bar.TargetNameText:SetShown(castInfo.targetName ~= nil)
        end
    else
        bar.TargetNameText:SetText("")
        bar.TargetNameText:Hide()
    end

    if bar.SetTimerDuration then
        bar:SetTimerDuration(castInfo.activeObj, Enum.StatusBarInterpolation.None, (castInfo.isChanneling and 1 or 0))
    end
    if bar.Cooldown then
        bar.Cooldown:SetHideCountdownNumbers(not EX_DB.showTimer or bar._isPreview)
        if bar.Cooldown.SetCooldownFromDurationObject then
            bar.Cooldown:SetCooldownFromDurationObject(castInfo.activeObj, true)
        end
    end

    if not bar._interruptMarkerInitialized then
        UpdateInterruptMarker(bar, castInfo)
        bar._interruptMarkerInitialized = true
    else
        RefreshInterruptMarkerVisibility(bar, castInfo)
    end

    local needsUpdateTimer = EX_DB.showTimer and not bar._isPreview
    local needsDynamicVisual = not bar._isPreview

    if needsUpdateTimer or needsDynamicVisual then
        bar:SetScript("OnUpdate", function(self)
            if needsUpdateTimer then
                if self.Cooldown and self.Cooldown.SetCooldownFromDurationObject then
                    local dur = self:GetTimerDuration()
                    if dur then
                        self.Cooldown:SetCooldownFromDurationObject(dur, true)
                    else
                        self.Cooldown:Clear()
                    end
                end
            end
            if needsDynamicVisual then
                local state = GetInterruptDynamicState()
                if self._lastIntState ~= state then
                    ApplyDynamicInterrupt(self, state)
                    -- 同步刷新一次可能被覆盖的透明度
                    if EX_DB.hideWhenNotInterruptible and self.SetAlphaFromBoolean and self._isNotInt ~= nil then
                        self:SetAlphaFromBoolean(self._isNotInt, 0, self:GetAlpha())
                    end
                end
            end
        end)
        if EX_DB.showTimer and bar._isPreview then bar.TimerText:Show() end
    else
        if bar.TimerText then bar.TimerText:SetText("") end
        if bar.Cooldown then
            bar.Cooldown:SetHideCountdownNumbers(true)
            bar.Cooldown:Clear()
        end
        bar:SetScript("OnUpdate", nil)
    end
end

local function UpdateFocusCast()
    if isPreviewing then return end
    if not EX_DB.enabled then
        ClearActiveBar()
        if anchorFrame then anchorFrame:Hide() end
        return
    end

    CreateAnchor()
    if anchorFrame then anchorFrame:Show() end

    local castInfo = GetFocusCastInfo()
    if not castInfo then
        ClearActiveBar()
        ReLayout()
        return
    end

    if EX_DB.showBar then
        local bar = EnsureActiveBar()
        if bar then
            ApplyFocusCastToBar(bar, castInfo)
            bar:Show()
        end
    else
        ClearActiveBar()
    end

    ReLayout()
end

local function TryPlayFocusSound()
    if not EX_DB.enabled or not EX_DB.playSound then return end
    if EX_DB.muteSoundOnInterruptCD and GetInterruptDynamicState() ~= "READY" then
        return
    end
    PlayConfiguredSound(false)
end

local function RefreshAll()
    if not EX_DB.enabled and not isPreviewing and not (isEditModeActive and isEditModeVisible) then
        if anchorFrame then anchorFrame:Hide() end
        return
    end

    CreateAnchor()
    if anchorFrame then
        anchorFrame:SetShown(EX_DB.enabled or isPreviewing or (isEditModeActive and isEditModeVisible))
    end

    if activeBar then
        UpdateBarVisuals(activeBar)
    end
    if previewBar then
        UpdateBarVisuals(previewBar)
    end

    RefreshAnchorState()
    ReLayout()
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
            UpdateFocusCast()
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
        RefreshAll()
    else
        if previewBar then
            ReleaseBar(previewBar)
            previewBar = nil
        end
        isPreviewing = false
        ClearActiveBar()
        anchorFrame:Hide()
    end

    RefreshEditOverlay()
end

function TogglePreview(enable)
    isPreviewing = enable
    CreateAnchor()
    if not anchorFrame then return end

    if enable then
        if activeBar then activeBar:Hide() end
        if previewBar then
            ReleaseBar(previewBar)
            previewBar = nil
        end

        if EX_DB.showBar then
            previewBar = AcquireBar()
            if previewBar then
                previewBar._isPreview = true
                -- 预览模式的焦点施法条，演示时固定为“可打断”状态，接受自身打断CD联动
                previewBar._isNotInt = false
                UpdateBarVisuals(previewBar)

                previewBar.Text:SetText(L["焦点测试施法"])
                previewBar.Icon:SetTexture(136197)
                previewBar:SetMinMaxValues(0, 1)
                previewBar:SetValue(0.55)
                previewBar.InterruptMarkerBar:SetFillStyle(Enum.StatusBarFillStyle.Standard)
                previewBar.InterruptMarkerBar:SetMinMaxValues(0, 4)
                previewBar.InterruptMarkerBar:SetValue(3)
                do
                    local lineR, lineG, lineB, lineA = GetColor("interruptMarkerColor")
                    previewBar.InterruptMarkerLine:SetVertexColor(lineR, lineG, lineB, lineA or 1)
                end
                previewBar.InterruptMarkerLine:SetWidth(EX_DB.interruptMarkerWidth or 2)
                previewBar.InterruptMarkerLine:SetHeight(previewBar:GetHeight())
                previewBar.InterruptMarkerLine:ClearAllPoints()
                previewBar.InterruptMarkerLine:SetPoint("LEFT", previewBar.InterruptMarkerBar:GetStatusBarTexture(), "RIGHT")
                if EX_DB.showInterruptMarkerLine then
                    previewBar.InterruptMarkerBar:SetAlpha(1)
                    previewBar.InterruptMarkerLine:Show()
                else
                    previewBar.InterruptMarkerBar:SetAlpha(0)
                    previewBar.InterruptMarkerLine:Hide()
                end

                if previewBar.TargetNameText then
    previewBar.TargetNameText:SetText((UnitName("player")) or L["玩家"])
                    local _, class = UnitClass("player")
                    local colorObj = C_ClassColor.GetClassColor(class or "")
                    if colorObj then
                        previewBar.TargetNameText:SetTextColor(colorObj.r, colorObj.g, colorObj.b, 1)
                    end
                    previewBar.TargetNameText:SetShown(EX_DB.showTarget)
                end

                if previewBar.TimerText then
                    previewBar.TimerText:SetText("2.5")
                    previewBar.TimerText:SetShown(true)
                end

                previewBar:Show()
            end
        end
    else
        if previewBar then
            ReleaseBar(previewBar)
            previewBar = nil
        end
        UpdateFocusCast()
    end

    RefreshAll()
end

local function OnFocusSpellEvent(event, unit, castID, spellID, interruptedBy)
    if unit and unit ~= "focus" then return end
    if not EX_DB.enabled or isPreviewing then return end

    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        TryPlayFocusSound()
        UpdateFocusCast()
        return
    end

    UpdateFocusCast()
end

ExwindTools:RegisterEvent("PLAYER_FOCUS_CHANGED", EXWIND_MODULE_KEY, function()
    if not EX_DB.enabled or isPreviewing then return end
    UpdateFocusCast()
end)

ExwindTools:RegisterEvent("UNIT_SPELLCAST_START", EXWIND_MODULE_KEY, OnFocusSpellEvent)
ExwindTools:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", EXWIND_MODULE_KEY, OnFocusSpellEvent)
ExwindTools:RegisterEvent("UNIT_SPELLCAST_STOP", EXWIND_MODULE_KEY, OnFocusSpellEvent)
ExwindTools:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", EXWIND_MODULE_KEY, OnFocusSpellEvent)
ExwindTools:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", EXWIND_MODULE_KEY, OnFocusSpellEvent)
ExwindTools:RegisterEvent("UNIT_SPELLCAST_FAILED", EXWIND_MODULE_KEY, OnFocusSpellEvent)
ExwindTools:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", EXWIND_MODULE_KEY, OnFocusSpellEvent)
ExwindTools:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", EXWIND_MODULE_KEY, OnFocusSpellEvent)

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
            CreateAnchor()
            if anchorFrame then anchorFrame:Show() end
            RefreshAll()
            UpdateFocusCast()
        else
            TogglePreview(false)
            ClearActiveBar()
            if anchorFrame then anchorFrame:Hide() end
        end
        return
    end

    if info.key == "showBar" then
        if isEditModeActive then
            ApplyEditModePresentation()
        else
            if not EX_DB.showBar then
                ClearActiveBar()
            else
                UpdateFocusCast()
            end
        end
    end

    RefreshAll()
    UpdateFocusCast()
end)

-- [动态打断响应] 监听 State 变动
ExwindTools:WatchState("InterruptReady", EXWIND_MODULE_KEY, function()
    if not EX_DB.enabled then return end
    RefreshAll()
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    if info.key == "btn_reset_pos" then
        EX_DB.posX = 0
        EX_DB.posY = -140
        if anchorFrame then
            anchorFrame:ClearAllPoints()
            anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
        end
        RefreshAll()
    elseif info.key == "btn_test_sound" then
        PlayConfiguredSound(true)
    end
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    EX_DB.preview = false
    C_Timer.After(1, function()
        CreateAnchor()
        TogglePreview(false)
        RefreshAll()
        UpdateFocusCast()
    end)
end)

-- =============================================================
-- 全局编辑模式支持
-- =============================================================
ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
        isEditModeActive = true
        CreateAnchor()
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
