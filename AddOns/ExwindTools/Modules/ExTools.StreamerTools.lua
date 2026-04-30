-- =============================================================
-- [[ 主播小工具 (Streamer Tools) ]]
-- { Key = "ExTools.StreamerTools", Name = "主播小工具", Desc = "提供战斗计时器等直播辅助功能。", Category = 4 },
-- =============================================================

local ExwindTools = _G.ExwindTools
if not ExwindTools then return end
local L = (ExwindTools and ExwindTools.L) or setmetatable({}, { __index = function(_, key) return key end })

local EXWIND_MODULE_KEY = "ExTools.StreamerTools"

-- =============================================================
-- 1. Grid 布局定义
-- =============================================================
local function EX_RegisterLayout()
    local layout = {
        { key = "header", type = "header", x = 1, y = 1, w = 47, h = 2, label = L["1. 战斗计时器"], labelSize = 20 },
        { key = "enabled", type = "checkbox", x = 1, y = 4, w = 11, h = 2, label = L["启用计时器"] },
        { key = "resetOnBoss", type = "checkbox", x = 12, y = 4, w = 11, h = 2, label = L["首领重置"] },
        { key = "hideOutOfCombat", type = "checkbox", x = 24, y = 4, w = 10, h = 2, label = L["脱战隐藏"] },
        { key = "keepTimeOnLeaveCombat", type = "checkbox", x = 35, y = 4, w = 11, h = 2, label = L["脱战停表"] },
        { key = "locked", type = "checkbox", x = 47, y = 4, w = 8, h = 2, label = L["锁定"] },
        { key = "leftText", type = "input", x = 1, y = 8, w = 15, h = 2, label = L["前缀文字 (左)"], labelPos = "top" },
        { key = "rightText", type = "input", x = 18, y = 8, w = 15, h = 2, label = L["后缀文字 (右)"], labelPos = "top" },
        { key = "timerFont", type = "fontgroup", x = 1, y = 11, w = 53, h = 17, label = L["字体样式配置"] },
        { key = "header2", type = "header", x = 1, y = 32, w = 52, h = 2, label = L["2. 战复计时"], labelSize = 20 },
        { key = "brezEnabled", type = "checkbox", x = 1, y = 35, w = 12, h = 2, label = L["启用战复监控"] },
        { key = "brezLocked", type = "checkbox", x = 16, y = 35, w = 10, h = 2, label = L["锁定位置"] },
        { key = "brezTimerFont", type = "fontgroup", x = 1, y = 57, w = 54, h = 18, label = L["战复计时文字 (中心)"], labelSize = 20 },
        { key = "brezCountFont", type = "fontgroup", x = 1, y = 76, w = 54, h = 18, label = L["战复层数文字 (右下)"], labelSize = 20 },
        { key = "brezIcon", type = "icongroup", x = 1, y = 38, w = 54, h = 18, label = L["战复图标尺寸/位置"], labelSize = 20 },
        { key = "header3", type = "header", x = 1, y = 96, w = 52, h = 2, label = L["3. 大秘境钥石"], labelSize = 20 },
        { key = "autoInsertKeystone", type = "checkbox", x = 1, y = 99, w = 24, h = 2, label = L["打开面板自动插入钥石"] },
        { key = "header4", type = "header", x = 1, y = 103, w = 52, h = 2, label = L["4. 战斗怪物数量"], labelSize = 20 },
        { key = "mobCountEnabled", type = "checkbox", x = 1, y = 106, w = 18, h = 2, label = L["启用怪物数量文本"] },
        { key = "mobCountTemplate", type = "input", x = 1, y = 110, w = 24, h = 2, label = L["文本模板（%n 为数量）"], labelPos = "top" },
        { key = "mobCountFont", type = "fontgroup", x = 1, y = 114, w = 53, h = 17, label = L["怪物数量文字"], labelSize = 20 },
    }




    ExwindTools:RegisterModuleLayout(EXWIND_MODULE_KEY, layout)
end
EX_RegisterLayout()

-- =============================================================
-- 2. 模块初始化检查
-- =============================================================
if not ExwindTools:IsModuleEnabled(EXWIND_MODULE_KEY) then return end

-- =============================================================
-- 3. 数据初始化
-- =============================================================
local EXWIND_DEFAULTS = {
    brezCountFont = {
        a = 1,
        b = 1,
        font = "Friz Quadrata TT",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowX = 1,
        shadowY = -1,
        size = 15,
        x = -2,
        y = 3,
    },
    brezEnabled = true,
    brezIcon = {
        height = 50,
        reverse = false,
        showIcon = true,
        width = 50,
        x = -831,
        y = -65,
    },
    brezLocked = true,
    preview = false, -- 编辑模式预览状态
    autoInsertKeystone = true,
    mobCountEnabled = false,
    mobCountTemplate = "周围怪物:%n",
    mobCountPos = {
        "CENTER",
        0,
        120,
    },
    mobCountFont = {
        a = 1,
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowX = 1,
        shadowY = -1,
        size = 22,
        x = 0,
        y = 0,
    },
    brezTimerFont = {
        a = 1,
        b = 0.1843137294054,
        font = "默认",
        g = 0.78823536634445,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowX = 1,
        shadowY = -1,
        size = 20,
        x = 0,
        y = 0,
    },
    enabled = false,
    leftText = "[",
    locked = true,
    pos = {
        "CENTER",
        0,
        0,
    },
    resetOnBoss = true,
    hideOutOfCombat = false,
    keepTimeOnLeaveCombat = true,
    rightText = "]",
    timerFont = {
        a = 1,
        b = 1,
        font = "默认",
        g = 1,
        outline = "OUTLINE",
        r = 1,
        shadow = true,
        shadowX = 1,
        shadowY = -1,
        size = 24,
        x = 0,
        y = 0,
    },
}

