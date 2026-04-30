-- =============================================================
-- [[ 施法序列 (Cast Sequence) ]]
-- { Key = "ExTools.CastSequence", Name = "施法序列", Desc = "实时显示你的施法序列，支持读条/引导/瞬发/打断等状态可视化。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
local EXDB = _G.EXDB
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExTools.CastSequence"

-- =============================================================
-- 第一部分：Grid 布局定义 (必须最先运行！)
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        -- 标题
        { key = "header", type = "header", x = 2, y = 1, w = 53, h = 3, label = L["施法序列"], labelSize = 25 },
        { key = "desc", type = "description", x = 2, y = 4, w = 53, h = 2, label = L["实时显示你的施法序列。支持读条/引导/瞬发/打断状态可视化。"] },

        -- 通用设置
        { key = "sub_general", type = "subheader", x = 2, y = 6, w = 53, h = 2, label = L["通用设置"], labelSize = 20 },
        { key = "divider_1", type = "divider", x = 2, y = 8, w = 53, h = 1 },
        { key = "enabled", type = "checkbox", x = 2, y = 10, w = 10, h = 2, label = L["启用"] },
        { key = "locked", type = "checkbox", x = 14, y = 10, w = 10, h = 2, label = L["锁定位置"], desc = L["启用全局编辑模式来移动位置"] },
        { key = "showTooltip", type = "checkbox", x = 26, y = 10, w = 14, h = 2, label = L["悬停显示鼠标提示"] },

        -- 技能图标设置
        { key = "sub_square", type = "subheader", x = 2, y = 13, w = 53, h = 2, label = L["技能图标设置"], labelSize = 20 },
        { key = "divider_2", type = "divider", x = 2, y = 15, w = 53, h = 1 },
        { key = "squareSize", type = "slider", x = 2, y = 17, w = 16, h = 2, label = L["图标大小"], min = 16, max = 64, step = 1, labelPos = "top" },
        { key = "squareAmount", type = "slider", x = 20, y = 17, w = 16, h = 2, label = L["图标数量"], min = 3, max = 20, step = 1, labelPos = "top" },
        { key = "frameScale", type = "slider", x = 38, y = 17, w = 16, h = 2, label = L["缩放"], min = 0.5, max = 2.0, step = 0.1, labelPos = "top" },
        {
            key = "squareGrowDirection",
            type = "dropdown",
            x = 2,
            y = 21,
            w = 16,
            h = 2,
            label = L["增长方向"],
            labelPos = "top",
            items = {
                { L["向右"], "right" },
                { L["向左"], "left" },
            }
        },
        {
            key = "frameStrata",
            type = "dropdown", --TEST
            x = 20,
            y = 21,
            w = 16,
            h = 2,
            label = L["图标层级"],
            labelPos = "top",
            items = {
                { "BACKGROUND", "BACKGROUND" },
                { "LOW",        "LOW" },
                { "MEDIUM",     "MEDIUM" },
                { "HIGH",       "HIGH" },
                { "DIALOG",     "DIALOG" },
            }
        },

        -- 忽略法术
        { key = "sub_ignore", type = "subheader", x = 2, y = 25, w = 53, h = 2, label = L["忽略法术"], labelSize = 20 },
        { key = "divider_3", type = "divider", x = 2, y = 27, w = 53, h = 1 },
        { key = "ignoreSpellId", type = "input", x = 2, y = 29, w = 18, h = 2, label = L["法术ID"], labelPos = "top" },
        { key = "btn_addIgnore", type = "button", x = 22, y = 29, w = 10, h = 3, label = L["添加/移除"] },
        { key = "btn_showIgnore", type = "button", x = 34, y = 29, w = 10, h = 3, label = L["显示列表"] },
        { key = "btn_clearIgnore", type = "button", x = 46, y = 29, w = 10, h = 3, label = L["清空列表"] },
        { key = "desc_ignore", type = "description", x = 2, y = 32, w = 53, h = 1, label = L["输入法术ID后点击添加/移除按钮。已忽略的法术将不会显示在施法序列中。"] },
    }

    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout() -- 立即执行注册

-- =============================================================
-- 第二部分：载入检查与环境过滤
-- =============================================================
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 第三部分：依赖与数据初始化
-- =============================================================

-- 默认配置
local EXWIND_DEFAULTS = {
    enabled = false,
    locked = true,   -- 默认锁定，通过编辑模式解锁
    preview = false, -- 编辑模式预览状态

    -- 显示设置
    frameScale = 1.0,
    frameStrata = "LOW",

    -- 位置
    point = "RIGHT",
    relativePoint = "RIGHT",
    xOffset = -6.9,
    yOffset = -201.3,

    -- 图标设置
    squareSize = 36,
    squareAmount = 8,
    squareGrowDirection = "right",
    showTooltip = true,

    -- 忽略法术
    ignoredSpellIds = {},
    ignoreSpellId = "", -- 输入框临时值
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)

-- =============================================================
-- 第四部分：工具函数
-- =============================================================

-- 法术信息获取 (适配 12.0 C_Spell API)
local function GetSpellInfo(spellId)
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if spellInfo then
        return spellInfo.name, nil, spellInfo.iconID
    end
end

