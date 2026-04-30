local addonName, DF = ...

-- ============================================================
-- TARGETED SPELLS SYSTEM
-- Shows incoming spell casts targeting party/raid members
-- 
-- When an enemy casts a spell targeting a party member, this
-- displays an icon with cast bar on that member's frame to
-- warn healers of incoming damage.
--
-- Supports multiple simultaneous incoming spells with stacking.
-- Features:
--   - Highlight important spells (C_Spell.IsSpellImportant)
--   - Sort by cast time (newest/oldest first)
--   - Max icons limit
--   - Interrupted visual feedback
--   - Off-screen nameplate support
-- ============================================================

local pairs, ipairs, wipe = pairs, ipairs, wipe
local GetTime = GetTime
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitGUID = UnitGUID
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitCastingDuration = UnitCastingDuration
local UnitChannelDuration = UnitChannelDuration
local UnitCanAttack = UnitCanAttack
local C_Spell = C_Spell
local C_CVar = C_CVar

-- Track all enemy casters we're monitoring
-- Structure: activeCasters[casterUnit] = { startTime = time, spellID = id, isChannel = bool }
-- Using unit token (e.g. "nameplate7") as key instead of GUID because GUIDs are secret values
local activeCasters = {}

-- ============================================================
-- API COMPATIBILITY: Group-frame targeted spells (PERMANENTLY DISABLED)
-- ------------------------------------------------------------
-- Blizzard hotfixed UnitIsUnit on 2026-04-07 so that comparing a
-- compound token like "nameplateXtarget" against a party/raid
-- token now returns nil. That kills our per-frame "is this enemy
-- targeting THIS party member" detection.
--
-- There is no in-addon workaround:
--   * UnitGUID/UnitName on nameplate units become secret in
--     instance combat, so we can't compare those either.
--   * The new PlayerIsSpellTarget API only answers for the player,
--     not for arbitrary group members.
--
-- The change is now live on retail. Group-frame Targeted Spells is
-- force-disabled unconditionally at addon load. The personal-display
-- path (compares against "player") still works and is unaffected,
-- since "player" is in the always-allowed list of UnitIsUnit args.
--
-- A "Targeted List" feature is being designed as a replacement for
-- the per-frame icon use case (see _Reference/targeted-list-mockup.html).
-- ============================================================

-- Permanent in-memory flag — not persisted, not detected, just on.
DF.GroupTargetedSpellsAPIBlocked = true

-- Force-disables the group-frame targetedSpellEnabled setting on both
-- party and raid profiles for the current profile. Called from Init,
-- so the GUI reflects the disabled state on every load.
local function ForceDisableGroupTargetedSpellSettings()
    if not DF.db then return end
    if DF.db.party then DF.db.party.targetedSpellEnabled = false end
    if DF.db.raid then DF.db.raid.targetedSpellEnabled = false end
end

-- Personal display variables (declared early for HandleTargetChange access)
local personalContainer = nil
local personalIcons = {}
local personalActiveSpells = {}

-- Cast history for learning/review (test feature)
-- Stores recent enemy casts with targeting info
local castHistory = {}
local MAX_HISTORY = 50

-- Event frame for tracking casts
local eventFrame = CreateFrame("Frame")
eventFrame:Hide()

-- ============================================================
-- HIGHLIGHT STYLE ANIMATIONS
-- ============================================================

-- Animation settings for marching ants
local ANIM_SPEED = 40
local DASH_LENGTH = 4
local GAP_LENGTH = 4
local PATTERN_LENGTH = DASH_LENGTH + GAP_LENGTH

-- Global animator for marching ants and pulse on targeted spell icons
local TargetedSpellAnimator = CreateFrame("Frame")
TargetedSpellAnimator.elapsed = 0
TargetedSpellAnimator.frames = {}
TargetedSpellAnimator.pulseFrames = {}
TargetedSpellAnimator.hasWork = false  -- Track whether any frames are registered

local function TargetedSpellAnimator_OnUpdate(self, elapsed)
    -- PERF TEST: Skip animations if disabled
    if DF.PerfTest and not DF.PerfTest.enableAnimations then return end
    
    -- Marching ants animation
    self.elapsed = self.elapsed + elapsed
    local offset = (self.elapsed * ANIM_SPEED) % PATTERN_LENGTH
    for highlightFrame in pairs(self.frames) do
        if highlightFrame:IsShown() and highlightFrame.animBorder then
            DF:UpdateTargetedSpellAnimatedBorder(highlightFrame, offset)
        end
    end
    
    -- Pulse animation (animates border texture alpha, not frame alpha)
    for highlightFrame in pairs(self.pulseFrames) do
        if highlightFrame:IsShown() and highlightFrame.pulseState and highlightFrame.glowBorder then
            local state = highlightFrame.pulseState
            state.elapsed = state.elapsed + elapsed
            
            -- Calculate current alpha based on time
            local progress = state.elapsed / state.duration
            if progress >= 1 then
                -- Reverse direction
                state.direction = -state.direction
                state.elapsed = 0
                progress = 0
            end
            
            -- Smooth interpolation (smoothstep)
            local smoothProgress = progress * progress * (3 - 2 * progress)
            
            local alpha
            if state.direction == 1 then
                alpha = state.minAlpha + (state.maxAlpha - state.minAlpha) * smoothProgress
            else
                alpha = state.maxAlpha - (state.maxAlpha - state.minAlpha) * smoothProgress
            end
            
            -- Apply alpha to border textures
            local border = highlightFrame.glowBorder
            local r = highlightFrame.pulseR or 1
            local g = highlightFrame.pulseG or 0.8
            local b = highlightFrame.pulseB or 0
            
            if border.top then border.top:SetColorTexture(r, g, b, alpha * 0.8) end
            if border.bottom then border.bottom:SetColorTexture(r, g, b, alpha * 0.8) end
            if border.left then border.left:SetColorTexture(r, g, b, alpha * 0.8) end
            if border.right then border.right:SetColorTexture(r, g, b, alpha * 0.8) end
        end
    end
end

-- Check if animator has any work to do and enable/disable accordingly
local function TargetedSpellAnimator_UpdateState()
    local hasWork = next(TargetedSpellAnimator.frames) or next(TargetedSpellAnimator.pulseFrames)
    if hasWork and not TargetedSpellAnimator.hasWork then
        TargetedSpellAnimator.hasWork = true
        TargetedSpellAnimator:SetScript("OnUpdate", TargetedSpellAnimator_OnUpdate)
    elseif not hasWork and TargetedSpellAnimator.hasWork then
        TargetedSpellAnimator.hasWork = false
        TargetedSpellAnimator:SetScript("OnUpdate", nil)
    end
end

-- Export for test mode access
DF.TargetedSpellAnimator = TargetedSpellAnimator

-- Create dashes for one edge of the animated border
local function CreateEdgeDashes(parent, count)
    local dashes = {}
    for i = 1, count do
        local dash = parent:CreateTexture(nil, "OVERLAY")
        dash:SetColorTexture(1, 1, 1, 1)
        dash:Hide()
        dashes[i] = dash
    end
    return dashes
end

-- Initialize animated border on a highlight frame
local function InitAnimatedBorder(highlightFrame)
    if highlightFrame.animBorder then return highlightFrame.animBorder end
    highlightFrame.animBorder = {
        topDashes = CreateEdgeDashes(highlightFrame, 15),
        bottomDashes = CreateEdgeDashes(highlightFrame, 15),
        leftDashes = CreateEdgeDashes(highlightFrame, 15),
        rightDashes = CreateEdgeDashes(highlightFrame, 15),
    }
    return highlightFrame.animBorder
end
DF.InitAnimatedBorder = InitAnimatedBorder

-- Update animated border with current offset
function DF:UpdateTargetedSpellAnimatedBorder(highlightFrame, offset)
    local border = highlightFrame.animBorder
    if not border then return end
    local thick = highlightFrame.animThickness or 2
    local r, g, b, a = highlightFrame.animR or 1, highlightFrame.animG or 0.8, highlightFrame.animB or 0, highlightFrame.animA or 1
    local frameWidth, frameHeight = highlightFrame:GetWidth(), highlightFrame:GetHeight()
    if frameWidth <= 0 or frameHeight <= 0 then return end

    local function DrawHorizontalEdge(dashes, isTop, edgeOffset)
        local numDashes = math.ceil(frameWidth / PATTERN_LENGTH) + 2
        for i, dash in ipairs(dashes) do dash:Hide() end
        local startPos = -(edgeOffset % PATTERN_LENGTH)
        for i = 1, numDashes do
            local dashStart = startPos + (i - 1) * PATTERN_LENGTH
            local dashEnd = dashStart + DASH_LENGTH
            local visStart, visEnd = math.max(0, dashStart), math.min(frameWidth, dashEnd)
            if visEnd > visStart and dashes[i] then
                local dash = dashes[i]
                dash:ClearAllPoints()
                dash:SetSize(visEnd - visStart, thick)
                if isTop then
                    dash:SetPoint("TOPLEFT", highlightFrame, "TOPLEFT", visStart, 0)
                else
                    dash:SetPoint("BOTTOMLEFT", highlightFrame, "BOTTOMLEFT", visStart, 0)
                end
                dash:SetColorTexture(r, g, b, a)
                dash:Show()
            end
        end
    end

    local function DrawVerticalEdge(dashes, isRight, edgeOffset)
        local numDashes = math.ceil(frameHeight / PATTERN_LENGTH) + 2
        for i, dash in ipairs(dashes) do dash:Hide() end
        local startPos = -(edgeOffset % PATTERN_LENGTH)
        for i = 1, numDashes do
            local dashStart = startPos + (i - 1) * PATTERN_LENGTH
            local dashEnd = dashStart + DASH_LENGTH
            local visStart, visEnd = math.max(0, dashStart), math.min(frameHeight, dashEnd)
            if visEnd > visStart and dashes[i] then
                local dash = dashes[i]
                dash:ClearAllPoints()
                dash:SetSize(thick, visEnd - visStart)
                if isRight then
                    dash:SetPoint("TOPRIGHT", highlightFrame, "TOPRIGHT", 0, -visStart)
                else
                    dash:SetPoint("TOPLEFT", highlightFrame, "TOPLEFT", 0, -visStart)
                end
                dash:SetColorTexture(r, g, b, a)
                dash:Show()
            end
        end
    end

    -- Counter-clockwise marching ants
    DrawHorizontalEdge(border.bottomDashes, false, offset)
    DrawVerticalEdge(border.leftDashes, false, frameWidth + offset)
    DrawHorizontalEdge(border.topDashes, true, frameWidth + frameHeight - offset)
    DrawVerticalEdge(border.rightDashes, true, (2 * frameWidth) + frameHeight - offset)
end

-- Hide animated border
local function HideAnimatedBorder(highlightFrame)
    if not highlightFrame.animBorder then return end
    for _, dashes in pairs(highlightFrame.animBorder) do
        for _, dash in ipairs(dashes) do dash:Hide() end
    end
end
DF.HideAnimatedBorder = HideAnimatedBorder

-- Create solid border (4 edge textures)
local function InitSolidBorder(highlightFrame)
    if highlightFrame.solidBorder then return highlightFrame.solidBorder end
    highlightFrame.solidBorder = {
        top = highlightFrame:CreateTexture(nil, "BORDER"),
        bottom = highlightFrame:CreateTexture(nil, "BORDER"),
        left = highlightFrame:CreateTexture(nil, "BORDER"),
        right = highlightFrame:CreateTexture(nil, "BORDER"),
    }
    return highlightFrame.solidBorder
end
DF.InitSolidBorder = InitSolidBorder

-- Update solid border
local function UpdateSolidBorder(highlightFrame, thickness, r, g, b, a)
    local border = highlightFrame.solidBorder
    if not border then return end
    
    border.top:ClearAllPoints()
    border.top:SetPoint("TOPLEFT", highlightFrame, "TOPLEFT", 0, 0)
    border.top:SetPoint("TOPRIGHT", highlightFrame, "TOPRIGHT", 0, 0)
    border.top:SetHeight(thickness)
    border.top:SetColorTexture(r, g, b, a)
    border.top:SetBlendMode("BLEND")
    border.top:Show()
    
    border.bottom:ClearAllPoints()
    border.bottom:SetPoint("BOTTOMLEFT", highlightFrame, "BOTTOMLEFT", 0, 0)
    border.bottom:SetPoint("BOTTOMRIGHT", highlightFrame, "BOTTOMRIGHT", 0, 0)
    border.bottom:SetHeight(thickness)
    border.bottom:SetColorTexture(r, g, b, a)
    border.bottom:SetBlendMode("BLEND")
    border.bottom:Show()
    
    border.left:ClearAllPoints()
    border.left:SetPoint("TOPLEFT", highlightFrame, "TOPLEFT", 0, -thickness)
    border.left:SetPoint("BOTTOMLEFT", highlightFrame, "BOTTOMLEFT", 0, thickness)
    border.left:SetWidth(thickness)
    border.left:SetColorTexture(r, g, b, a)
    border.left:SetBlendMode("BLEND")
    border.left:Show()
    
    border.right:ClearAllPoints()
    border.right:SetPoint("TOPRIGHT", highlightFrame, "TOPRIGHT", 0, -thickness)
    border.right:SetPoint("BOTTOMRIGHT", highlightFrame, "BOTTOMRIGHT", 0, thickness)
    border.right:SetWidth(thickness)
    border.right:SetColorTexture(r, g, b, a)
    border.right:SetBlendMode("BLEND")
    border.right:Show()
end
DF.UpdateSolidBorder = UpdateSolidBorder

-- Hide solid border
local function HideSolidBorder(highlightFrame)
    if not highlightFrame or not highlightFrame.solidBorder then return end
    highlightFrame.solidBorder.top:Hide()
    highlightFrame.solidBorder.bottom:Hide()
    highlightFrame.solidBorder.left:Hide()
    highlightFrame.solidBorder.right:Hide()
end
DF.HideSolidBorder = HideSolidBorder

-- Create glow border (4 edge textures with ADD blend mode for glow effect)
local function InitGlowBorder(highlightFrame)
    if highlightFrame.glowBorder then return highlightFrame.glowBorder end
    highlightFrame.glowBorder = {
        top = highlightFrame:CreateTexture(nil, "OVERLAY"),
        bottom = highlightFrame:CreateTexture(nil, "OVERLAY"),
        left = highlightFrame:CreateTexture(nil, "OVERLAY"),
        right = highlightFrame:CreateTexture(nil, "OVERLAY"),
    }
    -- Set ADD blend mode for glow effect
    for _, tex in pairs(highlightFrame.glowBorder) do
        tex:SetBlendMode("ADD")
    end
    return highlightFrame.glowBorder
end
DF.InitGlowBorder = InitGlowBorder

-- Update glow border
local function UpdateGlowBorder(highlightFrame, thickness, r, g, b, a)
    local border = highlightFrame.glowBorder
    if not border then return end
    
    border.top:ClearAllPoints()
    border.top:SetPoint("TOPLEFT", highlightFrame, "TOPLEFT", 0, 0)
    border.top:SetPoint("TOPRIGHT", highlightFrame, "TOPRIGHT", 0, 0)
    border.top:SetHeight(thickness)
    border.top:SetColorTexture(r, g, b, a)
    border.top:SetBlendMode("ADD")
    border.top:Show()
    
    border.bottom:ClearAllPoints()
    border.bottom:SetPoint("BOTTOMLEFT", highlightFrame, "BOTTOMLEFT", 0, 0)
    border.bottom:SetPoint("BOTTOMRIGHT", highlightFrame, "BOTTOMRIGHT", 0, 0)
    border.bottom:SetHeight(thickness)
    border.bottom:SetColorTexture(r, g, b, a)
    border.bottom:SetBlendMode("ADD")
    border.bottom:Show()
    
    border.left:ClearAllPoints()
    border.left:SetPoint("TOPLEFT", highlightFrame, "TOPLEFT", 0, -thickness)
    border.left:SetPoint("BOTTOMLEFT", highlightFrame, "BOTTOMLEFT", 0, thickness)
    border.left:SetWidth(thickness)
    border.left:SetColorTexture(r, g, b, a)
    border.left:SetBlendMode("ADD")
    border.left:Show()
    
    border.right:ClearAllPoints()
    border.right:SetPoint("TOPRIGHT", highlightFrame, "TOPRIGHT", 0, -thickness)
    border.right:SetPoint("BOTTOMRIGHT", highlightFrame, "BOTTOMRIGHT", 0, thickness)
    border.right:SetWidth(thickness)
    border.right:SetColorTexture(r, g, b, a)
    border.right:SetBlendMode("ADD")
    border.right:Show()
end
DF.UpdateGlowBorder = UpdateGlowBorder

-- Hide glow border
local function HideGlowBorder(highlightFrame)
    if not highlightFrame or not highlightFrame.glowBorder then return end
    highlightFrame.glowBorder.top:Hide()
    highlightFrame.glowBorder.bottom:Hide()
    highlightFrame.glowBorder.left:Hide()
    highlightFrame.glowBorder.right:Hide()
end
DF.HideGlowBorder = HideGlowBorder

-- Create pulse animation group - animates border texture alpha, not frame alpha
-- This prevents the animation from overriding SetAlphaFromBoolean on the frame
local function InitPulseAnimation(highlightFrame)
    if highlightFrame.pulseAnim then return highlightFrame.pulseAnim end
    
    -- Store pulse state on the frame
    highlightFrame.pulseState = {
        elapsed = 0,
        minAlpha = 0.3,
        maxAlpha = 1.0,
        duration = 0.5,
        direction = 1,  -- 1 = fading in, -1 = fading out
    }
    
    -- Create a dummy animation group that we use to track if pulsing is active
    local ag = {}
    ag.isPlaying = false
    ag.Play = function(self)
        self.isPlaying = true
        highlightFrame.pulseState.elapsed = 0
        highlightFrame.pulseState.direction = 1
        -- Register with animator
        TargetedSpellAnimator.pulseFrames[highlightFrame] = true
        TargetedSpellAnimator_UpdateState()
    end
    ag.Stop = function(self)
        self.isPlaying = false
        TargetedSpellAnimator.pulseFrames[highlightFrame] = nil
        TargetedSpellAnimator_UpdateState()
    end
    ag.IsPlaying = function(self)
        return self.isPlaying
    end
    
    highlightFrame.pulseAnim = ag
    return ag
end
DF.InitPulseAnimation = InitPulseAnimation



-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Get all party/raid units to check
local function GetGroupUnits()
    local units = {}
    
    -- Always include player
    table.insert(units, "player")
    
    if IsInRaid() then
        for i = 1, 40 do
            local unit = "raid" .. i
            -- Note: "raidN" tokens never equal "player" string, so simple ~= check is safe
            -- (avoids potential secret value issues with UnitIsUnit)
            if UnitExists(unit) and unit ~= "player" then
                table.insert(units, unit)
            end
        end
    else
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                table.insert(units, unit)
            end
        end
    end
    
    return units
end

-- Get current content type
-- Returns: "openworld", "dungeon", "raid", "arena", "battleground"
local function GetContentType()
    local inInstance, instanceType = IsInInstance()
    
    if not inInstance then
        return "openworld"
    end
    
    if instanceType == "party" then
        return "dungeon"
    elseif instanceType == "raid" then
        return "raid"
    elseif instanceType == "arena" then
        return "arena"
    elseif instanceType == "pvp" then
        return "battleground"
    elseif instanceType == "scenario" then
        return "dungeon"  -- Treat scenarios as dungeons
    end
    
    return "openworld"
end

-- Check if targeted spells should be shown for party/player frames based on content type
local function ShouldShowTargetedSpells(db)
    if not db.targetedSpellEnabled then return false end
    
    local contentType = GetContentType()
    
    if contentType == "openworld" then
        return db.targetedSpellInOpenWorld ~= false
    elseif contentType == "dungeon" then
        return db.targetedSpellInDungeons ~= false
    elseif contentType == "arena" then
        return db.targetedSpellInArena ~= false
    end
    
    return true  -- Default to showing
end

-- Check if targeted spells should be shown for raid frames based on content type
local function ShouldShowRaidTargetedSpells(db)
    if not db.targetedSpellEnabled then return false end
    
    local contentType = GetContentType()
    
    if contentType == "openworld" then
        return db.targetedSpellInOpenWorld ~= false
    elseif contentType == "raid" then
        return db.targetedSpellInRaids ~= false
    elseif contentType == "battleground" then
        return db.targetedSpellInBattlegrounds ~= false
    end
    
    return true  -- Default to showing
end

-- Check if personal targeted spells should be shown based on content type
local function ShouldShowPersonalTargetedSpells(db)
    if not db.personalTargetedSpellEnabled then return false end
    
    local contentType = GetContentType()
    
    if contentType == "openworld" then
        return db.personalTargetedSpellInOpenWorld ~= false
    elseif contentType == "dungeon" then
        return db.personalTargetedSpellInDungeons ~= false
    elseif contentType == "raid" then
        return db.personalTargetedSpellInRaids ~= false
    elseif contentType == "arena" then
        return db.personalTargetedSpellInArena ~= false
    elseif contentType == "battleground" then
        return db.personalTargetedSpellInBattlegrounds ~= false
    end
    
    return true  -- Default to showing
end

-- Check if a unit is valid for targeted spell tracking
-- We ONLY track nameplate units - boss/arena/target/focus all have nameplates too
-- so tracking them separately would cause duplicates
local function IsValidCasterUnit(unit)
    if not unit then return false end
    
    -- Only nameplate units
    if string.find(unit, "nameplate") then
        return true
    end
    
    return false
end

-- Get enemy units that might be casting at us
-- Note: We only track nameplates - boss/arena units have nameplates too
local function GetEnemyUnits()
    local units = {}
    
    -- Nameplates only (boss/arena/target/focus all have nameplates)
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) then
            table.insert(units, unit)
        end
    end
    
    return units
end

-- Get the frame for a unit
local function GetFrameForUnit(unit)
    -- Fast path: use unitFrameMap
    if DF.unitFrameMap and DF.unitFrameMap[unit] then
        return DF.unitFrameMap[unit]
    end
    
    local foundFrame = nil
    
    DF:IterateAllFrames(function(frame)
        if frame and frame.unit and frame.unit == unit then
            foundFrame = frame
            return true  -- Stop iteration
        end
    end)
    
    return foundFrame
end


-- ============================================================
-- ICON CREATION AND POOLING
-- ============================================================

