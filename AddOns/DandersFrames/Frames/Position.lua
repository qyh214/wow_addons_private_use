local addonName, DF = ...
local L = DF.L
local format = string.format

-- ============================================================
-- FRAMES POSITION MODULE
-- Contains mover, grid overlay, and position panel
-- ============================================================

-- ============================================================
-- RAIDPOS DIAGNOSTIC HELPERS
-- Targeted instrumentation for the "raid frames jump on roster
-- change and stay stuck" bug. Output goes through DF:Debug under
-- the "RAIDPOS" category so users can copy/paste from the Debug
-- Console. Logging cost is one boolean check when disabled.
-- ============================================================

local function ShortCaller(level)
    -- Returns "filename:line" of the caller `level` frames up.
    -- level=2 -> direct caller of the function that calls ShortCaller.
    local info = debugstack(level or 2, 1, 0)
    if not info then return "?" end
    -- debugstack format: "...\Frames\Position.lua:1841: in function 'NudgePosition'\n"
    local file, line = info:match("([^\\/]+):(%d+):")
    if file then return file .. ":" .. line end
    return "?"
end

-- Log a write to db.raidAnchorX/Y. Call BEFORE the assignment so
-- we can capture the old value, then perform the assignment.
function DF:LogRaidAnchorWrite(reason, newX, newY)
    if not DF.Debug then return end
    local db = DF:GetRaidDB()
    local oldX, oldY = db and db.raidAnchorX or 0, db and db.raidAnchorY or 0
    DF:Debug("RAIDPOS", "raidAnchor WRITE [%s] @ %s : (%.1f,%.1f) -> (%.1f,%.1f)",
        tostring(reason), ShortCaller(3), oldX, oldY, newX or 0, newY or 0)
end

-- ============================================================
-- POSITION PANEL MODE DESCRIPTORS
-- ============================================================
-- The position panel (the floating nudge UI shown while unlocking
-- frames) supports multiple targets: party frames, raid frames, the
-- personal targeted spells container, and the Targeted List. Each
-- target has its own db fields and its own "apply" function. The
-- descriptor table below encapsulates those differences so the panel
-- code can stay target-agnostic.
--
-- DF.positionPanelMode selects which descriptor is active. Clicking
-- any mover switches the mode; the panel then re-reads from the
-- descriptor's db fields and nudge operations write back to them.

local POSITION_MODES = {
    party = {
        title = "Party Position",
        getDB = function() return DF:GetDB() end,
        xField = "anchorX",
        yField = "anchorY",
        apply = function() if DF.UpdateContainerPosition then DF:UpdateContainerPosition() end end,
        useAccentColor = "accent",  -- main theme color
    },
    raid = {
        title = "Raid Position",
        getDB = function() return DF:GetRaidDB() end,
        xField = "raidAnchorX",
        yField = "raidAnchorY",
        apply = function() if DF.UpdateRaidContainerPosition then DF:UpdateRaidContainerPosition() end end,
        logWrites = true,
        autoProfileX = "raidAnchorX",  -- matches xField; AutoProfilesUI key
        autoProfileY = "raidAnchorY",
        useAccentColor = "raid",
    },
    personal = {
        title = "Personal Targeted",
        getDB = function() return DF:GetDB() end,
        xField = "personalTargetedSpellX",
        yField = "personalTargetedSpellY",
        apply = function()
            if DF.UpdatePersonalTargetedSpellsPosition then
                DF:UpdatePersonalTargetedSpellsPosition()
            end
            -- Also reposition the personal mover to match
            if DF.personalTargetedSpellsMover and DF.personalTargetedSpellsMover:IsShown() then
                local db = DF:GetDB()
                DF.personalTargetedSpellsMover:ClearAllPoints()
                DF.personalTargetedSpellsMover:SetPoint("CENTER", UIParent, "CENTER",
                    db.personalTargetedSpellX or 0, db.personalTargetedSpellY or -150)
            end
        end,
        useAccentColor = "accent",
    },
    targetedList = {
        title = "Targeted List",
        getDB = function() return DF:GetDB() end,
        xField = "targetedListX",
        yField = "targetedListY",
        apply = function()
            if DF.UpdateTargetedListLayout then DF:UpdateTargetedListLayout() end
            -- Also reposition the mover to match
            if DF.targetedListMoverFrame and DF.targetedListMoverFrame:IsShown() then
                local db = DF:GetDB()
                DF.targetedListMoverFrame:ClearAllPoints()
                DF.targetedListMoverFrame:SetPoint("CENTER", UIParent, "CENTER",
                    db.targetedListX or 0, db.targetedListY or -10)
            end
        end,
        useAccentColor = "accent",
    },
}

-- Accessor helper. Defaults to party mode if something's off.
local function GetPositionMode()
    return POSITION_MODES[DF.positionPanelMode] or POSITION_MODES.party
end

-- Exposed so the movers (personal targeted spells, targeted list)
-- can switch the panel target when clicked.
function DF:SetPositionPanelMode(mode)
    if not POSITION_MODES[mode] then return end
    DF.positionPanelMode = mode
    if DF.positionPanel then
        if DF.positionPanel.UpdateTheme then DF.positionPanel:UpdateTheme() end
        DF:UpdatePositionPanel()
    end
end

function DF:CreateMoverFrame()
    -- Cannot create UI elements during combat
    if InCombatLockdown() then return end
    
    -- Don't recreate if already exists
    if DF.moverFrame then return end
    
    -- CRITICAL: Ensure container exists before creating mover
    if not DF.container then
        print("|cFFFF0000[DF Position]|r Cannot create mover - DF.container doesn't exist!")
        return
    end
    
    local mover = CreateFrame("Frame", "DandersFramesMover", DF.container, "BackdropTemplate")
    mover:SetAllPoints(DF.container)
    mover:SetFrameStrata("TOOLTIP")  -- Very high strata to be above secure frames
    mover:SetFrameLevel(100)
    mover:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    mover:SetBackdropColor(0.2, 0.6, 1.0, 0.3)
    mover:SetBackdropBorderColor(0.2, 0.6, 1.0, 0.8)
    mover:EnableMouse(true)
    mover:SetMovable(true)
    mover:RegisterForDrag("LeftButton")
    mover:Hide()
    
    local label = mover:CreateFontString(nil, "OVERLAY")
    label:SetPoint("CENTER")
    -- Set font explicitly to avoid "Font not set" errors
    DF.GUI:SetSettingsFont(label, 14, "OUTLINE")
    label:SetText("Party Frames\nDrag to move")
    label:SetTextColor(1, 1, 1, 1)
    
    DF.moverFrame = mover
    
    -- Shared drag state between OnDragStart/OnUpdate/OnDragStop
    local dragOffsetX, dragOffsetY = 0, 0

    -- Left-click switches the shared position panel to party mode.
    -- This is necessary because clicking the personal or targeted-list
    -- mover switches the panel away from party — clicking the party
    -- mover should bring it back.
    mover:HookScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("party")
        end
    end)

    mover:SetScript("OnDragStart", function(self)
        -- Switch the position panel to party mode so nudge buttons
        -- affect the party container.
        if DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("party")
        end
        DF.isDragging = true
        -- Use saved db position as truth — avoids all GetCenter/GetLeft
        -- ambiguity on scaled frames. Cursor position in UIParent coords.
        local db = DF:GetDB()
        local pScale = UIParent:GetEffectiveScale()
        local startCursorX, startCursorY = GetCursorPosition()
        startCursorX = startCursorX / pScale
        startCursorY = startCursorY / pScale
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        -- The frame's visual center in UIParent coords (known from saved position)
        local frameCX = screenWidth / 2 + (db.anchorX or 0)
        local frameCY = screenHeight / 2 + (db.anchorY or 0)
        local cursorOffX = frameCX - startCursorX
        local cursorOffY = frameCY - startCursorY
        -- Initialize shared drag state
        dragOffsetX = db.anchorX or 0
        dragOffsetY = db.anchorY or 0

        -- Start OnUpdate to track cursor and sync positions during drag
        self:SetScript("OnUpdate", function()
            local cursorX, cursorY = GetCursorPosition()
            local ps = UIParent:GetEffectiveScale()
            cursorX = cursorX / ps
            cursorY = cursorY / ps
            -- New frame center = cursor + stored offset from cursor to frame center
            local sw, sh = GetScreenWidth(), GetScreenHeight()
            dragOffsetX = (cursorX + cursorOffX) - sw / 2
            dragOffsetY = (cursorY + cursorOffY) - sh / 2
            -- Apply with frame scale compensation
            local frameScale = DF.container:GetScale() or 1
            DF.container:ClearAllPoints()
            DF.container:SetPoint("CENTER", UIParent, "CENTER", dragOffsetX / frameScale, dragOffsetY / frameScale)

            -- Sync testPartyContainer to container position (for live preview)
            if DF.testPartyContainer then
                DF.testPartyContainer:ClearAllPoints()
                DF.testPartyContainer:SetPoint("CENTER", UIParent, "CENTER", dragOffsetX / frameScale, dragOffsetY / frameScale)
            end

            -- Snap preview if enabled
            local snapDb = DF:GetDB()
            if snapDb.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown() then
                DF:UpdateSnapPreview(DF.container, dragOffsetX, dragOffsetY)
            end
        end)
    end)

    mover:SetScript("OnDragStop", function(self)
        DF.isDragging = false

        -- Stop OnUpdate
        self:SetScript("OnUpdate", nil)

        -- Hide snap preview lines
        DF:HideSnapPreview()

        -- Use the last computed offset from OnUpdate (stored in shared upvalues)
        local x, y = dragOffsetX, dragOffsetY

        -- Snap to grid if enabled
        local db = DF:GetDB()
        if db.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown() then
            x, y = DF:SnapToGrid(x, y)
        end

        -- Apply snapped position
        local frameScale = DF.container:GetScale() or 1
        DF.container:ClearAllPoints()
        DF.container:SetPoint("CENTER", UIParent, "CENTER", x / frameScale, y / frameScale)

        -- Sync testPartyContainer to final position
        if DF.testPartyContainer then
            DF.testPartyContainer:ClearAllPoints()
            DF.testPartyContainer:SetPoint("CENTER", UIParent, "CENTER", x / frameScale, y / frameScale)
        end

        -- Save position
        db.anchorPoint = "CENTER"
        db.anchorX = x
        db.anchorY = y

        -- Update position panel
        DF:UpdatePositionPanel()
    end)
    
    mover:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            DF:LockFrames()
        end
    end)
    
    DF.moverFrame = mover
    
    -- Create grid overlay
    DF:CreateGridOverlay()
    
    -- Create position control panel
    DF:CreatePositionPanel()
end

-- ============================================================
-- PERMANENT MOVER HANDLE
-- Small always-visible drag handle for repositioning without unlock
-- ============================================================

local InCombatLockdown = InCombatLockdown