-- 12.0 UNIT_SPELLCAST_SENT 的 target 参数变为秘密字符串 (secret string)


local function CS_Print(msg)
    print("|cffff7700[" .. L["施法序列"] .. "]|r " .. tostring(msg))
end

-- =============================================================
-- 第五部分：施法追踪 (CastTracker)
-- =============================================================

-- 施法追踪表
local CastsTable = {}

-- 调试模式
local debugMode = false
local debugSpellId = nil

local function DebugPrint(spellId, event, msg)
    if not debugMode then return end
    if debugSpellId and debugSpellId ~= spellId then return end
    local spellName = GetSpellInfo(spellId) or "Unknown"
    print(string.format("|cff00ff00[CS Debug]|r [%s] %s - %s", event, spellName, msg))
end

-- 内置忽略法术
local ignoredSpells = {
    [49821] = true,  -- Mind Sear ticks
    [121557] = true, -- Angelic Feather walk-on
}

-- 法术颜色定义
local COLOR_HARMFUL = { 0.9, 0.5, 0.5, 0.4 }
local COLOR_HELPFUL = { 0.1, 0.9, 0.1, 0.4 }
local COLOR_DEFAULT = { 0.5, 0.5, 0.5, 0.4 }

-- 上一个法术追踪
local lastSpell, lastCastId, lastChannelId, isChanneling, lastSpellId
local channelSpells = {}
local lastChannelSpell = ""

-- 重复施法防抖
local recentCasts = {}
local DUPLICATE_THRESHOLD = 0.5

-- 定时清理旧数据 (60秒周期)
C_Timer.NewTicker(60, function()
    local now = GetTime()
    for castGUID, info in pairs(CastsTable) do
        if info.CastStart and (now - info.CastStart) > 120 then
            CastsTable[castGUID] = nil
        end
    end
    for spellId, timestamp in pairs(recentCasts) do
        if (now - timestamp) > 10 then
            recentCasts[spellId] = nil
        end
    end
    local channelCount = 0
    for _ in pairs(channelSpells) do channelCount = channelCount + 1 end
    if channelCount > 20 then
        channelSpells = {}
    end
end)

-- =============================================================
-- 第六部分：显示系统 (Display)
-- =============================================================

-- 显示数据表
local castContent = {}
local squares = {}
local totalSquares = 0
local isEditModeActive = false
local isEditModeVisible = true
local editModeRestore = nil
local editHandleFrame = nil
local mainFrame, titleBar

local function RefreshEditOverlay()
    if not mainFrame or not editHandleFrame then return end

    if isEditModeActive and isEditModeVisible then
        editHandleFrame:ClearAllPoints()
        editHandleFrame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, 0)
        editHandleFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)
        editHandleFrame:Show()
        ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY, editHandleFrame, { ownerFrame = mainFrame })
    else
        ExwindTools:HideExwindToolsEditOverlay(editHandleFrame)
        editHandleFrame:Hide()
    end
end

-- 获取法术信息 (颜色/图标)
local function GetSpellDisplayInfo(spellId)
    local _, _, icon = GetSpellInfo(spellId)
    local backgroundcolor = COLOR_DEFAULT

    local isHarmful = C_Spell.IsSpellHarmful(spellId)
    local isHelpful = C_Spell.IsSpellHelpful(spellId)

    if isHarmful then
        backgroundcolor = COLOR_HARMFUL
    elseif isHelpful then
        backgroundcolor = COLOR_HELPFUL
    end

    local bordercolor = { 0, 0, 0, 0 }
    return icon, backgroundcolor, bordercolor
end

-- [12.0 适配] ParseTargetName 已移除 (secret string taint)

-- ===================== 前置声明 =====================
local UpdateSquares, UpdateSquare, Refresh, RefreshAllSquareStyle, ReorderSquares
local CreateMainFrame, SavePosition, RestorePosition, UpdateLockState
local CreateSquareBox, SetSquareStyle, AutoSizeFrame
local UpdateCooldownFrame

-- ===================== 冷却帧更新 =====================
UpdateCooldownFrame = function(square, inCooldown, startTime, endTime, castInfo)
    if castInfo and (castInfo.Interrupted or castInfo.ChannelStopped) and castInfo.InterruptedPct then
        local completedPct = castInfo.InterruptedPct
        if completedPct < 0 then completedPct = 0 end
        if completedPct > 1 then completedPct = 1 end
        CooldownFrame_SetDisplayAsPercentage(square.cooldown, completedPct)
        square.cooldown:Show()
        return
    end

    if endTime and endTime < GetTime() then
        CooldownFrame_Clear(square.cooldown)
        square.cooldown:Hide()
        return
    end

    if inCooldown then
        local duration = endTime - startTime
        CooldownFrame_Set(square.cooldown, startTime, duration, duration > 0, true)
        square.cooldown:Show()
    else
        CooldownFrame_Clear(square.cooldown)
        square.cooldown:Hide()
    end
end

-- ===================== 方块样式 =====================
SetSquareStyle = function(square, index)
    square:SetSize(EX_DB.squareSize, EX_DB.squareSize)
end