local EX_DB = ExwindTools:GetModuleDB(EXWIND_MODULE_KEY, EXWIND_DEFAULTS)
local isEditModeActive = false
local isEditModeVisible = true
local editModeRestore = nil
local EXDB = _G.EXDB
local TimerFrame
local BRezFrame
local MobCountFrame
local TimerEditHandle
local BRezEditHandle
local MobCountEditHandle

local function EnsureEditHandle(handle)
    if handle then
        return handle
    end
    handle = CreateFrame("Frame", nil, UIParent)
    handle:SetFrameStrata("DIALOG")
    handle:Hide()
    return handle
end

local function AttachEditHandle(handle, owner)
    if not handle or not owner then
        return
    end
    handle:ClearAllPoints()
    handle:SetPoint("TOPLEFT", owner, "TOPLEFT", 0, 0)
    handle:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", 0, 0)
end

local function AttachTimerEditHandle(handle, owner)
    if not handle or not owner then
        return
    end
    local width = owner:GetWidth() or 200
    local reducedWidth = math.max(80, math.floor(width * 0.4 + 0.5))
    local inset = math.floor((width - reducedWidth) / 2)
    handle:ClearAllPoints()
    handle:SetPoint("TOPLEFT", owner, "TOPLEFT", inset, 0)
    handle:SetPoint("BOTTOMRIGHT", owner, "BOTTOMRIGHT", -inset, 0)
end

local function AttachMobCountEditHandle(handle, owner)
    if not handle or not owner then
        return
    end
    local text = owner.text
    local width = text and text.GetStringWidth and text:GetStringWidth() or owner:GetWidth() or 120
    local height = text and text.GetStringHeight and text:GetStringHeight() or owner:GetHeight() or 40
    width = math.max(80, math.floor(width + 28))
    height = math.max(24, math.floor(height + 18))
    handle:ClearAllPoints()
    if text then
        handle:SetPoint("CENTER", text, "CENTER", 0, 0)
    else
        handle:SetPoint("CENTER", owner, "CENTER", 0, 0)
    end
    handle:SetSize(width, height)
end

local function SetEditShellTransparent(frame)
    if not frame or not frame.SetBackdropColor then
        return
    end
    frame:SetBackdropColor(0, 0, 0, 0)
    if frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

local function RefreshEditOverlays()
    if TimerFrame then
        if isEditModeActive and isEditModeVisible and ExwindTools:IsEditModeModuleVisible(EXWIND_MODULE_KEY .. ".Timer") then
            TimerEditHandle = EnsureEditHandle(TimerEditHandle)
            AttachTimerEditHandle(TimerEditHandle, TimerFrame)
            TimerEditHandle:Show()
            ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY .. ".Timer", TimerEditHandle, { title = L["战斗计时器"], ownerFrame = TimerFrame })
        else
            if TimerEditHandle then
                ExwindTools:HideExwindToolsEditOverlay(TimerEditHandle)
                TimerEditHandle:Hide()
            end
        end
    end

    if BRezFrame then
        if isEditModeActive and isEditModeVisible and ExwindTools:IsEditModeModuleVisible(EXWIND_MODULE_KEY .. ".BRez") then
            BRezEditHandle = EnsureEditHandle(BRezEditHandle)
            AttachEditHandle(BRezEditHandle, BRezFrame)
            BRezEditHandle:Show()
            ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY .. ".BRez", BRezEditHandle, { title = L["战复计时"], ownerFrame = BRezFrame })
        else
            if BRezEditHandle then
                ExwindTools:HideExwindToolsEditOverlay(BRezEditHandle)
                BRezEditHandle:Hide()
            end
        end
    end

    if MobCountFrame then
        if isEditModeActive and isEditModeVisible and ExwindTools:IsEditModeModuleVisible(EXWIND_MODULE_KEY .. ".MobCount") then
            MobCountEditHandle = EnsureEditHandle(MobCountEditHandle)
            AttachMobCountEditHandle(MobCountEditHandle, MobCountFrame)
            MobCountEditHandle:Show()
            ExwindTools:ShowExwindToolsEditOverlay(EXWIND_MODULE_KEY .. ".MobCount", MobCountEditHandle, { title = L["怪物数量"], ownerFrame = MobCountFrame })
        else
            if MobCountEditHandle then
                ExwindTools:HideExwindToolsEditOverlay(MobCountEditHandle)
                MobCountEditHandle:Hide()
            end
        end
    end
end