-- Quick action dispatch table
local PERM_MOVER_ACTIONS = {
    NONE              = { label = L["None"],                       combatSafe = true },
    OPEN_SETTINGS     = { label = L["Open Settings"],              combatSafe = true,  fn = function() DF:ToggleGUI() end },
    UNLOCK_FRAMES     = { label = L["Unlock Frames"],              combatSafe = false, fn = function(mode)
        if mode == "raid" then DF:UnlockRaidFrames() else DF:UnlockFrames() end
    end },
    TOGGLE_TEST       = { label = L["Toggle Test Mode"],           combatSafe = false, fn = function() if DF.ToggleTestMode then DF:ToggleTestMode() end end },
    SWITCH_PROFILE    = { label = L["Quick Switch Profile"],       combatSafe = false, fn = function(mode, handle) DF:ShowPermanentMoverProfilePopup(handle) end },
    SWITCH_CC_PROFILE = { label = L["Quick Switch CC Profile"],    combatSafe = false, fn = function(mode, handle) DF:ShowPermanentMoverCCProfilePopup(handle) end },
    CYCLE_PROFILE     = { label = L["Cycle Next Profile"],         combatSafe = false, fn = function() DF:CycleNextProfile() end },
    CYCLE_CC_PROFILE  = { label = L["Cycle Next CC Profile"],      combatSafe = false, fn = function() DF:CycleNextCCProfile() end },
    TOGGLE_SOLO       = { label = L["Toggle Solo Mode"],           combatSafe = false, fn = function()
        local db = DF:GetDB()
        db.soloMode = not db.soloMode
        DF:UpdateAllFrames()
        if DF.UpdateDefaultPlayerFrame then DF:UpdateDefaultPlayerFrame() end
        print("|cff00ff00DandersFrames:|r " .. format(L["Solo mode %s"], db.soloMode and L["enabled"] or L["disabled"]))
    end },
    RELOAD_UI         = { label = L["Reload UI"],                  combatSafe = true,  fn = function() ReloadUI() end },
    RESET_POSITION    = { label = L["Reset Position"],             combatSafe = false, fn = function() DF:ResetPosition() end },
    READY_CHECK       = { label = L["Ready Check"],                combatSafe = true,  fn = function() DoReadyCheck() end },
    PULL_TIMER        = { label = L["Pull Timer"],                 combatSafe = true,  fn = function()
        local db = DF:GetDB()
        C_PartyInfo.DoCountdown(db.permanentMoverPullTimerDuration or 10)
    end },
}
DF.PERM_MOVER_ACTIONS = PERM_MOVER_ACTIONS

-- Cycle through profiles
function DF:CycleNextProfile()
    local profiles = DF:GetProfiles()
    if not profiles or #profiles < 2 then return end
    local current = DF:GetCurrentProfile()
    for i, name in ipairs(profiles) do
        if name == current then
            DF:SetProfile(profiles[(i % #profiles) + 1])
            return
        end
    end
end

function DF:CycleNextCCProfile()
    local CC = DF.ClickCast
    if not CC then return end
    local profiles = CC:GetProfileList()
    if not profiles or #profiles < 2 then return end
    local current = CC:GetActiveProfileName()
    for i, name in ipairs(profiles) do
        if name == current then
            local nextName = profiles[(i % #profiles) + 1]
            CC:SetActiveProfile(nextName)
            CC:ApplyBindings()
            print("|cff00ff00DandersFrames:|r " .. format(L["Click-cast profile: %s"], nextName))
            return
        end
    end
end

-- Shared popup menu for profile switching
function DF:CreatePermanentMoverPopup()
    if DF.permanentMoverPopup then return DF.permanentMoverPopup end

    local C_BG    = {r = 0.08, g = 0.08, b = 0.08, a = 0.95}
    local C_ELEM  = {r = 0.18, g = 0.18, b = 0.18, a = 1}
    local C_HOVER = {r = 0.22, g = 0.22, b = 0.22, a = 1}
    local C_BORDER = {r = 0.25, g = 0.25, b = 0.25, a = 1}

    local popup = CreateFrame("Frame", "DandersFramesPermanentMoverPopup", UIParent, "BackdropTemplate")
    popup:SetFrameStrata("FULLSCREEN_DIALOG")
    popup:SetFrameLevel(200)
    popup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    popup:SetBackdropColor(C_BG.r, C_BG.g, C_BG.b, C_BG.a)
    popup:SetBackdropBorderColor(0, 0, 0, 1)
    popup:EnableMouse(true)
    popup:Hide()

    popup.title = popup:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    popup.title:SetPoint("TOPLEFT", 10, -8)

    popup.buttons = {}

    -- Close when clicking outside
    popup.closer = CreateFrame("Button", nil, UIParent)
    popup.closer:SetAllPoints(UIParent)
    popup.closer:SetFrameStrata("FULLSCREEN")
    popup.closer:SetFrameLevel(199)
    popup.closer:Hide()
    popup.closer:SetScript("OnClick", function() popup:Hide() end)

    popup:SetScript("OnShow", function() popup.closer:Show() end)
    popup:SetScript("OnHide", function() popup.closer:Hide() end)

    -- Apply GUI scale
    popup:SetScript("OnShow", function(self)
        local guiScale = DF.db and DF.db.party and DF.db.party.guiScale or 1.0
        self:SetScale(guiScale)
        self.closer:Show()
    end)

    function popup:Populate(titleText, items, currentItem, onSelect, accentR, accentG, accentB)
        self.title:SetText(titleText)
        self.title:SetTextColor(accentR or 0.45, accentG or 0.45, accentB or 0.95)

        -- Hide all existing buttons
        for _, btn in ipairs(self.buttons) do btn:Hide() end

        local btnHeight = 22
        local btnWidth = 180
        local yOff = -28

        for idx, name in ipairs(items) do
            local btn = self.buttons[idx]
            if not btn then
                btn = CreateFrame("Button", nil, self, "BackdropTemplate")
                btn:SetSize(btnWidth, btnHeight)
                btn:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8x8",
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                })
                btn.text = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                btn.text:SetPoint("LEFT", 8, 0)
                btn.check = btn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
                btn.check:SetPoint("RIGHT", -8, 0)
                btn.check:SetText(">")
                self.buttons[idx] = btn
            end

            btn:SetPoint("TOPLEFT", 5, yOff)
            btn.text:SetText(name)
            btn:Show()

            local isCurrent = (name == currentItem)
            if isCurrent then
                btn:SetBackdropColor(accentR or 0.45, accentG or 0.45, accentB or 0.95, 0.3)
                btn:SetBackdropBorderColor(accentR or 0.45, accentG or 0.45, accentB or 0.95, 0.5)
                btn.text:SetTextColor(1, 1, 1)
                btn.check:SetTextColor(accentR or 0.45, accentG or 0.45, accentB or 0.95)
                btn.check:Show()
            else
                btn:SetBackdropColor(C_ELEM.r, C_ELEM.g, C_ELEM.b, C_ELEM.a)
                btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.3)
                btn.text:SetTextColor(0.8, 0.8, 0.8)
                btn.check:Hide()
            end

            btn:SetScript("OnEnter", function(b)
                if not isCurrent then
                    b:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1)
                end
            end)
            btn:SetScript("OnLeave", function(b)
                if isCurrent then
                    b:SetBackdropColor(accentR or 0.45, accentG or 0.45, accentB or 0.95, 0.3)
                else
                    b:SetBackdropColor(C_ELEM.r, C_ELEM.g, C_ELEM.b, C_ELEM.a)
                end
            end)
            btn:SetScript("OnClick", function()
                onSelect(name)
                self:Hide()
            end)

            yOff = yOff - btnHeight - 2
        end

        self:SetSize(btnWidth + 10, -yOff + 5)
    end

    DF.permanentMoverPopup = popup
    return popup
end

function DF:ShowPermanentMoverProfilePopup(anchorFrame)
    local popup = DF:CreatePermanentMoverPopup()
    local profiles = DF:GetProfiles()
    if not profiles or #profiles == 0 then return end
    local current = DF:GetCurrentProfile()
    local isRaid = anchorFrame and anchorFrame.isRaid
    local ar, ag, ab = 0.45, 0.45, 0.95
    if isRaid then ar, ag, ab = 1.0, 0.5, 0.2 end

    popup:Populate("Profiles", profiles, current, function(name)
        DF:SetProfile(name)
    end, ar, ag, ab)

    popup:ClearAllPoints()
    popup:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
    popup:Show()
end

function DF:ShowPermanentMoverCCProfilePopup(anchorFrame)
    local CC = DF.ClickCast
    if not CC then return end
    local popup = DF:CreatePermanentMoverPopup()
    local profiles = CC:GetProfileList()
    if not profiles or #profiles == 0 then return end
    local current = CC:GetActiveProfileName()
    local isRaid = anchorFrame and anchorFrame.isRaid
    local ar, ag, ab = 0.45, 0.45, 0.95
    if isRaid then ar, ag, ab = 1.0, 0.5, 0.2 end

    popup:Populate("Click-Cast Profiles", profiles, current, function(name)
        CC:SetActiveProfile(name)
        CC:ApplyBindings()
        print("|cff00ff00DandersFrames:|r " .. format(L["Click-cast profile: %s"], name))
    end, ar, ag, ab)

    popup:ClearAllPoints()
    popup:SetPoint("BOTTOMLEFT", anchorFrame, "TOPLEFT", 0, 4)
    popup:Show()
end

function DF:CreatePermanentMover(container, mode)
    if not container then return end

    local isRaid = (mode == "raid")
    local handleName = isRaid and "DandersFramesRaidPermanentMover" or "DandersFramesPartyPermanentMover"

    -- Don't recreate
    if isRaid and DF.permanentRaidMover then return end
    if not isRaid and DF.permanentPartyMover then return end

    local db = isRaid and DF:GetRaidDB() or DF:GetDB()

    local handle = CreateFrame("Button", handleName, UIParent, "BackdropTemplate")
    handle:SetSize(db.permanentMoverWidth or 20, db.permanentMoverHeight or 20)
    handle:SetFrameStrata("MEDIUM")
    handle:SetFrameLevel(100)
    handle:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })

    -- Store colors on handle from DB
    local color = db.permanentMoverColor or {r = 0.45, g = 0.45, b = 0.95}
    handle.accentR, handle.accentG, handle.accentB = color.r, color.g, color.b
    handle.isRaid = isRaid
    handle.mode = mode

    local function GetHandleColors()
        if InCombatLockdown() then
            local cDb = isRaid and DF:GetRaidDB() or DF:GetDB()
            local cc = cDb.permanentMoverCombatColor or {r = 0.8, g = 0.15, b = 0.15}
            return cc.r, cc.g, cc.b
        end
        return handle.accentR, handle.accentG, handle.accentB
    end

    local function ApplyHandleColors(hover)
        local r, g, b = GetHandleColors()
        local inCombat = InCombatLockdown()
        -- Use stronger alpha in combat so the red is clearly visible
        local bgAlpha = (hover or inCombat) and 0.7 or 0.4
        local borderAlpha = (hover or inCombat) and 1.0 or 0.7
        handle:SetBackdropColor(r, g, b, bgAlpha)
        handle:SetBackdropBorderColor(r, g, b, borderAlpha)
        -- Update dot colors to match
        local dotR, dotG, dotB = 1, 1, 1
        if inCombat then dotR, dotG, dotB = 1, 0.6, 0.6 end
        if handle.dots then
            for _, dot in ipairs(handle.dots) do
                dot:SetColorTexture(dotR, dotG, dotB, 0.6)
            end
        end
    end

    ApplyHandleColors(false)
    handle.ApplyHandleColors = ApplyHandleColors

    -- Grip dots — tiled to fill handle
    handle.dots = {}
    DF:UpdatePermanentMoverDots(handle)

    handle:EnableMouse(true)
    handle:SetMovable(true)
    handle:RegisterForDrag("LeftButton")
    handle:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    handle:Hide()

    -- Fade animations
    handle.fadeIn = handle:CreateAnimationGroup()
    local alphaIn = handle.fadeIn:CreateAnimation("Alpha")
    alphaIn:SetFromAlpha(0)
    alphaIn:SetToAlpha(1)
    alphaIn:SetDuration(0.2)
    handle.fadeIn:SetScript("OnPlay", function() handle:Show() end)
    handle.fadeIn:SetScript("OnFinished", function() handle:SetAlpha(1) end)

    handle.fadeOut = handle:CreateAnimationGroup()
    local alphaOut = handle.fadeOut:CreateAnimation("Alpha")
    alphaOut:SetFromAlpha(1)
    alphaOut:SetToAlpha(0)
    alphaOut:SetDuration(0.2)
    handle.fadeOut:SetScript("OnFinished", function() handle:SetAlpha(0) end)

    -- Hover handlers
    handle.isDragging = false

    handle:SetScript("OnEnter", function(self)
        local hoverDb = isRaid and DF:GetRaidDB() or DF:GetDB()
        if hoverDb.permanentMoverShowOnHover then
            self.fadeOut:Stop()
            self.fadeIn:Play()
        end
        ApplyHandleColors(true)
    end)
    handle:SetScript("OnLeave", function(self)
        if self.isDragging then return end  -- Stay visible while dragging
        local hoverDb = isRaid and DF:GetRaidDB() or DF:GetDB()
        if hoverDb.permanentMoverShowOnHover then
            self.fadeIn:Stop()
            self.fadeOut:Play()
        end
        ApplyHandleColors(false)
    end)

    -- Drag handlers with combat protection
    -- Manual cursor tracking instead of StartMoving() — WoW's StartMoving
    -- doesn't handle scaled frames correctly and causes a position jump
    handle:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        self.isDragging = true
        -- Keep fully visible during drag
        self.fadeOut:Stop()
        self.fadeIn:Stop()
        self:SetAlpha(1)

        -- Use saved db position as truth — avoids scale ambiguity
        local dragDb = isRaid and DF:GetRaidDB() or DF:GetDB()
        local pScale = UIParent:GetEffectiveScale()
        local startCursorX, startCursorY = GetCursorPosition()
        startCursorX = startCursorX / pScale
        startCursorY = startCursorY / pScale
        local sw, sh = GetScreenWidth(), GetScreenHeight()
        local anchorX = isRaid and (dragDb.raidAnchorX or 0) or (dragDb.anchorX or 0)
        local anchorY = isRaid and (dragDb.raidAnchorY or 0) or (dragDb.anchorY or 0)
        local frameCX = sw / 2 + anchorX
        local frameCY = sh / 2 + anchorY
        handle._cursorOffX = frameCX - startCursorX
        handle._cursorOffY = frameCY - startCursorY

        -- Sync container and test containers live during drag
        self:SetScript("OnUpdate", function()
            local cursorX, cursorY = GetCursorPosition()
            local ps = UIParent:GetEffectiveScale()
            cursorX = cursorX / ps
            cursorY = cursorY / ps

            local sww, shh = GetScreenWidth(), GetScreenHeight()
            local ox = (cursorX + handle._cursorOffX) - sww / 2
            local oy = (cursorY + handle._cursorOffY) - shh / 2

            local s = container:GetScale() or 1
            container:ClearAllPoints()
            container:SetPoint("CENTER", UIParent, "CENTER", ox / s, oy / s)

            if isRaid then
                if DF.testRaidContainer then
                    DF.testRaidContainer:ClearAllPoints()
                    DF.testRaidContainer:SetPoint("CENTER", UIParent, "CENTER", ox / s, oy / s)
                end
            else
                if DF.testPartyContainer then
                    DF.testPartyContainer:ClearAllPoints()
                    DF.testPartyContainer:SetPoint("CENTER", UIParent, "CENTER", ox / s, oy / s)
                end
            end
        end)
    end)

    handle:SetScript("OnDragStop", function(self)
        self.isDragging = false
        self:SetScript("OnUpdate", nil)

        -- Re-evaluate hover state after drag ends
        local hoverDb = isRaid and DF:GetRaidDB() or DF:GetDB()
        if hoverDb.permanentMoverShowOnHover and not self:IsMouseOver() then
            self.fadeOut:Play()
        end
        if not self:IsMouseOver() then
            ApplyHandleColors(false)
        end

        if InCombatLockdown() then return end

        -- Compute final position from cursor (same math as OnUpdate)
        -- to avoid GetCenter() ambiguity on scaled frames
        local ps = UIParent:GetEffectiveScale()
        local finalCursorX, finalCursorY = GetCursorPosition()
        finalCursorX = finalCursorX / ps
        finalCursorY = finalCursorY / ps
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        local x = (finalCursorX + self._cursorOffX) - screenWidth / 2
        local y = (finalCursorY + self._cursorOffY) - screenHeight / 2

        if isRaid then
            local stopDb = DF:GetRaidDB()
            DF:LogRaidAnchorWrite("DragMover:OnDragStop", x, y)
            stopDb.raidAnchorX = x
            stopDb.raidAnchorY = y
            DF:UpdateRaidContainerPosition()
        else
            local stopDb = DF:GetDB()
            stopDb.anchorX = x
            stopDb.anchorY = y
            DF:UpdateContainerPosition()
        end
    end)

    -- Click handlers for quick actions
    handle:SetScript("OnMouseDown", function(self, button)
        self.clickButton = button
        self.isClick = true
    end)

    handle:SetScript("OnMouseUp", function(self, button)
        if self.isDragging then
            self.isClick = false
            return  -- OnDragStop handles the drag
        end
        if not self.isClick then return end
        self.isClick = false

        local actionDb = isRaid and DF:GetRaidDB() or DF:GetDB()
        local actionKey
        local isShift = IsShiftKeyDown()

        if button == "LeftButton" and isShift then
            actionKey = actionDb.permanentMoverActionShiftLeft
        elseif button == "LeftButton" then
            actionKey = actionDb.permanentMoverActionLeft
        elseif button == "RightButton" and isShift then
            actionKey = actionDb.permanentMoverActionShiftRight
        elseif button == "RightButton" then
            actionKey = actionDb.permanentMoverActionRight
        end

        local action = actionKey and DF.PERM_MOVER_ACTIONS[actionKey]
        if action and action.fn then
            if InCombatLockdown() and not action.combatSafe then
                print("|cff00ff00DandersFrames:|r " .. L["Cannot use this action in combat."])
                return
            end
            action.fn(mode, self)
        end
    end)

    if isRaid then
        DF.permanentRaidMover = handle
    else
        DF.permanentPartyMover = handle
    end

    -- Create roster/login event frame for re-anchoring (once, shared)
    -- Combat state is handled by Core.lua's PLAYER_REGEN events
    if not DF.permanentMoverEventFrame then
        DF.permanentMoverEventFrame = CreateFrame("Frame")
        DF.permanentMoverEventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
        DF.permanentMoverEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        DF.permanentMoverEventFrame:SetScript("OnEvent", function(_, event)
            DF:Debug("POSITION", "Mover event: %s — scheduling anchor update in 0.2s", event)
            C_Timer.After(0.2, function()
                DF:UpdatePermanentMoverAnchor("party")
                DF:UpdatePermanentMoverAnchor("raid")
            end)
        end)
    end

    -- Apply anchor and visibility
    DF:UpdatePermanentMoverAnchor(mode)
    DF:UpdatePermanentMoverVisibility()
