-- =============================================================
-- [[ M+施法监控 ]]
-- { Key = "ExM+.MythicCast", Name = "施法监控", Desc = "监控周围敌对目标的施法进度 (原 ExwindCast)", Category = 2 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExM+.MythicCast"
local LSM = LibStub("LibSharedMedia-3.0") -- 假定 ExwindTools 环境中有 LSM

-- ------------------------------------------------------------
-- 常量定义
-- ------------------------------------------------------------
local EXWIND_COLOR_INTERRUPTIBLE = CreateColor(0, 1, 0)     -- 能打断 (绿)
local EXWIND_COLOR_NOT_INTERRUPTIBLE = CreateColor(1, 0, 0) -- 不能打断 (红)

local ExwindFactory = _G.ExwindFactory

-- ------------------------------------------------------------
-- 本地变量 
-- ------------------------------------------------------------
local activeBars = {}
local usedBarsList = {}
local previewBars = {}
local anchorFrame = nil
local editHandleFrame = nil
local isPreviewing = false
local isEditModeActive = false
local isEditModeVisible = true
local editModeRestore = nil
local TogglePreview
local UpdateCast

local function RefreshEditOverlay()
    if not editHandleFrame then return end

    if isEditModeActive and isEditModeVisible then
        ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY, editHandleFrame, { ownerFrame = anchorFrame })
    else
        ExwindTools:HideExwindToolsEditOverlay(editHandleFrame)
    end
end

-- 常用 API 引用
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local WorldFrame = _G.WorldFrame
local GetTime = _G.GetTime
local UnitName = _G.UnitName
local UnitClass = _G.UnitClass
local C_ClassColor = _G.C_ClassColor
local string = _G.string
local type = _G.type
local pairs = _G.pairs
local next = _G.next
local select = _G.select
local tonumber = _G.tonumber
local math = _G.math
local table = _G.table
local ipairs = _G.ipairs
local print = _G.print
local UnitExists = _G.UnitExists
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local UnitCastingDuration = _G.UnitCastingDuration
local UnitChannelDuration = _G.UnitChannelDuration
local UnitGUID = _G.UnitGUID
local C_Spell = _G.C_Spell
local CreateColor = _G.CreateColor
local IsMouseButtonDown = _G.IsMouseButtonDown
local IsKeyDown = _G.IsKeyDown
local ResetCursor = _G.ResetCursor
local SetCursor = _G.SetCursor
local GetMouseFocus = _G.GetMouseFocus
local GetMouseFoci = _G.GetMouseFoci
local GameTooltip = _G.GameTooltip
local C_StringUtil = _G.C_StringUtil
local C_Timer = _G.C_Timer

local pendingCombatRechecks = {}
local combatRecheckGeneration = 0

