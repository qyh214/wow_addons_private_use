local addonName, DF = ...

-- ============================================================
-- FRAMES ICONS MODULE
-- Contains missing buff icons and aura update functions
-- ============================================================

-- Local caching of frequently used globals and WoW API for performance
local pairs, ipairs, type, wipe = pairs, ipairs, type, wipe
local tinsert = table.insert
local floor = math.floor
local strsplit = strsplit
local UnitBuff, UnitDebuff = UnitBuff, UnitDebuff
local GetTime = GetTime
local C_Spell = C_Spell
local UnitClass = UnitClass
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsConnected = UnitIsConnected
local UnitExists = UnitExists
local InCombatLockdown = InCombatLockdown
local GetPlayerAuraBySpellID = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
local GetUnitAuraBySpellID = C_UnitAuras and C_UnitAuras.GetUnitAuraBySpellID
local issecretvalue = issecretvalue or function() return false end

-- ============================================================
-- MISSING BUFF CACHING (cached lookup optimization)
-- ============================================================

-- Cache player class once at load
local _, cachedPlayerClass = UnitClass("player")

-- Cache spell icons (spellID -> texture)
local spellIconCache = {}

-- Cache missing buff state per frame (frame -> spellID or nil)
local missingBuffCache = {}

-- Default border color for missing buff icon (avoids table allocation)
local DEFAULT_MISSING_BUFF_BORDER_COLOR = {r = 1, g = 0, b = 0, a = 1}

-- Helper to get cached spell icon
local function GetCachedSpellIcon(spellID)
    if not spellID then return nil end
    
    local cached = spellIconCache[spellID]
    if cached then return cached end
    
    -- Fetch and cache
    local icon
    if C_Spell and C_Spell.GetSpellTexture then
        icon = C_Spell.GetSpellTexture(spellID)
    elseif GetSpellTexture then
        icon = GetSpellTexture(spellID)
    end
    
    if icon then
        spellIconCache[spellID] = icon
    end
    return icon
end

-- ============================================================
-- PERFORMANCE FIX: Default colors for UpdateDefensiveBar fallbacks
-- Avoids creating tables on every call when db values are nil
-- ============================================================
local DEFAULT_DEFENSIVE_BORDER_COLOR = {r = 0, g = 0.8, b = 0, a = 1}
local DEFAULT_DEFENSIVE_DURATION_COLOR = {r = 1, g = 1, b = 1}

-- Growth direction helper for defensive bar (mirrors Update.lua pattern)
local function GetDefensiveGrowthOffset(direction, iconSize, pad)
    if direction == "LEFT" then
        return -(iconSize + pad), 0
    elseif direction == "RIGHT" then
        return iconSize + pad, 0
    elseif direction == "UP" then
        return 0, iconSize + pad
    elseif direction == "DOWN" then
        return 0, -(iconSize + pad)
    end
    return 0, 0
end

-- ============================================================
-- PERFORMANCE FIX: Module-level state for UpdateDefensiveBar pcalls
-- Avoids creating closures on every call
-- ============================================================
local DefensiveBarState = {
    unit = nil,
    auraInstanceID = nil,
    auraData = nil,
    frame = nil,
    textureSet = false,
}

-- Module-level function for GetAuraDataByAuraInstanceID pcall
local function GetDefensiveAuraData()
    local state = DefensiveBarState
    state.auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(state.unit, state.auraInstanceID)
end

-- Module-level function for SetTexture pcall
local function SetDefensiveTexture()
    local state = DefensiveBarState
    state.frame.defensiveIcon.texture:SetTexture(state.auraData.icon)
    state.textureSet = true
end

-- Module-level function for cooldown pcall (secret-safe via Duration objects)
local function SetDefensiveCooldown()
    local state = DefensiveBarState
    local cooldown = state.frame.defensiveIcon.cooldown
    -- Use Duration object pipeline for secret-safe cooldown display
    if state.unit and state.auraInstanceID
       and C_UnitAuras.GetAuraDuration
       and cooldown.SetCooldownFromDurationObject then
        local durationObj = C_UnitAuras.GetAuraDuration(state.unit, state.auraInstanceID)
        if durationObj then
            cooldown:SetCooldownFromDurationObject(durationObj)
            return
        end
    end
    -- Fallback for non-secret values (test mode)
    local auraData = state.auraData
    if auraData and auraData.expirationTime and auraData.duration
       and not issecretvalue(auraData.expirationTime) and not issecretvalue(auraData.duration) then
        if cooldown.SetCooldownFromExpirationTime then
            cooldown:SetCooldownFromExpirationTime(auraData.expirationTime, auraData.duration)
        end
    end
end

-- ============================================================
-- MULTI-DEFENSIVE BAR (Direct API mode)
-- Creates additional defensive icon frames on-demand for showing
-- multiple big defensives simultaneously
-- ============================================================