end

function DF:UpdatePermanentMoverDots(handle)
    if not handle then return end
    local w, h = handle:GetSize()

    -- Hide all existing dots first
    for _, dot in ipairs(handle.dots) do
        dot:Hide()
    end

    -- Calculate grid: 6px spacing between dots, 4px padding from edges
    local padding = 4
    local spacing = 6
    local cols = math.max(1, math.floor((w - padding * 2) / spacing) + 1)
    local rows = math.max(1, math.floor((h - padding * 2) / spacing) + 1)
    local totalNeeded = cols * rows

    -- Create more dot textures if needed
    while #handle.dots < totalNeeded do
        local dot = handle:CreateTexture(nil, "OVERLAY")
        dot:SetSize(2, 2)
        dot:SetColorTexture(1, 1, 1, 0.6)
        handle.dots[#handle.dots + 1] = dot
    end

    -- Position and show dots in a tiled grid, centered in the handle
    local gridW = (cols - 1) * spacing
    local gridH = (rows - 1) * spacing
    local startX = -gridW / 2
    local startY = -gridH / 2
    local idx = 0
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            idx = idx + 1
            local dot = handle.dots[idx]
            dot:ClearAllPoints()
            dot:SetPoint("CENTER", handle, "CENTER", startX + col * spacing, startY + row * spacing)
            dot:Show()
        end
    end
end

function DF:UpdatePermanentMoverSize(mode)
    local isRaid = (mode == "raid")
    local handle = isRaid and DF.permanentRaidMover or DF.permanentPartyMover
    if not handle then return end

    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    handle:SetSize(db.permanentMoverWidth or 20, db.permanentMoverHeight or 20)
    DF:UpdatePermanentMoverDots(handle)
end

function DF:UpdatePermanentMoverColor(mode)
    local isRaid = (mode == "raid")
    local handle = isRaid and DF.permanentRaidMover or DF.permanentPartyMover
    if not handle then return end

    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    local color = db.permanentMoverColor or {r = 0.45, g = 0.45, b = 0.95}
    handle.accentR, handle.accentG, handle.accentB = color.r, color.g, color.b
    handle.ApplyHandleColors(false)
end

function DF:GetPermanentMoverAttachFrame(mode)
    local isRaid = (mode == "raid")
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    local attachTo = db.permanentMoverAttachTo or "CONTAINER"
    local inTestMode = isRaid and DF.raidTestMode or DF.testMode

    if attachTo == "CONTAINER" then
        if inTestMode then
            return isRaid and DF.testRaidContainer or DF.testPartyContainer
                or isRaid and DF.raidContainer or DF.container
        end
        return isRaid and DF.raidContainer or DF.container
    end

    -- Find first or last visible unit frame, respecting sort order
    local targetFrame
    if inTestMode then
        -- Use test mode frames
        local frames = isRaid and DF.testRaidFrames or DF.testPartyFrames
        if frames then
            for i = 1, #frames do
                local frame = frames[i]
                if frame and frame:IsShown() then
                    if attachTo == "FIRST" and not targetFrame then
                        targetFrame = frame
                    end
                    if attachTo == "LAST" then
                        targetFrame = frame
                    end
                end
            end
        end
    else
        -- Determine first/last by actual screen position
        -- This works regardless of sorting system, data order, or secure handler state
        local candidates = {}
        local iterateFunc = function(frame)
            if frame and frame:IsShown() and frame:GetLeft() then
                candidates[#candidates + 1] = frame
            end
        end

        if isRaid then
            DF:IterateRaidFrames(iterateFunc)
        else
            local playerFrame = DF:GetPlayerFrame()
            if playerFrame then iterateFunc(playerFrame) end
            for i = 1, 4 do
                local frame = DF:GetPartyFrame(i)
                if frame then iterateFunc(frame) end
            end
        end

        if #candidates > 0 then
            -- Sort by visual position: primary axis depends on grow direction
            -- Use top-left as origin: lowest top+left = first, highest = last
            -- For horizontal layouts: sort by left, then by top (descending)
            -- For vertical layouts: sort by top (descending = higher first), then by left
            local horizontal = (db.growDirection == "HORIZONTAL")
            table.sort(candidates, function(a, b)
                local aLeft, aTop = a:GetLeft(), a:GetTop()
                local bLeft, bTop = b:GetLeft(), b:GetTop()
                if horizontal then
                    if math.abs(aLeft - bLeft) > 1 then return aLeft < bLeft end
                    return aTop > bTop  -- higher = first
                else
                    if math.abs(aTop - bTop) > 1 then return aTop > bTop end
                    return aLeft < bLeft  -- further left = first
                end
            end)

            if attachTo == "FIRST" then
                targetFrame = candidates[1]
            else
                targetFrame = candidates[#candidates]
            end
        end
    end

    -- Fallback to container
    local fallback
    if inTestMode then
        fallback = isRaid and (DF.testRaidContainer or DF.raidContainer) or (DF.testPartyContainer or DF.container)
    else
        fallback = isRaid and DF.raidContainer or DF.container
    end
    return targetFrame or fallback
end

function DF:UpdatePermanentMoverAnchor(mode)
    local isRaid = (mode == "raid")
    local handle = isRaid and DF.permanentRaidMover or DF.permanentPartyMover
    if not handle then return end

    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    local anchor = db.permanentMoverAnchor or "TOPLEFT"
    local offsetX = db.permanentMoverOffsetX or 0
    local offsetY = db.permanentMoverOffsetY or 0
    local attachFrame = DF:GetPermanentMoverAttachFrame(mode)

    DF:Debug("POSITION", "UpdatePermanentMoverAnchor(%s): anchor=%s offset=%.0f,%.0f attachFrame=%s",
        mode, anchor, offsetX, offsetY, attachFrame and attachFrame:GetName() or "nil")

    handle:ClearAllPoints()
    handle:SetPoint(anchor, attachFrame, anchor, offsetX, offsetY)
end

function DF:UpdatePermanentMoverCombatState()
    local handles = {}
    if DF.permanentPartyMover then handles[#handles + 1] = { handle = DF.permanentPartyMover, db = DF:GetDB() } end
    if DF.permanentRaidMover then handles[#handles + 1] = { handle = DF.permanentRaidMover, db = DF:GetRaidDB() } end

    local inCombat = InCombatLockdown()

    for _, info in ipairs(handles) do
        local h, db = info.handle, info.db
        if not db.permanentMover then
            -- Not enabled, skip
        elseif db.permanentMoverHideInCombat then
            if inCombat then
                h.fadeIn:Stop()
                h.fadeOut:Stop()
                h:Hide()
            else
                h:Show()
                if db.permanentMoverShowOnHover then
                    h:SetAlpha(0)
                else
                    h:SetAlpha(1)
                end
                h.ApplyHandleColors(false)
            end
        else
            -- Visible in combat — hide, update colors, re-show to force redraw
            local wasShown = h:IsShown()
            if wasShown then h:Hide() end

            if inCombat and db.permanentMoverShowOnHover then
                h.fadeOut:Stop()
                h.fadeIn:Stop()
            end

            if inCombat then
                local cc = db.permanentMoverCombatColor or {r = 0.8, g = 0.15, b = 0.15}
                h:SetBackdropColor(cc.r, cc.g, cc.b, 0.7)
                h:SetBackdropBorderColor(cc.r, cc.g, cc.b, 1.0)
                if h.dots then
                    for _, dot in ipairs(h.dots) do
                        dot:SetColorTexture(1, 0.6, 0.6, 0.6)
                    end
                end
            else
                local r, g, b = h.accentR or 0.45, h.accentG or 0.45, h.accentB or 0.95
                local isHover = h:IsMouseOver()
                h:SetBackdropColor(r, g, b, isHover and 0.7 or 0.4)
                h:SetBackdropBorderColor(r, g, b, isHover and 1.0 or 0.7)
                if h.dots then
                    for _, dot in ipairs(h.dots) do
                        dot:SetColorTexture(1, 1, 1, 0.6)
                    end
                end
            end

            if wasShown then
                h:Show()
                if inCombat or not db.permanentMoverShowOnHover then
                    h:SetAlpha(1)
                elseif not h:IsMouseOver() then
                    h:SetAlpha(0)
                end
            end
        end
    end
end

function DF:UpdatePermanentMoverVisibility()
    local inCombat = InCombatLockdown()
    DF:Debug("POSITION", "UpdatePermanentMoverVisibility: combat=%s", tostring(inCombat))

    -- Party
    if DF.permanentPartyMover then
        local db = DF:GetDB()
        -- Show if enabled and locked, but hide if raid test mode is active
        local show = db.permanentMover and db.locked and not DF.raidTestMode and not IsInRaid()
        DF:Debug("POSITION", "  Party mover: enabled=%s locked=%s show=%s",
            tostring(db.permanentMover), tostring(db.locked), tostring(show))
        if show then
            if inCombat and db.permanentMoverHideInCombat then
                DF.permanentPartyMover:Hide()
            else
                DF.permanentPartyMover:Show()
                if db.permanentMoverShowOnHover and not DF.permanentPartyMover:IsMouseOver() then
                    DF.permanentPartyMover:SetAlpha(0)
                else
                    DF.permanentPartyMover:SetAlpha(1)
                end
                DF.permanentPartyMover.ApplyHandleColors(false)
            end
            DF.container:SetMovable(true)
        else
            DF.permanentPartyMover:Hide()
            if db.locked and not db.permanentMover then
                DF.container:SetMovable(false)
            end
        end
    end

    -- Raid
    if DF.permanentRaidMover and DF.raidContainer then
        local db = DF:GetRaidDB()
        local raidEnabled = db.permanentMover
        DF:Debug("POSITION", "  Raid mover: enabled=%s locked=%s inRaid=%s testMode=%s",
            tostring(raidEnabled), tostring(db.raidLocked), tostring(IsInRaid()), tostring(DF.raidTestMode))
        -- In raid test mode, also show if party mover is enabled
        if DF.raidTestMode and not raidEnabled then
            raidEnabled = DF:GetDB().permanentMover
        end
        -- Only show if in raid test mode or actually in a raid group
        local inRaid = IsInRaid() or DF.raidTestMode
        local show = raidEnabled and db.raidLocked and inRaid
        -- Hide if party test mode is active
        if DF.testMode then show = false end
        if show then
            if inCombat and db.permanentMoverHideInCombat then
                DF.permanentRaidMover:Hide()
            else
                DF.permanentRaidMover:Show()
                if db.permanentMoverShowOnHover and not DF.permanentRaidMover:IsMouseOver() then
                    DF.permanentRaidMover:SetAlpha(0)
                else
                    DF.permanentRaidMover:SetAlpha(1)
                end
                DF.permanentRaidMover.ApplyHandleColors(false)
            end
            DF.raidContainer:SetMovable(true)
        else
            DF.permanentRaidMover:Hide()
            if db.raidLocked and not db.permanentMover then
                DF.raidContainer:SetMovable(false)
            end
        end
    end
end

-- ============================================================
-- GRID OVERLAY
-- ============================================================

function DF:CreateGridOverlay()
    local grid = CreateFrame("Frame", "DandersFramesGrid", UIParent)
    grid:SetAllPoints(UIParent)
    grid:SetFrameStrata("BACKGROUND")
    grid:Hide()
    
    grid.lines = {}
    
    -- Create snap preview lines (shown during drag)
    local snapPreviewV = grid:CreateTexture(nil, "OVERLAY")
    snapPreviewV:SetColorTexture(1, 0.2, 0.2, 0.8)  -- Red color
    snapPreviewV:SetSize(3, GetScreenHeight())
    snapPreviewV:Hide()
    grid.snapPreviewV = snapPreviewV
    
    local snapPreviewH = grid:CreateTexture(nil, "OVERLAY")
    snapPreviewH:SetColorTexture(1, 0.2, 0.2, 0.8)  -- Red color
    snapPreviewH:SetSize(GetScreenWidth(), 3)
    snapPreviewH:Hide()
    grid.snapPreviewH = snapPreviewH
    
    local function CreateGridLines()
        -- Clear existing lines
        for _, line in ipairs(grid.lines) do
            line:Hide()
        end
        grid.lines = {}
        
        -- Get db based on current position panel mode
        local db
        if DF.positionPanelMode == "raid" then
            db = DF:GetRaidDB()
        else
            db = DF:GetDB()
        end
        local gridSize = db.gridSize or 20
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        local centerX, centerY = screenWidth / 2, screenHeight / 2
        
        -- Vertical lines (from center outward)
        local x = 0
        while x <= screenWidth / 2 do
            -- Right of center
            local lineR = grid:CreateTexture(nil, "BACKGROUND")
            lineR:SetColorTexture(1, 1, 1, x == 0 and 0.5 or 0.15)
            lineR:SetSize(x == 0 and 2 or 1, screenHeight)
            lineR:SetPoint("CENTER", grid, "CENTER", x, 0)
            table.insert(grid.lines, lineR)
            
            -- Left of center (skip 0 - already drawn)
            if x > 0 then
                local lineL = grid:CreateTexture(nil, "BACKGROUND")
                lineL:SetColorTexture(1, 1, 1, 0.15)
                lineL:SetSize(1, screenHeight)
                lineL:SetPoint("CENTER", grid, "CENTER", -x, 0)
                table.insert(grid.lines, lineL)
            end
            
            x = x + gridSize
        end
        
        -- Horizontal lines (from center outward)
        local y = 0
        while y <= screenHeight / 2 do
            -- Above center
            local lineT = grid:CreateTexture(nil, "BACKGROUND")
            lineT:SetColorTexture(1, 1, 1, y == 0 and 0.5 or 0.15)
            lineT:SetSize(screenWidth, y == 0 and 2 or 1)
            lineT:SetPoint("CENTER", grid, "CENTER", 0, y)
            table.insert(grid.lines, lineT)
            
            -- Below center (skip 0 - already drawn)
            if y > 0 then
                local lineB = grid:CreateTexture(nil, "BACKGROUND")
                lineB:SetColorTexture(1, 1, 1, 0.15)
                lineB:SetSize(screenWidth, 1)
                lineB:SetPoint("CENTER", grid, "CENTER", 0, -y)
                table.insert(grid.lines, lineB)
            end
            
            y = y + gridSize
        end
    end
    
    grid:SetScript("OnShow", CreateGridLines)
    grid.RefreshLines = CreateGridLines
    
    DF.gridFrame = grid
end

-- Calculate snap position and return the grid line positions for preview
function DF:CalculateSnapPreview(x, y, container)
    local db
    if DF.positionPanelMode == "raid" then
        db = DF:GetRaidDB()
    else
        db = DF:GetDB()
    end
    local gridSize = db.gridSize or 20
    local snapThreshold = gridSize / 2

    -- Get frame dimensions (account for scale — GetWidth/GetHeight return logical size)
    local frameScale = container:GetScale() or 1
    local frameWidth = container:GetWidth() * frameScale
    local frameHeight = container:GetHeight() * frameScale
    
    -- Calculate edges
    local leftEdge = x - frameWidth / 2
    local rightEdge = x + frameWidth / 2
    local topEdge = y + frameHeight / 2
    local bottomEdge = y - frameHeight / 2
    
    -- Find snap X
    local snapLineX = nil
    local centerSnapX = math.floor((x / gridSize) + 0.5) * gridSize
    local leftSnapX = math.floor((leftEdge / gridSize) + 0.5) * gridSize
    local rightSnapX = math.floor((rightEdge / gridSize) + 0.5) * gridSize
    
    local centerDistX = math.abs(x - centerSnapX)
    local leftDistX = math.abs(leftEdge - leftSnapX)
    local rightDistX = math.abs(rightEdge - rightSnapX)
    
    if centerDistX <= leftDistX and centerDistX <= rightDistX and centerDistX <= snapThreshold then
        snapLineX = centerSnapX
    elseif leftDistX <= rightDistX and leftDistX <= snapThreshold then
        snapLineX = leftSnapX
    elseif rightDistX <= snapThreshold then
        snapLineX = rightSnapX
    end
    
    -- Find snap Y
    local snapLineY = nil
    local centerSnapY = math.floor((y / gridSize) + 0.5) * gridSize
    local topSnapY = math.floor((topEdge / gridSize) + 0.5) * gridSize
    local bottomSnapY = math.floor((bottomEdge / gridSize) + 0.5) * gridSize
    
    local centerDistY = math.abs(y - centerSnapY)
    local topDistY = math.abs(topEdge - topSnapY)
    local bottomDistY = math.abs(bottomEdge - bottomSnapY)
    
    if centerDistY <= topDistY and centerDistY <= bottomDistY and centerDistY <= snapThreshold then
        snapLineY = centerSnapY
    elseif bottomDistY <= topDistY and bottomDistY <= snapThreshold then
        snapLineY = bottomSnapY
    elseif topDistY <= snapThreshold then
        snapLineY = topSnapY
    end
    
    return snapLineX, snapLineY
end

-- Update snap preview lines position
function DF:UpdateSnapPreview(container, overrideX, overrideY)
    if not DF.gridFrame or not DF.gridFrame:IsShown() then return end

    local x, y
    if overrideX and overrideY then
        -- Use caller-provided position (avoids GetCenter ambiguity on scaled frames)
        x, y = overrideX, overrideY
    else
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        local centerX, centerY = container:GetCenter()
        x = centerX - screenWidth / 2
        y = centerY - screenHeight / 2
    end

    local snapLineX, snapLineY = DF:CalculateSnapPreview(x, y, container)
    
    -- Update vertical preview line
    if snapLineX then
        DF.gridFrame.snapPreviewV:ClearAllPoints()
        DF.gridFrame.snapPreviewV:SetPoint("CENTER", DF.gridFrame, "CENTER", snapLineX, 0)
        DF.gridFrame.snapPreviewV:Show()
    else
        DF.gridFrame.snapPreviewV:Hide()
    end
    
    -- Update horizontal preview line
    if snapLineY then
        DF.gridFrame.snapPreviewH:ClearAllPoints()
        DF.gridFrame.snapPreviewH:SetPoint("CENTER", DF.gridFrame, "CENTER", 0, snapLineY)
        DF.gridFrame.snapPreviewH:Show()
    else
        DF.gridFrame.snapPreviewH:Hide()
    end
end

-- Hide snap preview lines
function DF:HideSnapPreview()
    if DF.gridFrame then
        if DF.gridFrame.snapPreviewV then DF.gridFrame.snapPreviewV:Hide() end
        if DF.gridFrame.snapPreviewH then DF.gridFrame.snapPreviewH:Hide() end
    end
end

function DF:SnapToGrid(x, y)
    -- Grid settings are party-wide; edge-snap container depends on mode.
    local db = DF:GetDB()
    local container
    if DF.positionPanelMode == "raid" then
        container = DF.raidContainer
    elseif DF.positionPanelMode == "personal" then
        container = DF.personalTargetedSpellsMover or DF.container
    elseif DF.positionPanelMode == "targetedList" then
        container = DF.targetedListMoverFrame or DF.container
    else
        container = DF.container
    end
    if not container then return x, y end
    local gridSize = db.gridSize or 20
    local snapThreshold = gridSize / 2

    -- Get frame dimensions for edge/center snapping (account for scale)
    local frameScale = container:GetScale() or 1
    local frameWidth = container:GetWidth() * frameScale
    local frameHeight = container:GetHeight() * frameScale
    
    -- Calculate edges and center positions relative to frame center
    local leftEdge = x - frameWidth / 2
    local rightEdge = x + frameWidth / 2
    local topEdge = y + frameHeight / 2
    local bottomEdge = y - frameHeight / 2
    
    -- Snap X (check center, left edge, right edge)
    local snappedX = x
    local centerSnapX = math.floor((x / gridSize) + 0.5) * gridSize
    local leftSnapX = math.floor((leftEdge / gridSize) + 0.5) * gridSize
    local rightSnapX = math.floor((rightEdge / gridSize) + 0.5) * gridSize
    
    -- Find closest snap point for X
    local centerDistX = math.abs(x - centerSnapX)
    local leftDistX = math.abs(leftEdge - leftSnapX)
    local rightDistX = math.abs(rightEdge - rightSnapX)
    
    if centerDistX <= leftDistX and centerDistX <= rightDistX and centerDistX <= snapThreshold then
        snappedX = centerSnapX
    elseif leftDistX <= rightDistX and leftDistX <= snapThreshold then
        snappedX = leftSnapX + frameWidth / 2
    elseif rightDistX <= snapThreshold then
        snappedX = rightSnapX - frameWidth / 2
    end
    
    -- Snap Y (check center, top edge, bottom edge)
    local snappedY = y
    local centerSnapY = math.floor((y / gridSize) + 0.5) * gridSize
    local topSnapY = math.floor((topEdge / gridSize) + 0.5) * gridSize
    local bottomSnapY = math.floor((bottomEdge / gridSize) + 0.5) * gridSize
    
    -- Find closest snap point for Y
    local centerDistY = math.abs(y - centerSnapY)
    local topDistY = math.abs(topEdge - topSnapY)
    local bottomDistY = math.abs(bottomEdge - bottomSnapY)
    
    if centerDistY <= topDistY and centerDistY <= bottomDistY and centerDistY <= snapThreshold then
        snappedY = centerSnapY
    elseif bottomDistY <= topDistY and bottomDistY <= snapThreshold then
        snappedY = bottomSnapY + frameHeight / 2
    elseif topDistY <= snapThreshold then
        snappedY = topSnapY - frameHeight / 2
    end
    
    return snappedX, snappedY
end

-- ============================================================
-- POSITION CONTROL PANEL (shared for party and raid)
-- ============================================================

function DF:CreatePositionPanel()
    -- Same color constants as main GUI
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08, a = 0.95}
    local C_ELEMENT    = {r = 0.18, g = 0.18, b = 0.18, a = 1}
    local C_BORDER     = {r = 0.25, g = 0.25, b = 0.25, a = 1}
    local C_ACCENT     = {r = 0.45, g = 0.45, b = 0.95, a = 1}  -- Purple-Blue (matches main GUI)
    local C_RAID       = {r = 1.0, g = 0.5, b = 0.2, a = 1}
    local C_HOVER      = {r = 0.22, g = 0.22, b = 0.22, a = 1}
    local C_TEXT       = {r = 0.9, g = 0.9, b = 0.9, a = 1}
    
    -- Theme color per mode. Raid uses a distinct color; everything
    -- else shares the party accent.
    local function GetAccentColor()
        local mode = GetPositionMode()
        if mode.useAccentColor == "raid" then return C_RAID end
        return C_ACCENT
    end

    -- Helper to get the correct DB based on mode (now delegates to
    -- the descriptor; retained for minimal-diff in the panel code).
    local function GetPositionDB()
        return GetPositionMode().getDB()
    end

    -- Helper to lock the correct frames based on mode. Personal and
    -- Targeted List don't have separate lock paths — they go through
    -- the regular LockFrames which also hides their movers.
    local function LockCurrentFrames()
        if DF.positionPanelMode == "raid" then
            DF:LockRaidFrames()
        else
            DF:LockFrames()
        end
    end
    
    local function CreateElementBackdrop(frame)
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        frame:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, C_ELEMENT.a)
        frame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    end
    
    -- Main panel - matches main GUI style
    local panel = CreateFrame("Frame", "DandersFramesPositionPanel", UIParent, "BackdropTemplate")
    panel:SetSize(300, 294)
    panel:SetPoint("TOP", UIParent, "TOP", 0, -50)
    panel:SetFrameStrata("FULLSCREEN_DIALOG")
    panel:SetFrameLevel(100)  -- High level to ensure it's on top
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, C_BACKGROUND.a)
    panel:SetBackdropBorderColor(0, 0, 0, 1)
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    
    -- Apply scale from settings when shown
    panel:SetScript("OnShow", function(self)
        local guiScale = DF.db and DF.db.party and DF.db.party.guiScale or 1.0
        self:SetScale(guiScale)
    end)
    
    -- Store for theme updates
    panel.themedElements = {}
    
    local function UpdateTheme()
        local c = GetAccentColor()
        for _, elem in ipairs(panel.themedElements) do
            if elem.UpdateThemeColor then
                elem:UpdateThemeColor(c)
            end
        end
        -- Update title text based on mode (read from descriptor)
        if panel.title then
            panel.title:SetText(GetPositionMode().title or "Position")
        end
    end
    panel.UpdateTheme = UpdateTheme
    
    -- Title (matches main GUI title style)
    local c = GetAccentColor()
    local title = panel:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("TOPLEFT", 15, -12)
    title:SetText("Position")
    title:SetTextColor(c.r, c.g, c.b)
    title.UpdateThemeColor = function(self, col) self:SetTextColor(col.r, col.g, col.b) end
    table.insert(panel.themedElements, title)
    panel.title = title
    
    -- Close button (simple X like main GUI)
    local closeBtn = CreateFrame("Button", nil, panel)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -8, -8)
    closeBtn:SetNormalFontObject("DFFontNormal")
    closeBtn:SetText("x")
    closeBtn:GetFontString():SetTextColor(0.6, 0.6, 0.6)
    closeBtn:SetScript("OnClick", function() LockCurrentFrames() end)
    closeBtn:SetScript("OnEnter", function(self) self:GetFontString():SetTextColor(1, 1, 1) end)
    closeBtn:SetScript("OnLeave", function(self) self:GetFontString():SetTextColor(0.6, 0.6, 0.6) end)
    
    -- X Position row
    local xLabel = panel:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    xLabel:SetPoint("TOPLEFT", 15, -40)
    xLabel:SetText("X Position")
    xLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    local xInput = CreateFrame("EditBox", nil, panel, "BackdropTemplate")
    xInput:SetSize(65, 22)
    xInput:SetPoint("TOPLEFT", 15, -56)
    CreateElementBackdrop(xInput)
    xInput:SetFontObject("DFFontHighlightSmall")
    xInput:SetJustifyH("CENTER")
    xInput:SetAutoFocus(false)
    xInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            local mode = GetPositionMode()
            local db = mode.getDB()
            if db then
                if mode.logWrites then
                    DF:LogRaidAnchorWrite("PositionPanel:xInput", val, db[mode.yField] or 0)
                end
                db[mode.xField] = val
                if mode.autoProfileX and DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                    DF.AutoProfilesUI:SetProfileSetting(mode.autoProfileX, val)
                    if DF.GUI and DF.GUI.UpdatePositionOverrideIndicator then
                        DF.GUI.UpdatePositionOverrideIndicator()
                    end
                end
                mode.apply()
            end
            -- Update override indicator in position panel
            if DF.positionPanel and DF.positionPanel.UpdatePositionOverride then
                DF.positionPanel.UpdatePositionOverride()
            end
        end
        self:ClearFocus()
    end)
    xInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    panel.xInput = xInput
    
    -- X Nudge buttons
    local xMinus = CreateFrame("Button", nil, panel, "BackdropTemplate")
    xMinus:SetSize(22, 22)
    xMinus:SetPoint("LEFT", xInput, "RIGHT", 4, 0)
    CreateElementBackdrop(xMinus)
    local xMinusTxt = xMinus:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    xMinusTxt:SetPoint("CENTER")
    xMinusTxt:SetText("<")
    xMinus:SetScript("OnClick", function() DF:NudgePosition(-1, 0) end)
    xMinus:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
    xMinus:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    local xPlus = CreateFrame("Button", nil, panel, "BackdropTemplate")
    xPlus:SetSize(22, 22)
    xPlus:SetPoint("LEFT", xMinus, "RIGHT", 2, 0)
    CreateElementBackdrop(xPlus)
    local xPlusTxt = xPlus:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    xPlusTxt:SetPoint("CENTER")
    xPlusTxt:SetText(">")
    xPlus:SetScript("OnClick", function() DF:NudgePosition(1, 0) end)
    xPlus:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
    xPlus:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Y Position row
    local yLabel = panel:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    yLabel:SetPoint("TOPLEFT", 160, -40)
    yLabel:SetText("Y Position")
    yLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    local yInput = CreateFrame("EditBox", nil, panel, "BackdropTemplate")
    yInput:SetSize(65, 22)
    yInput:SetPoint("TOPLEFT", 160, -56)
    CreateElementBackdrop(yInput)
    yInput:SetFontObject("DFFontHighlightSmall")
    yInput:SetJustifyH("CENTER")
    yInput:SetAutoFocus(false)
    yInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            local mode = GetPositionMode()
            local db = mode.getDB()
            if db then
                if mode.logWrites then
                    DF:LogRaidAnchorWrite("PositionPanel:yInput", db[mode.xField] or 0, val)
                end
                db[mode.yField] = val
                if mode.autoProfileY and DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
                    DF.AutoProfilesUI:SetProfileSetting(mode.autoProfileY, val)
                    if DF.GUI and DF.GUI.UpdatePositionOverrideIndicator then
                        DF.GUI.UpdatePositionOverrideIndicator()
                    end
                end
                mode.apply()
            end
            -- Update override indicator in position panel
            if DF.positionPanel and DF.positionPanel.UpdatePositionOverride then
                DF.positionPanel.UpdatePositionOverride()
            end
        end
        self:ClearFocus()
    end)
    yInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    panel.yInput = yInput
    
    -- Y Nudge buttons
    local yMinus = CreateFrame("Button", nil, panel, "BackdropTemplate")
    yMinus:SetSize(22, 22)
    yMinus:SetPoint("LEFT", yInput, "RIGHT", 4, 0)
    CreateElementBackdrop(yMinus)
    local yMinusTxt = yMinus:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    yMinusTxt:SetPoint("CENTER")
    yMinusTxt:SetText("v")
    yMinus:SetScript("OnClick", function() DF:NudgePosition(0, -1) end)
    yMinus:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
    yMinus:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    local yPlus = CreateFrame("Button", nil, panel, "BackdropTemplate")
    yPlus:SetSize(22, 22)
    yPlus:SetPoint("LEFT", yMinus, "RIGHT", 2, 0)
    CreateElementBackdrop(yPlus)
    local yPlusTxt = yPlus:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    yPlusTxt:SetPoint("CENTER")
    yPlusTxt:SetText("^")
    yPlus:SetScript("OnClick", function() DF:NudgePosition(0, 1) end)
    yPlus:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
    yPlus:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Position Override Row (visible when editing auto profile)
    local posOverrideRow = CreateFrame("Frame", nil, panel)
    posOverrideRow:SetSize(270, 20)
    posOverrideRow:SetPoint("TOPLEFT", 15, -82)
    posOverrideRow:Hide()
    panel.posOverrideRow = posOverrideRow
    
    local posOverrideStar = posOverrideRow:CreateTexture(nil, "OVERLAY")
    posOverrideStar:SetSize(12, 12)
    posOverrideStar:SetPoint("LEFT", 0, 0)
    posOverrideStar:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\star")
    posOverrideStar:SetVertexColor(1, 0.8, 0.2)
    
    local posOverrideText = posOverrideRow:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    posOverrideText:SetPoint("LEFT", posOverrideStar, "RIGHT", 4, 0)
    posOverrideText:SetText("Position Overridden")
    posOverrideText:SetTextColor(1, 0.8, 0.2)
    
    local posResetBtn = CreateFrame("Button", nil, posOverrideRow, "BackdropTemplate")
    posResetBtn:SetSize(70, 18)
    posResetBtn:SetPoint("LEFT", posOverrideText, "RIGHT", 8, 0)
    posResetBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    posResetBtn:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    posResetBtn:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    local posResetIcon = posResetBtn:CreateTexture(nil, "OVERLAY")
    posResetIcon:SetSize(10, 10)
    posResetIcon:SetPoint("LEFT", 4, 0)
    posResetIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\refresh")
    posResetIcon:SetVertexColor(0.6, 0.6, 0.6)
    
    local posResetText = posResetBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    posResetText:SetPoint("LEFT", posResetIcon, "RIGHT", 2, 0)
    posResetText:SetText("Reset")
    posResetText:SetTextColor(0.7, 0.7, 0.7)
    
    posResetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.8, 0.2, 1)
        posResetIcon:SetVertexColor(1, 0.8, 0.2)
        posResetText:SetTextColor(1, 0.8, 0.2)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reset Position to Global")
        GameTooltip:Show()
    end)
    posResetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        posResetIcon:SetVertexColor(0.6, 0.6, 0.6)
        posResetText:SetTextColor(0.7, 0.7, 0.7)
        GameTooltip:Hide()
    end)
    posResetBtn:SetScript("OnClick", function()
        if DF.AutoProfilesUI then
            -- Reset position overrides
            DF.AutoProfilesUI:ResetProfileSetting("raidAnchorX")
            DF.AutoProfilesUI:ResetProfileSetting("raidAnchorY")
            
            -- Get global values and apply them
            local globalX = DF.AutoProfilesUI:GetGlobalValue("raidAnchorX") or 0
            local globalY = DF.AutoProfilesUI:GetGlobalValue("raidAnchorY") or 0
            
            local db = GetPositionDB()
            DF:LogRaidAnchorWrite("PositionPanel:resetOverride", globalX, globalY)
            db.raidAnchorX = globalX
            db.raidAnchorY = globalY

            -- Update container position
            DF:UpdateRaidContainerPosition()
            
            -- Update position panel inputs
            DF:UpdatePositionPanel()
            
            -- Update position override indicator in main GUI
            if DF.GUI and DF.GUI.UpdatePositionOverrideIndicator then
                DF.GUI.UpdatePositionOverrideIndicator()
            end
        end
    end)
    
    -- Function to update position override visibility
    panel.UpdatePositionOverride = function()
        -- Debug mode shows indicator
        if DF.GUI and DF.GUI.IsOverrideDebugMode and DF.GUI.IsOverrideDebugMode() then
            posOverrideStar:Show()
            posOverrideText:SetText("Position (debug)")
            posResetBtn:Show()
            posOverrideRow:Show()
            return
        end
        
        if DF.positionPanelMode ~= "raid" then
            posOverrideRow:Hide()
            return
        end
        
        local AutoProfilesUI = DF.AutoProfilesUI
        if not AutoProfilesUI or not AutoProfilesUI:IsEditing() then
            posOverrideRow:Hide()
            return
        end
        
        -- Check if position is overridden
        local xOverridden = AutoProfilesUI:IsSettingOverridden("raidAnchorX")
        local yOverridden = AutoProfilesUI:IsSettingOverridden("raidAnchorY")
        
        if xOverridden or yOverridden then
            posOverrideText:SetText("Position Overridden")
            posOverrideRow:Show()
        else
            posOverrideRow:Hide()
        end
    end
    
    -- Snap to Grid checkbox
    local snapContainer = CreateFrame("Frame", nil, panel)
    snapContainer:SetSize(150, 24)
    snapContainer:SetPoint("TOPLEFT", 15, -108)
    
    local snapCheck = CreateFrame("CheckButton", nil, snapContainer, "BackdropTemplate")
    snapCheck:SetSize(18, 18)
    snapCheck:SetPoint("LEFT", 0, 0)
    CreateElementBackdrop(snapCheck)
    
    local snapCheckMark = snapCheck:CreateTexture(nil, "OVERLAY")
    snapCheckMark:SetTexture("Interface\\Buttons\\WHITE8x8")
    snapCheckMark:SetVertexColor(c.r, c.g, c.b)
    snapCheckMark:SetPoint("CENTER")
    snapCheckMark:SetSize(10, 10)
    snapCheck:SetCheckedTexture(snapCheckMark)
    snapCheck.checkMark = snapCheckMark
    snapCheck.UpdateThemeColor = function(self, col) self.checkMark:SetVertexColor(col.r, col.g, col.b) end
    table.insert(panel.themedElements, snapCheck)
    
    local snapLabel = snapContainer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    snapLabel:SetPoint("LEFT", snapCheck, "RIGHT", 8, 0)
    snapLabel:SetText("Snap to Grid")
    snapLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    snapCheck:SetScript("OnClick", function(self)
        local db = GetPositionDB()
        db.snapToGrid = self:GetChecked()
        if db.snapToGrid then
            if DF.gridFrame.RefreshLines then
                DF.gridFrame:Show()
                DF.gridFrame.RefreshLines()
            else
                DF.gridFrame:Show()
            end
        else
            DF.gridFrame:Hide()
            -- Hide snap preview lines when disabling
            DF:HideSnapPreview()
        end
    end)
    panel.snapCheck = snapCheck

    -- Hide Overlay checkbox
    local hideOverlayContainer = CreateFrame("Frame", nil, panel)
    hideOverlayContainer:SetSize(150, 24)
    hideOverlayContainer:SetPoint("TOPLEFT", 15, -134)

    local hideOverlayCheck = CreateFrame("CheckButton", nil, hideOverlayContainer, "BackdropTemplate")
    hideOverlayCheck:SetSize(18, 18)
    hideOverlayCheck:SetPoint("LEFT", 0, 0)
    CreateElementBackdrop(hideOverlayCheck)

    local hideOverlayCheckMark = hideOverlayCheck:CreateTexture(nil, "OVERLAY")
    hideOverlayCheckMark:SetTexture("Interface\\Buttons\\WHITE8x8")
    hideOverlayCheckMark:SetVertexColor(c.r, c.g, c.b)
    hideOverlayCheckMark:SetPoint("CENTER")
    hideOverlayCheckMark:SetSize(10, 10)
    hideOverlayCheck:SetCheckedTexture(hideOverlayCheckMark)
    hideOverlayCheck.checkMark = hideOverlayCheckMark
    hideOverlayCheck.UpdateThemeColor = function(self, col) self.checkMark:SetVertexColor(col.r, col.g, col.b) end
    table.insert(panel.themedElements, hideOverlayCheck)

    local hideOverlayLabel = hideOverlayContainer:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    hideOverlayLabel:SetPoint("LEFT", hideOverlayCheck, "RIGHT", 8, 0)
    hideOverlayLabel:SetText("Hide Drag Overlay")
    hideOverlayLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)

    hideOverlayCheck:SetScript("OnClick", function(self)
        DF.hideDragOverlay = self:GetChecked()
        -- Store on the party db (grid / overlay settings are party-wide)
        local partyDB = DF:GetDB()
        if partyDB then partyDB.hideDragOverlay = DF.hideDragOverlay end
        -- Apply alpha to whichever mover matches the current mode.
        local mover
        if DF.positionPanelMode == "raid" then
            mover = DF.raidMoverFrame
        elseif DF.positionPanelMode == "personal" then
            mover = DF.personalTargetedSpellsMover
        elseif DF.positionPanelMode == "targetedList" then
            mover = DF.targetedListMoverFrame
        else
            mover = DF.moverFrame
        end
        if mover then
            mover:SetAlpha(DF.hideDragOverlay and 0 or 1)
        end
    end)
    panel.hideOverlayCheck = hideOverlayCheck

    -- Grid Size slider (matches main GUI slider style)
    local gridLabel = panel:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    gridLabel:SetPoint("TOPLEFT", 15, -164)
    gridLabel:SetText("Grid Size")
    gridLabel:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    
    -- Track background
    local track = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    track:SetPoint("TOPLEFT", 15, -182)
    track:SetSize(200, 8)
    CreateElementBackdrop(track)
    
    -- Fill (colored portion)
    local fill = track:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", 1, 0)
    fill:SetHeight(6)
    fill:SetColorTexture(c.r, c.g, c.b, 0.8)
    
    -- Slider
    local slider = CreateFrame("Slider", nil, panel)
    slider:SetPoint("TOPLEFT", 15, -182)
    slider:SetSize(200, 8)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(10, 100)
    slider:SetValueStep(5)
    slider:SetObeyStepOnDrag(true)
    slider:SetHitRectInsets(-4, -4, -8, -8)
    
    -- Thumb
    local thumb = slider:CreateTexture(nil, "OVERLAY")
    thumb:SetSize(12, 16)
    thumb:SetColorTexture(c.r, c.g, c.b, 1)
    slider:SetThumbTexture(thumb)
    
    -- Theme update for slider
    local sliderTheme = {
        UpdateThemeColor = function(self, col)
            fill:SetColorTexture(col.r, col.g, col.b, 0.8)
            thumb:SetColorTexture(col.r, col.g, col.b, 1)
        end
    }
    table.insert(panel.themedElements, sliderTheme)
    
    -- Grid value input
    local gridInput = CreateFrame("EditBox", nil, panel, "BackdropTemplate")
    gridInput:SetPoint("LEFT", track, "RIGHT", 10, 0)
    gridInput:SetSize(50, 20)
    CreateElementBackdrop(gridInput)
    gridInput:SetFontObject("DFFontHighlightSmall")
    gridInput:SetJustifyH("CENTER")
    gridInput:SetAutoFocus(false)
    
    local function UpdateFill()
        local val = slider:GetValue()
        local pct = (val - 10) / 90
        fill:SetWidth(math.max(1, pct * 198))
    end
    
    slider:SetScript("OnValueChanged", function(self, val)
        gridInput:SetText(tostring(math.floor(val)))
        UpdateFill()
        local db = GetPositionDB()
        db.gridSize = math.floor(val)
        -- Refresh grid lines with new size
        if DF.gridFrame and DF.gridFrame:IsShown() and DF.gridFrame.RefreshLines then
            DF.gridFrame.RefreshLines()
        end
    end)
    
    gridInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val and val >= 10 and val <= 100 then
            slider:SetValue(val)
        end
        self:ClearFocus()
    end)
    gridInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    
    panel.gridSlider = slider
    panel.gridInput = gridInput
    
    -- Reset Position button
    local resetBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    resetBtn:SetSize(85, 26)
    resetBtn:SetPoint("BOTTOMLEFT", 15, 15)
    CreateElementBackdrop(resetBtn)
    local resetIcon = resetBtn:CreateTexture(nil, "OVERLAY")
    resetIcon:SetPoint("LEFT", 6, 0)
    resetIcon:SetSize(16, 16)
    resetIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\refresh")
    resetIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    local resetBtnText = resetBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    resetBtnText:SetPoint("LEFT", resetIcon, "RIGHT", 2, 0)
    resetBtnText:SetText("Reset")
    resetBtnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    resetBtn:SetScript("OnClick", function() DF:ResetPosition() end)
    resetBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
    resetBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Center button
    local centerBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    centerBtn:SetSize(85, 26)
    centerBtn:SetPoint("BOTTOM", 0, 15)
    CreateElementBackdrop(centerBtn)
    local centerBtnText = centerBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    centerBtnText:SetPoint("CENTER")
    centerBtnText:SetText("Center")
    centerBtnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    centerBtn:SetScript("OnClick", function() DF:CenterFrames() end)
    centerBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
    centerBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Lock button (matches main GUI button style)
    local lockBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    lockBtn:SetSize(85, 26)
    lockBtn:SetPoint("BOTTOMRIGHT", -15, 15)
    CreateElementBackdrop(lockBtn)
    local lockIcon = lockBtn:CreateTexture(nil, "OVERLAY")
    lockIcon:SetPoint("LEFT", 6, 0)
    lockIcon:SetSize(16, 16)
    lockIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\lock")
    lockIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    local lockBtnText = lockBtn:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    lockBtnText:SetPoint("LEFT", lockIcon, "RIGHT", 2, 0)
    lockBtnText:SetText("Lock")
    lockBtnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    lockBtn:SetScript("OnClick", function() LockCurrentFrames() end)
    lockBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(C_HOVER.r, C_HOVER.g, C_HOVER.b, 1) end)
    lockBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1) end)
    
    -- Apply initial theme
    UpdateTheme()
    
    DF.positionPanel = panel