-- ------------------------------------------------------------
-- 1. Grid 布局定义
-- ------------------------------------------------------------
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 53, h = 2, label = L["大米怪物施法 (MythicCast)"], labelSize = 25 },
        { key = "desc", type = "description", x = 1, y = 4, w = 53, h = 2, label = L["实时监控姓名板单位的施法进度。"] },
        { key = "div1", type = "divider", x = 1, y = 7, w = 53, h = 1, label = "--[[ Function ]]" },
        { key = "subheader_main", type = "subheader", x = 1, y = 9, w = 53, h = 2, label = L["通用设置"], labelSize = 20 },
        { key = "enabled", type = "checkbox", x = 1, y = 11, w = 6, h = 2, label = L["启用"] },
        { key = "locked", type = "checkbox", x = 10, y = 11, w = 8, h = 2, label = L["锁定位置"] },
        { key = "preview", type = "checkbox", x = 20, y = 11, w = 8, h = 2, label = L["预览模式"] },
        { key = "btn_reset_pos", type = "button", x = 34, y = 11, w = 14, h = 2, label = L["重置位置"] },
        { key = "posX", type = "slider", x = 1, y = 14, w = 17, h = 2, label = L["整体水平位置"], min = -1000, max = 1000 },
        { key = "posY", type = "slider", x = 21, y = 14, w = 17, h = 2, label = L["整体垂直位置"], min = -1000, max = 1000 },

        { key = "custom_attach_header", type = "header", x = 1, y = 18, w = 53, h = 2, label = L["自由依附 (Beta)"], labelSize = 20 },
        { key = "custom_attach_desc", type = "description", x = 1, y = 21, w = 48, h = 1, label = L["开启后可将施法条组依附于任意 UI 元素。若目标框体不存在，将自动对齐到屏幕中心。"] },
        { key = "attachToCustom", type = "checkbox", x = 1, y = 23, w = 10, h = 2, label = L["启用自由依附"] },
        { key = "customAttachTarget", type = "input", x = 12, y = 23, w = 26, h = 2, label = L["当前目标路径"] },
        { key = "btn_pick_frame", type = "button", x = 39, y = 23, w = 10, h = 2, label = L["鼠标选取"] },

        { key = "raid_header", type = "header", x = 1, y = 27, w = 53, h = 2, label = L["团队标记"], labelSize = 20 },
        { key = "showRaidIcon", type = "checkbox", x = 1, y = 30, w = 15, h = 2, label = L["显示团队标记"] },
        { key = "raidIconSize", type = "slider", x = 21, y = 30, w = 15, h = 2, label = L["标记大小"], min = 10, max = 64 },
        { key = "raidIconX", type = "slider", x = 1, y = 33, w = 15, h = 2, label = L["水平偏移"], min = -100, max = 100 },
        { key = "raidIconY", type = "slider", x = 21, y = 33, w = 15, h = 2, label = L["垂直偏移"], min = -100, max = 100 },

        { key = "color_header", type = "header", x = 1, y = 37, w = 53, h = 2, label = L["计时条外观"], labelSize = 20 },
        { key = "nonInterruptColor", type = "color", x = 21, y = 42, w = 15, h = 2, label = L["无法打断颜色"], labelPos = "top" },
        { key = "spacing", type = "slider", x = 1, y = 42, w = 17, h = 2, label = L["垂直间距"], min = 0, max = 50 },
        { key = "growDirection", type = "dropdown", x = 21, y = 45, w = 15, h = 2, label = L["增长方向"], items = "向下,向上" },
        { key = "maxBars", type = "slider", x = 1, y = 45, w = 17, h = 2, label = L["最大显示数量"], min = 1, max = 15 },
        { key = "timerGroup", type = "timerBarGroup", x = 1, y = 49, w = 53, h = 26, label = "", labelSize = 20 },

        { key = "font_spell_header", type = "header", x = 1, y = 77, w = 53, h = 2, label = L["字体：法术说明"], labelSize = 20 },
        { key = "textAlign", type = "dropdown", x = 1, y = 80, w = 15, h = 2, label = L["对齐方式"], items = "LEFT,CENTER,RIGHT" },
        { key = "font_spell", type = "fontgroup", x = 1, y = 83, w = 53, h = 17, label = "", labelSize = 20 },

        { key = "font_target_header", type = "header", x = 1, y = 102, w = 47, h = 2, label = L["字体：施法目标"], labelSize = 20 },
        { key = "showTarget", type = "checkbox", x = 1, y = 105, w = 15, h = 2, label = L["显示目标姓名"] },
        { key = "targetAlign", type = "dropdown", x = 18, y = 105, w = 15, h = 2, label = L["对齐方式"], items = "LEFT,CENTER,RIGHT" },
        { key = "mergeTargetIntoSpellName", type = "checkbox", x = 35, y = 105, w = 18, h = 2, label = L["并入法术名称"] },
        { key = "spellTargetInlineFormat", type = "input", x = 1, y = 108, w = 22, h = 2, label = L["中间分隔符"], placeholder = "-" },
        { key = "font_target", type = "fontgroup", x = 1, y = 111, w = 53, h = 18, label = "", labelSize = 20 },

        { key = "font_timer_header", type = "header", x = 1, y = 128, w = 53, h = 2, label = L["字体：冷却时间"], labelSize = 20 },
        { key = "showTimer", type = "checkbox", x = 1, y = 131, w = 15, h = 2, label = L["显示时间文字"] },
        { key = "timerAlign", type = "dropdown", x = 18, y = 131, w = 15, h = 2, label = L["对齐方式"], items = "LEFT,CENTER,RIGHT" },
        { key = "font_timer", type = "fontgroup", x = 1, y = 134, w = 53, h = 18, label = "", labelSize = 20 },
    }






    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local EX_DEFAULTS = {
    enabled = true,
    font_spell = {
        a = 1,
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = false,
        shadowX = 1,
        size = 20,
        x = 2,
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
        size = 16,
        x = 38,
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
        shadowX = 9,
        size = 17,
        x = 0,
        y = 0,
    },
    growDirection = "向上",
    locked = true,
    maxBars = 6,
    nonInterruptColorA = 1,
    nonInterruptColorB = 0.16862745583057,
    nonInterruptColorG = 0.1294117718935,
    nonInterruptColorR = 1,
    posX = -527,
    posY = -12,
    preview = false,
    raidIconSize = 27,
    raidIconX = -1,
    raidIconY = 0,
    -- scale removed
    showRaidIcon = true,
    showTarget = true,
    showTimer = true,
    mergeTargetIntoSpellName = false,
    spellTargetInlineFormat = "-",
    spacing = 1,
    targetAlign = "CENTER",
    textAlign = "LEFT",
    timerAlign = "RIGHT",
    attachToCustom = false,  -- 是否启用自由依附
    customAttachTarget = "", -- 目标框架名称或路径
    timerGroup = {
        barBgColor = {
            a = 0.5,
            b = 0,
            g = 0,
            r = 0,
        },
        barBgColorA = 0.71539187431335,
        barBgColorB = 0.27843138575554,
        barBgColorG = 0.27843138575554,
        barBgColorR = 0.27843138575554,
        barColor = {
            a = 1,
            b = 0,
            g = 0.7,
            r = 1,
        },
        barColorA = 1,
        barColorB = 1,
        barColorG = 0.90980398654938,
        barColorR = 0.29019609093666,
        height = 28,
        iconOffsetX = 0,
        iconOffsetY = 0,
        iconSide = "LEFT",
        iconSize = 30,
        showIcon = true,
        texture = "Melli",
        width = 224,
    },
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)

local function GetColor(dbKey)
    local r, g, b, a = EX_DB[dbKey .. "R"], EX_DB[dbKey .. "G"], EX_DB[dbKey .. "B"], EX_DB[dbKey .. "A"]
    if r == nil and EX_DB[dbKey] and type(EX_DB[dbKey]) == "table" then
        return EX_DB[dbKey].r, EX_DB[dbKey].g, EX_DB[dbKey].b, EX_DB[dbKey].a
    end
    return r or 1, g or 1, b or 1, a or 1
end

