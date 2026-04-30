local addonName, DF = ...

-- ============================================================
-- FRAMES CREATE MODULE
-- Contains frame creation functions
-- ============================================================

-- ============================================================
-- BINDING TOOLTIP
-- Separate tooltip showing click-cast bindings on unit frame hover.
-- Spell usability / cooldown shown out of combat only (secret values).
-- ============================================================

local issecretvalue = issecretvalue or function() return false end
local pairs, ipairs = pairs, ipairs
local wipe = wipe
local format = string.format
local tinsert = table.insert
local tsort = table.sort
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local IsInRaid = IsInRaid
local UnitGUID = UnitGUID
local ceil = math.ceil
local InCombatLockdown = InCombatLockdown
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local GetTime = GetTime
local IsShiftKeyDown = IsShiftKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsAltKeyDown = IsAltKeyDown
local bindingTooltip = CreateFrame("GameTooltip", "DFBindingTooltip", UIParent, "GameTooltipTemplate")
bindingTooltip:SetFrameStrata("TOOLTIP")
if bindingTooltip.NineSlice then
    for _, piece in pairs({"TopLeftCorner", "TopRightCorner", "BottomLeftCorner", "BottomRightCorner", "TopEdge", "BottomEdge", "LeftEdge", "RightEdge"}) do
        if bindingTooltip.NineSlice[piece] then bindingTooltip.NineSlice[piece]:SetAlpha(0) end
    end
end
DFBindingTooltipTextLeft1:SetFontObject(GameTooltipText)

local BINDING_SHORT_NAMES = {
    LeftButton = "Left", RightButton = "Right", MiddleButton = "Middle",
}
local BINDING_SORT_ORDER = {
    LeftButton = 1, MiddleButton = 2, RightButton = 3,
    Button4 = 4, Button5 = 5, Button6 = 6, Button7 = 7, Button8 = 8,
    Button9 = 9, Button10 = 10, Button11 = 11, Button12 = 12,
    Button13 = 13, Button14 = 14, Button15 = 15, Button16 = 16,
}

-- Pre-allocated table for tooltip lines (wiped each call)
local lines = {}

local function getActiveModifier()
    local mods = ""
    if IsShiftKeyDown() then mods = mods .. "shift-" end
    if IsControlKeyDown() then mods = mods .. "ctrl-" end
    if IsAltKeyDown() then mods = mods .. "alt-" end
    if IsMetaKeyDown and IsMetaKeyDown() then mods = mods .. "meta-" end
    return mods
end

local function bindingMatchesMod(binding, activeMod)
    local mods = binding.modifiers or ""
    return mods == activeMod
end

-- Position the binding tooltip based on settings (mirrors PositionFrameTooltip pattern)
local function positionBindingTooltip(anchorFrame, db)
    local anchor = db.tooltipBindingAnchor or "FRAME"
    local anchorPos = db.tooltipBindingAnchorPos or "TOPRIGHT"
    local offsetX = db.tooltipBindingX or 4
    local offsetY = db.tooltipBindingY or 0

    bindingTooltip:ClearAllPoints()
    if anchor == "CURSOR" then
        -- Approximate cursor-follow by anchoring to cursor position
        local cursorX, cursorY = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        bindingTooltip:SetOwner(anchorFrame, "ANCHOR_NONE")
        bindingTooltip:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", cursorX / scale + offsetX, cursorY / scale + offsetY)
    elseif anchor == "FRAME" then
        bindingTooltip:SetOwner(anchorFrame, "ANCHOR_NONE")
        -- Use opposite anchor so tooltip appears on the correct side
        local opposites = {
            TOPLEFT = "BOTTOMRIGHT", TOP = "BOTTOM", TOPRIGHT = "BOTTOMLEFT",
            LEFT = "RIGHT", CENTER = "CENTER", RIGHT = "LEFT",
            BOTTOMLEFT = "TOPRIGHT", BOTTOM = "TOP", BOTTOMRIGHT = "TOPLEFT",
        }
        local tooltipAnchor = opposites[anchorPos] or "BOTTOMLEFT"
        bindingTooltip:SetPoint(tooltipAnchor, anchorFrame, anchorPos, offsetX, offsetY)
    else
        -- DEFAULT — anchor to top-right of frame
        bindingTooltip:SetOwner(anchorFrame, "ANCHOR_NONE")
        bindingTooltip:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT", 4, 0)
    end
end

function DF:ShowBindingTooltip(anchorFrame)
    local CC = DF.ClickCast
    if not CC or not CC.db or not CC.db.bindings then return end

    -- Read settings from frame db (party/raid independent)
    local db = DF:GetFrameDB(anchorFrame)
    if not db.tooltipBindingEnabled then return end

    local inCombat = InCombatLockdown()
    if db.tooltipBindingDisableInCombat and inCombat then
        bindingTooltip:Hide()
        bindingTooltip.anchorFrame = nil
        return
    end

    local activeMod = getActiveModifier()
    bindingTooltip:ClearLines()
    positionBindingTooltip(anchorFrame, db)
    wipe(lines)
    local unit = anchorFrame.unit
    local isDead = false
    if anchorFrame.dfIsTestFrame then
        local testData = DF.GetTestUnitData and DF:GetTestUnitData(anchorFrame.index, anchorFrame.isRaidFrame)
        isDead = testData and testData.status == "Dead"
    elseif unit and UnitExists(unit) then
        isDead = UnitIsDeadOrGhost(unit)
        if issecretvalue(isDead) then isDead = false end
    end
    local smartResMode = CC.db.options and CC.db.options.smartResurrection or "disabled"
    local resSpells = smartResMode ~= "disabled" and CC.GetPlayerResurrectionSpells and CC:GetPlayerResurrectionSpells() or nil
    for _, binding in ipairs(CC.db.bindings) do
        if binding.enabled ~= false and bindingMatchesMod(binding, activeMod) then
            local keyName
            local sortKey = 99
            if binding.bindType == "mouse" then
                keyName = BINDING_SHORT_NAMES[binding.button] or (binding.button and binding.button:match("Button(%d+)") and "Mouse " .. binding.button:match("Button(%d+)")) or binding.button
                sortKey = BINDING_SORT_ORDER[binding.button] or 99
            else
                keyName = binding.key or "?"
            end
            local action = binding.spellName or binding.actionType or "?"
            local r, g, b = 1, 1, 1
            local suffix = ""
            -- Smart Res: override action when target is dead
            local smartResApplied = false
            if isDead and resSpells and not CC:IsResurrectionSpell(binding.spellName) and binding.targetType ~= "hostile" then
                if inCombat and smartResMode == "normal+combat" and resSpells.combat then
                    action = resSpells.combat
                    smartResApplied = true
                elseif not inCombat then
                    action = resSpells.mass or resSpells.normal or action
                    smartResApplied = true
                end
            end
            -- Resolve override spell name (safe in combat)
            local spellRef = binding.spellId
            if not smartResApplied then
                if spellRef and C_Spell.GetOverrideSpell then
                    spellRef = C_Spell.GetOverrideSpell(spellRef) or spellRef
                end
                local ref = spellRef or binding.spellName
                if ref and C_Spell.GetSpellName then
                    action = C_Spell.GetSpellName(ref) or action
                end
            end
            if not inCombat and not smartResApplied then
                spellRef = spellRef or binding.spellName
                if spellRef and C_Spell.IsSpellUsable then
                    local usable = C_Spell.IsSpellUsable(spellRef)
                    if issecretvalue(usable) then usable = nil end
                    local cdLeft = 0
                    local hasSecretCD = false
                    if usable and C_Spell.GetSpellCharges then
                        local charges = C_Spell.GetSpellCharges(spellRef)
                        if charges then
                            if issecretvalue(charges.currentCharges) then
                                hasSecretCD = true
                            elseif charges.currentCharges == 0 then
                                usable = false
                                if not issecretvalue(charges.cooldownStartTime) then
                                    cdLeft = charges.cooldownStartTime + charges.cooldownDuration - GetTime()
                                end
                            end
                        end
                    end
                    if usable and C_Spell.GetSpellCooldown then
                        local cd = C_Spell.GetSpellCooldown(spellRef)
                        if cd and cd.duration then
                            if issecretvalue(cd.duration) then
                                hasSecretCD = true
                            elseif cd.duration > 1.5 then
                                usable = false
                                if not issecretvalue(cd.startTime) then
                                    cdLeft = cd.startTime + cd.duration - GetTime()
                                end
                            end
                        end
                    end
                    if usable ~= nil and not hasSecretCD then
                        r, g, b = usable and 0 or 1, usable and 1 or 0, 0
                    end
                    if cdLeft > 0 then
                        suffix = " (" .. ceil(cdLeft) .. "s)"
                    end
                end
            end
            -- OOR check (works in and out of combat)
            if unit and binding.spellId and C_Spell.IsSpellInRange then
                local inRange = C_Spell.IsSpellInRange(binding.spellId, unit)
                if not issecretvalue(inRange) and inRange == false then r, g, b = 1, 0, 0; suffix = " (OOR)" end
            end
            -- Dead check (works in and out of combat, skip if Smart Res overrode)
            if isDead and not smartResApplied then r, g, b = 1, 0, 0; suffix = " (DEAD)" end
            local hex = format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
            tinsert(lines, {text = keyName .. ": " .. hex .. action .. suffix .. "|r", sort = sortKey, smartRes = smartResApplied})
        end
    end
    tsort(lines, function(a, b) return a.sort < b.sort end)
    local smartResShown = false
    for _, line in ipairs(lines) do
        if line.smartRes and smartResShown then
            -- skip duplicate Smart Res lines
        else
            if line.smartRes then smartResShown = true end
            bindingTooltip:AddLine(line.text, 0.7, 0.7, 0.7)
        end
    end
    if #lines > 0 then bindingTooltip:Show() else bindingTooltip:Hide() end
    bindingTooltip.anchorFrame = anchorFrame
end

bindingTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
bindingTooltip:RegisterEvent("SPELL_UPDATE_COOLDOWN")
bindingTooltip:SetScript("OnEvent", function(self)
    if self.anchorFrame then DF:ShowBindingTooltip(self.anchorFrame) end
end)

-- ============================================================
-- TOOLTIP REFRESH TICKER
-- Re-fires GameTooltip:SetUnit() every 0.25s while hovering a unit frame.
-- Allows addons like RaiderIO that check IsModifierKeyDown() inside
-- TooltipDataProcessor to respond to modifier key state changes.
-- ============================================================
local tooltipRefreshTicker = nil
local tooltipRefreshFrame = nil
local tooltipRefreshModState = 0

local function GetModifierState()
    local s = 0
    if IsShiftKeyDown() then s = s + 1 end
    if IsControlKeyDown() then s = s + 2 end
    if IsAltKeyDown() then s = s + 4 end
    return s
end

local function StartTooltipRefresh(frame)
    tooltipRefreshFrame = frame
    -- Tooltip was just freshly set by the caller, so the current modifier
    -- state is our baseline — only refresh if it changes from this.
    tooltipRefreshModState = GetModifierState()
    if tooltipRefreshTicker then return end  -- already running
    tooltipRefreshTicker = C_Timer.NewTicker(0.25, function()
        local f = tooltipRefreshFrame
        if not f or not f.dfIsHovered or not GameTooltip:IsShown() then
            tooltipRefreshTicker:Cancel()
            tooltipRefreshTicker = nil
            tooltipRefreshFrame = nil
            return
        end
        -- Only re-call SetUnit when modifier state changes, so addons like
        -- RaiderIO can respond to modifier presses without us repeatedly
        -- overwriting aura tooltips when the cursor lands on a buff/debuff.
        local mod = GetModifierState()
        if mod == tooltipRefreshModState then return end
        tooltipRefreshModState = mod
        GameTooltip:SetUnit(f.unit)
        local _, ttUnit = GameTooltip:GetUnit()
        if (not ttUnit or issecretvalue(ttUnit)) and _G.RaiderIO and _G.RaiderIO.ShowProfile then
            _G.RaiderIO.ShowProfile(GameTooltip, f.unit)
        end
    end)
end

local function StopTooltipRefresh()
    tooltipRefreshFrame = nil
    if tooltipRefreshTicker then
        tooltipRefreshTicker:Cancel()
        tooltipRefreshTicker = nil
    end
end

-- Expose for Headers.lua (loads before Create.lua frame hooks)
function DF:StartTooltipRefresh(frame) StartTooltipRefresh(frame) end
function DF:StopTooltipRefresh() StopTooltipRefresh() end

-- Debug flag for duration API troubleshooting
-- Set to true to enable debug output: /run DandersFrames.debugDurationAPI = true
DF.debugDurationAPI = false

-- Debug print helper for duration API
local function DebugDuration(...)
    if DF.debugDurationAPI then
        print("|cFF00FF00[DF Duration Debug]|r", ...)
    end
end