-- Create or get a defensive bar icon at the given index (1-based)
-- Index 1 reuses the existing frame.defensiveIcon
local function GetOrCreateDefensiveBarIcon(frame, index)
    if index == 1 then return frame.defensiveIcon end

    -- Lazy-init the array
    if not frame.defensiveBarIcons then
        frame.defensiveBarIcons = {}
    end

    local icon = frame.defensiveBarIcons[index]
    if icon then return icon end

    -- Create a new icon frame cloned from the same pattern as Create.lua
    icon = CreateFrame("Frame", nil, frame.contentOverlay)
    icon:SetSize(24, 24)
    icon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 15)
    icon:Hide()

    local borderSize = 2
    icon.borderLeft = icon:CreateTexture(nil, "BACKGROUND")
    icon.borderLeft:SetPoint("TOPLEFT", 0, 0)
    icon.borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    icon.borderLeft:SetWidth(borderSize)
    icon.borderLeft:SetColorTexture(0, 0.8, 0, 1)

    icon.borderRight = icon:CreateTexture(nil, "BACKGROUND")
    icon.borderRight:SetPoint("TOPRIGHT", 0, 0)
    icon.borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    icon.borderRight:SetWidth(borderSize)
    icon.borderRight:SetColorTexture(0, 0.8, 0, 1)

    icon.borderTop = icon:CreateTexture(nil, "BACKGROUND")
    icon.borderTop:SetPoint("TOPLEFT", borderSize, 0)
    icon.borderTop:SetPoint("TOPRIGHT", -borderSize, 0)
    icon.borderTop:SetHeight(borderSize)
    icon.borderTop:SetColorTexture(0, 0.8, 0, 1)

    icon.borderBottom = icon:CreateTexture(nil, "BACKGROUND")
    icon.borderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
    icon.borderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
    icon.borderBottom:SetHeight(borderSize)
    icon.borderBottom:SetColorTexture(0, 0.8, 0, 1)

    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetPoint("TOPLEFT", borderSize, -borderSize)
    icon.texture:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
    icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
    icon.cooldown:SetAllPoints(icon.texture)
    icon.cooldown:SetDrawEdge(false)
    icon.cooldown:SetDrawSwipe(true)
    icon.cooldown:SetReverse(true)
    icon.cooldown:SetHideCountdownNumbers(false)

    icon.count = icon:CreateFontString(nil, "OVERLAY")
    DF:SafeSetFont(icon.count, "Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    icon.count:SetPoint("BOTTOMRIGHT", -1, 1)
    icon.count:SetTextColor(1, 1, 1, 1)

    icon.unitFrame = frame
    icon.auraType = "DEFENSIVE"

    -- Tooltip handling (matches primary defensive icon in Create.lua)
    icon:SetScript("OnEnter", function(self)
        if not self:IsShown() then return end
        local anchorFrame = self.unitFrame
        if not anchorFrame then return end
        local iconDb = DF:GetFrameDB(anchorFrame)
        if not iconDb.tooltipDefensiveEnabled then return end
        if iconDb.tooltipDefensiveDisableInCombat and InCombatLockdown() then return end
        if self.auraData and self.auraData.auraInstanceID then
            local unit = anchorFrame.unit
            if unit then
                local anchorType = iconDb.tooltipDefensiveAnchor or "CURSOR"
                if anchorType == "CURSOR" then
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                elseif anchorType == "FRAME" then
                    local anchorPos = iconDb.tooltipDefensiveAnchorPos or "BOTTOMRIGHT"
                    local offsetX = iconDb.tooltipDefensiveX or 0
                    local offsetY = iconDb.tooltipDefensiveY or 0
                    GameTooltip:SetOwner(self, "ANCHOR_NONE")
                    GameTooltip:SetPoint(anchorPos, self, anchorPos, offsetX, offsetY)
                else
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                end
                GameTooltip:SetUnitAuraByAuraInstanceID(unit, self.auraData.auraInstanceID)
                GameTooltip:Show()
            end
        end
    end)
    icon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Mouse setup: enable hover for tooltips, propagate clicks to parent for bindings
    -- Same approach as buff/debuff icons — guarded for combat lockdown
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
    else
        DF.auraIconsNeedMouseFix = true
    end

    frame.defensiveBarIcons[index] = icon
    return icon
end

-- Expose for use by TestMode
function DF:GetOrCreateDefensiveBarIcon(frame, index)
    return GetOrCreateDefensiveBarIcon(frame, index)
end

-- Render a single defensive icon at a position in the bar
local function RenderDefensiveBarIcon(icon, unit, auraInstanceID, db, iconSize, borderSize, borderColor, showBorder, showDuration, durationScale, durationFont, durationOutline, durationX, durationY, durationColor)
    -- Get aura data
    local auraData = nil
    pcall(function()
        auraData = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
    end)

    if not auraData then
        icon:Hide()
        return false
    end

    -- Set texture
    local textureSet = false
    pcall(function()
        icon.texture:SetTexture(auraData.icon)
        textureSet = true
    end)

    if not textureSet then
        icon:Hide()
        return false
    end

    -- Store aura data for tooltip
    if not icon.auraData then
        icon.auraData = { auraInstanceID = nil }
    end
    icon.auraData.auraInstanceID = auraInstanceID

    -- Cooldown (secret-safe via Duration objects)
    pcall(function()
        if unit and auraInstanceID
           and C_UnitAuras.GetAuraDuration
           and icon.cooldown.SetCooldownFromDurationObject then
            local durationObj = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
            if durationObj then
                icon.cooldown:SetCooldownFromDurationObject(durationObj)
                return
            end
        end
        -- Fallback for non-secret values
        if auraData.expirationTime and auraData.duration
           and not issecretvalue(auraData.expirationTime) and not issecretvalue(auraData.duration)
           and icon.cooldown.SetCooldownFromExpirationTime then
            icon.cooldown:SetCooldownFromExpirationTime(auraData.expirationTime, auraData.duration)
        end
    end)

    -- Expiration check
    local hasExpiration = nil
    if C_UnitAuras.DoesAuraHaveExpirationTime then
        hasExpiration = C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraInstanceID)
    end
    if icon.cooldown.SetShownFromBoolean then
        icon.cooldown:SetShownFromBoolean(hasExpiration, true, false)
    else
        icon.cooldown:Show()
    end

    -- Swipe
    icon.cooldown:SetDrawSwipe(not db.defensiveIconHideSwipe)

    -- Duration text
    icon.cooldown:SetHideCountdownNumbers(not showDuration)

    -- Style native cooldown text
    if not icon.nativeCooldownText then
        local regions = {icon.cooldown:GetRegions()}
        for _, region in ipairs(regions) do
            if region and region.GetObjectType and region:GetObjectType() == "FontString" then
                icon.nativeCooldownText = region
                break
            end
        end
    end
    if icon.nativeCooldownText then
        local dSize = 10 * durationScale
        DF:SafeSetFont(icon.nativeCooldownText, durationFont, dSize, durationOutline)
        icon.nativeCooldownText:ClearAllPoints()
        icon.nativeCooldownText:SetPoint("CENTER", icon, "CENTER", durationX, durationY)
        icon.nativeCooldownText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
    end

    -- Stack count
    icon.count:SetText("")
    if C_UnitAuras.GetAuraApplicationDisplayCount then
        local stackText = C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, 2, 99)
        if stackText then
            icon.count:SetText(stackText)
        end
    end

    -- Border
    if showBorder then
        if icon.borderLeft then
            icon.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            icon.borderLeft:SetWidth(borderSize)
            icon.borderLeft:Show()
        end
        if icon.borderRight then
            icon.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            icon.borderRight:SetWidth(borderSize)
            icon.borderRight:Show()
        end
        if icon.borderTop then
            icon.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            icon.borderTop:SetHeight(borderSize)
            icon.borderTop:ClearAllPoints()
            icon.borderTop:SetPoint("TOPLEFT", borderSize, 0)
            icon.borderTop:SetPoint("TOPRIGHT", -borderSize, 0)
            icon.borderTop:Show()
        end
        if icon.borderBottom then
            icon.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
            icon.borderBottom:SetHeight(borderSize)
            icon.borderBottom:ClearAllPoints()
            icon.borderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
            icon.borderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
            icon.borderBottom:Show()
        end
        icon.texture:ClearAllPoints()
        icon.texture:SetPoint("TOPLEFT", borderSize, -borderSize)
        icon.texture:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
    else
        if icon.borderLeft then icon.borderLeft:Hide() end
        if icon.borderRight then icon.borderRight:Hide() end
        if icon.borderTop then icon.borderTop:Hide() end
        if icon.borderBottom then icon.borderBottom:Hide() end
        icon.texture:ClearAllPoints()
        icon.texture:SetPoint("TOPLEFT", 0, 0)
        icon.texture:SetPoint("BOTTOMRIGHT", 0, 0)
    end

    icon:SetSize(iconSize, iconSize)
    icon:Show()
    return true