local function BuildInlineTargetText(targetName, targetClass)
    if not targetName then
        return targetName
    end

    local coloredTarget = targetName
    if targetClass then
        local classColor = C_ClassColor.GetClassColor(targetClass)
        if classColor and classColor.GenerateHexColor and WrapTextInColorCode then
            coloredTarget = WrapTextInColorCode(targetName, classColor:GenerateHexColor())
        end
    end

    local separator = EX_DB.spellTargetInlineFormat
    if type(separator) ~= "string" or separator == "" then
        separator = "-"
    end

    -- 兼容旧配置：如果用户之前填的是 "%s - %s" 这种格式串，自动提取中间分隔符
    local extracted = separator:match("^%%s(.-)%%s$")
    if extracted ~= nil then
        separator = extracted
    end

    local wrappedTarget = coloredTarget
    if C_StringUtil and C_StringUtil.WrapString then
        wrappedTarget = C_StringUtil.WrapString(coloredTarget, separator)
    else
        wrappedTarget = string.concat(separator, coloredTarget)
    end
    return wrappedTarget
end

local function BuildMergedSpellText(spellName, targetName, targetClass)
    if not spellName or not targetName then
        return spellName
    end

    local inlineTarget = BuildInlineTargetText(targetName, targetClass)
    if string.concat then
        return string.concat(spellName, inlineTarget)
    end
    return spellName
end

local function UpdateBarVisuals(bar)
    local db = EX_DB
    local group = db.timerGroup or {}
    local barWidth = group.width or 200
    local spellTextWidth
    if db.mergeTargetIntoSpellName then
        spellTextWidth = math.max(40, math.floor(barWidth * 0.85))
    else
        local timerReserve = db.showTimer and 48 or 0
        spellTextWidth = math.max(40, barWidth - timerReserve - 8)
    end
    -- 1. 基础视觉
    bar:SetSize(barWidth, group.height or 20)
    local texName = group.texture or "Melli"
    local tex = LSM:Fetch("statusbar", texName)
    if not tex then tex = "Interface\\Buttons\\WHITE8X8" end

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

    -- 2. 应用标准字体组 (EXDB:ApplyFont 会处理字体/大小/颜色/描边/阴影)
    local StaticDB = ExwindTools.DB_Static

    if bar.Text then
        StaticDB:ApplyFont(bar.Text, db.font_spell)
        bar.Text:ClearAllPoints()
        if db.mergeTargetIntoSpellName then
            bar.Text:SetPoint("LEFT", bar, "LEFT", db.font_spell.x, db.font_spell.y)
            bar.Text:SetJustifyH("LEFT")
        else
            bar.Text:SetPoint(db.textAlign, bar, db.textAlign, db.font_spell.x, db.font_spell.y)
            bar.Text:SetJustifyH(db.textAlign)
        end
        bar.Text:SetWidth(spellTextWidth)
        bar.Text:SetMaxLines(1)
        bar.Text:SetWordWrap(false)
        if bar.Text.SetNonSpaceWrap then
            bar.Text:SetNonSpaceWrap(false)
        end
    end

    if bar.TargetNameText then
        StaticDB:ApplyFont(bar.TargetNameText, db.font_target)
        bar.TargetNameText:ClearAllPoints()
        if db.mergeTargetIntoSpellName then
            -- 并排模式下不沿用独立目标名的大偏移量，否则会在中间制造大量空白
            bar.TargetNameText:SetPoint("LEFT", bar.Text, "RIGHT", 2, db.font_target.y)
            bar.TargetNameText:SetJustifyH("LEFT")
        else
            bar.TargetNameText:SetPoint(db.targetAlign, bar, db.targetAlign, db.font_target.x, db.font_target.y)
            bar.TargetNameText:SetJustifyH(db.targetAlign)
        end
        bar.TargetNameText:SetShown(db.showTarget and not db.mergeTargetIntoSpellName)
        bar.TargetNameText:SetWidth(math.max(30, barWidth - 16))
        bar.TargetNameText:SetMaxLines(1)
        bar.TargetNameText:SetWordWrap(false)
        if bar.TargetNameText.SetNonSpaceWrap then
            bar.TargetNameText:SetNonSpaceWrap(false)
        end


        if bar._isPreview then
            local _, class = UnitClass("player")
            local colorObj = C_ClassColor.GetClassColor(class)
            if colorObj then
                bar.TargetNameText:SetTextColor(colorObj.r, colorObj.g, colorObj.b, 1)
            end
        end
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
        -- 为所有图标应用 8% 裁剪 (Zoom)，去除暴雪原生的黑边
        bar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end

    if bar.RaidIcon then
        -- 实时视觉预览：应用设置中的大小和位置
        bar.RaidIcon:SetSize(db.raidIconSize or 24, db.raidIconSize or 24)
        bar.RaidIcon:ClearAllPoints()
        bar.RaidIcon:SetPoint("RIGHT", bar.Icon, "LEFT", db.raidIconX or -2, db.raidIconY or 0)

        -- 在预览模式下，为了让用户看清位置，如果没有真实标记且开启了显示，展示一个模拟标记(大饼)
        -- 预览模式的特殊处理
        if bar._isPreview then
            if bar.RaidIcon and EX_DB.showRaidIcon then
                bar.RaidIcon:Show()
                -- [Fix] 支持显示不通的图标（1-8 循环）
                local idx = bar._previewRaidIndex or 1
                bar.RaidIcon:SetSpriteSheetCell(idx, 4, 4)
            else
                if bar.RaidIcon then
                    bar.RaidIcon:Hide()
                end
            end
        end
    end

    -- 3. 增强：预览模式实时颜色预览
    local sbTex = bar:GetStatusBarTexture()
    if sbTex and bar._isPreview then
        local nrR, nrG, nrB, nrA = GetColor("nonInterruptColor")
        local intColor = CreateColor(nrR, nrG, nrB, nrA)
        local normColor = CreateColor(
            group.barColorR or 1,
            group.barColorG or 0.7,
            group.barColorB or 0,
            group.barColorA or 1
        )
        -- 使用存储的 _isNotInt 状态，确保修改颜色后实时刷新
        sbTex:SetVertexColorFromBoolean(bar._isNotInt, intColor, normColor)
    end