-- Create a single targeted spell icon
local function CreateSingleIcon(parent, index)
    local container = CreateFrame("Frame", nil, parent)
    container:SetFrameLevel(parent:GetFrameLevel() + 30 + index)
    container:Hide()
    container.index = index
    
    -- Disable mouse completely - these should be click-through
    container:EnableMouse(false)
    -- Make hitbox zero so clicks pass through
    container:SetHitRectInsets(10000, 10000, 10000, 10000)
    
    -- Importance filter frame - nested inside container
    -- This allows us to filter by importance using SetAlphaFromBoolean
    -- when importantOnly is enabled, without affecting the targeting logic
    local importanceFilterFrame = CreateFrame("Frame", nil, container)
    importanceFilterFrame:SetAllPoints()
    importanceFilterFrame:EnableMouse(false)
    importanceFilterFrame:SetHitRectInsets(10000, 10000, 10000, 10000)
    container.importanceFilterFrame = importanceFilterFrame
    
    -- Icon container (with border) - now parented to importanceFilterFrame
    local iconFrame = CreateFrame("Frame", nil, importanceFilterFrame)
    iconFrame:SetSize(28, 28)
    iconFrame:EnableMouse(false)
    iconFrame:SetHitRectInsets(10000, 10000, 10000, 10000)
    container.iconFrame = iconFrame
    
    -- Icon border - 4 edge textures (consistent with defensive/missing buff icons)
    local defBorderSize = 2
    local borderLeft = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderLeft:SetPoint("TOPLEFT", 0, 0)
    borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    borderLeft:SetWidth(defBorderSize)
    borderLeft:SetColorTexture(1, 0.3, 0, 1)
    container.borderLeft = borderLeft
    iconFrame.borderLeft = borderLeft
    
    local borderRight = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderRight:SetPoint("TOPRIGHT", 0, 0)
    borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    borderRight:SetWidth(defBorderSize)
    borderRight:SetColorTexture(1, 0.3, 0, 1)
    container.borderRight = borderRight
    iconFrame.borderRight = borderRight
    
    local borderTop = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderTop:SetPoint("TOPLEFT", defBorderSize, 0)
    borderTop:SetPoint("TOPRIGHT", -defBorderSize, 0)
    borderTop:SetHeight(defBorderSize)
    borderTop:SetColorTexture(1, 0.3, 0, 1)
    container.borderTop = borderTop
    iconFrame.borderTop = borderTop
    
    local borderBottom = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderBottom:SetPoint("BOTTOMLEFT", defBorderSize, 0)
    borderBottom:SetPoint("BOTTOMRIGHT", -defBorderSize, 0)
    borderBottom:SetHeight(defBorderSize)
    borderBottom:SetColorTexture(1, 0.3, 0, 1)
    container.borderBottom = borderBottom
    iconFrame.borderBottom = borderBottom
    
    -- Important spell highlight frame - use a frame so we can SetAlphaFromBoolean
    -- Set frame level ABOVE iconFrame so it renders on top when inset
    local highlightFrame = CreateFrame("Frame", nil, iconFrame)
    highlightFrame:SetPoint("TOPLEFT", -4, 4)
    highlightFrame:SetPoint("BOTTOMRIGHT", 4, -4)
    highlightFrame:SetFrameLevel(iconFrame:GetFrameLevel() + 5)
    highlightFrame:Hide()
    highlightFrame:EnableMouse(false)
    highlightFrame:SetHitRectInsets(10000, 10000, 10000, 10000)
    container.highlightFrame = highlightFrame
    
    iconFrame.highlightFrame = highlightFrame
    
    -- Icon texture - positioned with inset for border, with TexCoord cropping
    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", defBorderSize, -defBorderSize)
    icon:SetPoint("BOTTOMRIGHT", -defBorderSize, defBorderSize)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    container.icon = icon
    iconFrame.icon = icon
    
    -- Cooldown frame for swipe animation on icon
    local cooldown = CreateFrame("Cooldown", nil, iconFrame, "CooldownFrameTemplate")
    cooldown:SetAllPoints(icon)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawSwipe(true)
    cooldown:SetReverse(true)
    cooldown:SetHideCountdownNumbers(true)  -- We use our own duration text
    cooldown:EnableMouse(false)
    cooldown:SetHitRectInsets(10000, 10000, 10000, 10000)
    container.cooldown = cooldown
    iconFrame.cooldown = cooldown
    
    -- Overlay frame for duration text (sits above cooldown swipe)
    local textOverlay = CreateFrame("Frame", nil, iconFrame)
    textOverlay:SetAllPoints()
    textOverlay:SetFrameLevel(cooldown:GetFrameLevel() + 5)
    textOverlay:EnableMouse(false)
    textOverlay:SetHitRectInsets(10000, 10000, 10000, 10000)
    container.textOverlay = textOverlay
    
    -- Custom duration text (on overlay so it's above the swipe)
    local durationText = textOverlay:CreateFontString(nil, "OVERLAY")
    DF.GUI:SetSettingsFont(durationText, 10, "OUTLINE")
    durationText:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
    durationText:SetTextColor(1, 1, 1, 1)
    container.durationText = durationText
    iconFrame.durationText = durationText
    
    -- Interrupted overlay (X mark)
    local interruptOverlay = CreateFrame("Frame", nil, iconFrame)
    interruptOverlay:SetAllPoints()
    interruptOverlay:SetFrameLevel(cooldown:GetFrameLevel() + 10)
    interruptOverlay:Hide()
    interruptOverlay:EnableMouse(false)
    interruptOverlay:SetHitRectInsets(10000, 10000, 10000, 10000)
    container.interruptOverlay = interruptOverlay
    
    -- Red tint for interrupted
    local interruptTint = interruptOverlay:CreateTexture(nil, "OVERLAY")
    interruptTint:SetAllPoints()
    interruptTint:SetColorTexture(1, 0, 0, 0.5)
    container.interruptTint = interruptTint
    
    -- X mark for interrupted
    local interruptX = interruptOverlay:CreateFontString(nil, "OVERLAY")
    DF.GUI:SetSettingsFont(interruptX, 16, "OUTLINE")
    interruptX:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
    interruptX:SetText("X")
    interruptX:SetTextColor(1, 0, 0, 1)
    container.interruptX = interruptX
    
    -- OnUpdate for cleanup checking and duration text
    local durationThrottle = 0
    container:SetScript("OnUpdate", function(self, elapsed)
        -- Skip if not active (alpha is controlled by SetAlphaFromBoolean, can't read it)
        if not self.isActive then return end
        
        -- Handle interrupted animation (needs to run every frame for smooth animation)
        if self.isInterrupted then
            self.interruptTimer = (self.interruptTimer or 0) + elapsed
            local db = self.unitFrame and DF:GetFrameDB(self.unitFrame) or DF:GetDB()
            local duration = db.targetedSpellInterruptedDuration or 0.5
            
            if self.interruptTimer >= duration then
                -- Animation complete, hide icon
                if self.unitFrame and self.casterKey then
                    DF:HideTargetedSpellIcon(self.unitFrame, self.casterKey, true)
                end
            end
            return
        end
        
        -- Throttle duration text updates to ~10 FPS for performance
        durationThrottle = durationThrottle + elapsed
        if durationThrottle < 0.1 then return end
        durationThrottle = 0
        
        -- Update duration text from duration object
        -- Note: GetRemainingDuration returns a secret value so we can't compare it
        -- Just display it and use a fixed color from settings
        -- TODO: Can use durationObject:EvaluateRemainingPercent(colorCurve) for dynamic color-by-time
        -- similar to how aura icons do it in Frames/Create.lua
        if self.durationObject and self.durationText then
            local ok, remaining = pcall(self.durationObject.GetRemainingDuration, self.durationObject)
            if ok and remaining then
                -- Use SetFormattedText which handles secret values
                self.durationText:SetFormattedText("%.1f", remaining)
                
                -- Apply the configured color (can't do color-by-time with secret values)
                if self.durationColor then
                    self.durationText:SetTextColor(self.durationColor.r, self.durationColor.g, self.durationColor.b, 1)
                end
            end
        end
        
        -- Note: We DON'T check if cast is still active here anymore
        -- Events (UNIT_SPELLCAST_STOP, INTERRUPTED, etc.) handle all cleanup
        -- This prevents race conditions with interrupt visuals
    end)
    
    return container
end

-- Ensure icon pool exists for a frame
local function EnsureIconPool(frame, count)
    -- Create OOR container if it doesn't exist
    -- This container receives out-of-range alpha, so individual icons
    -- can use SetAlphaFromBoolean for targeting without conflict
    if not frame.targetedSpellContainer then
        local container = CreateFrame("Frame", nil, frame)
        container:SetAllPoints()
        container:SetFrameLevel(frame:GetFrameLevel() + 29)
        container:EnableMouse(false)
        container:SetHitRectInsets(10000, 10000, 10000, 10000)
        frame.targetedSpellContainer = container
    end
    
    if not frame.targetedSpellIcons then
        frame.targetedSpellIcons = {}
    end
    if not frame.dfActiveTargetedSpells then
        frame.dfActiveTargetedSpells = {}
    end
    
    count = count or 5  -- Default pool size

    local existing = #frame.targetedSpellIcons
    if existing >= count then return end

    -- Raid frames: create only 1 icon now, stagger the rest to avoid
    -- "script ran too long" when 40 frames each create 5 icons simultaneously
    if frame.isRaidFrame and existing == 0 then
        frame.targetedSpellIcons[1] = CreateSingleIcon(frame.targetedSpellContainer, 1)
        frame.targetedSpellIcons[1].unitFrame = frame
        -- Schedule remaining icons one-per-timer-tick
        if not frame.dfIconPoolStaggered then
            frame.dfIconPoolStaggered = true
            for i = 2, count do
                C_Timer.After(0.05 * (i - 1), function()
                    if not frame.targetedSpellIcons then return end
                    if #frame.targetedSpellIcons >= i then return end
                    frame.targetedSpellIcons[i] = CreateSingleIcon(frame.targetedSpellContainer, i)
                    frame.targetedSpellIcons[i].unitFrame = frame
                end)
            end
        end
        return
    end

    for i = existing + 1, count do
        -- Parent icons to the OOR container, not directly to frame
        frame.targetedSpellIcons[i] = CreateSingleIcon(frame.targetedSpellContainer, i)
        frame.targetedSpellIcons[i].unitFrame = frame
    end
end

-- Expose EnsureIconPool for test mode
function DF:EnsureTargetedSpellIconPool(frame, count)
    EnsureIconPool(frame, count)
end

-- Get an available icon from the pool
local function GetAvailableIcon(frame)
    EnsureIconPool(frame, 5)
    
    for i, icon in ipairs(frame.targetedSpellIcons) do
        if not icon:IsShown() or not icon.isActive then
            return icon, i
        end
    end
    
    -- All icons in use, create a new one - parent to container
    local newIndex = #frame.targetedSpellIcons + 1
    frame.targetedSpellIcons[newIndex] = CreateSingleIcon(frame.targetedSpellContainer, newIndex)
    frame.targetedSpellIcons[newIndex].unitFrame = frame
    return frame.targetedSpellIcons[newIndex], newIndex
end

-- ============================================================
-- LAYOUT AND POSITIONING
-- ============================================================

-- Position all icons based on growth direction
-- Sorts by cast start time for consistent ordering
local function PositionIcons(frame)
    if not frame or not frame.targetedSpellIcons or not frame.dfActiveTargetedSpells then return end
    
    local db = DF:GetFrameDB(frame)
    
    local iconSize = db.targetedSpellSize or 28
    local scale = db.targetedSpellScale or 1.0
    local anchor = db.targetedSpellAnchor or "LEFT"
    local x = db.targetedSpellX or -30
    local y = db.targetedSpellY or 0
    local growthDirection = db.targetedSpellGrowth or "DOWN"
    local spacing = db.targetedSpellSpacing or 2
    local frameLevel = db.targetedSpellFrameLevel or 0
    local maxIcons = db.targetedSpellMaxIcons or 5
    -- local sortByTime = db.targetedSpellSortByTime ~= false  -- Keep for future use
    -- local newestFirst = db.targetedSpellSortNewestFirst ~= false  -- Keep for future use
    
    -- Apply pixel perfect to icon size
    if db.pixelPerfect then
        iconSize = DF:PixelPerfect(iconSize)
        spacing = DF:PixelPerfect(spacing)
    end
    
    -- Apply scale to size for positioning calculations
    local scaledSize = iconSize * scale
    local scaledSpacing = spacing * scale
    
    -- Collect active casters with their data
    local casterData = {}
    for casterKey, iconIndex in pairs(frame.dfActiveTargetedSpells) do
        local icon = frame.targetedSpellIcons[iconIndex]
        if icon and icon.isActive then
            table.insert(casterData, {
                casterKey = casterKey,
                iconIndex = iconIndex,
                startTime = icon.startTime or 0
            })
        end
    end
    
    -- Sort by caster key (unit token) for deterministic order
    -- This ensures icons don't jump around as casts end
    table.sort(casterData, function(a, b)
        return a.casterKey < b.casterKey
    end)
    
    --[[ ALTERNATIVE: Sort by time (uncomment to use)
    if sortByTime then
        table.sort(casterData, function(a, b)
            if newestFirst then
                return a.startTime > b.startTime
            else
                return a.startTime < b.startTime
            end
        end)
    end
    --]]
    
    -- Limit to max icons
    local numIcons = math.min(#casterData, maxIcons)
    
    -- Position each icon based on its sorted position
    for i = 1, #casterData do
        local data = casterData[i]
        local icon = frame.targetedSpellIcons[data.iconIndex]
        
        if icon then
            if i <= maxIcons then
                local offsetX, offsetY = 0, 0
                local index = i - 1  -- 0-based for calculation
                
                if growthDirection == "UP" then
                    offsetY = index * (scaledSize + scaledSpacing)
                elseif growthDirection == "DOWN" then
                    offsetY = -index * (scaledSize + scaledSpacing)
                elseif growthDirection == "LEFT" then
                    offsetX = -index * (scaledSize + scaledSpacing)
                elseif growthDirection == "RIGHT" then
                    offsetX = index * (scaledSize + scaledSpacing)
                elseif growthDirection == "CENTER_H" then
                    -- Grow horizontally from center
                    local centerOffset = (numIcons - 1) * (scaledSize + scaledSpacing) / 2
                    offsetX = index * (scaledSize + scaledSpacing) - centerOffset
                elseif growthDirection == "CENTER_V" then
                    -- Grow vertically from center
                    local centerOffset = (numIcons - 1) * (scaledSize + scaledSpacing) / 2
                    offsetY = index * (scaledSize + scaledSpacing) - centerOffset
                end
                
                icon:ClearAllPoints()
                icon:SetPoint(anchor, frame, anchor, x + offsetX, y + offsetY)
                icon:SetSize(scaledSize, scaledSize)
                
                -- Set frame level
                icon:SetFrameLevel(frame:GetFrameLevel() + 30 + frameLevel + data.iconIndex)
                
                -- Position icon frame within container
                icon.iconFrame:SetSize(scaledSize, scaledSize)
                icon.iconFrame:ClearAllPoints()
                icon.iconFrame:SetPoint("CENTER", icon, "CENTER", 0, 0)
                
                icon:Show()
            else
                -- Hide icons beyond max limit
                icon:Hide()
            end
        end
    end
end

-- Apply settings to a single icon
local function ApplyIconSettings(icon, db, spellID)
    local borderColor = db.targetedSpellBorderColor or {r = 1, g = 0.3, b = 0}
    local borderSize = db.targetedSpellBorderSize or 2
    local showBorder = db.targetedSpellShowBorder ~= false
    local showSwipe = not db.targetedSpellHideSwipe
    local showDuration = db.targetedSpellShowDuration ~= false
    local durationFont = db.targetedSpellDurationFont or "Fonts\\FRIZQT__.TTF"
    local durationScale = db.targetedSpellDurationScale or 1.0
    local durationOutline = db.targetedSpellDurationOutline or "OUTLINE"
    local durationX = db.targetedSpellDurationX or 0
    local durationY = db.targetedSpellDurationY or 0
    local durationColor = db.targetedSpellDurationColor or {r = 1, g = 1, b = 1}
    local alpha = db.targetedSpellAlpha or 1.0
    local highlightImportant = db.targetedSpellHighlightImportant ~= false
    local highlightStyle = db.targetedSpellHighlightStyle or "glow"
    local highlightColor = db.targetedSpellHighlightColor or {r = 1, g = 0.8, b = 0}
    local highlightSize = db.targetedSpellHighlightSize or 3
    local highlightInset = db.targetedSpellHighlightInset or 0
    local importantOnly = db.targetedSpellImportantOnly
    if durationOutline == "NONE" then durationOutline = "" end
    
    -- Apply pixel perfect to border size
    if db.pixelPerfect then
        borderSize = DF:PixelPerfect(borderSize)
    end
    
    -- Store settings on icon for OnUpdate to use
    icon.durationColor = durationColor
    icon.baseAlpha = alpha
    
    -- Important spell filter (nested frame approach)
    -- When importantOnly is enabled, use SetAlphaFromBoolean to hide non-important spells
    if icon.importanceFilterFrame then
        if importantOnly and spellID then
            local isImportant = C_Spell.IsSpellImportant(spellID)
            icon.importanceFilterFrame:SetAlphaFromBoolean(isImportant)
        else
            -- Not filtering, show everything
            icon.importanceFilterFrame:SetAlpha(1)
        end
    end
    
    -- Important spell highlight
    if icon.highlightFrame then
        -- Calculate position with inset (negative inset = larger, positive = smaller/inward)
        local offset = borderSize + highlightSize - highlightInset
        
        -- Position the highlight frame
        icon.highlightFrame:ClearAllPoints()
        icon.highlightFrame:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", -offset, offset)
        icon.highlightFrame:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", offset, -offset)
        
        -- Hide all highlight styles first
        HideAnimatedBorder(icon.highlightFrame)
        HideSolidBorder(icon.highlightFrame)
        HideGlowBorder(icon.highlightFrame)
        if icon.highlightFrame.pulseAnim then icon.highlightFrame.pulseAnim:Stop() end
        TargetedSpellAnimator.frames[icon.highlightFrame] = nil
        TargetedSpellAnimator_UpdateState()
        
        if highlightImportant and spellID and highlightStyle ~= "none" then
            local isImportant = C_Spell.IsSpellImportant(spellID)
            
            if highlightStyle == "glow" then
                -- Glow effect using edge borders with ADD blend mode
                InitGlowBorder(icon.highlightFrame)
                UpdateGlowBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 0.8)
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                
            elseif highlightStyle == "marchingAnts" then
                -- Animated marching ants border
                InitAnimatedBorder(icon.highlightFrame)
                icon.highlightFrame.animThickness = math.max(1, highlightSize)
                icon.highlightFrame.animR = highlightColor.r
                icon.highlightFrame.animG = highlightColor.g
                icon.highlightFrame.animB = highlightColor.b
                icon.highlightFrame.animA = 1
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                TargetedSpellAnimator.frames[icon.highlightFrame] = true
                TargetedSpellAnimator_UpdateState()
                
            elseif highlightStyle == "solidBorder" then
                -- Solid colored border (4 edge textures, no fill)
                InitSolidBorder(icon.highlightFrame)
                UpdateSolidBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 1)
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                
            elseif highlightStyle == "pulse" then
                -- Pulsing glow using edge borders with ADD blend
                InitGlowBorder(icon.highlightFrame)
                UpdateGlowBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 0.8)
                InitPulseAnimation(icon.highlightFrame)
                -- Store color for pulse animation to use
                icon.highlightFrame.pulseR = highlightColor.r
                icon.highlightFrame.pulseG = highlightColor.g
                icon.highlightFrame.pulseB = highlightColor.b
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                icon.highlightFrame.pulseAnim:Play()
            end
        else
            icon.highlightFrame:Hide()
        end
    end
    
    -- Border
    -- Border - 4 edge textures (consistent with defensive/missing buff icons)
    if showBorder then
        if icon.borderLeft then
            icon.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderLeft:SetWidth(borderSize)
            icon.borderLeft:Show()
        end
        if icon.borderRight then
            icon.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderRight:SetWidth(borderSize)
            icon.borderRight:Show()
        end
        if icon.borderTop then
            icon.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderTop:SetHeight(borderSize)
            icon.borderTop:ClearAllPoints()
            icon.borderTop:SetPoint("TOPLEFT", borderSize, 0)
            icon.borderTop:SetPoint("TOPRIGHT", -borderSize, 0)
            icon.borderTop:Show()
        end
        if icon.borderBottom then
            icon.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderBottom:SetHeight(borderSize)
            icon.borderBottom:ClearAllPoints()
            icon.borderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
            icon.borderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
            icon.borderBottom:Show()
        end
        
        -- Adjust icon texture position for border
        if icon.icon then
            icon.icon:ClearAllPoints()
            icon.icon:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", borderSize, -borderSize)
            icon.icon:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", -borderSize, borderSize)
        end
        
        -- Adjust cooldown to match icon texture
        if icon.cooldown then
            icon.cooldown:ClearAllPoints()
            icon.cooldown:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", borderSize, -borderSize)
            icon.cooldown:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", -borderSize, borderSize)
        end
    else
        -- Hide all border edges
        if icon.borderLeft then icon.borderLeft:Hide() end
        if icon.borderRight then icon.borderRight:Hide() end
        if icon.borderTop then icon.borderTop:Hide() end
        if icon.borderBottom then icon.borderBottom:Hide() end
        
        -- Full size icon when no border
        if icon.icon then
            icon.icon:ClearAllPoints()
            icon.icon:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", 0, 0)
            icon.icon:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", 0, 0)
        end
        
        -- Adjust cooldown to match
        if icon.cooldown then
            icon.cooldown:ClearAllPoints()
            icon.cooldown:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", 0, 0)
            icon.cooldown:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", 0, 0)
        end
    end
    
    -- Cooldown on icon (hide native countdown, we use custom)
    if icon.cooldown then
        icon.cooldown:SetDrawSwipe(showSwipe)
        icon.cooldown:SetHideCountdownNumbers(true)
    end
    
    -- Custom duration text
    if icon.durationText then
        if showDuration then
            icon.durationText:Show()
            local fontSize = 10 * durationScale
            DF:SafeSetFont(icon.durationText, durationFont, fontSize, durationOutline)
            icon.durationText:ClearAllPoints()
            icon.durationText:SetPoint("CENTER", icon.iconFrame, "CENTER", durationX, durationY)
            icon.durationText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
        else
            icon.durationText:Hide()
        end
    end
end

-- ============================================================
-- SHOW/HIDE FUNCTIONS
-- ============================================================

-- Show a targeted spell icon for a specific caster on a frame
-- casterKey is the unit token (e.g. "nameplate7") used as table key
function DF:ShowTargetedSpellIcon(frame, casterKey, casterUnit, texture, spellName, durationObject, isChannel, spellID, startTime)
    if not frame then return end
    
    -- PERF TEST: Skip if disabled
    if DF.PerfTest and not DF.PerfTest.enableTargetedSpells then return end
    
    local db = DF:GetFrameDB(frame)
    if not db.targetedSpellEnabled then return end
    
    EnsureIconPool(frame, 5)
    
    -- Check if we already have an icon for this caster (using unit token as key)
    local existingIndex = frame.dfActiveTargetedSpells[casterKey]
    local icon
    
    if existingIndex and frame.targetedSpellIcons[existingIndex] then
        icon = frame.targetedSpellIcons[existingIndex]
    else
        -- Get a new icon
        icon, existingIndex = GetAvailableIcon(frame)
        frame.dfActiveTargetedSpells[casterKey] = existingIndex
    end
    
    if not icon then return end
    
    -- Store tracking data
    icon.casterKey = casterKey  -- Unit token used as table key
    icon.casterUnit = casterUnit
    icon.spellName = spellName
    icon.spellID = spellID
    icon.isChannel = isChannel
    icon.durationObject = durationObject  -- Store for OnUpdate to get remaining time
    icon.startTime = startTime or GetTime()
    icon.isInterrupted = false
    icon.interruptTimer = nil
    
    -- Hide interrupt overlay
    if icon.interruptOverlay then
        icon.interruptOverlay:Hide()
    end
    
    -- Set icon texture
    if texture and icon.icon then
        icon.icon:SetTexture(texture)
        icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon.icon:SetDesaturated(false)
    end
    
    -- Apply settings (including important spell highlight)
    ApplyIconSettings(icon, db, spellID)
    
    -- Set up cooldown on icon
    if icon.cooldown and durationObject then
        icon.cooldown:SetCooldownFromDurationObject(durationObject)
    end
    
    -- Mark as active (for OnUpdate cleanup checks)
    icon.isActive = true
    
    -- Show the icon (alpha will be set by caller via SetAlphaFromBoolean)
    icon:Show()
    
    return icon
end

-- Show interrupted visual on an icon
local function ShowInterruptedVisual(icon, db)
    if not icon or not db.targetedSpellShowInterrupted then return end
    
    icon.isInterrupted = true
    icon.interruptTimer = 0
    
    -- Desaturate the icon
    if icon.icon then
        icon.icon:SetDesaturated(true)
    end
    
    -- Hide duration text
    if icon.durationText then
        icon.durationText:Hide()
    end
    
    -- Stop cooldown
    if icon.cooldown then
        icon.cooldown:Clear()
    end
    
    -- Apply interrupted visual settings
    local tintColor = db.targetedSpellInterruptedTintColor or {r = 1, g = 0, b = 0}
    local tintAlpha = db.targetedSpellInterruptedTintAlpha or 0.5
    local showX = db.targetedSpellInterruptedShowX ~= false
    local xColor = db.targetedSpellInterruptedXColor or {r = 1, g = 0, b = 0}
    local xSize = db.targetedSpellInterruptedXSize or 16
    
    -- Apply tint
    if icon.interruptTint then
        icon.interruptTint:SetColorTexture(tintColor.r, tintColor.g, tintColor.b, tintAlpha)
    end
    
    -- Apply X mark settings
    if icon.interruptX then
        if showX then
            icon.interruptX:Show()
            icon.interruptX:SetTextColor(xColor.r, xColor.g, xColor.b, 1)
            DF.GUI:SetSettingsFont(icon.interruptX, xSize, "OUTLINE")
        else
            icon.interruptX:Hide()
        end
    end
    
    -- Show interrupt overlay
    if icon.interruptOverlay then
        icon.interruptOverlay:Show()
    end
end

-- Hide a specific targeted spell icon by caster key (unit token)
function DF:HideTargetedSpellIcon(frame, casterKey, skipInterruptAnim)
    if not frame or not frame.dfActiveTargetedSpells then return end
    
    local iconIndex = frame.dfActiveTargetedSpells[casterKey]
    if not iconIndex then return end
    
    local icon = frame.targetedSpellIcons and frame.targetedSpellIcons[iconIndex]
    if icon then
        -- If already showing interrupt animation, let it finish
        if icon.isInterrupted and not skipInterruptAnim then
            return
        end
        
        icon:Hide()
        icon.isActive = nil
        icon.casterKey = nil
        icon.casterUnit = nil
        icon.spellName = nil
        icon.spellID = nil
        icon.isChannel = nil
        icon.durationObject = nil
        icon.startTime = nil
        icon.isInterrupted = nil
        icon.interruptTimer = nil
        icon.isImportant = nil
        
        if icon.cooldown then
            icon.cooldown:Clear()
        end
        if icon.durationText then
            icon.durationText:SetText("")
        end
        if icon.interruptOverlay then
            icon.interruptOverlay:Hide()
        end
        if icon.highlightFrame then
            icon.highlightFrame:Hide()
            -- Clean up animator reference
            TargetedSpellAnimator.frames[icon.highlightFrame] = nil
            TargetedSpellAnimator_UpdateState()
            HideAnimatedBorder(icon.highlightFrame)
            HideSolidBorder(icon.highlightFrame)
            if icon.highlightFrame.pulseAnim then
                icon.highlightFrame.pulseAnim:Stop()
            end
        end
        if icon.icon then
            icon.icon:SetDesaturated(false)
        end
    end
    
    frame.dfActiveTargetedSpells[casterKey] = nil
    
    -- Reposition remaining icons
    PositionIcons(frame)
end

-- Hide all targeted spell icons on a frame
function DF:HideAllTargetedSpells(frame)
    if not frame then return end
    
    if frame.targetedSpellIcons then
        for _, icon in ipairs(frame.targetedSpellIcons) do
            icon:Hide()
            icon.isActive = nil
            icon.casterKey = nil
            icon.casterUnit = nil
            icon.spellName = nil
            icon.spellID = nil
            icon.isChannel = nil
            icon.durationObject = nil
            icon.startTime = nil
            icon.isInterrupted = nil
            icon.interruptTimer = nil
            icon.isImportant = nil
            
            if icon.cooldown then
                icon.cooldown:Clear()
            end
            if icon.durationText then
                icon.durationText:SetText("")
            end
            if icon.interruptOverlay then
                icon.interruptOverlay:Hide()
            end
            if icon.highlightFrame then
                icon.highlightFrame:Hide()
                -- Clean up animator reference
                TargetedSpellAnimator.frames[icon.highlightFrame] = nil
                TargetedSpellAnimator_UpdateState()
                HideAnimatedBorder(icon.highlightFrame)
                HideSolidBorder(icon.highlightFrame)
                if icon.highlightFrame.pulseAnim then
                    icon.highlightFrame.pulseAnim:Stop()
                end
            end
            if icon.icon then
                icon.icon:SetDesaturated(false)
            end
        end
    end
    
    if frame.dfActiveTargetedSpells then
        wipe(frame.dfActiveTargetedSpells)
    end
end

-- Legacy compatibility function
function DF:HideTargetedSpell(frame)
    DF:HideAllTargetedSpells(frame)
end

-- ============================================================
-- LAYOUT UPDATE FUNCTIONS
-- ============================================================

-- Update layout for all icons on a frame
function DF:UpdateTargetedSpellLayout(frame)
    if not frame or not frame.targetedSpellIcons then return end
    
    local db = DF:GetFrameDB(frame)
    
    -- Apply settings to all active icons
    for _, icon in ipairs(frame.targetedSpellIcons) do
        if icon.isActive then
            ApplyIconSettings(icon, db, icon.spellID)
        end
    end
    
    -- Reposition
    PositionIcons(frame)
end

-- Update all frames
function DF:UpdateAllTargetedSpellLayouts()
    DF:IterateAllFrames(function(frame)
        if frame then
            DF:UpdateTargetedSpellLayout(frame)
        end
    end)
end

-- Legacy compatibility
function DF:CreateTargetedSpellIndicator(frame)
    EnsureIconPool(frame, 5)
end

-- ============================================================
-- CAST EVENT HANDLING
-- ============================================================

-- Actually process and show the cast
local function ProcessCastInternal(casterUnit, isChannel)
    if not casterUnit or not UnitExists(casterUnit) then return end
    
    -- Only process valid unit types (nameplate, boss, arena)
    -- This prevents duplicates from "target"/"focus" which reference other units
    if not IsValidCasterUnit(casterUnit) then return end
    
    -- Only show casts from enemies
    if not UnitCanAttack("player", casterUnit) then return end
    
    -- Get cast info
    local name, displayName, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID
    local durationObject
    
    if isChannel then
        name, displayName, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible, spellID = UnitChannelInfo(casterUnit)
        durationObject = UnitChannelDuration(casterUnit)
    else
        name, displayName, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellID = UnitCastingInfo(casterUnit)
        durationObject = UnitCastingDuration(casterUnit)
    end
    
    -- No active cast
    if not name or not durationObject then return end
    
    -- Use GetTime() for start time - we can't do arithmetic on secret values from UnitCastingInfo
    local startTime = GetTime()
    
    -- Clean up any existing icons for this caster before creating new ones
    -- This prevents duplicate icons from multiple events
    if activeCasters[casterUnit] then
        -- Already tracking this caster, update instead of duplicate
        local groupUnits = GetGroupUnits()
        for _, targetUnit in ipairs(groupUnits) do
            local frame = GetFrameForUnit(targetUnit)
            if frame then
                DF:HideTargetedSpellIcon(frame, casterUnit)
            end
        end
    end
    
    -- Track this caster by unit token (not GUID - GUIDs are secret values)
    activeCasters[casterUnit] = {
        startTime = startTime,
        spellID = spellID,
        isChannel = isChannel
    }
    
    -- For each group member, create icon with visibility controlled by SetAlphaFromBoolean
    local groupUnits = GetGroupUnits()
    local db = DF:GetDB()
    local raidDb = DF:GetRaidDB()
    
    -- Check content type for party frames
    local showOnPartyFrames = ShouldShowTargetedSpells(db)
    -- Check content type for raid frames
    local showOnRaidFrames = ShouldShowRaidTargetedSpells(raidDb)
    
    -- Group-frame icon loop removed: Blizzard's UnitIsUnit hotfix on
    -- 2026-04-07 made it impossible to detect which party member an enemy
    -- is targeting from inside an addon. The "Targeted List" feature is
    -- planned as a replacement. See _Reference/targeted-list-mockup.html.

    -- Create personal display icon (always, for every cast - use SetAlphaFromBoolean for visibility)
    if ShouldShowPersonalTargetedSpells(db) then
        -- Always show icon, let SetAlphaFromBoolean control visibility based on targeting
        DF:ShowPersonalTargetedSpellIcon(casterUnit, casterUnit, spellID, texture, durationObject, isChannel, startTime)
    end
    
    -- Log cast to history for review
    -- Store secrets in separate table to avoid contaminating UI calculations
    
    local entryID = tostring(GetTime()) .. "_" .. tostring(casterUnit or "unknown") .. "_" .. tostring(math.random(10000))
    
    -- Store secrets in separate isolated table
    if not DF.castHistorySecrets then
        DF.castHistorySecrets = {}
    end
    
    local secrets = {
        targets = {},
        isImportant = nil,
    }
    
    -- Store player targeting (raw secret value). The "player" comparison
    -- is still permitted under the new UnitIsUnit rules.
    secrets.targets["player"] = UnitIsUnit(casterUnit .. "target", "player")

    -- Per-party-member targeting is no longer recoverable after Blizzard's
    -- 2026-04-07 UnitIsUnit hotfix — UnitIsUnit returns nil for
    -- nameplateXtarget vs partyN. We deliberately don't store nil here
    -- because the cast history UI feeds these values to SetAlphaFromBoolean,
    -- which errors on nil. The history will simply show "N/A" for party
    -- member targeting columns.
    
    -- Store isImportant secret
    if C_Spell and C_Spell.IsSpellImportant and spellID then
        secrets.isImportant = C_Spell.IsSpellImportant(spellID)
    end
    
    DF.castHistorySecrets[entryID] = secrets
    
    -- Store only regular values in the history entry (no secrets!)
    local targetNames = {}
    targetNames["player"] = UnitName("player")
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            targetNames[unit] = UnitName(unit)
        end
    end
    
    local historyEntry = {
        entryID = entryID,  -- Link to secrets table
        spellID = spellID,
        name = name,
        texture = texture,
        timestamp = GetTime(),
        isChannel = isChannel,
        casterUnit = casterUnit,
        casterName = UnitName(casterUnit),
        targetNames = targetNames,  -- Just names, no secrets
        interrupted = false,  -- Regular boolean
    }
    
    table.insert(castHistory, 1, historyEntry)  -- Insert at beginning (newest first)
    
    -- Trim to max size
    while #castHistory > MAX_HISTORY do
        local removed = table.remove(castHistory)
        if removed and removed.entryID then
            DF.castHistorySecrets[removed.entryID] = nil  -- Clean up secrets
        end
    end
end

-- Schedule cast processing after a short delay
-- The 0.2s delay ensures the caster's target info (nameplateXtarget) has
-- settled before we read it. Without this, we can read stale target data
-- from the previous frame, causing icons to appear on the wrong party member.
-- After the delay, we validate the cast is still active to avoid phantom
-- icon flashes from very fast casts that ended during the delay.
local CAST_PROCESS_DELAY = 0.2

local function ProcessCast(casterUnit, isChannel)
    if not casterUnit then return end
    if not IsValidCasterUnit(casterUnit) then return end
    
    C_Timer.After(CAST_PROCESS_DELAY, function()
        -- Validate the cast is still active after the delay
        -- If it finished/was interrupted during the delay, don't show anything
        if isChannel then
            if not UnitChannelInfo(casterUnit) then return end
        else
            if not UnitCastingInfo(casterUnit) then return end
        end
        
        ProcessCastInternal(casterUnit, isChannel)
    end)
end

-- Handle target change (enemy switched targets mid-cast)
local function HandleTargetChange(casterUnit)
    if not casterUnit or not UnitExists(casterUnit) then return end
    if not IsValidCasterUnit(casterUnit) then return end
    if not UnitCanAttack("player", casterUnit) then return end
    
    -- Check if this caster has an active cast we're tracking (by unit token)
    if not activeCasters[casterUnit] then return end
    
    local db = DF:GetDB()

    -- Group-frame visibility update removed: see ProcessCastInternal note.
    -- We only update the personal display now (which uses "player" comparisons,
    -- still permitted by the new UnitIsUnit rules).

    -- Update personal display visibility using SetAlphaFromBoolean
    if db.personalTargetedSpellEnabled then
        local iconIndex = personalActiveSpells[casterUnit]
        if iconIndex then
            local icon = personalIcons[iconIndex]
            if icon and icon.isActive and not icon.isInterrupted then
                local isTargetingPlayer = UnitIsUnit(casterUnit .. "target", "player")
                icon:SetAlphaFromBoolean(isTargetingPlayer, 1, 0)
            end
        end
    end
end

-- Handle cast ending (including interrupts)
local function HandleCastStop(casterUnit, wasInterrupted)
    if not casterUnit then return end
    if not IsValidCasterUnit(casterUnit) then return end
    
    -- Mark history entry as interrupted if applicable
    -- Can't compare spellID (it's a secret), so just mark the most recent entry for this caster
    if wasInterrupted then
        local casterInfo = activeCasters[casterUnit]
        if casterInfo then
            -- Find the most recent history entry for this caster (by timestamp match)
            for _, entry in ipairs(castHistory) do
                if entry.casterUnit == casterUnit and entry.timestamp == casterInfo.startTime and not entry.interrupted then
                    entry.interrupted = true
                    break  -- Only mark the most recent one
                end
            end
        end
    end
    
    -- Remove from active casters (using unit token, not GUID)
    activeCasters[casterUnit] = nil
    
    -- Get db for interrupt setting
    local db = DF:GetDB()
    
    -- Process icons on all frames
    local function ProcessFrame(frame)
        if not frame or not frame.dfActiveTargetedSpells then return end
        
        local iconIndex = frame.dfActiveTargetedSpells[casterUnit]
        if not iconIndex then return end
        
        local icon = frame.targetedSpellIcons and frame.targetedSpellIcons[iconIndex]
        if not icon or not icon.isActive then return end
        
        -- Check frame-specific db for raid frames
        local frameDb = DF:IsRaidFrame(frame) and DF:GetRaidDB() or db
        
        if wasInterrupted and frameDb.targetedSpellShowInterrupted then
            -- Show interrupted visual
            ShowInterruptedVisual(icon, frameDb)
        else
            -- Just hide immediately
            DF:HideTargetedSpellIcon(frame, casterUnit)
        end
    end
    
    -- Process icons on all frames using iterators
    DF:IterateAllFrames(function(frame)
        ProcessFrame(frame)
    end)
    
    -- Also hide personal targeted spell icon for this caster
    if db.personalTargetedSpellEnabled then
        if wasInterrupted and db.personalTargetedSpellShowInterrupted then
            -- Will show interrupted animation then hide
            DF:HidePersonalTargetedSpellIcon(casterUnit, false)
        else
            DF:HidePersonalTargetedSpellIcon(casterUnit, true)
        end
    end