end

function DF:UpdatePositionPanel()
    if not DF.positionPanel then return end

    local mode = GetPositionMode()
    local db = mode.getDB()
    if not db then return end

    local anchorX = db[mode.xField] or 0
    local anchorY = db[mode.yField] or 0

    DF.positionPanel.xInput:SetText(string.format("%.0f", anchorX))
    DF.positionPanel.yInput:SetText(string.format("%.0f", anchorY))

    -- Grid / snap / hideOverlay settings are party-wide and always
    -- read from the party db regardless of panel mode. Personal and
    -- Targeted List share the party profile's grid config.
    local partyDB = DF:GetDB()
    DF.positionPanel.snapCheck:SetChecked(partyDB.snapToGrid)
    DF.positionPanel.gridSlider:SetValue(partyDB.gridSize or 20)
    DF.positionPanel.gridInput:SetText(tostring(partyDB.gridSize or 20))
    if DF.positionPanel.hideOverlayCheck then
        DF.positionPanel.hideOverlayCheck:SetChecked(partyDB.hideDragOverlay or false)
    end

    -- Update position override indicator if editing profile
    if DF.positionPanel.UpdatePositionOverride then
        DF.positionPanel.UpdatePositionOverride()
    end
end

function DF:ResetPosition()
    if DF.positionPanelMode == "raid" then
        if DF.savedRaidPositionX and DF.savedRaidPositionY then
            local db = DF:GetRaidDB()
            DF:LogRaidAnchorWrite("ResetPosition:savedRaid", DF.savedRaidPositionX, DF.savedRaidPositionY)
            db.raidAnchorX = DF.savedRaidPositionX
            db.raidAnchorY = DF.savedRaidPositionY
            DF:UpdateRaidContainerPosition()
            DF:UpdatePositionPanel()
            print("|cff00ff00DandersFrames:|r " .. L["Raid position reset."])
        else
            print("|cffff0000DandersFrames:|r " .. L["No saved position to reset to."])
        end
    elseif DF.positionPanelMode == "party" or DF.positionPanelMode == nil then
        if DF.savedPositionX and DF.savedPositionY then
            local db = DF:GetDB()
            db.anchorX = DF.savedPositionX
            db.anchorY = DF.savedPositionY
            DF:UpdateContainerPosition()
            DF:UpdatePositionPanel()
            print("|cff00ff00DandersFrames:|r " .. L["Position reset."])
        else
            print("|cffff0000DandersFrames:|r " .. L["No saved position to reset to."])
        end
    else
        -- personal / targetedList: no "previous" saved state to
        -- revert to, so reset simply zeroes the position.
        local mode = GetPositionMode()
        local db = mode.getDB()
        if db then
            db[mode.xField] = 0
            db[mode.yField] = 0
            mode.apply()
            DF:UpdatePositionPanel()
        end
    end
