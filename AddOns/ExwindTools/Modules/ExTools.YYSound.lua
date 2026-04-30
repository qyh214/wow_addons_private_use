-- [[ 嗜血音效 (YY Sound Effect) ]]
-- { Key = "ExTools.YYSound", Name = "嗜血音效", Desc = "监控嗜血衰弱类光环并播放自定义音效与倒数图标。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExTools.YYSound"
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

local LSM = LibStub("LibSharedMedia-3.0")

-- 1. 默认设置
local EX_DEFAULTS = {
    borderColorA = 1,
    borderColorB = 0,
    borderColorG = 0,
    borderColorR = 0,
    borderPadding = 1,
    borderSize = 1,
    borderTexture = "1 Pixel",
    customSounds = { "", "", "", "", "", "" },
    enabled = true,
    font_timer = {
        a = 1,
        b = 0,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowColor = { 0, 0, 0, 1 },
        shadowX = 1,
        shadowY = -1,
        size = 48,
        x = 0,
        y = 0,
    },
    hideIcon = false,
    iconSize = 59,
    iconTexture = "132313",
    posX = -390,
    posY = 14,
    randomSound = false,
    reverseCD = true,
    showBorder = true,
    sound = "None",
    soundChannel = "Master",
    spellID = "",
    unlockDrag = false,
    useCustomSound = false,
    useNativeCD = false,
}

-- 固定数值
local CD_DURATION = 40     -- 倒计时显示时长

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EX_DEFAULTS)