end

-- ============================================================
-- SCANNING FUNCTIONS
-- ============================================================

-- Scan all enemy units for casts
local function ScanAllEnemyCasts()
    local enemyUnits = GetEnemyUnits()
    
    for _, unit in ipairs(enemyUnits) do
        if UnitExists(unit) then
            -- Check for casting
            local castName = UnitCastingInfo(unit)
            if castName then
                ProcessCast(unit, false)
            else
                -- Check for channeling
                local channelName = UnitChannelInfo(unit)
                if channelName then
                    ProcessCast(unit, true)
                end
            end
        end
    end
end

-- ============================================================
-- EVENT HANDLING
-- ============================================================

local function OnEvent(self, event, unit, ...)
    -- ============================================================
    -- Personal / group-frame Targeted Spells branch (existing)
    -- ============================================================
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
        ProcessCast(unit, false)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        ProcessCast(unit, true)
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        HandleCastStop(unit, true)  -- Was interrupted
    elseif event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_FAILED" or
           event == "UNIT_SPELLCAST_FAILED_QUIET" or
           event == "UNIT_SPELLCAST_SUCCEEDED" or
           event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        HandleCastStop(unit, false)  -- Normal end
    elseif event == "UNIT_TARGET" then
        -- Enemy changed target mid-cast
        HandleTargetChange(unit)
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        -- New nameplate, check if casting
        local castName = UnitCastingInfo(unit)
        if castName then
            ProcessCast(unit, false)
        else
            local channelName = UnitChannelInfo(unit)
            if channelName then
                ProcessCast(unit, true)
            end
        end
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        HandleCastStop(unit, false)
    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
        ScanAllEnemyCasts()
    end

    -- ============================================================
    -- Targeted List branch (alpha/beta only, stubs until commit #4)
    -- ============================================================
    -- Routing through DF._TargetedList* shims so the handlers defined
    -- in the Targeted List section at the bottom of this file don't
    -- need to be forward-declared. Each handler is gated internally —
    -- calls are effectively free on stable builds.
    --
    -- The full event-to-handler wiring (castId unpacking, empower
    -- spellId offset, varargs forwarding, mob-death guards) is
    -- implemented in commit #4. This scaffold only needs to invoke
    -- the stubs so the file loads and the gating plumbing is exercised.
    if event == "UNIT_SPELLCAST_START"
       or event == "UNIT_SPELLCAST_CHANNEL_START"
       or event == "UNIT_SPELLCAST_EMPOWER_START" then
        if DF._TargetedListProcessCastStart then
            DF._TargetedListProcessCastStart(unit, event, ...)
        end
    elseif event == "UNIT_SPELLCAST_STOP"
           or event == "UNIT_SPELLCAST_FAILED"
           or event == "UNIT_SPELLCAST_FAILED_QUIET"
           or event == "UNIT_SPELLCAST_SUCCEEDED"
           or event == "UNIT_SPELLCAST_INTERRUPTED"
           or event == "UNIT_SPELLCAST_CHANNEL_STOP"
           or event == "UNIT_SPELLCAST_EMPOWER_STOP"
           or event == "NAME_PLATE_UNIT_REMOVED" then
        if DF._TargetedListOnCastStop then
            DF._TargetedListOnCastStop(unit, event, ...)
        end
    elseif event == "UNIT_SPELLCAST_DELAYED"
           or event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
           or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
        -- Mid-cast update: the cast duration or progress changed
        -- (pushback, channel extension, empower stage). Re-read
        -- the duration object and re-apply bar content so the fill
        -- and countdown stay in sync with the actual cast.
        if DF._TargetedListOnCastUpdate then
            DF._TargetedListOnCastUpdate(unit, event, ...)
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
        if DF._TargetedListOnInterruptibilityChange then
            DF._TargetedListOnInterruptibilityChange(unit, true)
        end
    elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
        if DF._TargetedListOnInterruptibilityChange then
            DF._TargetedListOnInterruptibilityChange(unit, false)
        end
    elseif event == "UNIT_TARGET" then
        -- Enemy changed target mid-cast. If we're tracking this
        -- caster, verify the new target is still a party member.
        -- If not, drop the bar. We can't pick up NEW casts from
        -- UNIT_TARGET (no spellId in payload), but we can drop
        -- existing ones that are no longer relevant.
        if DF._TargetedListOnTargetChange then
            DF._TargetedListOnTargetChange(unit)
        end
    elseif event == "LOADING_SCREEN_DISABLED"
           or event == "ZONE_CHANGED_NEW_AREA"
           or event == "UPDATE_INSTANCE_INFO" then
        -- Zone transition or loading screen: validate all tracked
        -- bars and remove any that are stale.
        if DF._TargetedListValidateAll then
            DF._TargetedListValidateAll()
        end
    elseif event == "CVAR_UPDATE" then
        -- If enemy nameplates are disabled, all bars should go.
        local cvar = ...
        if cvar == "nameplateShowEnemies" then
            local val = C_CVar and C_CVar.GetCVar and C_CVar.GetCVar("nameplateShowEnemies")
            if val == "0" then
                if DF._TargetedListReleaseAllBars then
                    DF._TargetedListReleaseAllBars()
                end
            end
        end
    end
end

eventFrame:SetScript("OnEvent", OnEvent)

-- ============================================================
-- NAMEPLATE OFFSCREEN CVAR
-- ============================================================

function DF:SetNameplateOffscreen(enabled)
    if C_CVar and C_CVar.SetCVar then
        C_CVar.SetCVar("nameplateShowOffscreen", enabled and "1" or "0")
    end
end

function DF:GetNameplateOffscreen()
    if C_CVar and C_CVar.GetCVar then
        return C_CVar.GetCVar("nameplateShowOffscreen") == "1"
    end
    return false
end

-- ============================================================
-- ENABLE/DISABLE
-- ============================================================

-- Internal: register the cast-tracking events on eventFrame.
-- Used by both the group-frame Enable path and the personal-only path
-- (when group is API-blocked but personal display is on).
local function RegisterTargetedSpellEvents()
    eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
    -- Mid-cast update events: pushback, channel duration change, empower
    -- stage progression. Without these the bar desynchs from the actual
    -- cast when the enemy gets interrupted-but-not-stopped, pushed back,
    -- or an empower stage changes.
    eventFrame:RegisterEvent("UNIT_SPELLCAST_DELAYED")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE")
    -- Interruptibility toggles mid-cast (M+ phase changes).
    eventFrame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
    eventFrame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
    eventFrame:RegisterEvent("UNIT_TARGET")
    eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    -- Cleanup + zone transition events.
    eventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
    eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    eventFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
    -- CVAR changes that affect nameplate visibility.
    eventFrame:RegisterEvent("CVAR_UPDATE")
    eventFrame:Show()
end

-- Returns true if any consumer of the shared cast-event stream needs it
-- registered right now. Consumers: personal Targeted Spells display, the
-- (permanently-disabled) group-frame display, and the new Targeted List.
-- Checks both party and raid mode profiles because the addon may switch
-- modes based on group composition without us re-running this check.
local function NeedsCastEvents()
    if not DF.db then return false end
    local function modeNeeds(modeDb)
        if not modeDb then return false end
        local groupOn = (not DF.GroupTargetedSpellsAPIBlocked) and modeDb.targetedSpellEnabled
        local personalOn = modeDb.personalTargetedSpellEnabled
        return groupOn or personalOn
    end
    if modeNeeds(DF.db.party) or modeNeeds(DF.db.raid) then return true end
    -- Targeted List is party-only
    if DF.TargetedListNeedsCastEvents and DF:TargetedListNeedsCastEvents() then
        return true
    end
    return false
end

-- Public: re-evaluate whether eventFrame should be registered. Call this
-- whenever any of the gating settings change (group toggle, personal toggle,
-- API block trip).
function DF:UpdateTargetedSpellEventRegistration()
    if NeedsCastEvents() then
        RegisterTargetedSpellEvents()
    else
        eventFrame:UnregisterAllEvents()
        eventFrame:Hide()
        wipe(activeCasters)
    end
end

function DF:EnableTargetedSpells()
    -- If the API has blocked group-frame targeted spells, do not enable the
    -- group side at all. Personal display registration is handled separately.
    if DF.GroupTargetedSpellsAPIBlocked then
        ForceDisableGroupTargetedSpellSettings()
        DF:UpdateTargetedSpellEventRegistration()
        return
    end

    RegisterTargetedSpellEvents()

    -- Track enabled state for unified handler
    DF.targetedSpellsEnabled = true

    -- Initial scan
    ScanAllEnemyCasts()
end

function DF:DisableTargetedSpells()
    -- Track enabled state
    DF.targetedSpellsEnabled = false

    -- Hide all group-frame icons
    DF:IterateAllFrames(function(frame)
        if frame then
            DF:HideAllTargetedSpells(frame)
        end
    end)

    -- Re-evaluate whether events still need to be registered for personal display.
    -- If personal display is off too, this unregisters everything.
    DF:UpdateTargetedSpellEventRegistration()
end

-- Export scan function for unified roster handler
function DF:ScanAllEnemyCasts()
    ScanAllEnemyCasts()
end

-- Export active casters clear for unified roster handler
function DF:ClearActiveCasters()
    wipe(activeCasters)
end

function DF:ToggleTargetedSpells(enabled)
    if enabled then
        DF:EnableTargetedSpells()
    else
        DF:DisableTargetedSpells()
    end
end

-- ============================================================
-- PERSONAL TARGETED SPELLS DISPLAY
-- Shows incoming spells targeting the player in center of screen
-- ============================================================

-- personalContainer, personalIcons, personalActiveSpells declared at top of file

-- Calculate mover size based on settings
local function GetPersonalMoverSize()
    local db = DF:GetDB()
    local iconSize = db.personalTargetedSpellSize or 40
    local scale = db.personalTargetedSpellScale or 1.0
    local maxIcons = db.personalTargetedSpellMaxIcons or 5
    local spacing = db.personalTargetedSpellSpacing or 4
    local growthDirection = db.personalTargetedSpellGrowth or "RIGHT"
    
    local scaledSize = iconSize * scale
    local scaledSpacing = spacing * scale
    
    local width, height
    if growthDirection == "LEFT" or growthDirection == "RIGHT" or growthDirection == "CENTER_H" then
        width = maxIcons * scaledSize + (maxIcons - 1) * scaledSpacing
        height = scaledSize
    else
        width = scaledSize
        height = maxIcons * scaledSize + (maxIcons - 1) * scaledSpacing
    end
    
    return math.max(width, 50), math.max(height, 50)
end

-- Create the personal targeted spells container
local function CreatePersonalContainer()
    if personalContainer then return personalContainer end
    
    local db = DF:GetDB()
    local x = db.personalTargetedSpellX or 0
    local y = db.personalTargetedSpellY or -150
    
    local container = CreateFrame("Frame", "DandersFramesPersonalTargetedSpells", UIParent)
    local w, h = GetPersonalMoverSize()
    container:SetSize(w, h)
    container:SetPoint("CENTER", UIParent, "CENTER", x, y)
    container:SetFrameStrata("HIGH")
    container:Hide()
    container:EnableMouse(false)
    container:SetHitRectInsets(10000, 10000, 10000, 10000)
    
    personalContainer = container
    DF.personalTargetedSpellsContainer = container
    
    return container
end

-- Create icon for personal display (similar to unit frame icons)
local function CreatePersonalIcon(index)
    CreatePersonalContainer()
    
    local icon = CreateFrame("Frame", nil, personalContainer)
    icon:SetSize(40, 40)
    icon:Hide()
    icon.index = index
    icon:EnableMouse(false)
    icon:SetHitRectInsets(10000, 10000, 10000, 10000)
    
    -- Importance filter frame - nested inside icon
    local importanceFilterFrame = CreateFrame("Frame", nil, icon)
    importanceFilterFrame:SetAllPoints()
    importanceFilterFrame:EnableMouse(false)
    importanceFilterFrame:SetHitRectInsets(10000, 10000, 10000, 10000)
    icon.importanceFilterFrame = importanceFilterFrame
    
    -- Main icon frame with border
    local iconFrame = CreateFrame("Frame", nil, importanceFilterFrame)
    iconFrame:SetAllPoints()
    iconFrame:EnableMouse(false)
    iconFrame:SetHitRectInsets(10000, 10000, 10000, 10000)
    icon.iconFrame = iconFrame
    
    -- Border textures - 4 edge borders (consistent with other icons)
    local defBorderSize = 2
    local borderLeft = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderLeft:SetPoint("TOPLEFT", 0, 0)
    borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    borderLeft:SetWidth(defBorderSize)
    borderLeft:SetColorTexture(1, 0.3, 0, 1)
    icon.borderLeft = borderLeft
    
    local borderRight = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderRight:SetPoint("TOPRIGHT", 0, 0)
    borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    borderRight:SetWidth(defBorderSize)
    borderRight:SetColorTexture(1, 0.3, 0, 1)
    icon.borderRight = borderRight
    
    local borderTop = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderTop:SetPoint("TOPLEFT", defBorderSize, 0)
    borderTop:SetPoint("TOPRIGHT", -defBorderSize, 0)
    borderTop:SetHeight(defBorderSize)
    borderTop:SetColorTexture(1, 0.3, 0, 1)
    icon.borderTop = borderTop
    
    local borderBottom = iconFrame:CreateTexture(nil, "BACKGROUND")
    borderBottom:SetPoint("BOTTOMLEFT", defBorderSize, 0)
    borderBottom:SetPoint("BOTTOMRIGHT", -defBorderSize, 0)
    borderBottom:SetHeight(defBorderSize)
    borderBottom:SetColorTexture(1, 0.3, 0, 1)
    icon.borderBottom = borderBottom
    
    -- Important spell highlight frame - set frame level ABOVE iconFrame so it renders on top
    local highlightFrame = CreateFrame("Frame", nil, iconFrame)
    highlightFrame:SetPoint("TOPLEFT", -5, 5)
    highlightFrame:SetPoint("BOTTOMRIGHT", 5, -5)
    highlightFrame:SetFrameLevel(iconFrame:GetFrameLevel() + 5)
    highlightFrame:Hide()
    highlightFrame:EnableMouse(false)
    highlightFrame:SetHitRectInsets(10000, 10000, 10000, 10000)
    icon.highlightFrame = highlightFrame
    
    -- Icon texture - positioned with inset for border
    local texture = iconFrame:CreateTexture(nil, "ARTWORK")
    texture:SetPoint("TOPLEFT", defBorderSize, -defBorderSize)
    texture:SetPoint("BOTTOMRIGHT", -defBorderSize, defBorderSize)
    texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon.texture = texture
    icon.icon = texture
    
    -- Cooldown - attached to icon texture
    local cooldown = CreateFrame("Cooldown", nil, iconFrame, "CooldownFrameTemplate")
    cooldown:SetPoint("TOPLEFT", texture, "TOPLEFT", 0, 0)
    cooldown:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", 0, 0)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawBling(false)
    cooldown:SetDrawSwipe(true)
    cooldown:SetReverse(true)
    cooldown:SetHideCountdownNumbers(true)
    cooldown:EnableMouse(false)
    cooldown:SetHitRectInsets(10000, 10000, 10000, 10000)
    icon.cooldown = cooldown
    
    -- Text overlay (above cooldown)
    local textOverlay = CreateFrame("Frame", nil, iconFrame)
    textOverlay:SetAllPoints()
    textOverlay:SetFrameLevel(cooldown:GetFrameLevel() + 5)
    textOverlay:EnableMouse(false)
    textOverlay:SetHitRectInsets(10000, 10000, 10000, 10000)
    icon.textOverlay = textOverlay
    
    -- Duration text
    local durationText = textOverlay:CreateFontString(nil, "OVERLAY")
    DF.GUI:SetSettingsFont(durationText, 12, "OUTLINE")
    durationText:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
    durationText:SetTextColor(1, 1, 1, 1)
    icon.durationText = durationText
    
    -- Interrupted overlay
    local interruptOverlay = CreateFrame("Frame", nil, iconFrame)
    interruptOverlay:SetAllPoints()
    interruptOverlay:SetFrameLevel(cooldown:GetFrameLevel() + 10)
    interruptOverlay:Hide()
    interruptOverlay:EnableMouse(false)
    interruptOverlay:SetHitRectInsets(10000, 10000, 10000, 10000)
    icon.interruptOverlay = interruptOverlay
    
    local interruptTint = interruptOverlay:CreateTexture(nil, "OVERLAY")
    interruptTint:SetAllPoints()
    interruptTint:SetColorTexture(1, 0, 0, 0.5)
    icon.interruptTint = interruptTint
    
    local interruptX = interruptOverlay:CreateFontString(nil, "OVERLAY")
    DF.GUI:SetSettingsFont(interruptX, 20, "OUTLINE")
    interruptX:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
    interruptX:SetText("X")
    interruptX:SetTextColor(1, 0, 0, 1)
    icon.interruptX = interruptX
    
    -- OnUpdate for duration and cleanup
    local durationThrottle = 0
    icon:SetScript("OnUpdate", function(self, elapsed)
        if not self.isActive then return end
        
        -- Skip cleanup check for test mode icons
        if self.isTestIcon then
            -- Throttle test mode duration updates too
            durationThrottle = durationThrottle + elapsed
            if durationThrottle < 0.1 then return end
            durationThrottle = 0
            
            -- Only update duration text for test icons
            if self.testTimeRemaining and self.durationText and self.durationText:IsShown() then
                self.testTimeRemaining = self.testTimeRemaining - elapsed * 10  -- Compensate for throttle
                if self.testTimeRemaining < 0 then self.testTimeRemaining = 3.0 end  -- Loop
                self.durationText:SetFormattedText("%.1f", self.testTimeRemaining)
            end
            return
        end
        
        -- Handle interrupted animation (needs to run every frame for smooth animation)
        if self.isInterrupted then
            self.interruptTimer = (self.interruptTimer or 0) + elapsed
            local db = DF:GetDB()
            local duration = db.personalTargetedSpellInterruptedDuration or 0.5
            
            if self.interruptTimer >= duration then
                DF:HidePersonalTargetedSpellIcon(self.casterKey, true, true)  -- fromTimer=true
            end
            return
        end
        
        -- Throttle duration text updates to ~10 FPS for performance
        durationThrottle = durationThrottle + elapsed
        if durationThrottle < 0.1 then return end
        durationThrottle = 0
        
        -- Update duration text from duration object
        -- TODO: Can use durationObject:EvaluateRemainingPercent(colorCurve) for dynamic color-by-time
        if self.durationObject and self.durationText and self.durationText:IsShown() then
            local ok, remaining = pcall(self.durationObject.GetRemainingDuration, self.durationObject)
            if ok and remaining then
                self.durationText:SetFormattedText("%.1f", remaining)
                if self.durationColor then
                    self.durationText:SetTextColor(self.durationColor.r, self.durationColor.g, self.durationColor.b, 1)
                end
            end
        end
        
        -- Note: Target change detection is handled by UNIT_TARGET event + HandleTargetChange
        -- which uses SetAlphaFromBoolean. We can't do boolean checks on secret values here.
    end)
    
    return icon
end

-- Get or create personal icon
local function GetPersonalIcon(index)
    if not personalIcons[index] then
        personalIcons[index] = CreatePersonalIcon(index)
    end
    return personalIcons[index]
end

-- Apply settings to a personal icon
local function ApplyPersonalIconSettings(icon, db, spellID)
    local borderColor = db.personalTargetedSpellBorderColor or {r = 1, g = 0.3, b = 0}
    local borderSize = db.personalTargetedSpellBorderSize or 2
    local showBorder = db.personalTargetedSpellShowBorder ~= false
    local showSwipe = db.personalTargetedSpellShowSwipe ~= false
    local showDuration = db.personalTargetedSpellShowDuration ~= false
    local durationFont = db.personalTargetedSpellDurationFont or "Fonts\\FRIZQT__.TTF"
    local durationScale = db.personalTargetedSpellDurationScale or 1.2
    local durationOutline = db.personalTargetedSpellDurationOutline or "OUTLINE"
    local durationX = db.personalTargetedSpellDurationX or 0
    local durationY = db.personalTargetedSpellDurationY or 0
    local durationColor = db.personalTargetedSpellDurationColor or {r = 1, g = 1, b = 1}
    local highlightImportant = db.personalTargetedSpellHighlightImportant ~= false
    local highlightStyle = db.personalTargetedSpellHighlightStyle or "glow"
    local highlightColor = db.personalTargetedSpellHighlightColor or {r = 1, g = 0.8, b = 0}
    local highlightSize = db.personalTargetedSpellHighlightSize or 3
    local highlightInset = db.personalTargetedSpellHighlightInset or 0
    local importantOnly = db.personalTargetedSpellImportantOnly
    
    if durationOutline == "NONE" then durationOutline = "" end
    
    -- Apply pixel perfect to border size
    if db.pixelPerfect then
        borderSize = DF:PixelPerfect(borderSize)
    end
    
    icon.durationColor = durationColor
    
    -- Important spell filter
    if icon.importanceFilterFrame then
        if importantOnly and spellID then
            local isImportant = C_Spell.IsSpellImportant(spellID)
            icon.importanceFilterFrame:SetAlphaFromBoolean(isImportant)
        else
            icon.importanceFilterFrame:SetAlpha(1)
        end
    end
    
    -- Important spell highlight
    if icon.highlightFrame then
        -- Calculate position with inset (negative inset = larger, positive = smaller/inward)
        local offset = borderSize + highlightSize - highlightInset
        
        -- Position the highlight frame
        icon.highlightFrame:ClearAllPoints()
        icon.highlightFrame:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", -offset, offset)
        icon.highlightFrame:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", offset, -offset)
        
        -- Hide all highlight styles first
        HideAnimatedBorder(icon.highlightFrame)
        HideSolidBorder(icon.highlightFrame)
        HideGlowBorder(icon.highlightFrame)
        if icon.highlightFrame.pulseAnim then icon.highlightFrame.pulseAnim:Stop() end
        TargetedSpellAnimator.frames[icon.highlightFrame] = nil
        TargetedSpellAnimator_UpdateState()
        
        if highlightImportant and spellID and highlightStyle ~= "none" then
            local isImportant = C_Spell.IsSpellImportant(spellID)
            
            if highlightStyle == "glow" then
                -- Glow effect using edge borders with ADD blend mode
                InitGlowBorder(icon.highlightFrame)
                UpdateGlowBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 0.8)
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                
            elseif highlightStyle == "marchingAnts" then
                -- Animated marching ants border
                InitAnimatedBorder(icon.highlightFrame)
                icon.highlightFrame.animThickness = math.max(1, highlightSize)
                icon.highlightFrame.animR = highlightColor.r
                icon.highlightFrame.animG = highlightColor.g
                icon.highlightFrame.animB = highlightColor.b
                icon.highlightFrame.animA = 1
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                TargetedSpellAnimator.frames[icon.highlightFrame] = true
                TargetedSpellAnimator_UpdateState()
                
            elseif highlightStyle == "solidBorder" then
                -- Solid colored border (4 edge textures, no fill)
                InitSolidBorder(icon.highlightFrame)
                UpdateSolidBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 1)
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                
            elseif highlightStyle == "pulse" then
                -- Pulsing glow using edge borders with ADD blend
                InitGlowBorder(icon.highlightFrame)
                UpdateGlowBorder(icon.highlightFrame, highlightSize, highlightColor.r, highlightColor.g, highlightColor.b, 0.8)
                InitPulseAnimation(icon.highlightFrame)
                -- Store color for pulse animation to use
                icon.highlightFrame.pulseR = highlightColor.r
                icon.highlightFrame.pulseG = highlightColor.g
                icon.highlightFrame.pulseB = highlightColor.b
                icon.highlightFrame:Show()
                icon.highlightFrame:SetAlphaFromBoolean(isImportant)
                icon.highlightFrame.pulseAnim:Play()
            end
        else
            icon.highlightFrame:Hide()
        end
    end
    
    -- Border - 4 edge textures (consistent with other icons)
    if showBorder then
        if icon.borderLeft then
            icon.borderLeft:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderLeft:SetWidth(borderSize)
            icon.borderLeft:Show()
        end
        if icon.borderRight then
            icon.borderRight:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderRight:SetWidth(borderSize)
            icon.borderRight:Show()
        end
        if icon.borderTop then
            icon.borderTop:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderTop:SetHeight(borderSize)
            icon.borderTop:ClearAllPoints()
            icon.borderTop:SetPoint("TOPLEFT", borderSize, 0)
            icon.borderTop:SetPoint("TOPRIGHT", -borderSize, 0)
            icon.borderTop:Show()
        end
        if icon.borderBottom then
            icon.borderBottom:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 1)
            icon.borderBottom:SetHeight(borderSize)
            icon.borderBottom:ClearAllPoints()
            icon.borderBottom:SetPoint("BOTTOMLEFT", borderSize, 0)
            icon.borderBottom:SetPoint("BOTTOMRIGHT", -borderSize, 0)
            icon.borderBottom:Show()
        end
        
        -- Adjust icon texture position for border
        if icon.icon then
            icon.icon:ClearAllPoints()
            icon.icon:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", borderSize, -borderSize)
            icon.icon:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", -borderSize, borderSize)
        end
        
        -- Adjust cooldown to match
        if icon.cooldown then
            icon.cooldown:ClearAllPoints()
            icon.cooldown:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", borderSize, -borderSize)
            icon.cooldown:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", -borderSize, borderSize)
        end
    else
        -- Hide all border edges
        if icon.borderLeft then icon.borderLeft:Hide() end
        if icon.borderRight then icon.borderRight:Hide() end
        if icon.borderTop then icon.borderTop:Hide() end
        if icon.borderBottom then icon.borderBottom:Hide() end
        
        -- Full size icon when no border
        if icon.icon then
            icon.icon:ClearAllPoints()
            icon.icon:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", 0, 0)
            icon.icon:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", 0, 0)
        end
        
        -- Adjust cooldown to match
        if icon.cooldown then
            icon.cooldown:ClearAllPoints()
            icon.cooldown:SetPoint("TOPLEFT", icon.iconFrame, "TOPLEFT", 0, 0)
            icon.cooldown:SetPoint("BOTTOMRIGHT", icon.iconFrame, "BOTTOMRIGHT", 0, 0)
        end
    end
    
    -- Cooldown swipe
    if icon.cooldown then
        icon.cooldown:SetDrawSwipe(showSwipe)
        icon.cooldown:SetHideCountdownNumbers(true)
    end
    
    -- Duration text
    if icon.durationText then
        if showDuration then
            icon.durationText:Show()
            local fontSize = 10 * durationScale
            DF:SafeSetFont(icon.durationText, durationFont, fontSize, durationOutline)
            icon.durationText:ClearAllPoints()
            icon.durationText:SetPoint("CENTER", icon.iconFrame, "CENTER", durationX, durationY)
            icon.durationText:SetTextColor(durationColor.r, durationColor.g, durationColor.b, 1)
        else
            icon.durationText:Hide()
        end
    end
    
    -- Interrupt visual settings
    local interruptTintColor = db.personalTargetedSpellInterruptedTintColor or {r = 1, g = 0, b = 0}
    local interruptTintAlpha = db.personalTargetedSpellInterruptedTintAlpha or 0.5
    local interruptShowX = db.personalTargetedSpellInterruptedShowX ~= false
    local interruptXColor = db.personalTargetedSpellInterruptedXColor or {r = 1, g = 0, b = 0}
    local interruptXSize = db.personalTargetedSpellInterruptedXSize or 20
    
    -- Apply interrupt tint settings
    if icon.interruptTint then
        icon.interruptTint:SetColorTexture(interruptTintColor.r, interruptTintColor.g, interruptTintColor.b, interruptTintAlpha)
    end
    
    -- Apply interrupt X mark settings
    if icon.interruptX then
        if interruptShowX then
            icon.interruptX:Show()
            icon.interruptX:SetTextColor(interruptXColor.r, interruptXColor.g, interruptXColor.b, 1)
            DF.GUI:SetSettingsFont(icon.interruptX, interruptXSize, "OUTLINE")
        else
            icon.interruptX:Hide()
        end
    end