end

-- ------------------------------------------------------------
-- 锚点位移保存：支持自由依附模式下的相对坐标计算
-- ------------------------------------------------------------
local function SaveAnchorPosition()
    if not anchorFrame then return end
    local sx, sy = anchorFrame:GetCenter()
    if not sx or not sy then return end

    -- 默认参考点：屏幕中心 (UIParent)
    local tx, ty = UIParent:GetCenter()
    local targetScale = UIParent:GetEffectiveScale()
    local anchorScale = anchorFrame:GetEffectiveScale()

    -- 核心：如果是依附模式，则计算相对于目标框架中心的偏移量
    if EX_DB.attachToCustom and EX_DB.customAttachTarget ~= "" then
        local target = _G
        for part in string.gmatch(EX_DB.customAttachTarget, "([^%.]+)") do
            if target then target = target[part] else break end
        end
        if target and type(target) == "table" and target.GetCenter then
            local t_sx, t_sy = target:GetCenter()
            if t_sx and t_sy then
                tx, ty = t_sx, t_sy
                targetScale = target:GetEffectiveScale()
            end
        end
    end

    -- 考虑各自的有效缩放，换算成相对于锚点自身 Scale 的逻辑坐标
    EX_DB.posX = math.floor((sx * anchorScale - tx * targetScale) / anchorScale)
    EX_DB.posY = math.floor((sy * anchorScale - ty * targetScale) / anchorScale)

    -- 同步设置界面的滑块值
    if ExwindTools.UI and ExwindTools.UI.RefreshContent then
        ExwindTools.UI:RefreshContent()
    end
end

local function ReLayout()
    if not anchorFrame then return end
    local group = EX_DB.timerGroup or {}
    local height = group.height or 20
    local spacing = EX_DB.spacing or 0
    local list = isPreviewing and previewBars or usedBarsList
    local growUp = (EX_DB.growDirection == "向上")
    local maxLimit = EX_DB.maxBars or 5

    local visibleCount = 0
    for i, bar in ipairs(list) do
        if i <= maxLimit then
            visibleCount = visibleCount + 1
            bar:Show()
            bar:EnableMouse(false) -- [v4.7 Fix] 禁止条条感应鼠标，防止遮挡锚点拖动
        else
            bar:Hide()
        end
    end

    -- [v4.7 Fix] 核心重构：保持 anchorFrame 尺寸固定，作为逻辑原点
    -- 这样中心点 (CENTER) 永远不会因为条数变化而位移
    anchorFrame:SetSize(group.width or 220, 20)

    if anchorFrame.bg then
        local totalHeight = math.max(20, visibleCount * height + math.max(0, visibleCount - 1) * spacing)

        anchorFrame.bg:ClearAllPoints()
        anchorFrame.label:ClearAllPoints()
        anchorFrame.label:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)

        -- [v4.7.1] 动态感应层：让背景覆盖所有条目区域，并作为拖动手柄
        anchorFrame.bg:SetSize(group.width or 220, totalHeight)
        if growUp then
            -- 向上增长：背景底边对齐原点中心
            anchorFrame.bg:SetPoint("BOTTOM", anchorFrame, "CENTER")
        else
            -- 向下增长：背景顶边对齐原点中心
            anchorFrame.bg:SetPoint("TOP", anchorFrame, "CENTER")
        end

        -- 为背景手柄注入拖动逻辑 (转发给父级)
        anchorFrame.bg:EnableMouse(not EX_DB.locked)
        anchorFrame.bg:SetScript("OnMouseDown", function(_, button)
            if button == "LeftButton" and not EX_DB.locked then
                anchorFrame.isMoving = true
                anchorFrame:StartMoving()
            elseif button == "RightButton" and ExwindTools.GlobalEditMode then
                -- [v4.7.2 Fix] 转发右键点击，解决背景层遮挡 HUD 注册钩子的问题
                ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
            end
        end)
        anchorFrame.bg:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" and anchorFrame.isMoving then
                anchorFrame.isMoving = false
                anchorFrame:StopMovingOrSizing()
                SaveAnchorPosition() -- 使用统一保存逻辑
            end
        end)

        -- 所有的条相对于固定的 anchorFrame 进行堆叠
        for i, bar in ipairs(list) do
            if i <= maxLimit then
                bar:ClearAllPoints()
                local yOffset = (i - 1) * (height + spacing)
                if growUp then
                    bar:SetPoint("BOTTOM", anchorFrame, "CENTER", 0, yOffset)
                else
                    bar:SetPoint("TOP", anchorFrame, "CENTER", 0, -yOffset)
                end
            end
        end

        if editHandleFrame then
            editHandleFrame:ClearAllPoints()
            editHandleFrame:SetSize(group.width or 220, totalHeight)
            if growUp then
                editHandleFrame:SetPoint("BOTTOM", anchorFrame, "CENTER")
            else
                editHandleFrame:SetPoint("TOP", anchorFrame, "CENTER")
            end
        end
    end

    -- [Feature] 自由依附逻辑
    local attached = false
    if EX_DB.attachToCustom and EX_DB.customAttachTarget ~= "" then
        local target = _G
        for part in string.gmatch(EX_DB.customAttachTarget, "([^%.]+)") do
            if target then target = target[part] else break end
        end

        if target and type(target) == "table" and target.GetPoint then
            anchorFrame:ClearAllPoints()
            -- 默认对齐到中心，偏移量通过原来的 posX/Y 控制
            anchorFrame:SetPoint("CENTER", target, "CENTER", EX_DB.posX or 0, EX_DB.posY or 0)
            attached = true
        end
    end

    if not attached then
        -- [Fallback] 如果依附目标不存在，自动回退到相对于屏幕中心（UIParent）
        anchorFrame:ClearAllPoints()
        anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX or 0, EX_DB.posY or 0)
    end