-- 前置声明业务函数，解决回调引用顺序问题
local ApplyStyle, UpdateBRezInfo
local ApplyMobCountStyle, UpdateMobCountText
local brezRetryToken = 0
local BREZ_RETRY_DELAYS = { 0, 1, 2, 5, 10 }

-- =============================================================
-- 3.1 大秘境钥石自动插入
-- =============================================================
local KEYSTONE_RETRY_INTERVAL = 0.15
local KEYSTONE_RETRY_MAX = 8
local keystoneRetryToken = 0

local function FindKeystoneInBags()
    if not C_Container or not C_Container.GetContainerNumSlots or not C_Container.GetContainerItemInfo then
        return nil, nil
    end
    if not C_Item or not C_Item.IsItemKeystoneByID then
        return nil, nil
    end

    local bagStart = _G.BACKPACK_CONTAINER or 0
    local bagEnd = _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS or _G.NUM_BAG_SLOTS or 4

    for bag = bagStart, bagEnd do
        local numSlots = C_Container.GetContainerNumSlots(bag) or 0
        for slot = 1, numSlots do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            local itemID = itemInfo and itemInfo.itemID
            if itemID and C_Item.IsItemKeystoneByID(itemID) then
                if C_ChallengeMode and C_ChallengeMode.CanUseKeystoneInCurrentMap and ItemLocation and ItemLocation.CreateFromBagAndSlot then
                    local itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
                    if itemLocation and C_ChallengeMode.CanUseKeystoneInCurrentMap(itemLocation) then
                        return bag, slot
                    end
                else
                    return bag, slot
                end
            end
        end
    end

    return nil, nil
end

local function TryAutoInsertKeystone()
    if not EX_DB.autoInsertKeystone then return false end
    if C_MythicPlus and C_MythicPlus.GetOwnedKeystoneLevel and not C_MythicPlus.GetOwnedKeystoneLevel() then
        return false
    end
    if not C_ChallengeMode or not C_ChallengeMode.SlotKeystone or not C_ChallengeMode.HasSlottedKeystone then
        return false
    end
    if C_ChallengeMode.HasSlottedKeystone() then
        return true
    end
    if CursorHasItem and CursorHasItem() then
        return false
    end

    local bag, slot = FindKeystoneInBags()
    if not bag or not slot then
        return false
    end

    C_Container.PickupContainerItem(bag, slot)

    if CursorHasItem and CursorHasItem() then
        C_ChallengeMode.SlotKeystone()
        if C_ChallengeMode.HasSlottedKeystone() then
            if CloseAllBags then CloseAllBags() end
            return true
        end

        -- 兜底：插槽失败时尝试把钥石放回原背包格，避免卡在光标
        if C_Container and C_Container.PickupContainerItem then
            C_Container.PickupContainerItem(bag, slot)
        end
        return false
    end

    return false
end

local function ScheduleAutoInsertKeystone()
    if not EX_DB.autoInsertKeystone then return end

    keystoneRetryToken = keystoneRetryToken + 1
    local token = keystoneRetryToken

    local function Attempt(remaining)
        if token ~= keystoneRetryToken then return end
        if not EX_DB.autoInsertKeystone then return end
        if C_ChallengeMode and C_ChallengeMode.HasSlottedKeystone and C_ChallengeMode.HasSlottedKeystone() then
            return
        end

        if TryAutoInsertKeystone() then
            return
        end

        if remaining > 0 then
            C_Timer.After(KEYSTONE_RETRY_INTERVAL, function()
                Attempt(remaining - 1)
            end)
        end
    end

    Attempt(KEYSTONE_RETRY_MAX)
end

-- =============================================================
-- 4. 核心组件构建 - 战复模块
-- =============================================================
local SPELL_ID_REBIRTH = 20484    -- Rebirth (Standard)
local SPELL_ID_OVERRIDE = 1259644 -- M+ Context Check ID (User Provided)

