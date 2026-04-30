local addonName, DF = ...

-- ============================================================
-- STATUS ICONS MODULE
-- Handles creation and updates for all status icons:
-- Summon, Resurrection, Phased, AFK, Vehicle, RaidRole (MT/MA)
-- ============================================================

-- Local caching of frequently used globals
local pairs, ipairs, type = pairs, ipairs, type
local UnitExists = UnitExists
local UnitIsAFK = UnitIsAFK
local UnitHasVehicleUI = UnitHasVehicleUI
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local GetRaidTargetIndex = GetRaidTargetIndex
local GetReadyCheckStatus = GetReadyCheckStatus
local GetPartyAssignment = GetPartyAssignment
local GetRaidRosterInfo = GetRaidRosterInfo
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame

-- Forward declarations for caches used in closures
local resCache = {}    -- unit -> 1 (casting) or timestamp (pending accept start time)

-- Secret value handling (Midnight-safe)
local issecretvalue = issecretvalue or function() return false end
local canaccessvalue = function(v)
    return v ~= nil and not issecretvalue(v)
end

-- ============================================================
-- ICON CREATION HELPER
-- Creates a standard status icon frame with optional text
-- ============================================================
local function CreateStatusIcon(parent, size)
    local icon = CreateFrame("Frame", nil, parent)
    icon:SetSize(size or 16, size or 16)
    icon:SetFrameLevel(parent:GetFrameLevel() + 5)
    icon:Hide()
    icon:SetIgnoreParentAlpha(true)

    icon.texture = icon:CreateTexture(nil, "OVERLAY")
    icon.texture:SetAllPoints()
    icon.texture:SetDrawLayer("OVERLAY", 6)
    
    -- Text fontstring for text mode
    icon.text = icon:CreateFontString(nil, "OVERLAY")
    DF:SafeSetFont(icon.text, nil, 10, "OUTLINE")
    icon.text:SetPoint("CENTER")
    icon.text:SetTextColor(1, 1, 1, 1)
    icon.text:Hide()
    
    return icon
end

-- Helper to show icon as text or texture
local function ShowIconAsText(icon, text, showText)
    if showText then
        icon.texture:Hide()
        icon.text:SetText(text)
        icon.text:Show()
    else
        icon.text:Hide()
        icon.texture:Show()
    end
end