end

local function RefreshAll()
    if isPreviewing then
        -- 如果在预览模式，重新生成指定数量的预览条
        TogglePreview(false)
        TogglePreview(true)
    else
        for unit, bar in pairs(activeBars) do
            UpdateBarVisuals(bar)
            UpdateCast(unit)
        end
    end
    ReLayout()
    if anchorFrame then
        -- 整体缩放功能已移除

        if EX_DB.locked then
            anchorFrame:EnableMouse(false)
            anchorFrame.bg:Hide()
            anchorFrame.label:Hide()
        else
            anchorFrame:EnableMouse(true)
            anchorFrame.bg:Show()
            anchorFrame.label:Show()
        end
    end
end

-- ------------------------------------------------------------
-- 框架拾取器 (Frame Picker)
-- ------------------------------------------------------------
local pickerOverlay = nil
local highlightFrame = nil

local function GetRawFrameName(frame)
    if not frame then return end
    local name = frame.GetName and frame:GetName()
    if name then return name end

    -- 处理匿名框架：向上查询父级并探测 Key
    local parent = frame.GetParent and frame:GetParent()
    if parent then
        for k, v in pairs(parent) do
            if v == frame then
                local pName = GetRawFrameName(parent)
                return pName and (pName .. "." .. k) or nil
            end
        end
    end
    return nil
end

local function StartFramePicker()
    if not pickerOverlay then
        pickerOverlay = CreateFrame("Frame")
    end

    if not highlightFrame then
        highlightFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        highlightFrame:SetFrameStrata("TOOLTIP")
        highlightFrame:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            edgeSize = 2,
        })
        highlightFrame:SetBackdropBorderColor(0, 1, 0) -- 经典绿色
    end

    local lastFocus = nil
    pickerOverlay:SetScript("OnUpdate", function(self)
        -- 监听退出 (右键 或 ESC)
        if IsMouseButtonDown("RightButton") or IsKeyDown("ESCAPE") then
            self:SetScript("OnUpdate", nil)
            highlightFrame:Hide()
            ResetCursor()
            GameTooltip:Hide()
            return
        end

        SetCursor("CAST_CURSOR")

        local focus
        if GetMouseFoci then
            local foci = GetMouseFoci()
            focus = foci and foci[1]
        elseif GetMouseFocus then
            focus = GetMouseFocus()
        end

        if focus and focus ~= WorldFrame and focus ~= highlightFrame then
            local name = GetRawFrameName(focus)
            if name then
                if focus ~= lastFocus then
                    highlightFrame:ClearAllPoints()
                    highlightFrame:SetPoint("BOTTOMLEFT", focus, "BOTTOMLEFT", -2, -2)
                    highlightFrame:SetPoint("TOPRIGHT", focus, "TOPRIGHT", 2, 2)
                    highlightFrame:Show()
                    lastFocus = focus
                end

                GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
                GameTooltip:SetText("|cff00ff00" .. L["拾取中: "] .. "|r" .. name)
                GameTooltip:AddLine("|cffffffff" .. L["左键 : 选择该框架"] .. "|r")
                GameTooltip:AddLine("|cffaaaaaa" .. L["右键/ESC : 取消退出"] .. "|r")
                GameTooltip:Show()

                -- 监听保存 (左键)
                if IsMouseButtonDown("LeftButton") then
                    EX_DB.customAttachTarget = name
                    EX_DB.attachToCustom = true
                    self:SetScript("OnUpdate", nil)
                    highlightFrame:Hide()
                    ResetCursor()
                    GameTooltip:Hide()

                    if ExwindTools.UI and ExwindTools.UI.RefreshContent then
                        ExwindTools.UI:RefreshContent()
                    end
                    RefreshAll()
                end
                return
            end
        end

        highlightFrame:Hide()
        lastFocus = nil
        GameTooltip:Hide()
    end)
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

    -- 团队标记图标 (Raid Icon)
    local ri = bar:CreateTexture(nil, "OVERLAY")
    ri:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    ri:Hide()
    bar.RaidIcon = ri
end

if ExwindFactory then
    ExwindFactory:InitPool("ExMythicCastBar", "StatusBar", "BackdropTemplate", InitCastBarStructure)
end

local function AcquireBar()
    if not ExwindFactory then return end
    local bar = ExwindFactory:Acquire("ExMythicCastBar", anchorFrame)
    -- 关键：由于框架池复用机制，必须手动清除预览标记，否则战斗中条会卡在预览状态(如2.5s)
    bar._isPreview = nil
    bar._isNotInt = nil
    if bar.RaidIcon then bar.RaidIcon:Hide() end
    UpdateBarVisuals(bar)
    return bar
end

local function ReleaseBar(bar)
    if not ExwindFactory or not bar then return end
    bar:SetScript("OnUpdate", nil)
    if bar.Cooldown then
        bar.Cooldown:Clear()
    end
    ExwindFactory:Release("ExMythicCastBar", bar)
end