-- Test function to verify debug is working - call with: /run DandersFrames:TestDurationDebug()
function DF:TestDurationDebug()
    print("|cFF00FF00[DF Duration Debug]|r === Debug Test ===")
    print("|cFF00FF00[DF Duration Debug]|r debugDurationAPI flag:", self.debugDurationAPI and "ENABLED" or "DISABLED")
    print("|cFF00FF00[DF Duration Debug]|r")
    print("|cFF00FF00[DF Duration Debug]|r === API Availability ===")
    print("|cFF00FF00[DF Duration Debug]|r C_UnitAuras exists:", C_UnitAuras ~= nil)
    if C_UnitAuras then
        print("|cFF00FF00[DF Duration Debug]|r   .GetAuraDurationRemainingPercent:", C_UnitAuras.GetAuraDurationRemainingPercent ~= nil)
        print("|cFF00FF00[DF Duration Debug]|r   .GetAuraDurationRemaining:", C_UnitAuras.GetAuraDurationRemaining ~= nil)
        print("|cFF00FF00[DF Duration Debug]|r   .GetAuraDataByIndex:", C_UnitAuras.GetAuraDataByIndex ~= nil)
        print("|cFF00FF00[DF Duration Debug]|r   .DoesAuraHaveExpirationTime:", C_UnitAuras.DoesAuraHaveExpirationTime ~= nil)
    end
    print("|cFF00FF00[DF Duration Debug]|r C_CurveUtil exists:", C_CurveUtil ~= nil)
    if C_CurveUtil then
        print("|cFF00FF00[DF Duration Debug]|r   .CreateColorCurve:", C_CurveUtil.CreateColorCurve ~= nil)
    end
    print("|cFF00FF00[DF Duration Debug]|r")
    print("|cFF00FF00[DF Duration Debug]|r durationAPIMode:", self.durationAPIMode or "not set yet")
    print("|cFF00FF00[DF Duration Debug]|r")
    
    -- Try to get a sample aura to check its structure
    print("|cFF00FF00[DF Duration Debug]|r === Sample Aura Check ===")
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        local auraData = C_UnitAuras.GetAuraDataByIndex("player", 1, "HELPFUL")
        if auraData then
            local auraName = "(protected)"
            pcall(function() auraName = auraData.name or "?" end)
            print("|cFF00FF00[DF Duration Debug]|r Found buff:", auraName)
            print("|cFF00FF00[DF Duration Debug]|r   .duration type:", type(auraData.duration))
            print("|cFF00FF00[DF Duration Debug]|r   .duration value:", tostring(auraData.duration))
            print("|cFF00FF00[DF Duration Debug]|r   .expirationTime:", auraData.expirationTime)
            if type(auraData.duration) == "table" then
                print("|cFF00FF00[DF Duration Debug]|r   Duration is a TABLE - checking for methods...")
                for k, v in pairs(auraData.duration) do
                    print("|cFF00FF00[DF Duration Debug]|r     ." .. k .. " = " .. type(v))
                end
            elseif type(auraData.duration) == "number" then
                print("|cFF00FF00[DF Duration Debug]|r   Duration is a NUMBER (old style)")
            end
        else
            print("|cFF00FF00[DF Duration Debug]|r No buffs found on player slot 1")
        end
    end
    
    print("|cFF00FF00[DF Duration Debug]|r")
    print("|cFF00FF00[DF Duration Debug]|r To enable continuous debug: /run DandersFrames.debugDurationAPI = true")
end

-- Track which API we're using (set once on first use)
DF.durationAPIMode = nil  -- Will be "old" or "new" once detected

-- Register a simple slash command for debug (in case the main addon slash commands aren't loaded yet)
SLASH_DFDURATIONDEBUG1 = "/dfduration"
SlashCmdList["DFDURATIONDEBUG"] = function(msg)
    if msg == "on" then
        DF.debugDurationAPI = true
        print("|cFF00FF00[DF Duration Debug]|r Debug ENABLED - watch for output when auras update")
    elseif msg == "off" then
        DF.debugDurationAPI = false
        print("|cFF00FF00[DF Duration Debug]|r Debug DISABLED")
    else
        DF:TestDurationDebug()
    end
end

-- Local caching of frequently used globals for performance
local pairs, ipairs, type, wipe = pairs, ipairs, type, wipe
local CreateFrame = CreateFrame
local UnitExists = UnitExists
local InCombatLockdown = InCombatLockdown
local RegisterUnitWatch = RegisterUnitWatch

-- ============================================================
-- SAFE UNIT WATCH REGISTRATION (combat lockdown protection)
-- ============================================================

-- Queue of frames waiting for unit watch registration after combat
DF.pendingUnitWatchFrames = DF.pendingUnitWatchFrames or {}
-- Queue of frames waiting for unit watch UNregistration after combat
DF.pendingUnitUnwatchFrames = DF.pendingUnitUnwatchFrames or {}

-- Manual visibility update for frames pending registration (combat fallback)
local function UpdatePendingFrameVisibility()
    for frame in pairs(DF.pendingUnitWatchFrames) do
        if frame and frame.unit then
            if UnitExists(frame.unit) then
                frame:Show()
            else
                frame:Hide()
            end
        end
    end
end

-- Safe wrapper for RegisterUnitWatch that handles combat lockdown
function DF:SafeRegisterUnitWatch(frame)
    if not frame then return end
    
    -- If this frame is pending unregistration, cancel that
    DF.pendingUnitUnwatchFrames[frame] = nil
    
    if InCombatLockdown() then
        -- Queue for later registration
        DF.pendingUnitWatchFrames[frame] = true
        
        -- Manual visibility fallback - show/hide based on UnitExists right now
        if frame.unit then
            if UnitExists(frame.unit) then
                frame:Show()
            else
                frame:Hide()
            end
        end
        
        -- Start combat roster watcher if not already running
        if not DF.combatRosterWatcher then
            DF.combatRosterWatcher = CreateFrame("Frame")
            DF.combatRosterWatcher:RegisterEvent("GROUP_ROSTER_UPDATE")
            DF.combatRosterWatcher:SetScript("OnEvent", function()
                if InCombatLockdown() and next(DF.pendingUnitWatchFrames) then
                    UpdatePendingFrameVisibility()
                end
            end)
        end
    else
        RegisterUnitWatch(frame)
    end
end

-- Safe wrapper for UnregisterUnitWatch that handles combat lockdown
function DF:SafeUnregisterUnitWatch(frame)
    if not frame then return end
    
    -- If this frame is pending registration, cancel that
    DF.pendingUnitWatchFrames[frame] = nil
    
    if InCombatLockdown() then
        -- Queue for later unregistration
        DF.pendingUnitUnwatchFrames[frame] = true
        -- Hide the frame immediately (this is safe during combat)
        frame:Hide()
    else
        UnregisterUnitWatch(frame)
        frame:Hide()
    end
end

-- Process queued unit watch registrations/unregistrations after combat ends
function DF:ProcessPendingUnitWatch()
    if InCombatLockdown() then return end
    
    -- Process unregistrations first
    for frame in pairs(DF.pendingUnitUnwatchFrames) do
        if frame and frame.GetName then
            UnregisterUnitWatch(frame)
            frame:Hide()
        end
    end
    wipe(DF.pendingUnitUnwatchFrames)
    
    -- Then process registrations
    for frame in pairs(DF.pendingUnitWatchFrames) do
        if frame and frame.GetName then
            RegisterUnitWatch(frame)
        end
    end
    wipe(DF.pendingUnitWatchFrames)
end

-- ============================================================
-- UNIT EVENT REGISTRATION (performance optimization)
-- ============================================================
-- Using RegisterUnitEvent instead of RegisterEvent filters events
-- at the C++ level, preventing Lua from receiving events for units
-- we don't care about. This is critical for performance in cities
-- where many players/NPCs generate UNIT_* events constantly.
--
-- Added: 2025-01-20 for performance optimization

-- List of events that should use RegisterUnitEvent (have unit as first arg)
-- Events registered per-frame via RegisterUnitEvent (C++-level filtering).
-- Must be true unit events — i.e. events that deliver a unit token as the
-- first OnEvent arg. Non-unit events like INCOMING_SUMMON_CHANGED and
-- INCOMING_RESURRECT_CHANGED do NOT belong here; RegisterUnitEvent silently
-- fails on them. They're handled globally on headerChildEventFrame in
-- Headers.lua instead.
local UNIT_EVENTS_TO_FILTER = {
    "UNIT_HEALTH",
    "UNIT_MAXHEALTH",
    "UNIT_NAME_UPDATE",
    "UNIT_AURA",
    "UNIT_ABSORB_AMOUNT_CHANGED",
    "UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
    "UNIT_HEAL_PREDICTION",
    "UNIT_CONNECTION",
}

-- Register unit-specific events for a frame
-- This filters events at the C++ level so we only receive events for our unit
function DF:RegisterUnitEventsForFrame(frame, unit)
    if not frame or not unit then return end
    
    -- Unregister old unit events if unit changed
    if frame.dfRegisteredUnit and frame.dfRegisteredUnit ~= unit then
        for _, event in ipairs(UNIT_EVENTS_TO_FILTER) do
            frame:UnregisterEvent(event)
        end
    end
    
    -- Register for new unit using RegisterUnitEvent (C++ level filtering)
    for _, event in ipairs(UNIT_EVENTS_TO_FILTER) do
        frame:RegisterUnitEvent(event, unit)
    end
    
    frame.dfRegisteredUnit = unit
end

-- Unregister all unit events from a frame
function DF:UnregisterUnitEventsForFrame(frame)
    if not frame then return end
    
    for _, event in ipairs(UNIT_EVENTS_TO_FILTER) do
        frame:UnregisterEvent(event)
    end
    
    frame.dfRegisteredUnit = nil
end

-- ============================================================
-- CONDITIONAL POWER EVENT REGISTRATION (performance optimization)
-- ============================================================
-- UNIT_POWER_UPDATE fires very frequently, so we only register
-- these events when the power bar is actually enabled.

function DF:UpdatePowerEventRegistration(frame)
    if not frame then return end
    
    local db = DF:GetFrameDB(frame)
    local shouldRegister = db and db.resourceBarEnabled
    
    -- Track registration state to avoid redundant calls
    if frame.dfPowerEventsRegistered == shouldRegister then return end
    
    if shouldRegister then
        -- PERFORMANCE FIX 2025-01-20: Use RegisterUnitEvent for C++ level filtering
        -- This prevents receiving power events for all units in the game world
        local unit = frame.unit
        if unit then
            frame:RegisterUnitEvent("UNIT_POWER_UPDATE", unit)
            frame:RegisterUnitEvent("UNIT_MAXPOWER", unit)
            frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)
        else
            -- Fallback to global registration if unit not set yet
            frame:RegisterEvent("UNIT_POWER_UPDATE")
            frame:RegisterEvent("UNIT_MAXPOWER")
            frame:RegisterEvent("UNIT_DISPLAYPOWER")
        end
        --[[ OLD CODE - Remove after testing
        frame:RegisterEvent("UNIT_POWER_UPDATE")
        frame:RegisterEvent("UNIT_MAXPOWER")
        frame:RegisterEvent("UNIT_DISPLAYPOWER")
        --]]
        frame.dfPowerEventsRegistered = true
    else
        frame:UnregisterEvent("UNIT_POWER_UPDATE")
        frame:UnregisterEvent("UNIT_MAXPOWER")
        frame:UnregisterEvent("UNIT_DISPLAYPOWER")
        frame.dfPowerEventsRegistered = false
    end
end