end

function DF:NudgePosition(dx, dy)
    local mode = GetPositionMode()
    local db = mode.getDB()
    if not db then return end

    local newX = (db[mode.xField] or 0) + dx
    local newY = (db[mode.yField] or 0) + dy

    if mode.logWrites then
        DF:LogRaidAnchorWrite("NudgePosition", newX, newY)
    end

    db[mode.xField] = newX
    db[mode.yField] = newY

    -- Auto-profile override tracking (currently only raid mode uses this)
    if mode.autoProfileX and DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
        DF.AutoProfilesUI:SetProfileSetting(mode.autoProfileX, newX)
        DF.AutoProfilesUI:SetProfileSetting(mode.autoProfileY, newY)
        if DF.GUI and DF.GUI.UpdatePositionOverrideIndicator then
            DF.GUI.UpdatePositionOverrideIndicator()
        end
    end

    mode.apply()
    DF:UpdatePositionPanel()
end

function DF:CenterFrames()
    -- Personal / targetedList: simple reset to 0,0 since these don't
    -- have growth geometry to account for.
    if DF.positionPanelMode == "personal" or DF.positionPanelMode == "targetedList" then
        local mode = GetPositionMode()
        local db = mode.getDB()
        if db then
            db[mode.xField] = 0
            db[mode.yField] = 0
            mode.apply()
            DF:UpdatePositionPanel()
        end
        return
    end
    if DF.positionPanelMode == "raid" then
        local db = DF:GetRaidDB()
        DF:LogRaidAnchorWrite("CenterFrames", 0, 0)
        db.raidAnchorX = 0
        db.raidAnchorY = 0
        -- If editing profile, save as override
        if DF.AutoProfilesUI and DF.AutoProfilesUI:IsEditing() then
            DF.AutoProfilesUI:SetProfileSetting("raidAnchorX", 0)
            DF.AutoProfilesUI:SetProfileSetting("raidAnchorY", 0)
            if DF.GUI and DF.GUI.UpdatePositionOverrideIndicator then
                DF.GUI.UpdatePositionOverrideIndicator()
            end
        end
        DF:UpdateRaidContainerPosition()
        DF:UpdatePositionPanel()
        print("|cff00ff00DandersFrames:|r " .. L["Raid frames centered."])
    else
        local db = DF:GetDB()
        local horizontal = db.growDirection == "HORIZONTAL"
        local growthAnchor = db.growthAnchor or "START"
        local spacing = db.frameSpacing or 4
        
        -- Calculate full 5-frame size
        local frameCount = 5
        local totalWidth = frameCount * (db.frameWidth + spacing) - spacing
        local totalHeight = frameCount * (db.frameHeight + spacing) - spacing
        
        -- Calculate offset needed to visually center the frames
        -- The container anchor point is at CENTER of UIParent
        -- We need to offset the container so the visual center of frames is at screen center
        local offsetX, offsetY = 0, 0
        
        if horizontal then
            -- For horizontal layout, adjust X based on growth anchor
            if growthAnchor == "START" then
                -- Anchor is at left edge, frames grow right
                -- Visual center is at anchor + totalWidth/2
                -- To center: anchor needs to be at -totalWidth/2
                offsetX = -totalWidth / 2
            elseif growthAnchor == "CENTER" then
                -- Anchor is already at center of frames
                offsetX = 0
            elseif growthAnchor == "END" then
                -- Anchor is at right edge, frames grow left
                -- Visual center is at anchor - totalWidth/2
                -- To center: anchor needs to be at +totalWidth/2
                offsetX = totalWidth / 2
            end
            offsetY = 0
        else
            -- For vertical layout, adjust Y based on growth anchor
            if growthAnchor == "START" then
                -- Anchor is at top edge, frames grow down
                -- Visual center is at anchor - totalHeight/2
                -- To center: anchor needs to be at +totalHeight/2
                offsetY = totalHeight / 2
            elseif growthAnchor == "CENTER" then
                -- Anchor is already at center of frames
                offsetY = 0
            elseif growthAnchor == "END" then
                -- Anchor is at bottom edge, frames grow up
                -- Visual center is at anchor + totalHeight/2
                -- To center: anchor needs to be at -totalHeight/2
                offsetY = -totalHeight / 2
            end
            offsetX = 0
        end
        
        db.anchorX = offsetX
        db.anchorY = offsetY
        DF:UpdateContainerPosition()
        DF:UpdatePositionPanel()
        DF:UpdateAllFrames()
        
        print("|cff00ff00DandersFrames:|r " .. L["Frames centered on screen."])
    end