-- ===================== 方块排序 =====================
ReorderSquares = function()
    local direction = EX_DB.squareGrowDirection
    local spacing = 2

    -- [v4.7.6 Fix] 核心修复：绝对禁止边距动态化。边距必须恒定，坐标才不会跳。
    local padding = 2

    for index = 1, #squares do
        local thisSquare = squares[index]
        thisSquare:ClearAllPoints()
        if direction == "right" then
            if index == 1 then
                thisSquare:SetPoint("topleft", mainFrame, "topleft", padding, -padding)
            else
                thisSquare:SetPoint("topleft", squares[index - 1], "topright", spacing, 0)
            end
        else
            if index == 1 then
                thisSquare:SetPoint("topright", mainFrame, "topright", -padding, -padding)
            else
                thisSquare:SetPoint("topright", squares[index - 1], "topleft", -spacing, 0)
            end
        end
    end
end

-- ===================== 创建方块 =====================
CreateSquareBox = function()
    local index = #squares + 1

    local square = CreateFrame("Frame", "CastSequenceSquare" .. index, mainFrame, "BackdropTemplate")
    square:SetBackdrop({
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        edgeFile = [[Interface\Buttons\WHITE8X8]],
        edgeSize = 1,
        tile = true,
        tileSize = 16,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    square:SetBackdropBorderColor(0, 0, 0, 0)
    square.squareIndex = index

    square.texture = square:CreateTexture(nil, "ARTWORK")
    square.texture:SetAllPoints()

    square.interruptedTexture = square:CreateTexture(nil, "OVERLAY")
    square.interruptedTexture:SetColorTexture(1, 0, 0, 0.4)
    square.interruptedTexture:SetAllPoints()
    square.interruptedTexture:Hide()

    local cooldown = CreateFrame("Cooldown", "$parentCooldown", square, "CooldownFrameTemplate, BackdropTemplate")
    cooldown:SetAllPoints()
    cooldown:EnableMouse(false)
    cooldown:SetHideCountdownNumbers(true)
    square.cooldown = cooldown

    -- 鼠标悬停提示
    square:EnableMouse(true)
    -- [v4.7.6 Fix] 关键：点击转发。在编辑模式下，把点击权交给父框架 (mainFrame)
    square:SetScript("OnMouseDown", function(_, button)
        if not EX_DB.locked then
            mainFrame:GetScript("OnMouseDown")(mainFrame, button)
        end
    end)
    square:SetScript("OnMouseUp", function()
        if not EX_DB.locked then
            mainFrame:GetScript("OnMouseUp")(mainFrame)
        end
    end)
    square:SetScript("OnEnter", function(self)
        if not EX_DB.showTooltip then return end
        local data = castContent[self.squareIndex]
        if data then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            if data.spellId then
                local success = pcall(function()
                    GameTooltip:SetSpellByID(data.spellId)
                end)
                if success then
                    GameTooltip:AddLine(L["法术ID: "] .. data.spellId, 0.5, 0.5, 0.5)
                else
                    GameTooltip:AddLine(data.spellName or L["未知法术"], 1, 1, 1)
                    GameTooltip:AddLine(L["法术ID: "] .. data.spellId, 0.5, 0.5, 0.5)
                end
            else
                GameTooltip:AddLine(data.spellName or L["未知法术"], 1, 1, 1)
            end
            GameTooltip:Show()
        end
    end)
    square:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    squares[#squares + 1] = square
    square.in_use = 1
    square:Hide()

    SetSquareStyle(square, index)
    ReorderSquares()
end

-- ===================== 更新方块 =====================
UpdateSquare = function(index)
    local square = squares[index]
    if not square then return end

    local data = castContent[index]
    if data then
        square:Show()
        square.texture:SetTexture(data.icon)
        square.texture:SetTexCoord(5 / 64, 59 / 64, 5 / 64, 59 / 64)

        local castinfo = CastsTable[data.castID]
        local percent = castinfo and castinfo.Percent or 0
        if percent > 100 then percent = 100 end

        local startTime = data.startTime
        local endTime = data.endTime
        UpdateCooldownFrame(square, true, startTime, endTime, castinfo)

        -- 仅对非引导法术的打断显示红色遮罩
        if castinfo and castinfo.Interrupted and not castinfo.IsChanneled then
            square.interruptedTexture:Show()
        else
            square.interruptedTexture:Hide()
        end

        square.in_use = data.castStart
    else
        square:Hide()
        square.in_use = 1
    end
end

UpdateSquares = function()
    for index = 1, totalSquares do
        UpdateSquare(index)
    end
end

-- ===================== 刷新显示 =====================
Refresh = function()
    if not mainFrame then return end

    local amount = EX_DB.squareAmount or 8
    totalSquares = amount

    -- 自动计算框体大小
    AutoSizeFrame()

    while #squares < amount do
        CreateSquareBox()
    end

    for i = 1, #squares do
        if i <= amount then
            squares[i]:Show()
        else
            squares[i]:Hide()
        end
    end

    UpdateSquares()
end

RefreshAllSquareStyle = function()
    for i, square in ipairs(squares) do
        SetSquareStyle(square, i)
    end
    ReorderSquares()
    AutoSizeFrame()
end

-- ===================== 自动计算框体大小 =====================
AutoSizeFrame = function()
    if not mainFrame then return end
    local squareSize = EX_DB.squareSize or 36
    local amount = EX_DB.squareAmount or 8
    local spacing = 2
    local width = squareSize * amount + spacing * (amount + 1)
    local height = squareSize + spacing * 2

    -- [v4.7.7 Fix] 绝对禁止在 AutoSizeFrame 中修改物理尺寸。
    -- 编辑模式下的扩大感应区由 editBG 实现，以此保持主框体 CENTER 坐标的绝对稳定。
    mainFrame:SetSize(width, height)
end

-- ===================== 预览模式 (编辑模式使用) =====================
local function TogglePreview(enabled)
    EX_DB.preview = enabled
    if enabled then
        -- 备份真实数据
        mainFrame._realCastContent = castContent

        -- 填充假数据 (5个法术展示)
        local previewIcons = {
            { spellId = 116, name = "寒冰箭", icon = 134851 },
            { spellId = 44425, name = "奥术弹幕", icon = 135732 },
            { spellId = 190356, name = "冰冷血脉", icon = 135838 },
            { spellId = 2139, name = "反制", icon = 135856 },
            { spellId = 31661, name = "龙息术", icon = 135812 },
        }

        castContent = {}
        for i = 1, totalSquares do
            local p = previewIcons[(i % #previewIcons) + 1]
            table.insert(castContent, {
                spellId = p.spellId,
                spellName = p.name,
                icon = p.icon,
                castStart = GetTime() - i,
                startTime = GetTime() - i,
                endTime = GetTime() + 10,

            })
        end
    else
        -- 恢复真实数据
        if mainFrame._realCastContent then
            castContent = mainFrame._realCastContent
            mainFrame._realCastContent = nil
        end
    end
    UpdateSquares()
end

local function HideForEditMode()
    if mainFrame and mainFrame._realCastContent then
        castContent = mainFrame._realCastContent
        mainFrame._realCastContent = nil
    end
    EX_DB.preview = false
    UpdateSquares()
    if mainFrame then
        mainFrame:Hide()
        mainFrame:EnableMouse(false)
        if mainFrame.editBG then mainFrame.editBG:Hide() end
        if mainFrame.editLabel then mainFrame.editLabel:Hide() end
        if editHandleFrame then
            ExwindTools:HideExwindToolsEditOverlay(editHandleFrame)
            editHandleFrame:Hide()
        end
    end
end

-- ===================== 位置保存/恢复 =====================
SavePosition = function()
    if not mainFrame then return end

    local point, _, relativePoint, xOfs, yOfs = mainFrame:GetPoint()
    if point and relativePoint then
        EX_DB.point = point
        EX_DB.relativePoint = relativePoint
        EX_DB.xOffset = xOfs or 0
        EX_DB.yOffset = yOfs or 0
    end
end

RestorePosition = function()
    if not mainFrame then return end

    mainFrame:SetFrameStrata(EX_DB.frameStrata)
    mainFrame:SetScale(EX_DB.frameScale)
    AutoSizeFrame()

    mainFrame:ClearAllPoints()
    mainFrame:SetPoint(
        EX_DB.point or "CENTER",
        UIParent,
        EX_DB.relativePoint or "CENTER",
        EX_DB.xOffset or 0,
        EX_DB.yOffset or -100
    )
end

-- ===================== 锁定状态 =====================
UpdateLockState = function()
    if not mainFrame then return end

    mainFrame:EnableMouse(not EX_DB.locked)
    if mainFrame.editBG then mainFrame.editBG:Hide() end
    if mainFrame.editLabel then mainFrame.editLabel:Hide() end

    -- [v4.7.7 Fix] 重要：在编辑模式下，让图标方块不再拦截鼠标
    -- 这样任何点击图标的行为都会由于穿透效应由底层 mainFrame/editBG 接收，确保拖动不手滑
    for _, square in ipairs(squares) do
        square:EnableMouse(EX_DB.locked) -- 锁定=开启提示，非锁定=禁用拦截
    end

    AutoSizeFrame()
    ReorderSquares()
end

-- ===================== 重置位置 =====================
local function ResetPosition()
    EX_DB.point = EXWIND_DEFAULTS.point
    EX_DB.relativePoint = EXWIND_DEFAULTS.relativePoint
    EX_DB.xOffset = EXWIND_DEFAULTS.xOffset
    EX_DB.yOffset = EXWIND_DEFAULTS.yOffset
    RestorePosition()
    CS_Print("位置已重置")
end

-- [v4.0] 移除旧的 CreateTitleBar，改用核心编辑模式
local function RegisterEditMode()
    local function ApplyEditModePresentation()
        if isEditModeActive then
            if isEditModeVisible then
                EX_DB.locked = false
                UpdateLockState()
                TogglePreview(true)
                if mainFrame then
                    mainFrame:Show()
                    if mainFrame.editBG then mainFrame.editBG:Hide() end
                    if mainFrame.editLabel then mainFrame.editLabel:Hide() end
                end
                RefreshEditOverlay()
            else
                EX_DB.locked = true
                UpdateLockState()
                HideForEditMode()
            end
        else
            if editModeRestore then
                EX_DB.locked = editModeRestore.locked
                EX_DB.preview = false
                editModeRestore = nil
            end
            UpdateLockState()
            if EX_DB.preview then
                TogglePreview(true)
                if mainFrame then
                    mainFrame:Show()
                end
            elseif EX_DB.enabled then
                TogglePreview(false)
                if mainFrame then
                    mainFrame:Show()
                end
            else
                HideForEditMode()
            end
            RefreshEditOverlay()
        end
    end

    ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
        EnterEditMode = function()
            if not editModeRestore then
                editModeRestore = {
                    locked = EX_DB.locked,
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
end

-- ===================== 创建主框体 =====================
CreateMainFrame = function()
    local frame = CreateFrame("Frame", "CastSequenceFrame", UIParent, "BackdropTemplate")
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    mainFrame = frame

    -- [v4.7.7] 独立感应层设计 (editBG)：外扩 20px 的隐形/半透层，不改变父框体几何中心
    local editBG = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    editBG:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    editBG:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    editBG:SetBackdrop({
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    editBG:SetBackdropColor(0, 0.7, 0.2, 0.4)
    editBG:SetFrameLevel(frame:GetFrameLevel() - 1) -- 处于底层，不遮挡文字图标
    editBG:Hide()
    frame.editBG = editBG

    editHandleFrame = CreateFrame("Frame", nil, UIParent)
    editHandleFrame:SetFrameStrata("DIALOG")
    editHandleFrame:Hide()

    -- 将文字提示绑定在感应层上或主框体
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(ExwindTools.MAIN_FONT, 12, "OUTLINE")
    label:SetPoint("CENTER")
    label:SetText(L["施法序列"])
    label:SetTextColor(0, 1, 0, 0.8)
    label:Hide()
    frame.editLabel = label

    -- 交互逻辑全部绑定在主框架或感应层上 (由于 editBG 是 frame 的子级且 EnableMouse，它们共享交互区)
    frame:SetScript("OnMouseDown", function(f, button)
        if EX_DB.locked then return end
        if button == "LeftButton" then
            f.moving = true
            f:StartMoving()
        elseif button == "RightButton" and ExwindTools.GlobalEditMode then
            ExwindTools:OpenConfig(EXWIND_MODULE_KEY)
        end
    end)

    frame:SetScript("OnMouseUp", function(f)
        if f.moving then
            f.moving = false
            f:StopMovingOrSizing()
            SavePosition()
        end
    end)

    -- [关键修复] 正确注册 HUD 与 编辑模式回调
    RegisterEditMode()
    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY, frame)

    Refresh()
    UpdateLockState()
end

-- ===================== 新施法记录 =====================
local lastDisplayedSpell = {}
local DISPLAY_DUPLICATE_THRESHOLD = 0.4

local function NewCast(icon, spellName, spellId, backgroundcolor, bordercolor, castID, castStart, startTime,
                       endTime)
    local now = GetTime()
    if lastDisplayedSpell.spellName == spellName and
        lastDisplayedSpell.time and
        (now - lastDisplayedSpell.time) < DISPLAY_DUPLICATE_THRESHOLD then
        if debugMode then
            print(string.format("|cff00ff00[CS Debug]|r NewCast BLOCKED: %s duplicate within %.3fs",
                tostring(spellName), now - lastDisplayedSpell.time))
        end
        return
    end

    lastDisplayedSpell.spellName = spellName
    lastDisplayedSpell.time = now

    if debugMode then
        local castIDShort = castID and tostring(castID):sub(-8) or "nil"
        print(string.format("|cff00ff00[CS Debug]|r NewCast: %s, spellId: %s, castID: ...%s, before: %d",
            tostring(spellName), tostring(spellId), castIDShort, #castContent))
    end

    table.insert(castContent, 1, {
        icon = icon,
        spellName = spellName,
        spellId = spellId,
        backgroundcolor = backgroundcolor,
        bordercolor = bordercolor,
        castID = castID,
        castStart = castStart,
        startTime = startTime,
        endTime = endTime
    })
    table.remove(castContent, totalSquares + 1)

    if debugMode then
        print(string.format("|cff00ff00[CS Debug]|r NewCast: castContent count after: %d, totalSquares: %d", #
            castContent, totalSquares))
    end

    UpdateSquares()
end

-- ===================== 施法开始 (有读条) =====================
local function CastStart(castGUID)
    local castInfo = CastsTable[castGUID]
    if not castInfo then return end

    if castInfo.Displayed then return end

    local spellId = castInfo.SpellId
    local castStart = castInfo.CastStart
    local startTime = castInfo.CastTimeStart
    local endTime = castInfo.CastTimeEnd

    if ignoredSpells[spellId] then return end
    if EX_DB.ignoredSpellIds and EX_DB.ignoredSpellIds[spellId] then return end

    local icon, backgroundcolor, bordercolor = GetSpellDisplayInfo(spellId)
    local spellName = GetSpellInfo(spellId)

    castInfo.Displayed = true
    DebugPrint(spellId, "CastStart",
        string.format("Displaying via CastStart, castGUID=...%s", tostring(castGUID):sub(-8)))
    NewCast(icon, spellName, spellId, backgroundcolor, bordercolor, castGUID, castStart, startTime, endTime)
end

-- ===================== 施法完成 (瞬发) =====================
local function CastFinished(castId)
    local castInfo = CastsTable[castId]
    if not castInfo then
        DebugPrint(nil, "CastFinished", "No castInfo for " .. tostring(castId))
        return
    end

    local spellId = castInfo.SpellId

    if castInfo.Displayed then
        DebugPrint(spellId, "CastFinished", "Skipped: already displayed (flag)")
        return
    end

    local castStart = castInfo.CastStart

    if spellId and ignoredSpells[spellId] then return end
    if spellId and EX_DB.ignoredSpellIds and EX_DB.ignoredSpellIds[spellId] then return end

    local icon, backgroundcolor, bordercolor = GetSpellDisplayInfo(spellId)
    local spellName = GetSpellInfo(spellId)

    castInfo.Displayed = true
    DebugPrint(spellId, "CastFinished",
        string.format("Displaying via CastFinished, castGUID=...%s", tostring(castId):sub(-8)))
    NewCast(icon, spellName, spellId, backgroundcolor, bordercolor, castId, castStart, GetTime(), GetTime() + 1.2)
end

-- ===================== OnUpdate: 实时更新施法进度 =====================
local function TrackSpellCast()
    if not castContent or not squares then return end

    for i = 1, #castContent do
        local content = castContent[i]
        local square = squares[i]
        if not content or not square then break end

        local castInfo = CastsTable[content.castID]
        if castInfo and not castInfo.Done then
            if castInfo.PendingInterrupt then
                square.in_use = GetTime()
            elseif castInfo.HasCastTime then
                if castInfo.Success then
                    castInfo.Done = true
                    castInfo.Percent = 100
                    UpdateCooldownFrame(square, false)
                elseif castInfo.IsChanneled then
                    local name, _, _, startTime, endTime = UnitChannelInfo("player")
                    if name then
                        startTime = startTime / 1000
                        endTime = endTime / 1000
                        local diff = endTime - startTime
                        local current = GetTime() - startTime
                        local percent = current / diff * 100
                        castInfo.Percent = percent
                        UpdateCooldownFrame(square, true, startTime, endTime, castInfo)
                    end
                else
                    local _, _, _, startTime, endTime = UnitCastingInfo("player")
                    if startTime and endTime then
                        startTime = startTime / 1000
                        endTime = endTime / 1000
                        local diff = endTime - startTime
                        local current = GetTime() - startTime
                        local percent = current / diff * 100
                        castInfo.Percent = percent
                        UpdateCooldownFrame(square, true, startTime, endTime, castInfo)
                    else
                        UpdateCooldownFrame(square, false)
                    end
                end
            else
                -- 瞬发法术
                if castInfo.CastStart + 1.2 < GetTime() then
                    castInfo.Done = true
                    castInfo.Percent = 100
                    UpdateCooldownFrame(square, false)
                else
                    local startTime = castInfo.CastStart
                    local endTime = castInfo.CastStart + 1.2
                    local diff = endTime - startTime
                    local current = GetTime() - startTime
                    local percent = current / diff * 100
                    castInfo.Percent = percent
                    UpdateCooldownFrame(square, true, startTime, endTime, castInfo)
                end
            end

            square.in_use = GetTime()
        end
    end
end

-- ===================== 事件帧 =====================
local eventFrame = CreateFrame("Frame")

local function StartTracking()
    eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    eventFrame:SetScript("OnUpdate", TrackSpellCast)
end

local function StopTracking()
    eventFrame:UnregisterAllEvents()
    eventFrame:SetScript("OnUpdate", nil)
end

-- ===================== 事件处理器 =====================
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_SPELLCAST_SENT" then
        local unitID, _, castGUID, spellId = ...
        -- [12.0 适配] target 参数为秘密字符串，已忽略
        local spell = GetSpellInfo(spellId)

        if unitID == "player" then
            local existed = CastsTable[castGUID] ~= nil
            DebugPrint(spellId, "SENT",
                string.format("castGUID=%s existed=%s", tostring(castGUID), tostring(existed)))

            if not existed then
                CastsTable[castGUID] = {
                    Id = castGUID,
                    CastStart = GetTime(),
                    SpellId = spellId
                }
            else
                CastsTable[castGUID].SpellId = CastsTable[castGUID].SpellId or spellId
            end
            lastChannelSpell = castGUID
            lastSpell = spell
            lastSpellId = spellId
            lastCastId = castGUID
        end
    elseif event == "UNIT_SPELLCAST_START" then
        local unitID, castGUID, spellId = ...
        if unitID ~= "player" then return end

        DebugPrint(spellId, "START",
            string.format("unitID=%s castGUID=%s hasCastEntry=%s", tostring(unitID), tostring(castGUID),
                tostring(CastsTable[castGUID] ~= nil)))

        if CastsTable[castGUID] then
            CastsTable[castGUID].SpellId = spellId
            CastsTable[castGUID].HasCastTime = true

            local _, _, _, startTime, endTime = UnitCastingInfo("player")
            if startTime and endTime then
                CastsTable[castGUID].CastTimeStart = startTime / 1000
                CastsTable[castGUID].CastTimeEnd = endTime / 1000
            end

            CastStart(castGUID)
            DebugPrint(spellId, "START", "Called CastStart")
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unitID, castGUID, spellId = ...
        if unitID ~= "player" then return end

        DebugPrint(spellId, "INTERRUPTED", string.format("castGUID=%s, hasEntry=%s",
            tostring(castGUID), tostring(CastsTable[castGUID] ~= nil)))

        if CastsTable[castGUID] then
            local castInfo = CastsTable[castGUID]

            if castInfo.Success then
                DebugPrint(spellId, "INTERRUPTED", "Ignored: spell already succeeded (latency)")
                return
            end

            castInfo.PendingInterrupt = true
            castInfo.InterruptTime = GetTime()
            castInfo.InterruptPct = (castInfo.Percent or 0) / 100

            local _, _, _, startTime, endTime = UnitCastingInfo("player")
            if startTime and endTime then
                startTime = startTime / 1000
                endTime = endTime / 1000
                local totalTime = endTime - startTime
                local elapsed = GetTime() - startTime
                castInfo.InterruptPct = elapsed / totalTime
            end

            if castInfo.InterruptPct < 0 then castInfo.InterruptPct = 0 end
            if castInfo.InterruptPct > 1 then castInfo.InterruptPct = 1 end

            DebugPrint(spellId, "INTERRUPTED",
                string.format("Pending, pct=%s, waiting for SUCCEEDED...", tostring(castInfo.InterruptPct * 100)))

            C_Timer.After(0.25, function()
                if castInfo.Success then
                    DebugPrint(spellId, "INTERRUPTED", "Cancelled: spell succeeded during delay")
                    castInfo.PendingInterrupt = false
                    return
                end

                if castInfo.PendingInterrupt then
                    castInfo.Interrupted = true
                    castInfo.InterruptedTime = castInfo.InterruptTime
                    castInfo.Done = true
                    castInfo.Percent = castInfo.InterruptPct * 100
                    castInfo.InterruptedPct = castInfo.InterruptPct
                    castInfo.PendingInterrupt = false

                    for i, content in ipairs(castContent) do
                        if content.castID == castGUID then
                            content.endTime = castInfo.InterruptTime
                            break
                        end
                    end

                    DebugPrint(spellId, "INTERRUPTED",
                        string.format("Finalized: pct=%s", tostring(castInfo.InterruptPct * 100)))
                    UpdateSquares()
                end
            end)
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        local unitID, castGUID, spellId = ...

        if unitID == "player" then
            castGUID = lastChannelId

            if not CastsTable[castGUID] then
                castGUID = lastChannelSpell
                if not castGUID or not CastsTable[castGUID] then
                    isChanneling = false
                    lastChannelId = nil
                    return
                end
            end

            local castInfo = CastsTable[castGUID]

            local wasCompleted = castInfo.CastTimeEnd and GetTime() >= (castInfo.CastTimeEnd - 0.1)

            if wasCompleted then
                castInfo.Success = true
                castInfo.Done = true
                castInfo.Percent = 100
            else
                local completedPct = (castInfo.Percent or 0) / 100

                if castInfo.CastTimeStart and castInfo.CastTimeEnd then
                    local totalTime = castInfo.CastTimeEnd - castInfo.CastTimeStart
                    local elapsed = GetTime() - castInfo.CastTimeStart
                    completedPct = elapsed / totalTime
                end

                if completedPct < 0 then completedPct = 0 end
                if completedPct > 1 then completedPct = 1 end

                castInfo.ChannelStopped = true
                castInfo.Done = true
                castInfo.Percent = completedPct * 100
                castInfo.InterruptedPct = completedPct

                for i, content in ipairs(castContent) do
                    if content.castID == castGUID then
                        content.endTime = GetTime()
                        break
                    end
                end
            end

            isChanneling = false
            lastChannelId = nil
            UpdateSquares()
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unitID, castGUID, spellId = ...

        if unitID == "player" then
            if not castGUID or castGUID == "" then
                castGUID = lastCastId
            end

            if not CastsTable[castGUID] then
                castGUID = lastChannelSpell
            end

            if not CastsTable[castGUID] then
                castGUID = lastCastId or ("channel_" .. GetTime())
                CastsTable[castGUID] = { Id = castGUID, CastStart = GetTime() }
            end

            if isChanneling and lastChannelId and CastsTable[lastChannelId] then
                CastsTable[lastChannelId].Interrupted = true
                CastsTable[lastChannelId].InterruptedTime = GetTime()
            end

            CastsTable[castGUID].HasCastTime = true
            CastsTable[castGUID].IsChanneled = true
            CastsTable[castGUID].SpellId = lastSpellId
            lastChannelId = castGUID
            isChanneling = true

            local _, _, _, startTime, endTime = UnitChannelInfo("player")
            if startTime and endTime then
                CastsTable[castGUID].CastTimeStart = startTime / 1000
                CastsTable[castGUID].CastTimeEnd = endTime / 1000
            end

            if lastSpell then
                channelSpells[lastSpell] = true
            end

            CastStart(castGUID)
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unitID, castGUID, spellId = ...

        if unitID ~= "player" then return end

        local spell = GetSpellInfo(spellId)

        DebugPrint(spellId, "SUCCEEDED", string.format("castGUID=%s hasCastEntry=%s isChannel=%s",
            tostring(castGUID), tostring(CastsTable[castGUID] ~= nil), tostring(channelSpells[spell])))

        if not channelSpells[spell] then
            local castInfo = CastsTable[castGUID]

            if castInfo and castInfo.Displayed then
                DebugPrint(spellId, "SUCCEEDED", "Skipped: already displayed by CastStart")
                castInfo.Success = true
                return
            end

            -- [12.0 优化] 没有 SENT 记录的法术 = 附带效果/多跳，直接忽略
            -- 玩家主动施放的法术必定先触发 UNIT_SPELLCAST_SENT，在 CastsTable 中已有条目
            if not castInfo then
                DebugPrint(spellId, "SUCCEEDED", "Skipped: no SENT record (secondary effect)")
                return
            end

            local now = GetTime()
            if recentCasts[spellId] and (now - recentCasts[spellId]) < DUPLICATE_THRESHOLD then
                DebugPrint(spellId, "SUCCEEDED",
                    string.format("Skipped: duplicate within %.3fs", now - recentCasts[spellId]))
                return
            end

            recentCasts[spellId] = now

            castInfo.Success = true
            castInfo.SpellId = spellId

            CastFinished(castGUID)
            DebugPrint(spellId, "SUCCEEDED", "Called CastFinished")
        end
    end
end)

-- ===================== 过期清理 (10秒周期) =====================
C_Timer.NewTicker(10, function()
    if not mainFrame then return end
    local now = GetTime()
    local EXPIRE_TIME = 60

    local i = 1
    while i <= #castContent do
        local content = castContent[i]
        if content and content.castStart and (content.castStart + EXPIRE_TIME < now) then
            table.remove(castContent, i)
        else
            i = i + 1
        end
    end
    UpdateSquares()
end)

-- =============================================================
-- 第七部分：事件与状态订阅
-- =============================================================

-- 监听数据库变动 (用户在 Grid 面板中修改设置时触发)
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    local key = info.key
    if isEditModeActive and (key == "locked" or key == "preview") then
        return
    end

    -- 显示设置变动
    if key == "frameScale" then
        if mainFrame then mainFrame:SetScale(EX_DB.frameScale) end
    elseif key == "frameStrata" then
        if mainFrame then mainFrame:SetFrameStrata(EX_DB.frameStrata) end
    elseif key == "locked" then
        UpdateLockState()
    elseif key == "enabled" then
        if EX_DB.enabled then
            if mainFrame then mainFrame:Show() end
            StartTracking()
        else
            if mainFrame then mainFrame:Hide() end
            StopTracking()
        end
    elseif key == "squareSize" then
        RefreshAllSquareStyle()
    elseif key == "squareAmount" then
        Refresh()
    elseif key == "squareGrowDirection" then
        ReorderSquares()
    end
end)

-- 处理按钮点击
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".ButtonClicked", EXWIND_MODULE_KEY, function(info)
    if not info or not info.key then return end

    if info.key == "btn_reset" then
        ResetPosition()
    elseif info.key == "btn_addIgnore" then
        local idStr = EX_DB.ignoreSpellId
        local id = tonumber(idStr)
        if id then
            if not EX_DB.ignoredSpellIds then
                EX_DB.ignoredSpellIds = {}
            end
            if EX_DB.ignoredSpellIds[id] then
                EX_DB.ignoredSpellIds[id] = nil
                local spellName = GetSpellInfo(id) or "未知"
                CS_Print(string.format("已移除忽略: %s (ID: %d)", spellName, id))
            else
                EX_DB.ignoredSpellIds[id] = true
                local spellName = GetSpellInfo(id) or "未知"
                CS_Print(string.format("已添加忽略: %s (ID: %d)", spellName, id))
            end
            EX_DB.ignoreSpellId = ""
        else
            CS_Print("请输入有效的法术ID数字")
        end
    elseif info.key == "btn_showIgnore" then
        local count = 0
        CS_Print("已忽略的法术:")
        if EX_DB.ignoredSpellIds then
            for id, _ in pairs(EX_DB.ignoredSpellIds) do
                local spellName = GetSpellInfo(id) or "未知"
                print(string.format("  - %s (ID: %d)", spellName, id))
                count = count + 1
            end
        end
        if count == 0 then
            print("  " .. L["(无)"])
        else
            CS_Print(string.format("共 %d 个法术", count))
        end
    elseif info.key == "btn_clearIgnore" then
        EX_DB.ignoredSpellIds = {}
        CS_Print("已清空全部忽略列表")
    end
end)

-- =============================================================
-- 第八部分：初始化
-- =============================================================

ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, function(event, isLogin, isReload)
    -- 清理旧数据
    castContent = {}
    for k in pairs(CastsTable) do CastsTable[k] = nil end

    -- 创建主框体
    if not mainFrame then
        CreateMainFrame()
    end

    -- 恢复位置
    RestorePosition()

    -- 显示并开始追踪
    if EX_DB.enabled then
        mainFrame:Show()
        StartTracking()
    else
        mainFrame:Hide()
    end
end)

-- 报告模块加载完成
ExwindTools:ReportReady(EXWIND_MODULE_KEY)