end

-- Position personal icons
local function PositionPersonalIcons()
    local db = DF:GetDB()
    if not personalContainer then return end
    
    local iconSize = db.personalTargetedSpellSize or 40
    local scale = db.personalTargetedSpellScale or 1.0
    local growthDirection = db.personalTargetedSpellGrowth or "RIGHT"
    local spacing = db.personalTargetedSpellSpacing or 4
    local maxIcons = db.personalTargetedSpellMaxIcons or 5
    
    -- Apply pixel perfect
    if db.pixelPerfect then
        iconSize = DF:PixelPerfect(iconSize)
        spacing = DF:PixelPerfect(spacing)
    end
    
    local scaledSize = iconSize * scale
    local scaledSpacing = spacing * scale
    
    -- Collect active spells
    local casterData = {}
    for casterKey, iconIndex in pairs(personalActiveSpells) do
        local icon = personalIcons[iconIndex]
        if icon and icon.isActive then
            table.insert(casterData, {
                casterKey = casterKey,
                iconIndex = iconIndex,
                startTime = icon.startTime or 0
            })
        end
    end
    
    -- Sort for consistent order
    table.sort(casterData, function(a, b)
        return a.casterKey < b.casterKey
    end)
    
    local numIcons = math.min(#casterData, maxIcons)
    
    for i = 1, #casterData do
        local data = casterData[i]
        local icon = personalIcons[data.iconIndex]
        
        if icon then
            if i <= maxIcons then
                local offsetX, offsetY = 0, 0
                local index = i - 1
                
                if growthDirection == "UP" then
                    offsetY = index * (scaledSize + scaledSpacing)
                elseif growthDirection == "DOWN" then
                    offsetY = -index * (scaledSize + scaledSpacing)
                elseif growthDirection == "LEFT" then
                    offsetX = -index * (scaledSize + scaledSpacing)
                elseif growthDirection == "RIGHT" then
                    offsetX = index * (scaledSize + scaledSpacing)
                elseif growthDirection == "CENTER_H" then
                    local centerOffset = (numIcons - 1) * (scaledSize + scaledSpacing) / 2
                    offsetX = index * (scaledSize + scaledSpacing) - centerOffset
                elseif growthDirection == "CENTER_V" then
                    local centerOffset = (numIcons - 1) * (scaledSize + scaledSpacing) / 2
                    offsetY = index * (scaledSize + scaledSpacing) - centerOffset
                end
                
                icon:ClearAllPoints()
                icon:SetPoint("CENTER", personalContainer, "CENTER", offsetX, offsetY)
                icon:SetSize(scaledSize, scaledSize)
                icon.iconFrame:SetAllPoints(icon)
                
                icon:Show()
            else
                icon:Hide()
            end
        end
    end
end

-- Show a personal targeted spell icon
function DF:ShowPersonalTargetedSpellIcon(casterUnit, casterKey, spellID, texture, durationObject, isChannel, startTime)
    local db = DF:GetDB()
    if not db.personalTargetedSpellEnabled then return end
    
    CreatePersonalContainer()
    
    -- Check if already tracking this caster
    if personalActiveSpells[casterKey] then
        return
    end
    
    -- Find available icon
    local iconIndex = nil
    for i = 1, db.personalTargetedSpellMaxIcons or 5 do
        local icon = GetPersonalIcon(i)
        if not icon.isActive then
            iconIndex = i
            break
        end
    end
    
    if not iconIndex then
        iconIndex = #personalIcons + 1
        GetPersonalIcon(iconIndex)
    end
    
    local icon = personalIcons[iconIndex]
    personalActiveSpells[casterKey] = iconIndex
    
    -- Setup icon
    icon.casterUnit = casterUnit
    icon.casterKey = casterKey
    icon.spellID = spellID
    icon.isChannel = isChannel
    icon.durationObject = durationObject
    icon.startTime = startTime or GetTime()
    icon.isActive = true
    icon.isInterrupted = false
    icon.interruptTimer = 0
    icon.isTestIcon = false
    
    -- Hide interrupt overlay
    if icon.interruptOverlay then
        icon.interruptOverlay:Hide()
    end
    
    -- Set icon texture
    if texture and icon.icon then
        icon.icon:SetTexture(texture)
        icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        icon.icon:SetDesaturated(false)
    end
    
    -- Apply settings
    ApplyPersonalIconSettings(icon, db, spellID)
    
    -- Set up cooldown from duration object
    if icon.cooldown and durationObject then
        icon.cooldown:SetCooldownFromDurationObject(durationObject)
    end
    
    -- Use SetAlphaFromBoolean to control visibility based on targeting
    local isTargetingPlayer = UnitIsUnit(casterUnit .. "target", "player")
    icon:SetAlphaFromBoolean(isTargetingPlayer, 1, 0)
    
    -- Show container
    personalContainer:Show()
    
    PositionPersonalIcons()
end

-- Hide a personal targeted spell icon
function DF:HidePersonalTargetedSpellIcon(casterKey, immediate, fromTimer)
    local iconIndex = personalActiveSpells[casterKey]
    if not iconIndex then return end
    
    local icon = personalIcons[iconIndex]
    if not icon then return end
    
    local db = DF:GetDB()
    
    -- If already showing interrupt animation, only hide if timer completed (fromTimer=true)
    -- This prevents UNIT_SPELLCAST_STOP from hiding the icon during interrupt animation
    if icon.isInterrupted and not icon.isTestIcon and not fromTimer then
        return
    end
    
    -- Show interrupted animation if not immediate and enabled
    if not immediate and db.personalTargetedSpellShowInterrupted and not icon.isInterrupted and not icon.isTestIcon then
        icon.isInterrupted = true
        icon.interruptTimer = 0
        icon.interruptOverlay:Show()
        icon.durationText:Hide()
        if icon.icon then
            icon.icon:SetDesaturated(true)
        end
        return
    end
    
    -- Fully hide the icon
    icon.isActive = false
    icon.isInterrupted = false
    icon:Hide()
    if icon.highlightFrame then
        icon.highlightFrame:Hide()
        -- Clean up animator reference
        TargetedSpellAnimator.frames[icon.highlightFrame] = nil
        TargetedSpellAnimator_UpdateState()
        HideAnimatedBorder(icon.highlightFrame)
        HideSolidBorder(icon.highlightFrame)
        if icon.highlightFrame.pulseAnim then
            icon.highlightFrame.pulseAnim:Stop()
        end
    end
    icon.interruptOverlay:Hide()
    if icon.icon then
        icon.icon:SetDesaturated(false)
    end
    
    personalActiveSpells[casterKey] = nil
    
    PositionPersonalIcons()
    
    -- Hide container if no active spells
    local hasActive = false
    for _ in pairs(personalActiveSpells) do
        hasActive = true
        break
    end
    if not hasActive and personalContainer then
        personalContainer:Hide()
    end
end

-- Hide all personal targeted spell icons
function DF:HideAllPersonalTargetedSpells()
    for casterKey, iconIndex in pairs(personalActiveSpells) do
        local icon = personalIcons[iconIndex]
        if icon then
            icon.isActive = false
            icon.isInterrupted = false
            icon:Hide()
            if icon.highlightFrame then
                icon.highlightFrame:Hide()
                -- Clean up animator reference
                TargetedSpellAnimator.frames[icon.highlightFrame] = nil
                TargetedSpellAnimator_UpdateState()
                HideAnimatedBorder(icon.highlightFrame)
                HideSolidBorder(icon.highlightFrame)
                if icon.highlightFrame.pulseAnim then
                    icon.highlightFrame.pulseAnim:Stop()
                end
            end
            icon.interruptOverlay:Hide()
            if icon.icon then
                icon.icon:SetDesaturated(false)
            end
        end
    end
    wipe(personalActiveSpells)
    
    if personalContainer then
        personalContainer:Hide()
    end
end

-- Update personal display position from settings
function DF:UpdatePersonalTargetedSpellsPosition()
    local db = DF:GetDB()
    local x = db.personalTargetedSpellX or 0
    local y = db.personalTargetedSpellY or -150
    local iconAlpha = db.personalTargetedSpellAlpha or 1.0
    
    if personalContainer then
        personalContainer:ClearAllPoints()
        personalContainer:SetPoint("CENTER", UIParent, "CENTER", x, y)
        local w, h = GetPersonalMoverSize()
        personalContainer:SetSize(w, h)
        personalContainer:SetAlpha(iconAlpha)
    end
    
    -- Re-apply settings to active icons
    for casterKey, iconIndex in pairs(personalActiveSpells) do
        local icon = personalIcons[iconIndex]
        if icon and icon.isActive then
            ApplyPersonalIconSettings(icon, db, icon.spellID)
            icon:SetAlpha(iconAlpha)
        end
    end
    
    PositionPersonalIcons()
end

-- Update mover size to match settings
local function UpdateMoverSize()
    if not DF.personalTargetedSpellsMover then return end
    local w, h = GetPersonalMoverSize()
    DF.personalTargetedSpellsMover:SetSize(w, h)
end

-- Create mover for personal targeted spells
function DF:CreatePersonalTargetedSpellsMover()
    if DF.personalTargetedSpellsMover then return end
    
    CreatePersonalContainer()
    
    local w, h = GetPersonalMoverSize()
    
    local mover = CreateFrame("Frame", "DandersFramesPersonalTargetedSpellsMover", UIParent, "BackdropTemplate")
    mover:SetSize(w, h)
    mover:SetFrameStrata("DIALOG")
    mover:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    mover:SetBackdropColor(1.0, 0.5, 0.2, 0.3)
    mover:SetBackdropBorderColor(1.0, 0.5, 0.2, 0.8)
    mover:EnableMouse(true)
    mover:SetMovable(true)
    mover:RegisterForDrag("LeftButton")
    mover:Hide()
    
    local label = mover:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    label:SetPoint("CENTER")
    label:SetText("Personal\nTargeted Spells")
    label:SetTextColor(1, 1, 1, 1)
    mover.label = label

    -- Left-click switches the shared position panel to our mode.
    mover:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("personal")
        end
    end)

    mover:SetScript("OnDragStart", function(self)
        -- Switch the position panel to personal mode so nudge
        -- buttons affect us, not the party container.
        if DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("personal")
        end
        self:StartMoving()

        local db = DF:GetDB()
        self:SetScript("OnUpdate", function()
            -- Update icons to follow mover during drag
            local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
            local centerX, centerY = self:GetCenter()
            local x = centerX - screenWidth / 2
            local y = centerY - screenHeight / 2
            
            -- Update container position live
            if personalContainer then
                personalContainer:ClearAllPoints()
                personalContainer:SetPoint("CENTER", UIParent, "CENTER", x, y)
            end
            
            -- Snap preview
            if db.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown() then
                DF:UpdateSnapPreview(self)
            end
        end)
    end)
    
    mover:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
        DF:HideSnapPreview()
        
        local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
        local centerX, centerY = self:GetCenter()
        local x = centerX - screenWidth / 2
        local y = centerY - screenHeight / 2
        
        local db = DF:GetDB()
        if db.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown() then
            x, y = DF:SnapToGrid(x, y)
        end
        
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", x, y)
        
        -- Save to DB
        db.personalTargetedSpellX = x
        db.personalTargetedSpellY = y
        
        -- Update actual container
        DF:UpdatePersonalTargetedSpellsPosition()
    end)
    
    mover:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            DF:LockFrames()
        end
    end)
    
    DF.personalTargetedSpellsMover = mover
end

-- Show/hide the personal targeted spells mover
function DF:ShowPersonalTargetedSpellsMover()
    if not DF.personalTargetedSpellsMover then
        DF:CreatePersonalTargetedSpellsMover()
    end
    
    local db = DF:GetDB()
    local x = db.personalTargetedSpellX or 0
    local y = db.personalTargetedSpellY or -150
    
    UpdateMoverSize()
    DF.personalTargetedSpellsMover:ClearAllPoints()
    DF.personalTargetedSpellsMover:SetPoint("CENTER", UIParent, "CENTER", x, y)
    DF.personalTargetedSpellsMover:Show()
    
    -- Show test icons
    DF:ShowTestPersonalTargetedSpells()
end

function DF:HidePersonalTargetedSpellsMover()
    if DF.personalTargetedSpellsMover then
        DF.personalTargetedSpellsMover:Hide()
    end
    -- Hide test icons
    DF:HideTestPersonalTargetedSpells()
end

-- Test mode support for personal targeted spells
function DF:ShowTestPersonalTargetedSpells()
    local db = DF:GetDB()
    if not db.personalTargetedSpellEnabled then return end
    
    CreatePersonalContainer()
    
    -- Clear any existing test icons
    DF:HideAllPersonalTargetedSpells()
    
    local maxIcons = db.personalTargetedSpellMaxIcons or 5
    local numTestIcons = math.min(3, maxIcons)  -- Show up to 3 test icons
    local iconAlpha = db.personalTargetedSpellAlpha or 1.0
    local importantOnly = db.personalTargetedSpellImportantOnly
    
    -- Test spells - include one interrupted if settings allow
    local testSpells = {
        {id = 686, texture = "Interface\\Icons\\Spell_Shadow_ShadowBolt", isImportant = true, isInterrupted = false},
        {id = 348, texture = "Interface\\Icons\\Spell_Fire_Immolation", isImportant = false, isInterrupted = false},
        {id = 172, texture = "Interface\\Icons\\Spell_Shadow_AbominationExplosion", isImportant = true, isInterrupted = db.personalTargetedSpellShowInterrupted},
    }
    
    for i = 1, numTestIcons do
        local testData = testSpells[i]
        
        -- Skip non-important spells if importantOnly is enabled
        if importantOnly and not testData.isImportant then
            -- Skip this icon but continue loop
        else
            local testKey = "test-personal-" .. i
            
            local icon = GetPersonalIcon(i)
            personalActiveSpells[testKey] = i
            
            -- Setup icon
            icon.casterUnit = nil
            icon.casterKey = testKey
            icon.spellID = testData.id
            icon.isChannel = false
            icon.durationObject = nil
            icon.startTime = GetTime()
            icon.isActive = true
            icon.isInterrupted = false
            icon.interruptTimer = 0
            icon.isTestIcon = true
            icon.testTimeRemaining = 2.0 + i * 0.5  -- Varying durations
            
            -- Set icon texture
            if icon.icon then
                icon.icon:SetTexture(testData.texture)
                icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                icon.icon:SetDesaturated(testData.isInterrupted)
            end
            
            -- Apply settings (use real spellID for importance check in test)
            ApplyPersonalIconSettings(icon, db, testData.isImportant and testData.id or nil)
            
            -- For test mode, manually set highlight visibility based on test data
            if icon.highlightFrame then
                if db.personalTargetedSpellHighlightImportant and testData.isImportant and not testData.isInterrupted then
                    icon.highlightFrame:Show()
                    icon.highlightFrame:SetAlpha(1)
                else
                    icon.highlightFrame:Hide()
                end
            end
            
            -- Show interrupt overlay for the test interrupted icon
            if icon.interruptOverlay then
                if testData.isInterrupted then
                    icon.interruptOverlay:Show()
                    icon.durationText:Hide()
                else
                    icon.interruptOverlay:Hide()
                end
            end
            
            -- Set up fake cooldown for test (3 second duration)
            if icon.cooldown then
                if testData.isInterrupted then
                    -- Interrupted icons show partial cooldown
                    icon.cooldown:SetCooldown(GetTime() - 1.5, 3)
                else
                    icon.cooldown:SetCooldown(GetTime(), 3)
                end
            end
            
            -- Apply alpha setting
            icon:SetAlpha(iconAlpha)
            
            icon:Show()
        end
    end
    
    -- Apply alpha to container as well
    if personalContainer then
        personalContainer:SetAlpha(iconAlpha)
    end
    
    -- Show container
    personalContainer:Show()
    
    PositionPersonalIcons()
end

function DF:HideTestPersonalTargetedSpells()
    DF:HideAllPersonalTargetedSpells()
end