local function ScheduleCombatRecheck(unit)
    if not C_Timer or pendingCombatRechecks[unit] then return end
    local generation = combatRecheckGeneration
    pendingCombatRechecks[unit] = true
    C_Timer.After(0.1, function()
        if generation ~= combatRecheckGeneration then return end
        pendingCombatRechecks[unit] = nil
        if not EX_DB.enabled or isPreviewing or not UnitExists(unit) then return end
        if not string.match(unit, "^nameplate%d+$") or UnitIsUnit(unit, "player") or not UnitCanAttack("player", unit) then
            return
        end
        -- 严格过滤：仅在单位已进战斗时才允许显示
        if UnitAffectingCombat(unit) then
            UpdateCast(unit, false)
        end
    end)
end

UpdateCast = function(unit, allowCombatRecheck)
    if isPreviewing then return end


    -- 解决进战瞬间事件顺序问题：施法开始可能早于怪物战斗状态同步，短延迟复查一次。
    -- 严格过滤：仅检查单位是否处于战斗中
    local inCombat = UnitAffectingCombat(unit)
    if not inCombat and unit ~= "player" then
        local bar = activeBars[unit]
        if allowCombatRecheck and not bar then
            ScheduleCombatRecheck(unit)
        end
        if bar then
            activeBars[unit] = nil
            for i, b in ipairs(usedBarsList) do
                if b == bar then
                    table.remove(usedBarsList, i); break
                end
            end
            ReleaseBar(bar); ReLayout()
        end
        return
    end

    local objCast = UnitCastingDuration(unit)
    local objChannel = UnitChannelDuration(unit)
    local activeObj = objCast or objChannel
    local isChanneling = (objChannel ~= nil)

    if not activeObj then
        local bar = activeBars[unit]
        if bar then
            activeBars[unit] = nil
            for i, b in ipairs(usedBarsList) do
                if b == bar then
                    table.remove(usedBarsList, i); break
                end
            end
            ReleaseBar(bar)
            ReLayout()
        end
        return
    end

    local bar = activeBars[unit]
    if not bar then
        bar = AcquireBar()
        activeBars[unit] = bar
        table.insert(usedBarsList, bar)
        ReLayout()
    end

    local name, texture, notInterruptible;
    if isChanneling then
        name, _, texture, _, _, _, notInterruptible = UnitChannelInfo(unit)
    else
        name, _, texture, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
    end

    if not name then return end

    local finalTargetName = nil
    local targetClass = nil
    if EX_DB.showTarget or EX_DB.mergeTargetIntoSpellName then
        finalTargetName = UnitSpellTargetName(unit)
        targetClass = UnitSpellTargetClass(unit)
    end

    if EX_DB.mergeTargetIntoSpellName then
        bar.Text:SetText(BuildMergedSpellText(name, finalTargetName, targetClass))
    else
        bar.Text:SetText(name)
    end
    bar.Icon:SetTexture(texture)

    -- 12.0 适配：显示团队标记 (Raid Icon)
    -- GetRaidTargetIndex 在 12.0 返回的是 Secret Number
    local raidIndex = GetRaidTargetIndex(unit)
    if raidIndex and bar.RaidIcon and EX_DB.showRaidIcon then
        bar.RaidIcon:Show()
        -- 利用 12.0 专用 API 安全地根据秘机索引设置精灵图单元格 (4x4 布局)
        bar.RaidIcon:SetSpriteSheetCell(raidIndex, 4, 4)
    else
        if bar.RaidIcon then bar.RaidIcon:Hide() end
    end

    if notInterruptible == nil then notInterruptible = false end

    local sbTex = bar:GetStatusBarTexture()
    if sbTex then
        -- 为 12.0 Secret Boolean 适配：严禁在 Lua 中对 notInterruptible 进行布尔测试
        local nrR, nrG, nrB, nrA = GetColor("nonInterruptColor")
        local intColor = CreateColor(nrR, nrG, nrB, nrA)

        local group = EX_DB.timerGroup
        local normColor = CreateColor(
            group.barColorR or 1,
            group.barColorG or 0.7,
            group.barColorB or 0,
            group.barColorA or 1
        )

        -- 使用 12.0 安全 API，其内部处理 Secret Boolean 逻辑
        sbTex:SetVertexColorFromBoolean(notInterruptible, intColor, normColor)
    end

    if bar.SetTimerDuration then
        bar:SetTimerDuration(activeObj, Enum.StatusBarInterpolation.None, (isChanneling and 1 or 0))
    end
    if bar.Cooldown then
        bar.Cooldown:SetHideCountdownNumbers(not EX_DB.showTimer or bar._isPreview)
        if bar.Cooldown.SetCooldownFromDurationObject then
            bar.Cooldown:SetCooldownFromDurationObject(activeObj, true)
        end
    end

    if bar.TimerText and not bar._isPreview then
        bar.TimerText:SetText("")
    end
    if bar.Cooldown and (not EX_DB.showTimer or bar._isPreview) then
        bar.Cooldown:SetHideCountdownNumbers(true)
        bar.Cooldown:Clear()
    end
    bar:SetScript("OnUpdate", nil)

    if bar.TargetNameText and (EX_DB.showTarget or EX_DB.mergeTargetIntoSpellName) then
        local shouldShow = false
        if UnitShouldDisplaySpellTargetName then
            shouldShow = UnitShouldDisplaySpellTargetName(unit)
        else
            shouldShow = finalTargetName ~= nil
        end

        if EX_DB.mergeTargetIntoSpellName then
            bar.TargetNameText:SetText("")
            bar.TargetNameText:Hide()
        else
            bar.TargetNameText:SetText(finalTargetName)

            local c = nil
            local targetClassIsSecret = issecretvalue and issecretvalue(targetClass)
            if targetClassIsSecret or targetClass then
                c = C_ClassColor.GetClassColor(targetClass)
            end
            if c then
                bar.TargetNameText:SetTextColor(c.r, c.g, c.b, 1)
            else
                bar.TargetNameText:SetTextColor(GetColor("textColor"))
            end
            bar.TargetNameText:SetShown(shouldShow)
        end
    else
        if bar.TargetNameText then bar.TargetNameText:Hide() end
    end