end

function DF:UpdateContainerPosition()
    local db = DF:GetDB()
    local x, y = db.anchorX or 0, db.anchorY or 0
    local scale = db.frameScale or 1.0

    DF.container:SetScale(scale)
    DF.container:ClearAllPoints()
    DF.container:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)

    -- Also update mover if visible (use SetAllPoints to preserve size)
    -- Mover is a child of container, inherits scale automatically
    if DF.moverFrame and DF.moverFrame:IsShown() then
        DF.moverFrame:ClearAllPoints()
        DF.moverFrame:SetAllPoints(DF.container)
    end

    -- Also update test container if visible
    if DF.testPartyContainer then
        DF.testPartyContainer:SetScale(scale)
        DF.testPartyContainer:ClearAllPoints()
        DF.testPartyContainer:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)
    end
end

function DF:UpdateRaidContainerPosition()
    if not DF.raidContainer then return end
    if InCombatLockdown() then return end

    local db = DF:GetRaidDB()
    local x, y = db.raidAnchorX or 0, db.raidAnchorY or 0
    local scale = db.frameScale or 1.0

    if DF.Debug then
        DF:Debug("RAIDPOS", "UpdateRaidContainerPosition @ %s : applying (%.1f,%.1f) scale=%.3f combat=%s",
            ShortCaller(3), x, y, scale, tostring(InCombatLockdown()))
    end

    DF.raidContainer:SetScale(scale)
    DF.raidContainer:ClearAllPoints()
    DF.raidContainer:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)

    -- Also update mover if visible
    -- Raid mover is parented to UIParent, needs explicit scale + compensation
    if DF.raidMoverFrame and DF.raidMoverFrame:IsShown() then
        DF.raidMoverFrame:SetScale(scale)
        DF.raidMoverFrame:ClearAllPoints()
        DF.raidMoverFrame:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)
    end

    -- Also update test container if visible
    if DF.testRaidContainer then
        DF.testRaidContainer:SetScale(scale)
        DF.testRaidContainer:ClearAllPoints()
        DF.testRaidContainer:SetPoint("CENTER", UIParent, "CENTER", x / scale, y / scale)
    end