end

-- Hide a defensive bar icon at the given index
local function HideDefensiveBarIcon(frame, index)
    if index == 1 then
        frame.defensiveIcon:Hide()
        return
    end
    if frame.defensiveBarIcons and frame.defensiveBarIcons[index] then
        frame.defensiveBarIcons[index]:Hide()
    end
end

-- Get raid buff icons for fallback filtering (when spellId is secret)
-- This is cached after first call
function DF:GetRaidBuffIcons()
    if DF.RaidBuffIconCache then
        return DF.RaidBuffIconCache
    end
    
    local icons = {}
    for _, buffInfo in ipairs(DF.RaidBuffs) do
        local spellIdOrTable = buffInfo[1]
        -- Handle both single spell ID and table of spell IDs
        local spellIds = type(spellIdOrTable) == "table" and spellIdOrTable or {spellIdOrTable}
        for _, spellId in ipairs(spellIds) do
            local icon = nil
            if C_Spell and C_Spell.GetSpellTexture then
                icon = C_Spell.GetSpellTexture(spellId)
            elseif GetSpellTexture then
                icon = GetSpellTexture(spellId)
            end
            if icon then
                icons[icon] = true
            end
        end
    end
    
    DF.RaidBuffIconCache = icons
    return icons
end

-- Get raid buff names for filtering (when both spellId and icon are secret)
function DF:GetRaidBuffNames()
    if DF.RaidBuffNameCache then
        return DF.RaidBuffNameCache
    end
    
    local names = {}
    for _, buffInfo in ipairs(DF.RaidBuffs) do
        local name = buffInfo[3]  -- Name is index 3 in our table
        if name then
            names[name] = true
        end
    end
    
    DF.RaidBuffNameCache = names
    return names
end

-- ============================================================
-- PRE-COMBAT AURA SNAPSHOT
-- Captures raid buff state on entering combat for fallback
-- when spell IDs become secret during combat lockdown
-- ============================================================

-- Snapshot: preCombatAuraSnapshot[unit][spellID] = true
local preCombatAuraSnapshot = {}

function DF:SnapshotRaidBuffAuras()
    wipe(preCombatAuraSnapshot)
    local raidBuffs = DF.RaidBuffs
    if not raidBuffs then return end

    local function snapshotUnit(frame)
        local unit = frame and frame.unit
        if not unit or not UnitExists(unit) then return end
        if preCombatAuraSnapshot[unit] then return end  -- already snapshotted
        local unitSnap = {}
        for i = 1, #raidBuffs do
            local buffInfo = raidBuffs[i]
            local spellIDOrTable = buffInfo[1]
            local spellIDs = type(spellIDOrTable) == "table" and spellIDOrTable or {spellIDOrTable}
            for j = 1, #spellIDs do
                local id = spellIDs[j]
                local aura
                if unit == "player" and GetPlayerAuraBySpellID then
                    aura = GetPlayerAuraBySpellID(id)
                elseif GetUnitAuraBySpellID then
                    aura = GetUnitAuraBySpellID(unit, id)
                end
                if aura then
                    unitSnap[id] = true
                end
            end
        end
        preCombatAuraSnapshot[unit] = unitSnap
    end

    if DF.IteratePartyFrames then DF:IteratePartyFrames(snapshotUnit) end
    if DF.IterateRaidFrames then DF:IterateRaidFrames(snapshotUnit) end
end

function DF:ClearPreCombatSnapshot()
    wipe(preCombatAuraSnapshot)
end

-- ============================================================
-- PERFORMANCE FIX: Module-level state for UnitHasBuff
-- Avoids creating closures every call which caused memory leaks
-- OLD CODE preserved in comments below for rollback if needed
-- ============================================================

-- Shared state table for UnitHasBuff helper functions
local UnitHasBuffState = {
    spellIDs = nil,      -- Current spell IDs to check
    found = false,       -- Result from ForEachAura
    matched = false,     -- Result from GetAuraDataByIndex
    currentAuraData = nil, -- Current aura being checked
}

-- Reusable single-element table for single spell IDs (avoids {spellIDOrTable} allocation)
local singleSpellIDTable = {}

-- Module-level function for checking aura spell ID
-- Note: In WoW, comparing secret values doesn't error - it just returns false
local function CheckAuraSpellId_ForEach()
    local state = UnitHasBuffState
    local auraData = state.currentAuraData
    -- Check for secret value to avoid "attempt to compare secret value" errors
    if auraData and auraData.spellId and not issecretvalue(auraData.spellId) then
        local spellIDs = state.spellIDs
        local auraSpellId = auraData.spellId
        for i = 1, #spellIDs do
            if auraSpellId == spellIDs[i] then
                state.found = true
                return
            end
        end
    end
end

-- Module-level callback for AuraUtil.ForEachAura
local function ForEachAuraCallback(auraData)
    local state = UnitHasBuffState
    state.currentAuraData = auraData
    CheckAuraSpellId_ForEach()
    if state.found then return true end  -- Stop iteration
end

-- Module-level function for GetAuraDataByIndex loop
local function CheckAuraSpellId_ByIndex()
    local state = UnitHasBuffState
    local auraData = state.currentAuraData
    -- Check for secret value to avoid "attempt to compare secret value" errors
    if auraData and auraData.spellId and not issecretvalue(auraData.spellId) then
        local spellIDs = state.spellIDs
        local auraSpellId = auraData.spellId
        for i = 1, #spellIDs do
            if auraSpellId == spellIDs[i] then
                state.matched = true
                return
            end
        end
    end
end