end

local function CreateAnchor()
    if anchorFrame then return end
    anchorFrame = CreateFrame("Frame", "ExMythicCastAnchor", UIParent)
    anchorFrame:SetSize(200, 20)
    anchorFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
    anchorFrame:SetMovable(true); anchorFrame:SetClampedToScreen(true); anchorFrame:RegisterForDrag("LeftButton")
    anchorFrame.bg = anchorFrame:CreateTexture(nil, "BACKGROUND")
    -- [Fix] 移除 SetAllPoints，改由 ReLayout 动态控制背景伸展方向
    anchorFrame.bg:SetColorTexture(0, 1, 0, 0.5)
    anchorFrame.label = anchorFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    anchorFrame.label:SetPoint("CENTER")
    anchorFrame.label:SetText(L["M+施法监控"])

    editHandleFrame = CreateFrame("Frame", nil, anchorFrame)
    editHandleFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT", 0, 0)
    editHandleFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT", 0, 0)
    editHandleFrame:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMLEFT", 0, 0)
    editHandleFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT", 0, 0)

    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, anchorFrame)

    -- [v4.7 Fix] 确保锚点点击感应正常，且能正确停止拖动
    anchorFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not EX_DB.locked then
            self.isMoving = true
            self:StartMoving()
        end
    end)

    anchorFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and self.isMoving then
            self.isMoving = false
            self:StopMovingOrSizing()
            SaveAnchorPosition() -- 使用统一保存逻辑
        end
    end)
    RefreshAll()
end

function TogglePreview(enable)
    isPreviewing = enable
    if enable then
        -- [v3.1 Fix] 预览模式自动启用拖动
        if anchorFrame then
            anchorFrame:EnableMouse(true)
            anchorFrame.bg:Show()
            anchorFrame.label:Show()
        end
        RefreshEditOverlay()

        for _, bar in pairs(activeBars) do bar:Hide() end
        -- 始终清理并从池中归还旧预览条，确保数量和设置对齐
        for i = #previewBars, 1, -1 do
            local bar = previewBars[i]
            bar:Hide()
            ReleaseBar(bar)
            table.remove(previewBars, i)
        end

        local nrR, nrG, nrB, nrA = GetColor("nonInterruptColor")
        local intColor = CreateColor(nrR, nrG, nrB, nrA)
        local group = EX_DB.timerGroup
        local normColor = CreateColor(
            group.barColorR or 1,
            group.barColorG or 0.7,
            group.barColorB or 0,
            group.barColorA or 1
        )

        -- 根据当前“最大显示数量”生成预览
        local maxLimit = EX_DB.maxBars or 5
        for i = 1, maxLimit do
            local bar = AcquireBar()
            bar._isPreview = true
            -- [v4.3.17] 模拟标记在 1-8 之间循环显示
            bar._previewRaidIndex = (i - 1) % 8 + 1
            bar._isNotInt = (i % 2 == 1) -- 奇数行显示“不可打断”样式演示
            local previewSpellName = L["测试施法 "] .. i
            local previewTargetName = UnitName("player") or L["玩家"]
            local _, previewClass = UnitClass("player")
            if EX_DB.mergeTargetIntoSpellName then
                bar.Text:SetText(BuildMergedSpellText(previewSpellName, previewTargetName, previewClass))
            else
                bar.Text:SetText(previewSpellName)
            end
            bar.Icon:SetTexture(136197)  -- 演示图标
            bar:SetMinMaxValues(0, 1)
            bar:SetValue(0.5)

            -- [Fix] 在设置预览标记后立即刷新视觉，确保模拟团队标记可见
            UpdateBarVisuals(bar)

            -- 安全应用 12.0 预览颜色
            local sbTex = bar:GetStatusBarTexture()
            if sbTex then
                sbTex:SetVertexColorFromBoolean(bar._isNotInt, intColor, normColor)
            end

            -- 演示目标和时间
            if bar.TargetNameText then
                if EX_DB.mergeTargetIntoSpellName then
                    bar.TargetNameText:SetText("")
                    bar.TargetNameText:Hide()
                else
                    bar.TargetNameText:SetText(UnitName("player"))
                    bar.TargetNameText:Show()
                end
            end
            if bar.TimerText then
                bar.TimerText:SetText(L["2.5s"])
                bar.TimerText:Show()
            end

            table.insert(previewBars, bar)
        end
    else
        -- 退出预览，清空模拟数据
        for i = #previewBars, 1, -1 do
            local bar = previewBars[i]
            bar:Hide()
            ReleaseBar(bar)
            table.remove(previewBars, i)
        end
        for _, bar in pairs(activeBars) do UpdateCast(bar.unit) end

        -- [v3.1 Fix] 退出预览时恢复锁定状态
        if anchorFrame then
            if EX_DB.locked then
                anchorFrame:EnableMouse(false)
                anchorFrame.bg:Hide()
                anchorFrame.label:Hide()
            else
                anchorFrame:EnableMouse(true)
                anchorFrame.bg:Show()
                anchorFrame.label:Show()
            end
        end
        RefreshEditOverlay()
    end
    ReLayout()