end

function DF:UnlockFrames()
    if InCombatLockdown() then
        print("|cffff0000DandersFrames:|r " .. L["Cannot unlock frames during combat."])
        return
    end

    local db = DF:GetDB()

    -- Ensure container exists
    if not DF.container then
        print("|cffff0000DandersFrames:|r " .. L["Cannot unlock - container doesn't exist!"])
        return
    end

    -- Ensure mover frame exists (create if needed)
    if not DF.moverFrame then
        DF:CreateMoverFrame()
    end

    -- Safety check - if mover still doesn't exist, abort
    if not DF.moverFrame then
        print("|cffff0000DandersFrames:|r " .. L["Cannot unlock - failed to create mover frame!"])
        return
    end
    
    -- Save current position before making changes (for reset button)
    DF.savedPositionX = db.anchorX or 0
    DF.savedPositionY = db.anchorY or 0
    
    db.locked = false
    DF.positionPanelMode = "party"  -- Set mode for position panel
    DF.hideDragOverlay = db.hideDragOverlay or false
    
    local scale = db.frameScale or 1.0
    DF.container:SetScale(scale)

    -- Always use CENTER anchor for positioning
    db.anchorPoint = "CENTER"
    DF.container:ClearAllPoints()
    DF.container:SetPoint("CENTER", UIParent, "CENTER", (db.anchorX or 0) / scale, (db.anchorY or 0) / scale)
    DF.container:Show()  -- Ensure container is visible
    
    -- Ensure container has a reasonable size (might be 0 if headers haven't laid out yet)
    local cWidth, cHeight = DF.container:GetWidth(), DF.container:GetHeight()
    if cWidth < 50 or cHeight < 50 then
        -- Use fallback size based on settings
        local frameWidth = db.frameWidth or 100
        local frameHeight = db.frameHeight or 50
        local spacing = db.frameSpacing or 2
        local horizontal = (db.growDirection == "HORIZONTAL")
        
        if horizontal then
            DF.container:SetSize(5 * (frameWidth + spacing) - spacing, frameHeight)
        else
            DF.container:SetSize(frameWidth, 5 * (frameHeight + spacing) - spacing)
        end
        
        if DF.debugHeaders then
            print("|cFF00FF00[DF Position]|r Container size was too small, set fallback size")
        end
    end
    
    DF.container:SetMovable(true)
    
    -- Ensure mover frame matches container before showing
    DF.moverFrame:ClearAllPoints()
    DF.moverFrame:SetAllPoints(DF.container)
    DF.moverFrame:SetFrameStrata("TOOLTIP")  -- Very high strata to be above secure frames
    DF.moverFrame:SetFrameLevel(100)
    DF.moverFrame:SetAlpha(1)
    DF.moverFrame:Show()
    DF.moverFrame:Raise()

    -- Sync testPartyContainer to current position and size
    if DF.testPartyContainer then
        DF.testPartyContainer:SetScale(scale)
        DF.testPartyContainer:ClearAllPoints()
        DF.testPartyContainer:SetPoint("CENTER", UIParent, "CENTER", (db.anchorX or 0) / scale, (db.anchorY or 0) / scale)
        DF.testPartyContainer:SetSize(DF.container:GetSize())
    end
    
    -- Debug info
    if DF.debugHeaders then
        print("|cFF00FF00[DF Position]|r Unlock - container size:", DF.container:GetWidth(), "x", DF.container:GetHeight())
        print("|cFF00FF00[DF Position]|r Unlock - mover size:", DF.moverFrame:GetWidth(), "x", DF.moverFrame:GetHeight())
        print("|cFF00FF00[DF Position]|r Unlock - mover strata:", DF.moverFrame:GetFrameStrata())
    end
    
    -- Show personal targeted spells mover if enabled
    if db.personalTargetedSpellEnabled and DF.ShowPersonalTargetedSpellsMover then
        DF:ShowPersonalTargetedSpellsMover()
    end

    -- Show Targeted List mover if enabled
    if db.targetedListEnabled and DF.ShowTargetedListMover then
        DF:ShowTargetedListMover()
    end
    
    -- Always refresh grid state from db when unlocking
    if DF.gridFrame then
        if db.snapToGrid then
            -- Refresh grid lines to ensure they match current settings
            if DF.gridFrame.RefreshLines then
                DF.gridFrame:Show()
                DF.gridFrame.RefreshLines()
            else
                DF.gridFrame:Show()
            end
        else
            DF.gridFrame:Hide()
        end
    end
    
    -- Show position panel and update its values from db
    if DF.positionPanel then
        DF:UpdatePositionPanel()
        if DF.positionPanel.UpdateTheme then
            DF.positionPanel:UpdateTheme()
        end
        DF.positionPanel:Show()
    end
    
    -- Update Display tab button if it exists
    if DF.displayLockButton and DF.displayLockButton.Text then
        DF.displayLockButton.Text:SetText(L["Lock Frames"])
    end

    -- Enable test mode so user can position with full group visible
    DF:ShowTestFrames(true)

    -- Sync GUI toolbar buttons
    if DF.GUI then
        if DF.GUI.UpdateLockButtonState then DF.GUI.UpdateLockButtonState() end
        if DF.GUI.UpdateTestButtonState then DF.GUI.UpdateTestButtonState() end
    end

    -- Hide permanent mover while full overlay is active
    if DF.permanentPartyMover then DF.permanentPartyMover:Hide() end

    print("|cff00ff00DandersFrames:|r " .. L["Frames unlocked. Drag to move, right-click to lock."])
end

function DF:LockFrames()
    local db = DF:GetDB()
    db.locked = true
    DF.positionPanelMode = nil  -- Clear mode
    
    DF.moverFrame:Hide()

    -- Restore permanent mover visibility (keeps container movable if enabled)
    DF:UpdatePermanentMoverVisibility()

    -- Hide personal targeted spells mover
    if DF.HidePersonalTargetedSpellsMover then
        DF:HidePersonalTargetedSpellsMover()
    end

    -- Hide Targeted List mover
    if DF.HideTargetedListMover then
        DF:HideTargetedListMover()
    end
    
    -- Stop any OnUpdate for snap preview
    DF.moverFrame:SetScript("OnUpdate", nil)
    
    -- Hide snap preview lines
    DF:HideSnapPreview()
    
    -- Hide grid
    if DF.gridFrame then
        DF.gridFrame:Hide()
    end
    
    -- Hide position panel
    if DF.positionPanel then
        DF.positionPanel:Hide()
    end
    
    -- Update saved position for next unlock's reset button
    DF.savedPositionX = db.anchorX or 0
    DF.savedPositionY = db.anchorY or 0
    
    -- Update Display tab button if it exists
    if DF.displayLockButton and DF.displayLockButton.Text then
        DF.displayLockButton.Text:SetText(L["Unlock Frames"])
    end

    -- Sync GUI toolbar buttons
    if DF.GUI then
        if DF.GUI.UpdateLockButtonState then DF.GUI.UpdateLockButtonState() end
        if DF.GUI.UpdateTestButtonState then DF.GUI.UpdateTestButtonState() end
    end

    -- Disable test mode
    DF:HideTestFrames(true)

    print("|cff00ff00DandersFrames:|r " .. L["Frames locked."])
end