-- Helper function to check if a unit has a specific buff
-- Detection flow (Ellesmere-style 4-method approach):
--   1. Direct spell ID lookup (O(1), works in combat for whitelisted IDs)
--   2. Pre-combat snapshot fallback (for non-whitelisted IDs during combat)
--   3. Name-based lookup (AuraUtil.FindAuraByName)
--   4. Iteration fallback (ForEachAura / GetAuraDataByIndex with issecretvalue guards)
function DF:UnitHasBuff(unit, spellIDOrTable, spellName)
    if not unit or not UnitExists(unit) then return false end

    local db = DF:GetDB()
    local debug = db and db.missingBuffIconDebug

    -- Build spell ID list (reuse single-element table to avoid allocation)
    local spellIDs
    if type(spellIDOrTable) == "table" then
        spellIDs = spellIDOrTable
    else
        wipe(singleSpellIDTable)
        singleSpellIDTable[1] = spellIDOrTable
        spellIDs = singleSpellIDTable
    end

    if debug then
        local idStr = type(spellIDOrTable) == "table" and table.concat(spellIDOrTable, ", ") or tostring(spellIDOrTable)
        print("|cff00ff00DF:|r Checking " .. unit .. " for " .. (spellName or "unknown") .. " (IDs: " .. idStr .. ")")
    end

    -- Method 1: Direct spell ID lookup (O(1), works in combat for whitelisted IDs)
    local nonSecretIDs = DF.NonSecretRaidBuffIDs
    local allWhitelisted = true
    local directLookupAPI = (unit == "player") and GetPlayerAuraBySpellID or GetUnitAuraBySpellID

    if directLookupAPI and nonSecretIDs then
        for i = 1, #spellIDs do
            local id = spellIDs[i]
            if nonSecretIDs[id] then
                local aura
                if unit == "player" then
                    aura = directLookupAPI(id)
                else
                    aura = directLookupAPI(unit, id)
                end
                if aura then
                    if debug then print("|cff00ff00DF:|r   -> Found via direct API lookup (spell " .. id .. ")") end
                    return true
                end
            else
                allWhitelisted = false
            end
        end
        -- If all IDs are whitelisted and none returned a hit, the buff is genuinely absent
        if allWhitelisted then
            if debug then print("|cff00ff00DF:|r   -> NOT FOUND (all IDs whitelisted, direct API authoritative)") end
            return false
        end
    end

    -- Method 2: Pre-combat snapshot fallback (for non-whitelisted IDs during combat)
    if InCombatLockdown() then
        local unitSnap = preCombatAuraSnapshot[unit]
        if unitSnap then
            for i = 1, #spellIDs do
                if unitSnap[spellIDs[i]] then
                    if debug then print("|cff00ff00DF:|r   -> Found via pre-combat snapshot") end
                    return true
                end
            end
            if debug then print("|cff00ff00DF:|r   -> NOT FOUND (snapshot fallback, in combat)") end
            return false
        end
    end

    -- Method 3: Name-based lookup (works out of combat, spell names not protected)
    if spellName and AuraUtil and AuraUtil.FindAuraByName then
        local success, auraData = pcall(AuraUtil.FindAuraByName, spellName, unit, "HELPFUL")
        if success and auraData then
            if debug then print("|cff00ff00DF:|r   -> Found via FindAuraByName") end
            return true
        end
    end

    -- Method 4: Iteration fallback (ForEachAura / GetAuraDataByIndex with issecretvalue guards)
    -- Store in shared state for module-level helper functions
    UnitHasBuffState.spellIDs = spellIDs
    UnitHasBuffState.found = false
    UnitHasBuffState.matched = false

    if AuraUtil and AuraUtil.ForEachAura then
        UnitHasBuffState.found = false
        AuraUtil.ForEachAura(unit, "HELPFUL", nil, ForEachAuraCallback, true)
        if UnitHasBuffState.found then
            if debug then print("|cff00ff00DF:|r   -> Found via ForEachAura") end
            return true
        end
    end

    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for i = 1, 40 do
            local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
            if not auraData then break end
            UnitHasBuffState.currentAuraData = auraData
            UnitHasBuffState.matched = false
            CheckAuraSpellId_ByIndex()
            if UnitHasBuffState.matched then
                if debug then print("|cff00ff00DF:|r   -> Found via GetAuraDataByIndex at slot " .. i) end
                return true
            end
        end
    end

    if debug then print("|cff00ff00DF:|r   -> NOT FOUND") end
    return false
end

-- Per-frame throttle tracking for missing buff updates (kept for UpdateAllMissingBuffIcons)
local missingBuffThrottle = {}