-- Update power event registration for all frames (call when setting changes)
-- NOTE: Header children don't have individual event handlers so we skip them
function DF:UpdateAllPowerEventRegistration()
    -- Party frames - use iterators if available (handles both legacy and header modes)
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(function(frame)
            -- Only update legacy frames (header children don't use per-frame events)
            if frame and not frame.dfIsHeaderChild and frame.RegisterEvent then
                DF:UpdatePowerEventRegistration(frame)
            end
        end)
    end
    
    -- Raid frames - use iterators if available
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(function(frame)
            if frame and not frame.dfIsHeaderChild and frame.RegisterEvent then
                DF:UpdatePowerEventRegistration(frame)
            end
        end)
    end
end

-- ============================================================
-- UNIFIED FRAME CREATION AND UPDATE SYSTEM
-- ============================================================

-- Unified frame creation for both party and raid frames
-- ============================================================
-- CREATE FRAME ELEMENTS
-- Creates all visual elements on a frame (health bar, text, etc.)
-- Used by both legacy CreateUnitFrame and new header system
-- ============================================================

function DF:CreateFrameElements(frame, isRaid)
    if not frame then return end
    if frame.dfElementsCreated then return end  -- Don't create twice
    
    -- Determine if raid based on frame property or parameter
    if isRaid == nil then
        isRaid = frame.isRaidFrame
    end
    
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    
    -- Store reference for DB lookups
    frame.isRaidFrame = isRaid
    
    -- ========================================
    -- BACKGROUND
    -- ========================================
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetColorTexture(0, 0, 0, 0.8)
    
    -- ========================================
    -- MISSING HEALTH BAR (shows where health is missing)
    -- ========================================
    frame.missingHealthBar = CreateFrame("StatusBar", nil, frame)
    local padding = db.framePadding or 0
    frame.missingHealthBar:SetPoint("TOPLEFT", padding, -padding)
    frame.missingHealthBar:SetPoint("BOTTOMRIGHT", -padding, padding)
    frame.missingHealthBar:SetStatusBarTexture(db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar")
    frame.missingHealthBar:SetMinMaxValues(0, 1)
    frame.missingHealthBar:SetValue(0)
    frame.missingHealthBar:SetReverseFill(true)
    frame.missingHealthBar:SetFrameLevel(frame:GetFrameLevel() + 1)
    local missingColor = db.missingHealthColor or {r = 0.5, g = 0, b = 0, a = 0.8}
    frame.missingHealthBar:SetStatusBarColor(missingColor.r, missingColor.g, missingColor.b, missingColor.a or 0.8)
    frame.missingHealthBar:Hide()
    
    -- ========================================
    -- HEALTH BAR
    -- ========================================
    frame.healthBar = CreateFrame("StatusBar", nil, frame)
    frame.healthBar:SetPoint("TOPLEFT", padding, -padding)
    frame.healthBar:SetPoint("BOTTOMRIGHT", -padding, padding)
    frame.healthBar:SetStatusBarTexture(db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar")
    frame.healthBar:SetMinMaxValues(0, 1)
    frame.healthBar:SetValue(1)
    
    -- ========================================
    -- CONTENT OVERLAY (for text and icons above bars)
    -- ========================================
    frame.contentOverlay = CreateFrame("Frame", nil, frame)
    frame.contentOverlay:SetAllPoints()
    frame.contentOverlay:SetFrameLevel(frame:GetFrameLevel() + 25)
    frame.contentOverlay:EnableMouse(false)
    
    -- ========================================
    -- NAME TEXT
    -- ========================================
    frame.nameText = frame.contentOverlay:CreateFontString(nil, "OVERLAY")
    local nameOutline = db.nameTextOutline or "OUTLINE"
    if nameOutline == "NONE" then nameOutline = "" end
    DF:SafeSetFont(frame.nameText, db.nameFont or "Fonts\\FRIZQT__.TTF", db.nameFontSize or 11, nameOutline)
    local nameAnchor = db.nameTextAnchor or "TOP"
    frame.nameText:SetPoint(nameAnchor, frame, nameAnchor, db.nameTextX or 0, db.nameTextY or -2)
    frame.nameText:SetTextColor(1, 1, 1, 1)
    frame.nameText:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- HEALTH TEXT
    -- ========================================
    frame.healthText = frame.contentOverlay:CreateFontString(nil, "OVERLAY")
    local healthOutline = db.healthTextOutline or "OUTLINE"
    if healthOutline == "NONE" then healthOutline = "" end
    DF:SafeSetFont(frame.healthText, db.healthFont or "Fonts\\FRIZQT__.TTF", db.healthFontSize or 10, healthOutline)
    local healthAnchor = db.healthTextAnchor or "CENTER"
    frame.healthText:SetPoint(healthAnchor, frame, healthAnchor, db.healthTextX or 0, db.healthTextY or 0)
    frame.healthText:SetTextColor(1, 1, 1, 1)
    frame.healthText:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- STATUS TEXT (Dead, Offline, AFK)
    -- ========================================
    frame.statusText = frame.contentOverlay:CreateFontString(nil, "OVERLAY")
    local statusOutline = db.statusTextOutline or "OUTLINE"
    if statusOutline == "NONE" then statusOutline = "" end
    DF:SafeSetFont(frame.statusText, db.statusTextFont or "Fonts\\FRIZQT__.TTF", db.statusTextFontSize or 10, statusOutline)
    local statusAnchor = db.statusTextAnchor or "CENTER"
    frame.statusText:SetPoint(statusAnchor, frame, statusAnchor, db.statusTextX or 0, db.statusTextY or 0)
    local statusColor = db.statusTextColor or {r = 1, g = 1, b = 1}
    frame.statusText:SetTextColor(statusColor.r, statusColor.g, statusColor.b, 1)
    frame.statusText:SetDrawLayer("OVERLAY", 7)
    frame.statusText:Hide()
    
    -- Continue with the rest of the elements...
    -- (Border, icons, power bar, auras, absorbs, etc.)
    -- These are created by calling the internal element creation
    DF:CreateFrameElementsExtended(frame, db)
    
    -- Mark as created
    frame.dfElementsCreated = true
end

-- Extended element creation (called from CreateFrameElements)
-- Creates all visual elements needed for a full unit frame
function DF:CreateFrameElementsExtended(frame, db)
    if not frame or not db then return end
    
    -- ========================================
    -- BORDER
    -- ========================================
    frame.border = CreateFrame("Frame", nil, frame)
    frame.border:SetAllPoints()
    frame.border:SetFrameLevel(frame:GetFrameLevel() + 10)
    
    local borderSize = db.borderSize or 1
    local borderColor = db.borderColor or {r = 0, g = 0, b = 0, a = 1}
    
    frame.border.top = frame.border:CreateTexture(nil, "BORDER")
    frame.border.top:SetHeight(borderSize)
    frame.border.top:SetPoint("TOPLEFT", 0, 0)
    frame.border.top:SetPoint("TOPRIGHT", 0, 0)
    frame.border.top:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    frame.border.bottom = frame.border:CreateTexture(nil, "BORDER")
    frame.border.bottom:SetHeight(borderSize)
    frame.border.bottom:SetPoint("BOTTOMLEFT", 0, 0)
    frame.border.bottom:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.border.bottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    frame.border.left = frame.border:CreateTexture(nil, "BORDER")
    frame.border.left:SetWidth(borderSize)
    frame.border.left:SetPoint("TOPLEFT", 0, 0)
    frame.border.left:SetPoint("BOTTOMLEFT", 0, 0)
    frame.border.left:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    frame.border.right = frame.border:CreateTexture(nil, "BORDER")
    frame.border.right:SetWidth(borderSize)
    frame.border.right:SetPoint("TOPRIGHT", 0, 0)
    frame.border.right:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.border.right:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Helper function to set border color
    frame.border.SetBorderColor = function(self, r, g, b, a)
        self.top:SetColorTexture(r, g, b, a)
        self.bottom:SetColorTexture(r, g, b, a)
        self.left:SetColorTexture(r, g, b, a)
        self.right:SetColorTexture(r, g, b, a)
    end
    
    -- ========================================
    -- ROLE ICON
    -- ========================================
    frame.roleIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.roleIcon:SetSize(18, 18)
    frame.roleIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    frame.roleIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.roleIcon:Hide()
    
    frame.roleIcon.texture = frame.roleIcon:CreateTexture(nil, "OVERLAY")
    frame.roleIcon.texture:SetAllPoints()
    frame.roleIcon.texture:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- LEADER ICON
    -- ========================================
    frame.leaderIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.leaderIcon:SetSize(12, 12)
    frame.leaderIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    frame.leaderIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.leaderIcon:Hide()
    
    frame.leaderIcon.texture = frame.leaderIcon:CreateTexture(nil, "OVERLAY")
    frame.leaderIcon.texture:SetAllPoints()
    frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
    frame.leaderIcon.texture:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- RAID TARGET ICON
    -- ========================================
    frame.raidTargetIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.raidTargetIcon:SetSize(16, 16)
    frame.raidTargetIcon:SetPoint("TOP", frame, "TOP", 0, 2)
    frame.raidTargetIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.raidTargetIcon:Hide()
    
    frame.raidTargetIcon.texture = frame.raidTargetIcon:CreateTexture(nil, "OVERLAY")
    frame.raidTargetIcon.texture:SetAllPoints()
    frame.raidTargetIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    frame.raidTargetIcon.texture:SetDrawLayer("OVERLAY", 6)
    
    -- ========================================
    -- READY CHECK ICON
    -- ========================================
    frame.readyCheckIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.readyCheckIcon:SetSize(16, 16)
    frame.readyCheckIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.readyCheckIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.readyCheckIcon:Hide()
    
    frame.readyCheckIcon.texture = frame.readyCheckIcon:CreateTexture(nil, "OVERLAY")
    frame.readyCheckIcon.texture:SetAllPoints()
    frame.readyCheckIcon.texture:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- CENTER STATUS ICON (DEPRECATED - kept for backward compatibility)
    -- New individual icons created via CreateStatusIcons
    -- ========================================
    frame.centerStatusIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.centerStatusIcon:SetSize(16, 16)
    frame.centerStatusIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.centerStatusIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.centerStatusIcon:Hide()
    
    frame.centerStatusIcon.texture = frame.centerStatusIcon:CreateTexture(nil, "OVERLAY")
    frame.centerStatusIcon.texture:SetAllPoints()
    frame.centerStatusIcon.texture:SetDrawLayer("OVERLAY", 6)
    
    -- ========================================
    -- NEW STATUS ICONS (Summon, Res, Phased, AFK, Vehicle, RaidRole)
    -- ========================================
    DF:CreateStatusIcons(frame)
    
    -- ========================================
    -- RESTED INDICATOR (solo mode) - Custom animated ZZZ with glow
    -- ========================================
    frame.restedIndicator = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.restedIndicator:SetSize(24, 18)
    frame.restedIndicator:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", -18, -14)
    frame.restedIndicator:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.restedIndicator:Hide()
    
    -- Create 3 Z FontStrings with increasing sizes
    local zSizes = {8, 11, 14}
    local zOffsets = {0, 5, 12}
    local zYOffsets = {0, 3, 7}
    
    frame.restedIndicator.zTexts = {}
    for i = 1, 3 do
        local z = frame.restedIndicator:CreateFontString(nil, "OVERLAY")
        DF:SafeSetFont(z, nil, zSizes[i], "OUTLINE")
        z:SetText("Z")
        z:SetTextColor(1, 0.82, 0, 1)
        z:SetPoint("BOTTOMLEFT", frame.restedIndicator, "BOTTOMLEFT", zOffsets[i], zYOffsets[i])
        z:SetAlpha(0)
        z.baseSize = zSizes[i]
        frame.restedIndicator.zTexts[i] = z
    end

    -- Create glow texture
    frame.restedGlow = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    frame.restedGlow:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
    frame.restedGlow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -4)
    frame.restedGlow:SetTexture("Interface\\Buttons\\WHITE8x8")
    frame.restedGlow:SetVertexColor(1, 0.82, 0, 0.3)
    frame.restedGlow:SetBlendMode("ADD")
    frame.restedGlow:Hide()
    
    -- Animation state
    frame.restedIndicator.animTime = 0
    frame.restedIndicator.cycleDuration = 2.0
    
    -- OnUpdate script for custom animation
    frame.restedIndicator:SetScript("OnUpdate", function(self, elapsed)
        self.animTime = self.animTime + elapsed
        local cycle = self.animTime % self.cycleDuration
        local progress = cycle / self.cycleDuration
        
        for i, z in ipairs(self.zTexts) do
            local zDelay = (i - 1) * 0.15
            local zProgress = (progress - zDelay) % 1
            
            local alpha, scale
            if zProgress < 0.4 then
                local t = zProgress / 0.4
                alpha = t
                scale = 0.5 + (t * 0.5)
            elseif zProgress < 0.7 then
                alpha = 1
                scale = 1
            else
                local t = (zProgress - 0.7) / 0.3
                alpha = 1 - t
                scale = 1
            end
            
            z:SetAlpha(alpha)
            local baseSize = z.baseSize
            DF:SafeSetFont(z, nil, baseSize * scale, "OUTLINE")
        end
        
        local glowAlpha = 0.2 + (math.sin(self.animTime * 3) * 0.15 + 0.1)
        if frame.restedGlow and frame.restedGlow:IsShown() then
            frame.restedGlow:SetAlpha(glowAlpha)
        end
    end)
    
    frame.restedIndicator:SetScript("OnShow", function(self)
        self.animTime = 0
        for _, z in ipairs(self.zTexts) do
            z:Show()
        end
    end)
    
    frame.restedIndicator:SetScript("OnHide", function(self)
        for _, z in ipairs(self.zTexts) do
            z:Hide()
        end
    end)
    
    -- ========================================
    -- MISSING BUFF ICON
    -- ========================================
    frame.missingBuffFrame = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.missingBuffFrame:SetSize(24, 24)
    frame.missingBuffFrame:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.missingBuffFrame:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 10)
    
    local mbBorderSize = 2
    frame.missingBuffBorderLeft = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderLeft:SetPoint("TOPLEFT", 0, 0)
    frame.missingBuffBorderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    frame.missingBuffBorderLeft:SetWidth(mbBorderSize)
    frame.missingBuffBorderLeft:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffBorderRight = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderRight:SetPoint("TOPRIGHT", 0, 0)
    frame.missingBuffBorderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.missingBuffBorderRight:SetWidth(mbBorderSize)
    frame.missingBuffBorderRight:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffBorderTop = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderTop:SetPoint("TOPLEFT", mbBorderSize, 0)
    frame.missingBuffBorderTop:SetPoint("TOPRIGHT", -mbBorderSize, 0)
    frame.missingBuffBorderTop:SetHeight(mbBorderSize)
    frame.missingBuffBorderTop:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffBorderBottom = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderBottom:SetPoint("BOTTOMLEFT", mbBorderSize, 0)
    frame.missingBuffBorderBottom:SetPoint("BOTTOMRIGHT", -mbBorderSize, 0)
    frame.missingBuffBorderBottom:SetHeight(mbBorderSize)
    frame.missingBuffBorderBottom:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffIcon = frame.missingBuffFrame:CreateTexture(nil, "ARTWORK")
    frame.missingBuffIcon:SetPoint("TOPLEFT", mbBorderSize, -mbBorderSize)
    frame.missingBuffIcon:SetPoint("BOTTOMRIGHT", -mbBorderSize, mbBorderSize)
    frame.missingBuffIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    frame.missingBuffFrame:Hide()
    
    -- ========================================
    -- DEFENSIVE ICON
    -- ========================================
    frame.defensiveIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.defensiveIcon:SetSize(24, 24)
    frame.defensiveIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.defensiveIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 15)
    frame.defensiveIcon:Hide()
    
    local defBorderSize = 2
    frame.defensiveIcon.borderLeft = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderLeft:SetPoint("TOPLEFT", 0, 0)
    frame.defensiveIcon.borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    frame.defensiveIcon.borderLeft:SetWidth(defBorderSize)
    frame.defensiveIcon.borderLeft:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.borderRight = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderRight:SetPoint("TOPRIGHT", 0, 0)
    frame.defensiveIcon.borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.defensiveIcon.borderRight:SetWidth(defBorderSize)
    frame.defensiveIcon.borderRight:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.borderTop = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderTop:SetPoint("TOPLEFT", defBorderSize, 0)
    frame.defensiveIcon.borderTop:SetPoint("TOPRIGHT", -defBorderSize, 0)
    frame.defensiveIcon.borderTop:SetHeight(defBorderSize)
    frame.defensiveIcon.borderTop:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.borderBottom = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderBottom:SetPoint("BOTTOMLEFT", defBorderSize, 0)
    frame.defensiveIcon.borderBottom:SetPoint("BOTTOMRIGHT", -defBorderSize, 0)
    frame.defensiveIcon.borderBottom:SetHeight(defBorderSize)
    frame.defensiveIcon.borderBottom:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.texture = frame.defensiveIcon:CreateTexture(nil, "ARTWORK")
    frame.defensiveIcon.texture:SetPoint("TOPLEFT", defBorderSize, -defBorderSize)
    frame.defensiveIcon.texture:SetPoint("BOTTOMRIGHT", -defBorderSize, defBorderSize)
    frame.defensiveIcon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    frame.defensiveIcon.cooldown = CreateFrame("Cooldown", nil, frame.defensiveIcon, "CooldownFrameTemplate")
    frame.defensiveIcon.cooldown:SetAllPoints(frame.defensiveIcon.texture)
    frame.defensiveIcon.cooldown:SetDrawEdge(false)
    frame.defensiveIcon.cooldown:SetDrawSwipe(true)
    frame.defensiveIcon.cooldown:SetReverse(true)
    frame.defensiveIcon.cooldown:SetHideCountdownNumbers(false)
    
    frame.defensiveIcon.count = frame.defensiveIcon:CreateFontString(nil, "OVERLAY")
    DF:SafeSetFont(frame.defensiveIcon.count, "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    frame.defensiveIcon.count:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.defensiveIcon.count:SetTextColor(1, 1, 1, 1)
    
    frame.defensiveIcon.unitFrame = frame
    frame.defensiveIcon.auraType = "DEFENSIVE"
    
    -- Tooltip handling for defensive icon
    frame.defensiveIcon:SetScript("OnEnter", function(self)
        if not self:IsShown() then return end
        
        local anchorFrame = self.unitFrame
        if not anchorFrame then return end
        
        local iconDb = DF:GetFrameDB(anchorFrame)
        
        if not iconDb.tooltipDefensiveEnabled then return end
        if iconDb.tooltipDefensiveDisableInCombat and InCombatLockdown() then return end
        
        local anchorType = iconDb.tooltipDefensiveAnchor or "CURSOR"
        if anchorType == "CURSOR" then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        elseif anchorType == "FRAME" then
            local anchorPos = iconDb.tooltipDefensiveAnchorPos or "BOTTOMRIGHT"
            local offsetX = iconDb.tooltipDefensiveX or 0
            local offsetY = iconDb.tooltipDefensiveY or 0
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint(anchorPos, self, anchorPos, offsetX, offsetY)
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
        end
        
        if DF.testMode or DF.raidTestMode then
            GameTooltip:AddLine("Pain Suppression", 1, 1, 1)
            GameTooltip:AddLine("Defensive Cooldown (Test)", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        elseif self.auraData and self.unitFrame then
            local unit = self.unitFrame.unit
            if unit and self.auraData.auraInstanceID and GameTooltip.SetUnitAuraByAuraInstanceID then
                GameTooltip:SetUnitAuraByAuraInstanceID(unit, self.auraData.auraInstanceID)
                GameTooltip:Show()
            end
        end
    end)

    frame.defensiveIcon:SetScript("OnLeave", function(self)
        local parentFrame = self:GetParent()
        local focus = GetMouseFocus and GetMouseFocus() or GetMouseFoci and GetMouseFoci()[1]
        if focus and focus.unitFrame == parentFrame and focus ~= self then
            return
        end
        GameTooltip:Hide()
    end)

    frame.defensiveIcon:EnableMouse(true)
    if frame.defensiveIcon.SetPropagateMouseMotion then
        frame.defensiveIcon:SetPropagateMouseMotion(true)
    end
    if frame.defensiveIcon.SetPropagateMouseClicks then
        frame.defensiveIcon:SetPropagateMouseClicks(true)
    end
    if frame.defensiveIcon.SetMouseClickEnabled then
        frame.defensiveIcon:SetMouseClickEnabled(false)
    end

    frame.defensiveBar = frame.defensiveIcon  -- Alias

    -- External defensive frame (simplified)
    frame.externalDefFrame = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.externalDefFrame:SetSize(24, 24)
    frame.externalDefFrame:Hide()
    frame.externalDefBorder = frame.externalDefFrame:CreateTexture(nil, "BACKGROUND")
    frame.externalDefIcon = frame.externalDefFrame:CreateTexture(nil, "ARTWORK")
    frame.externalDefCooldown = CreateFrame("Cooldown", nil, frame.externalDefFrame, "CooldownFrameTemplate")
    
    -- ========================================
    -- POWER BAR
    -- ========================================
    frame.dfPowerBar = CreateFrame("StatusBar", nil, frame)
    frame.dfPowerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    frame.dfPowerBar:SetMinMaxValues(0, 1)
    frame.dfPowerBar:SetValue(1)
    frame.dfPowerBar:SetAlpha(1)
    frame.dfPowerBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 2)
    frame.dfPowerBar:Hide()
    
    local powerBg = frame.dfPowerBar:CreateTexture(nil, "BACKGROUND")
    powerBg:SetAllPoints()
    powerBg:SetColorTexture(0, 0, 0, 0.8)
    frame.dfPowerBar.bg = powerBg
    
    -- Power bar border
    local powerBorder = CreateFrame("Frame", nil, frame.dfPowerBar, "BackdropTemplate")
    powerBorder:SetPoint("TOPLEFT", -1, 1)
    powerBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    powerBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    powerBorder:SetBackdropBorderColor(0, 0, 0, 1)
    powerBorder:Hide()
    frame.dfPowerBar.border = powerBorder
    
    -- ========================================
    -- ABSORB BAR
    -- ========================================
    frame.dfAbsorbBar = CreateFrame("StatusBar", nil, frame)
    frame.dfAbsorbBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Fill")
    frame.dfAbsorbBar:SetMinMaxValues(0, 1)
    frame.dfAbsorbBar:SetValue(0)
    frame.dfAbsorbBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 3)
    frame.dfAbsorbBar:Hide()
    
    local absorbBg = frame.dfAbsorbBar:CreateTexture(nil, "BACKGROUND")
    absorbBg:SetAllPoints()
    absorbBg:SetColorTexture(0, 0, 0, 0)
    frame.dfAbsorbBar.bg = absorbBg
    
    local absorbBorder = CreateFrame("Frame", nil, frame.dfAbsorbBar, "BackdropTemplate")
    absorbBorder:SetPoint("TOPLEFT", -1, 1)
    absorbBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    absorbBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    absorbBorder:SetBackdropBorderColor(0, 0, 0, 1)
    absorbBorder:Hide()
    frame.dfAbsorbBar.border = absorbBorder
    
    -- ========================================
    -- HEAL ABSORB BAR
    -- ========================================
    frame.dfHealAbsorbBar = CreateFrame("StatusBar", nil, frame)
    frame.dfHealAbsorbBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Fill")
    frame.dfHealAbsorbBar:SetMinMaxValues(0, 1)
    frame.dfHealAbsorbBar:SetValue(0)
    frame.dfHealAbsorbBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 4)
    frame.dfHealAbsorbBar:Hide()
    
    local healAbsorbBg = frame.dfHealAbsorbBar:CreateTexture(nil, "BACKGROUND")
    healAbsorbBg:SetAllPoints()
    healAbsorbBg:SetColorTexture(0, 0, 0, 0)
    frame.dfHealAbsorbBar.bg = healAbsorbBg
    
    local healAbsorbBorder = CreateFrame("Frame", nil, frame.dfHealAbsorbBar, "BackdropTemplate")
    healAbsorbBorder:SetPoint("TOPLEFT", -1, 1)
    healAbsorbBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    healAbsorbBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    healAbsorbBorder:SetBackdropBorderColor(0, 0, 0, 1)
    healAbsorbBorder:Hide()
    frame.dfHealAbsorbBar.border = healAbsorbBorder
    
    -- ========================================
    -- AURA CONTAINER AND ICONS
    -- ========================================
    frame.auraContainer = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.auraContainer:SetAllPoints(frame)
    frame.auraContainer:EnableMouse(false)
    
    frame.buffIcons = {}
    frame.debuffIcons = {}
    
    -- Create aura icons (8 of each type)
    for i = 1, 8 do
        frame.buffIcons[i] = DF:CreateAuraIcon(frame, i, "BUFF")
        frame.debuffIcons[i] = DF:CreateAuraIcon(frame, i, "DEBUFF")
    end