-- 创建战复框架
local function CreateBRezFrame()
    if BRezFrame then return BRezFrame end

    local f = CreateFrame("Frame", "ExwindBRezFrame", UIParent, "BackdropTemplate")
    f:SetSize(40, 40) -- Default size, will be updated by ApplyStyle
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:SetClampedToScreen(true)

    -- 背景 (拖动提示)
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

    -- 图标
    f.Icon = f:CreateTexture(nil, "ARTWORK")
    f.Icon:SetTexture(C_Spell.GetSpellTexture(SPELL_ID_REBIRTH) or 136080) -- Rebirth Icon
    f.Icon:SetPoint("TOPLEFT", 2, -2)
    f.Icon:SetPoint("BOTTOMRIGHT", -2, 2)
    f.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- 冷却转圈 (Swipe)
    f.Cooldown = CreateFrame("Cooldown", "$parentCooldown", f, "CooldownFrameTemplate")
    f.Cooldown:SetAllPoints()
    f.Cooldown:SetDrawEdge(false)
    f.Cooldown:SetSwipeColor(0, 0, 0, 0.7)
    f.Cooldown:SetHideCountdownNumbers(true)
    f.Cooldown:SetFrameLevel(f:GetFrameLevel() + 1)

    -- 文字覆盖层：确保倒数/层数字体显示在冷却转圈之上
    f.TextOverlay = CreateFrame("Frame", nil, f)
    f.TextOverlay:SetAllPoints()
    f.TextOverlay:SetFrameStrata(f:GetFrameStrata())
    f.TextOverlay:SetFrameLevel(f.Cooldown:GetFrameLevel() + 1)
    f.TextOverlay:EnableMouse(false)

    -- 中心显示层数文本 (Timer)
    f.Timer = f.TextOverlay:CreateFontString(nil, "OVERLAY")
    f.Timer:SetPoint("CENTER", 0, 0)
    f.Timer:SetJustifyH("CENTER")
    if f.Timer.SetDrawLayer then
        f.Timer:SetDrawLayer("OVERLAY", 7)
    end

    -- 右下角文字 (Count)
    f.Count = f.TextOverlay:CreateFontString(nil, "OVERLAY")
    f.Count:SetPoint("BOTTOMRIGHT", -2, 2)
    f.Count:SetJustifyH("RIGHT")
    if f.Count.SetDrawLayer then
        f.Count:SetDrawLayer("OVERLAY", 7)
    end

    -- 按钮形式层数引用 (如果需要)
    f.Text = f.Timer

    -- 鼠标与拖动逻辑
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if not EX_DB.brezLocked then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local cx, cy = UIParent:GetCenter()
        local ex, ey = self:GetCenter()
        local scale = self:GetScale()
        if cx and ex and scale then
            EX_DB.brezIcon.x = math.floor((ex * scale - cx) + 0.5)
            EX_DB.brezIcon.y = math.floor((ey * scale - cy) + 0.5)
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "CENTER", EX_DB.brezIcon.x / scale, EX_DB.brezIcon.y / scale)
            if ExwindTools.UI and ExwindTools.UI.MainFrame and ExwindTools.UI.MainFrame:IsShown() then
                ExwindTools.UI:RefreshContent()
            end
        end
    end)

    -- 恢复位置
    local iconCfg = EX_DB.brezIcon
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", (iconCfg.x or 100), (iconCfg.y or 0))

    BRezFrame = f
    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY .. ".BRez", f)
    return f
end


-- =============================================================
-- 5. 业务逻辑与刷新 - 通用
-- =============================================================

-- ----------------- Timer Logic (Original) -----------------
local combatStartTime = 0
local combatEndTime = 0
local isRunning = false

local function GetActiveNameplateCombatCount()
    local EXcount = 0

    for EXi = 1, 40 do
        local EXunit = "nameplate" .. EXi
        if UnitExists(EXunit) and UnitAffectingCombat(EXunit) then
            EXcount = EXcount + 1
        end
    end

    return EXcount
end

local function CreateMobCountFrame()
    if MobCountFrame then return MobCountFrame end

    local f = CreateFrame("Frame", "ExwindMobCountFrame", UIParent, "BackdropTemplate")
    f:SetSize(220, 40)
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetPoint("CENTER", 0, 0)
    f.text:SetJustifyH("CENTER")

    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if EX_DB.preview then
            self:StartMoving()
        end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        EX_DB.mobCountPos = { point, x, y }
    end)

    if EX_DB.mobCountPos then
        f:ClearAllPoints()
        f:SetPoint(EX_DB.mobCountPos[1], UIParent, EX_DB.mobCountPos[1], EX_DB.mobCountPos[2], EX_DB.mobCountPos[3])
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
    end

    MobCountFrame = f
    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY .. ".MobCount", f)
    return f
end

local function CreateTimerFrame()
    if TimerFrame then return TimerFrame end

    local f = CreateFrame("Frame", "ExwindCombatTimerFrame", UIParent, "BackdropTemplate")
    f:SetSize(200, 40)
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:SetClampedToScreen(true)

    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0)
    f:SetBackdropBorderColor(0, 0, 0, 0)

    f.text = f:CreateFontString(nil, "OVERLAY")
    f.text:SetPoint("CENTER", 0, 0)
    f.text:SetJustifyH("CENTER")

    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if not EX_DB.locked then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint()
        EX_DB.pos = { point, x, y }
    end)

    if EX_DB.pos then
        f:ClearAllPoints()
        f:SetPoint(EX_DB.pos[1], UIParent, EX_DB.pos[1], EX_DB.pos[2], EX_DB.pos[3])
    else
        f:SetPoint("CENTER")
    end

    f:SetScript("OnUpdate", function(self, elapsed)
        if not isRunning then return end
        self.updater = (self.updater or 0) + elapsed
        if self.updater < 0.05 then return end
        self.updater = 0

        local now = GetTime()
        local duration = now - combatStartTime
        local minutes = math.floor(duration / 60)
        local seconds = math.floor(duration % 60)
        local timeStr = string.format("%02d:%02d", minutes, seconds)
        local fullText = (EX_DB.leftText or "") .. timeStr .. (EX_DB.rightText or "")
        self.text:SetText(fullText)
    end)

    TimerFrame = f
    ExwindTools:RegisterHUD(EXWIND_MODULE_KEY .. ".Timer", f)
    return f
end

local function StartTimer()
    if isRunning then return end
    combatStartTime = GetTime()
    isRunning = true
    if TimerFrame then TimerFrame:Show() end
end