end

-- =============================================================
-- 事件处理与状态管理
-- =============================================================

local function OnEvent(event, unit)
    -- [Fix] 严格过滤：仅监控敌对单位血条(nameplate)，排除玩家以及友方/队友单位
    if not EX_DB.enabled or not unit then return end
    if not string.match(unit, "^nameplate%d+$") or UnitIsUnit(unit, "player") or not UnitCanAttack("player", unit) then
        return
    end
    local allowCombatRecheck = event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START"
    UpdateCast(unit, allowCombatRecheck)
end

local function OnUnitRemoved(event, unit)
    pendingCombatRechecks[unit] = nil
    local bar = activeBars[unit]
    if bar then
        activeBars[unit] = nil
        for i, b in ipairs(usedBarsList) do
            if b == bar then
                table.remove(usedBarsList, i); break
            end
        end
        ReleaseBar(bar); ReLayout()
    end
end

local areEventsEnabled = false

local function EnableEnvEvents()
    if areEventsEnabled then return end
    areEventsEnabled = true

    ExwindTools:RegisterEvent("NAME_PLATE_UNIT_ADDED", EXWIND_MODULE_KEY, OnEvent)
    ExwindTools:RegisterEvent("NAME_PLATE_UNIT_REMOVED", EXWIND_MODULE_KEY, OnUnitRemoved)

    local events = {
        "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_STOP",
        "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_STOP",
        "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
    }
    for _, e in ipairs(events) do
        ExwindTools:RegisterEvent(e, EXWIND_MODULE_KEY, OnEvent)
    end

    if ExwindTools.DebugMode then
        print("|cff00ff00[ExM+.MythicCast]|r " .. L["进入5人副本，施法监控已启用。"])
    end
end

local function DisableEnvEvents()
    if not areEventsEnabled then return end
    areEventsEnabled = false

    ExwindTools:UnregisterEvent("NAME_PLATE_UNIT_ADDED", EXWIND_MODULE_KEY)
    ExwindTools:UnregisterEvent("NAME_PLATE_UNIT_REMOVED", EXWIND_MODULE_KEY)

    local events = {
        "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_STOP",
        "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_CHANNEL_STOP",
        "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE"
    }
    for _, e in ipairs(events) do
        ExwindTools:UnregisterEvent(e, EXWIND_MODULE_KEY)
    end

    -- 彻底清理
    for unit, bar in pairs(activeBars) do
        ReleaseBar(bar)
    end
    activeBars = {}
    usedBarsList = {}
    combatRecheckGeneration = combatRecheckGeneration + 1
    pendingCombatRechecks = {}
    ReLayout()
end

local function CheckEnvStatus()
    -- 核心优化: 仅在 5人副本 (party) 且模块开启时注册事件
    -- 注: State.InstanceType 由 ExwindState 维护
    local isParty = (ExwindTools.State.InstanceType == "party")

    if isParty and EX_DB.enabled then
        EnableEnvEvents()
    else
        DisableEnvEvents()
    end
end

-- 监听 InstanceType 变化 (进入/离开副本)
ExwindTools:WatchState("InstanceType", EXWIND_MODULE_KEY, function(newType)
    CheckEnvStatus()
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end
    if isEditModeActive and (info.key == "preview" or info.key == "locked") then
        return
    end
    if info.key == "preview" then
        TogglePreview(EX_DB.preview)
    elseif info.key == "enabled" then
        if EX_DB.enabled then
            CreateAnchor(); RefreshAll()
        else
            if anchorFrame then anchorFrame:Hide() end
        end
        CheckEnvStatus() -- 开关变化时也要检查
    else
        RefreshAll()
    end
end)

ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if info.key == "btn_reset_pos" then
        EX_DB.posX, EX_DB.posY = 0, 100
        EX_DB.attachToCustom = false
        EX_DB.customAttachTarget = ""
        if anchorFrame then
            anchorFrame:ClearAllPoints(); anchorFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
        end
        RefreshAll()
    elseif info.key == "btn_pick_frame" then
        StartFramePicker()
    end
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    -- [v4.3.18 Fix] 解决持久化问题：强制在加载时关闭预览模式
    -- 因为框架会在脚本加载后同步 DB 值，所以必须在进入世界事件中强制将其重置为 false
    EX_DB.preview = false
    EX_DB.locked = true

    C_Timer.After(1, function()
        CreateAnchor(); TogglePreview(false)
        RefreshAll()
        CheckEnvStatus() -- 初始检查
    end)
end)

-- =============================================================
-- 全局编辑模式支持
-- =============================================================
-- [v3.1 新增] 注册全局编辑模式回调
local function ApplyEditModePresentation()
    if isEditModeActive then
        EX_DB.locked = not isEditModeVisible
        EX_DB.preview = isEditModeVisible
        CreateAnchor()
        TogglePreview(isEditModeVisible)
        RefreshAll()
        if anchorFrame and isEditModeVisible then
            anchorFrame.bg:Hide()
            anchorFrame.label:Hide()
        end
        RefreshEditOverlay()
    else
        if editModeRestore then
            EX_DB.locked = editModeRestore.locked
            EX_DB.preview = editModeRestore.preview
            editModeRestore = nil
        end
        TogglePreview(EX_DB.preview)
        RefreshAll()
        RefreshEditOverlay()
    end
end

ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
        if not editModeRestore then
            editModeRestore = {
                locked = EX_DB.locked,
                preview = EX_DB.preview,
            }
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

ExwindTools:ReportReady(EXWIND_MODULE_KEY)