-- ============================================================
-- CREATE ALL STATUS ICONS FOR A FRAME
-- Called from CreateFrameElementsExtended and CreateUnitFrame
-- ============================================================
function DF:CreateStatusIcons(frame)
    if not frame or not frame.contentOverlay then return end
    
    local overlay = frame.contentOverlay
    
    -- ========================================
    -- SUMMON ICON (incoming summon status)
    -- ========================================
    frame.summonIcon = CreateStatusIcon(overlay, 16)
    frame.summonIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.summonIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-SummonPending")
    frame.summonIcon.text:SetTextColor(0.6, 0.2, 1, 1)  -- Purple for summon
    
    -- ========================================
    -- RESURRECTION ICON (incoming res status)
    -- ========================================
    frame.resurrectionIcon = CreateStatusIcon(overlay, 16)
    frame.resurrectionIcon:SetPoint("CENTER", frame, "CENTER", 0, 10)
    frame.resurrectionIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
    frame.resurrectionIcon.text:SetTextColor(0.2, 1, 0.2, 1)  -- Green for res
    frame.resurrectionIcon.unitFrame = frame
    frame.resurrectionIcon:EnableMouse(true)
    if frame.resurrectionIcon.SetPropagateMouseMotion then
        frame.resurrectionIcon:SetPropagateMouseMotion(true)
    end
    if frame.resurrectionIcon.SetPropagateMouseClicks then
        frame.resurrectionIcon:SetPropagateMouseClicks(true)
    end
    if frame.resurrectionIcon.SetMouseClickEnabled then
        frame.resurrectionIcon:SetMouseClickEnabled(false)
    end
    frame.resurrectionIcon:SetScript("OnEnter", function(self)
        local db = DF:GetFrameDB(self.unitFrame)
        if not db or not db.tooltipResurrectionEnabled then return end
        local unit = self.unitFrame and self.unitFrame.unit
        local state = unit and resCache[unit]
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:ClearLines()
        if state == 1 then
            GameTooltip:AddLine("Resurrection Incoming", 0.2, 1, 0.2)
            GameTooltip:AddLine("A resurrection is being cast on this player.", 0.8, 0.8, 0.8, true)
        elseif type(state) == "number" then
            GameTooltip:AddLine("Resurrection Pending", 1, 1, 0)
            GameTooltip:AddLine("Waiting for this player to accept the resurrection.", 0.8, 0.8, 0.8, true)
        else
            GameTooltip:AddLine("Resurrection", 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    frame.resurrectionIcon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- ========================================
    -- PHASED ICON (unit is phased/different instance)
    -- ========================================
    frame.phasedIcon = CreateStatusIcon(overlay, 16)
    frame.phasedIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    frame.phasedIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
    frame.phasedIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
    frame.phasedIcon.text:SetTextColor(0.5, 0.5, 1, 1)  -- Blue-ish for phased
    
    -- ========================================
    -- AFK ICON (unit is away from keyboard)
    -- ========================================
    frame.afkIcon = CreateStatusIcon(overlay, 32)
    frame.afkIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.afkIcon.texture:SetTexture("Interface\\FriendsFrame\\StatusIcon-Away")
    DF:SafeSetFont(frame.afkIcon.text, nil, 12, "OUTLINE")
    frame.afkIcon.text:SetTextColor(1, 0.5, 0, 1)  -- Orange for AFK
    -- Timer text (separate from main text, shown below/after)
    frame.afkIcon.timerText = frame.afkIcon:CreateFontString(nil, "OVERLAY")
    DF:SafeSetFont(frame.afkIcon.timerText, nil, 10, "OUTLINE")
    frame.afkIcon.timerText:SetPoint("TOP", frame.afkIcon.text, "BOTTOM", 0, -1)
    frame.afkIcon.timerText:SetTextColor(1, 0.5, 0, 1)
    frame.afkIcon.timerText:Hide()
    
    -- ========================================
    -- VEHICLE ICON (unit in vehicle)
    -- ========================================
    frame.vehicleIcon = CreateStatusIcon(overlay, 16)
    frame.vehicleIcon:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    frame.vehicleIcon.texture:SetTexture("Interface\\Vehicles\\UI-Vehicles-Raid-Icon")
    frame.vehicleIcon.text:SetTextColor(0.4, 0.8, 1, 1)  -- Light blue for vehicle
    
    -- ========================================
    -- RAID ROLE ICON (Main Tank / Main Assist)
    -- ========================================
    frame.raidRoleIcon = CreateStatusIcon(overlay, 12)
    frame.raidRoleIcon:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, 2)
    frame.raidRoleIcon.text:SetTextColor(1, 1, 0, 1)  -- Yellow for raid role
    -- Texture set dynamically based on role
    
    -- ========================================
    -- CENTER STATUS ICON (DEPRECATED - backward compat)
    -- ========================================
    frame.centerStatusIcon = CreateStatusIcon(overlay, 16)
    frame.centerStatusIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
end

-- ============================================================
-- HELPER: Apply icon positioning from settings
-- ============================================================
local function ApplyIconSettings(icon, db, prefix)
    if not icon or not db then return end
    
    local scale = db[prefix .. "Scale"] or 1
    local anchor = db[prefix .. "Anchor"] or "CENTER"
    local x = db[prefix .. "X"] or 0
    local y = db[prefix .. "Y"] or 0
    local alpha = db[prefix .. "Alpha"] or 1
    local frameLevel = db[prefix .. "FrameLevel"] or 0
    
    icon:SetScale(scale)
    icon:ClearAllPoints()
    icon:SetPoint(anchor, icon:GetParent():GetParent(), anchor, x, y)
    icon:SetAlpha(alpha)
    
    if frameLevel > 0 then
        icon:SetFrameLevel(icon:GetParent():GetParent():GetFrameLevel() + frameLevel)
    end
    
    -- Apply status icon font settings to text
    if icon.text then
        local font = db.statusIconFont or "Fonts\\FRIZQT__.TTF"
        local fontSize = db.statusIconFontSize or 12
        local outline = db.statusIconFontOutline or "OUTLINE"
        
        -- Handle SHADOW and NONE outlines (WoW SetFont rejects "NONE")
        local actualOutline = outline
        if outline == "SHADOW" or outline == "NONE" then
            actualOutline = ""
        end
        
        -- Get font path from SharedMedia if available
        local fontPath = font
        if DF.GetFont then
            fontPath = DF:GetFont(font) or font
        end
        
        icon.text:SetFont(fontPath, fontSize, actualOutline)
        
        -- Apply shadow if needed
        if outline == "SHADOW" then
            local shadowX = db.fontShadowOffsetX or 1
            local shadowY = db.fontShadowOffsetY or -1
            local shadowColor = db.fontShadowColor or {r = 0, g = 0, b = 0, a = 1}
            icon.text:SetShadowOffset(shadowX, shadowY)
            icon.text:SetShadowColor(shadowColor.r or 0, shadowColor.g or 0, shadowColor.b or 0, shadowColor.a or 1)
        else
            icon.text:SetShadowOffset(0, 0)
        end
        
        -- Apply text color from settings
        local textColor = db[prefix .. "TextColor"]
        if textColor then
            icon.text:SetTextColor(textColor.r or 1, textColor.g or 1, textColor.b or 1, 1)
        end
    end
    
    -- Also apply to timer text if it exists (AFK icon)
    if icon.timerText then
        local font = db.statusIconFont or "Fonts\\FRIZQT__.TTF"
        local fontSize = (db.statusIconFontSize or 12) - 2  -- Slightly smaller for timer
        local outline = db.statusIconFontOutline or "OUTLINE"
        
        local actualOutline = outline
        if outline == "SHADOW" or outline == "NONE" then
            actualOutline = ""
        end

        local fontPath = font
        if DF.GetFont then
            fontPath = DF:GetFont(font) or font
        end

        icon.timerText:SetFont(fontPath, fontSize, actualOutline)
        
        if outline == "SHADOW" then
            local shadowX = db.fontShadowOffsetX or 1
            local shadowY = db.fontShadowOffsetY or -1
            local shadowColor = db.fontShadowColor or {r = 0, g = 0, b = 0, a = 1}
            icon.timerText:SetShadowOffset(shadowX, shadowY)
            icon.timerText:SetShadowColor(shadowColor.r or 0, shadowColor.g or 0, shadowColor.b or 0, shadowColor.a or 1)
        else
            icon.timerText:SetShadowOffset(0, 0)
        end
        
        -- Timer text uses same color as main text
        local textColor = db[prefix .. "TextColor"]
        if textColor then
            icon.timerText:SetTextColor(textColor.r or 1, textColor.g or 1, textColor.b or 1, 1)
        end
    end
end

-- ============================================================
-- UPDATE SUMMON ICON
-- Shows pending/accepted/declined summon status
-- ============================================================
function DF:UpdateSummonIcon(frame)
    if not frame or not frame.unit or not frame.summonIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.summonIconEnabled then
        frame.summonIcon:Hide()
        return
    end
    
    -- Hide in combat check
    if db.summonIconHideInCombat and InCombatLockdown() then
        frame.summonIcon:Hide()
        return
    end
    
    local unit = frame.unit
    local showIcon = false
    local texture = nil
    local statusText = nil

    -- If the unit no longer exists (player left group), clear the icon immediately
    if not UnitExists(unit) then
        frame.summonIcon:Hide()
        return
    end

    -- Solo players cannot be summoned; incoming-summon API may return stale data
    if not IsInGroup() then
        frame.summonIcon:Hide()
        return
    end

    -- Check for incoming summon (secret-safe)
    if C_IncomingSummon and C_IncomingSummon.HasIncomingSummon then
        local hasSummon = nil
        pcall(function()
            hasSummon = C_IncomingSummon.HasIncomingSummon(unit)
        end)
        
        if canaccessvalue(hasSummon) and hasSummon then
            local summonStatus = nil
            pcall(function()
                summonStatus = C_IncomingSummon.IncomingSummonStatus(unit)
            end)
            
            if canaccessvalue(summonStatus) then
                if summonStatus == Enum.SummonStatus.Pending then
                    texture = "Interface\\RaidFrame\\Raid-Icon-SummonPending"
                    statusText = db.summonIconTextPending or "Summon"
                    showIcon = true
                elseif summonStatus == Enum.SummonStatus.Accepted then
                    texture = "Interface\\RaidFrame\\Raid-Icon-SummonAccepted"
                    statusText = db.summonIconTextAccepted or "Accepted"
                    showIcon = true
                elseif summonStatus == Enum.SummonStatus.Declined then
                    texture = "Interface\\RaidFrame\\Raid-Icon-SummonDeclined"
                    statusText = db.summonIconTextDeclined or "Declined"
                    showIcon = true
                end
            end
        end
    end
    
    if showIcon then
        frame.summonIcon.texture:SetTexture(texture)
        frame.summonIcon.texture:SetTexCoord(0, 1, 0, 1)
        ApplyIconSettings(frame.summonIcon, db, "summonIcon")
        
        -- Show as text or icon based on setting
        ShowIconAsText(frame.summonIcon, statusText, db.summonIconShowText)
        frame.summonIcon:Show()
    else
        frame.summonIcon:Hide()
    end
end

-- ============================================================
-- UPDATE RESURRECTION ICON
-- Res icon states: green during cast, yellow
-- when cast finishes and unit still dead (pending accept).
-- Timer cleans up stale entries (unit alive, left group, or
-- pending accept expired after 60s - the WoW accept window).
-- ============================================================

local resTimer

local RES_ACCEPT_TIMEOUT = 60  -- WoW's res accept window is 60 seconds

local function ResTimerCleanup()
    local hasEntries = false
    local now = GetTime()
    for unit, value in next, resCache do
        if not (UnitExists(unit) and UnitIsDeadOrGhost(unit)) then
            -- Unit alive or gone, clear
            resCache[unit] = nil
            local frame = DF.unitFrameMap and DF.unitFrameMap[unit]
            if frame and frame.resurrectionIcon then
                frame.resurrectionIcon:Hide()
            end
        elseif value ~= 1 and (now - value) > RES_ACCEPT_TIMEOUT then
            -- Pending accept expired (cancelled cast or they didn't accept in time)
            resCache[unit] = nil
            local frame = DF.unitFrameMap and DF.unitFrameMap[unit]
            if frame and frame.resurrectionIcon then
                frame.resurrectionIcon:Hide()
            end
        else
            hasEntries = true
        end
    end
    if not hasEntries and resTimer then
        resTimer:Cancel()
        resTimer = nil
    end
end

function DF:UpdateResurrectionIcon(frame)
    if not frame or not frame.unit or not frame.resurrectionIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    if not db.resurrectionIconEnabled then
        frame.resurrectionIcon:Hide()
        return
    end
    
    local unit = frame.unit
    
    -- Only process if unit is dead/ghost
    if UnitIsDeadOrGhost(unit) then
        if UnitHasIncomingResurrection(unit) then
            -- Cast in progress → green
            if resCache[unit] ~= 1 then
                resCache[unit] = 1
                resTimer = resTimer or C_Timer.NewTicker(0.25, ResTimerCleanup)
            end
            frame.resurrectionIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            frame.resurrectionIcon.texture:SetVertexColor(0, 1, 0, 1)
            ApplyIconSettings(frame.resurrectionIcon, db, "resurrectionIcon")
            frame.resurrectionIcon:Show()
            return
        elseif resCache[unit] == 1 then
            -- Was casting, now stopped → pending accept (yellow)
            -- Store timestamp so we can expire after 60s
            resCache[unit] = GetTime()
            frame.resurrectionIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            frame.resurrectionIcon.texture:SetVertexColor(1, 1, 0, 0.75)
            ApplyIconSettings(frame.resurrectionIcon, db, "resurrectionIcon")
            frame.resurrectionIcon:Show()
            return
        elseif resCache[unit] and resCache[unit] ~= 1 then
            -- Still showing pending accept (check not expired)
            if (GetTime() - resCache[unit]) <= RES_ACCEPT_TIMEOUT then
                frame.resurrectionIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
                frame.resurrectionIcon.texture:SetVertexColor(1, 1, 0, 0.75)
                ApplyIconSettings(frame.resurrectionIcon, db, "resurrectionIcon")
                frame.resurrectionIcon:Show()
                return
            else
                resCache[unit] = nil
            end
        end
    else
        -- Unit is alive, clear any cache
        resCache[unit] = nil
    end
    
    frame.resurrectionIcon:Hide()
end

function DF:ClearResurrectionCache(unit)
    if unit then resCache[unit] = nil end
end

function DF:HasPendingResurrection(unit)
    return resCache[unit] ~= nil
end

-- ============================================================
-- PHASED ICON (Grid2-style cached polling + event-driven)
-- ============================================================
-- UnitPhaseReason() only returns reliable results within ~250 yards.
-- Beyond that it returns nil, which looks like "not phased".
-- Grid2 solves this with:
--   1. A per-unit cache (avoids redundant indicator updates)
--   2. A 1-second polling timer with UnitDistanceSquared gating
--   3. Events (UNIT_PHASE etc.) for instant updates when they fire
-- We follow the same approach, with one difference:
-- Grid2 stops the timer inside instances; we keep it running but skip
-- distance gating, so UnitInOtherParty and UnitPhaseReason still poll.
-- CheckUnitPhase checks UnitInOtherParty first (returns -1 for LFG),
-- then UnitPhaseReason/UnitInPhase for actual phasing.
-- ============================================================

local UnitDistanceSquared = UnitDistanceSquared
local UnitInOtherParty = UnitInOtherParty
local UnitPhaseReason = UnitPhaseReason
local UnitInPhase = UnitInPhase
local IsInInstance = IsInInstance

-- Cache tables (keyed by unit token, e.g. "raid1", "party2")
-- phasedCache[unit] = phaseReason number (phased), -1 (LFG), false (checked, not phased), or nil (not yet checked)
-- phasedRange[unit] = true if within 250yd, false/nil otherwise
local phasedCache = {}
local phasedRange = {}
local phasedTicker = nil
local phasedTimerRunning = false

-- Clear cache for a specific unit (call when unit leaves group or frame changes unit)
function DF:ResetPhasedCache(unit)
    if unit then
        phasedCache[unit] = nil  -- nil = not yet checked, will be re-evaluated
        phasedRange[unit] = nil
    end
end

-- Clear all phased caches (call on zone change, group change, etc.)
function DF:WipePhasedCache()
    wipe(phasedCache)
    wipe(phasedRange)
end

-- Check phase status for a single unit and update cache.
-- Checks UnitInOtherParty (LFG/-1), then UnitPhaseReason/UnitInPhase.
-- Returns true if the cached value changed.
local function CheckUnitPhase(unit)
    local phased = false  -- false = checked, not phased (distinct from nil = not yet checked)
    
    -- Check LFG/other party first (unit in different instance group)
    -- This covers the case where UnitPhaseReason returns nil because the unit
    -- is in a completely different instance, not just a different "phase"
    if UnitInOtherParty then
        local ok, inOther = pcall(UnitInOtherParty, unit)
        if ok and canaccessvalue(inOther) and inOther then
            phased = -1
        end
    end
    
    -- If not in other party, check phase status
    if phased == false then
        if UnitPhaseReason then
            local ok, result = pcall(UnitPhaseReason, unit)
            if ok and canaccessvalue(result) and result then
                phased = result
            end
        elseif UnitInPhase then
            local ok, result = pcall(UnitInPhase, unit)
            if ok and canaccessvalue(result) and not result then
                phased = true  -- UnitInPhase returns false when phased
            end
        end
    end
    
    -- phased is false if not phased, or a truthy value if phased
    if phased ~= phasedCache[unit] then
        phasedCache[unit] = phased
        return true
    end
    return false
end

-- Event-driven update for a single unit (called from UNIT_PHASE, UNIT_FLAGS,
-- UNIT_OTHER_PARTY_CHANGED). Updates cache and refreshes the icon if changed.
function DF:UpdatePhasedCacheForUnit(unit)
    if not unit then return end
    if CheckUnitPhase(unit) then
        -- Cache changed — find and update the frame
        local frame = DF.unitFrameMap and DF.unitFrameMap[unit]
        if frame and frame.phasedIcon and frame.dfEventsEnabled ~= false then
            DF:UpdatePhasedIcon(frame)
        end
    end
end

-- Polling timer callback — iterates all grouped units (Grid2 style).
-- In the open world, uses UnitDistanceSquared gating for UnitPhaseReason reliability.
-- Inside instances, still polls (without distance gating) so UnitInOtherParty is caught.
local function PhasedTimerUpdate()
    if not DF.IterateAllFrames then return end
    
    local inInstance = IsInInstance()
    
    DF:IterateAllFrames(function(frame)
        if not frame or not frame:IsShown() or not frame.unit or not frame.phasedIcon then return end
        local unit = frame.unit
        
        if inInstance then
            -- Inside instances: UnitDistanceSquared returns nil, skip distance gating.
            -- Still check phase status directly — catches UnitInOtherParty and
            -- UnitPhaseReason for units that may be in different phases/instances.
            if CheckUnitPhase(unit) then
                DF:UpdatePhasedIcon(frame)
            end
        else
            -- Open world: use distance gating for UnitPhaseReason reliability
            -- (UnitPhaseReason only works within ~250 yards)
            local ok, distSq, valid = pcall(function()
                return UnitDistanceSquared(unit)
            end)
            if ok and valid and canaccessvalue(distSq) then
                local inrange = distSq < 62500  -- 250*250
                if inrange ~= phasedRange[unit] then
                    phasedRange[unit] = inrange
                    -- Range changed — re-evaluate phase
                    if CheckUnitPhase(unit) then
                        DF:UpdatePhasedIcon(frame)
                    end
                end
            else
                -- UnitDistanceSquared not valid (too far, not in group, cross-realm)
                -- Fall back to direct phase check without distance gating
                if CheckUnitPhase(unit) then
                    DF:UpdatePhasedIcon(frame)
                end
            end
        end
    end)
end

-- Start the phased polling timer
function DF:StartPhasedTimer()
    if phasedTimerRunning then return end
    phasedTicker = C_Timer.NewTicker(1, PhasedTimerUpdate)
    phasedTimerRunning = true
end

-- Stop the phased polling timer
function DF:StopPhasedTimer()
    if phasedTicker then
        phasedTicker:Cancel()
        phasedTicker = nil
    end
    phasedTimerRunning = false
    wipe(phasedCache)
    wipe(phasedRange)
end

-- Auto-start when addon is ready (called from PLAYER_LOGIN or first group join)
-- We start it once and let it run — the callback is cheap when solo/not in group.
local phasedTimerStartFrame = CreateFrame("Frame")
phasedTimerStartFrame:RegisterEvent("PLAYER_LOGIN")
phasedTimerStartFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
phasedTimerStartFrame:SetScript("OnEvent", function(self, event)
    if not phasedTimerRunning and DF.StartPhasedTimer then
        DF:StartPhasedTimer()
        -- Timer is running, no need to listen for more events
        self:UnregisterAllEvents()
    end
end)

-- ============================================================
-- UPDATE PHASED ICON (reads from cache, updates visuals)
-- Called from: event handlers, polling timer, FullFrameRefresh
-- ============================================================
function DF:UpdatePhasedIcon(frame)
    if not frame or not frame.unit or not frame.phasedIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.phasedIconEnabled then
        frame.phasedIcon:Hide()
        return
    end
    
    -- Hide in combat check
    if db.phasedIconHideInCombat and InCombatLockdown() then
        frame.phasedIcon:Hide()
        return
    end
    
    local unit = frame.unit
    
    -- Populate cache on first access for this unit (e.g., from FullFrameRefresh).
    -- Without this, the cache is empty until the polling timer runs (up to 1 second)
    -- and the icon would never show on initial frame creation.
    if phasedCache[unit] == nil and UnitExists(unit) then
        CheckUnitPhase(unit)
    end
    
    local cached = phasedCache[unit]
    
    if cached then
        -- cached == -1 means LFG (other party), anything else means phased
        local isLFG = (cached == -1)
        if isLFG and db.phasedIconShowLFGEye then
            frame.phasedIcon.texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            frame.phasedIcon.texture:SetTexCoord(0.14, 0.235, 0.28, 0.47)
        else
            frame.phasedIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
            frame.phasedIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
        end
        ApplyIconSettings(frame.phasedIcon, db, "phasedIcon")
        ShowIconAsText(frame.phasedIcon, db.phasedIconText or "Phased", db.phasedIconShowText)
        frame.phasedIcon:Show()
    else
        frame.phasedIcon:Hide()
    end
end

-- ============================================================
-- UPDATE AFK ICON
-- Shows when unit is AFK with optional timer
-- ============================================================

-- Cache for AFK start times (unit -> timestamp)
local afkStartTimes = {}

-- Format seconds as M:SS or H:MM:SS
local function FormatAFKTime(seconds)
    if seconds < 3600 then
        return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
    else
        local hours = math.floor(seconds / 3600)
        local mins = math.floor((seconds % 3600) / 60)
        local secs = seconds % 60
        return string.format("%d:%02d:%02d", hours, mins, secs)
    end
end

function DF:UpdateAFKIcon(frame)
    if not frame or not frame.unit or not frame.afkIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.afkIconEnabled then
        frame.afkIcon:Hide()
        if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
        return
    end
    
    -- Hide in combat check
    if db.afkIconHideInCombat and InCombatLockdown() then
        frame.afkIcon:Hide()
        if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
        return
    end
    
    local unit = frame.unit
    local showIcon = false
    local isDND = false

    -- Check AFK status (secret-safe)
    local isAFK = nil
    pcall(function()
        isAFK = UnitIsAFK(unit)
    end)

    if canaccessvalue(isAFK) and isAFK then
        -- Track AFK start time
        if not afkStartTimes[unit] then
            afkStartTimes[unit] = GetTime()
        end
        showIcon = true
    else
        -- Clear AFK start time
        afkStartTimes[unit] = nil
        -- AFK and DND are mutually exclusive; only check DND when not AFK
        local dndStatus = nil
        pcall(function()
            dndStatus = UnitIsDND(unit)
        end)
        if canaccessvalue(dndStatus) and dndStatus then
            isDND = true
            showIcon = true
        end
    end

    if showIcon then
        ApplyIconSettings(frame.afkIcon, db, "afkIcon")

        local L = DF.L
        local statusText
        if isDND then
            statusText = L["DND"]
            -- Red-ish for DND to visually distinguish from orange AFK
            frame.afkIcon.text:SetTextColor(1, 0.2, 0.2, 1)
            if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
        else
            statusText = db.afkIconText or "AFK"
            -- Restore AFK's orange color (may have been overridden by DND branch)
            frame.afkIcon.text:SetTextColor(1, 0.5, 0, 1)
            local showTimer = db.afkIconShowTimer ~= false

            -- Calculate timer if enabled
            if showTimer and afkStartTimes[unit] then
                local elapsed = math.floor(GetTime() - afkStartTimes[unit])
                local timerStr = FormatAFKTime(elapsed)

                if db.afkIconShowText then
                    -- Text mode: show "AFK 1:23"
                    statusText = statusText .. " " .. timerStr
                    if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
                else
                    -- Icon mode: show timer below icon
                    if frame.afkIcon.timerText then
                        frame.afkIcon.timerText:SetText(timerStr)
                        frame.afkIcon.timerText:Show()
                    end
                end
            else
                if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
            end
        end

        ShowIconAsText(frame.afkIcon, statusText, db.afkIconShowText)
        frame.afkIcon:Show()
    else
        frame.afkIcon:Hide()
        if frame.afkIcon.timerText then frame.afkIcon.timerText:Hide() end
    end
end

-- Clear AFK cache for a unit
function DF:ClearAFKCache(unit)
    if unit then
        afkStartTimes[unit] = nil
    end
end

-- ============================================================
-- UPDATE VEHICLE ICON
-- Shows when unit is in a vehicle
-- ============================================================
function DF:UpdateVehicleIcon(frame)
    if not frame or not frame.unit or not frame.vehicleIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.vehicleIconEnabled then
        frame.vehicleIcon:Hide()
        return
    end
    
    -- Hide in combat check
    if db.vehicleIconHideInCombat and InCombatLockdown() then
        frame.vehicleIcon:Hide()
        return
    end
    
    local unit = frame.unit
    local showIcon = false
    
    -- Check vehicle status (secret-safe)
    local hasVehicle = nil
    pcall(function()
        hasVehicle = UnitHasVehicleUI(unit)
    end)
    
    if canaccessvalue(hasVehicle) and hasVehicle then
        showIcon = true
    end
    
    if showIcon then
        ApplyIconSettings(frame.vehicleIcon, db, "vehicleIcon")
        ShowIconAsText(frame.vehicleIcon, db.vehicleIconText or "Vehicle", db.vehicleIconShowText)
        frame.vehicleIcon:Show()
    else
        frame.vehicleIcon:Hide()
    end
end

-- ============================================================
-- UPDATE RAID ROLE ICON
-- Shows Main Tank / Main Assist assignment
-- ============================================================

-- Cache for raid role assignments (unit -> role string)
local raidRoleCache = {}

function DF:UpdateRaidRoleIcon(frame)
    if not frame or not frame.unit or not frame.raidRoleIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.raidRoleIconEnabled then
        frame.raidRoleIcon:Hide()
        return
    end
    
    -- Hide in combat check
    if db.raidRoleIconHideInCombat and InCombatLockdown() then
        frame.raidRoleIcon:Hide()
        return
    end
    
    local unit = frame.unit
    local showIcon = false
    local role = nil
    
    -- Check raid role assignment
    if IsInRaid() then
        -- Get raid index for unit
        for i = 1, 40 do
            local raidUnit = "raid" .. i
            if UnitExists(raidUnit) then
                local isSameUnit = nil
                pcall(function()
                    -- Use string comparison to avoid secret value issues
                    isSameUnit = (raidUnit == unit)
                end)
                
                if isSameUnit then
                    local _, _, _, _, _, _, _, _, _, raidRole = GetRaidRosterInfo(i)
                    if raidRole == "MAINTANK" and db.raidRoleIconShowTank then
                        role = "MAINTANK"
                        showIcon = true
                    elseif raidRole == "MAINASSIST" and db.raidRoleIconShowAssist then
                        role = "MAINASSIST"
                        showIcon = true
                    end
                    break
                end
            end
        end
    else
        -- Party - check with GetPartyAssignment
        if GetPartyAssignment then
            local isTank = nil
            local isAssist = nil
            pcall(function()
                isTank = GetPartyAssignment("MAINTANK", unit)
                isAssist = GetPartyAssignment("MAINASSIST", unit)
            end)
            
            if canaccessvalue(isTank) and isTank and db.raidRoleIconShowTank then
                role = "MAINTANK"
                showIcon = true
            elseif canaccessvalue(isAssist) and isAssist and db.raidRoleIconShowAssist then
                role = "MAINASSIST"
                showIcon = true
            end
        end
    end
    
    if showIcon and role then
        local statusText = nil
        if role == "MAINTANK" then
            frame.raidRoleIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon")
            statusText = db.raidRoleIconTextTank or "MT"
        else
            frame.raidRoleIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
            statusText = db.raidRoleIconTextAssist or "MA"
        end
        frame.raidRoleIcon.texture:SetTexCoord(0, 1, 0, 1)
        ApplyIconSettings(frame.raidRoleIcon, db, "raidRoleIcon")
        ShowIconAsText(frame.raidRoleIcon, statusText, db.raidRoleIconShowText)
        frame.raidRoleIcon:Show()
    else
        frame.raidRoleIcon:Hide()
    end
end

-- ============================================================
-- UPDATE ALL STATUS ICONS FOR A FRAME
-- Convenience function to update all icons at once
-- ============================================================
function DF:UpdateAllStatusIcons(frame)
    if not frame then return end
    
    DF:UpdateSummonIcon(frame)
    DF:UpdateResurrectionIcon(frame)
    DF:UpdatePhasedIcon(frame)
    DF:UpdateAFKIcon(frame)
    DF:UpdateVehicleIcon(frame)
    DF:UpdateRaidRoleIcon(frame)
end

-- ============================================================
-- UPDATE STATUS ICONS ON ALL FRAMES
-- Called when text mode settings change
-- ============================================================
function DF:UpdateAllFramesStatusIcons()
    -- Update party frames
    if DF.partyHeader then
        local children = {DF.partyHeader:GetChildren()}
        for _, frame in pairs(children) do
            if frame.unit then
                DF:UpdateAllStatusIcons(frame)
            end
        end
    end
    
    -- Update raid frames
    for i = 1, 8 do
        local header = DF["raidGroup" .. i]
        if header then
            local children = {header:GetChildren()}
            for _, frame in pairs(children) do
                if frame.unit then
                    DF:UpdateAllStatusIcons(frame)
                end
            end
        end
    end
    
    -- Also refresh test frames if in test mode
    if DF.testMode or DF.raidTestMode then
        DF:RefreshTestFrames()
    end
end

-- ============================================================
-- AFK TIMER TICKER
-- Updates AFK icons periodically to show elapsed time
-- ============================================================
local afkTickerFrame = CreateFrame("Frame")
local afkTickerInterval = 1.0  -- Update every second
local afkTickerElapsed = 0

afkTickerFrame:SetScript("OnUpdate", function(self, elapsed)
    afkTickerElapsed = afkTickerElapsed + elapsed
    if afkTickerElapsed < afkTickerInterval then return end
    afkTickerElapsed = 0
    
    -- Only update if AFK timer is enabled somewhere
    local partyDb = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    local partyTimerEnabled = partyDb.afkIconEnabled and partyDb.afkIconShowTimer ~= false
    local raidTimerEnabled = raidDb.afkIconEnabled and raidDb.afkIconShowTimer ~= false
    
    if not partyTimerEnabled and not raidTimerEnabled then return end
    
    -- Update party frames
    if partyTimerEnabled and DF.partyHeader then
        local children = {DF.partyHeader:GetChildren()}
        for _, frame in pairs(children) do
            if frame.unit and frame.afkIcon and frame.afkIcon:IsShown() then
                DF:UpdateAFKIcon(frame)
            end
        end
    end
    
    -- Update raid frames
    if raidTimerEnabled then
        for i = 1, 8 do
            local header = DF["raidGroup" .. i]
            if header then
                local children = {header:GetChildren()}
                for _, frame in pairs(children) do
                    if frame.unit and frame.afkIcon and frame.afkIcon:IsShown() then
                        DF:UpdateAFKIcon(frame)
                    end
                end
            end
        end
    end
    
    -- Update test frames if in test mode
    if DF.testMode then
        for i = 0, 4 do
            local frame = DF.testPartyFrames and DF.testPartyFrames[i]
            if frame and frame.afkIcon and frame.afkIcon:IsShown() then
                local testData = DF:GetTestUnitData(i)
                if testData and testData.isAFK then
                    DF:UpdateTestStatusIcons(frame, testData)
                end
            end
        end
    end
    
    if DF.raidTestMode then
        for i = 1, 40 do
            local frame = DF.testRaidFrames and DF.testRaidFrames[i]
            if frame and frame.afkIcon and frame.afkIcon:IsShown() then
                local testData = DF:GetTestUnitData(i)
                if testData and testData.isAFK then
                    DF:UpdateTestStatusIcons(frame, testData)
                end
            end
        end
    end
end)

-- ============================================================
-- ENHANCED READY CHECK ICON
-- Adds AFK state detection (4th state)
-- ============================================================
function DF:UpdateReadyCheckIconEnhanced(frame)
    if not frame or not frame.unit or not frame.readyCheckIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.readyCheckIconEnabled then
        frame.readyCheckIcon:Hide()
        return
    end
    
    -- Hide in combat check
    if db.readyCheckIconHideInCombat and InCombatLockdown() then
        frame.readyCheckIcon:Hide()
        return
    end
    
    local readyCheckStatus = nil
    pcall(function()
        readyCheckStatus = GetReadyCheckStatus(frame.unit)
    end)
    
    if not canaccessvalue(readyCheckStatus) or not readyCheckStatus then
        frame.readyCheckIcon:Hide()
        return
    end
    
    local texture
    if readyCheckStatus == "ready" then
        texture = "Interface\\RaidFrame\\ReadyCheck-Ready"
    elseif readyCheckStatus == "notready" then
        texture = "Interface\\RaidFrame\\ReadyCheck-NotReady"
    elseif readyCheckStatus == "waiting" then
        -- Check if also AFK
        local isAFK = nil
        pcall(function()
            isAFK = UnitIsAFK(frame.unit)
        end)
        
        if canaccessvalue(isAFK) and isAFK then
            -- AFK state - use notready icon with different tint or keep waiting
            texture = "Interface\\RaidFrame\\ReadyCheck-NotReady"
            -- Could add vertex color for AFK distinction
        else
            texture = "Interface\\RaidFrame\\ReadyCheck-Waiting"
        end
    else
        frame.readyCheckIcon:Hide()
        return
    end
    
    frame.readyCheckIcon.texture:SetTexture(texture)
    
    -- Apply positioning
    local scale = db.readyCheckIconScale or 1.0
    local anchor = db.readyCheckIconAnchor or "CENTER"
    local x = db.readyCheckIconX or 0
    local y = db.readyCheckIconY or 0
    local alpha = db.readyCheckIconAlpha or 1
    
    frame.readyCheckIcon:SetScale(scale)
    frame.readyCheckIcon:ClearAllPoints()
    frame.readyCheckIcon:SetPoint(anchor, frame, anchor, x, y)
    frame.readyCheckIcon:SetAlpha(alpha)
    
    local frameLevel = db.readyCheckIconFrameLevel or 0
    if frameLevel > 0 then
        frame.readyCheckIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
    
    frame.readyCheckIcon:Show()
end

-- ============================================================
-- ENHANCED ROLE ICON WITH ALPHA
-- ============================================================
function DF:UpdateRoleIconEnhanced(frame)
    if not frame or not frame.unit or not frame.roleIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled (support both old and new settings)
    local enabled = db.roleIconEnabled
    if enabled == nil then enabled = true end  -- Default to enabled
    
    if not enabled then
        frame.roleIcon:Hide()
        return
    end
    
    -- Get role (secret-safe)
    local role = nil
    if UnitGroupRolesAssigned then
        pcall(function()
            role = UnitGroupRolesAssigned(frame.unit)
        end)
    end
    
    if not canaccessvalue(role) then
        frame.roleIcon:Hide()
        return
    end
    
    -- Check role visibility settings
    local shouldShow = false
    if role == "TANK" then
        shouldShow = db.roleIconShowTank ~= false
    elseif role == "HEALER" then
        shouldShow = db.roleIconShowHealer ~= false
    elseif role == "DAMAGER" then
        shouldShow = db.roleIconShowDPS ~= false
    end
    
    if not shouldShow or role == "NONE" then
        frame.roleIcon:Hide()
        return
    end
    
    -- Set texture based on style
    local tex, l, r, t, b = DF:GetRoleIconTexture(db, role)
    frame.roleIcon.texture:SetTexture(tex)
    frame.roleIcon.texture:SetTexCoord(l, r, t, b)
    
    frame.roleIcon:Show()
    
    -- Apply positioning and alpha
    local scale = db.roleIconScale or 1.0
    local anchor = db.roleIconAnchor or "TOPLEFT"
    local x = db.roleIconX or 2
    local y = db.roleIconY or -2
    local alpha = db.roleIconAlpha or 1
    
    frame.roleIcon:SetScale(scale)
    frame.roleIcon:ClearAllPoints()
    frame.roleIcon:SetPoint(anchor, frame, anchor, x, y)
    frame.roleIcon:SetAlpha(alpha)
    
    local frameLevel = db.roleIconFrameLevel or 0
    if frameLevel > 0 then
        frame.roleIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
end

-- ============================================================
-- ENHANCED LEADER ICON WITH ALPHA
-- ============================================================
function DF:UpdateLeaderIconEnhanced(frame)
    if not frame or not frame.unit or not frame.leaderIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.leaderIconEnabled then
        frame.leaderIcon:Hide()
        return
    end
    
    -- Hide in combat check
    if db.leaderIconHideInCombat and InCombatLockdown() then
        frame.leaderIcon:Hide()
        return
    end
    
    local unit = frame.unit
    local isLeader = nil
    local isAssistant = nil
    
    pcall(function()
        isLeader = UnitIsGroupLeader(unit)
    end)
    
    if canaccessvalue(isLeader) and isLeader then
        frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
        frame.leaderIcon.texture:SetTexCoord(0, 1, 0, 1)
        frame.leaderIcon:Show()
    else
        pcall(function()
            isAssistant = UnitIsGroupAssistant(unit)
        end)
        
        if canaccessvalue(isAssistant) and isAssistant then
            frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
            frame.leaderIcon.texture:SetTexCoord(0, 1, 0, 1)
            frame.leaderIcon:Show()
        else
            frame.leaderIcon:Hide()
            return
        end
    end
    
    -- Apply positioning and alpha
    local scale = db.leaderIconScale or 1.0
    local anchor = db.leaderIconAnchor or "TOPLEFT"
    local x = db.leaderIconX or -2
    local y = db.leaderIconY or 2
    local alpha = db.leaderIconAlpha or 1
    
    frame.leaderIcon:SetScale(scale)
    frame.leaderIcon:ClearAllPoints()
    frame.leaderIcon:SetPoint(anchor, frame, anchor, x, y)
    frame.leaderIcon:SetAlpha(alpha)
    
    local frameLevel = db.leaderIconFrameLevel or 0
    if frameLevel > 0 then
        frame.leaderIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
end

-- ============================================================
-- ENHANCED RAID TARGET ICON WITH ALPHA
-- ============================================================
function DF:UpdateRaidTargetIconEnhanced(frame)
    if not frame or not frame.unit or not frame.raidTargetIcon then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Check if enabled
    if not db.raidTargetIconEnabled then
        frame.raidTargetIcon:Hide()
        return
    end
    
    -- Hide in combat check
    if db.raidTargetIconHideInCombat and InCombatLockdown() then
        frame.raidTargetIcon:Hide()
        return
    end
    
    local index = nil
    pcall(function()
        index = GetRaidTargetIndex(frame.unit)
    end)
    
    -- Handle secret values
    if issecretvalue(index) then
        -- In Midnight, raid target might be secret
        -- Use SetSpriteSheetCell approach for sprite sheet icons
        frame.raidTargetIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        if frame.raidTargetIcon.texture.SetSpriteSheetCell then
            pcall(function()
                frame.raidTargetIcon.texture:SetSpriteSheetCell(index, 4, 4, 64, 64)
            end)
        end
        frame.raidTargetIcon:Show()
    elseif canaccessvalue(index) and index then
        frame.raidTargetIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(frame.raidTargetIcon.texture, index)
        frame.raidTargetIcon:Show()
    else
        frame.raidTargetIcon:Hide()
        return
    end
    
    -- Apply positioning and alpha
    local scale = db.raidTargetIconScale or 1.5
    local anchor = db.raidTargetIconAnchor or "TOP"
    local x = db.raidTargetIconX or 0
    local y = db.raidTargetIconY or 2
    local alpha = db.raidTargetIconAlpha or 1
    
    frame.raidTargetIcon:SetScale(scale)
    frame.raidTargetIcon:ClearAllPoints()
    frame.raidTargetIcon:SetPoint(anchor, frame, anchor, x, y)
    frame.raidTargetIcon:SetAlpha(alpha)
    
    local frameLevel = db.raidTargetIconFrameLevel or 0
    if frameLevel > 0 then
        frame.raidTargetIcon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
    end
end