local function StopTimer()
    if isRunning then
        combatEndTime = GetTime()
    end
    isRunning = false
end

local function ResetTimer()
    combatStartTime = GetTime()
    if not isRunning and EX_DB.enabled then
        local fullText = (EX_DB.leftText or "") .. "00:00" .. (EX_DB.rightText or "")
        if TimerFrame then TimerFrame.text:SetText(fullText) end
    end
end

-- ----------------- BRez Logic (New) -----------------

-- 检查当前是否为有效生效环境（大秘境 或 团本/地下城首领战）
-- * 团本/地下城首领战: 仅在 ENCOUNTER_START 后生效
local function IsActiveEnvironment()
    local state = ExwindTools.State
    -- 1. 大秘境环境 (不论是否战斗都从开始就显示，且它是5人环境)
    if state.DifficultyID == 8 then return true end

    -- 2. 5人小本逻辑：如果在5人本但非大秘境，则隐藏
    -- 用户要求：如果5人本的话 要在大秘境才显示 (硬编码默认行为)
    if state.InstanceType == "party" then
        return false
    end

    -- 3. 团队副本环境：结合首领战状态 (用户要求脱战即隐藏)
    if state.InstanceType == "raid" then
        return state.IsBossEncounter
    end

    -- 4. 其他场景保底匹配首领战状态 (如野外BOSS)
    if state.IsBossEncounter then return true end

    return false
end

-- 获取战复信息
UpdateBRezInfo = function()
    if not BRezFrame then return false end

    local spellIdentifier = SPELL_ID_REBIRTH
    local EXWIND_Charges = C_Spell.GetSpellCharges(spellIdentifier)

    if EXWIND_Charges and (EXWIND_Charges.maxCharges or 0) > 0 then
        local EX_Current = EXWIND_Charges.currentCharges or 0
        local EX_Max = EXWIND_Charges.maxCharges or 0
        local EX_Duration = EXWIND_Charges.cooldownDuration or 0
        local EX_StartTime = EXWIND_Charges.cooldownStartTime or 0
        local EX_Remaining = 0

        -- [预览模式] 强行展示 2层/55秒
        if EX_DB.preview then
            EX_Current = 2
            EX_Max = 3
            EX_Duration = 60
            EX_StartTime = GetTime() - 5
            EX_Remaining = 55
        else
            -- 计算当前层数恢复剩余时间
            if EX_Current < EX_Max and EX_StartTime > 0 then
                EX_Remaining = math.max(0, EX_StartTime + EX_Duration - GetTime())
            end
        end

        if EX_Remaining > 0 then
            -- 启动冷却圆圈动画
            if BRezFrame.Cooldown then
                BRezFrame.Cooldown:SetCooldown(EX_StartTime, EX_Duration)
            end

            -- 判断是否有字体再更新文字，避免 Font not set
            if BRezFrame.Timer:GetFont() then
                -- [MRT 风格] 10分钟以上显示 Xm，10分钟以下显示 M:SS
                if EX_Remaining >= 600 then
                    BRezFrame.Timer:SetFormattedText("%dm", math.ceil(EX_Remaining / 60))
                else
                    BRezFrame.Timer:SetFormattedText("%d:%02d", math.floor(EX_Remaining / 60), EX_Remaining % 60)
                end
            end
        else
            if BRezFrame.Cooldown then BRezFrame.Cooldown:Clear() end
            if BRezFrame.Timer:GetFont() then
                BRezFrame.Timer:SetText("")
            end
        end

        -- 右下角层数
        if BRezFrame.Count:GetFont() then
            BRezFrame.Count:SetText(EX_Current)
        end
        return true
    else
        return false
    end
end

-- BRez OnUpdate Handling
local brezUpdater = 0
local function BRez_OnUpdate(self, elapsed)
    brezUpdater = brezUpdater + elapsed
    if brezUpdater < 0.1 then return end
    brezUpdater = 0
    UpdateBRezInfo()
end

local function HasBRezChargeData()
    local chargeInfo = C_Spell.GetSpellCharges(SPELL_ID_REBIRTH)
    return chargeInfo and (chargeInfo.maxCharges or 0) > 0
end

local function ScheduleBRezRefresh(reason)
    brezRetryToken = brezRetryToken + 1
    local token = brezRetryToken

    for _, delay in ipairs(BREZ_RETRY_DELAYS) do
        C_Timer.After(delay, function()
            if token ~= brezRetryToken then return end
            ApplyStyle()
            if HasBRezChargeData() then
                brezRetryToken = brezRetryToken + 1
            end
        end)
    end
end

-- ----------------- Apply Styles -----------------