local function NormalizeCustomSounds()
    local migrated = {}

    if type(EX_DB.customSounds) == "table" then
        local maxIndex = math.max(#EX_DB.customSounds, 6)
        for i = 1, maxIndex do
            local value = EX_DB.customSounds[i]
            migrated[i] = type(value) == "string" and value or tostring(value or "")
        end
    end

    for i = 1, 6 do
        local legacy = EX_DB["customSound" .. i]
        if type(legacy) == "string" and legacy ~= "" then
            migrated[i] = legacy
        end
        EX_DB["customSound" .. i] = nil
    end

    for i = 1, 6 do
        if migrated[i] == nil then
            migrated[i] = ""
        end
    end

    EX_DB.customSounds = migrated
end

NormalizeCustomSounds()

local function GetCustomSoundCount()
    if type(EX_DB.customSounds) ~= "table" or #EX_DB.customSounds == 0 then
        return 1
    end
    return #EX_DB.customSounds
end

-- =========================================================
-- [Core] 功能组件: 倒计时图标框架
-- =========================================================
local DeathFrame = CreateFrame("Frame", "ExwindDeathSoundFrame", UIParent)
DeathFrame:SetSize(EX_DB.iconSize, EX_DB.iconSize)
DeathFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
DeathFrame:Hide()


DeathFrame.Bg = DeathFrame:CreateTexture(nil, "BACKGROUND")
DeathFrame.Bg:SetAllPoints()
DeathFrame.Bg:SetColorTexture(0, 0, 0, 0.5)


DeathFrame.Icon = DeathFrame:CreateTexture(nil, "ARTWORK")
DeathFrame.Icon:SetAllPoints()
DeathFrame.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

DeathFrame.BorderFrame = CreateFrame("Frame", nil, DeathFrame, "BackdropTemplate")
DeathFrame.BorderFrame:SetFrameLevel(DeathFrame:GetFrameLevel() + 5)


DeathFrame.TimerText = DeathFrame:CreateFontString(nil, "OVERLAY")
local fontPath = ExwindTools.MAIN_FONT
DeathFrame.TimerText:SetFont(fontPath, 48, "OUTLINE")
DeathFrame.TimerText:SetPoint("CENTER", DeathFrame, "CENTER", 0, 0)
DeathFrame.TimerText:SetTextColor(1, 1, 0)


DeathFrame.CD = CreateFrame("Cooldown", nil, DeathFrame, "CooldownFrameTemplate")
DeathFrame.CD:SetAllPoints()
DeathFrame.CD:SetDrawEdge(false)
DeathFrame.CD:SetHideCountdownNumbers(true)

local function UpdateVisuals()
    DeathFrame:SetSize(EX_DB.iconSize, EX_DB.iconSize)
    DeathFrame:ClearAllPoints()
    DeathFrame:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
    local icon = EX_DB.iconTexture or 132313
    -- [新增] 法术 ID 优先级逻辑
    if EX_DB.spellID and EX_DB.spellID ~= "" then
        local spellIcon = C_Spell.GetSpellTexture(EX_DB.spellID)
        if spellIcon then
            icon = spellIcon
        end
    end
    DeathFrame.Icon:SetTexture(icon)

    local edgeTex = EX_DB.showBorder and EX_DB.borderTexture and EX_DB.borderTexture ~= "None" and
        LSM:Fetch("border", EX_DB.borderTexture) or nil
    if edgeTex then
        local pad = EX_DB.borderPadding or 0
        local edgeSize = EX_DB.borderSize or 1
        DeathFrame.BorderFrame:ClearAllPoints()
        DeathFrame.BorderFrame:SetPoint("TOPLEFT", DeathFrame, "TOPLEFT", -pad, pad)
        DeathFrame.BorderFrame:SetPoint("BOTTOMRIGHT", DeathFrame, "BOTTOMRIGHT", pad, -pad)
        DeathFrame.BorderFrame:SetBackdrop({
            edgeFile = edgeTex,
            edgeSize = edgeSize,
        })
        DeathFrame.BorderFrame:SetBackdropBorderColor(
            EX_DB.borderColorR or 0,
            EX_DB.borderColorG or 0,
            EX_DB.borderColorB or 0,
            EX_DB.borderColorA or 1
        )
        DeathFrame.BorderFrame:Show()
    else
        DeathFrame.BorderFrame:Hide()
    end

    if ExwindTools.DB_Static and EX_DB.font_timer then
        ExwindTools.DB_Static:ApplyFont(DeathFrame.TimerText, EX_DB.font_timer)
    end
    DeathFrame.TimerText:ClearAllPoints()
    DeathFrame.TimerText:SetPoint(
        "CENTER",
        DeathFrame,
        "CENTER",
        (EX_DB.font_timer and EX_DB.font_timer.x) or 0,
        (EX_DB.font_timer and EX_DB.font_timer.y) or 0
    )

    -- 根据设置决定是否显示暴雪原生倒数
    if DeathFrame.CD.SetHideCountdownNumbers then
        DeathFrame.CD:SetHideCountdownNumbers(not EX_DB.useNativeCD)
    end
    -- 根据设置决定是否显示自定义字体
    if EX_DB.useNativeCD then
        DeathFrame.TimerText:Hide()
    else
        DeathFrame.TimerText:Show()
    end

    -- 倒数反转（亮暗互换）
    if DeathFrame.CD.SetReverse then
        DeathFrame.CD:SetReverse(EX_DB.reverseCD)
    end
end

-- 解锁拖动功能
local function SetDragMode(enabled)
    if enabled then
        -- 显示图标并启用拖动
        UpdateVisuals()
        DeathFrame:Show()
        DeathFrame:EnableMouse(true)
        DeathFrame:SetMovable(true)
        DeathFrame:RegisterForDrag("LeftButton")
        DeathFrame:SetScript("OnMouseDown", function(_, button)
            if button == "RightButton" and ExwindTools.GlobalEditMode then
                -- [v4.7.2 Fix] 为 YY Sound 补全右键设置跳转路由
                ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
            end
        end)
        DeathFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
        DeathFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            -- 计算框架中心相对于屏幕中心的偏移量
            local frameCenter = self:GetCenter()
            local screenCenter = UIParent:GetCenter()
            if frameCenter and screenCenter then
                EX_DB.posX = math.floor(frameCenter - screenCenter + 0.5)
                local _, frameCenterY = self:GetCenter()
                local _, screenCenterY = UIParent:GetCenter()
                EX_DB.posY = math.floor(frameCenterY - screenCenterY + 0.5)
            end
            -- 重新锚定到 CENTER 以保持一致性
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", EX_DB.posX, EX_DB.posY)
            -- 触发 UI 刷新，让滑块同步更新
            ExwindTools:UpdateState(EXWIND_MODULE_KEY .. ".DatabaseChanged", { key = "posX", ts = GetTime() })
            if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() then
                ExwindTools.UI:RefreshContent()
            end
        end)
    else
        -- 隐藏图标并禁用拖动
        DeathFrame:Hide()
        DeathFrame:EnableMouse(false)
        DeathFrame:SetMovable(false)
        DeathFrame:SetScript("OnMouseDown", nil)
        DeathFrame:SetScript("OnDragStart", nil)
        DeathFrame:SetScript("OnDragStop", nil)
    end