-- Update test personal targeted spells (called when settings change)
function DF:UpdateTestPersonalTargetedSpells()
    -- Update if mover is shown OR if in test mode with personal enabled
    local db = DF:GetDB()
    local moverShown = DF.personalTargetedSpellsMover and DF.personalTargetedSpellsMover:IsShown()
    -- Show personal targeted spells in test mode if personal is enabled (don't require testShowTargetedSpell)
    local inTestMode = (DF.testMode or DF.raidTestMode) and db.personalTargetedSpellEnabled
    
    if moverShown or inTestMode then
        UpdateMoverSize()
        DF:ShowTestPersonalTargetedSpells()
    end
end

-- Toggle personal targeted spells
function DF:TogglePersonalTargetedSpells(enabled)
    if enabled then
        CreatePersonalContainer()
        DF:CreatePersonalTargetedSpellsMover()
    else
        DF:HideAllPersonalTargetedSpells()
    end
    -- Re-evaluate event registration: personal display can keep events alive
    -- even when the group-frame side is off or API-blocked.
    DF:UpdateTargetedSpellEventRegistration()
end

-- ============================================================
-- CAST HISTORY (TEST FEATURE)
-- ============================================================

-- Get cast history table
function DF:GetCastHistory()
    return castHistory
end

-- Clear cast history
function DF:ClearCastHistory()
    wipe(castHistory)
    -- Also clear the secrets table
    if DF.castHistorySecrets then
        wipe(DF.castHistorySecrets)
    end
    print("|cff00ff00DandersFrames:|r Cast history cleared")
    -- Refresh UI if open
    if DF.castHistoryFrame and DF.castHistoryFrame:IsShown() then
        DF:RefreshCastHistoryUI()
    end
end

-- Cast history UI frame
local castHistoryFrame = nil
local castHistoryRows = {}
local HISTORY_ROW_HEIGHT = 28
local ROWS_PER_PAGE = 10
local currentPage = 1

-- Create the cast history UI with PAGINATION (no scroll frame to avoid secret contamination)
function DF:CreateCastHistoryUI()
    if castHistoryFrame then return castHistoryFrame end
    
    -- Theme colors (matching GUI.lua)
    local C_BACKGROUND = {r = 0.08, g = 0.08, b = 0.08, a = 0.95}
    local C_PANEL      = {r = 0.12, g = 0.12, b = 0.12, a = 1}
    local C_ELEMENT    = {r = 0.18, g = 0.18, b = 0.18, a = 1}
    local C_BORDER     = {r = 0.25, g = 0.25, b = 0.25, a = 1}
    local C_ACCENT     = {r = 0.45, g = 0.45, b = 0.95, a = 1}
    local C_TEXT       = {r = 0.9, g = 0.9, b = 0.9, a = 1}
    local C_TEXT_DIM   = {r = 0.6, g = 0.6, b = 0.6, a = 1}
    
    -- Main frame
    local frame = CreateFrame("Frame", "DFCastHistoryFrame", UIParent, "BackdropTemplate")
    frame:SetSize(590, 404)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    -- Backdrop - dark charcoal like main options
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, C_BACKGROUND.a)
    frame:SetBackdropBorderColor(0, 0, 0, 1)
    
    -- Title bar with accent color
    local titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    titleBar:SetHeight(32)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    titleBar:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
    titleBar:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    
    local title = titleBar:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    title:SetPoint("LEFT", 10, 4)
    title:SetText("Cast History")
    title:SetTextColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
    
    -- Subtitle note
    local subtitle = titleBar:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, 0)
    subtitle:SetText("Persists through load screens, resets on /reload")
    subtitle:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b, 0.7)
    
    -- Close button (styled X)
    local closeBtn = CreateFrame("Button", nil, titleBar, "BackdropTemplate")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", -4, 0)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    closeBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local closeIcon = closeBtn:CreateTexture(nil, "OVERLAY")
    closeIcon:SetPoint("CENTER", 0, 0)
    closeIcon:SetSize(12, 12)
    closeIcon:SetTexture("Interface\\AddOns\\DandersFrames\\Media\\Icons\\close")
    closeIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.4, 0.15, 0.15, 1)
        closeIcon:SetVertexColor(1, 0.3, 0.3)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        closeIcon:SetVertexColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    -- Clear button (themed)
    local clearBtn = CreateFrame("Button", nil, titleBar, "BackdropTemplate")
    clearBtn:SetSize(50, 20)
    clearBtn:SetPoint("RIGHT", closeBtn, "LEFT", -5, 0)
    clearBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    clearBtn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    clearBtn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
    local clearTxt = clearBtn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    clearTxt:SetPoint("CENTER")
    clearTxt:SetText("Clear")
    clearTxt:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
    clearBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.25, 1)
    end)
    clearBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
    end)
    clearBtn:SetScript("OnClick", function()
        DF:ClearCastHistory()
    end)
    
    -- Column headers
    local headerFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    headerFrame:SetHeight(22)
    headerFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -2)
    headerFrame:SetPoint("TOPRIGHT", titleBar, "BOTTOMRIGHT", 0, -2)
    headerFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    headerFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
    headerFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.3)
    
    local headerTime = headerFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    headerTime:SetPoint("LEFT", 5, 0)
    headerTime:SetWidth(30)
    headerTime:SetText("Time")
    headerTime:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local headerSpell = headerFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    headerSpell:SetPoint("LEFT", 40, 0)
    headerSpell:SetWidth(100)
    headerSpell:SetText("Spell")
    headerSpell:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    
    local headerCaster = headerFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
    headerCaster:SetPoint("LEFT", 165, 0)
    headerCaster:SetWidth(70)
    headerCaster:SetText("Caster")
    headerCaster:SetTextColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
    
    -- Player name headers (will be updated dynamically)
    frame.playerHeaders = {}
    for i = 1, 5 do
        local header = headerFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        header:SetPoint("LEFT", 240 + (i-1) * 65, 0)
        header:SetWidth(60)
        header:SetJustifyH("CENTER")
        header:SetTextColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
        header:Hide()
        frame.playerHeaders[i] = header
    end
    
    -- Content area (no scroll frame!)
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -2)
    content:SetPoint("TOPRIGHT", headerFrame, "BOTTOMRIGHT", 0, -2)
    content:SetHeight(ROWS_PER_PAGE * HISTORY_ROW_HEIGHT)
    frame.content = content
    
    -- Store theme colors for row access
    frame.themeColors = {
        C_BACKGROUND = C_BACKGROUND,
        C_PANEL = C_PANEL,
        C_ELEMENT = C_ELEMENT,
        C_BORDER = C_BORDER,
        C_ACCENT = C_ACCENT,
        C_TEXT = C_TEXT,
        C_TEXT_DIM = C_TEXT_DIM,
    }
    
    -- Create row pool for current page only
    for i = 1, ROWS_PER_PAGE do
        local row = CreateFrame("Frame", nil, content, "BackdropTemplate")
        row:SetHeight(HISTORY_ROW_HEIGHT)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i-1) * HISTORY_ROW_HEIGHT)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -(i-1) * HISTORY_ROW_HEIGHT)
        row:EnableMouse(true)
        row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
        row:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0)
        row.rowIndex = i  -- Store for alternating colors
        
        -- Time text
        local timeText = row:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        timeText:SetPoint("LEFT", 5, 0)
        timeText:SetWidth(30)
        timeText:SetJustifyH("LEFT")
        timeText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
        row.timeText = timeText
        
        -- Icon frame with border
        local iconFrame = CreateFrame("Frame", nil, row, "BackdropTemplate")
        iconFrame:SetSize(22, 22)
        iconFrame:SetPoint("LEFT", 35, 0)
        iconFrame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        iconFrame:SetBackdropColor(0, 0, 0, 0.5)
        iconFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 1)
        
        local icon = iconFrame:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 1, -1)
        icon:SetPoint("BOTTOMRIGHT", -1, 1)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.icon = icon
        row.iconFrame = iconFrame
        
        -- Interrupted X overlay
        local interruptedX = iconFrame:CreateTexture(nil, "OVERLAY")
        interruptedX:SetAllPoints()
        interruptedX:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
        interruptedX:SetVertexColor(1, 0.3, 0.3, 0.9)
        interruptedX:Hide()
        row.interruptedX = interruptedX
        
        -- Important spell border (controlled by SetAlphaFromBoolean)
        local importantBorder = CreateFrame("Frame", nil, row, "BackdropTemplate")
        importantBorder:SetPoint("TOPLEFT", iconFrame, "TOPLEFT", -2, 2)
        importantBorder:SetPoint("BOTTOMRIGHT", iconFrame, "BOTTOMRIGHT", 2, -2)
        importantBorder:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 2,
        })
        importantBorder:SetBackdropBorderColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b, 1)  -- Accent color
        importantBorder:SetAlpha(0)
        row.importantBorder = importantBorder
        
        -- Spell name
        local nameText = row:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        nameText:SetPoint("LEFT", iconFrame, "RIGHT", 4, 0)
        nameText:SetWidth(100)
        nameText:SetJustifyH("LEFT")
        nameText:SetWordWrap(false)
        nameText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        row.nameText = nameText
        
        -- Caster name
        local casterText = row:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        casterText:SetPoint("LEFT", 165, 0)
        casterText:SetWidth(70)
        casterText:SetJustifyH("LEFT")
        casterText:SetWordWrap(false)
        casterText:SetTextColor(C_ACCENT.r, C_ACCENT.g, C_ACCENT.b)
        row.casterText = casterText
        
        -- Target indicators (5 columns for party members)
        row.targetIndicators = {}
        for j = 1, 5 do
            local container = CreateFrame("Frame", nil, row)
            container:SetSize(60, 20)
            container:SetPoint("LEFT", 240 + (j-1) * 65, 0)
            
            -- YES frame (shown when targeted)
            local yesFrame = CreateFrame("Frame", nil, container)
            yesFrame:SetAllPoints()
            local yesText = yesFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
            yesText:SetAllPoints()
            yesText:SetText("|cffff6666YES|r")
            yesText:SetJustifyH("CENTER")
            container.yesFrame = yesFrame
            
            -- No frame (shown when not targeted)
            local noFrame = CreateFrame("Frame", nil, container)
            noFrame:SetAllPoints()
            local noText = noFrame:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
            noText:SetAllPoints()
            noText:SetText("|cff444444-|r")
            noText:SetJustifyH("CENTER")
            container.noFrame = noFrame
            
            -- N/A text
            local naText = container:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
            naText:SetAllPoints()
            naText:SetText("|cff222222--|r")
            naText:SetJustifyH("CENTER")
            naText:Hide()
            container.naText = naText
            
            container:Hide()
            row.targetIndicators[j] = container
        end
        
        -- Tooltip on hover with themed highlight
        row:SetScript("OnEnter", function(self)
            self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 0.8)
            -- Only show spell tooltips out of combat (some spells are "secret" in combat)
            if self.spellID and not InCombatLockdown() then
                GameTooltip:SetOwner(self.iconFrame, "ANCHOR_RIGHT")
                -- Still wrap in pcall as a safety net
                local success = pcall(function()
                    GameTooltip:SetSpellByID(self.spellID)
                end)
                if success then
                    GameTooltip:Show()
                else
                    GameTooltip:Hide()
                end
            end
        end)
        row:SetScript("OnLeave", function(self)
            -- Restore alternating background
            if self.rowIndex % 2 == 0 then
                self:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 0.5)
            else
                self:SetBackdropColor(C_BACKGROUND.r, C_BACKGROUND.g, C_BACKGROUND.b, 0)
            end
            GameTooltip:Hide()
        end)
        
        row:Hide()
        castHistoryRows[i] = row
    end
    
    -- Pagination controls at bottom (themed)
    local pageFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    pageFrame:SetHeight(32)
    pageFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    pageFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    pageFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    pageFrame:SetBackdropColor(C_PANEL.r, C_PANEL.g, C_PANEL.b, 1)
    pageFrame:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.3)
    
    -- Helper to create themed button
    local function CreateThemedButton(parent, text)
        local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(60, 22)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        btn:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
        btn:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
        
        local btnText = btn:CreateFontString(nil, "OVERLAY", "DFFontNormalSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(text)
        btnText:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
        btn.text = btnText
        btn.isEnabled = true
        
        btn:SetScript("OnEnter", function(self)
            if self.isEnabled then
                self:SetBackdropColor(C_ACCENT.r * 0.5, C_ACCENT.g * 0.5, C_ACCENT.b * 0.5, 1)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if self.isEnabled then
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
            end
        end)
        
        -- Custom SetEnabled for themed button
        btn.SetEnabled = function(self, enabled)
            self.isEnabled = enabled
            if enabled then
                self:SetBackdropColor(C_ELEMENT.r, C_ELEMENT.g, C_ELEMENT.b, 1)
                self:SetBackdropBorderColor(C_BORDER.r, C_BORDER.g, C_BORDER.b, 0.5)
                self.text:SetTextColor(C_TEXT.r, C_TEXT.g, C_TEXT.b)
                self:EnableMouse(true)
            else
                self:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
                self:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.3)
                self.text:SetTextColor(0.4, 0.4, 0.4)
                self:EnableMouse(false)
            end
        end
        
        return btn
    end
    
    local prevBtn = CreateThemedButton(pageFrame, "< Prev")
    prevBtn:SetPoint("LEFT", 10, 0)
    prevBtn:SetScript("OnClick", function()
        if currentPage > 1 then
            currentPage = currentPage - 1
            DF:RefreshCastHistoryUI()
        end
    end)
    frame.prevBtn = prevBtn
    
    local nextBtn = CreateThemedButton(pageFrame, "Next >")
    nextBtn:SetPoint("RIGHT", -10, 0)
    nextBtn:SetScript("OnClick", function()
        local maxPage = math.ceil(#castHistory / ROWS_PER_PAGE)
        if currentPage < maxPage then
            currentPage = currentPage + 1
            DF:RefreshCastHistoryUI()
        end
    end)
    frame.nextBtn = nextBtn
    
    local pageText = pageFrame:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    pageText:SetPoint("CENTER", 0, 0)
    pageText:SetText("Page 1 / 1")
    pageText:SetTextColor(C_TEXT_DIM.r, C_TEXT_DIM.g, C_TEXT_DIM.b)
    frame.pageText = pageText
    
    castHistoryFrame = frame
    DF.castHistoryFrame = frame
    
    return frame
end

-- Update player headers
local function UpdatePlayerHeaders()
    if not castHistoryFrame then return end
    
    local headers = castHistoryFrame.playerHeaders
    local sortOrder = {"player", "party1", "party2", "party3", "party4"}
    
    local idx = 1
    for _, unit in ipairs(sortOrder) do
        if unit == "player" or UnitExists(unit) then
            local name = UnitName(unit) or unit
            if #name > 7 then
                name = name:sub(1, 6) .. ".."
            end
            headers[idx]:SetText(name)
            headers[idx]:Show()
            idx = idx + 1
        end
    end
    
    for i = idx, 5 do
        headers[i]:Hide()
    end
end

-- Refresh the cast history UI with pagination
function DF:RefreshCastHistoryUI()
    if not castHistoryFrame then return end
    
    UpdatePlayerHeaders()
    
    local currentTime = GetTime()
    local totalEntries = #castHistory
    local maxPage = math.max(1, math.ceil(totalEntries / ROWS_PER_PAGE))
    
    -- Clamp current page
    if currentPage > maxPage then currentPage = maxPage end
    if currentPage < 1 then currentPage = 1 end
    
    -- Update page text
    castHistoryFrame.pageText:SetText(string.format("Page %d / %d  (%d casts)", currentPage, maxPage, totalEntries))
    
    -- Enable/disable pagination buttons
    castHistoryFrame.prevBtn:SetEnabled(currentPage > 1)
    castHistoryFrame.nextBtn:SetEnabled(currentPage < maxPage)
    
    -- Build current group order
    local sortOrder = {"player", "party1", "party2", "party3", "party4"}
    local activeUnits = {}
    for _, unit in ipairs(sortOrder) do
        if unit == "player" or UnitExists(unit) then
            table.insert(activeUnits, unit)
        end
    end
    
    -- Calculate which entries to show
    local startIdx = (currentPage - 1) * ROWS_PER_PAGE + 1
    
    -- Update rows
    for i, row in ipairs(castHistoryRows) do
        local entryIdx = startIdx + i - 1
        local entry = castHistory[entryIdx]
        
        if entry then
            -- Time
            local timeAgo = currentTime - entry.timestamp
            local timeStr
            if timeAgo < 60 then
                timeStr = string.format("%.0fs", timeAgo)
            elseif timeAgo < 3600 then
                timeStr = string.format("%.0fm", timeAgo / 60)
            else
                timeStr = string.format("%.0fh", timeAgo / 3600)
            end
            row.timeText:SetText(timeStr)
            
            -- Icon - just pass directly, let WoW handle it
            row.icon:SetTexture(entry.texture)
            row.spellID = entry.spellID
            
            -- Get secrets from separate table
            local secrets = DF.castHistorySecrets and DF.castHistorySecrets[entry.entryID]
            
            -- Important spell border - use SetAlphaFromBoolean directly (can't test secrets)
            -- If secrets exist, pass the isImportant secret; otherwise hide the border
            if secrets then
                row.importantBorder:SetAlphaFromBoolean(secrets.isImportant, 1, 0)
            else
                row.importantBorder:SetAlpha(0)
            end
            
            -- Alternating background (themed)
            if i % 2 == 0 then
                row:SetBackdropColor(0.12, 0.12, 0.12, 0.5)  -- C_PANEL
            else
                row:SetBackdropColor(0.08, 0.08, 0.08, 0)    -- C_BACKGROUND
            end
            
            -- Interrupted visual
            if entry.interrupted then
                row.interruptedX:Show()
                row.icon:SetDesaturated(true)
                row.icon:SetVertexColor(0.6, 0.6, 0.6)
            else
                row.interruptedX:Hide()
                row.icon:SetDesaturated(false)
                row.icon:SetVertexColor(1, 1, 1)
            end
            
            -- Name - just pass directly, let WoW handle secrets
            row.nameText:SetText(entry.name)
            
            -- Caster name - just pass directly
            row.casterText:SetText(entry.casterName)
            
            -- Hide all target indicators first
            for _, indicator in ipairs(row.targetIndicators) do
                indicator:Hide()
            end
            
            -- Show target indicators
            if entry.targetNames and secrets and secrets.targets then
                for idx, unit in ipairs(activeUnits) do
                    local hasName = entry.targetNames[unit]
                    local targetSecret = secrets.targets[unit]
                    local indicator = row.targetIndicators[idx]

                    -- We can compare to nil (type check, doesn't propagate secret
                    -- taint). After Blizzard's 2026-04-07 UnitIsUnit hotfix the
                    -- per-party-member targeting result is nil, so anything other
                    -- than the player will fall through to the N/A branch.
                    if hasName and indicator and targetSecret ~= nil then
                        -- Use SetAlphaFromBoolean for secret display
                        indicator.yesFrame:SetAlphaFromBoolean(targetSecret, 1, 0)
                        indicator.noFrame:SetAlphaFromBoolean(targetSecret, 0, 1)
                        indicator.naText:Hide()
                        indicator:Show()
                    elseif indicator then
                        indicator.yesFrame:SetAlpha(0)
                        indicator.noFrame:SetAlpha(0)
                        indicator.naText:Show()
                        indicator:Show()
                    end
                end
            end
            
            row:Show()
        else
            row:Hide()
        end
    end
end

-- Show cast history UI
function DF:ShowCastHistoryUI()
    local frame = DF:CreateCastHistoryUI()
    currentPage = 1  -- Reset to first page
    DF:RefreshCastHistoryUI()
    frame:Show()
    
    -- Set up periodic refresh while open
    if not frame.refreshTicker then
        frame.refreshTicker = C_Timer.NewTicker(1, function()
            if frame:IsShown() then
                DF:RefreshCastHistoryUI()
            end
        end)
    end
end

-- Toggle cast history UI
function DF:ToggleCastHistoryUI()
    if castHistoryFrame and castHistoryFrame:IsShown() then
        castHistoryFrame:Hide()
    else
        DF:ShowCastHistoryUI()
    end
end

-- Legacy chat output (keep for quick debug)
function DF:ShowCastHistory()
    DF:ShowCastHistoryUI()
end

-- ============================================================
-- TARGETED LIST
-- ============================================================
-- Stacked cast-bar display showing enemy casts targeting party
-- members. Anchored to the party frame container. Replaces the
-- group-frame Targeted Spells icons that Blizzard's 2026-04-07
-- UnitIsUnit hotfix permanently broke.
--
-- Party-mode only by design. We will not add raid support.
--
-- Implementation is split across commits:
--   * commit #3 (this one): scaffold — state tables, frame pool,
--     roster name cache, event hookup, empty lifecycle stubs
--   * commit #4: cast lifecycle (0.2s delay + all 13 gotchas from
--     the TS3 cross-reference in _Reference/targeted-spells-findings.md)
--   * commit #5: render pipeline + layout (bar build, LayoutBars,
--     Dispel-style skip-rebuild in the apply path)
--   * commit #6: settings sub-tab in Options.lua
--
-- The user-facing name "Targeted List" is intentionally decoupled
-- from the internal `targetedList*` db prefix. Renaming the feature
-- is a locale-only change; no code touches the string.
-- ============================================================

-- File-scope cached APIs (project convention, commit 1a5603d).
-- These are used by the cast lifecycle and render pipeline in later
-- commits; caching them here keeps the hot path zero-lookup.
local TL_UnitSpellTargetName = UnitSpellTargetName
local TL_UnitSpellTargetClass = UnitSpellTargetClass
local TL_UnitCastingInfo = UnitCastingInfo
local TL_UnitChannelInfo = UnitChannelInfo
local TL_UnitCastingDuration = UnitCastingDuration
local TL_UnitChannelDuration = UnitChannelDuration
local TL_UnitNameFromGUID = UnitNameFromGUID
local TL_UnitClassFromGUID = UnitClassFromGUID
local TL_UnitInParty = UnitInParty
local TL_UnitCanAttack = UnitCanAttack
local TL_UnitExists = UnitExists
local TL_UnitName = UnitName
local TL_UnitClass = UnitClass
local TL_IsInGroup = IsInGroup
local TL_IsInRaid = IsInRaid
local TL_GetTime = GetTime
local TL_C_Timer_After = C_Timer and C_Timer.After

-- ------------------------------------------------------------
-- State
-- ------------------------------------------------------------

-- activeTargetedListCasts[casterUnit] = {
--     spellId         = number,       -- clean (from event payload)
--     isChannel       = bool,         -- clean
--     startTime       = number,       -- clean local GetTime() approximation
--     duration        = TimerDuration, -- opaque object, fed to SetTimerDuration
--     uninterruptible = secret-bool,  -- only fed to SetVertexColorFromBoolean
--     casterUnit      = string,       -- clean (we generated it)
-- }
local activeTargetedListCasts = {}

-- Container frame that anchors the bar list in screen space. Created
-- on first enable. All children use the mover-driven position; there
-- is no party-frame anchor mode.
local targetedListContainer = nil

-- Frame pool + active bar array are declared further down in the
-- render pipeline section, close to the functions that use them.

-- Forward declaration: TargetedList_OnCastStop (below) calls
-- TargetedList_StartFadeTicker to kick off the fade-out re-render
-- ticker. The actual assignment happens in the render section far
-- below, because the ticker needs to call TargetedList_Render which
-- isn't defined until then. The file-local binding is hoisted here
-- so OnCastStop's reference resolves to the eventual assignment
-- rather than creating a stray global.
local TargetedList_StartFadeTicker

-- ------------------------------------------------------------
-- Runtime gate
-- ------------------------------------------------------------

-- Single source of truth for "is this feature allowed to run at all".
-- Every public entry point calls this; any time it returns false, the
-- caller must be a no-op.
local function TargetedList_IsGateOpen()
    return true
end

-- Map the current content type (from the shared GetContentType
-- helper above in this file) to the corresponding db toggle key.
local TARGETEDLIST_CONTENT_TYPE_KEY = {
    openworld   = "targetedListInOpenWorld",
    dungeon     = "targetedListInDungeons",
    raid        = "targetedListInRaids",
    arena       = "targetedListInArena",
    battleground = "targetedListInBattlegrounds",
}

-- Returns true if the user has enabled the feature for the current
-- content type. Gates the lifecycle so we don't pick up casts in
-- zones the user doesn't care about (e.g. disabling in open world).
local function TargetedList_ContentTypeAllowed(party)
    if not party then return false end
    local contentType = GetContentType()
    local key = TARGETEDLIST_CONTENT_TYPE_KEY[contentType]
    if not key then return true end  -- unknown → allow
    return party[key] ~= false
end

-- Secondary check: is the feature currently enabled by the user AND
-- are we in a party (not raid, not solo)? Used by the cast lifecycle
-- to decide whether to process incoming cast events.
--
-- NOTE: the content-type filter is deliberately NOT checked here.
-- It's checked separately at pickup time only (TargetedList_ShouldPickup)
-- so that stop events still clear tracked state even if the user
-- toggles content-type checkboxes mid-cast. Otherwise stale bars
-- would get stuck on screen until the next reload.
local function TargetedList_IsActive()
    if not TargetedList_IsGateOpen() then return false end
    if not DF.db then return false end
    local party = DF.db.party
    if not party or not party.targetedListEnabled then return false end
    if not TL_IsInGroup() then return false end
    if TL_IsInRaid() then return false end
    return true
end

-- Pickup-time gate: IsActive + content-type filter. Only applied
-- when deciding whether to START tracking a new cast. Cast-stop and
-- interruptibility-change handlers use IsActive alone so they can
-- clean up existing state regardless of content-type settings.
local function TargetedList_ShouldPickup()
    if not TargetedList_IsActive() then return false end
    local party = DF.db.party
    return TargetedList_ContentTypeAllowed(party)
end

-- Exposed for NeedsCastEvents below, so the shared event frame stays
-- registered when the Targeted List is the only active consumer.
function DF:TargetedListNeedsCastEvents()
    if not TargetedList_IsGateOpen() then return false end
    if not DF.db then return false end
    -- Party-only feature, but the raid profile may also toggle it on
    -- even though it won't actually render. Still register events so
    -- the user can see the toggle behave consistently in both modes.
    local p = DF.db.party
    return p and p.targetedListEnabled == true
end

-- ------------------------------------------------------------
-- Cast-targeting filter
-- ------------------------------------------------------------