ApplyStyle = function()
    -- 1. Combat Timer
    if TimerFrame then
        local font = EX_DB.timerFont
        if EXDB and EXDB.ApplyFont then
            EXDB:ApplyFont(TimerFrame.text, font)
        else
            local LSM = LibStub("LibSharedMedia-3.0")
            local fontPath = LSM:Fetch("font", font.font) or "Fonts\\FRIZQT__.TTF"
            TimerFrame.text:SetFont(fontPath, font.size, font.outline)
            TimerFrame.text:SetTextColor(font.r, font.g, font.b, font.a)
            if font.shadow then
                TimerFrame.text:SetShadowOffset(font.shadowX, font.shadowY)
                TimerFrame.text:SetShadowColor(0, 0, 0, 1)
            else
                TimerFrame.text:SetShadowOffset(0, 0)
            end
        end
        TimerFrame.text:ClearAllPoints()
        TimerFrame.text:SetPoint("CENTER", font.x or 0, font.y or 0)

        if not EX_DB.locked then
            TimerFrame:SetBackdropColor(0, 0.5, 0, 0.5)
            TimerFrame:EnableMouse(true)
        else
            TimerFrame:SetBackdropColor(0, 0, 0, 0)
            TimerFrame:EnableMouse(false)
        end

        if not isRunning then
            local fullText
            -- [Update] 脱战不重置功能：如果处于配置激活，且拥有有效的终止时间记录
            if EX_DB.keepTimeOnLeaveCombat and combatEndTime > combatStartTime then
                local duration = combatEndTime - combatStartTime
                local minutes = math.floor(duration / 60)
                local seconds = math.floor(duration % 60)
                fullText = (EX_DB.leftText or "") ..
                    string.format("%02d:%02d", minutes, seconds) .. (EX_DB.rightText or "")
            else
                fullText = (EX_DB.leftText or "") .. "00:00" .. (EX_DB.rightText or "")
            end
            TimerFrame.text:SetText(fullText)
        end

        -- [v4.3] 脱战隐藏逻辑
        local showTimer = EX_DB.enabled
        if EX_DB.hideOutOfCombat and not isRunning and not EX_DB.preview then
            showTimer = false
        end

        if showTimer then TimerFrame:Show() else TimerFrame:Hide() end
    end

    -- 2. Battle Res Frame
    if BRezFrame then
        -- >>> 核心修复：优先完成战复倒数的字体挂载，再执行后续判定与渲染
        -- 1. Timer Font & Style (Center)
        local tFont = EX_DB.brezTimerFont
        if EXDB and EXDB.ApplyFont and EXDB:ApplyFont(BRezFrame.Timer, tFont) then
            -- Done via engine
        else
            local LSM = LibStub("LibSharedMedia-3.0")
            local fPath = LSM:Fetch("font", tFont.font) or "Fonts\\FRIZQT__.TTF"
            BRezFrame.Timer:SetFont(fPath, tFont.size, tFont.outline)
        end
        BRezFrame.Timer:ClearAllPoints()
        BRezFrame.Timer:SetPoint("CENTER", BRezFrame, "CENTER", tFont.x or 0, tFont.y or 0)

        -- 2. Count Font & Style (Bottom Right)
        local cFont = EX_DB.brezCountFont
        if EXDB and EXDB.ApplyFont and EXDB:ApplyFont(BRezFrame.Count, cFont) then
            -- Done via engine
        else
            local LSM = LibStub("LibSharedMedia-3.0")
            local fPath = LSM:Fetch("font", cFont.font) or "Fonts\\FRIZQT__.TTF"
            BRezFrame.Count:SetFont(fPath, cFont.size, cFont.outline)
        end
        BRezFrame.Count:ClearAllPoints()
        BRezFrame.Count:SetPoint("BOTTOMRIGHT", BRezFrame, "BOTTOMRIGHT", cFont.x or 0, cFont.y or 0)
        -- <<< 字体挂载前置结束

        -- [v5.4] 综合判定：战复池必须有数据 (poolActive) 且 处于活跃环境 (IsActiveEnvironment)
        local poolActive = UpdateBRezInfo()
        local showBrez = (EX_DB.brezEnabled and poolActive and IsActiveEnvironment())

        -- 预览/解锁模式强制显示
        if not EX_DB.brezLocked then showBrez = true end

        if showBrez then
            BRezFrame:Show()
            BRezFrame:SetScript("OnUpdate", BRez_OnUpdate) -- Enable updates
        else
            BRezFrame:Hide()
            BRezFrame:SetScript("OnUpdate", nil)
        end

        -- 3. Cooldown Swipe Effect
        if BRezFrame.Cooldown then
            BRezFrame.Cooldown:SetReverse(EX_DB.brezIcon and EX_DB.brezIcon.reverse or false)
        end

        BRezFrame:SetSize(EX_DB.brezIcon.width or 32, EX_DB.brezIcon.height or 32)
        -- 这里不再使用 Scale，而是直接用宽度和高度，更符合 icongroup 设计
        BRezFrame:SetScale(1.0)

        -- 确定图标 (优先使用 icongroup 设置的 ID)
        local tex = EX_DB.brezIcon.iconID or C_Spell.GetSpellTexture(SPELL_ID_REBIRTH) or 136080
        BRezFrame.Icon:SetTexture(tex)

        -- Position override if moving
        if not EX_DB.brezLocked then
            BRezFrame:SetBackdropColor(0, 0.5, 1, 0.5) -- Blue for BRez
            BRezFrame:EnableMouse(true)
        else
            BRezFrame:SetBackdropColor(0, 0, 0, 0)
            BRezFrame:EnableMouse(false)
        end

        -- 定位
        local iconCfg = EX_DB.brezIcon
        BRezFrame:ClearAllPoints()
        BRezFrame:SetPoint("CENTER", UIParent, "CENTER", iconCfg.x or 100, iconCfg.y or 0)

        UpdateBRezInfo() -- Initial update
    end

    RefreshEditOverlays()