end

local activeTimer
local lastSoundHandle
local isEditModeActive = false
local isEditModeVisible = true

local function RefreshEditOverlay()
    if isEditModeActive and isEditModeVisible then
        ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY, DeathFrame)
    else
        ExwindTools:HideExwindToolsEditOverlay(DeathFrame)
    end
end

local function ApplyEditModePresentation()
    if isEditModeActive then
        SetDragMode(isEditModeVisible)
    else
        SetDragMode(EX_DB.unlockDrag)
    end
    RefreshEditOverlay()
end

local function StopEffect()
    if lastSoundHandle then
        StopSound(lastSoundHandle)
        lastSoundHandle = nil
    end
    if activeTimer then
        activeTimer:Cancel()
        activeTimer = nil
    end
    DeathFrame:Hide()
end

local function PlayEffect()
    if not EX_DB.enabled then return end

    -- 停止上一个，防止重叠
    StopEffect()

    -- 1. 播放音效（根据设置决定音效来源）
    local soundToPlay = nil

    if EX_DB.useCustomSound then
        -- 使用自定义音效
        if EX_DB.randomSound then
            -- 随机播放：从所有不为空的自定义音效中随机选择
            local validSounds = {}
            for _, s in ipairs(EX_DB.customSounds or {}) do
                if s and s ~= "" then
                    table.insert(validSounds, s)
                end
            end
            if #validSounds > 0 then
                soundToPlay = validSounds[math.random(1, #validSounds)]
            end
        else
            -- 固定使用第一条
            local s = EX_DB.customSounds and EX_DB.customSounds[1]
            if s and s ~= "" then
                soundToPlay = s
            end
        end
    else
        -- 使用 LSM 音效
        if EX_DB.sound and EX_DB.sound ~= "None" then
            soundToPlay = LSM:Fetch("sound", EX_DB.sound)
        end
    end

    if soundToPlay then
        local _, handle = PlaySoundFile(soundToPlay, EX_DB.soundChannel or "Master")
        lastSoundHandle = handle
    end

    -- 2. 激活 UI 反馈 (如果未勾选隐藏图标)
    -- DEBUFF 只用于确认嗜血触发；图标始终显示嗜血本体 40 秒。
    local now = GetTime()
    local duration = CD_DURATION

    if not EX_DB.hideIcon then
        UpdateVisuals()
        DeathFrame:Show()

        -- 开启转圈（嗜血本体固定 40 秒）
        DeathFrame.CD:SetCooldown(now, duration)
    end

    if EX_DB.useNativeCD then
        -- 使用原生模式
        if activeTimer then
            activeTimer:Cancel(); activeTimer = nil
        end
        -- [Fix] 原生 CD 模式下，CooldownFrame 扫光结束后不会自动隐藏父框架，
        -- 必须手动创建一个延迟隐藏计时器；同时挂到 activeTimer 以便 StopEffect() 可取消。
        activeTimer = C_Timer.After(duration, function()
            activeTimer = nil
            if not EX_DB.unlockDrag then
                DeathFrame:Hide()
            end
        end)
        return
    end

    -- 使用自定义模式
    if activeTimer then
        activeTimer:Cancel(); activeTimer = nil
    end

    local timeLeft = duration
    local lastDisplayNum = math.ceil(timeLeft)
    DeathFrame.TimerText:SetText(lastDisplayNum)

    activeTimer = C_Timer.NewTicker(0.1, function()
        timeLeft = timeLeft - 0.1
        if timeLeft <= 0 then
            DeathFrame:Hide()
            if activeTimer then activeTimer:Cancel() end
            activeTimer = nil
        else
            -- 仅在秒数发生变化时更新文字（无动画）
            local currentDisplayNum = math.ceil(timeLeft)
            if currentDisplayNum ~= lastDisplayNum then
                lastDisplayNum = currentDisplayNum
                DeathFrame.TimerText:SetText(currentDisplayNum)
            end
        end
    end)
end


-- =========================================================
-- [Core] 光环监控
-- =========================================================
local isReady = false
C_Timer.After(5, function() isReady = true end) -- 登录 5 秒后才允许触发

-- =========================================================
-- [Aura] 衰弱 DEBUFF 触发
-- 通过检查 DEBUFF 是否刚加上来确认嗜血真实触发。
-- =========================================================
local EXHAUSTION_IDS = { 57723, 57724, 80354, 95809, 160455, 207400, 264689, 390435 }
local EXHAUSTION_DURATION = 600 -- 衰弱持续 10 分钟
local FRESH_WINDOW = 5          -- 容差 5 秒（网络/帧延迟保险）
local lastExhaustionExpiration = 0

-- 检查玩家是否刚获得衰弱DEBUFF（剩余时间接近满值）
-- 返回 true 及 expirationTime（仅用于确认新触发和去重，不用于 UI 倒计时）
local function CheckExhaustionFresh()
    local UnitAuras = _G.C_UnitAuras
    if not UnitAuras or type(UnitAuras.GetPlayerAuraBySpellID) ~= "function" then
        return false, nil
    end

    local now = _G.GetTime()
    for _, id in ipairs(EXHAUSTION_IDS) do
        local aura = UnitAuras.GetPlayerAuraBySpellID(id)
        if aura and aura.expirationTime then
            local remaining = aura.expirationTime - now
            if remaining >= (EXHAUSTION_DURATION - FRESH_WINDOW) then
                return true, aura.expirationTime
            end
        end
    end
    return false, nil
end

local function CheckBloodlustDebuffTrigger()
    if not isReady or not EX_DB.enabled then return end

    local fresh, expirationTime = CheckExhaustionFresh()
    if not fresh or not expirationTime then return end
    if expirationTime == lastExhaustionExpiration then return end

    lastExhaustionExpiration = expirationTime
    PlayEffect()
end

ExwindTools:RegisterEvent("UNIT_AURA", EXWIND_MODULE_KEY, function(_, unit)
    if unit ~= "player" then return end

    -- UNIT_AURA 触发时光环数据有时同帧还没稳定，延迟一帧检查。
    C_Timer.After(0.05, CheckBloodlustDebuffTrigger)
end)

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function()
    lastExhaustionExpiration = 0
end)


-- =========================================================
-- [Grid] 布局配置 (标准化静态表)
-- =========================================================
local function EX_RegisterLayout()
    local soundCount = GetCustomSoundCount()
    local soundRowsStartY = 63
    local layout = {
        { key = "header", type = "header", x = 2, y = 1, w = 53, h = 3, label = L["嗜血音效 (YY Sound)"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 53, h = 2, label = L["获得嗜血BUFF时 播放音效和倒数 该功能测试中"] },
        { key = "sub1", type = "subheader", x = 2, y = 6, w = 53, h = 2, label = L["图标设置"], labelSize = 20 },
        { key = "enabled", type = "checkbox", x = 2, y = 10, w = 6, h = 2, label = L["启用"] },
        { key = "hideIcon", type = "checkbox", x = 10, y = 10, w = 8, h = 2, label = L["隐藏图标"] },
        { key = "unlockDrag", type = "checkbox", x = 19, y = 10, w = 10, h = 2, label = L["解锁拖动"] },
        { key = "useNativeCD", type = "checkbox", x = 32, y = 10, w = 18, h = 2, label = L["使用暴雪原生倒数(较省性能)"] },

        { key = "spellID", type = "input", x = 2, y = 14, w = 15, h = 2, label = L["法术 ID (优先)"], labelPos = "top" },
        { key = "iconTexture", type = "input", x = 19, y = 14, w = 17, h = 2, label = L["图标路径/ID |cffff2628优先使用法术ID(如有)|r"], labelPos = "top" },
        { key = "iconSize", type = "slider", x = 37, y = 14, w = 18, h = 2, label = L["尺寸"], min = 15, max = 300 },
        { key = "description_5432", type = "description", x = 19, y = 16, w = 24, h = 1, label = L["|cff97a393示例: Interface\\AddOns\\ExwindTools\\Textures\\EJ-UI\\EX1.PNG|r"], labelSize = 12 },

        { key = "posX", type = "slider", x = 2, y = 19, w = 15, h = 2, label = L["位置 X"], min = -800, max = 800 },
        { key = "posY", type = "slider", x = 19, y = 19, w = 17, h = 2, label = L["位置 Y"], min = -500, max = 500 },
        { key = "reverseCD", type = "checkbox", x = 37, y = 19, w = 10, h = 2, label = L["倒数反转"] },
        { key = "divider_2497", type = "divider", x = 2, y = 22, w = 53, h = 1, label = L["新组件"] },
        { key = "showBorder", type = "checkbox", x = 2, y = 25, w = 15, h = 2, label = L["显示边框"] },
        { key = "borderTexture", type = "lsm_border", x = 19, y = 25, w = 17, h = 2, label = L["边框材质"] },
        { key = "borderColor", type = "color", x = 37, y = 25, w = 18, h = 2, label = L["边框颜色"] },
        { key = "borderSize", type = "slider", x = 19, y = 29, w = 17, h = 2, label = L["宽度"], min = 1, max = 16, step = 1 },
        { key = "borderPadding", type = "slider", x = 37, y = 29, w = 18, h = 2, label = L["间距"], min = 0, max = 16, step = 1 },
        { key = "font_timer", type = "fontgroup", x = 2, y = 33, w = 53, h = 17, label = L["中间时间文字"], labelSize = 20 },

        { key = "divider_1504", type = "divider", x = 2, y = 51, w = 53, h = 1, label = "" },
        { key = "sub2", type = "subheader", x = 2, y = 52, w = 53, h = 2, label = L["音效设置"], labelSize = 20 },
        { key = "divider_2880", type = "divider", x = 2, y = 54, w = 53, h = 2, label = "" },
        { key = "sound", type = "lsm_sound", x = 9, y = 56, w = 25, h = 2, label = "|cff2bff6a" .. L["内置音效"] .. "|r", labelPos = "left", labelSize = 20 },
        { key = "soundChannel", type = "dropdown", x = 40, y = 56, w = 12, h = 2, label = L["输出频道"], items = { { L["主音量"], "Master" }, { L["效果"], "SFX" }, { L["环境"], "Ambience" }, { L["音乐"], "Music" }, { L["对话"], "Dialog" } }, labelPos = "left" },
        { key = "useCustomSound", type = "checkbox", x = 3, y = 59, w = 2, h = 2, label = L["使用自定义路径 (下方可持续新增)"] },
        { key = "randomSound", type = "checkbox", x = 30, y = 59, w = 2, h = 2, label = L["随机播放多条"] },
    }

    for i = 1, soundCount do
        layout[#layout + 1] = {
            key = "customSound_" .. i,
            type = "input",
            x = 10,
            y = soundRowsStartY + ((i - 1) * 2),
            w = 45,
            h = 2,
            label = string.format("%s(%d)", L["音效"], i),
            labelPos = "left",
            parentKey = "customSounds",
            subKey = tostring(i),
        }
    end

    local addButtonY = soundRowsStartY + (soundCount * 2)
    layout[#layout + 1] = { key = "btn_add_sound", type = "button", x = 10, y = addButtonY, w = 14, h = 3, label = L["新增音效"] }

    local testSectionY = addButtonY + 4
    layout[#layout + 1] = { key = "sub3", type = "subheader", x = 2, y = testSectionY, w = 53, h = 1, label = L["测试操作"], labelSize = 20 }
    layout[#layout + 1] = { key = "divider_7795", type = "divider", x = 2, y = testSectionY + 1, w = 53, h = 1, label = "" }
    layout[#layout + 1] = { key = "btn_test", type = "button", x = 2, y = testSectionY + 2, w = 13, h = 3, label = L["测试效果"] }
    layout[#layout + 1] = { key = "btn_stop", type = "button", x = 16, y = testSectionY + 2, w = 13, h = 3, label = L["停止测试"] }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()
UpdateVisuals()

-- =========================================================
-- [Logic] 响应网格事件
-- =========================================================

-- 1. 处理数据库变动
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(data)
    -- 解锁拖动状态变化
    if data and data.key == "unlockDrag" then
        ApplyEditModePresentation()
    end
    UpdateVisuals()
end)

-- 2. 处理按钮点击
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if info and info.key == "btn_test" then
        PlayEffect()
    elseif info and info.key == "btn_stop" then
        StopEffect()
    elseif info and info.key == "btn_add_sound" then
        EX_DB.customSounds[#EX_DB.customSounds + 1] = ""
        EX_RegisterLayout()
        if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() then
            if ExwindTools.UI.RefreshContentKeepModuleScroll then
                ExwindTools.UI:RefreshContentKeepModuleScroll()
            else
                ExwindTools.UI:RefreshContent()
            end
        end
    end
end)

-- =============================================================
-- 全局编辑模式支持
-- =============================================================
-- [v3.1 新增] 注册全局编辑模式回调
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

-- 注册 HUD (集权化管理)
ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, DeathFrame)

-- 报告模块就绪
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