end

-- ========================================
-- SETUP FRAME EVENTS
-- Sets up event registration and OnEvent handler for legacy frames
-- Header children do NOT call this - they use centralized event handling
-- ========================================
function DF:SetupFrameEvents(frame, unit)
    if not frame or not unit then return end
    
    -- Register unit-specific events using C++ level filtering
    DF:RegisterUnitEventsForFrame(frame, unit)
    
    -- Global events (no unit parameter or we need to receive for all units)
    -- NOTE: GROUP_ROSTER_UPDATE removed - handled centrally, OnAttributeChanged handles unit changes
    frame:RegisterEvent("RAID_TARGET_UPDATE")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    
    -- Conditionally register power events based on setting
    DF:UpdatePowerEventRegistration(frame)
    
    -- Event handler
    frame:SetScript("OnEvent", function(self, event, eventUnit)
        -- Wait until addon is fully initialized
        if not DF.initialized then return end
        
        -- PERF TEST: Nuclear option - disable ALL event handling
        if DF.PerfTest and not DF.PerfTest.enableAllEvents then return end
        
        -- Events that don't have a unit argument or need special handling
        if event == "RAID_TARGET_UPDATE" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:UpdateRaidTargetIcon(self)
            end
            return
        elseif event == "READY_CHECK" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:UpdateReadyCheckIcon(self)
            end
            return
        elseif event == "READY_CHECK_FINISHED" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:ScheduleReadyCheckHide(self)
            end
            return
        elseif event == "PARTY_LEADER_CHANGED" then
            if not DF.PerfTest or DF.PerfTest.enableRoleLeaderIcons then
                DF:UpdateLeaderIcon(self)
            end
            return
        elseif event == "PLAYER_ROLES_ASSIGNED" then
            -- Role changes - update role icon only (unit hasn't changed)
            if not DF.PerfTest or DF.PerfTest.enableRoleLeaderIcons then
                DF:UpdateRoleIcon(self)
            end
            return
        end
        
        -- Skip if unit doesn't match (should rarely trigger with RegisterUnitEvent)
        if eventUnit and eventUnit ~= self.unit then return end
        
        -- Route events to appropriate update functions
        if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
            if not DF.PerfTest or DF.PerfTest.enableHealthUpdates then
                if DF.UpdateHealthFast then
                    DF:UpdateHealthFast(self)
                else
                    DF:UpdateUnitFrame(self, "legacy:UNIT_HEALTH")
                end
            end
        elseif event == "UNIT_NAME_UPDATE" then
            if not DF.PerfTest or DF.PerfTest.enableNameUpdates then
                DF:UpdateName(self)
            end
        elseif event == "UNIT_AURA" then
            -- UpdateAuras, UpdateMissingBuffIcon, and UpdateDispelOverlay driven by hooksecurefunc (Auras.lua), not here
            if DF.UpdateExternalDefIcon then
                DF:UpdateExternalDefIcon(self)
            end
        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
            if not DF.PerfTest or DF.PerfTest.enablePowerBar then
                if DF.UpdatePower then
                    DF:UpdatePower(self)
                else
                    DF:UpdateUnitFrame(self, "legacy:UNIT_POWER")
                end
            end
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            if not DF.testMode and not DF.raidTestMode then
                DF:UpdateAbsorb(self)
            end
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            if not DF.testMode and not DF.raidTestMode then
                DF:UpdateHealAbsorb(self)
            end
        elseif event == "UNIT_HEAL_PREDICTION" then
            if not DF.testMode and not DF.raidTestMode then
                DF:UpdateHealPrediction(self)
            end
        elseif event == "UNIT_CONNECTION" then
            if not DF.PerfTest or DF.PerfTest.enableConnectionStatus then
                DF:UpdateUnitFrame(self, "legacy:UNIT_CONNECTION")
            end
        elseif event == "READY_CHECK_CONFIRM" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:UpdateReadyCheckIcon(self)
            end
        elseif event == "INCOMING_SUMMON_CHANGED" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:UpdateCenterStatusIcon(self)
            end
        elseif event == "INCOMING_RESURRECT_CHANGED" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:UpdateCenterStatusIcon(self)
            end
        end
    end)
    
    frame.dfEventsSetup = true
end

function DF:CreateUnitFrame(unit, index, isRaid)
    local db = isRaid and DF:GetRaidDB() or DF:GetDB()
    local parent = isRaid and DF.raidContainer or DF.container
    
    -- Generate frame name
    local frameName
    if isRaid then
        frameName = "DandersRaidFrame" .. index
    else
        frameName = "DandersFrames_" .. (unit == "player" and "Player" or "Party" .. index)
    end
    
    local frame = CreateFrame("Button", frameName, parent, "SecureUnitButtonTemplate,SecureHandlerEnterLeaveTemplate")
    frame:SetSize(db.frameWidth or 120, db.frameHeight or 50)
    frame.unit = unit
    frame.index = index
    frame.isRaidFrame = isRaid  -- Key flag for determining DB source
    frame.dfIsDandersFrame = true  -- Mark as DandersFrames frame for click casting module
    
    -- Register unit attribute
    frame:SetAttribute("unit", unit)
    -- Note: type1/type2 are set by click-casting module (or RestoreBlizzardDefaults when disabled)
    
    -- Register unit watch (managed externally for party frames)
    if isRaid then
        DF:SafeRegisterUnitWatch(frame)
    end
    
    -- Enable mouse
    frame:RegisterForClicks("AnyUp")
    
    -- ========================================
    -- BACKGROUND
    -- ========================================
    frame.background = frame:CreateTexture(nil, "BACKGROUND")
    frame.background:SetAllPoints()
    frame.background:SetColorTexture(0, 0, 0, 0.8)
    
    -- ========================================
    -- MISSING HEALTH BAR (shows where health is missing)
    -- ========================================
    frame.missingHealthBar = CreateFrame("StatusBar", nil, frame)
    local padding = db.framePadding or 0
    frame.missingHealthBar:SetPoint("TOPLEFT", padding, -padding)
    frame.missingHealthBar:SetPoint("BOTTOMRIGHT", -padding, padding)
    frame.missingHealthBar:SetStatusBarTexture(db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar")
    frame.missingHealthBar:SetMinMaxValues(0, 1)  -- Will be updated dynamically with UnitHealthMax
    frame.missingHealthBar:SetValue(0)
    frame.missingHealthBar:SetReverseFill(true)  -- Fill from right side (where health is missing)
    frame.missingHealthBar:SetFrameLevel(frame:GetFrameLevel() + 1)  -- Above background, below health bar
    local missingColor = db.missingHealthColor or {r = 0.5, g = 0, b = 0, a = 0.8}
    frame.missingHealthBar:SetStatusBarColor(missingColor.r, missingColor.g, missingColor.b, missingColor.a or 0.8)
    -- Initially hidden, visibility controlled by backgroundMode setting
    frame.missingHealthBar:Hide()
    
    -- ========================================
    -- HEALTH BAR
    -- ========================================
    frame.healthBar = CreateFrame("StatusBar", nil, frame)
    frame.healthBar:SetPoint("TOPLEFT", padding, -padding)
    frame.healthBar:SetPoint("BOTTOMRIGHT", -padding, padding)
    frame.healthBar:SetStatusBarTexture(db.healthTexture or "Interface\\TargetingFrame\\UI-StatusBar")
    frame.healthBar:SetMinMaxValues(0, 1)
    frame.healthBar:SetValue(1)
    
    -- ========================================
    -- CONTENT OVERLAY (for text and icons above bars)
    -- ========================================
    frame.contentOverlay = CreateFrame("Frame", nil, frame)
    frame.contentOverlay:SetAllPoints()
    frame.contentOverlay:SetFrameLevel(frame:GetFrameLevel() + 25)
    frame.contentOverlay:EnableMouse(false)  -- Don't intercept mouse - let clicks pass to unit frame
    
    -- ========================================
    -- NAME TEXT
    -- ========================================
    frame.nameText = frame.contentOverlay:CreateFontString(nil, "OVERLAY")
    local nameOutline = db.nameTextOutline or "OUTLINE"
    if nameOutline == "NONE" then nameOutline = "" end
    DF:SafeSetFont(frame.nameText, db.nameFont or "Fonts\\FRIZQT__.TTF", db.nameFontSize or 11, nameOutline)
    local nameAnchor = db.nameTextAnchor or "TOP"
    frame.nameText:SetPoint(nameAnchor, frame, nameAnchor, db.nameTextX or 0, db.nameTextY or -2)
    frame.nameText:SetTextColor(1, 1, 1, 1)
    frame.nameText:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- HEALTH TEXT
    -- ========================================
    frame.healthText = frame.contentOverlay:CreateFontString(nil, "OVERLAY")
    local healthOutline = db.healthTextOutline or "OUTLINE"
    if healthOutline == "NONE" then healthOutline = "" end
    DF:SafeSetFont(frame.healthText, db.healthFont or "Fonts\\FRIZQT__.TTF", db.healthFontSize or 10, healthOutline)
    local healthAnchor = db.healthTextAnchor or "CENTER"
    frame.healthText:SetPoint(healthAnchor, frame, healthAnchor, db.healthTextX or 0, db.healthTextY or 0)
    frame.healthText:SetTextColor(1, 1, 1, 1)
    frame.healthText:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- STATUS TEXT (Dead, Offline, AFK)
    -- ========================================
    frame.statusText = frame.contentOverlay:CreateFontString(nil, "OVERLAY")
    local statusOutline = db.statusTextOutline or "OUTLINE"
    if statusOutline == "NONE" then statusOutline = "" end
    DF:SafeSetFont(frame.statusText, db.statusTextFont or "Fonts\\FRIZQT__.TTF", db.statusTextFontSize or 10, statusOutline)
    local statusAnchor = db.statusTextAnchor or "CENTER"
    frame.statusText:SetPoint(statusAnchor, frame, statusAnchor, db.statusTextX or 0, db.statusTextY or 0)
    local statusColor = db.statusTextColor or {r = 1, g = 1, b = 1}
    frame.statusText:SetTextColor(statusColor.r, statusColor.g, statusColor.b, 1)
    frame.statusText:SetDrawLayer("OVERLAY", 7)
    frame.statusText:Hide()
    
    -- ========================================
    -- BORDER
    -- ========================================
    frame.border = CreateFrame("Frame", nil, frame)
    frame.border:SetAllPoints()
    frame.border:SetFrameLevel(frame:GetFrameLevel() + 10)
    
    local borderSize = db.borderSize or 1
    local borderColor = db.borderColor or {r = 0, g = 0, b = 0, a = 1}
    
    frame.border.top = frame.border:CreateTexture(nil, "BORDER")
    frame.border.top:SetHeight(borderSize)
    frame.border.top:SetPoint("TOPLEFT", 0, 0)
    frame.border.top:SetPoint("TOPRIGHT", 0, 0)
    frame.border.top:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    frame.border.bottom = frame.border:CreateTexture(nil, "BORDER")
    frame.border.bottom:SetHeight(borderSize)
    frame.border.bottom:SetPoint("BOTTOMLEFT", 0, 0)
    frame.border.bottom:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.border.bottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    frame.border.left = frame.border:CreateTexture(nil, "BORDER")
    frame.border.left:SetWidth(borderSize)
    frame.border.left:SetPoint("TOPLEFT", 0, 0)
    frame.border.left:SetPoint("BOTTOMLEFT", 0, 0)
    frame.border.left:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    frame.border.right = frame.border:CreateTexture(nil, "BORDER")
    frame.border.right:SetWidth(borderSize)
    frame.border.right:SetPoint("TOPRIGHT", 0, 0)
    frame.border.right:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.border.right:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Helper function to set border color
    frame.border.SetBorderColor = function(self, r, g, b, a)
        self.top:SetColorTexture(r, g, b, a)
        self.bottom:SetColorTexture(r, g, b, a)
        self.left:SetColorTexture(r, g, b, a)
        self.right:SetColorTexture(r, g, b, a)
    end
    
    -- ========================================
    -- ROLE ICON
    -- ========================================
    frame.roleIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.roleIcon:SetSize(18, 18)
    frame.roleIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    frame.roleIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.roleIcon:Hide()
    
    frame.roleIcon.texture = frame.roleIcon:CreateTexture(nil, "OVERLAY")
    frame.roleIcon.texture:SetAllPoints()
    frame.roleIcon.texture:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- LEADER ICON
    -- ========================================
    frame.leaderIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.leaderIcon:SetSize(12, 12)
    frame.leaderIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 2)
    frame.leaderIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.leaderIcon:Hide()
    
    frame.leaderIcon.texture = frame.leaderIcon:CreateTexture(nil, "OVERLAY")
    frame.leaderIcon.texture:SetAllPoints()
    frame.leaderIcon.texture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
    frame.leaderIcon.texture:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- RAID TARGET ICON
    -- ========================================
    frame.raidTargetIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.raidTargetIcon:SetSize(16, 16)
    frame.raidTargetIcon:SetPoint("TOP", frame, "TOP", 0, 2)
    frame.raidTargetIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.raidTargetIcon:Hide()
    
    frame.raidTargetIcon.texture = frame.raidTargetIcon:CreateTexture(nil, "OVERLAY")
    frame.raidTargetIcon.texture:SetAllPoints()
    frame.raidTargetIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    frame.raidTargetIcon.texture:SetDrawLayer("OVERLAY", 6)
    
    -- ========================================
    -- READY CHECK ICON
    -- ========================================
    frame.readyCheckIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.readyCheckIcon:SetSize(16, 16)
    frame.readyCheckIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.readyCheckIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.readyCheckIcon:Hide()
    
    frame.readyCheckIcon.texture = frame.readyCheckIcon:CreateTexture(nil, "OVERLAY")
    frame.readyCheckIcon.texture:SetAllPoints()
    frame.readyCheckIcon.texture:SetDrawLayer("OVERLAY", 7)
    
    -- ========================================
    -- CENTER STATUS ICON (DEPRECATED - kept for backward compatibility)
    -- New individual icons created via CreateStatusIcons
    -- ========================================
    frame.centerStatusIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.centerStatusIcon:SetSize(16, 16)
    frame.centerStatusIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.centerStatusIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.centerStatusIcon:Hide()
    
    frame.centerStatusIcon.texture = frame.centerStatusIcon:CreateTexture(nil, "OVERLAY")
    frame.centerStatusIcon.texture:SetAllPoints()
    frame.centerStatusIcon.texture:SetDrawLayer("OVERLAY", 6)
    
    -- ========================================
    -- NEW STATUS ICONS (Summon, Res, Phased, AFK, Vehicle, RaidRole)
    -- ========================================
    DF:CreateStatusIcons(frame)
    
    -- ========================================
    -- RESTED INDICATOR (solo mode) - Custom animated ZZZ with glow
    -- ========================================
    frame.restedIndicator = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.restedIndicator:SetSize(24, 18)
    frame.restedIndicator:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", -18, -14)  -- Half on, half off corner
    frame.restedIndicator:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 5)
    frame.restedIndicator:Hide()
    
    -- Create 3 Z FontStrings with increasing sizes, going UP and to the right
    -- Tighter spacing with some overlap
    local zSizes = {8, 11, 14}  -- Smallest to largest (left to right)
    local zOffsets = {0, 5, 12}  -- X positions (tighter, overlapping)
    local zYOffsets = {0, 3, 7}  -- Y offsets going UP
    
    frame.restedIndicator.zTexts = {}
    for i = 1, 3 do
        local z = frame.restedIndicator:CreateFontString(nil, "OVERLAY")
        DF:SafeSetFont(z, nil, zSizes[i], "OUTLINE")
        z:SetText("Z")
        z:SetTextColor(1, 0.82, 0, 1)  -- Yellow/gold color
        z:SetPoint("BOTTOMLEFT", frame.restedIndicator, "BOTTOMLEFT", zOffsets[i], zYOffsets[i])
        z:SetAlpha(0)
        z.baseSize = zSizes[i]  -- PERFORMANCE FIX: Store base size to avoid table allocation in OnUpdate
        frame.restedIndicator.zTexts[i] = z
    end
    
    -- Create glow texture around the frame (more visible)
    frame.restedGlow = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    frame.restedGlow:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
    frame.restedGlow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -4)
    frame.restedGlow:SetTexture("Interface\\Buttons\\WHITE8x8")
    frame.restedGlow:SetVertexColor(1, 0.82, 0, 0.3)  -- Yellow glow, more visible
    frame.restedGlow:SetBlendMode("ADD")
    frame.restedGlow:Hide()
    
    -- Animation state
    frame.restedIndicator.animTime = 0
    frame.restedIndicator.cycleDuration = 2.0  -- Full cycle duration
    
    -- OnUpdate script for custom animation
    frame.restedIndicator:SetScript("OnUpdate", function(self, elapsed)
        self.animTime = self.animTime + elapsed
        local cycle = self.animTime % self.cycleDuration
        local progress = cycle / self.cycleDuration
        
        -- Animate each Z with staggered timing
        for i, z in ipairs(self.zTexts) do
            -- Each Z starts at different times in the cycle (0, 0.15, 0.30)
            local zDelay = (i - 1) * 0.15
            local zProgress = (progress - zDelay) % 1
            
            -- Z fades in, scales up, then fades out
            local alpha, scale
            if zProgress < 0.4 then
                -- Fade in and scale up (0 to 0.4)
                local t = zProgress / 0.4
                alpha = t
                scale = 0.5 + (t * 0.5)  -- Scale from 50% to 100%
            elseif zProgress < 0.7 then
                -- Hold (0.4 to 0.7)
                alpha = 1
                scale = 1
            else
                -- Fade out (0.7 to 1.0)
                local t = (zProgress - 0.7) / 0.3
                alpha = 1 - t
                scale = 1
            end
            
            z:SetAlpha(alpha)
            -- Scale effect by adjusting font size
            -- PERFORMANCE FIX: Use stored baseSize instead of creating table every frame
            local baseSize = z.baseSize
            DF:SafeSetFont(z, nil, baseSize * scale, "OUTLINE")
        end
        
        -- Animate glow pulsing (stronger pulse)
        local glowAlpha = 0.2 + (math.sin(self.animTime * 3) * 0.15 + 0.1)
        if frame.restedGlow and frame.restedGlow:IsShown() then
            frame.restedGlow:SetAlpha(glowAlpha)
        end
    end)
    
    -- Start/stop animation
    frame.restedIndicator:SetScript("OnShow", function(self)
        self.animTime = 0
        for _, z in ipairs(self.zTexts) do
            z:Show()
        end
    end)
    
    frame.restedIndicator:SetScript("OnHide", function(self)
        for _, z in ipairs(self.zTexts) do
            z:Hide()
        end
    end)
    
    -- ========================================
    -- MISSING BUFF ICON
    -- ========================================
    frame.missingBuffFrame = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.missingBuffFrame:SetSize(24, 24)
    frame.missingBuffFrame:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.missingBuffFrame:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 10)
    
    -- Create actual edge borders instead of a background
    local borderSize = 2
    frame.missingBuffBorderLeft = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderLeft:SetPoint("TOPLEFT", 0, 0)
    frame.missingBuffBorderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    frame.missingBuffBorderLeft:SetWidth(borderSize)
    frame.missingBuffBorderLeft:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffBorderRight = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderRight:SetPoint("TOPRIGHT", 0, 0)
    frame.missingBuffBorderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.missingBuffBorderRight:SetWidth(borderSize)
    frame.missingBuffBorderRight:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffBorderTop = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderTop:SetPoint("TOPLEFT", borderSize, 0)
    frame.missingBuffBorderTop:SetPoint("TOPRIGHT", -borderSize, 0)
    frame.missingBuffBorderTop:SetHeight(borderSize)
    frame.missingBuffBorderTop:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffBorderBottom = frame.missingBuffFrame:CreateTexture(nil, "BACKGROUND")
    frame.missingBuffBorderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
    frame.missingBuffBorderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
    frame.missingBuffBorderBottom:SetHeight(borderSize)
    frame.missingBuffBorderBottom:SetColorTexture(1, 0, 0, 1)
    
    frame.missingBuffIcon = frame.missingBuffFrame:CreateTexture(nil, "ARTWORK")
    frame.missingBuffIcon:SetPoint("TOPLEFT", borderSize, -borderSize)
    frame.missingBuffIcon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
    frame.missingBuffIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    frame.missingBuffFrame:Hide()
    
    -- ========================================
    -- DEFENSIVE ICON
    -- ========================================
    frame.defensiveIcon = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.defensiveIcon:SetSize(24, 24)
    frame.defensiveIcon:SetPoint("CENTER", frame, "CENTER", 0, 0)
    frame.defensiveIcon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 15)
    frame.defensiveIcon:Hide()
    
    -- Create actual edge borders instead of a background
    local defBorderSize = 2
    frame.defensiveIcon.borderLeft = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderLeft:SetPoint("TOPLEFT", 0, 0)
    frame.defensiveIcon.borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    frame.defensiveIcon.borderLeft:SetWidth(defBorderSize)
    frame.defensiveIcon.borderLeft:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.borderRight = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderRight:SetPoint("TOPRIGHT", 0, 0)
    frame.defensiveIcon.borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    frame.defensiveIcon.borderRight:SetWidth(defBorderSize)
    frame.defensiveIcon.borderRight:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.borderTop = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderTop:SetPoint("TOPLEFT", defBorderSize, 0)
    frame.defensiveIcon.borderTop:SetPoint("TOPRIGHT", -defBorderSize, 0)
    frame.defensiveIcon.borderTop:SetHeight(defBorderSize)
    frame.defensiveIcon.borderTop:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.borderBottom = frame.defensiveIcon:CreateTexture(nil, "BACKGROUND")
    frame.defensiveIcon.borderBottom:SetPoint("BOTTOMLEFT", defBorderSize, 0)
    frame.defensiveIcon.borderBottom:SetPoint("BOTTOMRIGHT", -defBorderSize, 0)
    frame.defensiveIcon.borderBottom:SetHeight(defBorderSize)
    frame.defensiveIcon.borderBottom:SetColorTexture(0, 0.8, 0, 1)
    
    frame.defensiveIcon.texture = frame.defensiveIcon:CreateTexture(nil, "ARTWORK")
    frame.defensiveIcon.texture:SetPoint("TOPLEFT", defBorderSize, -defBorderSize)
    frame.defensiveIcon.texture:SetPoint("BOTTOMRIGHT", -defBorderSize, defBorderSize)
    frame.defensiveIcon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    frame.defensiveIcon.cooldown = CreateFrame("Cooldown", nil, frame.defensiveIcon, "CooldownFrameTemplate")
    frame.defensiveIcon.cooldown:SetAllPoints(frame.defensiveIcon.texture)
    frame.defensiveIcon.cooldown:SetDrawEdge(false)
    frame.defensiveIcon.cooldown:SetDrawSwipe(true)
    frame.defensiveIcon.cooldown:SetReverse(true)
    frame.defensiveIcon.cooldown:SetHideCountdownNumbers(false)
    
    frame.defensiveIcon.count = frame.defensiveIcon:CreateFontString(nil, "OVERLAY")
    -- Use SafeSetFont to support font families (don't use direct SetFont)
    DF:SafeSetFont(frame.defensiveIcon.count, "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    frame.defensiveIcon.count:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.defensiveIcon.count:SetTextColor(1, 1, 1, 1)
    
    frame.defensiveIcon.unitFrame = frame
    frame.defensiveIcon.auraType = "DEFENSIVE"
    
    -- Tooltip handling for defensive icon (simplified - bindings set by parent)
    frame.defensiveIcon:SetScript("OnEnter", function(self)
        if not self:IsShown() then return end
        
        -- With new approach, mouse is only enabled AFTER parent's OnEnter has fired
        local anchorFrame = self.unitFrame
        if not anchorFrame then return end
        
        local db = DF:GetFrameDB(anchorFrame)
        
        if not db.tooltipDefensiveEnabled then return end
        if db.tooltipDefensiveDisableInCombat and InCombatLockdown() then return end
        
        local anchorType = db.tooltipDefensiveAnchor or "CURSOR"
        if anchorType == "CURSOR" then
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        elseif anchorType == "FRAME" then
            local anchorPos = db.tooltipDefensiveAnchorPos or "BOTTOMRIGHT"
            local offsetX = db.tooltipDefensiveX or 0
            local offsetY = db.tooltipDefensiveY or 0
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint(anchorPos, self, anchorPos, offsetX, offsetY)
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
        end
        
        if DF.testMode or DF.raidTestMode then
            GameTooltip:AddLine("Pain Suppression", 1, 1, 1)
            GameTooltip:AddLine("Defensive Cooldown (Test)", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        elseif self.auraData and self.unitFrame then
            local unit = self.unitFrame.unit
            if unit and self.auraData.auraInstanceID and GameTooltip.SetUnitAuraByAuraInstanceID then
                GameTooltip:SetUnitAuraByAuraInstanceID(unit, self.auraData.auraInstanceID)
                GameTooltip:Show()
            end
        end
    end)

    frame.defensiveIcon:SetScript("OnLeave", function(self)
        -- Check if we're moving to another child element in the same frame
        local parentFrame = self:GetParent()
        local focus = GetMouseFocus and GetMouseFocus() or GetMouseFoci and GetMouseFoci()[1]
        if focus and focus.unitFrame == parentFrame and focus ~= self then
            -- Moving to another child element in same frame
            return
        end
        GameTooltip:Hide()
    end)

    -- === MOUSE HANDLING FOR DEFENSIVE ICON ===
    -- SetPropagateMouseMotion(true): Mouse motion events propagate to parent frame
    -- SetPropagateMouseClicks(true): Mouse click events propagate to parent frame
    -- SetMouseClickEnabled(false): This frame itself does not consume clicks
    -- Together these allow tooltips on hover while the PARENT receives all clicks for bindings
    frame.defensiveIcon:EnableMouse(true)
    if frame.defensiveIcon.SetPropagateMouseMotion then
        frame.defensiveIcon:SetPropagateMouseMotion(true)
    end
    if frame.defensiveIcon.SetPropagateMouseClicks then
        frame.defensiveIcon:SetPropagateMouseClicks(true)
    end
    if frame.defensiveIcon.SetMouseClickEnabled then
        frame.defensiveIcon:SetMouseClickEnabled(false)
    end
    
    -- Keep old references for backwards compatibility
    frame.defensiveBar = frame.defensiveIcon  -- Alias
    frame.externalDefFrame = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.externalDefFrame:SetSize(24, 24)
    frame.externalDefFrame:Hide()
    frame.externalDefBorder = frame.externalDefFrame:CreateTexture(nil, "BACKGROUND")
    frame.externalDefIcon = frame.externalDefFrame:CreateTexture(nil, "ARTWORK")
    frame.externalDefCooldown = CreateFrame("Cooldown", nil, frame.externalDefFrame, "CooldownFrameTemplate")
    
    -- ========================================
    -- POWER BAR
    -- ========================================
    frame.dfPowerBar = CreateFrame("StatusBar", nil, frame)
    frame.dfPowerBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    frame.dfPowerBar:SetMinMaxValues(0, 1)
    frame.dfPowerBar:SetValue(1)
    frame.dfPowerBar:SetAlpha(1)
    frame.dfPowerBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 2)
    frame.dfPowerBar:Hide()
    
    local powerBg = frame.dfPowerBar:CreateTexture(nil, "BACKGROUND")
    powerBg:SetAllPoints()
    powerBg:SetColorTexture(0, 0, 0, 0.8)
    frame.dfPowerBar.bg = powerBg
    
    -- Power bar border
    local powerBorder = CreateFrame("Frame", nil, frame.dfPowerBar, "BackdropTemplate")
    powerBorder:SetPoint("TOPLEFT", -1, 1)
    powerBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    powerBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    powerBorder:SetBackdropBorderColor(0, 0, 0, 1)
    powerBorder:Hide()
    frame.dfPowerBar.border = powerBorder
    
    -- ========================================
    -- ABSORB BAR
    -- ========================================
    frame.dfAbsorbBar = CreateFrame("StatusBar", nil, frame)
    frame.dfAbsorbBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Fill")
    frame.dfAbsorbBar:SetMinMaxValues(0, 1)
    frame.dfAbsorbBar:SetValue(0)
    frame.dfAbsorbBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 3)
    frame.dfAbsorbBar:Hide()
    
    local absorbBg = frame.dfAbsorbBar:CreateTexture(nil, "BACKGROUND")
    absorbBg:SetAllPoints()
    absorbBg:SetColorTexture(0, 0, 0, 0)
    frame.dfAbsorbBar.bg = absorbBg
    
    -- Border for absorb bar
    local absorbBorder = CreateFrame("Frame", nil, frame.dfAbsorbBar, "BackdropTemplate")
    absorbBorder:SetPoint("TOPLEFT", -1, 1)
    absorbBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    absorbBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    absorbBorder:SetBackdropBorderColor(0, 0, 0, 1)
    absorbBorder:Hide()
    frame.dfAbsorbBar.border = absorbBorder
    
    -- ========================================
    -- HEAL ABSORB BAR
    -- ========================================
    frame.dfHealAbsorbBar = CreateFrame("StatusBar", nil, frame)
    frame.dfHealAbsorbBar:SetStatusBarTexture("Interface\\RaidFrame\\Shield-Fill")
    frame.dfHealAbsorbBar:SetMinMaxValues(0, 1)
    frame.dfHealAbsorbBar:SetValue(0)
    frame.dfHealAbsorbBar:SetFrameLevel(frame.healthBar:GetFrameLevel() + 4)
    frame.dfHealAbsorbBar:Hide()
    
    local healAbsorbBg = frame.dfHealAbsorbBar:CreateTexture(nil, "BACKGROUND")
    healAbsorbBg:SetAllPoints()
    healAbsorbBg:SetColorTexture(0, 0, 0, 0)
    frame.dfHealAbsorbBar.bg = healAbsorbBg
    
    -- Border for heal absorb bar
    local healAbsorbBorder = CreateFrame("Frame", nil, frame.dfHealAbsorbBar, "BackdropTemplate")
    healAbsorbBorder:SetPoint("TOPLEFT", -1, 1)
    healAbsorbBorder:SetPoint("BOTTOMRIGHT", 1, -1)
    healAbsorbBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    healAbsorbBorder:SetBackdropBorderColor(0, 0, 0, 1)
    healAbsorbBorder:Hide()
    frame.dfHealAbsorbBar.border = healAbsorbBorder
    
    -- ========================================
    -- AURA CONTAINER AND ICONS
    -- ========================================
    frame.auraContainer = CreateFrame("Frame", nil, frame.contentOverlay)
    frame.auraContainer:SetAllPoints(frame)
    frame.auraContainer:EnableMouse(false)  -- Don't intercept mouse - let clicks pass to unit frame
    
    frame.buffIcons = {}
    frame.debuffIcons = {}
    
    -- Create aura icons (8 of each type)
    for i = 1, 8 do
        frame.buffIcons[i] = DF:CreateAuraIcon(frame, i, "BUFF")
        frame.debuffIcons[i] = DF:CreateAuraIcon(frame, i, "DEBUFF")
    end
    
    -- ========================================
    -- EVENTS
    -- ========================================
    
    -- PERFORMANCE FIX 2025-01-20: Use RegisterUnitEvent for unit-specific events
    -- This filters events at the C++ level, preventing us from receiving events
    -- for units we don't care about (massive performance gain in cities)
    DF:RegisterUnitEventsForFrame(frame, unit)
    
    -- NOTE: Global events (RAID_TARGET_UPDATE, READY_CHECK, PARTY_LEADER_CHANGED, PLAYER_ROLES_ASSIGNED)
    -- are all handled centrally by headerChildEventFrame in Headers.lua
    -- Do NOT register them per-frame or we'll get double processing!
    
    --[[ OLD CODE - Remove after testing (was causing event flooding in cities)
    frame:RegisterEvent("UNIT_HEALTH")
    frame:RegisterEvent("UNIT_MAXHEALTH")
    frame:RegisterEvent("UNIT_NAME_UPDATE")
    frame:RegisterEvent("UNIT_AURA")
    frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    -- Power events are registered conditionally below
    frame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
    frame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
    frame:RegisterEvent("UNIT_HEAL_PREDICTION")
    frame:RegisterEvent("UNIT_CONNECTION")
    frame:RegisterEvent("RAID_TARGET_UPDATE")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:RegisterEvent("PARTY_LEADER_CHANGED")
    frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    frame:RegisterEvent("INCOMING_SUMMON_CHANGED")
    frame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
    --]]
    
    -- Conditionally register power events based on setting (optimization)
    -- UNIT_POWER_UPDATE fires very frequently, so skip if power bar disabled
    DF:UpdatePowerEventRegistration(frame)
    
    -- ========================================
    -- EVENT HANDLER
    -- ========================================
    frame:SetScript("OnEvent", function(self, event, eventUnit)
        -- Wait until addon is fully initialized
        if not DF.initialized then return end
        
        -- PERF TEST: Nuclear option - disable ALL event handling
        if DF.PerfTest and not DF.PerfTest.enableAllEvents then return end
        
        -- PERFORMANCE NOTE 2025-01-20: With RegisterUnitEvent, unit events are now filtered
        -- at the C++ level, so this check should rarely/never trigger for unit events.
        -- Keeping it as a safety measure in case of edge cases or fallback paths.
        if eventUnit and eventUnit ~= self.unit then return end
        
        -- Route events to appropriate update functions
        if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
            if not DF.PerfTest or DF.PerfTest.enableHealthUpdates then
                if DF.UpdateHealthFast then
                    DF:UpdateHealthFast(self)
                else
                    DF:UpdateUnitFrame(self, "UNIT_HEALTH")
                end
            end
        elseif event == "UNIT_NAME_UPDATE" then
            if not DF.PerfTest or DF.PerfTest.enableNameUpdates then
                DF:UpdateName(self)
            end
        elseif event == "UNIT_AURA" then
            -- UpdateAuras, UpdateMissingBuffIcon, and UpdateDispelOverlay driven by hooksecurefunc (Auras.lua), not here
            if DF.UpdateExternalDefIcon then
                DF:UpdateExternalDefIcon(self)
            end
        elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" then
            if not DF.PerfTest or DF.PerfTest.enablePowerBar then
                if DF.UpdatePower then
                    DF:UpdatePower(self)
                else
                    DF:UpdateUnitFrame(self, "UNIT_POWER")
                end
            end
        elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
            -- Skip in test mode - test mode handles its own absorb display
            if not DF.testMode and not DF.raidTestMode then
                DF:UpdateAbsorb(self)
            end
        elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
            -- Skip in test mode - test mode handles its own heal absorb display
            if not DF.testMode and not DF.raidTestMode then
                DF:UpdateHealAbsorb(self)
            end
        elseif event == "UNIT_HEAL_PREDICTION" then
            -- Skip in test mode - test mode handles its own heal prediction display
            if not DF.testMode and not DF.raidTestMode then
                DF:UpdateHealPrediction(self)
            end
        elseif event == "UNIT_CONNECTION" then
            if not DF.PerfTest or DF.PerfTest.enableConnectionStatus then
                DF:UpdateUnitFrame(self)
            end
        elseif event == "READY_CHECK_CONFIRM" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:UpdateReadyCheckIcon(self)
            end
        elseif event == "INCOMING_SUMMON_CHANGED" or event == "INCOMING_RESURRECT_CHANGED" then
            if not DF.PerfTest or DF.PerfTest.enableStatusIcons then
                DF:UpdateCenterStatusIcon(self)
            end
        end
    end)
    
    -- ========================================
    -- ON SHOW HANDLER
    -- ========================================
    frame:SetScript("OnShow", function(self)
        if not DF.initialized then return end
        DF:UpdateUnitFrame(self)
    end)
    
    -- ========================================
    -- TOOLTIP HANDLERS
    -- ========================================
    
    -- Helper to get opposite anchor point for tooltip positioning
    local function GetOppositeAnchor(anchor)
        local opposites = {
            TOPLEFT = "BOTTOMRIGHT",
            TOP = "BOTTOM",
            TOPRIGHT = "BOTTOMLEFT",
            LEFT = "RIGHT",
            CENTER = "CENTER",
            RIGHT = "LEFT",
            BOTTOMLEFT = "TOPRIGHT",
            BOTTOM = "TOP",
            BOTTOMRIGHT = "TOPLEFT",
        }
        return opposites[anchor] or "BOTTOMLEFT"
    end
    
    -- Helper to map anchor position to WoW cursor anchor type
    local function GetCursorAnchorType(anchorPos)
        -- Map anchor positions to WoW cursor anchor types
        -- These anchors make the tooltip follow the cursor
        if anchorPos == "LEFT" or anchorPos == "TOPLEFT" or anchorPos == "BOTTOMLEFT" then
            return "ANCHOR_CURSOR_RIGHT"  -- Tooltip to left of cursor
        elseif anchorPos == "RIGHT" or anchorPos == "TOPRIGHT" or anchorPos == "BOTTOMRIGHT" then
            return "ANCHOR_CURSOR_LEFT"   -- Tooltip to right of cursor
        elseif anchorPos == "TOP" then
            return "ANCHOR_CURSOR"        -- Tooltip above cursor
        elseif anchorPos == "BOTTOM" then
            return "ANCHOR_CURSOR"        -- No native below option, use default
        else
            return "ANCHOR_CURSOR"        -- Default: tooltip above-right of cursor
        end
    end
    
    -- Helper function to position tooltip based on settings
    local function PositionFrameTooltip(anchorFrame)
        local db = DF:GetFrameDB(anchorFrame)
        local anchor = db.tooltipFrameAnchor or "DEFAULT"
        local anchorPos = db.tooltipFrameAnchorPos or "BOTTOMRIGHT"
        local offsetX = db.tooltipFrameX or 0
        local offsetY = db.tooltipFrameY or 0
        
        if anchor == "CURSOR" then
            -- Use WoW's built-in cursor anchors that follow the cursor
            local cursorAnchor = GetCursorAnchorType(anchorPos)
            GameTooltip:SetOwner(anchorFrame, cursorAnchor)
        elseif anchor == "FRAME" then
            GameTooltip:SetOwner(anchorFrame, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            local tooltipAnchor = GetOppositeAnchor(anchorPos)
            GameTooltip:SetPoint(tooltipAnchor, anchorFrame, anchorPos, offsetX, offsetY)
        else
            -- DEFAULT - use game's default anchor
            GameTooltip_SetDefaultAnchor(GameTooltip, anchorFrame)
        end
    end
    
    -- ========================================
    -- TOOLTIP HELPERS (parent-driven, Grid2 style)
    -- ========================================

    -- Walk the parent chain to check if a frame is a descendant of a unit frame.
    -- Used to detect Blizzard-rendered private aura icons and other children.
    local function IsChildOfUnitFrame(focus, unitFrame)
        local parent = focus.GetParent and focus:GetParent()
        for _ = 1, 10 do
            if not parent then return false end
            if parent == unitFrame then return true end
            parent = parent.GetParent and parent:GetParent()
        end
        return false
    end

    -- Show an aura tooltip for one of our icons (buff, debuff, or defensive).
    -- Called from the PARENT frame's OnEnter so it works with SetPropagateMouseMotion.
    local function ShowDFAuraTooltip(icon)
        if not icon or not icon:IsShown() then return end

        local anchorFrame = icon.unitFrame
        if not anchorFrame then return end

        local db = DF:GetFrameDB(anchorFrame)
        local auraType = icon.auraType  -- "BUFF", "DEBUFF", or "DEFENSIVE"

        -- Per-type tooltip enable + combat checks
        if auraType == "BUFF" then
            if not db.tooltipBuffEnabled then return end
            if db.tooltipBuffDisableInCombat and InCombatLockdown() then return end
        elseif auraType == "DEBUFF" then
            if not db.tooltipDebuffEnabled then return end
            if db.tooltipDebuffDisableInCombat and InCombatLockdown() then return end
        elseif auraType == "DEFENSIVE" then
            if not db.tooltipDefensiveEnabled then return end
            if db.tooltipDefensiveDisableInCombat and InCombatLockdown() then return end
        end

        -- Position tooltip
        if auraType == "DEFENSIVE" then
            local anchorType = db.tooltipDefensiveAnchor or "CURSOR"
            if anchorType == "CURSOR" then
                GameTooltip:SetOwner(icon, "ANCHOR_CURSOR")
            elseif anchorType == "FRAME" then
                local anchorPos = db.tooltipDefensiveAnchorPos or "BOTTOMRIGHT"
                local offsetX = db.tooltipDefensiveX or 0
                local offsetY = db.tooltipDefensiveY or 0
                GameTooltip:SetOwner(icon, "ANCHOR_NONE")
                GameTooltip:ClearAllPoints()
                GameTooltip:SetPoint(anchorPos, icon, anchorPos, offsetX, offsetY)
            else
                GameTooltip_SetDefaultAnchor(GameTooltip, icon)
            end
        else
            PositionAuraTooltip(icon, auraType == "BUFF")
        end

        -- Test mode
        if DF.testMode or DF.raidTestMode then
            if auraType == "DEFENSIVE" then
                GameTooltip:AddLine("Pain Suppression", 1, 1, 1)
                GameTooltip:AddLine("Defensive Cooldown (Test)", 0.8, 0.8, 0.8)
            elseif icon.testAuraData then
                GameTooltip:AddLine(icon.testAuraData.name or "Test Aura", 1, 1, 1)
                if icon.testAuraData.duration then
                    GameTooltip:AddLine("Duration: " .. icon.testAuraData.duration .. "s", 0.8, 0.8, 0.8)
                end
                if icon.testAuraData.stacks and icon.testAuraData.stacks > 1 then
                    GameTooltip:AddLine("Stacks: " .. icon.testAuraData.stacks, 0.8, 0.8, 0.8)
                end
                if icon.testAuraData.debuffType then
                    GameTooltip:AddLine("Type: " .. icon.testAuraData.debuffType, 1, 0.5, 0.5)
                end
            else
                GameTooltip:AddLine("Test Aura", 1, 1, 1)
            end
            GameTooltip:Show()
            return
        end

        -- Live aura data — use auraInstanceID API (secret-safe for Midnight)
        if icon.auraData and icon.auraData.auraInstanceID then
            local unit = anchorFrame.unit
            if unit then
                if GameTooltip.SetUnitAuraByAuraInstanceID then
                    GameTooltip:SetUnitAuraByAuraInstanceID(unit, icon.auraData.auraInstanceID)
                elseif auraType == "BUFF" and GameTooltip.SetUnitBuffByAuraInstanceID then
                    GameTooltip:SetUnitBuffByAuraInstanceID(unit, icon.auraData.auraInstanceID)
                elseif auraType == "DEBUFF" and GameTooltip.SetUnitDebuffByAuraInstanceID then
                    GameTooltip:SetUnitDebuffByAuraInstanceID(unit, icon.auraData.auraInstanceID)
                end
                GameTooltip:Show()
            end
        end
    end

    -- Expose for tooltip refresh in UpdateAuras_Enhanced
    DF.ShowDFAuraTooltip = ShowDFAuraTooltip

    -- Resolve a clean (untainted) unit token for tooltip use.
    -- Midnight 12.0 taints unit tokens from secure frame attributes, which causes
    -- GameTooltip:GetUnit() to return a secret value. Third-party tooltip hooks
    -- (e.g. RaiderIO) bail out on secret values via issecretvalue(). This function
    -- matches the frame's GUID against clean literal tokens to find an untainted match.
    local function GetCleanUnitForTooltip(frame)
        local guid = frame.unit and UnitGUID(frame.unit)
        if not guid or issecretvalue(guid) then return nil end

        if UnitGUID("player") == guid then return "player" end

        if IsInRaid() then
            for i = 1, GetNumGroupMembers() do
                local token = "raid" .. i
                if UnitGUID(token) == guid then return token end
            end
        else
            for i = 1, GetNumSubgroupMembers() do
                local token = "party" .. i
                if UnitGUID(token) == guid then return token end
            end
        end
        return nil
    end

    -- Use HookScript (not SetScript) to preserve SecureHandlerEnterLeaveTemplate's _onenter/_onleave
    -- SetScript would override the template's handler and break click-casting keyboard bindings
    frame:HookScript("OnEnter", function(self)
        local db = DF:GetFrameDB(self)

        -- Always: set hover state and update highlights
        self.dfIsHovered = true
        if DF.UpdateHighlights then
            DF:UpdateHighlights(self)
        end

        -- Check if we're actually hovering a child element with SetPropagateMouseMotion
        local focus = GetMouseFocus and GetMouseFocus() or GetMouseFoci and GetMouseFoci()[1]
        if focus and focus ~= self then
            -- Our aura/defensive icon → show tooltip from parent
            if focus.auraType and focus.unitFrame == self then
                ShowDFAuraTooltip(focus)
                return
            end
            -- Any other child (private aura icons, etc.) → don't override native tooltip
            if IsChildOfUnitFrame(focus, self) then
                return
            end
        end

        -- Unit frame itself → show unit tooltip
        if not db.tooltipFrameEnabled then return end
        if db.tooltipFrameDisableInCombat and InCombatLockdown() then return end

        -- Check for test mode (party or raid)
        local inTestMode = (self.isRaidFrame and DF.raidTestMode) or (not self.isRaidFrame and DF.testMode)

        if inTestMode then
            local testData = DF:GetTestUnitData(self.unit == "player" and 0 or tonumber(self.unit:match("%d+")))
            if testData then
                PositionFrameTooltip(self)
                GameTooltip:AddLine(testData.name, 1, 1, 1)
                GameTooltip:AddLine("Level 80 " .. (testData.class or "Unknown"), 0.8, 0.8, 0.8)
                GameTooltip:AddLine(testData.role or "DPS", 0.5, 0.5, 1)
                GameTooltip:AddLine(string.format("Health: %.0f%%", (testData.healthPercent or 1) * 100), 0, 1, 0)
                if testData.status then
                    GameTooltip:AddLine(testData.status, 1, 0, 0)
                end
                GameTooltip:Show()
            end
        else
            PositionFrameTooltip(self)
            local unit = GetCleanUnitForTooltip(self) or self.unit
            GameTooltip:SetUnit(unit)
            local _, ttUnit = GameTooltip:GetUnit()
            if (not ttUnit or issecretvalue(ttUnit)) and _G.RaiderIO and _G.RaiderIO.ShowProfile then
                _G.RaiderIO.ShowProfile(GameTooltip, unit)
            end
            StartTooltipRefresh(self)
        end
        DF:ShowBindingTooltip(self)
    end)
    
    frame:HookScript("OnLeave", function(self)
        -- Always: clear hover state and update highlights
        self.dfIsHovered = false
        if DF.UpdateHighlights then
            DF:UpdateHighlights(self)
        end

        -- Don't hide tooltip if we're moving to a child (our icon or private aura)
        local focus = GetMouseFocus and GetMouseFocus() or GetMouseFoci and GetMouseFoci()[1]
        if focus then
            if focus.unitFrame == self then return end           -- still over our icon
            if IsChildOfUnitFrame(focus, self) then return end   -- still over a child (e.g. private aura)
        end
        StopTooltipRefresh()
        GameTooltip:Hide()
        if DFBindingTooltip then DFBindingTooltip:Hide(); DFBindingTooltip.anchorFrame = nil end
    end)

    -- ========================================
    -- CLICK-CAST REGISTRATION
    -- ========================================
    DF:RegisterFrameWithClickCast(frame)
    
    -- ========================================
    -- PING SUPPORT
    -- ========================================
    DF:RegisterFrameForPing(frame)
    
    -- ========================================
    -- PRIVATE AURA ANCHORS
    -- ========================================
    -- Setup is delayed to allow frame to fully initialize
    C_Timer.After(0.1, function()
        if DF.SetupPrivateAuraAnchors then
            DF:SetupPrivateAuraAnchors(frame)
        end
    end)
    
    return frame
end

-- ============================================================
-- UNIFIED FRAME LAYOUT APPLICATION
-- ============================================================

function DF:CreatePartyFrame(unit, index)
    return DF:CreateUnitFrame(unit, index, false)
end

function DF:CreateAuraIcon(parent, index, auraType)
    -- Create on contentOverlay if available, otherwise parent
    local iconParent = parent.contentOverlay or parent
    local icon = CreateFrame("Frame", nil, iconParent)
    icon:SetSize(18, 18)  -- Default size, will be updated by ApplyAuraLayout
    
    -- Set frame level high to ensure visibility above most other elements
    -- contentOverlay is at base+25, we go to base+40 for auras
    -- This allows icons with custom frame levels (up to +100) to be placed above auras
    local baseLevel = parent:GetFrameLevel()
    icon:SetFrameLevel(baseLevel + 40)
    
    -- Border - use BACKGROUND layer so icon texture draws ON TOP of it
    -- This creates a visible border around the edges where the icon doesn't cover
    icon.border = icon:CreateTexture(nil, "BACKGROUND")
    PixelUtil.SetPoint(icon.border, "TOPLEFT", icon, "TOPLEFT", -1, 1)
    PixelUtil.SetPoint(icon.border, "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    icon.border:SetColorTexture(0, 0, 0, 0.8)
    
    -- Normal texture - Masque expects this for proper button structure
    -- Using a 1x1 white pixel that's invisible by default (alpha 0)
    icon.Normal = icon:CreateTexture(nil, "BORDER")
    icon.Normal:SetAllPoints()
    icon.Normal:SetColorTexture(1, 1, 1, 0)  -- Fully transparent white
    
    -- Masque border texture - only used when user enables "Masque Border Control"
    -- This is a separate texture that Masque can skin, kept hidden by default
    icon.masqueBorder = icon:CreateTexture(nil, "OVERLAY")
    PixelUtil.SetPoint(icon.masqueBorder, "TOPLEFT", icon, "TOPLEFT", -1, 1)
    PixelUtil.SetPoint(icon.masqueBorder, "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    icon.masqueBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
    icon.masqueBorder:SetBlendMode("BLEND")  -- Use BLEND, not ADD - ADD causes dimming issues
    icon.masqueBorder:Hide()  -- Hidden by default, shown only if Masque border control enabled
    
    -- Icon texture
    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints()
    icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    -- Cooldown (swipe effect)
    icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
    icon.cooldown:SetAllPoints(icon.texture)
    icon.cooldown:SetDrawEdge(false)
    icon.cooldown:SetDrawSwipe(true)
    icon.cooldown:SetReverse(true)
    -- Start with countdown numbers visible so the FontString gets created
    -- ApplyAuraLayout will configure this based on user settings
    icon.cooldown:SetHideCountdownNumbers(false)
    
    -- Create an overlay frame ABOVE the cooldown for text and indicators
    icon.textOverlay = CreateFrame("Frame", nil, icon)
    icon.textOverlay:SetAllPoints(icon)
    icon.textOverlay:SetFrameLevel(icon.cooldown:GetFrameLevel() + 5)
    icon.textOverlay:EnableMouse(false)  -- Don't intercept mouse - let clicks pass through
    
    -- Expiring tint overlay (on textOverlay, above cooldown swipe)
    icon.expiringTint = icon.textOverlay:CreateTexture(nil, "BACKGROUND")
    icon.expiringTint:SetAllPoints(icon)
    icon.expiringTint:SetColorTexture(1, 0.3, 0.3, 0.3)
    icon.expiringTint:SetBlendMode("ADD")
    icon.expiringTint:Hide()
    
    -- Expiring border uses two containers:
    -- Outer container: alpha controlled by API (visibility: 0 or 1)
    -- Inner container: alpha controlled by animation (pulsate: 0.3 to 1)
    -- This prevents API SetAlpha from conflicting with animation
    
    icon.expiringBorderAlphaContainer = CreateFrame("Frame", nil, icon.textOverlay)
    icon.expiringBorderAlphaContainer:SetAllPoints(icon)
    icon.expiringBorderAlphaContainer:SetFrameLevel(icon.textOverlay:GetFrameLevel())
    icon.expiringBorderAlphaContainer:EnableMouse(false)  -- Don't intercept mouse
    icon.expiringBorderAlphaContainer:Hide()
    
    icon.expiringBorderContainer = CreateFrame("Frame", nil, icon.expiringBorderAlphaContainer)
    icon.expiringBorderContainer:SetAllPoints(icon)
    icon.expiringBorderContainer:SetFrameLevel(icon.expiringBorderAlphaContainer:GetFrameLevel())
    icon.expiringBorderContainer:EnableMouse(false)  -- Don't intercept mouse
    
    -- Expiring border - use 4 edge textures for hollow rectangle effect
    -- Left and Right are full height, Top and Bottom fit between them (no corner overlap)
    local borderThickness = 2
    
    icon.expiringBorderLeft = icon.expiringBorderContainer:CreateTexture(nil, "OVERLAY")
    icon.expiringBorderLeft:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
    icon.expiringBorderLeft:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", -1, -1)
    icon.expiringBorderLeft:SetWidth(borderThickness)
    icon.expiringBorderLeft:SetColorTexture(1, 1, 1, 1)
    
    icon.expiringBorderRight = icon.expiringBorderContainer:CreateTexture(nil, "OVERLAY")
    icon.expiringBorderRight:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 1, 1)
    icon.expiringBorderRight:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
    icon.expiringBorderRight:SetWidth(borderThickness)
    icon.expiringBorderRight:SetColorTexture(1, 1, 1, 1)
    
    -- Top and bottom fit between left and right edges (no corner overlap)
    icon.expiringBorderTop = icon.expiringBorderContainer:CreateTexture(nil, "OVERLAY")
    icon.expiringBorderTop:SetPoint("TOPLEFT", icon.expiringBorderLeft, "TOPRIGHT", 0, 0)
    icon.expiringBorderTop:SetPoint("TOPRIGHT", icon.expiringBorderRight, "TOPLEFT", 0, 0)
    icon.expiringBorderTop:SetHeight(borderThickness)
    icon.expiringBorderTop:SetColorTexture(1, 1, 1, 1)
    
    icon.expiringBorderBottom = icon.expiringBorderContainer:CreateTexture(nil, "OVERLAY")
    icon.expiringBorderBottom:SetPoint("BOTTOMLEFT", icon.expiringBorderLeft, "BOTTOMRIGHT", 0, 0)
    icon.expiringBorderBottom:SetPoint("BOTTOMRIGHT", icon.expiringBorderRight, "BOTTOMLEFT", 0, 0)
    icon.expiringBorderBottom:SetHeight(borderThickness)
    icon.expiringBorderBottom:SetColorTexture(1, 1, 1, 1)
    
    -- Pulse animation for inner container (doesn't conflict with outer container's alpha)
    icon.expiringBorderPulse = icon.expiringBorderContainer:CreateAnimationGroup()
    icon.expiringBorderPulse:SetLooping("REPEAT")
    
    local fadeOut = icon.expiringBorderPulse:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0.3)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(1)
    fadeOut:SetSmoothing("IN_OUT")
    
    local fadeIn = icon.expiringBorderPulse:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.3)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetOrder(2)
    fadeIn:SetSmoothing("IN_OUT")
    
    -- Stack count (on textOverlay, above cooldown)
    icon.count = icon.textOverlay:CreateFontString(nil, "OVERLAY")
    icon.count:SetFontObject(GameFontNormalSmall)  -- Default font to prevent "Font not set" errors, overridden by ApplyAuraLayout
    icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 0)
    icon.count:SetTextColor(1, 1, 1, 1)
    
    -- Duration text - create on textOverlay so it's above swipe
    -- We'll copy the text from the native cooldown countdown
    icon.duration = icon.textOverlay:CreateFontString(nil, "OVERLAY")
    icon.duration:SetFontObject(GameFontNormalSmall)  -- Default font to prevent "Font not set" errors, overridden by ApplyAuraLayout
    icon.duration:SetPoint("CENTER", icon, "CENTER", 0, 0)
    icon.duration:SetTextColor(1, 1, 1, 1)
    icon.duration:Hide()
    
    -- Native cooldown text reference - will be found when icon is shown
    icon.nativeCooldownText = nil
    
    icon.auraType = auraType
    icon:Hide()
    
    -- Store reference to unit frame for API calls
    icon.unitFrame = parent
    
    -- Add Masque-compatible element references
    -- Masque expects: Icon, Border, Cooldown, Count, Normal, etc.
    icon.Icon = icon.texture
    icon.Border = icon.masqueBorder  -- Point to Masque-controlled border
    icon.Cooldown = icon.cooldown
    icon.Count = icon.count
    -- icon.Normal already set above
    
    -- FloatingBG for Masque's Backdrop feature (only created if needed)
    -- Masque registration is deferred to ApplyAuraLayout to ensure proper sizing
    icon.masqueRegistered = false
    
    -- Debug: Track that this icon was created
    icon.debugCreated = GetTime()
    
    -- PERFORMANCE OPTIMIZATION: OnUpdate script removed
    -- Duration text coloring and expiring indicators are now handled by
    -- a single shared timer in Auras.lua (DF:RegisterIconForAuraTimer)
    -- This reduces 400+ OnUpdate script dispatches per frame to 1 timer callback
    
    -- Helper to get opposite anchor point for tooltip positioning
    local function GetOppositeAnchor(anchor)
        local opposites = {
            TOPLEFT = "BOTTOMRIGHT",
            TOP = "BOTTOM",
            TOPRIGHT = "BOTTOMLEFT",
            LEFT = "RIGHT",
            CENTER = "CENTER",
            RIGHT = "LEFT",
            BOTTOMLEFT = "TOPRIGHT",
            BOTTOM = "TOP",
            BOTTOMRIGHT = "TOPLEFT",
        }
        return opposites[anchor] or "BOTTOMLEFT"
    end
    
    -- Helper to map anchor position to WoW cursor anchor type
    local function GetCursorAnchorType(anchorPos)
        if anchorPos == "LEFT" or anchorPos == "TOPLEFT" or anchorPos == "BOTTOMLEFT" then
            return "ANCHOR_CURSOR_RIGHT"
        elseif anchorPos == "RIGHT" or anchorPos == "TOPRIGHT" or anchorPos == "BOTTOMRIGHT" then
            return "ANCHOR_CURSOR_LEFT"
        elseif anchorPos == "TOP" then
            return "ANCHOR_CURSOR"
        elseif anchorPos == "BOTTOM" then
            return "ANCHOR_CURSOR"
        else
            return "ANCHOR_CURSOR"
        end
    end
    
    -- Helper function to position aura tooltip based on settings
    local function PositionAuraTooltip(auraIcon, isBuff)
        local anchorFrame = auraIcon.unitFrame
        local db = anchorFrame and DF:GetFrameDB(anchorFrame) or DF:GetDB()
        local anchor, anchorPos, offsetX, offsetY
        
        if isBuff then
            anchor = db.tooltipBuffAnchor or "DEFAULT"
            anchorPos = db.tooltipBuffAnchorPos or "BOTTOMRIGHT"
            offsetX = db.tooltipBuffX or 0
            offsetY = db.tooltipBuffY or 0
        else
            anchor = db.tooltipDebuffAnchor or "DEFAULT"
            anchorPos = db.tooltipDebuffAnchorPos or "BOTTOMRIGHT"
            offsetX = db.tooltipDebuffX or 0
            offsetY = db.tooltipDebuffY or 0
        end
        
        if anchor == "CURSOR" then
            local cursorAnchor = GetCursorAnchorType(anchorPos)
            GameTooltip:SetOwner(auraIcon, cursorAnchor)
        elseif anchor == "FRAME" then
            GameTooltip:SetOwner(auraIcon, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            local tooltipAnchor = GetOppositeAnchor(anchorPos)
            GameTooltip:SetPoint(tooltipAnchor, auraIcon, anchorPos, offsetX, offsetY)
        else
            GameTooltip_SetDefaultAnchor(GameTooltip, auraIcon)
        end
    end
    
    -- Aura tooltip on hover
    -- With SetPropagateMouseMotion(true), mouse events propagate to parent
    -- So the parent's WrapScript handles bindings, and this just shows tooltips
    icon:SetScript("OnEnter", function(self)
        if not self:IsShown() then return end
        
        local anchorFrame = self.unitFrame
        if not anchorFrame then return end
        
        local db = DF:GetFrameDB(anchorFrame)
        local isBuff = self.auraType == "BUFF"
        
        -- Check if tooltips are enabled for this aura type
        local showTooltip = true
        if isBuff then
            if not db.tooltipBuffEnabled then showTooltip = false end
            if db.tooltipBuffDisableInCombat and InCombatLockdown() then showTooltip = false end
        else
            if not db.tooltipDebuffEnabled then showTooltip = false end
            if db.tooltipDebuffDisableInCombat and InCombatLockdown() then showTooltip = false end
        end
        
        if not showTooltip then return end
        
        PositionAuraTooltip(self, isBuff)
        
        if DF.testMode or DF.raidTestMode then
            if self.testAuraData then
                GameTooltip:AddLine(self.testAuraData.name or "Test Aura", 1, 1, 1)
                if self.testAuraData.duration then
                    GameTooltip:AddLine("Duration: " .. self.testAuraData.duration .. "s", 0.8, 0.8, 0.8)
                end
                if self.testAuraData.stacks and self.testAuraData.stacks > 1 then
                    GameTooltip:AddLine("Stacks: " .. self.testAuraData.stacks, 0.8, 0.8, 0.8)
                end
                if self.testAuraData.debuffType then
                    GameTooltip:AddLine("Type: " .. self.testAuraData.debuffType, 1, 0.5, 0.5)
                end
            else
                GameTooltip:AddLine("Test Aura", 1, 1, 1)
            end
            GameTooltip:Show()
        else
            if self.auraData and self.unitFrame then
                local unit = self.unitFrame.unit
                if not unit then return end
                if self.auraData.auraInstanceID and GameTooltip.SetUnitAuraByAuraInstanceID then
                    GameTooltip:SetUnitAuraByAuraInstanceID(unit, self.auraData.auraInstanceID)
                    GameTooltip:Show()
                end
            end
        end
    end)
    
    icon:SetScript("OnLeave", function(self)
        -- Check if we're moving to another aura in the same frame
        local focus = GetMouseFocus and GetMouseFocus() or GetMouseFoci and GetMouseFoci()[1]
        if focus and focus.unitFrame == self.unitFrame and focus ~= self then
            -- Moving to another child element (another aura) in same frame
            -- Don't hide tooltip - the new aura's OnEnter will update it
            return
        end
        GameTooltip:Hide()
    end)
    
    -- === MOUSE HANDLING FOR AURAS ===
    -- SetPropagateMouseMotion(true): Mouse motion events propagate to parent frame
    -- SetPropagateMouseClicks(true): Mouse click events propagate to parent frame
    -- SetMouseClickEnabled(false): This frame itself does not consume clicks
    -- Together these allow tooltips on hover while the PARENT receives all clicks for bindings
    -- This matches Grid2's approach (IndicatorMidnightTooltip.lua:EnableFrameTooltips)
    -- Guarded: these are protected functions that can't be called in combat
    if not InCombatLockdown() then
        icon:EnableMouse(true)
        if icon.SetPropagateMouseMotion then
            icon:SetPropagateMouseMotion(true)
        end
        if icon.SetPropagateMouseClicks then
            icon:SetPropagateMouseClicks(true)
        end
        if icon.SetMouseClickEnabled then
            icon:SetMouseClickEnabled(false)
        end
        -- Apply user's click-through setting immediately so icons created
        -- after ADDON_LOADED don't stay in the wrong state until combat.
        local clickDB = DF.GetFrameDB and DF:GetFrameDB(parent)
        if clickDB then
            local disableMouse
            if auraType == "BUFF" then
                disableMouse = clickDB.buffDisableMouse
            elseif auraType == "DEBUFF" then
                disableMouse = clickDB.debuffDisableMouse
            end
            if disableMouse then
                icon:EnableMouse(false)
            end
        end
    else
        DF.auraIconsNeedMouseFix = true
    end
    
    -- Store parent frame name for secure binding setup
    -- Mouse propagation is handled by SetPropagateMouseMotion(true) on child elements
    if parent and parent:GetName() then
        icon:SetAttribute("dfParentFrame", parent:GetName())
    end
    
    return icon
end

-- ============================================================
-- PING SYSTEM SUPPORT
-- Makes frames pingable by using the PingableType_UnitFrameMixin
-- ============================================================

-- Function to register ping support on a frame (makes it pingable)
function DF:RegisterFrameForPing(frame)
    if not frame then return end
    
    -- Check if PingableType_UnitFrameMixin exists (retail/midnight)
    if PingableType_UnitFrameMixin then
        -- Mixin the pingable functionality
        Mixin(frame, PingableType_UnitFrameMixin)
        -- Set the ping-receiver attribute
        frame:SetAttribute("ping-receiver", true)
        
        -- Return the live GUID for the frame's current unit
        -- No caching needed - UnitGUID is cheap and frame.unit is always current
        function frame:GetTargetPingGUID()
            if self.unit and UnitExists(self.unit) then
                return UnitGUID(self.unit)
            end
            return nil
        end
    end
end

-- ============================================================