end

UpdateMobCountText = function()
    if not MobCountFrame then return end

    local count = EX_DB.preview and 5 or GetActiveNameplateCombatCount()
    local template = EX_DB.mobCountTemplate or "怪物:%n"
    local text = string.gsub(template, "%%n", tostring(count))
    MobCountFrame.text:SetText(text)
end

ApplyMobCountStyle = function()
    if not MobCountFrame then return end

    local font = EX_DB.mobCountFont or {}
    if EXDB and EXDB.ApplyFont then
        EXDB:ApplyFont(MobCountFrame.text, font)
    else
        local LSM = LibStub("LibSharedMedia-3.0")
        local fontPath = LSM:Fetch("font", font.font) or "Fonts\\FRIZQT__.TTF"
        MobCountFrame.text:SetFont(fontPath, font.size or 22, font.outline or "")
        MobCountFrame.text:SetTextColor(font.r or 1, font.g or 1, font.b or 1, font.a or 1)
        if font.shadow then
            MobCountFrame.text:SetShadowOffset(font.shadowX or 1, font.shadowY or -1)
            MobCountFrame.text:SetShadowColor(0, 0, 0, 1)
        else
            MobCountFrame.text:SetShadowOffset(0, 0)
        end
    end

    MobCountFrame.text:ClearAllPoints()
    MobCountFrame.text:SetPoint("CENTER", font.x or 0, font.y or 0)

    if EX_DB.mobCountPos then
        MobCountFrame:ClearAllPoints()
        MobCountFrame:SetPoint(EX_DB.mobCountPos[1], UIParent, EX_DB.mobCountPos[1], EX_DB.mobCountPos[2],
            EX_DB.mobCountPos[3])
    end

    if EX_DB.preview then
        MobCountFrame:SetBackdropColor(0.3, 0.3, 0.8, 0.45)
        MobCountFrame:SetBackdropBorderColor(0.6, 0.6, 1, 1)
        MobCountFrame:EnableMouse(true)
        MobCountFrame:Show()
    elseif EX_DB.mobCountEnabled then
        MobCountFrame:SetBackdropColor(0, 0, 0, 0)
        MobCountFrame:SetBackdropBorderColor(0, 0, 0, 0)
        MobCountFrame:EnableMouse(false)
        MobCountFrame:Show()
    else
        MobCountFrame:Hide()
    end

    UpdateMobCountText()
    RefreshEditOverlays()
end

-- =============================================================
-- 6. Event Handling
-- =============================================================

local function OnEvent(event, unit)
    if event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        ScheduleAutoInsertKeystone()
        return
    elseif event == "CHALLENGE_MODE_KEYSTONE_SLOTTED" then
        -- 终止尚未完成的重试链
        keystoneRetryToken = keystoneRetryToken + 1
    elseif event == "PLAYER_ENTERING_WORLD" then
        EX_DB.preview = false
        EX_DB.locked = true
        EX_DB.brezLocked = true
    end

    -- Combat Timer Logic
    if EX_DB.enabled then
        if event == "PLAYER_REGEN_DISABLED" then
            ResetTimer()
            StartTimer()
        elseif event == "PLAYER_REGEN_ENABLED" then
            StopTimer()
            ApplyStyle() -- 脱战立即响应隐藏
        elseif event == "PLAYER_ENTERING_WORLD" then
            if InCombatLockdown() then
                if not isRunning then StartTimer() end
            else
                StopTimer()
            end
            ApplyStyle() -- Re-check zone (M+)
        end
    end

    -- Battle Res Logic
    if event == "ZONE_CHANGED_NEW_AREA" or event == "CHALLENGE_MODE_START" or event == "CHALLENGE_MODE_COMPLETED" then
        ApplyStyle()
        ScheduleBRezRefresh(event)
    elseif event == "SPELL_UPDATE_CHARGES" then
        ApplyStyle()
    end

    -- Specific Update Trigger (User Requested)
    if event == "UNIT_FLAGS" then
        UpdateBRezInfo()
    end
end

-- =============================================================
-- 7. Initialization
-- =============================================================

CreateTimerFrame()
CreateBRezFrame()
CreateMobCountFrame()
ApplyStyle()
ApplyMobCountStyle()