-- Returns true if the caster's current cast target is a party member.
--
-- Why this shape: the "name-matching" approach the findings doc
-- originally proposed is dead because UnitSpellTargetName returns a
-- secret-tainted string on nameplates — it can't be used as a table
-- key or compared to anything. Instead we use TS3's filter
-- (Driver.lua:317): UnitInParty("nameplateXtarget"). This is a
-- compound-vs-party-token comparison that the findings doc warned
-- might be blocked by the 2026-04-07 hotfix. Empirically (and per
-- TS3's working implementation) it is NOT blocked — it returns a
-- usable boolean for this specific shape.
--
-- We don't return WHICH party member is targeted — we don't need to.
-- The render pipeline (commit #5) will fetch the target name via
-- UnitSpellTargetName and feed it directly into a FontString:SetText
-- secret-safe sink, which doesn't require comparing or indexing.
local function TargetedList_CastTargetIsPartyMember(casterUnit)
    local target = casterUnit .. "target"
    if not TL_UnitExists(target) then return false end
    -- Reject mob-targeting-mob casts (we'd never care about those)
    if TL_UnitCanAttack("player", target) then return false end
    -- The actual filter: is the targeted unit a party member?
    -- TS3 uses this exact compound-vs-party check post-hotfix.
    if TL_IsInGroup() and not TL_UnitInParty(target) then return false end
    return true
end

-- ------------------------------------------------------------
-- Cast lifecycle
-- ------------------------------------------------------------
-- Implements the 13 correctness gotchas captured in
-- _Reference/targeted-spells-findings.md §"Implementation gotchas".
-- Each gotcha is tagged inline as (gotcha #N).

-- Delay before we read cast data after UNIT_SPELLCAST_START. At the
-- instant the event fires, UnitSpellTargetName / UnitCastingDuration /
-- UnitChannelDuration all return nil — the engine populates them a
-- few frames later. TS3 uses 0.2s; match that. (gotcha #1)
local TARGETEDLIST_PICKUP_DELAY = 0.2

-- Is this unit a nameplate we're willing to look at? Filters out
-- friendly nameplates, party-member nameplates (wargames/mercenary),
-- and anything that isn't a valid enemy unit token.
local function TargetedList_IsRelevantCaster(casterUnit)
    if type(casterUnit) ~= "string" then return false end
    if string.sub(casterUnit, 1, 9) ~= "nameplate" then return false end
    if not TL_UnitExists(casterUnit) then return false end
    if not TL_UnitCanAttack("player", casterUnit) then return false end
    -- Exclude own party members that have nameplates (rare but real)
    if TL_UnitInParty(casterUnit) then return false end
    return true
end

-- File-scope cached APIs
local TL_UnitAffectingCombat = UnitAffectingCombat
local TL_UnitCastingDuration_API = UnitCastingDuration
local TL_UnitChannelDuration_API = UnitChannelDuration
local TL_C_Spell_GetSpellName = C_Spell and C_Spell.GetSpellName
local TL_C_Spell_GetSpellTexture = C_Spell and C_Spell.GetSpellTexture
local TL_C_Spell_IsSpellImportant = C_Spell and C_Spell.IsSpellImportant

-- IMPORTANT — secret-taint workaround (gotcha #0).
--
-- On nameplate units in instance combat, UnitCastingInfo and
-- UnitChannelInfo return SECRET-TAINTED values for the time fields
-- (startMS, endMS). Lua refuses arithmetic on secret values, so any
-- code that does (endMS - startMS) / 1000 raises:
--   "attempt to perform arithmetic on a secret number value"
--
-- The mitigation here mirrors TS3's approach (Driver.lua lines
-- 391-407):
--   * Don't extract time fields from Unit{Casting,Channel}Info — only
--     pull spellId (and castID for casts) via positional discard.
--   * Get spellId from the EVENT payload when possible — it's clean.
--   * Use UnitCastingDuration / UnitChannelDuration for duration.
--     The return value may itself be secret-tainted; treat it as
--     opaque and only feed it to secret-safe sinks at render time.
--   * GetTime() at pickup as a clean local approximation of start.
--   * C_Spell.GetSpellName / GetSpellTexture for clean metadata.

-- Delayed pickup: called 0.2s after START via C_Timer. Verifies the
-- cast is still active and targeting a party member, then records
-- minimal state. Cast-ID matching has been REMOVED (gotcha #0):
-- equality compare on a secret-tainted castID errors. We accept rare
-- flicker on rapid same-spell restart in exchange for not crashing.
local function TargetedList_DelayedPickup(casterUnit, isChannel, eventSpellId)
    if not TargetedList_ShouldPickup() then return end
    if not TargetedList_IsRelevantCaster(casterUnit) then return end

    -- Combat filter: skip casters not in combat (idle mobs casting nearby)
    local party = DF.db and DF.db.party
    if party and party.targetedListHideOutOfCombat then
        if not TL_UnitAffectingCombat(casterUnit) then return end
    end

    -- Targeting filter: check if the cast targets a party member.
    -- If "Show Untargeted" is on, also accept casts that have no
    -- target at all (ground AoEs, self-buffs, untargeted channels).
    local showUntargeted = party and party.targetedListShowUntargeted
    local target = casterUnit .. "target"
    local hasTarget = TL_UnitExists(target)

    if hasTarget then
        -- Has a target — check if it's a party member
        if not TargetedList_CastTargetIsPartyMember(casterUnit) then
            return
        end
    elseif not showUntargeted then
        -- No target and untargeted display is off — skip
        return
    end
    -- If hasTarget is false and showUntargeted is true, we fall through
    -- and show the bar with no target name.

    -- IMPORTANT — gotcha #0 update: spellId from the event payload is
    -- ALSO secret-tainted on nameplates. We can pass it through
    -- secret-safe sinks (SetText after C_Spell.GetSpellName, SetTexture
    -- after C_Spell.GetSpellTexture, SetShownFromBoolean after
    -- C_Spell.IsSpellImportant) but we cannot truth-test, compare,
    -- string.format, or otherwise inspect it in Lua.
    --
    -- Practical consequences:
    --   * Important-spells filter is DROPPED here. The render pipeline
    --     in commit #5 will implement it via SetShownFromBoolean using
    --     the secret-tainted IsSpellImportant return.
    --   * Spell name / texture are NOT read here. The render pipeline
    --     will fetch them at render time and feed them straight into
    --     SetText / SetTexture sinks.
    --   * The debug log can only print clean values (casterUnit, the
    --     channel flag, the event name). No spell name.
    local spellId = eventSpellId
    if spellId == nil then return end

    -- Re-detect cast vs channel at pickup time. The 0.2s delay means
    -- a cast may have transitioned to a channel since the START event.
    -- Check casting first, fall back to channel.
    local notInterruptible
    if TL_UnitCastingInfo(casterUnit) ~= nil then
        isChannel = false
        notInterruptible = select(8, TL_UnitCastingInfo(casterUnit))
    elseif TL_UnitChannelInfo(casterUnit) ~= nil then
        isChannel = true
        notInterruptible = select(7, TL_UnitChannelInfo(casterUnit))
    else
        -- Cast vanished during the 0.2s delay (CC, mob death, etc.)
        return
    end

    -- Duration: try both APIs regardless of isChannel flag. A cast that
    -- transitions to a channel may report via either API during the
    -- brief overlap.
    local duration = (TL_UnitCastingDuration_API and TL_UnitCastingDuration_API(casterUnit))
        or (TL_UnitChannelDuration_API and TL_UnitChannelDuration_API(casterUnit))

    activeTargetedListCasts[casterUnit] = {
        spellId         = spellId,           -- secret; only feed to C_Spell.* + sinks
        isChannel       = isChannel,         -- clean
        startTime       = TL_GetTime(),      -- clean local approximation
        duration        = duration,          -- opaque TimerDuration object
        uninterruptible = notInterruptible,  -- secret; SetVertexColorFromBoolean only
        casterUnit      = casterUnit,        -- clean (we generated it)
        -- spellName / spellTexture / targetName / targetClass / targetUnit
        -- intentionally NOT stored. All fetched at render time via the
        -- secret-tainted APIs and piped directly into secret-safe sinks
        -- (SetText, SetTexture, SetTextColor via C_ClassColor).
    }

    -- Safety timer: if the cast stop event never fires (CC, LOS,
    -- mob death, etc.), force-remove the record after a generous
    -- timeout. TS3 uses OnCooldownDone for this but that requires a
    -- Cooldown frame per bar — our simpler approach uses C_Timer.
    -- 15 seconds covers the longest enemy casts in WoW.
    -- Safety timer: force-remove the record if no stop event fires
    -- within 15 seconds. Uses DF._TargetedListRender to trigger a
    -- render pass which handles the cleanup (bar release + slot free)
    -- through the normal expiry path by marking as fading with 0 dur.
    -- Safety timer: periodically check if the unit is still casting.
    -- If not, force-remove the record. This catches cases where the
    -- cast stop event doesn't fire (CC, LOS, mob death, etc.).
    -- Unlike the previous fixed-timeout approach, this reschedules
    -- as long as the unit is still casting — so long channels (20s+)
    -- aren't prematurely removed.
    local SAFETY_CHECK_INTERVAL = 5
    if TL_C_Timer_After then
        local function safetyCheck()
            local rec = activeTargetedListCasts[casterUnit]
            if not rec or rec.fadingStartedAt or rec.isTestCast then
                return  -- already handled or test record
            end
            -- Check if the unit is still actually casting/channeling
            local stillCasting = TL_UnitExists(casterUnit)
                and (TL_UnitCastingInfo(casterUnit) ~= nil
                     or TL_UnitChannelInfo(casterUnit) ~= nil)
            if stillCasting then
                -- Still casting — reschedule another check
                TL_C_Timer_After(SAFETY_CHECK_INTERVAL, safetyCheck)
            else
                -- Not casting anymore — force-remove
                rec.fadingStartedAt = TL_GetTime()
                rec.fadingDuration = 0
                if DF._TargetedListRender then
                    DF._TargetedListRender()
                end
            end
        end
        TL_C_Timer_After(SAFETY_CHECK_INTERVAL, safetyCheck)
    end

    -- Debug log: only clean values. spellId / spellName / texture are
    -- all secret-tainted and can't be formatted.
    if DF.Debug then
        DF:Debug("TARGETEDLIST", "+cast %s%s",
            casterUnit,
            isChannel and " [channel]" or "")
    end
end

-- Called for UNIT_SPELLCAST_START / CHANNEL_START / EMPOWER_START.
-- Schedules the 0.2s delayed pickup — cast data isn't available yet
-- when the START event fires (gotcha #1).
--
-- Note: NAME_PLATE_UNIT_ADDED and UNIT_TARGET re-pickup paths are
-- intentionally NOT routed here. They don't carry spellId in their
-- event payloads, so we'd have to read it from the API — but the
-- secret-taint workaround (gotcha #0) makes that path fragile. The
-- visible cost is missing a bar when a nameplate enters range while
-- the mob is mid-cast (gap bounded by the cast remaining duration).
local function TargetedList_ProcessCastStart(casterUnit, event, ...)
    if not TargetedList_ShouldPickup() then return end
    if not TargetedList_IsRelevantCaster(casterUnit) then return end
    if not TL_C_Timer_After then return end

    local isChannel
    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        isChannel = true
    else  -- UNIT_SPELLCAST_START / UNIT_SPELLCAST_EMPOWER_START
        isChannel = false
    end

    -- Cast-to-channel transition: if CHANNEL_START fires and we already
    -- have a cast record for this unit, update the record immediately
    -- instead of waiting 0.2s. The channel duration is available now.
    -- We must re-apply bar content directly because the render loop
    -- only calls ApplyBarContent for newly assigned bars, not existing ones.
    -- Uses DF._TargetedListTransitionToChannel (defined later, after
    -- casterToBar and ApplyBarContent are in scope).
    if isChannel then
        local existing = activeTargetedListCasts[casterUnit]
        if existing and not existing.fadingStartedAt and not existing.isChannel then
            local channelDuration = TL_UnitChannelDuration_API
                and TL_UnitChannelDuration_API(casterUnit)
            if channelDuration then
                existing.duration = channelDuration
                existing.isChannel = true
                existing.uninterruptible = select(7, TL_UnitChannelInfo(casterUnit))
                if DF._TargetedListTransitionToChannel then
                    DF._TargetedListTransitionToChannel(casterUnit, existing)
                end
                return
            end
        end
    end

    -- Event payload (after `unit` consumed by OnEvent): (castGuid, spellId).
    -- We only need spellId — castGuid was used for cast-ID matching, which
    -- we've removed because secret-string equality compare errors.
    local _, eventSpellId = ...

    TL_C_Timer_After(TARGETEDLIST_PICKUP_DELAY, function()
        TargetedList_DelayedPickup(casterUnit, isChannel, eventSpellId)
    end)
end

-- Called for every "cast stopped" shaped event. Handles cast-ID
-- matching, SUCCEEDED-during-channel suppression, mob-death guards,
-- and interrupter lookup.
local function TargetedList_OnCastStop(casterUnit, event, ...)
    if not TargetedList_IsActive() then return end

    local active = activeTargetedListCasts[casterUnit]
    if not active then return end

    -- Gotcha #3: some channel spells (pulse DoTs, ground-effect zones)
    -- emit SUCCEEDED once per tick while still channeling. Also covers
    -- cast-to-channel transitions — the channel data may not be ready
    -- yet at SUCCEEDED time, so we just skip the fade and let
    -- CHANNEL_START handle the transition.
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if TL_UnitChannelInfo(casterUnit) ~= nil then return end
    end

    -- INTERRUPTED fires before STOP. If the record is already fading
    -- as interrupted, don't let STOP overwrite with the short fade.
    if active.wasInterrupted and active.fadingStartedAt then return end

    -- Gotcha #2 (cast-ID matching) has been REMOVED — see gotcha #0 in
    -- the findings doc. Equality compare on a secret-tainted castID
    -- errors. Without the match, rapid same-spell restarts may briefly
    -- show stale state. Acceptable for v1.

    local wasInterrupted = (event == "UNIT_SPELLCAST_INTERRUPTED")
    local active = activeTargetedListCasts[casterUnit]
    if not active then return end

    -- Store interrupter GUID for display. The GUID is secret-tainted
    -- on nameplates but UnitNameFromGUID → SetText is a secret-safe
    -- sink chain — we never inspect the value in Lua. For non-
    -- interrupt events this is harmlessly nil.
    local interrupterGuid = select(3, ...)

    local party = DF.db and DF.db.party
    local fadeDuration
    if wasInterrupted then
        fadeDuration = (party and party.targetedListInterruptedFlashDuration) or 1.0
    else
        fadeDuration = (party and party.targetedListFadeOutDuration) or 0.25
    end

    if fadeDuration and fadeDuration > 0 then
        active.fadingStartedAt = TL_GetTime()
        active.fadingDuration  = fadeDuration
        active.wasInterrupted  = wasInterrupted
        active.interrupterGuid = wasInterrupted and interrupterGuid or nil
        if TargetedList_StartFadeTicker then
            TargetedList_StartFadeTicker()
        end
    else
        activeTargetedListCasts[casterUnit] = nil
    end

    if DF.Debug then
        DF:Debug("TARGETEDLIST", "-cast %s: %s%s",
            casterUnit, event,
            wasInterrupted and " [interrupted]" or "")
    end
end

-- Gotcha #9: mob interruptibility toggles mid-cast. The clean boolean
-- from the event replaces the (possibly secret-tainted) value from
-- UnitCastingInfo so future bar redraws can branch on it cleanly.
local function TargetedList_OnInterruptibilityChange(casterUnit, isInterruptible)
    if not TargetedList_IsActive() then return end
    local active = activeTargetedListCasts[casterUnit]
    if not active then return end
    -- The stored field is "uninterruptible" (matches the WoW API name).
    -- Clean booleans are always safe to feed into SetVertexColorFromBoolean.
    active.uninterruptible = not isInterruptible
    if DF.Debug then
        DF:Debug("TARGETEDLIST", "~cast %s: interruptible=%s",
            casterUnit, tostring(isInterruptible))
    end
    -- Commit #5: apply to the bar via SetVertexColorFromBoolean.
end

-- Mid-cast update handler: UNIT_SPELLCAST_DELAYED, CHANNEL_UPDATE,
-- EMPOWER_UPDATE. The cast duration may have changed (pushback,
-- channel extension, empower stage). Re-read the duration object and
-- re-apply content so the bar fill stays in sync.
local function TargetedList_OnCastUpdate(casterUnit, event, ...)
    if not TargetedList_IsActive() then return end
    local rec = activeTargetedListCasts[casterUnit]
    if not rec or rec.fadingStartedAt then return end

    -- Re-read the duration object (may have changed).
    local isChannel = rec.isChannel
    local newDuration
    if isChannel then
        newDuration = TL_UnitChannelDuration and TL_UnitChannelDuration(casterUnit)
    else
        newDuration = TL_UnitCastingDuration and TL_UnitCastingDuration(casterUnit)
    end
    if newDuration then
        rec.duration = newDuration
    end

    -- Re-read notInterruptible (may have changed with pushback).
    if isChannel then
        rec.uninterruptible = select(7, TL_UnitChannelInfo(casterUnit))
    else
        rec.uninterruptible = select(8, TL_UnitCastingInfo(casterUnit))
    end

    -- Re-apply content to the existing bar to update fill + countdown.
    local bar = casterToBar and casterToBar[casterUnit]
    if bar then
        TargetedList_ApplyBarContent(bar, rec)
    end
end

-- Mid-cast target change handler: the enemy swapped target while
-- casting. If we're already tracking this caster, verify the new
-- target is still a party member. If not, drop the bar. We can't
-- pick up NEW casts from UNIT_TARGET (no spellId in the payload)
-- but we CAN drop existing bars that are no longer relevant.
local function TargetedList_OnTargetChange(casterUnit)
    if not TargetedList_IsActive() then return end
    local rec = activeTargetedListCasts[casterUnit]
    if not rec or rec.fadingStartedAt or rec.isTestCast then return end

    -- Check if the caster's new target is still a party member
    -- (or no target at all, which we might want to keep if
    -- showUntargeted is on).
    local target = casterUnit .. "target"
    local hasTarget = TL_UnitExists(target)
    local party = DF.db and DF.db.party

    if hasTarget then
        if not TargetedList_CastTargetIsPartyMember(casterUnit) then
            -- New target isn't a party member — drop the bar
            activeTargetedListCasts[casterUnit] = nil
            if DF._TargetedListRender then DF._TargetedListRender() end
        end
    elseif not (party and party.targetedListShowUntargeted) then
        -- No target and untargeted display is off — drop
        activeTargetedListCasts[casterUnit] = nil
        if DF._TargetedListRender then DF._TargetedListRender() end
    end
end

-- Stale-bar validation: iterate all tracked bars and verify each
-- one is still valid (nameplate exists, unit is casting/channeling).
-- Remove any that are stale. Called on zone transitions and loading
-- screen exit to catch bars that weren't cleaned up by normal events
-- (e.g. missed NAME_PLATE_UNIT_REMOVED during heavy nameplate
-- recycling, or zone changes that don't fire proper stop events).
local function TargetedList_ValidateTrackedBars()
    if not TargetedList_IsGateOpen() then return end
    local anyRemoved = false
    for unit, rec in pairs(activeTargetedListCasts) do
        if not rec.isTestCast and not rec.fadingStartedAt then
            -- Check: does the nameplate still exist?
            if not TL_UnitExists(unit) then
                activeTargetedListCasts[unit] = nil
                anyRemoved = true
            -- Check: is the unit still casting/channeling?
            elseif TL_UnitCastingInfo(unit) == nil
               and TL_UnitChannelInfo(unit) == nil then
                activeTargetedListCasts[unit] = nil
                anyRemoved = true
            end
        end
    end
    if anyRemoved and DF._TargetedListRender then
        DF._TargetedListRender()
    end
end

-- Gotcha #11: nameplate removal events don't reliably fire on zone
-- transitions. Also used on feature disable and on explicit cleanup.
local function TargetedList_ReleaseAllBars()
    if not TargetedList_IsGateOpen() then return end
    wipe(activeTargetedListCasts)
    -- Commit #5: release every pooled bar back to the framepool.
    if DF.Debug then
        DF:Debug("TARGETEDLIST", "release all bars")
    end
end

-- Expose internal hooks for the shared OnEvent dispatcher above.
DF._TargetedListProcessCastStart = TargetedList_ProcessCastStart
DF._TargetedListOnCastStop = TargetedList_OnCastStop
DF._TargetedListOnCastUpdate = TargetedList_OnCastUpdate
DF._TargetedListOnInterruptibilityChange = TargetedList_OnInterruptibilityChange
DF._TargetedListOnTargetChange = TargetedList_OnTargetChange
DF._TargetedListValidateAll = TargetedList_ValidateTrackedBars
DF._TargetedListReleaseAllBars = TargetedList_ReleaseAllBars

-- ------------------------------------------------------------
-- Public entry points
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- Render pipeline
-- ------------------------------------------------------------
-- All user-facing rendering flows through secret-safe sinks so that
-- values from UnitCastingInfo / UnitSpellTargetName / etc. — which
-- are secret-tainted on nameplates — can be displayed without ever
-- being inspected in Lua.
--
-- Safe sinks used below:
--   FontString:SetText(secretString)
--   Texture:SetTexture(secretTextureId)
--   StatusBar:SetTimerDuration(secretDurationObj, interp, direction)
--   Texture:SetVertexColorFromBoolean(secretBool, cA, cB)
--   Frame:SetShownFromBoolean(secretBool, true, false)
--   Frame:SetAlphaFromBoolean(secretBool, aOn, aOff)
--   C_ClassColor.GetClassColor(secretClassString) -> secret-safe color
--
-- Unsafe operations (never applied to secret values):
--   arithmetic, concatenation, equality compare with non-nil, truth
--   tests, table keys, string.format, tostring, print.

local TL_C_ClassColor = C_ClassColor

-- Lazy-created render state. All nil until the feature is first
-- enabled. On stable releases these stay nil forever (gate blocks).
-- (The bar pool itself is declared later, next to its helpers.)
local activeBars = {}  -- ordered list of currently-displayed bars

-- Per-caster bar map: casterToBar[casterUnit] = bar frame.
-- This is the incremental tracking table — bars persist until their
-- cast record is removed, avoiding the teardown-all/rebuild-all
-- pattern that caused performance issues.
local casterToBar = {}

-- Slot tracking for STATIC sort order. Each record gets a fixed slot
-- index at acquisition time. The slot persists until the record is
-- removed. When a record is removed its slot becomes available for
-- the next new record.
local casterToSlot = {}   -- [casterUnit] = slotIndex
local nextFreeSlot = 1    -- next slot to assign

-- Active test mode — when true, the container is populated from
-- synthetic data instead of live casts.
local targetedListTestActive = false

-- Layout version stamp, used for the Dispel-style skip-rebuild guard.
-- Incremented whenever a layout-affecting setting changes.
local targetedListLayoutVersion = 0

-- ------------------------------------------------------------
-- Container + bar creation
-- ------------------------------------------------------------

-- Compute the maximum container footprint: barWidth x
-- (barHeight*maxBars + spacing*(maxBars-1))
local function TargetedList_ComputeContainerSize(db)
    local w = db.targetedListWidth or 240
    local h = db.targetedListHeight or 22
    local spacing = db.targetedListSpacing or 2
    local max = db.targetedListMaxBars or 6
    if max < 1 then max = 1 end
    local height = (h * max) + (spacing * (max - 1))
    return w, height
end

local function TargetedList_EnsureContainer()
    if targetedListContainer then return targetedListContainer end
    local c = CreateFrame("Frame", "DandersFramesTargetedListContainer", UIParent)
    c:SetFrameStrata("MEDIUM")
    c:Hide()
    targetedListContainer = c
    return c
end

-- Build a single bar frame from scratch. Called by the pool's
-- acquire path on a cold fetch.
--
-- IMPORTANT: bars are plain Frames, NOT Buttons with
-- SecureActionButtonTemplate. A previous version used the secure
-- template so click-to-target could set a "unit" attribute, but the
-- container then became "parent of a secure child" and :Hide() on
-- it was protected during combat — triggering ADDON_ACTION_BLOCKED
-- every time the last active cast stopped mid-pull. Click-to-target
-- is deferred until we have a combat-safe mechanism for it.
--
-- Structure:
--   Frame
--     Background texture
--     Border
--     Icon texture (left-aligned by default)
--     StatusBar (progress fill)
--       Spell name FontString
--       Target name FontString
local function TargetedList_BuildBar(parent)
    local bar = CreateFrame("Frame", nil, parent)
    bar:Hide()
    bar:SetFrameStrata("MEDIUM")

    -- Background (solid color behind everything). Color + alpha
    -- applied by TargetedList_ApplyBarAppearance on every render.
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bar)
    bg:SetColorTexture(0, 0, 0, 0.6)
    bar.bg = bg

    -- Border (backdrop-template frame). Visibility + color applied
    -- by TargetedList_ApplyBarAppearance.
    local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    border:SetAllPoints(bar)
    border:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    border:SetBackdropBorderColor(0, 0, 0, 1)
    bar.border = border

    -- Icon — anchored dynamically by ApplyBarAppearance so its
    -- position (LEFT/RIGHT) and zoom state can change at runtime.
    local icon = bar:CreateTexture(nil, "ARTWORK")
    bar.icon = icon

    -- Progress StatusBar. Anchors are set by ApplyBarAppearance to
    -- leave room for the icon depending on its position.
    local progress = CreateFrame("StatusBar", nil, bar)
    progress:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    progress:SetMinMaxValues(0, 1)
    progress:SetValue(0)
    bar.progress = progress

    -- Text overlays on the progress bar. Anchor / offset / font are
    -- applied by ApplyBarAppearance and ApplyTextLayout per render.
    local spellName = progress:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    spellName:SetJustifyV("MIDDLE")
    spellName:SetWordWrap(false)
    bar.spellName = spellName

    local targetName = progress:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    targetName:SetJustifyV("MIDDLE")
    targetName:SetWordWrap(false)
    bar.targetName = targetName

    -- Duration countdown text. We use a custom FontString updated via
    -- OnUpdate instead of Blizzard's native Cooldown countdown, so that
    -- custom fonts can be applied. The remaining time is read from the
    -- duration object stored on the bar via GetRemainingDuration().
    local durationText = progress:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    durationText:SetJustifyV("MIDDLE")
    durationText:SetWordWrap(false)
    bar.duration = durationText

    -- OnUpdate: refresh duration countdown text every ~100ms.
    -- Read duration from the StatusBar via GetTimerDuration() each tick,
    -- call GetRemainingDuration(), feed
    -- directly to SetFormattedText (a secret-safe sink). Use explicit
    -- == nil checks (not truthiness) to avoid secret-taint errors.
    bar._durationElapsed = 0
    bar:SetScript("OnUpdate", function(self, elapsed)
        self._durationElapsed = self._durationElapsed + elapsed
        if self._durationElapsed < 0.1 then return end
        self._durationElapsed = self._durationElapsed - 0.1
        if not self.duration:IsShown() then return end
        if self._testDuration then
            -- Test bar: compute from startTime + totalDuration (clean values)
            local td = self._testDuration
            local remaining = td.totalDuration - (TL_GetTime() - td.startTime)
            if remaining > 0 then
                self.duration:SetFormattedText("%.1f", remaining)
            else
                self.duration:SetText("")
            end
        else
            -- Live bar: read duration fresh from the StatusBar each tick
            local durationObj = self.progress:GetTimerDuration()
            if durationObj == nil then return end
            self.duration:SetFormattedText("%.1f", durationObj:GetRemainingDuration())
        end
    end)

    -- Interrupter name FontString — shown during interrupted-flash
    -- fade with the name of who kicked the cast. Overlays spell name
    -- and target name (which are hidden during the flash).
    local interruptText = progress:CreateFontString(nil, "OVERLAY", "DFFontHighlightSmall")
    interruptText:SetPoint("CENTER", progress, "CENTER", 0, 0)
    interruptText:SetJustifyH("CENTER")
    interruptText:SetJustifyV("MIDDLE")
    interruptText:SetWordWrap(false)
    interruptText:Hide()
    bar.interruptText = interruptText

    -- Highlight frame for important-spell glow. Reuses the existing
    -- InitGlowBorder / UpdateGlowBorder infrastructure from the
    -- personal targeted spells icon system. Shown only for important
    -- spells via SetAlphaFromBoolean (secret-safe).
    local highlight = CreateFrame("Frame", nil, bar)
    highlight:SetAllPoints(bar)
    highlight:SetFrameLevel(bar:GetFrameLevel() + 5)
    highlight:Hide()
    bar.highlightFrame = highlight

    -- Self-target color overlay. A frame wrapping a colored texture,
    -- shown/hidden via SetShownFromBoolean (secret-safe sink) when
    -- the enemy cast targets the player.
    local selfFrame = CreateFrame("Frame", nil, progress)
    selfFrame:SetAllPoints()
    selfFrame:SetFrameLevel(progress:GetFrameLevel() + 1)
    selfFrame:Hide()
    local selfTex = selfFrame:CreateTexture(nil, "OVERLAY")
    selfTex:SetAllPoints()
    bar.selfTargetFrame = selfFrame
    bar.selfTargetTex = selfTex

    return bar
end

-- Helper: resolve an anchor-name string to a WoW SetPoint argument.
local function TargetedList_ResolveAnchorPoint(anchorName)
    if anchorName == "CENTER" then return "CENTER" end
    if anchorName == "RIGHT" then return "RIGHT" end
    return "LEFT"
end

-- Apply anchor/offset/alignment settings to a bar's text elements.
-- Anchor controls WHERE the element is placed on the bar. Alignment
-- controls how text WITHIN the element is justified — independently
-- of anchor, so users can e.g. anchor target name to RIGHT but
-- left-justify the text within it.
local function TargetedList_ApplyTextLayout(bar, db)
    if not bar or not db then return end

    -- Default text element width derived from the bar width setting.
    -- We don't call bar.progress:GetWidth() because it returns a
    -- secret-tainted number on nameplate-parented bars, and the
    -- comparison (< 10) would error. The db value is always clean.
    local barW = db.targetedListWidth or 240
    local barH = db.targetedListHeight or 22
    local showIcon = db.targetedListShowIcon ~= false
    local progressW = showIcon and (barW - barH) or (barW - 2)

    local function applyTextElement(fs, anchorKey, alignKey, widthKey, xKey, yKey, defaultAnchor, defaultAlign)
        if not fs then return end
        local point = TargetedList_ResolveAnchorPoint(db[anchorKey] or defaultAnchor)
        local align = db[alignKey] or defaultAlign or point
        local w = (widthKey and db[widthKey] or 0) or 0
        if w <= 0 then w = progressW end
        fs:ClearAllPoints()
        fs:SetPoint(point, bar.progress, point,
            db[xKey] or 0, db[yKey] or 0)
        fs:SetWidth(w)
        fs:SetJustifyH(align)
    end

    applyTextElement(bar.spellName,
        "targetedListSpellNameAnchor", "targetedListSpellNameAlign",
        "targetedListSpellNameWidth",
        "targetedListSpellNameX", "targetedListSpellNameY", "LEFT", "LEFT")
    applyTextElement(bar.targetName,
        "targetedListTargetNameAnchor", "targetedListTargetNameAlign",
        "targetedListTargetNameWidth",
        "targetedListTargetNameX", "targetedListTargetNameY", "RIGHT", "RIGHT")

    -- Interrupt text — normally hidden, shown during interrupted flash
    applyTextElement(bar.interruptText,
        "targetedListInterruptTextAnchor", "targetedListInterruptTextAlign",
        "targetedListInterruptTextWidth",
        "targetedListInterruptTextX", "targetedListInterruptTextY", "CENTER", "CENTER")

    -- Duration: now a FontString like the others, positioned via applyTextElement.
    applyTextElement(bar.duration,
        "targetedListDurationAnchor", "targetedListDurationAlign",
        nil,  -- no width key; duration text is short
        "targetedListDurationX", "targetedListDurationY", "RIGHT", "RIGHT")
end

-- Apply static appearance settings to a bar. "Static" here means the
-- configuration doesn't depend on the active cast — it's settings
-- that come straight from db: icon position/zoom/show, border color
-- and visibility, background alpha, statusbar texture, font, show/
-- hide toggles for all text elements.
--
-- Called per bar during render (both real and test paths), and again
-- from UpdateTargetedListLayout when settings change. The function
-- runs at drag-tick rate during slider interaction so keep it cheap.
local function TargetedList_ApplyBarAppearance(bar, db)
    if not bar or not db then return end
    local barH = db.targetedListHeight or 22
    local showIcon = db.targetedListShowIcon ~= false
    local iconPos = db.targetedListIconPosition or "LEFT"

    -- ----- Icon: show/hide, position, zoom -----
    bar.icon:ClearAllPoints()
    if showIcon then
        bar.icon:Show()
        bar.icon:SetHeight(barH - 2)
        bar.icon:SetWidth(barH - 2)
        if iconPos == "RIGHT" then
            bar.icon:SetPoint("TOPRIGHT", bar, "TOPRIGHT", -1, -1)
            bar.icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -1, 1)
        else
            bar.icon:SetPoint("TOPLEFT", bar, "TOPLEFT", 1, -1)
            bar.icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 1, 1)
        end
        if db.targetedListZoomIcon ~= false then
            bar.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        else
            bar.icon:SetTexCoord(0, 1, 0, 1)
        end
    else
        bar.icon:Hide()
    end

    -- ----- Progress StatusBar: anchors leave room for the icon -----
    bar.progress:ClearAllPoints()
    if showIcon and iconPos == "RIGHT" then
        bar.progress:SetPoint("TOPLEFT", bar, "TOPLEFT", 1, -1)
        bar.progress:SetPoint("BOTTOMRIGHT", bar.icon, "BOTTOMLEFT", -1, 0)
    elseif showIcon then
        bar.progress:SetPoint("TOPLEFT", bar.icon, "TOPRIGHT", 1, 0)
        bar.progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -1, 1)
    else
        bar.progress:SetPoint("TOPLEFT", bar, "TOPLEFT", 1, -1)
        bar.progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -1, 1)
    end

    -- ----- StatusBar texture -----
    -- Only call SetStatusBarTexture if the path changed — calling it
    -- unconditionally resets the StatusBar's internal value/fill state,
    -- which clobbers the progress fill set by ApplyBarContent.
    local texturePath = db.targetedListTexture or "Interface\\TargetingFrame\\UI-StatusBar"
    if bar._lastTexturePath ~= texturePath then
        bar.progress:SetStatusBarTexture(texturePath)
        bar._lastTexturePath = texturePath
    end

    -- ----- Background alpha -----
    local bgAlpha = db.targetedListBackgroundAlpha or 0.6
    bar.bg:SetColorTexture(0, 0, 0, bgAlpha)

    -- ----- Border show/hide + color -----
    local showBorder = db.targetedListShowBorder ~= false
    if showBorder then
        bar.border:Show()
        local bc = db.targetedListBorderColor or {r=0, g=0, b=0, a=1}
        bar.border:SetBackdropBorderColor(bc.r or 0, bc.g or 0, bc.b or 0, bc.a or 1)
    else
        bar.border:Hide()
    end

    -- ----- Font (all text elements share one font + outline setting) -----
    local fontName = db.targetedListFont or "Friz Quadrata TT"
    local fontSize = db.targetedListFontSize or 12
    local outline = db.targetedListFontOutline or ""

    -- Per-element font sizes fall back to the global targetedListFontSize.
    -- 0 means "use global" (the default for per-element overrides).
    local spellNameFontSize = db.targetedListSpellNameFontSize
    if not spellNameFontSize or spellNameFontSize == 0 then spellNameFontSize = fontSize end
    local targetNameFontSize = db.targetedListTargetNameFontSize
    if not targetNameFontSize or targetNameFontSize == 0 then targetNameFontSize = fontSize end

    DF:SafeSetFont(bar.spellName, fontName, spellNameFontSize, outline)
    DF:SafeSetFont(bar.targetName, fontName, targetNameFontSize, outline)
    if bar.interruptText then
        local intFontSize = db.targetedListInterruptTextFontSize
        if not intFontSize or intFontSize == 0 then intFontSize = fontSize end
        DF:SafeSetFont(bar.interruptText, fontName, intFontSize, outline)
    end
    if bar.duration then
        local durFontSize = db.targetedListDurationFontSize
        if not durFontSize or durFontSize == 0 then durFontSize = fontSize end
        DF:SafeSetFont(bar.duration, fontName, durFontSize, outline)
    end

    -- ----- Per-element show/hide toggles -----
    -- NOTE: spell name and target name visibility is handled in
    -- ApplyBarContent because it depends on the fading/interrupt
    -- state (hidden during interrupted flash to make room for the
    -- interrupter name). Only duration is toggled here.
    bar.duration:SetShown(db.targetedListShowDuration ~= false)
end

-- Release callback for the pool.
local function TargetedList_ResetBar(pool, bar)
    bar:Hide()
    bar:SetAlpha(1)
    bar:ClearAllPoints()
    bar.casterUnit = nil
    bar.spellId = nil
    bar.isChannel = nil
    bar.testAnim = nil
    bar.progress:SetValue(0)
    bar.progress:SetStatusBarColor(1, 0.2, 0.2, 1)
    bar.spellName:SetText("")
    bar.targetName:SetText("")
    if bar.duration then
        bar.duration:SetText("")
    end
    bar._testDuration = nil
    bar.icon:SetTexture(nil)
    bar._lastTexturePath = nil
    if bar.highlightFrame then
        bar.highlightFrame:Hide()
    end
    if bar.interruptText then
        bar.interruptText:SetText("")
        bar.interruptText:Hide()
    end
end

-- Manual pool — CreateFramePool requires an XML template, which we
-- don't have (bars are built programmatically). Simple array of
-- available bars + array of currently-used bars. Acquire pops from
-- available (or builds a new one); Release wipes and pushes back.
local targetedListBarPoolAvailable = {}

local function TargetedList_AcquireBar()
    local parent = TargetedList_EnsureContainer()
    local bar = table.remove(targetedListBarPoolAvailable)
    if not bar then
        bar = TargetedList_BuildBar(parent)
    end
    -- Apply appearance immediately so bars never show with template fonts
    local db = DF.db and DF.db.party
    if db then TargetedList_ApplyBarAppearance(bar, db) end
    return bar
end

local function TargetedList_ReleaseBar(bar)
    TargetedList_ResetBar(nil, bar)
    table.insert(targetedListBarPoolAvailable, bar)
end

-- Legacy shim so existing call sites using targetedListBarPool still
-- function. The pool object exposes Acquire() and Release(bar).
local targetedListBarPool = {
    Acquire = function(self) return TargetedList_AcquireBar() end,
    Release = function(self, bar) return TargetedList_ReleaseBar(bar) end,
}

local function TargetedList_EnsureBarPool()
    TargetedList_EnsureContainer()
    return targetedListBarPool
end

-- ------------------------------------------------------------
-- Bar content application (the secret-safe sink boundary)
-- ------------------------------------------------------------
--
-- This is the ONE function that touches secret-tainted values. It
-- reads them fresh from the API and pipes them directly into
-- Blizzard widget sinks. No values are stored, compared, formatted,
-- or inspected in Lua. If you need to add a new rendered field, do
-- it here and make sure every call goes through a sink.

local function TargetedList_ApplyBarContent(bar, activeRec)
    local casterUnit = activeRec.casterUnit
    local spellId = activeRec.spellId
    local isTest = activeRec.isTestCast

    -- Store casterUnit on the bar for lightweight progress lookups
    -- (the test ticker reads this to find the matching record).
    bar.casterUnit = casterUnit

    -- Spell name: test records store a clean string; live records
    -- pipe the (possibly secret) result through SetText.
    if isTest and activeRec.testSpellName then
        bar.spellName:SetText(activeRec.testSpellName)
    elseif TL_C_Spell_GetSpellName then
        bar.spellName:SetText(TL_C_Spell_GetSpellName(spellId) or "")
    end

    -- Spell texture: same pattern.
    if isTest and activeRec.testSpellTexture then
        bar.icon:SetTexture(activeRec.testSpellTexture)
    elseif TL_C_Spell_GetSpellTexture then
        bar.icon:SetTexture(TL_C_Spell_GetSpellTexture(spellId))
    end

    -- Target name: test records store a clean string; live records
    -- use UnitSpellTargetName (secret-tainted, fed to SetText sink).
    local party = DF.db and DF.db.party
    local arrowPrefix = (party and party.targetedListShowArrowPrefix) and "> " or ""
    local arrowSuffix = (party and party.targetedListShowArrowSuffix) and " <" or ""
    if isTest and activeRec.testTargetName then
        bar.targetName:SetText(arrowPrefix .. activeRec.testTargetName .. arrowSuffix)
    else
        local targetName = TL_UnitSpellTargetName(casterUnit)
        if targetName then
            if arrowPrefix ~= "" or arrowSuffix ~= "" then
                bar.targetName:SetFormattedText("%s%s%s", arrowPrefix, targetName, arrowSuffix)
            else
                bar.targetName:SetText(targetName)
            end
        else
            bar.targetName:SetText("")
        end
    end

    -- Class color: test records store a clean class string; live
    -- records use UnitSpellTargetClass (secret, through Blizzard sink).
    local useClassColor = party and party.targetedListTargetNameClassColor
    if useClassColor and TL_C_ClassColor and TL_C_ClassColor.GetClassColor then
        local targetClass
        if isTest then
            targetClass = activeRec.testTargetClass
        else
            targetClass = TL_UnitSpellTargetClass(casterUnit)
        end
        if targetClass then
            local color = TL_C_ClassColor.GetClassColor(targetClass)
            if color then
                bar.targetName:SetTextColor(color.r, color.g, color.b, 1)
            end
        else
            bar.targetName:SetTextColor(1, 1, 1, 1)
        end
    else
        bar.targetName:SetTextColor(1, 1, 1, 1)
    end

    -- Progress fill + countdown text:
    -- testFrozenFill provides a direct fill value for static test bars.
    -- Fading records skip fill updates (stays where cast stopped).
    if activeRec.testFrozenFill then
        bar.progress:SetMinMaxValues(0, 1)
        bar.progress:SetValue(activeRec.testFrozenFill)
        bar._testDuration = nil
    elseif activeRec.fadingStartedAt then
        -- Don't update progress. The fill stays where it was.
        bar._testDuration = nil
    elseif isTest and activeRec.testCastDuration then
        local cutoff = activeRec.testInterruptAt or activeRec.testCastDuration
        local elapsed = TL_GetTime() - activeRec.startTime
        local pct = math.min(1, math.max(0, elapsed / cutoff))
        bar.progress:SetMinMaxValues(0, 1)
        bar.progress:SetValue(pct)
        -- Store test timing for OnUpdate duration text
        bar._testDuration = { startTime = activeRec.startTime, totalDuration = cutoff }
    elseif activeRec.duration and bar.progress.SetTimerDuration then
        local direction = (activeRec.isChannel)
            and Enum.StatusBarTimerDirection.RemainingTime
            or Enum.StatusBarTimerDirection.ElapsedTime
        bar.progress:SetTimerDuration(activeRec.duration,
            Enum.StatusBarInterpolation.Immediate, direction)
        bar._testDuration = nil
    end

    -- Interruptible color: test records have a clean bool so we can
    -- use plain SetStatusBarColor. Live records have a secret-tainted
    -- bool → SetVertexColorFromBoolean.
    local interruptibleColor = party and party.targetedListInterruptibleColor
        or {r=1, g=0.2, b=0.2, a=1}
    local uninterruptibleColor = party and party.targetedListUninterruptibleColor
        or {r=0.5, g=0.5, b=0.5, a=1}
    if isTest then
        local c = activeRec.uninterruptible and uninterruptibleColor or interruptibleColor
        bar.progress:SetStatusBarColor(c.r, c.g, c.b, c.a or 1)
    elseif activeRec.uninterruptible ~= nil and bar.progress.GetStatusBarTexture then
        local tex = bar.progress:GetStatusBarTexture()
        if tex and tex.SetVertexColorFromBoolean then
            tex:SetVertexColorFromBoolean(activeRec.uninterruptible,
                uninterruptibleColor, interruptibleColor)
        else
            bar.progress:SetStatusBarColor(
                interruptibleColor.r, interruptibleColor.g,
                interruptibleColor.b, interruptibleColor.a)
        end
    else
        bar.progress:SetStatusBarColor(
            interruptibleColor.r, interruptibleColor.g,
            interruptibleColor.b, interruptibleColor.a)
    end

    -- Important-spells filter at render time. C_Spell.IsSpellImportant
    -- returns a secret-tainted boolean when given a secret spellId,
    -- so we pipe it through SetShownFromBoolean — the secret-safe
    -- sink that accepts a secret bool and toggles shown state.
    -- When the filter is off we just make sure the bar is shown.
    if party and party.targetedListImportantOnly
       and TL_C_Spell_IsSpellImportant
       and bar.SetShownFromBoolean then
        local isImportant = TL_C_Spell_IsSpellImportant(spellId)
        bar:SetShownFromBoolean(isImportant, true, false)
    else
        if bar.SetShownFromBoolean then
            bar:SetShownFromBoolean(true, true, false)
        end
    end

    -- Important-spell glow: reuses the existing InitGlowBorder /
    -- UpdateGlowBorder infrastructure. For test bars we use a stored
    -- testIsImportant flag (since our test spell IDs aren't actually
    -- flagged as important by Blizzard). For live bars we use
    -- SetAlphaFromBoolean with the secret-tainted IsSpellImportant result.
    if bar.highlightFrame then
        if party and party.targetedListHighlightImportant then
            local hc = party.targetedListHighlightColor or {r=1, g=0.8, b=0}
            if DF.InitGlowBorder then DF.InitGlowBorder(bar.highlightFrame) end
            if DF.UpdateGlowBorder then
                DF.UpdateGlowBorder(bar.highlightFrame, 2, hc.r, hc.g, hc.b, 0.8)
            end
            bar.highlightFrame:Show()
            if isTest and activeRec.testIsImportant ~= nil then
                -- Clean bool — use SetShown directly
                bar.highlightFrame:SetShown(activeRec.testIsImportant)
            elseif TL_C_Spell_IsSpellImportant then
                local isImportant = TL_C_Spell_IsSpellImportant(spellId)
                bar.highlightFrame:SetAlphaFromBoolean(isImportant)
            else
                bar.highlightFrame:Hide()
            end
        else
            bar.highlightFrame:Hide()
        end
    end

    -- Text visibility (normal, non-fading state). Fading bars have
    -- their text managed by Step 3 of the incremental Render.
    if not activeRec.fadingStartedAt then
        if bar.interruptText then bar.interruptText:Hide() end
        bar.spellName:SetShown(party and party.targetedListShowSpellName ~= false)
        bar.targetName:SetShown(party and party.targetedListShowTargetName ~= false)
    end

    -- Hide-own-casts filter (non-fading path only).
    if not activeRec.fadingStartedAt then
        if party and party.targetedListHideOwnCasts
           and bar.SetAlphaFromBoolean then
            local isTargetingPlayer = UnitIsUnit(casterUnit .. "target", "player")
            bar:SetAlphaFromBoolean(isTargetingPlayer, 0, 1)
        else
            bar:SetAlpha(1)
        end
    end

    -- Self-target color overlay (non-fading path only).
    if not activeRec.fadingStartedAt then
        if party and party.targetedListSelfTargetColorEnabled
           and bar.selfTargetFrame then
            local sc = party.targetedListSelfTargetColor or {r = 1, g = 0.85, b = 0.1, a = 0.4}
            bar.selfTargetTex:SetColorTexture(sc.r, sc.g, sc.b, sc.a or 0.4)
            if isTest then
                -- Test bars use a clean boolean field
                bar.selfTargetFrame:SetShown(activeRec.testIsTargetingPlayer or false)
            elseif bar.selfTargetFrame.SetShownFromBoolean then
                -- Live bars: UnitIsUnit returns a secret-tainted boolean
                local isTargetingPlayer = UnitIsUnit(casterUnit .. "target", "player")
                bar.selfTargetFrame:SetShownFromBoolean(isTargetingPlayer, true, false)
            end
        elseif bar.selfTargetFrame then
            bar.selfTargetFrame:Hide()
        end
    end
end

-- ------------------------------------------------------------
-- Layout
-- ------------------------------------------------------------

-- Applies the container size, bar dimensions, and stack positioning.
-- Called on every render pass (cheap; just a few SetSize/SetPoint calls).
local function TargetedList_LayoutBars()
    if not targetedListContainer then return end
    local db = DF.db and DF.db.party
    if not db then return end

    local cw, ch = TargetedList_ComputeContainerSize(db)
    local x = db.targetedListX or 0
    local y = db.targetedListY or -10
    targetedListContainer:ClearAllPoints()
    targetedListContainer:SetPoint("CENTER", UIParent, "CENTER", x, y)
    targetedListContainer:SetSize(cw, ch)

    local barW = db.targetedListWidth or 240
    local barH = db.targetedListHeight or 22
    local spacing = db.targetedListSpacing or 2
    local growth = db.targetedListGrowth or "DOWN"

    -- Position each active bar by index. For STATIC sort mode,
    -- activeBars may have nil gaps (released slots) — we use a
    -- numeric for loop and skip nils so bars stay at their
    -- assigned position. The slot index IS the position index.
    local maxBarsLocal = db.targetedListMaxBars or 6
    local maxSlot = #activeBars
    -- For STATIC, the highest slot might exceed #activeBars since
    -- Lua's # operator stops at the first nil. Scan for the real max.
    for i = maxBarsLocal, 1, -1 do
        if activeBars[i] then maxSlot = i; break end
    end

    for i = 1, maxSlot do
        local bar = activeBars[i]
        if bar then
            bar:SetSize(barW, barH)
            bar:ClearAllPoints()
            if growth == "UP" then
                bar:SetPoint("BOTTOM", targetedListContainer, "BOTTOM",
                    0, (i - 1) * (barH + spacing))
            else
                bar:SetPoint("TOP", targetedListContainer, "TOP",
                    0, -(i - 1) * (barH + spacing))
            end
            TargetedList_ApplyBarAppearance(bar, db)
            TargetedList_ApplyTextLayout(bar, db)
            bar:Show()
        end
    end
end

-- ------------------------------------------------------------
-- Render pass
-- ------------------------------------------------------------
--
-- Walks activeTargetedListCasts, acquires a pooled bar for each,
-- applies content via the secret-safe sink function, and lays out.
-- Called from the cast lifecycle after any change to the active set,
-- from UpdateTargetedListLayout when settings change, and from
-- test mode when rebuilding demo bars.

local function TargetedList_ReleaseAllActiveBars()
    for i = #activeBars, 1, -1 do
        local bar = activeBars[i]
        if bar then targetedListBarPool:Release(bar) end
        activeBars[i] = nil
    end
    wipe(casterToBar)
    wipe(casterToSlot)
    nextFreeSlot = 1
end

-- ------------------------------------------------------------
-- Bar style presets
-- ------------------------------------------------------------
-- Each preset is a bundle of individual settings. Picking a preset
-- from the dropdown writes the entire bundle to db and triggers a
-- layout refresh. Individual settings remain user-editable after
-- the bundle is applied — the preset is a one-shot "start from this
-- configuration" action, not a continuous override.

local TARGETEDLIST_STYLE_PRESETS = {
    DEFAULT = {
        targetedListWidth = 240,
        targetedListHeight = 22,
        targetedListSpacing = 2,
        targetedListShowIcon = true,
        targetedListIconPosition = "LEFT",
        targetedListZoomIcon = true,
        targetedListShowSpellName = true,
        targetedListShowTargetName = true,
        targetedListShowDuration = true,
        targetedListShowBorder = true,
        targetedListBackgroundAlpha = 0.6,
        targetedListFontSize = 12,
    },
    COMPACT = {
        targetedListWidth = 200,
        targetedListHeight = 16,
        targetedListSpacing = 1,
        targetedListShowIcon = true,
        targetedListIconPosition = "LEFT",
        targetedListZoomIcon = true,
        targetedListShowSpellName = true,
        targetedListShowTargetName = true,
        targetedListShowDuration = true,
        targetedListShowBorder = true,
        targetedListBackgroundAlpha = 0.6,
        targetedListFontSize = 10,
    },
    DETAILED = {
        targetedListWidth = 280,
        targetedListHeight = 30,
        targetedListSpacing = 3,
        targetedListShowIcon = true,
        targetedListIconPosition = "LEFT",
        targetedListZoomIcon = true,
        targetedListShowSpellName = true,
        targetedListShowTargetName = true,
        targetedListShowDuration = true,
        targetedListShowBorder = true,
        targetedListBackgroundAlpha = 0.7,
        targetedListFontSize = 14,
    },
    MINIMAL = {
        targetedListWidth = 180,
        targetedListHeight = 14,
        targetedListSpacing = 1,
        targetedListShowIcon = false,
        targetedListIconPosition = "LEFT",
        targetedListZoomIcon = true,
        targetedListShowSpellName = true,
        targetedListShowTargetName = true,
        targetedListShowDuration = false,
        targetedListShowBorder = false,
        targetedListBackgroundAlpha = 0.4,
        targetedListFontSize = 10,
    },
}

function DF:ApplyTargetedListPreset(presetName)
    if not TargetedList_IsGateOpen() then return end
    local preset = TARGETEDLIST_STYLE_PRESETS[presetName]
    if not preset then return end
    local party = DF.db and DF.db.party
    if not party then return end

    for k, v in pairs(preset) do
        party[k] = v
    end
    party.targetedListStylePreset = presetName

    DF:UpdateTargetedListLayout()
end

-- ------------------------------------------------------------
-- Fade-out / interrupted-flash ticker
-- ------------------------------------------------------------
-- When a cast stops, its record is marked with fadingStartedAt +
-- fadingDuration instead of being removed immediately. The ticker
-- below re-renders every ~50ms so the bar's alpha/tint can animate.
-- When a fading record's timer expires, the render pass removes it
-- from activeTargetedListCasts. The ticker self-cancels when no
-- fading records remain.

local targetedListFadeTicker = nil

local function TargetedList_HasAnyFadingRecord()
    for _, rec in pairs(activeTargetedListCasts) do
        if rec.fadingStartedAt then return true end
    end
    return false
end

-- Assign to the forward-declared file-local (see State section
-- above). This avoids creating a global and lets OnCastStop's
-- reference resolve to this function via upvalue lookup.
TargetedList_StartFadeTicker = function()
    if targetedListFadeTicker then return end
    if not C_Timer or not C_Timer.NewTicker then return end
    targetedListFadeTicker = C_Timer.NewTicker(0.05, function()
        if not TargetedList_HasAnyFadingRecord() then
            if targetedListFadeTicker then
                targetedListFadeTicker:Cancel()
                targetedListFadeTicker = nil
            end
            return
        end
        if DF._TargetedListRender then
            DF._TargetedListRender()
        end
    end)
end

-- Scratch array reused across renders to avoid per-render allocations.
local targetedListSortBuf = {}

-- Sort comparators. Only NEWEST and OLDEST are currently implemented —
-- other candidates (SHORTEST_REMAINING, INTERRUPTIBLE_FIRST, TARGET_ORDER)
-- would need to inspect secret-tainted values (duration objects,
-- uninterruptible flag, target-name-to-unit resolution) which errors
-- in Lua. startTime is the only clean numeric sort key we have.
local function TargetedList_SortNewestFirst(a, b)
    return (a.startTime or 0) > (b.startTime or 0)
end
local function TargetedList_SortOldestFirst(a, b)
    return (a.startTime or 0) < (b.startTime or 0)
end

-- ============================================================
-- INCREMENTAL RENDER (TS3-style)
-- ============================================================
-- Instead of tearing down and rebuilding ALL bars every state
-- change, bars persist in casterToBar[unit]. Render:
--   1. Expires completed fades (release that one bar)
--   2. Ensures every live record has a bar (acquire if missing)
--   3. Updates fading bars' alpha/color in-place
--   4. Sorts and repositions — no pool churn
--
-- Content (ApplyBarContent) runs ONCE at acquisition. Subsequent
-- renders only touch alpha/color for fading bars and re-anchor
-- positions via LayoutBars.

local function TargetedList_Render()
    if not TargetedList_IsGateOpen() then return end
    TargetedList_EnsureBarPool()

    local db = DF.db and DF.db.party
    local maxBars = (db and db.targetedListMaxBars) or 6
    local now = TL_GetTime()

    -- Step 1: expire fading records whose window elapsed.
    -- Free their bar and slot.
    for unit, rec in pairs(activeTargetedListCasts) do
        if rec.fadingStartedAt
           and (now - rec.fadingStartedAt) >= (rec.fadingDuration or 0) then
            activeTargetedListCasts[unit] = nil
            local bar = casterToBar[unit]
            if bar then
                targetedListBarPool:Release(bar)
                casterToBar[unit] = nil
            end
            casterToSlot[unit] = nil
        end
    end

    -- Step 1b: release orphaned bars. A bar is orphaned when its
    -- record was removed directly (e.g. fadeDuration == 0 in OnCastStop)
    -- rather than through the fading path. Without this, the bar stays
    -- visible in casterToBar with no record to drive its removal.
    for unit, bar in pairs(casterToBar) do
        if not activeTargetedListCasts[unit] then
            targetedListBarPool:Release(bar)
            casterToBar[unit] = nil
            casterToSlot[unit] = nil
        end
    end

    -- Step 2: ensure every live record has a bar. Assign a slot index
    -- for STATIC sort order — the slot persists for the record's
    -- lifetime so its bar never changes position.
    for unit, rec in pairs(activeTargetedListCasts) do
        if not casterToBar[unit] then
            local bar = targetedListBarPool:Acquire()
            casterToBar[unit] = bar

            -- Find the lowest available slot for STATIC mode.
            -- For non-STATIC modes the slot is unused but harmless.
            if not casterToSlot[unit] then
                -- Find lowest unused slot
                local slot = 1
                local usedSlots = {}
                for _, s in pairs(casterToSlot) do usedSlots[s] = true end
                while usedSlots[slot] do slot = slot + 1 end
                casterToSlot[unit] = slot
            end

            TargetedList_ApplyBarContent(bar, rec)
        end
    end

    -- Step 3: update fading bars' visual state (alpha + color + text).
    for unit, rec in pairs(activeTargetedListCasts) do
        if rec.fadingStartedAt then
            local bar = casterToBar[unit]
            if bar then
                local elapsed = now - rec.fadingStartedAt
                local dur = rec.fadingDuration or 0.25
                local pct = 1 - math.min(1, math.max(0, elapsed / dur))
                bar:SetAlpha(pct)
                if rec.wasInterrupted then
                    -- Snap fill to full. SetTimerDuration hands the fill
                    -- animation to the StatusBar engine, which keeps ticking
                    -- after the cast stops. SetValue overrides the timer and
                    -- freezes the bar at the interrupted-flash position.
                    bar.progress:SetMinMaxValues(0, 1)
                    bar.progress:SetValue(1)
                    bar.progress:SetStatusBarColor(1, 0.95, 0.2, 1)
                    if bar.interruptText then
                        bar.spellName:Hide()
                        bar.targetName:Hide()
                        if bar.duration then bar.duration:Hide() end
                        if rec.isTestCast and rec.testInterrupterName then
                            bar.interruptText:SetText("Interrupted: " .. rec.testInterrupterName)
                            -- Class-color the test interrupter name
                            if rec.testInterrupterClass and TL_C_ClassColor
                               and TL_C_ClassColor.GetClassColor then
                                local col = TL_C_ClassColor.GetClassColor(rec.testInterrupterClass)
                                if col then
                                    bar.interruptText:SetTextColor(col.r, col.g, col.b, 1)
                                end
                            end
                        elseif rec.interrupterGuid and TL_UnitNameFromGUID then
                            -- UnitNameFromGUID returns a secret-tainted string,
                            -- piped through SetFormattedText (secret-safe sink)
                            bar.interruptText:SetFormattedText("Interrupted: %s",
                                TL_UnitNameFromGUID(rec.interrupterGuid) or "")
                            if TL_UnitClassFromGUID and TL_C_ClassColor
                               and TL_C_ClassColor.GetClassColor then
                                local _, iClass = TL_UnitClassFromGUID(
                                    rec.interrupterGuid)
                                if iClass then
                                    local col = TL_C_ClassColor.GetClassColor(iClass)
                                    if col then
                                        bar.interruptText:SetTextColor(
                                            col.r, col.g, col.b, 1)
                                    end
                                end
                            end
                        end
                        bar.interruptText:Show()
                    end
                end
            end
        end
    end

    -- Step 4: sort and build the ordered activeBars list.
    local sortOrder = (db and db.targetedListSortOrder) or "NEWEST"

    wipe(activeBars)
    local count = 0

    if sortOrder == "STATIC" then
        -- Slot-based positioning: each bar has a fixed slot index
        -- assigned at acquisition. Bars never shift. Gaps are left
        -- when a bar is removed.
        for unit, rec in pairs(activeTargetedListCasts) do
            local slot = casterToSlot[unit]
            local bar = casterToBar[unit]
            if bar and slot and slot <= maxBars then
                activeBars[slot] = bar
                bar:Show()
                if slot > count then count = slot end
            elseif bar then
                bar:Hide()
            end
        end
    else
        -- Sort-based positioning: gather, sort, assign sequentially.
        wipe(targetedListSortBuf)
        for unit, rec in pairs(activeTargetedListCasts) do
            targetedListSortBuf[#targetedListSortBuf + 1] = rec
        end

        if sortOrder == "OLDEST" then
            table.sort(targetedListSortBuf, TargetedList_SortOldestFirst)
        else
            table.sort(targetedListSortBuf, TargetedList_SortNewestFirst)
        end

        for i = 1, #targetedListSortBuf do
            local rec = targetedListSortBuf[i]
            local bar = casterToBar[rec.casterUnit]
            if bar then
                count = count + 1
                if count <= maxBars then
                    activeBars[count] = bar
                    bar:Show()
                else
                    bar:Hide()
                end
            end
        end
        wipe(targetedListSortBuf)
    end

    -- Step 5: position and show container.
    if targetedListContainer then
        if count > 0 then
            targetedListContainer:Show()
        else
            targetedListContainer:Hide()
        end
    end

    TargetedList_LayoutBars()
end

-- Re-export so the cast lifecycle can trigger a render after
-- modifying activeTargetedListCasts.
DF._TargetedListRender = TargetedList_Render

-- Cast-to-channel transition: re-apply bar content so SetTimerDuration
-- picks up the new channel duration. Called from ProcessCastStart which
-- runs before casterToBar and ApplyBarContent are defined.
DF._TargetedListTransitionToChannel = function(casterUnit, rec)
    local bar = casterToBar[casterUnit]
    if bar then
        TargetedList_ApplyBarContent(bar, rec)
    end
end

-- ------------------------------------------------------------
-- Mover
-- ------------------------------------------------------------

local targetedListMover = nil

local function TargetedList_CreateMover()
    if targetedListMover then return targetedListMover end
    TargetedList_EnsureContainer()

    local mover = CreateFrame("Frame", "DandersFramesTargetedListMover", UIParent, "BackdropTemplate")
    mover:SetFrameStrata("DIALOG")
    mover:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    mover:SetBackdropColor(1.0, 0.5, 0.2, 0.3)
    mover:SetBackdropBorderColor(1.0, 0.5, 0.2, 0.8)
    mover:EnableMouse(true)
    mover:SetMovable(true)
    mover:RegisterForDrag("LeftButton")
    mover:Hide()

    local label = mover:CreateFontString(nil, "OVERLAY", "DFFontNormal")
    label:SetPoint("CENTER")
    label:SetText("Targeted List")
    label:SetTextColor(1, 1, 1, 1)
    mover.label = label

    -- Left-click switches the shared position panel to our mode.
    mover:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("targetedList")
        end
    end)

    mover:SetScript("OnDragStart", function(self)
        -- Also switch mode on drag start so the panel reflects our
        -- position live as the user nudges.
        if DF.SetPositionPanelMode then
            DF:SetPositionPanelMode("targetedList")
        end
        self:StartMoving()
        local db = DF:GetDB()
        self:SetScript("OnUpdate", function()
            local sw, sh = GetScreenWidth(), GetScreenHeight()
            local cx, cy = self:GetCenter()
            if cx and cy then
                local x, y = cx - sw / 2, cy - sh / 2
                -- Live-follow: keep container glued to mover while dragging
                if targetedListContainer then
                    targetedListContainer:ClearAllPoints()
                    targetedListContainer:SetPoint("CENTER", UIParent, "CENTER", x, y)
                end
                -- Snap preview (matches personal mover behavior)
                if db.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown()
                   and DF.UpdateSnapPreview then
                    DF:UpdateSnapPreview(self)
                end
            end
        end)
    end)

    mover:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self:SetScript("OnUpdate", nil)
        if DF.HideSnapPreview then DF:HideSnapPreview() end

        local sw, sh = GetScreenWidth(), GetScreenHeight()
        local cx, cy = self:GetCenter()
        if not cx or not cy then return end
        local x, y = cx - sw / 2, cy - sh / 2

        -- Snap to grid if enabled, mirroring the personal mover.
        local db = DF:GetDB()
        if db.snapToGrid and DF.gridFrame and DF.gridFrame:IsShown()
           and DF.SnapToGrid then
            x, y = DF:SnapToGrid(x, y)
        end

        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", x, y)
        if DF.db and DF.db.party then
            DF.db.party.targetedListX = x
            DF.db.party.targetedListY = y
        end
        DF:UpdateTargetedListLayout()
    end)

    -- Right-click anywhere on the mover locks everything (same as
    -- the personal targeted spells mover and the main mover frame).
    mover:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" and DF.LockFrames then
            DF:LockFrames()
        end
    end)

    targetedListMover = mover
    DF.targetedListMoverFrame = mover  -- exposed for position panel apply()
    return mover
end

function DF:ShowTargetedListMover()
    if not TargetedList_IsGateOpen() then return end
    TargetedList_CreateMover()
    local db = DF.db and DF.db.party
    if not db then return end
    local w, h = TargetedList_ComputeContainerSize(db)
    targetedListMover:SetSize(w, h)
    targetedListMover:ClearAllPoints()
    targetedListMover:SetPoint("CENTER", UIParent, "CENTER",
        db.targetedListX or 0, db.targetedListY or -10)
    targetedListMover:Show()
    -- Show test bars alongside the mover so users can see the
    -- actual bar layout while positioning.
    DF:ShowTestTargetedList()
end

function DF:HideTargetedListMover()
    if targetedListMover then
        targetedListMover:Hide()
    end
    DF:HideTestTargetedList()
end

-- ------------------------------------------------------------
-- Test mode
-- ------------------------------------------------------------
--
-- Synthetic bars driven from DF.TestData.units (the 5 test party
-- names) and a fixed list of real spell IDs. Bypasses the live-cast
-- lifecycle entirely — test mode just acquires pooled bars, fills
-- them with clean test data, and lays them out.
--
-- Unlike live casts, test spellIds are CLEAN (they're literals in
-- our code, not coming from UnitCastingInfo), so we can use them
-- freely for formatting if needed.

local TARGETED_LIST_TEST_SPELLS = {
    -- {spellId, isChannel, isImportant (always true for demo), uninterruptible}
    {spellId = 196408, isChannel = false, uninterruptible = false},  -- Focused Assault
    {spellId = 260189, isChannel = true,  uninterruptible = false},  -- Grasping Tendrils
    {spellId = 204242, isChannel = false, uninterruptible = true},   -- Solar Beam
    {spellId = 207982, isChannel = false, uninterruptible = false},  -- Mortal Strike
    {spellId = 205708, isChannel = true,  uninterruptible = false},  -- Chilled
    {spellId = 229714, isChannel = false, uninterruptible = true},   -- Death Bolt
}

local function TargetedList_GetTestTargetName(index)
    local units = DF.TestData and DF.TestData.units
    if not units or #units == 0 then return "Target" end
    local u = units[((index - 1) % #units) + 1]
    return u and u.name or "Target"
end

local function TargetedList_GetTestTargetClass(index)
    local units = DF.TestData and DF.TestData.units
    if not units or #units == 0 then return nil end
    local u = units[((index - 1) % #units) + 1]
    return u and u.class or nil
end

-- ============================================================
-- Test mode: fake event generator
-- ============================================================
-- Instead of pre-allocating bars and animating them in-place,
-- test mode periodically spawns fake cast records into
-- activeTargetedListCasts. The normal render pipeline handles
-- everything — sorting, layout, bar acquisition, content, fade.
-- This means test mode looks exactly like live play: bars appear,
-- shift, sort, fade out, and flash on interrupt.

local targetedListTestTicker = nil
local targetedListTestNextId = 1  -- incrementing key for test records

-- Spawn a new fake cast record. Called periodically by the ticker.
local function TargetedList_SpawnTestCast()
    local db = DF.db and DF.db.party
    if not db then return end

    -- Pick a test spell and target
    local idx = ((targetedListTestNextId - 1) % #TARGETED_LIST_TEST_SPELLS) + 1
    local spec = TARGETED_LIST_TEST_SPELLS[idx]
    local tIdx = ((targetedListTestNextId - 1) % 5) + 1
    local targetName = TargetedList_GetTestTargetName(tIdx)
    local targetClass = TargetedList_GetTestTargetClass(tIdx)

    -- Clean spell metadata
    local spellName = TL_C_Spell_GetSpellName and TL_C_Spell_GetSpellName(spec.spellId) or "Test Spell"
    local spellTexture = TL_C_Spell_GetSpellTexture and TL_C_Spell_GetSpellTexture(spec.spellId)

    local castDuration = 2 + (targetedListTestNextId % 5) * 1.0  -- 2-6s
    local willInterrupt = (targetedListTestNextId % 3 == 0)
    local key = "test-" .. targetedListTestNextId
    targetedListTestNextId = targetedListTestNextId + 1

    -- Interrupted casts trigger at 40-80% of their duration so they
    -- look like real mid-cast interrupts, not completed-then-interrupted.
    local interruptAt = nil
    if willInterrupt then
        interruptAt = castDuration * (0.4 + (targetedListTestNextId % 5) * 0.1)
    end

    activeTargetedListCasts[key] = {
        isTestCast       = true,
        spellId          = spec.spellId,
        isChannel        = spec.isChannel or false,
        startTime        = TL_GetTime(),
        casterUnit       = key,  -- fake unit token
        uninterruptible  = spec.uninterruptible or false,
        -- Test-specific clean fields (bypasses secret-value APIs)
        testSpellName    = spellName,
        testSpellTexture = spellTexture,
        testTargetName   = targetName,
        testTargetClass  = targetClass,
        testCastDuration = castDuration,
        testWillInterrupt = willInterrupt,
        testInterruptAt  = interruptAt,
        -- Fake interrupter name + class for display during interrupted flash
        testInterrupterName = willInterrupt and targetName or nil,
        testInterrupterClass = willInterrupt and targetClass or nil,
        -- Alternate importance: odd-numbered casts are "important"
        testIsImportant = (targetedListTestNextId % 2 == 0),
        -- Alternate self-targeting: every 3rd cast targets the player
        testIsTargetingPlayer = (targetedListTestNextId % 3 == 1),
    }
    -- NOTE: caller is responsible for calling TargetedList_Render()
    -- after all spawns/modifications are done. This avoids premature
    -- bar acquisition before static-mode record modifications.
end

-- Lightweight progress update for test bars. Only touches SetValue
-- on existing bars — no bar rebuild, no pool churn. This is what
-- runs every tick for smooth fill animation.
local function TargetedList_UpdateTestProgress()
    -- Iterate all tracked bars via casterToBar (not activeBars which
    -- may have nil gaps in STATIC mode that ipairs would skip).
    local now = TL_GetTime()
    for unit, bar in pairs(casterToBar) do
        local rec = activeTargetedListCasts[unit]
        if rec and rec.isTestCast and rec.testCastDuration
           and not rec.fadingStartedAt and not rec.testFrozenFill then
            local cutoff = rec.testInterruptAt or rec.testCastDuration
            local elapsed = now - rec.startTime
            local pct = math.min(1, math.max(0, elapsed / cutoff))
            bar.progress:SetMinMaxValues(0, 1)
            bar.progress:SetValue(pct)
        end
    end
end

-- Check test casts and transition them to fading when their cast
-- duration elapses. Called by the test ticker. Only triggers a full
-- Render on state transitions (cast finished → fading), not every tick.
local function TargetedList_UpdateTestCasts()
    local db = DF.db and DF.db.party
    if not db then return end
    local now = TL_GetTime()
    local fadeDuration = db.targetedListFadeOutDuration or 0.25
    local flashDuration = db.targetedListInterruptedFlashDuration or 1.0
    local needsRender = false

    for key, rec in pairs(activeTargetedListCasts) do
        if rec.isTestCast and not rec.fadingStartedAt then
            local elapsed = now - rec.startTime
            local cutoff = rec.testInterruptAt or rec.testCastDuration or 3
            if elapsed >= cutoff then
                local wasInt = rec.testWillInterrupt
                rec.fadingStartedAt = now
                rec.fadingDuration = wasInt and flashDuration or fadeDuration
                rec.wasInterrupted = wasInt
                needsRender = true
                TargetedList_StartFadeTicker()
            end
        end
    end

    -- Only re-render if a cast actually transitioned to fading.
    -- The fade ticker handles continuous alpha updates separately.
    if needsRender then
        TargetedList_Render()
    end
end

function DF:ShowTestTargetedList()
    if not TargetedList_IsGateOpen() then return end

    -- FIRST: cancel any running ticker from a previous mode. This
    -- prevents animated-mode tickers from interfering with static mode.
    if targetedListTestTicker then
        targetedListTestTicker:Cancel()
        targetedListTestTicker = nil
    end
    -- Also cancel the fade ticker to prevent stale fade renders
    if targetedListFadeTicker then
        targetedListFadeTicker:Cancel()
        targetedListFadeTicker = nil
    end

    targetedListTestActive = true
    TargetedList_EnsureContainer()
    TargetedList_EnsureBarPool()

    -- Clear ALL existing test records AND their bars from casterToBar
    for key in pairs(activeTargetedListCasts) do
        if type(key) == "string" and key:sub(1, 5) == "test-" then
            activeTargetedListCasts[key] = nil
            local bar = casterToBar[key]
            if bar then
                targetedListBarPool:Release(bar)
                casterToBar[key] = nil
            end
        end
    end
    wipe(activeBars)
    targetedListTestNextId = 1

    local db = DF.db and DF.db.party
    local maxBars = (db and db.targetedListMaxBars) or 6
    local animate = db and db.testAnimateTargetedList

    if animate then
        -- Animated mode: spawn initial batch staggered, ticker manages lifecycle
        local initialCount = math.min(maxBars, 4)
        for i = 1, initialCount do
            TargetedList_SpawnTestCast()
        end
        TargetedList_Render()

        -- Ticker spawns new casts and manages lifecycle.
        if not targetedListTestTicker and C_Timer and C_Timer.NewTicker then
            local spawnInterval = 2.0
            local spawnTimer = 0
            targetedListTestTicker = C_Timer.NewTicker(0.05, function()
                if not targetedListTestActive then
                    if targetedListTestTicker then
                        targetedListTestTicker:Cancel()
                        targetedListTestTicker = nil
                    end
                    return
                end

                -- Check for cast completions / interrupts
                TargetedList_UpdateTestCasts()

                -- Lightweight progress fill update (no bar rebuild)
                TargetedList_UpdateTestProgress()

                -- Periodically spawn new casts
                spawnTimer = spawnTimer + 0.05
                if spawnTimer >= spawnInterval then
                    spawnTimer = 0
                    local count = 0
                    for _, rec in pairs(activeTargetedListCasts) do
                        if rec.isTestCast and not rec.fadingStartedAt then
                            count = count + 1
                        end
                    end
                    if count < ((DF.db and DF.db.party and DF.db.party.targetedListMaxBars) or 6) then
                        TargetedList_SpawnTestCast()
                        TargetedList_Render()
                    end
                end
            end)
        end
    else
        -- Static mode: showcase all visual states for customisation.
        -- Bars show a mix of: normal casting (interruptible +
        -- uninterruptible), interrupted (with interrupter name), and
        -- important glow. Each bar is frozen at a varied fill point.
        for i = 1, maxBars do
            TargetedList_SpawnTestCast()
            local key = "test-" .. (targetedListTestNextId - 1)
            local rec = activeTargetedListCasts[key]
            if rec then
                -- Freeze the bar at a varied fill point. We store this
                -- directly rather than using time math (which broke when
                -- testCastDuration was set to 99999 making elapsed/dur ≈ 0).
                rec.testFrozenFill = 0.2 + ((i - 1) * 0.12) % 0.6
                rec.testCastDuration = 99999
                rec.testInterruptAt = nil
                rec.testWillInterrupt = false

                -- Distribute visual states across the bars:
                -- Bar 3 (if maxBars >= 3) or last bar: show as interrupted
                if maxBars >= 3 and i == 3 then
                    rec.fadingStartedAt = TL_GetTime()
                    rec.fadingDuration = 99999  -- never expires in static
                    rec.wasInterrupted = true
                    rec.testFrozenFill = 0.55   -- partial fill on interrupt
                    rec.testInterrupterName = TargetedList_GetTestTargetName(
                        ((i + 1) % 5) + 1)
                    rec.testInterrupterClass = TargetedList_GetTestTargetClass(
                        ((i + 1) % 5) + 1)
                elseif i == maxBars and maxBars ~= 3 then
                    rec.fadingStartedAt = TL_GetTime()
                    rec.fadingDuration = 99999
                    rec.wasInterrupted = true
                    rec.testFrozenFill = 0.7
                    rec.testInterrupterName = TargetedList_GetTestTargetName(
                        ((i + 2) % 5) + 1)
                    rec.testInterrupterClass = TargetedList_GetTestTargetClass(
                        ((i + 2) % 5) + 1)
                end
            end
        end
        TargetedList_Render()
    end
end

function DF:HideTestTargetedList()
    targetedListTestActive = false
    -- Cancel the test ticker
    if targetedListTestTicker then
        targetedListTestTicker:Cancel()
        targetedListTestTicker = nil
    end
    -- Remove test records and release their bars + slots individually
    for key in pairs(activeTargetedListCasts) do
        if type(key) == "string" and key:sub(1, 5) == "test-" then
            activeTargetedListCasts[key] = nil
            local bar = casterToBar[key]
            if bar then
                targetedListBarPool:Release(bar)
                casterToBar[key] = nil
            end
            casterToSlot[key] = nil
        end
    end
    -- Rebuild activeBars from remaining live records
    wipe(activeBars)
    local count = 0
    for unit, bar in pairs(casterToBar) do
        count = count + 1
        activeBars[count] = bar
    end
    if targetedListContainer then
        if count > 0 then
            TargetedList_LayoutBars()
        else
            targetedListContainer:Hide()
        end
    end
end

-- Called from ReleaseAllBars (the lifecycle path) so it also tears
-- down the visible bars including any test records.
local _TargetedList_ReleaseAllBars_Prev = TargetedList_ReleaseAllBars
TargetedList_ReleaseAllBars = function()
    if not TargetedList_IsGateOpen() then return end
    _TargetedList_ReleaseAllBars_Prev()
    TargetedList_ReleaseAllActiveBars()
    if targetedListContainer then
        targetedListContainer:Hide()
    end
end
DF._TargetedListReleaseAllBars = TargetedList_ReleaseAllBars

-- ------------------------------------------------------------
-- Hook the cast lifecycle to trigger renders
-- ------------------------------------------------------------
--
-- DelayedPickup and OnCastStop already modify activeTargetedListCasts.
-- We re-wrap them with a post-modification render trigger. Test mode
-- and live casts both share the same render pipeline, so no guards.

local _TargetedList_DelayedPickup_Prev = TargetedList_DelayedPickup
TargetedList_DelayedPickup = function(...)
    _TargetedList_DelayedPickup_Prev(...)
    TargetedList_Render()
end

local _TargetedList_OnCastStop_Prev = TargetedList_OnCastStop
TargetedList_OnCastStop = function(...)
    _TargetedList_OnCastStop_Prev(...)
    TargetedList_Render()
end

local _TargetedList_OnInterruptibility_Prev = TargetedList_OnInterruptibilityChange
TargetedList_OnInterruptibilityChange = function(...)
    _TargetedList_OnInterruptibility_Prev(...)
    TargetedList_Render()
end

DF._TargetedListProcessCastStart = TargetedList_ProcessCastStart
DF._TargetedListOnCastStop = TargetedList_OnCastStop
DF._TargetedListOnCastUpdate = TargetedList_OnCastUpdate
DF._TargetedListOnInterruptibilityChange = TargetedList_OnInterruptibilityChange
DF._TargetedListOnTargetChange = TargetedList_OnTargetChange
DF._TargetedListValidateAll = TargetedList_ValidateTrackedBars

-- ------------------------------------------------------------
-- Public entry points
-- ------------------------------------------------------------

-- Called from DF:InitTargetedSpells() at addon init and from the
-- settings toggle callback. Safe to call on stable (no-op via gate).
function DF:InitTargetedList()
    if not TargetedList_IsGateOpen() then return end
    -- Create the container early so the mover / test mode have
    -- something to anchor to. Bar pool stays lazy.
    TargetedList_EnsureContainer()
end

-- Called from the settings-apply path. Bumps the layout version and
-- triggers a re-layout. Safe to call on every callback.
function DF:UpdateTargetedListLayout()
    if not TargetedList_IsGateOpen() then return end
    targetedListLayoutVersion = targetedListLayoutVersion + 1
    -- Re-apply appearance + content to all existing bars so settings
    -- changes (font, texture, border, etc.) take effect on bars that
    -- are already acquired (the incremental render only applies
    -- content at acquisition time, not on every render tick).
    local db = DF.db and DF.db.party
    for unit, bar in pairs(casterToBar) do
        local rec = activeTargetedListCasts[unit]
        if rec then
            TargetedList_ApplyBarContent(bar, rec)
        end
    end
    TargetedList_Render()
    -- Also resize the mover if it's visible
    if targetedListMover and targetedListMover:IsShown() then
        local db = DF.db and DF.db.party
        if db then
            local w, h = TargetedList_ComputeContainerSize(db)
            targetedListMover:SetSize(w, h)
        end
    end
end

-- Lightweight updates for color picker drag. These only touch the
-- specific visual property on existing bars — no layout rebuild, no
-- pool churn, no content re-application. Designed to run at color-
-- picker drag-tick rate without lag.

function DF:LightweightUpdateTargetedListBarColor()
    if not TargetedList_IsGateOpen() then return end
    local db = DF.db and DF.db.party
    if not db then return end
    local interColor = db.targetedListInterruptibleColor or {r=1, g=0.2, b=0.2, a=1}
    local uninterColor = db.targetedListUninterruptibleColor or {r=0.5, g=0.5, b=0.5, a=1}
    for unit, bar in pairs(casterToBar) do
        local rec = activeTargetedListCasts[unit]
        if rec and not rec.fadingStartedAt then
            if rec.isTestCast then
                local c = rec.uninterruptible and uninterColor or interColor
                bar.progress:SetStatusBarColor(c.r, c.g, c.b, c.a or 1)
            elseif rec.uninterruptible ~= nil then
                local tex = bar.progress:GetStatusBarTexture()
                if tex and tex.SetVertexColorFromBoolean then
                    tex:SetVertexColorFromBoolean(rec.uninterruptible,
                        uninterColor, interColor)
                end
            end
        end
    end
end

function DF:LightweightUpdateTargetedListBorderColor()
    if not TargetedList_IsGateOpen() then return end
    local db = DF.db and DF.db.party
    if not db then return end
    local bc = db.targetedListBorderColor or {r=0, g=0, b=0, a=1}
    for _, bar in pairs(casterToBar) do
        if bar.border and bar.border:IsShown() then
            bar.border:SetBackdropBorderColor(bc.r, bc.g, bc.b, bc.a or 1)
        end
    end
end

function DF:LightweightUpdateTargetedListHighlightColor()
    if not TargetedList_IsGateOpen() then return end
    local db = DF.db and DF.db.party
    if not db then return end
    local hc = db.targetedListHighlightColor or {r=1, g=0.8, b=0}
    for _, bar in pairs(casterToBar) do
        if bar.highlightFrame and bar.highlightFrame:IsShown() then
            if DF.UpdateGlowBorder then
                DF.UpdateGlowBorder(bar.highlightFrame, 2, hc.r, hc.g, hc.b, 0.8)
            end
        end
    end
end

-- Called from the settings-apply path when the enable checkbox flips.
function DF:ToggleTargetedList(enabled)
    if not TargetedList_IsGateOpen() then return end
    if enabled then
        DF:InitTargetedList()
        TargetedList_Render()
    else
        TargetedList_ReleaseAllBars()
    end
    -- Re-evaluate shared event registration — the cast event frame
    -- may need to turn on/off depending on other consumers.
    DF:UpdateTargetedSpellEventRegistration()
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

function DF:InitTargetedSpells()
    local db = DF:GetDB()

    -- Group-frame Targeted Spells is permanently disabled (Blizzard's
    -- 2026-04-07 UnitIsUnit hotfix). Force the user-facing setting off
    -- so the GUI reflects reality every load — DF.GroupTargetedSpellsAPIBlocked
    -- is set unconditionally at the top of this file.
    ForceDisableGroupTargetedSpellSettings()

    -- Group-side enable path is no longer reachable — only events for
    -- the personal display are registered (handled by
    -- UpdateTargetedSpellEventRegistration below).

    -- Apply nameplate offscreen setting if enabled
    if db.targetedSpellNameplateOffscreen then
        DF:SetNameplateOffscreen(true)
    end

    -- Initialize personal targeted spells. Note: TogglePersonalTargetedSpells
    -- only manages the container/icons; the events that drive cast tracking
    -- are registered separately so personal display can run even when the
    -- group-frame feature is off or API-blocked.
    if db.personalTargetedSpellEnabled then
        DF:TogglePersonalTargetedSpells(true)
    end

    -- Initialize the Targeted List. Safe to call unconditionally — the
    -- function is gated internally on the user's targetedListEnabled setting.
    if DF.InitTargetedList then
        DF:InitTargetedList()
    end

    DF:UpdateTargetedSpellEventRegistration()
end