function DF:UpdateMissingBuffIcon(frame)
    if not frame or not frame.unit or not frame.missingBuffFrame then return end
    
    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableMissingBuff then
        frame.missingBuffFrame:Hide()
        return
    end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    
    -- Check if feature is disabled
    if not db.missingBuffIconEnabled then
        frame.missingBuffFrame:Hide()
        return
    end
    
    local unit = frame.unit
    
    -- Hide for dead or offline units
    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        frame.missingBuffFrame:Hide()
        missingBuffCache[frame] = nil
        return
    end
    
    -- Hide for units that don't exist
    if not UnitExists(unit) then
        frame.missingBuffFrame:Hide()
        missingBuffCache[frame] = nil
        return
    end

    -- Hide for out-of-range units (can't reliably query their buffs)
    local inRange = frame.dfInRange
    if issecretvalue and issecretvalue(inRange) then
        -- Secret value = can't tell, hide to be safe
        frame.missingBuffFrame:Hide()
        missingBuffCache[frame] = nil
        return
    elseif inRange == false then
        frame.missingBuffFrame:Hide()
        missingBuffCache[frame] = nil
        return
    end

    -- Hide for non-player units (NPCs, followers, pets can't have raid buffs)
    if not UnitIsPlayer(unit) then
        frame.missingBuffFrame:Hide()
        missingBuffCache[frame] = nil
        return
    end
    
    -- Check for missing buffs
    local missingSpellID = nil
    local missingIcon = nil
    
    -- Use cached player class (computed once at load)
    local playerBuffKey = db.missingBuffClassDetection and DF.ClassToRaidBuff[cachedPlayerClass]
    
    -- PERF: Use numeric for loop instead of ipairs (avoids iterator allocation)
    local raidBuffs = DF.RaidBuffs
    for i = 1, #raidBuffs do
        local buffInfo = raidBuffs[i]
        local spellIDOrTable, configKey, name, buffClass = buffInfo[1], buffInfo[2], buffInfo[3], buffInfo[4]
        
        -- Determine if we should check this buff
        local shouldCheck = false
        if db.missingBuffClassDetection then
            -- Class detection mode: only check YOUR class's raid buff
            shouldCheck = (configKey == playerBuffKey)
        else
            -- Manual mode: check if this buff type is enabled in settings
            shouldCheck = db[configKey]
        end
        
        if shouldCheck then
            -- Use our helper function to check for the buff (supports single ID or table of IDs)
            local hasBuff = DF:UnitHasBuff(unit, spellIDOrTable, name)
            
            if not hasBuff then
                -- Get the first spell ID for getting the icon
                missingSpellID = type(spellIDOrTable) == "table" and spellIDOrTable[1] or spellIDOrTable
                -- Use cached icon lookup
                missingIcon = GetCachedSpellIcon(missingSpellID)
                break  -- Show first missing buff
            end
        end
    end
    
    -- CACHING: Check if the missing buff state changed
    local cachedMissing = missingBuffCache[frame]
    if cachedMissing == missingSpellID then
        -- No change - skip all visual updates
        return
    end
    
    -- Update cache
    missingBuffCache[frame] = missingSpellID
    
    if missingSpellID and missingIcon then
        -- Show the missing buff icon
        frame.missingBuffIcon:SetTexture(missingIcon)
        
        -- Apply border if enabled
        local showBorder = db.missingBuffIconShowBorder ~= false
        if showBorder then
            -- PERF: Use module-level default instead of inline table
            local bc = db.missingBuffIconBorderColor or DEFAULT_MISSING_BUFF_BORDER_COLOR
            local borderSize = db.missingBuffIconBorderSize or 2
            
            -- Apply pixel perfect to border size 
            if db.pixelPerfect then
                borderSize = DF:PixelPerfect(borderSize)
            end
            
            -- Set color on all border edges
            if frame.missingBuffBorderLeft then
                frame.missingBuffBorderLeft:SetColorTexture(bc.r, bc.g, bc.b, bc.a)
                frame.missingBuffBorderLeft:SetWidth(borderSize)
                frame.missingBuffBorderLeft:Show()
            end
            if frame.missingBuffBorderRight then
                frame.missingBuffBorderRight:SetColorTexture(bc.r, bc.g, bc.b, bc.a)
                frame.missingBuffBorderRight:SetWidth(borderSize)
                frame.missingBuffBorderRight:Show()
            end
            if frame.missingBuffBorderTop then
                frame.missingBuffBorderTop:SetColorTexture(bc.r, bc.g, bc.b, bc.a)
                frame.missingBuffBorderTop:SetHeight(borderSize)
                frame.missingBuffBorderTop:ClearAllPoints()
                frame.missingBuffBorderTop:SetPoint("TOPLEFT", borderSize, 0)
                frame.missingBuffBorderTop:SetPoint("TOPRIGHT", -borderSize, 0)
                frame.missingBuffBorderTop:Show()
            end
            if frame.missingBuffBorderBottom then
                frame.missingBuffBorderBottom:SetColorTexture(bc.r, bc.g, bc.b, bc.a)
                frame.missingBuffBorderBottom:SetHeight(borderSize)
                frame.missingBuffBorderBottom:ClearAllPoints()
                frame.missingBuffBorderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
                frame.missingBuffBorderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
                frame.missingBuffBorderBottom:Show()
            end
            
            -- Adjust icon position for border
            frame.missingBuffIcon:ClearAllPoints()
            frame.missingBuffIcon:SetPoint("TOPLEFT", borderSize, -borderSize)
            frame.missingBuffIcon:SetPoint("BOTTOMRIGHT", -borderSize, borderSize)
        else
            -- Hide all border edges
            if frame.missingBuffBorderLeft then frame.missingBuffBorderLeft:Hide() end
            if frame.missingBuffBorderRight then frame.missingBuffBorderRight:Hide() end
            if frame.missingBuffBorderTop then frame.missingBuffBorderTop:Hide() end
            if frame.missingBuffBorderBottom then frame.missingBuffBorderBottom:Hide() end
            frame.missingBuffIcon:ClearAllPoints()
            frame.missingBuffIcon:SetPoint("TOPLEFT", 0, 0)
            frame.missingBuffIcon:SetPoint("BOTTOMRIGHT", 0, 0)
        end
        
        -- Apply positioning
        local scale = db.missingBuffIconScale or 1.5
        local anchor = db.missingBuffIconAnchor or "CENTER"
        local x = db.missingBuffIconX or 0
        local y = db.missingBuffIconY or 0
        
        frame.missingBuffFrame:SetScale(scale)
        frame.missingBuffFrame:ClearAllPoints()
        frame.missingBuffFrame:SetPoint(anchor, frame, anchor, x, y)
        
        -- Apply frame level (controls layering within strata)
        local frameLevel = db.missingBuffIconFrameLevel or 0
        if frameLevel == 0 then
            -- "Auto" - use default relative to content overlay
            frame.missingBuffFrame:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 10)
        else
            frame.missingBuffFrame:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
        end
        
        frame.missingBuffFrame:Show()
        
        -- Apply OOR alpha immediately after showing (the range timer won't
        -- re-trigger if the unit's range state hasn't changed)
        if DF.UpdateMissingBuffAppearance then
            DF:UpdateMissingBuffAppearance(frame)
        end
    else
        frame.missingBuffFrame:Hide()
    end
end

-- Update missing buff icons for all frames (called on a timer, out of combat only)
function DF:UpdateAllMissingBuffIcons()
    -- Clear caches so display-setting changes (border toggle, color, etc.) re-render
    wipe(missingBuffCache)
    wipe(missingBuffThrottle)
    
    -- Check if in test mode - use test update functions instead
    if DF.testMode or DF.raidTestMode then
        if DF.UpdateAllTestMissingBuff then
            DF:UpdateAllTestMissingBuff()
        end
        return
    end
    
    -- Throttle updates to avoid spam (0.1 second minimum between updates)
    local now = GetTime()
    if DF.lastMissingBuffUpdate and (now - DF.lastMissingBuffUpdate) < 0.1 then
        return
    end
    DF.lastMissingBuffUpdate = now
    
    local function updateFrame(frame)
        if frame and frame:IsShown() then
            DF:UpdateMissingBuffIcon(frame)
        end
    end
    
    -- Party frames via iterator
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(updateFrame)
    end
    
    -- Raid frames via iterator
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(updateFrame)
    end
end

-- ========================================
-- DEFENSIVE ICON
-- ========================================

-- Update defensive icon for a single frame
-- Uses Blizzard's CenterDefensiveBuff cache - they decide which defensive to show
function DF:UpdateDefensiveBar(frame)
    if not frame or not frame.unit or not frame.defensiveIcon then return end
    
    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableDefensive then
        frame.defensiveIcon:Hide()
        return
    end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    local unit = frame.unit
    
    -- Check if feature is enabled
    if not db.defensiveIconEnabled then
        frame.defensiveIcon:Hide()
        return
    end
    
    -- Check if unit exists
    if not UnitExists(unit) then
        frame.defensiveIcon:Hide()
        return
    end

    -- Ensure cache.defensives is populated for this unit.
    --
    -- Direct mode (Fix A commit 3): PopulateDefensiveCache is a cheap
    -- no-op — cache.defensives is maintained incrementally by
    -- ScanUnitFull / ApplyAuraDelta via the ClassifyAura defensive
    -- filter pass, and this early-returns when cache.hasFullScan is
    -- true (the common case in steady-state combat).
    --
    -- Blizzard mode (will be removed by Blizzard in 12.0.5 next week):
    -- PopulateDefensiveCache still runs the legacy GetUnitAuras scan
    -- because CaptureAurasFromBlizzardFrame doesn't populate
    -- cache.defensives itself. See the TODO in PopulateDefensiveCache
    -- for the post-removal cleanup.
    if DF.PopulateDefensiveCache then
        DF:PopulateDefensiveCache(unit)
    end

    -- Defensive icons always use the multi-defensive renderer regardless of
    -- the user's aura source mode.
    local cache = DF.BlizzardAuraCache and DF.BlizzardAuraCache[unit]
    do
        local maxDefs = db.defensiveBarMax or 4
        local iconSize = db.defensiveIconSize or 24
        local borderSize = db.defensiveIconBorderSize or 2
        local borderColor = db.defensiveIconBorderColor or DEFAULT_DEFENSIVE_BORDER_COLOR
        local showBorder = db.defensiveIconShowBorder ~= false
        local showDuration = db.defensiveIconShowDuration ~= false
        local durationScale = db.defensiveIconDurationScale or 1.0
        local durationFont = db.defensiveIconDurationFont or "Fonts\\FRIZQT__.TTF"
        local durationOutline = db.defensiveIconDurationOutline or "OUTLINE"
        if durationOutline == "NONE" then durationOutline = "" end
        local durationX = db.defensiveIconDurationX or 0
        local durationY = db.defensiveIconDurationY or 0
        local durationColor = db.defensiveIconDurationColor or DEFAULT_DEFENSIVE_DURATION_COLOR
        local anchor = db.defensiveIconAnchor or "CENTER"
        local baseX = db.defensiveIconX or 0
        local baseY = db.defensiveIconY or 0
        local scale = db.defensiveIconScale or 1.0
        local spacing = db.defensiveBarSpacing or 2
        local growth = db.defensiveBarGrowth or "RIGHT_DOWN"
        local wrap = db.defensiveBarWrap or 5

        if db.pixelPerfect then
            borderSize = DF:PixelPerfect(borderSize)
            iconSize = DF:PixelPerfect(iconSize)
        end

        -- Parse compound growth direction (PRIMARY_SECONDARY)
        local primary, secondary = strsplit("_", growth)
        primary = primary or "RIGHT"
        secondary = secondary or "DOWN"

        -- Calculate growth offsets using scaled size (same pattern as buff/debuff icons)
        local scaledSize = iconSize * scale
        local primaryX, primaryY = GetDefensiveGrowthOffset(primary, iconSize, spacing)
        local secondaryX, secondaryY = GetDefensiveGrowthOffset(secondary, iconSize, spacing)

        local count = 0
        local adIDs = frame.dfAD_activeInstanceIDs  -- Aura Designer dedup
        if cache and cache.defensives then
            -- Sort by spell ID so defensives get stable slot indices across frames.
            local sortedIds = {}
            for id in pairs(cache.defensives) do sortedIds[#sortedIds+1] = id end
            table.sort(sortedIds)
            for _, id in ipairs(sortedIds) do
                if count >= maxDefs then break end
                -- Skip defensives already shown by Aura Designer
                if adIDs and adIDs[id] then
                    -- dedup: Aura Designer is handling this aura
                elseif not C_UnitAuras.GetAuraDataByAuraInstanceID(unit, id) then
                    cache.defensives[id] = nil
                else
                    count = count + 1
                    local icon = GetOrCreateDefensiveBarIcon(frame, count)
                    RenderDefensiveBarIcon(icon, unit, id, db, iconSize, borderSize, borderColor, showBorder, showDuration, durationScale, durationFont, durationOutline, durationX, durationY, durationColor)

                    -- Position the icon using wrap grid layout (same as buff/debuff icons)
                    local idx = count - 1  -- 0-based for offset calculation
                    local row = floor(idx / wrap)
                    local col = idx % wrap

                    local offsetX = (col * primaryX) + (row * secondaryX)
                    local offsetY = (col * primaryY) + (row * secondaryY)

                    icon:SetScale(scale)
                    icon:ClearAllPoints()
                    icon:SetPoint(anchor, frame, anchor, baseX + offsetX, baseY + offsetY)

                    -- Frame level
                    local frameLevel = db.defensiveIconFrameLevel or 0
                    if frameLevel == 0 then
                        icon:SetFrameLevel(frame.contentOverlay:GetFrameLevel() + 15)
                    else
                        icon:SetFrameLevel(frame:GetFrameLevel() + frameLevel)
                    end
                end
            end
        end

        -- CENTER growth: second pass to center icons within each row/column
        -- Mirrors DF:RepositionCenterGrowthIcons from Features/Auras.lua
        if primary == "CENTER" and count > 0 then
            local isHorizontalGrowth = (secondary == "LEFT" or secondary == "RIGHT")

            if isHorizontalGrowth then
                -- Vertical stacking (centered), horizontal column growth
                local secX = secondaryX
                for i = 1, count do
                    local icon = GetOrCreateDefensiveBarIcon(frame, i)
                    local idx = i - 1
                    local col = floor(idx / wrap)
                    local row = idx % wrap
                    local iconsInCol = math.min(wrap, count - (col * wrap))
                    local centerOffset = (iconsInCol - 1) * (iconSize + spacing) / 2
                    local x = baseX + (col * secX)
                    local y = baseY - (row * (iconSize + spacing)) + centerOffset
                    icon:ClearAllPoints()
                    icon:SetPoint(anchor, frame, anchor, x, y)
                end
            else
                -- Horizontal stacking (centered), vertical row growth
                local secY = secondaryY
                for i = 1, count do
                    local icon = GetOrCreateDefensiveBarIcon(frame, i)
                    local idx = i - 1
                    local row = floor(idx / wrap)
                    local col = idx % wrap
                    local iconsInRow = math.min(wrap, count - (row * wrap))
                    local centerOffset = (iconsInRow - 1) * (iconSize + spacing) / 2
                    local x = baseX + (col * (iconSize + spacing)) - centerOffset
                    local y = baseY + (row * secY)
                    icon:ClearAllPoints()
                    icon:SetPoint(anchor, frame, anchor, x, y)
                end
            end
        end

        -- Hide remaining icons
        for i = count + 1, maxDefs do
            HideDefensiveBarIcon(frame, i)
        end

        -- If no defensives found, hide the primary icon too
        if count == 0 then
            frame.defensiveIcon:Hide()
        end

        -- Apply range-based fading to shown icons
        if count > 0 and DF.UpdateDefensiveIconAppearance then
            DF:UpdateDefensiveIconAppearance(frame)
        end

        return
    end

    -- (Legacy single-icon BLIZZARD branch removed — all defensive rendering
    -- now goes through the multi-defensive renderer above. The defensive
    -- cache is populated identically in both modes via the secret-safe
    -- IsAuraFilteredOutByInstanceID Direct API.)
end

-- Update defensive icons for all frames
function DF:UpdateAllDefensiveBars()
    -- Check if in test mode - use test update functions instead
    if DF.testMode or DF.raidTestMode then
        if DF.UpdateAllTestDefensiveBar then
            DF:UpdateAllTestDefensiveBar()
        end
        return
    end
    
    local function updateFrame(frame)
        if frame and frame:IsShown() then
            DF:UpdateDefensiveBar(frame)
        end
    end
    
    -- Party frames via iterator
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(updateFrame)
    end
    
    -- Raid frames via iterator
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(updateFrame)
    end
end

-- Hide all defensive icons
function DF:HideAllDefensiveBars()
    local function hideFrame(frame)
        if frame and frame.defensiveIcon then
            frame.defensiveIcon:Hide()
        end
        -- Also hide multi-defensive bar icons
        if frame and frame.defensiveBarIcons then
            for _, icon in pairs(frame.defensiveBarIcons) do
                icon:Hide()
            end
        end
    end
    
    -- Party frames via iterator
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(hideFrame)
    end
    
    -- Raid frames via iterator
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(hideFrame)
    end
end

-- Legacy function for backwards compatibility
function DF:UpdateExternalDefIcon(frame)
    -- Redirect to new defensive bar
    DF:UpdateDefensiveBar(frame)
end

-- Legacy function for backwards compatibility
function DF:UpdateAllExternalDefIcons()
    DF:UpdateAllDefensiveBars()
end

-- Legacy function for backwards compatibility
function DF:HideAllExternalDefIcons()
    DF:HideAllDefensiveBars()
end

function DF:UpdateAuras(frame)
    if DF.RosterDebugCount then DF:RosterDebugCount("UpdateAuras") end
    if not frame or not frame.unit then return end
    
    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableAuras then return end
    
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    
    if db.showBuffs then
        DF:UpdateAuraIcons(frame, frame.buffIcons, "HELPFUL", db.buffMax or 4)
    else
        for _, icon in ipairs(frame.buffIcons) do icon:Hide() end
    end
    
    if db.showDebuffs then
        DF:UpdateAuraIcons(frame, frame.debuffIcons, "HARMFUL", db.debuffMax or 4)
    else
        for _, icon in ipairs(frame.debuffIcons) do icon:Hide() end
    end
end

-- Update auras on all frames (used when entering/leaving combat)
function DF:UpdateAllAuras()
    local function updateFrame(frame)
        if frame and frame:IsShown() then
            DF:UpdateAuras(frame)
        end
    end
    
    -- Party frames via iterator
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(updateFrame)
    end
    
    -- Raid frames via iterator
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(updateFrame)
    end
    
    -- Pinned frames
    if DF.PinnedFrames and DF.PinnedFrames.initialized and DF.PinnedFrames.headers then
        for setIndex = 1, 2 do
            local header = DF.PinnedFrames.headers[setIndex]
            if header then
                for i = 1, 40 do
                    local child = header:GetAttribute("child" .. i)
                    if child then
                        updateFrame(child)
                    end
                end
            end
        end
    end

    -- Also update pinned boss frames
    if DF.PinnedFrames and DF.PinnedFrames.bossFrames then
        for setIndex = 1, 2 do
            local frames = DF.PinnedFrames.bossFrames[setIndex]
            if frames then
                for i = 1, 8 do
                    updateFrame(frames[i])
                end
            end
        end
    end
end

-- Update click-through state on all aura icons (used when combat state changes)
function DF:UpdateAuraClickThrough()
    -- Use SetMouseClickEnabled(false) to allow tooltips while passing clicks through
    -- This is Cell's approach for click-casting compatibility with tooltips
    -- If DisableMouse is enabled, use EnableMouse(false) for complete click-through (no tooltips)
    
    local function updateFrameClickThrough(frame)
        if not frame then return end
        local db = DF:GetFrameDB(frame)
        
        -- Update buff icons
        if frame.buffIcons then
            local disableMouse = db.buffDisableMouse
            for _, icon in ipairs(frame.buffIcons) do
                if icon then
                    if disableMouse then
                        -- Complete click-through - no mouse interaction at all
                        icon:EnableMouse(false)
                    else
                        -- Allow tooltips but pass clicks/motion through to parent for bindings
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
                    end
                end
            end
        end
        
        -- Update debuff icons
        if frame.debuffIcons then
            local disableMouse = db.debuffDisableMouse
            for _, icon in ipairs(frame.debuffIcons) do
                if icon then
                    if disableMouse then
                        -- Complete click-through - no mouse interaction at all
                        icon:EnableMouse(false)
                    else
                        -- Allow tooltips but pass clicks/motion through to parent for bindings
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
                    end
                end
            end
        end
        
        -- Update defensive icon
        if frame.defensiveIcon then
            local disableMouse = db.defensiveIconDisableMouse
            if disableMouse then
                -- Complete click-through - no mouse interaction at all
                frame.defensiveIcon:EnableMouse(false)
            else
                -- Allow tooltips but pass clicks/motion through to parent for bindings
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
            end
        end

        -- Update defensive bar icons (2nd+ icons in the defensive bar)
        if frame.defensiveBarIcons then
            local disableMouse = db.defensiveIconDisableMouse
            for _, icon in pairs(frame.defensiveBarIcons) do
                if icon then
                    if disableMouse then
                        icon:EnableMouse(false)
                    else
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
                    end
                end
            end
        end

        -- Update targeted spell icons
        if frame.targetedSpellIcons then
            local disableMouse = db.targetedSpellDisableMouse
            for _, icon in ipairs(frame.targetedSpellIcons) do
                if icon and icon.iconFrame then
                    if disableMouse then
                        -- Complete click-through - no mouse interaction at all
                        icon:EnableMouse(false)
                        icon.iconFrame:EnableMouse(false)
                    else
                        -- Allow tooltips but pass clicks/motion through to parent for bindings
                        icon:EnableMouse(true)
                        icon.iconFrame:EnableMouse(true)
                        if icon.SetPropagateMouseMotion then
                            icon:SetPropagateMouseMotion(true)
                        end
                        if icon.SetPropagateMouseClicks then
                            icon:SetPropagateMouseClicks(true)
                        end
                        if icon.iconFrame.SetPropagateMouseMotion then
                            icon.iconFrame:SetPropagateMouseMotion(true)
                        end
                        if icon.iconFrame.SetPropagateMouseClicks then
                            icon.iconFrame:SetPropagateMouseClicks(true)
                        end
                        if icon.SetMouseClickEnabled then
                            icon:SetMouseClickEnabled(false)
                        end
                        if icon.iconFrame.SetMouseClickEnabled then
                            icon.iconFrame:SetMouseClickEnabled(false)
                        end
                    end
                end
            end
        end
    end
    
    -- Party frames via iterator
    if DF.IteratePartyFrames then
        DF:IteratePartyFrames(updateFrameClickThrough)
    end
    
    -- Raid frames via iterator
    if DF.IterateRaidFrames then
        DF:IterateRaidFrames(updateFrameClickThrough)
    end
end

function DF:UpdateAuraIcons(frame, icons, filter, maxAuras)
    -- Don't read aura data during combat - it may be protected
    -- Event-driven updates will handle it when safe
    if InCombatLockdown() then
        return
    end
    
    local unit = frame.unit
    -- Use raid DB for raid frames, party DB for party frames
    local db = DF:GetFrameDB(frame)
    local index = 1
    local auraSlot = 1
    
    -- Get raid buff icons for filtering (only out of combat, not in encounter, when option enabled)
    -- We use icons because spellId is protected, but icon texture is accessible
    -- DF.raidBuffFilteringReady is set at PLAYER_LOGIN to avoid secret value errors during ADDON_LOADED
    local raidBuffIcons = nil
    local inEncounter = IsEncounterInProgress and IsEncounterInProgress()
    local shouldFilterRaidBuffs = filter == "HELPFUL" and db.missingBuffHideFromBar and DF.raidBuffFilteringReady and not InCombatLockdown() and not inEncounter
    if shouldFilterRaidBuffs then
        raidBuffIcons = DF:GetRaidBuffIcons()
    end
    
    -- Determine aura filter based on checkbox settings
    local auraFilter
    if filter == "HELPFUL" then
        -- Build filter string from checkbox settings
        auraFilter = "HELPFUL"
        if db.buffFilterPlayer then
            auraFilter = auraFilter .. "|PLAYER"
        end
        if db.buffFilterRaid then
            auraFilter = auraFilter .. "|RAID"
        end
        if db.buffFilterCancelable then
            auraFilter = auraFilter .. "|CANCELABLE"
        end
    elseif filter == "HARMFUL" then
        if db.debuffShowAll then
            auraFilter = "HARMFUL"
        else
            auraFilter = "HARMFUL|RAID"
        end
    else
        auraFilter = filter
    end
    
    while index <= maxAuras and auraSlot <= 40 do
        local auraData = nil
        
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            auraData = C_UnitAuras.GetAuraDataByIndex(unit, auraSlot, auraFilter)
        end
        
        if not auraData then
            break
        end
        
        -- Check if we should skip this aura (raid buff filtering via icon match)
        local skipAura = false
        if shouldFilterRaidBuffs and raidBuffIcons then
            -- Try to get icon - this is accessible even when other fields are protected
            local auraIconTexture = nil
            pcall(function()
                auraIconTexture = auraData.icon
            end)
            -- Check for secret value before using as table index
            if auraIconTexture and not issecretvalue(auraIconTexture) and raidBuffIcons[auraIconTexture] then
                skipAura = true
            end
        end
        
        if skipAura then
            -- Skip this aura, move to next slot but don't increment display index
            auraSlot = auraSlot + 1
        else
            local auraIcon = icons[index]
            local canDisplay = false
            
            -- Try to set texture - if it succeeds, we can display
            local ok = pcall(function()
                auraIcon.texture:SetTexture(auraData.icon)
            end)
            if ok then
                canDisplay = true
            end
            
            -- Only proceed if we could access the icon
            if canDisplay then
                -- Store aura data for tooltip (only store safe values, not secrets)
                auraIcon.auraData = {
                    index = auraSlot,
                    auraInstanceID = nil,  -- Will try to get this
                }
                
                -- Try to get auraInstanceID for tooltip
                local auraInstanceID = nil
                pcall(function()
                    auraInstanceID = auraData.auraInstanceID
                    auraIcon.auraData.auraInstanceID = auraInstanceID
                end)
                
                -- Set cooldown (secret-safe via Duration objects)
                pcall(function()
                    if unit and auraInstanceID
                       and C_UnitAuras.GetAuraDuration
                       and auraIcon.cooldown.SetCooldownFromDurationObject then
                        local durationObj = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
                        if durationObj then
                            auraIcon.cooldown:SetCooldownFromDurationObject(durationObj)
                            return
                        end
                    end
                    -- Fallback for non-secret values
                    if auraData.expirationTime and auraData.duration
                       and not issecretvalue(auraData.expirationTime) and not issecretvalue(auraData.duration)
                       and auraIcon.cooldown.SetCooldownFromExpirationTime then
                        auraIcon.cooldown:SetCooldownFromExpirationTime(auraData.expirationTime, auraData.duration)
                    end
                end)
                
                -- Show/hide cooldown based on whether aura expires
                if auraInstanceID and C_UnitAuras and C_UnitAuras.DoesAuraHaveExpirationTime then
                    local hasExpiration = C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraInstanceID)
                    if auraIcon.cooldown.SetShownFromBoolean then
                        auraIcon.cooldown:SetShownFromBoolean(hasExpiration, true, false)
                    end
                end
                
                -- Set stack count using new API if available
                auraIcon.count:SetText("")  -- Default to empty
                if auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraApplicationDisplayCount then
                    local success, stackText = pcall(C_UnitAuras.GetAuraApplicationDisplayCount, unit, auraInstanceID, 2, 99)
                    if success and stackText then
                        auraIcon.count:SetText(stackText)
                    end
                else
                    -- Fallback: try comparison (may fail with secrets)
                    pcall(function()
                        local count = auraData.applications
                        if count > 1 then
                            auraIcon.count:SetText(count)
                        end
                    end)
                end
                
                -- Border color for debuffs - set default first, then try to get type
                if filter == "HARMFUL" then
                    auraIcon.border:SetColorTexture(0.8, 0, 0, 0.8)  -- Default red
                    pcall(function()
                        local color = DebuffTypeColor[auraData.dispelName]
                        if color then
                            auraIcon.border:SetColorTexture(color.r, color.g, color.b, 0.8)
                        end
                    end)
                else
                    auraIcon.border:SetColorTexture(0, 0, 0, 0.8)
                end
                
                auraIcon:Show()
                index = index + 1
            end
            
            auraSlot = auraSlot + 1
        end
    end
    
    for i = index, #icons do
        icons[i].auraData = nil
        icons[i]:Hide()
    end
end