ExwindTools:RegisterEvent("PLAYER_REGEN_DISABLED", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("PLAYER_REGEN_ENABLED", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("PLAYER_ENTERING_WORLD", EXWIND_MODULE_KEY, OnEvent)

ExwindTools:RegisterEvent("ZONE_CHANGED_NEW_AREA", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("CHALLENGE_MODE_START", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("CHALLENGE_MODE_COMPLETED", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("UNIT_FLAGS", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("SPELL_UPDATE_CHARGES", EXWIND_MODULE_KEY, OnEvent)
ExwindTools:RegisterEvent("NAME_PLATE_UNIT_ADDED", EXWIND_MODULE_KEY, function()
    UpdateMobCountText()
end)
ExwindTools:RegisterEvent("NAME_PLATE_UNIT_REMOVED", EXWIND_MODULE_KEY, function()
    UpdateMobCountText()
end)
ExwindTools:RegisterEvent("UNIT_FLAGS", EXWIND_MODULE_KEY .. ".MobCount", function(_, unit)
    if unit and string.find(unit, "nameplate", 1, true) then
        UpdateMobCountText()
    end
end)
ExwindTools:RegisterEvent("PLAYER_REGEN_ENABLED", EXWIND_MODULE_KEY .. ".MobCount", function()
    UpdateMobCountText()
end)
ExwindTools:RegisterEvent("PLAYER_REGEN_DISABLED", EXWIND_MODULE_KEY .. ".MobCount", function()
    UpdateMobCountText()
end)

-- 监听配置变更
ExwindTools:WatchState(EXWIND_MODULE_KEY .. ".DatabaseChanged", EXWIND_MODULE_KEY, function(info)
    if isEditModeActive and info and (info.key == "preview" or info.key == "locked" or info.key == "brezLocked") then
        return
    end
    ApplyStyle()
    ApplyMobCountStyle()
end)

-- 监听首领战状态 (用于计时器重置 & 战复可见性)
ExwindTools:WatchState("IsBossEncounter", EXWIND_MODULE_KEY, function(isBoss)
    if isBoss and EX_DB.resetOnBoss then
        -- [Core] 用 WatchState 响应首领战开始
        ResetTimer()
        StartTimer()
    end
    ApplyStyle() -- 刷新可见性
    ScheduleBRezRefresh("IsBossEncounter")
end)

-- 监听副本难度/类型变化 (用于战复可见性)
ExwindTools:WatchState("DifficultyID", EXWIND_MODULE_KEY, function()
    ApplyStyle()
end)
ExwindTools:WatchState("InstanceType", EXWIND_MODULE_KEY, function()
    ApplyStyle()
end)

-- 全局编辑模式集成
local function ApplyEditModePresentation()
    if isEditModeActive then
        EX_DB.preview = isEditModeVisible
        EX_DB.locked = not isEditModeVisible
        EX_DB.brezLocked = not isEditModeVisible
        ApplyStyle()
        ApplyMobCountStyle()
        if isEditModeVisible then
            local timerVisible = ExwindTools:IsEditModeModuleVisible(EXWIND_MODULE_KEY .. ".Timer")
            local brezVisible = ExwindTools:IsEditModeModuleVisible(EXWIND_MODULE_KEY .. ".BRez")
            local mobVisible = ExwindTools:IsEditModeModuleVisible(EXWIND_MODULE_KEY .. ".MobCount")

            if not TimerFrame then CreateTimerFrame() end
            if not BRezFrame then CreateBRezFrame() end
            if not MobCountFrame then CreateMobCountFrame() end

            if TimerFrame then
                if timerVisible then
                    TimerFrame:Show()
                    TimerFrame:EnableMouse(true)
                    SetEditShellTransparent(TimerFrame)
                    local previewText = string.format("%s00:45%s", EX_DB.leftText or "", EX_DB.rightText or "")
                    if TimerFrame.text then
                        TimerFrame.text:SetText(previewText)
                    end
                else
                    TimerFrame:Hide()
                end
            end

            if BRezFrame then
                if brezVisible then
                    BRezFrame:Show()
                    BRezFrame:EnableMouse(true)
                    SetEditShellTransparent(BRezFrame)
                    if BRezFrame.Timer then BRezFrame.Timer:SetText("45") end
                    if BRezFrame.Count then BRezFrame.Count:SetText("1") end
                else
                    BRezFrame:Hide()
                end
            end

            if MobCountFrame then
                if mobVisible then
                    MobCountFrame:Show()
                    MobCountFrame:EnableMouse(true)
                    SetEditShellTransparent(MobCountFrame)
                    if MobCountFrame.text then
                        local template = EX_DB.mobCountTemplate or "周围怪物:%n"
                        MobCountFrame.text:SetText((template:gsub("%%n", "5")))
                    end
                else
                    MobCountFrame:Hide()
                end
            end
        else
            if TimerFrame then TimerFrame:Hide() end
            if BRezFrame then BRezFrame:Hide() end
            if MobCountFrame then MobCountFrame:Hide() end
        end
    else
        if editModeRestore then
            EX_DB.preview = editModeRestore.preview
            EX_DB.locked = editModeRestore.locked
            EX_DB.brezLocked = editModeRestore.brezLocked
            editModeRestore = nil
        end
        ApplyStyle()
        ApplyMobCountStyle()
    end

    RefreshEditOverlays()

    if ExwindTools.UI and ExwindTools.UI.RightPanel and ExwindTools.UI.RightPanel:IsVisible() and ExwindTools.UI.RefreshContent then
        ExwindTools.UI:RefreshContent()
    end
end

ExwindTools:RegisterEditModeHandler(EXWIND_MODULE_KEY, {
    EnterEditMode = function()
        if not editModeRestore then
            editModeRestore = {
                preview = EX_DB.preview,
                locked = EX_DB.locked,
                brezLocked = EX_DB.brezLocked,
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
